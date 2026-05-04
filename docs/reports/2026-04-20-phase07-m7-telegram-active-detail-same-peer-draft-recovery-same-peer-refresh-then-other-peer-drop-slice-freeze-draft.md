# 2026-04-20 Phase07 M7 Telegram Active-Detail Same-Peer Draft Recovery Same-Peer Refresh Then Other-Peer Drop Slice Freeze Draft

## Status

- freeze drafted；本文件当前只作为 `M6` 之后候选的下一 bounded continuation slice 说明面，不改写当前 approved plan。
- candidate step id：`phase07_m7_telegram_active_detail_same_peer_draft_recovery_same_peer_refresh_then_other_peer_drop_slice_frozen`
- current approved plan 仍停在 `phase07_m6_telegram_active_detail_same_peer_draft_recovery_other_peer_refresh_drop_boundary_slice_landed`。
- proof gate 仍关闭；本文件不授权实现、测试、evidence bundle、landed report 或 live truth sync。

## Objective

在已 landed 的 `M6 Telegram Active-Detail Same-Peer Draft Recovery Other-Peer Refresh Drop Boundary Slice` 之上，只冻结一个更窄的二步 list-route mixed-refresh 候选：当 active detail 持有未发送 draft、`backFromDetail()` 已武装 same-peer recovery slot、且用户仍停在 list route 时，若先对同一条 peer 执行一次 `refreshConversation(same peer, limit)` 保持 slot，再在任何 reopen 之前对另一条 visible peer 执行一次 `refreshConversation(other peer, limit)`，则第二步 other-peer refresh 必须把此前仍存活的 old recovery candidate 视为失效并丢弃；此后任何 later reopen 都不得恢复 old draft。与此同时，list-route 期间 draft 仍不得暴露，list-route composer API 仍必须 strict pure no-op。

## In Scope

- `samples/telegram-ui-vertical-slice-001` 的 same-package app-shell / detail / tests
- `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md` 中与本 candidate freeze 对应的冻结定义
- 当前 `M7` candidate freeze 说明面

## Out Of Scope

- `samples/phase07-shared-service-refresh-harness/**`
- `samples/real-message-service-cache-001/**`
- `P23`
- arbitrary mixed refresh chain
- reverse-order mixed refresh
- reopen 插在两次 refresh 之间
- repeated same-peer refresh
- repeated other-peer refresh
- third-peer refresh
- other-peer refresh 后 direct retarget
- shared helper/API
- generic send abstraction
- broader UI redesign
- 完整 per-peer draft persistence rollout

## Requirements Freeze

- `M4` / `M5` / `M6` slot lifecycle stays frozen：
  - recovery slot 仍是 single-slot、same-peer、short-lived
  - slot 仍只允许在 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 返回 list route 时写入
  - same-peer refresh preserve 与 other-peer refresh drop 的既有 landed 语义都保持不变
- 唯一新增 candidate edge：
  - `active detail unsent draft -> backFromDetail() arms slot -> list-route refreshConversation(same peer, limit) preserves slot -> list-route refreshConversation(other peer, limit) drops slot`
- step-1 same-peer refresh stays preserve-only：
  - refresh 可以沿既有 same-peer refresh rail 更新 refreshed same-peer summary
  - refresh 不得暴露 draft
  - refresh 不得 restore slot
  - refresh 不得创建、恢复、消费、清空或改写 armed slot
  - refresh 必须保持 armed slot 继续存活
- step-2 other-peer refresh becomes the drop boundary：
  - refresh 可以沿既有 other-peer refresh rail 更新 refreshed other-peer summary
  - refresh 不得暴露 draft
  - refresh 不得 restore slot
  - refresh 必须使 step-1 之后仍存活的 old recovery candidate 失效并立即丢弃
- later reopen stays no-restore：
  - 第二步发生后，later reopen 不得恢复 old draft
  - later reopen 后 detail thread ownership / bounded history / current page / summary coherence 继续沿用既有 refresh / reopen rail
- list-route composer API stays frozen：
  - `updateDetailDraft(...)` / `sendDetailDraft()` 在 list route 下仍必须 strict pure no-op
  - list-route composer API remains a pure no-op and must not create, restore, consume, leak, or clear recovery state
  - 它也不得创建 recovery model 之外的 secondary hidden fallback state

## Design Freeze

- 最小设计继续复用 `M5` 的 same-peer preserve rail 和 `M6` 的 other-peer drop rail，不引入新的 slot family、per-peer draft map、shared helper 或 generic send layer。
- `M7` 只允许 one-hop 组合一次 list-route same-peer preserve，再紧跟 one-hop list-route other-peer drop，不扩写其他 mixed-refresh family。
- 最小 transition 只冻结五条：
  - `backFromDetail()` arm slot：保持 `M4` / `M5` / `M6` 不变
  - step-1 same-peer refresh while armed：更新 refreshed same-peer summary，但不暴露 draft、不 restore slot，并保持 armed slot 继续存活
  - step-2 other-peer refresh before any reopen：更新 refreshed other-peer summary，但不暴露 draft、不 restore slot，并立即 drop 旧 recovery candidate
  - later reopen after step-2 drop：later reopen 不得 restore old draft
  - list-route composer API：继续 pure no-op，不得对 recovery state 或任何 secondary hidden state 产生副作用

## Boundary Freeze

- 与 `M5` 的边界：
  - `M5` 只锁定 `back -> same-peer refresh -> first same-peer reopen restore`
  - `M7` 只复用其中“same-peer refresh preserves slot”这一半，不重写 `M5` 的 first reopen restore edge
- 与 `M6` 的边界：
  - `M6` 只锁定 `back -> other-peer refresh -> drop instead of restore`
  - `M7` 只复用其中“other-peer refresh drops slot”这一半，并把它严格放在 `M5` preserve 之后
- 与 broader mixed-refresh family 的边界：
  - `M7` 只验证严格顺序的 `same-peer refresh -> other-peer refresh`
  - `M7` 不验证 reverse order、reopen 插在中间、repeated refresh、third-peer refresh、other-peer refresh 后 direct retarget，或任何 arbitrary mixed chain

## Tasks Freeze

- 在 `requirements.md` 新增 `M7-REQ-*` 与 `M7-AC-*`，明确当前只处于 candidate freeze，proof gate 仍未授权。
- 在 `design.md` 新增 `M7` design candidate freeze 小节，只记录最小状态模型与 transition，不扩成 broader mixed-refresh family。
- 在 `tasks.md` 把对应项收口为已冻结的 `[x] M7` 候选任务，限定未来 write set 仍只允许：
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- 在 `tasks.md` 明确 2-3 条最小回归草案与 out-of-scope 分支。
- 当前只把该 slice 收口为 candidate freeze；proof gate 继续关闭，current approved plan 仍停在 `M6 landed`。

## Proposed Minimal Regression Locks

- `appShellRecoverySlotShouldSurviveSamePeerRefreshThenDropAfterOtherPeerRefreshBeforeReopen`
- `appShellDroppedRecoveryAfterMixedRefreshShouldNotRestoreOnAnyLaterReopen`
- `appShellMixedRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndListComposerNoop`

## Done When

- reviewer / executor 能基于本文件与 `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md` 直接判断：
  - 该 candidate frozen slice 是否仍然足够窄
  - `M7` 是否只是在 `M5` preserve edge 与 `M6` drop edge 之间做一次严格顺序的二步组合
  - 三条最小回归草案是否足够支撑未来进入实现
  - 文档是否没有把 `M7` 写成 arbitrary mixed chain、shared continuation、generic send expansion、或 broader refresh family

## Proof Gate

- 本轮只完成 candidate freeze bundle 语义收口，不授权实现、测试、evidence bundle 或 live truth sync。
- 在 reviewer 明确把 `M7` 提升为当前批准的下一 bounded continuation slice并打开 proof gate 前，不允许执行：
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
- 在 reviewer 明确放行前，不允许生成：
  - landed report
  - `artifacts/verification_contracts/...` evidence bundle

## Notes For Reviewer

- 这不是对 `M6` 的返修判决；它是 `M6 landed` 之后候选的下一 bounded continuation slice。
- 该切片故意不把“任意 mixed-refresh chain 都应 drop old draft”写成目标；它只验证 list-route、严格顺序、single same-peer preserve followed by single other-peer drop 这一条最窄组合边。
- 若 reviewer 认为该 edge 仍过宽，应优先裁掉 later reopen 验证集合或第二步 refresh 目标集合，而不是引入更大的 shared/per-peer 设计。
