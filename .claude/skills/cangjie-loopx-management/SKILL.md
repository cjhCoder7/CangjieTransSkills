---
name: cangjie-loopx-management
description: "使用 LoopX 管理 CangjieTransSkills 的翻译、构建、测试、UI 验证和经验回写任务。操作型仓颉/HarmonyOS 请求自动使用；纯知识问答不创建 Goal"
---

# CangjieTransSkills 的 LoopX 管理适配

本 skill 是仓颉领域流程与 LoopX 控制面的唯一连接层。仓颉相关 skill 负责分析和执行，LoopX CLI 负责 Goal、Todo、用户 Gate、运行状态、恢复和结案。

不要在各领域 skill 中重写 LoopX 状态机，也不要根据聊天记录自行维护第二套任务状态。CLI 返回的 Goal、Agent、Todo、边界、Gate 和命令模板是当前状态的权威来源。

## 何时进入管理流程

以下请求必须由本 skill 管理：

- 应用或库迁移、代码修改、资源迁移；
- 应用或 cjpm 库构建、测试；
- HarmonyOS UI 采集、交互验证和修复迭代；
- 与上述交付绑定的经验回写和最终质量检查。

语法解释、API 查询、文档定位、已有代码只读分析等不会改变项目的请求，不创建 Goal。

## 运行前检查

1. 先按 `base-skill` 判定项目类型、模型能力和必要环境。
2. 解析一次本会话使用的 LoopX 命令前缀：优先使用 PATH 中的 `loopx`；若其不存在但 LoopX 已安装到指定 Python 3.11+ 环境，使用 `<python> -m loopx.cli`。下文的 `loopx` 均代表这个已验证的命令前缀，不得在同一 Goal 中混用不同安装来源。
3. 从实际目标项目根运行 `loopx doctor`。需要排查运行时时使用 `loopx doctor --deep`。
4. 若 LoopX 不可用，停止操作型流程，提示用户在 CangjieTransSkills 仓库执行：

   ```bash
   ./setup.sh <目标项目路径>
   ```

   LoopX 要求 Python 3.11+、Node.js 22.6+ 和兼容的 LoopX `>=1.0.2,<2`。不得在失败时退化为聊天内的临时 Todo。
5. 若目标是 Git 仓库，在首次状态写入前用 `git check-ignore` 确认 `.loopx/`、`.codex/goals/`、`.local/` 和领域原始证据目录受到项目 `.gitignore` 或本地 exclude 保护。缺少保护时先补充最小忽略规则，不允许把运行状态混入交付 diff。
6. 读取仓库级指令和 Git 状态，确认操作范围属于用户指定的目标项目。LoopX 不扩大文件、网络、凭据或外部系统权限。

## 新任务：建立 Goal 和有序 Todo

从目标项目根执行：

```bash
loopx --format json start-goal --guided --project . --goal-text "<用户目标>"
```

若当前会话已绑定稳定的 `goal_id` / `agent_id`，后续命令复用该身份；不得根据“唯一一个 Agent”或注册顺序猜测接管身份。

在写 Todo 前先向用户给出简洁、有序的实施计划。然后使用 `start-goal` 返回的命令包或 CLI 提示写入 Todo，保持计划顺序与写入顺序一致。Todo 应按可独立验证的阶段划分，不要为每个文件创建管理噪音。

应用迁移、库迁移、独立构建和 UI 验证的推荐拆分见 [工作流映射](references/workflow-mapping.md)。

## 恢复任务：先读状态再执行

任务已连接或可能是续作时，先读取实时状态：

```bash
loopx --format json diagnose --goal-id <GOAL_ID>
loopx --format json status --goal-id <GOAL_ID> --limit 20
loopx --format json quota should-run --goal-id <GOAL_ID> --agent-id <AGENT_ID>
```

以 `quota should-run` 的实时结果决定本轮行为：

- `should_run=true`：只执行 `selected_todo` 指向的有界阶段，并遵守 `goal_boundary`、required capabilities 和工作区约束；
- `state=operator_gate`：读取 `operator_question`、`gate_prompt`、`missing_gates` 和 `recommended_action`，向用户提出具体问题，不把 Gate 当作普通失败；
- 未准入、等待或没有可执行 Todo：不产生虚假进度；说明实时状态并停止本轮写操作；
- 投影互相矛盾、重复选择已完成 Todo、连续只有微小进展：进入“自修复”流程。

不要凭记忆选择下一项，也不要仅因为任务安全或容易就绕过 quota 决策。

## 执行与写回

1. 在所选 Todo 边界内调用对应仓颉领域 skill。
2. 记录可验证事实：修改范围、构建或测试结果、产物、UI 断言、未解决问题和下一动作。
3. 使用当前 CLI 投影给出的 `refresh-state`、Todo 更新/完成和 quota settlement 命令写回；优先执行 CLI 返回的精确命令模板，不手工猜测版本相关参数。
4. 只有实际验收通过后才能完成 Todo。失败时保留 Todo 为未完成状态，并写入公开安全的错误摘要和修复方向。
5. Todo 完成必须有明确 successor，或者使用 CLI 要求的 terminal no-follow-up 结案语义；随后再次执行 `quota should-run`，确认不会重复选择已结案工作。

写回内容只保留决策所需的紧凑证据。原始日志、截图、控件树、凭据、私有链接和本机绝对路径留在被 Git 忽略的本地目录中。

## 用户 Gate

以下情况创建或维持 `user_gate`，并阻断受影响的 Agent Todo：

- 高风险语义改写或不可直接翻译项需要用户选择；
- 源资源、SDK、DevEco Studio、设备或凭据缺失；
- 目标路径或写入边界会显著改变用户指定范围；
- 需要外部发布、远程仓库写操作或其他未获授权动作。

能从参数、项目结构或现有配置可靠推断的信息不创建 Gate。非阻塞的用户后续事项使用 `user_action`，不得阻塞无关 Todo。

## 自修复

遇到状态漂移、错误推荐、Todo 丢失、同一失败反复出现或流程异常变小时：

1. 暂停新的交付选择；
2. 运行 `git status --short --branch`、`loopx diagnose`、`status`、`quota should-run` 和最近历史，形成紧凑证据；
3. 区分 Agent 行为、状态投影、Goal 编排、领域实现或文档规则的问题；
4. 在最低且可复用的层级修复，并运行能捕获问题的最小验证；
5. 更新 Goal/Todo/下一动作后重新进入 quota 检查。

不得通过放宽 Gate、伪造成功或复制私有运行状态解决漂移。

## 条件能力

- 发现未来任务需要复用的设计、API、迁移决策或研究材料时，使用 LoopX doc-registry 流程登记脱敏的权威摘要；源文件仍由项目自身管理。
- 仅当 Goal 的 `change_quality_qualification.enabled=true` 时，安装并使用 `loopx-change-quality` 的 Claude Code 项目副本，对最终精确 diff 生成和验证回执。
- Material Lifecycle、benchmark、PR program 和 PR review 不属于普通仓颉迁移的默认流程；只有用户目标明确触发且具备对应权限时才启用。

## 结案条件

只有同时满足以下条件，才能将迁移目标结案：

- 目标功能和资源达到对应翻译 skill 的完整度要求；
- 应用构建或 `cjpm build` 成功，要求的测试通过；
- 含 UI 的应用已按目标范围完成 UI 验证，或存在明确且经用户接受的跳过理由；
- 所有降级、跳过、用户决策和剩余风险均有记录；
- 非显而易见且已验证的问题完成经验回写；
- 启用的质量策略已有当前精确 diff 的有效回执；
- 最终 `quota should-run` 不再要求重复执行已完成工作。
