# 2026-04-18 Phase07 P1-43 Telegram Active-Detail Warm-Send Direct-Retarget Other Visible Conversation Then Direct-Retarget Original Sent Target Back-Reopen Original Sent Target Coherence Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, once the original sent target conversation is already active on `TelegramChatDetailPage`, Telegram can perform a same-peer warm send, direct retarget to another visible conversation, direct retarget back to the original sent target, back out to the list, and then reopen the original sent target without reopening shared harness work or widening the existing same-package shell surface.

## Decision

- landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `specs/phase07-telegram-ui-incubation/tasks.md`
  - `docs/reports/2026-04-15-phase07-app-shell-consume-boundary.md`
  - `docs/status/current_committed_plan.md`
  - `docs/status/INDEX.md`
  - `docs/current_state.v2.md`
  - `docs/runtime_contract.v2.md`
  - `docs/status/current_task_handoff.md`
  - `docs/agent_system/execution_routing.md`
  - `AGENTS.md`
- boundary distinction:
  - `P1-42` froze the bounded active-detail warm-send -> direct-retarget other visible conversation -> direct-retarget original sent target -> back -> reopen other visible conversation branch.
  - `P1-43` extends only one sibling tail on the same Telegram consume rail: after the second direct retarget has already rebound detail ownership to the original sent target and `backFromDetail()` has returned the shell to the list, the shell may reopen the original sent target while preserving bounded coherence.
  - `P1-41` froze the direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target branch that never left `TelegramChatDetailPage`; `P1-43` adds only the bounded `back -> reopen original sent target` tail after that twin-retarget closure.
  - `P1-30` froze the older warm-send -> direct-retarget other visible conversation -> back -> reopen original sent target round trip; `P1-43` differs by first direct retargeting back to the original sent target while still on detail before executing the final back-reopen-original tail.
- regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellWarmSendThenDirectRetargetOtherVisibleConversationThenDirectRetargetOriginalSentTargetBackThenReopenOriginalSentTargetShouldPreserveBoundedCoherence`
- TDD result:
  - the new shell-level regression passed against the existing Telegram consume implementation.
  - the landed regression did not require production edits; git tracked baseline is unavailable for `samples/telegram-ui-vertical-slice-001/src`, so the strongest safe statement is that no `P1-43`-specific widening is observable in `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj` or `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj` from the current verification surface.

## Consumption Direction

- the new bounded case performs initial load, opens the original sent target conversation into active detail, sends `team-warm-send-3` through `sendMessageToActiveConversation(...)`, direct retargets to another visible conversation, direct retargets back to the original sent target, backs to `TelegramSessionListPage`, and then reopens the original sent target.
- the case proves that:
  - send and both direct retargets still leave the shell on `TelegramChatDetailPage`
  - after the second direct retarget, `backFromDetail()` returns the shell to `TelegramSessionListPage` and clears all detail getters
  - the final reopen of the original sent target returns the shell to `TelegramChatDetailPage`
  - `historySize()` stays bounded at `2` across send, both retargets, back, and the final reopen
  - the original sent target summary preserves `team-warm-send-3` with `messageCount = 3` throughout the chain
  - the other visible conversation summary remains unpolluted after the second retarget, after back, and after the final reopen of the original sent target
  - `adapter.sendMessageCallCount()` stays at `1`
  - `adapter.getHistoryCallCount()` stays pinned at `2`

## Why This Round Stops Here

- `P1-43` only proves the bounded active-detail warm-send -> direct-retarget other visible conversation -> direct-retarget original sent target -> back -> reopen original sent target branch on top of the already-landed Telegram shell send contract.
- This round stays same-package, does not touch `samples/phase07-shared-service-refresh-harness/**`, does not touch `samples/real-message-service-cache-001/**`, does not add shared helper/API, does not expand a generic send API, and does not reopen `P23`.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 34`, `PASSED: 34`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-p1-43-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-original-sent-target-coherence/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 34`, `PASSED: 34`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-p1-43-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-original-sent-target-coherence/timeout-unittest.log`
- verification-side support logs:
  - case existence: `artifacts/verification_contracts/20260418-phase07-telegram-p1-43-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-original-sent-target-coherence/case-existence.log`
  - git scope visibility: `artifacts/verification_contracts/20260418-phase07-telegram-p1-43-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-original-sent-target-coherence/git-scope-check.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-43-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-original-sent-target-coherence/`

## Outcome

- `P1-43` now becomes the current latest Telegram consume checkpoint while the latest shared-harness checkpoint remains `P1-27`.
- The slice proves that the already-landed twin-retarget rail can rebind detail ownership to the original sent target before leaving detail, then still back to the list and reopen the original sent target without growing route history, losing the original sent target summary, or contaminating the other visible summary.
- The slice remains same-package exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any shared-helper/API expansion, generic send API expansion, or broader repo-scope status escalation.
