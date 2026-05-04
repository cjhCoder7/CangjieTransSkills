# 2026-04-17 Phase07 P1-32 Telegram Active-Detail Warm-Send-Back-Reopen Sent-Target Coherence Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, once the target conversation is already active on `TelegramChatDetailPage`, Telegram can perform a same-peer warm send through the already-landed shell send path, back to the session list, and then reopen the same sent target without reopening shared harness work.

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
  - `P1-28` froze the active-detail same-peer warm-send summary coherence edge.
  - `P1-32` extends only one step further on the Telegram consume rail: after that warm send, the shell may back to the session list and reopen the same sent target while preserving bounded detail/list coherence.
  - this round is smaller than any shared-only continuation because it exercises `TelegramAppShell.sendMessageToActiveConversation(...)` and `backFromDetail()` on the shell/page/router consume layer and does not touch shared service code.
- regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellWarmSendBackThenReopenSameSentTargetShouldPreserveBoundedCoherence`
- TDD result:
  - the new shell-level regression passed immediately against the existing Telegram consume implementation.
  - no production-code widening was required in this round; the slice lands as a Telegram consume contract-freeze plus evidence refresh.

## Consumption Direction

- the new bounded case performs initial load, opens the target conversation into active detail, sends `team-warm-send-3` through `sendMessageToActiveConversation(...)`, backs through `backFromDetail()`, and then reopens the same sent target from the list surface.
- the case proves that:
  - the shell remains on `TelegramChatDetailPage` immediately after send
  - the shell returns to `TelegramSessionListPage` after the back
  - detail getters clear on that back-to-list reset
  - reopening the same sent target returns the shell to `TelegramChatDetailPage`
  - route history stays bounded at `2` across send, back, and reopen
  - detail title / peer label rebind to the same sent target while the placeholder body contract stays unchanged
  - the sent target summary still preserves the sent text and `messageCount = 3`
  - the other visible summary remains unpolluted before send, after send, after back, and after reopen
  - `adapter.getHistoryCallCount()` stays pinned at the initial-load value of `2`
  - `adapter.sendMessageCallCount()` stays at `1`

## Why This Round Stops Here

- `P1-32` only proves the bounded active-detail warm-send -> back -> reopen-same-target round trip on top of the already-landed Telegram shell send contract.
- This round does not touch `samples/phase07-shared-service-refresh-harness/**`, does not touch `samples/real-message-service-cache-001/**`, does not add shared helper/API, does not expand a generic send API, does not introduce retarget or alternating-reopen as new scope, does not reopen `P23`, and does not create any Harmony live / Windows `Staging-Full` / promoted claim.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 23`, `PASSED: 23`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-telegram-p1-32-active-detail-warm-send-back-reopen-sent-target-coherence/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 23`, `PASSED: 23`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-telegram-p1-32-active-detail-warm-send-back-reopen-sent-target-coherence/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-32-active-detail-warm-send-back-reopen-sent-target-coherence/`

## Outcome

- `P1-32` now proves that, after initial load has already warmed the visible conversations and the target conversation is active on `TelegramChatDetailPage`, a same-peer warm send followed by direct `backFromDetail()` and reopen of the same sent target can keep the shell bounded at route history `2`, clear detail projection on the back-to-list reset, rebind detail ownership to the same sent target on reopen, preserve the placeholder-body contract, keep the sent target summary carrying the sent text with `messageCount = 3`, leave the other visible summary untouched, and avoid any extra history refetch beyond the initial warm load.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.
