#!/usr/bin/env python3
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import re
import shutil
import subprocess
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable, Optional

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SOURCE = PROJECT_ROOT / "research" / "external-baselines" / "CangjieTransSkills" / "option" / "README.md"
DEFAULT_SKILL = PROJECT_ROOT / ".claude" / "skills" / "base-kernel" / "option.md"
DEFAULT_ADMISSION_ROOT = PROJECT_ROOT / "artifacts" / "knowledge_admission"
DEFAULT_VERIFIER = PROJECT_ROOT / "scripts" / "verifier.py"

SHAPE_STANDALONE = "standalone"
SHAPE_WRAPPABLE = "wrappable"
SHAPE_CONTEXT_ONLY = "context-only"

VERDICT_VERIFIED = "ADMITTED_VERIFIED"
VERDICT_CONTEXT = "ADMITTED_CONTEXT_ONLY"
VERDICT_DEPRECATED = "QUARANTINED_DEPRECATED"
VERDICT_PATCHED = "ADMITTED_PATCHED"
VERDICT_RESTRICTED = "ADMITTED_L2_RESTRICTED"
VERDICT_HARMFUL = "REJECTED_HARMFUL"

LABEL_BY_VERDICT = {
    VERDICT_VERIFIED: "[L3-VERIFIED]",
    VERDICT_CONTEXT: "[L3-CONTEXT-ONLY]",
    VERDICT_DEPRECATED: "[L3-DEPRECATED]",
    VERDICT_PATCHED: "[L3-PATCHED]",
    VERDICT_RESTRICTED: "[L2-RESTRICTED]",
    VERDICT_HARMFUL: "[L3-BLOCKED-BY:harmful-pattern]",
}

DEFINITION_PATTERN = re.compile(r"(?m)^\s*(?:public\s+|protected\s+|private\s+)?(?:enum|func|class|struct|interface|macro|const)\b")
MAIN_PATTERN = re.compile(r"(?m)\bmain\s*\(")
HEADING_PATTERN = re.compile(r"^(#{1,6})\s+(.*\S)\s*$")
FENCE_START_PATTERN = re.compile(r"^```(?P<lang>[\w+-]*)\s*$")
HARMFUL_PATTERNS = (
    (re.compile(r"\bstd\.unsafe\b"), "std.unsafe"),
    (re.compile(r"\bimport\s+.+\s+from\b"), "import-from"),
    (re.compile(r"\bValueSignal\b"), "ValueSignal"),
    (re.compile(r"\bSignal\b"), "Signal"),
)


@dataclass
class Snippet:
    snippet_id: str
    topic: str
    source_line_start: int
    source_line_end: int
    fence_language: str
    raw_code: str
    heading_context: str
    preceding_text_excerpt: str
    shape: str = ""


@dataclass
class AdmissionEntry:
    snippet_id: str
    verdict: str
    label: str
    shape: str
    heading_context: str
    source_lines: str
    note: str
    evidence_path: str
    run_dir: str
    source_excerpt_path: str
    snippet_path: str
    candidate_path: Optional[str] = None
    verify_result_path: Optional[str] = None
    admission_result_path: Optional[str] = None


def utc_now() -> str:
    return dt.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def relpath(path: Path) -> str:
    return str(path.resolve().relative_to(PROJECT_ROOT))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="对单个外来 kernel Markdown 执行 admission")
    parser.add_argument("--source-markdown", default=str(DEFAULT_SOURCE), help="输入 Markdown 路径")
    parser.add_argument("--topic", default="option", help="当前 admission topic")
    parser.add_argument("--output-skill", default=str(DEFAULT_SKILL), help="接收版 skill 输出路径")
    parser.add_argument("--admission-root", default=str(DEFAULT_ADMISSION_ROOT), help="admission 输出根目录")
    parser.add_argument("--verifier-script", default=str(DEFAULT_VERIFIER), help="verifier.py 路径")
    parser.add_argument("--compiler-executable", required=True, help="真实 cjc 绝对路径")
    parser.add_argument("--compiler-home", required=True, help="SDK 根目录")
    parser.add_argument("--runtime-lib-path", required=True, help="运行时库目录")
    parser.add_argument("--tool-bin-path", required=True, help="工具 bin 目录")
    return parser.parse_args()


def extract_snippets(markdown_text: str, topic: str) -> list[Snippet]:
    lines = markdown_text.splitlines()
    snippets: list[Snippet] = []
    heading_stack: list[tuple[int, str]] = []
    capture_lang = ""
    capture_start = 0
    capture_lines: list[str] = []
    in_fence = False

    for index, line in enumerate(lines, start=1):
        if not in_fence:
            heading_match = HEADING_PATTERN.match(line)
            if heading_match:
                level = len(heading_match.group(1))
                title = heading_match.group(2).strip()
                while heading_stack and heading_stack[-1][0] >= level:
                    heading_stack.pop()
                heading_stack.append((level, title))

            fence_match = FENCE_START_PATTERN.match(line)
            if fence_match:
                in_fence = True
                capture_lang = fence_match.group("lang").strip()
                capture_start = index + 1
                capture_lines = []
            continue

        if line.strip() == "```":
            source_line_end = index - 1
            start_window = max(0, capture_start - 4)
            preceding_excerpt = "\n".join(part for part in lines[start_window:capture_start - 1] if part.strip())
            heading_context = " / ".join(title for _, title in heading_stack) or "(root)"
            raw_code = "\n".join(capture_lines).rstrip() + "\n"
            snippets.append(
                Snippet(
                    snippet_id=f"snippet-{len(snippets) + 1:03d}",
                    topic=topic,
                    source_line_start=capture_start,
                    source_line_end=source_line_end,
                    fence_language=capture_lang,
                    raw_code=raw_code,
                    heading_context=heading_context,
                    preceding_text_excerpt=preceding_excerpt,
                )
            )
            in_fence = False
            capture_lang = ""
            capture_start = 0
            capture_lines = []
            continue

        capture_lines.append(line)

    return snippets


def classify_snippet(snippet: Snippet) -> str:
    code = snippet.raw_code.strip()
    if not code:
        return SHAPE_CONTEXT_ONLY
    if MAIN_PATTERN.search(code):
        return SHAPE_STANDALONE
    if DEFINITION_PATTERN.search(code):
        return SHAPE_WRAPPABLE
    return SHAPE_CONTEXT_ONLY


def detect_harmful(snippet: Snippet) -> Optional[str]:
    for pattern, reason in HARMFUL_PATTERNS:
        if pattern.search(snippet.raw_code):
            return reason
    return None


def build_candidate(snippet: Snippet) -> Optional[str]:
    if snippet.shape == SHAPE_CONTEXT_ONLY:
        return None
    code = snippet.raw_code.rstrip() + "\n"
    if snippet.shape == SHAPE_STANDALONE:
        return code
    if snippet.shape == SHAPE_WRAPPABLE:
        return code + "\nmain() {}\n"
    return None


def ensure_clean_topic_root(runs_topic_root: Path) -> None:
    if runs_topic_root.exists():
        shutil.rmtree(runs_topic_root)
    runs_topic_root.mkdir(parents=True, exist_ok=True)


def write_json(path: Path, payload: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def write_source_excerpt(path: Path, snippet: Snippet) -> None:
    excerpt = [
        f"# {snippet.snippet_id}",
        "",
        f"- heading_context: `{snippet.heading_context}`",
        f"- source_lines: `{snippet.source_line_start}-{snippet.source_line_end}`",
        f"- shape: `{snippet.shape}`",
        "",
    ]
    if snippet.preceding_text_excerpt:
        excerpt.extend([
            "## preceding_text_excerpt",
            "",
            snippet.preceding_text_excerpt,
            "",
        ])
    excerpt.extend([
        "## source_code",
        "",
        "```cangjie",
        snippet.raw_code.rstrip(),
        "```",
        "",
    ])
    path.write_text("\n".join(excerpt), encoding="utf-8")


def build_tu(run_dir: Path, snippet: Snippet) -> dict:
    return {
        "tu_id": f"kernel-admission::{snippet.topic}::{snippet.snippet_id}",
        "target": {
            "path": "candidate.cj",
            "role": "kernel-admission",
        },
        "snapshot": {
            "root_path": str(run_dir),
        },
    }


def build_artifact(run_dir: Path, candidate_code: str) -> dict:
    candidate_path = run_dir / "candidate.cj"
    return {
        "generated_code": candidate_code,
        "metadata": {
            "workspace_dir": str(run_dir),
            "attempt_dir": str(run_dir),
            "candidate_file_path": str(candidate_path),
            "candidate_rel_path": "candidate.cj",
        },
    }


def run_verifier(args: argparse.Namespace, run_dir: Path) -> tuple[dict, subprocess.CompletedProcess[str]]:
    verify_result_path = run_dir / "verify_result.json"
    command = [
        "python",
        str(Path(args.verifier_script).resolve()),
        "--tu-json",
        str(run_dir / "tu.json"),
        "--artifact-json",
        str(run_dir / "artifact.json"),
        "--output",
        str(verify_result_path),
        "--no-dry-run",
        "--real-compile",
        "--compiler-executable",
        str(Path(args.compiler_executable).resolve()),
        "--compiler-home",
        str(Path(args.compiler_home).resolve()),
        "--runtime-lib-path",
        str(Path(args.runtime_lib_path).resolve()),
        "--tool-bin-path",
        str(Path(args.tool_bin_path).resolve()),
    ]
    completed = subprocess.run(command, cwd=str(PROJECT_ROOT), capture_output=True, text=True, check=False)
    if completed.returncode != 0:
        raise SystemExit(
            "verifier.py 调用失败：\n"
            f"command={' '.join(command)}\n"
            f"stdout={completed.stdout}\n"
            f"stderr={completed.stderr}"
        )
    payload = json.loads(verify_result_path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise SystemExit(f"verify_result.json 结构无效：{verify_result_path}")
    return payload, completed


def build_manifest_record(source_markdown: Path, topic: str) -> dict:
    text = read_text(source_markdown)
    return {
        "generated_at": utc_now(),
        "topic": topic,
        "source_markdown": relpath(source_markdown),
        "source_sha256": sha256_text(text),
        "line_count": len(text.splitlines()),
        "kind": "kernel-admission-source",
    }


def load_existing_manifest(path: Path) -> list[dict]:
    if not path.exists():
        return []
    items: list[dict] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        data = json.loads(line)
        if isinstance(data, dict):
            items.append(data)
    return items


def save_manifest(path: Path, record: dict) -> None:
    existing = [item for item in load_existing_manifest(path) if item.get("topic") != record.get("topic")]
    existing.append(record)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        for item in existing:
            handle.write(json.dumps(item, ensure_ascii=False) + "\n")


def determine_verdict(snippet: Snippet, verify_payload: Optional[dict], harmful_reason: Optional[str]) -> tuple[str, str, str]:
    if harmful_reason:
        note = f"命中高风险模式 `{harmful_reason}`，禁止直接接收入主知识层"
        return VERDICT_HARMFUL, LABEL_BY_VERDICT[VERDICT_HARMFUL], note
    if snippet.shape == SHAPE_CONTEXT_ONLY:
        note = "该片段是语法/表达式级演示，不构造最小单文件候选程序"
        return VERDICT_CONTEXT, LABEL_BY_VERDICT[VERDICT_CONTEXT], note
    if verify_payload is None:
        note = "缺少真实 verifier 结果，无法给出 compile 级结论"
        return VERDICT_DEPRECATED, LABEL_BY_VERDICT[VERDICT_DEPRECATED], note
    if bool(verify_payload.get("passed")):
        note = "已通过真实 compile 体检；unit-test / behavior 保持 dry-run"
        return VERDICT_VERIFIED, LABEL_BY_VERDICT[VERDICT_VERIFIED], note
    failure_type = str(verify_payload.get("failure_type", "compile-failed") or "compile-failed")
    note = f"真实 compile 未通过，当前轮次不自动 patch；failure_type={failure_type}"
    return VERDICT_DEPRECATED, LABEL_BY_VERDICT[VERDICT_DEPRECATED], note


def summarize_counts(entries: Iterable[AdmissionEntry]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for entry in entries:
        counts[entry.verdict] = counts.get(entry.verdict, 0) + 1
    return counts


def render_card(entry: AdmissionEntry, raw_code: str) -> str:
    lines = [
        f"### `{entry.snippet_id}` {entry.label}",
        f"- status: `{entry.verdict}`",
        f"- shape: `{entry.shape}`",
        f"- heading_context: `{entry.heading_context}`",
        f"- source_lines: `{entry.source_lines}`",
        f"- evidence: `{entry.evidence_path}`",
        f"- note: {entry.note}",
        "```cangjie",
        raw_code.rstrip(),
        "```",
        "",
    ]
    return "\n".join(lines)


def build_accepted_skill(source_markdown: Path, entries: list[AdmissionEntry], snippets_by_id: dict[str, Snippet], admission_root: Path) -> str:
    verified = [entry for entry in entries if entry.verdict == VERDICT_VERIFIED]
    context_only = [entry for entry in entries if entry.verdict == VERDICT_CONTEXT]
    deprecated = [entry for entry in entries if entry.verdict == VERDICT_DEPRECATED]
    harmful = [entry for entry in entries if entry.verdict == VERDICT_HARMFUL]
    counts = summarize_counts(entries)
    lines = [
        "# Option Admission Skill",
        "",
        "- intake_mode: `kernel-admission-mvp`",
        f"- source_markdown: `{relpath(source_markdown)}`",
        f"- intake_time: `{utc_now()}`",
        f"- source_manifest: `{relpath(admission_root / 'source-manifest.jsonl')}`",
        f"- admission_index: `{relpath(admission_root / 'admission-index.json')}`",
        f"- runs_root: `{relpath(admission_root / 'runs' / 'option')}`",
        f"- counts: `{json.dumps(counts, ensure_ascii=False, sort_keys=True)}`",
        "- routing_rule: `L3 真实证据 > L2 项目约束 > L1 一般知识`",
        "",
        "## Core Definitions",
        "",
        "- `Option<T>` 表示仓颉中的可选值容器。",
        "- `?T` 是 `Option<T>` 的简写。",
        "- `Some(v)` 表示有值，`None` 表示无值。",
        "- `??` 用于提供默认值；`match` / `if-let` / `while-let` 用于解构可选值。",
        "- 当 L1 文档与当前编译器行为冲突时，以本轮 admission 的 L3 证据为准。",
        "",
        "## Verified Snippets",
        "",
    ]
    if verified:
        for entry in verified:
            lines.append(render_card(entry, snippets_by_id[entry.snippet_id].raw_code))
    else:
        lines.extend(["- 当前没有 `[L3-VERIFIED]` 片段。", ""])

    lines.extend(["## Context-only Snippets", ""])
    if context_only:
        for entry in context_only:
            lines.append(render_card(entry, snippets_by_id[entry.snippet_id].raw_code))
    else:
        lines.extend(["- 当前没有 `[L3-CONTEXT-ONLY]` 片段。", ""])

    lines.extend(["## Deprecated / Quarantine", ""])
    if deprecated:
        for entry in deprecated:
            lines.append(render_card(entry, snippets_by_id[entry.snippet_id].raw_code))
    else:
        lines.extend(["- 当前没有 `[L3-DEPRECATED]` 片段。", ""])

    if harmful:
        lines.extend(["## Blocked / Harmful", ""])
        for entry in harmful:
            lines.append(render_card(entry, snippets_by_id[entry.snippet_id].raw_code))

    lines.extend([
        "## Admission Metadata",
        "",
        f"- `source-manifest.jsonl`: `{relpath(admission_root / 'source-manifest.jsonl')}`",
        f"- `admission-index.json`: `{relpath(admission_root / 'admission-index.json')}`",
        f"- `runs/option`: `{relpath(admission_root / 'runs' / 'option')}`",
        "",
    ])
    return "\n".join(lines)


def main() -> int:
    args = parse_args()
    source_markdown = Path(args.source_markdown).resolve()
    output_skill = Path(args.output_skill).resolve()
    admission_root = Path(args.admission_root).resolve()
    runs_topic_root = admission_root / "runs" / args.topic
    verifier_script = Path(args.verifier_script).resolve()

    if not source_markdown.exists():
        raise SystemExit(f"source markdown 不存在：{source_markdown}")
    if not verifier_script.exists():
        raise SystemExit(f"verifier.py 不存在：{verifier_script}")

    markdown_text = read_text(source_markdown)
    snippets = extract_snippets(markdown_text, args.topic)
    if not snippets:
        raise SystemExit(f"未从 Markdown 中抽取到 fenced code block：{source_markdown}")

    manifest_record = build_manifest_record(source_markdown, args.topic)
    save_manifest(admission_root / "source-manifest.jsonl", manifest_record)
    ensure_clean_topic_root(runs_topic_root)

    entries: list[AdmissionEntry] = []
    snippets_by_id: dict[str, Snippet] = {}

    for snippet in snippets:
        snippet.shape = classify_snippet(snippet)
        snippets_by_id[snippet.snippet_id] = snippet
        run_dir = runs_topic_root / snippet.snippet_id
        run_dir.mkdir(parents=True, exist_ok=True)
        source_excerpt_path = run_dir / "source_excerpt.md"
        snippet_path = run_dir / "snippet.json"
        admission_result_path = run_dir / "admission_result.json"
        write_source_excerpt(source_excerpt_path, snippet)
        write_json(snippet_path, asdict(snippet))

        harmful_reason = detect_harmful(snippet)
        verify_payload: Optional[dict] = None
        candidate_path: Optional[Path] = None
        verify_result_path: Optional[Path] = None

        candidate_code = build_candidate(snippet)
        if candidate_code is not None and not harmful_reason:
            candidate_path = run_dir / "candidate.cj"
            tu_path = run_dir / "tu.json"
            artifact_path = run_dir / "artifact.json"
            candidate_path.write_text(candidate_code, encoding="utf-8")
            write_json(tu_path, build_tu(run_dir, snippet))
            write_json(artifact_path, build_artifact(run_dir, candidate_code))
            verify_payload, _ = run_verifier(args, run_dir)
            verify_result_path = run_dir / "verify_result.json"

        verdict, label, note = determine_verdict(snippet, verify_payload, harmful_reason)
        entry = AdmissionEntry(
            snippet_id=snippet.snippet_id,
            verdict=verdict,
            label=label,
            shape=snippet.shape,
            heading_context=snippet.heading_context,
            source_lines=f"{snippet.source_line_start}-{snippet.source_line_end}",
            note=note,
            evidence_path=relpath(verify_result_path) if verify_result_path else relpath(admission_result_path),
            run_dir=relpath(run_dir),
            source_excerpt_path=relpath(source_excerpt_path),
            snippet_path=relpath(snippet_path),
            candidate_path=relpath(candidate_path) if candidate_path else None,
            verify_result_path=relpath(verify_result_path) if verify_result_path else None,
            admission_result_path=relpath(admission_result_path),
        )
        write_json(admission_result_path, asdict(entry))
        entries.append(entry)

    admission_index = {
        "generated_at": utc_now(),
        "topic": args.topic,
        "source_markdown": relpath(source_markdown),
        "source_manifest": relpath(admission_root / "source-manifest.jsonl"),
        "runs_root": relpath(runs_topic_root),
        "stats": {
            "snippet_count": len(entries),
            "verdict_counts": summarize_counts(entries),
            "shape_counts": {
                SHAPE_STANDALONE: sum(1 for item in entries if item.shape == SHAPE_STANDALONE),
                SHAPE_WRAPPABLE: sum(1 for item in entries if item.shape == SHAPE_WRAPPABLE),
                SHAPE_CONTEXT_ONLY: sum(1 for item in entries if item.shape == SHAPE_CONTEXT_ONLY),
            },
        },
        "entries": [asdict(entry) for entry in entries],
    }
    write_json(admission_root / "admission-index.json", admission_index)

    output_skill.parent.mkdir(parents=True, exist_ok=True)
    output_skill.write_text(build_accepted_skill(source_markdown, entries, snippets_by_id, admission_root), encoding="utf-8")

    print(
        json.dumps(
            {
                "topic": args.topic,
                "snippets": len(entries),
                "shape_counts": admission_index["stats"]["shape_counts"],
                "verdict_counts": admission_index["stats"]["verdict_counts"],
                "output_skill": relpath(output_skill),
                "admission_index": relpath(admission_root / "admission-index.json"),
            },
            ensure_ascii=False,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
