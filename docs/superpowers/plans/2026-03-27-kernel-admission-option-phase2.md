# Kernel Admission Option Phase 2.1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 `Option` 外来 kernel 文档建立第一条可复用的知识准入通道：抽取 fenced code block、构造最小 verifier 工件、运行真实 compile 体检、生成 admission index，并产出接收版 `/.claude/skills/base-kernel/option.md`。

**Architecture:** 采用“半自动 admission MVP”方案：先把 private 基线中的 `Option` 文档稳定镜像到仓库内，再通过 `scripts/sync/kernel_admission.py` 执行单文档 admission 流程。该流程只支持 `standalone` / `wrappable` / `context-only` 三分类，并通过现有 `scripts/verifier.py` 获取真实 compile 证据；最后由接收版生成器把 verdict 翻译成 Agent 可消费的 L1 文档与结构化 artifact。

**Tech Stack:** Markdown、Python 3 标准库、现有 `scripts/verifier.py`、现有仓颉工具链、`rg`

---

**执行前提与限制**

- 当前工作区不是 Git 仓库；
- `AGENTS.md` 明确要求未经用户授权不要执行 `git commit`；
- 当前仓库没有现成测试框架；
- 因此本计划使用：
  - `scripts/validate_kernel_admission.py` 作为最小验证脚本；
  - `python scripts/sync/kernel_admission.py ...` 作为真实 admission 运行命令；
  - `python scripts/validate_kernel_admission.py ...` + `rg` smoke check 作为完成证据。

## File Structure

### Create

- `research/external-baselines/CangjieTransSkills/README.md`
  - 记录本次引入的 private 基线路径、zip 摘要 hash、拉取日期、用途、限制。
- `research/external-baselines/CangjieTransSkills/option/README.md`
  - 稳定镜像 `Option` 源 Markdown，避免后续 admission 依赖 `/tmp` 或手工解压目录。
- `scripts/validate_kernel_admission.py`
  - 检查 admission 输出是否存在、是否包含至少一个 run sandbox、是否生成 `option.md`、是否存在 `ADMITTED_VERIFIED` 或 `ADMITTED_CONTEXT_ONLY`。
- `scripts/sync/kernel_admission.py`
  - 单文档 admission runner。
- `/.claude/skills/base-kernel/option.md`
  - `Option` 的接收版文档。
- `artifacts/knowledge_admission/source-manifest.jsonl`
  - 来源清单。
- `artifacts/knowledge_admission/admission-index.json`
  - 结构化 verdict 索引。

### Modify

- `scripts/sync/README.md`
  - 从纯 placeholder 升级为包含 `kernel_admission.py` 的说明与执行示例。
- `/.claude/skills/base-kernel/.placeholder`
  - 从“待未来接入”改为“Option 已作为首个样本接入，后续 kernel 继续分批引入”。

### Runtime Outputs (not committed as hand-written sources)

- `artifacts/knowledge_admission/runs/option/<snippet-id>/source_excerpt.md`
- `artifacts/knowledge_admission/runs/option/<snippet-id>/snippet.json`
- `artifacts/knowledge_admission/runs/option/<snippet-id>/candidate.cj`
- `artifacts/knowledge_admission/runs/option/<snippet-id>/tu.json`
- `artifacts/knowledge_admission/runs/option/<snippet-id>/artifact.json`
- `artifacts/knowledge_admission/runs/option/<snippet-id>/verify_result.json`
- `artifacts/knowledge_admission/runs/option/<snippet-id>/admission_result.json`

### Validate

- `python scripts/validate_kernel_admission.py --admission-root artifacts/knowledge_admission --accepted-skill .claude/skills/base-kernel/option.md`
- `python scripts/sync/kernel_admission.py --source-markdown research/external-baselines/CangjieTransSkills/option/README.md --topic option --output-skill .claude/skills/base-kernel/option.md --admission-root artifacts/knowledge_admission --compiler-executable artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin/cjc --compiler-home artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie --runtime-lib-path artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/runtime/lib/linux_x86_64_cjnative --tool-bin-path artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin`
- `rg -n "L3-VERIFIED|L3-CONTEXT-ONLY|L3-DEPRECATED|ADMITTED_VERIFIED|ADMITTED_CONTEXT_ONLY|QUARANTINED_DEPRECATED" .claude/skills/base-kernel/option.md artifacts/knowledge_admission/admission-index.json`

---

### Task 1: Add a stable source mirror and a failing validation script

**Files:**
- Create: `research/external-baselines/CangjieTransSkills/README.md`
- Create: `research/external-baselines/CangjieTransSkills/option/README.md`
- Create: `scripts/validate_kernel_admission.py`
- Test: `python scripts/validate_kernel_admission.py --admission-root artifacts/knowledge_admission --accepted-skill .claude/skills/base-kernel/option.md`

- [ ] **Step 1: Create the stable source metadata file**

```md
# CangjieTransSkills External Baseline

- source_type: `private zip mirror`
- local_zip_path: `/volume/wzhang/cky-workspace/my_projects/Cangjie/资源/CangjieTransSkills-main.zip`
- archive_digest_hint: `d8d0824a68280e56617a879aa8c4443e41710e72`
- imported_at: `2026-03-27`
- usage: `作为 Phase 2 kernel admission 的外来知识源，仅选择 Option 首块作为最小切片`
- limitation: `当前只镜像本次 admission 所需的 Option 文档，不批量吸收全部 kernel 文档`
```

- [ ] **Step 2: Copy the private baseline `Option` source into a stable repo-local path**

Run:
```bash
mkdir -p research/external-baselines/CangjieTransSkills/option
unzip -p /volume/wzhang/cky-workspace/my_projects/Cangjie/资源/CangjieTransSkills-main.zip \
  CangjieTransSkills-main/.claude/skills/cangjie-kernel/option/README.md \
  > research/external-baselines/CangjieTransSkills/option/README.md
```

Expected:
```text
# no output
```

- [ ] **Step 3: Write the failing validation script before admission code exists**

```python
#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="验证 kernel admission 输出是否完整")
    parser.add_argument("--admission-root", required=True)
    parser.add_argument("--accepted-skill", required=True)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    admission_root = Path(args.admission_root)
    accepted_skill = Path(args.accepted_skill)
    problems: list[str] = []

    source_manifest = admission_root / "source-manifest.jsonl"
    admission_index = admission_root / "admission-index.json"
    runs_root = admission_root / "runs" / "option"

    if not source_manifest.exists():
        problems.append(f"missing file: {source_manifest}")
    if not admission_index.exists():
        problems.append(f"missing file: {admission_index}")
    if not accepted_skill.exists():
        problems.append(f"missing file: {accepted_skill}")

    if admission_index.exists():
        data = json.loads(admission_index.read_text(encoding="utf-8"))
        snippets = data.get("snippets") if isinstance(data, dict) else None
        if not isinstance(snippets, list) or not snippets:
            problems.append("admission-index has no snippets")
        else:
            verdicts = {str(item.get("verdict", "")) for item in snippets if isinstance(item, dict)}
            if "ADMITTED_VERIFIED" not in verdicts and "ADMITTED_CONTEXT_ONLY" not in verdicts:
                problems.append("admission-index missing both ADMITTED_VERIFIED and ADMITTED_CONTEXT_ONLY")

    if runs_root.exists():
        run_dirs = [p for p in runs_root.iterdir() if p.is_dir()]
        if not run_dirs:
            problems.append(f"no run directories under: {runs_root}")
        else:
            first = run_dirs[0]
            for required in ["snippet.json", "admission_result.json"]:
                if not (first / required).exists():
                    problems.append(f"missing file in first run dir: {(first / required)}")
    else:
        problems.append(f"missing directory: {runs_root}")

    if accepted_skill.exists():
        text = accepted_skill.read_text(encoding="utf-8")
        if "[L3-VERIFIED]" not in text and "[L3-CONTEXT-ONLY]" not in text and "[L3-DEPRECATED]" not in text:
            problems.append("accepted skill missing all expected L3 labels")

    if problems:
        print("kernel-admission validation: FAIL")
        for item in problems:
            print(f"- {item}")
        return 1

    print("kernel-admission validation: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

- [ ] **Step 4: Run the validator and confirm it fails before admission implementation exists**

Run:
```bash
python scripts/validate_kernel_admission.py \
  --admission-root artifacts/knowledge_admission \
  --accepted-skill .claude/skills/base-kernel/option.md
```

Expected:
```text
kernel-admission validation: FAIL
- missing file: artifacts/knowledge_admission/source-manifest.jsonl
- missing file: artifacts/knowledge_admission/admission-index.json
- missing file: .claude/skills/base-kernel/option.md
- missing directory: artifacts/knowledge_admission/runs/option
```

---

### Task 2: Implement extraction, shape classification, and source manifest generation

**Files:**
- Create: `scripts/sync/kernel_admission.py`
- Test: `python scripts/sync/kernel_admission.py --help`
- Test: `python scripts/sync/kernel_admission.py ...`

- [ ] **Step 1: Write the CLI skeleton and source manifest path helpers**

```python
#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable

FENCE_RE = re.compile(r"^```(?P<lang>[A-Za-z0-9_-]*)\s*$")


@dataclass
class SnippetRecord:
    snippet_id: str
    topic: str
    source_path: str
    source_line_start: int
    source_line_end: int
    heading_context: str
    preceding_text_excerpt: str
    raw_code: str
    shape: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="单文档 kernel admission runner")
    parser.add_argument("--source-markdown", required=True)
    parser.add_argument("--topic", required=True)
    parser.add_argument("--output-skill", required=True)
    parser.add_argument("--admission-root", required=True)
    parser.add_argument("--compiler-executable", required=True)
    parser.add_argument("--compiler-home", required=True)
    parser.add_argument("--runtime-lib-path", required=True)
    parser.add_argument("--tool-bin-path", required=True)
    return parser.parse_args()
```

- [ ] **Step 2: Add fenced block extraction and minimal three-shape classification**

```python
def classify_shape(code: str) -> str:
    stripped = code.strip()
    lines = [line for line in stripped.splitlines() if line.strip()]
    if "main()" in stripped or "main (" in stripped:
        return "standalone"
    if len(lines) <= 3:
        return "context-only"
    if "func " in stripped or "enum " in stripped:
        return "wrappable"
    return "context-only"


def extract_snippets(markdown: str, source_path: str, topic: str) -> list[SnippetRecord]:
    lines = markdown.splitlines()
    snippets: list[SnippetRecord] = []
    heading_context = ""
    preceding_buffer: list[str] = []
    in_fence = False
    fence_lang = ""
    fence_start = 0
    buffer: list[str] = []

    for line_no, line in enumerate(lines, start=1):
        if line.startswith("#"):
            heading_context = line.strip()
        match = FENCE_RE.match(line)
        if match and not in_fence:
            in_fence = True
            fence_lang = (match.group("lang") or "").strip().lower()
            fence_start = line_no + 1
            buffer = []
            continue
        if match and in_fence:
            code = "\n".join(buffer).strip()
            if code and fence_lang in {"", "cangjie"}:
                snippet_id = f"snippet-{len(snippets) + 1:03d}"
                snippets.append(
                    SnippetRecord(
                        snippet_id=snippet_id,
                        topic=topic,
                        source_path=source_path,
                        source_line_start=fence_start,
                        source_line_end=line_no - 1,
                        heading_context=heading_context,
                        preceding_text_excerpt="\n".join(preceding_buffer[-4:]).strip(),
                        raw_code=code,
                        shape=classify_shape(code),
                    )
                )
            in_fence = False
            fence_lang = ""
            buffer = []
            continue
        if in_fence:
            buffer.append(line)
        else:
            preceding_buffer.append(line)
    return snippets
```

- [ ] **Step 3: Write source manifest and snippet JSON outputs without verifier integration yet**

```python
def write_source_manifest(admission_root: Path, source_markdown: Path, topic: str) -> None:
    manifest_path = admission_root / "source-manifest.jsonl"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "topic": topic,
        "source_path": str(source_markdown),
        "source_name": source_markdown.name,
    }
    manifest_path.write_text(json.dumps(payload, ensure_ascii=False) + "\n", encoding="utf-8")


def write_extracted_snippets(admission_root: Path, topic: str, snippets: Iterable[SnippetRecord]) -> None:
    extracted_root = admission_root / "extracted" / topic
    extracted_root.mkdir(parents=True, exist_ok=True)
    for snippet in snippets:
        target = extracted_root / f"{snippet.snippet_id}.json"
        target.write_text(json.dumps(asdict(snippet), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
```

- [ ] **Step 4: Run the script once and confirm extracted snippet JSON files appear**

Run:
```bash
python scripts/sync/kernel_admission.py \
  --source-markdown research/external-baselines/CangjieTransSkills/option/README.md \
  --topic option \
  --output-skill .claude/skills/base-kernel/option.md \
  --admission-root artifacts/knowledge_admission \
  --compiler-executable artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin/cjc \
  --compiler-home artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie \
  --runtime-lib-path artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/runtime/lib/linux_x86_64_cjnative \
  --tool-bin-path artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin
```

Expected:
```text
# 第一次可以只打印 extracted_snippet_count 等摘要 JSON
```

Run:
```bash
find artifacts/knowledge_admission/extracted/option -type f | sort
```

Expected:
```text
...至少出现 snippet-001.json 等抽取结果...
```

---

### Task 3: Add run sandbox generation and verifier integration

**Files:**
- Modify: `scripts/sync/kernel_admission.py`
- Test: `python scripts/sync/kernel_admission.py ...`

- [ ] **Step 1: Add minimal sandbox generation for `standalone` and `wrappable` snippets**

```python
def build_candidate_code(snippet: SnippetRecord) -> str:
    if snippet.shape == "standalone":
        return snippet.raw_code.strip() + "\n"
    if snippet.shape == "wrappable":
        return snippet.raw_code.strip() + "\n\nmain() {\n    // admission entrypoint\n}\n"
    raise ValueError(f"snippet {snippet.snippet_id} is not compilable: {snippet.shape}")


def write_run_inputs(run_dir: Path, snippet: SnippetRecord, candidate_code: str) -> tuple[Path, Path, Path]:
    run_dir.mkdir(parents=True, exist_ok=True)
    candidate_path = run_dir / "candidate.cj"
    tu_path = run_dir / "tu.json"
    artifact_path = run_dir / "artifact.json"

    candidate_path.write_text(candidate_code, encoding="utf-8")
    (run_dir / "snippet.json").write_text(json.dumps(asdict(snippet), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (run_dir / "source_excerpt.md").write_text(snippet.raw_code + "\n", encoding="utf-8")
    tu_payload = {
        "tu_id": f"kernel-admission::{snippet.topic}::{snippet.snippet_id}",
        "target": {"path": "candidate.cj", "role": "kernel-admission"},
        "snapshot": {"root_path": str(run_dir)},
    }
    artifact_payload = {
        "generated_code": candidate_code,
        "metadata": {
            "workspace_dir": str(run_dir),
            "attempt_dir": str(run_dir),
            "candidate_file_path": str(candidate_path),
            "candidate_rel_path": "candidate.cj",
        },
    }
    tu_path.write_text(json.dumps(tu_payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    artifact_path.write_text(json.dumps(artifact_payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return candidate_path, tu_path, artifact_path
```

- [ ] **Step 2: Call `scripts/verifier.py` for compilable snippets only**

```python
import subprocess


def run_verifier(run_dir: Path, tu_path: Path, artifact_path: Path, args: argparse.Namespace) -> Path:
    verify_output = run_dir / "verify_result.json"
    command = [
        "python",
        "scripts/verifier.py",
        "--tu-json", str(tu_path),
        "--artifact-json", str(artifact_path),
        "--output", str(verify_output),
        "--no-dry-run",
        "--real-compile",
        "--compiler-executable", args.compiler_executable,
        "--compiler-home", args.compiler_home,
        "--runtime-lib-path", args.runtime_lib_path,
        "--tool-bin-path", args.tool_bin_path,
    ]
    subprocess.run(command, check=True)
    return verify_output
```

- [ ] **Step 3: Map verifier output to first-round verdicts**

```python
def resolve_verdict(snippet: SnippetRecord, verify_result_path: Path | None) -> tuple[str, list[str]]:
    if snippet.shape == "context-only":
        return "ADMITTED_CONTEXT_ONLY", ["L3-CONTEXT-ONLY"]
    if verify_result_path is None:
        return "REJECTED_HARMFUL", ["REJECTED-HARMFUL"]
    data = json.loads(verify_result_path.read_text(encoding="utf-8"))
    if bool(data.get("passed")):
        return "ADMITTED_VERIFIED", ["L3-VERIFIED"]
    return "QUARANTINED_DEPRECATED", ["L3-DEPRECATED"]
```

- [ ] **Step 4: Re-run admission and confirm run sandboxes and verify results exist**

Run:
```bash
python scripts/sync/kernel_admission.py \
  --source-markdown research/external-baselines/CangjieTransSkills/option/README.md \
  --topic option \
  --output-skill .claude/skills/base-kernel/option.md \
  --admission-root artifacts/knowledge_admission \
  --compiler-executable artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin/cjc \
  --compiler-home artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie \
  --runtime-lib-path artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/runtime/lib/linux_x86_64_cjnative \
  --tool-bin-path artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin
```

Run:
```bash
find artifacts/knowledge_admission/runs/option -maxdepth 2 -type f | sort
```

Expected:
```text
...出现 snippet.json / candidate.cj / tu.json / artifact.json / verify_result.json / admission_result.json ...
```

---

### Task 4: Generate admission index and accepted `option.md`

**Files:**
- Modify: `scripts/sync/kernel_admission.py`
- Create: `/.claude/skills/base-kernel/option.md`
- Test: `python scripts/validate_kernel_admission.py ...`

- [ ] **Step 1: Write `admission-index.json` from all snippet records**

```python
def write_admission_index(admission_root: Path, topic: str, records: list[dict]) -> Path:
    target = admission_root / "admission-index.json"
    payload = {"topic": topic, "snippets": records}
    target.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return target
```

- [ ] **Step 2: Generate the accepted `option.md` with verdict sections**

```python
def render_option_skill(source_path: str, records: list[dict], admission_root: Path) -> str:
    verified = [item for item in records if item["verdict"] == "ADMITTED_VERIFIED"]
    context_only = [item for item in records if item["verdict"] == "ADMITTED_CONTEXT_ONLY"]
    deprecated = [item for item in records if item["verdict"] == "QUARANTINED_DEPRECATED"]

    lines = [
        "# Option（Admitted Kernel Skill）",
        "",
        f"- source: `{source_path}`",
        f"- admission_root: `{admission_root}`",
        f"- verified_count: `{len(verified)}`",
        f"- context_only_count: `{len(context_only)}`",
        f"- deprecated_count: `{len(deprecated)}`",
        "",
        "## 核心定义",
        "",
        "- `Option<T>`：表示有值或无值的泛型枚举。",
        "- `?T`：`Option<T>` 的简写语法。",
        "- `Some / None`：表示存在值或空值。",
        "- `??`：提供 coalescing 语义。",
        "",
        "## Verified Snippets",
    ]
    for item in verified:
        lines.extend([
            "",
            f"### {item['snippet_id']}",
            "",
            f"- status: `[L3-VERIFIED]`",
            f"- shape: `{item['shape']}`",
            f"- source_lines: `{item['source_lines']}`",
            f"- evidence: `{item['verify_result_path']}`",
            "",
            "```cangjie",
            item["final_code"].rstrip(),
            "```",
        ])
    lines.append("")
    lines.append("## Context-only Snippets")
    for item in context_only:
        lines.extend([
            "",
            f"### {item['snippet_id']}",
            "",
            f"- status: `[L3-CONTEXT-ONLY]`",
            f"- shape: `{item['shape']}`",
            f"- source_lines: `{item['source_lines']}`",
            "",
            "```cangjie",
            item["raw_code"].rstrip(),
            "```",
        ])
    lines.append("")
    lines.append("## Deprecated / Quarantine")
    for item in deprecated:
        lines.extend([
            "",
            f"### {item['snippet_id']}",
            "",
            f"- status: `[L3-DEPRECATED]`",
            f"- source_lines: `{item['source_lines']}`",
            f"- evidence: `{item['verify_result_path']}`",
            f"- reason: `当前工具链下 compile 未通过，保留为隔离知识`",
            "",
            "```cangjie",
            item["raw_code"].rstrip(),
            "```",
        ])
    return "\n".join(lines) + "\n"
```

- [ ] **Step 3: Run the validator and confirm the full Phase 2.1 slice passes**

Run:
```bash
python scripts/validate_kernel_admission.py \
  --admission-root artifacts/knowledge_admission \
  --accepted-skill .claude/skills/base-kernel/option.md
```

Expected:
```text
kernel-admission validation: PASS
```

- [ ] **Step 4: Run a targeted smoke grep for verdicts and labels**

Run:
```bash
rg -n "L3-VERIFIED|L3-CONTEXT-ONLY|L3-DEPRECATED|ADMITTED_VERIFIED|ADMITTED_CONTEXT_ONLY|QUARANTINED_DEPRECATED" \
  .claude/skills/base-kernel/option.md \
  artifacts/knowledge_admission/admission-index.json
```

Expected:
```text
...命中 option.md 和 admission-index.json 中的 verdict 与标签...
```

---

### Task 5: Update placeholders and sync docs to reflect the first admitted kernel unit

**Files:**
- Modify: `scripts/sync/README.md`
- Modify: `/.claude/skills/base-kernel/.placeholder`
- Test: `python scripts/validate_kernel_admission.py ...`

- [ ] **Step 1: Replace the placeholder wording in `/.claude/skills/base-kernel/.placeholder`**

```md
# Phase 2 Admission Status

当前状态：
- `Option` 已作为首个 kernel admission 样本接入
- 接收版文档位置：`/.claude/skills/base-kernel/option.md`
- 结构化准入索引：`artifacts/knowledge_admission/admission-index.json`

后续计划：
- 继续把 `Atomic`、`ArrayList`、`cjpm` 等单元分批接入
- 在后续阶段逐步引入 `[L3-PATCHED]` 与 `[L2-RESTRICTED]` 的真实落地
```

- [ ] **Step 2: Upgrade `scripts/sync/README.md` from placeholder to active Phase 2.1 docs**

```md
# Sync Pipeline

## 当前已落地

- `kernel_admission.py`
  - 单文档 kernel admission runner
  - 当前支持 `Option` 首块 admission MVP

## 当前输入

- `research/external-baselines/CangjieTransSkills/option/README.md`

## 当前输出

- `artifacts/knowledge_admission/source-manifest.jsonl`
- `artifacts/knowledge_admission/admission-index.json`
- `artifacts/knowledge_admission/runs/option/`
- `/.claude/skills/base-kernel/option.md`

## 后续接口

- `sync_docs.py`
  - 用于官方文档镜像同步
- `index_to_skill.py`
  - 用于切片并接入 Skill 体系
```

- [ ] **Step 3: Re-run the validator and one final smoke check**

Run:
```bash
python scripts/validate_kernel_admission.py \
  --admission-root artifacts/knowledge_admission \
  --accepted-skill .claude/skills/base-kernel/option.md
rg -n "Option 已作为首个 kernel admission 样本接入|kernel_admission.py|option.md|admission-index.json" \
  .claude/skills/base-kernel/.placeholder \
  scripts/sync/README.md
```

Expected:
```text
kernel-admission validation: PASS
...命中 placeholder 和 README 中的 Phase 2.1 更新内容...
```

---

## Self-Review

### 1. Spec coverage

- `Option` 首块最小切片：Task 1~4 覆盖
- fenced block 抽取：Task 2 覆盖
- `standalone` / `wrappable` / `context-only`：Task 2 覆盖
- verifier 复用：Task 3 覆盖
- verdict 与标签：Task 3、Task 4 覆盖
- 接收版 `option.md`：Task 4 覆盖
- Phase 2 状态回写：Task 5 覆盖

无缺口；自动 patch、多文档 batch、HTML 输入等明确留到后续阶段。

### 2. Placeholder scan

本计划正文不保留任何无执行意义的占位句；所有步骤都给出了明确文件、命令、预期输出或代码骨架。

### 3. Type / naming consistency

关键命名保持一致：

- `kernel_admission.py`
- `source-manifest.jsonl`
- `admission-index.json`
- `option.md`
- `ADMITTED_VERIFIED`
- `ADMITTED_CONTEXT_ONLY`
- `QUARANTINED_DEPRECATED`
- `[L3-VERIFIED]`
- `[L3-CONTEXT-ONLY]`
- `[L3-DEPRECATED]`

以上命名与 Phase 2.1 设计稿保持一致。
