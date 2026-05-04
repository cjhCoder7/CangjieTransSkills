# 2026-04-20 Phase07 M6 Telegram Active-Detail Same-Peer Draft Recovery Other-Peer Refresh Drop Boundary Slice Freeze Draft

## Status

- freeze approved；本文件现为 `M5` 之后当前批准的下一 bounded continuation slice 说明面。
- current approved plan 已切到 `phase07_m6_telegram_active_detail_same_peer_draft_recovery_other_peer_refresh_drop_boundary_slice_frozen`。
- proof gate 仍关闭；本文件仍不授权实现、测试、evidence bundle 或 landed report，但已允许最小 live truth sync 把当前步骤收口为 `frozen but unimplemented` state surfaces。

## Objective

在已 landed 的 `M5 Telegram Active-Detail Same-Peer Draft Recovery Refresh-Before-Reopen Coherence Slice` 之上，只冻结一个更窄的 other-peer-refresh drop-boundary sibling edge：当 active detail 持有未发送 draft、`backFromDetail()` 已武装 same-peer recovery slot、且用户仍停在 list route 时，若先对另一条 visible peer 执行 `refreshConversation(peer, limit)`，则该 refresh 仍只允许沿既有 refresh rail 更新 refreshed other-peer summary，但它必须把旧 recovery candidate 视为失效并丢弃；随后无论 reopen 原 peer 还是 reopen refreshed other peer，old draft 都不得恢复。与此同时，list-route 期间 draft 仍不得暴露，list-route composer API 仍必须 strict pure no-op。

## In Scope

- `samples/telegram-ui-vertical-slice-001` 的 same-package app-shell / detail / tests
- `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md` 中与本 frozen slice 对应的冻结定义
- 当前已批准的 freeze 说明面

## Out Of Scope

- `samples/phase07-shared-service-refresh-harness/**`
- `samples/real-message-service-cache-001/**`
- `P23`
- multiple refresh chain
- other-peer refresh 后 direct retarget
- same-peer refresh 与 other-peer refresh 混合序列
- any broader refresh permutation
- shared helper/API
- generic send abstraction
- broader UI redesign
- 完整 per-peer draft persistence rollout

## Requirements Freeze

- `M4` / `M5` slot lifecycle stays frozen：
  - recovery slot 仍是 single-slot、same-peer、short-lived
  - slot 仍只允许在 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 返回 list route 时写入
  - slot 仍只允许在 first same-peer reopen 时 restore 并立即消费
- 唯一新增 sibling edge：
  - `active detail unsent draft -> backFromDetail() arms slot -> list-route refreshConversation(other visible peer, limit)`
- list-route other-peer refresh becomes a drop boundary：
  - refresh 可以沿既有 refresh rail 更新 refreshed other-peer summary
  - refresh 不得暴露 draft
  - refresh 不得 restore slot
  - refresh 必须使旧 recovery candidate 失效并立即丢弃 armed slot
- reopen after invalidation stays no-restore：
  - other-peer refresh 之后 reopen 原 peer 不得恢复 old draft
  - other-peer refresh 之后 reopen refreshed other peer 也不得恢复 old draft
  - reopen 后 detail thread ownership / bounded history / current page / summary coherence 继续沿用既有 refresh / reopen rail
- list-route composer API stays frozen：
  - `updateDetailDraft(...)` / `sendDetailDraft()` 在 list route 下仍必须 strict pure no-op
  - list-route composer API remains a pure no-op and must not create, restore, consume, leak, or clear recovery state
  - 它也不得创建 recovery model 之外的 secondary hidden fallback state

## Design Freeze

- 最小设计继续复用 `M4` / `M5` 的 single-slot recovery state 和 `P1-11` / `P1-15` 的 refresh / reopen coherence rail，不引入新的 slot family、per-peer draft map、shared helper 或 generic send layer。
- `M6` 只允许 one-hop 插入一次 list-route other-peer refresh invalidation，不扩写其他 refresh family。
- 最小 transition 只冻结四条：
  - `backFromDetail()` arm slot：保持 `M4` / `M5` 不变
  - list-route other-peer refresh while armed：更新 refreshed other-peer summary，但不暴露 draft、不 restore slot，并立即 drop 旧 recovery candidate
  - reopen after invalidation：reopen 原 peer 或 refreshed other peer 都不得 restore old draft
  - list-route composer API：继续 pure no-op，不得对 recovery state 或任何 secondary hidden state 产生副作用

## Boundary Freeze

- 与 `M5` 的边界：
  - `M5` 只锁定 `back -> same-peer refresh -> first same-peer reopen restore`
  - `M6` 只在 sibling 的 other-peer refresh 分支上冻结“drop instead of restore”
  - `M6` 不重写 `M5` 的 same-peer survive edge
- 与 `P1-11` 的边界：
  - `P1-11` 锁定的是 list-route `back -> refresh -> reopen refreshed target` 的 summary / detail coherence
  - `M6` 只在这个 rail 上增加“armed same-peer recovery slot 在 other-peer refresh 后必须失效”的语义
- 与 `P1-15` 的边界：
  - `P1-15` 锁定的是 active-detail target `refresh -> back -> reopen same refreshed target`
  - `M6` 不从 detail 内 refresh 起步，而是从 `M4` / `M5` 已经 back 到 list 且 slot 已 armed 的状态起步

## Tasks Freeze

- 在 `requirements.md` 新增 `M6-REQ-*` 与 `M6-AC-*`，明确 proof gate 仍未授权。
- 在 `design.md` 新增 `M6` design freeze 小节，只记录最小状态模型与 transition，不扩成 broader refresh family。
- 在 `tasks.md` 把对应项收口为已冻结的 `[x] M6` 任务，限定未来 write set 仍只允许：
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- 在 `tasks.md` 明确三条最小回归草案与 out-of-scope 分支。
- 当前只把该 slice 收口为已冻结但未实现的下一 continuation slice；proof gate 继续关闭。

## Proposed Minimal Regression Locks

- `appShellRecoverySlotShouldDropAfterOtherPeerRefreshBeforeReopen`
- `appShellDroppedRecoveryAfterOtherPeerRefreshShouldNotRestoreOnOriginalReopen`
- `appShellOtherPeerRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndListComposerNoop`

## Done When

- reviewer / executor 能基于本文件与 `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md` 直接判断：
  - 该 frozen slice 是否仍然足够窄
  - `M6` 是否只是在 `M5` 的 armed-slot refresh family 中补一条 other-peer refresh drop boundary
  - 三条最小回归草案是否足够支撑进入实现
  - 文档是否没有把 `M6` 写成 per-peer persistence、shared continuation、generic send expansion、或 broader refresh family

## Proof Gate

- 本轮已完成 freeze bundle 语义收口与最小 live truth sync，仍不授权实现、测试或 evidence bundle。
- 在 reviewer 明确打开 proof gate 前，不允许执行：
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
- 在 reviewer 明确打开 proof gate 前，不允许生成：
  - landed report
  - `artifacts/verification_contracts/...` evidence bundle

## Notes For Reviewer

- 这不是对 `M5` 的返修判决；它是 `M5` 之后当前已冻结的下一 continuation slice。
- 该切片故意不把“armed slot 遇到任意 other-peer activity 都应丢弃”写成目标；它只验证 list-route、single refresh、other visible peer 这一条最窄 invalidation edge。
- 若 reviewer 认为该 edge 仍过宽，应优先裁掉 refresh 目标集合或 reopen 验证集合，而不是引入更大的 shared/per-peer 设计。
