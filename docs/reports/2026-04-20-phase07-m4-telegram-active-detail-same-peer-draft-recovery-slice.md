# 2026-04-20 Phase07 M4 Telegram Active-Detail Same-Peer Draft Recovery Slice

## Goal

Land `M4 Telegram Active-Detail Same-Peer Draft Recovery Slice` inside `samples/telegram-ui-vertical-slice-001` by promoting the already-landed active-detail composer surface into a bounded same-peer draft recovery slice: while a visible conversation is active in `TelegramChatDetailPage`, the shell may arm one short-lived recovery slot only when the user backs out with an unsent draft, restore that draft only on the first same-peer reopen, consume the slot immediately after that restore, keep `sendDetailDraft()` / other-peer transitions clearing draft and slot, and preserve list-route composer API as a strict pure no-op without reopening shared harness work or widening the generic send surface.

## Decision

- landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - `docs/reports/2026-04-15-phase07-app-shell-consume-boundary.md`
  - `docs/reports/2026-04-20-phase07-m4-telegram-active-detail-same-peer-draft-recovery-slice.md`
  - `docs/runtime_contract.v2.md`
  - `docs/status/current_committed_plan.md`
  - `docs/current_state.v2.md`
  - `docs/status/INDEX.md`
  - `docs/status/current_task_handoff.md`
  - `docs/agent_system/execution_routing.md`
  - `AGENTS.md`
- milestone scope:
  - same-peer back/reopen restores the unsent draft exactly once:
    - regression lock: `appShellDetailDraftShouldRecoverAfterBackAndReopenSameConversation`
  - recovered draft still uses the existing same-package send path and clears after send:
    - regression lock: `appShellRecoveredDetailDraftShouldStillClearAfterSend`
  - other-peer reopen / direct retarget still clear draft+slot while list-route composer API stays pure no-op:
    - regression lock: `appShellRecoveredDetailDraftShouldDropOnOtherPeerAndListRouteNoop`
- boundary distinction:
  - `M3` remains the landed active-detail composer milestone that introduced local draft update/send semantics.
  - `M4` is the next same-package Telegram UI milestone: it does not widen draft into per-peer persistence, but it freezes one narrower sibling edge where a back-to-list transition may preserve an unsent draft for the first same-peer reopen only.
  - This round still does not touch `samples/phase07-shared-service-refresh-harness/**`, `samples/real-message-service-cache-001/**`, `P23`, shared helper/API, generic send abstraction, or broader UI redesign.

## Production Changes

- `TelegramChatDetailPage` now keeps a single same-peer recovery slot in addition to the existing active-detail local draft.
- `tapBack()` now arms that slot only when the current detail peer owns a non-empty draft that was explicitly edited during the current active-detail session, then clears active detail state immediately after the route returns to list.
- `aboutToAppear()` now restores the slot only on the first same-peer reopen, consumes it immediately after that restore, clears it on other-peer reopen or direct retarget, and keeps list-route reads from mutating slot state.
- `sendDraft(...)` now clears both the active draft and any leftover recovery slot after a successful send.

## Behavior Frozen By M4

- Opening a visible conversation into detail still projects the correct current thread, and the active detail still starts with an empty composer draft unless the first same-peer reopen is consuming a previously armed recovery slot.
- Backing out from an active detail with an unsent draft may arm one short-lived recovery slot for that same peer only; the list route itself still exposes no draft.
- Reopening the same visible conversation once restores that draft and immediately consumes the slot, so a second same-peer reopen without a new edit cannot ghost-restore the old draft.
- `sendDetailDraft()` after a restored draft still appends the draft text into the projected thread immediately, keeps the target list summary synchronized with sent text and `messageCount`, and clears both draft and slot.
- Reopening another visible conversation from list or direct-retargeting to another visible conversation from detail still drops the old draft / slot.
- When no conversation is active, list-route `updateDetailDraft(...)` / `sendDetailDraft()` remains a strict pure no-op: the shell stays on `TelegramSessionListPage`, history does not grow, summaries do not change, and recovery-slot state is not created, restored, consumed, leaked, or cleared.

## Why This Round Stops Here

- `M4` only upgrades same-package Telegram detail consumption to one bounded same-peer draft recovery edge.
- It does not widen into per-peer draft persistence, broader composer redesign, shared continuation, shared helper rollout, generic send expansion, Harmony live / promoted wording, or any non-repo-local claim.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 43`, `PASSED: 43`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260420-phase07-telegram-m4-active-detail-same-peer-draft-recovery-slice/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 43`, `PASSED: 43`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260420-phase07-telegram-m4-active-detail-same-peer-draft-recovery-slice/timeout-unittest.log`
- verification-side support logs:
  - case existence: `artifacts/verification_contracts/20260420-phase07-telegram-m4-active-detail-same-peer-draft-recovery-slice/case-existence.log`
  - git scope visibility: `artifacts/verification_contracts/20260420-phase07-telegram-m4-active-detail-same-peer-draft-recovery-slice/git-scope-check.log`
  - pointer consistency: `artifacts/verification_contracts/20260420-phase07-telegram-m4-active-detail-same-peer-draft-recovery-slice/pointer-consistency.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260420-phase07-telegram-m4-active-detail-same-peer-draft-recovery-slice/`

## Outcome

- `M4` now becomes the current latest Telegram consume entry while the latest shared-harness checkpoint remains `P1-27`.
- `M3` remains a landed composer checkpoint and `M2` / `P1-43` remain landed bounded checkpoints, but `M4` is the current answer for the narrower same-peer recovery continuation of same-package Telegram detail usability.
- The milestone remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not authorize shared-helper expansion, generic send expansion, per-peer draft persistence rollout, or broader repo-scope escalation wording.
