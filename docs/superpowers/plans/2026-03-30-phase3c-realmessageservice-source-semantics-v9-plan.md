# Phase 3C RealMessageService Source Semantics V9 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 `RealMessageService` 的 `messageSignals / fetchMessages / sendMessage` 收平到更接近 ArkTS source semantics 的状态，并用新的红灯测试与静态断言把偏差钉死。

**Architecture:** 采用最小 source semantics 收平方案：`getMessages` 以“signal 是否首次创建”为 fetch 触发条件，`fetchMessages` 改走 internal params bag，`sendMessage` 继续沿用 source-aligned public 签名并补强乐观 signal 更新测试。V5/V6/V7 的并发内核保持不动，只允许在 internal 层换接线。

**Tech Stack:** Cangjie `cjpm test`、Linux SDK `cjpm`、Python 静态断言脚本、`raw_docs/telegramharmony-phase02` 对账、Staging-Core Harness

---

### Task 1: 写 V9 设计与红灯

**Files:**
- Create: `docs/superpowers/specs/2026-03-30-phase3c-realmessageservice-source-semantics-v9-design.md`
- Create: `scripts/phase3_source_semantics_asserts.py`
- Create: `samples/real-message-service-cache-001/src/source_semantics_v9_test.cj`
- Reference: `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:74`
- Reference: `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:86`
- Reference: `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:111`

- [ ] 写 V9 设计文档，明确 `messageSignals / fetchMessages / sendMessage` 三个目标
- [ ] 写 `phase3_source_semantics_asserts.py`，先打出 `fetchMessages(peerId, limit)` 的静态红灯
- [ ] 写 `firstSignalCreationShouldFetchEvenWhenCacheAlreadySeeded`，先打出运行时红灯
- [ ] 记录红灯必须集中在 source semantics 偏差，而不是无关语法错误

### Task 2: 实现最小 source semantics 收平

**Files:**
- Modify: `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`
- Modify: `samples/real-message-service-cache-001/src/cache_behavior_test.cj`
- Modify: `samples/real-message-service-cache-001/src/source_semantics_v9_test.cj`

- [ ] 新增 package-local `GetHistoryParams(peerId, limit)`
- [ ] 把 `fetchMessages` 改为 `private func fetchMessages(params: GetHistoryParams)`
- [ ] 把 `getMessages` 的 fetch 触发条件改成“signal first-create”
- [ ] 保持 `sendMessage(params)` public 面不变，只在 internal 路径上继续更新 cache / signal / publish

### Task 3: 守住 optimistic signal 与历史契约

**Files:**
- Modify: `samples/real-message-service-cache-001/src/source_semantics_v9_test.cj`
- Reference: `samples/real-message-service-cache-001/src/delayed_handoff_interruptions_test.cj`
- Reference: `samples/real-message-service-cache-001/src/double_fetch_invalidation_test.cj`

- [ ] 增加 `sendMessageShouldOptimisticallyUpdateExistingSignalBeforeUiDrain`
- [ ] 确认它不破坏 V5/V6 的 stale discard / no-leak 心智
- [ ] 保持现有 public API whitelist 不回归

### Task 4: Linux 物理验证与回写

**Files:**
- Modify: `docs/phase-03-behavior-contract-matrix-realmessageservice.md`
- Create: `docs/traces/trace-phase-03-v9-source-semantics.md`
- Create: `artifacts/behavior_runs/phase03-v9-source-semantics-red/summary.json`
- Create: `artifacts/behavior_runs/phase03-v9-source-semantics-green/summary.json`

- [ ] 跑 `python scripts/phase3_source_semantics_asserts.py --target-file samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`
- [ ] 跑 `cd samples/real-message-service-cache-001 && cjpm test`
- [ ] 跑 `timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'`
- [ ] 回写 `BCM-ALIGN-001` / `BCM-ALIGN-002` 与 V9 source semantics 证据
