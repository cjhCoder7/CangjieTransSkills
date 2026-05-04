# 2026-04-21 Phase07 M10 Telegram Active-Detail Same-Peer Draft Recovery Repeated Same-Peer Refresh Before First-Reopen Preserve Slice Freeze Draft

## Status

- freeze approved；本文件现为 `M9 landed` 之后当前批准的下一 bounded continuation slice 说明面。
- candidate step id：`phase07_m10_telegram_active_detail_same_peer_draft_recovery_repeated_same_peer_refresh_before_first_reopen_preserve_slice_frozen`
- current approved plan 已切到 `phase07_m10_telegram_active_detail_same_peer_draft_recovery_repeated_same_peer_refresh_before_first_reopen_preserve_slice_frozen`。
- `Phase07` 仍保持 `exploratory-only`，latest shared checkpoint 仍为 `P1-27`。
- 当前 canonical landed consume entry / `latest_report` / `raw_log_root` 仍维持在 `M9`。
- proof gate 仍关闭；本文件不授权实现、不授权测试、不授权 evidence bundle，也不授权 landed report。

## slice_name

- `M10 Telegram Active-Detail Same-Peer Draft Recovery Repeated Same-Peer Refresh Before First-Reopen Preserve Slice`

## Objective

在已 landed 的 `M9 Telegram Active-Detail Same-Peer Draft Recovery Refresh-Reopen Then Direct-Retarget Other-Peer Drop Slice` 之后，只冻结一个更窄、仍停留在 Telegram same-package refresh/draft direction 内的 sibling edge：当 active detail 持有未发送 draft、`backFromDetail()` 已武装 single-slot same-peer recovery slot、且用户仍停在 list route 时，若在任何 reopen 之前连续两次对同一条 recovery peer 执行 `refreshConversation(same peer, limit)`，则这两次 refresh 都只允许沿既有 same-peer refresh rail 更新 refreshed summary；draft 仍不得暴露在 list route surface，recovery slot 仍必须保持 single-slot、same-peer、short-lived，不得被重复 refresh 扩写成 duplicate slot、secondary persistence 或 per-peer persistence。随后首次 reopen 同一条 refreshed visible conversation 时，draft 仍应只恢复一次，并在这次 restore 后立即消费该唯一 slot。

## why_this_gap_after_M9

- `M9` 已经锁定 `same-peer refresh -> first same-peer reopen restore/consume -> exactly one direct retarget(other peer)` 的 post-recovery drop/no-leak/no-ghost-restore 边界，但它显式把 `repeated refresh` 保留为未冻结分支。
- 在 `M9` 明确延后的候选里，`repeated same-peer refresh before first reopen` 是更小、更独立的一条缺口，因为它只增加一个额外的 same-peer refresh hop，仍停留在 list-route refresh / draft-hidden / first-reopen consume 这一条既有 rail 内，不需要 reopening direct-retarget tail、back/reopen tail、或额外 peer target。
- 它比 `second direct retarget` 更小：后者会重新进入 detail-route retarget family，并引入第二次 ownership 切换与更宽的 route-tail 判定。
- 它比 `additional reopen-in-between permutation` 更独立：后者会把 proof 重心从 refresh/draft 模型拖向 broader back/reopen tail。
- 它比 `third-peer refresh` 或 broader mixed-refresh family 更窄：这两个方向都会扩大 peer cardinality 或 mixed ordering，而本候选只增加同一 peer 的第二次 refresh。

## In Scope

- `samples/telegram-ui-vertical-slice-001` 的 same-package app-shell / detail / tests
- 只围绕 `single-slot recovery -> same-peer refresh -> same-peer refresh -> first same-peer reopen restore/consume exactly once` 这一条最窄链路收口 freeze draft
- 当前 freeze-draft 说明面

## Out Of Scope

- `samples/phase07-shared-service-refresh-harness/**`
- `samples/real-message-service-cache-001/**`
- `P23`
- any other-peer refresh
- repeated other-peer refresh
- third-peer refresh
- any broader mixed-refresh family
- any direct retarget after recovery
- second direct retarget
- additional reopen-in-between permutation
- broader back/reopen tail expansion
- shared helper/API
- generic send abstraction
- broader UI redesign
- 完整 per-peer draft persistence rollout
- repo-level promotion

## done_when

- reviewer / executor 能基于本文件直接判断：
  - 该候选是否只是在 `M5` / `M9` 已冻结的 one-hop same-peer refresh preserve 边界上，再追加 exactly one same-peer refresh，而没有引入新的 route family 或新的 peer target
  - 该候选是否仍把 recovery model 限定为 single-slot、same-peer、short-lived，而不是 repeated-refresh driven persistence rollout
  - 未来若打开 proof gate，最小回归是否可以只围绕 repeated same-peer refresh 下的 draft-hidden、summary coherence、以及 first-reopen single-consume 来闭合
  - 文档是否没有把该候选写成 generic retarget family、broader mixed-refresh family、shared/helper、generic send、per-peer persistence、`P23`，或 repo-scope promotion

## proof

- 本轮只允许 freeze-stage proof；当前不授权实现、不授权测试、不授权 evidence bundle。
- 若 reviewer 后续明确批准该候选并打开 proof gate，最小 proof 仍只允许围绕 `samples/telegram-ui-vertical-slice-001` 的 same-package surface 展开：
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
- 若后续进入 proof gate，最小回归草案应优先围绕：
  - `appShellRecoverySlotShouldStayHiddenAcrossRepeatedSamePeerRefreshes`
  - `appShellRepeatedSamePeerRefreshBeforeFirstReopenShouldStillRestoreAndConsumeExactlyOnce`
  - `appShellRepeatedSamePeerRefreshWhileRecoveryArmedShouldKeepSummaryBoundedAndListComposerNoop`
- 在 reviewer 二次放行前，上述命令、回归名、evidence bundle 和 landed report 都只属于候选 proof 草案，不得提前执行或生成。

## minimal_write_set

- 当前定义回合的实际 write set 只包含本文件。
- 若 reviewer 后续批准 proof gate，最小允许 write set 仍应限制为：
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - 只有在回归明确暴露 same-package 缺口时，才允许触碰：
    - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
    - `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - 对应的 landed report 与 `artifacts/verification_contracts/...` evidence bundle

## risk

- 现有 production 行为有可能已经天然满足该 repeated same-peer refresh preserve 语义，因此这条候选未来仍可能闭合为 regression / spec / evidence-only slice，而不需要 production widening。
- 若 repeated refresh 的措辞不够严格，候选很容易滑向 repeated other-peer refresh、third-peer refresh、arbitrary mixed-refresh chain 或 per-peer persistence 叙事。
- 若未来 proof 额外引入 direct retarget、second reopen tail 或 alternating back/reopen 断言，scope 会迅速膨胀，不再是 `M9` 之后最小、最独立的 next bounded continuation slice。

## Why This Candidate Before Other Deferred M9 Gaps

- not chosen first：`second direct retarget after recovered-draft drop`
  - 会把当前候选从 refresh/draft direction 拉回 broader detail-route retarget tail，耦合第二次 ownership 切换与更宽的 retarget family 判定。
- not chosen first：`additional reopen-in-between permutation`
  - 会把当前候选从 repeated refresh preserve 问题拉向 broader back/reopen tail，独立性更差，且与 `M9` 已用过的一跳 later reopen 断言发生重叠。
- not chosen first：`third-peer refresh` 或 broader mixed-refresh family
  - 会直接扩大 peer target set 或 mixed ordering，明显宽于“同一 peer 再 refresh 一次”这一条最窄增量。
- selected first：
  - 只新增一个 same-peer refresh hop；
  - 不引入新 peer；
  - 不引入 direct retarget；
  - 不引入 additional reopen-in-between；
  - 仍完全停留在 same-package refresh/draft rail。
