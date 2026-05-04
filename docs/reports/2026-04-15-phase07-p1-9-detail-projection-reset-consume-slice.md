# 2026-04-15 Phase07 P1-9 Detail-Projection Reset Consume Slice

## Goal

Land the next bounded Telegram app-shell/detail consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, after returning from detail to the session list, the shell no longer leaks stale detail title / peer label / placeholder body.

## Decision

- Landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
- Consumption direction:
  - `TelegramAppShell.backFromDetail()` keeps the existing detail-page `tapBack()` path.
  - The bounded change lands in `TelegramChatDetailPage.aboutToAppear()` plus the existing detail getters: when the current route no longer owns a conversation, the detail projection now resets instead of leaking the last detail state into the session-list route.
- Regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellBackShouldClearDetailProjectionAfterReturningToSessionList`

## Why This Round Stops Here

- `P1-9` only extends the Telegram app-shell/detail consume contract for post-back detail-projection reset.
- This round does not reopen shared harness, cache-sample verification, `P1-6` second-consumer packaging, `P23`, or any `Phase06 regular` lane.
- No new shared dependency, router framework, or service abstraction is introduced; the only code change is the bounded reset of detail projection inside the Telegram sample detail page.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 9`, `PASSED: 9`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-9-detail-projection-reset/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 9`, `PASSED: 9`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-9-detail-projection-reset/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260415-phase07-telegram-p1-9-detail-projection-reset/`

## Outcome

- `P1-9` now proves that the repo-local Telegram shell clears stale detail projection after the consume boundary has returned to the session-list route.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, or `Windows Staging-Full` claim.
