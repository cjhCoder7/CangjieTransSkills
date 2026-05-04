# 2026-04-21 Phase07 M11 Telegram Active-Detail Same-Peer Draft Recovery Third Same-Peer Refresh Before First-Reopen Preserve Slice

## Goal

Land `M11 Telegram Active-Detail Same-Peer Draft Recovery Third Same-Peer Refresh Before First-Reopen Preserve Slice` inside `samples/telegram-ui-vertical-slice-001` by freezing one narrower same-package sibling edge on top of landed `M10`: while `TelegramChatDetailPage` has already armed one short-lived same-peer recovery slot through `backFromDetail()` with an unsent draft, the exact two same-peer `refreshConversation(same peer, limit)` chain already frozen by `M10` may still preserve that slot, exactly one additional same-peer `refreshConversation(same peer, limit)` on the same recovery peer may still preserve that same slot again before the first reopen, and then the first reopen of that refreshed same peer must still restore and consume the draft exactly once. The shell must keep the draft hidden on list route, preserve summary coherence and bounded history on the existing same-package rail, and keep list-route composer APIs as strict pure no-op, without reopening arbitrary repeated-refresh family work, other-peer refresh, retarget tails, shared/helper expansion, generic send widening, per-peer draft persistence, `P23`, or repo-level promotion.

## Decision

- landing path:
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice.md`
  - `docs/runtime_contract.v2.md`
  - `docs/status/current_committed_plan.md`
  - `docs/current_state.v2.md`
  - `docs/status/INDEX.md`
  - `docs/status/current_task_handoff.md`
  - `docs/agent_system/execution_routing.md`
  - `AGENTS.md`
- milestone scope:
  - the third same-peer refresh must keep the recovery slot hidden and unmutated until the first reopen:
    - regression lock: `appShellRecoverySlotShouldStayHiddenAcrossThirdSamePeerRefreshBeforeFirstReopen`
  - after exactly three total same-peer refreshes before the first reopen, that first reopen must still restore and consume exactly once:
    - regression lock: `appShellThirdSamePeerRefreshBeforeFirstReopenShouldStillRestoreAndConsumeExactlyOnce`
  - while that exact three-refresh same-peer chain remains armed, summary state must stay bounded and list-route composer APIs must remain no-op:
    - regression lock: `appShellThirdSamePeerRefreshWhileRecoveryArmedShouldKeepSummaryBoundedAndListComposerNoop`
- boundary distinction:
  - `M10` remains the landed same-package Telegram milestone that froze exactly two same-peer refreshes before the first reopen.
  - `M9` remains the landed same-package Telegram milestone that froze `same-peer refresh -> first same-peer reopen restore/consume -> exactly one direct retarget(other peer) drop/no-leak/no-ghost-restore`.
  - `M11` is the next same-package Telegram UI milestone: it goes back before the first reopen and freezes exactly one additional same-peer refresh on top of `M10`, for a total of exactly three same-peer refreshes before the first reopen, and nothing wider.
- landing note:
  - current verification already proved existing same-package behavior satisfies `M11`, so this landed round does not widen `telegram_ui_slice.cj`, `telegram_app_shell.cj`, or `telegram_ui_vertical_slice_test.cj`
  - `M11 landed` directly reuses the already-closed proof-round report at `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
  - `M11 landed` directly reuses the already-closed proof-round evidence bundle at `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`
  - this landed truth sync does not rerun `cjpm test` or the runtime binary gate, and does not generate a second evidence bundle

## Production Changes

- no production or test behavior widening in this landed round:
  - `telegram_ui_slice.cj` is unchanged
  - `telegram_app_shell.cj` is unchanged
  - `telegram_ui_vertical_slice_test.cj` is unchanged in this landing pass; the three `M11` regressions were already present from the closed proof round
- spec / truth sync only:
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md` now describe `M11` as landed, while keeping the scope bound to the exact third same-peer refresh sibling edge
  - live truth surfaces now describe `M11` as the current latest landed Telegram consume entry
  - `latest_report` now points to this landed report
  - `raw_log_root` now points to the existing `M11` proof-round evidence bundle

## Behavior Frozen By M11

- Backing out from active detail with an unsent draft may still arm only one short-lived same-peer recovery slot, and list route still exposes no draft surface.
- The exact two same-peer `refreshConversation(peer, limit)` chain already frozen by `M10` may still update only the refreshed same-peer summary while that slot is armed, and it must continue to preserve the slot.
- Exactly one additional same-peer `refreshConversation(peer, limit)` on that same recovery peer may still update only the refreshed same-peer summary while continuing to preserve that same armed slot.
- During those three total same-peer refreshes before first reopen, the slot must stay hidden, single-slot, same-peer, and short-lived; it must not duplicate, mutate, restore, consume, or widen into persistence.
- The first reopen of that refreshed same peer after those three refreshes may still restore the draft, bind detail ownership back to the refreshed original peer, and must immediately consume the slot exactly once.
- During the whole chain, list-route `updateDetailDraft(...)` and `sendDetailDraft()` must stay strict pure no-op, `historySize()` must remain bounded, and no broader repeated-refresh, mixed-refresh, retarget, or reopen-tail family is authorized.

## Verification

- current landed evidence is directly reused from the already-closed proof round; this landing pass did not rerun any tests
- reused `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 64`, `PASSED: 64`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/cjpm-test.log`
- reused `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 64`, `PASSED: 64`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/timeout-unittest.log`
- supporting proof/report artifacts:
  - proof-round report: `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
  - case existence: `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/case-existence.log`
  - git scope visibility: `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/git-scope-check.log`
  - pointer consistency: `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/pointer-consistency.log`

## Runtime Artifact

- evidence bundle:
  - `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`
- no second bundle:
  - `M11 landed` reuses the bundle above as `raw_log_root`

## Outcome

- `M11` now becomes the current latest Telegram consume entry while the latest shared-harness checkpoint remains `P1-27`.
- `latest_report` now points at `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice.md`.
- `raw_log_root` now points at `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`.
- `M10`、`M9`、`M8`、`M7`、`M6`、`M5`、`M4`、`M3`、`M2` 与 `P1-43` remain landed checkpoints, while `M11` is now the current answer for the strict sibling edge `same-peer refresh -> same-peer refresh -> same-peer refresh -> first same-peer reopen restore/consume exactly once`.
- The milestone remains exploratory-only within `Phase07 Telegram UI Incubation`; it does not authorize arbitrary repeated-refresh family rollout, other-peer refresh, retarget family rollout, shared-helper expansion, generic send expansion, per-peer draft persistence rollout, `P23` relaunch, or broader repo-scope promotion wording.
