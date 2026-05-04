#!/usr/bin/env python3
"""诊断 DevEco 工程中 ArkTS <-> Cangjie interop 导出契约是否对齐。"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any, Dict, Iterable, List, Set


SKIP_DIR_NAMES = {".git", ".hg", ".svn", "node_modules", ".hvigor", ".idea", "build"}
TARGET_SO_NAME = "libohos_app_cangjie_entry.so"
LOADER_PACKAGE = "libark_interop_loader.so"

DIRECT_NAMED_IMPORT_RE = re.compile(
    r"import\s*\{\s*(?P<symbols>[^}]+?)\s*\}\s*from\s*['\"]libohos_app_cangjie_entry\.so['\"]",
    re.MULTILINE,
)
DIRECT_DEFAULT_IMPORT_RE = re.compile(
    r"import\s+(?!\{)(?!\*)(?P<symbol>[A-Za-z_][A-Za-z0-9_]*)\s+from\s*['\"]libohos_app_cangjie_entry\.so['\"]",
    re.MULTILINE,
)
DIRECT_NAMESPACE_IMPORT_RE = re.compile(
    r"import\s+\*\s+as\s+(?P<symbol>[A-Za-z_][A-Za-z0-9_]*)\s+from\s*['\"]libohos_app_cangjie_entry\.so['\"]",
    re.MULTILINE,
)
LOADER_CALL_RE = re.compile(r"requireCJLib\(\s*['\"]libohos_app_cangjie_entry\.so['\"]\s*\)")
LOADER_REF_RE = re.compile(r"['\"]libark_interop_loader\.so['\"]")
EXPORT_SYMBOL_RE = re.compile(r"exports\[\s*['\"](?P<symbol>[^'\"]+)['\"]\s*\]")
DECLARED_SYMBOL_RE = re.compile(
    r"export(?:\s+declare)?\s+(?:abstract\s+)?(?:function|const|class|interface|type|enum)\s+(?P<symbol>[A-Za-z_][A-Za-z0-9_]*)"
)
EXPORT_LIST_RE = re.compile(r"export\s*\{(?P<symbols>[^}]+)\}")
DEFAULT_EXPORT_RE = re.compile(r"export\s+default\b")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="诊断 ArkTS / Cangjie interop 契约是否对齐")
    parser.add_argument("--project-root", required=True, help="待分析的 DevEco 工程根目录")
    parser.add_argument(
        "--format",
        choices=("json", "text"),
        default="json",
        help="输出格式：json 或 text",
    )
    return parser.parse_args()


def should_skip(path: Path) -> bool:
    return any(part in SKIP_DIR_NAMES for part in path.parts)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def line_number(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def split_symbols(raw: str) -> List[str]:
    symbols: List[str] = []
    for item in raw.split(","):
        piece = item.strip()
        if not piece:
            continue
        if " as " in piece:
            left, right = piece.split(" as ", 1)
            exported = right.strip() or left.strip()
        else:
            exported = piece
        if exported:
            symbols.append(exported)
    return symbols


def relative_path(project_root: Path, path: Path) -> str:
    return str(path.relative_to(project_root).as_posix())


def iter_files(project_root: Path, suffixes: Iterable[str]) -> Iterable[Path]:
    suffix_set = set(suffixes)
    for path in project_root.rglob("*"):
        if not path.is_file():
            continue
        relative = path.relative_to(project_root)
        if should_skip(relative):
            continue
        if path.suffix in suffix_set:
            yield path


def collect_arkts_imports(project_root: Path) -> Dict[str, Any]:
    direct_imports: List[Dict[str, Any]] = []
    loader_usages: List[Dict[str, Any]] = []
    for path in iter_files(project_root, {".ets", ".ts"}):
        text = read_text(path)
        relative = relative_path(project_root, path)
        for match in DIRECT_NAMED_IMPORT_RE.finditer(text):
            direct_imports.append(
                {
                    "path": relative,
                    "line": line_number(text, match.start()),
                    "module": TARGET_SO_NAME,
                    "mode": "named",
                    "symbols": split_symbols(match.group("symbols")),
                }
            )
        for match in DIRECT_DEFAULT_IMPORT_RE.finditer(text):
            direct_imports.append(
                {
                    "path": relative,
                    "line": line_number(text, match.start()),
                    "module": TARGET_SO_NAME,
                    "mode": "default",
                    "symbols": [match.group("symbol")],
                }
            )
        for match in DIRECT_NAMESPACE_IMPORT_RE.finditer(text):
            direct_imports.append(
                {
                    "path": relative,
                    "line": line_number(text, match.start()),
                    "module": TARGET_SO_NAME,
                    "mode": "namespace",
                    "symbols": [match.group("symbol")],
                }
            )
        for match in LOADER_CALL_RE.finditer(text):
            loader_usages.append(
                {
                    "path": relative,
                    "line": line_number(text, match.start()),
                    "module": TARGET_SO_NAME,
                }
            )
    direct_imports.sort(key=lambda item: (item["path"], item["line"], item["mode"]))
    loader_usages.sort(key=lambda item: (item["path"], item["line"]))
    return {
        "direct_imports": direct_imports,
        "loader_usages": loader_usages,
    }


def parse_declared_exports(text: str) -> Dict[str, Any]:
    named_symbols: Set[str] = set()
    for match in DECLARED_SYMBOL_RE.finditer(text):
        named_symbols.add(match.group("symbol"))
    for match in EXPORT_LIST_RE.finditer(text):
        named_symbols.update(split_symbols(match.group("symbols")))
    return {
        "named_exports": sorted(named_symbols),
        "has_default_export": bool(DEFAULT_EXPORT_RE.search(text)),
    }


def collect_types(project_root: Path) -> List[Dict[str, Any]]:
    results: List[Dict[str, Any]] = []
    for path in iter_files(project_root, {".ts"}):
        if path.name.endswith(".d.ts"):
            text = read_text(path)
            relative = relative_path(project_root, path)
            if "libark_interop_loader.d.ts" in relative:
                continue
            parsed = parse_declared_exports(text)
            results.append(
                {
                    "path": relative,
                    "named_exports": parsed["named_exports"],
                    "has_default_export": parsed["has_default_export"],
                }
            )
    results.sort(key=lambda item: item["path"])
    return results


def collect_loader(project_root: Path) -> Dict[str, Any]:
    files: List[str] = []
    referenced_by: List[str] = []
    for path in project_root.rglob("libark_interop_loader.d.ts"):
        if not path.is_file():
            continue
        relative = path.relative_to(project_root)
        if should_skip(relative):
            continue
        files.append(relative_path(project_root, path))
    for path in project_root.rglob("oh-package.json5"):
        if not path.is_file():
            continue
        relative = path.relative_to(project_root)
        if should_skip(relative):
            continue
        text = read_text(path)
        if LOADER_REF_RE.search(text):
            referenced_by.append(relative_path(project_root, path))
    files.sort()
    referenced_by.sort()
    return {
        "available": bool(files or referenced_by),
        "files": files,
        "referenced_by": referenced_by,
    }


def collect_cangjie_exports(project_root: Path) -> List[Dict[str, Any]]:
    exports: List[Dict[str, Any]] = []
    for path in iter_files(project_root, {".cj"}):
        text = read_text(path)
        symbols = sorted({match.group("symbol") for match in EXPORT_SYMBOL_RE.finditer(text)})
        if not symbols:
            continue
        exports.append(
            {
                "path": relative_path(project_root, path),
                "symbols": symbols,
            }
        )
    exports.sort(key=lambda item: item["path"])
    return exports


def flatten_declared_symbols(type_entries: List[Dict[str, Any]]) -> Set[str]:
    symbols: Set[str] = set()
    for entry in type_entries:
        symbols.update(entry.get("named_exports", []))
    return symbols


def has_default_export(type_entries: List[Dict[str, Any]]) -> bool:
    return any(bool(entry.get("has_default_export")) for entry in type_entries)


def flatten_cangjie_symbols(cangjie_exports: List[Dict[str, Any]]) -> Set[str]:
    symbols: Set[str] = set()
    for entry in cangjie_exports:
        symbols.update(entry.get("symbols", []))
    return symbols


def assess_contract(
    direct_imports: List[Dict[str, Any]],
    loader_usages: List[Dict[str, Any]],
    loader: Dict[str, Any],
    type_entries: List[Dict[str, Any]],
    cangjie_exports: List[Dict[str, Any]],
) -> Dict[str, Any]:
    issue_codes: List[str] = []
    issue_details: List[str] = []
    declared_symbols = flatten_declared_symbols(type_entries)
    exported_symbols = flatten_cangjie_symbols(cangjie_exports)
    types_have_default_export = has_default_export(type_entries)
    loader_available = bool(loader.get("available"))

    named_imports = [item for item in direct_imports if item["mode"] == "named"]
    default_imports = [item for item in direct_imports if item["mode"] == "default"]
    namespace_imports = [item for item in direct_imports if item["mode"] == "namespace"]

    if direct_imports and loader_available:
        issue_codes.append("direct_import_bypasses_loader_path")
        issue_details.append(
            "工程内已经存在 libark_interop_loader.so 路径，但 ArkTS 仍直接 import libohos_app_cangjie_entry.so；这与当前官方样例主路径不一致。"
        )
        if named_imports:
            issue_codes.append("direct_named_import_on_cangjie_so")
            issue_details.append(
                "ArkTS 直接从 libohos_app_cangjie_entry.so 做 named import；在当前 HarmonyOS Cangjie 样例里，标准形态是 requireCJLib(...) 返回对象后再取方法。"
            )
            requested_symbols = sorted({symbol for item in named_imports for symbol in item["symbols"]})
            missing_in_types = sorted(symbol for symbol in requested_symbols if symbol not in declared_symbols)
            missing_in_cangjie = sorted(symbol for symbol in requested_symbols if symbol not in exported_symbols)
            if missing_in_types and types_have_default_export:
                issue_codes.append("named_import_not_declared_in_types")
                issue_details.append(
                    f"named import 请求的符号未在声明文件中以 named export 暴露，当前 d.ts 只表现出 default export 形态：{', '.join(missing_in_types)}。"
                )
            if missing_in_cangjie:
                issue_codes.append("named_import_not_found_in_cangjie_exports")
                issue_details.append(
                    f"named import 请求的符号未在 Cangjie JSModule exports[...] 中找到：{', '.join(missing_in_cangjie)}。"
                )
        elif default_imports:
            issue_details.append(
                "当前 direct default import 仍绕开了 requireCJLib(...) loader，对应运行时更容易出现模块对象为 undefined 或属性缺失。"
            )
        elif namespace_imports:
            issue_details.append(
                "当前 namespace import 仍绕开了 requireCJLib(...) loader，应先回到 loader-object 主路径验证导出对象。"
            )
        return {
            "status": "mismatch",
            "recommended_contract_shape": "loader-object",
            "issue_codes": issue_codes,
            "details": issue_details,
        }

    if named_imports:
        issue_codes.append("direct_named_import_on_cangjie_so")
        issue_details.append(
            "ArkTS 直接从 libohos_app_cangjie_entry.so 做 named import；在当前 HarmonyOS Cangjie 样例里，标准形态是 requireCJLib(...) 返回对象后再取方法。"
        )
        requested_symbols = sorted({symbol for item in named_imports for symbol in item["symbols"]})
        missing_in_types = sorted(symbol for symbol in requested_symbols if symbol not in declared_symbols)
        missing_in_cangjie = sorted(symbol for symbol in requested_symbols if symbol not in exported_symbols)
        if missing_in_types and types_have_default_export:
            issue_codes.append("named_import_not_declared_in_types")
            issue_details.append(
                f"named import 请求的符号未在声明文件中以 named export 暴露，当前 d.ts 只表现出 default export 形态：{', '.join(missing_in_types)}。"
            )
        if missing_in_cangjie:
            issue_codes.append("named_import_not_found_in_cangjie_exports")
            issue_details.append(
                f"named import 请求的符号未在 Cangjie JSModule exports[...] 中找到：{', '.join(missing_in_cangjie)}。"
            )
        if loader_available:
            recommended_contract_shape = "loader-object"
        elif types_have_default_export:
            recommended_contract_shape = "direct-default"
        else:
            recommended_contract_shape = "unknown"
        return {
            "status": "mismatch",
            "recommended_contract_shape": recommended_contract_shape,
            "issue_codes": issue_codes,
            "details": issue_details,
        }

    if loader_usages:
        return {
            "status": "aligned",
            "recommended_contract_shape": "loader-object",
            "issue_codes": [],
            "details": [
                "ArkTS 当前通过 requireCJLib(...) 获取 libohos_app_cangjie_entry.so 导出对象，已与官方样例主路径一致。"
            ],
        }

    if default_imports and types_have_default_export:
        return {
            "status": "aligned",
            "recommended_contract_shape": "direct-default",
            "issue_codes": [],
            "details": [
                "ArkTS 当前使用 default import，且本地 d.ts 也显式提供 default export。"
            ],
        }

    status = "unknown"
    recommended_contract_shape = "loader-object" if loader_available else "unknown"
    details = [
        "未检测到足够的 ArkTS 调用形态来给出严格结论；请补充页面侧调用代码或直接运行到 Hilog 对照。"
    ]
    return {
        "status": status,
        "recommended_contract_shape": recommended_contract_shape,
        "issue_codes": [],
        "details": details,
    }


def build_payload(project_root: Path) -> Dict[str, Any]:
    arkts = collect_arkts_imports(project_root)
    loader = collect_loader(project_root)
    interop_types = collect_types(project_root)
    cangjie_exports = collect_cangjie_exports(project_root)
    assessment = assess_contract(
        direct_imports=arkts["direct_imports"],
        loader_usages=arkts["loader_usages"],
        loader=loader,
        type_entries=interop_types,
        cangjie_exports=cangjie_exports,
    )
    return {
        "project_root": str(project_root.resolve()),
        "target_so_name": TARGET_SO_NAME,
        "loader": loader,
        "arkts_direct_imports": arkts["direct_imports"],
        "arkts_loader_usages": arkts["loader_usages"],
        "interop_types": interop_types,
        "cangjie_exports": cangjie_exports,
        "assessment": assessment,
    }


def render_text(payload: Dict[str, Any]) -> str:
    assessment = payload["assessment"]
    lines = [
        f"project_root={payload['project_root']}",
        f"status={assessment['status']}",
        f"recommended_contract_shape={assessment['recommended_contract_shape']}",
    ]
    issue_codes = assessment.get("issue_codes", [])
    if issue_codes:
        lines.append(f"issue_codes={','.join(issue_codes)}")
    lines.append(f"loader_available={'true' if payload['loader']['available'] else 'false'}")
    lines.append(f"arkts_direct_import_count={len(payload['arkts_direct_imports'])}")
    lines.append(f"arkts_loader_usage_count={len(payload['arkts_loader_usages'])}")
    if payload["cangjie_exports"]:
        exported = ",".join(payload["cangjie_exports"][0]["symbols"])
        lines.append(f"first_cangjie_export_symbols={exported}")
    for detail in assessment.get("details", []):
        lines.append(f"detail={detail}")
    return "\n".join(lines) + "\n"


def main() -> int:
    args = parse_args()
    project_root = Path(args.project_root).expanduser()
    if not project_root.exists():
        print(f"project root does not exist: {project_root}", file=sys.stderr)
        return 1
    if not project_root.is_dir():
        print(f"project root is not a directory: {project_root}", file=sys.stderr)
        return 1
    payload = build_payload(project_root.resolve())
    if args.format == "text":
        sys.stdout.write(render_text(payload))
    else:
        sys.stdout.write(json.dumps(payload, ensure_ascii=False, indent=2) + "\n")
    return 2 if payload["assessment"]["status"] == "mismatch" else 0


if __name__ == "__main__":
    raise SystemExit(main())
