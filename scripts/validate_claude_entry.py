#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

REQUIRED_FILES = {
    ".claude/mission-control.md": [
        "# Mission Control",
        "Phase 03: Physical Iron Test",
        ".claude/status/current-phase.md",
        ".claude/runbooks/pipeline-runner.md",
        ".claude/skills/index.md",
        "L3 真实证据 > L2 项目约束 > L1 一般知识",
    ],
    ".claude/status/current-phase.md": [
        "phase:",
        "status:",
        "blocked_by:",
        "summary.json",
        "console.log",
    ],
    ".claude/runbooks/pipeline-runner.md": [
        "# Pipeline Runner Runbook",
        "scripts/pipeline_runner.py",
        "static-blacklist-failed",
        "Short-circuit",
        "L3 -> L2 -> Repair",
    ],
    ".claude/skills/index.md": [
        "# Skills Index",
        "Concept-first",
        "Failure-first",
        "L3 真实证据 > L2 项目约束 > L1 一般知识",
        "语言允许，不等于项目推荐；继续检查 L2 项目约束",
        "L3 -> L2 -> Repair",
        "[L3-DEPRECATED]",
    ],
    ".claude/skills/base-kernel/.placeholder": [
        "Phase 2",
        "cangjie-kernel",
        "verifier.py",
        "[L3-DEPRECATED]",
    ],
    "scripts/sync/README.md": [
        "# Sync and Admission Pipelines",
        "sync_docs.py",
        "index_to_skill.py",
        "Phase 3",
    ],
}


def validate_file(relative_path: str, required_fragments: list[str]) -> list[str]:
    problems: list[str] = []
    target = ROOT / relative_path
    if not target.exists():
        return [f"missing file: {relative_path}"]

    text = target.read_text(encoding="utf-8")
    for fragment in required_fragments:
        if fragment not in text:
            problems.append(f"missing fragment in {relative_path}: {fragment}")
    return problems


def main() -> int:
    failures: list[str] = []
    for relative_path, fragments in REQUIRED_FILES.items():
        failures.extend(validate_file(relative_path, fragments))

    if failures:
        print("claude-entry validation: FAIL")
        for item in failures:
            print(f"- {item}")
        return 1

    print("claude-entry validation: PASS")
    for relative_path in REQUIRED_FILES:
        print(f"- ok: {relative_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
