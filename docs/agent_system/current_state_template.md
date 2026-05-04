# Current State Template

这个文件承载“项目级当前快照”。
它回答的是“项目现在在哪、唯一主线是什么、哪些动作现在允许”，而不是“这个 task 已返工几轮”。

## 推荐结构

```markdown
# Current State

更新时间：`YYYY-MM-DD`

## 1. Headline

- 当前阶段：
- 唯一 active lane：
- 当前 blocker：
- 本周唯一主线目标：

## 2. What Is Active Now

- 当前唯一建议推进的工作：
- 当前 owner / reviewer 状态：
- 当前依赖的权威文档：
  - `specs/...`
  - `docs/reports/...`
  - `artifacts/...`

## 3. Allowed Moves

- 当前允许动作 1：
- 当前允许动作 2：
- 当前允许动作 3：

## 4. Explicit Non-Goals

- 当前明确禁止动作 1：
- 当前明确禁止动作 2：
- 当前不应重开的旧方向：

## 5. Pending Decisions

- 需要用户 / PM 最终拍板的点：
- 当前仍缺的关键证据：
- 若 blocker 解除，下一步应切到：

## 6. Evidence Index

- 状态页 / runbook：
- 最近一次 authoritative report：
- 当前 canonical artifact / dashboard：
```

## 使用原则

- 只写项目级当前快照
- 优先写“现在是什么”，而不是“过去发生了什么”
- 若需要解释为什么形成今天的状态，链接到 `docs/reports/*` 或 archive

## 什么时候更新

只在快照真的变化时更新，例如：

- 当前阶段变化
- 唯一 active lane 变化
- 当前 blocker 变化
- 当前允许动作变化
- 一个阶段正式收口并进入下一个阶段

## 不该放进来什么

- per-task 返工过程
- 长 artifact 路径洪水
- 运行时 exact flags / exact counts
- 长 why-not 分析
- 全量历史日志
- “今天这个 agent 干了什么”的流水账

## 容易混淆的相邻承载面

- `current_state`
  - 项目级当前快照
- `task_handoff`
  - 当前 task 的持续状态
- `window_init`
  - 本次开窗的动态变量
- `docs/reports/*`
  - 详细分析和证据
