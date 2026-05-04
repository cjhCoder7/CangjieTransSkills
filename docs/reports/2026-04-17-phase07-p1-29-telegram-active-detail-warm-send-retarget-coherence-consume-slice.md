# 2026-04-17 Phase07 P1-29 Telegram Active-Detail Warm-Send-Retarget Coherence Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, once the target conversation is already active on `TelegramChatDetailPage`, Telegram can perform a same-peer warm send through the already-landed shell send path and then directly retarget to another visible conversation without reopening shared harness work.

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
  - `P1-29` extends only one step further on the Telegram consume rail: after that warm send, the shell may directly retarget to another visible conversation while preserving bounded detail/list coherence.
  - this round is smaller than any shared-only continuation because it exercises `TelegramAppShell.sendMessageToActiveConversation(...)` plus active-detail `openConversation(...)` on the shell/page/router consume layer and does not touch shared service code.
- regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellWarmSendThenDirectRetargetShouldPreserveBoundedDetailAndListCoherence`
- TDD result:
  - the new shell-level regression passed immediately against the existing Telegram consume implementation.
  - no production-code widening was required in this round; the slice lands as a Telegram consume contract-freeze plus evidence refresh.

## Consumption Direction

- the new bounded case performs initial load, opens the target conversation into active detail, sends `team-warm-send-3` through `sendMessageToActiveConversation(...)`, and then directly retargets to the other visible conversation through the existing active-detail `openConversation(...)` path.
- the case proves that:
  - the shell remains on `TelegramChatDetailPage`
  - route history stays bounded at `2`
  - detail title / peer label switch to the retargeted visible conversation while the placeholder body contract stays unchanged
  - the original target summary still preserves the sent text and `messageCount = 3`
  - the retargeted visible summary remains unpolluted before and after retarget
  - `adapter.getHistoryCallCount()` stays pinned at the initial-load value of `2`
  - `adapter.sendMessageCallCount()` stays at `1`

## Why This Round Stops Here

- `P1-29` only proves the bounded active-detail warm-send -> direct-retarget coherence path on top of the already-landed Telegram shell send and detail-retarget contracts.
- This round does not touch `samples/phase07-shared-service-refresh-harness/**`, does not touch `samples/real-message-service-cache-001/**`, does not add shared helper/API, does not expand a generic send API, does not reopen `P23`, and does not create any Harmony live / Windows `Staging-Full` / promoted claim.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 20`, `PASSED: 20`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-telegram-p1-29-active-detail-warm-send-retarget-coherence/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 20`, `PASSED: 20`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-telegram-p1-29-active-detail-warm-send-retarget-coherence/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-29-active-detail-warm-send-retarget-coherence/`

## Outcome

- `P1-29` now proves that, after initial load has already warmed the visible conversations and the target conversation is active on `TelegramChatDetailPage`, a same-peer warm send followed by direct retarget to another visible conversation can keep the shell pinned to `TelegramChatDetailPage`, keep bounded history at `2`, switch detail ownership to the retargeted visible conversation, preserve the placeholder-body contract, keep the original target summary carrying the sent text with `messageCount = 3`, leave the retargeted visible summary untouched, and avoid any extra history refetch beyond the initial warm load.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.
