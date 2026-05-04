# 2026-04-17 Phase07 P1-28 Telegram Active-Detail Warm-Send Summary Coherence Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, once the target conversation is already active on `TelegramChatDetailPage`, Telegram can consume the already-frozen shared `sendMessage(...)` capability for a same-peer warm send without reopening shared harness work.

## Decision

- landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `specs/phase07-telegram-ui-incubation/tasks.md`
  - `docs/status/current_committed_plan.md`
  - `docs/status/INDEX.md`
  - `docs/current_state.v2.md`
  - `docs/runtime_contract.v2.md`
  - `docs/status/current_task_handoff.md`
  - `AGENTS.md`
- boundary distinction:
  - `P1-26` froze the shared second-consumer warm-send append-without-refetch parity edge.
  - `P1-27` froze the shared second-consumer warm-send repeated-get reuse/no-refetch edge.
  - `P1-28` is the first Telegram consume writeback on top of that frozen shared send surface: it proves an active-detail same-peer warm send can update the target summary without widening shared helper/API, shared service semantics, or shared-harness scope.
- consumption direction:
  - `TelegramAppShell.sendMessageToActiveConversation(...)` reads the current detail-route peer and keeps the consume boundary pinned to the active-detail same-peer case instead of introducing a route-independent send API.
  - `TelegramSessionListPage.sendMessage(...)` and `TelegramSessionListController.sendMessage(...)` reuse the existing shared `RealMessageService.sendMessage(SendMessageParams(...))` plus `MainContextDatasetRefreshBridge.drainOnMain()` path, so the list summary refresh stays in the already-landed refresh observer flow.
  - the detail route remains route-owned: same-peer warm send does not replace the route, does not grow history, and does not alter the existing title / peer-label / placeholder-body contract.
- regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellWarmSendOnActiveDetailShouldKeepSummaryAndDetailCoherentWithoutHistoryRefetch`
- TDD red phase:
  - the first red run failed at compile time because `TelegramAppShell` did not yet expose `sendMessageToActiveConversation(...)`.
  - that red failure localized the gap to Telegram app-shell consume surface rather than shared harness semantics, so the fix stayed inside `samples/telegram-ui-vertical-slice-001`.

## Why This Round Stops Here

- `P1-28` only proves the first Telegram app-shell consumption of the already-frozen shared `sendMessage(...)` capability for the active-detail same-peer warm-send path.
- This round does not touch `samples/phase07-shared-service-refresh-harness/**`, does not touch `samples/real-message-service-cache-001/**`, does not add shared helper/API, does not reopen `P23`, and does not create any Harmony live / Windows `Staging-Full` / promoted claim.
- The new code remains a bounded Telegram consume writeback because the only production widening is local shell/page/controller plumbing needed to call the pre-existing shared send surface and drain the already-existing refresh bridge on main.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 19`, `PASSED: 19`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-telegram-p1-28-active-detail-warm-send-summary-coherence/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 19`, `PASSED: 19`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-telegram-p1-28-active-detail-warm-send-summary-coherence/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-28-active-detail-warm-send-summary-coherence/`

## Outcome

- `P1-28` now proves that, after initial load has already warmed the target conversation and that target is active on `TelegramChatDetailPage`, a same-peer warm send can keep the shell pinned to `TelegramChatDetailPage`, keep route history bounded at `2`, preserve `currentDetailTitle()` / `currentDetailPeerLabel()` / `currentDetailBody()`, update the target summary `previewText` to the sent text, grow the target summary `messageCount` from `2` to `3`, leave the non-target summary unchanged, keep `adapter.getHistoryCallCount()` pinned at the initial-load value of `2`, and record exactly one `adapter.sendMessage(...)` call.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.
