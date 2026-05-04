# CangjieTransSkills Phase06 Live Curator Pilot Requirements

## 1. 问题定义

当前仓库已经完成以下前置条件：

- `Phase05` 默认入口已经形成 keyless deterministic baseline；
- `Phase06` 外部 UI P0 样本已经冻结到 `raw_docs/phase06-ui-p0`；
- `docs/manifests/phase06_ui_p0_file_manifest.json` 已将外部样本展开为 12-slice file-level workset；
- `docs/manifests/phase06_ui_prompt_pilot_batch1.json` 已从 workset 中确定性选出 5 个首轮 prompt pilot；
- `artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/batch1-evidence.json` 已给出 `pilot_count=5`、`passed_count=5` 的 prompt-dump 证据。

当前未决问题不是“是否已经具备入口”，而是：

1. 首轮 live curator 应该先消费哪 1-2 条 lane；
2. 如何在不扰动 `Phase05` baseline 的前提下，把“吸收学长项目”的下一步收敛为最小试点；
3. 如何为后续真实执行预先定义证据要求、暂停条件和扩量条件。

本 spec 只解决上述计划问题，不启动实现。

## 2. 范围

### 2.1 In Scope

- 基于现有 `Phase06 batch1` prompt-pilot manifest 选择首轮 lane 组合；
- 明确首轮试点的目标、边界、优先级与进入条件；
- 定义后续 live translator attempt / curator 的最小证据要求；
- 定义何时可以从首轮 lane 扩展到下一轮 lane。

### 2.2 Out of Scope

- 不执行真实 live translator attempt；
- 不修改 `scripts/run_mass_translation.sh`、`scripts/pipeline_runner.py`、`scripts/pipeline_batch_runner.py`；
- 不推进 `RealMessageService.ets` control-only fresh repair；
- 不在本轮推进 `docs/`、`scripts/`、`full-pass sidecar` 的全面吸收落位；
- 不创建新的 SSOT，也不改写 `AGENTS.md` 或 `/.claude/status/current-phase.md` 的主线结论。

## 3. 冻结输入

本 spec 依赖以下已冻结输入：

- [AGENTS.md](../../AGENTS.md)
- [.claude/status/current-phase.md](../../.claude/status/current-phase.md)
- [docs/decisions/2026-04-08-cangjietransskills-landing-checklist.md](../../docs/decisions/2026-04-08-cangjietransskills-landing-checklist.md)
- [docs/reports/2026-04-08-cangjietransskills-absorption-plan-draft.md](../../docs/reports/2026-04-08-cangjietransskills-absorption-plan-draft.md)
- [docs/manifests/phase06_ui_p0_file_manifest.json](../../docs/manifests/phase06_ui_p0_file_manifest.json)
- [docs/manifests/phase06_ui_prompt_pilot_batch1.json](../../docs/manifests/phase06_ui_prompt_pilot_batch1.json)
- [artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/batch1-evidence.json](../../artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/batch1-evidence.json)
- [artifacts/batch_runs/telegramharmony-phase05-mass-translation-initialization/batch-summary.json](../../artifacts/batch_runs/telegramharmony-phase05-mass-translation-initialization/batch-summary.json)

## 4. 用户故事

- 作为当前仓维护者，我希望先从 `Phase06 batch1` 中选出最小互补 lane 组合，这样可以继续推进“吸收学长项目”的计划，而不必一次性扩大范围。
- 作为验证与证据链维护者，我希望首轮试点沿用现有 manifest 和 artifact 路径，这样后续执行仍然可复现、可回放。
- 作为当前阶段的执行者，我希望 `Phase05` baseline 保持冻结，这样新试点不会把已绿主线重新拖回不稳定状态。

## 5. 约束

- 当前阶段仍属于 `Doc / Design`，不得把新外部 UI 样本表述为“已 compile passed / 已 Full Pass”。
- 当前仓的 SSOT 仍由 `AGENTS.md`、`current-phase.md` 与 `artifacts/*` 原始证据共同裁决。
- `Phase05` baseline、Windows `full-pass-achieved` 证据和 `Phase06 batch1` prompt-dump 证据都必须保持可回放。
- `mock-mode` 不得作为后续 live curator 通过性的证明。

## 6. 验收标准

### Requirement 1: 主线保护

当规划 `Phase06` 首轮 live curator 试点时，计划文档应明确把 `Phase05` keyless deterministic baseline 视为冻结护栏，并且不得要求修改 `docs/manifests/batch_manifest_phase05.json` 或其默认执行入口。

### Requirement 2: 最小互补 lane 选择

当从 `docs/manifests/phase06_ui_prompt_pilot_batch1.json` 选择首轮试点时，计划文档应明确给出一组主选 lane 和一组备选 lane，并说明它们为何能够以最小范围覆盖 `page` 与 `component` 两类互补风险。

### Requirement 3: 消费正确入口

当后续真实执行开始时，执行者应直接消费 `docs/manifests/phase06_ui_prompt_pilot_batch1.json` 中已经生成的 `src_root`、`target_file`、`pipeline_command` 和 prompt dump 路径，而不是退回到 `phase06_ui_source_corpus_p0.json` 或 `phase06_ui_p0_file_manifest.json` 重新做人肉选择。

### Requirement 4: 计划阶段口径

当本任务仍停留在规划阶段时，文档应明确禁止把首轮 lane 表述为“已翻译通过”“已 compile 通过”或“已 Full Pass”，并应把后续动作描述为待批准的执行任务。

### Requirement 5: 证据链要求

当后续任一 live translator attempt / curator 开始时，执行者应至少回收命令、结果、`summary.json`、`failure.json`、prompt dump 路径和对应 artifact 根路径，保证每条 lane 都能独立回放。

### Requirement 6: 优先级收敛

当 `Phase06` 首轮 live curator 与 `RealMessageService.ets` control-only fresh repair 发生优先级竞争时，计划文档应把 `Phase06 batch1` 首轮试点置于更高优先级，并将后者保留为次级 repair 选项。

## 7. 非目标澄清

- 本 spec 不判断“学长项目是否应该替代当前仓主线”。
- 本 spec 不承诺整包吸收 `CangjieTransSkills`。
- 本 spec 不在本轮引入 AGENT TEAM。
- 本 spec 不要求考古 `docs/agent_evolution_archive.md`，除非后续执行时遇到热区口径冲突。
