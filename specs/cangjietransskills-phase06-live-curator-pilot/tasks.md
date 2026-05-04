# Implementation Plan

- [x] 1. 冻结首轮试点范围
  - 在执行前继续以 [requirements.md](./requirements.md) 与 [design.md](./design.md) 作为当前计划边界。
  - 明确主选组合为 `markdown-index-page + markdown-heading-component`，备选组合为 `badgeview-page + photo-view-component`。
  - 明确 `ledger-top-bar-component` 不进入首轮主选。
  - _Requirement: 1, 2, 6_

- [x] 2. 为主选组合整理执行包
  - 从 [docs/manifests/phase06_ui_prompt_pilot_batch1.json](../../docs/manifests/phase06_ui_prompt_pilot_batch1.json) 中提取主选两条 lane 的 `src_root`、`target_file`、`pipeline_command`、`artifact_root`、prompt dump 路径和 few-shot 入口。
  - 为每条 lane 准备一页执行清单，明确命令、预期产物路径、失败分类入口和回写位置。
  - 当前执行清单：
    - [runbooks/markdown-index-page.md](./runbooks/markdown-index-page.md)
    - [runbooks/markdown-heading-component.md](./runbooks/markdown-heading-component.md)
  - 保证执行包直接消费 batch1 manifest，而不是退回 file-level workset 重新人肉挑选。
  - _Requirement: 3, 5_

- [x] 3. 冻结执行前护栏
  - 在真正实施前再次确认 `Phase05` baseline 入口和证据路径不变。
  - 明确本轮不插入 `RealMessageService.ets` control-only fresh repair。
  - 明确本轮不创建新的 `summary/report/promotion` 体系。
  - 护栏已落入：
    - [runbooks/markdown-index-page.md](./runbooks/markdown-index-page.md)
    - [runbooks/markdown-heading-component.md](./runbooks/markdown-heading-component.md)
  - _Requirement: 1, 4, 6_

- [x] 4. 定义首轮 live curator 的停机条件
  - 把“基础设施噪声、prompt 失配、static wall、新 reviewer 墙、工具链异常”列为优先分类项。
  - 约定首个 blocker 未归类前不扩量到备选组合。
  - 约定任何需要回滚 `Phase05` baseline 的情况都直接暂停试点。
  - 停机条件已落入：
    - [runbooks/markdown-index-page.md](./runbooks/markdown-index-page.md)
    - [runbooks/markdown-heading-component.md](./runbooks/markdown-heading-component.md)
  - _Requirement: 4, 5_

- [x] 5. 等待实施批准
  - 用户已明确批准进入执行阶段，并已使用用户批准共享凭证点火 `phase06-ui-p0-markdown-heading-component`。
  - 实际执行顺序已从热区最新 SSOT 调整为先消费已知主战场 `markdown-heading-component`，不再沿用旧的 `page -> component` 固定顺序。
  - `20260409-phase06-ui-batch1-live-curator-r4` 已在 `2` 轮内取得 `final_status=passed` + `verify_status=passed` 证据；下一步再决定是否回到 `markdown-index-page` 或扩展到其它 batch1 lane。
  - _Requirement: 4, 5_
