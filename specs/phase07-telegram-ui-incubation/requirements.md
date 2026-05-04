# Phase07 Telegram UI Incubation Requirements

## 1. 问题定义

`Phase06 regular` 主线已经在正式 SSOT 上封顶于 `P22 / 311/311 live passed`，并且 post-P22 review 已冻结 `P23 mechanical-ready = No`。当前未决问题不再是“如何继续 regular reserve expansion”，而是“如何在不改写既有正式 checkpoint 的前提下，为项目定义下一条可执行但非 promotion 的 continuation lane”。

本 spec 定义 `Phase07 Telegram UI Incubation`：

- 它是 post-P22 之后的独立 continuation lane；
- 它不属于 `Phase06 regular` reserve expansion；
- 它不改变 `P22 / 311/311 live passed`；
- 它不改变 `P23 mechanical-ready = No`；
- 它只把 next-stage strategy 落成可执行规格，不启动实现或 promotion。

## 2. 范围

### 2.1 In Scope

- 定义一个以 repo-local Telegram UI bounded slice 为种子的独立推进轨；
- 明确该轨道的目标、边界、输入资产和 staging boundary；
- 为后续 Linux `Staging-Core` 闭环定义最小 acceptance、设计边界与近期任务；
- 明确 `samples/telegram-ui-vertical-slice-001`、`samples/real-message-service-cache-001`、`samples/ui-routing-defining-page-layout` 的角色分工。

### 2.2 Out of Scope

- 不重开任何 `P23` freeze / mock / live；
- 不刷新 aggregate audit / coverage；
- 不改写 `AGENTS.md`、`/.claude/status/current-phase.md`、既有 post-P22 reports；
- 不将 exploratory sample 升级为 promoted evidence；
- 不在本轮创建 execution artifact、run log、promotion report 或 live claim。

## 3. 冻结输入

本 spec 只依赖以下现有输入：

- [AGENTS.md](../../AGENTS.md)
- [.claude/status/current-phase.md](../../.claude/status/current-phase.md)
- [docs/reports/2026-04-14-phase06-post-p22-phase-summary-and-next-stage-strategy.md](../../docs/reports/2026-04-14-phase06-post-p22-phase-summary-and-next-stage-strategy.md)
- [docs/reports/2026-04-14-phase06-post-p22-route-transition-archive-handoff.md](../../docs/reports/2026-04-14-phase06-post-p22-route-transition-archive-handoff.md)
- [samples/telegram-ui-vertical-slice-001](../../samples/telegram-ui-vertical-slice-001)
- [samples/real-message-service-cache-001](../../samples/real-message-service-cache-001)
- [samples/ui-routing-defining-page-layout](../../samples/ui-routing-defining-page-layout)

## 4. 目标

- 以 `samples/telegram-ui-vertical-slice-001` 作为 seed input，推进“可持续扩展的 Telegram UI 骨架能力”。
- 优先建立 Linux `Staging-Core` 下可验证的 repo-local compile / test / behavior 闭环。
- 让后续推进围绕共享 harness、最小 app-shell consume boundary 与 regression/test-first rail 收敛，而不是继续 Phase06 reserve expansion。
- 保持新轨道为 incubation / exploratory continuation lane，而不是 Harmony live、promoted lane 或 Full Pass lane。

## 5. 用户故事

- 作为当前仓维护者，我希望在 `Phase06 regular` 封顶后仍有一条正式但不冲突的推进轨，这样项目可以继续前进而不必重开 `P23`。
- 作为后续实现者，我希望 Telegram UI 的推进从共享 harness、最小 consume boundary 和 regression rail 开始，这样可以避免把 exploratory sample 直接扩写成不可控工程。
- 作为验证维护者，我希望所有下一步都优先落在 Linux `Staging-Core` 的 repo-local compile / test / behavior 范围内，这样证据边界清晰且可复现。

## 6. requirements

### REQ-1 轨道身份

`Phase07 Telegram UI Incubation` 必须被定义为独立的 post-P22 continuation lane，而不是 `Phase06 regular` reserve expansion lane。

### REQ-2 正式状态保护

该新轨道必须显式保持 `P22 / 311/311 live passed` 与 `P23 mechanical-ready = No` 不变，不得把自身表述为新的 promotion 或 mechanical-ready 入口。

### REQ-3 seed input 约束

`samples/telegram-ui-vertical-slice-001` 只能作为 exploratory seed input；后续任何实现都应消费它暴露出的边界，而不是把该 sample 本身升级成 promoted basis。

### REQ-4 共享 harness 优先

后续推进必须优先定义从 Telegram seed slice 与 `real-message-service-cache-001` 中可抽取的 shared harness / service boundary，避免直接跳到完整 app 化。

### REQ-5 最小 app-shell consume boundary

后续推进必须定义一个 repo-local app-shell prototype consume boundary，用于承接 page router、session list、detail placeholder 等 UI skeleton 能力，但不得触发 Windows `Staging-Full` claim。

### REQ-6 regression / test-first rail

后续推进必须把 regression/test-first rail 作为默认护栏，优先锁定 compile / unit / behavior 闭环，再允许 bounded-slice 能力扩展。

### REQ-7 staging boundary

Linux `Staging-Core` 只负责证明 repo-local compile / test / behavior；Windows `Staging-Full` 仍只对应已有 Full Pass / physical evidence 语义，不属于本轨道的当前目标。

## 7. acceptance criteria

### AC-1

While 当前正式 checkpoint 保持冻结，when `Phase07 Telegram UI Incubation` 被引用时，spec shall 将其表述为独立 continuation lane，而不是 `Phase06 regular` 扩展批次。

### AC-2

While post-P22 strategy 仍有效，when 任何文档引用本轨道时，spec shall 明确保留 `P22 / 311/311 live passed` 和 `P23 mechanical-ready = No` 不变。

### AC-3

While `samples/telegram-ui-vertical-slice-001` 仍为 exploratory 输入，when 设计或任务引用该 sample 时，spec shall 将其限定为 seed input，而不是 promoted evidence、live lane 或 mechanical-ready 输入。

### AC-4

When 后续实现任务被拆解时，spec shall 把共享 harness / module boundary 识别为第一优先方向之一，并把它与 `real-message-service-cache-001` 的 service / refresh / behavior harness 关联起来。

### AC-5

When 后续实现任务定义 repo-local UI 入口时，spec shall 只允许最小 app-shell prototype consume boundary，并把 `ui-routing-defining-page-layout` 视为路由和页面组织参考，而不是 `Windows Staging-Full` claim 的依据。

### AC-6

When 后续验证面被定义时，spec shall 默认要求 Linux `Staging-Core` 下的 compile / test / behavior evidence，并显式禁止把本轨道的结果表述为 Harmony live、promoted 或 Full Pass。

### AC-7

When 本轨道的近期任务被列出时，spec shall 优先给出能启动 continuation lane 的 3-5 个任务，并且每个任务都能映射回本 requirements。

## 8. non-goals

- non-goal：重开 `P23` freeze / mock / live。
- non-goal：刷新 `Phase06 regular` aggregate audit / coverage。
- non-goal：把 exploratory sample 当作 promoted evidence 或 mechanical-ready basis。
- non-goal：在本轮推进 Windows `Staging-Full`、Harmony live、promoted 或 Full Pass claim。
- non-goal：直接实现 app-shell prototype、shared harness 抽取或 regression 套件。

## 9. M4 Telegram Active-Detail Same-Peer Draft Recovery Slice

### 9.1 问题定义

`M3` 已经把 active-detail composer/draft 冻结为最小可用链路，但它仍采取“`back` / `reopen` 一律清空 draft”的保守边界。当前 landed `M4` 不重开 shared harness 或 generic send，只落地一个更窄的 same-package recovery edge：当 active detail 存在未发送 draft 且用户执行 `backFromDetail()` 返回列表后，若随后 reopen 的仍是同一条可见会话，则该 draft 可以恢复；same-peer reopen 仍是唯一 restore 路径。若发送成功或切到其他 peer，则旧 draft / slot 仍必须被清空；若仅停留在 list-route，则未发送 draft 不得暴露为 list-route surface，且 list-route composer API 仍保持 strict pure no-op，不对 recovery slot 产生任何副作用。

### 9.2 requirements

#### M4-REQ-1 same-peer back/reopen draft recovery

当 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 返回 `TelegramSessionListPage` 时，Telegram app-shell 才允许把该 peer 绑定的 draft 写入单槽、same-peer、short-lived recovery slot；返回 list route 后不得把 draft 暴露为 list-route surface。随后只有 reopen 同一条仍可见会话时，Telegram app-shell 才允许恢复该 draft；该 recovery slot 必须在首次 same-peer reopen restore 时立即被消费，除非用户再次编辑新的未发送 draft 并再次 `backFromDetail()`，否则它不得继续存活。

#### M4-REQ-2 send / other-peer / list-route clearing boundary

恢复后的 draft 与 recovery slot 仍必须沿用严格的 `M3` 边界：`sendDetailDraft()` 成功发送后必须清空；打开另一条 visible conversation、或在 detail 内 direct retarget 到其他 peer 时必须丢弃旧 draft / slot。list-route `updateDetailDraft(...)` / `sendDetailDraft()` 仍必须保持严格 no-op；该 no-op 不得创建、恢复、消费、泄漏或清空 recovery slot，也不得对 recovery 状态产生任何副作用。

#### M4-REQ-3 same-package bounded scope

该 landed 切片只允许在 `samples/telegram-ui-vertical-slice-001` 的 same-package app-shell / detail / tests 范围内实现与回归；不得触碰 `samples/phase07-shared-service-refresh-harness/**`、`samples/real-message-service-cache-001/**`、`P23`、shared helper/API、generic send abstraction、broader UI redesign，或完整 per-peer draft persistence rollout。

#### M4-REQ-4 pre-implementation proof gate

本 landed 切片的 canonical verification / evidence / state sync 只允许围绕 `samples/telegram-ui-vertical-slice-001` 的 same-package M4 surface 展开，不得把结果外推成 shared continuation、promoted lane、或任何更宽的 repo-status claim。

### 9.3 acceptance criteria

#### M4-AC-1

While active detail 持有未发送 draft，when 用户执行 `backFromDetail()` 后 reopen 同一条仍可见会话，the Telegram app-shell shall 恢复该 draft，并继续把 route、bounded history 与 detail thread ownership 绑定到同一 peer；the recovery slot is consumed on the first same-peer reopen restore and does not survive that restore unless a new unsent draft is edited and backed out again.

#### M4-AC-2

While same-peer recovery draft 已恢复，when `sendDetailDraft()` 被调用，the Telegram app-shell shall 复用现有 same-package send 路径追加消息、同步 target summary 的 sent text / `messageCount`，并在发送后清空 draft 与 recovery slot。

#### M4-AC-3

While 存在可恢复或已恢复的 draft，when 用户改为打开另一条 visible conversation、或在 detail 内 direct retarget 到其他 peer，the Telegram app-shell shall 丢弃旧 draft / slot，且不得把它泄漏为 generic/per-peer persistence; when 用户仅停留在 list route 调用 composer API，the list-route composer API remains a pure no-op and must not mutate recovery-slot state, create it, restore it, consume it, leak it, or clear it.

#### M4-AC-4

When `M4` 被引用时，the spec shall 将其表述为 `M3` 之后的 bounded landed milestone，而不是 shared continuation reopening、repo-level promotion、或 broader current-state escalation。

### 9.4 non-goals

- non-goal：把 `M4` 写成 per-peer draft persistence rollout。
- non-goal：新增 shared helper、shared draft store、generic send abstraction 或跨 package consume surface。
- non-goal：允许 list-route 暴露、编辑或发送恢复中的 draft。
- non-goal：在 freeze draft 阶段提前产出 runtime/evidence/report 闭环并回写 repo-level current pointers。

## 10. M5 Telegram Active-Detail Same-Peer Draft Recovery Refresh-Before-Reopen Coherence Slice

### 10.1 问题定义

`M4` 已经把 single-slot same-peer draft recovery 落地为 `backFromDetail()` -> first same-peer reopen 的最小恢复链路，但它还没有定义“已武装 recovery slot 时，list-route 先对同一条 peer 执行一次 refresh，再 reopen”的 sibling edge。当前 landed `M5` 不重开 shared harness、不扩成 per-peer persistence、也不改写 `M4` 已冻结的 slot write / restore / consume / clear 语义；它只在两者之间插入一次 list-route `refreshConversation(same peer, limit)`：当 active detail 持有未发送 draft、`backFromDetail()` 已武装 same-peer recovery slot、且用户仍停在 list route 时，若先刷新同一条 peer 并随后首次 reopen 同一条 refreshed visible conversation，则 draft 仍允许恢复，且 recovery slot 仍必须在这次 restore 后立即消费。与此同时，list-route refresh 不得暴露 draft，也不得消费、清空或改写 slot；refreshed summary、detail thread ownership 与 bounded history 继续沿用既有 refresh / reopen rail 的 coherence 边界。本轮不冻结 other-peer refresh、refresh 后 direct retarget，或任何更宽的 refresh family。

### 10.2 requirements

#### M5-REQ-1 same-peer refresh-before-reopen recovery coherence

当 active detail 持有未发送 draft 且 `backFromDetail()` 已按 `M4` 合同武装单槽、same-peer、short-lived recovery slot 后，若 shell 仍停在 list route，则针对同一条 peer 的 `refreshConversation(peer, limit)` 只允许沿既有 list-route refresh rail 更新 refreshed visible summary；该 refresh 不得把 draft 暴露为 list-route surface，也不得创建、恢复、消费、清空或改写 recovery slot。随后只有首次 reopen 同一条 refreshed visible conversation 时，Telegram app-shell 才允许恢复该 draft，且必须在这次 restore 后立即消费 slot；reopen 后 detail thread ownership 必须绑定到 refreshed target。

#### M5-REQ-2 M4 slot semantics and send-clear boundary remain frozen

`M5` 不得改写 `M4` 已冻结的 slot 生命周期：recovery slot 仍只允许在 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 返回 list route 时写入；仍只允许在首次 same-peer reopen 时恢复并立即消费；`sendDetailDraft()` after recovery 仍必须复用现有 same-package send path，并在发送成功后清空 draft / slot。list-route `updateDetailDraft(...)` / `sendDetailDraft()` 仍必须保持 strict pure no-op；该 no-op 不得创建、恢复、消费、泄漏或清空 recovery slot，也不得对 recovery 状态产生任何副作用。

#### M5-REQ-3 same-package bounded scope

该 landed 切片只允许在 `samples/telegram-ui-vertical-slice-001` 的 same-package app-shell / detail / tests 范围内实现、回归、验证与证据收口；不得触碰 `samples/phase07-shared-service-refresh-harness/**`、`samples/real-message-service-cache-001/**`、`P23`、shared helper/API、generic send abstraction、broader UI redesign，或完整 per-peer draft persistence rollout。与此同时，本轮明确不冻结：

- refresh other peer while recovery slot is armed
- direct retarget after refreshed same-peer recovery
- any broader refresh permutation
- shared/helper rollout
- generic send expansion

#### M5-REQ-4 canonical verification and evidence boundary

本 landed 切片的 canonical verification / evidence / state sync 只允许围绕 `samples/telegram-ui-vertical-slice-001` 的 same-package M5 surface 展开：必须运行 `cjpm test` 与 `timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`，并把日志、case existence、git scope visibility 与 pointer consistency 收口到 `artifacts/verification_contracts/20260420-phase07-telegram-m5-active-detail-same-peer-draft-recovery-refresh-before-reopen-coherence-slice/`；与此同时，不得把结果外推成 shared continuation、promoted lane、或任何更宽的 repo-status claim。

### 10.3 acceptance criteria

#### M5-AC-1

While active detail 持有未发送 draft 且 `backFromDetail()` 已武装 same-peer recovery slot，when 用户停留在 list route 并对同一条 peer 执行 `refreshConversation(peer, limit)`，the Telegram app-shell shall 继续把 draft 隐藏在 list-route surface 之外，并仅沿既有 refresh rail 更新 refreshed target summary；the refresh shall not create, restore, consume, clear, or mutate the armed recovery slot.

#### M5-AC-2

While same-peer recovery slot 在 list-route same-peer refresh 之后仍保持已武装，when 用户首次 reopen 同一条 refreshed visible conversation，the Telegram app-shell shall 恢复 draft、把 detail thread ownership 绑定到 refreshed target、保持 refreshed summary / bounded history 与既有 refresh / reopen coherence 一致，并在该次 restore 后立即消费 recovery slot。

#### M5-AC-3

While draft 已沿 `M5` edge 恢复，when `sendDetailDraft()` 被调用，the Telegram app-shell shall 复用现有 same-package send path 把 draft 文本追加到当前投影线程、继续同步 target summary 的 sent text / `messageCount`，并在发送成功后清空 draft / slot；when 用户仅停留在 list route 调用 composer API，the list-route composer API shall remain a strict pure no-op and shall not mutate recovery-slot state.

#### M5-AC-4

When `M5` 被引用时，the spec shall 将其表述为 `M4` 之后一个更窄的 bounded landed milestone：它只在 `backFromDetail()` 与 first same-peer reopen 之间插入一次 list-route same-peer refresh；它建立在 `P1-11` / `P1-15` 已冻结的 refresh coherence 之上，但不得被写成 per-peer draft persistence、shared continuation、generic send expansion，或 broader refresh family。

### 10.4 non-goals

- non-goal：改写 `M4` 的 recovery slot 写入、恢复、消费或清空语义。
- non-goal：冻结 armed slot 下的 other-peer refresh 分支。
- non-goal：冻结 refreshed same-peer recovery 之后的 direct retarget 或更宽 route family。
- non-goal：把 `M5` 写成 shared continuation、per-peer draft persistence、generic send 扩张或 broader UI redesign。
- non-goal：把 `M5` landed 的 same-package 验证 / evidence 闭环外推成 shared continuation、repo-level promotion、或 broader refresh family 授权。

## 11. M6 Telegram Active-Detail Same-Peer Draft Recovery Other-Peer Refresh Drop Boundary Slice

### 11.1 问题定义

`M5` 已经把 armed same-peer recovery slot 遇到 list-route same-peer refresh 时仍允许恢复 draft 的 sibling edge 落地，而 `M6` 进一步把“已武装 recovery slot 时，list-route 先对另一条 visible peer 执行一次 refresh”的 drop boundary 落成当前 latest Telegram consume milestone。`M6` 仍不重开 shared harness、不扩成 per-peer persistence、也不改写 `M4` / `M5` 已冻结的 slot write / restore / consume / clear 语义；它只在 `active detail unsent draft -> backFromDetail() arms slot -> list-route refreshConversation(other visible peer, limit)` 这条更窄的 sibling edge 上补一条失效合同：other-peer refresh 仍只允许沿既有 refresh rail 更新 refreshed other-peer summary，不得暴露 draft，也不得 restore slot，但必须把旧 recovery candidate 视为失效并丢弃。随后无论 reopen 原 peer 还是 reopen refreshed other peer，old draft 都不得恢复；detail ownership、summary coherence、`historySize()` / `currentPageName()` 继续沿用既有 refresh / reopen rail。本轮不冻结 multiple refresh chain、other-peer refresh 后 direct retarget、same-peer refresh 与 other-peer refresh 混合序列，或任何更宽的 refresh family。

### 11.2 requirements

#### M6-REQ-1 other-peer refresh invalidates the armed recovery candidate

当 active detail 持有未发送 draft 且 `backFromDetail()` 已按 `M4` / `M5` 合同武装单槽、same-peer、short-lived recovery slot 后，若 shell 停在 list route，则针对另一条 visible peer 的 `refreshConversation(peer, limit)` 只允许沿既有 list-route refresh rail 更新 refreshed other-peer summary；该 refresh 不得把 draft 暴露为 list-route surface，也不得 restore recovery slot，但必须使旧 recovery candidate 失效并立即丢弃该 slot。

#### M6-REQ-2 no-restore boundary after other-peer refresh invalidation

`M6` 不得改写 `M4` / `M5` 已冻结的 slot 生命周期，只新增“list-route other-peer refresh invalidates armed slot”这一条 drop boundary：一旦该 invalidation 已发生，随后 reopen 原 peer 或 reopen refreshed other peer 时，Telegram app-shell 都不得恢复 old draft。与此同时，reopen 后的 detail thread ownership、refreshed summary、`historySize()` 与 `currentPageName()` 必须继续沿用既有 refresh / reopen coherence rail；list-route `updateDetailDraft(...)` / `sendDetailDraft()` 仍必须保持 strict pure no-op，不得创建、恢复、消费、泄漏或清空 recovery slot，也不得创建 recovery state 之外的新隐含状态。

#### M6-REQ-3 same-package bounded scope

该 landed 切片只允许在 `samples/telegram-ui-vertical-slice-001` 的 same-package app-shell / detail / tests 范围内落地与维护；不得触碰 `samples/phase07-shared-service-refresh-harness/**`、`samples/real-message-service-cache-001/**`、`P23`、shared helper/API、generic send abstraction、broader UI redesign，或完整 per-peer draft persistence rollout。与此同时，本轮明确不冻结：

- multiple refresh chain
- other-peer refresh 后 direct retarget
- same-peer refresh 与 other-peer refresh 混合序列
- any broader refresh family
- shared/helper rollout
- generic send expansion

#### M6-REQ-4 landed proof and state sync

`M6` 必须以最小实现和最小 proof 闭环 landed：三条 `M6` 回归锁需要纳入 `telegram_ui_vertical_slice_test.cj`，`cd samples/telegram-ui-vertical-slice-001 && cjpm test` 与 `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001` 必须都通过，并生成 landed report 与 evidence bundle；在此基础上，live truth surfaces 才能把 `M6` 收口为当前 latest landed Telegram consume milestone，同时继续保持 `Phase07 exploratory-only`、`M5` / `M4` / `M3` / `M2` / `P1-43` 为已落地 checkpoint、以及 latest shared-harness checkpoint 仍为 `P1-27`。

### 11.3 acceptance criteria

#### M6-AC-1

While active detail 持有未发送 draft 且 `backFromDetail()` 已武装 same-peer recovery slot，when 用户停留在 list route 并对另一条 visible peer 执行 `refreshConversation(peer, limit)`，the Telegram app-shell shall 继续把 draft 隐藏在 list-route surface 之外，并仅沿既有 refresh rail 更新 refreshed other-peer summary；the refresh shall not restore the armed slot, and it shall invalidate and drop the old recovery candidate immediately.

#### M6-AC-2

While the armed recovery candidate has been invalidated by list-route other-peer refresh, when 用户随后 reopen 原 peer 或 reopen refreshed other peer，the Telegram app-shell shall not restore the old draft, and it shall keep detail ownership, summary coherence, `historySize()`, and `currentPageName()` aligned with the existing refresh / reopen rail.

#### M6-AC-3

While 用户仅停留在 list route 且 old recovery candidate 已被 other-peer refresh 丢弃，when 用户调用 `updateDetailDraft(...)` 或 `sendDetailDraft()`，the Telegram app-shell shall keep list-route composer API as a strict pure no-op; it shall not create, restore, consume, leak, or clear recovery state, and it shall not create any secondary hidden fallback state outside that recovery model.

#### M6-AC-4

When `M6` 被引用时，the spec shall 将其表述为 `M5` 之后一个更窄的 bounded landed milestone：它只在 `backFromDetail()` 与任意 reopen 之间插入一次 list-route other-peer refresh invalidation；它建立在 `P1-11` / `P1-15` 已冻结的 refresh coherence 之上，但不得被写成 per-peer draft persistence、shared continuation、generic send expansion，或 broader refresh family。

### 11.4 non-goals

- non-goal：改写 `M4` / `M5` 的 recovery slot 写入、恢复、消费或清空语义。
- non-goal：把 other-peer refresh 写成新的 restore 路径，或写成 broader clear-all refresh framework。
- non-goal：冻结 multiple refresh chain、same-peer/other-peer mixed refresh 序列、或 other-peer refresh 之后的 direct retarget。
- non-goal：把 `M6` 写成 shared continuation、per-peer draft persistence、generic send 扩张或 broader UI redesign。
- non-goal：把 `M6` landed 的最小 same-package proof 闭环误写成 repo-level promotion、shared continuation、proof-open 宽授权，或更宽 refresh family rollout。

## 12. M7 Telegram Active-Detail Same-Peer Draft Recovery Same-Peer Refresh Then Other-Peer Drop Slice

### 12.1 问题定义

`M5` 已经把 armed same-peer recovery slot 遇到 list-route same-peer refresh 时仍允许恢复 draft 的 preserve edge landed，`M6` 已经把 armed slot 直接遇到 list-route other-peer refresh 时必须丢弃的 sibling edge landed，而 `M7` 则把两者之间最窄的 mixed-refresh 组合边 landed：当 active detail 持有未发送 draft、`backFromDetail()` 已武装 same-peer recovery slot、且用户仍停在 list route 时，若先对同一条 peer 执行一次 `refreshConversation(same peer, limit)` 保持 slot，再在任何 reopen 之前对另一条 visible peer 执行一次 `refreshConversation(other peer, limit)`，则第二步 other-peer refresh 必须使此前仍存活的 recovery candidate 失效并丢弃；此后任何 later reopen 都不得恢复 old draft。`M7` 只落地这条严格顺序的二步 list-route mixed-refresh slice，不重开 shared harness、不扩成 arbitrary mixed chain、也不改写 `M4` / `M5` / `M6` 已冻结的 slot write / restore / consume / clear 语义。

### 12.2 requirements

#### M7-REQ-1 exact two-step mixed-refresh sequence

当 active detail 持有未发送 draft 且 `backFromDetail()` 已按 `M4` / `M5` / `M6` 合同武装单槽、same-peer、short-lived recovery slot 后，若 shell 仍停在 list route，则 `M7` 只落地如下严格顺序的一条二步 mixed-refresh 组合边：先对同一条 peer 执行一次 `refreshConversation(same peer, limit)`，该 refresh 仍只允许沿既有 same-peer refresh rail 更新 refreshed same-peer summary，并保持 armed slot 存活；随后在任何 reopen 之前，再对另一条 visible peer 执行一次 `refreshConversation(other peer, limit)`，该 refresh 仍只允许沿既有 other-peer refresh rail 更新 refreshed other-peer summary，但必须使此前仍存活的 recovery candidate 失效并立即丢弃。

#### M7-REQ-2 post-drop no-restore boundary after the two-step sequence

`M7` 不得改写 `M4` / `M5` / `M6` 已冻结的 slot 生命周期，只新增“same-peer preserve -> other-peer drop”这条严格顺序的二步 list-route mixed-refresh landed contract：一旦第二步 other-peer refresh 已发生并丢弃 armed slot，随后任何 later reopen 都不得恢复 old draft。与此同时，later reopen 后的 detail thread ownership、summary coherence、`historySize()` 与 `currentPageName()` 必须继续沿用既有 refresh / reopen rail；list-route `updateDetailDraft(...)` / `sendDetailDraft()` 仍必须保持 strict pure no-op，不得创建、恢复、消费、泄漏或清空 recovery slot，也不得创建 recovery state 之外的新隐含状态。

#### M7-REQ-3 same-package bounded scope

该 landed slice 只允许在 `samples/telegram-ui-vertical-slice-001` 的 same-package app-shell / detail / tests 范围内实现、回归、验证与证据收口；不得触碰 `samples/phase07-shared-service-refresh-harness/**`、`samples/real-message-service-cache-001/**`、`P23`、shared helper/API、generic send abstraction、broader UI redesign，或完整 per-peer draft persistence rollout。与此同时，本轮明确不冻结：

- reverse order 的 `other-peer refresh -> same-peer refresh`
- reopen 插在两次 refresh 之间的序列
- repeated same-peer refresh
- repeated other-peer refresh
- third-peer refresh
- any broader mixed refresh chain
- other-peer refresh 后 direct retarget
- shared/helper rollout
- generic send expansion

#### M7-REQ-4 landed proof and state sync

`M7` 必须以最小 proof 闭环 landed：三条 `M7` 回归锁需要纳入 `telegram_ui_vertical_slice_test.cj`，`cd samples/telegram-ui-vertical-slice-001 && cjpm test` 与 `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001` 必须都通过，并生成 landed report、evidence bundle 与 live truth sync。若现有 `M5/M6` production 行为已满足这条 mixed-refresh 合同，则 landed write set 可以只落在 regression、report、spec 与 state surfaces，不扩大 `telegram_ui_slice.cj` / `telegram_app_shell.cj` 的行为面。

### 12.3 acceptance criteria

#### M7-AC-1

While active detail 持有未发送 draft 且 `backFromDetail()` 已武装 same-peer recovery slot，when 用户停留在 list route 并先对同一条 peer 执行一次 `refreshConversation(peer, limit)`，the Telegram app-shell shall 继续把 draft 隐藏在 list-route surface 之外，并仅沿既有 same-peer refresh rail 更新 refreshed same-peer summary；the refresh shall not create, restore, consume, clear, or mutate the armed recovery slot.

#### M7-AC-2

While the armed recovery slot is still alive after the first same-peer refresh, when 用户在任何 reopen 之前再对另一条 visible peer 执行一次 `refreshConversation(peer, limit)`，the Telegram app-shell shall 仅沿既有 other-peer refresh rail 更新 refreshed other-peer summary，并立即 invalidate and drop the old recovery candidate.

#### M7-AC-3

While the old recovery candidate has already been dropped by the second-step other-peer refresh, when 用户随后执行 any later reopen，the Telegram app-shell shall not restore the old draft, and it shall keep detail ownership, summary coherence, `historySize()`, and `currentPageName()` aligned with the existing refresh / reopen rail; when 用户仅停留在 list route 调用 composer API，the list-route composer API shall remain a strict pure no-op and shall not create, restore, consume, leak, or clear recovery state.

#### M7-AC-4

When `M7` 被引用时，the spec shall 将其表述为 `M6` 之后一个更窄的 bounded landed slice：它只落地 `backFromDetail() -> same-peer refresh preserves slot -> other-peer refresh drops slot -> later reopen stays no-restore` 这一条严格顺序的二步 list-route mixed-refresh 组合边；它不得被写成 arbitrary mixed chain、shared continuation、per-peer persistence、generic send expansion，或更宽的 repo-level promotion。

### 12.4 non-goals

- non-goal：改写 `M4` / `M5` / `M6` 的 recovery slot 写入、恢复、消费或清空语义。
- non-goal：把 `M7` 扩写成 arbitrary mixed refresh chain、reverse-order mixed sequence、或任意 refresh family 框架。
- non-goal：冻结 reopen 插在两次 refresh 之间、other-peer refresh 后 direct retarget、或任何更宽 alternating route family。
- non-goal：把 `M7` 写成 shared continuation、per-peer draft persistence、generic send 扩张或 broader UI redesign。
- non-goal：把 `M7` 外推成 shared continuation、repo-level promotion、或下一 bounded continuation slice 已获批准。

## 13. M8 Telegram Active-Detail Same-Peer Draft Recovery Other-Peer Refresh Then Same-Peer Refresh No-Restore Slice

### 13.1 问题定义

`M6` 已经把 armed same-peer recovery slot 遇到 list-route other-peer refresh 时必须直接丢弃的 sibling edge landed，`M7` 已经把 `same-peer refresh preserves slot -> other-peer refresh drops slot` 这条严格顺序 mixed-refresh 组合边 landed，而它们之间最窄、最连续的 reverse-order sibling edge 仍未 landed：当 active detail 持有未发送 draft、`backFromDetail()` 已武装 same-peer recovery slot、且用户仍停在 list route 时，若先对另一条 visible peer 执行一次 `refreshConversation(other peer, limit)` 使 old recovery candidate 失效并丢弃，再在任何 reopen 之前对原 recovery peer 执行一次 `refreshConversation(same peer, limit)`，则第二步 same-peer refresh 也不得重建、恢复或间接 resurrect 已被丢弃的 old draft；此后任何 later reopen 都不得恢复 old draft。`M8` 只锁定这条严格顺序的 `other-peer refresh -> same-peer refresh` reverse-order sibling edge，不重开 shared harness、不扩成 repeated refresh / arbitrary mixed chain、也不改写 `M4` / `M5` / `M6` / `M7` 已冻结的 slot write / restore / consume / clear 语义。

### 13.2 requirements

#### M8-REQ-1 exact reverse-order two-step mixed-refresh sequence

当 active detail 持有未发送 draft 且 `backFromDetail()` 已按 `M4` / `M5` / `M6` / `M7` 合同武装单槽、same-peer、short-lived recovery slot 后，若 shell 仍停在 list route，则 `M8` 只锁定如下严格顺序的一条二步 reverse-order mixed-refresh 组合边：先对另一条 visible peer 执行一次 `refreshConversation(other peer, limit)`，该 refresh 仍只允许沿既有 other-peer refresh rail 更新 refreshed other-peer summary，并必须立即使 armed slot 失效并丢弃；随后在任何 reopen 之前，再对原 recovery peer 执行一次 `refreshConversation(same peer, limit)`，该 refresh 仍只允许沿既有 same-peer refresh rail 更新 refreshed same-peer summary，但不得重建、恢复、消费、清空或改写已被丢弃的 old recovery candidate。

#### M8-REQ-2 post-drop same-peer refresh remains no-resurrect and later reopen no-restore

`M8` 不得改写 `M4` / `M5` / `M6` / `M7` 已冻结的 slot 生命周期，只新增“other-peer drop -> same-peer refresh still no-resurrect”这条严格顺序的二步 list-route mixed-refresh 合同：一旦第一步 other-peer refresh 已发生并丢弃 armed slot，随后第二步 same-peer refresh 不得让 old draft 重新变成可 later reopen 的 recovery candidate，且任何 later reopen 都不得恢复 old draft。与此同时，later reopen 后的 detail thread ownership、summary coherence、`historySize()` 与 `currentPageName()` 必须继续沿用既有 refresh / reopen rail；list-route `updateDetailDraft(...)` / `sendDetailDraft()` 仍必须保持 strict pure no-op，不得创建、恢复、消费、泄漏或清空 recovery slot，也不得创建 recovery state 之外的新隐含状态。

#### M8-REQ-3 same-package bounded scope

该 landed-ready slice 只允许在 `samples/telegram-ui-vertical-slice-001` 的 same-package app-shell / detail / tests 范围内实现、回归、验证与证据收口；不得触碰 `samples/phase07-shared-service-refresh-harness/**`、`samples/real-message-service-cache-001/**`、`P23`、shared helper/API、generic send abstraction、broader UI redesign，或完整 per-peer draft persistence rollout。与此同时，本轮明确不冻结：

- repeated other-peer refresh
- repeated same-peer refresh
- reopen 插在两次 refresh 之间
- third-peer refresh
- any broader mixed refresh chain
- other-peer refresh 后 direct retarget
- shared/helper rollout
- generic send expansion

#### M8-REQ-4 landed proof and state sync

`M8` 必须以最小 proof 闭环 landed：三条 `M8` 回归锁需要纳入 `telegram_ui_vertical_slice_test.cj`，`cd samples/telegram-ui-vertical-slice-001 && cjpm test` 与 `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001` 必须都通过，并生成 landed report、evidence bundle 与 live truth sync。若现有 `M6/M7` production 行为已满足这条 reverse-order mixed-refresh 合同，则 landed write set 可以只落在 regression、report、spec 与 state surfaces，不扩大 `telegram_ui_slice.cj` / `telegram_app_shell.cj` 的行为面。

### 13.3 acceptance criteria

#### M8-AC-1

While active detail 持有未发送 draft 且 `backFromDetail()` 已武装 same-peer recovery slot，when 用户停留在 list route 并先对另一条 visible peer 执行一次 `refreshConversation(peer, limit)`，the Telegram app-shell shall 继续把 draft 隐藏在 list-route surface 之外，并仅沿既有 other-peer refresh rail 更新 refreshed other-peer summary；the refresh shall not restore the armed recovery slot and shall immediately invalidate and drop the old recovery candidate.

#### M8-AC-2

While the old recovery candidate has already been dropped by the first-step other-peer refresh, when 用户在任何 reopen 之前再对原 recovery peer 执行一次 `refreshConversation(peer, limit)`，the Telegram app-shell shall 仅沿既有 same-peer refresh rail 更新 refreshed same-peer summary，并不得重新创建、恢复、消费或间接 resurrect 已被丢弃的 old draft。

#### M8-AC-3

While the reverse-order mixed-refresh chain has already completed, when 用户随后执行 any later reopen，the Telegram app-shell shall not restore the old draft, and it shall keep detail ownership, summary coherence, `historySize()`, and `currentPageName()` aligned with the existing refresh / reopen rail; when 用户仅停留在 list route 调用 composer API，the list-route composer API shall remain a strict pure no-op and shall not create, restore, consume, leak, or clear recovery state.

#### M8-AC-4

When `M8` 被引用时，the spec shall 将其表述为 `M7` 之后一个更窄的 bounded reverse-order sibling slice：它只锁定 `backFromDetail() -> other-peer refresh drops slot -> same-peer refresh still no-resurrect -> later reopen stays no-restore` 这一条严格顺序的二步 list-route mixed-refresh 组合边；它不得被写成 repeated refresh、reopen-in-between、third-peer refresh、arbitrary mixed chain、shared continuation、per-peer persistence、generic send expansion，或更宽的 repo-level promotion。

### 13.4 non-goals

- non-goal：改写 `M4` / `M5` / `M6` / `M7` 的 recovery slot 写入、恢复、消费或清空语义。
- non-goal：把 `M8` 扩写成 repeated refresh、reopen 插在中间、third-peer refresh、或任意 broader mixed refresh family。
- non-goal：把 `M8` 写成 shared continuation、per-peer draft persistence、generic send 扩张或 broader UI redesign。
- non-goal：在 proof 未闭合前提前切 pointer / state / current truth surfaces。

## 14. M9 Telegram Active-Detail Same-Peer Draft Recovery Refresh-Reopen Then Direct-Retarget Other-Peer Drop Slice

### 14.1 问题定义

`M5` 已经把 armed same-peer recovery slot 遇到 list-route same-peer refresh 时仍可在 first same-peer reopen 恢复并消费 draft 的 preserve edge landed；`P1-12` / `P1-16` 已分别把 `refresh -> reopen -> retarget` 与 active-detail `refresh -> direct retarget` 的 same-package retarget coherence rail 冻结为既有边界；`M8` 则把 restore 之前的 reverse-order mixed-refresh no-resurrect sibling edge landed。当前仍未定义、且必须保持更窄的后续 sibling edge 是：当 active detail 持有未发送 draft、`backFromDetail()` 已武装 same-peer recovery slot、用户先在 list route 对同一条 peer 执行一次 refresh、随后首次 reopen 同一条 refreshed peer 以 restore and consume draft，再立刻 direct retarget 到一条 other visible peer 时，old recovered draft 必须在 retarget 时被丢弃，不得泄漏到新目标，也不得在 later reopen 原 peer 时 ghost-restore。`M9` 只锁定这条 `same-peer refresh -> first same-peer reopen restore/consume -> exactly one direct retarget other peer` 的更窄 same-package route edge；它不是 generic retarget family，也不重开 `M8` 的 pre-reopen mixed-refresh family、shared/helper、generic send、per-peer persistence、`P23` 或 repo-level promotion。

### 14.2 requirements

#### M9-REQ-1 exact refresh-reopen-retarget chain after same-peer recovery consumption

当 active detail 持有未发送 draft 且 `backFromDetail()` 已按 `M4` / `M5` 合同武装单槽、same-peer、short-lived recovery slot 后，若 shell 仍停在 list route，则 `M9` 只锁定如下严格顺序的一条 post-recovery route edge：先对原 recovery peer 执行一次 `refreshConversation(same peer, limit)`，该 refresh 仍只允许沿既有 same-peer refresh rail 更新 refreshed same-peer summary，并保持 armed slot 存活；随后首次 reopen 同一条 refreshed visible conversation 时，Telegram app-shell 才允许恢复该 draft，且必须在这次 restore 后立即消费 slot；在这之后，才允许一次 direct retarget 到一条 other visible peer，且该 retarget 仍只允许沿既有 detail-route retarget rail 切换 detail ownership、保持 `currentPageName()` 为 detail、并继续维持 bounded history。

#### M9-REQ-2 direct-retarget drop / no-leak / no-ghost-restore boundary

`M9` 不得改写 `M4` / `M5` / `P1-12` / `P1-16` / `M8` 已冻结的 slot、refresh、reopen 或 retarget rail；它只新增“refreshed same-peer recovery 已 restore and consume 后，exactly one direct retarget to one other visible peer 必须 drop old recovered draft”这条更窄合同：一旦 first same-peer reopen 已经恢复并消费 slot，随后 direct retarget 到 other visible peer 时，old recovered draft 不得泄漏到新目标的 draft、send state、summary surface 或任何 hidden fallback state；在该 direct retarget 之后，later reopen 原 peer 也不得 ghost-restore 这份已经恢复并已被丢弃的 old draft。与此同时，detail ownership、summary coherence、`historySize()` 与 `currentPageName()` 必须继续沿用既有 same-package refresh / reopen / retarget rail，且 same-peer refresh、first reopen restore/consume、direct retarget 三步都不得重新创建 recovery slot、secondary persistence 或 recovery model 之外的新隐含状态。

#### M9-REQ-3 same-package bounded scope

该 landed slice 只允许在 `samples/telegram-ui-vertical-slice-001` 的 same-package app-shell / detail / tests 范围内实现、回归、验证与证据收口；不得触碰 `samples/phase07-shared-service-refresh-harness/**`、`samples/real-message-service-cache-001/**`、`P23`、shared helper/API、generic send abstraction、broader UI redesign，或完整 per-peer draft persistence rollout。与此同时，本轮明确不冻结：

- repeated refresh
- third-peer refresh
- 除定义链路所需的 first same-peer reopen restore/consume 之外的 additional reopen-in-between permutation
- 第二次 direct retarget
- back/reopen tail expansion
- generic retarget family
- shared/helper rollout
- generic send expansion
- per-peer draft persistence
- broader mixed-refresh family
- repo-level promotion

#### M9-REQ-4 landed proof and authority boundary

`M9` 的 canonical regression / proof / authority boundary 只允许围绕 `samples/telegram-ui-vertical-slice-001` 的 same-package surface 展开：三条 `M9` 最小回归锁已经纳入 `telegram_ui_vertical_slice_test.cj`，其 landed proof 继续由 `docs/reports/2026-04-20-phase07-m9-telegram-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice.md` 与 `artifacts/verification_contracts/20260420-phase07-telegram-m9-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice/` 中闭合的 `cjpm test` / `timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001` 日志承载。基于这套已 landed 的 proof / report / evidence bundle，live truth surfaces 已收口到 `M9 landed / latest_report = M9 / raw_log_root = M9`；与此同时，next bounded continuation slice 仍待 reviewer 明确批准，且不得把该 slice 外推成更宽的 retarget family、shared/helper、generic send、per-peer persistence、`P23`，或 repo-status promotion。

### 14.3 acceptance criteria

#### M9-AC-1

While active detail 持有未发送 draft 且 `backFromDetail()` 已武装 same-peer recovery slot，when 用户停留在 list route 并先对同一条 peer 执行一次 `refreshConversation(peer, limit)`、随后首次 reopen 同一条 refreshed visible conversation，the Telegram app-shell shall 恢复 draft、把 detail thread ownership 绑定回 refreshed original peer、保持 refreshed summary / bounded history 与既有 refresh / reopen rail 一致，并在该次 restore 后立即消费 recovery slot。

#### M9-AC-2

While the refreshed same-peer recovery draft has already been restored and its slot consumed, when 用户从该 detail 直接 retarget 到一条 other visible peer，the Telegram app-shell shall 把 detail ownership 切到新目标、保持 `currentPageName()` 为 detail 与 `historySize()` 有界，并将 old recovered draft 视为已丢弃状态；it shall not leak that old draft into the other peer's draft, send state, summary surface, or any hidden fallback state.

#### M9-AC-3

While the one-hop direct retarget has already dropped the old recovered draft, when 用户 later reopen 原 peer，the Telegram app-shell shall not ghost-restore that old draft, and it shall keep original-peer summary coherence、other-peer ownership stability、`historySize()`、and `currentPageName()` aligned with the existing same-package retarget / reopen rail。

#### M9-AC-4

When `M9` 被引用时，the spec shall 将其表述为 `M5` 的 refreshed same-peer recovery restore/consume edge 之后追加 exactly one `direct retarget(other visible peer)` 的 bounded sibling slice：它借用 `P1-12` / `P1-16` 已冻结的 retarget coherence rail 来约束 ownership / summary / bounded history，但不得被写成 generic retarget family、`M8` 的简单延长、second direct retarget、back/reopen tail family、shared continuation、per-peer persistence、generic send expansion，或 repo-level promotion。

### 14.4 non-goals

- non-goal：改写 `M4` / `M5` 的 recovery slot 写入、恢复、消费或清空语义。
- non-goal：改写 `P1-12` / `P1-16` 已冻结的 retarget ownership / summary / bounded history rail。
- non-goal：把 `M9` 写成 generic retarget family、second direct retarget、back/reopen tail family，或任何更宽 refresh-retarget permutation。
- non-goal：把 `M9` 回写成 `M8` 的 reverse-order mixed-refresh 续篇、shared continuation、per-peer draft persistence、generic send 扩张、`P23` reopening，或 repo-level promotion。

## 15. M10 Telegram Active-Detail Same-Peer Draft Recovery Repeated Same-Peer Refresh Before First-Reopen Preserve Slice

### 15.1 问题定义

`M5` 已经把 armed same-peer recovery slot 遇到 one-hop list-route same-peer refresh 时仍可在 first same-peer reopen 恢复并消费 draft 的 preserve edge landed；`M9` 则消费了这条 one-hop edge，并把 repeated refresh 明确保留为 deferred gap。当前 reviewer 已明确批准把 `M10` 收口为 landed，因此 `M10` 现已作为 same-package landed Telegram sibling slice 固定如下行为：当 active detail 持有未发送 draft、`backFromDetail()` 已武装 same-peer recovery slot、且用户仍停在 list route 时，若在 first reopen 之前先对同一条 recovery peer 执行一次 `refreshConversation(same peer, limit)`，再在任何 reopen 之前追加 exactly one additional `refreshConversation(same peer, limit)`，则这两次 same-peer refresh 都只允许沿既有 same-peer refresh rail 更新 refreshed summary；draft 仍不得暴露在 list-route surface，single-slot same-peer recovery slot 仍必须保持已武装且不得被扩写成 duplicate slot、secondary persistence 或 per-peer persistence。随后首次 reopen 同一条 refreshed visible conversation时，draft 仍只允许恢复一次，并在该次 restore 后立即消费该唯一 slot。`M10 landed` 只围绕这条建立在 `M5` one-hop preserve 之上的 exact repeated same-peer refresh sibling edge，总计两次 same-peer refresh before first reopen；它不重开 other-peer refresh、mixed-refresh family、direct retarget、`P23` 或 repo-level promotion。

### 15.2 requirements

#### M10-REQ-1 exact two-refresh same-peer preserve chain before first reopen

当 active detail 持有未发送 draft 且 `backFromDetail()` 已按 `M4` / `M5` 合同武装单槽、same-peer、short-lived recovery slot 后，若 shell 仍停在 list route，则 `M10` 只冻结如下严格顺序的一条 repeated same-peer refresh chain：先对原 recovery peer 执行一次 `refreshConversation(same peer, limit)`，再在任何 reopen 之前，对同一条 recovery peer 追加 exactly one additional `refreshConversation(same peer, limit)`。这两次 same-peer refresh 都只允许沿既有 same-peer refresh rail 更新 refreshed same-peer summary，并保持 armed slot 存活；两步都不得暴露 draft，也不得创建、恢复、消费、清空或改写该 armed slot。

#### M10-REQ-2 first reopen restore/consume exactly once after the second same-peer refresh

`M10` 不得改写 `M4` / `M5` 已冻结的 slot 生命周期；它只在 `M5` 的 one-hop same-peer refresh preserve 上，再追加 exactly one additional same-peer refresh，因此总计两次 same-peer refresh before first reopen。完成第二次 same-peer refresh 之后，只有首次 reopen 同一条 refreshed visible conversation 时，Telegram app-shell 才允许恢复该 draft，且必须在这次 restore 后立即消费该唯一 slot；不得因为 repeated same-peer refresh 产生 duplicate slot、secondary persistence、double-restore、重复 consume，或 recovery model 之外的新隐含状态。list-route `updateDetailDraft(...)` / `sendDetailDraft()` 仍必须保持 strict pure no-op，不得创建、恢复、消费、泄漏或清空 recovery slot，也不得对该 repeated-refresh 链路产生任何副作用。

#### M10-REQ-3 same-package bounded scope

该 landed same-package slice 只允许在 `samples/telegram-ui-vertical-slice-001` 的 app-shell / detail / tests 语义范围内收口 authority；其 landed truth 直接复用已经闭合的 proof-round regressions 与 canonical gates，而不新增第二套 evidence bundle。当前 live truth surfaces 已切到 `M10 landed / latest_report = docs/reports/2026-04-21-phase07-m10-telegram-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice.md / raw_log_root = artifacts/verification_contracts/20260421-phase07-telegram-m10-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`。与此同时，本轮明确不冻结：

- other-peer refresh
- repeated other-peer refresh
- third-peer refresh
- direct retarget
- second direct retarget
- additional reopen-in-between permutation
- broader back/reopen tail
- broader mixed-refresh family
- shared/helper rollout
- generic send expansion
- per-peer draft persistence
- repo-level promotion

#### M10-REQ-4 landed proof and authority boundary

`M10` 的 canonical regression / proof / authority boundary 只允许围绕 `samples/telegram-ui-vertical-slice-001` 的 same-package surface 展开：三条 `M10` 最小回归锁已经纳入 `telegram_ui_vertical_slice_test.cj`，其 landed proof 继续由 `docs/reports/2026-04-21-phase07-m10-telegram-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice.md` 与 `artifacts/verification_contracts/20260421-phase07-telegram-m10-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/` 中已闭合的 `cjpm test` / `timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001` 日志承载。基于这套已 landed 的 proof / report / evidence bundle，`M10` 已固定为既有 landed checkpoint；后续 current approved step / latest landed consume entry / `latest_report` / `raw_log_root` 已前移到 `M11 landed`，且不得把 `M10` 或 `M11` 外推成更宽的 repeated-refresh family、other-peer refresh、retarget tail、shared/helper、generic send、per-peer persistence、`P23`，或 repo-status promotion。

### 15.3 acceptance criteria

#### M10-AC-1

While active detail 持有未发送 draft 且 `backFromDetail()` 已武装 same-peer recovery slot，when 用户停留在 list route 并先对同一条 peer 执行一次 `refreshConversation(peer, limit)`、再在任何 reopen 之前对同一条 peer 追加 exactly one additional `refreshConversation(peer, limit)`，the Telegram app-shell shall 继续把 draft 隐藏在 list-route surface 之外，并仅沿既有 same-peer refresh rail 更新 refreshed same-peer summary；both refreshes shall not create, restore, consume, clear, or mutate the armed recovery slot.

#### M10-AC-2

While the same recovery peer has already completed exactly two same-peer refreshes before first reopen, when 用户随后首次 reopen 同一条 refreshed visible conversation，the Telegram app-shell shall 恢复 draft、把 detail thread ownership 绑定回 refreshed original peer、保持 refreshed summary / bounded history 与既有 refresh / reopen rail 一致，并在该次 restore 后立即消费 recovery slot exactly once.

#### M10-AC-3

While the exact `same-peer refresh -> same-peer refresh -> first reopen` chain is the only chain frozen by `M10`, when 用户仅停留在 list route 调用 composer API，the list-route composer API shall remain a strict pure no-op and shall not create, restore, consume, leak, or clear recovery state; it also shall not widen `M10` into other-peer refresh, direct retarget, additional reopen-in-between, or broader mixed-refresh behavior.

#### M10-AC-4

When `M10` 被引用时，the spec shall 将其表述为 `M5` 的 one-hop same-peer refresh preserve edge 之后追加 exactly one additional same-peer refresh 的 landed same-package sibling slice：总计两次 same-peer refresh before first reopen；它自己的 landed truth 继续由 `M10` landed report 与 `M10` proof-round evidence bundle承载，但它已不是当前 canonical latest landed consume entry。它不得被写成 arbitrary repeated-refresh family、other-peer refresh、repeated other-peer refresh、third-peer refresh、direct retarget、second direct retarget、additional reopen-in-between、broader back/reopen tail、broader mixed-refresh family、shared/helper、generic send、per-peer persistence、`P23`，或 repo-level promotion。

### 15.4 non-goals

- non-goal：改写 `M4` / `M5` 已冻结的 recovery slot 写入、恢复、消费或清空语义。
- non-goal：把 `M10` 写成 arbitrary repeated refresh family，而不是“在 `M5` 的 one-hop same-peer refresh preserve 上，再追加 exactly one additional same-peer refresh；总计两次 same-peer refresh before first reopen”。
- non-goal：把 `M10` 外推成 other-peer refresh、repeated other-peer refresh、third-peer refresh、direct retarget、second direct retarget、additional reopen-in-between permutation，或 broader back/reopen tail。
- non-goal：把 `M10` 写成 broader mixed-refresh family、shared continuation、shared/helper 扩张、generic send 扩张、per-peer draft persistence、`P23` reopening，或 repo-level promotion。
- non-goal：把 `M10 landed` 改写成第二套重复 evidence cycle、额外 rerun 结论，或把当前 `raw_log_root` 从承载 landed truth 的 proof-round evidence bundle 外推成新的重复产物。

## 16. M11 Telegram Active-Detail Same-Peer Draft Recovery Third Same-Peer Refresh Before First-Reopen Preserve Slice

### 16.1 问题定义

`M10` 已经把 exact `same-peer refresh -> same-peer refresh -> first same-peer reopen restore/consume exactly once` 这条 two-refresh preserve chain landed，但它只闭合到总计两次 same-peer refresh before first reopen。当前 reviewer 已明确批准把 `M11` 收口为 landed，因此 `M11` 现固定如下 landed same-package 行为：当 active detail 持有未发送 draft、`backFromDetail()` 已武装 same-peer recovery slot、且用户仍停在 list route 时，若在 `M10` 已冻结的两次 same-peer refresh 之后、仍在任何 reopen 之前，对同一条 recovery peer 再追加 exactly one same-peer `refreshConversation(same peer, limit)`，则这第三次 same-peer refresh 仍只允许沿既有 same-peer refresh rail 更新 refreshed summary；draft 仍不得暴露在 list-route surface，single-slot same-peer recovery slot 仍必须保持已武装且不得被扩写成 duplicate slot、secondary persistence 或 per-peer persistence。随后首次 reopen 同一条 refreshed visible conversation 时，draft 仍只允许恢复一次，并在该次 restore 后立即消费该唯一 slot。`M11 landed` 只围绕这条建立在 `M10` exact two-refresh chain 之上的 exact third same-peer refresh sibling edge，总计三次 same-peer refresh before first reopen；它不重开 other-peer refresh、mixed-refresh family、direct retarget、`P23` 或 repo-level promotion。

### 16.2 requirements

#### M11-REQ-1 exact three-refresh same-peer preserve chain before first reopen

当 active detail 持有未发送 draft 且 `backFromDetail()` 已按 `M4` / `M5` / `M10` 合同武装单槽、same-peer、short-lived recovery slot 后，若 shell 仍停在 list route，则 `M11` 只冻结如下严格顺序的一条 third same-peer refresh chain：先完成 `M10` 已冻结的两次 `refreshConversation(same peer, limit)`，再在任何 reopen 之前，对同一条 recovery peer 追加 exactly one same-peer `refreshConversation(same peer, limit)`。这三次 same-peer refresh 都只允许沿既有 same-peer refresh rail 更新 refreshed same-peer summary，并保持 armed slot 存活；三步都不得暴露 draft，也不得创建、恢复、消费、清空或改写该 armed slot。

#### M11-REQ-2 first reopen restore/consume exactly once after the third same-peer refresh

`M11` 不得改写 `M4` / `M5` / `M10` 已冻结的 slot 生命周期；它只在 `M10` 的 exact two-refresh same-peer preserve chain 上，再追加 exactly one same-peer refresh，因此总计三次 same-peer refresh before first reopen。完成第三次 same-peer refresh 之后，只有首次 reopen 同一条 refreshed visible conversation 时，Telegram app-shell 才允许恢复该 draft，且必须在这次 restore 后立即消费该唯一 slot；不得因为 third same-peer refresh 产生 duplicate slot、secondary persistence、double-restore、重复 consume，或 recovery model 之外的新隐含状态。list-route `updateDetailDraft(...)` / `sendDetailDraft()` 仍必须保持 strict pure no-op，不得创建、恢复、消费、泄漏或清空 recovery slot，也不得对该 exact three-refresh 链路产生任何副作用。

#### M11-REQ-3 same-package landed scope

该 landed same-package slice 只允许在 `samples/telegram-ui-vertical-slice-001` 的 app-shell / detail / tests 语义范围内收口 authority；其 landed truth 直接复用已经闭合的 `M11` proof report、三条最小回归锁、canonical gates 与现有 proof-round evidence bundle，而不新增第二套 evidence bundle，也不进行 rerun。当前 live truth surfaces 已切到 `M11 landed / latest_report = docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice.md / raw_log_root = artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`。与此同时，本轮明确不冻结：

- arbitrary repeated-refresh family beyond the exact third same-peer refresh
- other-peer refresh
- repeated other-peer refresh
- third-peer refresh
- direct retarget
- second direct retarget
- additional reopen-in-between permutation
- broader back/reopen tail
- broader mixed-refresh family
- shared/helper rollout
- generic send expansion
- per-peer draft persistence
- repo-level promotion

#### M11-REQ-4 landed authority boundary

`M11` 的 current authority boundary 只允许围绕 `samples/telegram-ui-vertical-slice-001` 的 same-package surface 展开：本轮授权 `requirements/design/tasks`、`docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice.md`、`docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md` 与 `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/` 共同承载 `M11 landed` 的说明面。基于这套 landed authority bundle，live truth surfaces 当前已收口到 `M11 landed / latest landed Telegram consume entry = M11 / latest_report = M11 / raw_log_root = current M11 proof-round bundle`；与此同时，不得把 `M11` 外推成更宽的 repeated-refresh family、other-peer refresh、retarget tail、shared/helper、generic send、per-peer persistence、`P23`，或 repo-status promotion。

### 16.3 acceptance criteria

#### M11-AC-1

While active detail 持有未发送 draft 且 `backFromDetail()` 已武装 same-peer recovery slot，when 用户停留在 list route 并先完成 `M10` 已冻结的两次 same-peer `refreshConversation(peer, limit)`，再在任何 reopen 之前对同一条 peer 追加 exactly one same-peer `refreshConversation(peer, limit)`，the Telegram app-shell shall 继续把 draft 隐藏在 list-route surface 之外，并仅沿既有 same-peer refresh rail 更新 refreshed same-peer summary；all three refreshes shall not create, restore, consume, clear, or mutate the armed recovery slot。

#### M11-AC-2

While the same recovery peer has already completed exactly three same-peer refreshes before first reopen, when 用户随后首次 reopen 同一条 refreshed visible conversation，the Telegram app-shell shall 恢复 draft、把 detail thread ownership 绑定回 refreshed original peer、保持 refreshed summary / bounded history 与既有 refresh / reopen rail 一致，并在该次 restore 后立即消费 recovery slot exactly once。

#### M11-AC-3

While the exact `same-peer refresh -> same-peer refresh -> same-peer refresh -> first reopen` chain is the only chain frozen by `M11`, when 用户仅停留在 list route 调用 composer API，the list-route composer API shall remain a strict pure no-op and shall not create, restore, consume, leak, or clear recovery state; it also shall not widen `M11` into other-peer refresh, direct retarget, additional reopen-in-between, or broader mixed-refresh behavior。

#### M11-AC-4

When `M11` 被引用时，the spec shall 将其表述为 `M10` 的 exact two-refresh same-peer preserve chain 之后追加 exactly one same-peer refresh 的 landed same-package sibling slice：总计三次 same-peer refresh before first reopen；当前 canonical latest landed consume entry / `latest_report` / `raw_log_root` 已切到 `M11`，且 `raw_log_root` 继续直接指向承载当前 landed truth 的 `M11` proof-round evidence bundle。它不得被写成 arbitrary repeated-refresh family、other-peer refresh、repeated other-peer refresh、third-peer refresh、direct retarget、second direct retarget、additional reopen-in-between、broader back/reopen tail、broader mixed-refresh family、shared/helper、generic send、per-peer persistence、`P23`，或 repo-level promotion。

### 16.4 non-goals

- non-goal：改写 `M4` / `M5` / `M10` 已冻结的 recovery slot 写入、恢复、消费或清空语义。
- non-goal：把 `M11` 写成 arbitrary repeated refresh family，而不是“在 `M10` 的 exact two-refresh same-peer preserve chain 上，再追加 exactly one same-peer refresh；总计三次 same-peer refresh before first reopen”。
- non-goal：把 `M11` 外推成 other-peer refresh、repeated other-peer refresh、third-peer refresh、direct retarget、second direct retarget、additional reopen-in-between permutation，或 broader back/reopen tail。
- non-goal：把 `M11` 写成 broader mixed-refresh family、shared continuation、shared/helper 扩张、generic send 扩张、per-peer draft persistence、`P23` reopening，或 repo-level promotion。
- non-goal：把 `M11 landed` 改写成第二套重复 evidence cycle、额外 rerun 结论，或把当前 `raw_log_root` 从承载 landed truth 的现有 `M11` proof-round evidence bundle 外推成新的重复产物。
