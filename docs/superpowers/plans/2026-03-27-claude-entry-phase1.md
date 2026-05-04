# Claude Entry Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为当前仓库新增 `.claude` 入口层神经中枢，让 Agent 能在第一分钟内理解当前阶段、命令入口、L1/L2/L3 知识路由与失败短路规则，并为 Phase 2 `base-kernel` 吸收与 Phase 3 文档同步流水线预留接口。

**Architecture:** 采用“轻入口 + 强路由”方案：`mission-control.md` 维护稳态规则，`current-phase.md` 维护动态战况，`pipeline-runner.md` 提供操作手册与短路规则，`skills/index.md` 提供三层知识总路由；同时增加一个最小 Python 校验脚本，确保 `.claude` 入口层的必需文件、关键标题和关键路由语句不会漂移。

**Tech Stack:** Markdown、Python 3 标准库、现有 `scripts/` 工具链、`rg` 命令行校验

---

**执行前提与限制**

- 当前工作区不是 Git 仓库；
- `AGENTS.md` 明确要求未经用户授权不要主动执行 `git commit` 等高风险 Git 操作；
- 因此本计划**不包含 commit 步骤**，改以“文件落盘 + 脚本校验 + `rg`/`python` smoke check”作为完成标准。
- 仓库当前没有测试框架；不要为了这次任务引入新的测试框架。使用 `scripts/validate_claude_entry.py` 作为最小验证入口。

## File Structure

### Create

- `scripts/validate_claude_entry.py`
  - 校验 `.claude` 入口层文件是否存在、关键标题是否齐全、关键路由语句是否出现、Phase 2/3 预置位是否就位。
- `.claude/mission-control.md`
  - Agent 首跳总控台，维护稳态规则与统一入口。
- `.claude/status/current-phase.md`
  - 动态战况板，挂接当前阶段、最近有效实验、`blocked_by` 与下一步动作。
- `.claude/runbooks/pipeline-runner.md`
  - 命令入口总表，包含 mock / dry-run / real compile 模板与 `static-blacklist-failed` 短路规则。
- `.claude/skills/index.md`
  - L1/L2/L3 路由总线，包含 Concept-first / Failure-first、桥接句式、Stop Conditions。
- `.claude/skills/base-kernel/.placeholder`
  - Phase 2 预置位，声明 `cangjie-kernel` 未来接入方式与准入要求。
- `scripts/sync/README.md`
  - Phase 3 预置位，声明 `sync_docs.py` 与 `index_to_skill.py` 的职责。

### Modify

- `README.md:5-22`
  - 把“项目初始化阶段”修正为已进入 `Phase 03: Physical Iron Test` 的实验平台叙事；在阅读顺序中加入 `.claude` 入口层。
- `AGENTS.md:25-26`
  - 把“项目初始化阶段”修正为已具备 repo-scale translation stack 原型并进入真实模块试验。
- `AGENTS.md:56-62`
  - 把“当前真正的第一优先级”从纯小样本期调整为“在保持最小闭环原则下推进真实模块级实验”。
- `docs/README.md:38-47`
  - 在建议阅读顺序中加入 `.claude` 入口层与当前阶段文件。
- `docs/development-workflow.md:5-16`
  - 在“开始任务前/执行任务时”加入 `.claude` 首跳与 L1/L2/L3 路由规则。
- `docs/project-overview.md:1-80`
  - 将阶段描述同步到“已完成初始化并进入真实模块级物理验证”的口径。

### Validate

- `python scripts/validate_claude_entry.py`
  - 验证 `.claude` 入口层骨架与关键语句。
- `rg -n "Phase 03: Physical Iron Test|blocked_by|static-blacklist-failed|L3 真实证据 > L2 项目约束 > L1 一般知识" .claude README.md AGENTS.md docs`
  - 验证核心阶段口径与关键路由语句已经露出。

---

### Task 1: Build the entry-layer validator

**Files:**
- Create: `scripts/validate_claude_entry.py`
- Test: `python scripts/validate_claude_entry.py`

- [ ] **Step 1: Write the validator script**

```python
#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

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
        "# Sync Pipeline Placeholder",
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
```

- [ ] **Step 2: Run the validator to verify it fails before `.claude` exists**

Run:
```bash
python scripts/validate_claude_entry.py
```

Expected:
```text
claude-entry validation: FAIL
- missing file: .claude/mission-control.md
- missing file: .claude/status/current-phase.md
- missing file: .claude/runbooks/pipeline-runner.md
- missing file: .claude/skills/index.md
- missing file: .claude/skills/base-kernel/.placeholder
- missing file: scripts/sync/README.md
```

- [ ] **Step 3: Make the script executable and keep it as the permanent Phase 1 smoke check**

Run:
```bash
chmod +x scripts/validate_claude_entry.py
```

Expected:
```text
# no output
```

---

### Task 2: Create Mission Control and Current Phase board

**Files:**
- Create: `.claude/mission-control.md`
- Create: `.claude/status/current-phase.md`
- Test: `python scripts/validate_claude_entry.py`

- [ ] **Step 1: Write `/.claude/mission-control.md`**

```md
# Mission Control

> 当前仓库的 Agent 入口总控台。
> 目标不是重复所有文档，而是让任何新进场的 Agent 在第一分钟内知道：
> 1. 当前项目正处于什么阶段；
> 2. 应该先读什么；
> 3. 应该跑什么命令；
> 4. 出现问题后该去哪一层知识里找答案；
> 5. 哪些动作默认不该做。

---

## 1. Current Stage

- 当前默认阶段：`Phase 03: Physical Iron Test`
- 当前仓库定位：`HarmonyOS / Cangjie 代码翻译实验平台`
- 当前主战场：`ArkTS / TelegramHarmony -> 仓颉` 的模块级真实翻译与验证
- 当前战况与最新阻塞：请先读 `/.claude/status/current-phase.md`

## 2. First Read Order

1. `AGENTS.md`
2. `/.claude/status/current-phase.md`
3. `/.claude/runbooks/pipeline-runner.md`
4. `/.claude/skills/index.md`
5. `docs/evaluation-criteria.md`
6. `docs/traces/` 与 `artifacts/pipeline_runs/`

## 3. Command Entry

当前推荐的实验入口：

- `scripts/pipeline_runner.py`
- `scripts/orchestrator.py`
- `scripts/verifier.py`

具体命令模板统一跳转到：`/.claude/runbooks/pipeline-runner.md`

## 4. Knowledge Routing

### L1：Kernel Knowledge
- 解决语言语法、标准库、`cjpm` / `cjc`、并发原语、CFFI 的一般性问题
- 默认目录：`/.claude/skills/base-kernel/`

### L2：Harmony / Telegram Project Constraints
- 解决 Harmony 页面映射、协议隔离、Domain purity、并发边界、Repo-scale translation 约束问题
- 默认目录：`skills/`

### L3：Real-time Pipeline Evidence
- 解决真实实验发生了什么、为什么失败、之前怎么修过的问题
- 默认目录：`docs/traces/`、`docs/samples/`、`artifacts/pipeline_runs/`、`artifacts/pattern_memory/`

优先级规则：

`L3 真实证据 > L2 项目约束 > L1 一般知识`

## 5. Failure Routing

- 语法 / 类型 / 构建问题：先查 L1，再对照 L3
- Harmony API / 生命周期 / Router：先查 L2，必要时回看官方文档
- 架构污染 / DTO 上浮 / 协议泄漏：直接查 L2，再结合 L3
- 静态黑名单 / Reviewer 高压项：先查 L3，再查 L2，不要优先退回语言百科

## 6. Guardrails

- 不要跳过 `AGENTS.md` 与当前阶段说明直接开跑
- 不要把 L1 的一般性示例直接当成项目级最佳实践
- 不要绕过 L2 的架构约束去“强行编过”
- 不要忽略 L3 的真实失败证据
- 不要把明文密钥写入仓库
- 不要未经授权执行高风险 Git 操作

## 7. Extension Points

### Phase 2：Kernel Absorption
目标目录：`/.claude/skills/base-kernel/`

### Phase 3：Docs Sync + Index to Skill
目标目录：`scripts/sync/`
```

- [ ] **Step 2: Write `/.claude/status/current-phase.md` with the current Round 26 evidence**

```md
# Current Phase

phase: `Phase 03: Physical Iron Test`
status: `active`
focus: `围绕 TelegramHarmony 真实模块做 Translate -> Review -> Verify -> Repair 的物理试验`

latest_run:
- label: `phase03-physical-iron-test-realmessageservice-023-round26-nested-legacy-smuggling-purge`
- target_file: `src/services/RealMessageService.ets`
- model: `Pro/zai-org/GLM-4.7`
- repair_rounds: `4`
- orchestration_final_status: `failed`

summary_path:
- `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-023-round26-nested-legacy-smuggling-purge/summary.json`

console_log_path:
- `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-023-round26-nested-legacy-smuggling-purge/console.log`

final_output_path:
- `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-023-round26-nested-legacy-smuggling-purge/temp_workspace/20260327T120556Z-tu-pipeline-realmessageservice-src-services-realmessageservice.ets/attempt-05/src/services/RealMessageService.cj`

blocked_by:
- `static-blacklist-failed`
- `std.unsafe`
- `ArrayList / Signal / ValueSignal / Array<UInt8> 一类高危污染残留`

next_actions:
- `优先巩固 .claude 入口层，降低新 Agent 进场成本`
- `把高频高危词从 L3 现场映射到 L2 修复模板`
- `为 Phase 2 的 kernel 吸收准备验真与补丁标记协议`
```

- [ ] **Step 3: Run the validator again and confirm it now fails only on the missing runbook, skills index, and placeholders**

Run:
```bash
python scripts/validate_claude_entry.py
```

Expected:
```text
claude-entry validation: FAIL
- missing file: .claude/runbooks/pipeline-runner.md
- missing file: .claude/skills/index.md
- missing file: .claude/skills/base-kernel/.placeholder
- missing file: scripts/sync/README.md
```

---

### Task 3: Create the runbook and skills router

**Files:**
- Create: `.claude/runbooks/pipeline-runner.md`
- Create: `.claude/skills/index.md`
- Test: `python scripts/validate_claude_entry.py`

- [ ] **Step 1: Write `/.claude/runbooks/pipeline-runner.md`**

```md
# Pipeline Runner Runbook

> 这里是当前仓库的命令入口手册，不重复解释所有背景。
> 先看 `/.claude/status/current-phase.md`，再在这里选择合适命令模板。

---

## 1. Mock 全链路

```bash
python scripts/pipeline_runner.py \
  --src-root third_party/TelegramHarmony \
  --target-file src/pages/HomePage.ets \
  --mock-mode \
  --verify-dry-run
```

## 2. 真实模型 + dry-run verify

```bash
OPENAI_API_KEY=xxx OPENAI_BASE_URL=https://open.bigmodel.cn/api/paas/v4 \
python scripts/pipeline_runner.py \
  --src-root third_party/TelegramHarmony \
  --target-file src/pages/HomePage.ets \
  --no-mock-mode \
  --llm-model zai-org/GLM-4.5-Air \
  --verify-dry-run
```

## 3. 真实模型 + 真实编译验证

```bash
OPENAI_API_KEY=xxx \
python scripts/orchestrator.py \
  --tu-json artifacts/tu/HomePage.ets.tu.json \
  --schema skills/SKILL_SCHEMA_V2.md \
  --verify-no-dry-run \
  --verify-real-compile \
  --compile-cmd 'cjc --build-path {workspace_dir} {candidate_file_path}'
```

## 4. Short-circuit

命中以下情况时，优先走 `L3 -> L2 -> Repair`：

- `static-blacklist-failed`
- `std.unsafe`
- `Signal`
- `ValueSignal`
- `import ... from`
- `sendRequest`
- `Array<UInt8>` 在 Service 层直出

不要先去 L1 寻找“保留脏代码”的理由。

## 5. 跳转说明

- 想知道当前最热视频点：`/.claude/status/current-phase.md`
- 想知道理论 / 项目 / 现场之间如何跳转：`/.claude/skills/index.md`
- 想找项目专项约束：`skills/`
```

- [ ] **Step 2: Write `/.claude/skills/index.md`**

```md
# Skills Index

> 这是三层知识路由表，不是知识正文。
> 它负责把 Agent 从“当前问题”送到最合适的知识层与证据层。

---

## 1. Routing Priority

### L1：Kernel Knowledge
- 解决语言语法、标准库、`cjpm` / `cjc`、并发原语、CFFI 的定义问题
- 默认目录：`/.claude/skills/base-kernel/`

### L2：Harmony / Telegram Project Constraints
- 解决 Harmony / Telegram 翻译的项目级约束与推荐模板问题
- 默认目录：`skills/`

### L3：Real-time Pipeline Evidence
- 解决真实实验中到底发生了什么的问题
- 默认目录：`docs/traces/`、`docs/samples/`、`artifacts/pipeline_runs/`、`artifacts/pattern_memory/`

优先级：

`L3 真实证据 > L2 项目约束 > L1 一般知识`

## 2. Entry Modes

### Concept-first
默认路径：`L1 -> L2 -> L3`

### Failure-first
默认路径：`L3 -> L2 -> L1`

## 3. Bridge Rules

### Bridge A：L1 -> L2
“语言允许，不等于项目推荐；继续检查 L2 项目约束。”

### Bridge B：L2 -> L3
“项目模板已明确，继续检查 L3 是否已有真实成功或失败先例。”

### Bridge C：L3 -> L1
“现场失败已确认，回查 L1 判断是语法错误、版本差异还是示例失效。”

若 L3 证明 L1 示例已过期，必须打上 `[L3-DEPRECATED]`。

### Bridge D：L3 -> L2
“现场失败优先解释为项目级违约，先查 L2 的替代模板。”

## 4. High-value Routes

### ArrayList
- 先去 L1 看定义
- 再去 L2 看项目是否推荐
- 再去 L3 看真实实验里是否炸过

### Atomic
- 若是概念问题：L1 -> L2 -> L3
- 若是报错问题：L3 -> L1 -> L2

### static-blacklist-failed
- 直接走 `L3 -> L2 -> Repair`
- 不要先退回 L1 寻找保留理由

## 5. Stop Conditions

出现以下情况时，停止继续检索，开始修复：
- 已找到项目级模板与真实先例
- 报错属于已知黑名单类别
- L3 已存在高度相似失败记录
- 继续检索只会把问题从修复拖成百科漫游

## 6. Canonical Links

### L2 高频入口
- `skills/domain-purity-hard-template.md`
- `skills/protocol-adapter-extraction-strategy.md`
- `skills/anti-corruption-and-concurrency-strategy.md`
- `skills/acl-mapper-and-domain-genesis-strategy.md`
- `skills/main-thread-ui-boundary.md`
- `skills/state-ownership-and-lifecycle.md`
- `skills/signal-based-reactive-pipeline.md`
- `skills/tdlib-c-interop-bridge.md`

### L3 高频入口
- `docs/traces/`
- `docs/samples/`
- `artifacts/pipeline_runs/`
- `artifacts/pattern_memory/`
```

- [ ] **Step 3: Run the validator again and confirm only the Phase 2 / 3 placeholders are still missing**

Run:
```bash
python scripts/validate_claude_entry.py
```

Expected:
```text
claude-entry validation: FAIL
- missing file: .claude/skills/base-kernel/.placeholder
- missing file: scripts/sync/README.md
```

---

### Task 4: Add Phase 2 / 3 placeholders and make the validator pass

**Files:**
- Create: `.claude/skills/base-kernel/.placeholder`
- Create: `scripts/sync/README.md`
- Test: `python scripts/validate_claude_entry.py`

- [ ] **Step 1: Write `/.claude/skills/base-kernel/.placeholder`**

```md
# Phase 2 Placeholder

这里是未来 `cangjie-kernel` 吸收后的目标目录。

准入规则：
- 外来 kernel 文档不能直接进入主知识层
- 必须通过 `verifier.py` 驱动的体检流程
- 若 L3 证明某段示例已过期，必须打上 `[L3-DEPRECATED]`
- 若语言层成立但项目层禁用，必须打上 `[L2-RESTRICTED]`

本目录在 Phase 2 之前只作为接口预置位存在。
```

- [ ] **Step 2: Write `scripts/sync/README.md`**

```md
# Sync Pipeline Placeholder

这里是 Phase 3 文档同步与切片流水线的预置位。

未来脚本：
- `sync_docs.py`
  - 从官方源同步文档镜像
- `index_to_skill.py`
  - 将文档切片并映射到当前 Skill 体系

目标：
- 把官方文档同步、切片、回写接入当前 `skills/`、`docs/`、`artifacts/` 流程
- 避免继续依赖散落在 `/tmp` 的一次性文档镜像

当前状态：
- Phase 3 未开始实现
- 本文件只负责固定接口位置与职责边界
```

- [ ] **Step 3: Run the validator and confirm the `.claude` skeleton now passes**

Run:
```bash
python scripts/validate_claude_entry.py
```

Expected:
```text
claude-entry validation: PASS
- ok: .claude/mission-control.md
- ok: .claude/status/current-phase.md
- ok: .claude/runbooks/pipeline-runner.md
- ok: .claude/skills/index.md
- ok: .claude/skills/base-kernel/.placeholder
- ok: scripts/sync/README.md
```

---

### Task 5: Update root docs so the repo narrative matches Phase 03 reality

**Files:**
- Modify: `README.md:5-22`
- Modify: `AGENTS.md:25-26`
- Modify: `AGENTS.md:56-62`
- Modify: `docs/README.md:38-47`
- Modify: `docs/development-workflow.md:5-16`
- Modify: `docs/project-overview.md:1-80`
- Test: `python scripts/validate_claude_entry.py`
- Test: `rg -n "Phase 03: Physical Iron Test|blocked_by|static-blacklist-failed|L3 真实证据 > L2 项目约束 > L1 一般知识" .claude README.md AGENTS.md docs`

- [ ] **Step 1: Patch `README.md` to reflect Phase 03 and expose `.claude` as the first operational entry**

```diff
@@
-当前仓库处于“项目初始化 + 文档定标 + 验证链路准备”阶段，当前优先目标不是直接翻译完整 Telegram 工程，而是先建立可持续迭代的文档、目录、Skill 与样本验证基础设施。
+当前仓库已完成“项目初始化 + 文档定标 + 验证链路准备”的早期阶段，现默认处于 `Phase 03: Physical Iron Test`，重点是围绕 Harmony / Telegram 真实模块推进 Translate -> Review -> Verify -> Repair 的物理试验，并持续沉淀 Skill、Pattern Memory 与执行证据。
@@
-1. `AGENTS.md`：项目协作规则、优先级、外部资源、开发约束；
-2. `docs/README.md`：文档索引与使用方式；
-3. `docs/project-overview.md`：项目背景、目标、范围、交付标准；
+1. `AGENTS.md`：项目协作规则、优先级、外部资源、开发约束；
+2. `/.claude/mission-control.md`：Agent 首跳总控台；
+3. `/.claude/status/current-phase.md`：当前阶段与最新战况；
+4. `docs/README.md`：文档索引与使用方式；
+5. `docs/project-overview.md`：项目背景、目标、范围、交付标准；
```

- [ ] **Step 2: Patch `AGENTS.md` so the stage description matches the actual repo capability**

```diff
@@
-- **当前阶段**：项目初始化阶段，重点是整理资料、设计 Skill、搭建验证路径，而不是直接翻译完整 Telegram 工程
+- **当前阶段**：已完成项目初始化与验证链路搭建，默认进入 `Phase 03: Physical Iron Test`，重点是围绕 Harmony / Telegram 真实模块推进 Translate -> Review -> Verify -> Repair 的物理试验，并把成功模式沉淀为可复用 Skill 与 Pattern Memory
@@
-当前不是直接翻译 Telegram 全量源码，而是优先完成以下前置工作：
+当前不是盲目铺开 Telegram 全量源码，而是优先在最小闭环原则下推进真实模块级实验与证据沉淀：
```

- [ ] **Step 3: Patch `docs/README.md`, `docs/development-workflow.md`, and `docs/project-overview.md` to add the `.claude` first-hop model**

```diff
*** docs/README.md
@@
-1. `AGENTS.md`
-2. `docs/project-overview.md`
+1. `AGENTS.md`
+2. `/.claude/mission-control.md`
+3. `/.claude/status/current-phase.md`
+4. `docs/project-overview.md`
```

```diff
*** docs/development-workflow.md
@@
-- 先阅读 `AGENTS.md`；
+- 先阅读 `AGENTS.md`；
+- 再阅读 `/.claude/mission-control.md` 与 `/.claude/status/current-phase.md`，确认当前阶段、命令入口与主要阻塞；
@@
-- 明确当前任务属于文档整理、Skill 构建、样本验证还是工程翻译；
+- 明确当前任务属于文档整理、Skill 构建、样本验证、工程翻译，还是 `.claude` / 路由层维护；
```

```diff
*** docs/project-overview.md
@@
-本项目围绕“将已有代码仓库翻译为仓颉语言版本”的目标展开，当前重点聚焦 Telegram 相关应用的翻译验证，并以鸿蒙 / ArkTS 场景作为第一落点。
+本项目围绕“将已有代码仓库翻译为仓颉语言版本”的目标展开，当前重点聚焦 Telegram 相关应用的真实模块级翻译验证，并以鸿蒙 / ArkTS 场景作为第一落点。当前默认阶段已进入 `Phase 03: Physical Iron Test`。
```

- [ ] **Step 4: Run the validator and a targeted grep smoke check**

Run:
```bash
python scripts/validate_claude_entry.py
rg -n "Phase 03: Physical Iron Test|blocked_by|static-blacklist-failed|L3 真实证据 > L2 项目约束 > L1 一般知识" .claude README.md AGENTS.md docs
```

Expected:
```text
claude-entry validation: PASS
...至少命中以下文件...
.claude/mission-control.md
.claude/status/current-phase.md
.claude/runbooks/pipeline-runner.md
.claude/skills/index.md
README.md
AGENTS.md
```

---

## Self-Review

### 1. Spec coverage

- `mission-control.md`：Task 2 覆盖
- `current-phase.md`：Task 2 覆盖，包含 `blocked_by`
- `pipeline-runner.md`：Task 3 覆盖，包含 `Short-circuit`
- `skills/index.md`：Task 3 覆盖，包含 L1/L2/L3、桥接句式与 Stop Conditions
- `base-kernel/.placeholder`：Task 4 覆盖
- `scripts/sync/README.md`：Task 4 覆盖
- “阶段口径同步”与 `.claude` 首跳：Task 5 覆盖

无明显缺口；Phase 2 / 3 只做接口预置，未越界到实现。

### 2. Placeholder scan

本计划正文不保留任何无实际执行意义的占位语句；所有步骤都给出了明确文件、命令、预期输出或补丁内容。

### 3. Type / naming consistency

- `.claude/mission-control.md`
- `.claude/status/current-phase.md`
- `.claude/runbooks/pipeline-runner.md`
- `.claude/skills/index.md`
- `.claude/skills/base-kernel/.placeholder`
- `scripts/sync/README.md`
- `scripts/validate_claude_entry.py`

以上命名与 approved spec 保持一致；`L1` / `L2` / `L3`、`Phase 03: Physical Iron Test`、`L3 -> L2 -> Repair`、`[L3-DEPRECATED]` 等关键术语在各任务中保持同名。
