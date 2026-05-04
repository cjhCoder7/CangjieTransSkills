# Trace: Phase 03 Physical Iron Test — RealMessageService Round 32 Match Helper Push

- 日期：`2026-03-30`
- 目标：`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`
- 运行目录：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-031-round32-match-helper-push`
- 模型：`Pro/zai-org/GLM-4.7`（SiliconFlow OpenAI-Compatible API）
- 核心新增：`skills/cangjie-match-helper-extraction-v1.md`

## 1. 本轮目的

Round 31 已经证明：

- `constructor -> init` 修正开始生效；
- 但系统仍把 `let` / `this.messageCache.add(...)` / 嵌套 `match` 塞在 `case ... => { ... }` 分支块里，持续触发：
  - `expected '=>' in lambda expression, found keyword 'let'`
  - `expected '=>' in lambda expression, found keyword 'this'`
  - `expected '=>' in lambda expression, found keyword 'match'`

Round 32 的目标只有一个：

- 用 Zero-Block / Mandatory Helper Extraction 的暴力 Skill，彻底砍掉 `match` 分支块。

## 2. 本轮新增

### 2.1 新 Skill：`cangjie-match-helper-extraction-v1`

新增 `skills/cangjie-match-helper-extraction-v1.md`，焊死三条军规：

1. `=>` 后绝对禁止 `{}` 代码块；
2. `=>` 后绝对禁止 `let`；
3. 只要分支里操作数 > 1，必须抽 `private func handleXxx(...)` helper。

### 2.2 Prompt 最高优先级路由

修改 `scripts/prompt_assembler.py`：

- 当 repair guidance 同时出现：
  - `expected '=>' in lambda expression`
  - `found keyword 'let'` / `found keyword 'this'` / `found keyword 'match'`
  - 或显式 `case Some(...) => {` / `case _ => {`
- 就把 `cangjie-match-helper-extraction-v1` 推到最高优先级。

### 2.3 新 curated pattern

新增：`curated::service::match-helper-extraction::2026-03-30`

核心模式：

- `case Some(existing) => this.appendExistingMessages(...)`
- `case _ => this.seedMessageCache(...)`
- 所有可变逻辑离开 `match` 分支，集中到 private helper。

## 3. 关键结果

Round 32 最重要的变化不是 compile pass，而是：

- `attempt-01` 的候选已经不再使用 `case Some(...) => { ... }` 这种分支块；
- `attempt-05` / `attempt-07` 也开始出现 `handleSendMessageCache(...)`、`handleFetchMessages(...)` 这类 helper 风格；
- 这说明 Zero-Block / Helper Extraction 已经开始改变生成形态。

## 4. 本轮最终状态

最终结果仍为：`failed`

但 7 轮的形态和前几轮不同：

- `attempt-01`~`attempt-04`：主要被 `ArrayList` / `std.unsafe` 等静态墙回退拦截；
- `attempt-05`：重新进入真实 `compile-failed`，但模型仍在 helper 之外残留 `let` / `this` / 嵌套 `match` 分支块；
- `attempt-07`：再次进入真实 `compile-failed`，且出现了更深层的新错误：
  - `DateTime` 未导入导致 `undeclared identifier 'DateTime'`
  - 简化版 `DomainUser` / `DomainChannel` / `DomainMessage` struct 字段未初始化

## 5. 本轮最关键的真实收获

### 收获 1：`case => { ... }` 不再是唯一主形态

这轮已经看到候选明显转向：

- `case Some(existing) => this.messageCache.add(...)`
- `case _ => this.handleXxx(...)`
- `handleSendMessageCache(...)`
- `handleFetchMessages(...)`

说明 helper extraction Skill 已经开始对抗旧的 `match` 分支块惯性。

### 收获 2：新的主错误已经更深

在 `attempt-07` 中，最前面的 compile 错误不再是 `expected '=>' in lambda expression`，而是：

- `undeclared identifier 'DateTime'`
- struct 成员未初始化

这意味着：

- Zero-Block 路线正在生效；
- 系统已经开始触达下一层“真实 API / 数据模型初始化”问题。

### 收获 3：新问题边界被明确刻画

当前系统并非完全摆脱了 `match` 分支块问题，因为：

- `attempt-05` 仍有 `let newMessages = ...` 塞在 `case` 分支中；
- 某些轮次会在打掉分支块之后，又退回 `ArrayList` / `std.unsafe`。

但整体趋势已经从“纯粹死在 case 大括号里”前移到“helper 提取初步成功后，开始暴露 import / struct 初始化 / 默认值策略”的下一层错误。

## 6. 结论

Round 32 没有产出第一次 compile pass。

但它完成了一个很关键的任务：

- **Zero-Block / Mandatory Helper Extraction 已经开始改变候选生成分布。**

接下来最应该追的，不再是继续强调“不要写 `case => { ... }`”本身，而是：

1. 补一份 `struct init / field initialization / domain-model skeleton` 专项 Skill；
2. 补一份 `std.time import / DateTime usage` 的轻量 compile-safe 约束；
3. 把 `messageCache.add(key, Array<DomainMessage>(1, { _ => message }))` 也抽成 helper，避免在 `case` 里直接放构造表达式。
