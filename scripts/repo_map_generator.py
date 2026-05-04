#!/usr/bin/env python3
"""Repo Map 生成器。

功能：
1. 读取 `repo_indexer.py` 生成的 SQLite 索引库；
2. 选择最新或指定快照；
3. 查询文件节点、符号节点、依赖边与调用边；
4. 生成适合 LLM 阅读的 `repo_map.txt`，采用 Aider 风格缩进树结构；
5. 输出模块角色、关键符号、直接依赖、调用热点与风险标签。
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import sqlite3
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DB_PATH = PROJECT_ROOT / "artifacts" / "repo_index.sqlite"
DEFAULT_OUTPUT_PATH = PROJECT_ROOT / "artifacts" / "repo_map.txt"


@dataclass
class FileCard:
    path: str
    role: str
    summary: str
    risk_tags: List[str] = field(default_factory=list)
    state_tags: List[str] = field(default_factory=list)
    thread_tags: List[str] = field(default_factory=list)
    interop_tags: List[str] = field(default_factory=list)
    symbols: List[str] = field(default_factory=list)
    imports: List[str] = field(default_factory=list)
    dependents: List[str] = field(default_factory=list)
    calls: List[str] = field(default_factory=list)


@dataclass
class TreeNode:
    name: str
    path: str = ""
    is_file: bool = False
    children: Dict[str, "TreeNode"] = field(default_factory=dict)
    file_card: Optional[FileCard] = None


class RepoMapGenerator:
    def __init__(
        self,
        db_path: Path,
        output_path: Path,
        snapshot_label: Optional[str],
        max_symbols: int,
        max_imports: int,
        max_calls: int,
    ) -> None:
        self.db_path = db_path.resolve()
        self.output_path = output_path.resolve()
        self.snapshot_label = snapshot_label
        self.max_symbols = max_symbols
        self.max_imports = max_imports
        self.max_calls = max_calls

    def run(self) -> int:
        if not self.db_path.exists():
            raise SystemExit(f"SQLite 索引不存在：{self.db_path}")
        connection = sqlite3.connect(self.db_path)
        connection.row_factory = sqlite3.Row
        snapshot = load_snapshot(connection, self.snapshot_label)
        if snapshot is None:
            label_text = self.snapshot_label or "最新快照"
            raise SystemExit(f"找不到快照：{label_text}")
        snapshot_id = int(snapshot["id"])
        file_cards = load_file_cards(connection, snapshot_id, self.max_symbols, self.max_imports, self.max_calls)
        content = render_repo_map(snapshot, file_cards)
        self.output_path.parent.mkdir(parents=True, exist_ok=True)
        self.output_path.write_text(content, encoding="utf-8")
        print(
            json.dumps(
                {
                    "output_path": str(self.output_path),
                    "snapshot_id": snapshot_id,
                    "snapshot_label": snapshot["label"],
                    "file_count": len(file_cards),
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


def load_file_cards(
    connection: sqlite3.Connection,
    snapshot_id: int,
    max_symbols: int,
    max_imports: int,
    max_calls: int,
) -> List[FileCard]:
    file_rows = connection.execute(
        """
        SELECT path, role, summary, risk_tags_json, state_tags_json, thread_tags_json, interop_tags_json
        FROM nodes
        WHERE snapshot_id = ? AND kind = 'file'
        ORDER BY path ASC
        """,
        (snapshot_id,),
    ).fetchall()
    cards: Dict[str, FileCard] = {}
    for row in file_rows:
        path = str(row["path"])
        cards[path] = FileCard(
            path=path,
            role=str(row["role"]),
            summary=str(row["summary"]),
            risk_tags=load_json_list(row["risk_tags_json"]),
            state_tags=load_json_list(row["state_tags_json"]),
            thread_tags=load_json_list(row["thread_tags_json"]),
            interop_tags=load_json_list(row["interop_tags_json"]),
        )

    symbol_rows = connection.execute(
        """
        SELECT path, name, kind
        FROM nodes
        WHERE snapshot_id = ? AND kind IN ('class', 'interface', 'function', 'method')
        ORDER BY path ASC, start_line ASC, name ASC
        """,
        (snapshot_id,),
    ).fetchall()
    for row in symbol_rows:
        path = str(row["path"])
        card = cards.get(path)
        if card is None:
            continue
        label = f"{row['kind']}:{row['name']}"
        if len(card.symbols) < max_symbols:
            card.symbols.append(label)

    import_rows = connection.execute(
        """
        SELECT src_path, dst_path
        FROM edges
        WHERE snapshot_id = ? AND edge_type = 'import'
        ORDER BY src_path ASC, dst_path ASC
        """,
        (snapshot_id,),
    ).fetchall()
    for row in import_rows:
        src_path = str(row["src_path"])
        dst_path = str(row["dst_path"])
        card = cards.get(src_path)
        if card is None:
            continue
        if dst_path not in card.imports and len(card.imports) < max_imports:
            card.imports.append(dst_path)
        dependent_card = cards.get(dst_path)
        if dependent_card is not None and src_path not in dependent_card.dependents and len(dependent_card.dependents) < max_imports:
            dependent_card.dependents.append(src_path)

    call_rows = connection.execute(
        """
        SELECT src_path, symbol_name
        FROM edges
        WHERE snapshot_id = ? AND edge_type = 'call'
        ORDER BY src_path ASC, symbol_name ASC
        """,
        (snapshot_id,),
    ).fetchall()
    for row in call_rows:
        src_path = str(row["src_path"])
        card = cards.get(src_path)
        if card is None:
            continue
        callee_name = str(row["symbol_name"])
        if callee_name not in card.calls and len(card.calls) < max_calls:
            card.calls.append(callee_name)

    return [cards[key] for key in sorted(cards)]


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


def render_repo_map(snapshot: sqlite3.Row, file_cards: Sequence[FileCard]) -> str:
    root = TreeNode(name=Path(str(snapshot["root_path"])).name or "repo", path="")
    for card in file_cards:
        insert_file_card(root, card)
    lines = [
        f"# Repo Map",
        f"snapshot_label: {snapshot['label']}",
        f"snapshot_id: {snapshot['id']}",
        f"root_path: {snapshot['root_path']}",
        f"parser_backend: {snapshot['parser_backend']}",
        f"created_at: {snapshot['created_at']}",
        "",
        f"{root.name}/",
    ]
    lines.extend(render_tree_children(root, prefix=""))
    lines.append("")
    lines.append(f"generated_at: {utc_now()}")
    return "\n".join(lines) + "\n"


def insert_file_card(root: TreeNode, card: FileCard) -> None:
    parts = card.path.split("/")
    current = root
    accumulated_parts: List[str] = []
    for index, part in enumerate(parts):
        accumulated_parts.append(part)
        child = current.children.get(part)
        if child is None:
            child = TreeNode(
                name=part,
                path="/".join(accumulated_parts),
                is_file=index == len(parts) - 1,
            )
            current.children[part] = child
        current = child
    current.file_card = card
    current.is_file = True


def render_tree_children(node: TreeNode, prefix: str) -> List[str]:
    lines: List[str] = []
    items = sorted(node.children.values(), key=lambda item: (item.is_file, item.name.lower()))
    for index, child in enumerate(items):
        is_last = index == len(items) - 1
        connector = "└── " if is_last else "├── "
        child_prefix = prefix + ("    " if is_last else "│   ")
        if child.is_file:
            label = render_file_label(child.file_card) if child.file_card is not None else child.name
            lines.append(prefix + connector + label)
            if child.file_card is not None:
                lines.extend(render_file_details(child.file_card, child_prefix))
        else:
            lines.append(prefix + connector + f"{child.name}/")
            lines.extend(render_tree_children(child, child_prefix))
    return lines


def render_file_label(card: Optional[FileCard]) -> str:
    if card is None:
        return "<unknown-file>"
    risk_text = ",".join(card.risk_tags[:4]) if card.risk_tags else "none"
    return f"{Path(card.path).name} [{card.role}] risks={risk_text}"


def render_file_details(card: FileCard, prefix: str) -> List[str]:
    rows: List[str] = []
    detail_items: List[Tuple[str, str]] = []
    detail_items.append(("summary", card.summary))
    detail_items.append(("symbols", ", ".join(card.symbols) if card.symbols else "-"))
    detail_items.append(("imports", ", ".join(card.imports) if card.imports else "-"))
    detail_items.append(("used_by", ", ".join(card.dependents) if card.dependents else "-"))
    detail_items.append(("calls", ", ".join(card.calls) if card.calls else "-"))
    if card.state_tags:
        detail_items.append(("state", ", ".join(card.state_tags)))
    if card.thread_tags:
        detail_items.append(("thread", ", ".join(card.thread_tags)))
    if card.interop_tags:
        detail_items.append(("interop", ", ".join(card.interop_tags)))
    for index, (label, value) in enumerate(detail_items):
        is_last = index == len(detail_items) - 1
        connector = "└── " if is_last else "├── "
        rows.append(prefix + connector + f"{label}: {value}")
    return rows


def utc_now() -> str:
    return dt.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="根据 SQLite 索引库生成 repo_map.txt")
    parser.add_argument("--db", default=str(DEFAULT_DB_PATH), help="repo_indexer 生成的 SQLite 路径")
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT_PATH), help="repo_map.txt 输出路径")
    parser.add_argument("--snapshot-label", help="指定快照标签；不传则使用最新快照")
    parser.add_argument("--max-symbols", type=int, default=8, help="每个文件最多展示多少个符号")
    parser.add_argument("--max-imports", type=int, default=8, help="每个文件最多展示多少个依赖或反向依赖")
    parser.add_argument("--max-calls", type=int, default=10, help="每个文件最多展示多少个调用热点")
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = parse_args(argv)
    generator = RepoMapGenerator(
        db_path=Path(args.db),
        output_path=Path(args.output),
        snapshot_label=args.snapshot_label,
        max_symbols=args.max_symbols,
        max_imports=args.max_imports,
        max_calls=args.max_calls,
    )
    return generator.run()


if __name__ == "__main__":
    raise SystemExit(main())
