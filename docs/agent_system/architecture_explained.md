# Agent System Architecture Explained

这份文档是给维护者看的，不是给模型每轮都注入的。

它回答五个问题：

1. 这些文件分别负责什么
2. 原版 `AGENTS.md` 的哪些价值必须保留
3. `Debate / Conductor` 分别解决什么问题
4. `current_state / task_handoff / window_init / archive` 有什么区别
5. 以后新增信息时该落到哪一层

说明：

- 下文用 `current_state / runtime_contract / domain_review_rubric` 作为概念名
- 在当前三项目落地时，对应的实际文件是：
  - `docs/current_state.v2.md`
  - `docs/runtime_contract.v2.md`
  - `docs/domain_review_rubric.v2.md`

## 一、先记住：不是四层，而是五层

更贴近实际的分层是：

1. 宪法层：`AGENTS.md` / `AGENTS.refactor.md`
2. 角色层：`prompts/*.md`
3. 项目态层：`current_state` / `runtime_contract` / `domain_review_rubric`
4. task 层：`task_handoff` / `window_init`
5. 证据与历史层：`docs/reports/*` / `docs/status/*` / archive / artifacts

之所以要把 task 层单独抽出来，是因为图片方法论里的 `Conductor` 明确依赖“clean-context 续接”。
如果没有一个稳定的 per-task 持久承载面，系统最终还是会把 task 过程回写进顶层 `AGENTS`。

## 二、每层分别解决什么问题

### 1. 宪法层

回答：

- 怎么做
- 先读什么
- 什么不能做
- 角色如何协作
- 证据和叙事如何收口

不回答：

- 当前项目今天推进到哪一步
- 这个 task 已经返工几轮
- 某次 run 的详细 why-not

### 2. 角色层

回答：

- 这个角色看世界的视角是什么
- 它该对什么负责
- 它该拒绝什么

不回答：

- 当前主线是什么
- 当前 blocker 是什么
- 这个项目特有术语是什么意思

### 3. 项目态层

回答：

- 当前项目的唯一 active lane 是什么
- 当前 blocker 是什么
- 运行时有哪些硬边界
- 仓库专有词义与 promotion ladder 是什么

不回答：

- 当前 task 的返工细节
- 每次窗口启动的动态变量
- 长历史和长 why-not

### 4. task 层

回答两类不同问题：

- `task_handoff`
  - 这个 task 当前做到哪
  - 已有哪些证据
  - 下一位 agent 最少需要接什么上下文
- `window_init`
  - 本次开窗的目标、范围、禁区、验证要求是什么

它们不是一回事：

- `task_handoff` 是持续状态
- `window_init` 是本次注入

### 5. 证据与历史层

回答：

- 为什么形成今天的判断
- 证据路径在哪
- 上次具体跑了什么
- 长 why-not 和替代分支是什么

它不应该再回流污染上面四层。

## 三、原版 AGENTS 的价值到底在哪

原版 `AGENTS.md` 最大的价值通常不在“它很长”，而在它把这些东西绑在了一起：

- 热区读取顺序
- 稳定模块教训
- reviewer / executor 的真实角色边界
- baseline / compare / preview / smoke 的叙事红线
- 输出证据纪律
- git 宪法
- 热区日志索引

这些东西是要保留的。
真正要改的是承载位置，而不是把它们概括没了。

## 四、Debate 到底该解决什么

`Debate` 不等于 brainstorm。
它的存在价值是把“看起来像方案分歧、实际是底层定义没对齐”的问题提前收口。

### Debate 的四层

1. 问题定义 / 产品定位
2. 理想态与底层定义
3. 四维 gap analysis
4. 三段式策略与 `no-regret`

### 第二层不能丢的四个底座

1. 主系统与工作台 / 会话系统的关系
2. `session` 的生命周期
3. 工作材料的对象模型
4. 用户控制权与可见性边界

如果这四项没定义，后面的策略、裁剪和排期很容易变成伪推进。

### Debate 的典型产物

- 四层共识文档
- PRD 摘要
- scope / 非 scope
- 风险
- 待确认项

## 五、Conductor 到底该解决什么

`Conductor` 的意义不是“多一个会指挥人的 agent”。
它的意义是把落地过程从“整包交给 Dev”改成“task 级闭环”。

### Conductor 的职责

- 维护状态机
- 拆最小 task
- 控制 dispatch
- 管每个 task 的质量闸门
- 控制 context budget
- 管 acceptance 前的最终编排

### Conductor 的最关键纪律

1. 一次只推进一个最小可验收 task
2. Dev 做完一个 task 后立即过审，不等全部做完
3. 失败时优先原地返修，避免任务扩散
4. 通过后下一个 task 用新上下文继续
5. task 的持续状态写进 `task_handoff`，不写回 `AGENTS`

### 什么情况必须升级给用户

- scope 变了
- user-facing 判断还没定
- 数据库 / schema / 外部接口迁移
- blocker 超过约定轮次
- 代码、文档、artifact 叙事冲突并影响 acceptance

## 六、`current_state`、`task_handoff`、日志三者怎么区分

这是最容易写乱的地方。

### `current_state`

解决“项目现在是什么状态”。

适合放：

- 当前阶段
- 唯一 active lane
- 当前 blocker
- 当前允许动作
- 当前明确禁止动作

### `task_handoff`

解决“当前这一个 task 在哪一步”。

适合放：

- task id / owner / status
- 当前 objective
- 已完成子任务
- 当前 blocker
- 最新验证证据
- 下一位 agent 的起点

### 日志 / 报告 / archive

解决“这个状态是怎么来的”。

适合放：

- 命令
- artifact 路径
- why-not
- 对比分析
- 长叙事

一句话区分：

- `current_state` = 项目级当前快照
- `task_handoff` = 当前 task 的持续状态
- `日志 / 报告 / archive` = 形成这些状态的证据历史

## 七、什么时候该新增 path-scoped 规则

出现以下任一情况时，优先考虑新增子目录文档或局部 `AGENTS`：

- 某规则只对一个子系统生效
- 某目录有自己稳定的 build / verify / release 方式
- 某类文件有独立的 reviewer gate
- 某块知识频繁更新，不适合顶层宪法承载

不要把所有局部差异继续推回顶层 `AGENTS`。

## 八、工具特定文件应该怎么处理

现在不同 agent / IDE 会识别不同入口：

- `AGENTS.md`
- `CLAUDE.md`
- `GEMINI.md`
- `.github/copilot-instructions.md`

正确做法不是为每个工具各写一套不同宪法，而是：

1. 保持一套核心规则为主
2. 工具特定文件只做薄 shim
3. shim 负责导向同一套核心文档，或只补该工具必要差异

否则很快会出现“不同工具读到的是不同项目现实”。

## 九、以后该更新哪个文件

### 场景 1：跨任务规则变了

更新：

- `AGENTS`

### 场景 2：角色职责或门槛变了

更新：

- `prompts/*.md`

### 场景 3：项目主线、blocker、允许动作变了

更新：

- `current_state`

### 场景 4：运行命令、env、consume boundary 变了

更新：

- `runtime_contract`

### 场景 5：术语、promotion ladder、reviewer gate 变了

更新：

- `domain_review_rubric`

### 场景 6：当前 task 做到一半、换人或换上下文续做

更新：

- `task_handoff`

### 场景 7：只是本次开窗多了几个动态变量

更新：

- `window_init`

### 场景 8：需要保存详细命令、证据、why-not、长报告

更新：

- `docs/reports/*`
- `docs/status/*`
- `docs/agent_evolution_archive.md`

## 十、最重要的维护原则

- 不为追求轻量而删掉关键定义
- 不为追求“一处全有”而重新混层
- 不把 task 过程回写成宪法
- 不让角色模板背项目长期记忆
- 不让 `window_init` 演化成新的超长系统提示词
