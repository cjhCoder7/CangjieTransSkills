# 2026-04-21 Phase07 M11 Telegram Active-Detail Same-Peer Draft Recovery Third Same-Peer Refresh Before First-Reopen Preserve Slice Proof Round

## Status

- proof closed；本文件只承载 `M11` 的 non-landed proof-round 结果，不切 landed truth。
- current approved step 仍是 `phase07_m11_telegram_active_detail_same_peer_draft_recovery_third_same_peer_refresh_before_first_reopen_preserve_slice_proof_round`。
- current canonical landed consume entry / `latest_report` / `raw_log_root` 仍维持在 `M10`。
- `Phase07` 仍保持 `exploratory-only`，latest shared checkpoint 仍为 `P1-27`。

## Goal

闭合一个严格受限于 Telegram same-package refresh/draft direction 的 sibling edge：在 `M10` 已冻结的 exact two-refresh same-peer preserve rail 上，再追加 exactly one same-peer refresh，使总链路收口为 `same-peer refresh -> same-peer refresh -> same-peer refresh -> first reopen restore and consume exactly once`。本轮只证明这条 exact third same-peer refresh preserve chain，不把 `M11` 外推成 arbitrary repeated-refresh family、other-peer refresh、repeated other-peer refresh、third-peer refresh、direct retarget、second direct retarget、additional reopen-in-between、broader back/reopen tail、broader mixed-refresh family、shared/helper、generic send、per-peer persistence、`P23`，或 repo-level promotion。

## Decision

- proof path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - `AGENTS.md`
  - `docs/status/current_committed_plan.md`
  - `docs/current_state.v2.md`
  - `docs/status/INDEX.md`
  - `docs/status/current_task_handoff.md`
  - `docs/runtime_contract.v2.md`
  - `docs/agent_system/execution_routing.md`
  - `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
- proof boundary:
  - on top of `M10`'s exact two-refresh same-peer preserve chain, add exactly one same-peer refresh on the same recovery peer before the first reopen
  - the first reopen of that refreshed same peer still restores and consumes the draft exactly once
  - list-route composer APIs remain strict pure no-op while recovery stays armed
- non-landed result:
  - existing same-package production already satisfies this edge, so `M11` closes as regression/spec/state/report/evidence-only proof round
  - this round does not widen `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
  - this round does not widen `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - this round does not move `latest_report` / `raw_log_root` off `M10`

## Production Changes

- `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - added the three `M11` regression locks:
    - `appShellRecoverySlotShouldStayHiddenAcrossThirdSamePeerRefreshBeforeFirstReopen`
    - `appShellThirdSamePeerRefreshBeforeFirstReopenShouldStillRestoreAndConsumeExactlyOnce`
    - `appShellThirdSamePeerRefreshWhileRecoveryArmedShouldKeepSummaryBoundedAndListComposerNoop`
- `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - updated `M11` authority wording from frozen posture to proof-closed, non-landed posture
- live truth surfaces
  - updated plan/state/routing/handoff surfaces to `M11 proof round / proof closed / landed truth pending`
- no production widening
  - the new `M11` regressions passed immediately, so proof closed without touching app-shell or slice production files

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - under explicit repo-local toolchain injection
  - exit `0`
  - `TOTAL: 64`, `PASSED: 64`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - under the same explicit repo-local toolchain injection
  - exit `0`
  - `TOTAL: 64`, `PASSED: 64`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/timeout-unittest.log`
- support logs:
  - case existence: `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/case-existence.log`
  - git scope visibility: `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/git-scope-check.log`
  - pointer consistency: `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/pointer-consistency.log`

## Outcome

- `M11` 现在是当前 approved proof-round Telegram continuation slice，且其最小 same-package proof 已闭合。
- `M10` 仍是当前 latest landed Telegram consume entry；`latest_report` / `raw_log_root` 仍继续指向 `M10`。
- `M11` proof closed 不授权 landed truth 自动切换，也不授权更宽 refresh family、retarget family、shared/helper、generic send、per-peer persistence、`P23`，或 repo-level promotion。
