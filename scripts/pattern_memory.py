#!/usr/bin/env python3
"""Pattern Memory 引擎。

功能：
1. 将成功闭环的 TU 经验沉淀到 JSONL；
2. 基于 TU 的角色、签名、风险标签、依赖角色做相似检索；
3. 为 Prompt Assembler 提供 few-shot 模式样例。
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MEMORY_PATH = PROJECT_ROOT / "artifacts" / "pattern_memory" / "pattern_memory.jsonl"


@dataclass
class PatternEntry:
    pattern_id: str
    created_at: str
    tu_id: str
    target_path: str
    target_role: str
    risk_tags: List[str]
    target_signatures: List[Dict[str, object]]
    dependency_roles: List[str]
    dependency_signatures: List[Dict[str, object]]
    declared_constraints: List[str]
    generated_code_excerpt: str
    verification_status: str
    notes: List[str] = field(default_factory=list)


class PatternMemoryEngine:
    def __init__(self, memory_path: Path) -> None:
        self.memory_path = memory_path.resolve()
        self.memory_path.parent.mkdir(parents=True, exist_ok=True)
        if not self.memory_path.exists():
            self.memory_path.write_text("", encoding="utf-8")

    def record_success(
        self,
        *,
        tu: Dict[str, object],
        artifact: Dict[str, object],
        verify_result: Dict[str, object],
    ) -> Optional[PatternEntry]:
        if not bool(verify_result.get("passed", False)):
            return None
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        dependency_closure = tu.get("dependency_closure", []) if isinstance(tu.get("dependency_closure"), list) else []
        entry = PatternEntry(
            pattern_id=build_pattern_id(tu),
            created_at=utc_now(),
            tu_id=str(tu.get("tu_id", "")),
            target_path=str(target.get("path", "")),
            target_role=str(target.get("role", "")),
            risk_tags=[str(item) for item in target.get("risk_tags", [])] if isinstance(target.get("risk_tags", []), list) else [],
            target_signatures=normalize_signature_items(target.get("signatures", [])),
            dependency_roles=collect_dependency_roles(dependency_closure),
            dependency_signatures=collect_dependency_signatures(dependency_closure),
            declared_constraints=[str(item) for item in artifact.get("declared_constraints", [])] if isinstance(artifact.get("declared_constraints", []), list) else [],
            generated_code_excerpt=clip_text(str(artifact.get("generated_code", "")), 1200),
            verification_status=str(verify_result.get("status", "")),
            notes=[str(item) for item in artifact.get("notes", [])] if isinstance(artifact.get("notes", []), list) else [],
        )
        self.append_entry(entry)
        return entry

    def append_entry(self, entry: PatternEntry) -> None:
        if self.entry_exists(entry.pattern_id):
            return
        with self.memory_path.open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(as_pattern_dict(entry), ensure_ascii=False) + "\n")

    def entry_exists(self, pattern_id: str) -> bool:
        for item in self.load_entries():
            if str(item.get("pattern_id", "")) == pattern_id:
                return True
        return False

    def query_for_tu(self, tu: Dict[str, object], limit: int = 3) -> List[Dict[str, object]]:
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        target_role = str(target.get("role", ""))
        target_risk_tags = set(str(item) for item in target.get("risk_tags", [])) if isinstance(target.get("risk_tags", []), list) else set()
        target_signature_names = set(extract_signature_names(target.get("signatures", [])))
        target_dependency_roles = set(collect_dependency_roles(tu.get("dependency_closure", []) if isinstance(tu.get("dependency_closure", []), list) else []))
        scored: List[Tuple[float, Dict[str, object]]] = []
        for entry in self.load_entries():
            score = 0.0
            if entry.get("target_role") == target_role:
                score += 10.0
            entry_risk_tags = set(str(item) for item in entry.get("risk_tags", []))
            score += min(6.0, 2.0 * len(target_risk_tags & entry_risk_tags))
            entry_signature_names = set(extract_signature_names(entry.get("target_signatures", [])))
            score += min(12.0, 3.0 * len(target_signature_names & entry_signature_names))
            entry_dependency_roles = set(str(item) for item in entry.get("dependency_roles", []))
            score += min(6.0, 2.0 * len(target_dependency_roles & entry_dependency_roles))
            if score <= 0:
                continue
            scored.append((score, build_prompt_pattern(entry, score)))
        scored.sort(key=lambda item: (-item[0], item[1].get("pattern_id", "")))
        return [item[1] for item in scored[:limit]]

    def load_entries(self) -> List[Dict[str, object]]:
        entries: List[Dict[str, object]] = []
        with self.memory_path.open("r", encoding="utf-8") as handle:
            for line in handle:
                text = line.strip()
                if not text:
                    continue
                try:
                    payload = json.loads(text)
                except json.JSONDecodeError:
                    continue
                if isinstance(payload, dict):
                    entries.append(payload)
        return entries


def normalize_signature_items(value: object) -> List[Dict[str, object]]:
    if not isinstance(value, list):
        return []
    items: List[Dict[str, object]] = []
    for item in value:
        if not isinstance(item, dict):
            continue
        items.append(
            {
                "kind": str(item.get("kind", "")),
                "name": str(item.get("name", "")),
                "signature": str(item.get("signature", "")),
                "summary": str(item.get("summary", "")),
            }
        )
    return items


def collect_dependency_roles(dependency_closure: object) -> List[str]:
    if not isinstance(dependency_closure, list):
        return []
    roles: List[str] = []
    for item in dependency_closure:
        if not isinstance(item, dict):
            continue
        role = str(item.get("role", ""))
        if role:
            roles.append(role)
    return dedupe_preserve_order(roles)


def collect_dependency_signatures(dependency_closure: object) -> List[Dict[str, object]]:
    if not isinstance(dependency_closure, list):
        return []
    items: List[Dict[str, object]] = []
    for entry in dependency_closure:
        if not isinstance(entry, dict):
            continue
        path = str(entry.get("path", ""))
        signatures = normalize_signature_items(entry.get("signatures", []))
        for signature in signatures:
            signature_with_path = dict(signature)
            signature_with_path["path"] = path
            items.append(signature_with_path)
    return items[:24]


def extract_signature_names(signatures: object) -> List[str]:
    if not isinstance(signatures, list):
        return []
    names: List[str] = []
    for item in signatures:
        if not isinstance(item, dict):
            continue
        name = str(item.get("name", ""))
        if name:
            names.append(name)
    return names


def build_prompt_pattern(entry: Dict[str, object], score: float) -> Dict[str, object]:
    return {
        "pattern_id": entry.get("pattern_id", ""),
        "score": score,
        "target_role": entry.get("target_role", ""),
        "target_path": entry.get("target_path", ""),
        "target_signatures": entry.get("target_signatures", []),
        "dependency_roles": entry.get("dependency_roles", []),
        "declared_constraints": entry.get("declared_constraints", []),
        "generated_code_excerpt": entry.get("generated_code_excerpt", ""),
        "notes": entry.get("notes", []),
    }


def clip_text(text: str, limit: int) -> str:
    compact = text.strip()
    if len(compact) <= limit:
        return compact
    return compact[: limit - 3] + "..."


def build_pattern_id(tu: Dict[str, object]) -> str:
    target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
    path = str(target.get("path", "unknown"))
    role = str(target.get("role", ""))
    signature_names = ",".join(sorted(extract_signature_names(target.get("signatures", []))))
    raw = f"{path}|{role}|{signature_names}"
    digest = hashlib.sha1(raw.encode("utf-8")).hexdigest()[:12]
    return f"pattern::{path.replace('/', '::')}::{digest}"


def as_pattern_dict(entry: PatternEntry) -> Dict[str, object]:
    return {
        "pattern_id": entry.pattern_id,
        "created_at": entry.created_at,
        "tu_id": entry.tu_id,
        "target_path": entry.target_path,
        "target_role": entry.target_role,
        "risk_tags": entry.risk_tags,
        "target_signatures": entry.target_signatures,
        "dependency_roles": entry.dependency_roles,
        "dependency_signatures": entry.dependency_signatures,
        "declared_constraints": entry.declared_constraints,
        "generated_code_excerpt": entry.generated_code_excerpt,
        "verification_status": entry.verification_status,
        "notes": entry.notes,
    }


def utc_now() -> str:
    return dt.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def dedupe_preserve_order(items: Sequence[str]) -> List[str]:
    seen = set()
    result: List[str] = []
    for item in items:
        if item in seen:
            continue
        seen.add(item)
        result.append(item)
    return result


def load_json_file(path: Path) -> Dict[str, object]:
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise SystemExit(f"无效 JSON 结构：{path}")
    return data


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Pattern Memory 引擎")
    parser.add_argument("--memory-path", default=str(DEFAULT_MEMORY_PATH), help="pattern_memory.jsonl 路径")
    parser.add_argument("--tu-json", required=True, help="TU JSON 路径")
    parser.add_argument("--artifact-json", help="成功产物 JSON；配合 --record-success 使用")
    parser.add_argument("--verify-json", help="验证结果 JSON；配合 --record-success 使用")
    parser.add_argument("--record-success", action="store_true", help="记录一条成功模式")
    parser.add_argument("--query", action="store_true", help="按 TU 查询相似模式")
    parser.add_argument("--limit", type=int, default=3, help="查询结果条数")
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = parse_args(argv)
    engine = PatternMemoryEngine(Path(args.memory_path))
    tu = load_json_file(Path(args.tu_json))
    if args.record_success:
        if not args.artifact_json or not args.verify_json:
            raise SystemExit("record-success 需要同时提供 --artifact-json 和 --verify-json")
        artifact = load_json_file(Path(args.artifact_json))
        verify_result = load_json_file(Path(args.verify_json))
        entry = engine.record_success(tu=tu, artifact=artifact, verify_result=verify_result)
        print(json.dumps({"recorded": entry is not None, "pattern_id": entry.pattern_id if entry else ""}, ensure_ascii=False))
        return 0
    if args.query:
        result = engine.query_for_tu(tu, limit=args.limit)
        print(json.dumps({"count": len(result), "items": result}, ensure_ascii=False, indent=2))
        return 0
    raise SystemExit("请至少选择 --record-success 或 --query")


if __name__ == "__main__":
    raise SystemExit(main())
