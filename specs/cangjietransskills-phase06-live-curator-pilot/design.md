# CangjieTransSkills Phase06 Live Curator Pilot Design

## 1. 设计目标

本设计把“吸收学长项目”的下一步收敛为一个可执行但尚未执行的最小试点：

- 继续把当前仓作为 `执行主线 / 证据主线 / promotion 裁决主线`；
- 不做整仓集成或整包吸收；
- 仅围绕 `Phase06 batch1` 决定首轮 live curator 先跑哪 1-2 条 lane；
- 为后续执行预先定义进入条件、停机条件和扩量条件。

## 2. 设计边界

### 2.1 保持不变的部分

- `env -u SILICONFLOW_API_KEY bash scripts/run_mass_translation.sh docs/manifests/batch_manifest_phase05.json`
  仍是 `Phase05` 默认 deterministic baseline 入口；
- `RealMessageService.ets` control-only fresh repair 继续保持次级优先级；
- Windows `full-pass-achieved` 证据继续视为既有闭环，不参与本轮 lane 选择。

### 2.2 本轮真正要决定的部分

- 从 `Phase06 batch1` 的 5 条 pilot 中选出主选与备选 lane 组合；
- 定义后续 live curator 的最小执行包；
- 定义什么情况下可以从首轮 pair 扩到下一组 pair。

## 3. 输入资产

### 3.1 现有 prompt-pilot 入口

[docs/manifests/phase06_ui_prompt_pilot_batch1.json](../../docs/manifests/phase06_ui_prompt_pilot_batch1.json) 已为每条 lane 预计算：

- `src_root`
- `target_file`
- `pipeline_command`
- `artifact_root`
- `pipeline_summary_path`
- `failure_path`
- `base_prompt_dump_path`
- `explicit_prompt_dump_path`
- `recommended_few_shot_entry_ids`

这意味着首轮 live curator 不需要再从 file-level manifest 重新手工拼接执行参数。

### 3.2 当前 batch1 候选

| Pilot | 角色 | 结构 | 所有权模型 | 特征 | 当前判断 |
|---|---|---|---|---|---|
| `badgeview-page` | `page` | `page-shell` | `view-model-renderer` | 嵌套 badge / 组合布局 | 可作为后续横向扩展示例 |
| `ledger-top-bar-component` | `component` | `rich-component` | `view-model-renderer` | 支撑组件，风险较低 | 代表性不如主组件 |
| `markdown-index-page` | `page` | `page-shell` | `controller-owned-state` | 低额外变量的 page-shell | 适合作为主选 page lane |
| `markdown-heading-component` | `component` | `rich-component` | `controller-owned-state` | 同语料域主组件 | 适合作为主选 component lane |
| `photo-view-component` | `component` | `rich-component` | `controller-owned-state` | `gesture-component` | 适合作为第二波扩展 lane |

## 4. Lane 选择策略

### 4.1 主选组合

首轮主选组合定为：

1. `phase06-ui-pilot-batch1-phase06-ui-p0-markdown-index-page`
2. `phase06-ui-pilot-batch1-phase06-ui-p0-markdown-heading-component`

选择理由：

- 两条 lane 来自同一语料域 `markdown4cj`，变量更少；
- 一条 `page` + 一条 `component`，覆盖面互补；
- 同属 `controller-owned-state` 口径，便于观察 prompt 与 live translator 行为，而不是把差异混进样本域；
- `markdown-heading-component` 在冷历史里已经出现过 prompt evidence 与 secret 缺失阻塞的早期记录，便于与旧证据对照。

### 4.2 备选组合

第二优先级备选组合定为：

1. `phase06-ui-pilot-batch1-phase06-ui-p0-badgeview-page`
2. `phase06-ui-pilot-batch1-phase06-ui-p0-photo-view-component`

选择理由：

- `badgeview-page` 提供 `page-shell + view-model-renderer` 的异质样本；
- `photo-view-component` 提供 `gesture-component` 风险增量；
- 组合的信息增益更大，但问题定位会更分散，因此不应作为第一轮主选。

### 4.3 暂不作为首轮主选的 lane

- `ledger-top-bar-component`

原因：

- 其风险低且偏支撑组件；
- 在首轮只允许 1 page + 1 component 时，它的代表性不如 `markdown-heading-component` 或 `photo-view-component`。

## 5. 执行包设计

后续一旦进入实施，执行者应以每条 lane 的 manifest entry 作为最小执行包，至少包含：

- `pilot_id`
- `src_root`
- `target_file`
- `pipeline_command`
- `artifact_root`
- `base_prompt_dump_path`
- `explicit_prompt_dump_path`
- `recommended_few_shot_entry_ids`

### 5.1 执行顺序

1. 先确认 `Phase05` baseline 仍可独立 rerun；
2. 再消费主选 page lane；
3. 再消费主选 component lane；
4. 根据两条 lane 的失败类别决定是否扩到备选组合；
5. 若首轮失败归因为基础设施或 prompt 口径问题，先分类，不立即扩量。

### 5.2 不允许的捷径

- 不从 `phase06_ui_source_corpus_p0.json` 重新手工挑样本；
- 不绕开 `phase06_ui_prompt_pilot_batch1.json` 的显式 `ui_prompt_tags` 证据；
- 不把 `prompt_dump_only` 产物误当成真实翻译通过证据；
- 不在首轮试点前插入 `RealMessageService.ets` fresh repair。

## 6. 证据与决策门

### 6.1 执行前门

进入真实实施前，必须同时满足：

- `Phase05` baseline 无回退；
- `batch1` manifest、prompt dump 和 artifact 路径存在；
- 首轮 lane 组合已经在 spec 中冻结；
- 用户明确批准从计划阶段切换到执行阶段。

### 6.2 执行中门

对每条 lane，至少应记录：

- 实际命令
- 退出结果
- `summary.json`
- `failure.json`
- prompt dump 路径
- 运行根目录

如果首个 blocker 属于以下类型，应先停在分类层，不直接扩量：

- 缺 key / 网络基础设施噪声
- prompt 解析或显式 tag 失配
- reviewer / static blacklist 新墙
- 非样本本身导致的工具链异常

### 6.3 扩量门

只有在首轮 pair 满足以下条件后，才允许扩到第二组 lane：

- 两条 lane 都完成独立证据回收；
- 失败被明确归类，或通过结果被明确落盘；
- 未要求回滚 `Phase05` baseline；
- 未引入第二套 summary/report/promotion 口径。

## 7. 风险与取舍

### 7.1 为什么不是先跑更广的异质 pair

`badgeview-page + photo-view-component` 的覆盖更宽，但会把：

- `view-model-renderer`
- `controller-owned-state`
- `gesture-component`
- 样本域差异

同时引入首轮试点，导致问题分离难度更高。

### 7.2 为什么不是先修 RealMessageService

热区已经把 `RealMessageService.ets` control-only fresh repair 降为次级选项。当前最稀缺的不是又一轮 service repair，而是把 `Phase06 batch1` 从“prompt evidence ready”推进到“首轮 curator 方案已冻结”。

### 7.3 为什么不启用 AGENT TEAM

当前仍是设计任务，不存在必须并行推进的实现、验证、环境探测三条独立工作流。单 Agent 更利于保持口径收敛和 spec 一致性。
