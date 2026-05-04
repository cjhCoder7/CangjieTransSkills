# 2026-04-15 Phase07 P1-14 Alternating Reopen Bounded Stability Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, after refreshing a target conversation summary, reopening that refreshed target, retargeting to another visible conversation, backing to the session list, reopening the original refreshed target, backing again, and reopening the other visible conversation, the shell still preserves bounded alternating-reopen stability and coherent detail/list ownership.

## Decision

- Landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- Consumption direction:
  - `TelegramAppShell.openConversation(...)` continues to consume the existing list-page summary plus bounded router push semantics for list-route reopen, the already-landed active-detail replace semantics for retarget, and the already-landed back-to-list bounded reset semantics.
  - No production-code widening was required in this round: the newly added shell-level regression proved that the landed `P1-8` retarget-back stability, `P1-11` refresh-then-reopen coherence, `P1-12` refresh-reopen-retarget coherence, and `P1-13` round-trip stability already satisfy the P1-14 alternating-reopen contract.
- Regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellAlternatingReopenAfterRoundTripShouldKeepBoundedStableDetailOwnership`

## Why This Round Stops Here

- `P1-14` only extends the Telegram app-shell consume contract for `refreshConversation(target) -> reopen refreshed target -> retarget(other visible conversation) -> backFromDetail() -> reopen original refreshed target -> backFromDetail() -> reopen other visible conversation` bounded stability.
- This round does not reopen shared harness, cache-sample verification, `P1-6` second-consumer packaging, `P23`, or any `Phase06 regular` lane.
- Because the target semantics were already satisfied by the existing bounded implementation, the landed slice is a contract-lock and evidence refresh rather than a new production-code expansion.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 14`, `PASSED: 14`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-14-alternating-reopen-bounded-stability/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 14`, `PASSED: 14`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-14-alternating-reopen-bounded-stability/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260415-phase07-telegram-p1-14-alternating-reopen-bounded-stability/`

## Outcome

- `P1-14` now proves that after the refreshed target and another visible conversation are alternately reopened across two back-to-list round trips, the shell still restores `TelegramChatDetailPage`, keeps bounded history at `2`, rebinds detail title / peer label / placeholder body to whichever visible conversation is reopened last, preserves the refreshed original target summary on the list surface, preserves the other visible summary without pollution, and keeps the service-history pull count bounded.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, or `Windows Staging-Full` claim.
