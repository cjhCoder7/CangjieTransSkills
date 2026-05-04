# Phase 3C delayed_handoff_with_interruptions 设计

## 背景

当前仓库已经在 `samples/real-message-service-cache-001` 上拿到了三类关键基线：

- `BCM-STATE-001`：缓存刷新闭环；
- `BCM-CONC-001 / BCM-CONC-002`：worker 执行边界与 `Mutex` 串行化；
- `BCM-ASYNC-003`：`MockUiDatasetObserver + MainContextDatasetRefreshBridge` 证明“worker 只排队，main drain 后才交付 UI 刷新”。

但这套基线仍缺一个更接近真实线上竞态的 V5 压力样本：

> **delayed_handoff_with_interruptions**

它要回答的问题不是“UI 刷新能不能发生”，而是：

1. 当旧请求 A 的 handoff 被人为延迟，而新请求 B 已完成并交付到 UI 后，系统能否在 UI 边界前明确丢弃 A；
2. 当中断 / 丢弃发生时，`messageCache` 相关锁是否完全释放，不留下幽灵线程、锁泄漏或死锁。

这会成为当前 Linux `Staging-Core` 物理编译链上的第一块“异步交付 + 竞态淘汰 + 锁安全”综合压力样本。

## 目标

本轮设计聚焦以下 4 个硬目标：

1. 复用 `samples/real-message-service-cache-001` 现有 Harness，不新开第二个样本包；
2. 在 `RealMessageService` 的 mock/harness 语境下构造 `A delayed, B immediate` 的可重复竞态；
3. 把两道硬断言写成一级闸门：
   - `Generation / Epoch Check`
   - `No-Leak Guarantee`
4. 让样本可在 `Linux + cjpm test` 下稳定运行，作为 `Staging-Core` 编译链的真实压力测试对象。

## 非目标

- 本轮不引入 Harmony 真 UI / 真主线程；
- 本轮不改真实 Telegram 模块源码；
- 本轮不把 `Conditional Pass` 误报为 `Full Pass`；
- 本轮不追求“真实用户中断 API”全量复刻，只做最小可证伪的 handoff/interruption harness。

## 为什么选它作为 V5 首个对象

`delayed_handoff_with_interruptions` 具备三个优点：

1. **正好压在当前最关键的缝上**：`messageCache -> refreshBridge -> MockUiDatasetObserver`；
2. **既能测 stale delivery，又能测锁安全**：比纯缓存命中更像真实竞态；
3. **仍然可在无头 Linux 上稳定复现**：不依赖 GUI / DevEco / 模拟器。

## 方案对比

### 方案 A：直接改现有 `MainContextDatasetRefreshBridge`，加入 epoch / delayed queue / discard log

优点：

- 最大化复用现有样本包与 UI refresh 断言；
- 交付路径最短；
- 能直接复用 `MockUiDatasetObserver` 与已有 `drainOnMain()` 语义。

缺点：

- 需要小心保持旧的 `ui_refresh_behavior_test.cj` 继续通过；
- 需要在 bridge 中引入更多调试状态。

### 方案 B：复制一份新的 `RealMessageServiceV5Harness`

优点：

- 隔离性强；
- 不容易影响既有测试。

缺点：

- 复制现有 `RealMessageService` 逻辑会制造分叉；
- 后续维护成本高，经验不易回流。

### 方案 C：直接在真实候选 `.cj` 上做延迟与中断实验

优点：

- 离最终产物最近。

缺点：

- 当前仍处于 Harness 证据扩张期；
- 一旦失败，很难区分是翻译噪声、编译问题还是 handoff 逻辑本身。

## 选定方案

采用 **方案 A**：在现有样本包内扩展 `RealMessageService` Harness 与 `MainContextDatasetRefreshBridge`，把 delayed/interruption/epoch/discard/no-leak 逻辑做成可复用的测试基线。

## 设计细节

### 1. 总体结构

本轮继续以 `samples/real-message-service-cache-001` 为唯一包根，计划新增 / 修改：

- 修改：`samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`
- 新增：`samples/real-message-service-cache-001/src/delayed_handoff_interruptions_test.cj`
- 可选补充：`docs/phase-03-behavior-contract-matrix-realmessageservice.md`
- 新增轨迹：`docs/traces/trace-phase-03-v5-delayed-handoff-with-interruptions.md`

### 2. Epoch / Generation 语义

#### 2.1 逻辑要求

每次会触发 UI 可见刷新的 fetch/send 路径，都必须携带一个 `requestEpoch`。

- 请求 A 启动时拿到 `epoch=1`；
- 请求 B 在 A 被延迟时启动，并将全局 epoch 推到 `2`；
- 当 A 准备进入 UI handoff 时，必须比较：`requestEpoch == currentEpoch`；
- 若不相等，A 必须被拦截层明确丢弃，且不得到达 `MockUiDatasetObserver`。

#### 2.2 物理实现建议

架构上，这个计数器是一个“逻辑上的原子世代计数器”。

用户给出的战术建议是使用类似 `AtomicInt64` 的实现，这在语义上完全正确；但结合当前仓库的 Phase 03 现实约束，本轮设计采用以下兼容策略：

- **接口层**：引入 `EpochRegister` / `GenerationClock` 抽象，暴露 `nextEpoch()` 与 `currentEpoch()`；
- **首选后端**：使用 `Mutex + Int64` 实现一个 compile-safe 的 `MutexEpochRegister`，保证当前 `cjpm test` / Linux 编译链最稳；
- **可替换后端**：若后续确认 harness-only 代码中 `AtomicInt64` 可稳定通过当前 Linux 物理编译链，再在不改测试语义的前提下切到真正的 atomic backend。

也就是说：

> 本轮必须保留“atomic epoch semantics”，但具体后端先用当前仓库最稳的 compile-safe 方案落地。

### 3. Delayed Handoff / Interruptions 模型

#### 3.1 不使用真实 sleep，改用可控 Gate

为了让 `Staging-Core` 下的样本稳定、可重复、无时序抖动，本轮不依赖真实 `sleep()`；改用显式 gate：

- bridge 接到 A 的刷新时，不立刻进入 `pendingQueue`，而是进入 `delayedQueue`；
- 测试显式触发 B 完成并交付；
- 测试再显式“释放 A”；
- bridge 在释放 A 的那一刻做 `epoch` 对比，并记录 `discard` 或 `deliver`。

这比真实睡眠更适合作为 CI / Linux 无头链路里的确定性压力样本。

#### 3.2 Bridge 新职责

`MainContextDatasetRefreshBridge` 计划扩展为具备以下能力：

- 普通排队：`pendingQueue`
- 延迟排队：`delayedQueue`
- 调度日志：`refresh:queued:*` / `refresh:delivered:*`
- 丢弃日志：`refresh:discarded:stale-epoch:*`
- 调试接口：
  - `delayNextHandoffFor(sourceContext)`
  - `releaseDelayedHandoffs()`
  - `discardLog()` / `debugDispatchLog()`
  - `pendingRefreshCount()` / `delayedRefreshCount()`

### 4. 两道硬断言

#### 4.1 `Generation / Epoch Check`

必须人为制造：

- A：带延迟的 worker 请求；
- B：无延迟的 worker 请求；
- A 与 B 指向同一个 `peerId`，但 B 表示更新的快照。

硬断言：

1. UI 最终只能看到 B；
2. A 不得进入 `MockUiDatasetObserver`；
3. bridge 必须留下明确的 stale discard 证据，例如：
   - `refresh:discarded:stale-epoch:worker-fetch-A:1->2`
4. `observer.lastMessageText()`、`observer.lastDatasetSize()`、`observer.notificationCount()` 都必须与 B 对齐，而不是与 A 对齐。

#### 4.2 `No-Leak Guarantee`

在 A/B 竞态 + interruption 结束后，必须证明 `messageCache` 写锁已经完全释放。

本轮设计采用两层保证：

- **第一层（首选）**：若当前 SDK 能确认 `Mutex` 存在 `tryLock` 或等价 timed acquire，则实现 `debugAcquireCacheWriteLockWithin(50)`，直接以 `50ms` 预算验证；
- **第二层（当前默认）**：若当前 SDK 无明确 `tryLock` 证据，则在 Harness 中提供一次真实的“劫持后强行获取”探针：
  - 在主测试流程末尾，spawn 一个 probe worker 去获取并立即释放 `cacheLock`；
  - probe 成功后把结果写入共享标记与 trace；
  - 外层测试命令继续由 shell `timeout` 熔断，防止任何死锁把 `cjpm test` 永久挂住。

核心目标不变：

> 中断发生后，必须能证明 `cacheLock` 不是悬挂状态。

### 5. RealMessageService 侧最小扩展

本轮不重写 service，只做最小扩展：

- 增加 epoch register；
- 在 fetch/send 会触发刷新之前记录 `requestEpoch`；
- 发布 refresh 时把 `requestEpoch` 交给 bridge；
- 暴露一个仅供测试使用的 lock probe / debug trace 接口；
- 保持旧的 cache / UI refresh / concurrency 测试仍可通过。

### 6. 测试样例设计

#### 6.1 Case A：`delayedHandoffShouldDiscardStaleEpochBeforeUiDelivery`

构造：

- A 请求被 bridge 延迟；
- B 请求在更高 epoch 下完成；
- main 先 drain B，再 release A。

断言：

- observer 只看到 B；
- A 被丢弃；
- dispatch/discard log 留有证据；
- `messageCache` 最终快照与 B 一致。

#### 6.2 Case B：`interruptionShouldNotLeakCacheLock`

构造：

- 重复 A delayed + B immediate；
- 释放 stale A 后，立刻执行 cache write lock probe。

断言：

- probe 成功；
- trace 中存在 `cache:lock-probe:acquired`（或等价日志）；
- 整个 `cjpm test` 不得卡死。

### 7. 与现有 BCM / Harness 的关系

本轮建议把它视作现有断言的增强层，而不是另起炉灶：

- `BCM-ASYNC-003`：从“worker 只排队、main drain 后交付”增强到“过期 handoff 不得交付 UI”；
- `BCM-CONC-002`：从“共享状态串行化”增强到“中断后锁必须可再次获取”；
- `BCM-CONC-001`：继续要求重操作不落到 main。

### 8. 验证命令

建议至少保留两类命令：

```bash
cd samples/real-message-service-cache-001 && cjpm test
```

```bash
timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'
```

第一条验证语义正确；第二条验证没有死锁把整个 Harness 卡住。

## 风险与缓解

### 风险 1：Atomic 语义写对了，但具体 API 在当前 SDK 下不稳

缓解：首轮使用 `EpochRegister` 抽象 + `MutexEpochRegister` 后端，避免让 V5 计划被 API 不确定性卡死。

### 风险 2：把延迟做成真实 sleep 导致测试抖动

缓解：用手工 gate / delayed queue 做确定性调度，不依赖墙钟。

### 风险 3：锁探针本身又引入新耦合

缓解：锁探针只暴露最小 debug 接口，不进入业务路径；若 SDK 没有 `tryLock`，就把 `timeout 5s cjpm test` 作为外层熔断器保底。

## 结论

`delayed_handoff_with_interruptions` 是当前 Phase 03 最适合作为 V5 首个真实压力样本的对象。它既贴着现有 `RealMessageService` Harness 的主缝，又能把“过期 handoff 丢弃”和“中断后锁释放”这两类线上高风险问题提前在 Linux `Staging-Core` 下打穿。
