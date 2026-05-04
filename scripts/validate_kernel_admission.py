#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parent.parent
ALLOWED_VERDICTS = {
    "ADMITTED_VERIFIED",
    "ADMITTED_CONTEXT_ONLY",
    "QUARANTINED_DEPRECATED",
    "ADMITTED_L2_RESTRICTED",
    "REJECTED_HARMFUL",
    "ADMITTED_PATCHED",
}
REQUIRED_SKILL_LABELS = (
    "[L3-VERIFIED]",
    "[L3-CONTEXT-ONLY]",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="验证 kernel admission MVP 产物")
    parser.add_argument(
        "--admission-root",
        default="artifacts/knowledge_admission",
        help="admission 输出根目录，相对路径基于仓库根目录",
    )
    parser.add_argument(
        "--accepted-skill",
        default=".claude/skills/base-kernel/option.md",
        help="接收版 skill 文档路径，相对路径基于仓库根目录",
    )
    return parser.parse_args()


def iter_run_dirs(topic_root: Path) -> Iterable[Path]:
    if not topic_root.exists():
        return []
    return sorted(path for path in topic_root.iterdir() if path.is_dir())


def load_json(path: Path) -> dict:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"JSON 顶层必须是 object: {path}")
    return data


def main() -> int:
    args = parse_args()
    admission_root = (ROOT / args.admission_root).resolve()
    accepted_skill = (ROOT / args.accepted_skill).resolve()

    failures: list[str] = []
    source_manifest = admission_root / "source-manifest.jsonl"
    admission_index = admission_root / "admission-index.json"
    runs_option_root = admission_root / "runs" / "option"

    if not source_manifest.exists():
        failures.append(f"missing file: {source_manifest.relative_to(ROOT)}")
    else:
        first_line = next((line.strip() for line in source_manifest.read_text(encoding="utf-8").splitlines() if line.strip()), "")
        if not first_line:
            failures.append(f"empty manifest: {source_manifest.relative_to(ROOT)}")

    index_payload: dict | None = None
    entries: list[dict] = []
    if not admission_index.exists():
        failures.append(f"missing file: {admission_index.relative_to(ROOT)}")
    else:
        try:
            index_payload = load_json(admission_index)
            raw_entries = index_payload.get("entries")
            if not isinstance(raw_entries, list) or not raw_entries:
                failures.append(f"missing or empty entries in: {admission_index.relative_to(ROOT)}")
            else:
                entries = [entry for entry in raw_entries if isinstance(entry, dict)]
                if not entries:
                    failures.append(f"no valid object entries in: {admission_index.relative_to(ROOT)}")
                verdicts = {str(entry.get("verdict", "")) for entry in entries}
                if not verdicts & ALLOWED_VERDICTS:
                    failures.append(f"no allowed verdict found in: {admission_index.relative_to(ROOT)}")
                if "ADMITTED_VERIFIED" not in verdicts and "ADMITTED_CONTEXT_ONLY" not in verdicts:
                    failures.append(f"need at least one ADMITTED_VERIFIED or ADMITTED_CONTEXT_ONLY in: {admission_index.relative_to(ROOT)}")
        except Exception as exc:
            failures.append(f"invalid JSON in {admission_index.relative_to(ROOT)}: {exc}")

    run_dirs = list(iter_run_dirs(runs_option_root))
    if not run_dirs:
        failures.append(f"missing run sandboxes under: {runs_option_root.relative_to(ROOT)}")
    else:
        required_run_files = {"snippet.json", "admission_result.json"}
        has_verify_result = False
        for run_dir in run_dirs:
            missing = [name for name in sorted(required_run_files) if not (run_dir / name).exists()]
            if missing:
                failures.append(f"run sandbox incomplete: {run_dir.relative_to(ROOT)} missing {', '.join(missing)}")
            if (run_dir / "verify_result.json").exists():
                has_verify_result = True
        if not has_verify_result:
            failures.append(f"no verify_result.json found under: {runs_option_root.relative_to(ROOT)}")

    if not accepted_skill.exists():
        failures.append(f"missing file: {accepted_skill.relative_to(ROOT)}")
    else:
        text = accepted_skill.read_text(encoding="utf-8")
        if "# Option Admission Skill" not in text:
            failures.append(f"missing title in: {accepted_skill.relative_to(ROOT)}")
        if not any(label in text for label in REQUIRED_SKILL_LABELS):
            failures.append(f"missing L3 labels in: {accepted_skill.relative_to(ROOT)}")
        if "admission-index.json" not in text:
            failures.append(f"missing admission metadata link in: {accepted_skill.relative_to(ROOT)}")

    if failures:
        print("kernel-admission validation: FAIL")
        for item in failures:
            print(f"- {item}")
        return 1

    print("kernel-admission validation: PASS")
    print(f"- ok: {source_manifest.relative_to(ROOT)}")
    print(f"- ok: {admission_index.relative_to(ROOT)}")
    print(f"- ok: {accepted_skill.relative_to(ROOT)}")
    print(f"- run sandboxes: {len(run_dirs)}")
    if index_payload is not None:
        print(f"- indexed entries: {len(entries)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
