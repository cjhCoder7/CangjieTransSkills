# Status Index

更新时间：`2026-04-21 03:26 UTC`

## 1. Resume Core

- 统一恢复顺序：`AGENTS.md -> docs/status/current_committed_plan.md -> docs/current_state.v2.md -> docs/status/INDEX.md -> docs/status/current_task_handoff.md`
- `docs/status/current_committed_plan.md`
  - 当前批准计划六字段：`approved_on`、`approved_by`、`current_step`、`why_this_step`、`do_not_do_now`、`exit_condition`
- `docs/current_state.v2.md`
  - 项目级当前快照、`active lane`、blocker、allowed moves、当前 checkpoint
- `docs/status/INDEX.md`
  - 导航当前默认 task surface、`latest_report`、`raw_log_root`、fallback search order
- `docs/status/current_task_handoff.md`
  - 当前 task 或 landed checkpoint 的状态面；不承载默认恢复顺序或 repo 级裁决
- `docs/agent_system/execution_routing.md`
  - 五步恢复之后再读；只负责模式读取面、authority/report routing、fallback 规则
- 若本文件或 `current_task_handoff` 在 `current_step`、`why_this_step`、`do_not_do_now`、`exit_condition` 上与 `current_committed_plan` 不一致，按 `current_committed_plan` 收口。
- 若本文件或 `current_task_handoff` 在 `active lane`、blocker、allowed moves、repo-status 边界上与 `docs/current_state.v2.md` 不一致，按 `current_state` 收口。

## 2. Pointer Surfaces

- `latest_report`：`docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice.md`
  - 当前 latest landed Telegram consume milestone 的说明面
- `raw_log_root`：`artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`
  - 当前 `M11 landed` 复用的原始验证证据根目录；这是 landed truth sync 对 proof-round evidence 的直接复用，不是二次 rerun
- `default_task_surface`：`docs/status/current_task_handoff.md`
  - 当前 `M11 landed` checkpoint 的持久状态面；当前 approved step 已切到 `M11 landed`
- `supporting_frozen_definition`：`docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-freeze-draft.md`
  - 当前 `M11` frozen definition 的前序说明面；供 proof-round authority 回溯使用
- `supporting_proof_report`：`docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
  - 当前 `M11 landed` 继续复用的 supporting proof-round 说明面
- `supporting_landed_proof_report`：`docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
  - 当前 landed truth sync 继续复用的 same-package supporting proof-round 说明面
- `authority_bundle`
  - `docs/runtime_contract.v2.md`
  - `docs/domain_review_rubric.v2.md`
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
- `archive/index`：`docs/reports/README.md`
  - 需要回跳长报告目录时再读
- `rolling_phase_log`：`.claude/status/current-phase.md`
  - 只在需要追老背景或长历史时读取；不是默认 resume 首跳

## 3. Path-Scoped Resume

- `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
- 仅在继续 `Phase07` 边界定义、验证已 landed `M11` 边界，或在 reviewer 放行后准备 `M11` 之后的下一 bounded continuation slice 时读取

## 4. Current Lane And Default Task Surface

- `active_lane`：`Phase07 Telegram UI Incubation`（`exploratory-only`）
- `committed_step`：`phase07_m11_telegram_active_detail_same_peer_draft_recovery_third_same_peer_refresh_before_first_reopen_preserve_slice_landed`
- `active_executing_task`：`phase07_m11_telegram_active_detail_same_peer_draft_recovery_third_same_peer_refresh_before_first_reopen_preserve_slice_landed; latest landed Telegram consume entry is M11; next bounded continuation slice pending reviewer approval`
- `default_task_surface`：`docs/status/current_task_handoff.md`
- `default_checkpoint`：`M11 Telegram Active-Detail Same-Peer Draft Recovery Third Same-Peer Refresh Before First-Reopen Preserve Slice landed`
- `checkpoint_task_id`：`phase07_m11_telegram_active_detail_same_peer_draft_recovery_third_same_peer_refresh_before_first_reopen_preserve_slice_landed`
- `checkpoint_status`：`landed`
- `latest_state`：`M11 已成为当前 latest landed Telegram consume entry；它只在 M10 的 exact two-refresh same-peer preserve chain 上，再追加 exactly one same-peer refresh，总计三次 same-peer refresh before first reopen。当前 latest shared-harness checkpoint 仍为 P1-27；latest_report 已切到 M11 landed report；raw_log_root 已切到 current M11 proof-round evidence bundle；next bounded continuation slice 仍待 reviewer 明确批准`

## 5. Status Utilities

- `docs/status/weekly_status_template.md`
  - 周报或阶段状态模板
