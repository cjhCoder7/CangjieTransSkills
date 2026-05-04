# Agent System README

> `role`: `architecture_explainer`
> `resume_surface`: `false`
> `default_live_truth`: `AGENTS.md -> docs/status/current_committed_plan.md -> docs/current_state.v2.md -> docs/status/INDEX.md -> docs/status/current_task_handoff.md`
> 若本页与 live truth surfaces 冲突，以 live truth surfaces 为准。

本页是维护者解释面，不是当前任务的默认恢复入口，也不是项目真值层。
它负责解释“为什么这么分层、各层怎么配合”，不负责宣布当前 goal、active lane、blocker 或 allowed moves。

本目录不是“把原 `AGENTS.md` 改写得更短”的工具包。
它的目标是把原版里真正决定质量的内容拆到对的位置上，让系统既不失真，也不继续臃肿。

当前这套架构要同时保住三类价值：

1. 原版 `AGENTS.md` 里的强执行骨架
2. `Debate / Conductor` 这套 harness 方法论
3. 外部主流 agent tooling 对“仓库级规则 + 路径级规则 + 任务级注入”的共识

说明：

- 文中用 `current_state / runtime_contract / domain_review_rubric` 作为概念名
- 在当前仓库里，它们实际落地为：
  - `docs/current_state.v2.md`
  - `docs/runtime_contract.v2.md`
  - `docs/domain_review_rubric.v2.md`

## 先看总图

建议把整套系统理解成五层，而不是两层：

1. `AGENTS.md`
   - 宪法层
   - 放跨任务稳定规则、热区读取顺序、证据纪律、协作骨架
2. `prompts/*.md`
   - 角色层
   - 放 `Debate / Conductor / Planner / Executor` 的视角与职责
3. `current_state / runtime_contract / domain_review_rubric`
   - 项目态层
   - 放项目当前快照、运行合同、仓库专有词义与 reviewer gate
4. `task_handoff / window_init`
   - task 层
   - 一个是持久 task 状态，一个是本次开窗的动态注入
5. `docs/reports/* / docs/status/* / .claude/status/current-phase.md / archive / artifacts`
   - 证据与历史层
   - 放详细日志、滚动阶段日志、why-not、长报告、原始产物

如果这些层被重新混写，系统很快会退化回“巨型 `AGENTS.md` + 高 token 噪声”的旧状态。

## 原版 AGENTS 哪些内容必须保留

原版 `AGENTS.md` 虽然过长，但以下内容不能在重构里丢掉：

- 热区读取顺序
- 输出与证据纪律
- baseline / compare / preview / smoke 不得误写成正式放行
- reviewer 与 executor 的角色张力
- 稳定模块教训
- git 宪法
- 热区日志只做索引，长日志另存

换句话说，重构不是“删规则”，而是“把规则放回正确承载面”。

## 图片方法论哪些必须落地

从 harness 方法论里，至少要落地这几件事：

### 1. Debate 不是泛泛 brainstorm

它必须真的解决：

- 问题定义
- 理想态与底层定义
- 四维 gap analysis
- 三段式策略与 `no-regret` 判断

特别是 Layer 2 里的底层定义不能丢：

- 主系统与工作台 / 会话系统的关系
- `session` 的生命周期
- 工作材料的对象模型
- 用户控制权与可见性边界

### 2. Conductor 不是“给 Dev 派活”

它必须真的承担：

- 状态机调度
- 增量 task 拆分
- per-task review
- clean-context 续接
- acceptance 前的最终编排

如果没有 `task_handoff` 这类持久 task 态，Conductor 就会退化成口头调度。

### 3. 低耦合不等于都能提前做

只有当一个改动：

- 不依赖未定义的 session / 工作台底座
- 不会让策略层在未定义基础上提前收敛

才适合被提前收割。
否则看起来“低耦合”，实际上是在掏空上层判断。

## 外部写法给出的共识

主流 agent tooling 的共同点不是“文件越短越好”，而是：

- 仓库级规则单独放
- 路径级 / 主题级规则继续拆分
- 任务级变量只在当前窗口注入
- 内容要 repo-specific、可执行、少空话

这也是为什么这里要把：

- 宪法
- 角色
- 项目态
- task handoff
- window init
- archive / reports

拆成不同文件，而不是继续堆回一处。

## 本目录里的文件应该怎么用

- `AGENTS.md`
  - 代理入口宪法、协作骨架、热区索引层
- `docs/status/INDEX.md`
  - 默认恢复入口；负责当前 task / `latest_report` / `raw_log_root` / path-scoped resume 导航
- `.claude/status/current-phase.md`
  - legacy 滚动阶段日志；只在需要追旧背景时读取
- `prompts/conductor.md`
  - 受控落地总管，不写代码
- `prompts/debate_*.md`
  - 问题收敛与结构化对抗
- `prompts/planner_reviewer.md`
  - 双窗口中的审查 / 放行 / 下一步指令角色
- `prompts/executor.md`
  - 真正做改动、测试、回传证据的角色
- `current_state_template.md`
  - 项目级当前快照模板
- `runtime_contract_template.md`
  - 运行态合同模板
- `domain_review_rubric_template.md`
  - 仓库特有词义与 reviewer gate 模板
- `task_handoff_template.md`
  - 当前 task 的持久交接模板
- `window_init_template.md`
  - 本次开窗注入模板
- `architecture_explained.md`
  - 给维护者看的“为什么这么拆”
- `codex_conversation_templates.md`
  - 给实际对话使用者的消息模板

## 推荐装配顺序

### 开 `reviewer + planner` 窗口

1. `AGENTS.md`
2. `docs/status/current_committed_plan.md`
3. `docs/current_state.v2.md`
4. `docs/status/INDEX.md`
5. `docs/status/current_task_handoff.md`
6. 需要时再加 `docs/domain_review_rubric.v2.md`
7. `prompts/planner_reviewer.md`
8. 若需要追旧背景，再读 `.claude/status/current-phase.md`
9. 最后补本轮 `window_init`

### 开 `executor` 窗口

1. `AGENTS.md`
2. `docs/status/current_committed_plan.md`
3. `docs/current_state.v2.md`
4. `docs/status/INDEX.md`
5. `docs/status/current_task_handoff.md`
6. 涉及运行时再加 `docs/runtime_contract.v2.md`
7. `prompts/executor.md`
8. 若需要追旧背景，再读 `.claude/status/current-phase.md`
9. 最后补本轮 `window_init`

### 开 `Debate` 窗口

1. `AGENTS.md`
2. `docs/status/current_committed_plan.md`
3. `docs/current_state.v2.md`
4. `docs/status/INDEX.md`
5. 若当前 task 相关，再读 `docs/status/current_task_handoff.md`
6. `prompts/debate_host.md`
7. `prompts/debate_proposer.md`
8. `prompts/debate_reviewer.md`
9. 当前议题、材料、停止条件

### 开 `Conductor` 窗口

1. `AGENTS.md`
2. `docs/status/current_committed_plan.md`
3. `docs/current_state.v2.md`
4. `docs/status/INDEX.md`
5. `docs/status/current_task_handoff.md`
6. `docs/runtime_contract.v2.md`
7. `prompts/conductor.md`
8. 若需要追旧背景，再读 `.claude/status/current-phase.md`
9. 当前 stage、允许动作、验收与升级条件

## 什么时候该继续拆，而不是继续加长

出现以下情况时，不要继续把内容塞进顶层 `AGENTS`：

- 规则只对某个子目录生效
- 术语只属于某个项目
- 当前是 task 级返工细节
- 当前只是某次 run 的证据说明
- 当前内容需要频繁变更

此时应优先考虑：

- path-scoped 文档或局部 `AGENTS`
- `current_state`
- `runtime_contract`
- `domain_review_rubric`
- `task_handoff`
- `docs/reports/*`

## 最小迁移建议

如果你已经有一份非常强但很长的 `AGENTS.md`，迁移时建议按这个顺序拆：

1. 先保留原版，不直接替换
2. 把跨任务稳定规则收进 `AGENTS.md`
3. 把 `planner / executor / debate / conductor` 拆成角色模板
4. 把项目特有边界词义拆到 `domain_review_rubric`
5. 把当前主线与 blocker 拆到 `current_state`
6. 把 task 过程状态拆到 `task_handoff`
7. 把长 why-not、周报、run 叙事拆到 `docs/reports/*` 或 archive

## 防呆规则

- 不允许在模板里保存明文密钥
- 不允许在 `AGENTS` 里保存 task 级返工过程
- 不允许用 `current_state` 代替 `task_handoff`
- 不允许用 `window_init` 覆写宪法
- 不允许为了省 token 把关键边界定义删掉
