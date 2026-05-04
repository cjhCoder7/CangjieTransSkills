# 2026-04-16 Phase07 P1-15 Active-Detail Target Refresh Back Reopen Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, when the target conversation is already active on `TelegramChatDetailPage`, refreshing that same target, backing to the session list, and reopening that same refreshed target still preserves bounded active-detail refresh-back-reopen coherence.

## Decision

- Landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- Boundary distinction:
  - `P1-11` locks list-route `back -> refresh -> reopen refreshed target`.
  - `P1-15` locks active-detail target `refresh -> back -> reopen same refreshed target`.
  - `P1-14` remains the later alternating-reopen round-trip slice across another visible conversation.
- Consumption direction:
  - `TelegramAppShell.refreshConversation(...)` continues to delegate to the existing list-page refresh path while the active detail route stays pinned to the route-owned target conversation.
  - `TelegramAppShell.backFromDetail()` continues to clear detail projection on return to the session-list route.
  - `TelegramAppShell.openConversation(...)` continues to reuse the bounded list-route reopen semantics for the same refreshed target after the shell has returned to the list.
  - No production-code widening was required in this round: the already-present shell-level regression proved that the landed implementation already satisfies the P1-15 contract.
- Regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellRefreshActiveDetailTargetThenBackAndReopenShouldPreserveBoundedCoherence`

## Why This Round Stops Here

- `P1-15` only extends the Telegram app-shell consume contract for active-detail target `refreshConversation(target) -> backFromDetail() -> reopen same refreshed target` coherence.
- This round does not reopen shared harness, cache-sample verification, `P1-6` second-consumer packaging, `P23`, or any `Phase06 regular` lane.
- This round is a contract-lock and evidence refresh slice: it formalizes an already-green regression into the continuation-lane SSOT without widening production code.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 15`, `PASSED: 15`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260416-phase07-telegram-p1-15-active-detail-target-refresh-back-reopen/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 15`, `PASSED: 15`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260416-phase07-telegram-p1-15-active-detail-target-refresh-back-reopen/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260416-phase07-telegram-p1-15-active-detail-target-refresh-back-reopen/`

## Outcome

- `P1-15` now proves that when the target conversation is already active on detail, refreshing that same target keeps the shell pinned to `TelegramChatDetailPage`, keeps bounded history at `2`, preserves route-owned detail title / peer label / placeholder body during the refresh, preserves the refreshed target summary on the list surface after backing to the session list, clears detail projection on the list route, and then restores the same refreshed target back onto `TelegramChatDetailPage` when reopened without polluting non-target summaries or growing service-history pulls.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.
