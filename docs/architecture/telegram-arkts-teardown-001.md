# Telegram ArkTS 技术栈拆解 001：面向仓颉翻译与 Skill 体系设计的高压难点研判

## 1. 文档目的

本文不是仓颉代码翻译文档，也不是仓库实现说明书。本文的目的是站在架构设计与 Skill 体系建设的角度，拆解 Telegram ArkTS 方向最关键的三类硬核难点，从而回答以下问题：

1. 为什么 Telegram 级别工程不能用“小样本页面翻译经验”直接外推。
2. 如果未来目标是将 Telegram Harmony 这类工程迁移或翻译到仓颉，Agent 必须掌握哪些超出 UI / API 映射范畴的知识。
3. 为什么 Skill Taxonomy 必须引入 Native Boundary、Execution Topology、State Contract 等高阶维度。

本文重点聚焦三大问题：

- TDLib（C++）与 ArkTS 的通信模型，以及未来仓颉要掌握的互操作知识；
- 海量消息场景下的并发处理与响应式 UI 同步；
- 巨型应用跨页面、跨模块的复杂状态管理策略。

---

## 2. 前提纠偏：当前 TelegramHarmony 不是现成 TDLib 桥接工程

这一点必须在文档最前面明确，因为它会直接影响后续所有判断。

基于当前公开资料，`ForestBook/TelegramHarmony` 的现实更接近：

- 使用 ArkTS / ArkUI 开发应用壳与业务层；
- 在 ArkTS 侧实现 MTProto 2.0 相关协议逻辑；
- 使用自定义响应式层 `SignalKit`；
- 使用 `Service Locator` 组织核心服务；
- 在应用层引入 `AppState`、ViewModel、Storage 等典型客户端结构。

也就是说，当前可见仓库并不是一个“TDLib C++ 已经封装好，ArkTS 只做页面渲染”的轻量壳工程。

这一点非常关键，因为它告诉我们：

### 2.1 对当前仓库的理解不能偷懒

如果把它误判为 TDLib 壳工程，就会低估以下难点：

- 协议栈自实现；
- Socket 层与传输层设计；
- Session / Auth Key / 消息序号管理；
- 自定义状态流；
- 服务组织和消息分发路径。

### 2.2 对未来翻译路线必须做双重预案

未来真正的仓颉化目标可能有两条路线：

- **路线 A：延续当前仓库思路，使用仓颉重写或承接 ArkTS 侧协议实现与业务层。**
- **路线 B：切换到更工业化的 TDLib C++ 核心，通过 ArkTS 或仓颉的 Native Bridge 接入 UI 与业务层。**

这两条路线对 Skill 的要求完全不同：

- 路线 A 更强调协议、状态流、缓存与响应式 UI。
- 路线 B 更强调 C-Interop、NAPI、线程模型、指针与内存所有权。

因此，本拆解文档会在每个硬点里同时讨论“当前仓库现实”和“未来 TDLib 路线要求”。

---

## 3. 当前 TelegramHarmony 可见架构轮廓

根据当前可见目录和文件命名，可以大致还原出 TelegramHarmony 的若干核心结构：

- `common/signalkit`：自定义响应式基础设施；
- `core/services`：服务定位与服务组织；
- `entry/src/main/ets/app/AppState.ets`：全局应用状态；
- `entry/src/main/ets/viewmodel/*.ets`：页面或功能域 ViewModel；
- `entry/src/main/ets/core/mtproto/*`：协议、传输、会话等核心逻辑；
- `entry/src/main/ets/core/storage/AuthStorage.ets`：本地存储；
- `RealChatListService`、`RealMessageService`、`RealServiceAdapter`：业务服务适配层。

如果把这些角色按职责连接起来，可以得到一个非常值得警惕的架构图：

```text
ArkUI Page
    ↓
ViewModel
    ↓
Service Adapter / Service Locator
    ↓
Protocol / Message Service / Auth Service / Storage Service
    ↓
MTProto Transport / Preferences / NetworkKit Socket
    ↓
Remote Telegram Server

同时存在的横向结构：
- AppState：跨页面共享的应用级状态
- SignalKit：服务返回的响应式流
- DisposableSet：订阅生命周期管理
```

这说明 TelegramHarmony 的挑战远超“页面翻译”。真正的难点是如何让协议层、服务层、状态层和 UI 层在高并发下保持稳定协作。

---

## 4. 难点一：TDLib（C++）与 ArkTS 的通信模型

这一部分需要分成两个子问题：

1. 当前 TelegramHarmony 现实上并不是 TDLib 接入工程，那它说明了什么。
2. 如果未来要走 TDLib 路线，仓颉翻译必须掌握什么。

### 4.1 当前仓库现实说明了什么

当前 TelegramHarmony 采用纯 ArkTS / MTProto 路线，至少说明三件事：

#### 4.1.1 纯托管侧也能承载核心协议逻辑，但工程复杂度会显著上升

一旦不依赖 TDLib，客户端就需要自行承担：

- 连接建立与传输；
- 认证密钥协商；
- 请求序列化与响应解析；
- 消息顺序与确认；
- 断线重连；
- 本地会话保持；
- 服务抽象与上层语义包装。

对于 Agent 来说，这意味着不能只学习 UI 或系统能力 Skill，而必须学习协议栈相关 Skill。

#### 4.1.2 “纯 ArkTS 实现”并不降低 Skill 体系难度，反而扩大了知识覆盖面

纯 ArkTS 路线绕开了 C++ 边界，但引入了更多应用层复杂度：

- 自定义响应式库；
- 自定义服务分发路径；
- 自定义缓存与状态组织；
- 自定义消息处理流水线。

所以即便暂时不做 Native Bridge，Skill Taxonomy 也必须覆盖：

- 协议服务层；
- 状态与数据流层；
- 并发与执行拓扑层；
- 可观测性与验证层。

#### 4.1.3 当前仓库可以作为“协议自实现型工程”的样板，而不是 TDLib 桥接样板

这意味着未来若从 TelegramHarmony 提炼 Skill，不应只做：

- `login-page.md`
- `chat-list-page.md`
- `message-item.md`

而应该做：

- `mtproto-transport-and-session.md`
- `signal-based-reactive-pipeline.md`
- `service-locator-to-explicit-dependency-graph.md`
- `appstate-and-viewmodel-ownership.md`
- `message-stream-to-ui-delta-commit.md`

### 4.2 如果未来改走 TDLib 路线，典型通信模型是什么

TDLib 官方提供的是一个跨平台 Telegram Client Core。它提供 C 接口与 JSON 接口，这使它很适合被非 C++ 语言包裹。

如果未来在鸿蒙端选择 TDLib 路线，一个典型的数据流大致如下：

```text
ArkUI / 仓颉页面
    ↓
ViewModel / UseCase / Service Adapter
    ↓
高层 Telegram Service 接口
    ↓
Native Bridge 封装层（ArkTS NAPI 或 仓颉 C-Interop / ArkTS Interop）
    ↓
C 包装层
    ↓
TDLib JSON Client API
    ↓
TDLib 内部状态机 / 网络 / 加密 / 缓存
    ↓
Telegram Server
```

在这一模型中，几个关键接口语义非常重要：

- `td_send`：发送请求；
- `td_receive`：拉取响应和更新；
- `td_execute`：执行少量同步操作；
- `td_create_client_id`：创建客户端实例标识。

对 Agent 来说，最关键的不是记住函数名，而是理解它们暗示的架构约束。

### 4.3 TDLib 模型背后的关键约束

#### 4.3.1 接收循环必须有清晰的单消费者语义

TDLib 的接收接口要求调用方认真管理读取模型。`td_receive` 不能被两个线程并发乱调，否则会直接破坏更新顺序与调用假设。

这意味着未来 Skill 必须明确要求：

- 接收循环由单一消费实体持有；
- 更新按接收顺序进入上层流水线；
- 上层若要并发处理，也应在接收后做分层拆分，而不是在底层乱并发读取。

这已经不再是普通 API 使用问题，而是典型的 `Execution Topology` 与 `Boundary Contract` 问题。

#### 4.3.2 请求和响应的相关性不能依赖 UI 层临时状态

TDLib JSON 请求通常需要携带可关联的额外上下文，例如请求标识、场景标识或回调映射。不能把这种相关性临时放在页面组件里，否则页面销毁、路由切换或重建时，关联关系就会丢失。

正确的做法应当是：

- 在 Service / Bridge 层统一建立请求上下文；
- 将请求标识与 Promise、回调、状态变更路径对应起来；
- 更新流与显式请求响应使用统一的事件模型整理。

#### 4.3.3 Native 返回的数据不能直接推动 UI 全量刷新

无论是 TDLib 返回 JSON，还是 C 层返回结构化数据，都不应该让 UI 主线程直接做大规模反序列化和全量状态替换。

更合理的流水线是：

1. Native 接口收到原始更新；
2. 后台层完成 JSON 解析或中间对象解码；
3. 业务层将其标准化为领域事件；
4. Store 或状态协调层合并增量；
5. 主线程只提交最小 UI 差量。

### 4.4 未来仓颉要掌握哪些 C-Interop / ArkTS Interop 知识

如果走 TDLib 或任意 Native Core 路线，仓颉侧至少要掌握以下知识点：

#### 4.4.1 基础跨边界类型映射

包括但不限于：

- `String` 与 C 字符串或 JSON 字节流的转换；
- `ArrayBuffer`、字节数组、二进制媒体数据的桥接；
- 数值、布尔、枚举、错误码映射；
- C 结构体与仓颉对象之间的边界约定。

#### 4.4.2 指针与资源生命周期管理

这类问题无法用页面级 Skill 解决，必须单独训练 Agent 理解：

- 谁申请内存；
- 谁释放内存；
- 何时可以保留指针；
- 何时必须复制数据；
- 回调结束后对象是否仍然有效；
- 关闭客户端时如何有序释放资源。

#### 4.4.3 线程亲和与回调封送

Native 层收到数据的线程通常不是 UI 主线程。Agent 必须知道：

- 哪一层允许处理原始回调；
- 哪一层负责切回 UI 主线程；
- 哪些对象可以跨线程共享；
- 哪些状态只能在主线程提交。

#### 4.4.4 错误模型转换

C / C++ 层的错误往往表现为：

- 错误码；
- 空指针；
- 失败对象；
- 超时；
- 崩溃风险；
- 部分不可恢复错误。

高层业务需要的是：

- 登录失败；
- 网络异常；
- 会话失效；
- 消息发送失败；
- 文件下载中断。

二者之间必须有一层显式的错误映射 Skill，否则上层会被底层细节污染。

### 4.5 为什么这一难点会反推 Schema V2

仅靠 V1 的 `Translation Mapping` 与 `Examples`，无法完整表达以下内容：

- 单消费者接收循环；
- Native 数据所有权；
- 回调线程切换；
- C 层错误到业务层错误的归一化；
- Bridge 层必须隔离哪些职责。

所以 Schema V2 必须引入：

- `Boundary Contract`；
- `Execution Topology`；
- `Dependency Constraint`；
- `Failure Model`；
- `Security / Privacy Constraint`。

---

## 5. 难点二：海量消息的并发处理与响应式 UI 同步

聊天应用最大的工程压力之一，是消息流不是按用户点击节奏到达，而是按网络推送、同步补偿、历史分页、媒体下载、未读状态变化等多条流水线并发涌入。

在这一点上，Telegram 级别应用远比普通设置页或表单页复杂。

### 5.1 当前仓库暴露出的关键结构

从可见文件命名与描述看，TelegramHarmony 至少已经引入以下机制：

- `SignalKit`：用于响应式信号流和订阅；
- `DisposableSet`：用于订阅生命周期管理；
- `AppState`：用于全局状态；
- `@ObservedV2`、`@Trace`：用于状态观察与界面驱动；
- `ChatListViewModel`、`LoginViewModel`：作为页面与服务之间的协调层；
- `RealChatListService`、`RealMessageService`：作为服务层入口。

这说明当前仓库已经不是“Page 直接调用 API”的简单模型，而是引入了：

- 响应式数据源；
- ViewModel 层协调；
- 全局与局部状态并存；
- 订阅生命周期管理。

### 5.2 真正的问题不是“能否订阅消息”，而是“如何在高频更新下不拖垮 UI”

一个聊天应用在高峰场景下，可能同时面对：

- 长连接推送的新消息；
- 历史分页加载；
- 已读状态变化；
- 发送中的本地回显状态变化；
- 媒体消息上传下载进度变化；
- 用户在多个聊天之间快速切换；
- 后台恢复后的批量补同步。

如果这些变化都直接驱动页面全量刷新，结果通常只有两种：

- UI 卡顿；
- 状态错乱。

### 5.3 Telegram 级别的正确思路是“数据面”和“渲染面”分离

对于高频消息流，建议把系统分成两张平面：

#### 5.3.1 数据面（Data Plane）

负责：

- 接收原始更新；
- 解析协议对象；
- 去重、排序、归并；
- 维护消息索引；
- 合并未读计数、会话摘要、消息时间线；
- 管理待发送、本地回显、失败重试。

#### 5.3.2 渲染面（Render Plane）

负责：

- 接收已经归并过的领域状态；
- 只针对可见页面和可见列表窗口提交最小差量；
- 控制渲染频率；
- 避免高频事件直接触达组件树。

当 Agent 不理解这两张平面的差别时，就会做出错误设计，例如：

- 在页面组件里直接解析网络消息；
- 在主线程里排序大消息列表；
- 收到每一条更新就整页刷新；
- 把订阅和业务逻辑绑死在页面生命周期里。

### 5.4 在鸿蒙平台上，主线程边界尤其敏感

根据当前公开资料，ArkUI 状态管理存在明显的主线程约束。UI 状态并不能在任意后台线程随意修改。

这意味着未来不管是 ArkTS 还是仓颉，只要涉及高频流式更新，都必须遵守一条铁律：

- 后台线程负责处理和整理数据；
- UI 主线程只负责提交最终可渲染状态。

从工程角度看，这条铁律会直接演化出一整套 Skill：

- `main-thread-ui-boundary`
- `background-message-diff-and-merge`
- `delta-commit-for-chat-timeline`
- `subscription-lifecycle-and-cancellation`
- `batching-and-backpressure-for-ui-safe-updates`

### 5.5 一个更符合 Telegram 级别工程的更新流水线

下面给出一个更适合大规模消息场景的流水线模型：

```text
网络线程 / Native 回调 / Socket 回调
    ↓
协议解析层
    ↓
领域事件标准化层
    ↓
后台合并层（去重、排序、聚合、批处理）
    ↓
状态协调层（更新 Store、索引、会话摘要）
    ↓
主线程提交层（只提交可见聊天和可见窗口的最小状态）
    ↓
ArkUI 组件渲染
```

这个流水线里的每一层都值得成为独立 Skill，而不是只写进聊天页面说明里。

### 5.6 Telegram 级别场景中的几类性能与一致性陷阱

#### 5.6.1 全量替换陷阱

每来一条消息就重建整个聊天列表或整个消息数组，这会直接导致：

- diff 成本过高；
- 重绘范围过大；
- 滚动位置易抖动；
- 可见项之外的状态也被反复重建。

#### 5.6.2 无背压陷阱

如果网络层疯狂推送，UI 层毫无节制地逐条消费，主线程很快会被淹没。需要明确：

- 批量合并；
- 节流；
- 优先级分层；
- 在不可见页面降采样。

#### 5.6.3 生命周期泄漏陷阱

页面退出后订阅还在继续，或者切换聊天后旧聊天订阅未及时释放，会导致：

- 重复渲染；
- 内存泄漏；
- 旧页面抢写状态；
- 难以定位的幽灵更新。

#### 5.6.4 主线程大对象处理陷阱

如果主线程负责：

- 大 JSON 解析；
- 大数组排序；
- 大量对象转换；
- 媒体元数据处理；

那么无论 UI 写得多漂亮，用户体验都无法稳定。

### 5.7 这一难点对 Skill 系统的反推要求

要让 Agent 真正处理这一问题，Skill 体系至少要能表达：

- 哪些步骤必须在后台做；
- 哪些步骤必须回主线程；
- 哪些状态更新允许批量；
- 哪些页面只应消费投影状态，而不是完整原始流；
- 如何用 Fake Stream、Fake Scheduler、Fake Store 测试更新流水线。

这也就要求 Schema V2 增加：

- `Execution Topology`；
- `State Contract`；
- `Performance Envelope`；
- `Verification Matrix`；
- `Composition With Other Skills`。

---

## 6. 难点三：复杂状态管理策略

如果说前两个难点聚焦在“边界”和“并发”，那么第三个难点聚焦在“谁拥有系统的真相”。

对于 Telegram 级别应用，这不是一个抽象问题，而是几乎每一个功能都必须回答的问题。

### 6.1 当前仓库已经暴露出状态分层雏形

根据可见结构，TelegramHarmony 至少已经具备以下状态角色：

- `AppState`：应用级共享状态；
- ViewModel：页面或功能域状态协调层；
- `AuthStorage`：持久化状态；
- Service 层：提供领域语义的状态或数据流；
- `SignalKit`：支撑订阅和推送。

这说明当前仓库已经不再是“页面内部几个 `@State` 变量就够了”的规模。

### 6.2 Telegram 级应用至少需要七层状态视角

为了避免状态混乱，建议从一开始把 Telegram 级应用的状态划分为多个层次。

#### 6.2.1 启动与环境状态

包括：

- 应用是否完成初始化；
- 当前是否具备网络；
- 当前能力、权限、配置是否准备好；
- 运行环境版本与兼容开关。

#### 6.2.2 认证与会话状态

包括：

- 当前账号身份；
- 登录态；
- 多账号切换上下文；
- 会话有效性；
- token、session、auth key 等敏感信息。

这一层通常不能只放在页面状态里，而应由全局状态与安全存储共同负责。

#### 6.2.3 连接与传输状态

包括：

- 当前连接是否在线；
- 当前连接的数据中心或通道；
- 重连状态；
- 心跳或同步状态；
- 网络错误与恢复策略。

这层状态常常不直接渲染 UI，却决定大量功能行为。

#### 6.2.4 会话列表与索引状态

包括：

- 聊天列表顺序；
- 未读计数；
- 最后一条消息摘要；
- 草稿预览；
- Pin、Mute、Archive 等列表维度。

这一层应该与具体聊天时间线解耦，否则列表和详情页很难保持一致。

#### 6.2.5 单个聊天时间线状态

包括：

- 已加载消息窗口；
- 分页锚点；
- 待发送本地回显；
- 已发送未确认消息；
- 编辑态、删除态、引用态；
- 滚动位置与可见窗口。

这是复杂度最高的一层，绝不能简单等同于“消息数组”。

#### 6.2.6 媒体与传输任务状态

包括：

- 上传中、下载中、暂停中、失败中任务；
- 文件本地路径；
- 缩略图、转码、缓存命中；
- 权限与可访问性。

这一层经常跨页面共享，也需要持久化或断点恢复。

#### 6.2.7 页面瞬态交互状态

包括：

- 当前输入框内容；
- 选择态；
- 弹窗开关；
- 当前筛选条件；
- 页面级 loading 或错误提示。

这一层才是传统页面 `@State` 最适合承载的状态。

### 6.3 为什么单纯页面级 `@State` 不够

页面级状态只适合：

- 瞬态输入；
- 局部 UI 控制；
- 不跨页面共享的信息；
- 可以随着页面销毁而自然丢失的信息。

但 Telegram 级应用的大多数关键状态都具备以下特征：

- 跨页面共享；
- 需要在后台继续存活；
- 需要和网络或磁盘同步；
- 需要在页面重建后恢复；
- 需要多个视图共同观察。

因此，Skill 体系必须单独教授 Agent：

- 哪些状态是页面私有；
- 哪些状态属于全局 Store；
- 哪些状态属于领域服务；
- 哪些状态应持久化；
- 哪些状态只能派生，不能直接写入。

### 6.4 巨型应用中的“状态真值”通常不是单一位置

在聊天应用里，很多状态并不存在唯一单点真值，而是多源协作：

- 网络是远端真值；
- 本地缓存是可恢复真值；
- 页面 Store 是可渲染真值；
- 输入框与发送队列是乐观真值；
- 持久化索引是历史真值。

因此需要非常明确地界定：

- 哪一种真值优先；
- 何时覆盖；
- 何时合并；
- 何时回滚；
- 何时丢弃本地状态。

如果 Skill 没有 `State Contract` 字段，就无法可靠表达这些规则。

### 6.5 一个更适合 Telegram 级应用的状态组织思路

建议把状态组织成“核心真值层 + 投影层 + 页面瞬态层”三层模型。

#### 6.5.1 核心真值层

由领域 Store、会话管理器、缓存索引、传输管理器共同维护，负责：

- 身份状态；
- 聊天列表索引；
- 消息时间线索引；
- 任务状态；
- 持久化与网络合并。

#### 6.5.2 投影层

由 ViewModel、选择器、衍生状态计算器负责，输出：

- 页面展示模型；
- 当前聊天窗口的渲染片段；
- 已过滤、已排序、已聚合的数据；
- 适合 UI 直接消费的轻量对象。

#### 6.5.3 页面瞬态层

由页面组件维护：

- 输入框、开关、当前选中项；
- 局部弹窗、菜单、聚焦状态；
- 只影响当前页面且可随生命周期销毁的状态。

这种分层比“所有状态都放进一个全局对象”更稳，也比“所有状态都放进页面里”更适合大型工程。

### 6.6 这一难点对 Skill Taxonomy 的反推

要让 Agent 正确处理 Telegram 级状态管理，Skill 体系至少需要独立覆盖：

- `state-ownership-and-lifecycle`
- `shared-viewmodel-state`
- `cache-coherency-and-derived-state`
- `offline-first-sync-and-reconciliation`
- `message-timeline-and-local-echo`
- `auth-session-and-sensitive-storage`
- `service-locator-and-dependency-boundary`

如果这些知识仍然散落在页面 Skill 里，后续大工程翻译一定会出现大量重复、冲突与错误抽象。

---

## 7. 从三大难点反推：未来 Agent 必须掌握的核心 Skill 组

为了让后续 Skill 建设更聚焦，这里把三大难点反推为一组更直接的候选 Skill。

### 7.1 Native / TDLib 路线相关 Skill

- `tdlib-json-client-bridge`
- `single-consumer-receive-loop`
- `cangjie-c-interop-pointer-and-resource-lifetime`
- `arraybuffer-string-json-boundary-mapping`
- `native-callback-thread-handoff`
- `native-error-to-domain-error-mapping`

### 7.2 纯 ArkTS / 协议自实现路线相关 Skill

- `mtproto-transport-session-and-seq-management`
- `service-adapter-and-protocol-facade`
- `signal-based-reactive-service-pipeline`
- `socket-update-flow-to-domain-events`
- `auth-storage-and-session-recovery`

### 7.3 消息并发与 UI 收敛相关 Skill

- `message-delta-merge-and-batching`
- `chat-timeline-virtualized-rendering`
- `main-thread-ui-safe-commit`
- `subscription-lifecycle-and-disposal`
- `background-parse-and-ui-projection`

### 7.4 状态架构相关 Skill

- `appstate-global-store-boundary`
- `page-state-vs-domain-state`
- `local-echo-pending-queue-and-reconciliation`
- `chat-list-summary-store`
- `offline-cache-index-and-rehydration`
- `service-locator-to-explicit-di-migration`

这些 Skill 明显已经超出了当前 V1 主要覆盖的“单点 API 映射”范围，因此必须使用更强的 Schema 组织。

---

## 8. 对 Skill Taxonomy 与 Schema V2 的直接启示

前文的三大难点共同证明了一件事：

**如果 Skill 体系不能表达运行边界、状态契约、失败模型与组合关系，Agent 就只能处理 demo 级任务，无法支撑 Telegram 级工程。**

因此，Skill Taxonomy 与 Schema V2 至少要满足以下目标：

### 8.1 让 Agent 先识别任务边界，再识别 API 细节

例如：

- 看到 `TDLib`、`C++`、`NAPI`、`pointer`，先加载 Native Boundary Skill；
- 看到 `message stream`、`chat timeline`、`push update`，先加载并发与状态 Skill；
- 看到 `session recovery`、`cache`、`unread count`，先加载状态与存储 Skill。

### 8.2 让 Agent 先理解拓扑，再生成代码

真正高风险的错误往往不是语法错，而是：

- 在错误线程改 UI；
- 在错误层保存真值；
- 在错误边界释放资源；
- 在错误时机做全量刷新；
- 在错误位置做错误恢复。

这些都需要 `Execution Topology`、`State Contract`、`Boundary Contract` 明确约束。

### 8.3 让 Agent 先理解组合关系，再装配局部 Skill

Telegram 级任务几乎都不是一个 Skill 能独立解决的。更常见的情况是：

- 一个 Architecture Skill 决定总边界；
- 两到三个 Pattern Skill 负责状态或服务协作；
- 若干 Atomic Skill 负责具体 API 写法。

所以 Skill 系统必须支持组合，而不是平铺。

---

## 9. 结论

### 9.1 当前 TelegramHarmony 的真正价值

当前 TelegramHarmony 的最大价值，不是“它已经给了我们完整 TDLib 方案”，而是它暴露了：

- 纯 ArkTS 路线下客户端工程到底有多复杂；
- Signal、Service、ViewModel、Storage、Transport 如何共同构成聊天应用；
- 为什么状态与并发问题比页面语法更关键。

### 9.2 未来仓颉翻译面临的真正门槛

未来如果真的要翻译 Telegram 级别工程，最大门槛不是把 ArkUI 代码翻成仓颉，而是让 Agent 具备：

- 互操作边界意识；
- 线程与主线程提交意识；
- 大规模状态树分层意识；
- 缓存、协议、UI 三者协同意识；
- 失败恢复与性能预算意识。

### 9.3 对 Skill 体系的最终反推

因此后续 Skill 体系必须至少单列：

- `Native Boundary / C-Interop`
- `Concurrency / Execution Topology`
- `State Ownership / Store Architecture`
- `Protocol / Service Pipeline`
- `Observability / Failure Recovery`

只有当这些维度被正式纳入 Taxonomy 和 Schema，Agent 才有可能从“小样本翻译器”成长为“大型客户端工程迁移助手”。

---

## 10. Sources

- `https://github.com/ForestBook/TelegramHarmony`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/README.md`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/entry/src/main/ets/app/AppState.ets`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/docs/MESSAGE_SERVICE_ARCHITECTURE.md`
- `https://core.telegram.org/tdlib`
- `https://core.telegram.org/tdlib/docs/td__json__client_8h.html`
- `https://gitee.com/openharmony/docs/raw/master/en/application-dev/napi/ndk-development-overview.md`
- `https://gitee.com/openharmony/docs/raw/master/zh-cn/application-dev/napi/napi-guidelines.md`
- `/tmp/docs_cangjie_inspect/en/Overview-of-Cangjie-capabilities-in-OpenHarmony.md`
- `/tmp/docs_cangjie_inspect/en/application-dev/reference/arkinterop/cj-apis-ark_interop.md`
