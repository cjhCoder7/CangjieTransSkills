# 2026-04-20 Phase07 M8 Telegram Active-Detail Same-Peer Draft Recovery Other-Peer Refresh Then Same-Peer Refresh No-Restore Slice

## Goal

Land `M8 Telegram Active-Detail Same-Peer Draft Recovery Other-Peer Refresh Then Same-Peer Refresh No-Restore Slice` inside `samples/telegram-ui-vertical-slice-001` by promoting one stricter reverse-order mixed-refresh sibling edge on top of landed `M6` and `M7`: while `TelegramChatDetailPage` has already armed one short-lived same-peer recovery slot through `backFromDetail()` with an unsent draft, one list-route `refreshConversation(other peer, limit)` must still invalidate and drop that old recovery candidate immediately, and if one later list-route `refreshConversation(same recovery peer, limit)` happens before any reopen, that second refresh must update only the refreshed same-peer summary without rearming, rebuilding, restoring, or otherwise resurrecting the dropped draft. Any later reopen must still stay no-restore. The shell must keep draft hidden on list route, keep list-route composer API as a strict pure no-op, and avoid reopening shared harness work, generic send widening, per-peer draft persistence, broader reverse-order mixed-refresh family rollout, or broader UI redesign.

## Decision

- landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - `docs/reports/2026-04-20-phase07-m8-telegram-active-detail-same-peer-draft-recovery-other-peer-refresh-then-same-peer-refresh-no-restore-slice.md`
  - `docs/runtime_contract.v2.md`
  - `docs/status/current_committed_plan.md`
  - `docs/current_state.v2.md`
  - `docs/status/INDEX.md`
  - `docs/status/current_task_handoff.md`
  - `docs/agent_system/execution_routing.md`
  - `AGENTS.md`
- milestone scope:
  - one list-route other-peer refresh must drop the armed slot before one later same-peer refresh can rearm or restore anything:
    - regression lock: `appShellRecoverySlotShouldDropBeforeSamePeerRefreshCanRearmOrRestore`
  - once that reverse-order mixed-refresh chain has happened, no later reopen may ghost-restore the old draft:
    - regression lock: `appShellDroppedRecoveryAfterReverseOrderMixedRefreshShouldNotRestoreOnAnyLaterReopen`
  - while the slot is armed and then dropped on list route, draft remains hidden and list-route composer API stays a pure no-op even after the later same-peer refresh:
    - regression lock: `appShellReverseOrderMixedRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndListComposerNoop`
- boundary distinction:
  - `M6` remains the landed same-package Telegram milestone that froze the direct edge `back -> other-peer refresh -> drop before reopen`.
  - `M7` remains the landed same-package Telegram milestone that froze the forward-order mixed edge `back -> same-peer refresh preserves slot -> other-peer refresh drops slot -> later reopen no-restore`.
  - `M8` is the next same-package Telegram UI milestone: it composes exactly one `M6`-style drop step followed by exactly one later same-peer refresh no-resurrect step, and nothing wider.
- implementation note:
  - current verification shows existing `M5/M6/M7` production behavior already satisfies `M8`, so this landed round does not widen `telegram_ui_slice.cj` or `telegram_app_shell.cj`
  - repo `git status --short` still reflects a broad untracked worktree, so write-scope evidence continues to rely on the bounded evidence logs rather than a clean tracked diff baseline
  - this round still does not touch `samples/phase07-shared-service-refresh-harness/**`, `samples/real-message-service-cache-001/**`, `P23`, shared helper/API, generic send abstraction, per-peer draft persistence, broader reverse-order mixed-refresh family, or broader UI redesign

## Production Changes

- `telegram_ui_vertical_slice_test.cj`
  - added the three `M8` regression locks covering reverse-order drop-before-same-peer-refresh no-resurrect, later-reopen no-restore, and list-route no-op stability under the reverse-order mixed-refresh chain
- `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - added `M8` landed-ready requirements, design boundary, task entry, expected regression names, and expected `55`-case total if only the three new regressions were added
- no production widening:
  - `telegram_app_shell.cj` is unchanged because existing `refreshConversation(...)` already calls `dropRecoverySlotOnOtherPeerRefresh(...)` before list-route refresh dispatch, so a later same-peer refresh sees no remaining slot to restore
  - `telegram_ui_slice.cj` is unchanged because the existing single-slot recovery model plus `dropRecoverySlotOnOtherPeerRefresh(...)` already enforces the `M8` reverse-order no-resurrect boundary
- truth/report sync:
  - live truth surfaces, `runtime_contract`, and `execution_routing` now describe `M8` as landed and point `latest_report` / `raw_log_root` at `M8`

## Behavior Frozen By M8

- Backing out from active detail with an unsent draft may still arm only one short-lived same-peer recovery slot, and list route still exposes no draft surface.
- One list-route other-peer `refreshConversation(peer, limit)` may update only the refreshed other-peer summary while that slot is armed, and it must invalidate and drop the old recovery candidate immediately.
- If one later list-route same-peer `refreshConversation(peer, limit)` happens after that drop step and before any reopen, it may update the refreshed same-peer summary but must not recreate, restore, or otherwise resurrect the dropped draft.
- After that reverse-order two-hop chain, reopening the original peer, reopening the refreshed other peer, or any later reopen of those peers must not restore the old draft.
- During the armed-slot list-route interval and after the drop, `updateDetailDraft(...)` / `sendDetailDraft()` still remain strict pure no-ops on list route: the shell stays on `TelegramSessionListPage`, history does not grow, summaries do not change except for the explicitly refreshed targets, and recovery state is not recreated, restored, consumed, leaked, or mutated through composer APIs.
- The milestone deliberately does not freeze repeated refreshes, reopen inserted between refreshes, third-peer refresh, arbitrary mixed chains, shared continuation, per-peer draft persistence, or any broader refresh-family rollout.

## Why This Round Stops Here

- `M8` only upgrades same-package Telegram detail consumption to one narrower reverse-order two-step sibling edge on top of landed `M6` and `M7`.
- Current `M5/M6/M7` production behavior already satisfies that edge, so this landed round intentionally stops at regression locks, canonical proof, evidence, report, and live truth sync instead of widening production code.
- The milestone remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not authorize shared-helper expansion, generic send expansion, per-peer draft persistence rollout, broader reverse-order mixed-refresh-family rollout, broader repo-scope escalation wording, or `P23` relaunch.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - under explicit repo-local toolchain injection per `docs/runtime_contract.v2.md`
  - exit `0`
  - `TOTAL: 55`, `PASSED: 55`, `FAILED: 0`
  - delta explanation: previous `M7` total was `52`; `M8` added exactly the three planned regressions and nothing else
  - log: `artifacts/verification_contracts/20260420-phase07-telegram-m8-active-detail-same-peer-draft-recovery-other-peer-refresh-then-same-peer-refresh-no-restore-slice/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - under the same explicit repo-local toolchain injection
  - exit `0`
  - `TOTAL: 55`, `PASSED: 55`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260420-phase07-telegram-m8-active-detail-same-peer-draft-recovery-other-peer-refresh-then-same-peer-refresh-no-restore-slice/timeout-unittest.log`
- verification-side support logs:
  - case existence: `artifacts/verification_contracts/20260420-phase07-telegram-m8-active-detail-same-peer-draft-recovery-other-peer-refresh-then-same-peer-refresh-no-restore-slice/case-existence.log`
  - git scope visibility: `artifacts/verification_contracts/20260420-phase07-telegram-m8-active-detail-same-peer-draft-recovery-other-peer-refresh-then-same-peer-refresh-no-restore-slice/git-scope-check.log`
  - pointer consistency: `artifacts/verification_contracts/20260420-phase07-telegram-m8-active-detail-same-peer-draft-recovery-other-peer-refresh-then-same-peer-refresh-no-restore-slice/pointer-consistency.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260420-phase07-telegram-m8-active-detail-same-peer-draft-recovery-other-peer-refresh-then-same-peer-refresh-no-restore-slice/`

## Outcome

- `M8` now becomes the current latest Telegram consume entry while the latest shared-harness checkpoint remains `P1-27`.
- `M7`、`M6`、`M5`、`M4`、`M3`、`M2` 与 `P1-43` remain landed checkpoints, but `M8` is now the current answer for the strict reverse-order sibling edge `other-peer refresh drops slot -> same-peer refresh still no-resurrect -> later reopen stays no-restore`.
- The milestone remains exploratory-only within `Phase07 Telegram UI Incubation`; it does not authorize shared-helper expansion, generic send expansion, per-peer draft persistence rollout, broader reverse-order mixed-refresh-family rollout, or broader repo-scope promotion wording.
