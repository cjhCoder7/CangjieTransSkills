#!/usr/bin/env python3
"""按物理方法边界切分源文件，供 chunked translation 使用。"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Dict, List, Mapping, Sequence


PROJECT_ROOT = Path(__file__).resolve().parents[1]
MTPROTOCLIENT_TARGET_PATH = "src/core/mtproto/MTProtoClient.ets"
CHUNKED_STRATEGY_ID = "mtprotoclient-method-boundary-v4"
CONTROLLED_EXPANSION_SINGLE_CHUNK_TARGETS = {
    "src/core/mtproto/CryptoUtils.ets": {
        "strategy": "cryptoutils-single-anchor-v1",
        "chunk_id": "module",
        "label": "Crypto Helpers",
        "description": "translate the full crypto utils module as a single frozen-anchor chunk",
        "expected_members": ["ByteUtils", "SHA1", "SHA256", "MTProtoCrypto", "EncryptedMessage"],
    },
    "src/core/mtproto/TLSerialization.ets": {
        "strategy": "tlserialization-single-anchor-v1",
        "chunk_id": "module",
        "label": "TL Serialization",
        "description": "translate the full TL serialization module as a single frozen-anchor chunk",
        "expected_members": ["TLConstructors", "TLSerializer", "TLDeserializer"],
    },
    "src/core/mtproto/MTProtoConfig.ets": {
        "strategy": "mtprotoconfig-single-anchor-v1",
        "chunk_id": "module",
        "label": "MTProto Config",
        "description": "translate the full config/session module as a single frozen-anchor chunk",
        "expected_members": ["AuthKeyState", "SessionInfo", "MTProtoConfig", "SessionManager"],
    },
    "src/core/mtproto/MTProtoTransport.ets": {
        "strategy": "mtprototransport-single-anchor-v1",
        "chunk_id": "module",
        "label": "Transport Core",
        "description": "translate the full transport module as a single frozen-anchor chunk",
        "expected_members": ["TransportState", "TransportCallback", "TCPTransport", "TransportManager"],
    },
    "src/core/mtproto/AuthKeyCreator.ets": {
        "strategy": "authkeycreator-single-anchor-v1",
        "chunk_id": "module",
        "label": "Auth Handshake",
        "description": "translate the full auth key creator module as a single frozen-anchor chunk",
        "expected_members": ["AuthKeyResult", "AuthKeyCreator"],
    },
    "src/core/mtproto/Inflate.ets": {
        "strategy": "inflate-single-anchor-v1",
        "chunk_id": "module",
        "label": "Compression",
        "description": "translate the full inflate module as a single frozen-anchor chunk",
        "expected_members": ["decompress"],
    },
}
MTPROTOCLIENT_CLASS_NAME = "MTProtoClient"
MTPROTOCLIENT_CLASS_MEMBER_NAMES = {
    "init",
    "setUpdateCallback",
    "initialize",
    "createAuthKey",
    "sendRequest",
    "initConnection",
    "onConnected",
    "onDisconnected",
    "onData",
    "onError",
}
MTPROTOCLIENT_TAIL_SYMBOLS = {
    "clientSingleton",
    "getMTProtoClient",
}


@dataclass
class SourceChunk:
    chunk_id: str
    label: str
    description: str
    source_text: str
    expected_members: List[str] = field(default_factory=list)
    found_members: List[str] = field(default_factory=list)
    missing_members: List[str] = field(default_factory=list)


@dataclass
class ChunkPlan:
    strategy: str
    target_path: str
    chunks: List[SourceChunk]
    warnings: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, object]:
        return {
            "strategy": self.strategy,
            "target_path": self.target_path,
            "warnings": list(self.warnings),
            "chunks": [asdict(chunk) for chunk in self.chunks],
        }


@dataclass
class ExtractedMember:
    name: str
    text: str
    start: int
    end: int


def supports_chunked_translation(target_path: str) -> bool:
    normalized = Path(target_path).as_posix()
    return normalized.endswith(MTPROTOCLIENT_TARGET_PATH) or normalized in CONTROLLED_EXPANSION_SINGLE_CHUNK_TARGETS


def build_chunk_plan(*, target_path: str, source_text: str) -> ChunkPlan:
    normalized_target_path = Path(target_path).as_posix()
    if not supports_chunked_translation(normalized_target_path):
        raise ValueError(f"chunked translation is not configured for target: {target_path}")
    if not source_text.strip():
        raise ValueError(f"target source is empty: {target_path}")
    if normalized_target_path in CONTROLLED_EXPANSION_SINGLE_CHUNK_TARGETS:
        return _build_single_chunk_plan(normalized_target_path, source_text)
    return _build_mtprotoclient_plan(normalized_target_path, source_text)


def build_readonly_stub(translated_code: str, *, max_chars: int = 2400) -> str:
    rendered_blocks = _render_stub_blocks(translated_code, inside_type=False)
    stub = "\n".join(block for block in rendered_blocks if block).strip() or translated_code.strip()
    if len(stub) <= max_chars:
        return stub
    return stub[: max_chars - 3] + "..."


def build_chunked_readonly_stub(
    *,
    target_path: str,
    translated_chunks: Mapping[str, str],
    max_chars: int = 2400,
) -> str:
    normalized_target_path = Path(target_path).as_posix()
    non_empty_chunks = {
        chunk_id: chunk_code
        for chunk_id, chunk_code in translated_chunks.items()
        if str(chunk_code).strip()
    }
    if not non_empty_chunks:
        return ""
    if normalized_target_path.endswith(MTPROTOCLIENT_TARGET_PATH):
        return _build_mtprotoclient_chunked_readonly_stub(non_empty_chunks, max_chars=max_chars)
    joined = "\n\n".join(str(chunk_code).strip() for chunk_code in non_empty_chunks.values()).strip()
    return build_readonly_stub(joined, max_chars=max_chars)


def _build_single_chunk_plan(target_path: str, source_text: str) -> ChunkPlan:
    config = CONTROLLED_EXPANSION_SINGLE_CHUNK_TARGETS[target_path]
    return ChunkPlan(
        strategy=str(config["strategy"]),
        target_path=target_path,
        chunks=[
            SourceChunk(
                chunk_id=str(config["chunk_id"]),
                label=str(config["label"]),
                description=str(config["description"]),
                source_text=source_text.strip() + "\n",
                expected_members=[str(item) for item in config["expected_members"]],
                found_members=[str(item) for item in config["expected_members"]],
                missing_members=[],
            )
        ],
        warnings=[],
    )


def _build_mtprotoclient_chunked_readonly_stub(
    translated_chunks: Mapping[str, str],
    *,
    max_chars: int,
) -> str:
    package_lines: List[str] = []
    import_lines: List[str] = []
    helper_blocks: List[str] = []
    class_fields: List[str] = []
    class_members: List[str] = []
    tail_blocks: List[str] = []
    package_seen: set[str] = set()
    import_seen: set[str] = set()
    helper_seen: set[str] = set()
    class_field_seen: set[str] = set()
    class_member_seen: set[str] = set()
    tail_seen: set[str] = set()
    class_header = ""
    include_tail_blocks = bool(str(translated_chunks.get("chunk-c", "")).strip())

    for chunk_id in _ordered_chunk_ids(translated_chunks):
        chunk_code = str(translated_chunks.get(chunk_id, "")).strip()
        if not chunk_code:
            continue
        chunk_stub = build_readonly_stub(chunk_code, max_chars=max(max_chars * 4, 16000))
        for block in _iter_stub_blocks(chunk_stub):
            stripped = block.strip()
            if not stripped or _is_comment_line(stripped):
                continue
            if stripped.startswith("package "):
                _append_unique(package_lines, package_seen, stripped)
                continue
            if stripped.startswith("import "):
                _append_unique(import_lines, import_seen, stripped)
                continue
            if _is_type_declaration(stripped) and "{" in block:
                type_name = _extract_type_name(stripped)
                if type_name == MTPROTOCLIENT_CLASS_NAME:
                    class_header = _prefer_mtprotoclient_header(current=class_header, candidate=block)
                    for member in _extract_type_members(block):
                        member_stripped = member.strip()
                        if not member_stripped:
                            continue
                        if _is_field_declaration(member_stripped):
                            _append_unique(
                                class_fields,
                                class_field_seen,
                                _indent_stub_member(member_stripped),
                            )
                        elif _is_callable_declaration(member_stripped):
                            _append_unique(
                                class_members,
                                class_member_seen,
                                _indent_stub_member(member_stripped),
                            )
                    continue
                _append_unique(helper_blocks, helper_seen, block.strip())
                continue
            if _is_field_declaration(stripped):
                field_name = _extract_field_name(stripped)
                if field_name in MTPROTOCLIENT_TAIL_SYMBOLS:
                    if include_tail_blocks:
                        _append_unique(tail_blocks, tail_seen, stripped)
                else:
                    _append_unique(class_fields, class_field_seen, _indent_stub_member(stripped))
                continue
            if _is_callable_declaration(stripped):
                callable_name = _extract_callable_name(stripped)
                if callable_name in MTPROTOCLIENT_CLASS_MEMBER_NAMES:
                    _append_unique(class_members, class_member_seen, _indent_stub_member(stripped))
                elif include_tail_blocks:
                    _append_unique(tail_blocks, tail_seen, stripped)

    blocks: List[str] = []
    blocks.extend(package_lines)
    blocks.extend(import_lines)
    blocks.extend(helper_blocks)
    if class_header:
        class_block_lines = [class_header.strip()]
        class_block_lines.extend(class_fields)
        class_block_lines.extend(class_members)
        class_block_lines.append("}")
        blocks.append("\n".join(class_block_lines))
    blocks.extend(tail_blocks)
    stub = "\n\n".join(block for block in blocks if block).strip()
    if len(stub) <= max_chars:
        return stub
    return stub[: max_chars - 3] + "..."


def _render_stub_blocks(text: str, *, inside_type: bool) -> List[str]:
    rendered: List[str] = []
    for block in _iter_stub_blocks(text):
        stripped = block.strip()
        if not stripped or _is_comment_line(stripped):
            continue
        if not inside_type and _is_package_or_import(stripped):
            rendered.append(stripped)
            continue
        if _is_type_declaration(stripped) and "{" in block:
            rendered.append(_render_type_stub(block))
            continue
        if _is_callable_declaration(stripped) and "{" in block:
            rendered.append(_render_callable_stub(block))
            continue
        if _is_field_declaration(stripped):
            rendered.append(_strip_initializer_from_declaration(block))
    return rendered


def _iter_stub_blocks(text: str) -> List[str]:
    lines = text.splitlines()
    blocks: List[str] = []
    index = 0
    while index < len(lines):
        line = lines[index].rstrip()
        stripped = line.strip()
        if not stripped or _is_comment_line(stripped):
            index += 1
            continue
        if "{" in line and (_is_type_declaration(stripped) or _is_callable_declaration(stripped)):
            block_lines, index = _consume_brace_block(lines, index)
            blocks.append("\n".join(block_lines).rstrip())
            continue
        blocks.append(line)
        index += 1
    return blocks


def _consume_brace_block(lines: Sequence[str], start_index: int) -> tuple[List[str], int]:
    block_lines: List[str] = []
    brace_depth = 0
    opened = False
    index = start_index
    while index < len(lines):
        line = lines[index].rstrip()
        block_lines.append(line)
        for char in line:
            if char == "{":
                brace_depth += 1
                opened = True
            elif char == "}":
                brace_depth -= 1
        index += 1
        if opened and brace_depth == 0:
            return block_lines, index
    return block_lines, index


def _render_type_stub(block_text: str) -> str:
    lines = [line.rstrip() for line in block_text.splitlines() if line.strip()]
    if not lines:
        return ""
    header_line = lines[0]
    body_text = "\n".join(lines[1:-1])
    members = _render_stub_blocks(body_text, inside_type=True)
    closing_indent = re.match(r"^\s*", header_line).group(0)
    parts = [header_line]
    parts.extend(member for member in members if member)
    parts.append(f"{closing_indent}}}")
    return "\n".join(parts)


def _render_callable_stub(block_text: str) -> str:
    header_text, _, _ = block_text.partition("{")
    header_line = header_text.rstrip()
    if not header_line:
        return ""
    return header_line + " {}"


def _strip_initializer_from_declaration(line: str) -> str:
    depth_paren = 0
    depth_bracket = 0
    depth_angle = 0
    for index, char in enumerate(line):
        if char == "(":
            depth_paren += 1
        elif char == ")" and depth_paren > 0:
            depth_paren -= 1
        elif char == "[":
            depth_bracket += 1
        elif char == "]" and depth_bracket > 0:
            depth_bracket -= 1
        elif char == "<":
            depth_angle += 1
        elif char == ">" and depth_angle > 0:
            depth_angle -= 1
        elif char == "=" and depth_paren == depth_bracket == depth_angle == 0:
            return line[:index].rstrip()
    return line.rstrip()


def _is_comment_line(stripped: str) -> bool:
    return stripped.startswith("//") or stripped.startswith("/*") or stripped.startswith("*/") or stripped.startswith("*")


def _is_package_or_import(stripped: str) -> bool:
    return stripped.startswith("package ") or stripped.startswith("import ")


def _is_type_declaration(stripped: str) -> bool:
    return bool(
        re.match(
            r"^(?:public|private|internal|protected)?\s*(?:sealed\s+|abstract\s+)?(?:class|struct|interface|enum|object)\b",
            stripped,
        )
    )


def _is_callable_declaration(stripped: str) -> bool:
    return bool(
        re.match(
            r"^(?:public|private|internal|protected)?\s*(?:override\s+)?(?:static\s+)?(?:mut\s+)?(?:func|init)\b",
            stripped,
        )
    )


def _is_field_declaration(stripped: str) -> bool:
    return bool(re.match(r"^(?:public|private|internal|protected)?\s*(?:let|var)\b", stripped))


def _ordered_chunk_ids(translated_chunks: Mapping[str, str]) -> List[str]:
    preferred_order = ["chunk-a", "chunk-a-ctor", "chunk-a-callback", "chunk-a-init", "chunk-b", "chunk-c"]
    ordered = [chunk_id for chunk_id in preferred_order if chunk_id in translated_chunks]
    ordered.extend(chunk_id for chunk_id in translated_chunks if chunk_id not in ordered)
    return ordered


def _append_unique(items: List[str], seen: set[str], value: str) -> None:
    normalized = value.strip()
    if not normalized or normalized in seen:
        return
    seen.add(normalized)
    items.append(value.rstrip())


def _extract_type_name(stripped: str) -> str:
    match = re.search(r"\b(class|struct|interface|enum|object)\s+([A-Za-z_][A-Za-z0-9_]*)", stripped)
    return match.group(2) if match else ""


def _extract_type_members(block_text: str) -> List[str]:
    lines = [line.rstrip() for line in block_text.splitlines() if line.strip()]
    if len(lines) < 3:
        return []
    body_text = "\n".join(lines[1:-1])
    return [member.strip() for member in _render_stub_blocks(body_text, inside_type=True) if member.strip()]


def _prefer_mtprotoclient_header(*, current: str, candidate: str) -> str:
    candidate_header = candidate.splitlines()[0].strip()
    if not current:
        return candidate_header
    if "<:" in candidate_header and "<:" not in current:
        return candidate_header
    if len(candidate_header) > len(current):
        return candidate_header
    return current


def _extract_field_name(stripped: str) -> str:
    match = re.match(r"^(?:public|private|internal|protected)?\s*(?:let|var)\s+([A-Za-z_][A-Za-z0-9_]*)", stripped)
    return match.group(1) if match else ""


def _extract_callable_name(stripped: str) -> str:
    if re.match(r"^(?:public|private|internal|protected)?\s*(?:override\s+)?(?:static\s+)?(?:mut\s+)?init\b", stripped):
        return "init"
    match = re.match(
        r"^(?:public|private|internal|protected)?\s*(?:override\s+)?(?:static\s+)?(?:mut\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)",
        stripped,
    )
    return match.group(1) if match else ""


def _indent_stub_member(stripped: str) -> str:
    return "    " + stripped


def assemble_chunk_translations(plan: ChunkPlan, chunk_outputs: Mapping[str, str]) -> str:
    rendered_chunks: List[str] = []
    for chunk in plan.chunks:
        payload = str(chunk_outputs.get(chunk.chunk_id, "")).strip()
        if not payload:
            raise ValueError(f"missing translated output for {chunk.chunk_id}")
        rendered_chunks.append(payload)
    return "\n\n".join(rendered_chunks).strip() + "\n"


def _build_mtprotoclient_plan(target_path: str, source_text: str) -> ChunkPlan:
    class_start = source_text.find("export class MTProtoClient")
    if class_start < 0:
        raise ValueError("failed to locate `export class MTProtoClient`")
    class_open = source_text.find("{", class_start)
    if class_open < 0:
        raise ValueError("failed to locate class opening brace")
    class_close = find_matching_brace(source_text, class_open)
    prefix_text = source_text[:class_start]
    class_header = source_text[class_start : class_open + 1]
    class_body = source_text[class_open + 1 : class_close]
    tail_text = source_text[class_close + 1 :]

    chunk_a_ctor_members = _collect_members(
        class_body,
        ["constructor"],
    )
    chunk_a_callback_members = _collect_members(
        class_body,
        ["setUpdateCallback"],
    )
    chunk_a_init_members = _collect_members(
        class_body,
        ["initialize"],
    )
    chunk_b_members = _collect_members(
        class_body,
        ["createAuthKey", "req_pq_multi", "req_DH_params", "set_client_DH_params"],
    )
    chunk_c_members = _collect_members(
        class_body,
        ["sendRequest", "initConnection", "onConnected", "onDisconnected", "onData", "onError"],
    )

    first_chunk_a_start = min(
        (
            member.start
            for member in [
                *chunk_a_ctor_members["found"],
                *chunk_a_callback_members["found"],
                *chunk_a_init_members["found"],
            ]
        ),
        default=0,
    )
    class_fields_prefix = class_body[:first_chunk_a_start]

    chunk_a_text = (
        prefix_text.rstrip()
        + "\n\n"
        + class_header
        + class_fields_prefix
    ).strip() + "\n"
    chunk_a_ctor_text = "".join(member.text for member in chunk_a_ctor_members["found"]).strip() + "\n"
    chunk_a_callback_text = "".join(member.text for member in chunk_a_callback_members["found"]).strip() + "\n"
    chunk_a_init_text = "".join(member.text for member in chunk_a_init_members["found"]).strip() + "\n"
    chunk_b_text = "".join(member.text for member in chunk_b_members["found"]).strip() + "\n"
    chunk_c_core = "".join(member.text for member in chunk_c_members["found"]).strip()
    chunk_c_tail = tail_text.strip()
    if chunk_c_core and chunk_c_tail:
        chunk_c_text = chunk_c_core + "\n}\n\n" + chunk_c_tail + "\n"
    elif chunk_c_core:
        chunk_c_text = chunk_c_core + "\n}\n"
    elif chunk_c_tail:
        chunk_c_text = "}\n\n" + chunk_c_tail + "\n"
    else:
        chunk_c_text = "}\n"

    warnings: List[str] = []
    if chunk_b_members["missing"]:
        warnings.append(
            "chunk-b directive members absent in source: " + ", ".join(chunk_b_members["missing"])
        )

    return ChunkPlan(
        strategy=CHUNKED_STRATEGY_ID,
        target_path=target_path,
        warnings=warnings,
        chunks=[
            SourceChunk(
                chunk_id="chunk-a",
                label="State Skeleton",
                description="imports, helper declarations, MTProtoClient class header, and state fields only",
                source_text=chunk_a_text,
                expected_members=[],
                found_members=[],
                missing_members=[],
            ),
            SourceChunk(
                chunk_id="chunk-a-ctor",
                label="Constructor Setup",
                description="constructor only",
                source_text=chunk_a_ctor_text,
                expected_members=["constructor"],
                found_members=[member.name for member in chunk_a_ctor_members["found"]],
                missing_members=chunk_a_ctor_members["missing"],
            ),
            SourceChunk(
                chunk_id="chunk-a-callback",
                label="Callback Hook",
                description="setUpdateCallback only",
                source_text=chunk_a_callback_text,
                expected_members=["setUpdateCallback"],
                found_members=[member.name for member in chunk_a_callback_members["found"]],
                missing_members=chunk_a_callback_members["missing"],
            ),
            SourceChunk(
                chunk_id="chunk-a-init",
                label="Initialize Flow",
                description="initialize overloads only",
                source_text=chunk_a_init_text,
                expected_members=["initialize"],
                found_members=[member.name for member in chunk_a_init_members["found"]],
                missing_members=chunk_a_init_members["missing"],
            ),
            SourceChunk(
                chunk_id="chunk-b",
                label="Auth Handshake",
                description="auth handshake members only; translate present source methods and record missing directive-only members",
                source_text=chunk_b_text,
                expected_members=["createAuthKey", "req_pq_multi", "req_DH_params", "set_client_DH_params"],
                found_members=[member.name for member in chunk_b_members["found"]],
                missing_members=chunk_b_members["missing"],
            ),
            SourceChunk(
                chunk_id="chunk-c",
                label="Network I/O",
                description="remaining network I/O, callbacks, class tail, and singleton tail",
                source_text=chunk_c_text,
                expected_members=["sendRequest", "initConnection", "onConnected", "onDisconnected", "onData", "onError", "getMTProtoClient"],
                found_members=[member.name for member in chunk_c_members["found"]] + _collect_tail_symbols(tail_text),
                missing_members=chunk_c_members["missing"],
            ),
        ],
    )


def _collect_members(class_body: str, member_names: Sequence[str]) -> Dict[str, object]:
    found: List[ExtractedMember] = []
    missing: List[str] = []
    for member_name in member_names:
        extracted = _extract_member_block(class_body, member_name)
        if extracted is None:
            missing.append(member_name)
            continue
        found.append(extracted)
    found.sort(key=lambda item: item.start)
    return {"found": found, "missing": missing}


def _extract_member_block(class_body: str, member_name: str) -> ExtractedMember | None:
    if member_name == "constructor":
        patterns = [re.compile(r"(?m)^[ \t]*constructor\s*\(")]
    else:
        patterns = [re.compile(rf"(?m)^[ \t]*(?:public|private|protected)?\s*(?:async\s+)?{re.escape(member_name)}\s*\(")]
    for pattern in patterns:
        match = pattern.search(class_body)
        if match is None:
            continue
        block_start = match.start()
        brace_index = class_body.find("{", match.start())
        if brace_index < 0:
            continue
        block_end = find_matching_brace(class_body, brace_index) + 1
        while block_end < len(class_body) and class_body[block_end] in {"\n", "\r"}:
            block_end += 1
        return ExtractedMember(
            name=member_name,
            text=class_body[block_start:block_end],
            start=block_start,
            end=block_end,
        )
    return None


def _collect_tail_symbols(tail_text: str) -> List[str]:
    symbols: List[str] = []
    if "getMTProtoClient" in tail_text:
        symbols.append("getMTProtoClient")
    return symbols


def find_matching_brace(text: str, open_brace_index: int) -> int:
    depth = 0
    for index in range(open_brace_index, len(text)):
        char = text[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return index
    raise ValueError(f"unmatched brace starting at index {open_brace_index}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Slice MTProtoClient.ets into chunked translation source blocks")
    parser.add_argument("--target-path", type=str, help="target relative path, e.g. src/core/mtproto/MTProtoClient.ets")
    parser.add_argument("--source-file", type=str, help="source file path")
    parser.add_argument("--tu-json", type=str, help="optional TU JSON path; if provided, read target.path + target.source from TU")
    parser.add_argument("--output", type=str, help="optional output JSON path")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.tu_json:
        tu_path = Path(args.tu_json).expanduser().resolve()
        payload = json.loads(tu_path.read_text(encoding="utf-8"))
        if not isinstance(payload, dict):
            raise SystemExit(f"invalid TU JSON object: {tu_path}")
        target = payload.get("target", {}) if isinstance(payload.get("target"), dict) else {}
        target_path = str(target.get("path", "")).strip()
        source_text = str(target.get("source", ""))
    else:
        if not args.target_path or not args.source_file:
            raise SystemExit("either --tu-json or both --target-path and --source-file are required")
        target_path = str(args.target_path)
        source_path = Path(args.source_file).expanduser().resolve()
        source_text = source_path.read_text(encoding="utf-8")
    plan = build_chunk_plan(target_path=target_path, source_text=source_text)
    rendered = json.dumps(plan.to_dict(), ensure_ascii=False, indent=2) + "\n"
    if args.output:
        output_path = Path(args.output).expanduser().resolve()
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(rendered, encoding="utf-8")
    else:
        print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
