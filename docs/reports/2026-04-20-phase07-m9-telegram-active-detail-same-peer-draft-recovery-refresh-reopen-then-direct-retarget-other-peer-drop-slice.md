# 2026-04-20 Phase07 M9 Telegram Active-Detail Same-Peer Draft Recovery Refresh-Reopen Then Direct-Retarget Other-Peer Drop Slice

## Goal

Land `M9 Telegram Active-Detail Same-Peer Draft Recovery Refresh-Reopen Then Direct-Retarget Other-Peer Drop Slice` inside `samples/telegram-ui-vertical-slice-001` by freezing one narrower post-recovery sibling edge on top of landed `M5`, `P1-12`, and `P1-16`: while `TelegramChatDetailPage` has already armed one short-lived same-peer recovery slot through `backFromDetail()` with an unsent draft, one list-route `refreshConversation(same peer, limit)` may still preserve that slot, the first reopen of that refreshed same peer may still restore and consume the draft, and then exactly one direct retarget to one other visible peer must drop the recovered draft immediately. That recovered draft must not leak into the new target, and any later reopen of the original peer must stay no-ghost-restore. The shell must keep ownership, summary coherence, bounded history, and list/detail route semantics on the existing same-package rail, without reopening generic retarget family work, shared/helper expansion, generic send widening, per-peer draft persistence, broader mixed-refresh family rollout, `P23`, or repo-level promotion.

## Decision

- landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - `docs/reports/2026-04-20-phase07-m9-telegram-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice.md`
  - `docs/runtime_contract.v2.md`
  - `docs/status/current_committed_plan.md`
  - `docs/current_state.v2.md`
  - `docs/status/INDEX.md`
  - `docs/status/current_task_handoff.md`
  - `docs/agent_system/execution_routing.md`
  - `AGENTS.md`
- milestone scope:
  - refreshed same-peer recovery draft is restored on the first same-peer reopen and then must drop on one direct retarget to one other visible peer:
    - regression lock: `appShellRecoveredDraftAfterSamePeerRefreshReopenShouldDropOnDirectRetargetToOtherPeer`
  - once that direct retarget has happened, any later reopen of the original peer must stay no-ghost-restore:
    - regression lock: `appShellDirectRetargetAfterRecoveredDraftShouldNotGhostRestoreOnLaterOriginalPeerReopen`
  - the whole refresh-reopen-retarget chain must keep other-peer ownership, summary coherence, and bounded history stable:
    - regression lock: `appShellRefreshReopenRetargetAfterRecoveryShouldKeepOtherPeerOwnershipAndBoundedHistory`
- boundary distinction:
  - `M5` remains the landed same-package Telegram milestone that froze `same-peer refresh -> first same-peer reopen restore/consume`.
  - `M8` remains the landed same-package Telegram milestone that froze the pre-reopen reverse-order `other-peer refresh -> same-peer refresh` no-resurrect sibling edge.
  - `M9` is the next same-package Telegram UI milestone: it consumes the `M5` restore/consume edge and then freezes exactly one post-recovery direct retarget-other-peer drop/no-leak/no-ghost-restore edge, and nothing wider.
- implementation note:
  - current verification shows existing same-package `M4/M5/P1-12/P1-16` production behavior already satisfies `M9`, so this landed round does not widen `telegram_ui_slice.cj` or `telegram_app_shell.cj`
  - repo `git status --short` still reflects a broad untracked worktree, so scope evidence continues to rely on targeted evidence logs rather than a clean tracked diff baseline
  - this round still does not touch `samples/phase07-shared-service-refresh-harness/**`, `samples/real-message-service-cache-001/**`, `P23`, shared helper/API, generic send abstraction, generic retarget family, per-peer draft persistence, broader mixed-refresh family, broader back/reopen tail family, or broader UI redesign

## Production Changes

- `telegram_ui_vertical_slice_test.cj`
  - added the three `M9` regression locks covering refreshed-recovery direct-retarget drop/no-leak, later-original-reopen no-ghost-restore, and post-recovery refresh-reopen-retarget bounded ownership/history stability
- `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - added `M9` landed-ready requirements, design boundary, task entry, expected regression names, and expected `58`-case total if only the three new regressions were added
- no production widening:
  - `telegram_app_shell.cj` is unchanged because the existing detail-route retarget path already clears recovered draft state when active detail switches to another peer
  - `telegram_ui_slice.cj` is unchanged because the existing single-slot recovery model plus first-reopen consume semantics already leave no reusable recovery candidate after the restored draft is retarget-dropped
- truth/report sync:
  - live truth surfaces, `runtime_contract`, and `execution_routing` now describe `M9` as landed and point `latest_report` / `raw_log_root` at `M9`

## Behavior Frozen By M9

- Backing out from active detail with an unsent draft may still arm only one short-lived same-peer recovery slot, and list route still exposes no draft surface.
- One list-route same-peer `refreshConversation(peer, limit)` may still update only the refreshed same-peer summary while that slot is armed, and it must continue to preserve the slot for the first same-peer reopen.
- The first reopen of that refreshed same peer may still restore the draft, bind detail ownership to the refreshed original peer, and must immediately consume the slot.
- Exactly one direct retarget to one other visible peer after that restore/consume must drop the recovered draft immediately: the draft must not leak into the new target's `currentDraft`, send state, or summary surface.
- After that direct retarget, reopening the original peer later must not ghost-restore the old recovered draft.
- During the whole chain, `currentPageName()` must stay on `TelegramChatDetailPage` after the retarget, `historySize()` must remain `2`, the original refreshed summary must stay on the list surface, the other visible summary must stay stable, and no extra service-history pull may be introduced.
- The milestone deliberately does not freeze repeated refresh, third-peer refresh, extra reopen-in-between permutations, second direct retarget, broader back/reopen tails, generic retarget family rollout, shared continuation, per-peer draft persistence, or any broader repo-status promotion wording.

## Why This Round Stops Here

- `M9` only upgrades same-package Telegram detail consumption to one narrower post-recovery retarget sibling edge on top of landed `M5`, `P1-12`, and `P1-16`.
- Current same-package production behavior already satisfies that edge, so this landed round intentionally stops at regression locks, canonical proof, evidence, report, and live truth sync instead of widening production code.
- The milestone remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not authorize shared-helper expansion, generic send expansion, generic retarget family rollout, per-peer draft persistence rollout, broader mixed-refresh-family rollout, broader back/reopen-tail rollout, `P23` relaunch, or broader repo-scope promotion wording.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - under explicit repo-local toolchain injection per `docs/runtime_contract.v2.md`
  - exit `0`
  - `TOTAL: 58`, `PASSED: 58`, `FAILED: 0`
  - delta explanation: previous `M8` total was `55`; `M9` added exactly the three planned regressions and nothing else
  - log: `artifacts/verification_contracts/20260420-phase07-telegram-m9-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - under the same explicit repo-local toolchain injection
  - exit `0`
  - `TOTAL: 58`, `PASSED: 58`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260420-phase07-telegram-m9-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice/timeout-unittest.log`
- verification-side support logs:
  - case existence: `artifacts/verification_contracts/20260420-phase07-telegram-m9-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice/case-existence.log`
  - git scope visibility: `artifacts/verification_contracts/20260420-phase07-telegram-m9-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice/git-scope-check.log`
  - pointer consistency: `artifacts/verification_contracts/20260420-phase07-telegram-m9-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice/pointer-consistency.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260420-phase07-telegram-m9-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice/`

## Outcome

- `M9` now becomes the current latest Telegram consume entry while the latest shared-harness checkpoint remains `P1-27`.
- `M8`、`M7`、`M6`、`M5`、`M4`、`M3`、`M2` 与 `P1-43` remain landed checkpoints, but `M9` is now the current answer for the strict post-recovery sibling edge `same-peer refresh -> first same-peer reopen restore/consume -> direct retarget(other peer) drops old recovered draft -> later original reopen stays no-ghost-restore`.
- The milestone remains exploratory-only within `Phase07 Telegram UI Incubation`; it does not authorize shared-helper expansion, generic send expansion, generic retarget family rollout, per-peer draft persistence rollout, broader mixed-refresh-family rollout, broader back/reopen-tail rollout, or broader repo-scope promotion wording.
