# Phase06 Markdown Heading Component Execution Pack

## 0. 文档定位

- `pilot_id`：`phase06-ui-pilot-batch1-phase06-ui-p0-markdown-heading-component`
- `状态`：`live-curator-passed`
- `目标`：`markdown-heading-component` 已完成首轮 live curator 收口；当前文档保留最小执行包与通过证据，供后续扩量和复盘使用。
- `上游 spec`：
  - [requirements.md](../requirements.md)
  - [design.md](../design.md)
  - [tasks.md](../tasks.md)

## 1. 冻结身份

- `repo_name`：`markdown4cj`
- `repo_local_path`：`raw_docs/phase06-ui-p0/markdown4cj/markdown/src/main/cangjie/src/components/markdown_heading_component.cj`
- `source_path`：`markdown/src/main/cangjie/src/components/markdown_heading_component.cj`
- `src_root`：`raw_docs/phase06-ui-p0/markdown4cj/markdown/src/main/cangjie/src`
- `target_file`：`components/markdown_heading_component.cj`
- `target_role`：`component`
- `slice_kind`：`primary-component`
- `track_id`：`rich-component-controller-owned-state`
- `ui_prompt_tags`：
  - `structure_tag=rich-component`
  - `ownership_tag=controller-owned-state`
  - `interaction_tags=[]`
- `recommended_few_shot_entry_ids`：
  - `markdown4cj-rich-component-controller-owned-state`

## 2. 当前冻结证据

- prompt-dump 证据路径：
  - `artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-heading-component/prompt_dump.txt`
  - `artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-heading-component/prompt_dump.explicit_ui_tags.txt`
- prompt 摘要路径：
  - `artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-heading-component/pilot-summary.json`
- 当前证据结论：
  - `status=prompt-dumped`
  - `expected_prompt_signal=resolution_source=explicit-target-ui-tags`
  - `explicit_prompt_contains_signal=true`
- live curator 通过证据路径：
  - `artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/20260409-phase06-ui-batch1-live-curator-r4/phase06-ui-p0-markdown-heading-component/summary.json`
  - `artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/20260409-phase06-ui-batch1-live-curator-r4/phase06-ui-p0-markdown-heading-component/orchestration.json`
  - `artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/20260409-phase06-ui-batch1-live-curator-r4/phase06-ui-p0-markdown-heading-component/run.log`
  - `artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/20260409-phase06-ui-batch1-live-curator-r4/batch-report.json`
- post-pass stronger verification 路径：
  - `artifacts/verification/20260409-phase06-ui-markdown-heading-component-r4.real-compile.verify.json`
  - `artifacts/verification/20260409-phase06-ui-markdown-heading-component-r4.real-compile.with-api-import-path.verify.json`
- 当前最新结论：
  - `run_label=20260409-phase06-ui-batch1-live-curator-r4`
  - `final_status=passed`
  - `verify_status=passed`
  - `round_count=2`
  - `attempt-1` 已消除旧 `ARCH_SYNTAX_BLOCKER`，并将 blocker 收敛为两条 `ARCH_SOURCE_ALIGNMENT_RUPTURE`
  - `attempt-2` 已去除 `@Builder` 漂移并修正 source-backed invocation patterns，随后 reviewer + verifier 全绿
  - post-pass `verifier.py --no-dry-run --real-compile` 已证明当前候选不再首先卡在 `refreshData` / source-alignment 实体问题，而是卡在 Linux Staging-Core 的 Harmony package 解析边界
  - 第一轮 real compile 直接报 `ohos.base` / `ohos.component` / `ohos.state_manage` / `ohos.state_macro_manage` 缺包
  - 在 `CANGJIE_PATH` 追加 `api/lib/linux_ohos_x86_64_cjnative` 后，`ohos.base` 已可解析，但 `ohos.component` / `ohos.state_manage` / `ohos.state_macro_manage` 仍缺失，说明当前更像 package-era mismatch / host SDK boundary，而不是 prompt regression

## 3. 历史锚点

该 lane 在更早的 Phase06 UI pilot 中已经有一条明确的基础设施型 blocker：

- 历史失败路径：
  - `artifacts/ui_pilots/20260406-phase06-ui-pilot/rich-component-controller-owned-state/real_dry_run/failure.json`
- 历史结论：
  - `failure_class=pipeline-error`
  - `error=LLMAdapterError: 未检测到 SILICONFLOW_API_KEY，无法发起真实 LLM 调用。`

这说明首轮 live curator 的第一检查项仍然是 key 入口，而不是 UI 误译簇本身。

## 4. 执行前检查

进入真实执行前，先确认：

1. `Phase05` baseline 仍可独立 rerun，不需要为本 lane 改动默认入口。
2. `pilot-summary.json` 中 `explicit_prompt_contains_signal=true` 仍成立。
3. 当前 shell 已准备好 live key 入口，但不在文档中落盘真实 key。
4. 当前 run 不会覆盖 2026-04-08 已落盘的 prompt-dump 证据。

## 5. 冻结命令

### 5.1 已收证 prompt-baseline 命令

以下命令来自 batch1 manifest，代表当前已落盘的 prompt-dump 基线：

```bash
python3 scripts/pipeline_runner.py \
  --src-root raw_docs/phase06-ui-p0/markdown4cj/markdown/src/main/cangjie/src \
  --target-file components/markdown_heading_component.cj \
  --run-root artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-heading-component/pipeline_run \
  --db-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-heading-component/pipeline_run/repo_index.sqlite \
  --repo-map-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-heading-component/pipeline_run/repo_map.txt \
  --tu-json-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-heading-component/pipeline_run/target.tu.json \
  --orchestration-output-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-heading-component/pipeline_run/target.orchestration.json \
  --summary-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-heading-component/pipeline_run/summary.json \
  --failure-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-heading-component/pipeline_run/failure.json \
  --prompt-dump-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-heading-component/prompt_dump.txt \
  --architecture-skill docs/strategy/phase-06-ui-sample-taxonomy-and-prompt-constraints.md \
  --snapshot-label phase06-ui-batch1-phase06-ui-p0-markdown-heading-component \
  --dump-prompt-only \
  --extensions .cj \
  --pattern-limit 0
```

### 5.2 待批准首轮 live-attempt 模板

以下命令模板已由 `20260409-phase06-ui-batch1-live-curator-r4` 实际消费，保留为可回放模板：

```bash
OPENAI_API_KEY=... \
python3 scripts/pipeline_runner.py \
  --src-root raw_docs/phase06-ui-p0/markdown4cj/markdown/src/main/cangjie/src \
  --target-file components/markdown_heading_component.cj \
  --run-root artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-heading-component/pipeline_run \
  --db-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-heading-component/pipeline_run/repo_index.sqlite \
  --repo-map-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-heading-component/pipeline_run/repo_map.txt \
  --tu-json-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-heading-component/pipeline_run/target.tu.json \
  --orchestration-output-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-heading-component/pipeline_run/target.orchestration.json \
  --summary-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-heading-component/pipeline_run/summary.json \
  --failure-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-heading-component/pipeline_run/failure.json \
  --prompt-dump-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-heading-component/prompt_dump.txt \
  --architecture-skill docs/strategy/phase-06-ui-sample-taxonomy-and-prompt-constraints.md \
  --snapshot-label <snapshot-label> \
  --no-mock-mode \
  --verify-dry-run \
  --llm-max-retries 1 \
  --max-rounds 1 \
  --extensions .cj \
  --pattern-limit 0
```

## 6. 预期产物

若进入真实执行，至少应回收：

- `summary.json`
- `failure.json`
- `target.orchestration.json`
- `target.tu.json`
- `prompt_dump.txt`
- `pipeline.log`
- `repo_map.txt`

所有产物都应落在：

- `artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-heading-component/`

## 7. 首个 blocker 分类入口

优先按以下顺序分类：

1. 是否仍缺 live key 或命中基础设施噪声
2. `prompt signal` 是否仍为 `resolution_source=explicit-target-ui-tags`
3. 是否命中新 reviewer / static blacklist
4. 是否出现 rich-component / controller-owned-state 口径漂移

若首个 blocker 仍是 key 缺失，应直接归类为基础设施问题，不把它误判为组件误译。

## 8. 停机条件

出现以下任一情况即暂停本 lane，不扩到下一条：

- 需要回滚 `Phase05` baseline
- 当前 shell 无法安全提供 live key
- `summary.json` 首个 blocker 未被归类
- 出现新的 schema / summary / promotion 口径分叉

## 9. 回写位置

本 lane 后续真实执行完成后，只回写：

- lane 自身 artifact 目录
- [tasks.md](../tasks.md) 的状态
- 必要时回写 [design.md](../design.md) 的风险结论

在未形成稳定证据前，不修改 `AGENTS.md` 或 `current-phase.md` 的主线结论。
