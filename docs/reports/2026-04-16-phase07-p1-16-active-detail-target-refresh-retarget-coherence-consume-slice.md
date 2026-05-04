# 2026-04-16 Phase07 P1-16 Active-Detail Target Refresh Retarget Coherence Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, when the target conversation is already active on `TelegramChatDetailPage`, refreshing that same target and then directly retargeting to another visible conversation still preserves bounded active-detail refresh-retarget coherence.

## Decision

- Landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- Boundary distinction:
  - `P1-15` locks active-detail target `refresh -> back -> reopen same refreshed target`.
  - `P1-16` locks active-detail target `refresh -> retarget other visible conversation`.
  - `P1-12` remains the later list-route `refresh -> reopen refreshed target -> retarget other visible conversation` slice.
- Consumption direction:
  - `TelegramAppShell.refreshConversation(...)` continues to delegate to the existing list-page refresh path while the active detail route stays pinned to the route-owned target conversation during the refresh.
  - `TelegramAppShell.openConversation(...)` continues to reuse the already-landed active-detail replace semantics to retarget directly to another visible conversation without growing route history.
  - No production-code widening was required in this round: the newly added shell-level regression proved that the landed implementation already satisfies the P1-16 contract.
- Regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellRefreshActiveDetailTargetThenRetargetShouldPreserveBoundedCoherence`

## Why This Round Stops Here

- `P1-16` only extends the Telegram app-shell consume contract for active-detail target `refreshConversation(target) -> retarget(other visible conversation)` coherence.
- This round does not reopen shared harness, cache-sample verification, `P1-6` second-consumer packaging, `P23`, or any `Phase06 regular` lane.
- This round is a contract-lock and evidence refresh slice: it formalizes an already-green regression into the continuation-lane SSOT without widening production code.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 16`, `PASSED: 16`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260416-phase07-telegram-p1-16-active-detail-target-refresh-retarget-coherence/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 16`, `PASSED: 16`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260416-phase07-telegram-p1-16-active-detail-target-refresh-retarget-coherence/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260416-phase07-telegram-p1-16-active-detail-target-refresh-retarget-coherence/`

## Outcome

- `P1-16` now proves that when the target conversation is already active on detail, refreshing that same target keeps the shell pinned to `TelegramChatDetailPage`, keeps bounded history at `2`, preserves route-owned detail title / peer label / placeholder body during the refresh, preserves the refreshed target summary on the list surface, and then allows direct retarget to another visible conversation while keeping the shell on detail, rebinding detail ownership to the new target conversation, preserving the refreshed original target summary, leaving the other visible summary unpolluted, and avoiding any extra service-history pull beyond the refresh itself.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.
