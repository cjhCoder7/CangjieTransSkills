# 2026-04-18 Phase07 P1-40 Telegram Active-Detail Warm-Send-Back-Reopen Other Visible Conversation Then Direct-Retarget Original Sent Target Coherence Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, once the target conversation is already active on `TelegramChatDetailPage`, Telegram can perform a same-peer warm send through the already-landed shell send path, back to the session list, reopen another visible conversation, and then direct retarget back to the original sent target without reopening shared harness work.

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
  - `AGENTS.md`
- boundary distinction:
  - `P1-39` froze the active-detail warm-send -> back -> reopen other visible conversation stability edge.
  - `P1-40` extends only one step further on the same Telegram consume rail: after that other-visible recovery reopen has already succeeded, the shell may direct retarget back to the original sent target while preserving bounded detail/list coherence.
  - `P1-38` froze the warm-send -> back -> reopen same sent target -> direct-retarget other visible conversation branch; `P1-40` proves the sibling inverse recovery-retarget branch where the shell first reopens another visible conversation and only then direct retargets back to the original sent target.
  - this round is a Telegram consume continuation, not a shared-only continuation, because it exercises only `TelegramAppShell.sendMessageToActiveConversation(...)`, `backFromDetail()`, and `openConversation(...)` on the shell/page/router consume layer and does not touch shared service code.
- regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellWarmSendBackThenReopenOtherVisibleConversationThenDirectRetargetOriginalSentTargetShouldPreserveBoundedCoherence`
- TDD result:
  - the new shell-level regression passed against the existing Telegram consume implementation.
  - no `P1-40`-specific widening is observable in `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj` or `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`.

## Consumption Direction

- the new bounded case performs initial load, opens the target conversation into active detail, sends `team-warm-send-3` through `sendMessageToActiveConversation(...)`, backs through `backFromDetail()`, reopens another visible conversation from the list surface, and then direct retargets back to the original sent target.
- the case proves that:
  - the shell remains on `TelegramChatDetailPage` immediately after send
  - the shell returns to `TelegramSessionListPage` after the back and clears detail getters
  - reopening another visible conversation returns the shell to `TelegramChatDetailPage`
  - direct retarget from that reopened visible conversation keeps `TelegramChatDetailPage` active and rebinds detail ownership to the original sent target
  - route history stays bounded at `2` across send, back, reopen, and retarget
  - detail title / peer label move from the original sent target to the reopened visible conversation and then back to the original sent target while the placeholder-body contract stays unchanged
  - the original sent target summary still preserves `team-warm-send-3` and `messageCount = 3`
  - the reopened visible conversation summary remains unpolluted before send, after send, after back, after reopen, and after final retarget
  - `adapter.sendMessageCallCount()` stays at `1`
  - `adapter.getHistoryCallCount()` stays pinned at the initial-load value of `2`

## Why This Round Stops Here

- `P1-40` only proves the bounded active-detail warm-send -> back -> reopen other visible conversation -> direct-retarget original sent target branch on top of the already-landed Telegram shell send contract.
- This round stays same-package, does not touch `samples/phase07-shared-service-refresh-harness/**`, does not touch `samples/real-message-service-cache-001/**`, does not add shared helper/API, does not expand a generic send API, does not add a list-route send-noop branch, does not add a same-target recovery reopen branch, and does not reopen `P23`.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 31`, `PASSED: 31`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-p1-40-active-detail-warm-send-back-reopen-other-visible-conversation-then-direct-retarget-original-sent-target-coherence/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 31`, `PASSED: 31`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-p1-40-active-detail-warm-send-back-reopen-other-visible-conversation-then-direct-retarget-original-sent-target-coherence/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-40-active-detail-warm-send-back-reopen-other-visible-conversation-then-direct-retarget-original-sent-target-coherence/`

## Outcome

- `P1-40` now becomes the current latest Telegram consume checkpoint while the latest shared-harness checkpoint remains `P1-27`.
- The slice proves that the already-landed warm-send-back recovery rail can reopen another visible conversation and then direct retarget back to the original sent target: route history stays `2`, detail ownership cleanly returns to the original sent target, the original sent target summary continues carrying `team-warm-send-3` with `messageCount = 3`, the intermediate other visible summary remains untouched, and no extra send or history refetch occurs.
- The slice remains same-package exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any shared-helper/API expansion, generic send API expansion, or broader repo-scope status escalation.
