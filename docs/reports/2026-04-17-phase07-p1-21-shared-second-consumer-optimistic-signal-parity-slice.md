# 2026-04-17 Phase07 P1-21 Shared Second-Consumer Optimistic-Signal Parity Slice

## Goal

Freeze the next bounded shared-harness continuation slice by proving that the Phase07 shared second consumer can reuse the existing shared `MessageSignal` contract and observe `worker send -> optimistic signal snapshot before main-context drain` parity without widening shared API, shared service semantics, or Telegram app-shell scope.

## Scout Decision

- bounded candidates found before coding:
  - `P1-21 shared second-consumer optimistic-signal parity`
    - single second-consumer regression can lock the gap on top of the already-landed fetch/send path
    - reuses existing public `getMessages(...)`, `debugDrainPromiseResolutions()`, `MessageSignal.currentSnapshot()`, `sendMessage(...)`, and `MainContextDatasetRefreshBridge`
  - `next-best shared second-consumer invalidate/refetch parity`
    - still smaller than a new Telegram consume slice because it can stay inside the second-consumer regression file and reuse existing public `debugInvalidateCache(...)`
    - not chosen first because `P1-21` closes with an even smaller signal-only contract lock and stays closer to the already-landed `P1-20` send parity
- not chosen as the next slice:
  - delayed handoff / stale discard parity
    - would need cache-sample probe-only bridge APIs such as delayed handoff control / dispatch-log inspection, which would widen the shared-harness regression surface beyond this round

## Decision

- Landing path:
  - `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj`
  - `docs/reports/2026-04-15-phase07-p0-3-verification-contract.md`
  - `specs/phase07-telegram-ui-incubation/tasks.md`
  - `docs/status/INDEX.md`
  - `docs/current_state.v2.md`
  - `docs/runtime_contract.v2.md`
  - `docs/status/current_task_handoff.md`
- Boundary distinction:
  - `P1-20` locked second-consumer `worker send -> main-context drain` refresh-dispatch parity.
  - `P1-21` stops one step earlier than any new invalidate/refetch or delayed-handoff work: it only freezes the minimum optimistic signal contract that exists between `worker send` and `main-context drain`.
- Consumption direction:
  - the new bounded case creates the shared signal through `getMessages(...)`, drains the initial fetch promise, performs the first main-context history delivery, then issues a worker-side send while holding the same signal
  - the case proves that the shared signal snapshot updates to the sent message before main drain, while observer delivery count remains unchanged until the main-context drain happens
  - no new shared helper/API was added, and no Telegram app-shell behavior contract was expanded
- Regression lock:
  - `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldKeepSecondConsumerSignalOptimisticBeforeMainDrain`
  - No production-code widening was required in this round: the newly added second-consumer regression closed on the existing shared surface.

## Why This Round Stops Here

- `P1-21` only proves second-consumer optimistic signal parity on top of the already-landed shared fetch/send path.
- This round does not touch `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`, does not touch `telegram_app_shell.cj` / `telegram_ui_slice.cj` / router/page/controller, does not reopen cache runtime/no-deadlock or compile-budget decisions, and does not pull legacy cache-sample local-harness tests into scope.
- Because no shared-harness or Telegram consumer source moved, the canonical Telegram build/runtime evidence remains inherited from `P1-19`; this round only refreshes the cache-sample canonical build gate.
- This round remains exploratory-only continuation work inside `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.

## Verification

- `cd samples/real-message-service-cache-001 && cjpm test`
  - exit `0`
  - `TOTAL: 28`, `PASSED: 28`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-shared-p1-21-second-consumer-optimistic-signal-parity/cache-cjpm-test.log`
- inherited Telegram evidence:
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - latest green checkpoint remains `P1-19` with `TOTAL: 18`, `PASSED: 18`, `FAILED: 0`

## Runtime Artifact

- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-21-second-consumer-optimistic-signal-parity/`
- inherited Telegram evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/`

## Outcome

- `P1-21` now proves that the Phase07 shared second consumer can establish the existing shared signal, warm it up through fetch promise drain and main-context history delivery, then issue a worker-side send that updates the held signal snapshot before `main-context drain` while keeping observer delivery main-gated until the drain happens.
- The slice remains smaller than a new Telegram app-shell consume extension and smaller than invalidate/refetch or delayed-handoff follow-ups: it is a shared-harness regression lock only, built on the existing shared service surface, with no new shared helper/API and no new Telegram consume contract.
