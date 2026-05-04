# 2026-04-15 Phase07 P1-11 Refresh-Then-Reopen Coherence Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, after returning from detail to the session list and refreshing a target conversation summary, reopening that refreshed conversation restores coherent detail ownership without losing the refreshed list state.

## Decision

- Landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- Consumption direction:
  - `TelegramAppShell.openConversation(...)` continues to consume the existing list-page summary plus bounded router push path.
  - No production-code widening was required in this round: the newly added shell-level regression proved that the landed `P1-5` shell refresh delegate, `P1-8` bounded reopen history behavior, `P1-9` detail-projection reset, and `P1-10` back-to-list refresh isolation already satisfy the P1-11 coherence contract.
- Regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellRefreshThenReopenShouldPreserveCoherentDetailAndListState`

## Why This Round Stops Here

- `P1-11` only extends the Telegram app-shell consume contract for refresh-then-reopen coherence.
- This round does not reopen shared harness, cache-sample verification, `P1-6` second-consumer packaging, `P23`, or any `Phase06 regular` lane.
- Because the target semantics were already satisfied by the existing bounded implementation, the landed slice is a contract-lock and evidence refresh rather than a new production-code expansion.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 11`, `PASSED: 11`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-11-refresh-then-reopen-coherence/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 11`, `PASSED: 11`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-11-refresh-then-reopen-coherence/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260415-phase07-telegram-p1-11-refresh-then-reopen-coherence/`

## Outcome

- `P1-11` now proves that the repo-local Telegram shell can reopen a refreshed target conversation after `back` + list-route refresh while restoring `TelegramChatDetailPage`, keeping bounded history at `2`, rebinding detail title / peer label / placeholder body to the reopened target conversation, preserving the refreshed target summary on the list surface, and leaving non-target summaries untouched.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, or `Windows Staging-Full` claim.
