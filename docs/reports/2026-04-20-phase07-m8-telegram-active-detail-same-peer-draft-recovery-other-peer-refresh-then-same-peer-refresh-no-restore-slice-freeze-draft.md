# 2026-04-20 Phase07 M8 Telegram Active-Detail Same-Peer Draft Recovery Other-Peer Refresh Then Same-Peer Refresh No-Restore Slice Freeze Draft

## Status

- freeze drafted；本文件当前只作为 `M7 landed` 之后候选的下一 bounded continuation slice 说明面，不改写当前 approved plan。
- candidate step id：`phase07_m8_telegram_active_detail_same_peer_draft_recovery_other_peer_refresh_then_same_peer_refresh_no_restore_slice_frozen`
- current approved plan 仍停在 `phase07_m7_telegram_active_detail_same_peer_draft_recovery_same_peer_refresh_then_other_peer_drop_slice_landed`。
- 本文件不授权实现、不授权测试、不授权 evidence bundle、不授权 landed report，也不授权 live truth sync。

## Objective

在已 landed 的 `M7 Telegram Active-Detail Same-Peer Draft Recovery Same-Peer Refresh Then Other-Peer Drop Slice` 之上，只冻结一个更窄的 reverse-order sibling edge：当 active detail 持有未发送 draft、`backFromDetail()` 已武装 same-peer recovery slot、且用户仍停在 list route 时，若先对另一条 visible peer 执行一次 `refreshConversation(other peer, limit)`，该 refresh 必须沿既有 `M6` invalidation rail 立即使 old recovery candidate 失效并丢弃；随后即使在任何 reopen 之前再对原 recovery peer 执行一次 `refreshConversation(same peer, limit)`，该 later same-peer refresh 也不得重新武装、恢复、重建或间接 resurrect 已被丢弃的 old draft。与此同时，list-route 期间 draft 仍不得暴露，list-route composer API 仍必须 strict pure no-op。

## Why This Is The Next Narrowest Sibling Edge

- 它只交换 `M7` 已冻结/已落地二步 mixed-refresh 组合边的先后顺序：`same-peer -> other-peer` 变成 `other-peer -> same-peer`。
- 它仍停留在 same-package、single-slot、list-route、exactly two refresh hops 的 mixed-refresh rail 内，没有引入新的对象模型或新的 route family。
- 它直接复用 `M6` 已 landed 的核心 drop 语义，再验证 drop 之后的 one-hop same-peer refresh 不得把已失效的 slot 重新变回可恢复状态，因此比 repeated refresh、reopen-in-between、third-peer refresh 都更连续。

## In Scope

- `samples/telegram-ui-vertical-slice-001` 的 same-package app-shell / detail / tests
- 当前 `M6` / `M7` 已 landed sibling edge 的 reverse-order continuation 说明
- 只围绕 `single-slot recovery -> list-route other-peer drop -> later list-route same-peer no-restore` 这一条最窄组合边收口 freeze draft

## Out Of Scope

- `samples/phase07-shared-service-refresh-harness/**`
- `samples/real-message-service-cache-001/**`
- `P23`
- reopen 插在两次 refresh 之间
- repeated other-peer refresh
- repeated same-peer refresh
- third-peer refresh
- arbitrary mixed refresh chain
- same-peer / other-peer / same-peer 三步或更多步组合
- other-peer refresh 后 direct retarget
- shared helper/API
- generic send abstraction
- broader UI redesign
- 完整 per-peer draft persistence rollout

## Boundary Difference Versus M6 / M7

- 与 `M6` 的边界：
  - `M6` 只锁定 `back -> other-peer refresh -> drop instead of restore`
  - `M8` 复用 `M6` 的 first-step drop，但只新增“drop 之后紧跟 one same-peer refresh 仍不得 resurrect old draft”这一半
- 与 `M7` 的边界：
  - `M7` 锁定的是 `back -> same-peer refresh preserves slot -> other-peer refresh drops slot -> later reopen no-restore`
  - `M8` 只交换前两步顺序，验证 `back -> other-peer refresh drops slot -> same-peer refresh still no-restore`
- 与 broader mixed-refresh family 的边界：
  - `M8` 只验证严格顺序的 `other-peer refresh -> same-peer refresh`
  - `M8` 不验证 repeated refresh、reopen 插在中间、third-peer refresh、reverse-back-to-M7 alternating chain，或任何 arbitrary mixed sequence

## Requirements Freeze

- `M4` / `M5` / `M6` / `M7` slot lifecycle stays frozen：
  - recovery slot 仍是 single-slot、same-peer、short-lived
  - slot 仍只允许在 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 返回 list route 时写入
  - `M6` 的 `other-peer refresh drops slot` 与 `M7` 的 `same-peer preserve then other-peer drop` 既有 landed 语义都保持不变
- 唯一新增 candidate edge：
  - `active detail unsent draft -> backFromDetail() arms slot -> list-route refreshConversation(other peer, limit) drops slot -> list-route refreshConversation(same recovery peer, limit) still no-restore`
- step-1 other-peer refresh stays drop-first：
  - refresh 可以沿既有 other-peer refresh rail 更新 refreshed other-peer summary
  - refresh 不得暴露 draft
  - refresh 不得 restore slot
  - refresh 必须使 armed slot 立即失效并丢弃
- step-2 same-peer refresh becomes no-resurrect boundary：
  - refresh 可以沿既有 same-peer refresh rail 更新 refreshed same-peer summary
  - refresh 不得重新创建、恢复、消费、清空或改写已被丢弃的 old slot
  - refresh 不得把 old draft 重新变成可 later reopen 的 recovery candidate
- later reopen stays no-restore：
  - 第二步发生后，later reopen 原 recovery peer 或 step-1 refreshed other peer 时都不得恢复 old draft
  - later reopen 后 detail thread ownership / bounded history / current page / summary coherence 继续沿用既有 refresh / reopen rail
- list-route composer API stays frozen：
  - `updateDetailDraft(...)` / `sendDetailDraft()` 在 list route 下仍必须 strict pure no-op
  - list-route composer API remains a pure no-op and must not create, restore, consume, leak, or clear recovery state
  - 它也不得创建 recovery model 之外的 secondary hidden fallback state

## Design Freeze

- 最小设计继续复用 `M6` 的 first-step other-peer drop rail 和 `M7` 已确认的 single-slot mixed-refresh framing，不引入新的 slot family、per-peer draft map、shared helper 或 generic send layer。
- `M8` 只允许 one-hop list-route other-peer drop，再紧跟 one-hop list-route same-peer refresh no-resurrect，不扩写其他 reverse-order mixed-refresh family。
- 最小 transition 只冻结五条：
  - `backFromDetail()` arm slot：保持 `M4` / `M5` / `M6` / `M7` 不变
  - step-1 other-peer refresh while armed：更新 refreshed other-peer summary，但不暴露 draft、不 restore slot，并立即 drop old recovery candidate
  - step-2 same-peer refresh after drop：更新 refreshed same-peer summary，但不得重建 recovery candidate、不得 restore old draft
  - later reopen after step-2 no-resurrect：later reopen 不得 restore old draft
  - list-route composer API：继续 pure no-op，不得对 recovery state 或任何 secondary hidden state 产生副作用

## Candidate Proof

- 当前只允许 freeze-stage 证据：
  - `M6` 已 landed 证明 first-step other-peer refresh 会 drop armed slot
  - `M7` 已 landed 证明 mixed-refresh rail 可以 bounded 地承载 one-hop sibling composition，而不需要更宽 refresh family
- 基于当前 landed 语义，可作出的 freeze-stage 判断：
  - 现有 `M6/M7` behavior 大概率已经覆盖该 reverse-order sibling edge，因为一旦 first-step other-peer refresh 已按 `M6` rail 丢弃 slot，later same-peer refresh 理论上不应再有可 preserve / restore 的 recovery candidate
  - 但这只是 proposal-stage inference，不等于 landed 事实，不得据此自行补测试、跑 gate、生成 evidence bundle、或切任何 pointer
- 若未来 reviewer 打开 proof gate，最小回归草案可优先围绕：
  - `appShellRecoverySlotShouldDropBeforeSamePeerRefreshCanRearmOrRestore`
  - `appShellDroppedRecoveryAfterReverseOrderMixedRefreshShouldNotRestoreOnAnyLaterReopen`
  - `appShellReverseOrderMixedRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndListComposerNoop`

## Done When

- reviewer / executor 能基于本文件直接判断：
  - `other-peer refresh -> same-peer refresh` 是否确实是 `M7` 之后最窄、最连续的 next sibling edge
  - `M8` 是否只是在 `M6` direct-drop rail 与 `M7` mixed-refresh framing 之间做一次 reverse-order 组合，而不是扩大 refresh family
  - “现有行为大概率已覆盖”是否被严格限定为 freeze-stage inference，而非 landed claim
  - 文档是否没有把 `M8` 写成 repeated refresh、reopen-in-between、third-peer refresh、shared continuation、generic send expansion，或 broader mixed-refresh family

## Proof

- 本轮只完成 candidate freeze draft，不授权实现、测试、evidence bundle、landed report 或 live truth sync。
- 在 reviewer 明确把 `M8` 提升为当前批准的下一 bounded continuation slice并打开 proof gate 前，不允许执行：
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
- 在 reviewer 明确放行前，不允许生成：
  - landed report
  - `artifacts/verification_contracts/...` evidence bundle
  - 任何 pointer / state / current truth surface 改写

## Notes For Reviewer

- 这不是对 `M7` 的返修判决；它是 `M7 landed` 之后候选的下一 bounded continuation slice。
- 该切片故意不把“任意 reverse-order mixed-refresh chain 都应 no-restore”写成目标；它只验证 list-route、严格顺序、single other-peer drop followed by single same-peer refresh no-resurrect 这一条最窄 sibling edge。
- 若 reviewer 认为该 edge 仍过宽，应优先裁掉 later reopen 目标集合，而不是引入 repeated refresh、third-peer、或更大的 shared/per-peer 设计。
