# 2026-04-21 Phase07 M10 Telegram Active-Detail Same-Peer Draft Recovery Repeated Same-Peer Refresh Before First-Reopen Preserve Slice Proof Round

## Status

- proof closed；本文件只承载 `M10` 的 non-landed proof-round 结果，不切 landed truth。
- current approved step 仍是 `phase07_m10_telegram_active_detail_same_peer_draft_recovery_repeated_same_peer_refresh_before_first_reopen_preserve_slice_proof_round`。
- current canonical landed consume entry / `latest_report` / `raw_log_root` 仍维持在 `M9`。
- `Phase07` 仍保持 `exploratory-only`，latest shared checkpoint 仍为 `P1-27`。

## Goal

闭合一个严格受限于 Telegram same-package refresh/draft direction 的 sibling edge：在 `M5` 已冻结的 one-hop `same-peer refresh -> first same-peer reopen restore/consume` preserve rail 上，再追加 exactly one additional same-peer refresh，使总链路收口为 `same-peer refresh -> same-peer refresh -> first reopen restore and consume exactly once`。本轮只证明这条 exact two-refresh same-peer preserve chain，不把 `M10` 外推成 other-peer refresh、repeated other-peer refresh、third-peer refresh、direct retarget、second direct retarget、additional reopen-in-between、broader back/reopen tail、broader mixed-refresh family、shared/helper、generic send、per-peer persistence、`P23`，或 repo-level promotion。

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
  - `docs/reports/2026-04-21-phase07-m10-telegram-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
- proof boundary:
  - exactly one first list-route same-peer refresh while recovery slot stays armed
  - exactly one additional same-peer refresh on the same recovery peer before the first reopen
  - the first reopen of that refreshed same peer still restores and consumes the draft exactly once
  - list-route composer APIs remain strict pure no-op while recovery stays armed
- non-landed result:
  - existing same-package production already satisfies this edge, so `M10` closes as regression/spec/state/report/evidence-only proof round
  - this round does not widen `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
  - this round does not widen `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - this round does not move `latest_report` / `raw_log_root` off `M9`

## Production Changes

- `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - added the three `M10` regression locks:
    - `appShellRecoverySlotShouldStayHiddenAcrossRepeatedSamePeerRefreshes`
    - `appShellRepeatedSamePeerRefreshBeforeFirstReopenShouldStillRestoreAndConsumeExactlyOnce`
    - `appShellRepeatedSamePeerRefreshWhileRecoveryArmedShouldKeepSummaryBoundedAndListComposerNoop`
- `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - updated `M10` authority wording from proof-gate-open posture to proof-closed, non-landed posture
- live truth surfaces
  - updated plan/state/routing/handoff surfaces to `M10 proof round / proof closed / landed truth pending`
- no production widening
  - the new `M10` regressions passed immediately, so proof closed without touching app-shell or slice production files

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - under explicit repo-local toolchain injection
  - exit `0`
  - `TOTAL: 61`, `PASSED: 61`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260421-phase07-telegram-m10-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - under the same explicit repo-local toolchain injection
  - exit `0`
  - `TOTAL: 61`, `PASSED: 61`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260421-phase07-telegram-m10-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/timeout-unittest.log`
- support logs:
  - case existence: `artifacts/verification_contracts/20260421-phase07-telegram-m10-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/case-existence.log`
  - git scope visibility: `artifacts/verification_contracts/20260421-phase07-telegram-m10-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/git-scope-check.log`
  - pointer consistency: `artifacts/verification_contracts/20260421-phase07-telegram-m10-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/pointer-consistency.log`

## Outcome

- `M10` 现在是当前 approved proof-round Telegram continuation slice，且其最小 same-package proof 已闭合。
- `M9` 仍是当前 latest landed Telegram consume entry；`latest_report` / `raw_log_root` 仍继续指向 `M9`。
- `M10` proof closed 不授权 landed truth 自动切换，也不授权更宽 refresh family、retarget family、shared/helper、generic send、per-peer persistence、`P23`，或 repo-level promotion。
