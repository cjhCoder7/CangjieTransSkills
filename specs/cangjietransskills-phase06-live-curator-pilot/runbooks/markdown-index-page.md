# Phase06 Markdown Index Page Execution Pack

## 0. 文档定位

- `pilot_id`：`phase06-ui-pilot-batch1-phase06-ui-p0-markdown-index-page`
- `状态`：`planning-only`
- `目标`：为 `markdown-index-page` 首轮 live curator 准备最小执行包，但当前不启动真实 run。
- `上游 spec`：
  - [requirements.md](../requirements.md)
  - [design.md](../design.md)
  - [tasks.md](../tasks.md)

## 1. 冻结身份

- `repo_name`：`markdown4cj`
- `repo_local_path`：`raw_docs/phase06-ui-p0/markdown4cj/entry/src/main/cangjie/src/index_page.cj`
- `source_path`：`entry/src/main/cangjie/src/index_page.cj`
- `src_root`：`raw_docs/phase06-ui-p0/markdown4cj/entry/src/main/cangjie/src`
- `target_file`：`index_page.cj`
- `target_role`：`page`
- `slice_kind`：`entry-page`
- `track_id`：`page-shell-controller-owned-state`
- `ui_prompt_tags`：
  - `structure_tag=page-shell`
  - `ownership_tag=controller-owned-state`
  - `interaction_tags=[]`
- `recommended_few_shot_entry_ids`：
  - `local-data-persistence-page-shell-controller-owned-state`
  - `harmonyos-cangjie-cases-customtabbar-page-shell-controller-owned-state`

## 2. 当前冻结证据

- prompt-dump 证据路径：
  - `artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-index-page/prompt_dump.txt`
  - `artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-index-page/prompt_dump.explicit_ui_tags.txt`
- prompt 摘要路径：
  - `artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-index-page/pilot-summary.json`
- 当前证据结论：
  - `status=prompt-dumped`
  - `expected_prompt_signal=resolution_source=explicit-target-ui-tags`
  - `explicit_prompt_contains_signal=true`

## 3. 执行前检查

进入真实执行前，先确认：

1. `Phase05` baseline 仍可独立 rerun，不需要为本 lane 改动默认入口。
2. `pilot-summary.json` 中 `explicit_prompt_contains_signal=true` 仍成立。
3. 当前 shell 已准备好 live key 入口，但不在文档中落盘真实 key。
4. 本轮仍不插入 `RealMessageService.ets` control-only fresh repair。

## 4. 冻结命令

### 4.1 已收证 prompt-baseline 命令

以下命令来自 batch1 manifest，代表当前已落盘的 prompt-dump 基线：

```bash
python3 scripts/pipeline_runner.py \
  --src-root raw_docs/phase06-ui-p0/markdown4cj/entry/src/main/cangjie/src \
  --target-file index_page.cj \
  --run-root artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-index-page/pipeline_run \
  --db-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-index-page/pipeline_run/repo_index.sqlite \
  --repo-map-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-index-page/pipeline_run/repo_map.txt \
  --tu-json-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-index-page/pipeline_run/target.tu.json \
  --orchestration-output-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-index-page/pipeline_run/target.orchestration.json \
  --summary-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-index-page/pipeline_run/summary.json \
  --failure-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-index-page/pipeline_run/failure.json \
  --prompt-dump-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-markdown-index-page/prompt_dump.txt \
  --architecture-skill docs/strategy/phase-06-ui-sample-taxonomy-and-prompt-constraints.md \
  --snapshot-label phase06-ui-batch1-phase06-ui-p0-markdown-index-page \
  --dump-prompt-only \
  --extensions .cj \
  --pattern-limit 0
```

### 4.2 待批准首轮 live-attempt 模板

以下命令模板尚未执行，只用于首轮批准后的 live curator 起跑：

```bash
OPENAI_API_KEY=... \
python3 scripts/pipeline_runner.py \
  --src-root raw_docs/phase06-ui-p0/markdown4cj/entry/src/main/cangjie/src \
  --target-file index_page.cj \
  --run-root artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-index-page/pipeline_run \
  --db-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-index-page/pipeline_run/repo_index.sqlite \
  --repo-map-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-index-page/pipeline_run/repo_map.txt \
  --tu-json-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-index-page/pipeline_run/target.tu.json \
  --orchestration-output-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-index-page/pipeline_run/target.orchestration.json \
  --summary-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-index-page/pipeline_run/summary.json \
  --failure-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-index-page/pipeline_run/failure.json \
  --prompt-dump-path artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-index-page/prompt_dump.txt \
  --architecture-skill docs/strategy/phase-06-ui-sample-taxonomy-and-prompt-constraints.md \
  --snapshot-label <snapshot-label> \
  --no-mock-mode \
  --verify-dry-run \
  --llm-max-retries 1 \
  --max-rounds 1 \
  --extensions .cj \
  --pattern-limit 0
```

## 5. 预期产物

若进入真实执行，至少应回收：

- `summary.json`
- `failure.json`
- `target.orchestration.json`
- `target.tu.json`
- `prompt_dump.txt`
- `pipeline.log`
- `repo_map.txt`

所有产物都应落在：

- `artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/live_curator/<run-label>/phase06-ui-p0-markdown-index-page/`

## 6. 首个 blocker 分类入口

优先按以下顺序分类：

1. `prompt signal` 是否仍为 `resolution_source=explicit-target-ui-tags`
2. 是否缺失 live key 或命中基础设施噪声
3. 是否命中新 reviewer / static blacklist
4. 是否出现 page-shell / controller-owned-state 口径漂移

若第 1 项不成立，应先停在 prompt/tag 分类层，不进入更深修复。

## 7. 停机条件

出现以下任一情况即暂停本 lane，不扩到下一条：

- 需要回滚 `Phase05` baseline
- 当前 shell 无法安全提供 live key
- `summary.json` 首个 blocker 未被归类
- 出现新的 schema / summary / promotion 口径分叉

## 8. 回写位置

本 lane 后续真实执行完成后，只回写：

- lane 自身 artifact 目录
- [tasks.md](../tasks.md) 的状态
- 必要时回写 [design.md](../design.md) 的风险结论

在未形成稳定证据前，不修改 `AGENTS.md` 或 `current-phase.md` 的主线结论。
