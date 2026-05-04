# Full Pass Harmony Refresh & Summary Builder Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 `pipeline_runner.py --full-pass-refresh-cmd` 补齐真实 Harmony Full Pass refresh harness 与 `summary.json` 生成器，让 Path B 环境也能先完成脚本级自验证与证据链模板固化。

**Architecture:** 新增一个 Bash refresh harness 负责 preflight、state reset、log capture、log filtering、install/launch/exercise 编排，再新增一个 Python builder 把过滤后的 Hilog 归一化为 `docs/schemas/full-pass-summary-schema.json` 所要求的 `summary.json`。验证层使用现有 `full-pass-summary-validate.py` 做第二闸门，测试层采用 Python `unittest` + 现有 example log 做最小红绿闭环。

**Tech Stack:** Bash、Python 3、`unittest`、现有 `jsonschema` validator、`pipeline_runner.py` 占位符模板。

---

### Task 1: 先写最小红灯测试

**Files:**
- Create: `tests/test_full_pass_summary_builder.py`

- [ ] **Step 1: 写 builder pass/nonpass 夹具测试**
- [ ] **Step 2: 写 refresh harness 语法/帮助测试**
- [ ] **Step 3: 运行 `python3 -m unittest discover -s tests -p 'test_full_pass_summary_builder.py' -v`，确认红灯**

### Task 2: 实现 refresh harness 与 summary builder

**Files:**
- Create: `scripts/full-pass-summary-builder.py`
- Create: `scripts/full-pass-harmony-refresh.sh`

- [ ] **Step 1: 实现 Hilog → summary 生成器**
- [ ] **Step 2: 实现带 Timeout Guard / Log Pre-processor / State Reset 的 refresh harness**
- [ ] **Step 3: 回跑 Task 1 测试，确认变绿**

### Task 3: 更新使用文档与命令模板

**Files:**
- Modify: `scripts/README.md`
- Modify: `docs/phase-03-full-pass-readiness-checklist.md`

- [ ] **Step 1: 写清环境变量约定与推荐命令模板**
- [ ] **Step 2: 补充 builder + validator 的本地验证命令**
- [ ] **Step 3: 记录 Path B 下只能做脚本级验证、不能误报 Full Pass**
