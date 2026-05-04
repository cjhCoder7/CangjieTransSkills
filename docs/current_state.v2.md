# Current State v2

更新时间：`2026-04-21 03:26 UTC`

## Current Approved Plan

- 当前批准计划：`docs/status/current_committed_plan.md`
- 当前步骤：`phase07_m11_telegram_active_detail_same_peer_draft_recovery_third_same_peer_refresh_before_first_reopen_preserve_slice_landed`
- 为什么是这一步：`M11 Telegram Active-Detail Same-Peer Draft Recovery Third Same-Peer Refresh Before First-Reopen Preserve Slice` 已在 `M10 landed` 之后完成 same-package proof，并被 reviewer 明确批准收口为当前 landed Telegram sibling slice；它只在 `M10` 已闭合的 exact two-refresh same-peer preserve chain 上，再追加 exactly one same-peer refresh，总计三次 same-peer refresh before first reopen。当前 landed truth sync 已闭合，并直接复用现有 `M11` proof report / proof-round evidence bundle；与此同时，`latest_report` 已切到 `M11` landed report，`raw_log_root` 已切到现有 `M11` proof-round evidence bundle，`M11` proof report 继续只作为 landed supporting proof surface，`M10`、`M9`、`M8`、`M7`、`M6`、`M5`、`M4`、`M3`、`M2` 与 `P1-43` 保留为已落地 checkpoint，latest shared checkpoint 仍是 `P1-27`。
- 当前不要做什么：不要拔高 `Phase07` 身份；不要重开 `P23`；不要把 `raw_docs/phase06-ui-p23` 与其 manifest / artifact 回升为当前 input 或 basis；不要重跑 `cjpm test`、runtime gate、或生成新的 verification bundle root；不要启动新的 continuation slice；也不要把 `M11` 误写成 arbitrary repeated-refresh family、other-peer refresh、repeated other-peer refresh、third-peer refresh、direct retarget、第二次 direct retarget、additional reopen-in-between permutation、generic retarget family、shared-only continuation、shared helper expansion、generic send API 扩张、跨 package consume widening、per-peer draft persistence rollout、broader mixed refresh family、broader UI redesign，或更强的 git-diff 级 repo-scope widening 证明。
- 当前退出条件：只有在 reviewer 明确批准 `M11` 之后的下一 bounded continuation slice、或 `P23` 既有冻结边界 / `Phase07 exploratory-only` posture 被 reviewer 明确改写时，才允许离开当前步骤并同步更新下游状态面。

## 0. Alignment Rules

- 默认恢复顺序：`AGENTS.md -> docs/status/current_committed_plan.md -> docs/current_state.v2.md -> docs/status/INDEX.md -> docs/status/current_task_handoff.md`
- `docs/status/current_committed_plan.md` 负责当前批准计划的六字段：`approved_on`、`approved_by`、`current_step`、`why_this_step`、`do_not_do_now`、`exit_condition`；若本文件在这些口径上漂移，按 `current_committed_plan` 收口。
- `docs/status/INDEX.md` 只负责导航；若 `INDEX` 与 `current_task_handoff` 的当前默认 task pointer / status 不一致，按 `current_task_handoff` 收口。
- `docs/status/current_task_handoff.md` 只保留当前 task 或 landed checkpoint 的状态，不承载默认恢复顺序或 repo 级裁决。
- `docs/agent_system/execution_routing.md` 只负责在五步恢复之后补充模式读取面与 authority/report 跳转。
- 若 `INDEX` 或 `current_task_handoff` 在 `current_step`、`why_this_step`、`do_not_do_now`、`exit_condition` 上与 `current_committed_plan` 不一致，按 `current_committed_plan` 收口。
- 若 `current_task_handoff` 或 `INDEX` 在 `active lane`、blocker、allowed moves、repo-status 身份上比本文件更激进或更宽，按本文件收口。
- `.claude/status/current-phase.md` 只作 legacy 长历史 / 旧背景对齐，不单独覆写当前项目态。

## 1. Headline

- 当前 repo 真实状态已经不是 README 里那条泛化的 `Phase 03: Physical Iron Test` 叙事，而是三层并存：
  - `Phase05` 双 baseline 稳定
  - `Phase06 regular` 正式冻结在 `P22 / 311/311 frozen-pass checkpoint`
  - post-P22 review 已固定 `direct P23 relaunch = No`
- 当前唯一 active lane：`Phase07 Telegram UI Incubation`。已落地的边界栈仍包括 `P0-1` shared-harness/module boundary 到 `P1-43` Telegram warm-send / retarget / recovery consume checkpoints，以及 `M2` 到 `M11` Telegram active-detail recovery slices；latest shared-harness checkpoint 仍为 `P1-27`，当前 latest landed Telegram consume entry / `latest_report` 已为 `M11`，当前 `raw_log_root` 已指向 `M11` proof-round evidence bundle。
- 当前 blocker：这条 lane 被明确限定为 `exploratory-only`。`raw_docs/phase06-ui-p23`、`docs/manifests/phase06_ui_*_p23*.json` 与 `artifacts/ui_pilots/20260414-phase06-ui-p23-*` 只能作为 exploratory evidence，不能回升为 current input 或 `P23` basis。与此同时，当前 `M11` 已 landed，但其后的下一 bounded continuation slice 仍待 reviewer 明确批准；clean shell 下 repo-local 仓颉 toolchain 仍需显式注入环境变量；cache sample 的 mixed `timeout 5s ... cjpm test` 仍会返回 `124`，但当前合同把它归类为 compile-budget known risk，而不是 runtime deadlock。
- 当前唯一主线目标：在不改写 `P22 / 311/311 frozen-pass checkpoint`、不重开 `P23` 的前提下，只沿 `Linux Staging-Core` 的 shared harness / Telegram app-shell / regression-first rail 维持 `M11 landed / latest_report = M11 / raw_log_root = current M11 proof-round bundle` truth surfaces：`M11` 当前只冻结“在 `M10` 的 exact two-refresh chain 上，再追加 exactly one same-peer refresh；总计三次 same-peer refresh before first reopen”的 same-package sibling edge，且 landed truth 已直接复用已闭合的 `M11` proof report / proof-round bundle，而不发生二次 rerun；当前不默认外推新 lane、shared continuation、generic retarget family 或更宽 consume widening。

## 2. What Is Active Now

- 当前唯一建议继续推进的工作：围绕 `M11 landed` 的 state/spec/report/evidence surfaces 维持一致口径，并继续保持 `Phase07 exploratory-only`；在 reviewer 明确批准 `M11` 之后的下一 bounded continuation slice之前，当前不默认启动新的 Telegram continuation，也不重回 `Phase06 regular` reserve expansion。
- 当前 authoritative frozen surfaces：
  - `AGENTS.md`
  - `docs/status/INDEX.md`
  - `docs/reports/2026-04-14-phase06-p22-regular-promotion.md`
  - `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.json`
  - `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.validation.json`
  - `artifacts/ui_pilots/20260414-phase06-ui-live-pass-coverage-r17.json`
- 当前 authoritative continuation-lane surfaces：
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - `docs/reports/2026-04-15-phase07-p0-3-verification-contract.md`
  - `docs/reports/2026-04-15-phase07-p0-4-cache-sample-5s-gate-decision.md`
  - `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice.md`
  - `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
  - `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`
  - `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-freeze-draft.md`
  - `docs/reports/2026-04-21-phase07-m10-telegram-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice.md`
  - `docs/reports/2026-04-21-phase07-m10-telegram-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
  - `artifacts/verification_contracts/20260421-phase07-telegram-m10-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`
  - `docs/reports/2026-04-20-phase07-m9-telegram-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice.md`
  - `artifacts/verification_contracts/20260420-phase07-telegram-m9-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice/`
  - `docs/reports/2026-04-20-phase07-m8-telegram-active-detail-same-peer-draft-recovery-other-peer-refresh-then-same-peer-refresh-no-restore-slice.md`
  - `artifacts/verification_contracts/20260420-phase07-telegram-m8-active-detail-same-peer-draft-recovery-other-peer-refresh-then-same-peer-refresh-no-restore-slice/`
  - `docs/reports/2026-04-20-phase07-m7-telegram-active-detail-same-peer-draft-recovery-same-peer-refresh-then-other-peer-drop-slice.md`
  - `artifacts/verification_contracts/20260420-phase07-telegram-m7-active-detail-same-peer-draft-recovery-same-peer-refresh-then-other-peer-drop-slice/`
  - `docs/reports/2026-04-20-phase07-m6-telegram-active-detail-same-peer-draft-recovery-other-peer-refresh-drop-boundary-slice.md`
  - `artifacts/verification_contracts/20260420-phase07-telegram-m6-active-detail-same-peer-draft-recovery-other-peer-refresh-drop-boundary-slice/`
  - `docs/reports/2026-04-20-phase07-m5-telegram-active-detail-same-peer-draft-recovery-refresh-before-reopen-coherence-slice.md`
  - `artifacts/verification_contracts/20260420-phase07-telegram-m5-active-detail-same-peer-draft-recovery-refresh-before-reopen-coherence-slice/`
  - `docs/reports/2026-04-20-phase07-m4-telegram-active-detail-same-peer-draft-recovery-slice.md`
  - `artifacts/verification_contracts/20260420-phase07-telegram-m4-active-detail-same-peer-draft-recovery-slice/`
  - `docs/reports/2026-04-18-phase07-m3-telegram-active-detail-composer-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-m3-active-detail-composer-slice/`
  - `docs/reports/2026-04-18-phase07-m2-telegram-active-detail-usable-thread-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-m2-active-detail-usable-thread-slice/`
  - `docs/reports/2026-04-18-phase07-p1-43-telegram-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-original-sent-target-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-43-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-original-sent-target-coherence/`
  - `docs/reports/2026-04-18-phase07-p1-42-telegram-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-other-visible-conversation-bounded-stability-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-42-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-other-visible-conversation-bounded-stability/`
  - `docs/reports/2026-04-18-phase07-p1-41-telegram-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-41-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-coherence/`
  - `docs/reports/2026-04-18-phase07-p1-40-telegram-active-detail-warm-send-back-reopen-other-visible-conversation-then-direct-retarget-original-sent-target-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-40-active-detail-warm-send-back-reopen-other-visible-conversation-then-direct-retarget-original-sent-target-coherence/`
  - `docs/reports/2026-04-18-phase07-p1-39-telegram-active-detail-warm-send-back-reopen-other-visible-conversation-stability-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-39-active-detail-warm-send-back-reopen-other-visible-conversation-stability/`
  - `docs/reports/2026-04-18-phase07-p1-38-telegram-active-detail-warm-send-back-reopen-same-sent-target-then-direct-retarget-other-visible-conversation-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-38-active-detail-warm-send-back-reopen-same-sent-target-then-direct-retarget-other-visible-conversation-coherence/`
  - `docs/reports/2026-04-18-phase07-m1-telegram-warm-send-recovery-closure.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-m1-warm-send-recovery-closure/`
  - `docs/reports/2026-04-18-phase07-p1-34-telegram-active-detail-warm-send-back-list-route-send-noop-then-reopen-same-sent-target-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-34-active-detail-warm-send-back-list-route-send-noop-then-reopen-same-sent-target-coherence/`
  - `docs/reports/2026-04-18-phase07-p1-33-telegram-active-detail-warm-send-back-list-route-send-noop-boundary-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-33-active-detail-warm-send-back-list-route-send-noop-boundary/`
  - `docs/reports/2026-04-17-phase07-p1-32-telegram-active-detail-warm-send-back-reopen-sent-target-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-32-active-detail-warm-send-back-reopen-sent-target-coherence/`
  - `docs/reports/2026-04-17-phase07-p1-31-telegram-active-detail-warm-send-retarget-alternating-reopen-bounded-stability-consume-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-31-active-detail-warm-send-retarget-alternating-reopen-bounded-stability/`
  - `docs/reports/2026-04-17-phase07-p1-30-telegram-active-detail-warm-send-retarget-back-reopen-original-sent-target-consume-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-30-active-detail-warm-send-retarget-back-reopen-original-sent-target/`
  - `docs/reports/2026-04-17-phase07-p1-29-telegram-active-detail-warm-send-retarget-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-29-active-detail-warm-send-retarget-coherence/`
  - `docs/reports/2026-04-17-phase07-p1-28-telegram-active-detail-warm-send-summary-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-28-active-detail-warm-send-summary-coherence/`
  - `docs/reports/2026-04-17-phase07-p1-27-shared-second-consumer-warm-send-repeated-get-reuse-no-refetch-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-27-second-consumer-warm-send-repeated-get-reuse-no-refetch-parity/`
  - `docs/reports/2026-04-17-phase07-p1-26-shared-second-consumer-warm-send-append-without-refetch-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-26-second-consumer-warm-send-append-without-refetch-parity/`
  - `docs/reports/2026-04-17-phase07-p1-25-shared-second-consumer-same-peer-repeated-get-reuse-no-refetch-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-25-second-consumer-same-peer-repeated-get-reuse-no-refetch-parity/`
  - `docs/reports/2026-04-17-phase07-p1-24-shared-second-consumer-cold-send-seeded-pre-drain-fetch-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-24-second-consumer-cold-send-seeded-pre-drain-fetch-parity/`
  - `docs/reports/2026-04-17-phase07-p1-23-shared-second-consumer-pre-drain-invalidate-discard-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-23-second-consumer-pre-drain-invalidate-discard-parity/`
  - `docs/reports/2026-04-17-phase07-p1-22-shared-second-consumer-invalidate-refetch-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-22-second-consumer-invalidate-refetch-parity/`
  - `docs/reports/2026-04-17-phase07-p1-21-shared-second-consumer-optimistic-signal-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-21-second-consumer-optimistic-signal-parity/`
  - `docs/reports/2026-04-17-phase07-p1-20-shared-second-consumer-send-refresh-dispatch-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-20-second-consumer-send-refresh-dispatch-parity/`
  - `docs/reports/2026-04-17-phase07-p1-19-shared-worker-fetch-helper-unification-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/`
  - `docs/reports/2026-04-17-phase07-p1-18-active-detail-refresh-retarget-alternating-reopen-bounded-stability-consume-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-18-active-detail-refresh-retarget-alternating-reopen-bounded-stability/`
- `.claude/status/current-phase.md` 现在只视为 legacy 长历史 / 滚动阶段日志；只有在需要追旧背景时才读取，不再作为默认 resume 首跳。
- `Phase05` 两套 manifest 仍是 baseline guardrail，而不是当前 continuation lane 的 active truth surface；它们负责保住翻译 / verifier 基线，不负责定义 `Phase07` 的 app-shell 语义。

## 3. Allowed Moves

- 只允许在 `Phase07 Telegram UI Incubation` 当前边界内继续做：
  - shared harness / module boundary 的最小抽取
  - Telegram app-shell bounded consume slice
  - regression/test-first rail
  - Linux `Staging-Core` compile / unit / behavior 证据
- 只允许把 `samples/telegram-ui-vertical-slice-001` 继续当作 exploratory seed input，而不是 broader repo evidence。
- 只允许在需要 guard 当前基线时重跑：
  - `docs/manifests/batch_manifest_phase05.json`
  - `docs/manifests/batch_manifest_phase05_fresh_real_translator.json`
  但这些 rerun 只能解释 baseline 稳定性，不能冒充 `Phase07` 进展。
- 只允许把 cache sample 的 mixed `5s` wrapper 当作 compile-budget probe；真正 runtime/no-deadlock gate 仍是 `--skip-build` 路径。

## 4. Explicit Non-Goals

- 不重开任何 `P23` freeze、mock、aggregate audit 或 coverage 分支。
- 不把 `raw_docs/phase06-ui-p23`、`docs/manifests/phase06_ui_*_p23*.json`、`artifacts/ui_pilots/20260414-phase06-ui-p23-*` 重新升格为 current input、broader repo evidence 或 `P23` basis。
- 不把 `Phase07` 的 repo-local sample 结果写成 broader non-repo-local rollout、full-pass outcome 或新的 `Phase06 regular` 成果。
- 不把 README 里的旧 `Phase03` 叙事当成当前唯一事实，也不把 `Phase05` baseline rerun 写成 `Phase07` 功能落地。
- 不把 cache sample `timeout 5s ... cjpm test = 124` 写成 runtime deadlock 或 packaging blocker。

## 5. Pending Decisions

- `M11` 已作为当前 latest landed Telegram continuation slice 收口；是否继续向下推进取决于 reviewer 是否明确批准 `M11` 之后的下一 bounded continuation slice。
- cache sample 的 compile-budget known risk 当前被允许带着继续前进；是否需要专门收紧 build budget，仍取决于下一轮 continuation lane 需要。
- 如果后续继续扩 continuation lane，需要先重新判断 Telegram app-shell consume rail 在 `M11 landed` 已锁定 exact third-refresh sibling gap 之后是否仍存在一个更小、更独立、且未闭合的 same-package gap；在此之前，不默认授予新的 shared continuation、broader app-shell widening或 repo-scope promotion 授权。

## 6. Evidence Index

- 项目热区 SSOT：`AGENTS.md`
- 当前批准计划：`docs/status/current_committed_plan.md`
- 当前项目态快照：`docs/current_state.v2.md`
- 状态索引 / 续接导航：`docs/status/INDEX.md`
- 当前 task 交接面：`docs/status/current_task_handoff.md`
- 当前执行路线：`docs/agent_system/execution_routing.md`
- 长历史 / 阶段滚动日志：`.claude/status/current-phase.md`（只在需要旧背景时读取，不是默认续接首跳）
- `Phase05` baseline manifests：
  - `docs/manifests/batch_manifest_phase05.json`
  - `docs/manifests/batch_manifest_phase05_fresh_real_translator.json`
- `Phase06` 正式冻结证据：`docs/reports/2026-04-14-phase06-p22-regular-promotion.md`
- `Phase07` 规格集：`specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
- `Phase07` 运行合同：`docs/reports/2026-04-15-phase07-p0-3-verification-contract.md`
- cache sample gate split：`docs/reports/2026-04-15-phase07-p0-4-cache-sample-5s-gate-decision.md`
- 当前 latest shared-harness checkpoint：`docs/reports/2026-04-17-phase07-p1-27-shared-second-consumer-warm-send-repeated-get-reuse-no-refetch-parity-slice.md`
- 当前 latest shared-harness evidence bundle：`artifacts/verification_contracts/20260417-phase07-shared-p1-27-second-consumer-warm-send-repeated-get-reuse-no-refetch-parity/`
- 当前 Telegram landed report：`docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice.md`
- 当前 Telegram antecedent freeze-draft report：`docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-freeze-draft.md`
- 当前 Telegram supporting proof-round report：`docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
- 当前 Telegram consume entry：`docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice.md`
- 当前下一 bounded continuation slice：`待 reviewer 明确批准`
- 当前 Telegram proof-round evidence bundle：`artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`

## 更新规则

只有当“当前快照”发生变化时才更新本文件。
