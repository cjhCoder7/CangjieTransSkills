# Phase 3C Double Fetch Invalidation Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 `samples/real-message-service-cache-001` 中补出 `Double Fetch` 高压变体，用 `debugInvalidateCache + force refresh fetch` 验证缓存击穿、epoch 推高、stale handoff 丢弃与 strict stale-read 断言。

**Architecture:** 继续复用现有 `RealMessageService`、`DelayedHandoffProbeAdapter`、`MainContextDatasetRefreshBridge`。这次不再让 B 走 `sendMessage`，而是让 B 先执行 `debugInvalidateCache(peerId)` 强制击穿缓存，再走第二次 `getMessages()`，由 bridge 的 `epoch` 机制保证 stale A 在进入 UI 前被 discard；同时扩展 `MockUiDatasetObserver` 内部 delivery log，把“唯一有效 UI 载荷”做成可断言证据。

**Tech Stack:** Cangjie `cjpm test`、`std.sync.Mutex`、`HashMap.remove`、`ThreadLocal<String>`、`spawn().get()`、shell `timeout`

---

### Task 1: 先立 Double Fetch 红灯

**Files:**
- Create: `samples/real-message-service-cache-001/src/double_fetch_invalidation_test.cj`
- Modify: `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`

- [ ] 写 `debugInvalidateCache` 与 strict stale-read 的失败测试
- [ ] 跑 `cd samples/real-message-service-cache-001 && cjpm test`，确认失败点集中在缺失的 invalidate / observer log 能力

### Task 2: 实现缓存击穿与 epoch 推高

**Files:**
- Modify: `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`

- [ ] 给 `DatasetRefreshBridge` 增加 `debugForceAdvanceEpoch(reason)` 能力
- [ ] 在 `MainContextDatasetRefreshBridge` 中实现显式 epoch bump 与调试日志
- [ ] 在 `RealMessageService` 中实现 `debugInvalidateCache(peerId)`：抢占 cache 写锁、删除 peer cache、记录 trace、推动 bridge epoch

### Task 3: 收紧 observer 断言面

**Files:**
- Modify: `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`
- Modify: `samples/real-message-service-cache-001/src/double_fetch_invalidation_test.cj`

- [ ] 给 `MockUiDatasetObserver` 增加内部 delivery log
- [ ] 在 Double Fetch 测试中断言只有 B payload 进入 observer log，A 不得留下幽灵载荷

### Task 4: 物理验证与文档回写

**Files:**
- Modify: `docs/phase-03-behavior-contract-matrix-realmessageservice.md`
- Create: `docs/traces/trace-phase-03-v6-double-fetch-invalidation.md`
- Create: `artifacts/behavior_runs/phase03-v6-double-fetch-invalidation/summary.json`

- [ ] 跑 `cjpm test`，确认全量样本仍然全绿
- [ ] 跑 `timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'`，确认无死锁
- [ ] 回写 `BCM-ASYNC-006` / `BCM-CONC-006`（如最终编号采用新编号）与执行轨迹
