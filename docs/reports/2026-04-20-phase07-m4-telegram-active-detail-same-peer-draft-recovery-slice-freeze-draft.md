# 2026-04-20 Phase07 M4 Telegram Active-Detail Same-Peer Draft Recovery Slice Freeze Draft

## Status

- draft only；本文件只用于 reviewer 审阅新的 bounded continuation slice 候选。
- current approved plan 仍是 `phase07_m3_telegram_active_detail_composer_slice_landed`。
- 在 reviewer 明确批准前，本文件不授权实现、测试、evidence bundle、repo-level state sync 或 landed report。

## Objective

在 `M3 Telegram Active-Detail Composer Slice` 之上，只验证一个更窄的 same-package recovery edge：同一条可见会话的未发送 draft 能否在 `backFromDetail()` -> reopen same conversation 后恢复；与此同时，`sendDetailDraft()` 后仍必须清空 draft，切到其他 peer 仍必须清空旧 draft，list-route composer API 仍必须保持 no-op。

## In Scope

- `samples/telegram-ui-vertical-slice-001` 的 same-package app-shell / detail / tests
- `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md` 中与本候选 slice 对应的冻结定义
- reviewer 审阅用的 freeze-draft 说明面

## Out Of Scope

- `samples/phase07-shared-service-refresh-harness/**`
- `samples/real-message-service-cache-001/**`
- `P23`
- shared helper/API
- generic send abstraction
- broader UI redesign
- 完整 per-peer draft persistence rollout

## Requirements Freeze

- same-peer recovery only：
  只有在 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 返回列表时，才允许把当前 peer + draft 写入单槽、same-peer、short-lived recovery slot；返回 list route 后，未发送 draft 不应在 list-route surface 暴露。随后只有首次 reopen 同一条仍可见会话时才允许恢复，且 restore 后必须立即消费该 slot。recovery slot is consumed on the first same-peer reopen restore and does not survive that restore unless a new unsent draft is edited and backed out again.
- clear-on-send stays frozen：
  恢复后的 `sendDetailDraft()` 仍必须复用 `M3` 的 same-package send 路径，并在发送成功后清空 draft 与 recovery slot。
- clear-on-other-peer stays frozen：
  direct retarget 到其他 peer、或从列表 reopen 另一条 visible conversation，仍必须丢弃旧 draft / slot。
- list-route no-op stays frozen：
  `updateDetailDraft(...)` / `sendDetailDraft()` 在 list route 下仍必须严格 no-op。list-route composer API remains a pure no-op and must not mutate recovery-slot state；它不得创建、恢复、消费、泄漏或清空 recovery slot。

## Design Freeze

- 最小设计只允许一个 same-package recovery slot，而不是 per-peer draft map。
- recovery slot 只服务于 `backFromDetail()` 之后 reopen same conversation 的单条 sibling edge；它不是 generic persistence，也不是 shared helper。
- recovery slot 只允许在 active detail 持有未发送 draft 且执行 `backFromDetail()` 返回 list 时写入。
- 恢复时机限定为“先 back 到 list，再首次 reopen 同一条 visible conversation”；recovery slot is consumed on the first same-peer reopen restore and does not survive that restore unless a new unsent draft is edited and backed out again.
- 若改为打开其他 peer、或 direct retarget 到其他 peer，则该 slot 必须立即清空。
- list-route composer API remains a pure no-op and must not mutate recovery-slot state。
- `currentPageName()`、`historySize()`、detail thread ownership、summary coherence 继续沿用 `M3` 边界，不在本候选中扩写新的 route family。

## Tasks Freeze

- 在 `requirements.md` 记录 `M4-REQ-*` 与 `M4-AC-*`，明确 proof gate 仍处于未授权状态。
- 在 `design.md` 记录单槽 same-peer recovery 的最小状态模型与 transition 规则，明确 slot 的唯一写入、首次 same-peer restore 即消费、以及 send / other-peer clear 边界。
- 在 `tasks.md` 新增未执行的 `[ ] M4` 任务，限定 write set 仍只允许：
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- 在 `tasks.md` 明确 list-route composer API 仍是 pure no-op，且不得创建、恢复、消费、泄漏或清空 recovery slot。
- reviewer 只需先判断该 slice 是否值得冻结，不在本轮要求实现。

## Proposed Minimal Regression Locks

- `appShellDetailDraftShouldRecoverAfterBackAndReopenSameConversation`
- `appShellRecoveredDetailDraftShouldStillClearAfterSend`
- `appShellRecoveredDetailDraftShouldDropOnOtherPeerAndListRouteNoop`

## Done When

- reviewer 能基于本文件与 `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md` 直接判断：
  - 该候选 slice 的目标是否够窄
  - same-peer recovery 是否没有越过 `M3` / `P23` / shared-harness 边界
  - 2-3 条最小回归草案是否足够支撑进入实现

## Proof Gate

- 本轮修正仅收口 freeze 包语义，不授权实现、测试或 state sync。
- 只有 freeze draft 被 reviewer 明确批准后，才允许执行：
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
- 只有 freeze draft 被 reviewer 明确批准后，才允许生成：
  - landed report
  - `artifacts/verification_contracts/...` evidence bundle
  - `docs/status/current_committed_plan.md` / `docs/current_state.v2.md` / `docs/status/INDEX.md` / `docs/status/current_task_handoff.md` 的 state sync

## Notes For Reviewer

- 这不是对 `M3` 的返修判决；它只是 `M3` 之后的一条候选 continuation slice。
- 该候选故意不把“draft 在任意 reopen 间持久化”写成目标，只重新打开 one-slot same-peer recovery 这一条 sibling edge。
- 若 reviewer 认为该 edge 仍过宽，应优先裁掉 recovery slot 的寿命或触发条件，而不是引入更大的 shared/per-peer 设计。
