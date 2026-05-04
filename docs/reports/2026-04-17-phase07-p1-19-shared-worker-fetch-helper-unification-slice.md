# 2026-04-17 Phase07 P1-19 Shared Worker-Fetch Helper Unification Slice

## Goal

Land the next bounded shared-harness continuation slice by promoting the duplicated worker-side `RealMessageService.getMessages(...) -> debugDrainPromiseResolutions() -> signal.currentSnapshot()` idiom into one shared public helper, then rebinding the existing Telegram consumer and the Phase07 second consumer to that single helper without widening app-shell behavior or shared service semantics.

## Decision

- Landing path:
  - `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_message_service_harness.cj`
  - `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj`
- Boundary distinction:
  - `P1-6` proved that the shared service / refresh surface can be consumed by Telegram and a second repo-local consumer.
  - `P1-19` closes the deferred worker helper from `docs/reports/2026-04-15-phase07-shared-harness-module-boundary.md` by lifting that fetch/drain/snapshot idiom into the shared package.
  - This round does not create a new Telegram app-shell behavior slice; the current app-shell consume entry remains `P1-18`.
- Consumption direction:
  - `phase07_shared_service_refresh_harness` now exports public `runWorkerGetMessages(...)`.
  - `samples/telegram-ui-vertical-slice-001` no longer keeps a consumer-local `runWorkerGetMessages(...)` implementation; the existing `telegram_ui_slice.cj` worker fetch path now resolves to the shared helper through package import.
  - `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj` no longer keeps a consumer-local `runSharedWorkerGetMessages(...)` implementation and now consumes the same shared helper directly.
- TDD lock:
  - the red phase was an expected compile failure in `phase07_second_consumer_compatibility_test.cj` when it first imported `runWorkerGetMessages` from the shared package before that helper existed;
  - the green phase landed by exporting the helper from the shared package and deleting both consumer-local implementations.

## Why This Round Stops Here

- `P1-19` only unifies the worker fetch/drain/snapshot helper across the existing shared-harness consumers.
- This round does not reopen `P1-6` packaging, does not widen shared service semantics, does not touch `telegram_app_shell.cj` / `telegram_ui_slice.cj` / router/page/controller, and does not pull cache sample legacy local-harness tests into the write set.
- This round remains exploratory-only continuation work inside `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 18`, `PASSED: 18`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/telegram-cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 18`, `PASSED: 18`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/telegram-timeout-unittest.log`
- `cd samples/real-message-service-cache-001 && cjpm test`
  - exit `0`
  - `TOTAL: 26`, `PASSED: 26`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/cache-cjpm-test.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/`

## Outcome

- `P1-19` now proves that the Phase07 shared-harness landing package owns a single public worker-side fetch/drain/snapshot helper, Telegram no longer keeps its own `runWorkerGetMessages(...)` implementation, the Phase07 second-consumer compatibility test no longer keeps its own `runSharedWorkerGetMessages(...)` implementation, both consumers now express the same cross-thread worker fetch idiom through the same shared helper, the existing Telegram app-shell behavior contract remains unchanged, and the canonical Telegram build/runtime gate plus cache sample build gate remain green under explicit repo-local toolchain injection.
