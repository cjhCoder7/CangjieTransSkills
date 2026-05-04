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

- 当前默认阶段与唯一 active lane：以 `AGENTS.md` 与 `docs/current_state.v2.md` 为准
- 当前仓库定位：`HarmonyOS / Cangjie 代码翻译实验平台`
- 当前主战场：`ArkTS / TelegramHarmony -> 仓颉` 的模块级真实翻译与验证
- 当前战况与最新阻塞：先读 `AGENTS.md`、`docs/status/INDEX.md`、`docs/current_state.v2.md`、`docs/status/current_task_handoff.md`
- `/.claude/status/current-phase.md` 仅作 legacy rolling history，对齐旧背景时再读

## 2. First Read Order

1. `AGENTS.md`
2. `docs/status/INDEX.md`
3. `docs/current_state.v2.md`
4. `docs/status/current_task_handoff.md`
5. `/.claude/runbooks/pipeline-runner.md`
6. `/.claude/skills/index.md`
7. `docs/evaluation-criteria.md`
8. 需要旧背景时再读 `/.claude/status/current-phase.md`
9. 需要追原始证据时再读 `docs/traces/` 与 `artifacts/pipeline_runs/`

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
- 当前已准入样本：`/.claude/skills/base-kernel/option.md`

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

- 不要跳过 `AGENTS.md -> docs/status/INDEX.md -> docs/current_state.v2.md -> docs/status/current_task_handoff.md` 直接开跑
- 不要把 `/.claude/status/current-phase.md` 当默认 resume 首跳或当前 authority
- 不要把 L1 的一般性示例直接当成项目级最佳实践
- 不要绕过 L2 的架构约束去“强行编过”
- 不要忽略 L3 的真实失败证据
- 不要把明文密钥写入仓库
- 不要未经授权执行高风险 Git 操作

## 7. Extension Points

### Phase 2：Kernel Absorption
目标目录：`/.claude/skills/base-kernel/`
当前进展：`Option` 已完成首轮 admission，后续 kernel 单元应沿用同一体检通道。

### Phase 3：Docs Sync + Index to Skill
目标目录：`scripts/sync/`
