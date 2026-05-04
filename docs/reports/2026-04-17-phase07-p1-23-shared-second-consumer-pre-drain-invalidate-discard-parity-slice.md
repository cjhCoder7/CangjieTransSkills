# 2026-04-17 Phase07 P1-23 Shared Second-Consumer Pre-Drain Invalidate Discard Parity Slice

## Goal

Freeze the next bounded shared-harness continuation slice by proving that the Phase07 shared second consumer can reuse the existing public `debugInvalidateCache(...)` surface to discard an already-triggered but not-yet-drained fetch, then refetch replacement history without widening shared helper/API, shared service semantics, or Telegram app-shell scope.

## Decision

- why this slice is still smaller than a new Telegram consume slice:
  - it closes with one additional regression in `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj`
  - it reuses only the existing public `getMessages(...)`, `debugInvalidateCache(...)`, `debugDrainPromiseResolutions()`, `MessageSignal.currentSnapshot()`, and `MainContextDatasetRefreshBridge` surface
  - it does not touch `telegram_app_shell.cj`, `telegram_ui_slice.cj`, router/page/controller, or shared-harness production source
- boundary distinction:
  - `P1-22` proved invalidate/refetch parity only after the first fetch had already drained into a warmed signal
  - `P1-23` stops one step earlier and only locks the public pre-drain contract: old pending fetch must be discarded after invalidate, replacement fetch must become the only valid dataset handoff, and the old held signal must stay unpolluted
- regression lock:
  - `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldDiscardPreDrainFetchWhenSecondConsumerInvalidates`
  - no production-code widening was required in this round

## Consumption Direction

- the new bounded case triggers a first shared `getMessages(...)` call against payload `A` but intentionally does not call `debugDrainPromiseResolutions()`
- while that first fetch is still in the pre-drain window, the case invalidates through `debugInvalidateCache(peerId)`, reseeds the adapter with payload `B`, and creates a replacement signal through a second `getMessages(...)`
- the case proves that both old and replacement signals are still empty before replacement drain, that only one replacement refresh enters the pending queue after drain, that the old held signal remains empty, and that `main-context drain` delivers only payload `B`

## Why This Round Stops Here

- `P1-23` only proves second-consumer pre-drain invalidate discard parity on top of the already-landed shared fetch/send/signal/invalidate path.
- This round does not touch `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`, does not touch `telegram_app_shell.cj` / `telegram_ui_slice.cj` / router/page/controller, does not add delayed handoff control / dispatch log assertions / runtimeId / updateVersion / observeRuntime, and does not reopen cache runtime/no-deadlock or compile-budget decisions.
- Because no shared-harness or Telegram consumer source moved, the canonical Telegram build/runtime evidence remains inherited from `P1-19`; this round only refreshes the cache-sample canonical build gate.
- This round remains exploratory-only continuation work inside `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.

## Verification

- `cd samples/real-message-service-cache-001 && cjpm test`
  - exit `0`
  - `TOTAL: 30`, `PASSED: 30`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-shared-p1-23-second-consumer-pre-drain-invalidate-discard-parity/cache-cjpm-test.log`
- inherited Telegram evidence:
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - latest green checkpoint remains `P1-19` with `TOTAL: 18`, `PASSED: 18`, `FAILED: 0`

## Runtime Artifact

- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-23-second-consumer-pre-drain-invalidate-discard-parity/`
- inherited Telegram evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/`

## Outcome

- `P1-23` now proves that the Phase07 shared second consumer can invalidate a pre-drain fetch window through the existing public `debugInvalidateCache(...)` surface, discard the old pending fetch before it ever reaches the signal or observer, and then refetch replacement history as the only valid handoff.
- The slice remains smaller than any new Telegram app-shell consume extension: it is a shared-harness regression lock only, built on the existing shared service surface, with no new shared helper/API and no new Telegram consume contract.
