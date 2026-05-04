# Skill Metadata
- Skill ID: `ARCH-CHAT-TIMELINE-VIRTUALIZATION-001`
- Skill Name: `chat-timeline-virtualized-rendering`
- Skill Class: `Architecture`
- Scope: 该 Skill 用于指导 Agent 处理聊天时间线在海量消息场景下的虚拟化渲染问题，覆盖可见窗口、预加载窗口、双向分页、锚点稳定、组件复用、富媒体离屏回收和主线程渲染边界。它关注的不是单个列表 API，而是如何把 ArkTS 中围绕 `LazyForEach`、`Repeat.virtualScroll`、`cachedCount`、`@Reusable`、`reuseId`、`WaterFlow` 等实践，迁移为仓颉侧可维护、可控、可扩展的时间线窗口与组件复用架构。
- Tags: `chat`, `timeline`, `virtualization`, `windowing`, `reusable`, `reuseId`, `repeat`, `virtualScroll`, `waterflow`, `memory`, `pagination`, `anchor`, `performance`, `architecture`, `cangjie`, `arkts`
- Version: `V2.0-initial`

# Trigger Condition
- 任务触发条件：当需求中出现聊天时间线、历史消息上万条、虚拟列表、`LazyForEach`、`Repeat`、`virtualScroll`、`cachedCount`、`@Reusable`、`reuseId`、双向分页、滚动锚点、线性长列表、媒体时间线、WaterFlow、离屏回收、组件池复用、滑动卡顿、内存占用过高等关键词时，应装载本 Skill。
- 强制触发条件：当任务同时涉及“海量聊天消息 + 列表虚拟化”“向上翻历史 + 向下追最新”“组件复用 + 内存控制”“富媒体消息 + 惰性加载”“合批后的时间线数据如何安全渲染”时，必须优先装载本 Skill，不能只依赖普通列表组件 Skill。
- 不适用条件：如果任务只是几十条以内的静态消息列表、没有分页、没有虚拟化窗口、没有组件复用、没有富媒体、没有滚动锚点与内存压力，则不应优先使用本 Skill。

# Core Concept
- 最短知识结论：聊天时间线的虚拟化不是“少渲染几个节点”这么简单，而是“让完整消息真值、窗口投影、组件复用池和主线程渲染边界彼此解耦”。
- 最短知识结论：`@Reusable` / `reuseId` 在架构上的本质，是把消息单元按模板类型分桶，并允许可见窗口之外的节点被安全回收和重绑定，而不是为每条消息长期持有独立组件实例。
- 最短知识结论：双向分页必须和锚点管理一起设计；历史分页插入和最新消息追加都不能无条件打断用户当前可视位置。
- 一句话风险提示：最危险的误用是把整条时间线当成一个普通长数组，每次分页或新消息都整体替换并全量重建节点，这会同时击穿内存、滚动稳定性和组件复用命中率。

# Architecture Mapping
- 源侧角色：ArkTS 中的 `List` / `LazyForEach`、`Repeat.virtualScroll`、`cachedCount` 预加载区、`@Reusable` 组件、`reuseId` 分组标识、`WaterFlow` 容器、`Scroller`、消息模板组件、历史分页触发、最新消息追踪、富媒体消息节点和滚动锚点控制逻辑。
- 目标侧角色：仓颉中的 `TimelineViewportWindow`、`TimelinePreloadWindowPolicy`、`TimelineAnchorManager`、`BidirectionalPaginationCoordinator`、`TimelineReusePool`、`ReusableMessageCell`、`RenderTemplateRegistry`、`VisibleRangeProjectionStore`、`MediaDeferredLoader`、`MainThreadTimelineRenderer`。页面只消费窗口化后的投影和主线程安全的数据源适配器，不直接消费完整消息真值。
- 保留策略：可以保留“可见区 + 预加载区”这一虚拟化思想；可以保留按模板类型进行组件复用分桶的思路；可以保留双向分页与锚点稳定并行处理的架构；可以保留线性时间线使用线性容器、媒体流使用瀑布流容器的场景区分；可以保留上游消息合批后再进入渲染层的处理顺序。
- 重构策略：不能把 `@Reusable` 直译成一个孤立装饰器就结束；必须将其重构为“可重绑定消息单元 + 复用池 + 模板分桶 + 生命周期回收策略”。不能把 `WaterFlow` 当成所有聊天时间线的默认容器；必须根据线性消息流与媒体瀑布流分别建模。不能把完整消息真值直接交给页面和列表容器；必须通过窗口投影层暴露给渲染层。不能假设 `Repeat` 的节点复用一定会触发自定义回调；应把数据重绑定与资源释放设计成显式策略，而不是依赖隐式生命周期。

# Dependency Constraint
- 必需依赖：`SKILL_SCHEMA_V2.md`；`message-delta-merge-and-batching.md`；`signal-based-reactive-pipeline.md`；`state-ownership-and-lifecycle.md`；滚动容器与分页状态管理知识；媒体资源惰性加载与释放基础知识。
- 可选依赖：未来的 `main-thread-ui-boundary` Skill；未来的 `chat-media-gallery-waterflow` Skill；未来的 `timeline-anchor-recovery` Skill；缓存与离线恢复 Skill。
- 冲突依赖：整表替换时间线数组的模式；页面直接维护完整消息真值和渲染节点的模式；把 `@Reusable` 当成自动解决全部复用问题的模式；线性时间线误用瀑布流容器的模式；富媒体节点离屏后仍长期保留大对象的模式。
- 环境前提：如果当前环境没有真实仓颉虚拟列表实现、没有组件复用池 API、没有主线程调度与滚动锚点恢复接口，则本 Skill 应优先输出架构分层、窗口策略、复用分桶和性能包络，不应声称已经完成真实运行时落地。

# Boundary Contract
- 边界类型：完整消息真值与窗口投影边界；后台分页与主线程渲染边界；组件复用池与活动可见节点边界；富媒体资源与轻量消息投影边界；上游合批结果与下游虚拟化渲染边界。
- 输入：上游合批后的消息增量、历史分页结果、最新消息追加事件、消息状态更新、已读变化、当前滚动位置、当前锚点消息、用户是否贴底、媒体缩略图加载结果、页面进入退出事件。
- 输出：窗口化后的时间线投影、可见区和预加载区范围、复用池中的空闲节点、主线程渲染命令、锚点恢复命令、分页请求命令、媒体懒加载任务和诊断指标。
- 生命周期归属：完整消息真值由上游 Store 拥有；窗口投影由 `VisibleRangeProjectionStore` 或等价协调器拥有；复用池由 `TimelineReusePool` 拥有；活动节点由 `MainThreadTimelineRenderer` 与页面级 ViewModel 按页面生命周期管理；媒体加载器拥有短寿命的资源句柄，不由页面手工管理。
- 资源释放责任：页面离开时释放活动节点绑定和滚动监听；窗口切换时把离屏节点交回复用池；复用池负责回收已脱离活动区的可重用单元；媒体加载器负责离屏资源释放与取消；上下文切换时分页协调器负责阻断旧分页结果回写。
- 错误传递方式：锚点恢复失败、窗口索引冲突、复用池命中异常、媒体回收失败、分页顺序错乱等问题先映射为领域错误与性能诊断，再决定是降级到较粗粒度刷新、强制锚点重定位，还是触发重新同步；页面不应直接感知底层复用池细节。

# Execution Topology
- 线程模型：上游消息流和分页结果可能来自后台线程、网络线程或缓存恢复线程；窗口计算、模板分桶决策、复用池分配策略、媒体预取计划、锚点恢复计算都应尽量在后台线程完成；主线程只负责创建或重绑定当前可见窗口所需的少量活动节点，以及执行最终滚动定位和 UI 刷新。
- 主线程提交点：只有在最终确定可见窗口、需要将窗口投影交给列表容器、需要把复用池中的节点绑定到当前可见消息、需要执行滚动锚点恢复、需要显示可见区加载态和错误态时，才允许进入主线程。主线程不得承担全量时间线排序、分页归并和富媒体大对象管理。
- 后台处理点：分页结果归并、时间线顺序维护、可见窗口与预加载窗口计算、模板类型判定、复用池分配策略、富媒体惰性任务队列、历史插入后的锚点补偿计算、与 `message-delta-merge-and-batching` 联动后的区段压缩，都应在后台完成。
- 串行要求：同一聊天时间线的窗口投影更新必须有单一串行入口；同一锚点恢复操作不能与旧分页结果并发竞争；同一复用分桶内的节点借出和归还要有明确顺序，避免重复绑定；历史分页和最新消息追加应经过统一的时间线协调器排序后再进入渲染层。
- 批处理要求：上游合批后的数据优先按区段进入虚拟化层；虚拟化层在短时间窗口内可再次合并多个渲染层变化，例如历史分页插入加局部状态更新，避免一帧内多次切换窗口；富媒体预取也应按窗口批次调度，而不是滚动一次就触发大量离散请求。

# State Contract
- 状态所有者：完整消息真值、顺序索引、分页游标和消息元数据由上游 `MessageStore` 或时间线 Store 持有；可见窗口范围、预加载窗口、锚点信息和窗口投影由 `VisibleRangeProjectionStore` 或 `TimelineViewportWindow` 持有；复用池拥有空闲节点集合和模板分桶状态；页面只拥有滚动位置、是否贴底、当前高亮项等局部瞬态状态。
- 真值来源：完整消息真值不以 UI 列表为准，而以上游 Store 为准；虚拟化层只持有面向渲染的窗口快照；`@Reusable` 或复用节点本身不是业务真值，它们只是可重绑定的渲染载体；滚动锚点以“当前屏幕上下文 + 目标消息标识 + 窗口投影”三者共同决定。
- 可变字段：可变字段集中在上游时间线 Store、窗口管理器和复用池状态中；活动节点只允许变更绑定数据和轻量渲染状态；页面不应直接改写完整消息真值与复用池内部状态。
- 衍生字段：日期分割线、连续气泡合并样式、群聊头像显示策略、富媒体占位态、贴底提示、新消息浮层、上下分页加载态、估算高度与窗口边界都是衍生字段，应由窗口和模板层统一计算，而不是由页面组件散点计算。
- 持久化策略：完整消息真值、分页锚点、滚动恢复点、消息索引可按业务需求持久化；活动节点实例、复用池空闲节点、媒体瞬时解码结果、可见窗口短期投影默认不持久化。
- 一致性规则：虚拟化层只消费上游合批后的稳定时间线结果；当历史分页插入后，必须先恢复锚点，再刷新活动窗口；当最新消息到达时，若用户不贴底，不应强制重置窗口到底部；当复用池可复用节点与目标模板不匹配时，允许新建节点，但不得错误复用不同模板的节点；当线性时间线与媒体墙共享同一上游数据时，必须用不同的窗口与模板策略分别渲染。

# Progressive Modules
## Module 1：概念最小版
聊天时间线虚拟化至少拆成五层：

1. 完整消息真值层；
2. 时间线窗口层；
3. 组件复用池层；
4. 主线程渲染层；
5. 锚点与分页协调层。

最小原则如下：

- 完整真值不直接交给页面；
- 可见窗口和预加载窗口由专门层管理；
- 组件按模板类型复用；
- 历史分页和最新消息必须保护锚点稳定；
- 富媒体资源离屏后要主动回收或降级为轻量状态。

## Module 2：常见映射
常见 ArkTS 聊天时间线虚拟化概念与仓颉侧推荐角色如下：

| ArkTS 概念 | 语义 | 仓颉侧推荐目标 | 说明 |
|---|---|---|---|
| `LazyForEach` | 懒创建子节点 | `TimelineLazyRenderer` | 只负责按窗口创建节点，不拥有完整真值 |
| `Repeat.virtualScroll` | 可见区与预加载区驱动的懒渲染 | `TimelineViewportWindow` + `TimelineLazyRenderer` | 更强调窗口与节点复用 |
| `cachedCount` | 预加载区大小 | `PreloadWindowPolicy` | 预加载必须受内存预算约束 |
| `@Reusable` | 可复用组件声明 | `ReusableMessageCell` | 需与显式复用池策略配合 |
| `reuseId` | 复用分组标识 | `RenderTemplateKey` / `ReuseBucketId` | 应按模板类型分桶 |
| `WaterFlow` | 瀑布流布局 | `MediaWallVirtualRenderer` | 更适合媒体流，不是普通线性聊天正文默认容器 |
| `Scroller` | 滚动控制 | `TimelineScrollController` | 用于锚点恢复与分页触发 |
| 上滑历史分页 | 头部插入更早消息 | `HistoryPaginationCoordinator` | 需要锚点补偿 |
| 下滑追最新 | 尾部追加或新消息提示 | `LatestMessageFollowCoordinator` | 取决于用户是否贴底 |

## Module 3：跨层模式
推荐采用“七段式时间线渲染管道”：

1. **Message Truth 层**：上游 Store 持有完整消息真值与顺序；
2. **Delta Merge 层**：与 `message-delta-merge-and-batching` 联动，把消息变化压缩为稳定区段；
3. **Viewport Window 层**：根据滚动位置、锚点和分页游标计算可见区与预加载区；
4. **Template Registry 层**：把消息映射到文本、图片、文件、系统提示、日期条等模板类型；
5. **Reuse Pool 层**：按模板类型管理可重用节点；
6. **Main Thread Renderer 层**：只挂载当前窗口需要的少量活动节点；
7. **Anchor Recovery 层**：在头部插入历史消息或上下文切换后恢复用户当前阅读位置。

推荐流程如下：

```text
Merged timeline delta
    ↓
Viewport window recalculation
    ↓
Template classification and reuse bucket selection
    ↓
Background anchor compensation planning
    ↓
Main thread binds visible cells only
    ↓
Media deferred loading for visible range
```

不推荐流程如下：

```text
Full timeline array
    ↓
Page receives entire array
    ↓
Page rebuilds all message cells
    ↓
Every pagination event replaces all nodes
    ↓
Scroll anchor drifts and memory keeps growing
```

## Module 4：工程级约束
Telegram 级别的聊天时间线虚拟化必须满足以下约束：

- 上游必须先完成消息增量合批，再进入虚拟化层；
- 虚拟化层必须区分完整真值与窗口投影；
- 复用分桶必须按模板类型划分，而不能混用结构差异极大的消息单元；
- 历史分页插入时必须优先保护用户当前锚点；
- 不贴底时最新消息不能强制重置滚动位置；
- 富媒体节点必须具备可见区内加载、离屏降级或释放策略；
- 线性聊天时间线和媒体瀑布流必须采用不同容器策略；
- 不应把 `Repeat` 或 `@Reusable` 的局部特性误当成完整的时间线内存管理方案。

# Translation Mapping
- ArkTS 对应写法：ArkTS 可通过 `List` 搭配 `LazyForEach` 或 `Repeat.virtualScroll` 控制长列表渲染，通过 `cachedCount` 控制预加载，通过 `@Reusable` 与 `reuseId` 表达组件复用分组，通过 `Scroller` 或滚动事件驱动分页和锚点恢复；对媒体型内容可参考 `WaterFlow` 的懒加载、缓存与组件复用建议。
- 仓颉对应写法：推荐抽象出 `TimelineViewportWindow`、`TimelineAnchorManager`、`BidirectionalPaginationCoordinator`、`TimelineReusePool`、`ReusableMessageCell`、`RenderTemplateRegistry`、`MainThreadTimelineRenderer`、`MediaDeferredLoader`。其中上游 `message-delta-merge-and-batching` 输出稳定区段，虚拟化层负责只把当前窗口所需数据绑定到主线程上的少量活动单元。`@Reusable` / `reuseId` 的核心迁移目标不是语法，而是“有类型约束的复用池 + 显式重绑定策略 + 离屏回收策略”。
- 允许差异：小样本阶段可以先用单一 `TimelineViewportWindow + TimelineReusePool + MainThreadTimelineRenderer` 组合；如果未来仓颉提供原生虚拟列表与组件复用能力，可把这些抽象映射到官方运行时对象，但仍需保留锚点管理、窗口投影和模板分桶三层思想。媒体流可以在后续拆成独立 `WaterFlow` Skill，而普通聊天正文时间线仍以线性容器为主。
- 禁止直译点：禁止把 `@Reusable` 机械翻译成单个装饰器然后忽略复用桶、重绑定和离屏回收；禁止把 `WaterFlow` 机械套用到普通线性时间线；禁止把完整消息数组直接暴露给页面并期望虚拟化自动解决性能问题；禁止在主线程执行窗口计算、分页补偿和模板分桶。

# Performance Envelope
- 主线程预算：主线程只应处理当前可见窗口节点的创建、重绑定、轻量样式更新、滚动定位和必要的 UI 刷新；不应执行全量时间线排序、分页归并、锚点补偿计算、媒体大对象解码或复用池分配决策。
- 吞吐量关注点：新消息风暴、快速滚动、双向分页、已读状态变化、媒体下载进度和富文本布局变化会显著放大渲染成本；如果窗口控制和组件复用不稳，主线程会被频繁拉起创建和销毁大量节点。
- 内存关注点：活动节点数必须与可见窗口和预加载窗口严格绑定；离屏节点不应继续持有大图、视频预览、复杂文本布局缓存；复用池的大小要受控，不能无限保留空闲节点；媒体资源和富文本测量缓存需要按模板和可见范围有节制地保留。
- 建议优化手段：将时间线拆为“完整真值 + 窗口投影”；引入按模板类型分桶的复用池；为文本消息和富媒体消息制定不同的复用策略；控制 `cachedCount` 或等价预加载窗口；为双向分页引入锚点管理器；对媒体缩略图采用可见区优先、离屏释放、低分辨率占位、后台解码的策略；通过上游 `message-delta-merge-and-batching` 压缩消息变化，避免虚拟化层面对原始事件流。

# Failure Model
- 常见编译失败：把复用池、窗口层和上游 Store 职责混在一起，导致类型边界不清；没有单独的锚点管理器，导致分页逻辑只能写进页面；把媒体加载器和消息单元耦合得过紧，导致生命周期难以表达。
- 常见运行失败：历史分页插入后锚点漂移；新消息到来时用户中途阅读位置被强制打断；复用池错误复用了不同模板类型的节点；离屏媒体节点仍然持有大对象；页面反复进入退出后旧节点和旧监听器未释放；可见窗口失控导致活动节点数过多。
- 高风险误用：整表替换时间线数组；把 `@Reusable` 当成自动复用解决方案；不区分线性时间线与媒体墙容器；主线程中直接做分页补偿；把完整消息真值长期复制到页面层；在 `Repeat` 复用路径中错误依赖 `aboutToReuse` 或 `aboutToRecycle` 回调完成关键资源清理。
- 恢复策略：先检查上游是否已完成合批；再检查窗口层是否只维护可见区与预加载区；再检查分页插入是否有锚点补偿；再检查复用分桶是否按模板类型隔离；再检查离屏媒体是否真的释放；最后查看性能日志中活动节点数、复用命中率、窗口切换次数和主线程创建次数是否异常。

# Verification Matrix
- 单元测试：验证窗口计算逻辑、可见区与预加载区更新规则、锚点恢复规则、双向分页协调规则、模板分桶逻辑、复用池借还规则、媒体可见区调度规则。
- Fake / Mock：使用 Fake TimelineStore 提供上游时间线真值；使用 Fake DeltaBatchSource 模拟 `message-delta-merge-and-batching` 输出；使用 Fake ScrollController 模拟用户上下滚动；使用 Fake ReusePool 记录节点借出与归还；使用 Fake MediaLoader 记录离屏资源释放与可见区加载行为。
- 集成测试：组合 `message-delta-merge-and-batching`、窗口投影层、复用池、主线程渲染器和分页协调器，验证历史分页插入、最新消息追加、富媒体混排、页面切换和锚点恢复的完整闭环；验证上游合批结果不会导致虚拟化层整表重建。
- 手动验证：在真实环境中验证上万条消息情况下的滚动是否流畅；验证向上翻历史时当前位置是否稳定；验证不贴底时新消息到来不会强制滚到底部；验证图片和视频消息离屏后内存是否明显回落；验证长时间滚动后是否仍能维持复用命中率和稳定帧率。
- 观测指标：记录活动节点数、预加载节点数、复用池大小、复用命中率、主线程创建节点次数、分页插入后的锚点偏移量、离屏媒体释放次数、窗口重算耗时、每帧绑定节点数、整表重建次数。

# Composition With Other Skills
- 前置 Skill：`SKILL_SCHEMA_V2`；`message-delta-merge-and-batching`；`signal-based-reactive-pipeline`；`state-ownership-and-lifecycle`。
- 常见组合：与 `message-delta-merge-and-batching` 组合时，可形成“先合批，再进入时间线窗口和数据投影”的上游下游关系；与 `signal-based-reactive-pipeline` 组合时，可形成“响应式流 -> 后台批量合并 -> 虚拟化窗口 -> 主线程渲染”的完整路径；与 `state-ownership-and-lifecycle` 组合时，可明确完整消息真值、窗口投影、复用池和页面局部状态的所有权边界。
- 覆盖关系：一旦任务涉及海量聊天消息、双向分页、时间线锚点、组件复用和窗口化渲染，本 Skill 应覆盖普通列表组件 Skill 的默认做法；上游的批处理 Skill 负责压缩变化，本 Skill 负责把这些变化安全地交给虚拟化渲染层。
- 禁止组合：禁止与“页面直接持有完整消息数组并整表渲染”的模式共存；禁止与“线性时间线默认使用 WaterFlow”的模式共存；禁止与“主线程做分页归并与窗口重算”的模式共存。

# Retrieval Fallback
- 官方文档入口：优先检索 OpenHarmony `Repeat` / `virtualScroll` 文档、`LazyForEach` 文档、`reuseId` 文档、`WaterFlow` 文档、滚动容器与 `Scroller` 文档、组件生命周期文档。
- 仓库检索入口：优先检索 `TelegramHarmony` 中与聊天列表、消息时间线、`SignalKit`、ViewModel、消息服务和媒体相关的目录；在本仓库中优先检索 `docs/raw_docs/arkts-chat-timeline-virtualization.md`、`skills/message-delta-merge-and-batching.md`、`skills/signal-based-reactive-pipeline.md`、`docs/architecture/telegram-arkts-teardown-001.md`。
- CLI / Python 检索示例：`rg -n "LazyForEach|Repeat|virtualScroll|cachedCount|@Reusable|reuseId|WaterFlow|Scroller|anchor" /path/to/repo`；`rg -n "timeline|virtual|reuse|window|pagination|anchor|media" docs skills samples`；`python scripts/skill_generator_v2.py --source docs/raw_docs/arkts-chat-timeline-virtualization.md --source skills/message-delta-merge-and-batching.md --source skills/signal-based-reactive-pipeline.md --skill-name chat-timeline-virtualized-rendering --skill-class Architecture --mock-output-file artifacts/pipeline/chat-timeline-virtualized-rendering.mock.md --output skills/chat-timeline-virtualized-rendering.md --overwrite`。
- 升级提问模板：如果当前时间线虚拟化策略不清楚，应向人类或上层系统询问：“当前列表使用线性容器还是瀑布流容器？完整消息真值由谁持有？可见窗口和预加载窗口由谁计算？历史分页插入后锚点如何恢复？组件复用按什么模板分桶？离屏媒体资源由谁释放？”

# Security / Privacy Constraint
- 敏感数据范围：聊天正文、图片缩略图、附件名称、分页锚点、未读标记、最近阅读位置、消息模板分类和媒体缓存路径都可能涉及隐私。
- 脱敏规则：日志中优先记录窗口大小、活动节点数、锚点偏移量、复用命中率、分页次数和匿名化会话标识；避免记录真实聊天正文、图片路径、文件名和完整消息对象。
- 本地存储要求：完整消息缓存和分页锚点如果需要持久化，应遵守更高等级的本地安全策略；复用池状态、活动节点实例和离屏媒体临时资源不应作为持久化对象。
- 日志限制：禁止在性能日志中输出完整时间线快照、完整富媒体元数据和真实会话标识；禁止为调试复用池而打印完整消息对象内容。

# Migration Strategy
- 小样本做法：小样本阶段可以先实现单一线性时间线的 `TimelineViewportWindow + TimelineReusePool + MainThreadTimelineRenderer` 组合，只验证可见窗口、预加载窗口、上翻历史锚点恢复和少量模板分桶复用；上游仍通过 `message-delta-merge-and-batching` 提供稳定区段。
- 工程级替代方案：大型工程中应拆分文本时间线、媒体时间线、搜索结果时间线、会话摘要时间线等不同渲染域；引入更细的模板注册表、锚点恢复策略、富媒体加载级别和性能监控；对线性时间线和媒体瀑布流分别构建不同的虚拟化渲染器。
- 何时升级：当活动节点数持续过高、上滑历史时锚点经常漂移、`notifyDataReload` 频繁触发窗口重建、富媒体消息导致内存峰值过高、复用池命中率过低、线性时间线与媒体流混用策略失控时，必须升级到更严格的窗口策略和模板分桶策略。
- 升级检查点：升级后必须重新验证活动节点数是否下降、锚点恢复是否稳定、复用池命中率是否提升、富媒体离屏释放是否有效、主线程节点创建次数是否减少、上游合批结果是否仍能稳定进入窗口层。

# Examples
- 示例一：概念性时间线虚拟化结构

```text
class TimelineViewportWindow {
    func updateVisibleRange(scrollOffset: Int64): Unit
    func visibleSlice(): TimelineSlice
    func preloadSlice(): TimelineSlice
}

class TimelineReusePool {
    func acquire(templateKey: String): ReusableMessageCell
    func release(cell: ReusableMessageCell): Unit
}

class MainThreadTimelineRenderer {
    func render(slice: TimelineSlice, pool: TimelineReusePool): Unit
    func restoreAnchor(anchor: TimelineAnchor): Unit
}

上游 MessageStore 提供完整真值。
message-delta-merge-and-batching 提供稳定区段。
TimelineViewportWindow 只暴露当前窗口。
MainThreadTimelineRenderer 只绑定窗口内的少量活动节点。
```

- 示例二：错误模式与修正模式对照

```text
错误模式：
页面持有完整消息数组。
历史分页回来后直接把整表拼接并整体替换。
随后页面重新构建全部消息节点。
图片消息离屏后仍然保留大图和解码结果。
滚动一段时间后内存和掉帧同时恶化。

修正模式：
上游先经过 message-delta-merge-and-batching 压缩变化。
时间线窗口层只维护可见区和预加载区。
ReusableMessageCell 按模板类型进入复用池。
历史分页插入后由 AnchorManager 先恢复锚点，再更新活动窗口。
离屏媒体节点降级为轻量状态并释放重资源。
```

# Test & Debug
- 快速验证步骤：先确认完整消息真值是否和窗口投影分离；再确认上游是否已先完成合批；再确认窗口层是否只维护可见区与预加载区；再确认组件是否按模板类型分桶复用；最后确认历史分页是否有锚点恢复策略。
- 排错顺序：先查是否整表替换时间线；再查窗口层是否过大；再查复用池是否按模板类型正确分桶；再查分页插入后锚点是否漂移；再查离屏媒体是否释放；最后查主线程是否承担了过多窗口计算和资源管理。
- 常见误判：看到滚动卡顿，不一定是列表容器本身慢，往往是窗口策略和富媒体释放不当；看到复用失败，不一定是 `@Reusable` 没生效，往往是模板分桶和重绑定策略不完整；看到历史分页后跳动，不一定是滚动控制器问题，往往是锚点恢复先后顺序不对。

# Sources
- `skills/SKILL_SCHEMA_V2.md`
- `skills/message-delta-merge-and-batching.md`
- `skills/signal-based-reactive-pipeline.md`
- `skills/state-ownership-and-lifecycle.md`
- `docs/raw_docs/arkts-chat-timeline-virtualization.md`
- `docs/architecture/telegram-arkts-teardown-001.md`
- `https://gitee.com/openharmony/docs/raw/master/zh-cn/application-dev/reference/apis-arkui/arkui-ts/ts-container-waterflow.md`
- `https://gitee.com/openharmony/docs/raw/master/zh-cn/application-dev/ui/rendering-control/arkts-new-rendering-control-repeat.md`
- `https://gitee.com/openharmony/docs/raw/master/en/application-dev/reference/apis-arkui/arkui-ts/ts-universal-attributes-reuse-id.md`

# Known Gaps
- 当前环境无法直接在仓颉 ArkUI 工程中验证虚拟列表、主线程时间线渲染器和组件复用池的真实 API 命名，因此文中的 `TimelineViewportWindow`、`TimelineReusePool`、`MainThreadTimelineRenderer` 等属于架构映射建议，而非已存在官方 API 名称。
- 当前原始材料主要基于官方 ArkUI 虚拟化和复用术语以及聊天时间线工程推导，尚未对某个真实 ArkTS 聊天时间线仓库做逐文件比对，因此后续仍需结合目标项目源码继续校准。
- 当前 Skill 重点解决的是窗口化、复用、分页和内存策略，对富文本测量缓存、复杂贴纸布局、视频播放器复用等更细分问题尚未展开。

# Evolution Log
- `2026-03-26`：首版创建，作为自动化 Pipeline 的第二个 Architecture 级试产目标，聚焦聊天时间线虚拟化渲染。
- `2026-03-26`：明确将 `@Reusable` / `reuseId` 的本质提炼为“模板分桶的组件复用池”，并将 `message-delta-merge-and-batching` 定义为本 Skill 的明确上游。
