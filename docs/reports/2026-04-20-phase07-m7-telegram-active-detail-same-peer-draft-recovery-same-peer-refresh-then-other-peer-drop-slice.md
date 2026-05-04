# 2026-04-20 Phase07 M7 Telegram Active-Detail Same-Peer Draft Recovery Same-Peer Refresh Then Other-Peer Drop Slice

## Goal

Land `M7 Telegram Active-Detail Same-Peer Draft Recovery Same-Peer Refresh Then Other-Peer Drop Slice` inside `samples/telegram-ui-vertical-slice-001` by promoting one stricter mixed-refresh sibling edge on top of landed `M5` and `M6`: while `TelegramChatDetailPage` has already armed one short-lived same-peer recovery slot through `backFromDetail()` with an unsent draft, one list-route `refreshConversation(same peer, limit)` may still update only that refreshed same-peer summary and preserve the slot, but if one list-route `refreshConversation(other peer, limit)` happens before any reopen, that second refresh must invalidate and drop the old recovery candidate immediately, so neither reopening the original peer nor reopening the refreshed other peer may restore the old draft later. The shell must still keep draft hidden on list route, keep list-route composer API as a strict pure no-op, and avoid reopening shared harness work, generic send widening, per-peer draft persistence, broader mixed-refresh-family rollout, or broader UI redesign.

## Decision

- landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - `docs/reports/2026-04-20-phase07-m7-telegram-active-detail-same-peer-draft-recovery-same-peer-refresh-then-other-peer-drop-slice.md`
  - `docs/runtime_contract.v2.md`
  - `docs/status/current_committed_plan.md`
  - `docs/current_state.v2.md`
  - `docs/status/INDEX.md`
  - `docs/status/current_task_handoff.md`
  - `docs/agent_system/execution_routing.md`
  - `AGENTS.md`
- milestone scope:
  - armed same-peer recovery slot survives exactly one list-route same-peer refresh before any reopen:
    - regression lock: `appShellRecoverySlotShouldSurviveSamePeerRefreshThenDropAfterOtherPeerRefreshBeforeReopen`
  - once that preserved slot later meets one list-route other-peer refresh, any later reopen must not ghost-restore the old draft:
    - regression lock: `appShellDroppedRecoveryAfterMixedRefreshShouldNotRestoreOnAnyLaterReopen`
  - while that mixed-refresh chain is still on list route, draft remains hidden and list-route composer API stays a pure no-op:
    - regression lock: `appShellMixedRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndListComposerNoop`
- boundary distinction:
  - `M5` remains the landed same-package Telegram milestone that froze the sibling edge where one list-route same-peer refresh may preserve an armed recovery slot until the first same-peer reopen.
  - `M6` remains the landed same-package Telegram milestone that froze the sibling edge where one list-route other-peer refresh directly drops that armed slot before any reopen.
  - `M7` is the next same-package Telegram UI milestone: it composes exactly one `M5`-style same-peer preserve step followed by exactly one `M6`-style other-peer drop step, and nothing wider.
- implementation note:
  - current verification surface shows existing `M5/M6` production behavior already satisfies `M7`, so this landed round does not widen `telegram_ui_slice.cj` or `telegram_app_shell.cj`
  - this round still does not touch `samples/phase07-shared-service-refresh-harness/**`, `samples/real-message-service-cache-001/**`, `P23`, shared helper/API, generic send abstraction, or broader UI redesign

## Production Changes

- `telegram_ui_vertical_slice_test.cj`
  - added the three `M7` regression locks covering same-peer preserve then other-peer drop, later-reopen no-restore, and list-route no-op stability under the mixed-refresh chain
- no production widening:
  - `telegram_app_shell.cj` is unchanged because existing `refreshConversation(...)` already composes list-route refresh dispatch with recovery-slot invalidation on the later other-peer step
  - `telegram_ui_slice.cj` is unchanged because the existing single-slot recovery model plus `dropRecoverySlotOnOtherPeerRefresh(...)` already covers the `M7` drop boundary once the first same-peer refresh has preserved the slot
- truth/spec/report sync:
  - live truth surfaces, `runtime_contract`, `execution_routing`, and `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md` now all describe `M7` as landed and point `latest_report` / `raw_log_root` at `M7`

## Behavior Frozen By M7

- Backing out from active detail with an unsent draft may still arm only one short-lived same-peer recovery slot, and list route still exposes no draft surface.
- One list-route same-peer `refreshConversation(peer, limit)` may update only the refreshed same-peer summary while that slot is armed, and it must preserve the armed slot without restoring or exposing the draft.
- If one list-route other-peer `refreshConversation(peer, limit)` happens after that preserve step and before any reopen, it must invalidate and drop the old recovery candidate immediately.
- After that second-step invalidation, reopening the original peer or reopening the refreshed other peer must not restore the old draft on any later reopen.
- During the armed-slot list-route interval, `updateDetailDraft(...)` / `sendDetailDraft()` still remain strict pure no-ops: the shell stays on `TelegramSessionListPage`, history does not grow, summaries do not change except for the explicitly refreshed targets, and recovery state is not recreated, restored, consumed, leaked, or mutated through composer APIs.
- The milestone deliberately does not freeze reverse order, repeated refreshes, reopen inserted between refreshes, third-peer refresh, other-peer refresh followed by direct retarget, any broader mixed-refresh family, or any shared/per-peer draft persistence rollout.

## Why This Round Stops Here

- `M7` only upgrades same-package Telegram detail consumption to one narrower two-step mixed-refresh edge on top of landed `M5` and `M6`.
- Current `M5/M6` production behavior already satisfies that edge, so this landed round intentionally stops at regression locks, canonical proof, evidence, report, and live truth sync instead of widening production code.
- The milestone remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not authorize shared-helper expansion, generic send expansion, per-peer draft persistence rollout, broader mixed-refresh-family rollout, broader repo-scope escalation wording, or `P23` relaunch.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 52`, `PASSED: 52`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260420-phase07-telegram-m7-active-detail-same-peer-draft-recovery-same-peer-refresh-then-other-peer-drop-slice/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 52`, `PASSED: 52`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260420-phase07-telegram-m7-active-detail-same-peer-draft-recovery-same-peer-refresh-then-other-peer-drop-slice/timeout-unittest.log`
- verification-side support logs:
  - case existence: `artifacts/verification_contracts/20260420-phase07-telegram-m7-active-detail-same-peer-draft-recovery-same-peer-refresh-then-other-peer-drop-slice/case-existence.log`
  - git scope visibility: `artifacts/verification_contracts/20260420-phase07-telegram-m7-active-detail-same-peer-draft-recovery-same-peer-refresh-then-other-peer-drop-slice/git-scope-check.log`
  - pointer consistency: `artifacts/verification_contracts/20260420-phase07-telegram-m7-active-detail-same-peer-draft-recovery-same-peer-refresh-then-other-peer-drop-slice/pointer-consistency.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260420-phase07-telegram-m7-active-detail-same-peer-draft-recovery-same-peer-refresh-then-other-peer-drop-slice/`

## Outcome

- `M7` now becomes the current latest Telegram consume entry while the latest shared-harness checkpoint remains `P1-27`.
- `M6`、`M5`、`M4`、`M3`、`M2` 与 `P1-43` remain landed checkpoints, but `M7` is now the current answer for the strict same-peer-refresh-preserve then other-peer-refresh-drop continuation of same-package Telegram detail usability.
- The milestone remains exploratory-only within `Phase07 Telegram UI Incubation`; it does not authorize shared-helper expansion, generic send expansion, per-peer draft persistence rollout, broader mixed-refresh-family rollout, or broader repo-scope promotion wording.
