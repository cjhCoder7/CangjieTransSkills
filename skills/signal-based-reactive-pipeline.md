# Skill Metadata
- Skill ID: `ARCH-REACTIVE-PIPELINE-001`
- Skill Name: `signal-based-reactive-pipeline`
- Skill Class: `Architecture`
- Scope: 该 Skill 用于指导 Agent 将 ArkTS 或 Swift 中基于 Signal、Observer、Subscriber、Disposable、map/filter/flatMap 等机制构建的响应式管道，迁移为适配仓颉强类型与并发边界的事件流、变换层、状态投影层和主线程 UI 提交层。该 Skill 重点解决的是“响应式流怎么组织、在哪个线程变换、何时释放订阅、如何安全进入 UI”，而不是页面布局或具体业务 API。
- Tags: `signal`, `reactive`, `observer`, `disposable`, `pipeline`, `signalkit`, `swift`, `arkts`, `main-thread`, `background-transform`, `projection`, `architecture`, `cangjie`
- Version: `V2.0-initial`

# Trigger Condition
- 任务触发条件：当需求中出现 `SignalKit`、Signal、Observer、Subscriber、Disposable、DisposableSet、`map`、`filter`、`flatMap`、`Promise`、异步流、流式更新、链式事件处理、订阅释放、主线程回投、跨页面数据推送等关键词时，应装载本 Skill。
- 强制触发条件：当任务同时涉及“后台事件流变换 + UI 状态更新”“`SignalKit` 到仓颉的迁移”“页面销毁与订阅释放”“高频推送消息流或聊天更新管道”“Swift Signal / ArkTS Signal 模型映射”时，必须优先装载本 Skill，不能只依赖普通异步 API Skill 或单页状态 Skill。
- 不适用条件：如果任务只是单次 HTTP 请求、一次性 `await` 调用、没有持续订阅、没有链式变换、没有事件流生命周期管理，也没有跨页面或高频更新需求，则不应优先使用本 Skill。

# Core Concept
- 最短知识结论：Signal 不是页面状态本身，而是“状态变化的运输带”；页面应消费投影结果，不应长期持有底层事件流作为真值来源。
- 最短知识结论：所有 `map`、`filter`、`merge`、`flatMap`、去重、批处理等信号变换应尽量发生在后台线程或非 UI 线程，主线程只负责最终投递和页面可见状态提交。
- 最短知识结论：Disposable 的本质不是语法糖，而是生命周期契约；谁创建订阅，谁就必须知道何时释放它。
- 一句话风险提示：最危险的误用是让页面直接订阅底层 Signal 并在回调里做计算、改全局状态或忘记释放订阅，这会引发主线程卡顿、重复渲染、幽灵更新和内存泄漏。

# Architecture Mapping
- 源侧角色：ArkTS `SignalKit` 中的 `Signal<T>`、订阅回调、`Disposable`、`DisposableSet`、链式变换操作；Swift 中的 Signal、Observer、Subscriber、Disposable 或类似响应式抽象；服务层返回的持续更新流；ViewModel 内部的订阅协调逻辑。
- 目标侧角色：仓颉中的 `EventStream<T>` 或等价事件通道；纯函数变换层 `PipelineStage`；集中式订阅协调器 `ReactiveCoordinator`；主线程投递器 `UiDispatchSink`；生命周期容器 `SubscriptionBag`；状态归并目标 `Store` 或 `ProjectionSink`。
- 保留策略：可以保留“以流为中心的异步编排”思想；可以保留基于 `map`、`filter`、`flatMap`、去重和合并的阶段式处理；可以保留用 Disposable 统一管理订阅生命周期的实践；可以保留由 ViewModel 或协调器充当页面与服务流之间的桥接角色。
- 重构策略：不能把源侧 Signal 直接等同为页面字段或全局真值；不能让页面直接承担复杂链式变换；不能让订阅释放依赖页面自然销毁的偶然行为；必须重构为“事件源 -> 后台变换管道 -> Store 或 Projection 收敛 -> 主线程投递 -> 页面消费”的明确分层。

# Dependency Constraint
- 必需依赖：`SKILL_SCHEMA_V2.md`；`state-ownership-and-lifecycle.md`；页面生命周期与 UI 主线程边界知识；异步编程与错误传播基础知识；日志与追踪基础能力。
- 可选依赖：未来的 `main-thread-ui-boundary` Skill；未来的 `message-delta-merge-and-batching` Skill；存储和缓存相关 Skill；路由生命周期 Skill；全局状态与 Projection 相关 Skill。
- 冲突依赖：页面直接订阅服务底层流并做重计算的模式；把 Disposable 忽略为“可有可无”的模式；后台线程直接推送 UI 可见状态的模式；让多个页面分别订阅同一底层高频流并各自独立做去重与合并的模式。
- 环境前提：如果当前环境没有仓颉 IDE、没有可编译的响应式运行时封装、没有明确的 UI 主线程调度 API，则该 Skill 应优先输出架构分层、流向图、释放策略和测试矩阵，不应冒进声称“已完成运行时对接”。

# Boundary Contract
- 边界类型：服务层事件流与状态层边界；后台流处理与主线程 UI 提交边界；页面生命周期与订阅生命周期边界；响应式错误通道与页面展示错误边界。
- 输入：网络推送、长连接消息、数据库监听结果、持久化恢复信号、用户交互命令转换出的事件、重试信号、取消信号、页面进入退出事件。
- 输出：经过变换和收敛的领域事件、批处理后的状态更新、页面可消费的投影对象、错误事件、完成事件、订阅句柄和释放动作。
- 生命周期归属：底层流由服务层或协调器拥有；变换管道由 `ReactiveCoordinator` 或 ViewModel 创建；页面只持有与自身绑定的订阅句柄；主线程投递器不拥有业务真值，只负责安全切换上下文。
- 资源释放责任：创建订阅的一方负责释放订阅；页面离开时释放页面级订阅；ViewModel 销毁时释放 ViewModel 级订阅；应用级长寿命流由应用容器或服务层负责关闭；错误恢复和重试逻辑不能通过遗忘旧 Disposable 来实现。
- 错误传递方式：底层流错误先映射为领域错误，再决定是中断当前管道、触发重试、输出降级状态还是投递到页面错误投影；页面不应直接感知底层异常细节，而应感知已分类的业务错误或可重试状态。

# Execution Topology
- 线程模型：事件源可能来自网络线程、后台线程、Socket 回调线程或持久化恢复线程；`map`、`filter`、`flatMap`、去重、归并、节流、批处理等操作默认应在后台线程或非 UI 线程执行；最终把结果写入页面可见状态或 UI 绑定对象时，必须切回主线程。
- 主线程提交点：只有在生成最终 `Projection`、更新 UI 绑定状态、触发页面局部刷新、提交可见错误提示、切换加载态时，才允许进入主线程；主线程不负责处理原始高频消息流。
- 后台处理点：从 `SignalKit`、Swift Signal、服务层事件流进入后的所有中间变换阶段，包括 `map`、`filter`、`flatMap`、合并、重试、去抖、去重、排序、批量压缩、领域事件规范化，都应在后台完成。
- 串行要求：同一份状态真值的最终写入应有单一串行入口；同一底层流不应被多个页面独立重复消费后再争夺真值更新；`flatMapLatest`、取消旧请求、会话切换时的旧订阅清理必须有明确顺序，避免过期结果回写。
- 批处理要求：高频更新流应支持节流、背压或窗口批处理；聊天列表、消息时间线、通知计数等高频状态不应逐条直接投递 UI；当短时间内有多个事件命中同一页面区域时，应先后台聚合，再进行单次主线程提交。

# State Contract
- 状态所有者：Signal 或事件流不拥有最终业务真值；最终真值由 `Store` 或领域协调器持有；页面只拥有局部瞬态状态和订阅句柄；主线程投递器不拥有状态，只负责上下文切换。
- 真值来源：服务流提供的是“变化输入”或“变化候选”，不是页面长期真值；只有经过 Store 归并后的共享状态才是业务真值；页面展示以投影结果为准，而不是以最近一次事件为准。
- 可变字段：可变字段只存在于 Store 的源状态和页面局部瞬态状态中；管道中的中间对象应尽量视为不可变数据；Projection 原则上应只读。
- 衍生字段：加载文案、按钮可点击状态、聊天摘要展示文本、过滤结果、排序结果、空态提示、错误提示文案等，都属于衍生字段，应从源状态和事件结果计算生成，而不是在流回调中直接多处写入。
- 持久化策略：响应式流本身通常不持久化；需要跨重启保留的是归并后的稳定状态、缓存索引或用户设置；管道中间态、临时订阅、瞬时错误不应默认持久化。
- 一致性规则：多个事件同时到达时，以领域归并规则为准，不以到达某个页面的先后顺序为准；取消后的旧流结果不得覆盖新流；后台变换结果必须在进入 UI 之前再次确认其上下文仍有效，例如当前页面仍活跃、当前会话仍匹配。

# Progressive Modules
## Module 1：概念最小版
响应式管道至少拆成四个层次：

1. 事件源层；
2. 后台变换层；
3. 状态归并或投影层；
4. 主线程 UI 投递层。

最小原则如下：

- Signal 不是 UI 状态；
- 变换发生在后台；
- 页面只消费投影；
- 订阅必须可释放；
- 主线程只做最终投递。

## Module 2：常见映射
常见源侧响应式概念与仓颉侧推荐角色如下：

| 源侧概念 | 语义 | 仓颉侧推荐目标 | 说明 |
|---|---|---|---|
| `Signal<T>` | 连续异步事件流 | `EventStream<T>` 或同等事件通道 | 不等同于共享真值 |
| `Observer` / `Subscriber` | 事件接收方 | `PipelineSink<T>` / `ProjectionSink<T>` | 建议分离后台处理与 UI 投递 |
| `Disposable` | 订阅释放句柄 | `SubscriptionToken` / `Cancelable` | 必须绑定生命周期 |
| `DisposableSet` | 多订阅统一释放 | `SubscriptionBag` | 页面或 ViewModel 离开时统一清理 |
| `map` / `filter` / `flatMap` | 流变换 | `PipelineStage` 组合 | 默认后台执行 |
| `deliverOnMainQueue` | 主线程回投 | `UiDispatchSink` / `MainThreadDispatcher` | 只放最终状态投递 |
| `Promise` / `Future` | 单次异步结果 | `Future<T>` / `TaskResult<T>` | 与持续流区分 |

## Module 3：跨层模式
推荐采用“五段式响应式管道”：

1. **Source 层**：网络、Socket、存储监听、用户事件形成原始事件流；
2. **Transform 层**：后台线程执行 `map`、`filter`、`flatMap`、归一化、去重、重试；
3. **Merge 层**：把多个流合并为领域事件，并处理取消、上下文切换、版本冲突；
4. **State Sink 层**：把领域事件应用到 Store 或 Projection Factory；
5. **UI Dispatch 层**：将最终投影安全提交到主线程页面。

推荐流程如下：

```text
SignalSource / ServiceStream / Swift Signal
    ↓
Background Transform Stages
    ↓
Merge / Switch / Retry / Cancel Coordination
    ↓
Store.apply(event) 或 ProjectionFactory.build(snapshot)
    ↓
MainThreadDispatcher.submit(projection)
    ↓
Page / ViewModel 更新可见状态
```

不推荐流程如下：

```text
Service Signal
    ↓
Page subscribe
    ↓
Page 内 map/filter/排序
    ↓
Page 直接改共享状态
    ↓
页面销毁后遗留订阅继续工作
```

该反模式在高频流场景下会迅速失控。

## Module 4：工程级约束
Telegram 级别的响应式管道必须满足以下约束：

- 任何高频消息流都必须有批处理或背压策略；
- 任何 UI 绑定前都必须完成后台归并；
- 任何订阅都必须有清晰的拥有者和释放点；
- 任何取消旧请求的场景都必须阻断过期结果回写；
- 任何跨页面共享的流都不应让页面各自重复消费底层源，而应先由共享协调器收敛；
- 任何错误都应通过统一错误通道分类，避免页面到处散落 `catch` 分支。

# Translation Mapping
- ArkTS 对应写法：`SignalKit` 中通过 `Signal<T>` 返回连续事件；ViewModel 或服务层可能使用 `start`、订阅回调和 `DisposableSet` 管理订阅；响应式链条可包含 `map`、`filter`、`flatMap`、重试和状态更新。
- 仓颉对应写法：推荐抽象出 `EventStream<T>`、`ReactiveCoordinator`、`PipelineStage`、`SubscriptionBag`、`UiDispatchSink`、`Store` / `ProjectionFactory` 等角色。持续流与单次异步结果区分建模；流变换放入后台管道；最终结果先归并为领域状态或投影，再经主线程投递到页面。
- 允许差异：小样本阶段可以先用较少的层，例如 `ReactiveCoordinator + SubscriptionBag + Store` 三层组合；如果仓颉未来提供成熟的原生响应式流库，可以把自定义 `EventStream` 角色映射到官方抽象，但仍要保留线程边界和释放契约。
- 禁止直译点：禁止把每个 Signal 回调都直接映射成页面回调；禁止把 `Disposable` 忽略为普通局部变量；禁止在主线程做复杂 `map`、`filter`、排序、去重；禁止把持续流误建模为单次 `Future` 导致丢失取消、重试和多次事件语义。

# Performance Envelope
- 主线程预算：主线程只允许接收已经完成收敛的投影或最小状态差量；不应在主线程执行长链 `map`、`filter`、批量对象创建、排序、消息去重或重试编排。
- 吞吐量关注点：聊天消息流、未读计数、在线状态、连接状态、下载进度等高频事件会迅速放大错误的订阅设计；必须避免每个事件都触发整页重绘。
- 内存关注点：长寿命 Signal 容易导致订阅链和闭包长期持有大对象；页面销毁后若未释放订阅，会持续保留页面投影和上下文；`flatMap` 嵌套过深会产生难以管理的中间对象和取消路径。
- 建议优化手段：使用共享协调器统一消费底层源；使用批处理和节流压缩 UI 投递；对高频流使用去重和投影缓存；在 ViewModel 和页面级引入 `SubscriptionBag`；把错误恢复和取消逻辑集中到协调器层。

# Failure Model
- 常见编译失败：将持续流误建模为单次结果对象时，容易出现接口不匹配；把 UI 调度器和后台变换器职责混在一起时，容易导致类型和依赖注入错误；忘记为订阅句柄预留生命周期容器时，容易出现资源管理结构缺失。
- 常见运行失败：页面多次进入退出后订阅叠加；旧请求完成后覆盖新上下文状态；后台线程直接写 UI 造成线程违规；高频流逐条主线程投递导致卡顿；错误通道未统一导致某些流默默终止而页面无感知。
- 高风险误用：在页面内直接对底层 Signal 做复杂链式变换；多个页面重复订阅同一底层高频流；将 `Disposable` 放在局部函数里不统一管理；取消旧流时只创建新订阅、不释放旧订阅；把错误恢复写成页面层零散重试。
- 恢复策略：先检查订阅的拥有者与释放点；再检查后台变换是否误跑到主线程；再检查旧流取消后是否仍能回写状态；再检查是否由共享协调器统一消费底层流；最后检查错误通道是否把终止、重试、降级三种路径区分清楚。

# Verification Matrix
- 单元测试：验证 `PipelineStage` 的 `map`、`filter`、`flatMap`、去重、重试规则是否正确；验证取消旧流后过期结果不会继续投递；验证批处理后只生成一次主线程提交；验证 `SubscriptionBag` 清理后不再接收新事件。
- Fake / Mock：使用 Fake EventSource 模拟高频消息流；使用 Fake MainThreadDispatcher 记录主线程投递次数；使用 Fake Store 或 Fake ProjectionSink 验证归并结果；使用 Fake Scheduler 验证后台与主线程阶段分离是否正确。
- 集成测试：组合 ServiceStream、ReactiveCoordinator、Store、UiDispatchSink 和 ViewModel，验证页面进入、接收流、切换上下文、取消旧流、页面退出释放订阅的完整闭环；验证聊天列表和消息详情共享同一底层事件源时不会重复消费底层流。
- 手动验证：在 DevEco 或真实运行环境中验证页面快速切换时是否仍有旧数据闪回；验证高频消息进入时 UI 是否保持流畅；验证页面退出后日志中订阅计数是否归零；验证错误或断线后是否进入预期的重试或降级状态。
- 观测指标：记录底层事件流吞吐量、后台变换耗时、主线程投递次数、订阅数量、页面级活动订阅数、取消次数、重试次数、错误通道命中次数、批处理压缩比。

# Composition With Other Skills
- 前置 Skill：`SKILL_SCHEMA_V2`；`state-ownership-and-lifecycle`；未来的主线程边界 Skill；日志与追踪 Skill。
- 常见组合：与 `state-ownership-and-lifecycle` 组合时，可形成“事件流输入 -> Store 真值 -> Projection 页面投影”的完整闭环；与未来的 `message-delta-merge-and-batching` 组合时，可形成高频消息流的完整收敛方案；与页面生命周期 Skill 组合时，可形成订阅创建与销毁规则。
- 覆盖关系：一旦任务涉及持续事件流、Signal、Disposable 或链式变换，本 Skill 应覆盖普通异步请求 Skill 的默认处理方式；页面级技能不应绕过本 Skill 的线程和释放约束。
- 禁止组合：禁止与“页面直接长期持有底层流”的模式共存；禁止与“所有变换都在主线程”的模式共存；禁止与“忽略订阅释放”的模式共存。

# Retrieval Fallback
- 官方文档入口：优先检索仓颉并发与异步模型文档、仓颉 ArkUI 主线程状态更新文档、鸿蒙 ArkTS 状态管理和异步编程文档、OpenHarmony 线程与任务池相关资料。
- 仓库检索入口：优先检索 `TelegramHarmony` 中的 `common/signalkit/src/main/ets/Signal.ets`、`DisposableSet` 相关实现、`LoginViewModel.ets`、`ChatListViewModel.ets`、消息服务架构文档；如果需要参考 Swift 侧模式，可检索 `Telegram-iOS` 中与 `SwiftSignalKit` 或 Signal / Disposable 相关目录结构。
- CLI / Python 检索示例：`rg -n "Signal|Disposable|DisposableSet|start\(|map\(|filter\(|flatMap|deliverOn|subscribe" /path/to/repo`；`rg -n "SignalKit|Observer|Subscriber|Disposable|Promise|Future" docs skills samples`；`python scripts/skill_generator_v2.py --source docs/architecture/telegram-arkts-teardown-001.md --skill-name reactive-skill-draft --skill-class Architecture --mock-output-file skills/state-ownership-and-lifecycle.md --output skills/_tmp_reactive_draft.md --overwrite`。
- 升级提问模板：如果当前流的职责不明，应向人类或上层系统询问：“这个 Signal 是持续流还是单次结果？谁拥有订阅？何时释放？是否允许旧流结果覆盖新上下文？哪些变换必须在后台执行？最终 UI 状态由哪个 Store 或 Projection 接收？”

# Security / Privacy Constraint
- 敏感数据范围：响应式流中可能携带账号状态、消息内容、聊天列表摘要、在线状态、错误细节、文件路径、下载进度等敏感数据。
- 脱敏规则：日志和 Trace 只记录事件类型、阶段、计数、耗时和匿名化标识；不要记录完整消息正文、用户标识、文件路径和完整状态快照；必要时对事件载荷做结构级脱敏。
- 本地存储要求：响应式流本身不应默认落盘；若某些流结果需要缓存，只应缓存归并后的稳定状态，而不是完整事件历史或原始载荷；涉及认证态和会话态的缓存应走安全存储策略。
- 日志限制：禁止把完整 Signal 载荷、完整消息对象或完整错误堆栈直接输出到业务日志；禁止为了调试重复订阅而打印敏感对象全文。

# Migration Strategy
- 小样本做法：小样本中可以先用单一 `ReactiveCoordinator` 消费一个或两个事件源，再把结果写入单一 `Store`；可以用 Fake EventSource、Fake Dispatcher、Fake Store 做闭环验证。
- 工程级替代方案：大型工程中应按业务域拆分多个协调器和多个流域，例如认证流、聊天列表流、消息时间线流、媒体传输流；应引入共享调度器、取消策略和统一错误通道，并按页面可见范围生成投影。
- 何时升级：当一个页面开始消费多个持续流；当需要取消旧上下文并切换新上下文；当高频推送导致 UI 卡顿；当订阅泄漏难以定位；当同一底层流被多个页面重复消费时，必须升级为共享协调器和分层管道。
- 升级检查点：升级后必须重新验证后台变换与主线程提交是否分离、取消旧流后过期结果是否被阻断、订阅释放是否成体系、错误通道是否统一、主线程投递次数是否显著下降。

# Examples
- 示例一：概念性响应式管道示意

```text
class EventStream<MessageEvent> {}

class ReactiveCoordinator {
    private let source: EventStream<MessageEvent>
    private let store: MessageStore
    private let dispatcher: MainThreadDispatcher
    private let bag: SubscriptionBag

    func bindChatList(): Unit {
        let subscription = source
            .map(normalizeMessage)
            .filter(shouldAffectChatList)
            .batch(byWindow: 50ms)
            .map(buildChatListDelta)
            .onBackground()
            .sink { delta =>
                store.apply(delta)
                let projection = store.chatListProjection()
                dispatcher.submit(projection)
            }

        bag.add(subscription)
    }
}

Page 只接收 dispatcher 提交后的 projection。
Page 不直接接触 source，也不直接做 map/filter。
```

- 示例二：错误模式与修正模式对照

```text
错误模式：
ChatPage 在 aboutToAppear 中直接订阅底层 Signal。
回调里直接排序消息、过滤脏数据、更新页面字段。
页面切换到别的会话后，旧订阅未释放。
旧流结果继续回写，导致聊天内容闪回。

修正模式：
底层 Signal 由共享 ReactiveCoordinator 消费。
所有 map/filter/flatMap/批处理在后台执行。
Coordinator 将结果写入 Store，再通过主线程 Dispatcher 投递 Projection。
页面退出时只释放页面级绑定；会话切换时由 Coordinator 取消旧流并阻断过期结果。
```

# Test & Debug
- 快速验证步骤：先标记所有 Signal 的拥有者、释放点、下游接收者；再标记哪些阶段属于后台变换、哪些阶段属于主线程提交；再检查是否存在页面直接订阅底层流；最后再检查是否存在过期结果回写。
- 排错顺序：先查是否有订阅泄漏；再查是否在主线程做了重计算；再查旧流取消后是否仍能提交结果；再查是否缺少共享协调器；最后查错误通道是否提前终止了流但没有显式暴露。
- 常见误判：看到 UI 闪回，不一定是路由问题，往往是旧流结果回写；看到页面卡顿，不一定是 UI 布局问题，往往是流变换跑在主线程；看到重复事件，不一定是服务端重复推送，往往是多个页面重复订阅同一底层流。

# Sources
- `skills/SKILL_SCHEMA_V2.md`
- `skills/state-ownership-and-lifecycle.md`
- `docs/architecture/skill-taxonomy-and-schema-evolution.md`
- `docs/architecture/telegram-arkts-teardown-001.md`
- `https://github.com/ForestBook/TelegramHarmony`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/README.md`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/common/signalkit/src/main/ets/Signal.ets`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/entry/src/main/ets/viewmodel/LoginViewModel.ets`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/entry/src/main/ets/viewmodel/ChatListViewModel.ets`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/docs/MESSAGE_SERVICE_ARCHITECTURE.md`
- `https://github.com/TelegramMessenger/Telegram-iOS`
- `/tmp/docs_cangjie_inspect/en/Overview-of-Cangjie-capabilities-in-OpenHarmony.md`
- `/tmp/docs_cangjie_inspect/en/application-dev/reference/arkinterop/cj-apis-ark_interop.md`

# Known Gaps
- 当前仓库环境无法直接验证仓颉侧是否已经存在成熟的官方响应式流抽象，因此文中的 `EventStream`、`ReactiveCoordinator`、`MainThreadDispatcher` 等角色命名属于架构映射建议，而不是已存在官方 API 名称。
- 当前对 Swift 侧响应式实现的引用主要用于抽象语义对照，而非对某个具体库版本进行一比一绑定；未来若目标代码库明确依赖某个 Swift 响应式实现，需要再补专门的 Pattern Skill。
- 当前尚未在真实仓颉工程中编译验证主线程调度接口和后台执行器的具体 API，因此本 Skill 重点提供安全边界和组织结构，而非最终运行时代码模板。

# Evolution Log
- `2026-03-26`：首版创建，作为第二个 Architecture 级 Skill 试点，聚焦 Signal、Observer、Disposable 与主线程 UI 边界的迁移规则。
- `2026-03-26`：明确规定 `map`、`filter`、`flatMap`、去重、批处理等变换默认在后台执行，最终状态投递必须安全切回主线程，并把 Disposable 视为生命周期契约而非语法细节。
