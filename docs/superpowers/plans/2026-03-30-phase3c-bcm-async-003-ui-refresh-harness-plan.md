# Phase 3C BCM-ASYNC-003 UI Refresh Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 `RealMessageService` 的最小仓颉样本补齐 UI 刷新语义 Harness，拿到 `BCM-ASYNC-003` 在 Staging-Core 无头环境下的 `Conditional Pass` 级证据。

**Architecture:** 在现有 `samples/real-message-service-cache-001` 包中引入 `Mock observer + main-context dispatcher + pending refresh queue` 三件套；Service 仍在 worker 上执行 adapter/cache 重操作，但所有 UI 数据集刷新都必须经过显式的 main-context dispatch，再由 `MockUiObserver` 收到 `onDatasetChanged`。测试将断言“worker 不直接改 UI”“main drain 后恰好收到一次刷新”“数据集快照与 cache 保持一致”。

**Tech Stack:** Cangjie `cjpm test`、`ThreadLocal<String>`、`Mutex`、`spawn().get()`、`std.unittest`。

---

### Task 1: 写出 BCM-ASYNC-003 红测

**Files:**
- Create: `samples/real-message-service-cache-001/src/ui_refresh_behavior_test.cj`
- Modify: `docs/phase-03-behavior-contract-matrix-realmessageservice.md`

- [ ] **Step 1: 写出 fetch 路径红测**

```cj
@TestCase
public func fetchShouldDispatchDatasetRefreshToMockUiOnMainContext(): Unit {
    let peerId = PeerId(0, 4001)
    let adapter = FakeMessageAdapter()
    adapter.seedHistory(peerId, buildHistory(peerId))
    let observer = MockUiDatasetObserver()
    let bridge = MainContextDatasetRefreshBridge(observer)
    let service = RealMessageService(adapter)
    service.attachRefreshBridge(bridge)

    _ = runWorkerGetMessages(service, peerId, 2, "worker-fetch-ui")
    assertEqual("worker 完成后尚未 main-dispatch，因此 UI 不应提前刷新", "", 0, observer.notificationCount())
    assertEqual("worker 完成后应存在 1 个待派发刷新事件", "", 1, bridge.pendingRefreshCount())

    bridge.drainOnMain()
    assertEqual("main drain 后 UI 必须收到一次刷新", "", 1, observer.notificationCount())
    assertEqual("UI 刷新必须发生在 main context", "", "main", observer.lastDeliveryContext())
}
```

- [ ] **Step 2: 写出 send 路径红测**

```cj
@TestCase
public func sendShouldDispatchUpdatedDatasetToMockUiOnMainContext(): Unit {
    let peerId = PeerId(0, 4002)
    ...
    _ = runWorkerGetMessages(service, peerId, 2, "worker-warmup-ui")
    bridge.drainOnMain()
    _ = runWorkerSendMessage(service, peerId, "ui-outbound", "worker-send-ui")

    assertEqual("worker-send 后不得直接越线程修改 UI", "", 1, observer.notificationCount())
    assertEqual("send 完成后应排队 1 个新的刷新事件", "", 1, bridge.pendingRefreshCount())

    bridge.drainOnMain()
    assertEqual("main drain 后 UI 应看到 3 条消息", "", 3, observer.lastDatasetSize())
    assertEqual("刷新后的尾消息必须与发送结果一致", "", "ui-outbound", observer.lastMessageText())
}
```

- [ ] **Step 3: 跑红，确认当前缺少 observer/dispatcher 能力**

Run: `cd samples/real-message-service-cache-001 && cjpm test`
Expected: FAIL，错误集中在 `MockUiDatasetObserver` / `MainContextDatasetRefreshBridge` / `attachRefreshBridge` / `drainOnMain` 等能力未实现。

### Task 2: 补齐 mock observer / dispatcher / dispatch semantics

**Files:**
- Modify: `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`

- [ ] **Step 1: 定义最小 UI 刷新契约**

```cj
public interface DatasetRefreshObserver {
    func onDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>): Unit
}

public interface DatasetRefreshBridge {
    func notifyDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>): Unit
}
```

- [ ] **Step 2: 实现 main-context bridge 与 mock observer**

```cj
public class MainContextDatasetRefreshBridge <: DatasetRefreshBridge {
    public func pendingRefreshCount(): Int64
    public func drainOnMain(): Unit
    public func debugDispatchLog(): Array<String>
}

public class MockUiDatasetObserver <: DatasetRefreshObserver {
    public func notificationCount(): Int64
    public func lastDatasetSize(): Int64
    public func lastMessageText(): String
    public func lastDeliveryContext(): String
}
```

- [ ] **Step 3: 让 Service 通过 bridge 发布刷新而不是直接改 UI**

```cj
private let refreshBridge: DatasetRefreshBridge

public func attachRefreshBridge(bridge: DatasetRefreshBridge): Unit
private func publishDatasetChanged(peerId: PeerId, messages: Array<DomainMessage>): Unit
```

### Task 3: 取证并回写

**Files:**
- Modify: `docs/phase-03-behavior-contract-matrix-realmessageservice.md`
- Modify: `.claude/status/current-phase.md`
- Create: `artifacts/behavior_runs/phase03-bcm-async-003-ui-refresh/summary.json`
- Create: `artifacts/behavior_runs/phase03-bcm-async-003-ui-refresh/cjpm-test.log`

- [ ] **Step 1: 跑全量测试**

Run: `cd samples/real-message-service-cache-001 && cjpm test`
Expected: PASS，并覆盖包 A / B / C / BCM-ASYNC-003 新增用例。

- [ ] **Step 2: 落盘摘要证据**

```json
{
  "label": "phase03-bcm-async-003-ui-refresh",
  "package_root": "samples/real-message-service-cache-001",
  "contracts": ["BCM-ASYNC-003"],
  "result": "pending",
  "limitations": ["Conditional Pass only; no real Harmony ArkUI runtime"]
}
```

- [ ] **Step 3: 回写行为矩阵与状态板**

把 `BCM-ASYNC-003` 更新为“在 `Mock observer + main-context dispatcher` 口径下已取得 Conditional Pass”，同时明确说明：这不是 Harmony 真 UI 引擎的 Full Pass 证据。

