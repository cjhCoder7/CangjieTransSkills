# 2026-04-17 Phase07 P1-22 Shared Second-Consumer Invalidate/Refetch Parity Slice

## Goal

Freeze the next bounded shared-harness continuation slice by proving that the Phase07 shared second consumer can reuse the existing public `debugInvalidateCache(...)` surface to invalidate a warmed cache/signal pair and refetch replacement history without widening shared helper/API, shared service semantics, or Telegram app-shell scope.

## Scout Decision

- why this slice is still smaller than a new Telegram consume slice:
  - it closes with one additional regression in `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj`
  - it reuses only the existing public `getMessages(...)`, `debugDrainPromiseResolutions()`, `debugInvalidateCache(...)`, `MessageSignal.currentSnapshot()`, and `MainContextDatasetRefreshBridge` surface
  - it does not touch `telegram_app_shell.cj`, `telegram_ui_slice.cj`, router/page/controller, or shared-harness production source
- why it is a valid continuation after `P1-21`:
  - `P1-20` locked `worker send -> main-context drain` refresh-dispatch parity
  - `P1-21` locked `worker send -> optimistic signal snapshot before main drain`
  - `P1-22` stays on the same shared-harness rail and only extends the second-consumer regression to the next smallest public invalidation/refetch contract

## Decision

- landing path:
  - `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj`
  - `docs/reports/2026-04-15-phase07-p0-3-verification-contract.md`
  - `specs/phase07-telegram-ui-incubation/tasks.md`
  - `docs/status/INDEX.md`
  - `docs/current_state.v2.md`
  - `docs/runtime_contract.v2.md`
  - `docs/status/current_task_handoff.md`
- boundary distinction:
  - `P1-21` stopped at `worker send -> optimistic signal snapshot before main drain`
  - `P1-22` does not add any new send helper, delayed-handoff control, dispatch-log inspection, or Telegram consume behavior; it only proves that a warmed second-consumer signal can be invalidated and replaced through the existing shared invalidation surface
- consumption direction:
  - the new bounded case warms a first shared signal to history `A` and intentionally leaves the first dataset refresh main-gated
  - it then reseeds the adapter with history `B`, invalidates through `debugInvalidateCache(...)`, creates a replacement signal, drains the replacement fetch, and finally drains on main
  - the case proves that the old held signal stays detached on `A`, the replacement signal restarts from an empty snapshot and refetches `B`, and the observer only sees the new valid `B` payload once main-context drain happens
- regression lock:
  - `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldRefetchSecondConsumerAfterInvalidate`
  - no production-code widening was required in this round

## Why This Round Stops Here

- `P1-22` only proves second-consumer invalidate/refetch parity on top of the already-landed shared fetch/send/signal path.
- This round does not touch `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`, does not touch `telegram_app_shell.cj` / `telegram_ui_slice.cj` / router/page/controller, does not reopen cache runtime/no-deadlock or compile-budget decisions, and does not pull legacy cache-sample local-harness tests into scope beyond reference.
- Because no shared-harness or Telegram consumer source moved, the canonical Telegram build/runtime evidence remains inherited from `P1-19`; this round only refreshes the cache-sample canonical build gate.
- This round remains exploratory-only continuation work inside `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.

## Verification

- `cd samples/real-message-service-cache-001 && cjpm test`
  - exit `0`
  - `TOTAL: 29`, `PASSED: 29`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-shared-p1-22-second-consumer-invalidate-refetch-parity/cache-cjpm-test.log`
- inherited Telegram evidence:
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - latest green checkpoint remains `P1-19` with `TOTAL: 18`, `PASSED: 18`, `FAILED: 0`

## Runtime Artifact

- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-22-second-consumer-invalidate-refetch-parity/`
- inherited Telegram evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/`

## Outcome

- `P1-22` now proves that the Phase07 shared second consumer can invalidate a warmed shared cache/signal pair and refetch replacement history through the existing public `debugInvalidateCache(...)` surface while keeping the old held signal detached, keeping observer delivery main-gated, and delivering only the refetched payload after main-context drain.
- The slice remains smaller than any new Telegram app-shell consume extension: it is a shared-harness regression lock only, built on the existing shared service surface, with no new shared helper/API and no new Telegram consume contract.
