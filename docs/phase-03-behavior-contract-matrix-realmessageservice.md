# Phase 03 行为契约矩阵：RealMessageService

## 1. 文档定位

- `目标模块`：`RealMessageService.ets`
- `当前仓颉候选`：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-041-round42-freeze-anchor-repair/temp_workspace/20260330T111005Z-tu-041-round42-freeze-anchor-repair-src-services-realmessageservice.ets/attempt-06/src/services/RealMessageService.cj`
- `源侧参考`：`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`
- `当前阶段坐标`：`Phase 3B passed / Phase 3C active`
- `本文目标`：把 `RealMessageService` 从“已编译通过的候选代码”推进为“具备最小语义闭环证据的服务模块”

本文件不是新的叙述性路线图，而是 `Phase 3C` 的执行型约束文档。
所有后续单测、dry-run、行为验证、日志采集，都应优先对齐本文中的 `Behavior Contract` 与 `Hard Assert`。

---

## 2. 当前真实坐标

### 2.1 已经拿到的证据

- `Phase 3B` 物理编译通过证据已经存在；权威结果见：
  - `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-041-round42-freeze-anchor-repair/summary.json`
  - `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-041-round42-freeze-anchor-repair/realmessageservice-ets.orchestration.json`
- 当前候选已经通过了：
  - 静态墙；
  - Reviewer；
  - 真实 `verify compile`。

### 2.2 仍然缺失的证据

当前候选虽然能编，但还没有证明以下事实：

1. `messageCache` 的刷新行为与源侧一致；
2. 异步 / 回调 / UI 边界是否仍然保持“纯 Domain Message 输出”；
3. 在仓颉并发模型下，状态写入是否无脏读、无竞态、无主线程阻塞。

### 2.3 当前候选的语义风险概览

对比源侧 `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:74` 与候选 `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-041-round42-freeze-anchor-repair/temp_workspace/20260330T111005Z-tu-041-round42-freeze-anchor-repair-src-services-realmessageservice.ets/attempt-06/src/services/RealMessageService.cj:70`，当前候选存在以下语义压缩：

- 源侧 `getMessages()` 返回 `Signal<Message[]>`，候选变为直接返回 `Array<DomainMessage>`；
- 源侧 `fetchMessages()` / `sendMessage()` 为 `async`，候选变为同步 `adapter` 调用；
- 源侧存在 `TLDeserializer(response)` 与二进制 transport 边界，候选只保留 `IMTProtoAdapter` 抽象接口；
- 源侧借助 `SignalPipe` 向 UI 推送缓存刷新，候选暂未保留显式回调 / 推送通道；
- 候选中没有任何锁、互斥器或线程约束表达，因此“不会死锁”不等于“并发安全已被证明”。

结论：

> 当前代码已经是 `骨骼完整的可编译候选`，但尚未取得 `Phase 3C` 需要的行为级证据。

---

## 3. Phase 3C 的验证边界

本轮建议采用两层口径：

### 3.1 `Phase 3C Conditional Pass`

允许在 **无模拟器 / 无真机 / 无完整 Harmony runtime 权限** 的前提下，先证明以下三类语义边界：

- 状态机与缓存刷新；
- 异步 / 回调隔离后的领域纯洁度；
- 并发访问下的最小线程安全假设。

### 3.2 `Phase 3C Full Pass`

在 `Conditional Pass` 基础上，再补以下真实运行证据：

- Harmony 模拟器或真机上的页面 / 功能可达；
- UI 层确实收到正确的消息列表刷新；
- 线程调度与日志证据可回放；
- 若存在系统能力或插件依赖，其权限状态已明确记录。

---

## 4. 行为契约总表

| Contract ID | 契约主题 | 硬性断言 | 当前候选覆盖情况 | 当前判定 |
|---|---|---|---|---|
| `BCM-STATE-001` | 首次拉取刷新缓存 | `fetch/getHistory` 返回后，`messageCache[key]` 必须被刷新为最新列表 | 候选在 `fetchMessages()` 中有写缓存逻辑，且 `包 A` 已断言通过 | `已验证通过` |
| `BCM-STATE-002` | 发送后追加缓存 | `sendMessage` 成功后，缓存尾部必须追加新消息，而不是覆盖旧列表 | 候选在 `appendMessageToCache()` 中有追加逻辑，且 `包 A` 已断言通过 | `已验证通过` |
| `BCM-STATE-003` | 无死锁 / 无脏读 | 多次并发读写下，不能卡死，不能读到半更新状态 | 真实候选无原生证据；`包 C` 已用 worker warmup + `48 send / 32 read` 压测补齐 harness 级证据 | `已验证通过（harness 压测）` |
| `BCM-STATE-006` | Force Refresh 缓存击穿 | `debugInvalidateCache(peerId)` 必须在抢占 cache 写锁后清空对应 peer 缓存、驱逐同 peer 的旧 signal，并显式推高 bridge epoch | `包 V6 + V9` 已证明 invalidate 会清空 cache、驱逐旧 signal，使下一次 `getMessages()` 重新走首次 signal fetch 路径，且 `debugInvalidateCache` 返回的 epoch 严格大于失效前 epoch | `已验证通过（Double Fetch invalidation + V9 signal evict）` |
| `BCM-STATE-007` | Invalidate Detaches Old Signal Instance | `debugInvalidateCache(peerId)` 之后，旧 signal 实例不得再接收后续 fetch / send 更新；后续更新必须只流向新 signal | `包 V10` 已用 `invalidateShouldDetachOldSignalFromFutureUpdates` 证明：old signal observer 保持 `0` 次更新，而 new signal observer 能看到 post-invalidate send | `已验证通过（V10 signal detach）` |
| `BCM-ASYNC-001` | Transport 边界封口 | 底层 transport / bytes 只能停留在 Adapter 层，Service / UI 不得泄漏 `Array<UInt8>` | 公开签名白名单与 import 白名单已对真实候选和包 B harness 扫描通过 | `已验证通过（静态边界）` |
| `BCM-ASYNC-002` | 领域模型纯输出 | Service 对外只能暴露 `DomainMessage` 或 `Array<DomainMessage>`，不得回吐 TL* / bytes | 包 B 的 DTO Conversion Wall 已用恶意 TLMessage 输入做反向断言并通过 | `已验证通过（harness 证据）` |
| `BCM-ASYNC-003` | UI 刷新路径语义保持 | 源侧“拉历史 / 发消息后触发 UI 可见刷新”的语义必须保留 | `包 UI` 已用 `MockUiDatasetObserver + MainContextDatasetRefreshBridge` 证明“worker 只排队、main drain 后才交付 UI 刷新” | `已验证通过（Conditional Pass / mock UI）` |
| `BCM-ASYNC-005` | 过期 handoff 丢弃 | 更高 epoch 的数据已交付后，旧 handoff 必须在进入 UI 前被明确 discard | `包 V5` 已用 `delayed queue + MutexEpochRegister` 证明 “A delayed fetch / B immediate send” 下 UI 最终只收到 B，且保留 stale discard log | `已验证通过（V5 delayed handoff）` |
| `BCM-ASYNC-006` | Strict Stale-Read Observer Log | 在 `A delayed fetch / B force-refresh fetch` 下，`MockUiDatasetObserver` 的 delivery log 中只允许出现 B payload，A 不得留下任何幽灵交付 | `包 V6` 已用 observer delivery log 严格断言证明 UI 层唯一生效载荷来自 `worker-force-refresh-B` | `已验证通过（Double Fetch strict observer log）` |
| `BCM-ASYNC-007` | Optimistic Signal Update Before UI Drain | `sendMessage(params)` 成功后，现有 signal 的 snapshot 必须先更新，UI observer 仍需等到 `main drain` 才收到新的可见交付 | `包 V9` 已用 `sendMessageShouldOptimisticallyUpdateExistingSignalBeforeUiDrain` 证明：signal 在 `main drain` 前已看到新消息，而 observer 仍保持上一轮 delivery 次数 | `已验证通过（V9 optimistic signal update）` |
| `BCM-ASYNC-008` | Signal Runtime Version Monotonicity | 同一 signal 实例在 fetch / send 更新过程中，其内部更新版本必须单调推进，且 runtime observer 看到的版本不得回退 | `包 V10` 已用 `signalVersionShouldAdvanceMonotonicallyAcrossFetchAndSend` 证明：首次 fetch 后 version=`1`，随后 send 推进到 version=`2`，observer 同步看到最后版本 `2` | `已验证通过（V10 signal versioning）` |
| `BCM-ASYNC-009` | Fetch Promise Drain Boundary | `getMessages()` 首次创建 signal 后，Promise drain 前只能暴露 seeded / current snapshot，不得提前写 cache / signal / UI refresh；只有 drain 后才允许远端 fetch 结果回流 | `包 V11` 已用 `getMessagesShouldExposeSeededSnapshotBeforeFetchPromiseDrain` 与 `fetchPromiseDrainShouldQueueUiRefreshOnlyAfterResolution` 证明：drain 前 signal 仍停留在 local seed / empty snapshot，bridge `pendingRefreshCount()==0`；drain 后 signal 切换到远端历史并开始排队 UI refresh | `已验证通过（V11 fetch promise boundary）` |
| `BCM-ASYNC-010` | Collapsed Send Promise Settlement Trace | 在当前同步 façade 约束下，`sendMessage(params)` 必须保持 V9 的 optimistic signal update，同时在 internal trace 中显式留下 `promise:queued:send` 与 `promise:settled:send` 证据 | `包 V11` 已用 `sendMessageShouldKeepOptimisticSignalContractAndLeavePromiseSettlementTrace` 证明：signal 仍先于 UI drain 更新，且 `debugThreadLog()` 同时包含 queued / settled send promise trace | `已验证通过（V11 send promise trace）` |
| `BCM-ALIGN-001` | Signature Parity | 仓颉版 `getMessages` 与 `sendMessage` 的参数数量、类型含义必须与 ArkTS 原版 `1:1` 对应 | `包 V7` 已用 source parity 红绿测试证明：`getMessages(peerId, limit)` 保持同名同义并暴露 signal-like public shape，`sendMessage` 已收口为 `SendMessageParams` bag | `已验证通过（V7 public parity）` |
| `BCM-ALIGN-002` | Encapsulated Enhancement | `Epoch`、锁机制、缓存击穿等增强能力不得改变 ArkTS 原有业务调用心智，必须被封装在 `private` / `internal` 作用域下 | `包 V8` 已新增 `scripts/phase3_source_alignment_asserts.py` 固化 public whitelist，并把 `debug*`、`attachRefreshBridge`、bridge / adapter scaffolding 收回到同包内部可见；当前 public 面仅保留 `PeerId`、`DomainMessage`、`SendMessageParams`、`MessageSignal`、`RealMessageService` | `已验证通过（V8 public surface encapsulation）` |
| `BCM-ALIGN-003` | First Signal Fetch Parity | 第一次为某个 `peerId` 创建 signal 时，即使 cache 已预热，也必须继续触发一次 fetch；后续复用同一 signal 时才允许不 refetch | `包 V9` 已用 `firstSignalCreationShouldFetchEvenWhenCacheAlreadySeeded` 证明：本地 seed cache 后第一次 `getMessages()` 仍会调用 `adapter.getHistory()`，而后续 signal reuse 保持不 refetch | `已验证通过（V9 first signal fetch parity）` |
| `BCM-ALIGN-004` | Internal Fetch Params Bag | `fetchMessages` 必须停留在 `private` / `internal` 层，并使用 `GetHistoryParams` 这种 source-aligned params bag，而不是扁平 `peerId + limit` | `包 V9` 已新增 `scripts/phase3_source_semantics_asserts.py`，静态证明 `GetHistoryParams` 存在、不是 public type，且旧的 `fetchMessages(peerId, limit)` 已消失 | `已验证通过（V9 internal fetch semantics）` |
| `BCM-ALIGN-005` | Signal Instance Reuse Parity | 同一 `peerId` 在 signal 未失效前必须复用同一 signal 实例；只有 invalidation 后才允许切换到新实例 | `包 V10` 已用 `samePeerShouldReuseSignalInstanceUntilInvalidation` 证明：两次 `getMessages()` 共享同一 `runtimeId`，invalidate 后才切换到新 `runtimeId` | `已验证通过（V10 signal identity）` |
| `BCM-CONC-001` | 非主线程执行 | 网络 / adapter 路径不得在主线程长时间阻塞完成 | 真实候选没有线程证据；`包 C` 通过 `ThreadLocal<String>` worker 标签和 trace log 给出 harness 级证据 | `已验证通过（Conditional Pass / harness）` |
| `BCM-CONC-002` | 共享状态串行化 | 共享 Map 的修改必须具备可解释的串行化策略 | 真实候选无并发策略表达；`包 C` 的 `RealMessageService` harness 已显式使用 `Mutex` 串行化缓存写入 | `已验证通过（Mutex 串行化）` |
| `BCM-CONC-003` | 并发下结果稳定 | 并发 `getMessages` + `sendMessage` 后缓存结果应稳定、可重复 | `包 C` 在 worker warmup 后执行 `48` 个 send worker 与 `32` 个 read worker，最终 cache size 稳定为 `50` 且 burst 消息无丢失 | `已验证通过（压力证据）` |
| `BCM-CONC-005` | 中断后锁无泄漏 | interruption 结束后，`messageCache` 写锁必须可在预算内重新获取，且整套测试不得死锁 | `包 V5` 已用 `debugAcquireCacheWriteLockWithin(50)` + 外层 `timeout 5s` 证明 lock probe 可再次拿锁且 `cjpm test` 不挂死 | `已验证通过（lock probe + timeout 熔断）` |

---

## 5. 三大语义边界与翻译一致性的硬性断言

## 5.1 状态机与缓存刷新（State & Cache）

### 5.1.1 源侧真实语义

源侧在以下位置明确定义了缓存刷新行为：

- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:105`
  - `fetchMessages()` 完成后执行 `this.messageCache.set(cacheKey, messages)`；
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:124`
  - `sendMessage()` 成功后执行 `this.messageCache.set(key, [...existing, message])`；
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:107`
  - 如果存在 `SignalPipe`，还要继续 `set(messages)` 推给 UI。

### 5.1.2 当前候选对应点

- `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-041-round42-freeze-anchor-repair/temp_workspace/20260330T111005Z-tu-041-round42-freeze-anchor-repair-src-services-realmessageservice.ets/attempt-06/src/services/RealMessageService.cj:78`
  - `fetchMessages()` 调用 `adapter.getHistory()` 后写缓存；
- `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-041-round42-freeze-anchor-repair/temp_workspace/20260330T111005Z-tu-041-round42-freeze-anchor-repair-src-services-realmessageservice.ets/attempt-06/src/services/RealMessageService.cj:84`
  - `sendMessage()` 调用 `adapter.sendMessage()` 后追加缓存；
- `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-041-round42-freeze-anchor-repair/temp_workspace/20260330T111005Z-tu-041-round42-freeze-anchor-repair-src-services-realmessageservice.ets/attempt-06/src/services/RealMessageService.cj:98`
  - `appendMessageToCache()` 负责命中新旧缓存分支。

### 5.1.3 硬性断言

- `ASSERT BCM-STATE-001`：首次 `getMessages(peerId, limit)` 未命中缓存时，必须调用 `adapter.getHistory()`，并把返回值完整写入 `messageCache[key]`。
- `ASSERT BCM-STATE-002`：随后再次 `getMessages(peerId, limit)` 命中缓存时，不得再次调用 `adapter.getHistory()`。
- `ASSERT BCM-STATE-003`：`sendMessage(peerId, text)` 成功后，`messageCache[key]` 的长度必须增加 `1`，且尾部消息必须与返回消息一致。
- `ASSERT BCM-STATE-004`：若 `sendMessage()` 在空缓存下执行，必须自动初始化新缓存，而不是丢失首条消息。
- `ASSERT BCM-STATE-005`：若并发读写发生，不能出现“长度已增加但尾部对象为空 / 默认值 / 半初始化”的脏读迹象。
- `ASSERT BCM-STATE-006`：`debugInvalidateCache(peerId)` 必须先抢占 `messageCache` 写锁，删除该 `peerId` 的缓存，并驱逐已存在的 signal，再显式推动 bridge epoch 前进；否则 Double Fetch 下既没有可信代际边界，也无法重新进入 source-aligned 的首次 signal fetch 路径。

### 5.1.4 本轮建议验证方式

- 构造 `FakeAdapter`，可编程返回固定 `Array<DomainMessage>` 与单条 `DomainMessage`；
- 先执行 `cacheUsers` / `cacheChannels` 准备数据；
- 对同一 `PeerId` 执行：
  1. 首次 `getMessages()`；
  2. 再次 `getMessages()`；
  3. `sendMessage()`；
  4. 第三次 `getMessages()`；
- 在每一步记录：
  - adapter 调用次数；
  - `messageCache[key]` 长度；
  - 最后一条消息 `id/text/peerId`。

### 5.1.5 当前判定

已执行 `包 A：缓存行为验证`，权威证据见：

- `samples/real-message-service-cache-001`
- `artifacts/behavior_runs/phase03-package-a-cache-harness/summary.json`
- `artifacts/behavior_runs/phase03-package-a-cache-harness/cjpm-test.log`

本轮已被测试断言直接覆盖并通过的契约：

- `BCM-STATE-001`：首次读取会触发一次 `adapter.getHistory` 并写入缓存；
- `BCM-STATE-002`：第二次读取命中缓存，不会重复拉取；
- `BCM-STATE-003`：已有缓存时 `sendMessage` 会把新消息追加到尾部；
- `BCM-STATE-004`：空缓存时 `sendMessage` 会自动播种单条缓存。
- `BCM-STATE-006`：Double Fetch 变体中 `debugInvalidateCache` 会清空指定 `peerId` 的 cache、驱逐旧 signal，并返回严格大于失效前的 forced epoch。

`包 A` 自身未覆盖的风险曾包括：无死锁、无脏读、并发交错下的状态一致性。

但这些缺口已在 `包 C` 中补充取证，权威结果见：

- `artifacts/behavior_runs/phase03-package-c-concurrency/summary.json`
- `artifacts/behavior_runs/phase03-package-c-concurrency/cjpm-test.log`

结论：`State & Cache` 已从“纸面成立”推进到“`BCM-STATE-001 ~ 006` 已具备自动化行为证据”，其中 `BCM-STATE-005` 由 `包 C` 的并发压测补齐，`BCM-STATE-006` 由 `包 V6 + V9` 的 Double Fetch invalidation / signal-evict 收口共同补齐。

---

## 5.2 异步回调隔离（Async / Callback Boundary）

### 5.2.1 源侧真实语义

源侧的关键路径是：

`transport bytes -> TLDeserializer -> Message -> messageCache -> SignalPipe -> UI`

对应位置：

- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:91`
  - `client.sendRequest(request.toBytes())` 返回底层 bytes；
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:92`
  - `TLDeserializer(response)` 在服务内部解析；
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:136`
  - 对外暴露的是 `Message` 领域对象；
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:107`
  - UI 更新通过 `SignalPipe` 完成。

### 5.2.2 当前候选对应点

当前候选将边界收敛为：

`IMTProtoAdapter -> DomainMessage -> messageCache`

对应位置：

- `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-041-round42-freeze-anchor-repair/temp_workspace/20260330T111005Z-tu-041-round42-freeze-anchor-repair-src-services-realmessageservice.ets/attempt-06/src/services/RealMessageService.cj:42`
  - `IMTProtoAdapter` 直接返回 `DomainMessage` / `Array<DomainMessage>`；
- `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-041-round42-freeze-anchor-repair/temp_workspace/20260330T111005Z-tu-041-round42-freeze-anchor-repair-src-services-realmessageservice.ets/attempt-06/src/services/RealMessageService.cj:78`
  - `fetchMessages()` 只接触领域对象；
- `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-041-round42-freeze-anchor-repair/temp_workspace/20260330T111005Z-tu-041-round42-freeze-anchor-repair-src-services-realmessageservice.ets/attempt-06/src/services/RealMessageService.cj:84`
  - `sendMessage()` 只接触领域对象。

### 5.2.3 硬性断言

- `ASSERT BCM-ASYNC-001`：Service 对外接口及缓存中，不得出现 `Array<UInt8>`、`Vector<UInt8>`、`TLDeserializer`、`TL*`、`InputPeer`、`sendRequest(...)` 等底层 transport 痕迹。
- `ASSERT BCM-ASYNC-002`：`adapter` 向 Service 返回的数据，必须在进入 UI / 上层调用方之前已经是纯 `DomainMessage`。
- `ASSERT BCM-ASYNC-003`：即使去掉了 `SignalPipe`，也必须保留“历史拉取或发送成功后，上层可观察到新消息列表”的语义；不能只剩缓存更新、但没有可传播的刷新约定。
- `ASSERT BCM-ASYNC-004`：若未来恢复 callback / stream / signal 机制，回调参数仍必须是纯领域对象，绝不能把 bytes 或 TL 协议对象泄漏到 UI。
- `ASSERT BCM-ASYNC-005`：一旦更高 `epoch` 的刷新已经成功交付 UI，所有较旧 `epoch` 的 delayed handoff 都必须在 bridge 层被显式丢弃，绝不能再落到 `MockUiDatasetObserver`。
- `ASSERT BCM-ASYNC-006`：在 Double Fetch 的 force refresh 路径中，必须通过 `MockUiDatasetObserver` 的内部 delivery log 证明“唯一有效 UI 载荷来自 B”；不能只凭 `lastMessageText()` 间接推断。
- `ASSERT BCM-ASYNC-007`：`sendMessage(params)` 成功后，现有 signal 的 snapshot 必须先于 UI observer 的第二次 main-context 交付更新完成。
- `ASSERT BCM-ASYNC-008`：同一 signal 实例的 runtime version 必须在 fetch / send 更新中单调推进；若 observer 看到回退版本，直接判定 signal 运行时语义失真。

### 5.2.4 本轮实际验证方式

- 保持 `包 B` 的类型/接口白名单检查，继续证明 Service/adapter 边界不泄漏 transport 与 TL 协议对象；
- 在 `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj` 中新增：
  - `MockUiDatasetObserver`：模拟 UI 侧的响应式观察者；
  - `MainContextDatasetRefreshBridge`：模拟主线程 dispatcher 与 pending refresh queue；
- 在 `samples/real-message-service-cache-001/src/ui_refresh_behavior_test.cj` 中执行两条最小行为断言：
  - `fetchShouldDispatchDatasetRefreshToMockUiOnMainContext`；
  - `sendShouldDispatchUpdatedDatasetToMockUiOnMainContext`；
- 通过断言证明：
  - worker 上的 fetch/send 只会排队刷新事件；
  - `MockUiDatasetObserver` 在 main-context drain 之前不会被直接改写；
  - main drain 之后，UI 才精确收到一次 `onDatasetChanged` 等价刷新。
- 在 `samples/real-message-service-cache-001/src/delayed_handoff_interruptions_test.cj` 中新增 `包 V5` 压测：
  - `epochRegisterShouldAdvanceMonotonicallyForNewHandoffs`；
  - `delayedHandoffShouldDiscardStaleEpochBeforeUiDelivery`；
  - `interruptionShouldNotLeakCacheWriteLockWithinBudget`；
- 通过 `A delayed fetch / B immediate send / main drain / release delayed A` 的确定性序列，验证 stale handoff 会在 bridge 层被 discard，UI 最终只看到 B。
- 在 `samples/real-message-service-cache-001/src/double_fetch_invalidation_test.cj` 中新增 `包 V6` 压测：
  - `debugInvalidateCacheShouldClearPeerCacheAndAdvanceEpoch`；
  - `forceRefreshDoubleFetchShouldLeaveOnlyBPayloadInUiObserverLog`；
- 通过 `worker-fetch-A delayed / worker-force-refresh-B = debugInvalidateCache + getMessages / main drain / release delayed A` 的确定性序列，验证 force refresh fetch 才是 UI 层唯一生效载荷。

### 5.2.5 当前判定

已执行 `包 B` 与 `BCM-ASYNC-003` 的 mock UI refresh 验证，权威证据见：

- `artifacts/behavior_runs/phase03-package-b-domain-purity/summary.json`
- `artifacts/behavior_runs/phase03-package-b-domain-purity/domain-purity-scan.json`
- `artifacts/behavior_runs/phase03-bcm-async-003-ui-refresh/summary.json`
- `artifacts/behavior_runs/phase03-bcm-async-003-ui-refresh/cjpm-test.log`
- `samples/real-message-service-cache-001/src/ui_refresh_behavior_test.cj`
- `samples/real-message-service-cache-001/src/delayed_handoff_interruptions_test.cj`
- `artifacts/behavior_runs/phase03-v5-delayed-handoff-with-interruptions/summary.json`
- `artifacts/behavior_runs/phase03-v5-delayed-handoff-with-interruptions/cjpm-test.log`
- `samples/real-message-service-cache-001/src/double_fetch_invalidation_test.cj`
- `artifacts/behavior_runs/phase03-v6-double-fetch-invalidation/summary.json`
- `artifacts/behavior_runs/phase03-v6-double-fetch-invalidation/cjpm-test.log`

本轮已经拿到的证据：

- `Public Signature Check`：真实候选 `RealMessageService.cj` 与 harness 中的 `RealMessageService` 均保持公开签名纯洁；
- `Import Whitelist Assert`：业务层仅依赖 `std.*`；
- `DTO Conversion Wall`：恶意 TL / transport 污染文本在离开 adapter 前会被洗脱为纯 `DomainMessage`；
- `Mock UI Refresh Path`：worker 上的 fetch/send 只会经由 `MainContextDatasetRefreshBridge` 排队刷新，`MockUiDatasetObserver` 只有在 main-context drain 后才收到 `onDatasetChanged` 等价通知；
- `Refresh Context Check`：刷新排队日志记录为 `refresh:queued:worker-*`，实际交付上下文为 `main`，证明刷新语义具备跨线程抛递约束。
- `Stale Handoff Discard`：当 `worker-fetch-A` 被延迟而 `worker-send-B` 先完成交付时，bridge 会留下 `refresh:discarded:stale-epoch:worker-fetch-A:*` 证据，并保证 `MockUiDatasetObserver` 最终只看到 B。
- `Strict Observer Log`：在 Double Fetch 变体中，`MockUiDatasetObserver.debugDeliveryLog()` 只保留 `double-fetch-b-tail` 对应的 UI 交付，不含任何 `double-fetch-a-tail` 幽灵载荷。

仍然缺失的证据：

- `callback / stream` 恢复到真实 Harmony UI runtime 后的端到端行为：未证明；
- `真实 transport adapter` 接入后的 UI 刷新闭环：未证明；
- `真实主线程 / ArkUI 引擎` 的物理级日志：未证明。

结论：按 `Staging-Core` 的 `Mock observer + main-context dispatcher` 口径，`BCM-ASYNC-003`、`BCM-ASYNC-005` 与 `BCM-ASYNC-006` 已取得 `Conditional Pass`；但这 **不等于** Harmony 真 UI 引擎上的 `Full Pass`。

---

## 5.3 并发安全验证（Concurrency Safety）

### 5.3.1 源侧真实语义

源侧虽然没有显式锁，但其运行时上下文天然带有异步请求、Signal 更新和 UI 观察者，因此隐含并发风险：

- `fetchMessages()` 可能与 `sendMessage()` 交错；
- `messageCache` 与 `messageSignals` 是共享可变状态；
- 若迁移到仓颉实现后线程模型变化，则必须重新证明共享状态的安全性。

### 5.3.2 当前候选对应点

当前候选使用：

- `HashMap<String, Int64>` 保存 access hash；
- `HashMap<String, Array<DomainMessage>>` 保存缓存；
- 无 `Mutex` / `ReentrantMutex` / actor / worker 边界表达；
- 无线程标签、无调度日志、无串行执行策略。

对应位置：

- `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-041-round42-freeze-anchor-repair/temp_workspace/20260330T111005Z-tu-041-round42-freeze-anchor-repair-src-services-realmessageservice.ets/attempt-06/src/services/RealMessageService.cj:48`
- `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-041-round42-freeze-anchor-repair/temp_workspace/20260330T111005Z-tu-041-round42-freeze-anchor-repair-src-services-realmessageservice.ets/attempt-06/src/services/RealMessageService.cj:50`

### 5.3.3 硬性断言

- `ASSERT BCM-CONC-001`：耗时的 adapter / transport 工作不得在主线程上长时间阻塞执行。
- `ASSERT BCM-CONC-002`：所有共享状态写入必须具备清晰的串行化策略：单线程拥有、显式互斥、actor 隔离，三者至少其一。
- `ASSERT BCM-CONC-003`：并发触发 `getMessages()` 与 `sendMessage()` 后，`messageCache[key]` 的最终结果必须稳定、可重复，不得丢消息。
- `ASSERT BCM-CONC-004`：验证日志中必须能回答“这段业务是在哪个执行上下文完成的”，不能只靠推测说“应该不在主线程”。
- `ASSERT BCM-CONC-005`：在 delayed handoff / interruption 结束后，必须能在预算内再次获取 `messageCache` 写锁；若获取失败或测试整体被卡死，应直接判定为 lock leak。

### 5.3.4 本轮建议验证方式

- `Conditional Pass`：
  - 在最小 dry-run 环境中加入线程 / 执行上下文日志；
  - 用双线程或双任务交错调用同一 `PeerId` 的 `getMessages()` / `sendMessage()`；
  - 检查是否出现：
    - 卡死；
    - 返回长度异常；
    - 尾消息丢失；
    - 旧缓存覆盖新缓存。
- `Full Pass`：
  - 在 Harmony 真实运行时记录主线程/工作线程日志；
  - 证明 UI 刷新不会被后台线程违规直接触达。

### 5.3.5 当前判定

本轮 `包 C` 已实际落盘并跑通：

- `samples/real-message-service-cache-001/src/concurrency_pressure_test.cj`
- `artifacts/behavior_runs/phase03-package-c-concurrency/summary.json`
- `artifacts/behavior_runs/phase03-package-c-concurrency/cjpm-test.log`

已拿到的硬证据：

- `无死锁`：在 `48 send workers + 32 read workers` 的 `spawn().get()` 压测下未出现卡死；
- `无脏读`：压测结束后 `cache size = 50`，且 `burst-0 ~ burst-47` 全部可检出；
- `主线程未阻塞（harness 级）`：adapter / cache 的重操作日志均为 `worker-*` 上下文，没有 `:main` 泄漏；
- `共享状态串行化策略`：`RealMessageService` harness 已显式采用 `Mutex` 保护缓存读写，具备可解释的串行化路径。
- `中断后锁无泄漏`：`interruptionShouldNotLeakCacheWriteLockWithinBudget` 已证明 `debugAcquireCacheWriteLockWithin(50)` 返回 `true`，且 `timeout 5s` 下整套 `cjpm test` 正常退出。

结论：`Concurrency Safety` 已取得 `Conditional Pass（harness 级）`，其中 `BCM-CONC-005` 已通过 V5 lock probe + shell timeout 熔断补齐；但这 **不等于** 已拿到 Harmony 真实主线程 / 工作线程级 `Full Pass`。

## 5.4 翻译一致性（Source Alignment）

### 5.4.1 源侧真实语义

`RealMessageService` 的 ArkTS 原版公开面当前锁定为：

- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:74`
  - `getMessages(peerId: PeerId, limit: number): Signal<Message[]>`
- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:111`
  - `sendMessage(params: SendMessageParams): Promise<Message>`

对翻译任务而言，这两条源侧公开签名不是“可参考建议”，而是后续仓颉映射时的绝对基线。

### 5.4.2 翻译铁律

- public 级 API 签名必须优先服从源侧对齐，而不是为了仓颉内部实现便利而改写调用心智；
- 并发、缓存、`Epoch`、锁、stale discard、force refresh 等增强逻辑可以存在，但必须尽量下沉到 `private` / `internal` 层；
- V5 / V6 中出现的 `debugInvalidateCache`、`debugForceAdvanceEpoch` 等能力只能作为 `Staging-Core` harness 取证 seam 存在，不得直接升级为正式业务公开接口；
- `V8` 起，`scripts/phase3_source_alignment_asserts.py` 成为 public surface 白名单哨兵：任何新增 public type / member，必须先给出 source 依据，再允许进入仓颉公开面。

### 5.4.3 硬性断言

- `ASSERT BCM-ALIGN-001`：仓颉版 `getMessages` 与 `sendMessage` 的参数数量、类型含义必须与 ArkTS 原版 `1:1` 对应；若源侧是 `params` 形态，仓颉正式公开面也不得擅自扁平化为另一套心智模型。
- `ASSERT BCM-ALIGN-002`：`Epoch` 世代管理、锁机制、缓存击穿等增强功能，不得改变原有业务调用心智；它们必须被封装在 `private` / `internal` 作用域下，对调用方保持语义透明。
- `ASSERT BCM-ALIGN-003`：某个 `peerId` 的 signal 第一次被创建时，即使 cache 已经存在，也必须继续触发一次 fetch；只有 signal 已存在的复用路径，才允许不 refetch。
- `ASSERT BCM-ALIGN-004`：`fetchMessages` 必须停留在 `private` / `internal` 层，并使用 `GetHistoryParams` 这类 params bag；不得重新退化成对外可见或扁平 `peerId + limit` 的形态。
- `ASSERT BCM-ALIGN-005`：同一 `peerId` 的 signal 在 invalidation 前必须复用同一实例；若无 invalidation 就切换实例，判定为 signal 生命周期偏离 source 心智。

### 5.4.4 当前判定

- `BCM-ALIGN-001` 已在 `V7` 完成 source parity 收口，并在 `V8 / V9 / V10` 后继续保持通过：`getMessages(peerId, limit)` 与 `sendMessage(params)` 仍维持 ArkTS 原版公开心智；
- `BCM-ALIGN-002` 已在 `V8` 取得 `Staging-Core` 级验证通过：`debug*`、`attachRefreshBridge`、bridge / adapter scaffolding 已下沉到同包内部可见，`MessageSignal.replace()` 也不再暴露在 public 面；
- `BCM-ALIGN-003` 已在 `V9` 取得验证通过：首次 signal 创建会重新触发 fetch，不再受“cache 已存在就短路”的旧逻辑绑死；
- `BCM-ALIGN-004` 已在 `V9` 取得验证通过：`fetchMessages` 已回到 `private func fetchMessages(params: GetHistoryParams)` 的 internal params bag 形态，并由 `scripts/phase3_source_semantics_asserts.py` 固化为静态哨兵；
- `BCM-ALIGN-005` 已在 `V10` 取得验证通过：同一 `peerId` 的 signal 会在 invalidation 前持续复用同一实例，只有 invalidation 后才切换 runtime identity；
- 因此，当前 `Staging-Core` harness 仍是“模块级物理取证壳”，但其 public 面、signal 生命周期、internal fetch 入口与最小运行时更新语义都已经明显更接近 ArkTS 真理源；后续只需继续收平 `Promise` 的运行时语义差距。

---

## 6. 本轮建议的最小验证包（Phase 3C Conditional Pass 候选）

## 6.1 包 A：缓存行为验证

目标：先打掉“代码会编，但 cache 不工作”的幻觉。

建议最小用例：

1. `test_get_messages_populates_cache_on_first_fetch`
2. `test_get_messages_hits_cache_on_second_read`
3. `test_send_message_appends_to_existing_cache`
4. `test_send_message_seeds_cache_when_empty`

预期证据：

- adapter 调用计数；
- 缓存长度变化；
- 末尾消息内容；
- 失败日志。

## 6.2 包 B：领域纯洁度验证

目标：证明 Service 与 UI 边界不再泄漏 transport bytes / TL 协议对象。

建议最小检查：

1. Service 公开签名白名单检查；
2. 静态扫描扩展到 `Phase 3C` 行为契约白名单；
3. fake adapter 返回异常对象时，Service 是否仍保持领域边界。

预期证据：

- 公开接口签名快照；
- 白名单检查结果；
- 失败时的拒绝日志或断言失败记录。

## 6.3 包 C：并发与线程边界验证

目标：证明当前实现至少不会在最小压力下直接失真。

本轮实际执行结果：

1. 先用 `runWorkerGetMessages(service, peerId, 2, "worker-warmup")` 以 worker 上下文预热缓存；
2. 随后通过 `spawn().get()` 并发打入 `48` 个 send worker 与 `32` 个 read worker；
3. 用 `ThreadLocal<String>` 执行上下文标签分别记录 adapter 重操作与 cache 重操作；
4. 最终断言 `cache size = 50`，且 `burst-0 ~ burst-47` 全部存在。

权威证据：

- `samples/real-message-service-cache-001/src/concurrency_pressure_test.cj`
- `artifacts/behavior_runs/phase03-package-c-concurrency/summary.json`
- `artifacts/behavior_runs/phase03-package-c-concurrency/cjpm-test.log`

本轮结论：

- `BCM-CONC-001`：通过（`ThreadLocal` worker 标签无 `:main` 泄漏）；
- `BCM-CONC-002`：通过（`Mutex` 串行化 cache 读写）；
- `BCM-CONC-003`：通过（`48/32` 混合压测后 cache 稳定且不丢消息）。

限制说明：

- 这是 `Conditional Pass` 级 harness，而不是 Harmony 真实主线程探针；
- `BCM-ASYNC-003` 已在独立的 mock UI harness 中闭环，因此这里不能把“包 C 的并发证据”误当成“UI 刷新语义本身的证据来源”。

## 6.4 包 V5：Delayed Handoff with Interruptions

目标：把“UI handoff 世代校验”和“中断后锁不泄漏”从架构设想推进为 Linux `Staging-Core` 的物理证据。

本轮实际执行结果：

1. 在 `MainContextDatasetRefreshBridge` 中引入 `MutexEpochRegister`、`pendingQueue`、`delayedQueue`、`delayedSources` 与 `latestDeliveredEpoch`；
2. 对 `worker-fetch-A` 预先执行 `delayNextHandoffFor(...)`，把 A 的 UI handoff 暂存到带锁 delayed queue；
3. 让 `worker-send-B` 产生更新的快照并先在 main drain 中交付 UI；
4. 再释放 delayed A，并在 bridge 的 `drainOnMain()` 中基于 `epoch` 执行 stale discard；
5. 最后调用 `debugAcquireCacheWriteLockWithin(50)`，并用外层 `timeout 5s` 对整套 `cjpm test` 做死锁熔断。

权威证据：

- `samples/real-message-service-cache-001/src/delayed_handoff_interruptions_test.cj`
- `artifacts/behavior_runs/phase03-v5-delayed-handoff-with-interruptions/summary.json`
- `artifacts/behavior_runs/phase03-v5-delayed-handoff-with-interruptions/cjpm-test.log`
- `artifacts/behavior_runs/phase03-v5-delayed-handoff-with-interruptions/cjpm-test-timeout-5s.log`

本轮结论：

- `BCM-ASYNC-005`：通过（A delayed / B immediate send，UI 最终只收到 B，旧的 A handoff 在进入 UI 前被 discard）；
- `BCM-CONC-005`：通过（`debugAcquireCacheWriteLockWithin(50)` 返回 `true`，且 `timeout 5s` 下整套测试未挂死）；
- `Generation / Epoch Check`：通过（bridge dispatch log 明确保留 `refresh:discarded:stale-epoch:*` 证据）；
- `No-Leak Guarantee`：通过（lock probe + shell 熔断双保险）。

限制说明：

- 当前 `epoch` 后端是 compile-safe 的 `Mutex + Int64`，仍不是最终形态的 `AtomicInt64`；
- `B` 路径当前采用 `sendMessage` 而不是第二次 `getMessages`，这是为了避免缓存命中把 V5 压测稀释成假绿。

## 6.5 包 V6：Double Fetch Invalidation

目标：把“物理级缓存击穿 + force refresh fetch + strict stale-read observer log”从战术建议推进为 Linux `Staging-Core` 的可复现证据。

本轮实际执行结果：

1. 给 `DatasetRefreshBridge` 增加 `debugForceAdvanceEpoch(reason)`，并在 `MainContextDatasetRefreshBridge` 中实现 forced epoch bump；
2. 给 `RealMessageService` 增加 `debugInvalidateCache(peerId)`，在 `cacheLock` 保护下删除指定 `peerId` 的缓存后，再显式推动 bridge epoch 前进；
3. 给 `MockUiDatasetObserver` 增加 `deliveryLog`，把每次 UI 生效载荷写成可断言字符串；
4. 构造 `worker-fetch-A delayed / worker-force-refresh-B = debugInvalidateCache + getMessages / main drain / release delayed A` 的确定性序列；
5. 用 observer delivery log 严格断言：UI 只生效 B，A 不得逸出任何幽灵状态。

权威证据：

- `samples/real-message-service-cache-001/src/double_fetch_invalidation_test.cj`
- `artifacts/behavior_runs/phase03-v6-double-fetch-invalidation/summary.json`
- `artifacts/behavior_runs/phase03-v6-double-fetch-invalidation/cjpm-test.log`
- `artifacts/behavior_runs/phase03-v6-double-fetch-invalidation/cjpm-test-timeout-5s.log`

本轮结论：

- `BCM-STATE-006`：通过（`debugInvalidateCache` 会清空指定 `peerId` 的 cache、驱逐旧 signal，并返回严格大于失效前的 forced epoch）；
- `BCM-ASYNC-006`：通过（observer delivery log 中唯一有效载荷来自 `worker-force-refresh-B`，不含 A 的幽灵交付）；
- `BCM-CONC-005`：在 Double Fetch 变体下再次通过（`timeout 5s` 完整 `cjpm test` 正常退出）；
- `Double Fetch`：已从红灯编译失败推进到 Linux 物理 `15/15` 全绿。

限制说明：

- 当前 invalidate 仍是 harness-only debug 接口，不代表真实业务接口已经暴露同名能力；
- 若后续要模拟更接近真实协议层的 “B 不是强制 cache invalidate，而是 transport 侧 cache bust”，应再补 adapter 层的显式 invalidation 信号。

---

## 7. 当前阶段判定

基于现有证据，`RealMessageService` 当前应被判定为：

- `Phase 3B`：**已通过**；
- `Phase 3C / State & Cache`：**已取得 Conditional Pass 级证据（包 A + 包 C + Double Fetch invalidation）**；
- `Phase 3C / Async Boundary`：**已取得 Conditional Pass（mock observer / main dispatcher / stale handoff discard / strict stale-read observer log）**；
- `Phase 3C / Concurrency Safety`：**已取得 Conditional Pass（harness 级 + no-leak probe）**。

因此，当前最诚实的表述是：

> `RealMessageService` 已在 `Staging-Core` 无头验证环境下完成 `Phase 3C Conditional Pass`：缓存行为、领域纯洁度、并发线程边界、UI 刷新语义，以及 delayed handoff 的 stale discard / no-leak 断言、Double Fetch invalidation 与 strict stale-read observer log 都已经拿到最小自动化证据；但由于仍缺少真实 Harmony ArkUI / 主线程运行时证据，当前还不能宣称 `Phase 3C Full Pass`。

---

## 8. 下一步执行顺序

1. `包 A：缓存行为验证` 已完成，且 `4/4` 用例通过；
2. `包 B：领域纯洁度验证` 已完成，且三锁口径已全绿；
3. `包 C：并发与线程边界验证` 已完成，并拿到 `8/8` 样本测试全绿与 `BCM-CONC-*` 证据；
4. `BCM-ASYNC-003` 已完成 mock UI refresh 验证，并把总样本测试推进到 `10/10` 全绿；
5. `包 V5` 已完成 delayed handoff / interruption 压测，并把总样本测试推进到 `13/13` 全绿；
6. `包 V6` 已完成 Double Fetch invalidation 压测，并把总样本测试推进到 `15/15` 全绿；
7. `包 V7` 已完成 source parity 收口首轮，并把总样本测试推进到 `17/17` 全绿；
8. 下一优先级应转入 `Phase 3C Full Pass`：补齐真实 Harmony UI / 主线程 / SignalPipe 等价路径的物理级证据；
9. 每完成一包，都要产出：
   - 执行命令；
   - 输入 / 输出；
   - 日志；
   - 结论；
   - 回写到状态板与执行轨迹。

