# 2026-04-17 Phase07 P1-24 Shared Second-Consumer Cold-Send Seeded Pre-Drain Fetch Parity Slice

## Goal

Freeze the next bounded shared-harness continuation slice by proving that the Phase07 shared second consumer can reuse the existing public `sendMessage(...)`, `getMessages(...)`, `MessageSignal.currentSnapshot()`, and `debugDrainPromiseResolutions()` surface so that a cold local send can seed cache before the first fetch drain without widening shared helper/API, shared service semantics, or Telegram app-shell scope.

## Decision

- why this slice is still smaller than a new Telegram consume slice:
  - it closes with one additional regression in `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj`
  - it reuses only the existing public `sendMessage(...)`, `getMessages(...)`, `MessageSignal.currentSnapshot()`, `debugDrainPromiseResolutions()`, and `MainContextDatasetRefreshBridge` surface
  - it does not touch `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`, `telegram_app_shell.cj`, `telegram_ui_slice.cj`, router/page/controller, or any Telegram consume source
- boundary distinction:
  - `P1-23` proved pre-drain invalidate can discard an old pending fetch and keep only the replacement handoff
  - `P1-24` stops on a different public edge: a cold send can seed cache first, the first `getMessages(...)` still fetches remote history once, but the signal must expose the seeded local snapshot until fetch promise drain completes
- regression lock:
  - `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldExposeColdSendSeedBeforeFirstFetchDrain`
  - no production-code widening was required in this round

## Consumption Direction

- the new bounded case seeds remote history `A`, creates the shared service without attaching a refresh bridge, and performs a cold `sendMessage(...)` so the cache is seeded locally without re-running the already-landed send-dispatch parity contract
- the case then attaches `MainContextDatasetRefreshBridge`, performs the first shared `getMessages(...)`, and proves that:
  - the first `getMessages(...)` still triggers exactly one remote `adapter.getHistory(...)`
  - before `debugDrainPromiseResolutions()`, the signal exposes exactly the locally seeded send result
  - after promise drain, the same signal switches to remote history `A`
  - if the bridge participates, observer delivery remains main-gated and the pending queue drains back to empty

## Why This Round Stops Here

- `P1-24` only proves second-consumer cold-send seeded pre-drain fetch parity on top of the already-landed shared fetch/send/signal/invalidate path.
- This round does not touch `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`, does not touch `telegram_app_shell.cj` / `telegram_ui_slice.cj` / router/page/controller, does not add runtime probes or delayed handoff controls, and does not reopen cache runtime/no-deadlock or compile-budget decisions.
- Because no shared-harness or Telegram consumer source moved, the canonical Telegram build/runtime evidence remains inherited from `P1-19`; this round only refreshes the cache-sample canonical build gate.
- This round remains exploratory-only continuation work inside `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.

## Verification

- `cd samples/real-message-service-cache-001 && cjpm test`
  - exit `0`
  - `TOTAL: 31`, `PASSED: 31`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-shared-p1-24-second-consumer-cold-send-seeded-pre-drain-fetch-parity/cache-cjpm-test.log`
- inherited Telegram evidence:
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - latest green checkpoint remains `P1-19` with `TOTAL: 18`, `PASSED: 18`, `FAILED: 0`

## Runtime Artifact

- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-24-second-consumer-cold-send-seeded-pre-drain-fetch-parity/`
- inherited Telegram evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/`

## Outcome

- `P1-24` now proves that the Phase07 shared second consumer can let a cold `sendMessage(...)` seed cache first, still trigger the first remote fetch on the first `getMessages(...)`, expose the seeded local snapshot until promise drain completes, and then switch the signal to remote history while keeping observer delivery main-gated.
- The slice remains smaller than any new Telegram app-shell consume extension: it is a shared-harness regression lock only, built on the existing shared service surface, with no new shared helper/API and no new Telegram consume contract.
