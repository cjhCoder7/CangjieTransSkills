# 2026-04-17 Phase07 P1-27 Shared Second-Consumer Warm-Send Repeated-Get Reuse-No-Refetch Parity Slice

## Goal

Freeze the next bounded shared-harness continuation slice by proving that the Phase07 shared second consumer can reuse the existing public `getMessages(...)`, `sendMessage(...)`, `debugDrainPromiseResolutions()`, `MessageSignal.currentSnapshot()`, and `MainContextDatasetRefreshBridge` surface so that a warm same-peer send can be followed by a repeated same-peer read that still reuses the appended signal/cache without refetching history.

## Decision

- landing path:
  - `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj`
  - `specs/phase07-telegram-ui-incubation/tasks.md`
  - `docs/status/INDEX.md`
  - `docs/current_state.v2.md`
  - `docs/runtime_contract.v2.md`
  - `docs/status/current_task_handoff.md`
- why this slice is still smaller than a new Telegram consume slice:
  - it closes with one additional regression in `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj`
  - it reuses only the existing public `getMessages(...)`, `sendMessage(...)`, `debugDrainPromiseResolutions()`, `MessageSignal.currentSnapshot()`, `MainContextDatasetRefreshBridge.pendingRefreshCount()`, and `MainContextDatasetRefreshBridge.drainOnMain()` surface
  - it does not touch `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`, `telegram_app_shell.cj`, `telegram_ui_slice.cj`, router/page/controller, or any Telegram consume source
- boundary distinction:
  - `P1-25` proved same-peer repeated get reuse/no-refetch parity only on top of warmed remote history before any send happens
  - `P1-26` proved warm send append-without-refetch parity but explicitly stopped short of turning the second `getMessages(...)` into that slice's main contract
  - `P1-27` closes the next smallest public edge: once warm send has already appended payload to the warmed signal/cache, a repeated same-peer read must continue to reuse that appended state without a second history pull or extra queued refresh
- regression lock:
  - `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldReuseWarmSendSnapshotOnRepeatedSamePeerGetWithoutRefetch`
  - no production-code widening was required in this round
  - the new regression passed immediately against the existing shared public surface, so this slice lands as a pure contract-freeze rather than an implementation expansion

## Consumption Direction

- the new bounded case attaches `MainContextDatasetRefreshBridge`, performs the first same-peer shared `getMessages(...)`, drains fetch promise resolution, and drains the queued warmup refresh on main
- the case then issues a warm shared `sendMessage(...)` on that same `peerId`, confirms the existing signal has already appended the send payload, and keeps observer delivery main-gated with exactly one queued refresh
- before that queued send refresh is drained on main, the case performs a second same-peer shared `getMessages(...)` and proves that:
  - the entire chain still keeps `adapter.getHistoryCallCount()` pinned at `1`
  - the second snapshot continues to expose the append-after-send payload rather than an empty snapshot or refetched remote history
  - observer delivery count does not increase and the pending queue does not gain a second queued refresh

## Why This Round Stops Here

- `P1-27` only proves second-consumer warm-send repeated-get reuse/no-refetch parity on top of the already-landed shared fetch/send/invalidate path.
- This round does not touch `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`, does not touch `telegram_app_shell.cj` / `telegram_ui_slice.cj` / router/page/controller, does not add `debugDispatchLog`, `runtimeId`, `updateVersion`, `observeRuntime`, delayed handoff control, stale-dispatch probe-only assertions, or reopen cache runtime/no-deadlock or compile-budget decisions.
- Because no shared-harness or Telegram consumer source moved, the canonical Telegram build/runtime evidence remains inherited from `P1-19`; this round only refreshes the cache-sample canonical build gate.
- This round remains exploratory-only continuation work inside `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.

## Verification

- `cd samples/real-message-service-cache-001 && cjpm test`
  - exit `0`
  - `TOTAL: 34`, `PASSED: 34`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-shared-p1-27-second-consumer-warm-send-repeated-get-reuse-no-refetch-parity/cache-cjpm-test.log`
- inherited Telegram evidence:
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - latest green checkpoint remains `P1-19` with `TOTAL: 18`, `PASSED: 18`, `FAILED: 0`

## Runtime Artifact

- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-27-second-consumer-warm-send-repeated-get-reuse-no-refetch-parity/`
- inherited Telegram evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/`

## Outcome

- `P1-27` now proves that the Phase07 shared second consumer can warm the same-peer signal with remote history once, append a warm `sendMessage(...)` payload onto that warmed signal/cache, and then let a repeated same-peer `getMessages(...)` reuse the already-appended state while keeping `adapter.getHistoryCallCount()` pinned at `1`, observer delivery main-gated, and the pending queue bounded to the single send refresh.
- The slice remains smaller than any new Telegram app-shell consume extension: it is a shared-harness regression lock only, built on the existing shared service surface, with no new shared helper/API and no new Telegram consume contract.
