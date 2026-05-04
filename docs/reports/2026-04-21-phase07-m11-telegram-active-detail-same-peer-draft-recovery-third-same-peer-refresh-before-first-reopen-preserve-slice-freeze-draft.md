# 2026-04-21 Phase07 M11 Telegram Active-Detail Same-Peer Draft Recovery Third Same-Peer Refresh Before First-Reopen Preserve Slice Freeze Draft

## Status

- definition-only freeze draft；本文件只定义一个 post-`M10` bounded continuation candidate，不授权 proof、不授权实现、不授权测试、不授权 evidence bundle，也不授权 landed truth sync。
- provisional candidate step id：`phase07_m11_telegram_active_detail_same_peer_draft_recovery_third_same_peer_refresh_before_first_reopen_preserve_slice_frozen`
- 当前 live truth surfaces 仍保持 `M10 landed / latest_report = M10 / raw_log_root = M10 proof-round bundle`；本文件不改写 `AGENTS.md`、`current_committed_plan`、`current_state`、`INDEX`、`current_task_handoff`、`runtime_contract` 或 `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`。
- `Phase07` 仍保持 `exploratory-only`，latest shared checkpoint 仍为 `P1-27`。

## slice_name

- `M11 Telegram Active-Detail Same-Peer Draft Recovery Third Same-Peer Refresh Before First-Reopen Preserve Slice`
- 命名合理性：
  - `M11` 只作为 `M10 landed` 之后、同一 Telegram same-package refresh/draft rail 上的单一 next-candidate 序号，不暗示已批准、已 proof 或已 landed。
  - 名称使用 `Third Same-Peer Refresh Before First-Reopen Preserve`，而不再泛写为 `Repeated Same-Peer Refresh`，目的是把 scope 锁死为“在 `M10` 的 exact two-refresh chain 上，再追加 exactly one same-peer refresh”，避免滑向 arbitrary repeated-refresh family。

## objective

在已 landed 的 `M10 Telegram Active-Detail Same-Peer Draft Recovery Repeated Same-Peer Refresh Before First-Reopen Preserve Slice` 之后，只冻结一个更窄、仍严格停留在 Telegram same-package refresh/draft direction 内的 sibling edge：当 active detail 持有未发送 draft、`backFromDetail()` 已武装 single-slot same-peer recovery slot、且用户仍停在 list route 时，若在任何 reopen 之前对同一条 recovery peer 连续执行三次 `refreshConversation(same peer, limit)`，则这三次 refresh 都只允许沿既有 same-peer refresh rail 更新 refreshed summary；draft 仍不得暴露在 list route surface，recovery slot 仍必须保持 single-slot、same-peer、short-lived，不得被第三次 refresh 扩写成 duplicate slot、secondary persistence 或 per-peer persistence。随后首次 reopen 同一条 refreshed visible conversation 时，draft 仍应只恢复一次，并在这次 restore 后立即消费该唯一 slot。

## why_this_gap_after_M10

- `M10` 已经把 exact `same-peer refresh -> same-peer refresh -> first same-peer reopen restore/consume exactly once` 这条 two-refresh preserve chain landed，但它只闭合到总计两次 same-peer refresh before first reopen。
- 在不触碰 other-peer refresh、retarget tail、additional reopen-in-between、shared/helper、generic send、per-peer persistence、`P23` 或 repo-level promotion 的前提下，post-`M10` 最小且仍同 rail 的未闭合缺口，就是再追加 exactly one same-peer refresh，使链路变成 total three same-peer refreshes before first reopen。
- 这条缺口仍停留在 list-route refresh / draft-hidden / first-reopen single-consume 这一条既有 same-package rail 内，不需要引入新 peer、detail-route ownership 切换、额外 reopen tail，或 broader family 归纳。
- 即使现有 production 行为未来可能天然满足这条 edge，它的 authority / proof 仍未闭合；因此它可以作为 post-`M10` 的 definition-only 候选，而不预设实现 shortfall。

## why_smaller_than_other_candidates

- 它比 arbitrary repeated-refresh family 更小：这里只冻结“第三次 same-peer refresh”这一条精确 sibling edge，而不是把任意次数 repeated refresh 全部提升为一个 family contract。
- 它比 other-peer refresh、repeated other-peer refresh、third-peer refresh 更独立：这些方向都会引入新的 peer cardinality、mixed ordering 或 drop/no-restore 语义；当前候选只增加同一 recovery peer 的一个额外 refresh hop。
- 它比 direct-retarget tail 更小：任何 direct retarget 都会把问题拉回 detail-route ownership 切换与 retarget family，而当前候选全程不离开 refresh/draft rail。
- 它比 additional reopen-in-between 更独立：后者会把定义重心从 refresh preserve 拖向 broader back/reopen tail；当前候选在 first reopen 之前不引入任何新的 reopen permutation。
- 它比 shared/helper、generic send、per-peer persistence 更局部：这些候选会扩 shared abstraction 或 hidden state model；当前候选仍只讨论同一个 single-slot same-peer recovery model 在第三次 refresh 下是否继续保持不变。

## in_scope

- `samples/telegram-ui-vertical-slice-001` 的 same-package app-shell / detail / tests 语义
- 只围绕 `same-peer refresh -> same-peer refresh -> same-peer refresh -> first same-peer reopen restore/consume exactly once` 这一条最窄链路做 definition freeze
- `single-slot`、`same-peer`、`short-lived` recovery model 在第三次 same-peer refresh 下的继续保持
- draft-hidden、summary coherence、bounded history、以及 list-route composer strict pure no-op 在该 exact chain 下的继续保持
- 当前 freeze-draft 说明面

## out_of_scope

- `samples/phase07-shared-service-refresh-harness/**`
- `samples/real-message-service-cache-001/**`
- `P23`
- arbitrary repeated-refresh family beyond the exact third same-peer refresh
- any other-peer refresh
- repeated other-peer refresh
- third-peer refresh
- any direct retarget tail
- second direct retarget
- additional reopen-in-between permutation
- broader back/reopen tail expansion
- broader mixed-refresh family
- shared helper/API
- generic send abstraction
- broader UI redesign
- 完整 per-peer draft persistence rollout
- repo-level promotion

## done_when

- reviewer / executor 能基于本文件直接判断：
  - 该候选是否只是在 `M10` 的 exact two-refresh preserve chain 上，再追加 exactly one same-peer refresh，而没有引入新 peer、新 route family 或新 tail
  - 该候选是否仍把 recovery model 限定为 single-slot、same-peer、short-lived，而不是 third-refresh driven persistence rollout
  - 该候选是否明确只冻结 total three same-peer refreshes before first reopen，而不是 arbitrary repeated-refresh family
  - 若未来打开 proof gate，最小回归是否仍可以只围绕 draft-hidden、summary coherence、bounded list-route no-op，以及 first-reopen single-consume 来闭合
  - 文档是否没有把该候选写成 other-peer refresh、repeated other-peer refresh、third-peer refresh、direct-retarget tail、additional reopen-in-between、shared/helper、generic send、per-peer persistence、`P23`，或 repo-level promotion

## proof_plan

- 本轮只允许 definition-only freeze；当前不授权 proof、不授权测试、不授权 artifacts。
- 若 reviewer 后续明确批准该候选并打开 proof gate，最小 proof 仍应只围绕 `samples/telegram-ui-vertical-slice-001` 的 same-package surface 展开。
- 未来 proof round 的最小回归草案应优先围绕：
  - `appShellRecoverySlotShouldStayHiddenAcrossThirdSamePeerRefreshBeforeFirstReopen`
  - `appShellThirdSamePeerRefreshBeforeFirstReopenShouldStillRestoreAndConsumeExactlyOnce`
  - `appShellThirdSamePeerRefreshWhileRecoveryArmedShouldKeepSummaryBoundedAndListComposerNoop`
- 未来 canonical gates 仍应优先保持为：
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
- 在 reviewer 后续明示 proof gate 之前，上述回归名与命令都只属于 proof 草案，不得提前执行、不得提前生成 evidence bundle、也不得提前切 landed truth。

## minimal_write_set

- 当前定义回合的实际 write set 只包含本文件。
- 若 reviewer 后续批准 proof gate，最小允许 write set 应先限制为：
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - 只有在回归明确暴露 same-package 缺口时，才允许触碰：
    - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
    - `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
- 在 proof 未闭合之前，不预授权 plan/state/live truth surface 改写，也不预授权 `latest_report` / `raw_log_root` 切换。

## risk

- 现有 production 行为有可能已经天然满足这条 exact third-refresh preserve 语义，因此未来 proof 仍可能闭合为 regression / spec / report-only slice，而不需要 production widening；但在 proof 真正闭合之前，不能把这种可能性写成已 landed 事实。
- 若 `third same-peer refresh` 的措辞不够严格，候选很容易滑向 arbitrary repeated-refresh family，而不再是 post-`M10` 单一、最小的 bounded continuation slice。
- 若未来 proof 额外引入 other-peer refresh、direct retarget、second direct retarget、additional reopen-in-between 或 broader back/reopen tail 断言，scope 会迅速膨胀，不再保持独立。
- 若 `M11` 序号没有与“definition-only / provisional candidate”反复绑定，后续消费者可能误读为当前 approved step；因此本文件必须持续和 `M10 landed` live truth surfaces 分层消费。
