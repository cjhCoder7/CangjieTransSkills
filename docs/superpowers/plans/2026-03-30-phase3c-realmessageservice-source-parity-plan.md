# Phase 3C RealMessageService Source Parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让 `RealMessageService` 的 public API 从当前 Harness 形态回归 ArkTS 源侧签名心智，并用红灯测试先钉住当前偏差。

**Architecture:** 先不改绿灯实现，先通过新的 source parity 红灯测试把 `getMessages` 与 `sendMessage` 的公开签名偏差显性化。随后在实现阶段再把 V5/V6 的强并发内核下沉到 `private` / `internal`，对外恢复 ArkTS 对齐的 public 面。

**Tech Stack:** Cangjie `cjpm test`、`std.unittest`、`raw_docs/telegramharmony-phase02` 源码对账、Staging-Core Harness

---

### Task 1: 写 source parity 红灯测试

**Files:**
- Create: `samples/real-message-service-cache-001/src/source_parity_signature_test.cj`
- Reference: `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:74`
- Reference: `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:111`

- [ ] 写 `getMessagesShouldExposeSignalLikePublicShape`
- [ ] 写 `sendMessageShouldAcceptSourceAlignedParamsBag`
- [ ] 跑 `cd samples/real-message-service-cache-001 && cjpm test`
- [ ] 记录红灯必须集中在“公开签名不对齐”，而不是无关语法错误

### Task 2: 做 public signature source parity 收口

**Files:**
- Modify: `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`
- Modify: `samples/real-message-service-cache-001/src/cache_behavior_test.cj`
- Modify: `samples/real-message-service-cache-001/src/ui_refresh_behavior_test.cj`
- Modify: `samples/real-message-service-cache-001/src/concurrency_pressure_test.cj`
- Modify: `samples/real-message-service-cache-001/src/delayed_handoff_interruptions_test.cj`
- Modify: `samples/real-message-service-cache-001/src/double_fetch_invalidation_test.cj`
- Modify: `samples/real-message-service-cache-001/src/domain_purity_test.cj`

- [ ] 让 `sendMessage` public 面回到 `params` 形态
- [ ] 让 `getMessages` public 面至少具备 source-aligned signal-like 外壳
- [ ] 把 `debug*` 能力收回 internal test seam 或明确隔离为 harness-only 扩展

### Task 3: 回归 V5 / V6 / 包 A-B-C

**Files:**
- Modify: `docs/phase-03-behavior-contract-matrix-realmessageservice.md`
- Create: `docs/traces/trace-phase-03-v7-source-parity.md`

- [ ] 跑全量 `cjpm test`
- [ ] 跑 `timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'`
- [ ] 回写 `BCM-ALIGN-001` / `BCM-ALIGN-002` 的验证状态
