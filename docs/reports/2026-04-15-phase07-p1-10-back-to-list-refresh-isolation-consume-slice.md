# 2026-04-15 Phase07 P1-10 Back-to-List Refresh Isolation Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, after returning from detail to the session list, a later `refreshConversation(...)` updates only the target summary while keeping the shell on the list route and keeping detail projection empty.

## Decision

- Landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- Consumption direction:
  - `TelegramAppShell.refreshConversation(...)` keeps the existing same-package delegate to `TelegramSessionListPage.refreshConversation(...)`.
  - No production-code widening was required in this round: the newly added shell-level regression proved that the existing `P1-5` refresh delegate plus the landed `P1-9` detail-projection reset already satisfy the P1-10 isolation contract.
- Regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellRefreshAfterBackShouldKeepListRouteAndDetailProjectionIsolation`

## Why This Round Stops Here

- `P1-10` only extends the Telegram app-shell consume contract for back-to-list refresh isolation.
- This round does not reopen shared harness, cache-sample verification, `P1-6` second-consumer packaging, `P23`, or any `Phase06 regular` lane.
- Because the target semantics were already satisfied by the existing bounded implementation, the landed slice is a contract-lock and evidence refresh rather than a new production-code expansion.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 10`, `PASSED: 10`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-10-back-to-list-refresh-isolation/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 10`, `PASSED: 10`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-10-back-to-list-refresh-isolation/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260415-phase07-telegram-p1-10-back-to-list-refresh-isolation/`

## Outcome

- `P1-10` now proves that the repo-local Telegram shell can refresh a list-route target summary after `back` without reactivating detail title / peer label / placeholder body, without widening history beyond `2`, and without polluting non-target summaries.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, or `Windows Staging-Full` claim.
