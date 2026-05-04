# Phase 3C Package C Concurrency Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 `samples/real-message-service-cache-001` 增加最小并发压力 Harness，给 `BCM-CONC-001/002/003` 产出可重复的 Conditional Pass 级证据。

**Architecture:** 继续复用现有 `RealMessageService` 最小样本包，不直接改动真实候选源码；在 Harness 中补入 `Mutex + ThreadLocal context tag + trace log + concurrency probe adapter`，通过 worker 预热缓存、混合并发 `sendMessage/getMessages`、以及线程上下文日志断言来证明“共享状态串行化”“结果稳定”“重操作不在 main context”。

**Tech Stack:** Cangjie `cjpm test`、`std.sync.Mutex`、`spawn().get()`、`ThreadLocal<T>`、现有 `std.unittest`。

---

### Task 1: 落盘并发红测

**Files:**
- Create: `samples/real-message-service-cache-001/src/concurrency_pressure_test.cj`
- Modify: `docs/phase-03-behavior-contract-matrix-realmessageservice.md`

- [ ] **Step 1: 写出失败测试，锁定 BCM-CONC 目标**

```cj
@TestCase
public func concurrentSendAndReadShouldKeepCacheConsistent(): Unit {
    let peerId = PeerId(0, 3001)
    let adapter = ConcurrencyProbeAdapter(artificialSpin: 4000)
    adapter.seedHistory(peerId, buildHistory(peerId))
    let service = RealMessageService(adapter)

    runWorkerGetMessages(service, peerId, 2, "worker-warmup")
    runConcurrentBurst(service, peerId, sendWorkers: 48, readWorkers: 32)

    let snapshot = service.debugCachedMessages(peerId)
    assertEqual("压测后缓存 size 必须稳定", "", 50, snapshot.size)
    assertAllBurstMessagesPresent(snapshot, 48)
}
```

- [ ] **Step 2: 跑单测，确认当前会红**

Run: `cd samples/real-message-service-cache-001 && cjpm test`
Expected: FAIL，原因应是 `ConcurrencyProbeAdapter` / `debugCachedMessages` / `runConcurrentBurst` 等并发能力尚未实现。

### Task 2: 补齐最小并发实现

**Files:**
- Modify: `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`

- [ ] **Step 1: 给 Harness 增加并发能力**

```cj
private let EXECUTION_CONTEXT = ThreadLocal<String>()

func setExecutionContext(label: String): Unit {
    EXECUTION_CONTEXT.set(label)
}

func currentExecutionContext(): String {
    match (EXECUTION_CONTEXT.get()) {
        case Some(value) => value
        case None => "main"
    }
}
```

- [ ] **Step 2: 让 `RealMessageService` 具备可解释的串行化策略**

```cj
private let cacheLock = Mutex()
private let traceLock = Mutex()
private var traceLog = emptyStrings()

private func appendTrace(entry: String): Unit {
    this.traceLock.lock()
    this.traceLog = appendString(this.traceLog, entry)
    this.traceLock.unlock()
}
```

- [ ] **Step 3: 增加并发探针适配器与 debug API**

```cj
public class ConcurrencyProbeAdapter <: IMTProtoAdapter {
    public func debugInvocationLog(): Array<String>
}

public func debugCachedMessages(peerId: PeerId): Array<DomainMessage>
public func debugThreadLog(): Array<String>
```

### Task 3: 取证并回写

**Files:**
- Modify: `docs/phase-03-behavior-contract-matrix-realmessageservice.md`
- Modify: `.claude/status/current-phase.md`
- Create: `artifacts/behavior_runs/phase03-package-c-concurrency/summary.json`
- Create: `artifacts/behavior_runs/phase03-package-c-concurrency/cjpm-test.log`

- [ ] **Step 1: 跑全量样本测试**

Run: `cd samples/real-message-service-cache-001 && cjpm test`
Expected: PASS，至少覆盖包 A / 包 B / 包 C。

- [ ] **Step 2: 落盘摘要证据**

```json
{
  "label": "phase03-package-c-concurrency",
  "package_root": "samples/real-message-service-cache-001",
  "test_command": "cd samples/real-message-service-cache-001 && cjpm test",
  "contracts": ["BCM-CONC-001", "BCM-CONC-002", "BCM-CONC-003"],
  "result": "pending"
}
```

- [ ] **Step 3: 回写行为矩阵与状态板**

在 `docs/phase-03-behavior-contract-matrix-realmessageservice.md` 明确标注：本轮线程边界证据来自 `ThreadLocal worker label + spawn stress harness`，属于 `Conditional Pass` 级，不代表真实 Harmony UI thread 已闭环。

