# 2026-04-17 Phase07 P1-20 Shared Second-Consumer Send-Refresh Dispatch Parity Slice

## Goal

Land the next bounded shared-harness continuation slice by proving that the Phase07 shared second consumer does not only support the existing fetch/drain path, but also supports the minimum `worker send -> main-context dataset refresh dispatch` parity contract without widening shared API, shared service semantics, or Telegram app-shell scope.

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
  - `P1-6` proved that the shared service / refresh surface can be consumed by Telegram and a second repo-local consumer.
  - `P1-19` unified the shared worker-side fetch/drain/snapshot helper through public `runWorkerGetMessages(...)`.
  - `P1-20` stops one step later than `P1-19`: it only freezes the minimum second-consumer parity that follows `warmup fetch / drain` with `worker send -> main-context drain`.
- Consumption direction:
  - the second-consumer regression continues to use the existing shared `RealMessageService`, `MainContextDatasetRefreshBridge`, `runWorkerGetMessages(...)`, and `SendMessageParams`
  - the new bounded case proves observer notification count, pending queue, last message text, and delivery context across the `warmup -> send -> drain` chain
  - no new shared `runWorkerSendMessage(...)` helper was added, and no Telegram app-shell behavior contract was expanded
- Regression lock:
  - `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldDispatchSecondConsumerSendRefreshOnMainContext`
  - No production-code widening was required in this round: the newly added second-consumer regression closed on the existing shared surface.

## Why This Round Stops Here

- `P1-20` only proves second-consumer send-refresh dispatch parity on top of the already-landed shared fetch/drain path.
- This round does not touch `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`, does not touch `telegram_app_shell.cj` / `telegram_ui_slice.cj` / router/page/controller, does not reopen cache runtime/no-deadlock or compile-budget decisions, and does not pull legacy cache-sample local-harness tests into scope.
- Because no shared-harness or Telegram consumer source moved, the canonical Telegram build/runtime evidence remains inherited from `P1-19`; this round only refreshes the cache-sample canonical build gate.
- This round remains exploratory-only continuation work inside `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.

## Verification

- `cd samples/real-message-service-cache-001 && cjpm test`
  - exit `0`
  - `TOTAL: 27`, `PASSED: 27`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-shared-p1-20-second-consumer-send-refresh-dispatch-parity/cache-cjpm-test.log`
- inherited Telegram evidence:
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - latest green checkpoint remains `P1-19` with `TOTAL: 18`, `PASSED: 18`, `FAILED: 0`

## Runtime Artifact

- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-20-second-consumer-send-refresh-dispatch-parity/`
- inherited Telegram evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/`

## Outcome

- `P1-20` now proves that the Phase07 shared second consumer can warm up through the shared worker fetch/drain path, then issue a worker-side send, leave the refreshed dataset queued until main-context drain, and finally deliver the updated dataset on main with the correct observer notification count, empty pending queue after drain, correct last message text, and correct delivery context.
- The slice remains smaller than a new Telegram app-shell consume extension: it is a shared-harness regression lock only, built on the existing shared service surface, with no new shared send helper and no new Telegram consume contract.
