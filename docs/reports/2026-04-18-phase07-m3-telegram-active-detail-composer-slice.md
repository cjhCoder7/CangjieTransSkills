# 2026-04-18 Phase07 M3 Telegram Active-Detail Composer Slice

## Goal

Land `M3 Telegram Active-Detail Composer Slice` inside `samples/telegram-ui-vertical-slice-001` by promoting the already-landed active-detail usable-thread surface into a same-package composer slice: while a visible conversation is active in `TelegramChatDetailPage`, the shell must expose detail draft state, allow draft updates, send the draft through the existing Telegram-local send path, clear the draft after send, and reset draft state across list-route no-op, direct retarget, back, and reopen transitions without reopening shared harness work or widening the generic send surface.

## Decision

- landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `specs/phase07-telegram-ui-incubation/tasks.md`
  - `docs/reports/2026-04-15-phase07-app-shell-consume-boundary.md`
  - `docs/reports/2026-04-18-phase07-m3-telegram-active-detail-composer-slice.md`
  - `docs/status/current_committed_plan.md`
  - `docs/status/INDEX.md`
  - `docs/current_state.v2.md`
  - `docs/runtime_contract.v2.md`
  - `docs/status/current_task_handoff.md`
  - `docs/agent_system/execution_routing.md`
  - `AGENTS.md`
- milestone scope:
  - active-detail composer tracks draft and clears after send:
    - regression lock: `appShellActiveDetailComposerShouldTrackDraftAndClearAfterSend`
  - list-route composer update/send remain bounded no-op:
    - regression lock: `appShellDetailComposerShouldNoopWithoutActiveConversation`
  - retarget / back / reopen reset draft while preserving thread ownership:
    - regression lock: `appShellDetailComposerShouldResetAcrossRetargetBackReopen`
- boundary distinction:
  - `M2` remains the landed usable-thread milestone that introduced real-history projection.
  - `M3` is the next same-package Telegram UI milestone: it stops pursuing more route sibling permutations and instead upgrades active detail from thread projection to minimal composer usability.
  - This round still does not touch `samples/phase07-shared-service-refresh-harness/**`, `samples/real-message-service-cache-001/**`, `P23`, shared helper/API, generic send abstraction, or per-peer draft persistence rollout.

## Production Changes

- `TelegramChatDetailPage` now keeps a local active-detail draft and exposes `composerDraft()`, `updateDraft(...)`, and `sendDraft(...)`.
- `TelegramChatDetailPage.aboutToAppear()` now resets draft state only when detail ownership changes or the route returns to list, so same-peer reads do not accidentally wipe an in-progress draft.
- `TelegramAppShell` now exposes `currentDetailDraft()`, `updateDetailDraft(...)`, and `sendDetailDraft()` so shell-level regressions can drive the composer through the same-package app-shell boundary.

## Behavior Frozen By M3

- Opening a visible conversation into detail still projects the correct current thread, and the active detail now starts with an empty composer draft.
- While detail is active, `updateDetailDraft(...)` reflects the latest draft and `sendDetailDraft()` appends that draft text into the projected thread immediately, keeps the target list summary synchronized with sent text and `messageCount`, and clears the draft.
- When no conversation is active, detail draft update/send remains a no-op: the shell stays on `TelegramSessionListPage`, history does not grow, and summaries do not change.
- Direct retarget to another visible conversation resets draft ownership to empty while switching the projected thread to the new target.
- `backFromDetail()` still clears detail projection and now also clears the draft; reopening any visible conversation restores the correct projected thread with an empty draft.

## Why This Round Stops Here

- `M3` only upgrades same-package Telegram detail consumption to minimal composer usability.
- It does not widen into broader UI redesign, shared continuation, shared helper rollout, per-peer draft persistence, generic send expansion, Harmony live / promoted wording, or any non-repo-local claim.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 40`, `PASSED: 40`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-m3-active-detail-composer-slice/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 40`, `PASSED: 40`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-m3-active-detail-composer-slice/timeout-unittest.log`
- verification-side support logs:
  - case existence: `artifacts/verification_contracts/20260418-phase07-telegram-m3-active-detail-composer-slice/case-existence.log`
  - git scope visibility: `artifacts/verification_contracts/20260418-phase07-telegram-m3-active-detail-composer-slice/git-scope-check.log`
  - pointer consistency: `artifacts/verification_contracts/20260418-phase07-telegram-m3-active-detail-composer-slice/pointer-consistency.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260418-phase07-telegram-m3-active-detail-composer-slice/`

## Outcome

- `M3` now becomes the current latest Telegram consume entry while the latest shared-harness checkpoint remains `P1-27`.
- `M2` remains a landed usable-thread checkpoint and `P1-43` remains a landed bounded route checkpoint, but `M3` is the current answer for the more usable same-package Telegram detail direction.
- The milestone remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not authorize shared-helper expansion, generic send expansion, per-peer draft persistence rollout, or broader repo-scope escalation wording.
