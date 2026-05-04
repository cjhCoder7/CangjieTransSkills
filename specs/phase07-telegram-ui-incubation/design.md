# Phase07 Telegram UI Incubation Design

## 1. 设计目标

本设计把 post-P22 的抽象 strategy 收敛为一条新的执行轨定义：

- `Phase07 Telegram UI Incubation` 是独立 continuation lane；
- 它不属于 `Phase06 regular`；
- 它不改写 `P22 / 311/311 live passed`；
- 它不改写 `P23 mechanical-ready = No`；
- 它只为后续 repo-local Telegram UI 骨架扩展定义边界、推荐路线与验证面。

## 2. 样本关系与职责

### 2.1 `samples/telegram-ui-vertical-slice-001`

角色：seed input，且保持 `exploratory`。

它当前提供的价值是：

- 一个 Telegram conversation list -> detail placeholder 的最小 UI skeleton；
- 一个与 `RealMessageService` 风格一致的 repo-local message/domain/refresh wiring；
- 一个可直接用 `cjpm test` 验证的 bounded slice 闭环。

它不提供的价值是：

- Harmony live 证据；
- promoted evidence；
- `Phase06 regular` continuation basis。

### 2.2 `samples/real-message-service-cache-001`

角色：共享 service / cache / refresh / behavior harness 的 authoritative repo-local source。

它贡献的是：

- message-domain 类型、cache / signal / refresh 语义；
- 并发、刷新、中断、source parity、domain purity 的测试护栏；
- Linux `Staging-Core` 下稳定的 repo-local behavior baseline。

Phase07 不应重新发明这套 service 语义，而应优先考虑从这里抽取 shared harness / module boundary。

### 2.3 `samples/ui-routing-defining-page-layout`

角色：最小 page router / page shell / app-shell 组织参考。

它贡献的是：

- root-level 分析层中的 `PageRouter` / route request / list-detail 路由模式；
- repo-local 页面组织和 detail consume boundary；
- 一个接近 app-shell 但仍可在 repo-local 范围讨论的结构模板。

Phase07 应只消费它的路由和页面组织模式，不把其 `entry/` 工程装配层或 IDE/DevEco 导入路径当作当前轨道目标。

## 3. continuation lane 边界

### 3.1 轨道内

- shared harness 抽取与 module boundary 定义；
- repo-local Telegram app-shell prototype consume boundary；
- regression/test-first rail；
- Linux `Staging-Core` compile / test / behavior evidence。

### 3.2 轨道外

- `Phase06 regular` reserve expansion；
- 任何 `P23` freeze / mock / live / coverage / aggregate audit；
- Windows `Staging-Full` claim；
- Harmony live / promoted / Full Pass 叙事。

## 4. 推荐方案

### Recommended: Harness-first incubation lane with regression-first spine

推荐路线按以下顺序推进：

1. 先定义 shared harness / module boundary。
   - 从 `telegram-ui-vertical-slice-001` 中识别 Telegram-specific UI boundary。
   - 从 `real-message-service-cache-001` 中识别可复用的 service / refresh / behavior harness。
2. 再定义 repo-local app-shell prototype consume boundary。
   - 只承接 Telegram session list、detail placeholder、router state 与 minimal shell composition。
   - router / page shell 组织优先参考 `ui-routing-defining-page-layout` 的 root-level 模式。
3. 始终把 regression/test-first rail 作为推进护栏。
   - 每次扩展先回答“要锁什么 compile / unit / behavior surface”，再回答“要多做什么 UI 骨架能力”。

推荐原因：

- 它最符合 Linux `Staging-Core` 的现有强项；
- 它避免把 exploratory sample 直接膨胀成 app 工程；
- 它把“能复用的 service/harness”与“Telegram-specific UI shell”切开，后续更容易持续扩展。

## 5. 备选方案

### Alternative A: App-shell-first prototype

先做 repo-local app-shell prototype，再回补 shared harness。

优点：

- 更快看到 UI skeleton 轮廓。

缺点：

- 容易把 `telegram-ui-vertical-slice-001` 的内嵌 service 逻辑继续复制扩散；
- regression surface 容易滞后，后续返工概率更高。

### Alternative B: Regression-only rail

先只补 regression，再延后 app-shell 和 harness boundary。

优点：

- 风险最低，验证先行。

缺点：

- 无法真正启动新的 Telegram UI continuation lane；
- 只会得到更多验证约束，而没有新的可消费骨架边界。

## 6. 架构草图

建议把 Phase07 视为三个逻辑层：

### 6.1 Shared Harness Layer

- 目标：沉淀可重复使用的 message-domain、cache / signal、dataset refresh、behavior harness。
- 主要来源：`real-message-service-cache-001`
- 使用方式：供 Telegram UI skeleton 消费，但不承诺跨到 live/app 工程。

### 6.2 Telegram UI Skeleton Layer

- 目标：定义 session list、router、detail placeholder、refresh interaction 的最小可持续骨架。
- 主要来源：`telegram-ui-vertical-slice-001`
- 使用方式：作为 Telegram-specific boundary，而不是 promoted sample。

### 6.3 Repo-Local App-Shell Prototype Layer

- 目标：把 Telegram UI skeleton 放进最小 repo-local shell 中，验证 consume boundary 是否成立。
- 主要来源：`ui-routing-defining-page-layout` 的 router/page-shell 组织经验。
- 使用方式：仅证明 repo-local composition，不触发 Windows `Staging-Full` claim。

## 7. staging boundary

### Linux `Staging-Core`

本轨道允许证明：

- repo-local compile；
- repo-local `cjpm test`；
- behavior / routing / refresh regression；
- bounded app-shell prototype 的 repo-local consume boundary。

### Windows `Staging-Full`

本轨道明确不证明：

- Harmony live；
- promoted UI lane；
- Full Pass；
- 任何新的 physical evidence claim。

## 8. 测试与证据策略

Phase07 默认使用 regression/test-first rail：

- service / cache / refresh 语义回归，优先复用 `real-message-service-cache-001` 的 harness 思路；
- router / list-detail consume boundary 回归，优先复用 `ui-routing-defining-page-layout` 的 page-router 测试模式；
- Telegram bounded slice 的 session list / detail placeholder / targeted refresh 回归，保持 seed-level exploratory 语义；
- 所有新结果默认只落在 Linux `Staging-Core` compile / test / behavior 证据，不进入 promotion 话语。

## 9. 设计结论

`Phase07 Telegram UI Incubation` 的推荐推进方式不是重开 `P23`，也不是继续 `Phase06 regular`。推荐方案是：

- 以 `telegram-ui-vertical-slice-001` 为 seed input；
- 以 `real-message-service-cache-001` 为 shared harness 源；
- 以 `ui-routing-defining-page-layout` 为最小 router / app-shell consume 模式；
- 按“shared harness 抽取 -> repo-local app-shell prototype -> regression/test-first 扩展”的顺序推进；
- 全程保持 Linux `Staging-Core` 边界，不触碰 Windows `Staging-Full` claim。

## 10. M4 Telegram Active-Detail Same-Peer Draft Recovery Slice Design

### 10.1 设计目标

`M4` 不是把 composer draft 扩写成完整 persistence 系统，而是在 `M3` 已冻结的 composer 合同之上，只落地一个更窄的 sibling edge：active detail 持有未发送 draft 时，允许 `backFromDetail()` -> reopen same visible conversation 恢复 draft；除此之外仍保持 `M3` 的 send-clear、other-peer clear、list-route no-op 边界。

### 10.2 最小状态模型

推荐设计继续限制在 same-package Telegram sample 内，不引入 shared helper/API：

- active state：
  - `TelegramChatDetailPage.currentConversation`
  - `TelegramChatDetailPage.currentDraft`
- recovery slot：
  - 只记录“最近一次从 detail route 返回 list route 时，是否有一个待恢复的 same-peer unsent draft”
  - 该 slot 必须是单槽、短寿命、peer-bound，而不是 per-peer map
  - recovery slot is consumed on the first same-peer reopen restore and does not survive that restore unless a new unsent draft is edited and backed out again.

该设计的核心约束是：`M4` 允许“同一个 peer 的一次回退后恢复”，但不允许把 draft 生命周期扩成跨 peer、跨 package、或跨 route family 的通用持久化机制。

### 10.3 transition 规则

- active detail edit：
  - `updateDetailDraft(...)` 仍只在 active detail 下写入 `currentDraft`
  - recovery slot 不能由 edit 本身写入；它只允许在 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 时写入
- `backFromDetail()` -> reopen same peer：
  - 当 active detail 存在未发送 draft 且用户执行 `backFromDetail()` 时，detail page 允许把当前 peer + draft 文本暂存进 recovery slot
  - 随后只有首次 reopen 同一条 visible conversation 时，才允许把 slot 内容恢复回 `currentDraft`
  - restore 发生后，该 slot 必须立即被消费；除非用户再次编辑新的未发送 draft 并再次 `backFromDetail()`，否则它不得继续存活
- send after recovery：
  - `sendDetailDraft()` 仍复用现有 same-package send path
  - 一旦发送成功，`currentDraft` 与 recovery slot 都必须清空
- switch to other peer：
  - direct retarget 到其他 peer，或 `backFromDetail()` 后 reopen 另一条 visible conversation，必须丢弃旧 slot 与旧 draft
- list-route no-op：
  - `currentDetailDraft()` 在 list route 下仍返回 empty
  - `updateDetailDraft(...)` / `sendDetailDraft()` 在 list route 下仍保持严格 no-op
  - list-route composer API remains a pure no-op and must not mutate recovery-slot state
  - 该 no-op 不得创建、恢复、消费、泄漏或清空 recovery slot

### 10.4 为什么停在单槽 recovery

不采用 per-peer draft map 或 shared draft store，原因是：

- 用户当前只要求验证一个 bounded same-peer recovery edge；
- `M4` 的 landed 目标是把这条边稳定限制在单槽 same-peer recovery 内，而不是启动更宽的 draft persistence rollout；
- 单槽 recovery 更容易把回归面限定在 `back -> reopen same peer`，避免把 `M3` 的清空边界整体推翻。

### 10.5 最小测试策略

`M4` landed regression 只补三条回归：

- `appShellDetailDraftShouldRecoverAfterBackAndReopenSameConversation`
- `appShellRecoveredDetailDraftShouldStillClearAfterSend`
- `appShellRecoveredDetailDraftShouldDropOnOtherPeerAndListRouteNoop`

在这三条回归之外，`M4` 不应顺手扩写新的 route permutation、shared harness parity、generic send contract，或 broader UI redesign。

## 11. M5 Telegram Active-Detail Same-Peer Draft Recovery Refresh-Before-Reopen Coherence Slice Design

### 11.1 设计目标

`M5` 不新增新的 draft persistence 机制，也不改写 `M4` 已落地的单槽 same-peer recovery lifecycle。它只落地一个更窄的 sibling edge：active detail 持有未发送 draft 时，`backFromDetail()` 已武装 slot，用户仍停在 list route，对同一条 peer 执行一次 `refreshConversation(peer, limit)`，随后首次 reopen 同一条 refreshed visible conversation；在这条边中，draft 仍允许恢复，但 list-route refresh 不能暴露或改写 slot，且 restore 后仍必须立即消费 slot。

### 11.2 最小状态模型

`M5` 继续复用两组既有状态，不引入 shared helper 或 per-peer map：

- `M4` 已有的 active-detail local draft + single-slot same-peer recovery state
- `P1-11` / `P1-15` 已有的 same-package refresh / reopen coherence rail

`M5` 不增加新的 route family、slot family、refresh family 或 generic send layer；它只要求“已武装 slot 的同一 peer list-route refresh”在 refresh rail 上与 recovery rail 共存。

### 11.3 transition 规则

- arm slot：保持 `M4` 不变
  - recovery slot 仍只允许在 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 返回 list route 时写入
  - active detail edit 本身仍不得直接写入 slot
- list-route same-peer refresh while armed：
  - `refreshConversation(peer, limit)` 仍沿既有 list-route refresh rail 更新 refreshed target summary
  - draft 仍不得暴露在 list-route surface
  - 该 refresh 不得创建、恢复、消费、清空或改写 recovery slot
- first reopen same refreshed visible conversation：
  - 仍只有首次 same-peer reopen 才允许 restore draft
  - restore 后 slot 必须立即消费
  - detail thread ownership 必须绑定到 refreshed target
  - bounded history / current page / summary coherence 继续沿用既有 refresh / reopen rail，不新增新 route family
- send after refreshed recovery：
  - `sendDetailDraft()` 仍复用现有 same-package send path
  - 发送成功后仍必须清空 draft / slot
- list-route composer no-op：
  - `updateDetailDraft(...)` / `sendDetailDraft()` 在 list route 下仍是 strict pure no-op
  - list-route composer API remains a pure no-op and must not mutate recovery-slot state

### 11.4 边界收口

- 与 `M4` 的边界：
  - `M4` 只锁定 `backFromDetail()` -> first same-peer reopen 的 recovery edge
  - `M5` 不改写 slot lifecycle，只在两者之间插入一次 list-route same-peer refresh
- 与 `P1-11` 的边界：
  - `P1-11` 锁定的是 list-route `back -> refresh -> reopen refreshed target` 的 summary / detail coherence
  - `M5` 只在这个 refresh / reopen rail 上增加“armed same-peer recovery slot 仍可恢复 draft”的语义
- 与 `P1-15` 的边界：
  - `P1-15` 锁定的是 active-detail target `refresh -> back -> reopen same refreshed target`
  - `M5` 不从 detail 内 refresh 起步，而是从 `M4` 已经 back 到 list 且 slot 已 armed 的状态起步

### 11.5 最小 landed 回归

`M5` landed regression 只补三条最小回归，不在本轮扩写其它 refresh permutation：

- `appShellDraftRecoverySlotShouldSurviveSamePeerRefreshBeforeReopen`
- `appShellRecoveredDraftAfterSamePeerRefreshShouldStillClearAfterSend`
- `appShellListRouteSamePeerRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndBounded`

这三条回归已经作为本次 landed slice 的最小锁定面进入 canonical verification；从当前 verification surface 看，既有 `M4` production code 已满足该更窄的 M5 edge，因此本轮不需要继续扩大 `telegram_ui_slice.cj` 或 `telegram_app_shell.cj` 的行为面，只需补齐回归、evidence 与 state sync。

## 12. M6 Telegram Active-Detail Same-Peer Draft Recovery Other-Peer Refresh Drop Boundary Slice Design

### 12.1 设计目标

`M6` 不新增新的 draft persistence 机制，也不改写 `M4` / `M5` 已落地的单槽 same-peer recovery lifecycle。它只落地一个更窄的 sibling edge：active detail 持有未发送 draft 时，`backFromDetail()` 已武装 slot，用户仍停在 list route，对另一条 visible peer 执行一次 `refreshConversation(peer, limit)`；在这条边中，draft 仍不得暴露，other-peer refresh 也不得 restore slot，但它必须把这个旧 recovery candidate 视为失效并丢弃，因此后续任何 reopen 都不得再恢复 old draft。

### 12.2 最小状态模型

`M6` 继续复用两组既有状态，不引入 shared helper、per-peer map 或新的 hidden fallback state：

- `M4` / `M5` 已有的 active-detail local draft + single-slot same-peer recovery state
- `P1-11` / `P1-15` 已有的 same-package refresh / reopen coherence rail

`M6` 不增加新的 route family、slot family、refresh family 或 generic send layer；它只要求“已武装 slot 的 list-route other-peer refresh”在 refresh rail 上显式成为一个 drop boundary。

### 12.3 transition 规则

- arm slot：保持 `M4` / `M5` 不变
  - recovery slot 仍只允许在 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 返回 list route 时写入
  - active detail edit 本身仍不得直接写入 slot
- list-route other-peer refresh while armed：
  - `refreshConversation(peer, limit)` 仍沿既有 list-route refresh rail 更新 refreshed other-peer summary
  - draft 仍不得暴露在 list-route surface
  - 该 refresh 不得 restore slot
  - 该 refresh 必须使旧 recovery candidate 失效并立即丢弃 armed slot
- reopen after invalidation：
  - reopen 原 peer 时，不得 restore old draft
  - reopen refreshed other peer 时，也不得 restore old draft
  - detail thread ownership、`currentPageName()`、`historySize()` 与 summary coherence 继续沿用既有 refresh / reopen rail，不新增新 route family
- list-route composer no-op：
  - `updateDetailDraft(...)` / `sendDetailDraft()` 在 list route 下仍是 strict pure no-op
  - list-route composer API must not create, restore, consume, leak, or clear recovery state
  - 它也不得创建 recovery model 之外的 secondary hidden fallback state

### 12.4 边界收口

- 与 `M5` 的边界：
  - `M5` 锁定的是 armed slot 遇到 list-route same-peer refresh 时仍可恢复 draft
  - `M6` 锁定的是 armed slot 遇到 list-route other-peer refresh 时必须丢弃 old recovery candidate
  - `M6` 不改写 `M5` 的 same-peer survive edge，只补一个 sibling invalidation edge
- 与 `P1-11` 的边界：
  - `P1-11` 锁定的是 list-route `back -> refresh -> reopen refreshed target` 的 summary / detail coherence
  - `M6` 只在这个 refresh / reopen rail 上增加“armed same-peer recovery slot 在 other-peer refresh 后必须 drop”的语义
- 与 `P1-15` 的边界：
  - `P1-15` 锁定的是 active-detail target `refresh -> back -> reopen same refreshed target`
  - `M6` 不从 detail 内 refresh 起步，而是从 `M4` / `M5` 已经 back 到 list 且 slot 已 armed 的状态起步

### 12.5 最小回归与验证

`M6` landed 只锁定三条最小回归，不扩写其它 refresh permutation：

- `appShellRecoverySlotShouldDropAfterOtherPeerRefreshBeforeReopen`
- `appShellDroppedRecoveryAfterOtherPeerRefreshShouldNotRestoreOnOriginalReopen`
- `appShellOtherPeerRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndListComposerNoop`

本轮实际 write set 继续限制在 `telegram_ui_slice.cj`、`telegram_app_shell.cj` 与 `telegram_ui_vertical_slice_test.cj`；canonical proof 已收口到 `cjpm test` 与 `timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001` 的 `49/49`，并形成 `M6` landed report / evidence bundle / live-truth sync。该 landed design 仍不授权更宽 refresh family、shared helper、generic send、per-peer persistence 或 broader UI redesign。

## 13. M7 Telegram Active-Detail Same-Peer Draft Recovery Same-Peer Refresh Then Other-Peer Drop Slice Design

### 13.1 设计目标

`M7` 不新增新的 draft persistence 机制，也不改写 `M4` / `M5` / `M6` 已落地的单槽 same-peer recovery lifecycle。它只落地一条比 broader mixed-refresh family 更窄的严格顺序组合边：active detail 持有未发送 draft 时，`backFromDetail()` 已武装 slot，用户仍停在 list route，先对同一条 peer 执行一次 `refreshConversation(peer, limit)` 以保持 slot，再在任何 reopen 之前对另一条 visible peer 执行一次 `refreshConversation(peer, limit)`；第二步 other-peer refresh 必须把此前仍存活的 recovery candidate 视为失效并丢弃，因此此后任何 later reopen 都不得再恢复 old draft。

### 13.2 最小状态模型

`M7` 继续复用三组既有状态/rail，不引入 shared helper、per-peer map 或新的 hidden fallback state：

- `M4` 已有的 active-detail local draft + single-slot same-peer recovery state
- `M5` 已有的 list-route same-peer refresh preserve rail
- `M6` 已有的 list-route other-peer refresh invalidation rail

`M7` 不增加新的 route family、slot family、refresh family 或 generic send layer；它只要求“same-peer preserve 之后紧跟 one other-peer drop”在 list-route refresh rail 上显式成为一个严格顺序的二步 landed slice。

### 13.3 transition 规则

- arm slot：保持 `M4` / `M5` / `M6` 不变
  - recovery slot 仍只允许在 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 返回 list route 时写入
  - active detail edit 本身仍不得直接写入 slot
- step 1: list-route same-peer refresh while armed
  - `refreshConversation(same peer, limit)` 仍沿既有 same-peer refresh rail 更新 refreshed same-peer summary
  - draft 仍不得暴露在 list-route surface
  - 该 refresh 不得创建、恢复、消费、清空或改写 armed slot
  - 该 refresh 必须保持 armed slot 继续存活，且不允许在这一步恢复 draft
- step 2: list-route other-peer refresh before any reopen
  - `refreshConversation(other peer, limit)` 仍沿既有 other-peer refresh rail 更新 refreshed other-peer summary
  - draft 仍不得暴露在 list-route surface
  - 该 refresh 不得 restore slot
  - 该 refresh 必须使第一步之后仍存活的 old recovery candidate 失效并立即丢弃 armed slot
- later reopen after second-step drop
  - 第二步发生后，later reopen 不得 restore old draft
  - detail thread ownership、`currentPageName()`、`historySize()` 与 summary coherence 继续沿用既有 refresh / reopen rail
  - 本节不扩写 later reopen 的 wider alternating route family，只要求 old draft 不会幽灵恢复
- list-route composer no-op
  - `updateDetailDraft(...)` / `sendDetailDraft()` 在 list route 下仍是 strict pure no-op
  - list-route composer API must not create, restore, consume, leak, or clear recovery state
  - 它也不得创建 recovery model 之外的 secondary hidden fallback state

### 13.4 边界收口

- 与 `M5` 的边界：
  - `M5` 锁定的是 armed slot 遇到一次 list-route same-peer refresh 时仍可在 first same-peer reopen 恢复 draft
  - `M7` 只复用其中“same-peer refresh preserves slot”这一半，不重写 `M5` 的 first reopen restore edge
- 与 `M6` 的边界：
  - `M6` 锁定的是 armed slot 直接遇到一次 list-route other-peer refresh 时必须丢弃 old recovery candidate
  - `M7` 只复用其中“other-peer refresh drops slot”这一半，并把它严格放在 `M5` preserve 之后
- 与 broader mixed-refresh family 的边界：
  - `M7` 只落地 exactly one same-peer refresh followed by exactly one other-peer refresh
  - `M7` 不冻结 reverse order、arbitrary mixed chain、reopen 插在两次 refresh 之间、double same-peer、double other-peer、third-peer refresh，或 other-peer refresh 后 direct retarget

### 13.5 最小 landed 回归

`M7` landed regression 只补三条最小回归，不扩写更宽 mixed-refresh family：

- `appShellRecoverySlotShouldSurviveSamePeerRefreshThenDropAfterOtherPeerRefreshBeforeReopen`
- `appShellDroppedRecoveryAfterMixedRefreshShouldNotRestoreOnAnyLaterReopen`
- `appShellMixedRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndListComposerNoop`

当前 verification surface 说明现有 `M5/M6` production 行为已经满足这条严格顺序的 mixed-refresh 合同：same-peer refresh 继续 preserve armed slot，而 later other-peer refresh 仍会沿既有 invalidation rail 立即 drop 该 slot。因此本轮 `M7` landed 不需要继续扩大 `telegram_ui_slice.cj` / `telegram_app_shell.cj` 的行为面，只需补齐回归、canonical proof、report/evidence 与 live truth sync；该 landed slice 仍不授权更宽 mixed-refresh family、shared helper、generic send、per-peer persistence 或 broader UI redesign。

## 14. M8 Telegram Active-Detail Same-Peer Draft Recovery Other-Peer Refresh Then Same-Peer Refresh No-Restore Slice Design

### 14.1 设计目标

`M8` 不新增新的 draft persistence 机制，也不改写 `M4` / `M5` / `M6` / `M7` 已落地的单槽 same-peer recovery lifecycle。它只落地一条比 broader mixed-refresh family 更窄的 reverse-order sibling 组合边：active detail 持有未发送 draft 时，`backFromDetail()` 已武装 slot，用户仍停在 list route，先对另一条 visible peer 执行一次 `refreshConversation(peer, limit)` 以 drop slot，再在任何 reopen 之前对原 recovery peer 执行一次 `refreshConversation(peer, limit)`；第二步 same-peer refresh 也不得把此前已被丢弃的 recovery candidate 重新变成可 later reopen 的 restore 来源。

### 14.2 最小状态模型

`M8` 继续复用四组既有状态/rail，不引入 shared helper、per-peer map 或新的 hidden fallback state：

- `M4` 已有的 active-detail local draft + single-slot same-peer recovery state
- `M5` 已有的 list-route same-peer refresh preserve rail
- `M6` 已有的 list-route other-peer refresh invalidation rail
- `M7` 已有的 exactly-two-refresh mixed-refresh framing

`M8` 不增加新的 route family、slot family、refresh family 或 generic send layer；它只要求“one other-peer drop 之后紧跟 one same-peer refresh 仍 no-resurrect”在 list-route refresh rail 上显式成为一个严格顺序的二步 landed-ready slice。

### 14.3 transition 规则

- arm slot：保持 `M4` / `M5` / `M6` / `M7` 不变
  - recovery slot 仍只允许在 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 返回 list route 时写入
  - active detail edit 本身仍不得直接写入 slot
- step 1: list-route other-peer refresh while armed
  - `refreshConversation(other peer, limit)` 仍沿既有 other-peer refresh rail 更新 refreshed other-peer summary
  - draft 仍不得暴露在 list-route surface
  - 该 refresh 不得 restore slot
  - 该 refresh 必须使 armed slot 立即失效并丢弃
- step 2: list-route same-peer refresh after drop
  - `refreshConversation(same recovery peer, limit)` 仍沿既有 same-peer refresh rail 更新 refreshed same-peer summary
  - draft 仍不得暴露在 list-route surface
  - 该 refresh 不得重建、恢复、消费、清空或改写已被丢弃的 old recovery candidate
  - 该 refresh 不得在这一步重新武装 old draft 或让 later reopen 重新可恢复
- later reopen after reverse-order chain
  - 第二步发生后，later reopen 原 recovery peer 或 first-step refreshed other peer 时都不得 restore old draft
  - detail thread ownership、`currentPageName()`、`historySize()` 与 summary coherence 继续沿用既有 refresh / reopen rail
  - 本节不扩写 reopen 插在两步之间或更宽 alternating route family
- list-route composer no-op
  - `updateDetailDraft(...)` / `sendDetailDraft()` 在 list route 下仍是 strict pure no-op
  - list-route composer API must not create, restore, consume, leak, or clear recovery state
  - 它也不得创建 recovery model 之外的 secondary hidden fallback state

### 14.4 边界收口

- 与 `M6` 的边界：
  - `M6` 锁定的是 armed slot 直接遇到一次 list-route other-peer refresh 时必须丢弃 old recovery candidate
  - `M8` 只复用其中“first-step other-peer refresh drops slot”这一半，并在其后严格补一跳 same-peer refresh no-resurrect
- 与 `M7` 的边界：
  - `M7` 锁定的是 exactly one `same-peer refresh -> other-peer refresh` mixed-refresh sibling edge
  - `M8` 只交换前两步顺序，锁定 exactly one `other-peer refresh -> same-peer refresh` reverse-order sibling edge
- 与 broader mixed-refresh family 的边界：
  - `M8` 只落地 exactly one other-peer refresh followed by exactly one same-peer refresh
  - `M8` 不冻结 repeated refresh、reopen 插在两次 refresh 之间、third-peer refresh、arbitrary mixed chain，或 other-peer refresh 后 direct retarget

### 14.5 最小 landed-ready 回归

`M8` landed attempt 只补三条最小回归，不扩写更宽 mixed-refresh family：

- `appShellRecoverySlotShouldDropBeforeSamePeerRefreshCanRearmOrRestore`
- `appShellDroppedRecoveryAfterReverseOrderMixedRefreshShouldNotRestoreOnAnyLaterReopen`
- `appShellReverseOrderMixedRefreshWhileRecoveryArmedShouldKeepDraftHiddenAndListComposerNoop`

基于当前 `M6/M7` landed 语义，可以合理预期现有 production 行为大概率已经满足这条 reverse-order sibling 合同：一旦 first-step other-peer refresh 已沿 `M6` invalidation rail 丢弃 slot，later same-peer refresh 理论上不应再有可 preserve / restore 的 recovery candidate。但该判断在 proof 闭合前只是一条 landed-attempt 假设，不替代回归与 canonical proof；本节仍不授权更宽 mixed-refresh family、shared helper、generic send、per-peer persistence 或 broader UI redesign。

## 15. M9 Telegram Active-Detail Same-Peer Draft Recovery Refresh-Reopen Then Direct-Retarget Other-Peer Drop Slice Design

### 15.1 设计目标

`M9` 不新增新的 draft persistence 机制，也不把 direct retarget 扩写成 generic family。它只消费 `M5` 已冻结的 refreshed same-peer recovery edge：active detail 持有未发送 draft 时，`backFromDetail()` 已武装 slot，用户在 list route 先对同一条 peer 执行一次 refresh，再首次 reopen 同一条 refreshed visible conversation 以 restore and consume draft；只有在这次 restore/consume 已经发生之后，才允许 exactly one direct retarget 到一条 other visible peer。`M9` 要锁定的是这次 retarget 的 drop / no-leak / no-ghost-restore 行为，而不是重新打开 `M8` 的 pre-reopen no-resurrect family 或更宽的 retarget/back/reopen family。

### 15.2 最小状态模型

`M9` 继续复用四组既有状态/rail，不引入 shared helper、per-peer map、secondary recovery slot 或新的 hidden fallback persistence：

- `M4` 已有的 active-detail local draft + single-slot same-peer recovery state
- `M5` 已有的 list-route same-peer refresh preserve + first reopen restore/consume rail
- `P1-12` 已有的 `refresh -> reopen -> retarget` ownership / summary / bounded-history coherence rail
- `P1-16` 已有的 detail-route direct-retarget ownership / bounded-history rail

`M9` 与 `M8` 的关系只停留在边界层：`M8` 锁定的是 restore 之前的 pre-reopen drop/no-resurrect；`M9` 锁定的是 restore/consume 之后的 one-hop direct-retarget drop/no-leak/no-ghost-restore。它不增加新的 route family、slot family、retarget family 或 generic send layer；它只要求“已 restore and consume 的 same-peer recovered draft，在 exactly one direct retarget 到 other peer 时必须 drop 且不可复活”。

### 15.3 transition 规则

- arm slot：保持 `M4` / `M5` 不变
  - recovery slot 仍只允许在 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 返回 list route 时写入
  - active detail edit 本身仍不得直接写入 slot
- step 1: list-route same-peer refresh while armed
  - `refreshConversation(same recovery peer, limit)` 仍沿既有 same-peer refresh rail 更新 refreshed same-peer summary
  - draft 仍不得暴露在 list-route surface
  - 该 refresh 不得 restore、consume、clear 或改写 armed slot
- step 2: first same-peer reopen after refresh
  - 仍只有首次 reopen 同一条 refreshed visible conversation 时才允许 restore recovered draft
  - restore 发生后 slot 必须立即消费
  - detail thread ownership 必须绑定回 refreshed original peer
  - 这一步只消费 `M5` 已冻结的 preserve/restore edge，不新增新的 reopen family
- step 3: direct retarget to one other visible peer after recovery consumption
  - direct retarget 仍沿既有 detail-route retarget rail 切到 other visible peer
  - `currentPageName()` 继续保持 detail，`historySize()` 继续保持有界，detail thread ownership 必须切到新目标
  - original refreshed peer summary 继续留在 list surface，other visible peer summary 不得被 old draft 污染
  - old recovered draft 不得被复制到新目标的 `currentDraft`、pending send state、summary surface 或 hidden fallback state
  - 该 retarget 不得重新创建 recovery slot，也不得把已消费的恢复状态重新武装
- later reopen original peer after direct retarget
  - later reopen 原 peer 时不得 ghost-restore 已恢复并已丢弃的 old draft
  - reopen 后的 detail/list ownership、summary coherence、`historySize()` 与 `currentPageName()` 继续沿用既有 retarget / reopen rail
  - 本节只用这一跳 later reopen 作为 no-ghost-restore 断言，不扩写 second direct retarget、alternating reopen、或 broader back/reopen tail family

### 15.4 边界收口

- 与 `M5` 的边界：
  - `M5` 锁定的是 armed slot 遇到 same-peer refresh 后，first same-peer reopen 仍可 restore and consume draft
  - `M9` 只消费这条 restore/consume edge，并在其后追加 exactly one direct retarget-other-peer drop/no-leak/no-ghost-restore
- 与 `M8` 的边界：
  - `M8` 锁定的是 `other-peer refresh -> same-peer refresh` 的 pre-reopen no-resurrect sibling edge
  - `M9` 不讨论 slot 在 reopen 之前如何 drop；它只讨论 slot 已 restore and consume 之后的一跳 direct retarget drop boundary
- 与 `P1-12` 的边界：
  - `P1-12` 锁定的是 list-route `refresh -> reopen -> retarget` 的 route / summary coherence
  - `M9` 只借用其中 refresh-reopen-retarget 的 ownership / bounded-history rail，但额外加上 recovered draft 必须 drop/no-leak/no-ghost-restore 的约束
- 与 `P1-16` 的边界：
  - `P1-16` 锁定的是 active-detail target `refresh -> direct retarget other visible conversation`
  - `M9` 只借用其中 direct-retarget 的 detail ownership / bounded-history rail；它不把 active-detail refresh 重新引入为 generic retarget family
- 与 broader family 的边界：
  - `M9` 只落地 exactly one same-peer refresh、one first same-peer reopen restore/consume、and exactly one direct retarget to one other visible peer
  - `M9` 不冻结 repeated refresh、third-peer refresh、除定义链路所需 restore/reopen 之外的 additional reopen-in-between permutation、second direct retarget、或 broader back/reopen tail family

### 15.5 最小 landed 回归锁与 authority 收口

`M9` 已以三条最小 landed 回归锁完成 authority 收口，不扩写 generic retarget family：

- `appShellRecoveredDraftAfterSamePeerRefreshReopenShouldDropOnDirectRetargetToOtherPeer`
- `appShellDirectRetargetAfterRecoveredDraftShouldNotGhostRestoreOnLaterOriginalPeerReopen`
- `appShellRefreshReopenRetargetAfterRecoveryShouldKeepOtherPeerOwnershipAndBoundedHistory`

这三条回归分别锁定：

- refreshed same-peer recovery 已 restore/consume 后，direct retarget 到 other peer 会丢弃 old recovered draft，且不把它泄漏到新目标
- 上述 direct retarget 之后，later reopen original peer 不得 ghost-restore old recovered draft
- 整条 refresh-reopen-retarget 链路继续保持 other-peer ownership、summary coherence 与 bounded history，而不膨胀成更宽 route family

这三条回归已经作为 `M9` 的最小 landed 回归锁进入 canonical verification。当前 landed proof 继续由 `docs/reports/2026-04-20-phase07-m9-telegram-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice.md` 与 `artifacts/verification_contracts/20260420-phase07-telegram-m9-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice/` 承载，live truth surfaces 已切到 `M9 landed / latest_report = M9 / raw_log_root = M9`；与此同时，next bounded continuation slice 仍待 reviewer 明确批准，本节也不授权 shared/helper、generic send、per-peer persistence、`P23` 或 repo-level promotion。

## 16. M10 Telegram Active-Detail Same-Peer Draft Recovery Repeated Same-Peer Refresh Before First-Reopen Preserve Slice Design

### 16.1 设计目标

`M10` 当前已是 landed slice。它只把 `M9` 明确留空的 repeated same-peer refresh gap 收口为 current landed Telegram sibling edge：active detail 持有未发送 draft 时，`backFromDetail()` 已武装 slot，用户仍停在 list route，先对同一条 recovery peer 执行一次 same-peer refresh，再在任何 reopen 之前对同一条 recovery peer 追加 exactly one additional same-peer refresh；这两次 refresh 都必须继续 preserve 同一个 armed slot，draft 仍不得暴露，随后首次 reopen 同一条 refreshed visible conversation 时，draft 仍只允许 restore and consume exactly once。`M10` 锁定的是这条 two-refresh same-peer preserve 链，而不是把 repeated refresh 扩写成 broader family、mixed-refresh family、或 direct-retarget/back-reopen tail family。

### 16.2 最小状态模型

`M10` 继续复用三组既有状态/rail，不引入 shared helper、per-peer map、secondary recovery slot 或新的 hidden fallback persistence：

- `M4` 已有的 active-detail local draft + single-slot same-peer recovery state
- `M5` 已有的 list-route one-hop same-peer refresh preserve + first reopen restore/consume rail
- 既有 same-package refresh / reopen coherence rail

`M10` 与 `M9` 的关系只停留在 deferred-gap 层：`M9` 消费的是 `M5` one-hop preserve 之后的 restore/consume -> direct-retarget drop boundary；`M10` 则回到 first reopen 之前，只在 `M5` 的 one-hop same-peer refresh preserve 上，再追加 exactly one additional same-peer refresh，总计两次 same-peer refresh before first reopen。它不增加新的 route family、slot family、peer family、retarget family 或 generic send layer；它只要求“同一 recovery peer 的第二次 same-peer refresh”继续 preserve 同一个 armed slot，而不是把 recovery 模型扩成 repeated-refresh driven persistence。

### 16.3 transition 规则

- arm slot：保持 `M4` / `M5` 不变
  - recovery slot 仍只允许在 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 返回 list route 时写入
  - active detail edit 本身仍不得直接写入 slot
- step 1: first list-route same-peer refresh while armed
  - `refreshConversation(same recovery peer, limit)` 仍沿既有 same-peer refresh rail 更新 refreshed same-peer summary
  - draft 仍不得暴露在 list-route surface
  - 该 refresh 不得 restore、consume、clear 或改写 armed slot
  - 该 refresh 必须保持 armed slot 继续存活
- step 2: exactly one additional list-route same-peer refresh before first reopen
  - 第二步仍必须是对同一条 recovery peer 的 same-peer refresh，而不是 other-peer refresh、mixed refresh 或 retarget
  - 该 additional refresh 仍只允许沿既有 same-peer refresh rail 更新 refreshed same-peer summary
  - draft 仍不得暴露在 list-route surface
  - 该 refresh 同样不得 restore、consume、clear、复制、拆分或改写 armed slot
  - 完成第二步后，系统中仍只允许存在同一个 single-slot、same-peer、short-lived armed recovery slot
- step 3: first same-peer reopen after the second refresh
  - 仍只有首次 reopen 同一条 refreshed visible conversation 时才允许 restore recovered draft
  - restore 发生后 slot 必须立即消费，且只能消费一次
  - detail thread ownership 必须绑定回 refreshed original peer
  - 这一步只消费 `M5` 已冻结的 first-reopen restore/consume rail，不新增新的 reopen family
- list-route composer no-op
  - `updateDetailDraft(...)` / `sendDetailDraft()` 在 list route 下仍是 strict pure no-op
  - list-route composer API must not create, restore, consume, leak, or clear recovery state
  - 它也不得把这条 two-refresh chain 外推成 secondary persistence 或更宽的 route family

### 16.4 边界收口

- 与 `M5` 的边界：
  - `M5` 锁定的是 armed slot 遇到 one-hop list-route same-peer refresh 时仍可在 first same-peer reopen 恢复 draft
  - `M10` 只在这条 one-hop preserve 之上，再追加 exactly one additional same-peer refresh
  - `M10` 反复绑定到同一个结论：总计两次 same-peer refresh before first reopen
- 与 `M9` 的边界：
  - `M9` 锁定的是 `same-peer refresh -> first same-peer reopen restore/consume -> exactly one direct retarget(other peer)` 的 post-recovery drop/no-leak/no-ghost-restore
  - `M10` 不重开这条 direct-retarget tail，也不消费 restore 之后的 retarget family
  - `M10` 只停留在 first reopen 之前的 repeated same-peer refresh preserve 问题
- 与 broader family 的边界：
  - `M10` 只冻结 exactly two total same-peer refreshes before first reopen
  - `M10` 不冻结 other-peer refresh
  - `M10` 不冻结 repeated other-peer refresh
  - `M10` 不冻结 third-peer refresh
  - `M10` 不冻结 direct retarget
  - `M10` 不冻结 second direct retarget
  - `M10` 不冻结 additional reopen-in-between permutation
  - `M10` 不冻结 broader back/reopen tail
  - `M10` 不冻结 broader mixed-refresh family
  - `M10` 不冻结 shared/helper、generic send、per-peer persistence、`P23` 或 repo-level promotion

### 16.5 最小 landed 回归锁与 authority 收口

`M10` 当前已 landed。它的 landed proof / authority surface 只允许围绕 `samples/telegram-ui-vertical-slice-001` 的 same-package surface 展开，并继续维持“在 `M5` 的 one-hop same-peer refresh preserve 上，再追加 exactly one additional same-peer refresh；总计两次 same-peer refresh before first reopen”的收口。当前 `M10` 由三条最小 landed 回归锁与同一套已闭合的 canonical gates 承载：

- `appShellRecoverySlotShouldStayHiddenAcrossRepeatedSamePeerRefreshes`
- `appShellRepeatedSamePeerRefreshBeforeFirstReopenShouldStillRestoreAndConsumeExactlyOnce`
- `appShellRepeatedSamePeerRefreshWhileRecoveryArmedShouldKeepSummaryBoundedAndListComposerNoop`
- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`

当前 landed proof 由 `docs/reports/2026-04-21-phase07-m10-telegram-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice.md` 与 `artifacts/verification_contracts/20260421-phase07-telegram-m10-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/` 承载；这是对已闭合 proof-round evidence 的 landed truth sync，不是二次 rerun。尽管当前 canonical landed consume entry / `latest_report` / `raw_log_root` 已进一步前移到 `M11 landed`，`M10` 仍保留为既有 landed checkpoint。本节也不得借机外推到 arbitrary repeated-refresh family、other-peer refresh、mixed-refresh family、direct-retarget tail、shared/helper、generic send、per-peer persistence、`P23` 或任何更宽的 repo-level claim。

## 17. M11 Telegram Active-Detail Same-Peer Draft Recovery Third Same-Peer Refresh Before First-Reopen Preserve Slice Design

### 17.1 设计目标

`M11` 当前是 latest landed slice。它只把 `M10` 已收口的 exact two-refresh same-peer preserve gap 再向前延长一步：active detail 持有未发送 draft 时，`backFromDetail()` 已武装 slot，用户仍停在 list route，先完成 `M10` 已冻结的两次 same-peer refresh，再在任何 reopen 之前对同一条 recovery peer 追加 exactly one same-peer refresh；这三次 refresh 都必须继续 preserve 同一个 armed slot，draft 仍不得暴露，随后首次 reopen 同一条 refreshed visible conversation 时，draft 仍只允许 restore and consume exactly once。`M11` 锁定的是这条 exact third same-peer refresh preserve 链，而不是把 repeated refresh 扩写成 broader family、mixed-refresh family、或 direct-retarget/back-reopen tail family。

### 17.2 最小状态模型

`M11` 继续复用三组既有状态/rail，不引入 shared helper、per-peer map、secondary recovery slot 或新的 hidden fallback persistence：

- `M4` 已有的 active-detail local draft + single-slot same-peer recovery state
- `M10` 已有的 exact two-refresh same-peer preserve + first reopen restore/consume rail
- 既有 same-package refresh / reopen coherence rail

`M11` 与 `M10` 的关系只停留在 deferred-gap 层：`M10` 锁定的是 `M5` one-hop preserve 之上的第二次 same-peer refresh；`M11` 则只在 `M10` 的 exact two-refresh chain 上，再追加 exactly one same-peer refresh，总计三次 same-peer refresh before first reopen。它不增加新的 route family、slot family、peer family、retarget family 或 generic send layer；它只要求“同一 recovery peer 的第三次 same-peer refresh”继续 preserve 同一个 armed slot，而不是把 recovery 模型扩成 arbitrary repeated-refresh driven persistence。

### 17.3 transition 规则

- arm slot：保持 `M4` / `M5` / `M10` 不变
  - recovery slot 仍只允许在 active detail 持有未发送 draft 且用户执行 `backFromDetail()` 返回 list route 时写入
  - active detail edit 本身仍不得直接写入 slot
- step 1 and step 2: first two list-route same-peer refreshes while armed
  - 沿用 `M10` 已冻结的两次 same-peer refresh preserve 规则
  - 两步都只允许沿既有 same-peer refresh rail 更新 refreshed same-peer summary
  - draft 仍不得暴露在 list-route surface
  - 两步都不得 restore、consume、clear 或改写 armed slot
- step 3: exactly one additional list-route same-peer refresh before first reopen
  - 第三步仍必须是对同一条 recovery peer 的 same-peer refresh，而不是 other-peer refresh、mixed refresh 或 retarget
  - 该 additional refresh 仍只允许沿既有 same-peer refresh rail 更新 refreshed same-peer summary
  - draft 仍不得暴露在 list-route surface
  - 该 refresh 同样不得 restore、consume、clear、复制、拆分或改写 armed slot
  - 完成第三步后，系统中仍只允许存在同一个 single-slot、same-peer、short-lived armed recovery slot
- step 4: first same-peer reopen after the third refresh
  - 仍只有首次 reopen 同一条 refreshed visible conversation 时才允许 restore recovered draft
  - restore 发生后 slot 必须立即消费，且只能消费一次
  - detail thread ownership 必须绑定回 refreshed original peer
  - 这一步只消费 `M5` / `M10` 已冻结的 first-reopen restore/consume rail，不新增新的 reopen family
- list-route composer no-op
  - `updateDetailDraft(...)` / `sendDetailDraft()` 在 list route 下仍是 strict pure no-op
  - list-route composer API must not create, restore, consume, leak, or clear recovery state
  - 它也不得把这条 three-refresh chain 外推成 secondary persistence 或更宽的 route family

### 17.4 边界收口

- 与 `M10` 的边界：
  - `M10` 锁定的是 exact two total same-peer refreshes before first reopen
  - `M11` 只在这条 exact two-refresh preserve 之上，再追加 exactly one same-peer refresh
  - `M11` 反复绑定到同一个结论：总计三次 same-peer refresh before first reopen
- 与 `M9` 的边界：
  - `M9` 锁定的是 `same-peer refresh -> first same-peer reopen restore/consume -> exactly one direct retarget(other peer)` 的 post-recovery drop/no-leak/no-ghost-restore
  - `M11` 不重开这条 direct-retarget tail，也不消费 restore 之后的 retarget family
  - `M11` 只停留在 first reopen 之前的 exact third same-peer refresh preserve 问题
- 与 broader family 的边界：
  - `M11` 只冻结 exactly three total same-peer refreshes before first reopen
  - `M11` 不冻结 arbitrary repeated-refresh family
  - `M11` 不冻结 other-peer refresh
  - `M11` 不冻结 repeated other-peer refresh
  - `M11` 不冻结 third-peer refresh
  - `M11` 不冻结 direct retarget
  - `M11` 不冻结 second direct retarget
  - `M11` 不冻结 additional reopen-in-between permutation
  - `M11` 不冻结 broader back/reopen tail
  - `M11` 不冻结 broader mixed-refresh family
  - `M11` 不冻结 shared/helper、generic send、per-peer persistence、`P23` 或 repo-level promotion

### 17.5 最小 landed authority 收口

`M11` 当前已经 landed，且 same-package proof 已先前闭合。它的 current landed authority surface 只允许围绕 `samples/telegram-ui-vertical-slice-001` 的 same-package surface 展开，并继续维持“在 `M10` 的 exact two-refresh same-peer preserve chain 上，再追加 exactly one same-peer refresh；总计三次 same-peer refresh before first reopen”的收口。当前 `M11` 由以下 landed surfaces 承载：

- `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
- `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice.md`
- `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
- `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`

当前 landed authority 直接复用已闭合的 `cjpm test`、runtime gate、supporting proof report 与 proof bundle，不进行 rerun，也不生成第二套 evidence bundle。当前 latest landed consume entry / `latest_report` / `raw_log_root` 已切到 `M11`；本节也不得借机把 `M11` 写成 arbitrary repeated-refresh family、other-peer refresh、mixed-refresh family、direct-retarget tail、shared/helper、generic send、per-peer persistence、`P23`，或任何更宽的 repo-level claim。
