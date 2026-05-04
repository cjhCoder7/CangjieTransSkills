# Phase 3C RealMessageService Signal Runtime V10 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不发明新 public API 的前提下，把 `MessageSignal` 的运行时语义推进到“持续实例 + 连续更新 + invalidate 后摘除旧实例”的 V10 状态。

**Architecture:** 保持现有 source-aligned public surface 不变，只在 `MessageSignal` 内新增同包内部可见的 runtime seam（实例 ID、版本号、内部 observer）。通过红灯测试证明 signal 的复用、更新与摘除行为，再用 Linux `cjpm test` 和 `timeout 5s` 守住 V5~V9 的既有证据。

**Tech Stack:** Cangjie `cjpm test`、Linux SDK `cjpm`、`std.sync.Mutex`、同包内部 observer seam、public surface 白名单脚本

---

### Task 1: 写 V10 设计与红灯测试

**Files:**
- Create: `docs/superpowers/specs/2026-03-30-phase3c-realmessageservice-signal-runtime-v10-design.md`
- Create: `samples/real-message-service-cache-001/src/signal_runtime_v10_test.cj`
- Reference: `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:74`
- Reference: `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:107`
- Reference: `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:127`

- [ ] 写 `samePeerShouldReuseSignalInstanceUntilInvalidation`
- [ ] 写 `signalVersionShouldAdvanceMonotonicallyAcrossFetchAndSend`
- [ ] 写 `invalidateShouldDetachOldSignalFromFutureUpdates`
- [ ] 跑 `cjpm test`，确认红灯集中在缺失的 runtime seam

### Task 2: 实现 internal signal runtime seam

**Files:**
- Modify: `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`
- Modify: `samples/real-message-service-cache-001/src/signal_runtime_v10_test.cj`

- [ ] 给 `MessageSignal` 增加 internal `runtimeId()`
- [ ] 给 `MessageSignal` 增加 internal `updateVersion()`
- [ ] 给 `MessageSignal` 增加 internal `observeRuntime(observer)`
- [ ] 确保 callback 在锁外执行，不引入自锁风险

### Task 3: 回归 invalidate / reuse / update 语义

**Files:**
- Modify: `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`
- Reference: `samples/real-message-service-cache-001/src/source_semantics_v9_test.cj`
- Reference: `samples/real-message-service-cache-001/src/double_fetch_invalidation_test.cj`

- [ ] 证明 invalidation 后新 signal 是新实例
- [ ] 证明旧 signal 的 observer 不再接收新事件
- [ ] 保持 `debugInvalidateCache()`、V6 Double Fetch 与 V9 first-signal-fetch 全部不回归

### Task 4: Linux 验证与回写

**Files:**
- Modify: `docs/phase-03-behavior-contract-matrix-realmessageservice.md`
- Create: `docs/traces/trace-phase-03-v10-signal-runtime.md`
- Create: `artifacts/behavior_runs/phase03-v10-signal-runtime-red/summary.json`
- Create: `artifacts/behavior_runs/phase03-v10-signal-runtime-green/summary.json`

- [ ] 跑 `python scripts/phase3_source_alignment_asserts.py --target-file samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`
- [ ] 跑 `cd samples/real-message-service-cache-001 && cjpm test`
- [ ] 跑 `timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'`
- [ ] 回写 V10 signal runtime 契约与 artifact
