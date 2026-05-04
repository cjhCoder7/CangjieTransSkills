# 2026-04-20 Phase07 M5 Telegram Active-Detail Same-Peer Draft Recovery Refresh-Before-Reopen Coherence Slice

## Goal

Land `M5 Telegram Active-Detail Same-Peer Draft Recovery Refresh-Before-Reopen Coherence Slice` inside `samples/telegram-ui-vertical-slice-001` by promoting the already-landed `M4` single-slot same-peer draft recovery surface into one narrower refresh-before-reopen sibling edge: while a visible conversation is active in `TelegramChatDetailPage`, the shell may arm one short-lived recovery slot only when the user backs out with an unsent draft, keep that slot intact across one list-route same-peer `refreshConversation(...)`, restore that draft only on the first reopen of the same refreshed visible conversation, consume the slot immediately after that restore, keep `sendDetailDraft()` clearing draft and slot after recovery, and preserve list-route composer API as a strict pure no-op without reopening shared harness work, widening generic send, or turning the feature into per-peer draft persistence.

## Decision

- landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - `docs/reports/2026-04-15-phase07-app-shell-consume-boundary.md`
  - `docs/reports/2026-04-20-phase07-m5-telegram-active-detail-same-peer-draft-recovery-refresh-before-reopen-coherence-slice.md`
  - `docs/runtime_contract.v2.md`
  - `docs/status/current_committed_plan.md`
  - `docs/current_state.v2.md`
  - `docs/status/INDEX.md`
  - `docs/status/current_task_handoff.md`
  - `docs/agent_system/execution_routing.md`
  - `AGENTS.md`
- milestone scope:
  - armed same-peer recovery slot survives one list-route same-peer refresh and still restores on the first same-peer reopen:
    - regression lock: `appShellDraftRecoverySlotShouldSurviveSamePeerRefreshBeforeReopen`
  - recovered draft after same-peer refresh still uses the existing same-package send path and clears after send:
    - regression lock: `appShellRecoveredDraftAfterSamePeerRefreshShouldStillClearAfterSend`
  - armed slot stays hidden and bounded during list-route same-peer refresh while composer API remains pure no-op:
    - regression lock: `appShellListRouteSamePeerRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndBounded`
- boundary distinction:
  - `M4` remains the landed same-package Telegram draft recovery milestone that introduced the single-slot same-peer back/reopen restore edge.
  - `M5` is the next same-package Telegram UI milestone: it does not widen slot lifecycle into per-peer persistence or broader refresh family, but freezes one narrower sibling edge where that already-armed slot may survive exactly one list-route same-peer refresh before the first same-peer reopen.
  - This round still does not touch `samples/phase07-shared-service-refresh-harness/**`, `samples/real-message-service-cache-001/**`, `P23`, shared helper/API, generic send abstraction, or broader UI redesign.

## Production Changes

- No additional production widening was required in `telegram_ui_slice.cj` or `telegram_app_shell.cj`.
- The existing `M4` same-package implementation already satisfied the narrower `M5` edge:
  - `tapBack()` still arms the slot only from active detail with an unsent draft.
  - list-route same-peer `refreshConversation(...)` still runs entirely through the existing refresh rail and does not touch recovery-slot state.
  - the first reopen of the same refreshed visible conversation still restores the draft and immediately consumes the slot.
  - `sendDetailDraft()` after recovery still clears both draft and slot.
  - list-route composer API still remains a strict pure no-op with no recovery-slot side effects.
- This round therefore lands `M5` by adding the three regression locks, running canonical verification, publishing a landed report, and syncing repo-level pointers to the narrower latest Telegram consume entry.

## Behavior Frozen By M5

- Backing out from active detail with an unsent draft may still arm only one short-lived same-peer recovery slot, and list route still exposes no draft surface.
- One list-route same-peer `refreshConversation(peer, limit)` may update the refreshed summary while that slot is armed, but it must not create, restore, consume, clear, or mutate the recovery slot.
- The first reopen of that same refreshed visible conversation still restores the draft and immediately consumes the slot, so a second same-peer reopen without a new edit cannot ghost-restore the old draft.
- After refreshed recovery, `sendDetailDraft()` still appends the draft text into the projected thread immediately, keeps the target summary synchronized with sent text and `messageCount`, and clears both draft and slot.
- During the armed-slot list-route interval, `updateDetailDraft(...)` / `sendDetailDraft()` still remain strict pure no-ops: the shell stays on `TelegramSessionListPage`, history does not grow, summaries do not change, and recovery-slot state is not created, restored, consumed, leaked, or cleared.
- The milestone deliberately does not freeze armed-slot other-peer refresh, direct retarget after refreshed same-peer recovery, any broader refresh permutation, or any shared/per-peer draft persistence rollout.

## Why This Round Stops Here

- `M5` only upgrades same-package Telegram detail consumption to one narrower refresh-before-reopen sibling edge on top of `M4`.
- It does not widen into per-peer draft persistence, broader composer redesign, broader refresh family rollout, shared continuation, shared helper rollout, generic send expansion, Harmony live / promoted wording, or any non-repo-local claim.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 46`, `PASSED: 46`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260420-phase07-telegram-m5-active-detail-same-peer-draft-recovery-refresh-before-reopen-coherence-slice/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 46`, `PASSED: 46`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260420-phase07-telegram-m5-active-detail-same-peer-draft-recovery-refresh-before-reopen-coherence-slice/timeout-unittest.log`
- verification-side support logs:
  - case existence: `artifacts/verification_contracts/20260420-phase07-telegram-m5-active-detail-same-peer-draft-recovery-refresh-before-reopen-coherence-slice/case-existence.log`
  - git scope visibility: `artifacts/verification_contracts/20260420-phase07-telegram-m5-active-detail-same-peer-draft-recovery-refresh-before-reopen-coherence-slice/git-scope-check.log`
  - pointer consistency: `artifacts/verification_contracts/20260420-phase07-telegram-m5-active-detail-same-peer-draft-recovery-refresh-before-reopen-coherence-slice/pointer-consistency.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260420-phase07-telegram-m5-active-detail-same-peer-draft-recovery-refresh-before-reopen-coherence-slice/`

## Outcome

- `M5` now becomes the current latest Telegram consume entry while the latest shared-harness checkpoint remains `P1-27`.
- `M4` remains a landed same-peer draft recovery checkpoint and `M3` / `M2` / `P1-43` remain landed bounded checkpoints, but `M5` is the current answer for the narrower refresh-before-reopen continuation of same-package Telegram detail usability.
- The milestone remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not authorize shared-helper expansion, generic send expansion, per-peer draft persistence rollout, broader refresh family rollout, or broader repo-scope escalation wording.
