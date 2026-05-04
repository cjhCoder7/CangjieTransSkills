# 2026-04-15 Phase07 P1-12 Refresh-Reopen-Retarget Coherence Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, after returning from detail to the session list, refreshing a target conversation summary, and reopening that refreshed conversation, retargeting to another visible conversation still preserves coherent detail ownership and stable list-state evidence.

## Decision

- Landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- Consumption direction:
  - `TelegramAppShell.openConversation(...)` continues to consume the existing list-page summary plus bounded router push semantics for reopen and the already-landed active-detail replace semantics for retarget.
  - No production-code widening was required in this round: the newly added shell-level regression proved that the landed `P1-5` shell refresh delegate, `P1-7` detail-route retarget, `P1-8` retarget-back stability, `P1-10` back-to-list refresh isolation, and `P1-11` refresh-then-reopen coherence already satisfy the P1-12 closure contract.
- Regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellRefreshReopenThenRetargetShouldKeepDetailCoherenceAndListStability`

## Why This Round Stops Here

- `P1-12` only extends the Telegram app-shell consume contract for refresh -> reopen refreshed conversation -> retarget to another visible conversation coherence.
- This round does not reopen shared harness, cache-sample verification, `P1-6` second-consumer packaging, `P23`, or any `Phase06 regular` lane.
- Because the target semantics were already satisfied by the existing bounded implementation, the landed slice is a contract-lock and evidence refresh rather than a new production-code expansion.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 12`, `PASSED: 12`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-12-refresh-reopen-retarget-coherence/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 12`, `PASSED: 12`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260415-phase07-telegram-p1-12-refresh-reopen-retarget-coherence/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260415-phase07-telegram-p1-12-refresh-reopen-retarget-coherence/`

## Outcome

- `P1-12` now proves that after a list-route target refresh the refreshed visible conversation can be reopened coherently into `TelegramChatDetailPage` and then retargeted to another visible conversation while bounded history stays `2`, detail title / peer label / placeholder body switch to the retargeted conversation, the originally refreshed target summary remains visible on the list surface, and non-target summaries remain stable.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, or `Windows Staging-Full` claim.
