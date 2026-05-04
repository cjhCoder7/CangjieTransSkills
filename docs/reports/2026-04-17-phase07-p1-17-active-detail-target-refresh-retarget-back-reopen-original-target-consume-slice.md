# 2026-04-17 Phase07 P1-17 Active-Detail Target Refresh Retarget Back Reopen Original Refreshed Target Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, when the target conversation is already active on `TelegramChatDetailPage`, refreshing that same target, directly retargeting to another visible conversation, backing to the session list, and reopening the original refreshed target still preserves bounded active-detail round-trip stability.

## Decision

- Landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- Boundary distinction:
  - `P1-16` locks active-detail target `refresh -> retarget other visible conversation`.
  - `P1-17` locks active-detail target `refresh -> retarget other visible conversation -> backFromDetail() -> reopen original refreshed target`.
  - `P1-13` remains the later list-route `refresh -> reopen refreshed target -> retarget other visible conversation -> backFromDetail() -> reopen original refreshed target` slice.
- Consumption direction:
  - `TelegramAppShell.refreshConversation(...)` continues to delegate to the existing list-page refresh path while the active detail route stays pinned to the route-owned target conversation during the refresh.
  - `TelegramAppShell.openConversation(...)` continues to reuse the already-landed active-detail replace semantics for direct retarget and the already-landed bounded list-route reopen semantics for restoring the original refreshed target after returning to the session list.
  - `TelegramAppShell.backFromDetail()` continues to reuse the already-landed bounded reset semantics so the retargeted detail route returns to the session list without leaking stale detail projection.
  - No production-code widening was required in this round: the newly added shell-level regression proved that the landed implementation already satisfies the P1-17 contract.
- Regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellRefreshActiveDetailRetargetBackThenReopenOriginalTargetShouldPreserveRoundTripStability`

## Why This Round Stops Here

- `P1-17` only extends the Telegram app-shell consume contract for active-detail target `refreshConversation(target) -> retarget(other visible conversation) -> backFromDetail() -> reopen original refreshed target` round-trip stability.
- This round does not reopen shared harness, cache-sample verification, `P1-6` second-consumer packaging, `P23`, or any `Phase06 regular` lane.
- This round is a contract-lock and evidence refresh slice: it formalizes an already-green regression into the continuation-lane SSOT without widening production code.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 17`, `PASSED: 17`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-telegram-p1-17-active-detail-target-refresh-retarget-back-reopen-original-target/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 17`, `PASSED: 17`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-telegram-p1-17-active-detail-target-refresh-retarget-back-reopen-original-target/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-17-active-detail-target-refresh-retarget-back-reopen-original-target/`

## Outcome

- `P1-17` now proves that when the target conversation is already active on detail, refreshing that same target keeps the shell pinned to `TelegramChatDetailPage`, direct retarget still rebinds detail ownership to another visible conversation without growing route history, `backFromDetail()` still returns the shell to `TelegramSessionListPage` with cleared detail projection, and reopening the original refreshed target restores `TelegramChatDetailPage`, rebinds detail ownership back to the original refreshed target, preserves the refreshed original target summary on the list surface, leaves the other visible summary unpolluted, and avoids any extra service-history pull beyond the refresh itself.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.
