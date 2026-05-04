# Phase 3C RealMessageService Source Semantics V9 Design

## 1. 设计目的

`V7` 和 `V8` 已经把 `RealMessageService` 的 **public surface** 收口到 ArkTS 真理源附近，但还剩下一层更深的偏差：

- `messageSignals` 的生命周期还没有完全按 ArkTS 心智运行；
- `fetchMessages` 仍是 `peerId + limit` 扁平签名，而不是 source 侧的内部 `params bag`；
- `sendMessage(params)` 虽已收口 public 签名，但“乐观 signal 更新先于 UI drain”还缺少显式语义断言。

因此，`V9` 的目标不是再设计新 API，而是把 `messageSignals / fetchMessages / sendMessage` 这三块 source semantics 收平到更接近 `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets` 的状态。

> 本轮范围已由用户明确批准直接执行：设计落盘后立即进入红灯与绿灯，不再额外等待实现授权。

## 2. 真理源

当前 V9 的唯一真理源仍是：

- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:74`
  - `getMessages(peerId: PeerId, limit: number): Signal<Message[]>`
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:86`
  - `async fetchMessages(params: GetHistoryParams): Promise<Message[]>`
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:111`
  - `async sendMessage(params: SendMessageParams): Promise<Message>`

关键 source semantics：

1. `getMessages` 的第一职责是“拿到 / 复用 signal”；
2. `fetchMessages` 是内部 dirty-work 方法，接收 `params bag`；
3. 首次创建 signal 时，无论 cache 是否已有内容，都会继续触发一次 fetch；
4. `sendMessage(params)` 成功后，会更新 `messageCache`，并把现有 signal 同步到最新快照。

## 3. 当前偏差

### 3.1 `messageSignals` 生命周期偏差

当前 harness 的 `getMessages(peerId, limit)` 只有在 **cache miss** 时才触发 fetch：

- 若 `messageCache` 已有内容但 `messageSignals` 尚未建立，当前实现会直接返回 seeded signal，**不会再 fetch**；
- 这与 ArkTS 源侧“首次创建 signal 就 fetch 一次”的心智不一致。

### 3.2 `fetchMessages` 内部签名偏差

当前 harness 仍使用：

- `private func fetchMessages(peerId: PeerId, limit: Int32): Array<DomainMessage>`

而 source 侧是：

- `async fetchMessages(params: GetHistoryParams): Promise<Message[]>`

在 Staging-Core 中我们不强求一步到位复刻 `Promise`，但至少要把“内部 params bag”这一层 source semantics 对齐回来。

### 3.3 `sendMessage` 乐观更新缺少显式断言

当前实现实际上已经会：

1. 更新 cache；
2. 刷新 signal snapshot；
3. 再走 mock UI bridge 排队。

这意味着它具备“signal 先变、UI 后 drain”的乐观更新语义。但这条关键行为目前缺少独立测试守护，未来回归风险偏高。

## 4. 方案比较

### 方案 A：最小 source semantics 收平（推荐）

动作：

- 引入 package-local `GetHistoryParams`；
- 把 `fetchMessages` 改为 `private func fetchMessages(params: GetHistoryParams)`；
- 把 `getMessages` 的 fetch 触发条件从“cache miss”改为“signal first-create”；
- 用一条运行时红灯测试钉住“cache 已有值但 signal 首次创建仍必须 fetch”；
- 再补一条 `sendMessage` 乐观 signal 更新测试守护。

优点：

- 严格围绕 source semantics，不引入新的 public API；
- 改动小，不会破坏 V5/V6/V7 的并发证据结构；
- 与当前 Linux `Staging-Core` 的同步 harness 能力兼容。

代价：

- 仍然没有完整复刻 ArkTS `Signal` / `Promise` 的异步运行时；
- “先返回 seeded signal，再异步 refresh”的真实时间语义，仍只能近似模拟。

### 方案 B：完整模拟 ArkTS `Signal/Promise` 运行时

动作：

- 为 `MessageSignal` 引入订阅器列表、异步调度、事件派发；
- 为 `fetchMessages` / `sendMessage` 引入 Promise-like 包装；
- 让 `getMessages` 返回后真正先暴露旧 snapshot，再异步刷新。

优点：

- 最接近 source 的运行时语义。

代价：

- 明显超出本轮需要；
- 会把当前 Staging-Core harness 变成一套新的事件系统，偏离“翻译验证”主线。

### 方案 C：只补文档，不改行为

优点：

- 快。

代价：

- 没有真正把 source semantics 钉进代码；
- 会继续保留“cache seeded but no signal”这一处明显偏差。

## 5. 采纳决策

采纳 **方案 A**。

### 5.1 `messageSignals` 收口决策

- `messageSignals` 继续由 `cacheLock + HashMap` 保护；
- `getMessages` 必须以“是否已有 signal”为唯一生命周期分支；
- 若 signal 不存在：
  - 用现有 cache 作为初始快照创建 signal；
  - 立即触发一次 `fetchMessages(GetHistoryParams(...))`；
- 若 signal 已存在：
  - 直接复用，不因 `limit` 改变而再次 fetch。

### 5.2 `fetchMessages` 收口决策

- 新增 package-local `GetHistoryParams(peerId, limit)`；
- `fetchMessages` 改成 private/internal params bag 入口；
- public `getMessages` 不再直接操纵 adapter，而是统一委托给 `fetchMessages(params)`。

### 5.3 `sendMessage` 收口决策

- `sendMessage(params)` 保持当前 public 形态；
- 继续先改 cache / signal，再 publish 到 UI bridge；
- 新增测试明确钉住“signal 更新早于 main drain”的乐观语义；
- 不新增任何新的 public facade。

## 6. 测试设计

### 6.1 红灯 1：首次 signal 创建必须 fetch，即使 cache 已预热

测试场景：

1. 先通过 `sendMessage(params)` 在本地 seed cache；
2. 再第一次调用 `getMessages(peerId, limit)`；
3. 断言：`adapter.getHistoryCallCount()` 必须从 `0` 变为 `1`。

当前实现预期失败原因：

- 现有逻辑以 `hasCache` 为准，不会在 cache 已存在时触发第一次 fetch。

### 6.2 红灯 2：内部 fetch 入口必须是 params bag

采用静态 fitness function，而不是新的 public 测试：

- 新增 `scripts/phase3_source_semantics_asserts.py`；
- 断言 harness 中存在 `private func fetchMessages(params: GetHistoryParams)`；
- 断言旧的 `fetchMessages(peerId, limit)` 已消失；
- 断言 `GetHistoryParams` 不是 public type。

### 6.3 绿灯守护：sendMessage 乐观 signal 更新

测试场景：

1. 先 warmup 创建 signal；
2. 记录该 signal；
3. worker 调用 `sendMessage(params)`；
4. 在 `main drain` 之前直接读取 signal snapshot；
5. 断言 signal 已包含新消息，而 observer 还未收到新的 UI delivery。

## 7. 风险与边界

- 本轮仍不尝试完整模拟 ArkTS `Promise`；
- 本轮的“首次 signal 创建会 fetch”仍然在同步 harness 中执行，因此返回后的 snapshot 可能已经被 fetch 刷新，这是 Staging-Core 的已知降维现实；
- 只要 public API 不发明新心智，且 V5/V6/V7 不回归，这种降维在本阶段可接受。

## 8. 验收口径

V9 完成需同时满足：

1. `scripts/phase3_source_semantics_asserts.py` 通过；
2. 新增 V9 红灯测试转绿；
3. `samples/real-message-service-cache-001` 全量 `cjpm test` 继续 `17+` 全绿；
4. `timeout 5s` 熔断验证通过；
5. `BCM-ALIGN-001`、`BCM-ALIGN-002` 保持通过，并新增本轮 source semantics 取证记录。
