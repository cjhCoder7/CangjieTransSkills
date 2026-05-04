# Phase 3C RealMessageService Signal Runtime V10 Design

## 1. 设计目的

`V9` 已经把 `getMessages()` / `fetchMessages()` / `sendMessage()` 的 source semantics 收平到更接近 ArkTS 真理源的状态，但当前 `MessageSignal` 仍然只是一个“可读快照壳”：

- 它能提供 `currentSnapshot()`；
- 它能被 internal `replace()` 更新；
- 但它还缺少更像 `Signal<Message[]>` 的**持续实例 + 连续更新**运行时语义。

V10 采用你批准的 **方案 A**：

- **先收平 `Signal<Message[]>` 的运行时行为**；
- **不新增任何未经 source 证明的 public API 名字**；
- 所有更真实的 runtime seam 只停留在同包内部可见，供 Staging-Core harness 取证。

## 2. 真理源

当前能确认的 source 事实只有这些：

- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:74`
  - `getMessages(peerId: PeerId, limit: number): Signal<Message[]>`
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:77`
  - 首次创建 signal 时使用 `new ValueSignal<Message[]>(...)`
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:107`
  - `fetchMessages()` 完成后对现有 signal 执行 `.set(messages)`
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:127`
  - `sendMessage()` 完成后对现有 signal 执行 `.set(updatedCache)`

因此，V10 不能凭空发明 public `subscribe()` / `watch()` / `effect()` 名字；
但可以合理收平如下运行时心智：

1. 同一个 `peerId` 对应的 signal 实例在未失效前应持续复用；
2. `fetchMessages()` / `sendMessage()` 应该推动同一实例持续更新；
3. signal 的更新次序应可被内部 runtime seam 观察与验证；
4. invalidate 后旧 signal 应被摘除，后续更新不得再穿透到旧实例。

## 3. 当前偏差

### 3.1 持续实例语义缺少显式证据

虽然 V9 已经让 `getMessages()` 按 `messageSignals` 复用已有实例，但当前没有测试直接证明：

- 同一个 `peerId` 的 signal 在 invalidation 前后是否真的“同一实例 / 新实例”切换；
- V6 Double Fetch 与 invalidate 之后，旧 signal 是否真的被摘除。

### 3.2 连续更新语义缺少显式证据

当前 `MessageSignal` 没有内部观察 seam，导致我们只能从 `currentSnapshot()` 的结果反推：

- fetch 更新过它；
- send 更新过它。

但还没有直接证据说明：

- 更新版本号是单调推进的；
- 同一 signal 在 fetch 之后、send 之后是连续更新，而不是“换了个壳”。

## 4. 采纳方案（A）

### 4.1 公开面不加戏

继续保持：

- `MessageSignal` 的 public 面只保留当前 source-aligned 外壳；
- `scripts/phase3_source_alignment_asserts.py` 继续卡死 public whitelist；
- V10 不新增任何新的 public 方法名。

### 4.2 internal runtime seam 最小补齐

在 `MessageSignal` 内新增 **同包内部可见** 的 runtime seam：

- `runtimeId()`：标识 signal 实例身份；
- `updateVersion()`：标识该 signal 已被更新了多少次；
- `observeRuntime(observer)`：让 harness 测试能记录后续更新事件。

这些 seam 的目标不是对外开放，而是让我们能在 Linux `Staging-Core` 环境里，证明 V10 的 signal 行为真的更接近 source。

### 4.3 observer 实现原则

- observer 只用于 harness 内部；
- callback 必须在锁外触发，避免 observer 回读 `currentSnapshot()` 时与 `replace()` 自锁；
- invalidate 后旧 signal 不应再接收新更新。

## 5. 测试目标

### 5.1 signal 复用与替换

- 同一 `peerId` 在 invalidation 前两次 `getMessages()` 必须返回同一个 runtimeId；
- `debugInvalidateCache(peerId)` 后，新一次 `getMessages()` 必须返回新的 runtimeId。

### 5.2 单调更新版本

- 首次 fetch 完成后，signal 的 `updateVersion()` 至少推进到 `1`；
- 后续 `sendMessage(params)` 再次更新该 signal 时，版本号必须继续单调增加；
- runtime observer 必须看到与版本推进一致的事件。

### 5.3 invalidate 摘除旧 signal

- old signal 上挂的 runtime observer，在 invalidate + new signal + send 之后，不得再看到新事件；
- new signal 的 runtime observer 必须能看到后续 send 更新。

## 6. 风险与边界

- 我们仍然没有 `@ohos/signalkit` 的精确订阅 API 文档，因此 V10 的 observer seam 必须严格停留在 internal；
- 本轮只收平运行时语义，不尝试 public API 级别的订阅接口还原；
- 若未来拿到 `SignalKit` 官方接口，再决定是否把 internal seam 收敛到更贴近官方命名的桥接层。

## 7. 验收口径

V10 完成需同时满足：

1. 新增 V10 runtime 红灯测试先失败后转绿；
2. `scripts/phase3_source_alignment_asserts.py` 继续通过，证明 V10 没污染 public 面；
3. `samples/real-message-service-cache-001` 全量 `cjpm test` 通过；
4. `timeout 5s` 熔断验证通过；
5. 文档中新增 V10 runtime 级契约与证据回写。
