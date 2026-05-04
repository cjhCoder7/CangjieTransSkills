# 2026-04-17 Phase07 P1-25 Shared Second-Consumer Same-Peer Repeated Get Reuse-No-Refetch Parity Slice

## Goal

Freeze the next bounded shared-harness continuation slice by proving that the Phase07 shared second consumer can reuse the existing public `getMessages(...)`, `debugDrainPromiseResolutions()`, `MessageSignal.currentSnapshot()`, and `MainContextDatasetRefreshBridge` surface so that a repeated same-peer read reuses the warmed signal/cache without widening shared helper/API, shared service semantics, or Telegram app-shell scope.

## Decision

- why this slice is still smaller than a new Telegram consume slice:
  - it closes with one additional regression in `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj`
  - it reuses only the existing public `getMessages(...)`, `debugDrainPromiseResolutions()`, `MessageSignal.currentSnapshot()`, `attachRefreshBridge(...)`, and `MainContextDatasetRefreshBridge` surface
  - it does not touch `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`, `telegram_app_shell.cj`, `telegram_ui_slice.cj`, router/page/controller, or any Telegram consume source
- boundary distinction:
  - `P1-24` proved a cold local send can seed cache before the first fetch drain while the signal later switches to remote history
  - `P1-25` stops on a different public edge: after the first same-peer `getMessages(...)` has already warmed the signal with remote history, a second same-peer read must reuse that warmed state and must not trigger a second fetch or refresh delivery
- regression lock:
  - `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldReuseWarmSecondConsumerSignalWithoutRefetch`
  - no production-code widening was required in this round
  - the new regression passed immediately against the existing shared public surface, so this slice lands as a pure contract-freeze rather than an implementation expansion

## Consumption Direction

- the new bounded case attaches `MainContextDatasetRefreshBridge`, performs the first same-peer shared `getMessages(...)`, drains fetch promise resolution, and drains the queued refresh on main
- the case then performs a second shared `getMessages(...)` on the same `peerId` and proves that:
  - the first same-peer read triggers exactly one remote `adapter.getHistory(...)`
  - after promise drain, the warmed signal exposes remote history
  - the second same-peer read keeps `adapter.getHistoryCallCount()` at `1`
  - the second snapshot still exposes the already-warmed remote history rather than an empty snapshot or new payload
  - observer delivery count does not increase and the pending queue remains empty

## Why This Round Stops Here

- `P1-25` only proves second-consumer same-peer repeated get reuse/no-refetch parity on top of the already-landed shared fetch/send/invalidate path.
- This round does not touch `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`, does not touch `telegram_app_shell.cj` / `telegram_ui_slice.cj` / router/page/controller, does not add runtime probes or delayed handoff controls, and does not reopen cache runtime/no-deadlock or compile-budget decisions.
- Because no shared-harness or Telegram consumer source moved, the canonical Telegram build/runtime evidence remains inherited from `P1-19`; this round only refreshes the cache-sample canonical build gate.
- This round remains exploratory-only continuation work inside `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.

## Verification

- `cd samples/real-message-service-cache-001 && cjpm test`
  - exit `0`
  - `TOTAL: 32`, `PASSED: 32`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-shared-p1-25-second-consumer-same-peer-repeated-get-reuse-no-refetch-parity/cache-cjpm-test.log`
- inherited Telegram evidence:
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - latest green checkpoint remains `P1-19` with `TOTAL: 18`, `PASSED: 18`, `FAILED: 0`

## Runtime Artifact

- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-25-second-consumer-same-peer-repeated-get-reuse-no-refetch-parity/`
- inherited Telegram evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/`

## Outcome

- `P1-25` now proves that the Phase07 shared second consumer can reuse the warmed same-peer `MessageSignal` / cache pair after the first fetch drain, keep the second read on the already-warmed remote history, avoid a second `adapter.getHistory(...)`, and avoid any extra main-gated refresh delivery.
- The slice remains smaller than any new Telegram app-shell consume extension: it is a shared-harness regression lock only, built on the existing shared service surface, with no new shared helper/API and no new Telegram consume contract.
