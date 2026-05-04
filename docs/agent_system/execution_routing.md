# Execution Routing / Collaboration Modes

更新时间：`2026-04-21 03:26 UTC`

本文件承载长期执行路线、模式读取面、wake conditions 与 anti-stall routing。
它不是项目真值层，不覆写 `AGENTS.md`、`current_committed_plan`、`current_state` 或 `current_task_handoff`。
它也不是默认恢复入口；只有在需要协作模式边界、角色分工、wake conditions 或 anti-stall 时才继续读。

## 1. Standard Resume Order

- 标准恢复顺序：`AGENTS.md -> docs/status/current_committed_plan.md -> docs/current_state.v2.md -> docs/status/INDEX.md -> docs/status/current_task_handoff.md`
- 只有在需要模式路由、双窗口分工、wake conditions 或 anti-stall 时，才继续读本文件。
- 若本文件与 `current_task_handoff` 在当前 task pointer / status 上不一致，按 `current_task_handoff` 为准。
- 若本文件在 active lane / blocker / allowed moves 上比 `current_state` 更激进或更宽，按 `current_state` 收口。

## 2. Collaboration Mode Routing

| 模式 | 必须先读 | 默认动作 |
| --- | --- | --- |
| `单窗口执行模式` | `AGENTS -> current_committed_plan -> current_state -> INDEX -> current_task_handoff` | 单执行者直接推进当前主线 |
| `Reviewer + Planner / Executor` | `AGENTS -> current_committed_plan -> current_state -> INDEX -> current_task_handoff`，再按角色补 `runtime_contract` / `domain_review_rubric` / prompts | `reviewer + planner` 负责判断主线，`executor` 负责实现与证据 |
| `Debate 模式` | `AGENTS -> current_committed_plan -> current_state -> INDEX`，必要时补 `current_task_handoff` 与 debate prompts | 先做问题收敛，不直接实现 |
| `Conductor 模式` | `AGENTS -> current_committed_plan -> current_state -> INDEX -> current_task_handoff -> runtime_contract` | 按 task 单元、quality gate、clean-context 续接推进 |

## 3. Mode Boundaries And AGENT TEAM Capability

- `AGENT TEAM` 不是协作模式本身；它只是可挂接在当前模式上的条件化能力。
- `Reviewer + Planner / Executor` 是默认显式双窗口模式，不等于自动并行 widening。
- `Debate` 默认不直接实现，除非用户明确 reroute。
- `Conductor` 负责任务编排、quality gate 与 clean-context 续接，不把用户一句话自动升格为全面并行。
- 只有 owner、write set 与 verification surface 都能拆清时，才允许附加 `AGENT TEAM`。

## 4. Current Long-Running Route

当前条件化主路线固定为：

1. 维持 `Phase05` 双 baseline 稳定与 `Phase06 regular` 的 `P22 / 311/311 live passed` 冻结边界
2. 继续把 `Phase07 Telegram UI Incubation` 保持为唯一 active continuation lane
3. 当前 approved step 已推进到 `M11 Telegram Active-Detail Same-Peer Draft Recovery Third Same-Peer Refresh Before First-Reopen Preserve Slice landed`
4. 当前 `M11` 已收口为 latest landed same-package slice：它只在 `M10` 的 exact two-refresh chain 上，再追加 exactly one same-peer refresh，总计三次 same-peer refresh before first reopen；其 landed truth 直接复用已闭合的 `M11` proof report / proof-round evidence bundle，不重跑测试，也不生成第二套 evidence bundle
5. 当前 `M11` 继续作为 latest landed Telegram consume entry：`latest_report` 已切到 `M11` landed report，`raw_log_root` 已切到现有 `M11` proof-round evidence bundle，next bounded continuation slice 仍待 reviewer 明确批准，`Phase07` 仍保持 `exploratory-only`；当前不把这条 lane 外推成 promoted / live / mechanical-ready，更不重开 `P23`
6. 若需要追溯 shared harness、cache-sample gate、app-shell boundary、`M11` freeze 定义、`M11` supporting proof report 或 verification contract，只把它们当作已冻结 / 已闭合输入，不自动改写当前 lane judgment

上述路线是条件化下游路线，不得改写成“已完成更高 staging promotion”“direct P23 mechanical-ready 已放开”或“当前已进入新 formal lane”。

## 5. Collaboration Wake Conditions

- 唤醒 `Reviewer + Planner / Executor`
  - 用户明确要求双窗口协作
  - 当前需要审查 / 执行分工
  - 当前任务需要 reviewer 判断是否真正推进主线
- 唤醒 `Debate`
  - 需求边界、对象模型、验收口径仍不清楚
  - 当前分歧来自底层概念不一致，而不是实现细节
- 唤醒 `Conductor`
  - 当前任务已经批准，需要按 task 单元编排、续接、过 quality gate
  - 需要维护 clean-context handoff，而不是继续停留在口头调度
- 附加 `AGENT TEAM`
  - 只在当前主模式已明确，且 owner、write set、verification surface 可以低耦合拆分时启用
  - 用户提到“多人”“并行”本身，不足以自动开启

## 6. Fallbacks

- 若 `INDEX` 未及时同步，仍按 `current_committed_plan` 与 `current_state` 收口，不直接从旧 `latest_report` 外推新动作或新 continuation slice。
- 若 `current_task_handoff` 只记录 landed checkpoint 而非 active task，不能把它自动升级成新的 executing task。
- 若工具面不支持真实双窗口，仍按对应角色顺序在同一代理内执行，不回退成无角色协作。
