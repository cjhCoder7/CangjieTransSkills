# 2026-04-15 Phase07 P1-8 Back-Stability Consume Slice

## Goal

Land the next bounded Telegram app-shell/router consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, after one or more detail-route retargets, `back` returns stably to the session list without leaving a stale forward-history tail that can inflate the next selection to route-history `3`.

## Decision

- Landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
- Consumption direction:
  - `TelegramAppShell.backFromDetail()` keeps the existing detail-page `tapBack()` path.
  - The bounded change lands in `TelegramPageRouter.push(...)`: when the shell has returned to the session-list route and a stale forward detail tail still exists, the next detail navigation now reuses the bounded detail slot instead of appending a third route entry.
- Regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellBackShouldReturnToSessionListAfterDetailRetargetsWithoutForwardHistoryGrowth`

## Why This Round Stops Here

- `P1-8` only extends the Telegram app-shell/router consume contract for post-retarget back stability.
- This round does not reopen shared harness, cache-sample verification, `P1-6` second-consumer packaging, `P23`, or any `Phase06 regular` lane.
- No new shared dependency, service abstraction, or generic router framework is introduced; the only code change is the bounded forward-tail handling inside the Telegram sample router.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 8`, `PASSED: 8`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-8-back-stability/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 8`, `PASSED: 8`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-8-back-stability/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260415-phase07-telegram-p1-8-back-stability/`

## Outcome

- `P1-8` now proves that the repo-local Telegram shell can return from a retargeted detail route to the session list and keep the next list selection on a bounded 2-entry route history.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, or `Windows Staging-Full` claim.
