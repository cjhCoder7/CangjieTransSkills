# 2026-04-18 Phase07 P1-39 Telegram Active-Detail Warm-Send-Back-Reopen Other Visible Conversation Stability Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, once the target conversation is already active on `TelegramChatDetailPage`, Telegram can perform a same-peer warm send through the already-landed shell send path, back to the session list, and reopen another visible conversation without reopening shared harness work.

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
  - `P1-32` froze the active-detail warm-send -> back -> reopen same-sent-target coherence edge.
  - `P1-39` freezes a sibling recovery edge on the same Telegram consume rail: after that back-to-list reset has already succeeded, the shell may reopen another visible conversation while preserving bounded detail/list stability.
  - `P1-35` froze the warm-send -> back -> list-route send-noop -> reopen other visible conversation branch; `P1-39` proves that the same other-visible reopen remains stable without taking the intermediate list-route send-noop branch.
  - `P1-37` froze the warm-send -> back -> list-route send-noop -> reopen same sent target -> back -> reopen other visible conversation alternating branch; `P1-39` does not require the no-op branch, the same-target recovery reopen, or the second back-to-list reset.
  - this round is a Telegram consume continuation, not a shared-only continuation, because it exercises only `TelegramAppShell.sendMessageToActiveConversation(...)`, `backFromDetail()`, and `openConversation(...)` on the shell/page/router consume layer and does not touch shared service code.
- regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj:697`
  - `appShellWarmSendBackThenReopenOtherVisibleConversationShouldPreserveBoundedStability`
- TDD result:
  - the new shell-level regression passed against the existing Telegram consume implementation.
  - no `P1-39`-specific widening is observable in `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj` or `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`.

## Consumption Direction

- the new bounded case performs initial load, opens the target conversation into active detail, sends `team-warm-send-3` through `sendMessageToActiveConversation(...)`, backs through `backFromDetail()`, and then reopens another visible conversation from the list surface.
- the case proves that:
  - the shell remains on `TelegramChatDetailPage` immediately after send
  - the shell returns to `TelegramSessionListPage` after the back and clears detail getters
  - reopening another visible conversation returns the shell to `TelegramChatDetailPage`
  - route history stays bounded at `2` across send, back, and reopen
  - detail title / peer label move from the original sent target to the reopened visible conversation while the placeholder-body contract stays unchanged
  - the original sent target summary still preserves `team-warm-send-3` and `messageCount = 3`
  - the reopened visible conversation summary remains unpolluted before send, after send, after back, and after reopen
  - `adapter.sendMessageCallCount()` stays at `1`
  - `adapter.getHistoryCallCount()` stays pinned at the initial-load value of `2`

## Why This Round Stops Here

- `P1-39` only proves the bounded active-detail warm-send -> back -> reopen other visible conversation branch on top of the already-landed Telegram shell send contract.
- This round does not touch `samples/phase07-shared-service-refresh-harness/**`, does not touch `samples/real-message-service-cache-001/**`, does not add shared helper/API, does not expand a generic send API, does not add a list-route send-noop branch, does not add a same-target recovery reopen branch, does not reopen `P23`, and does not create any higher-staging claim.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 30`, `PASSED: 30`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-p1-39-active-detail-warm-send-back-reopen-other-visible-conversation-stability/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 30`, `PASSED: 30`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-p1-39-active-detail-warm-send-back-reopen-other-visible-conversation-stability/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-39-active-detail-warm-send-back-reopen-other-visible-conversation-stability/`

## Outcome

- `P1-39` now becomes the current latest Telegram consume checkpoint while the latest shared-harness checkpoint remains `P1-27`.
- The slice proves that the already-landed warm-send-back recovery rail can reopen another visible conversation directly from the list route: route history stays `2`, detail ownership cleanly switches to the reopened visible conversation, the original sent target summary continues carrying `team-warm-send-3` with `messageCount = 3`, the reopened visible summary remains untouched, and no extra send or history refetch occurs.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any shared-helper expansion, generic send expansion, or higher-staging claim.
