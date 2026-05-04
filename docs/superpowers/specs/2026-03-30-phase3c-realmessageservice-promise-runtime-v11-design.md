# Phase 3C RealMessageService Promise Runtime V11 Design

## 1. 设计目的

`V10` 已经把 `Signal<Message[]>` 的实例复用、版本推进与 invalidate 摘除语义收平，但 `RealMessageService` 仍有一个明显的 source gap：

- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:86` 的 `fetchMessages(params)` 是 `Promise<Message[]>`；
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:111` 的 `sendMessage(params)` 是 `Promise<Message>`；
- 当前 Staging-Core harness 仍然把这两条链路压成了“同步调用立即完成”。

这会导致一个失真：`getMessages()` 创建 signal 后，仓颉样本会立刻把 fetch 结果写入 cache / signal，而不是先暴露已有 snapshot、再在 Promise resolve 时回流。

V11 的目标不是发明新的 public Promise API，而是在 **不污染 public surface** 的前提下，把 Promise 的最小运行时边界补出来。

## 2. 真理源

本轮继续以以下 source 片段为绝对真理：

- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:74`
  - `getMessages(peerId: PeerId, limit: number): Signal<Message[]>`
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:86`
  - `async fetchMessages(params: GetHistoryParams): Promise<Message[]>`
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:107`
  - fetch resolve 后执行 `this.messageSignals.get(cacheKey)?.set(messages)`
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:111`
  - `async sendMessage(params: SendMessageParams): Promise<Message>`
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:127`
  - send resolve 后执行 `this.messageSignals.get(key)?.set(...)`

## 3. 当前偏差

### 3.1 fetch 回流过早

当前 harness 在 `getMessages()` 首次创建 signal 时，会同步调用 `fetchMessages()` 并立刻写入：

- `messageCache`
- `messageSignals`
- UI refresh bridge

这使得 `getMessages()` 返回后的首帧 snapshot 已经是远端 fetch 结果，不再保留 ArkTS 源侧“先返回 signal，再等待 Promise 回流”的心理模型。

### 3.2 send Promise 无法一步到位暴露

由于当前仓颉样本的 public `sendMessage(params)` 仍返回 `DomainMessage`，我们这轮不能冒进地发明新的 public Promise 类型；否则会直接撕裂 `BCM-ALIGN-001` / `BCM-ALIGN-002` 已固化的 public 契约。

因此 V11 采用分层收口：

- 对 `Promise<Message[]>`：补真实的 pending -> drain -> settle 运行时边界；
- 对 `Promise<Message>`：先补 internal settlement trace，不破坏 V9 的 optimistic signal contract。

## 4. 采纳方案

### 4.1 fetch 走 internal Promise drain 队列（推荐）

在 `RealMessageService` 内新增 package-local Promise resolution queue：

- `fetchMessages(params)` 仍立即调用 adapter，保持 source 侧“请求已发起”的心智；
- 但 fetch 结果不再立刻写 cache / signal；
- 而是进入 `pendingPromiseResolutions`；
- 只有显式执行 `debugDrainPromiseResolutions()` 时，才真正 apply：
  - `messageCache[key] = messages`
  - `messageSignals[key].replace(messages)`
  - `publishDatasetChanged(...)`

这样，`getMessages()` 返回后的 signal 可以先暴露 seeded snapshot；Promise drain 之后，再看到远端消息回流。

### 4.2 send 保持 V9 可见语义，补 internal Promise trace

为了不打穿 `BCM-ASYNC-007`：

- `sendMessage(params)` 仍保持“signal 先更新、UI 后 main drain”的 V9 合同；
- 但内部新增 `promise:queued:send:*` 与 `promise:settled:send:*` trace；
- 让我们至少能在 Staging-Core 中证明：
  - send 路径已经被纳入 Promise runtime 账本；
  - 但本轮不改变 public / visible behavior。

## 5. 测试目标

### 5.1 fetch Promise 边界

新增红灯断言：

1. `getMessages()` 首次创建 signal 且本地 cache 已有 seed 时：
   - Promise drain 前，signal snapshot 必须仍是 local seed；
   - Promise drain 后，signal snapshot 才切到远端 fetch 结果。
2. Promise drain 前，不得提前向 UI bridge 排队 refresh；
3. Promise drain 后，才允许出现 `refresh:queued:*`。

### 5.2 send Promise trace 收口

新增红灯断言：

- `sendMessage(params)` 后：
  - signal 仍需保持 V9 optimistic update；
  - `debugThreadLog()` 中必须同时存在 `promise:queued:send:*` 与 `promise:settled:send:*` 证据。

## 6. 风险与边界

- 本轮不新增任何新的 public type / public method；
- 本轮不尝试把 `sendMessage(params)` 的 public 返回值改成 Promise-like 壳；
- `debugDrainPromiseResolutions()` 仅作为 harness/internal seam 存在，用于 Linux `Staging-Core` 物理取证；
- invalidate 时必须同步清理同 peer 的 pending Promise resolution，避免旧 fetch 在 drain 后回魂污染新 signal。

## 7. 验收口径

V11 完成需同时满足：

1. V11 Promise runtime 红灯先失败后转绿；
2. `scripts/phase3_source_alignment_asserts.py` 继续通过；
3. 现有 22 条回归测试在适配 Promise drain 后继续通过；
4. 全量 `cjpm test` 通过；
5. `timeout 5s` 熔断验证继续通过；
6. 契约矩阵与执行轨迹补齐 V11 证据。
