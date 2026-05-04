# Skill Metadata
- Skill ID: `ARCH-MESSAGE-DELTA-BATCHING-001`
- Skill Name: `message-delta-merge-and-batching`
- Skill Class: `Architecture`
- Scope: 该 Skill 用于指导 Agent 处理高频消息流、聊天列表更新、消息时间线增量变更、批量同步补偿等场景下的“消息增量合并与批处理”问题。它关注的不是单个列表组件 API，而是如何把 ArkTS 中围绕 `LazyForEach`、`IDataSource`、`DataChangeListener`、防抖、节流、局部通知的实践，迁移为仓颉侧可控的后台归并、主线程派发、稳定数据源和 UI 安全更新结构。
- Tags: `message`, `delta`, `batching`, `list`, `lazyforeach`, `idatasource`, `datachangelistener`, `main-thread`, `background-merge`, `ui-datasource`, `reactive`, `architecture`, `cangjie`, `arkts`
- Version: `V2.0-initial`

# Trigger Condition
- 任务触发条件：当需求中出现消息增量更新、聊天列表高频刷新、时间线合批、`LazyForEach`、`IDataSource`、`DataChangeListener`、局部通知、`notifyDataAdd`、`notifyDataDelete`、`notifyDataChange`、`notifyDataReload`、防抖、节流、批处理窗口、列表重绘优化等关键词时，应装载本 Skill。
- 强制触发条件：当任务同时涉及“高频消息流 + 列表 UI”“后台流式事件 + 批量合并”“聊天时间线 / 会话列表增量更新”“主线程数据源派发”“响应式流与列表数据源联动”时，必须优先装载本 Skill，不能只依赖普通列表组件 Skill 或单次网络请求 Skill。
- 不适用条件：如果任务只是静态列表展示、一次性加载后不再更新的简单页面，且没有高频数据流、增量变更、数据源监听器、主线程边界和批处理需求，则不应优先使用本 Skill。

# Core Concept
- 最短知识结论：高频消息列表的关键不是“页面如何渲染一条消息”，而是“后台如何先把多条变化压缩成一批可安全投递给 UI 数据源的增量通知”。
- 最短知识结论：消息合批、去重、排序、索引决策、变化分类应在后台线程完成，最终的 `notifyDataAdd`、`notifyDataDelete`、`notifyDataChange`、`notifyDataReload` 才能安全派发给主线程的 UI 绑定数据源。
- 最短知识结论：`IDataSource` 或等价数据源对象不是原始消息流本身，而是主线程上的稳定桥梁，用于把已经收敛过的批量变化传递给 `LazyForEach` 或等价列表绑定层。
- 一句话风险提示：最危险的误用是让页面逐条消费消息流并逐条通知列表，这会把高频变化直接倾泻到主线程，导致卡顿、抖动、索引错乱和过期更新。

# Architecture Mapping
- 源侧角色：ArkTS 页面里的 `LazyForEach`；自定义 `IDataSource` 或数据源对象；`DataChangeListener` 风格的通知接口；聊天消息或列表摘要的高频事件流；局部刷新与全量重载的决策逻辑；防抖、节流或窗口合批逻辑。
- 目标侧角色：仓颉中的 `MessageDeltaBuffer`、`BatchMergeCoordinator`、`ListProjectionStore`、`UiListDataSourceAdapter`、`MainThreadListDispatcher`；页面只绑定投影化后的数据源适配器，而不直接绑定原始消息流。
- 保留策略：可以保留“稳定数据源对象 + 增量通知”的总体思想；可以保留按变化类型区分新增、删除、局部变化和全量重载的策略；可以保留用防抖、节流或时间窗口合批压缩高频事件的工程实践；可以保留列表层只感知数据源变化、不直接感知底层消息流的分层。
- 重构策略：不能把原始消息流直接交给页面做逐条 `notifyDataAdd`；不能把 `LazyForEach` 误认为高频更新自动优化器；不能让页面内同时承担消息归并、索引维护、数据源通知和 UI 渲染；必须重构为“事件流输入 -> 后台增量合并 -> 批量变化分类 -> 主线程数据源通知 -> 页面惰性渲染”的管道。

# Dependency Constraint
- 必需依赖：`SKILL_SCHEMA_V2.md`；`signal-based-reactive-pipeline.md`；`state-ownership-and-lifecycle.md`；列表生命周期和主线程边界知识；日志与追踪能力。
- 可选依赖：未来的 `main-thread-ui-boundary` Skill；未来的 `chat-timeline-virtualized-rendering` Skill；持久化和缓存一致性 Skill；分页与列表索引管理 Skill。
- 冲突依赖：页面直接整体替换消息数组的模式；每条消息都立即 `notifyDataReload` 的模式；页面直接订阅底层消息流并自行维护索引的模式；多个页面重复消费同一底层消息流并各自更新数据源的模式。
- 环境前提：如果当前环境还没有仓颉可编译的列表数据源适配器或主线程调度接口，则本 Skill 应先输出架构约束、数据流拓扑、验证矩阵和通知分类策略，不应声称已经具备真实运行时代码。

# Boundary Contract
- 边界类型：原始消息流与列表数据源边界；后台批量合并与主线程数据源通知边界；共享列表真值与页面惰性渲染边界；分页或补同步事件与当前可见窗口边界。
- 输入：新消息事件、消息状态变化、已读变化、删除事件、分页插入、草稿摘要变化、缓存恢复事件、同步补偿事件、页面进入退出事件、列表可见区变化信号。
- 输出：分类后的批量变化描述，例如新增区段、删除区段、局部更新区段、排序重排标记、全量重载标记；主线程数据源通知命令；页面可消费的列表投影；调试指标和错误状态。
- 生命周期归属：原始消息流由服务层或响应式协调器拥有；批量缓冲区和合并协调器由领域层或 ViewModel 层拥有；主线程数据源适配器由页面或页面级 ViewModel 拥有；`LazyForEach` 只消费数据源，不拥有消息真值。
- 资源释放责任：页面离开时释放页面级数据源监听和 UI 绑定；合并协调器在上下文切换时清理旧缓冲窗口和旧订阅；共享消息 Store 负责维护真值和索引，不由页面负责；全量重载决策不得通过丢弃旧监听器来掩盖索引错误。
- 错误传递方式：后台归并中的索引冲突、重复事件、越界变更、上下文失效等问题先映射为领域错误或诊断日志，再决定是降级为 `notifyDataReload`、跳过本次局部更新，还是触发重新同步；页面不应直接承担底层归并错误处理。

# Execution Topology
- 线程模型：底层消息事件可能来自网络线程、后台线程、Socket 回调线程、缓存恢复线程；消息去重、排序、聚合、窗口合批、变化分类、索引重算、局部变化决策都必须默认在后台线程完成；最终的 `notifyDataAdd`、`notifyDataDelete`、`notifyDataChange`、`notifyDataReload` 只能在主线程派发给 UI 绑定的数据源对象。
- 主线程提交点：当后台已经得出最终批量变化描述后，才允许主线程执行数据源通知、投影交换、页面局部刷新和可见错误提示更新；主线程不应执行批量消息归并和索引推导。
- 后台处理点：消息事件进入系统后，应先进入 `MessageDeltaBuffer` 或等价缓冲结构，在后台完成去重、排序、连续区间合并、冲突决策、是否降级为全量重载的判断；若与 `signal-based-reactive-pipeline` 联动，则 `map`、`filter`、`flatMap`、节流和批处理窗口都在后台完成。
- 串行要求：同一聊天时间线、同一会话列表的列表真值更新必须有单一串行入口；对于同一索引区段的多次变化必须按归并规则串行处理；上下文切换后旧窗口的批处理结果不得继续回写新页面的数据源。
- 批处理要求：必须支持时间窗口或数量窗口合批；高频消息流不允许逐条直接通知 `IDataSource`；局部变化可合并时优先合并为一次通知；当连续变化无法稳定表达为局部通知时，允许降级为一次 `notifyDataReload`，但不允许在主线程逐条回退。

# State Contract
- 状态所有者：消息真值、聊天摘要真值、索引映射和顺序信息由 `MessageStore` 或 `ListProjectionStore` 持有；批处理窗口中的暂存增量由 `MessageDeltaBuffer` 持有；主线程数据源适配器只持有当前 UI 绑定所需的可读投影；页面只持有局部滚动状态、选择态和短生命周期监听句柄。
- 真值来源：原始消息流只是变化输入，不是最终列表真值；最终真值以 Store 中归并后的列表结构为准；数据源适配器以 Store 生成的批量变化投影为准；页面展示以数据源适配器当前投影为准，而不是以最近一条消息事件为准。
- 可变字段：可变字段集中在 Store 的源状态和批处理缓冲区；数据源适配器内部允许维护当前可见列表快照和索引映射；页面不应直接修改列表真值。
- 衍生字段：列表摘要文案、未读标记展示、时间分组、连续消息合并视图、日期分段、空态展示、加载态提示都属于衍生字段，应由后台归并和投影层统一生成，不应在页面回调中散点计算。
- 持久化策略：批处理窗口和临时增量不持久化；可恢复的列表真值、分页锚点、缓存索引等可根据业务需求持久化；数据源适配器的短期 UI 投影默认不持久化。
- 一致性规则：后台归并结果进入数据源前，必须再次确认当前上下文仍有效，例如当前聊天 ID、当前分页窗口、当前筛选条件仍匹配；多个消息变化冲突时，以领域归并规则为准，不以页面接收顺序为准；局部通知无法保证一致性时，应显式降级为 `notifyDataReload`，而不是带着错误索引继续局部刷新。

# Progressive Modules
## Module 1：概念最小版
高频消息列表至少拆成四层：

1. 原始消息事件流；
2. 后台增量合并层；
3. 主线程数据源通知层；
4. `LazyForEach` 或等价惰性渲染层。

最小原则如下：

- 原始消息不直接打到 UI；
- 批量合并先在后台完成；
- 数据源是 UI 的稳定桥梁；
- 局部通知优先于全量重载；
- 订阅和监听器必须随生命周期释放。

## Module 2：常见映射
常见 ArkTS 列表优化概念与仓颉侧推荐角色如下：

| ArkTS 概念 | 语义 | 仓颉侧推荐目标 | 说明 |
|---|---|---|---|
| `LazyForEach` | 惰性渲染长列表 | `LazyListView` 或等价惰性绑定层 | 只负责渲染，不负责真值归并 |
| `IDataSource` | 列表绑定数据桥梁 | `UiListDataSourceAdapter` | 主线程上稳定存在的数据源适配器 |
| `DataChangeListener` | 数据变化通知接口 | `ListChangeDispatcher` | 接收后台批处理后的通知命令 |
| `notifyDataAdd` | 新增区间通知 | `dispatchAdd(range)` | 仅在已知稳定索引区间时使用 |
| `notifyDataChange` | 局部更新通知 | `dispatchChange(range)` | 内容变化但索引稳定时使用 |
| `notifyDataDelete` | 删除区间通知 | `dispatchDelete(range)` | 删除区间明确时使用 |
| `notifyDataReload` | 重载通知 | `dispatchReload()` | 局部变化不可安全表达时使用 |
| Debounce / Throttle | 控制高频事件 | `BatchWindowPolicy` | 属于后台管道策略 |

## Module 3：跨层模式
推荐采用“六段式消息列表更新管道”：

1. **Message Source 层**：接收消息、状态变化、同步补偿、分页事件；
2. **Reactive Transform 层**：与 `signal-based-reactive-pipeline` 联动，在后台执行筛选、规范化、节流与批处理窗口；
3. **Delta Merge 层**：对同一消息、多条连续消息、同一索引区段变化做去重和合并；
4. **List Projection 层**：根据当前聊天上下文、分页窗口和排序规则生成列表增量；
5. **UI DataSource Dispatch 层**：在主线程把增量转换为 `notifyDataAdd` / `notifyDataChange` / `notifyDataDelete` / `notifyDataReload`；
6. **Lazy Rendering 层**：由 `LazyForEach` 或等价惰性列表消费最终数据源投影。

推荐流程如下：

```text
Message Signal / Event Stream
    ↓
Background normalize + throttle + batch window
    ↓
Delta merge + deduplicate + conflict resolution
    ↓
Projection store computes list diff
    ↓
Main thread data source dispatch
    ↓
LazyForEach renders only needed rows
```

不推荐流程如下：

```text
Message Signal
    ↓
Page callback receives every event
    ↓
Page sorts and deduplicates messages
    ↓
Page directly calls notifyDataAdd for each message
    ↓
UI thread becomes overloaded and indices drift
```

## Module 4：工程级约束
Telegram 级别的高频消息列表必须满足以下工程约束：

- 原始消息事件不得直接逐条驱动数据源通知；
- 局部通知与全量重载的判定必须由后台批处理结果决定；
- 批量窗口长度和触发阈值应可配置，但默认应优先保护主线程；
- 页面切换、聊天切换、分页锚点变化时，旧窗口结果必须失效；
- 数据源适配器必须是主线程安全对象，不能跨线程直接调用其通知方法；
- 当索引稳定性无法保证时，允许一次性 `notifyDataReload`，但必须有诊断日志说明降级原因；
- 与响应式管道协作时，批处理结果应作为事件流下游的“最终 UI 变更命令”，而不是半成品消息集合。

# Translation Mapping
- ArkTS 对应写法：页面可能用 `LazyForEach` 绑定消息列表；通过 `IDataSource` 或类似对象管理列表数据；使用 `DataChangeListener` 风格的监听器通知 UI；对高频输入采用 Debounce、Throttle 或短时间窗口合批；在消息变化后调用 `notifyDataAdd`、`notifyDataChange`、`notifyDataDelete` 或 `notifyDataReload`。
- 仓颉对应写法：推荐抽象出 `MessageDeltaBuffer`、`BatchMergeCoordinator`、`ListProjectionStore`、`UiListDataSourceAdapter`、`MainThreadListDispatcher`。消息流先经响应式后台管道完成合并，再由主线程调度器把批量变化派发给 UI 数据源，最后由惰性列表消费数据源投影。
- 允许差异：小样本阶段可以先用单一 `BatchMergeCoordinator + UiListDataSourceAdapter` 组合；如果未来仓颉或鸿蒙侧提供官方更成熟的数据源与批量刷新 API，可以把这些角色映射到官方能力，但仍要保留后台合批与主线程通知的边界。
- 禁止直译点：禁止把每条消息都映射成一次 UI 通知；禁止把 `notifyDataReload` 作为默认路径掩盖索引混乱；禁止在页面层直接维护消息索引和批量窗口；禁止让后台线程直接调用 UI 数据源通知方法。

# Performance Envelope
- 主线程预算：主线程只允许执行最终数据源通知和必要的投影交换，不应执行消息去重、排序、索引重算、批处理窗口聚合和分页冲突决策。
- 吞吐量关注点：新消息风暴、同步补偿、分页插入、已读回执和草稿摘要变化会显著放大错误的列表通知策略；若逐条通知 UI，极易导致掉帧和抖动。
- 内存关注点：批处理缓冲区不能无限增长；旧页面数据源和旧监听器必须及时释放；投影层不应为每次增量都复制整份大型列表快照；无上限的历史消息对象保留会放大 GC 和闭包持有成本。
- 建议优化手段：对高频变化使用窗口合批；对连续区间变化做区段压缩；对消息唯一键做去重；对不可安全表达的变化降级为一次 `notifyDataReload`；记录批处理压缩比和主线程通知次数，持续调优阈值。

# Failure Model
- 常见编译失败：将数据源适配器和 Store 职责混淆，导致类型边界不清；没有单独的主线程派发器，导致后台与 UI 通知接口耦合；在没有统一变更对象的情况下直接拼接多种通知命令，容易出现结构设计不完整。
- 常见运行失败：高频消息逐条打入主线程导致卡顿；局部通知索引错误导致列表项错位；上下文切换后旧窗口结果仍然回写；数据源监听器未释放导致重复更新；本应局部刷新却误触发大量 `notifyDataReload` 导致页面闪烁。
- 高风险误用：页面自己维护去重和排序；把 `LazyForEach` 当成自动解决高频列表更新的方案；为求简单无条件走 `notifyDataReload`；多个页面分别持有自己的消息真值和数据源索引；让批处理窗口长度完全失控而造成延迟积压。
- 恢复策略：先检查批处理是否真的发生在后台；再检查主线程是否只收到最终通知命令；再检查局部通知索引是否基于最新上下文；再检查是否存在旧页面监听器或旧窗口结果回写；最后根据诊断日志判断是否需要暂时降级为 `notifyDataReload` 并补充更细粒度的索引策略。

# Verification Matrix
- 单元测试：验证 `MessageDeltaBuffer` 的去重、连续区间合并、排序和批处理窗口规则；验证变化分类逻辑是否正确产出 `add`、`delete`、`change`、`reload`；验证旧上下文结果不会回写新页面；验证降级为 `notifyDataReload` 的触发条件是否合理。
- Fake / Mock：使用 Fake MessageSource 模拟高频消息流；使用 Fake Scheduler 模拟后台批处理窗口；使用 Fake MainThreadListDispatcher 记录主线程通知次数；使用 Fake UiListDataSourceAdapter 验证实际收到的通知命令序列。
- 集成测试：组合 `signal-based-reactive-pipeline`、`BatchMergeCoordinator`、`ListProjectionStore`、`UiListDataSourceAdapter`，验证聊天列表和消息时间线在高频事件下只产生少量主线程通知；验证页面切换后旧窗口不会继续更新当前数据源。
- 手动验证：在真实环境中验证快速连续收到多条消息时页面是否仍然流畅；验证大量历史分页插入时是否保持索引正确；验证页面来回切换后是否还有重复通知；验证诊断日志中主线程通知次数是否明显低于原始消息数。
- 观测指标：记录原始消息数、批处理后通知数、主线程通知次数、`notifyDataReload` 次数、局部通知命中率、平均批处理窗口耗时、页面销毁后的活动监听器数量、旧上下文结果丢弃次数。

# Composition With Other Skills
- 前置 Skill：`SKILL_SCHEMA_V2`；`signal-based-reactive-pipeline`；`state-ownership-and-lifecycle`。
- 常见组合：与 `signal-based-reactive-pipeline` 组合时，可形成“消息流 -> 后台变换 -> 合批归并 -> 主线程数据源通知”的完整闭环；与 `state-ownership-and-lifecycle` 组合时，可明确消息真值、数据源投影和页面局部状态的所有权；与未来的 `chat-timeline-virtualized-rendering` 组合时，可覆盖从数据流到长列表渲染的完整路径。
- 覆盖关系：一旦任务涉及高频消息列表、批量增量更新或数据源通知，本 Skill 应覆盖普通列表组件 Skill 的默认做法；普通页面 Skill 不应绕过本 Skill 的后台合批和主线程通知规则。
- 禁止组合：禁止与“页面逐条通知数据源”的模式共存；禁止与“主线程做增量合并”的模式共存；禁止与“默认每次都 `notifyDataReload`”的模式共存。

# Retrieval Fallback
- 官方文档入口：优先检索鸿蒙 ArkUI 列表与惰性渲染文档、`LazyForEach` 相关文档、ArkTS 数据源与监听器实践文档、后台任务与 UI 主线程边界资料、仓颉 ArkUI 和并发相关文档。
- 仓库检索入口：优先检索 `TelegramHarmony` 中与 `SignalKit`、聊天列表、消息服务、ViewModel、列表展示相关的目录；在本仓库中优先检索 `docs/raw_docs/arkts-list-batch-update.md`、`skills/signal-based-reactive-pipeline.md`、`docs/architecture/telegram-arkts-teardown-001.md`。
- CLI / Python 检索示例：`rg -n "LazyForEach|IDataSource|DataChangeListener|notifyDataAdd|notifyDataDelete|notifyDataChange|notifyDataReload|debounce|throttle" /path/to/repo`；`rg -n "batch|delta|merge|projection|datasource|list" docs skills samples`；`python scripts/skill_generator_v2.py --source docs/raw_docs/arkts-list-batch-update.md --source skills/signal-based-reactive-pipeline.md --skill-name message-delta-merge-and-batching --skill-class Architecture --mock-output-file artifacts/pipeline/message-delta-merge-and-batching.mock.md --output skills/message-delta-merge-and-batching.md --overwrite`。
- 升级提问模板：如果当前列表更新策略不清楚，应向人类或上层系统询问：“底层消息流有多高频？当前列表是否使用稳定数据源对象？局部通知是否需要索引区间？哪些变化必须降级为全量重载？批处理窗口应按时间还是按数量触发？主线程通知由谁统一派发？”

# Security / Privacy Constraint
- 敏感数据范围：消息内容、聊天摘要、未读计数、聊天标识、媒体缩略信息、草稿文本、错误日志中的消息索引和上下文信息都可能具有敏感性。
- 脱敏规则：日志和轨迹应优先记录变化类型、区间数量、通知次数、耗时和匿名化上下文 ID，而不是记录真实消息正文和真实聊天标识；必要时仅记录“新增 12 条消息”这类统计信息。
- 本地存储要求：批处理窗口中的临时消息增量不应直接落盘；若需要缓存列表真值，只缓存已经归并后的稳定结构；涉及私聊或群聊内容的缓存应遵守更高等级的本地安全策略。
- 日志限制：禁止在批处理调试日志中打印完整消息对象数组；禁止输出真实用户消息文本、文件路径、会话标识与完整分页索引快照。

# Migration Strategy
- 小样本做法：小样本中可以先构建一个单一的 `BatchMergeCoordinator`，消费一个聊天列表或消息时间线事件流，在后台生成批量变化命令，再由主线程 `UiListDataSourceAdapter` 派发局部通知；可以通过 Fake MessageSource 和 Fake Dispatcher 跑通闭环。
- 工程级替代方案：大型工程中应按聊天列表、消息时间线、媒体列表、通知中心等不同领域拆分多个合批协调器；应引入统一的批处理窗口策略、索引一致性规则、取消旧上下文机制和性能监控指标；应把数据源适配器与 ViewModel 生命周期绑定。
- 何时升级：当列表通知次数远高于批处理预期；当频繁出现 `notifyDataReload` 掩盖细粒度问题；当页面切换后旧结果回写；当索引错乱难以排查；当多个页面重复消费同一底层消息流时，必须升级为共享合批协调器和更严格的上下文失效机制。
- 升级检查点：升级后必须重新验证主线程通知次数是否下降、局部通知命中率是否提升、旧上下文是否仍会回写、`notifyDataReload` 是否只在必要时发生、页面销毁后监听器和数据源是否被完整释放。

# Examples
- 示例一：概念性批处理流水线示意

```text
class MessageDeltaBuffer {
    func push(event: MessageEvent): Unit
    func flushWindow(): Array<MessageEvent>
}

class BatchMergeCoordinator {
    private let buffer: MessageDeltaBuffer
    private let store: ListProjectionStore
    private let dispatcher: MainThreadListDispatcher

    func onMessageEvent(event: MessageEvent): Unit {
        buffer.push(event)
    }

    func onWindowFlush(): Unit {
        let batch = buffer.flushWindow()
        let merged = mergeAndClassify(batch)
        let commands = store.applyMergedDelta(merged)
        dispatcher.dispatch(commands)
    }
}

class MainThreadListDispatcher {
    func dispatch(commands: Array<ListNotifyCommand>): Unit {
        for (command in commands) {
            match command {
                | Add(range) => uiDataSource.notifyDataAdd(range)
                | Delete(range) => uiDataSource.notifyDataDelete(range)
                | Change(range) => uiDataSource.notifyDataChange(range)
                | Reload => uiDataSource.notifyDataReload()
            }
        }
    }
}
```

- 示例二：错误模式与修正模式对照

```text
错误模式：
每来一条消息，Page 就直接 append 到数组。
随后 Page 立即调用一次 notifyDataAdd。
如果同一条消息随后又收到状态变更，Page 再立刻 notifyDataChange。
高峰期时主线程被成百上千次离散通知轰炸。

修正模式：
原始消息事件先进入 signal-based-reactive-pipeline。
后台窗口在 30ms 内收集和去重多条消息变化。
BatchMergeCoordinator 把多个变化压缩成少量区间命令。
MainThreadListDispatcher 只在主线程派发最终 notifyDataAdd 或 notifyDataReload。
LazyForEach 只渲染稳定数据源上的最终结果。
```

# Test & Debug
- 快速验证步骤：先确认当前列表是否存在稳定的数据源适配器；再确认消息事件是否先进入后台批处理窗口；再检查主线程是否只接收最终通知命令；最后检查页面离开后监听器和数据源是否释放。
- 排错顺序：先查是否逐条通知 UI；再查批处理是否真的发生在后台；再查局部通知索引是否稳定；再查旧上下文结果是否被阻断；最后查是否过度依赖 `notifyDataReload` 掩盖设计问题。
- 常见误判：看到列表卡顿，不一定是 `LazyForEach` 本身慢，往往是通知频率过高；看到索引错乱，不一定是列表组件 Bug，往往是后台归并和上下文失效规则不完整；看到刷新闪烁，不一定是渲染主题问题，往往是 `notifyDataReload` 过于频繁。

# Sources
- `skills/SKILL_SCHEMA_V2.md`
- `skills/signal-based-reactive-pipeline.md`
- `skills/state-ownership-and-lifecycle.md`
- `docs/raw_docs/arkts-list-batch-update.md`
- `docs/architecture/skill-taxonomy-and-schema-evolution.md`
- `docs/architecture/telegram-arkts-teardown-001.md`
- `https://github.com/ForestBook/TelegramHarmony`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/docs/MESSAGE_SERVICE_ARCHITECTURE.md`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/common/signalkit/src/main/ets/Signal.ets`
- `/tmp/docs_cangjie_inspect/en/Overview-of-Cangjie-capabilities-in-OpenHarmony.md`

# Known Gaps
- 当前源材料是为首次点火而整理的工程化原始文档，不是逐字摘录官方 ArkTS API 手册，因此关于 `IDataSource`、`DataChangeListener`、通知接口名称的表述更偏向工程模式提炼，后续仍需用官方样例和 IDE 环境校准。
- 当前环境无法直接在仓颉 ArkUI 项目中验证数据源适配器和主线程通知 API 的最终命名，因此 `UiListDataSourceAdapter`、`MainThreadListDispatcher` 等角色名属于架构映射建议。
- 当前 Skill 重点解决的是批处理与主线程边界问题，对分页锚点、长列表虚拟化细节、媒体消息特殊布局等问题尚未展开。

# Evolution Log
- `2026-03-26`：首版创建，用于自动化流水线首次点火，验证 V2 生成器是否能从原始 ArkTS 列表优化材料中稳定产出一个 Architecture 级 Skill。
- `2026-03-26`：明确把“消息合批必须在后台线程完成，最终 `notifyDataReload` / `notifyDataAdd` 等通知必须安全派发到主线程 UI 数据源”写入 Execution Topology 作为核心约束。
