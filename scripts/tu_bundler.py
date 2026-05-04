#!/usr/bin/env python3
"""Translation Unit 打包器。

功能：
1. 连接 `repo_index.sqlite`，读取指定快照；
2. 给定目标文件路径，递归计算文件级依赖闭包；
3. 对依赖文件进行签名级裁剪，只保留类 / 接口 / 函数 / 方法摘要；
4. 输出标准化 Translation Unit JSON，供 Orchestrator / Reviewer / Verifier 使用。

说明：
- 目标文件源码全文会被打入 TU；
- 依赖闭包默认只保留签名和模块摘要，不全文展开；
- 若索引库中缺少签名，脚本会回退到源文件的轻量 Regex 解析，以保证 TU 组装逻辑完整。
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import sqlite3
from collections import deque
from dataclasses import dataclass, field
from pathlib import Path
from typing import Deque, Dict, Iterable, List, Optional, Sequence, Set, Tuple

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DB_PATH = PROJECT_ROOT / "artifacts" / "repo_index.sqlite"
DEFAULT_OUTPUT_DIR = PROJECT_ROOT / "artifacts" / "tu"
DEPENDENCY_SIGNATURE_RE = re.compile(
    r"^\s*(?:export\s+)?(?:(class|interface|function)\s+([A-Za-z_][A-Za-z0-9_]*)|(?:public\s+|private\s+|protected\s+)?(?:static\s+)?(?:async\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*\([^\)]*\)\s*\{)",
    re.MULTILINE,
)


@dataclass
class DependencyReason:
    edge_type: str
    symbol_name: str
    confidence: float
    is_strong: bool
    metadata: Dict[str, object] = field(default_factory=dict)


@dataclass
class DependencyEntry:
    path: str
    depth: int
    reasons: List[DependencyReason] = field(default_factory=list)


class TranslationUnitBundler:
    def __init__(
        self,
        db_path: Path,
        target_file: str,
        output_path: Path,
        snapshot_label: Optional[str],
        max_depth: int,
        max_dependency_files: int,
        max_signatures_per_file: int,
    ) -> None:
        self.db_path = db_path.resolve()
        self.target_file = target_file
        self.output_path = output_path.resolve()
        self.snapshot_label = snapshot_label
        self.max_depth = max_depth
        self.max_dependency_files = max_dependency_files
        self.max_signatures_per_file = max_signatures_per_file

    def run(self) -> int:
        if not self.db_path.exists():
            raise SystemExit(f"SQLite 索引不存在：{self.db_path}")
        connection = sqlite3.connect(self.db_path)
        connection.row_factory = sqlite3.Row
        snapshot = load_snapshot(connection, self.snapshot_label)
        if snapshot is None:
            raise SystemExit(f"找不到快照：{self.snapshot_label or 'latest'}")
        snapshot_id = int(snapshot["id"])
        root_path = Path(str(snapshot["root_path"]))
        target_relative_path = normalize_target_path(root_path, self.target_file)
        target_node = load_file_node(connection, snapshot_id, target_relative_path)
        if target_node is None:
            raise SystemExit(f"目标文件未在索引库中出现：{target_relative_path}")
        target_source = read_source_text(root_path / target_relative_path)
        closure_entries = compute_dependency_closure(
            connection=connection,
            snapshot_id=snapshot_id,
            target_path=target_relative_path,
            max_depth=self.max_depth,
            max_dependency_files=self.max_dependency_files,
        )
        target_symbols = load_signatures(
            connection=connection,
            snapshot_id=snapshot_id,
            file_path=target_relative_path,
            root_path=root_path,
            max_signatures=self.max_signatures_per_file,
        )
        dependency_context = [
            build_dependency_context(
                connection=connection,
                snapshot_id=snapshot_id,
                root_path=root_path,
                entry=entry,
                max_signatures=self.max_signatures_per_file,
            )
            for entry in closure_entries
        ]
        translation_unit = {
            "tu_id": build_tu_id(snapshot, target_relative_path),
            "schema_reference": "skills/SKILL_SCHEMA_V2.md",
            "snapshot": {
                "id": snapshot_id,
                "label": snapshot["label"],
                "root_path": snapshot["root_path"],
                "parser_backend": snapshot["parser_backend"],
                "created_at": snapshot["created_at"],
            },
            "target": {
                "path": target_relative_path,
                "role": target_node["role"],
                "summary": target_node["summary"],
                "risk_tags": load_json_list(target_node["risk_tags_json"]),
                "state_tags": load_json_list(target_node["state_tags_json"]),
                "thread_tags": load_json_list(target_node["thread_tags_json"]),
                "interop_tags": load_json_list(target_node["interop_tags_json"]),
                "source": target_source,
                "signatures": target_symbols,
            },
            "dependency_closure": dependency_context,
            "extended_candidates": [],
            "metadata": {
                "generated_at": utc_now(),
                "closure_depth": self.max_depth,
                "dependency_file_count": len(dependency_context),
                "max_signatures_per_file": self.max_signatures_per_file,
            },
        }
        self.output_path.parent.mkdir(parents=True, exist_ok=True)
        self.output_path.write_text(json.dumps(translation_unit, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(
            json.dumps(
                {
                    "output_path": str(self.output_path),
                    "tu_id": translation_unit["tu_id"],
                    "snapshot_id": snapshot_id,
                    "target_path": target_relative_path,
                    "dependency_file_count": len(dependency_context),
                },
                ensure_ascii=False,
            )
        )
        return 0


def load_snapshot(connection: sqlite3.Connection, snapshot_label: Optional[str]) -> Optional[sqlite3.Row]:
    if snapshot_label:
        return connection.execute(
            "SELECT * FROM snapshots WHERE label = ? ORDER BY id DESC LIMIT 1",
            (snapshot_label,),
        ).fetchone()
    return connection.execute("SELECT * FROM snapshots ORDER BY id DESC LIMIT 1").fetchone()


def normalize_target_path(root_path: Path, target_file: str) -> str:
    raw_path = Path(target_file)
    if raw_path.is_absolute():
        resolved = raw_path.resolve()
    else:
        resolved = (root_path / raw_path).resolve()
    try:
        return resolved.relative_to(root_path.resolve()).as_posix()
    except ValueError as exc:
        raise SystemExit(f"目标文件必须位于快照根目录内：{resolved}") from exc


def load_file_node(connection: sqlite3.Connection, snapshot_id: int, path: str) -> Optional[sqlite3.Row]:
    return connection.execute(
        "SELECT * FROM nodes WHERE snapshot_id = ? AND kind = 'file' AND path = ? LIMIT 1",
        (snapshot_id, path),
    ).fetchone()


def read_source_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text(encoding="utf-8", errors="ignore")


def compute_dependency_closure(
    connection: sqlite3.Connection,
    snapshot_id: int,
    target_path: str,
    max_depth: int,
    max_dependency_files: int,
) -> List[DependencyEntry]:
    queue: Deque[Tuple[str, int]] = deque([(target_path, 0)])
    visited_depth: Dict[str, int] = {target_path: 0}
    results: Dict[str, DependencyEntry] = {}

    while queue:
        current_path, current_depth = queue.popleft()
        if current_depth >= max_depth:
            continue
        dependencies = query_file_dependencies(connection, snapshot_id, current_path)
        for dep_path, reason in dependencies:
            if dep_path == target_path:
                continue
            existing = results.get(dep_path)
            if existing is None:
                if len(results) >= max_dependency_files:
                    continue
                existing = DependencyEntry(path=dep_path, depth=current_depth + 1)
                results[dep_path] = existing
            existing.depth = min(existing.depth, current_depth + 1)
            if not any(
                item.edge_type == reason.edge_type and item.symbol_name == reason.symbol_name and item.metadata == reason.metadata
                for item in existing.reasons
            ):
                existing.reasons.append(reason)
            known_depth = visited_depth.get(dep_path)
            next_depth = current_depth + 1
            if known_depth is None or next_depth < known_depth:
                visited_depth[dep_path] = next_depth
                queue.append((dep_path, next_depth))

    return sorted(results.values(), key=lambda item: (item.depth, item.path))


def query_file_dependencies(
    connection: sqlite3.Connection,
    snapshot_id: int,
    file_path: str,
) -> List[Tuple[str, DependencyReason]]:
    rows = connection.execute(
        """
        SELECT DISTINCT
            COALESCE(dst.path, e.dst_path) AS dep_path,
            e.edge_type,
            e.symbol_name,
            e.is_strong,
            e.confidence,
            e.metadata_json
        FROM edges e
        LEFT JOIN nodes src ON src.id = e.src_node_id
        LEFT JOIN nodes dst ON dst.id = e.dst_node_id
        WHERE e.snapshot_id = ?
          AND (
                (e.edge_type = 'import' AND e.src_path = ? AND dst.path IS NOT NULL)
             OR (e.edge_type = 'call' AND src.path = ? AND dst.path IS NOT NULL)
          )
          AND COALESCE(dst.path, e.dst_path) IS NOT NULL
          AND COALESCE(dst.path, e.dst_path) != ?
        ORDER BY e.is_strong DESC, e.confidence DESC, dep_path ASC
        """,
        (snapshot_id, file_path, file_path, file_path),
    ).fetchall()
    result: List[Tuple[str, DependencyReason]] = []
    for row in rows:
        dep_path = str(row["dep_path"])
        result.append(
            (
                dep_path,
                DependencyReason(
                    edge_type=str(row["edge_type"]),
                    symbol_name=str(row["symbol_name"] or ""),
                    confidence=float(row["confidence"]),
                    is_strong=bool(row["is_strong"]),
                    metadata=load_json_object(row["metadata_json"]),
                ),
            )
        )
    return result


def build_dependency_context(
    connection: sqlite3.Connection,
    snapshot_id: int,
    root_path: Path,
    entry: DependencyEntry,
    max_signatures: int,
) -> Dict[str, object]:
    node = load_file_node(connection, snapshot_id, entry.path)
    if node is None:
        raise SystemExit(f"依赖文件未在索引库中找到：{entry.path}")
    signatures = load_signatures(connection, snapshot_id, entry.path, root_path, max_signatures)
    return {
        "path": entry.path,
        "depth": entry.depth,
        "role": node["role"],
        "summary": node["summary"],
        "risk_tags": load_json_list(node["risk_tags_json"]),
        "state_tags": load_json_list(node["state_tags_json"]),
        "thread_tags": load_json_list(node["thread_tags_json"]),
        "interop_tags": load_json_list(node["interop_tags_json"]),
        "reasons": [
            {
                "edge_type": reason.edge_type,
                "symbol_name": reason.symbol_name,
                "confidence": reason.confidence,
                "is_strong": reason.is_strong,
                "metadata": reason.metadata,
            }
            for reason in entry.reasons
        ],
        "signatures": signatures,
    }


def load_signatures(
    connection: sqlite3.Connection,
    snapshot_id: int,
    file_path: str,
    root_path: Path,
    max_signatures: int,
) -> List[Dict[str, object]]:
    rows = connection.execute(
        """
        SELECT kind, name, signature, summary, start_line, end_line, role, metadata_json
        FROM nodes
        WHERE snapshot_id = ?
          AND path = ?
          AND kind IN ('class', 'interface', 'function', 'method')
        ORDER BY
            CASE kind
                WHEN 'class' THEN 0
                WHEN 'interface' THEN 1
                WHEN 'function' THEN 2
                WHEN 'method' THEN 3
                ELSE 9
            END,
            start_line ASC,
            name ASC
        LIMIT ?
        """,
        (snapshot_id, file_path, max_signatures),
    ).fetchall()
    if rows:
        items: List[Dict[str, object]] = []
        for row in rows:
            metadata = load_json_object(row["metadata_json"])
            items.append(
                {
                    "kind": row["kind"],
                    "name": row["name"],
                    "signature": row["signature"],
                    "summary": row["summary"],
                    "start_line": row["start_line"],
                    "end_line": row["end_line"],
                    "role": row["role"],
                    "parent_name": str(metadata.get("parent_symbol", "")),
                    "parent_kind": str(metadata.get("parent_kind", "")),
                }
            )
        return items
    source_path = root_path / file_path
    if not source_path.exists():
        return []
    text = read_source_text(source_path)
    fallback = extract_signature_fallback(text)
    return fallback[:max_signatures]


def extract_signature_fallback(text: str) -> List[Dict[str, object]]:
    items: List[Dict[str, object]] = []
    lines = text.splitlines()
    for match in DEPENDENCY_SIGNATURE_RE.finditer(text):
        line = text[: match.start()].count("\n") + 1
        raw_line = lines[line - 1].strip() if 0 < line <= len(lines) else ""
        kind = match.group(1) or "method"
        name = match.group(2) or match.group(3) or "anonymous"
        items.append(
            {
                "kind": kind,
                "name": name,
                "signature": compact_line(raw_line),
                "summary": f"fallback {kind} {name}",
                "start_line": line,
                "end_line": line,
                "role": "fallback",
            }
        )
    return items


def compact_line(text: str, limit: int = 180) -> str:
    compact = re.sub(r"\s+", " ", text).strip()
    if len(compact) <= limit:
        return compact
    return compact[: limit - 3] + "..."


def build_tu_id(snapshot: sqlite3.Row, target_path: str) -> str:
    safe_target = target_path.replace("/", "::")
    return f"tu::{snapshot['label']}::{safe_target}"


def load_json_list(raw_value: object) -> List[str]:
    if raw_value in (None, ""):
        return []
    try:
        value = json.loads(str(raw_value))
    except json.JSONDecodeError:
        return []
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if str(item)]


def load_json_object(raw_value: object) -> Dict[str, object]:
    if raw_value in (None, ""):
        return {}
    try:
        value = json.loads(str(raw_value))
    except json.JSONDecodeError:
        return {}
    if not isinstance(value, dict):
        return {}
    return {str(key): value[key] for key in value}


def utc_now() -> str:
    return dt.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="根据 repo_index.sqlite 生成 Translation Unit JSON")
    parser.add_argument("--db", default=str(DEFAULT_DB_PATH), help="repo_index.sqlite 路径")
    parser.add_argument("--target-file", required=True, help="目标文件路径，相对快照根目录或绝对路径")
    parser.add_argument("--output", help="TU JSON 输出路径；默认写入 artifacts/tu/")
    parser.add_argument("--snapshot-label", help="指定快照标签；不传则使用最新快照")
    parser.add_argument("--max-depth", type=int, default=2, help="依赖闭包递归深度")
    parser.add_argument("--max-dependency-files", type=int, default=12, help="最多保留多少个依赖文件")
    parser.add_argument("--max-signatures-per-file", type=int, default=8, help="每个依赖文件最多保留多少个签名")
    return parser.parse_args(argv)


def default_output_path(target_file: str) -> Path:
    target_name = Path(target_file).name
    return DEFAULT_OUTPUT_DIR / f"{target_name}.tu.json"


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = parse_args(argv)
    output_path = Path(args.output) if args.output else default_output_path(args.target_file)
    bundler = TranslationUnitBundler(
        db_path=Path(args.db),
        target_file=args.target_file,
        output_path=output_path,
        snapshot_label=args.snapshot_label,
        max_depth=args.max_depth,
        max_dependency_files=args.max_dependency_files,
        max_signatures_per_file=args.max_signatures_per_file,
    )
    return bundler.run()


if __name__ == "__main__":
    raise SystemExit(main())
