#!/usr/bin/env python3
"""仓库结构索引器。

功能：
1. 扫描 ArkTS / TypeScript / JavaScript 类源码文件；
2. 初始化 SQLite 索引库，至少落 `snapshots`、`nodes`、`edges` 三张核心表；
3. 优先尝试使用 tree-sitter 解析，若环境不可用则自动退化到内置 Regex 后备解析器；
4. 提取文件节点、类节点、函数节点、导入依赖、调用依赖与风险标签；
5. 为后续 Repo Map 生成与 Translation Unit 计算提供事实底座。

说明：
- 脚本本身仅依赖 Python 标准库，可直接运行；
- tree-sitter 与 tree_sitter_languages 为可选依赖；
- 若 tree-sitter 不可用，脚本会自动使用内置后备解析器，保证流程完整可执行。
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import re
import sqlite3
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, Iterable, Iterator, List, Optional, Sequence, Tuple

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DB_PATH = PROJECT_ROOT / "artifacts" / "repo_index.sqlite"
DEFAULT_EXTENSIONS = (".ts", ".tsx", ".js", ".jsx", ".ets", ".arkts")
DEFAULT_EXCLUDE_DIRS = {
    ".git",
    ".hg",
    ".svn",
    "node_modules",
    ".idea",
    ".vscode",
    "dist",
    "build",
    "out",
    "coverage",
    "__pycache__",
}
IMPORT_RE = re.compile(
    r"(?:import|export)\s+(?:type\s+)?(?P<body>.*?)\s+from\s+[\"'](?P<source>[^\"']+)[\"']",
    re.DOTALL,
)
SIDE_EFFECT_IMPORT_RE = re.compile(r"import\s+[\"'](?P<source>[^\"']+)[\"']")
CLASS_RE = re.compile(r"\bclass\s+(?P<name>[A-Za-z_][A-Za-z0-9_]*)")
INTERFACE_RE = re.compile(r"\binterface\s+(?P<name>[A-Za-z_][A-Za-z0-9_]*)")
FUNCTION_RE = re.compile(r"\bfunction\s+(?P<name>[A-Za-z_][A-Za-z0-9_]*)\s*\(")
ARROW_RE = re.compile(
    r"(?:const|let|var)\s+(?P<name>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?:async\s*)?(?:\([^\)]*\)|[A-Za-z_][A-Za-z0-9_]*)\s*=>"
)
METHOD_RE = re.compile(
    r"""
    ^(?P<indent>\s*)
    (?:(?:public|private|protected|readonly|declare|abstract|override|static)\s+)*
    (?:async\s+)?
    (?P<name>[A-Za-z_][A-Za-z0-9_]*)
    \s*(?:<[^\n\r{}()]*>)?
    \s*\(
    """,
    re.MULTILINE | re.VERBOSE,
)
CALL_RE = re.compile(r"(?P<name>[A-Za-z_][A-Za-z0-9_]*)\s*\(")
STATE_TAG_PATTERNS = {
    "state-decorator": re.compile(r"@(State|Observed|ObjectLink|StorageLink|StorageProp|Provide|Consume)\b"),
    "signal-or-store": re.compile(r"\b(Signal|Store|useState|createSignal|computed|observable)\b"),
    "persistence": re.compile(r"\b(preferences|storage|cache|persist|restore|save|load)\b", re.IGNORECASE),
}
THREAD_TAG_PATTERNS = {
    "async-flow": re.compile(r"\b(async|await|Promise|setTimeout|setInterval|postTask|queueMicrotask)\b"),
    "main-thread-ui": re.compile(r"\b(UIContext|promptAction|animateTo|build\s*\()\b"),
    "callback-entry": re.compile(r"\b(onClick|onAppear|onDisAppear|then\s*\(|catch\s*\()\b"),
}
INTEROP_TAG_PATTERNS = {
    "ffi": re.compile(r"\b(ffi|FFI|CPointer|Pointer|CType|extern)\b"),
    "napi": re.compile(r"\b(napi|NAPI|native|Native)\b"),
    "tdlib": re.compile(r"\b(td_|TDLib|telegram)\b"),
}
UI_TAG_PATTERNS = {
    "routing": re.compile(r"\b(router\.|Navigation|pushUrl|replaceUrl|back\()\b"),
    "list-or-grid": re.compile(r"\b(List|Grid|LazyForEach|ForEach|WaterFlow|Tabs)\b"),
    "virtualization": re.compile(r"\b(virtual|recycle|batch|delta|timeline)\b", re.IGNORECASE),
}
SEMANTIC_RISK_PATTERNS = {
    "[ASYNC_FLOW]": re.compile(r"\b(async|await|Promise|AsyncGenerator|then|catch|finally|setTimeout|setInterval|queueMicrotask|postTask)\b"),
    "[BINARY_PROTO]": re.compile(r"\b(ArrayBuffer|Uint8Array|Uint16Array|Uint32Array|Int8Array|Int16Array|Int32Array|DataView|TLStream|TLSerializer|TLDeserializer)\b"),
}
CONTROL_KEYWORDS = {
    "if",
    "for",
    "while",
    "switch",
    "catch",
    "return",
    "new",
    "super",
    "typeof",
    "function",
}


@dataclass
class ImportRecord:
    source: str
    names: List[str] = field(default_factory=list)
    symbol_bindings: List[Dict[str, object]] = field(default_factory=list)
    is_type_only: bool = False
    is_runtime: bool = True
    line: int = 1


@dataclass
class CallRecord:
    caller_name: str
    callee_name: str
    line: int
    caller_kind: str = ""
    caller_line_start: int = 0
    callee_expression: str = ""
    receiver_text: str = ""
    receiver_root: str = ""
    is_async_boundary: bool = False
    is_ui_handoff: bool = False


@dataclass
class SymbolRecord:
    name: str
    kind: str
    line_start: int
    line_end: int
    signature: str
    visibility: str = "default"
    role: str = ""
    summary: str = ""
    parent_name: str = ""
    parent_kind: str = ""
    risk_tags: List[str] = field(default_factory=list)
    state_tags: List[str] = field(default_factory=list)
    thread_tags: List[str] = field(default_factory=list)
    interop_tags: List[str] = field(default_factory=list)


@dataclass
class ParseResult:
    file_role: str
    summary: str
    imports: List[ImportRecord] = field(default_factory=list)
    symbols: List[SymbolRecord] = field(default_factory=list)
    calls: List[CallRecord] = field(default_factory=list)
    risk_tags: List[str] = field(default_factory=list)
    state_tags: List[str] = field(default_factory=list)
    thread_tags: List[str] = field(default_factory=list)
    interop_tags: List[str] = field(default_factory=list)
    metadata: Dict[str, object] = field(default_factory=dict)


@dataclass
class FileScanResult:
    absolute_path: Path
    relative_path: str
    sha256: str
    parse_result: ParseResult


class ParserBackend:
    name = "base"

    def parse(self, path: Path, text: str) -> ParseResult:
        raise NotImplementedError

    def build_report(self) -> Optional[Dict[str, object]]:
        return None


class RegexFallbackBackend(ParserBackend):
    name = "regex-fallback"

    def parse(self, path: Path, text: str) -> ParseResult:
        file_role = infer_file_role(path)
        imports = extract_imports(text)
        symbols = extract_symbols_regex(text, file_role)
        calls = extract_calls_regex(text, symbols)
        risk_tags, state_tags, thread_tags, interop_tags = classify_risk_tags(path, text, file_role)
        summary = build_file_summary(path, file_role, symbols, imports, risk_tags)
        metadata = {
            "backend": self.name,
            "line_count": text.count("\n") + 1,
            "symbol_count": len(symbols),
            "import_count": len(imports),
            "call_count": len(calls),
        }
        return ParseResult(
            file_role=file_role,
            summary=summary,
            imports=imports,
            symbols=symbols,
            calls=calls,
            risk_tags=risk_tags,
            state_tags=state_tags,
            thread_tags=thread_tags,
            interop_tags=interop_tags,
            metadata=metadata,
        )


class MockTreeSitterBackend(ParserBackend):
    name = "mock-tree-sitter-unavailable"
    install_hint = "python -m pip install --user 'tree-sitter<0.22' tree-sitter-languages"

    def __init__(self, reason: str) -> None:
        self.reason = reason
        self.regex_backend = RegexFallbackBackend()

    def parse(self, path: Path, text: str) -> ParseResult:
        result = self.regex_backend.parse(path, text)
        result.metadata["backend"] = self.name
        result.metadata["tree_sitter_unavailable_reason"] = self.reason
        result.metadata["tree_sitter_install_hint"] = self.install_hint
        return result


class TreeSitterQueryBackend(ParserBackend):
    name = "tree-sitter-query"
    install_hint = "python -m pip install --user 'tree-sitter<0.22' tree-sitter-languages"
    SYMBOL_QUERY = r'''
        (class_declaration) @symbol.class
        (interface_declaration) @symbol.interface
        (method_definition) @symbol.method
        (function_declaration) @symbol.function
        (generator_function_declaration) @symbol.function
        (lexical_declaration
          (variable_declarator
            name: (identifier) @symbol.arrow.name
            value: [(arrow_function) (function)] @symbol.arrow.value))
    '''
    CALL_QUERY = r'''
        (call_expression
          function: (identifier) @call.identifier) @call.expr
        (call_expression
          function: (member_expression
            property: (property_identifier) @call.member.name)) @call.member.expr
    '''
    IMPORT_QUERY = r'''
        (import_statement) @import.statement
        (import_statement
          (import_clause) @import.clause)
        (import_statement
          source: (string) @import.source)
    '''
    CALL_NOISE_RECEIVERS = {"console", "Date", "Math"}
    COLLECTION_NOISE_METHODS = {"push", "pop", "shift", "unshift", "slice", "map", "filter", "forEach", "toString"}
    RECEIVER_SENSITIVE_KEEP_METHODS = {"get", "set", "has", "sendRequest", "readInt32", "readString", "readBytes"}

    def __init__(self) -> None:
        self._available = False
        self._init_error = ""
        self._parser_cache: Dict[str, object] = {}
        self._language_cache: Dict[str, object] = {}
        self._query_cache: Dict[Tuple[str, str], object] = {}
        try:
            from tree_sitter_languages import get_language, get_parser  # type: ignore

            self._get_language = get_language
            self._get_parser = get_parser
            self._available = True
        except Exception as exc:
            self._get_language = None
            self._get_parser = None
            self._init_error = str(exc)

    @property
    def available(self) -> bool:
        return self._available

    @property
    def init_error(self) -> str:
        return self._init_error

    def parse(self, path: Path, text: str) -> ParseResult:
        if not self.available or self._get_language is None or self._get_parser is None:
            raise RuntimeError(self._init_error or "tree-sitter backend is not available")
        language_name = detect_tree_sitter_language(path)
        parser = self._get_cached_parser(language_name)
        language = self._get_cached_language(language_name)
        source_bytes = text.encode("utf-8")
        tree = parser.parse(source_bytes)
        root = tree.root_node
        file_role = infer_file_role(path)
        imports = self._extract_imports(language_name, language, root, text, source_bytes)
        symbols = self._extract_symbols(language_name, language, root, text, source_bytes, file_role)
        calls = self._extract_calls(language_name, language, root, text, source_bytes, symbols)
        risk_tags, state_tags, thread_tags, interop_tags = classify_risk_tags(path, text, file_role)
        summary = build_file_summary(path, file_role, symbols, imports, risk_tags)
        metadata = {
            "backend": self.name,
            "language": language_name,
            "line_count": text.count("\n") + 1,
            "symbol_count": len(symbols),
            "import_count": len(imports),
            "call_count": len(calls),
        }
        return ParseResult(
            file_role=file_role,
            summary=summary,
            imports=imports,
            symbols=symbols,
            calls=calls,
            risk_tags=risk_tags,
            state_tags=state_tags,
            thread_tags=thread_tags,
            interop_tags=interop_tags,
            metadata=metadata,
        )

    def _get_cached_parser(self, language_name: str) -> object:
        parser = self._parser_cache.get(language_name)
        if parser is None:
            parser = self._get_parser(language_name)
            self._parser_cache[language_name] = parser
        return parser

    def _get_cached_language(self, language_name: str) -> object:
        language = self._language_cache.get(language_name)
        if language is None:
            language = self._get_language(language_name)
            self._language_cache[language_name] = language
        return language

    def _get_query(self, language_name: str, language: object, query_type: str) -> object:
        key = (language_name, query_type)
        query = self._query_cache.get(key)
        if query is not None:
            return query
        if query_type == "symbols":
            query_text = self.SYMBOL_QUERY
        elif query_type == "calls":
            query_text = self.CALL_QUERY
        elif query_type == "imports":
            query_text = self.IMPORT_QUERY
        else:
            raise ValueError(f"unsupported query type: {query_type}")
        query = language.query(query_text)
        self._query_cache[key] = query
        return query

    def _extract_imports(
        self,
        language_name: str,
        language: object,
        root: object,
        text: str,
        source_bytes: bytes,
    ) -> List[ImportRecord]:
        query = self._get_query(language_name, language, "imports")
        imports: List[ImportRecord] = []
        statements: List[object] = []
        seen_statements = set()
        for node, capture_name in query.captures(root):
            if capture_name != "import.statement":
                continue
            key = (getattr(node, 'start_byte'), getattr(node, 'end_byte'))
            if key in seen_statements:
                continue
            seen_statements.add(key)
            statements.append(node)
        for node in statements:
            clause_node = None
            source = ""
            is_type_only = False
            for child in getattr(node, 'children', []):
                child_type = getattr(child, 'type', '')
                if child_type == 'import_clause':
                    clause_node = child
                elif child_type == 'string':
                    source = self._strip_quotes(self._node_text(child, source_bytes))
                elif child_type == 'type':
                    is_type_only = True
            if not source:
                continue
            symbol_bindings = self._extract_import_bindings(clause_node, source_bytes, is_type_only)
            imports.append(
                ImportRecord(
                    source=source,
                    names=self._binding_names(symbol_bindings),
                    symbol_bindings=symbol_bindings,
                    is_type_only=is_type_only,
                    is_runtime=not is_type_only,
                    line=getattr(node, 'start_point')[0] + 1,
                )
            )
        unique: Dict[Tuple[str, int], ImportRecord] = {}
        for record in imports:
            unique[(record.source, record.line)] = record
        return list(unique.values())

    def _extract_import_bindings(
        self,
        clause_node: object,
        source_bytes: bytes,
        is_type_only: bool,
    ) -> List[Dict[str, object]]:
        if clause_node is None:
            return []
        bindings: List[Dict[str, object]] = []
        for child in getattr(clause_node, 'children', []):
            child_type = getattr(child, 'type', '')
            if child_type == 'identifier':
                local_name = self._node_text(child, source_bytes).strip()
                if local_name:
                    bindings.append(
                        {
                            'kind': 'default',
                            'imported_name': 'default',
                            'local_name': local_name,
                            'is_type_only': is_type_only,
                        }
                    )
            elif child_type == 'namespace_import':
                namespace_name = ''
                for sub in getattr(child, 'children', []):
                    if getattr(sub, 'type', '') == 'identifier':
                        namespace_name = self._node_text(sub, source_bytes).strip()
                        break
                if namespace_name:
                    bindings.append(
                        {
                            'kind': 'namespace',
                            'imported_name': '*',
                            'local_name': namespace_name,
                            'is_type_only': is_type_only,
                        }
                    )
            elif child_type == 'named_imports':
                for sub in getattr(child, 'children', []):
                    if getattr(sub, 'type', '') != 'import_specifier':
                        continue
                    name_node = sub.child_by_field_name('name')
                    alias_node = sub.child_by_field_name('alias')
                    imported_name = self._node_text(name_node, source_bytes).strip() if name_node is not None else ''
                    local_name = self._node_text(alias_node, source_bytes).strip() if alias_node is not None else imported_name
                    if imported_name or local_name:
                        bindings.append(
                            {
                                'kind': 'named',
                                'imported_name': imported_name,
                                'local_name': local_name,
                                'is_type_only': is_type_only,
                            }
                        )
        return self._dedupe_import_bindings(bindings)

    def _binding_names(self, bindings: Sequence[Dict[str, object]]) -> List[str]:
        names: List[str] = []
        seen = set()
        for binding in bindings:
            imported_name = str(binding.get('imported_name', '')).strip()
            local_name = str(binding.get('local_name', '')).strip()
            chosen = imported_name if imported_name not in {'', 'default', '*'} else local_name
            if not chosen or chosen in seen:
                continue
            seen.add(chosen)
            names.append(chosen)
        return names

    def _dedupe_import_bindings(self, bindings: Sequence[Dict[str, object]]) -> List[Dict[str, object]]:
        deduped: List[Dict[str, object]] = []
        seen = set()
        for binding in bindings:
            key = (
                str(binding.get('kind', '')),
                str(binding.get('imported_name', '')),
                str(binding.get('local_name', '')),
                bool(binding.get('is_type_only', False)),
            )
            if key in seen:
                continue
            seen.add(key)
            deduped.append(dict(binding))
        return deduped

    def _strip_quotes(self, value: str) -> str:
        text = value.strip()
        if len(text) >= 2 and text[0] in {'"', "'"} and text[-1] == text[0]:
            return text[1:-1]
        return text

    def _extract_symbols(
        self,
        language_name: str,
        language: object,
        root: object,
        text: str,
        source_bytes: bytes,
        file_role: str,
    ) -> List[SymbolRecord]:
        query = self._get_query(language_name, language, "symbols")
        symbols: List[SymbolRecord] = []
        arrow_pairs: Dict[Tuple[int, int], Dict[str, object]] = {}
        for node, capture_name in query.captures(root):
            if capture_name == "symbol.class":
                symbols.append(self._build_class_like_symbol(node, text, source_bytes, file_role, kind="class"))
            elif capture_name == "symbol.interface":
                symbols.append(self._build_class_like_symbol(node, text, source_bytes, file_role, kind="interface"))
            elif capture_name == "symbol.method":
                symbols.append(self._build_method_symbol(node, text, source_bytes, file_role))
            elif capture_name == "symbol.function":
                symbols.append(self._build_function_symbol(node, text, source_bytes, file_role))
            elif capture_name in {"symbol.arrow.name", "symbol.arrow.value"}:
                key = (getattr(node, 'start_point')[0], getattr(node, 'end_point')[0])
                arrow_pairs.setdefault(key, {})[capture_name] = node
        for pair in arrow_pairs.values():
            name_node = pair.get("symbol.arrow.name")
            value_node = pair.get("symbol.arrow.value")
            if name_node is None or value_node is None:
                continue
            declarator_node = name_node.parent
            if declarator_node is None:
                continue
            symbol_text = source_bytes[getattr(declarator_node, 'start_byte'): getattr(value_node, 'end_byte')].decode('utf-8', errors='ignore')
            risk_tags, state_tags, thread_tags, interop_tags = classify_symbol_tags(symbol_text)
            symbols.append(
                SymbolRecord(
                    name=self._node_text(name_node, source_bytes),
                    kind="function",
                    line_start=getattr(declarator_node, 'start_point')[0] + 1,
                    line_end=getattr(value_node, 'end_point')[0] + 1,
                    signature=compact_signature(symbol_text),
                    role=file_role,
                    summary=f"function {self._node_text(name_node, source_bytes)}",
                    risk_tags=risk_tags,
                    state_tags=state_tags,
                    thread_tags=thread_tags,
                    interop_tags=interop_tags,
                )
            )
        dedup: Dict[Tuple[str, str, int], SymbolRecord] = {}
        for symbol in symbols:
            dedup[(symbol.kind, symbol.name, symbol.line_start)] = symbol
        return sorted(dedup.values(), key=lambda item: (item.line_start, symbol_kind_rank(item.kind), item.name))

    def _extract_calls(
        self,
        language_name: str,
        language: object,
        root: object,
        text: str,
        source_bytes: bytes,
        symbols: Sequence[SymbolRecord],
    ) -> List[CallRecord]:
        query = self._get_query(language_name, language, "calls")
        calls: List[CallRecord] = []
        for node, capture_name in query.captures(root):
            if capture_name not in {"call.expr", "call.member.expr"}:
                continue
            owner = self._find_ast_owner(node, source_bytes)
            if owner is None:
                continue
            function_node = node.child_by_field_name("function")
            if function_node is None:
                continue
            callee_name, callee_expression, receiver_text, receiver_root = self._extract_call_target(function_node, source_bytes)
            if not callee_name or callee_name in CONTROL_KEYWORDS:
                continue
            if self._is_filtered_call(callee_name, receiver_text, receiver_root):
                continue
            calls.append(
                CallRecord(
                    caller_name=owner.name,
                    caller_kind=owner.kind,
                    caller_line_start=owner.line_start,
                    callee_name=callee_name,
                    callee_expression=callee_expression,
                    receiver_text=receiver_text,
                    receiver_root=receiver_root,
                    line=getattr(node, 'start_point')[0] + 1,
                    is_async_boundary=callee_name in {"then", "catch", "await", "setTimeout", "setInterval", "queueMicrotask", "postTask"},
                    is_ui_handoff=callee_name in {"build", "animateTo", "postTask", "pushUrl", "replaceUrl"},
                )
            )
        dedup: Dict[Tuple[str, str, int, str, int], CallRecord] = {}
        for call in calls:
            dedup[(call.caller_name, call.callee_name, call.line, call.caller_kind, call.caller_line_start)] = call
        return list(dedup.values())

    def _build_class_like_symbol(self, node: object, text: str, source_bytes: bytes, file_role: str, kind: str) -> SymbolRecord:
        name_node = node.child_by_field_name("name")
        if name_node is None:
            raise RuntimeError(f"missing name for {kind} node")
        symbol_text = self._node_text(node, source_bytes)
        risk_tags, state_tags, thread_tags, interop_tags = classify_symbol_tags(symbol_text)
        name = self._node_text(name_node, source_bytes)
        return SymbolRecord(
            name=name,
            kind=kind,
            line_start=getattr(node, 'start_point')[0] + 1,
            line_end=getattr(node, 'end_point')[0] + 1,
            signature=compact_signature(symbol_text),
            role=file_role,
            summary=f"{kind} {name}",
            risk_tags=risk_tags,
            state_tags=state_tags,
            thread_tags=thread_tags,
            interop_tags=interop_tags,
        )

    def _build_method_symbol(self, node: object, text: str, source_bytes: bytes, file_role: str) -> SymbolRecord:
        name_node = node.child_by_field_name("name")
        if name_node is None:
            raise RuntimeError("missing name for method_definition")
        symbol_text = self._node_text(node, source_bytes)
        risk_tags, state_tags, thread_tags, interop_tags = classify_symbol_tags(symbol_text)
        parent_container = self._find_container_ancestor(node, source_bytes)
        name = self._node_text(name_node, source_bytes)
        return SymbolRecord(
            name=name,
            kind="method",
            line_start=getattr(node, 'start_point')[0] + 1,
            line_end=getattr(node, 'end_point')[0] + 1,
            signature=compact_signature(symbol_text),
            role=file_role,
            summary=f"method {name}",
            parent_name=parent_container.name if parent_container is not None else "",
            parent_kind=parent_container.kind if parent_container is not None else "",
            risk_tags=risk_tags,
            state_tags=state_tags,
            thread_tags=thread_tags,
            interop_tags=interop_tags,
        )

    def _build_function_symbol(self, node: object, text: str, source_bytes: bytes, file_role: str) -> SymbolRecord:
        name_node = node.child_by_field_name("name")
        if name_node is None:
            raise RuntimeError("missing name for function_definition")
        symbol_text = self._node_text(node, source_bytes)
        risk_tags, state_tags, thread_tags, interop_tags = classify_symbol_tags(symbol_text)
        name = self._node_text(name_node, source_bytes)
        return SymbolRecord(
            name=name,
            kind="function",
            line_start=getattr(node, 'start_point')[0] + 1,
            line_end=getattr(node, 'end_point')[0] + 1,
            signature=compact_signature(symbol_text),
            role=file_role,
            summary=f"function {name}",
            risk_tags=risk_tags,
            state_tags=state_tags,
            thread_tags=thread_tags,
            interop_tags=interop_tags,
        )

    def _find_ast_owner(self, node: object, source_bytes: bytes) -> Optional[SymbolRecord]:
        current = getattr(node, 'parent', None)
        while current is not None:
            node_type = getattr(current, 'type', '')
            if node_type == 'method_definition':
                name_node = current.child_by_field_name('name')
                if name_node is None:
                    return None
                name = self._node_text(name_node, source_bytes)
                return SymbolRecord(
                    name=name,
                    kind='method',
                    line_start=getattr(current, 'start_point')[0] + 1,
                    line_end=getattr(current, 'end_point')[0] + 1,
                    signature='',
                )
            if node_type in {'function_declaration', 'generator_function_declaration'}:
                name_node = current.child_by_field_name('name')
                if name_node is None:
                    return None
                name = self._node_text(name_node, source_bytes)
                return SymbolRecord(
                    name=name,
                    kind='function',
                    line_start=getattr(current, 'start_point')[0] + 1,
                    line_end=getattr(current, 'end_point')[0] + 1,
                    signature='',
                )
            if node_type == 'class_declaration':
                name_node = current.child_by_field_name('name')
                if name_node is None:
                    return None
                name = self._node_text(name_node, source_bytes)
                return SymbolRecord(
                    name=name,
                    kind='class',
                    line_start=getattr(current, 'start_point')[0] + 1,
                    line_end=getattr(current, 'end_point')[0] + 1,
                    signature='',
                )
            current = getattr(current, 'parent', None)
        return None

    def _find_container_ancestor(self, node: object, source_bytes: bytes) -> Optional[SymbolRecord]:
        current = getattr(node, 'parent', None)
        while current is not None:
            node_type = getattr(current, 'type', '')
            if node_type in {'class_declaration', 'interface_declaration'}:
                name_node = current.child_by_field_name('name')
                if name_node is None:
                    return None
                name = self._node_text(name_node, source_bytes)
                return SymbolRecord(
                    name=name,
                    kind='class' if node_type == 'class_declaration' else 'interface',
                    line_start=getattr(current, 'start_point')[0] + 1,
                    line_end=getattr(current, 'end_point')[0] + 1,
                    signature='',
                )
            current = getattr(current, 'parent', None)
        return None

    def _extract_call_target(self, function_node: object, source_bytes: bytes) -> Tuple[str, str, str, str]:
        node_type = getattr(function_node, 'type', '')
        expression = self._node_text(function_node, source_bytes)
        if node_type == 'identifier':
            return expression, expression, '', ''
        if node_type == 'member_expression':
            property_node = function_node.child_by_field_name('property')
            object_node = function_node.child_by_field_name('object')
            callee_name = self._node_text(property_node, source_bytes) if property_node is not None else expression.split('.')[-1]
            receiver_text = self._node_text(object_node, source_bytes) if object_node is not None else ''
            receiver_root = receiver_text.split('.')[0] if receiver_text else ''
            return callee_name, expression, receiver_text, receiver_root
        if node_type == 'optional_chain':
            named_children = [child for child in getattr(function_node, 'children', []) if getattr(child, 'is_named', False)]
            if named_children:
                return self._extract_call_target(named_children[-1], source_bytes)
        return expression.split('.')[-1], expression, '', ''

    def _is_filtered_call(self, callee_name: str, receiver_text: str, receiver_root: str) -> bool:
        if receiver_root in self.CALL_NOISE_RECEIVERS:
            return True
        if callee_name in self.RECEIVER_SENSITIVE_KEEP_METHODS:
            return False
        normalized_receiver = receiver_text.replace('?.', '.').strip()
        if normalized_receiver in {'console'} and callee_name in {'info', 'log', 'debug', 'warn', 'error'}:
            return True
        if normalized_receiver in {'Date'} and callee_name == 'now':
            return True
        if receiver_root and receiver_root != 'this' and callee_name in self.COLLECTION_NOISE_METHODS:
            return True
        return False

    def _node_text(self, node: object, source_bytes: bytes) -> str:
        if node is None:
            return ''
        return source_bytes[getattr(node, 'start_byte'): getattr(node, 'end_byte')].decode('utf-8', errors='ignore')


class HybridParserBackend(ParserBackend):
    name = 'hybrid(ast+regex)'

    def __init__(self, ast_backend: TreeSitterQueryBackend, regex_backend: RegexFallbackBackend) -> None:
        self.ast_backend = ast_backend
        self.regex_backend = regex_backend
        self.diff_entries: List[Dict[str, object]] = []

    def parse(self, path: Path, text: str) -> ParseResult:
        regex_result = self.regex_backend.parse(path, text)
        if not self.ast_backend.available:
            fallback = self.regex_backend.parse(path, text)
            fallback.metadata['backend'] = self.name
            fallback.metadata['hybrid_mode'] = 'regex-only-fallback'
            fallback.metadata['tree_sitter_unavailable_reason'] = self.ast_backend.init_error
            fallback.metadata['tree_sitter_install_hint'] = self.ast_backend.install_hint
            self.diff_entries.append({
                'path': str(path),
                'status': 'tree-sitter-unavailable',
                'reason': self.ast_backend.init_error,
                'install_hint': self.ast_backend.install_hint,
            })
            return fallback
        ast_result = self.ast_backend.parse(path, text)
        merged = merge_parse_results(regex_result, ast_result)
        diff_entry = build_parse_diff(path, regex_result, ast_result)
        self.diff_entries.append(diff_entry)
        merged.metadata['backend'] = self.name
        merged.metadata['hybrid_diff_summary'] = diff_entry.get('summary', {})
        return merged

    def build_report(self) -> Optional[Dict[str, object]]:
        return {
            'backend': self.name,
            'generated_at': utc_now(),
            'files': self.diff_entries,
        }


def merge_tag_lists(*tag_lists: Sequence[str]) -> List[str]:
    merged: List[str] = []
    seen = set()
    for tag_list in tag_lists:
        for tag in tag_list:
            if tag not in seen:
                seen.add(tag)
                merged.append(tag)
    return merged


def merge_import_records(primary: Sequence[ImportRecord], secondary: Sequence[ImportRecord]) -> List[ImportRecord]:
    merged: List[ImportRecord] = []
    seen = set()
    for record in list(primary) + list(secondary):
        key = (record.source, tuple(record.names), record.line, record.is_type_only, record.is_runtime)
        if key in seen:
            continue
        seen.add(key)
        merged.append(record)
    return merged


def symbol_diff_key(symbol: SymbolRecord) -> Tuple[str, str, str, str]:
    return (symbol.kind, symbol.parent_kind, symbol.parent_name, symbol.name)


def merge_symbol_records(primary: Sequence[SymbolRecord], secondary: Sequence[SymbolRecord]) -> List[SymbolRecord]:
    merged: Dict[Tuple[str, str, str, str], SymbolRecord] = {}
    for symbol in secondary:
        merged[symbol_diff_key(symbol)] = symbol
    for symbol in primary:
        merged[symbol_diff_key(symbol)] = symbol
    return sorted(merged.values(), key=lambda item: (item.line_start, symbol_kind_rank(item.kind), item.name))


def call_diff_key(call: CallRecord) -> Tuple[str, str, str, int]:
    return (call.caller_name, call.caller_kind, call.callee_name, call.line)


def is_likely_regex_noise_call(call: CallRecord) -> bool:
    generic_noise = {'push', 'pop', 'shift', 'unshift', 'slice', 'map', 'filter', 'forEach', 'toString'}
    logging_noise = {'info', 'log', 'debug', 'warn', 'error'}
    time_noise = {'now'}
    return call.callee_name in generic_noise | logging_noise | time_noise


def merge_call_records(primary: Sequence[CallRecord], secondary: Sequence[CallRecord]) -> List[CallRecord]:
    merged: Dict[Tuple[str, str, str, int], CallRecord] = {}
    for call in secondary:
        if is_likely_regex_noise_call(call):
            continue
        merged[call_diff_key(call)] = call
    for call in primary:
        merged[call_diff_key(call)] = call
    return sorted(merged.values(), key=lambda item: (item.line, item.caller_name, item.callee_name))


def serialize_symbol_record(symbol: SymbolRecord) -> Dict[str, object]:
    return {
        'name': symbol.name,
        'kind': symbol.kind,
        'line_start': symbol.line_start,
        'line_end': symbol.line_end,
        'parent_name': symbol.parent_name,
        'parent_kind': symbol.parent_kind,
        'signature': symbol.signature,
        'risk_tags': list(symbol.risk_tags),
    }


def serialize_call_record(call: CallRecord) -> Dict[str, object]:
    return {
        'caller_name': call.caller_name,
        'caller_kind': call.caller_kind,
        'caller_line_start': call.caller_line_start,
        'callee_name': call.callee_name,
        'callee_expression': call.callee_expression,
        'receiver_text': call.receiver_text,
        'receiver_root': call.receiver_root,
        'line': call.line,
        'is_async_boundary': call.is_async_boundary,
        'is_ui_handoff': call.is_ui_handoff,
    }


def merge_parse_results(regex_result: ParseResult, ast_result: ParseResult) -> ParseResult:
    imports = merge_import_records(ast_result.imports, regex_result.imports)
    symbols = merge_symbol_records(ast_result.symbols, regex_result.symbols)
    calls = merge_call_records(ast_result.calls, regex_result.calls)
    metadata = dict(ast_result.metadata)
    metadata.update(
        {
            'regex_backend': regex_result.metadata.get('backend', 'regex-fallback'),
            'ast_backend': ast_result.metadata.get('backend', 'tree-sitter-query'),
            'regex_symbol_count': len(regex_result.symbols),
            'ast_symbol_count': len(ast_result.symbols),
            'merged_symbol_count': len(symbols),
            'regex_import_count': len(regex_result.imports),
            'ast_import_count': len(ast_result.imports),
            'merged_import_count': len(imports),
            'regex_call_count': len(regex_result.calls),
            'ast_call_count': len(ast_result.calls),
            'merged_call_count': len(calls),
        }
    )
    return ParseResult(
        file_role=ast_result.file_role or regex_result.file_role,
        summary=ast_result.summary or regex_result.summary,
        imports=imports,
        symbols=symbols,
        calls=calls,
        risk_tags=merge_tag_lists(regex_result.risk_tags, ast_result.risk_tags),
        state_tags=merge_tag_lists(regex_result.state_tags, ast_result.state_tags),
        thread_tags=merge_tag_lists(regex_result.thread_tags, ast_result.thread_tags),
        interop_tags=merge_tag_lists(regex_result.interop_tags, ast_result.interop_tags),
        metadata=metadata,
    )


def build_parse_diff(path: Path, regex_result: ParseResult, ast_result: ParseResult) -> Dict[str, object]:
    regex_symbol_map = {symbol_diff_key(symbol): symbol for symbol in regex_result.symbols}
    ast_symbol_map = {symbol_diff_key(symbol): symbol for symbol in ast_result.symbols}
    regex_call_map = {call_diff_key(call): call for call in regex_result.calls}
    ast_call_map = {call_diff_key(call): call for call in ast_result.calls}

    symbols_ast_only = [serialize_symbol_record(ast_symbol_map[key]) for key in sorted(set(ast_symbol_map) - set(regex_symbol_map))]
    symbols_regex_only = [serialize_symbol_record(regex_symbol_map[key]) for key in sorted(set(regex_symbol_map) - set(ast_symbol_map))]
    calls_ast_only = [serialize_call_record(ast_call_map[key]) for key in sorted(set(ast_call_map) - set(regex_call_map))]
    calls_regex_only_records = [regex_call_map[key] for key in sorted(set(regex_call_map) - set(ast_call_map))]
    regex_noise_filtered = [serialize_call_record(call) for call in calls_regex_only_records if is_likely_regex_noise_call(call)]
    calls_regex_only = [serialize_call_record(call) for call in calls_regex_only_records]

    return {
        'path': str(path),
        'parser_mode': 'hybrid',
        'symbols_ast_only': symbols_ast_only,
        'symbols_regex_only': symbols_regex_only,
        'calls_ast_only': calls_ast_only,
        'calls_regex_only': calls_regex_only,
        'regex_noise_filtered': regex_noise_filtered,
        'summary': {
            'regex_symbol_count': len(regex_result.symbols),
            'ast_symbol_count': len(ast_result.symbols),
            'symbols_ast_only_count': len(symbols_ast_only),
            'symbols_regex_only_count': len(symbols_regex_only),
            'regex_call_count': len(regex_result.calls),
            'ast_call_count': len(ast_result.calls),
            'calls_ast_only_count': len(calls_ast_only),
            'calls_regex_only_count': len(calls_regex_only),
            'regex_noise_filtered_count': len(regex_noise_filtered),
        },
    }


class RepoIndexer:
    def __init__(
        self,
        root_path: Path,
        db_path: Path,
        snapshot_label: str,
        extensions: Sequence[str],
        exclude_dirs: Sequence[str],
        prefer_tree_sitter: bool,
        reset_db: bool,
        parser_mode: Optional[str] = None,
        diff_report_path: Optional[Path] = None,
    ) -> None:
        self.root_path = root_path.resolve()
        self.db_path = db_path.resolve()
        self.snapshot_label = snapshot_label
        self.extensions = tuple(normalize_extension(item) for item in extensions)
        self.exclude_dirs = set(exclude_dirs)
        self.prefer_tree_sitter = prefer_tree_sitter
        self.parser_mode = normalize_parser_mode(parser_mode, prefer_tree_sitter)
        self.reset_db = reset_db
        self.diff_report_path = diff_report_path.resolve() if diff_report_path else None
        self.connection: Optional[sqlite3.Connection] = None
        self.snapshot_id: Optional[int] = None

    def run(self) -> int:
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        connection = sqlite3.connect(self.db_path)
        connection.row_factory = sqlite3.Row
        self.connection = connection
        if self.reset_db:
            reset_database(connection)
        initialize_database(connection)
        parser_backend = select_parser_backend(self.parser_mode)
        snapshot_id = create_snapshot(
            connection=connection,
            label=self.snapshot_label,
            root_path=self.root_path,
            parser_backend=parser_backend.name,
            metadata={
                'extensions': list(self.extensions),
                'tree_sitter_preferred': self.prefer_tree_sitter,
                'parser_mode': self.parser_mode,
                'diff_report_path': str(self.diff_report_path) if self.diff_report_path else None,
            },
        )
        self.snapshot_id = snapshot_id
        file_results = self.scan_files(parser_backend)
        insert_results(connection, snapshot_id, self.root_path, file_results)
        connection.commit()

        generated_report_path: Optional[str] = None
        report = parser_backend.build_report()
        if report is not None and self.diff_report_path is not None:
            self.diff_report_path.parent.mkdir(parents=True, exist_ok=True)
            self.diff_report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
            generated_report_path = str(self.diff_report_path)

        print(
            json.dumps(
                {
                    'db_path': str(self.db_path),
                    'snapshot_id': snapshot_id,
                    'snapshot_label': self.snapshot_label,
                    'parser_mode': self.parser_mode,
                    'parser_backend': parser_backend.name,
                    'indexed_files': len(file_results),
                    'diff_report_path': generated_report_path,
                },
                ensure_ascii=False,
            )
        )
        return 0

    def scan_files(self, parser_backend: ParserBackend) -> List[FileScanResult]:
        results: List[FileScanResult] = []
        for path in iter_source_files(self.root_path, self.extensions, self.exclude_dirs):
            try:
                text = path.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                text = path.read_text(encoding="utf-8", errors="ignore")
            relative_path = path.relative_to(self.root_path).as_posix()
            sha256 = hashlib.sha256(text.encode("utf-8", errors="ignore")).hexdigest()
            try:
                parse_result = parser_backend.parse(path, text)
            except Exception as exc:
                fallback_backend = RegexFallbackBackend()
                parse_result = fallback_backend.parse(path, text)
                parse_result.metadata["tree_sitter_error"] = str(exc)
                parse_result.metadata["fallback_backend"] = fallback_backend.name
            results.append(
                FileScanResult(
                    absolute_path=path,
                    relative_path=relative_path,
                    sha256=sha256,
                    parse_result=parse_result,
                )
            )
        return results


def normalize_extension(value: str) -> str:
    return value if value.startswith(".") else f".{value}"


def iter_source_files(root_path: Path, extensions: Sequence[str], exclude_dirs: Sequence[str]) -> Iterator[Path]:
    for current_root, dirnames, filenames in os.walk(root_path):
        dirnames[:] = sorted(item for item in dirnames if item not in exclude_dirs)
        current = Path(current_root)
        for filename in sorted(filenames):
            path = current / filename
            if path.suffix.lower() in extensions:
                yield path


def normalize_parser_mode(parser_mode: Optional[str], prefer_tree_sitter: bool) -> str:
    if parser_mode:
        normalized = parser_mode.strip().lower()
    else:
        normalized = 'ast' if prefer_tree_sitter else 'regex'
    if normalized not in {'regex', 'ast', 'hybrid'}:
        raise ValueError(f'unsupported parser mode: {normalized}')
    return normalized


def select_parser_backend(parser_mode: str) -> ParserBackend:
    normalized = parser_mode.strip().lower()
    regex_backend = RegexFallbackBackend()
    tree_sitter_backend = TreeSitterQueryBackend()
    if normalized == 'regex':
        return regex_backend
    if normalized == 'ast':
        if tree_sitter_backend.available:
            return tree_sitter_backend
        print(
            f"[repo_indexer] tree-sitter 不可用，AST 模式退化为 mock backend: {tree_sitter_backend.init_error}",
            file=sys.stderr,
        )
        return MockTreeSitterBackend(tree_sitter_backend.init_error or 'tree-sitter unavailable')
    if normalized == 'hybrid':
        if not tree_sitter_backend.available:
            print(
                f"[repo_indexer] tree-sitter 不可用，Hybrid 模式将保留 regex 主路径并记录差异占位: {tree_sitter_backend.init_error}",
                file=sys.stderr,
            )
        return HybridParserBackend(tree_sitter_backend, regex_backend)
    raise ValueError(f'unsupported parser mode: {parser_mode}')


def initialize_database(connection: sqlite3.Connection) -> None:
    connection.executescript(
        """
        PRAGMA foreign_keys = ON;

        CREATE TABLE IF NOT EXISTS snapshots (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            label TEXT NOT NULL,
            root_path TEXT NOT NULL,
            parser_backend TEXT NOT NULL,
            created_at TEXT NOT NULL,
            metadata_json TEXT NOT NULL DEFAULT '{}'
        );

        CREATE TABLE IF NOT EXISTS nodes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            snapshot_id INTEGER NOT NULL,
            node_key TEXT NOT NULL,
            kind TEXT NOT NULL,
            name TEXT NOT NULL,
            full_name TEXT NOT NULL,
            path TEXT,
            start_line INTEGER,
            end_line INTEGER,
            role TEXT NOT NULL DEFAULT '',
            visibility TEXT NOT NULL DEFAULT 'default',
            signature TEXT NOT NULL DEFAULT '',
            summary TEXT NOT NULL DEFAULT '',
            risk_tags_json TEXT NOT NULL DEFAULT '[]',
            state_tags_json TEXT NOT NULL DEFAULT '[]',
            thread_tags_json TEXT NOT NULL DEFAULT '[]',
            interop_tags_json TEXT NOT NULL DEFAULT '[]',
            metadata_json TEXT NOT NULL DEFAULT '{}',
            created_at TEXT NOT NULL,
            FOREIGN KEY(snapshot_id) REFERENCES snapshots(id) ON DELETE CASCADE,
            UNIQUE(snapshot_id, node_key)
        );

        CREATE INDEX IF NOT EXISTS idx_nodes_snapshot_kind ON nodes(snapshot_id, kind);
        CREATE INDEX IF NOT EXISTS idx_nodes_snapshot_path ON nodes(snapshot_id, path);
        CREATE INDEX IF NOT EXISTS idx_nodes_snapshot_full_name ON nodes(snapshot_id, full_name);

        CREATE TABLE IF NOT EXISTS edges (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            snapshot_id INTEGER NOT NULL,
            edge_key TEXT NOT NULL,
            edge_type TEXT NOT NULL,
            src_node_id INTEGER,
            dst_node_id INTEGER,
            src_node_key TEXT,
            dst_node_key TEXT,
            src_path TEXT,
            dst_path TEXT,
            symbol_name TEXT NOT NULL DEFAULT '',
            is_strong INTEGER NOT NULL DEFAULT 0,
            confidence REAL NOT NULL DEFAULT 0.0,
            metadata_json TEXT NOT NULL DEFAULT '{}',
            created_at TEXT NOT NULL,
            FOREIGN KEY(snapshot_id) REFERENCES snapshots(id) ON DELETE CASCADE,
            FOREIGN KEY(src_node_id) REFERENCES nodes(id) ON DELETE SET NULL,
            FOREIGN KEY(dst_node_id) REFERENCES nodes(id) ON DELETE SET NULL,
            UNIQUE(snapshot_id, edge_key)
        );

        CREATE INDEX IF NOT EXISTS idx_edges_snapshot_type ON edges(snapshot_id, edge_type);
        CREATE INDEX IF NOT EXISTS idx_edges_snapshot_src ON edges(snapshot_id, src_node_id);
        CREATE INDEX IF NOT EXISTS idx_edges_snapshot_dst ON edges(snapshot_id, dst_node_id);
        """
    )
    connection.commit()


def reset_database(connection: sqlite3.Connection) -> None:
    connection.executescript(
        """
        DROP TABLE IF EXISTS edges;
        DROP TABLE IF EXISTS nodes;
        DROP TABLE IF EXISTS snapshots;
        """
    )
    connection.commit()


def create_snapshot(
    connection: sqlite3.Connection,
    label: str,
    root_path: Path,
    parser_backend: str,
    metadata: Dict[str, object],
) -> int:
    timestamp = utc_now()
    cursor = connection.execute(
        """
        INSERT INTO snapshots (label, root_path, parser_backend, created_at, metadata_json)
        VALUES (?, ?, ?, ?, ?)
        """,
        (label, str(root_path), parser_backend, timestamp, json.dumps(metadata, ensure_ascii=False, sort_keys=True)),
    )
    return int(cursor.lastrowid)


def insert_results(
    connection: sqlite3.Connection,
    snapshot_id: int,
    root_path: Path,
    file_results: Sequence[FileScanResult],
) -> None:
    now = utc_now()
    file_node_ids: Dict[str, int] = {}
    symbol_node_ids: Dict[Tuple[str, str, str, int], int] = {}
    symbol_name_node_ids: Dict[Tuple[str, str], int] = {}
    container_node_ids: Dict[Tuple[str, str, str], int] = {}
    external_node_ids: Dict[str, int] = {}
    inserted_symbols: List[Tuple[str, str, int, SymbolRecord, str, int]] = []

    for item in file_results:
        parse_result = item.parse_result
        file_node_key = f"file:{item.relative_path}"
        metadata = dict(parse_result.metadata)
        metadata["sha256"] = item.sha256
        metadata["root_path"] = str(root_path)
        file_node_id = upsert_node(
            connection=connection,
            snapshot_id=snapshot_id,
            node_key=file_node_key,
            kind="file",
            name=Path(item.relative_path).name,
            full_name=item.relative_path,
            path=item.relative_path,
            start_line=1,
            end_line=int(metadata.get("line_count", 1)),
            role=parse_result.file_role,
            visibility="default",
            signature="",
            summary=parse_result.summary,
            risk_tags=parse_result.risk_tags,
            state_tags=parse_result.state_tags,
            thread_tags=parse_result.thread_tags,
            interop_tags=parse_result.interop_tags,
            metadata=metadata,
            created_at=now,
        )
        file_node_ids[item.relative_path] = file_node_id

        for symbol in parse_result.symbols:
            symbol_key = f"symbol:{item.relative_path}:{symbol.kind}:{symbol.name}:{symbol.line_start}:{symbol.line_end}"
            symbol_full_name = f"{item.relative_path}::{symbol.name}"
            symbol_metadata = {"owner_file": item.relative_path}
            if symbol.parent_name:
                symbol_metadata["parent_symbol"] = symbol.parent_name
                symbol_metadata["parent_kind"] = symbol.parent_kind
            symbol_node_id = upsert_node(
                connection=connection,
                snapshot_id=snapshot_id,
                node_key=symbol_key,
                kind=symbol.kind,
                name=symbol.name,
                full_name=symbol_full_name,
                path=item.relative_path,
                start_line=symbol.line_start,
                end_line=symbol.line_end,
                role=symbol.role or parse_result.file_role,
                visibility=symbol.visibility,
                signature=symbol.signature,
                summary=symbol.summary,
                risk_tags=symbol.risk_tags,
                state_tags=symbol.state_tags,
                thread_tags=symbol.thread_tags,
                interop_tags=symbol.interop_tags,
                metadata=symbol_metadata,
                created_at=now,
            )
            symbol_node_ids[(item.relative_path, symbol.kind, symbol.name, symbol.line_start)] = symbol_node_id
            symbol_name_node_ids[(item.relative_path, symbol.name)] = symbol_node_id
            if symbol.kind in {"class", "interface"}:
                container_node_ids[(item.relative_path, symbol.kind, symbol.name)] = symbol_node_id
            inserted_symbols.append((item.relative_path, file_node_key, file_node_id, symbol, symbol_key, symbol_node_id))

    for relative_path, file_node_key, file_node_id, symbol, symbol_key, symbol_node_id in inserted_symbols:
        upsert_edge(
            connection=connection,
            snapshot_id=snapshot_id,
            edge_key=f"contains:{file_node_key}->{symbol_key}",
            edge_type="contains",
            src_node_id=file_node_id,
            dst_node_id=symbol_node_id,
            src_node_key=file_node_key,
            dst_node_key=symbol_key,
            src_path=relative_path,
            dst_path=relative_path,
            symbol_name=symbol.name,
            is_strong=True,
            confidence=1.0,
            metadata={"relationship": "file_contains_symbol"},
            created_at=now,
        )
        if symbol.kind == "method" and symbol.parent_name and symbol.parent_kind:
            parent_node_id = container_node_ids.get((relative_path, symbol.parent_kind, symbol.parent_name))
            if parent_node_id is not None:
                parent_node_key = lookup_node_key(connection, parent_node_id)
                upsert_edge(
                    connection=connection,
                    snapshot_id=snapshot_id,
                    edge_key=f"contains:{parent_node_key}->{symbol_key}",
                    edge_type="contains",
                    src_node_id=parent_node_id,
                    dst_node_id=symbol_node_id,
                    src_node_key=parent_node_key,
                    dst_node_key=symbol_key,
                    src_path=relative_path,
                    dst_path=relative_path,
                    symbol_name=symbol.name,
                    is_strong=True,
                    confidence=1.0,
                    metadata={
                        "relationship": "container_contains_method",
                        "parent_name": symbol.parent_name,
                        "parent_kind": symbol.parent_kind,
                    },
                    created_at=now,
                )

    name_lookup = build_symbol_lookup(connection, snapshot_id)

    for item in file_results:
        parse_result = item.parse_result
        file_node_id = file_node_ids[item.relative_path]
        file_node_key = f"file:{item.relative_path}"
        for record in parse_result.imports:
            dst_path = resolve_import_target(item.absolute_path, record.source, root_path)
            dst_node_id: Optional[int] = None
            dst_node_key: Optional[str] = None
            dst_relative_path: Optional[str] = None
            symbol_bindings = list(record.symbol_bindings or [])
            if not symbol_bindings and record.names:
                symbol_bindings = [
                    {
                        "kind": "named",
                        "imported_name": name,
                        "local_name": name,
                        "is_type_only": record.is_type_only,
                    }
                    for name in record.names
                ]
            resolved_symbol_bindings: List[Dict[str, object]] = []
            unresolved_symbol_bindings: List[Dict[str, object]] = []
            if dst_path is not None:
                dst_relative_path = dst_path.relative_to(root_path).as_posix()
                dst_node_id = file_node_ids.get(dst_relative_path)
                dst_node_key = f"file:{dst_relative_path}"
            else:
                external_key = f"external-module:{record.source}"
                dst_node_id = external_node_ids.get(external_key)
                if dst_node_id is None:
                    dst_node_id = upsert_node(
                        connection=connection,
                        snapshot_id=snapshot_id,
                        node_key=external_key,
                        kind="module",
                        name=record.source,
                        full_name=record.source,
                        path=None,
                        start_line=None,
                        end_line=None,
                        role="external-module",
                        visibility="default",
                        signature="",
                        summary=f"external module {record.source}",
                        risk_tags=[],
                        state_tags=[],
                        thread_tags=[],
                        interop_tags=[],
                        metadata={"external": True},
                        created_at=now,
                    )
                    external_node_ids[external_key] = dst_node_id
                dst_node_key = external_key
            if dst_relative_path is not None:
                for binding in symbol_bindings:
                    imported_name = str(binding.get("imported_name", "")).strip()
                    local_name = str(binding.get("local_name", "")).strip() or imported_name
                    symbol_node_id = resolve_symbol_node_id_in_path(connection, snapshot_id, dst_relative_path, imported_name)
                    binding_payload = dict(binding)
                    binding_payload.update(
                        {
                            "import_source": record.source,
                            "line": record.line,
                            "resolved_path": dst_relative_path,
                        }
                    )
                    if symbol_node_id is None:
                        unresolved_symbol_bindings.append(binding_payload)
                        continue
                    binding_payload.update(
                        {
                            "resolved_node_id": symbol_node_id,
                            "resolved_kind": lookup_node_kind(connection, symbol_node_id),
                            "resolved_full_name": lookup_node_full_name(connection, symbol_node_id),
                        }
                    )
                    resolved_symbol_bindings.append(binding_payload)
                    upsert_edge(
                        connection=connection,
                        snapshot_id=snapshot_id,
                        edge_key=f"import-symbol:{file_node_key}:{dst_relative_path}:{local_name}:{record.line}",
                        edge_type="import_symbol",
                        src_node_id=file_node_id,
                        dst_node_id=symbol_node_id,
                        src_node_key=file_node_key,
                        dst_node_key=lookup_node_key(connection, symbol_node_id),
                        src_path=item.relative_path,
                        dst_path=dst_relative_path,
                        symbol_name=local_name,
                        is_strong=bool(record.is_runtime),
                        confidence=0.98,
                        metadata=binding_payload,
                        created_at=now,
                    )
            metadata = {
                "import_source": record.source,
                "names": record.names,
                "symbol_bindings": symbol_bindings,
                "resolved_symbol_bindings": resolved_symbol_bindings,
                "unresolved_symbol_bindings": unresolved_symbol_bindings,
                "line": record.line,
                "is_type_only": record.is_type_only,
                "is_runtime": record.is_runtime,
            }
            upsert_edge(
                connection=connection,
                snapshot_id=snapshot_id,
                edge_key=f"import:{file_node_key}:{record.source}:{record.line}",
                edge_type="import",
                src_node_id=file_node_id,
                dst_node_id=dst_node_id,
                src_node_key=file_node_key,
                dst_node_key=dst_node_key,
                src_path=item.relative_path,
                dst_path=dst_relative_path if dst_relative_path is not None else record.source,
                symbol_name=",".join(record.names),
                is_strong=bool(record.is_runtime),
                confidence=0.95 if dst_path is not None else 0.6,
                metadata=metadata,
                created_at=now,
            )

        for call in parse_result.calls:
            src_symbol_id = symbol_node_ids.get((item.relative_path, call.caller_kind, call.caller_name, call.caller_line_start))
            if src_symbol_id is None:
                src_symbol_id = symbol_name_node_ids.get((item.relative_path, call.caller_name))
            if src_symbol_id is None:
                continue
            dst_symbol_id = resolve_symbol_node_id(name_lookup, call.callee_name, current_path=item.relative_path)
            dst_node_key: Optional[str] = None
            if dst_symbol_id is None:
                external_symbol_key = f"external-symbol:{call.callee_name}"
                dst_symbol_id = external_node_ids.get(external_symbol_key)
                if dst_symbol_id is None:
                    dst_symbol_id = upsert_node(
                        connection=connection,
                        snapshot_id=snapshot_id,
                        node_key=external_symbol_key,
                        kind="external_symbol",
                        name=call.callee_name,
                        full_name=call.callee_name,
                        path=None,
                        start_line=None,
                        end_line=None,
                        role="external-symbol",
                        visibility="default",
                        signature="",
                        summary=f"external symbol {call.callee_name}",
                        risk_tags=[],
                        state_tags=[],
                        thread_tags=[],
                        interop_tags=[],
                        metadata={"external": True},
                        created_at=now,
                    )
                    external_node_ids[external_symbol_key] = dst_symbol_id
                dst_node_key = external_symbol_key
            else:
                dst_node_key = lookup_node_key(connection, dst_symbol_id)
            src_node_key = lookup_node_key(connection, src_symbol_id)
            upsert_edge(
                connection=connection,
                snapshot_id=snapshot_id,
                edge_key=f"call:{item.relative_path}:{call.caller_name}:{call.callee_name}:{call.line}",
                edge_type="call",
                src_node_id=src_symbol_id,
                dst_node_id=dst_symbol_id,
                src_node_key=src_node_key,
                dst_node_key=dst_node_key,
                src_path=item.relative_path,
                dst_path=lookup_node_path(connection, dst_symbol_id),
                symbol_name=call.callee_name,
                is_strong=True,
                confidence=0.8 if lookup_node_path(connection, dst_symbol_id) else 0.5,
                metadata={
                    "line": call.line,
                    "caller_kind": call.caller_kind,
                    "caller_line_start": call.caller_line_start,
                    "callee_expression": call.callee_expression,
                    "receiver_text": call.receiver_text,
                    "receiver_root": call.receiver_root,
                    "is_async_boundary": call.is_async_boundary,
                    "is_ui_handoff": call.is_ui_handoff,
                },
                created_at=now,
            )


def build_symbol_lookup(connection: sqlite3.Connection, snapshot_id: int) -> Dict[str, List[Dict[str, object]]]:
    rows = connection.execute(
        "SELECT id, name, kind, path, start_line FROM nodes WHERE snapshot_id = ? AND kind IN ('class', 'interface', 'function', 'method')",
        (snapshot_id,),
    ).fetchall()
    lookup: Dict[str, List[Dict[str, object]]] = {}
    for row in rows:
        lookup.setdefault(str(row["name"]), []).append(
            {
                "id": int(row["id"]),
                "name": str(row["name"]),
                "kind": str(row["kind"]),
                "path": str(row["path"]) if row["path"] is not None else None,
                "start_line": int(row["start_line"] or 0),
            }
        )
    return lookup


def resolve_symbol_node_id(
    lookup: Dict[str, List[Dict[str, object]]],
    callee_name: str,
    current_path: Optional[str] = None,
) -> Optional[int]:
    candidates = lookup.get(callee_name, [])
    if not candidates:
        return None

    def rank(candidate: Dict[str, object]) -> Tuple[int, int, int, int]:
        path_rank = 0 if current_path and candidate.get("path") == current_path else 1
        kind = str(candidate.get("kind", ""))
        if kind == "method":
            kind_rank = 0
        elif kind == "function":
            kind_rank = 1
        elif kind == "class":
            kind_rank = 2
        else:
            kind_rank = 3
        return (path_rank, kind_rank, int(candidate.get("start_line", 0)), int(candidate.get("id", 0)))

    best = sorted(candidates, key=rank)[0]
    return int(best["id"])


def upsert_node(
    connection: sqlite3.Connection,
    snapshot_id: int,
    node_key: str,
    kind: str,
    name: str,
    full_name: str,
    path: Optional[str],
    start_line: Optional[int],
    end_line: Optional[int],
    role: str,
    visibility: str,
    signature: str,
    summary: str,
    risk_tags: Sequence[str],
    state_tags: Sequence[str],
    thread_tags: Sequence[str],
    interop_tags: Sequence[str],
    metadata: Dict[str, object],
    created_at: str,
) -> int:
    connection.execute(
        """
        INSERT INTO nodes (
            snapshot_id, node_key, kind, name, full_name, path, start_line, end_line,
            role, visibility, signature, summary, risk_tags_json, state_tags_json,
            thread_tags_json, interop_tags_json, metadata_json, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(snapshot_id, node_key) DO UPDATE SET
            kind = excluded.kind,
            name = excluded.name,
            full_name = excluded.full_name,
            path = excluded.path,
            start_line = excluded.start_line,
            end_line = excluded.end_line,
            role = excluded.role,
            visibility = excluded.visibility,
            signature = excluded.signature,
            summary = excluded.summary,
            risk_tags_json = excluded.risk_tags_json,
            state_tags_json = excluded.state_tags_json,
            thread_tags_json = excluded.thread_tags_json,
            interop_tags_json = excluded.interop_tags_json,
            metadata_json = excluded.metadata_json
        """,
        (
            snapshot_id,
            node_key,
            kind,
            name,
            full_name,
            path,
            start_line,
            end_line,
            role,
            visibility,
            signature,
            summary,
            json.dumps(sorted(set(risk_tags)), ensure_ascii=False),
            json.dumps(sorted(set(state_tags)), ensure_ascii=False),
            json.dumps(sorted(set(thread_tags)), ensure_ascii=False),
            json.dumps(sorted(set(interop_tags)), ensure_ascii=False),
            json.dumps(metadata, ensure_ascii=False, sort_keys=True),
            created_at,
        ),
    )
    row = connection.execute(
        "SELECT id FROM nodes WHERE snapshot_id = ? AND node_key = ?",
        (snapshot_id, node_key),
    ).fetchone()
    return int(row["id"])


def upsert_edge(
    connection: sqlite3.Connection,
    snapshot_id: int,
    edge_key: str,
    edge_type: str,
    src_node_id: Optional[int],
    dst_node_id: Optional[int],
    src_node_key: Optional[str],
    dst_node_key: Optional[str],
    src_path: Optional[str],
    dst_path: Optional[str],
    symbol_name: str,
    is_strong: bool,
    confidence: float,
    metadata: Dict[str, object],
    created_at: str,
) -> int:
    connection.execute(
        """
        INSERT INTO edges (
            snapshot_id, edge_key, edge_type, src_node_id, dst_node_id, src_node_key,
            dst_node_key, src_path, dst_path, symbol_name, is_strong, confidence,
            metadata_json, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(snapshot_id, edge_key) DO UPDATE SET
            edge_type = excluded.edge_type,
            src_node_id = excluded.src_node_id,
            dst_node_id = excluded.dst_node_id,
            src_node_key = excluded.src_node_key,
            dst_node_key = excluded.dst_node_key,
            src_path = excluded.src_path,
            dst_path = excluded.dst_path,
            symbol_name = excluded.symbol_name,
            is_strong = excluded.is_strong,
            confidence = excluded.confidence,
            metadata_json = excluded.metadata_json
        """,
        (
            snapshot_id,
            edge_key,
            edge_type,
            src_node_id,
            dst_node_id,
            src_node_key,
            dst_node_key,
            src_path,
            dst_path,
            symbol_name,
            1 if is_strong else 0,
            confidence,
            json.dumps(metadata, ensure_ascii=False, sort_keys=True),
            created_at,
        ),
    )
    row = connection.execute(
        "SELECT id FROM edges WHERE snapshot_id = ? AND edge_key = ?",
        (snapshot_id, edge_key),
    ).fetchone()
    return int(row["id"])


def lookup_node_key(connection: sqlite3.Connection, node_id: int) -> Optional[str]:
    row = connection.execute("SELECT node_key FROM nodes WHERE id = ?", (node_id,)).fetchone()
    return None if row is None else str(row["node_key"])


def lookup_node_path(connection: sqlite3.Connection, node_id: Optional[int]) -> Optional[str]:
    if node_id is None:
        return None
    row = connection.execute("SELECT path FROM nodes WHERE id = ?", (node_id,)).fetchone()
    return None if row is None else row["path"]



def lookup_node_full_name(connection: sqlite3.Connection, node_id: Optional[int]) -> Optional[str]:
    if node_id is None:
        return None
    row = connection.execute("SELECT full_name FROM nodes WHERE id = ?", (node_id,)).fetchone()
    return None if row is None else str(row["full_name"])


def lookup_node_kind(connection: sqlite3.Connection, node_id: Optional[int]) -> Optional[str]:
    if node_id is None:
        return None
    row = connection.execute("SELECT kind FROM nodes WHERE id = ?", (node_id,)).fetchone()
    return None if row is None else str(row["kind"])


def resolve_symbol_node_id_in_path(
    connection: sqlite3.Connection,
    snapshot_id: int,
    file_path: str,
    symbol_name: str,
) -> Optional[int]:
    if not symbol_name or symbol_name in {'default', '*'}:
        return None
    row = connection.execute(
        """
        SELECT id
        FROM nodes
        WHERE snapshot_id = ?
          AND path = ?
          AND name = ?
          AND kind IN ('class', 'interface', 'function', 'method')
        ORDER BY
          CASE kind
            WHEN 'function' THEN 0
            WHEN 'class' THEN 1
            WHEN 'interface' THEN 2
            WHEN 'method' THEN 3
            ELSE 4
          END,
          start_line ASC,
          id ASC
        LIMIT 1
        """,
        (snapshot_id, file_path, symbol_name),
    ).fetchone()
    return None if row is None else int(row['id'])


def infer_file_role(path: Path) -> str:
    parts = {part.lower() for part in path.parts}
    filename = path.name.lower()
    if "pages" in parts or filename.endswith("page.ts") or filename.endswith("page.ets"):
        return "page"
    if "components" in parts or filename.endswith("component.ts") or filename.endswith("component.ets"):
        return "component"
    if "viewmodel" in parts or "viewmodels" in parts:
        return "viewmodel"
    if "service" in filename or "services" in parts:
        return "service"
    if "model" in filename or "models" in parts:
        return "model"
    if "router" in filename or "navigation" in filename:
        return "router"
    if "store" in filename or "state" in filename or "signal" in filename:
        return "state"
    if "bridge" in filename or "interop" in filename or "native" in filename:
        return "interop"
    if "test" in filename or filename.endswith("spec.ts") or filename.endswith("test.ts"):
        return "test"
    return "module"


def extract_imports(text: str) -> List[ImportRecord]:
    imports: List[ImportRecord] = []
    for match in IMPORT_RE.finditer(text):
        line = text[: match.start()].count("\n") + 1
        body = match.group("body").strip()
        source = match.group("source").strip()
        is_type_only = body.startswith("type ") or "import type" in match.group(0)
        names = normalize_import_names(body)
        bindings = build_import_bindings_from_body(body, is_type_only)
        imports.append(
            ImportRecord(
                source=source,
                names=import_binding_names(bindings) or names,
                symbol_bindings=bindings,
                is_type_only=is_type_only,
                is_runtime=not is_type_only,
                line=line,
            )
        )
    for match in SIDE_EFFECT_IMPORT_RE.finditer(text):
        line = text[: match.start()].count("\n") + 1
        source = match.group("source").strip()
        imports.append(ImportRecord(source=source, names=[], symbol_bindings=[], is_type_only=False, is_runtime=True, line=line))
    unique: Dict[Tuple[str, int], ImportRecord] = {}
    for record in imports:
        unique[(record.source, record.line)] = record
    return list(unique.values())


def normalize_import_names(body: str) -> List[str]:
    compact = body.replace("\n", " ").strip()
    if not compact:
        return []
    compact = compact.replace("{", " ").replace("}", " ")
    compact = compact.replace("* as", " ")
    tokens = []
    for item in re.split(r"[,\s]+", compact):
        token = item.strip()
        if not token or token in {"as", "type", "default"}:
            continue
        tokens.append(token)
    return tokens



def build_import_bindings_from_body(body: str, is_type_only: bool) -> List[Dict[str, object]]:
    compact = re.sub(r"\s+", " ", body.replace("\n", " ")).strip()
    if not compact:
        return []
    if compact.startswith("type "):
        compact = compact[len("type ") :].strip()
    bindings: List[Dict[str, object]] = []
    if compact.startswith("* as "):
        local_name = compact[len("* as ") :].strip()
        if local_name:
            bindings.append({"kind": "namespace", "imported_name": "*", "local_name": local_name, "is_type_only": is_type_only})
        return bindings
    if "{" in compact and "}" in compact:
        prefix, remainder = compact.split("{", 1)
        inside, _ = remainder.split("}", 1)
        default_name = prefix.strip().rstrip(",").strip()
        if default_name:
            bindings.append({"kind": "default", "imported_name": "default", "local_name": default_name, "is_type_only": is_type_only})
        for raw_item in inside.split(","):
            item = raw_item.strip()
            if not item:
                continue
            if item.startswith("type "):
                item = item[len("type ") :].strip()
            if " as " in item:
                imported_name, local_name = [part.strip() for part in item.split(" as ", 1)]
            else:
                imported_name = item
                local_name = item
            if imported_name or local_name:
                bindings.append({"kind": "named", "imported_name": imported_name, "local_name": local_name, "is_type_only": is_type_only})
        return bindings
    local_name = compact.strip().rstrip(",")
    if local_name:
        bindings.append({"kind": "default", "imported_name": "default", "local_name": local_name, "is_type_only": is_type_only})
    return bindings


def import_binding_names(bindings: Sequence[Dict[str, object]]) -> List[str]:
    names: List[str] = []
    seen = set()
    for binding in bindings:
        imported_name = str(binding.get("imported_name", "")).strip()
        local_name = str(binding.get("local_name", "")).strip()
        chosen = imported_name if imported_name not in {"", "default", "*"} else local_name
        if not chosen or chosen in seen:
            continue
        seen.add(chosen)
        names.append(chosen)
    return names


def extract_symbols_regex(text: str, file_role: str) -> List[SymbolRecord]:
    symbols: List[SymbolRecord] = []
    class_like_symbols = []
    for pattern, kind in ((CLASS_RE, "class"), (INTERFACE_RE, "interface"), (FUNCTION_RE, "function"), (ARROW_RE, "function")):
        pattern_symbols = extract_pattern_symbols(text, pattern, kind, file_role)
        symbols.extend(pattern_symbols)
        if kind in {"class", "interface"}:
            class_like_symbols.extend(pattern_symbols)
    symbols.extend(extract_method_symbols(text, file_role, class_like_symbols))
    dedup: Dict[Tuple[str, str, int], SymbolRecord] = {}
    for symbol in symbols:
        dedup[(symbol.kind, symbol.name, symbol.line_start)] = symbol
    return sorted(dedup.values(), key=lambda item: (item.line_start, symbol_kind_rank(item.kind), item.name))


def extract_pattern_symbols(text: str, pattern: re.Pattern[str], kind: str, file_role: str) -> List[SymbolRecord]:
    symbols: List[SymbolRecord] = []
    for match in pattern.finditer(text):
        name = match.group("name")
        if kind == "method" and name in CONTROL_KEYWORDS:
            continue
        start_index = match.start()
        line_start = text[: start_index].count("\n") + 1
        end_index, line_end = infer_block_end_position(text, start_index)
        symbol_text = extract_symbol_text(text, start_index, end_index)
        symbol_risk_tags, symbol_state_tags, symbol_thread_tags, symbol_interop_tags = classify_symbol_tags(symbol_text)
        symbols.append(
            SymbolRecord(
                name=name,
                kind=kind,
                line_start=line_start,
                line_end=max(line_start, line_end),
                signature=compact_signature(symbol_text),
                role=file_role,
                summary=f"{kind} {name}",
                risk_tags=symbol_risk_tags,
                state_tags=symbol_state_tags,
                thread_tags=symbol_thread_tags,
                interop_tags=symbol_interop_tags,
            )
        )
    return symbols


def extract_method_symbols(text: str, file_role: str, container_symbols: Sequence[SymbolRecord]) -> List[SymbolRecord]:
    methods: List[SymbolRecord] = []
    for match in METHOD_RE.finditer(text):
        name = match.group("name")
        if name in CONTROL_KEYWORDS:
            continue
        line_text = text[match.start() : text.find("\n", match.start()) if text.find("\n", match.start()) != -1 else len(text)].strip()
        if line_text.startswith(("if ", "for ", "while ", "switch ", "catch ")):
            continue
        body_start_index = scan_method_body_start(text, match.end() - 1)
        if body_start_index is None:
            continue
        start_index = match.start()
        line_start = text[: start_index].count("\n") + 1
        end_index, line_end = infer_block_end_position(text, start_index)
        symbol_text = extract_symbol_text(text, start_index, end_index)
        parent_symbol = find_parent_container(container_symbols, line_start, line_end)
        symbol_risk_tags, symbol_state_tags, symbol_thread_tags, symbol_interop_tags = classify_symbol_tags(symbol_text)
        methods.append(
            SymbolRecord(
                name=name,
                kind="method",
                line_start=line_start,
                line_end=max(line_start, line_end),
                signature=compact_signature(symbol_text),
                role=file_role,
                summary=f"method {name}",
                parent_name=parent_symbol.name if parent_symbol is not None else "",
                parent_kind=parent_symbol.kind if parent_symbol is not None else "",
                risk_tags=symbol_risk_tags,
                state_tags=symbol_state_tags,
                thread_tags=symbol_thread_tags,
                interop_tags=symbol_interop_tags,
            )
        )
    return methods


def scan_method_body_start(text: str, open_paren_index: int) -> Optional[int]:
    index = open_paren_index
    paren_depth = 0
    while index < len(text):
        char = text[index]
        next_char = text[index + 1] if index + 1 < len(text) else ""
        if char == "/" and next_char == "/":
            index = skip_line_comment(text, index + 2)
            continue
        if char == "/" and next_char == "*":
            index = skip_block_comment(text, index + 2)
            continue
        if char in {'"', "'", "`"}:
            index = skip_string_literal(text, index)
            continue
        if char == "(":
            paren_depth += 1
        elif char == ")":
            paren_depth -= 1
            if paren_depth == 0:
                index += 1
                break
        index += 1
    if paren_depth != 0:
        return None

    while index < len(text) and text[index].isspace():
        index += 1
    if index < len(text) and text[index] == "{":
        return index
    if index >= len(text) or text[index] != ":":
        return None
    index += 1
    angle_depth = 0
    square_depth = 0
    nested_paren_depth = 0
    while index < len(text):
        char = text[index]
        next_char = text[index + 1] if index + 1 < len(text) else ""
        if char == "/" and next_char == "/":
            index = skip_line_comment(text, index + 2)
            continue
        if char == "/" and next_char == "*":
            index = skip_block_comment(text, index + 2)
            continue
        if char in {'"', "'", "`"}:
            index = skip_string_literal(text, index)
            continue
        if char == "<":
            angle_depth += 1
        elif char == ">":
            angle_depth = max(0, angle_depth - 1)
        elif char == "[":
            square_depth += 1
        elif char == "]":
            square_depth = max(0, square_depth - 1)
        elif char == "(":
            nested_paren_depth += 1
        elif char == ")":
            nested_paren_depth = max(0, nested_paren_depth - 1)
        elif char == "\n" and angle_depth == 0 and square_depth == 0 and nested_paren_depth == 0:
            next_index = advance_past_whitespace_and_comments(text, index + 1)
            if next_index is None or text[next_index] != "{":
                return None
            return next_index
        elif char == ";" and angle_depth == 0 and square_depth == 0 and nested_paren_depth == 0:
            return None
        elif char == "=" and next_char == ">":
            return None
        elif char == "{" and angle_depth == 0 and square_depth == 0 and nested_paren_depth == 0:
            return index
        index += 1
    return None


def extract_calls_regex(text: str, symbols: Sequence[SymbolRecord]) -> List[CallRecord]:
    calls: List[CallRecord] = []
    lines = text.splitlines()
    for match in CALL_RE.finditer(text):
        name = match.group("name")
        if name in CONTROL_KEYWORDS or name[0].isupper():
            continue
        line = text[: match.start()].count("\n") + 1
        line_text = lines[line - 1].strip() if 0 < line <= len(lines) else ""
        if is_declaration_line(line_text, name):
            continue
        owner_symbol = find_owner_symbol(symbols, line)
        if owner_symbol is None:
            continue
        calls.append(
            CallRecord(
                caller_name=owner_symbol.name,
                caller_kind=owner_symbol.kind,
                caller_line_start=owner_symbol.line_start,
                callee_name=name,
                callee_expression=name,
                line=line,
                is_async_boundary=name in {"then", "catch", "await", "setTimeout", "setInterval"},
                is_ui_handoff=name in {"build", "animateTo", "postTask", "pushUrl", "replaceUrl"},
            )
        )
    dedup: Dict[Tuple[str, str, int, str, int], CallRecord] = {}
    for call in calls:
        dedup[(call.caller_name, call.callee_name, call.line, call.caller_kind, call.caller_line_start)] = call
    return list(dedup.values())


def is_declaration_line(line_text: str, name: str) -> bool:
    declaration_patterns = [
        rf"^(?:export\s+)?(?:async\s+)?function\s+{re.escape(name)}\s*\(",
        rf"^(?:export\s+)?(?:const|let|var)\s+{re.escape(name)}\s*=.*=>",
        rf"^(?:(?:public|private|protected|readonly|declare|abstract|override|static)\s+)*(?:async\s+)?{re.escape(name)}\s*(?:<[^>]*>)?\s*\(",
    ]
    return any(re.search(pattern, line_text) for pattern in declaration_patterns)


def find_owner_symbol(symbols: Sequence[SymbolRecord], line: int) -> Optional[SymbolRecord]:
    candidates = [item for item in symbols if item.line_start <= line <= item.line_end]
    if not candidates:
        return None
    candidates.sort(key=lambda item: (item.line_end - item.line_start, symbol_owner_rank(item.kind), item.line_start, item.name))
    return candidates[0]


def find_parent_container(container_symbols: Sequence[SymbolRecord], line_start: int, line_end: int) -> Optional[SymbolRecord]:
    candidates = [
        item
        for item in container_symbols
        if item.kind in {"class", "interface"} and item.line_start <= line_start and item.line_end >= line_end
    ]
    if not candidates:
        return None
    candidates.sort(key=lambda item: (item.line_end - item.line_start, item.line_start, item.name))
    return candidates[0]


def symbol_kind_rank(kind: str) -> int:
    if kind in {"class", "interface"}:
        return 0
    if kind == "method":
        return 1
    return 2


def symbol_owner_rank(kind: str) -> int:
    if kind == "method":
        return 0
    if kind == "function":
        return 1
    if kind in {"class", "interface"}:
        return 2
    return 3


def infer_block_end_position(text: str, start_index: int) -> Tuple[int, int]:
    brace_depth = 0
    seen_open_brace = False
    line = text[:start_index].count("\n") + 1
    index = start_index
    while index < len(text):
        char = text[index]
        next_char = text[index + 1] if index + 1 < len(text) else ""
        if char == "\n":
            line += 1
            index += 1
            continue
        if char == "/" and next_char == "/":
            index = skip_line_comment(text, index + 2)
            continue
        if char == "/" and next_char == "*":
            index = skip_block_comment(text, index + 2)
            continue
        if char in {'"', "'", "`"}:
            index = skip_string_literal(text, index)
            continue
        if char == "{":
            brace_depth += 1
            seen_open_brace = True
        elif char == "}":
            brace_depth -= 1
            if seen_open_brace and brace_depth <= 0:
                return index, line
        index += 1
    return len(text), line


def infer_block_end_line(text: str, start_index: int) -> int:
    _, line = infer_block_end_position(text, start_index)
    return line


def extract_symbol_text(text: str, start_index: int, end_index: int) -> str:
    if end_index <= start_index or end_index >= len(text):
        return text[start_index : min(len(text), start_index + 400)]
    return text[start_index : end_index + 1]


def advance_past_whitespace_and_comments(text: str, start_index: int) -> Optional[int]:
    index = start_index
    while index < len(text):
        char = text[index]
        next_char = text[index + 1] if index + 1 < len(text) else ""
        if char.isspace():
            index += 1
            continue
        if char == "/" and next_char == "/":
            index = skip_line_comment(text, index + 2)
            continue
        if char == "/" and next_char == "*":
            index = skip_block_comment(text, index + 2)
            continue
        return index
    return None


def skip_string_literal(text: str, start_index: int) -> int:
    quote = text[start_index]
    index = start_index + 1
    while index < len(text):
        char = text[index]
        if char == "\\":
            index += 2
            continue
        if char == quote:
            return index + 1
        index += 1
    return index


def skip_line_comment(text: str, start_index: int) -> int:
    index = start_index
    while index < len(text) and text[index] != "\n":
        index += 1
    return index


def skip_block_comment(text: str, start_index: int) -> int:
    index = start_index
    while index + 1 < len(text):
        if text[index] == "*" and text[index + 1] == "/":
            return index + 2
        index += 1
    return len(text)


def classify_symbol_tags(text: str) -> Tuple[List[str], List[str], List[str], List[str]]:
    state_tags = [name for name, pattern in STATE_TAG_PATTERNS.items() if pattern.search(text)]
    thread_tags = [name for name, pattern in THREAD_TAG_PATTERNS.items() if pattern.search(text)]
    interop_tags = [name for name, pattern in INTEROP_TAG_PATTERNS.items() if pattern.search(text)]
    semantic_tags = [name for name, pattern in SEMANTIC_RISK_PATTERNS.items() if pattern.search(text)]
    risk_tags = dedupe_list(semantic_tags + state_tags + thread_tags + interop_tags)
    return risk_tags, dedupe_list(state_tags), dedupe_list(thread_tags), dedupe_list(interop_tags)


def dedupe_list(items: Sequence[str]) -> List[str]:
    seen = set()
    result: List[str] = []
    for item in items:
        if item in seen:
            continue
        seen.add(item)
        result.append(item)
    return result


def classify_risk_tags(path: Path, text: str, file_role: str) -> Tuple[List[str], List[str], List[str], List[str]]:
    state_tags = [name for name, pattern in STATE_TAG_PATTERNS.items() if pattern.search(text)]
    thread_tags = [name for name, pattern in THREAD_TAG_PATTERNS.items() if pattern.search(text)]
    interop_tags = [name for name, pattern in INTEROP_TAG_PATTERNS.items() if pattern.search(text)]
    ui_tags = [name for name, pattern in UI_TAG_PATTERNS.items() if pattern.search(text)]
    semantic_tags = [name for name, pattern in SEMANTIC_RISK_PATTERNS.items() if pattern.search(text)]
    risk_tags = dedupe_list(ui_tags + state_tags + thread_tags + interop_tags + semantic_tags + [file_role])
    return risk_tags, dedupe_list(state_tags), dedupe_list(thread_tags), dedupe_list(interop_tags)


def build_file_summary(
    path: Path,
    file_role: str,
    symbols: Sequence[SymbolRecord],
    imports: Sequence[ImportRecord],
    risk_tags: Sequence[str],
) -> str:
    top_symbols = ", ".join(item.name for item in symbols[:5]) or "无显式符号"
    top_imports = ", ".join(item.source for item in imports[:3]) or "无显式 import"
    risk_summary = ", ".join(risk_tags[:4]) or "无明显风险标签"
    return f"角色={file_role}; 符号={top_symbols}; 依赖={top_imports}; 风险={risk_summary}; 文件={path.name}"


def compact_signature(text: str) -> str:
    compact = re.sub(r"\s+", " ", text).strip()
    if len(compact) <= 160:
        return compact
    return compact[:157] + "..."


def resolve_import_target(base_path: Path, import_source: str, root_path: Path) -> Optional[Path]:
    if not import_source.startswith("."):
        return None
    candidate_base = (base_path.parent / import_source).resolve()
    candidates = [candidate_base]
    if candidate_base.suffix:
        candidates.append(candidate_base.with_suffix(""))
    else:
        for extension in DEFAULT_EXTENSIONS:
            candidates.append(candidate_base.with_suffix(extension))
        candidates.extend(candidate_base / f"index{extension}" for extension in DEFAULT_EXTENSIONS)
    for candidate in candidates:
        if candidate.is_file() and is_relative_to(candidate, root_path):
            return candidate
    return None


def is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def detect_tree_sitter_language(path: Path) -> str:
    suffix = path.suffix.lower()
    if suffix in {".ts", ".tsx", ".ets", ".arkts"}:
        return "typescript"
    return "javascript"


def utc_now() -> str:
    return dt.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="构建仓库级结构索引 SQLite 库")
    parser.add_argument("--root", required=True, help="待索引源码根目录")
    parser.add_argument("--db", default=str(DEFAULT_DB_PATH), help="SQLite 输出路径")
    parser.add_argument("--snapshot-label", default="default", help="快照标签")
    parser.add_argument(
        "--extensions",
        default=",".join(DEFAULT_EXTENSIONS),
        help="待扫描扩展名，逗号分隔，例如 .ts,.ets,.tsx",
    )
    parser.add_argument(
        "--exclude-dirs",
        default=",".join(sorted(DEFAULT_EXCLUDE_DIRS)),
        help="排除目录名，逗号分隔",
    )
    parser.add_argument(
        "--prefer-tree-sitter",
        action="store_true",
        help="兼容旧参数；未显式指定 --parser-mode 时，将默认切到 ast",
    )
    parser.add_argument(
        "--parser-mode",
        choices=["regex", "ast", "hybrid"],
        default=None,
        help="解析模式：regex / ast / hybrid",
    )
    parser.add_argument(
        "--diff-report-path",
        default=None,
        help="Hybrid 差异报告输出路径（JSON）",
    )
    parser.add_argument(
        "--reset-db",
        action="store_true",
        help="写入前删除现有表结构并重建",
    )
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = parse_args(argv)
    root_path = Path(args.root).resolve()
    if not root_path.exists() or not root_path.is_dir():
        raise SystemExit(f"无效的源码根目录：{root_path}")
    extensions = [item.strip() for item in args.extensions.split(",") if item.strip()]
    exclude_dirs = [item.strip() for item in args.exclude_dirs.split(",") if item.strip()]
    diff_report_path = Path(args.diff_report_path) if args.diff_report_path else None
    indexer = RepoIndexer(
        root_path=root_path,
        db_path=Path(args.db),
        snapshot_label=args.snapshot_label,
        extensions=extensions,
        exclude_dirs=exclude_dirs,
        prefer_tree_sitter=bool(args.prefer_tree_sitter),
        parser_mode=args.parser_mode,
        diff_report_path=diff_report_path,
        reset_db=bool(args.reset_db),
    )
    return indexer.run()


if __name__ == "__main__":
    raise SystemExit(main())
