# Current State v2

更新时间：`2026-04-16`

## 1. Headline

- 当前 repo 真实状态已经不是 README 里那条泛化的 `Phase 03: Physical Iron Test` 叙事，而是三层并存：
  - `Phase05` 双 baseline 稳定
  - `Phase06 regular` 正式冻结在 `P22 / 311/311 live passed`
  - post-P22 review 已固定 `direct P23 mechanical-ready = No`
- 当前唯一 active lane：`Phase07 Telegram UI Incubation`。已落地的边界栈是 `P0-1` shared-harness/module boundary、`P0-2` app-shell consume boundary、`P0-3` verification contract、`P0-4` cache-sample 5s gate split、`P1-4` shared-harness first slice、`P1-5` shell-refresh consume slice、`P1-6` second-consumer compatibility slice、`P1-7` detail-route retarget consume slice、`P1-8` back-stability consume slice、`P1-9` detail-projection reset consume slice、`P1-10` back-to-list refresh isolation consume slice、`P1-11` refresh-then-reopen coherence consume slice、`P1-12` refresh-reopen-retarget coherence consume slice、`P1-13` round-trip stability consume slice、`P1-14` alternating-reopen bounded stability consume slice、`P1-15` active-detail target refresh-back-reopen consume slice，以及当前 Telegram consume entry `P1-16 active-detail target refresh-retarget coherence consume slice`。
- 当前 blocker：这条 lane 被明确限定为 `exploratory-only`。`raw_docs/phase06-ui-p23`、`docs/manifests/phase06_ui_*_p23*.json` 与 `artifacts/ui_pilots/20260414-phase06-ui-p23-*` 只能作为 exploratory evidence，不能回升为 live input 或 mechanical-ready basis。与此同时，clean shell 下 repo-local 仓颉 toolchain 仍需显式注入环境变量；cache sample 的 mixed `timeout 5s ... cjpm test` 仍会返回 `124`，但当前合同把它归类为 compile-budget known risk，而不是 runtime deadlock。
- 当前唯一主线目标：在不改写 `P22 / 311/311 live passed`、不重开 `P23` 的前提下，只沿 `Linux Staging-Core` 的 shared harness / Telegram app-shell / regression-first rail 继续推进 `Phase07` 的 bounded continuation lane，同时保持 `Phase05` 双 baseline 继续可回放。

## 2. What Is Active Now

- 当前唯一建议继续推进的工作：围绕 `samples/telegram-ui-vertical-slice-001`、`samples/phase07-shared-service-refresh-harness`、`samples/real-message-service-cache-001` 继续做 `Phase07` 的 bounded consume / regression work，而不是重回 `Phase06 regular` reserve expansion。
- 当前 authoritative frozen surfaces：
  - `AGENTS.md`
  - `.claude/status/current-phase.md`
  - `docs/reports/2026-04-14-phase06-p22-regular-promotion.md`
  - `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.json`
  - `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.validation.json`
  - `artifacts/ui_pilots/20260414-phase06-ui-live-pass-coverage-r17.json`
- 当前 authoritative continuation-lane surfaces：
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - `docs/reports/2026-04-15-phase07-p0-3-verification-contract.md`
  - `docs/reports/2026-04-15-phase07-p0-4-cache-sample-5s-gate-decision.md`
  - `docs/reports/2026-04-16-phase07-p1-16-active-detail-target-refresh-retarget-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260416-phase07-telegram-p1-16-active-detail-target-refresh-retarget-coherence/`
- `Phase05` 两套 manifest 仍是 baseline guardrail，而不是当前 continuation lane 的 active truth surface；它们负责保住翻译 / verifier 基线，不负责定义 `Phase07` 的 app-shell 语义。

## 3. Allowed Moves

- 只允许在 `Phase07 Telegram UI Incubation` 当前边界内继续做：
  - shared harness / module boundary 的最小抽取
  - Telegram app-shell bounded consume slice
  - regression/test-first rail
  - Linux `Staging-Core` compile / unit / behavior 证据
- 只允许把 `samples/telegram-ui-vertical-slice-001` 继续当作 exploratory seed input，而不是 promoted evidence。
- 只允许在需要 guard 当前基线时重跑：
  - `docs/manifests/batch_manifest_phase05.json`
  - `docs/manifests/batch_manifest_phase05_fresh_real_translator.json`
  但这些 rerun 只能解释 baseline 稳定性，不能冒充 `Phase07` 进展。
- 只允许把 cache sample 的 mixed `5s` wrapper 当作 compile-budget probe；真正 runtime/no-deadlock gate 仍是 `--skip-build` 路径。

## 4. Explicit Non-Goals

- 不重开任何 `P23` freeze、mock、live、aggregate audit 或 coverage。
- 不把 `raw_docs/phase06-ui-p23`、`docs/manifests/phase06_ui_*_p23*.json`、`artifacts/ui_pilots/20260414-phase06-ui-p23-*` 重新升格为 live input、promoted evidence 或 mechanical-ready basis。
- 不把 `Phase07` 的 repo-local sample 结果写成 Harmony live、Windows `Staging-Full`、promoted lane、Full Pass 或新的 `Phase06 regular` 成果。
- 不把 README 里的旧 `Phase03` 叙事当成当前唯一事实，也不把 `Phase05` baseline rerun 写成 `Phase07` 功能落地。
- 不把 cache sample `timeout 5s ... cjpm test = 124` 写成 runtime deadlock 或 packaging blocker。

## 5. Pending Decisions

- `P1-16` 已落地，但下一个 bounded `Phase07` 切片还没有正式冻结成新的后续任务。
- cache sample 的 compile-budget known risk 当前被允许带着继续前进；是否需要专门收紧 build budget，仍取决于下一轮 continuation lane 需要。
- 如果后续继续扩 app-shell consume boundary，需要决定是先补新 regression/report，还是先做更小的 harness 层切片。

## 6. Evidence Index

- 项目热区 SSOT：`AGENTS.md`
- 当前阶段页：`.claude/status/current-phase.md`
- `Phase05` baseline manifests：
  - `docs/manifests/batch_manifest_phase05.json`
  - `docs/manifests/batch_manifest_phase05_fresh_real_translator.json`
- `Phase06` 正式冻结证据：`docs/reports/2026-04-14-phase06-p22-regular-promotion.md`
- `Phase07` 规格集：`specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
- `Phase07` 运行合同：`docs/reports/2026-04-15-phase07-p0-3-verification-contract.md`
- cache sample gate split：`docs/reports/2026-04-15-phase07-p0-4-cache-sample-5s-gate-decision.md`
- 当前 Telegram consume entry：`docs/reports/2026-04-16-phase07-p1-16-active-detail-target-refresh-retarget-coherence-consume-slice.md`
- 当前 Telegram evidence bundle：`artifacts/verification_contracts/20260416-phase07-telegram-p1-16-active-detail-target-refresh-retarget-coherence/`

## 更新规则

只有当“当前快照”发生变化时才更新本文件。
