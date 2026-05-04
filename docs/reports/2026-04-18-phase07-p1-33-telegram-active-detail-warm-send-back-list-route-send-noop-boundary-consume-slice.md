# 2026-04-18 Phase07 P1-33 Telegram Active-Detail Warm-Send-Back List-Route Send-Noop Boundary Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, once the target conversation is already active on `TelegramChatDetailPage`, Telegram can perform a same-peer warm send through the already-landed shell send path, back to the session list, and then treat any list-route `sendMessageToActiveConversation(...)` call as a no-op without reopening shared harness work.

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
  - `P1-32` froze the active-detail warm-send -> back -> reopen-same-target coherence edge.
  - `P1-33` extends only one step further on the Telegram consume rail: after that warm send and back-to-list reset, the shell send entry must no-op on the list route instead of leaking the old active peer.
  - this round is smaller than any shared-only continuation because it exercises `TelegramAppShell.sendMessageToActiveConversation(...)` and `backFromDetail()` on the shell/page/router consume layer and does not touch shared service code.
- regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellWarmSendBackThenListRouteSendShouldNoopWithoutLeakingOldActivePeer`
- TDD result:
  - the new shell-level regression passed immediately against the existing Telegram consume implementation.
  - no production-code widening was required in this round; the slice lands as a Telegram consume contract-freeze plus evidence refresh.

## Consumption Direction

- the new bounded case performs initial load, opens the target conversation into active detail, sends `team-warm-send-3` through `sendMessageToActiveConversation(...)`, backs through `backFromDetail()`, and then attempts `sendMessageToActiveConversation("should-not-send")` again from the list route.
- the case proves that:
  - the shell returns to `TelegramSessionListPage` after the back
  - detail getters stay empty on that back-to-list reset
  - the list-route `sendMessageToActiveConversation(...)` call does not reactivate detail ownership
  - route history stays bounded at `2` across send, back, and list-route no-op
  - the sent target summary still preserves `team-warm-send-3` and `messageCount = 3`
  - the other visible summary remains unpolluted before and after the list-route no-op
  - `adapter.sendMessageCallCount()` stays at `1`
  - `adapter.getHistoryCallCount()` stays pinned at the initial-load value of `2`

## Why This Round Stops Here

- `P1-33` only proves the bounded active-detail warm-send -> back-to-list -> list-route send-noop boundary on top of the already-landed Telegram shell send contract.
- This round does not touch `samples/phase07-shared-service-refresh-harness/**`, does not touch `samples/real-message-service-cache-001/**`, does not add shared helper/API, does not expand a generic send API, does not introduce reopen or retarget as new scope, does not reopen `P23`, and does not create any Harmony live / Windows `Staging-Full` / promoted claim.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 24`, `PASSED: 24`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-p1-33-active-detail-warm-send-back-list-route-send-noop-boundary/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 24`, `PASSED: 24`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-p1-33-active-detail-warm-send-back-list-route-send-noop-boundary/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-33-active-detail-warm-send-back-list-route-send-noop-boundary/`

## Outcome

- `P1-33` now proves that, after initial load has already warmed the visible conversations and the target conversation is active on `TelegramChatDetailPage`, a same-peer warm send followed by direct `backFromDetail()` can return the shell to the list route, clear detail projection, and then keep `sendMessageToActiveConversation(...)` bounded as a list-route no-op: route history stays `2`, the sent target summary continues carrying `team-warm-send-3` with `messageCount = 3`, the other visible summary remains untouched, no stale active peer is reused, no extra send is issued, and no extra history refetch occurs.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.
