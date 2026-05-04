# Phase 3C delayed_handoff_with_interruptions Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 `samples/real-message-service-cache-001` 中补出 `delayed_handoff_with_interruptions` 的 V5 压测 Harness，验证 stale handoff 丢弃与中断后锁释放。

**Architecture:** 继续复用现有 `RealMessageService`、`MockUiDatasetObserver` 与 `MainContextDatasetRefreshBridge`。在 Harness 内新增 epoch register、delayed queue、discard log 与 lock probe 接口，让 `A delayed / B immediate` 的竞态在无头 Linux 上可稳定复现，并通过 `cjpm test` + shell `timeout` 双层验证。

**Tech Stack:** Cangjie `cjpm test`、`std.sync.Mutex`、`ThreadLocal<String>`、`spawn().get()`、`std.unittest`、shell `timeout`

---

### Task 1: 写红灯测试，钉住 Epoch / No-Leak 两个闸门

**Files:**
- Create: `samples/real-message-service-cache-001/src/delayed_handoff_interruptions_test.cj`
- Modify: `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`

- [ ] **Step 1: 先写 stale handoff 红灯测试**

把测试文件先写成下面这类目标形态：

```cj
package real_message_service_cache_001

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class RealMessageServiceDelayedHandoffTests {
    @TestCase
    public func delayedHandoffShouldDiscardStaleEpochBeforeUiDelivery(): Unit {
        setExecutionContext("main")
        let peerId = PeerId(0, 5001)
        let adapter = DelayedHandoffProbeAdapter()
        let observer = MockUiDatasetObserver()
        let bridge = MainContextDatasetRefreshBridge(observer)
        let service = RealMessageService(adapter)
        service.attachRefreshBridge(bridge)
        adapter.primeScenario("worker-fetch-A", buildScenarioMessages(peerId, "request-a-tail"))
        adapter.primeScenario("worker-fetch-B", buildScenarioMessages(peerId, "request-b-tail"))

        bridge.delayNextHandoffFor("worker-fetch-A")

        _ = runWorkerFetchScenario(service, peerId, 2, "worker-fetch-A")
        _ = runWorkerFetchScenario(service, peerId, 2, "worker-fetch-B")

        setExecutionContext("main")
        bridge.drainOnMain()
        bridge.releaseDelayedHandoffs()
        bridge.drainOnMain()

        assertEqual("最终 UI 只能看到 B 的尾消息", "", "request-b-tail", observer.lastMessageText())
        assertEqual("stale A 不得落到 UI", "", 1, observer.notificationCount())
        assertEqual("必须留下 stale discard 日志", "", true, logContains(bridge.debugDispatchLog(), "refresh:discarded:stale-epoch:worker-fetch-A"))
    }
}
```

- [ ] **Step 2: 运行红灯测试，确认当前实现必然失败**

运行：

```bash
cd samples/real-message-service-cache-001 && cjpm test
```

预期：编译失败或测试失败，原因应集中在 `delayNextHandoffFor`、`releaseDelayedHandoffs`、`DelayedHandoffProbeAdapter` 等新符号尚不存在。

- [ ] **Step 3: 再写 No-Leak 红灯测试**

在同一文件继续补第二个测试：

```cj
@TestCase
public func interruptionShouldNotLeakCacheWriteLock(): Unit {
    setExecutionContext("main")
    let peerId = PeerId(0, 5002)
    let adapter = DelayedHandoffProbeAdapter()
    let observer = MockUiDatasetObserver()
    let bridge = MainContextDatasetRefreshBridge(observer)
    let service = RealMessageService(adapter)
    service.attachRefreshBridge(bridge)
    adapter.primeScenario("worker-fetch-A", buildScenarioMessages(peerId, "request-a-tail"))
    adapter.primeScenario("worker-fetch-B", buildScenarioMessages(peerId, "request-b-tail"))

    bridge.delayNextHandoffFor("worker-fetch-A")
    _ = runWorkerFetchScenario(service, peerId, 2, "worker-fetch-A")
    _ = runWorkerFetchScenario(service, peerId, 2, "worker-fetch-B")

    setExecutionContext("main")
    bridge.drainOnMain()
    bridge.releaseDelayedHandoffs()
    bridge.drainOnMain()

    assertEqual("中断后必须能重新获取 cache 写锁", "", true, service.debugAcquireCacheWriteLockProbe())
}
```

- [ ] **Step 4: 再跑一次红灯，确认第二个闸门也在失败**

运行：

```bash
cd samples/real-message-service-cache-001 && cjpm test
```

预期：继续失败，且失败点仍然只在缺失的 V5 Harness 能力，不是语法拼写错误。

### Task 2: 在 Harness 中补 epoch register 与 delayed queue

**Files:**
- Modify: `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`

- [ ] **Step 1: 先补 epoch register 抽象与 compile-safe 后端**

加入如下结构：

```cj
public interface EpochRegister {
    func nextEpoch(): Int64
    func currentEpoch(): Int64
}

public class MutexEpochRegister <: EpochRegister {
    private let epochLock = Mutex()
    private var current: Int64 = 0

    public init() {}

    public func nextEpoch(): Int64 {
        this.epochLock.lock()
        this.current = this.current + 1
        let snapshot = this.current
        this.epochLock.unlock()
        snapshot
    }

    public func currentEpoch(): Int64 {
        this.epochLock.lock()
        let snapshot = this.current
        this.epochLock.unlock()
        snapshot
    }
}
```

- [ ] **Step 2: 扩展 pending refresh 结构，挂上 epoch**

将 pending item 扩成类似结构：

```cj
public class PendingDatasetRefresh {
    public let peerId: PeerId
    public let messages: Array<DomainMessage>
    public let sourceContext: String
    public let epoch: Int64

    public init(peerId: PeerId, messages: Array<DomainMessage>, sourceContext: String, epoch: Int64) {
        this.peerId = peerId
        this.messages = messages
        this.sourceContext = sourceContext
        this.epoch = epoch
    }
}
```

- [ ] **Step 3: 给 bridge 加 delayed queue 和 release 机制**

在 `MainContextDatasetRefreshBridge` 中加入：

```cj
private var delayedQueue = emptyPendingRefreshes()
private var delayedSources = emptyStrings()

public func delayNextHandoffFor(sourceContext: String): Unit {
    this.queueLock.lock()
    this.delayedSources = appendString(this.delayedSources, sourceContext)
    this.queueLock.unlock()
    this.appendDispatchLog("refresh:delay-armed:${sourceContext}")
}

public func releaseDelayedHandoffs(): Unit {
    this.queueLock.lock()
    let snapshot = clonePendingRefreshes(this.delayedQueue)
    this.delayedQueue = emptyPendingRefreshes()
    this.queueLock.unlock()
    for (item in snapshot) {
        this.queueLock.lock()
        this.pendingQueue = appendPendingRefresh(this.pendingQueue, item)
        this.queueLock.unlock()
        this.appendDispatchLog("refresh:released:${item.sourceContext}:epoch=${item.epoch}")
    }
}

public func delayedRefreshCount(): Int64 {
    this.queueLock.lock()
    let size = this.delayedQueue.size
    this.queueLock.unlock()
    size
}
```

规则：

- 若当前 source 被标为 delayed，则先进入 `delayedQueue`；
- `releaseDelayedHandoffs()` 只负责把 delayed item 挪回待判定路径，不直接绕过 epoch check；
- 所有路径都要留下 `refresh:queued:*` / `refresh:released:*` / `refresh:discarded:*` 日志。

- [ ] **Step 4: 再跑测试，确认失败前进到 service/adapter 侧缺能力**

运行：

```bash
cd samples/real-message-service-cache-001 && cjpm test
```

预期：编译/测试失败开始转移到 `RealMessageService` 尚未传递 epoch 或 `DelayedHandoffProbeAdapter` 尚未实现。

### Task 3: 给 `RealMessageService` 补 epoch 传播与 lock probe

**Files:**
- Modify: `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`

- [ ] **Step 1: 在 service 中接入 epoch register**

把 `RealMessageService` 最小扩成类似结构：

```cj
private let epochRegister: EpochRegister

public init(adapter: IMTProtoAdapter) {
    this.adapter = adapter
    this.refreshBridge = NoopDatasetRefreshBridge()
    this.epochRegister = MutexEpochRegister()
}
```

并在 fetch/send 发布前拿到 epoch：

```cj
let requestEpoch = this.epochRegister.nextEpoch()
this.publishDatasetChanged(peerId, messages, requestEpoch)
```

- [ ] **Step 2: 修改 publish 路径，把 epoch 交给 bridge**

目标形态：

```cj
private func publishDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>, requestEpoch: Int64): Unit {
    this.appendTrace("cache:publish:${currentExecutionContext()}:epoch=${requestEpoch}")
    this.refreshBridge.notifyDatasetChanged(peerId, messages, requestEpoch)
}
```

如果现有接口不便直接变更，可通过新增 bridge 接口或 overload 保持旧测试兼容，但必须统一到一套最终路径。

- [ ] **Step 3: 加 lock probe 调试接口**

先实现最小 compile-safe 版本：

```cj
public func debugAcquireCacheWriteLockProbe(): Bool {
    this.cacheLock.lock()
    this.appendTrace("cache:lock-probe:acquired:${currentExecutionContext()}")
    this.cacheLock.unlock()
    true
}
```

若当前 SDK 已证实存在 `tryLock` / timed lock，再把这里收紧为预算式实现；否则先保留这版，并依赖 shell `timeout` 作为死锁熔断。

- [ ] **Step 4: 跑测试，确认编译通过并只剩行为断言问题**

运行：

```bash
cd samples/real-message-service-cache-001 && cjpm test
```

预期：此时若仍失败，应主要是 A/B 数据构造、discard 条件或日志内容未完全对齐，而不是缺接口。

### Task 4: 实现 A delayed / B immediate 的可重复竞态

**Files:**
- Modify: `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`
- Modify: `samples/real-message-service-cache-001/src/delayed_handoff_interruptions_test.cj`

- [ ] **Step 1: 新增专用 adapter，返回 A/B 两套可区分历史快照**

新增一个 probe adapter，至少支持：

```cj
public class DelayedHandoffProbeAdapter <: IMTProtoAdapter {
    private let seededHistory = HashMap<String, Array<DomainMessage>>()
    private let historyLock = Mutex()
    private let counterLock = Mutex()
    private let logLock = Mutex()
    private var invocationLog = emptyStrings()
    private var nextMessageId: Int32 = 30000

    public init() {}

    public func primeScenario(label: String, messages: Array<DomainMessage>): Unit {
        this.historyLock.lock()
        this.seededHistory[label] = cloneMessages(messages)
        this.historyLock.unlock()
    }

    public func getHistory(peerId: PeerId, _limit: Int32): Array<DomainMessage> {
        _ = peerId
        let label = currentExecutionContext()
        this.appendInvocation("adapter:getHistory:${label}")
        this.historyLock.lock()
        let result = match (this.seededHistory.get(label)) {
            case Some(messages) => cloneMessages(messages)
            case None => emptyMessages()
        }
        this.historyLock.unlock()
        result
    }

    public func sendMessage(peerId: PeerId, text: String): DomainMessage {
        this.appendInvocation("adapter:send:${currentExecutionContext()}")
        this.counterLock.lock()
        this.nextMessageId = this.nextMessageId + 1
        let nextId = this.nextMessageId
        this.counterLock.unlock()
        DomainMessage(nextId, text, peerId)
    }

    public func debugInvocationLog(): Array<String> {
        this.logLock.lock()
        let snapshot = cloneStrings(this.invocationLog)
        this.logLock.unlock()
        snapshot
    }

    private func appendInvocation(entry: String): Unit {
        this.logLock.lock()
        this.invocationLog = appendString(this.invocationLog, entry)
        this.logLock.unlock()
    }
}
```

测试中要求：

- `primeScenario("worker-fetch-A", buildScenarioMessages(peerId, "request-a-tail"))`
- `primeScenario("worker-fetch-B", buildScenarioMessages(peerId, "request-b-tail"))`
- 最终 observer 只能看到 `request-b-tail`

- [ ] **Step 2: 提供 worker fetch 场景 helper**

加一个 helper，便于显式传 source label：

```cj
func runWorkerFetchScenario(service: RealMessageService, peerId: PeerId, limit: Int32, workerLabel: String): Array<DomainMessage> {
    let task = spawn {
        setExecutionContext(workerLabel)
        service.getMessages(peerId, limit)
    }
    task.get()
}

func buildScenarioMessages(peerId: PeerId, tailText: String): Array<DomainMessage> {
    Array<DomainMessage>(2, { index: Int64 =>
        if (index == 0) {
            DomainMessage(700 + Int32(index), "seed-${tailText}", peerId)
        } else {
            DomainMessage(701 + Int32(index), tailText, peerId)
        }
    })
}
```

这里直接把 `workerLabel` 作为 adapter 场景键和 bridge source key，避免再引入第二套 request label 协议。

- [ ] **Step 3: 补 stale discard 逻辑，保证 A 在 UI 前被拦截**

核心条件必须长这样：

```cj
if (item.epoch < this.latestAcceptedEpoch()) {
    this.appendDispatchLog("refresh:discarded:stale-epoch:${item.sourceContext}:${item.epoch}->${this.latestAcceptedEpoch()}")
    continue
}
```

实现时允许用等价写法，但不能把 stale item 先送进 observer 再“修正状态”。

- [ ] **Step 4: 跑整包测试，确认两道硬断言都转绿**

运行：

```bash
cd samples/real-message-service-cache-001 && cjpm test
```

预期：`delayed_handoff_interruptions_test.cj` 通过，且现有 `cache_behavior_test.cj`、`ui_refresh_behavior_test.cj`、`concurrency_pressure_test.cj` 不回归。

### Task 5: 增加死锁熔断验证与文档证据

**Files:**
- Create: `docs/traces/trace-phase-03-v5-delayed-handoff-with-interruptions.md`
- Modify: `docs/phase-03-behavior-contract-matrix-realmessageservice.md`

- [ ] **Step 1: 用 shell timeout 证明 Harness 不会卡死**

运行：

```bash
timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'
```

预期：退出码为 `0`；若超时，则说明 `No-Leak Guarantee` 尚未成立。

- [ ] **Step 2: 在行为矩阵里补一条 harness 级增强说明**

在 `docs/phase-03-behavior-contract-matrix-realmessageservice.md` 记录：

```text
- BCM-ASYNC-003 扩展证据：stale delayed handoff 在 UI 交付前被 epoch check 丢弃
- BCM-CONC-002 扩展证据：interruption 后 cache lock probe 可成功获取
```

- [ ] **Step 3: 写 trace 文档**

轨迹至少记录：

```text
- A delayed / B immediate 的构造方式
- dispatch log / discard log 的关键片段
- observer 最终接收到 B 的证据
- lock probe 成功与 timeout 5s 不触发的证据
```

### Task 6: 最终验收

**Files:**
- No additional files required

- [ ] **Step 1: 运行最终命令集**

依次运行：

```bash
python3 -m unittest discover -s tests -p 'test_*.py' -v
```

```bash
cd samples/real-message-service-cache-001 && cjpm test
```

```bash
timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'
```

- [ ] **Step 2: 仅在三条命令都通过后，才能宣称 V5 Harness ready**

最终结论必须同时满足：

```text
- delayed handoff stale discard 通过
- interruption 后 lock probe 通过
- 现有 cache/ui/concurrency 样本无回归
- Linux Staging-Core 物理编译链可稳定承载该压力样本
```
