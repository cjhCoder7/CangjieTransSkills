# 2026-04-17 Phase07 P1-18 Active-Detail Refresh Retarget Alternating-Reopen Bounded Stability Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, when the target conversation is already active on `TelegramChatDetailPage`, refreshing that same target, directly retargeting to another visible conversation, backing to the session list, reopening the original refreshed target, backing again, and finally reopening the other visible conversation still preserves bounded alternating-reopen stability at the app-shell consume boundary.

## Decision

- Landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- Boundary distinction:
  - `P1-17` locks active-detail target `refresh -> retarget other visible conversation -> backFromDetail() -> reopen original refreshed target`.
  - `P1-18` extends that chain with `backFromDetail() -> reopen other visible conversation`.
  - `P1-14` remains the earlier list-route alternating-reopen bounded-stability slice.
- Consumption direction:
  - `TelegramAppShell.refreshConversation(...)` continues to reuse the existing list-page refresh path while the active detail route stays pinned to the route-owned target conversation during the refresh.
  - `TelegramAppShell.openConversation(...)` continues to reuse the already-landed active-detail replace semantics for direct retarget, the already-landed bounded list-route reopen semantics for restoring the original refreshed target, and the same bounded list-route reopen semantics again for reopening the other visible conversation after the second back.
  - `TelegramAppShell.backFromDetail()` continues to reuse the already-landed bounded reset semantics so both back operations return the shell to the session list without leaking stale detail projection.
  - No production-code widening was required in this round: the newly added shell-level regression proved that the landed implementation already satisfies the `P1-18` contract.
- Regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellRefreshActiveDetailRetargetAlternatingReopenShouldKeepBoundedStableDetailOwnership`

## Why This Round Stops Here

- `P1-18` only extends the Telegram app-shell consume contract for active-detail target `refreshConversation(target) -> retarget(other visible conversation) -> backFromDetail() -> reopen original refreshed target -> backFromDetail() -> reopen other visible conversation` bounded stability.
- This round does not reopen shared harness, cache-sample verification, `P1-6` second-consumer packaging, `P23`, or any `Phase06 regular` lane.
- This round is a contract-lock and evidence refresh slice: it formalizes an already-green regression into the continuation-lane SSOT without widening production code.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 18`, `PASSED: 18`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-telegram-p1-18-active-detail-refresh-retarget-alternating-reopen-bounded-stability/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 18`, `PASSED: 18`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-telegram-p1-18-active-detail-refresh-retarget-alternating-reopen-bounded-stability/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-18-active-detail-refresh-retarget-alternating-reopen-bounded-stability/`

## Outcome

- `P1-18` now proves that when the target conversation is already active on detail, refreshing that same target keeps the shell pinned to `TelegramChatDetailPage`, direct retarget still rebinds detail ownership to another visible conversation without growing route history, the first `backFromDetail()` still returns the shell to `TelegramSessionListPage` with cleared detail projection, reopening the original refreshed target restores detail ownership to the refreshed target, the second `backFromDetail()` again clears the detail projection on the session-list route, and the final reopen of the other visible conversation returns the shell to `TelegramChatDetailPage`, keeps bounded history at `2`, rebinds detail ownership to the other visible conversation, preserves the refreshed original target summary and `messageCount` on the list surface, leaves the other visible summary unpolluted before and after the final reopen, and avoids any extra service-history pull beyond the refresh itself.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.
