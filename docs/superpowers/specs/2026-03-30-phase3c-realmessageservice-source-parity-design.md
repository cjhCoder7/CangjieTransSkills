# Phase 3C RealMessageService Source Parity Design

## 1. 设计目的

本设计不是继续优化 `Staging-Core` Harness 的内部能力，而是把 `RealMessageService` 从“行为已取证的验证壳”重新拉回“翻译产物”的主轨道：

- 对外 public API 必须回到 ArkTS 源码；
- V5 / V6 已验证通过的并发、缓存、Epoch、stale discard 机制继续保留；
- 但这些增强必须完全隐藏在 `private` / `internal` 内核下，不得污染未来仓颉版 Telegram 组件的调用心智。

## 2. 真理源

当前 `RealMessageService` 的 ArkTS 原版公开面以以下两处为绝对基线：

- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:74`
  - `getMessages(peerId: PeerId, limit: number): Signal<Message[]>`
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:111`
  - `sendMessage(params: SendMessageParams): Promise<Message>`

## 3. 当前偏差

当前 `Staging-Core` harness 中的公开面仍有两个明显偏差：

1. `getMessages(peerId, limit)` 当前直接返回 `Array<DomainMessage>`；
2. `sendMessage(peerId, text)` 当前仍是扁平双参数，而不是源侧的 `params` 形态。

对应位置：

- `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj:552`
- `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj:579`

## 4. 收口原则

### 4.1 Public 面只做最小等价映射

- `getMessages` 继续保留同名、同参数数量、同参数语义；
- `sendMessage` 必须收口为 `params` 形态；
- 返回值若因当前 Harness 现实无法一步到位对齐 ArkTS 的 `Signal` / `Promise`，也必须先朝“公开面 source parity”方向推进，而不是继续沿着当前验证壳自由生长。

### 4.2 内核增强继续保留，但必须下沉

以下能力仍然保留：

- `Mutex` 保护的 cache 读写；
- `Epoch` 世代推进；
- stale handoff discard；
- invalidate / force refresh 路径；
- No-Leak lock probe；
- strict observer log。

但这些能力在正式翻译收口后应满足：

- 对 UI / 调用方语义透明；
- 不再以 `debug*` 公开方法暴露；
- 测试若需继续取证，应改走 internal test seam 或 harness-only adapter，而非污染业务 API。

## 5. 本轮设计目标

本轮不直接做绿灯实现，只做两件事：

1. 落盘 source parity 设计与实施计划；
2. 通过红灯测试把“公开签名偏差”钉死在物理编译输出中。

## 6. 红灯测试目标

### 6.1 `getMessages` Source Parity 红灯

测试目标：当前 public `getMessages(peerId, limit)` 不应再把 `Array<DomainMessage>` 直接暴露给调用方；应至少朝“signal-like public shape”收口。

首轮红灯方式：

- 在测试中按 source parity 心智调用 `service.getMessages(peerId, 2)`；
- 立即要求其返回值提供 `currentSnapshot()` 等 signal-like 读取能力；
- 让当前实现因“返回 `Array` 而无此成员”触发编译红灯。

### 6.2 `sendMessage` Source Parity 红灯

测试目标：当前 public `sendMessage` 不应继续维持扁平 `peerId + text` 形态；应转向 `params` bag。

首轮红灯方式：

- 在测试中按源侧心智创建 `SendMessageParams(peerId, text)`；
- 直接调用 `service.sendMessage(params)`；
- 让当前实现因缺少 `SendMessageParams` / 签名不匹配而触发编译红灯。

## 7. 预期结果

一旦红灯成立，就意味着：

- 当前 `RealMessageService` 在行为上已足够强；
- 但在“翻译一致性 / public signature parity”上还没有完成收口；
- 下一轮实现应围绕 source parity 做接口收束，而不是继续扩写新的业务面。
