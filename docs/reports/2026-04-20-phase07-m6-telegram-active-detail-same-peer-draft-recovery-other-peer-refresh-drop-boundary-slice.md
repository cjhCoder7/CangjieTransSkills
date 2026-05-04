# 2026-04-20 Phase07 M6 Telegram Active-Detail Same-Peer Draft Recovery Other-Peer Refresh Drop Boundary Slice

## Goal

Land `M6 Telegram Active-Detail Same-Peer Draft Recovery Other-Peer Refresh Drop Boundary Slice` inside `samples/telegram-ui-vertical-slice-001` by promoting the already-landed `M5` same-peer refresh-before-reopen recovery surface into one narrower sibling invalidation edge: while `TelegramChatDetailPage` has already armed one short-lived same-peer recovery slot through `backFromDetail()` with an unsent draft, one list-route `refreshConversation(...)` targeting another visible peer may still update only that refreshed other-peer summary through the existing refresh rail, but it must invalidate and drop the old recovery candidate immediately, so neither reopening the original peer nor reopening the refreshed other peer may restore the old draft. The shell must still keep draft hidden on list route, keep list-route composer API as a strict pure no-op, and avoid reopening shared harness work, generic send widening, per-peer draft persistence, or broader refresh-family rollout.

## Decision

- landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - `docs/reports/2026-04-20-phase07-m6-telegram-active-detail-same-peer-draft-recovery-other-peer-refresh-drop-boundary-slice.md`
  - `docs/runtime_contract.v2.md`
  - `docs/status/current_committed_plan.md`
  - `docs/current_state.v2.md`
  - `docs/status/INDEX.md`
  - `docs/status/current_task_handoff.md`
  - `docs/agent_system/execution_routing.md`
  - `AGENTS.md`
- milestone scope:
  - armed same-peer recovery slot is dropped when one list-route refresh targets another visible peer before any reopen:
    - regression lock: `appShellRecoverySlotShouldDropAfterOtherPeerRefreshBeforeReopen`
  - once that other-peer refresh invalidation happens, reopening the original peer must not ghost-restore the old draft:
    - regression lock: `appShellDroppedRecoveryAfterOtherPeerRefreshShouldNotRestoreOnOriginalReopen`
  - while the armed slot is being invalidated on list route, draft remains hidden and list-route composer API stays a pure no-op:
    - regression lock: `appShellOtherPeerRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndListComposerNoop`
- boundary distinction:
  - `M5` remains the landed same-package Telegram milestone that froze the sibling edge where one list-route same-peer refresh may preserve an armed recovery slot until the first same-peer reopen.
  - `M6` is the next same-package Telegram UI milestone: it does not widen slot lifecycle into per-peer persistence or broader refresh family, but freezes one narrower sibling invalidation edge where one list-route other-peer refresh drops that already-armed slot before any reopen.
  - This round still does not touch `samples/phase07-shared-service-refresh-harness/**`, `samples/real-message-service-cache-001/**`, `P23`, shared helper/API, generic send abstraction, or broader UI redesign.

## Production Changes

- `telegram_ui_vertical_slice_test.cj`
  - added the three `M6` regression locks covering other-peer refresh invalidation, original-peer reopen no-restore, and list-route no-op stability while recovery is armed
- `telegram_app_shell.cj`
  - `TelegramAppShell.refreshConversation(...)` now notifies detail-page recovery state before dispatching the existing list-route refresh rail
- `telegram_ui_slice.cj`
  - added `TelegramChatDetailPage.dropRecoverySlotOnOtherPeerRefresh(peerId)` and limited it to one bounded condition: when the shell is on list route with an armed recovery slot and the refresh target is not the recovery peer, clear the slot
- no widening:
  - same-peer refresh behavior from `M5` stays intact
  - detail-active draft editing semantics stay intact
  - list-route composer API remains a pure no-op
  - no shared helper, cache sample, generic send, per-peer persistence, or broader refresh permutation work was added

## Behavior Frozen By M6

- Backing out from active detail with an unsent draft may still arm only one short-lived same-peer recovery slot, and list route still exposes no draft surface.
- One list-route other-peer `refreshConversation(peer, limit)` may update only the refreshed other-peer summary while that slot is armed, but it must invalidate and drop the old recovery candidate immediately.
- After that invalidation, reopening the original peer or reopening the refreshed other peer must not restore the old draft.
- During the armed-slot list-route interval, `updateDetailDraft(...)` / `sendDetailDraft()` still remain strict pure no-ops: the shell stays on `TelegramSessionListPage`, history does not grow, summaries do not change except for the refreshed target, and recovery state is not recreated, restored, consumed, leaked, or mutated through composer APIs.
- The milestone deliberately does not freeze multiple refresh chains, same-peer/other-peer mixed refresh sequences, other-peer refresh followed by direct retarget, any broader refresh family, or any shared/per-peer draft persistence rollout.

## Why This Round Stops Here

- `M6` only upgrades same-package Telegram detail consumption to one narrower other-peer refresh invalidation edge on top of `M5`.
- It does not widen into per-peer draft persistence, broader composer redesign, broader refresh family rollout, shared continuation, shared helper rollout, generic send expansion, Harmony live / promoted wording, or any non-repo-local claim.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 49`, `PASSED: 49`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260420-phase07-telegram-m6-active-detail-same-peer-draft-recovery-other-peer-refresh-drop-boundary-slice/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 49`, `PASSED: 49`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260420-phase07-telegram-m6-active-detail-same-peer-draft-recovery-other-peer-refresh-drop-boundary-slice/timeout-unittest.log`
- verification-side support logs:
  - case existence: `artifacts/verification_contracts/20260420-phase07-telegram-m6-active-detail-same-peer-draft-recovery-other-peer-refresh-drop-boundary-slice/case-existence.log`
  - git scope visibility: `artifacts/verification_contracts/20260420-phase07-telegram-m6-active-detail-same-peer-draft-recovery-other-peer-refresh-drop-boundary-slice/git-scope-check.log`
  - pointer consistency: `artifacts/verification_contracts/20260420-phase07-telegram-m6-active-detail-same-peer-draft-recovery-other-peer-refresh-drop-boundary-slice/pointer-consistency.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260420-phase07-telegram-m6-active-detail-same-peer-draft-recovery-other-peer-refresh-drop-boundary-slice/`

## Outcome

- `M6` now becomes the current latest Telegram consume entry while the latest shared-harness checkpoint remains `P1-27`.
- `M5` remains a landed same-peer refresh-survive checkpoint, and `M4` / `M3` / `M2` / `P1-43` remain landed bounded checkpoints, but `M6` is now the current answer for the narrower list-route other-peer refresh invalidation continuation of same-package Telegram detail usability.
- The milestone remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not authorize shared-helper expansion, generic send expansion, per-peer draft persistence rollout, broader refresh family rollout, or broader repo-scope escalation wording.
