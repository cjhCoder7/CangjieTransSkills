# 2026-04-20 Phase07 M5 Telegram Active-Detail Same-Peer Draft Recovery Refresh-Before-Reopen Coherence Slice Freeze Draft

## Status

- draft only；本文件只用于 reviewer 审阅新的 bounded continuation slice 候选。
- current approved plan 仍是 `phase07_m4_telegram_active_detail_same_peer_draft_recovery_slice_landed`。
- 在 reviewer 明确批准前，本文件不授权实现、测试、evidence bundle、repo-level state sync 或 landed report。

## Objective

在已 landed 的 `M4 Telegram Active-Detail Same-Peer Draft Recovery Slice` 之上，只冻结一个更窄的 refresh-before-reopen sibling edge：当 active detail 持有未发送 draft、`backFromDetail()` 已武装 same-peer recovery slot、且用户仍停在 list route 时，若先对同一条 peer 执行 `refreshConversation(peer, limit)`，随后首次 reopen 同一条 refreshed visible conversation，则 draft 仍允许恢复，recovery slot 仍必须在这次 restore 后立即消费，refreshed summary / detail thread ownership / bounded history 继续保持与既有 refresh rail 一致；与此同时，list-route 期间 draft 仍不得暴露，`sendDetailDraft()` after recovery 仍必须清空 draft / slot。

## In Scope

- `samples/telegram-ui-vertical-slice-001` 的 same-package app-shell / detail / tests
- `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md` 中与本候选 slice 对应的冻结定义
- reviewer 审阅用的 freeze-draft 说明面

## Out Of Scope

- `samples/phase07-shared-service-refresh-harness/**`
- `samples/real-message-service-cache-001/**`
- `P23`
- refresh other peer while recovery slot is armed
- direct retarget after refreshed same-peer recovery
- any broader refresh permutation
- shared helper/API
- generic send abstraction
- broader UI redesign
- 完整 per-peer draft persistence rollout

## Requirements Freeze

- `M4` slot lifecycle stays frozen：
  - recovery slot 仍是 single-slot、same-peer、short-lived
  - slot 仍只允许在 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 返回 list route 时写入
  - slot 仍只允许在 first same-peer reopen 时 restore 并立即消费
- 唯一新增 sibling edge：
  - `active detail unsent draft -> backFromDetail() arms slot -> list-route refreshConversation(same peer, limit) -> first reopen same refreshed visible conversation`
- list-route same-peer refresh stays side-effect-free on recovery：
  - refresh 可以沿既有 refresh rail 更新 refreshed target summary
  - refresh 不得暴露 draft
  - refresh 不得创建、恢复、消费、清空或改写 same-peer recovery slot
- first same-peer reopen after refresh still restores and consumes：
  - first same-peer reopen 仍应恢复 draft
  - recovery slot 仍必须在这次 restore 后立即消费
  - reopen 后 detail thread ownership 必须绑定到 refreshed target
  - refreshed target summary / bounded history 继续沿用既有 refresh / reopen rail
- send-clear stays frozen：
  - `sendDetailDraft()` after recovery 仍必须复用现有 same-package send path，并在发送成功后清空 draft / slot
- list-route composer API stays frozen：
  - `updateDetailDraft(...)` / `sendDetailDraft()` 在 list route 下仍必须 strict pure no-op
  - list-route composer API remains a pure no-op and must not mutate recovery-slot state

## Design Freeze

- 最小设计继续复用 `M4` 的 single-slot recovery state 和 `P1-11` / `P1-15` 的 refresh / reopen coherence rail，不引入新的 slot family、per-peer draft map、shared helper 或 generic send layer。
- `M5` 只允许 one-hop 插入一次 list-route same-peer refresh，不扩写其他 refresh family。
- 最小 transition 只冻结五条：
  - `backFromDetail()` arm slot：保持 `M4` 不变
  - list-route same-peer refresh while armed：更新 refreshed summary，但不暴露 draft，也不改写 slot
  - first reopen same refreshed visible conversation：restore draft 并立即 consume slot
  - send after refreshed recovery：沿既有 same-package send path 发送，并清空 draft / slot
  - list-route composer API：继续 pure no-op，不得对 slot 产生副作用

## Boundary Freeze

- 与 `M4` 的边界：
  - `M4` 只锁定 `back -> first same-peer reopen`
  - `M5` 只在两者之间插入一次 list-route same-peer refresh，不重写 `M4` 的 slot 语义
- 与 `P1-11` 的边界：
  - `P1-11` 锁定的是 list-route `back -> refresh -> reopen refreshed target` 的 summary / detail coherence
  - `M5` 只在这个 rail 上增加“armed same-peer recovery slot 仍可恢复 draft”的语义
- 与 `P1-15` 的边界：
  - `P1-15` 锁定的是 active-detail target `refresh -> back -> reopen same refreshed target`
  - `M5` 不从 detail 内 refresh 起步，而是从 `M4` 已经 back 到 list 且 slot 已 armed 的状态起步

## Tasks Freeze

- 在 `requirements.md` 新增 `M5-REQ-*` 与 `M5-AC-*`，明确 proof gate 仍未授权。
- 在 `design.md` 新增 `M5` design freeze 小节，只记录最小状态模型与 transition，不扩成 broader refresh family。
- 在 `tasks.md` 新增未执行的 `[ ] M5` 任务，限定未来 write set 仍只允许：
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- 在 `tasks.md` 明确三条最小回归草案与 out-of-scope 分支。
- reviewer 本轮只需判断该 slice 是否值得进入实现；proof gate 继续关闭。

## Proposed Minimal Regression Locks

- `appShellDraftRecoverySlotShouldSurviveSamePeerRefreshBeforeReopen`
- `appShellRecoveredDraftAfterSamePeerRefreshShouldStillClearAfterSend`
- `appShellListRouteSamePeerRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndBounded`

## Done When

- reviewer 能基于本文件与 `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md` 直接判断：
  - 该候选 slice 是否仍然足够窄
  - `M5` 是否只是在 `M4` 与既有 refresh rail 之间插入一次 same-peer refresh
  - 三条最小回归草案是否足够支撑进入实现
  - 文档是否没有把 `M5` 写成 per-peer persistence、shared continuation、或 broader refresh family

## Proof Gate

- 本轮只收口 freeze bundle 语义，不授权实现、测试、evidence bundle 或 state sync。
- 在 reviewer 明确批准前，不允许执行：
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
- 在 reviewer 明确批准前，不允许生成：
  - landed report
  - `artifacts/verification_contracts/...` evidence bundle
  - `docs/status/current_committed_plan.md` / `docs/current_state.v2.md` / `docs/status/INDEX.md` / `docs/status/current_task_handoff.md` 的 state sync

## Notes For Reviewer

- 这不是对 `M4` 的返修判决；它只是 `M4` 之后的一条候选 continuation slice。
- 该候选故意不把“armed slot 遇到任何 refresh 都应存活”写成目标；它只验证 same-peer、list-route、refresh-before-first-reopen 这一条最窄 edge。
- 若 reviewer 认为该 edge 仍过宽，应优先裁掉 refresh 分支的目标集合或 reopen 之后的延伸动作，而不是引入更大的 shared/per-peer 设计。
