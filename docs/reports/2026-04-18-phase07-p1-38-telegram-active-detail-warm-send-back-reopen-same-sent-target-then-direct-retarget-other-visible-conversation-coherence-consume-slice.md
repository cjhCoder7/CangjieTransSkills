# 2026-04-18 Phase07 P1-38 Telegram Active-Detail Warm-Send-Back-Reopen Same-Sent-Target Then Direct-Retarget Other Visible Conversation Coherence Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, once the target conversation is already active on `TelegramChatDetailPage`, Telegram can perform a same-peer warm send through the already-landed shell send path, back to the session list, reopen the same sent target, and then direct retarget to another visible conversation without reopening shared harness work.

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
  - `P1-38` extends only one step further on the Telegram consume rail: after that same-target recovery reopen has already succeeded, the shell may direct retarget to another visible conversation while preserving bounded detail/list coherence.
  - `P1-29` froze the warm-send -> direct-retarget branch from an already-active detail route; `P1-38` proves that the same retarget remains coherent even after the intermediate back-to-list reset plus same-target recovery reopen.
  - this round is a Telegram consume continuation, not a shared-only continuation, because it exercises only `TelegramAppShell.sendMessageToActiveConversation(...)`, `backFromDetail()`, and `openConversation(...)` on the shell/page/router consume layer and does not touch shared service code.
- regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj:615`
  - `appShellWarmSendBackThenReopenSameSentTargetThenDirectRetargetShouldPreserveBoundedCoherence`
- TDD result:
  - the new shell-level regression passed against the existing Telegram consume implementation.
  - no production-code widening was required in this round; no `P1-38`-specific widening is observable in `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj` or `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`.

## Consumption Direction

- the new bounded case performs initial load, opens the target conversation into active detail, sends `team-warm-send-3` through `sendMessageToActiveConversation(...)`, backs through `backFromDetail()`, reopens the same sent target from the list surface, and then direct retargets to another visible conversation.
- the case proves that:
  - the shell remains on `TelegramChatDetailPage` immediately after send
  - the shell returns to `TelegramSessionListPage` after the back and clears detail getters
  - reopening the same sent target returns the shell to `TelegramChatDetailPage`
  - direct retarget after that same-target recovery reopen keeps `TelegramChatDetailPage` active
  - route history stays bounded at `2` across send, back, reopen, and retarget
  - detail title / peer label move from the original sent target to the retargeted visible conversation while the placeholder-body contract stays unchanged
  - the original sent target summary still preserves `team-warm-send-3` and `messageCount = 3`
  - the retarget target summary remains unpolluted before send, after send, after back, after reopen, and after retarget
  - `adapter.sendMessageCallCount()` stays at `1`
  - `adapter.getHistoryCallCount()` stays pinned at the initial-load value of `2`

## Why This Round Stops Here

- `P1-38` only proves the bounded active-detail warm-send -> back -> reopen same-sent-target -> direct-retarget other visible conversation branch on top of the already-landed Telegram shell send contract.
- This round does not touch `samples/phase07-shared-service-refresh-harness/**`, does not touch `samples/real-message-service-cache-001/**`, does not add shared helper/API, does not expand a generic send API, does not add a list-route send-noop branch, does not reopen `P23`, and does not create any Harmony live / Windows `Staging-Full` / promoted / mechanical-ready claim.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 29`, `PASSED: 29`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-p1-38-active-detail-warm-send-back-reopen-same-sent-target-then-direct-retarget-other-visible-conversation-coherence/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 29`, `PASSED: 29`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-p1-38-active-detail-warm-send-back-reopen-same-sent-target-then-direct-retarget-other-visible-conversation-coherence/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-38-active-detail-warm-send-back-reopen-same-sent-target-then-direct-retarget-other-visible-conversation-coherence/`

## Outcome

- `P1-38` now becomes the current latest Telegram consume checkpoint while the latest shared-harness checkpoint remains `P1-27`.
- The slice proves that the already-landed warm-send-back same-target recovery rail still preserves bounded coherence when it is extended by one direct retarget to another visible conversation: route history stays `2`, detail ownership cleanly switches to the retargeted visible conversation, the original sent target summary continues carrying `team-warm-send-3` with `messageCount = 3`, the retarget target summary remains untouched, and no extra send or history refetch occurs.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.
