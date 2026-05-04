# Skill Metadata
- Skill ID: `ARCH-STATE-OWNERSHIP-LIFECYCLE-001`
- Skill Name: `state-ownership-and-lifecycle`
- Skill Class: `Architecture`
- Scope: 该 Skill 用于指导 Agent 在 ArkTS 的 `@StorageLink`、`AppStorage`、跨页面共享状态、`SignalKit` 响应式分发等场景下，如何在仓颉侧重新建立状态所有权、生命周期、线程提交点与状态投影结构。该 Skill 不负责具体业务页面 UI 编写，而负责“谁拥有状态、谁可以写、谁只读、何时创建、何时释放、何时持久化”的系统级约束。
- Tags: `state`, `ownership`, `lifecycle`, `appstorage`, `storagelink`, `signalkit`, `architecture`, `main-thread`, `projection`, `global-store`, `cangjie`, `arkts`
- Version: `V2.0-initial`

# Trigger Condition
- 任务触发条件：当需求中出现跨页面共享状态、应用级状态、全局 Store、`@StorageLink`、`AppStorage`、`SignalKit`、ViewModel 共享数据、页面恢复状态、缓存回填、状态投影、页面销毁后状态仍需保留等问题时，应装载本 Skill。
- 强制触发条件：当任务同时涉及“跨页面共享状态 + 生命周期管理”“后台数据更新 + UI 主线程提交”“页面状态与全局状态拆分”“ArkTS 共享状态机制迁移到仓颉”时，必须优先装载本 Skill，不能只依赖页面级 UI Skill 或 Preferences Skill。
- 不适用条件：如果任务只是单页瞬态开关、单个按钮点击、完全不跨页面共享的局部表单状态，且没有状态持久化、响应式流、后台更新或全局依赖，则不应优先使用本 Skill。

# Core Concept
- 最短知识结论：ArkTS 中看似统一的共享状态写法，在仓颉侧必须拆成“页面瞬态状态”“共享领域状态”“持久化状态”“衍生投影状态”四类对象分别管理。
- 最短知识结论：任何跨页面共享状态都必须先定义所有者、写入权限、生命周期和主线程提交点，再决定 UI 如何绑定。
- 最短知识结论：`SignalKit` 一类响应式流不应被直接等同于页面状态；它更接近“状态变更通道”或“事件流”，通常要经过 Store 或 Projection 层收敛后才能驱动 UI。
- 一句话风险提示：最危险的误用是把 `AppStorage`、`@StorageLink` 或 `Signal` 直译成页面字段共享，从而导致状态真值混乱、跨线程写 UI、生命周期泄漏和重复订阅。

# Architecture Mapping
- 源侧角色：ArkTS 页面内部的 `@State`；跨页面共享的 `@StorageLink`；应用级键值共享入口 `AppStorage`；全局 `AppState`；`SignalKit` 提供的 `Signal<T>` 与订阅；ViewModel 中用于承接服务流和页面展示的协调对象。
- 目标侧角色：仓颉页面局部状态容器；全局或领域级 `GlobalStore` / `DomainStore`；只读状态投影对象 `StateProjection`；持久化适配器 `PersistenceAdapter`；事件或信号输入通道 `StateEventStream`；负责主线程提交的 `StateCoordinator` 或 ViewModel。
- 保留策略：可以保留“页面只消费状态投影、服务层提供领域事件、ViewModel 负责组装页面展示模型”的总体思路；可以保留按业务域拆 Store 的方式；可以保留通过状态对象驱动 UI 的声明式更新模式。
- 重构策略：不能把 `AppStorage` 直译成任意页面都可写的全局可变字典；不能把 `@StorageLink` 直译成多个页面共享同一可变字段引用；不能让 `Signal<T>` 直接作为 UI 的长期真值来源；必须重构为“事件流输入 -> Store 合并 -> Projection 投影 -> 主线程提交 -> 页面消费”的结构。

# Dependency Constraint
- 必需依赖：`SKILL_SCHEMA_V2.md` 中的 V2 字段理解；UI 主线程边界知识；Preferences 或持久化基础知识；页面生命周期与路由生命周期知识；依赖注入或服务定位基础模式。
- 可选依赖：`data-persistence-preferences` 这类存储 Skill；`page-routing-and-param-passing` 这类页面生命周期 Skill；未来的 `main-thread-ui-boundary`、`signal-based-reactive-pipeline`、`cache-coherency-and-derived-state` Skill。
- 冲突依赖：把所有共享状态都塞进页面字段的模式；直接暴露可变全局字典给页面写入的模式；在后台线程直接修改 ArkUI 状态的模式；页面销毁后仍保留未解除的订阅模式。
- 环境前提：如果当前环境没有 DevEco Studio、仓颉插件、可编译样例或真实运行环境，则本 Skill 应优先输出架构设计、类职责与验证矩阵，不应冒进声称“已验证运行无误”。

# Boundary Contract
- 边界类型：页面局部状态与全局共享状态边界；响应式事件流与稳定真值状态边界；后台更新与 UI 主线程提交边界；内存态与持久化态边界。
- 输入：用户交互事件、路由进入事件、服务层事件、网络同步结果、持久化恢复结果、信号流推送、页面销毁事件。
- 输出：页面可消费的状态投影、领域 Store 中的稳定状态、持久化刷盘请求、订阅解除动作、错误状态对象或诊断日志。
- 生命周期归属：页面瞬态状态由页面实例持有并随页面销毁而释放；领域共享状态由 `GlobalStore` 或 `DomainStore` 持有；持久化状态由持久化适配器持有其外部表示；投影对象由 ViewModel 或协调器按页面生命周期生成与销毁。
- 资源释放责任：页面离开时由页面或 ViewModel 解除订阅；Store 关闭时由协调器或应用容器清理观察者；持久化适配器负责刷盘和句柄关闭；事件流生产方不得要求页面直接承担底层资源释放。
- 错误传递方式：底层事件流错误先映射为领域错误，再由协调器投影为页面可显示状态；持久化失败应转化为可重试或降级的状态，不应直接污染页面局部状态；后台更新冲突应通过日志与状态快照暴露，而不是静默覆盖。

# Execution Topology
- 线程模型：后台线程、网络线程或服务线程负责接收外部事件和恢复持久化数据；状态归并逻辑可以在后台层执行；最终驱动 UI 的状态提交必须在主线程发生；页面组件只能消费已经完成归并和投影的状态对象。
- 主线程提交点：页面 `aboutToAppear`、ViewModel 绑定回调、全局状态变更后投影刷新、页面重新激活后的状态重绑定，这些步骤中的 UI 可见状态赋值必须回到主线程。
- 后台处理点：从 `SignalKit`、网络响应、持久化恢复、长连接推送中获取的原始更新，应先在后台完成解析、归并、去重、优先级判断和状态写入，再产生主线程可消费的最小投影。
- 串行要求：同一份领域状态的写入必须有明确串行入口；同一聊天时间线、同一认证态、同一会话列表的真值更新不能由多个页面直接并发写入；订阅解除和页面销毁应有确定顺序。
- 批处理要求：高频更新应先合并再提交 UI；同一事务中的多个字段变化应打包为单次状态提交；后台恢复大批数据时应先构建新投影，再统一切换页面状态引用，避免页面逐字段抖动刷新。

# State Contract
- 状态所有者：页面输入框内容、弹窗开关、局部筛选条件等瞬态状态由页面持有；认证态、当前用户、会话列表、主题设置、通知配置等共享状态由 `GlobalStore` 或特定 `DomainStore` 持有；持久化快照由 `PersistenceAdapter` 管理；`SignalKit` 或服务事件流本身不是状态所有者，而是状态变更输入通道。
- 真值来源：页面瞬态状态以页面内存为准；共享业务状态以领域 Store 为准；重启后可恢复的配置以持久化层恢复值为初始化来源；远端同步结果在成功归并后更新领域 Store；页面展示始终以投影层输出为准，而不是直接以事件流当前值为准。
- 可变字段：允许直接修改的只有 Store 内部的源状态字段和页面局部瞬态字段；持久化适配器内部允许修改序列化表示；页面投影对象原则上只读。
- 衍生字段：按钮文案、列表排序结果、筛选后的可见集合、组合状态说明、已读计数展示文本、主题展示名称等都属于衍生字段，只能通过源状态计算得出，不能由页面直接写回。
- 持久化策略：认证态、主题配置、通知开关、上次选中的全局偏好等稳定配置可持久化；页面临时输入、临时弹窗、滚动位置默认不持久化，除非明确有恢复需求；持久化动作由 Store 或协调器触发，不由页面散点触发。
- 一致性规则：页面投影与 Store 冲突时以 Store 为准；Store 与持久化快照冲突时，以最新有效写入策略决定，通常启动时由持久化初始化，运行中由 Store 主导并回写持久化；远端同步结果进入系统后，以领域归并规则决定是否覆盖本地乐观状态；事件流重复到达时必须先去重再投影。

# Progressive Modules
## Module 1：概念最小版
ArkTS 里的共享状态机制不能机械理解为“哪里都能直接读写的公共变量”。在仓颉侧，至少要先区分四种对象：

1. 页面瞬态状态；
2. 领域共享状态；
3. 持久化稳定状态；
4. 事件流与投影状态。

最小原则如下：

- 页面只拥有自己的瞬态状态；
- 共享真值进入 Store；
- 信号流只负责传递变化，不负责长期持有真值；
- UI 只绑定投影，不直接绑定底层事件源。

## Module 2：常见映射
常见 ArkTS 共享状态模式与仓颉侧推荐映射如下：

| ArkTS 源模式 | 语义 | 仓颉侧推荐目标 | 说明 |
|---|---|---|---|
| `@State` | 页面局部瞬态状态 | 页面局部状态字段或局部状态对象 | 随页面生命周期创建与销毁 |
| `@StorageLink('theme')` | 页面与共享状态双向绑定 | `GlobalStore.theme` + 页面只读投影 + 显式更新方法 | 不建议直接暴露双向可变引用 |
| `AppStorage.SetOrCreate('notify', true)` | 应用级共享键值真值或初始化值 | `SettingsStore` + `PersistenceAdapter` | 初始化和持久化要显式化 |
| `Signal<T>` | 事件推送 / 响应式流 | `StateEventStream<T>` + `Store.apply(event)` | 事件流不是长期真值 |
| 全局 `AppState` | 应用级共享对象 | `GlobalStore` 或多个 `DomainStore` | 推荐按业务域拆分，避免单体巨型对象 |

## Module 3：跨层模式
推荐采用四层组织：

1. **Persistence Adapter 层**：负责加载和保存稳定状态；
2. **Store / Coordinator 层**：负责维护领域真值、应用归并规则、对外提供只读快照；
3. **Projection / ViewModel 层**：负责根据领域真值生成页面可消费对象；
4. **Page 层**：负责持有局部瞬态状态，并消费投影结果。

推荐的数据流方向如下：

```text
持久化恢复 / 网络事件 / Signal 事件
    ↓
StateCoordinator 或 DomainStore.apply(event)
    ↓
更新共享真值并生成 Projection
    ↓
主线程提交 Projection 到页面
    ↓
页面只渲染和处理局部瞬态交互
    ↓
用户动作经显式命令回到 Coordinator 或 Store
```

不推荐的数据流方向如下：

```text
Signal 事件
    ↓
页面直接接收
    ↓
页面直接改全局字段
    ↓
其他页面依赖共享引用自动变化
```

这种模式虽然在小 Demo 中看似快捷，但在大型工程里会导致写入路径失控。

## Module 4：工程级约束
在 Telegram 级别应用或类似的大型鸿蒙工程中，状态所有权必须满足以下工程约束：

- 同一份全局状态必须有单一写入入口；
- 页面之间只能共享真值快照或受控命令接口，不能共享任意可变引用；
- 所有高频事件都先进入后台归并，再统一主线程提交；
- 订阅的创建与释放必须绑定生命周期；
- 任何需要跨应用重启保留的状态，都必须显式声明持久化策略；
- 派生字段必须统一在 Projection 层生成，避免不同页面各算一份导致不一致。

# Translation Mapping
- ArkTS 对应写法：`@StorageLink` 常表现为页面直接绑定应用级共享状态；`AppStorage` 常表现为全局键值共享入口；`SignalKit` 常表现为订阅式数据推送；`AppState` 常表现为全局共享对象；页面可通过装饰器直接感知变化。
- 仓颉对应写法：优先把 ArkTS 共享状态拆分为 `GlobalStore`、`DomainStore`、`StateProjection`、`PersistenceAdapter`、`StateCoordinator` 五类角色。页面通过 ViewModel 或 Coordinator 获取只读投影，通过显式命令方法修改共享状态；事件流经 `apply(event)` 进入 Store，而不是直接驱动 UI 字段。
- 允许差异：可以根据业务复杂度，把 `GlobalStore` 再拆为 `AuthStore`、`SettingsStore`、`ChatListStore`、`MessageTimelineStore` 等多个领域 Store；可以在小样本中先使用单一协调器，但仍要保持只读投影和显式更新命令的结构。
- 禁止直译点：禁止把 `@StorageLink` 机械翻译成多个对象共享同一可变字段引用；禁止把 `AppStorage` 机械翻译成任何模块都能随意写的全局字典；禁止把 `Signal<T>` 当前值当成页面的长期真值；禁止让页面在订阅回调里直接承担持久化职责。

# Performance Envelope
- 主线程预算：主线程不应承担大批量状态归并、排序、去重、信号风暴处理或持久化恢复计算；主线程只接收已经准备好的投影对象或最小状态差量。
- 吞吐量关注点：当状态更新频率很高时，最危险的是每次事件都直接触发页面重绘；应优先合并事件、压缩重复更新、按页面可见性裁剪投影。
- 内存关注点：避免为每个页面复制完整全局状态；避免投影对象无限缓存历史版本；避免未释放订阅导致隐藏页面仍持有大对象快照。
- 建议优化手段：按业务域拆 Store；按页面可见范围生成投影；对高频事件使用批量提交；对只读派生结果引入缓存失效机制；对页面销毁触发订阅释放和投影回收。

# Failure Model
- 常见编译失败：试图把页面局部状态对象直接注入为全局共享对象时，容易出现类型职责混淆；把只读投影对象当作可写对象使用时，容易出现接口不匹配；在没有上下文注入的情况下访问持久化适配器时，容易出现依赖缺失。
- 常见运行失败：页面销毁后订阅未释放，导致旧页面继续接收更新；后台线程直接推动 UI 状态，导致主线程违规更新；多个页面同时修改同一共享状态，导致最后写入者覆盖前者；事件流重复到达但未去重，导致页面抖动或重复渲染。
- 高风险误用：把全局状态对象暴露为公开可变对象；把持久化快照直接当成运行时真值；把 Projection 层省略掉，让页面直接订阅底层 Store 或 Signal；在业务增长后仍维持一个巨大单体 `AppState` 承担所有领域职责。
- 恢复策略：先检查状态所有者是否唯一，再检查写入路径是否集中，再检查订阅生命周期是否与页面绑定，再检查主线程提交点是否明确，最后检查持久化恢复是否覆盖了运行中真值。必要时输出状态快照日志，定位是“重复写入”“旧订阅泄漏”还是“错误线程提交”。

# Verification Matrix
- 单元测试：验证 Store 的 `apply(event)` 是否遵守单一写入入口；验证 Projection 是否由源状态正确导出；验证页面局部状态不会反向污染全局状态；验证持久化恢复后状态初始化逻辑是否正确。
- Fake / Mock：使用 Fake PersistenceAdapter 模拟本地恢复和保存；使用 Fake EventStream 模拟 `SignalKit` 推送；使用 Fake Scheduler 或主线程派发器模拟后台归并后主线程提交；使用 Fake Store 记录写入次数和最后状态快照。
- 集成测试：组合 ViewModel、Store、PersistenceAdapter、EventStream，验证页面进入、状态恢复、用户动作修改、页面离开后的订阅释放；验证跨页面共享主题或通知开关时，两个页面观察到的投影是否一致。
- 手动验证：在 DevEco 环境中验证页面多次进入离开后是否仍有旧状态残留；验证主题切换或通知开关在多个页面中是否同步；验证应用重启后稳定配置是否恢复；验证后台恢复数据后 UI 是否只发生一次稳定刷新。
- 观测指标：记录 Store 写入次数、Projection 重建次数、订阅数量、页面销毁后的活动订阅数量、主线程提交计数、持久化恢复耗时、状态冲突日志。

# Composition With Other Skills
- 前置 Skill：`SKILL_SCHEMA_V2`；页面生命周期相关 Skill；持久化 Skill；未来的主线程边界 Skill。
- 常见组合：与 `data-persistence-preferences` 组合时，可形成“稳定配置 + 全局 Store + 页面投影”的完整方案；与 UI 路由 Skill 组合时，可形成“路由进入后恢复投影、路由离开后释放订阅”的闭环；与未来的 `signal-based-reactive-pipeline` 组合时，可形成“事件流输入到状态真值”的完整路径。
- 覆盖关系：本 Skill 会覆盖页面级 UI Skill 中关于共享状态的默认直觉写法；一旦任务涉及跨页面共享状态，应优先以本 Skill 的所有权与生命周期规则为准，再决定具体 UI 绑定方式。
- 禁止组合：禁止与“页面直接写全局字典”的模式共存；禁止与“事件流直接当真值”的模式共存；禁止与“页面任意持有长期订阅但不解除”的模式共存。

# Retrieval Fallback
- 官方文档入口：优先检索鸿蒙 ArkUI 状态管理文档、Ability 生命周期文档、仓颉 ArkUI 声明式开发文档、仓颉互操作与状态管理相关官方资料。
- 仓库检索入口：优先检索 `TelegramHarmony` 中的 `AppState.ets`、`Signal.ets`、`LoginViewModel.ets`、`ChatListViewModel.ets`、`ServiceLocator.ets`、`AuthStorage.ets`；在本仓库中优先检索 `docs/architecture/skill-taxonomy-and-schema-evolution.md` 与各样本中的状态、持久化、UI 注入记录。
- CLI / Python 检索示例：`rg -n "AppStorage|@StorageLink|@ObservedV2|@Trace|Signal|DisposableSet|AppState" /path/to/repo`；`rg -n "state|store|projection|lifecycle|subscription|dispose" docs skills samples`；`python scripts/search_docs.py --query "ArkUI state management AppStorage lifecycle" --source official`。
- 升级提问模板：如果当前代码里共享状态来源不明，应向人类或上层系统询问：“这份状态是否跨页面共享、是否需要持久化、谁应拥有写权限、页面销毁后是否必须保留、后台更新是否可能修改它？”

# Security / Privacy Constraint
- 敏感数据范围：认证状态、当前用户信息、会话状态、通知偏好、主题配置、聊天摘要、未读计数、页面快照和任何能够反推用户行为的状态数据都可能敏感。
- 脱敏规则：轨迹和日志中记录状态快照时，应删去 token、手机号、聊天内容正文、用户唯一标识、设备标识和文件路径；如果只需排查状态流向，应优先记录字段名和状态类别，不记录真实值。
- 本地存储要求：认证态和会话态不得默认明文写入；稳定配置可按平台能力持久化，但应明确区分“普通偏好”和“高敏感状态”；高敏感状态应优先走安全存储或加密封装。
- 日志限制：禁止把完整全局 Store、完整页面状态、完整消息列表或完整用户资料直接写入日志；禁止在错误日志中输出能复现用户隐私的完整状态对象。

# Migration Strategy
- 小样本做法：在小样本中可以先用单一 `SettingsStore` 或 `AppStateCoordinator` 表示共享真值，再通过页面 Projection 消费；可以暂时用 Fake PersistenceAdapter 和 Fake EventStream 完成验证。
- 工程级替代方案：在真实大型工程中，应按业务域拆分为 `AuthStore`、`SettingsStore`、`ChatListStore`、`MessageTimelineStore`、`ConnectionStore` 等多个领域 Store，并引入更明确的依赖注入与生命周期容器。
- 何时升级：当共享状态开始跨越多个页面和多个业务域；当同一状态既受本地恢复又受远端同步影响；当页面数量、订阅数量、恢复逻辑显著增长；当状态冲突与订阅泄漏变得难以排查时，必须从单体全局对象升级为领域化状态架构。
- 升级检查点：升级后必须重新验证写入入口是否唯一、主线程提交点是否清晰、订阅释放是否完备、持久化边界是否明确、派生状态是否仍保持一致。

# Examples
- 示例一：概念性状态分层示意

```text
class SettingsStore {
    private var sourceState: SettingsSourceState

    func apply(command: SettingsCommand): Unit
    func snapshot(): SettingsSnapshot
}

class SettingsProjectionFactory {
    func forThemePage(snapshot: SettingsSnapshot): ThemePageProjection
    func forNotificationPage(snapshot: SettingsSnapshot): NotificationPageProjection
}

class ThemePageViewModel {
    private let store: SettingsStore
    private let projectionFactory: SettingsProjectionFactory

    func bind(): ThemePageProjection
    func changeTheme(nextTheme: ThemeMode): Unit
}

Page 只拿到 ThemePageProjection。
Page 修改主题时调用 ViewModel.changeTheme。
ViewModel 再把命令交给 SettingsStore.apply。
SettingsStore 决定是否回写 PersistenceAdapter。
```

- 示例二：错误模式与修正模式对照

```text
错误模式：
PageA 持有 GlobalState 引用并直接写 theme。
PageB 也持有同一引用并在订阅回调中直接写 notify。
Signal 事件到达后，两个页面都可能在各自生命周期里直接修改共享对象。
结果是写入路径不可追踪，页面销毁后仍可能继续改状态。

修正模式：
GlobalStore 是共享状态唯一所有者。
PageA 和 PageB 只拿各自 Projection。
所有修改都通过显式命令进入 Coordinator 或 Store。
Signal 事件也只进入 Coordinator，再由 Coordinator 串行更新 Store。
页面销毁时只解除订阅，不负责共享真值销毁。
```

# Test & Debug
- 快速验证步骤：先画出当前任务涉及的状态清单，并标记每项是页面瞬态、共享真值、持久化状态还是事件流；再检查每项状态是否只有一个所有者；再检查页面是否只消费投影；最后再补代码实现。
- 排错顺序：先查是否存在多个写入入口；再查是否有页面直接持有全局可变引用；再查订阅是否在页面离开时释放；再查后台事件是否绕过 Store 直接改 UI；最后查持久化恢复是否覆盖了运行中状态。
- 常见误判：看到两个页面显示不同，不一定是 UI 渲染问题，往往是投影来源不一致；看到状态重置，不一定是持久化失效，可能是页面瞬态状态误当共享状态；看到订阅重复触发，不一定是事件源重复，可能是旧页面订阅未解除。

# Sources
- `skills/SKILL_SCHEMA_V2.md`
- `docs/architecture/skill-taxonomy-and-schema-evolution.md`
- `docs/architecture/telegram-arkts-teardown-001.md`
- `https://github.com/ForestBook/TelegramHarmony`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/README.md`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/entry/src/main/ets/app/AppState.ets`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/entry/src/main/ets/viewmodel/LoginViewModel.ets`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/entry/src/main/ets/viewmodel/ChatListViewModel.ets`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/common/signalkit/src/main/ets/Signal.ets`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/core/services/src/main/ets/ServiceLocator.ets`
- `/tmp/docs_cangjie_inspect/en/Overview-of-Cangjie-capabilities-in-OpenHarmony.md`
- `/tmp/docs_cangjie_inspect/en/application-dev/reference/arkinterop/cj-apis-ark_interop.md`

# Known Gaps
- 当前仓库环境无法直接在 DevEco Studio 中对仓颉状态管理实现做编译验证，因此本文中的仓颉侧角色划分属于架构推导与迁移规范，不是已运行通过的最终实现。
- 当前公开资料能够确认 ArkTS 侧存在 `AppState`、ViewModel、`SignalKit` 等模式，但对仓颉 ArkUI 在复杂全局状态共享场景中的最佳工程实践，仍需后续结合 IDE、官方样例和可编译项目继续细化。
- `SignalKit` 在具体页面中的完整生命周期绑定细节仍需继续从更多源码路径中提炼；当前 Skill 已给出安全上界和推荐模式，但未来仍应用更多样本校准。

# Evolution Log
- `2026-03-26`：首版创建，基于 `SKILL_SCHEMA_V2` 正式起草；目标是作为第一个 Architecture 级 Skill 试点，验证 V2 对状态边界、线程拓扑和生命周期约束的表达能力。
- `2026-03-26`：明确将 ArkTS 的 `@StorageLink`、`AppStorage`、`SignalKit` 拆分为“状态真值”“事件流输入”“页面投影”“持久化快照”四类角色，作为后续大型工程翻译的默认约束。
