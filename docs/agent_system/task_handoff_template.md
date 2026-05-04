# Task Handoff Template

这个文件承载“当前 task 或 landed checkpoint 的持久状态”。
它的存在是为了支持 clean-context 续接，不让每一轮 task 过程重新污染顶层 `AGENTS`。
统一基础恢复顺序固定为 `AGENTS.md -> docs/status/current_committed_plan.md -> docs/current_state.v2.md -> docs/status/INDEX.md -> docs/status/current_task_handoff.md`；模式路由与 authority/report 跳转再去读 `docs/agent_system/execution_routing.md`，不要回灌到本文件。

## 推荐结构

```markdown
# Current Task Handoff

更新时间：`YYYY-MM-DD HH:MM`

## 1. Task Identity

- task_id：
- lane：
- status：`scheduled | executing | blocked | in_review | passed | accepted`
- owner：
- reviewer：

## 2. Objective

- 当前 task 目标：
- done_when：
- 本 task 不要做什么：

## 3. Current Slice

- 当前只允许动的文件 / 模块：
- 当前只允许引用的 checkpoint / report / evidence：
- 当前显式禁止重开的旧分支：

## 4. What Is Already Done

- 已完成子任务：
- 已通过的验证：
- 已落盘的关键路径：

## 5. Current Blockers

- blocker：
- 缺什么证据才能继续：
- 若超过约定轮次应升级给谁：

## 6. Reopen Conditions

- 什么时候才应该重开这个 task：
- 一旦重开，第一动作是什么：
- 不要重复做的事：

## 7. Acceptance Snapshot

- 当前离 acceptance 还差什么：
- 哪些只是文档瑕疵，不构成 blocker：
```

## 什么时候更新

只在 task 状态真的变化时更新，例如：

- task 开始执行
- task 进入返修
- task blocker 变化
- task 通过 per-task review
- task 被 acceptance 或被明确废弃

## 不该放进来什么

- 项目级长期规则
- 完整周报
- 全量命令输出
- 与当前 task 无关的背景历史
- 默认恢复顺序 / 模式路由 / wake-up 总则
- 当前批准计划 / repo 级 active lane / allowed moves 裁决
