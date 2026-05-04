# 2026-04-17 Phase07 P1-26 Shared Second-Consumer Warm-Send Append-Without-Refetch Parity Slice

## Goal

Freeze the next bounded shared-harness continuation slice by proving that the Phase07 shared second consumer can reuse the existing public `getMessages(...)`, `sendMessage(...)`, `debugDrainPromiseResolutions()`, `MessageSignal.currentSnapshot()`, and `MainContextDatasetRefreshBridge` surface so that a warm same-peer send appends payload without widening shared helper/API, shared service semantics, or Telegram app-shell scope.

## Decision

- why this slice is still smaller than a new Telegram consume slice:
  - it closes with one additional regression in `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj`
  - it reuses only the existing public `getMessages(...)`, `sendMessage(...)`, `debugDrainPromiseResolutions()`, `MessageSignal.currentSnapshot()`, `attachRefreshBridge(...)`, and `MainContextDatasetRefreshBridge` surface
  - it does not touch `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`, `telegram_app_shell.cj`, `telegram_ui_slice.cj`, router/page/controller, or any Telegram consume source
- boundary distinction:
  - `P1-20` proved `worker send -> main-context dataset refresh dispatch` parity
  - `P1-21` proved optimistic signal parity before main drain
  - `P1-25` proved same-peer repeated `getMessages(...)` reuse/no-refetch parity
  - `P1-26` stops on a different public edge: once the same-peer signal has already warmed to remote history, a warm `sendMessage(...)` must append payload without triggering a second history pull
- regression lock:
  - `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldAppendWarmSendWithoutRefetchingHistory`
  - no production-code widening was required in this round
  - the new regression passed immediately against the existing shared public surface, so this slice lands as a pure contract-freeze rather than an implementation expansion

## Consumption Direction

- the new bounded case attaches `MainContextDatasetRefreshBridge`, performs the first same-peer shared `getMessages(...)`, drains fetch promise resolution, and drains the queued refresh on main
- the case then performs a warm shared `sendMessage(...)` on that same `peerId` and proves that:
  - the warmup fetch still triggers exactly one remote `adapter.getHistory(...)`
  - after promise drain, the warmed signal exposes remote history
  - the later warm send keeps `adapter.getHistoryCallCount()` at `1`
  - the warmed signal/cache now exposes only the append-after-send payload rather than a refetched remote history
  - observer delivery remains main-gated and the pending queue drains back to empty

## Why This Round Stops Here

- `P1-26` only proves second-consumer warm-send append-without-refetch parity on top of the already-landed shared fetch/send/invalidate path.
- This round does not touch `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`, does not touch `telegram_app_shell.cj` / `telegram_ui_slice.cj` / router/page/controller, does not add runtime probes or delayed handoff controls, and does not reopen cache runtime/no-deadlock or compile-budget decisions.
- Because no shared-harness or Telegram consumer source moved, the canonical Telegram build/runtime evidence remains inherited from `P1-19`; this round only refreshes the cache-sample canonical build gate.
- This round remains exploratory-only continuation work inside `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.

## Verification

- `cd samples/real-message-service-cache-001 && cjpm test`
  - exit `0`
  - `TOTAL: 33`, `PASSED: 33`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-shared-p1-26-second-consumer-warm-send-append-without-refetch-parity/cache-cjpm-test.log`
- inherited Telegram evidence:
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - latest green checkpoint remains `P1-19` with `TOTAL: 18`, `PASSED: 18`, `FAILED: 0`

## Runtime Artifact

- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-26-second-consumer-warm-send-append-without-refetch-parity/`
- inherited Telegram evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/`

## Outcome

- `P1-26` now proves that the Phase07 shared second consumer can warm the same-peer signal with remote history once, later append a warm `sendMessage(...)` payload onto that warmed signal/cache, keep `adapter.getHistoryCallCount()` pinned at `1`, and still preserve main-gated observer delivery.
- The slice remains smaller than any new Telegram app-shell consume extension: it is a shared-harness regression lock only, built on the existing shared service surface, with no new shared helper/API and no new Telegram consume contract.
