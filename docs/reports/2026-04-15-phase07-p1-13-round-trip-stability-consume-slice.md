# 2026-04-15 Phase07 P1-13 Round-Trip Stability Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, after refreshing a target conversation summary, reopening that refreshed target, retargeting to another visible conversation, backing to the session list, and reopening the original refreshed target, the shell still preserves coherent round-trip detail ownership and stable list-state evidence.

## Decision

- Landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- Consumption direction:
  - `TelegramAppShell.openConversation(...)` continues to consume the existing list-page summary plus bounded router push semantics for list-route reopen and the already-landed active-detail replace semantics for retarget.
  - No production-code widening was required in this round: the newly added shell-level regression proved that the landed `P1-7` detail-route retarget, `P1-8` retarget-back stability, `P1-11` refresh-then-reopen coherence, and `P1-12` refresh-reopen-retarget coherence already satisfy the P1-13 round-trip contract.
- Regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellRefreshReopenRetargetBackThenReopenShouldPreserveRoundTripStability`

## Why This Round Stops Here

- `P1-13` only extends the Telegram app-shell consume contract for `refreshConversation(target) -> reopen refreshed target -> retarget(other visible conversation) -> backFromDetail() -> reopen original refreshed target` round-trip stability.
- This round does not reopen shared harness, cache-sample verification, `P1-6` second-consumer packaging, `P23`, or any `Phase06 regular` lane.
- Because the target semantics were already satisfied by the existing bounded implementation, the landed slice is a contract-lock and evidence refresh rather than a new production-code expansion.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 13`, `PASSED: 13`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-13-round-trip-stability/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 13`, `PASSED: 13`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-13-round-trip-stability/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260415-phase07-telegram-p1-13-round-trip-stability/`

## Outcome

- `P1-13` now proves that after a target summary is refreshed, reopened, temporarily retargeted to another visible conversation, and backed to the list, reopening the original refreshed target still restores `TelegramChatDetailPage`, keeps bounded history at `2`, rebinds detail title / peer label / placeholder body to the original refreshed target, preserves the refreshed target summary on the list surface, and leaves non-target summaries untouched through the entire round trip.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, or `Windows Staging-Full` claim.
