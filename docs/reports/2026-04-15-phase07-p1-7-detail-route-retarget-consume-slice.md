# 2026-04-15 Phase07 P1-7 Detail-Route Retarget Consume Slice

## Goal

Land the next bounded Telegram app-shell/router consume slice inside `samples/telegram-ui-vertical-slice-001` by allowing the active detail route to retarget to another visible conversation without growing route history.

## Decision

- Landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
- Consumption direction:
  - `TelegramAppShell.openConversation(...)` keeps the existing list-page push path when the shell is on the session-list route.
  - When the shell is already on `TelegramChatDetailPage`, the consume path now reuses the active detail route through a router-level `replace(...)` instead of appending another detail entry.
- Regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellShouldRetargetActiveDetailConversationWithoutGrowingRouteHistory`

## Why This Round Stops Here

- `P1-7` only extends the Telegram app-shell/router consume contract for active-detail retargeting.
- This round does not reopen shared harness relocation, cache-sample verification, `P1-6` second-consumer packaging, or any `Phase06 regular` / `P23` lane.
- No new service, refresh, or controller abstraction is introduced; the only router change is the bounded current-route replacement semantics required by the new consume slice.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 7`, `PASSED: 7`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-7-detail-route-retarget/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 7`, `PASSED: 7`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-7-detail-route-retarget/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260415-phase07-telegram-p1-7-detail-route-retarget/`

## Outcome

- `P1-7` now proves that the repo-local Telegram shell can retarget the active detail consume boundary without inflating route history.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, or `Windows Staging-Full` claim.
