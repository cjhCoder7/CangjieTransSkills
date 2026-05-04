# 2026-04-18 Phase07 P1-42 Telegram Active-Detail Warm-Send Direct-Retarget Other Visible Conversation Then Direct-Retarget Original Sent Target Back-Reopen Other Visible Conversation Bounded Stability Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, once the original sent target conversation is already active on `TelegramChatDetailPage`, Telegram can perform a same-peer warm send, direct retarget to another visible conversation, direct retarget back to the original sent target, back out to the list, and then reopen the other visible conversation without reopening shared harness work or widening the existing same-package shell surface.

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
- boundary distinction:
  - `P1-41` froze the bounded active-detail warm-send -> direct-retarget other visible conversation -> direct-retarget original sent target branch.
  - `P1-42` extends only one bounded step further on the same Telegram consume rail: after the second direct retarget has already rebound detail ownership to the original sent target, the shell may `backFromDetail()` and reopen the other visible conversation while preserving bounded stability.
  - `P1-40` froze the sibling branch where warm-send first backs to the list, reopens another visible conversation, and only then direct retargets back to the original sent target; `P1-42` instead keeps send and both retargets inside `TelegramChatDetailPage` first, then performs the final back-reopen tail.
  - `P1-31` froze the sibling alternating-reopen branch where warm-send direct retargets to another visible conversation, backs to the list, reopens the original sent target, backs again, and reopens the other visible conversation; `P1-42` replaces that recovery reopen of the original sent target with a second direct retarget while the shell is still on detail, then adds only one bounded back-reopen-other tail.
- regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellWarmSendThenDirectRetargetOtherVisibleConversationThenDirectRetargetOriginalSentTargetBackThenReopenOtherVisibleConversationShouldPreserveBoundedStability`
- TDD result:
  - the new shell-level regression passed against the existing Telegram consume implementation.
  - the landed regression did not require production edits; git tracked baseline is unavailable for `samples/telegram-ui-vertical-slice-001/src`, so the strongest safe statement is that no `P1-42`-specific widening is observable in `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj` or `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj` from the current verification surface.
  - `docs/agent_system/execution_routing.md` also received a stale-pointer repair from `P1-39` to the new current Telegram consume entry, but that routing fix is secondary sync work rather than the proof of landing.

## Consumption Direction

- the new bounded case performs initial load, opens the original sent target conversation into active detail, sends `team-warm-send-3` through `sendMessageToActiveConversation(...)`, direct retargets to another visible conversation, direct retargets back to the original sent target, backs to `TelegramSessionListPage`, and then reopens the other visible conversation.
- the case proves that:
  - send and both direct retargets still leave the shell on `TelegramChatDetailPage`
  - after the second direct retarget, `backFromDetail()` returns the shell to `TelegramSessionListPage` and clears all detail getters
  - the final reopen of the other visible conversation returns the shell to `TelegramChatDetailPage`
  - `historySize()` stays bounded at `2` across send, both retargets, back, and the final reopen
  - the original sent target summary preserves `team-warm-send-3` with `messageCount = 3` throughout the chain
  - the other visible conversation summary remains unpolluted before the final reopen and after the final reopen
  - `adapter.sendMessageCallCount()` stays at `1`
  - `adapter.getHistoryCallCount()` stays pinned at `2`

## Why This Round Stops Here

- `P1-42` only proves the bounded active-detail warm-send -> direct-retarget other visible conversation -> direct-retarget original sent target -> back -> reopen other visible conversation branch on top of the already-landed Telegram shell send contract.
- This round stays same-package, does not touch `samples/phase07-shared-service-refresh-harness/**`, does not touch `samples/real-message-service-cache-001/**`, does not add shared helper/API, does not expand a generic send API, and does not reopen `P23`.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 33`, `PASSED: 33`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-p1-42-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-other-visible-conversation-bounded-stability/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 33`, `PASSED: 33`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-p1-42-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-other-visible-conversation-bounded-stability/timeout-unittest.log`
- verification-side support logs:
  - case existence: `artifacts/verification_contracts/20260418-phase07-telegram-p1-42-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-other-visible-conversation-bounded-stability/case-existence.log`
  - git scope visibility: `artifacts/verification_contracts/20260418-phase07-telegram-p1-42-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-other-visible-conversation-bounded-stability/git-scope-check.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-42-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-other-visible-conversation-bounded-stability/`

## Outcome

- `P1-42` now becomes the current latest Telegram consume checkpoint while the latest shared-harness checkpoint remains `P1-27`.
- The slice proves that the already-landed warm-send direct-retarget rail can rebind detail ownership back to the original sent target before leaving detail, then still back to the list and reopen the other visible conversation without growing route history, losing the original sent target summary, or contaminating the other visible summary.
- The slice remains same-package exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any shared-helper/API expansion, generic send API expansion, or broader repo-scope status escalation.
