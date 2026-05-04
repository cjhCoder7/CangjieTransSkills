# 2026-04-17 Phase07 P1-31 Telegram Active-Detail Warm-Send-Retarget Alternating-Reopen Bounded Stability Consume Slice

## Goal

Land the next bounded Telegram app-shell consume slice inside `samples/telegram-ui-vertical-slice-001` by proving that, once the target conversation is already active on `TelegramChatDetailPage`, Telegram can perform a same-peer warm send through the already-landed shell send path, directly retarget to another visible conversation, back to the session list, reopen the original sent target, back again, and finally reopen the other visible conversation without reopening shared harness work.

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
  - `P1-30` froze the active-detail same-peer warm-send direct-retarget-back-reopen original-target edge.
  - `P1-31` extends only one step further on the Telegram consume rail: after that warm send, direct retarget, and reopen of the original sent target, the shell may back again and finally reopen the other visible conversation while preserving bounded detail/list coherence.
  - this round is smaller than any shared-only continuation because it exercises `TelegramAppShell.sendMessageToActiveConversation(...)`, active-detail `openConversation(...)`, and `backFromDetail()` on the shell/page/router consume layer and does not touch shared service code.
- regression lock:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `appShellWarmSendRetargetAlternatingReopenShouldKeepBoundedStableDetailOwnership`
- TDD result:
  - the new shell-level regression passed immediately against the existing Telegram consume implementation.
  - no production-code widening was required in this round; the slice lands as a Telegram consume contract-freeze plus evidence refresh.

## Consumption Direction

- the new bounded case performs initial load, opens the target conversation into active detail, sends `team-warm-send-3` through `sendMessageToActiveConversation(...)`, directly retargets to the other visible conversation through the existing active-detail `openConversation(...)` path, backs through `backFromDetail()`, reopens the original sent target, backs again, and finally reopens the other visible conversation from the list surface.
- the case proves that:
  - the shell returns to `TelegramSessionListPage` after both back operations
  - detail getters clear on both back-to-list resets
  - reopening the original sent target returns the shell to `TelegramChatDetailPage`
  - the final reopen of the other visible conversation also returns the shell to `TelegramChatDetailPage`
  - route history stays bounded at `2` across send, retarget, both backs, and both reopens
  - the final detail title / peer label bind to the other visible conversation while the placeholder body contract stays unchanged throughout
  - the original sent target summary still preserves the sent text and `messageCount = 3`
  - the other visible summary remains unpolluted before retarget, after retarget, after both backs, and after the final reopen
  - `adapter.getHistoryCallCount()` stays pinned at the initial-load value of `2`
  - `adapter.sendMessageCallCount()` stays at `1`

## Why This Round Stops Here

- `P1-31` only proves the bounded active-detail warm-send -> direct-retarget -> back -> reopen-original-target -> back -> reopen-other alternating round trip on top of the already-landed Telegram shell send and detail-retarget contracts.
- This round does not touch `samples/phase07-shared-service-refresh-harness/**`, does not touch `samples/real-message-service-cache-001/**`, does not add shared helper/API, does not expand a generic send API, does not reopen `P23`, and does not create any Harmony live / Windows `Staging-Full` / promoted claim.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 22`, `PASSED: 22`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-telegram-p1-31-active-detail-warm-send-retarget-alternating-reopen-bounded-stability/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 22`, `PASSED: 22`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260417-phase07-telegram-p1-31-active-detail-warm-send-retarget-alternating-reopen-bounded-stability/timeout-unittest.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-31-active-detail-warm-send-retarget-alternating-reopen-bounded-stability/`

## Outcome

- `P1-31` now proves that, after initial load has already warmed the visible conversations and the target conversation is active on `TelegramChatDetailPage`, a same-peer warm send followed by direct retarget to another visible conversation, `backFromDetail()`, reopen of the original sent target, another `backFromDetail()`, and final reopen of the other visible conversation can keep the shell bounded at route history `2`, clear detail projection on both back-to-list resets, rebind final detail ownership to the other visible conversation, preserve the placeholder-body contract, keep the original sent target summary carrying the sent text with `messageCount = 3`, leave the other visible summary untouched, and avoid any extra history refetch beyond the initial warm load.
- The slice remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not create any promotion, live, mechanical-ready, `Windows Staging-Full`, or Full Pass claim.
