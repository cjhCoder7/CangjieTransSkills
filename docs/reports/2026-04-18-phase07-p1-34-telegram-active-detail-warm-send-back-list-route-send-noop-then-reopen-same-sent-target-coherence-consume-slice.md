# 2026-04-18 Phase07 P1-34 Telegram Active-Detail Warm-Send-Back List-Route Send-Noop Then Reopen Same-Sent-Target Coherence Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, once the target conversation is already active on `TelegramChatDetailPage`, Telegram can perform a same-peer warm send through the already-landed shell send path, back to the session list, observe list-route `sendMessageToActiveConversation(...)` no-op, and then reopen the same sent target without reopening shared harness work.

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
  - `P1-33` froze the active-detail warm-send -> back-to-list -> list-route send-noop boundary.
  - `P1-34` extends only one step further on the Telegram consume rail: after that no-op boundary has been observed, the shell may reopen the same sent target while preserving bounded detail/list coherence.
  - this round is smaller than any shared-only continuation because it exercises `TelegramAppShell.sendMessageToActiveConversation(...)`, `backFromDetail()`, and same-target `openConversation(...)` on the shell/page/router consume layer and does not touch shared service code.
- regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellWarmSendBackListRouteSendNoopThenReopenSameSentTargetShouldPreserveBoundedCoherence`
- TDD result:
  - the new shell-level regression passed immediately against the existing Telegram consume implementation.
  - no production-code widening was required in this round; the slice lands as a Telegram consume contract-freeze plus evidence refresh.

## Consumption Direction

- the new bounded case performs initial load, opens the target conversation into active detail, sends `team-warm-send-3` through `sendMessageToActiveConversation(...)`, backs through `backFromDetail()`, attempts `sendMessageToActiveConversation("should-not-send")` again from the list route, and then reopens the same sent target.
- the case proves that:
  - the shell stays on `TelegramSessionListPage` immediately after the list-route no-op
  - detail getters stay empty across that no-op
  - reopening the same sent target returns the shell to `TelegramChatDetailPage`
  - route history stays bounded at `2` across send, back, no-op, and reopen
  - detail title / peer label rebind to the same sent target while the placeholder body contract stays unchanged
  - the sent target summary still preserves `team-warm-send-3` and `messageCount = 3`
  - the other visible summary remains unpolluted before and after the no-op and after the reopen
  - `adapter.sendMessageCallCount()` stays at `1`
  - `adapter.getHistoryCallCount()` stays pinned at the initial-load value of `2`

## Why This Round Stops Here

- `P1-34` only proves the bounded active-detail warm-send -> back-to-list -> list-route send-noop -> reopen-same-target round trip on top of the already-landed Telegram shell send contract.
- This round does not touch `samples/phase07-shared-service-refresh-harness/**`, does not touch `samples/real-message-service-cache-001/**`, does not add shared helper/API, does not expand a generic send API, does not introduce retarget or alternating-reopen as new scope, does not reopen `P23`, and does not create any Harmony live / Windows `Staging-Full` / promoted claim.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 25`, `PASSED: 25`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-p1-34-active-detail-warm-send-back-list-route-send-noop-then-reopen-same-sent-target-coherence/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 25`, `PASSED: 25`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-p1-34-active-detail-warm-send-back-list-route-send-noop-then-reopen-same-sent-target-coherence/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-34-active-detail-warm-send-back-list-route-send-noop-then-reopen-same-sent-target-coherence/`

## Outcome

- `P1-34` now proves that, after initial load has already warmed the visible conversations and the target conversation is active on `TelegramChatDetailPage`, a same-peer warm send followed by direct `backFromDetail()` can return the shell to the list route, keep `sendMessageToActiveConversation(...)` bounded as a list-route no-op, and still allow reopen of the same sent target without losing bounded detail/list coherence: route history stays `2`, detail projection stays empty until reopen, the reopened detail rebinds to the original sent target, the sent target summary continues carrying `team-warm-send-3` with `messageCount = 3`, the other visible summary remains untouched, no stale active peer is reused for an extra send, and no extra history refetch occurs.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.
