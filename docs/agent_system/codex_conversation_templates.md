# Codex Conversation Templates

这份文档回答两个问题：

1. 以后应该怎样给 Codex 开局
2. 什么时候该开 `Debate`、`Conductor`、双窗口或单窗口

核心原则只有一句：

不要每次都手写一大段“项目全史”。
应该让稳定信息落盘，只把这次任务真正变化的东西注入当前窗口。

## 一、初始化一个新项目

```text
当前目录是一个新项目。

目标：
1. 基于现有 `AGENTS` / `docs/agent_system` 蓝本初始化协作结构
2. 先不要做业务代码改动
3. 只完成协作基础设施初始化

要求：
- 先读取 `AGENTS` 和 `docs/agent_system` 蓝本
- 产出本项目的：
  - `docs/current_state.v2.md`
  - `docs/runtime_contract.v2.md`
  - `docs/domain_review_rubric.v2.md`
  - `docs/status/current_task_handoff.md`（可先给最小版本）
- 若当前项目信息不足，先给最小可用版本，不要脑补过多业务细节
- 回答时先给“思路 / 假设 / 权衡”，再给“结论 / 动作”
```

## 二、日常单窗口执行

```text
当前任务：
- 目标：
- 范围：
- 非范围：
- 完成标准：

请先按 `AGENTS` 读取顺序对齐状态。
命中时再读：
- `docs/current_state.v2.md`
- `docs/runtime_contract.v2.md`
- `docs/domain_review_rubric.v2.md`
- `docs/status/current_task_handoff.md`

要求：
- 不擅自扩大范围
- 先给“思路 / 假设 / 权衡”，再给“结论 / 动作”
- 修改后必须带回验证证据
- 若发现文档、代码、artifact 叙事冲突，先做一致性核对
```

## 三、双窗口模式

### 给 `reviewer + planner` 窗口

```text
你在这个窗口中的固定角色是 `reviewer + planner`，不是主执行者。

请先读取：
- `AGENTS`
- `docs/current_state.v2.md`
- 必要时再读 `docs/domain_review_rubric.v2.md`
- 若任务在途，再读 `docs/status/current_task_handoff.md`

你的任务是：
- 审查执行者回复
- 判断是否真正推进了当前主线
- 给出下一步可直接转发给执行者的指令

要求：
- 没有证据就视为没完成
- 不抓非阻断瑕疵不放
- 先给审查思路，再给审查结论
- 默认偏推进主线，不做礼貌性点评
```

### 给 `executor` 窗口

```text
你是当前任务的执行者。

请先读取：
- `AGENTS`
- `docs/current_state.v2.md`
- 若涉及运行时，再读 `docs/runtime_contract.v2.md`
- 若任务在途，再读 `docs/status/current_task_handoff.md`

当前任务：
- 目标：
- 范围：
- 非范围：
- 完成标准：

要求：
- 不擅自扩大范围
- 默认先给“思路 / 假设 / 权衡”，再给“结论 / 动作”
- 修改后必须带回验证证据
- 若任务复杂且可拆分，再按 `AGENT TEAM` 规则启用团队
```

## 四、什么时候开 Debate

出现以下任一情况，就不要直接让执行者开干：

- 问题其实没定义清楚
- 方案分歧来自底层概念不一致
- 主系统 / 工作台边界不清
- `session` 生命周期没定义
- 工作材料对象模型没定义
- scope 裁一裁可能把目标裁空

```text
当前不要直接实现。
先进入 `Debate` 模式，目标是把问题收敛成可执行 PRD / 共识文档。

请使用：
- `debate_host`
- `debate_proposer`
- `debate_reviewer`

当前议题：
- 问题：
- 已知材料：
- 当前分歧：
- 结束标准：
```

## 五、什么时候开 Conductor

当需求已经批准、要进入受控落地时，再开 `Conductor`。

```text
当前需求已经批准，接下来不要自由发挥实现。
请按 `Conductor` 机制推进：
- 先确认当前 stage
- 拆最小 task
- 每个 task 都要有验证证据
- per-task review 未过不能进入下一个 task
- 当前 task 的持续状态同步到 `docs/status/current_task_handoff.md`
- 最后统一收口 acceptance
```

## 六、什么时候更新哪些文件

- 主线 / blocker / 当前允许动作变化
  - 更新 `current_state`
- 运行命令 / env / consume boundary 变化
  - 更新 `runtime_contract`
- 仓库特有词义或 reviewer gate 变化
  - 更新 `domain_review_rubric`
- 当前 task 进入返工、换人、过审或阻塞变化
  - 更新 `current_task_handoff`
- 只是本次开窗变量变化
  - 更新 `window_init`

## 七、最常见误区

- 误区 1：每次都把所有文档全文贴给 Codex
  - 正解：默认只给 `AGENTS` + 当前角色 + 当前任务 + 必要状态面

- 误区 2：每次任务结束都重写整个 `current_state`
  - 正解：只有项目级快照变了才更新

- 误区 3：把 task 返工过程直接写回 `AGENTS`
  - 正解：写入 `task_handoff`

- 误区 4：把角色模板写进 `AGENTS`
  - 正解：角色模板单独文件，避免角色泄漏
