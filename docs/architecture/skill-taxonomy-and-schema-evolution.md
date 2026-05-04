# Skill Taxonomy 与 Schema 演进方案（面向 Telegram 级别工程）

## 1. 文档目的

本文用于回答两个关键问题：

1. 当目标从“小样本 ArkTS 页面翻译”升级为“Telegram 级别的复杂鸿蒙应用翻译”时，Skill 库应如何分类，才能避免知识组织失真。
2. 当前 `skills/SKILL_SCHEMA_V1.md` 在单点 API 映射场景下已经可用，但如果未来要覆盖 C/C++ 互操作、复杂并发、全局状态架构、协议栈迁移等高压任务，Schema 还缺少哪些维度，应该如何升级为 V2。

本文不是实现文档，也不是自动化脚本方案。本文的目标是为后续大规模 Skill 建设提供知识组织原则、目录规划原则与 Schema 演进原则。

---

## 2. 为什么现在必须暂停“按样本经验批量生产 Skill”

前两个小样本已经证明了一件事：

- 当任务聚焦在页面布局、路由、Preferences 存取时，当前的 V1 Schema 足以组织“单点 API 映射”和“单页业务逻辑”。
- 但这类成功经验只覆盖了巨型项目中的一小部分难度，主要集中在表现层与浅层数据层。

如果现在直接把这套经验推广成大规模 Skill 生产机制，会有三个明显风险：

### 2.1 风险一：把“组件映射问题”误判为“系统架构问题”的通解

UI/路由样本解决的是：

- ArkUI 声明式页面结构；
- 页面状态绑定；
- 路由跳转与参数传递；
- 页面生命周期；
- 小规模页面逻辑。

它没有解决：

- 全局状态所有权；
- 高并发消息流的调度拓扑；
- Native 边界上的内存管理；
- 协议栈与 UI 的解耦；
- 多层缓存一致性；
- 大型工程中的依赖约束与失败恢复。

### 2.2 风险二：把“单点 API Skill”错误套用于“跨层设计模式”

Preferences Skill 可以告诉 Agent：

- 如何保存和读取用户设置；
- 如何抽象 `IStorage`；
- 如何用 Fake Store 做单测。

但它无法回答：

- 认证态应该属于全局 Store 还是会话 Store；
- 消息时间线的真实来源是内存缓存、磁盘索引还是网络推送；
- Native 回调线程收到消息后，应该先落缓存还是先驱动 UI；
- 长连接断开重连后，状态树如何补偿；
- 多页面共享同一份聊天列表时，谁拥有变更权。

### 2.3 风险三：把“ArkTS 页面翻译”误认为 Telegram 级别工程的主难点

Telegram 级别工程的真正难点并不在于把一个页面翻成另一种语言，而在于以下系统性边界：

- 协议层与 UI 层的边界；
- Native 库与托管语言运行时之间的边界；
- 主线程 UI 状态与后台并发任务之间的边界；
- 全局状态、页面状态、持久化缓存之间的边界；
- 可观测性、失败恢复、性能预算之间的边界。

因此，当前阶段最重要的工作不是“继续多做几个页面 Skill”，而是先设计一套可以承载复杂边界知识的 Taxonomy 与 Schema。

---

## 3. 前提纠偏：TelegramHarmony 现实并不是现成 TDLib 封装工程

这一点必须先说清楚，否则后续 Skill 分类会从一开始就歪掉。

基于目前可见资料，`ForestBook/TelegramHarmony` 当前仓库的关键特征是：

- 其 README 明确强调使用 ArkTS / ArkUI 开发；
- 核心协议方向是 MTProto 2.0；
- 仓库内存在 `core/mtproto`、`AuthStorage`、`SignalKit`、`ServiceLocator` 等结构；
- 它更接近“纯 ArkTS 实现客户端协议栈 + 自定义响应式状态层”的路线，而不是“TDLib C++ 核心 + ArkTS UI 壳”的现成桥接路线。

这意味着未来的 Skill Taxonomy 必须从一开始就覆盖两条技术路线，而不能只覆盖其中一条：

### 3.1 路线 A：纯 ArkTS / 仓颉侧协议实现路线

这类工程的核心 Skill 会集中在：

- Socket / Transport；
- MTProto / 自定义协议栈；
- Session 与 Auth Key 管理；
- 本地缓存与索引；
- 响应式状态流；
- UI 与数据流收敛；
- 业务服务与 ViewModel 组织。

### 3.2 路线 B：TDLib / C++ / Native Bridge 路线

这类工程的核心 Skill 会集中在：

- NAPI / NDK / C-Interop；
- ABI 与二进制边界；
- JSON Client 接口包装；
- 指针、内存所有权与生命周期；
- 跨线程回调与主线程投递；
- Native 错误到高层错误模型的映射；
- C++ 核心与 ArkUI 页面的隔离。

如果 Skill 体系只能描述路线 A，就无法翻译未来的 Native 桥接场景。
如果 Skill 体系只能描述路线 B，就无法解释当前 TelegramHarmony 这类纯 ArkTS 实现。

所以 Taxonomy 必须把“协议自实现型工程”和“原生桥接型工程”同时纳入知识图谱。

---

## 4. Skill Taxonomy 的设计原则

为了支撑 Telegram 级别工程，Skill Taxonomy 不能只按 API 名称、页面类型、组件类别来分目录。它至少要同时满足五条原则。

### 4.1 原则一：按“架构层”组织，而不是按“文档章节”组织

官方文档往往按 Kit、模块、组件、接口分类，这种方式方便查阅，但不一定适合 Agent 决策。

Agent 在真实任务中更常面对的是：

- 我现在是在处理表现层还是互操作边界；
- 我现在是在迁移状态模式还是迁移协议实现；
- 这个问题是线程边界问题还是 API 缺失问题；
- 我应该先加载 UI Skill、存储 Skill，还是先加载 Native Boundary Skill。

因此，Skill 体系必须先表达系统架构层，再挂接具体 API。

### 4.2 原则二：按“边界类型”组织，而不是按“文件后缀”组织

大型工程真正危险的地方都发生在边界：

- UI 主线程与后台线程边界；
- ArkTS / 仓颉与 C/C++ 边界；
- 内存对象与序列化对象边界；
- 本地缓存与远端真值边界；
- 页面局部状态与全局共享状态边界。

Skill 必须让 Agent 在读到任务时，第一时间知道自己碰到的是哪一种边界，以及这类边界的约束是什么。

### 4.3 原则三：按“执行拓扑”组织，而不是按“语法结构”组织

对 Telegram 级别工程而言，任务不只是“把 A 语法翻成 B 语法”。
真正重要的是：

- 代码跑在哪个线程；
- 数据从哪里流入；
- 哪一层拥有写权限；
- 何时合并增量；
- 何时必须回到主线程提交 UI。

因此，Skill 必须能表达执行路径和线程亲和，而不只是表达语法差异。

### 4.4 原则四：按“状态所有权”组织，而不是按“页面功能”组织

巨型应用的状态通常跨页面、跨模块、跨生命周期共享。仅用“聊天页 Skill”“登录页 Skill”这种分类，会把真正的状态问题掩盖掉。

Skill 需要能明确描述：

- 某份状态由谁拥有；
- 谁可以修改；
- 谁只能订阅；
- 何时持久化；
- 何时从网络恢复；
- 失败后如何回滚。

### 4.5 原则五：目录树只是主索引，元数据标签必须并存

即使设计出一棵很好的目录树，它也无法完整表达多维度知识。例如：

- 一个 `TDLib JSON Client` Skill 同时属于 Native Boundary、并发模型、错误恢复、协议服务层；
- 一个 `Message Timeline Delta Merge` Skill 同时属于状态层、并发层、性能层、领域层。

因此，建议采用“目录树 + 结构化元数据标签”的双轨方案：

- 目录树提供主导航；
- Skill 元数据提供二级检索与自动路由。

---

## 5. 面向巨型项目的 Skill 分类树构想

下面给出一棵可以支撑 Telegram 级别项目的一级至三级分类树。目录名称可以后续微调，但一级结构建议保持稳定。

```text
skills/
├── 00-foundation-language-runtime/
│   ├── syntax-and-type-system/
│   ├── module-package-build/
│   ├── testing-and-assertion/
│   ├── diagnostics-and-compiler-errors/
│   └── arkts-to-cangjie-basic-mapping/
├── 10-ui-and-interaction/
│   ├── arkui-primitives/
│   ├── layout-and-collection-views/
│   ├── navigation-routing-and-lifecycle/
│   ├── forms-input-and-focus/
│   ├── theme-animation-and-visual-feedback/
│   └── rendering-performance-and-virtualization/
├── 20-state-and-dataflow/
│   ├── page-local-state/
│   ├── shared-viewmodel-state/
│   ├── reactive-signal-observable/
│   ├── event-bus-and-pubsub/
│   ├── dependency-injection-and-service-locator/
│   ├── cache-coherency-and-derived-state/
│   └── state-ownership-and-lifecycle/
├── 30-concurrency-and-execution-topology/
│   ├── main-thread-ui-boundary/
│   ├── async-await-promise-mapping/
│   ├── worker-and-taskpool/
│   ├── native-callback-thread-affinity/
│   ├── batching-throttling-and-backpressure/
│   └── cancellation-retry-and-shutdown/
├── 40-storage-and-data-layer/
│   ├── preferences-and-key-value/
│   ├── relational-store-and-query-mapping/
│   ├── file-cache-and-binary-assets/
│   ├── media-index-and-large-object-management/
│   ├── serialization-versioning-and-schema-evolution/
│   └── offline-first-sync-and-reconciliation/
├── 50-network-protocol-and-services/
│   ├── http-rpc-and-rest/
│   ├── websocket-and-long-connection/
│   ├── tcp-socket-and-custom-transport/
│   ├── auth-session-and-token-refresh/
│   ├── mtproto-tl-schema-and-update-pipeline/
│   ├── upload-download-and-resumable-transfer/
│   └── error-taxonomy-and-network-recovery/
├── 60-native-boundary-and-c-interop/
│   ├── napi-and-ndk-bridge/
│   ├── c-interop-basic-types/
│   ├── buffer-string-and-binary-ownership/
│   ├── pointer-lifetime-and-resource-release/
│   ├── callback-marshalling-and-thread-handoff/
│   ├── native-error-to-domain-error-mapping/
│   └── tdlib-json-client-bridge/
├── 70-platform-capabilities-and-ability-framework/
│   ├── uiability-and-stage-lifecycle/
│   ├── permissions-and-capability-declaration/
│   ├── notification-background-task-and-push/
│   ├── media-camera-file-and-system-services/
│   └── context-injection-and-platform-adapters/
├── 80-observability-quality-and-verification/
│   ├── logging-and-redaction/
│   ├── tracing-metrics-and-performance-baseline/
│   ├── unit-test-integration-test-and-fakes/
│   ├── compile-run-failure-triage/
│   ├── benchmark-and-regression-watch/
│   └── reproducible-execution-trace/
├── 90-security-privacy-and-compliance/
│   ├── secret-handling-and-key-management/
│   ├── local-encryption-and-sensitive-storage/
│   ├── pii-redaction-and-log-safety/
│   ├── capability-minimization/
│   └── trust-boundary-and-input-validation/
├── 100-domain-features-telegram/
│   ├── auth-login-and-2fa/
│   ├── dialog-list-and-chat-list/
│   ├── message-timeline-and-local-echo/
│   ├── media-message-upload-download/
│   ├── contacts-search-and-discovery/
│   ├── group-channel-and-membership/
│   └── bot-inline-and-special-message-types/
└── 110-build-release-and-operations/
    ├── project-topology-and-module-splitting/
    ├── oh-package-build-profile-and-product-config/
    ├── devEco-import-and-sync-repair/
    ├── ci-cd-and-artifact-collection/
    └── release-hardening-and-rollback/
```

---

## 6. 每一大类为何必要

下面对一级分类的必要性进行逐一解释。

### 6.1 `00-foundation-language-runtime`

这一层是所有翻译任务的基础能力层，负责承载：

- 仓颉基础语法；
- 类型系统与泛型；
- 包管理与模块组织；
- 编译与测试命令；
- 基础诊断与错误解释；
- ArkTS 到仓颉的基础语法映射。

如果这一层不稳定，后续任何高阶 Skill 都会在语法和工具链层面反复失败。

### 6.2 `10-ui-and-interaction`

这一层只关心界面表现，不承载全局架构推理。它负责：

- 组件与布局；
- 页面导航；
- 生命周期；
- 表单与输入；
- 动画、主题、视觉交互；
- 列表虚拟化与渲染优化。

这是最接近“小样本验证”的区域，但它不能越权承担全局状态与线程边界决策。

### 6.3 `20-state-and-dataflow`

这是 Telegram 级别工程必须单列的一层。它负责：

- 页面局部状态；
- ViewModel 层状态；
- 全局共享状态；
- 响应式信号流；
- 事件总线；
- 依赖注入与服务定位；
- 衍生状态、缓存状态、状态生命周期。

如果不把状态层独立出来，Agent 很容易用页面级 Skill 去处理全局一致性问题，最终导致错位设计。

### 6.4 `30-concurrency-and-execution-topology`

这是当前 V1 几乎没有显式表达、但未来绝对绕不开的一层。它负责：

- UI 主线程边界；
- 异步模型映射；
- worker / taskpool；
- Native 回调的线程亲和；
- 批量合并、背压、节流；
- 取消、重试、关闭过程。

Telegram 级消息流如果没有这一层的 Skill 约束，UI 一定会被高频更新拖垮，或者出现跨线程状态修改错误。

### 6.5 `40-storage-and-data-layer`

这一层不只是“怎么存”，更负责回答：

- 存什么；
- 谁拥有真值；
- 如何版本演进；
- 如何从磁盘与网络合并；
- 如何管理大对象与媒体索引；
- 如何在离线与在线之间保持一致性。

对于聊天应用而言，存储层不是附属层，而是状态体系的重要组成部分。

### 6.6 `50-network-protocol-and-services`

这一层承担：

- HTTP、RPC、长连接；
- 自定义 transport；
- 协议编码与解码；
- Auth 会话管理；
- 文件传输；
- 网络错误分类与恢复。

在纯 ArkTS MTProto 路线里，这是核心战场；在 TDLib 路线里，这一层更多表现为上层服务语义映射。

### 6.7 `60-native-boundary-and-c-interop`

这是 Telegram 级别工程最容易被低估的一层。它负责：

- Node-API / NDK；
- C 互操作；
- Buffer 和字符串桥接；
- 指针与资源释放；
- 回调封送；
- Native 错误转换；
- TDLib JSON Client 包装。

如果这一层没有单独的 Skill 分类，Agent 会误把 Native 桥接问题当成普通 API 对接问题，风险极高。

### 6.8 `70-platform-capabilities-and-ability-framework`

这一层负责鸿蒙平台约束与系统能力接入，例如：

- UIAbility 生命周期；
- 权限声明；
- 通知与后台任务；
- 媒体、文件、相机等系统服务；
- Context 注入与平台适配。

这类知识常常影响工程初始化与运行时行为，但不能和业务 Skill 混在一起。

### 6.9 `80-observability-quality-and-verification`

这一层负责让 Agent 从“能生成代码”进化到“能验证代码”。它包含：

- 日志策略；
- Trace 与指标；
- 单元测试与 Fake；
- 编译失败与运行失败分类；
- 性能回归；
- 可复现实验轨迹。

如果没有这一层，Skill 只会生成知识，不会生成闭环。

### 6.10 `90-security-privacy-and-compliance`

Telegram 级别工程涉及账号、会话、聊天记录、媒体、隐私数据，这一层必须独立出来。它负责：

- 密钥处理；
- 敏感数据本地保护；
- 日志脱敏；
- 能力最小化；
- 输入边界校验；
- 信任边界定义。

### 6.11 `100-domain-features-telegram`

前面各层负责通用架构能力，这一层负责 Telegram 领域语义，例如：

- 登录与二次验证；
- 会话列表；
- 聊天消息时间线；
- 媒体上传下载；
- 群组与频道；
- 联系人、搜索与机器人能力。

这一层不能替代通用层，但它能把通用层组合成领域任务模板。

### 6.12 `110-build-release-and-operations`

这一层负责从“可以开发”走向“可以交付”。它包括：

- 工程拓扑与模块拆分；
- `oh-package.json5` / `build-profile.json5`；
- DevEco 导入与同步修复；
- CI / 构建工件；
- 发布与回滚。

这类知识不是业务逻辑，却直接决定项目是否能被真实导入、编译、验证。

---

## 7. Skill 不应只有一种粒度：Atomic / Pattern / Architecture 三层并存

除了目录分类，Skill 还需要按粒度分层。建议将 Skill 分成三类。

### 7.1 Atomic Skill

Atomic Skill 用于解决单点知识映射，特征是：

- 面向单一 API、单一组件、单一语法特性；
- 通常可以在单文件或单函数范围内应用；
- 输入上下文较小；
- 检索降级路径相对简单。

典型例子：

- List / Grid 布局映射；
- Preferences 存取；
- Router 参数传递；
- 简单日志调用。

### 7.2 Pattern Skill

Pattern Skill 用于解决跨文件、跨对象的设计模式迁移，特征是：

- 关注职责边界和协作关系；
- 常涉及多个类、多个模块；
- 同时依赖状态、线程、生命周期等约束；
- 需要更强的测试与验证指引。

典型例子：

- ViewModel + Store + Page 的协作映射；
- 本地缓存 + 网络同步的模式迁移；
- Fake Store + 真实存储实现的依赖注入模式；
- Service Locator 到显式依赖注入容器的改写。

### 7.3 Architecture Skill

Architecture Skill 用于描述系统级边界和运行拓扑，特征是：

- 面向线程、进程、运行时、协议栈、Native 边界；
- 决定多个 Pattern Skill 如何组合；
- 常常需要表达“必须如此”的约束，而不是“可以这样写”的建议；
- 一旦判断错误，会导致系统级错误而不是单点编译错误。

典型例子：

- TDLib JSON Client 单消费者接收循环；
- C-Interop 中 Buffer 所有权管理；
- 海量消息增量更新的主线程收敛模式；
- 全局状态树与页面局部状态的分层策略。

### 7.4 调用策略建议

- Atomic Skill 默认可直接按 Trigger Condition 命中。
- Pattern Skill 应在任务包含多文件修改、状态协作、测试补齐时优先装载。
- Architecture Skill 应在任务涉及 Native、线程、全局状态、长连接、协议栈、性能或失败恢复时强制装载。

也就是说，后续的 Agent 路由不能只靠关键词匹配，还应结合 `Skill Class` 与任务风险等级决定装载顺序。

---

## 8. 为什么不能只按 API、组件或页面类型来分类

这一点值得单独展开，因为它是 Skill 库最容易出问题的地方。

### 8.1 API 分类会把“约束”隐藏掉

例如 `@ohos.data.preferences` 与 `@ohos.hilog` 都是 API，但前者关乎状态持久化与默认值语义，后者关乎可观测性与脱敏策略。它们在工程中的决策意义完全不同。

如果只按 API 分桶，Agent 会得到“查得到接口，却看不到约束”的坏结果。

### 8.2 组件分类会把“数据来源”隐藏掉

例如“消息列表页面”从 UI 角度看是一个列表组件问题，但它真正依赖的是：

- 增量更新策略；
- 本地缓存；
- 网络回放；
- 滚动窗口；
- 未读状态；
- 发送中的本地回显；
- 并发合并顺序。

这些都不是组件本身能解释的。

### 8.3 页面分类会把“共享状态”切碎

例如登录页、聊天页、设置页看起来是不同页面，但它们共享：

- 当前用户身份；
- 会话与连接状态；
- 权限和能力；
- 主题配置；
- 缓存目录与存储策略。

如果每个页面 Skill 各写一套状态说明，最终一定互相矛盾。

### 8.4 只按源码文件分类，会让 Agent 丧失组合能力

大型工程里的一个任务经常同时涉及：

- 一个 ViewModel；
- 一个全局 Store；
- 一个 Native 接口包装；
- 一个测试 Fake；
- 一个 README 或轨迹记录。

如果 Skill 体系不能跨这些对象组合，Agent 只能头痛医头、脚痛医脚。

---

## 9. `SKILL_SCHEMA_V1` 的优势与当前局限

当前 `SKILL_SCHEMA_V1.md` 已经具备良好的基础框架，尤其适合以下场景：

- 小样本翻译；
- 单点 API 知识卡片；
- 从触发条件到代码示例的快速查阅；
- 带检索降级的渐进式披露；
- 结合测试与排错的最小闭环。

它的现有字段已经覆盖：

- `Trigger Condition`；
- `Core Concept`；
- `Progressive Modules`；
- `Translation Mapping`；
- `Examples`；
- `Retrieval Fallback`；
- `Test & Debug`；
- `Sources`；
- `Known Gaps`；
- `Evolution Log`。

这些字段对 Atomic Skill 十分有效，但面对巨型工程时，V1 有以下六类明显缺口。

### 9.1 缺少架构映射维度

V1 擅长表达“ArkTS 的某个 API 对应到仓颉怎么写”，却难以表达：

- ArkTS 中的某种架构模式在仓颉里应该如何重构；
- Service Locator 是否要保留，还是改为显式依赖注入；
- ViewModel 与全局 Store 的职责边界如何迁移；
- Native Bridge 应该落在哪一层。

### 9.2 缺少依赖约束维度

V1 无法清楚说明：

- 这个 Skill 依赖哪些上游 Skill；
- 与哪些能力必须联合使用；
- 在缺少某些环境前提时不能直接套用；
- 哪些模块不应该互相直接依赖。

### 9.3 缺少执行拓扑维度

V1 几乎不表达线程、主线程亲和、回调封送、任务调度。这会在以下场景中失效：

- 长连接回调；
- Native 线程到 UI 线程的切换；
- worker / taskpool；
- 流式消息合并；
- 大对象解析与 UI 提交的分工。

### 9.4 缺少状态契约维度

V1 不擅长说明：

- 谁拥有这份状态；
- 状态的真实来源是什么；
- 哪些字段允许乐观更新；
- 何时刷盘；
- 何时以网络为准；
- 跨页面共享的一致性规则。

### 9.5 缺少性能预算与失败模型维度

Telegram 级项目中，很多方案并不是“能跑就行”，而是必须满足：

- 更新吞吐量；
- UI 主线程占用预算；
- 内存峰值控制；
- 重连恢复时间；
- 丢包、重复消息、顺序错乱时的行为；
- Native 调用失败、序列化失败时的恢复路径。

V1 几乎没有位置去系统描述这些内容。

### 9.6 缺少 Skill 组合规则维度

V1 默认把每个 Skill 看成独立文档，但对巨型工程而言，更重要的是：

- 这个 Skill 应该和哪些 Skill 一起装载；
- 它是作为前置 Skill，还是作为补充 Skill；
- 它是否必须压制某些低层 Skill 的自动触发；
- 它是否会改变其它 Skill 的适用边界。

---

## 10. Schema V2 的核心补充字段提案

Schema V2 应保留 V1 的渐进式披露结构，但新增一组面向“系统级推理”的字段。下面给出建议字段及其作用。

### 10.1 `Skill Class`

**作用**：标记该 Skill 属于 `Atomic`、`Pattern` 还是 `Architecture`。

**为什么必须增加**：

它直接决定 Agent 的装载方式、上下文预算和优先级策略。如果不显式标注，Agent 会把所有 Skill 当作同一类型文档处理。

### 10.2 `Architecture Mapping`

**作用**：描述源工程中的架构角色，到目标工程中的架构角色如何对应。

**应回答的问题**：

- 源侧的 Service、Store、Adapter、Bridge、Page、ViewModel 对应到目标侧什么角色；
- 是直译保留，还是建议重构；
- 哪些职责必须拆开；
- 哪些职责允许合并。

### 10.3 `Dependency Constraint`

**作用**：明确该 Skill 的依赖前提、禁止依赖和可选依赖。

**应回答的问题**：

- 使用前必须先具备哪些 Skill；
- 与哪些 Skill 联合时才完整；
- 与哪些模式冲突；
- 缺少哪些环境条件时只能输出设计稿，不能输出实现。

### 10.4 `Boundary Contract`

**作用**：表达系统边界上的输入输出契约。

**应回答的问题**：

- 这个 Skill 跨越了哪些边界；
- 边界两侧的数据格式是什么；
- 生命周期归属谁；
- 错误如何跨边界传递；
- 谁负责资源释放。

对于 C-Interop、NAPI、Socket 回调、磁盘缓存合并等场景，这个字段是必需的。

### 10.5 `Execution Topology`

**作用**：明确执行路径、线程亲和与调度责任。

**应回答的问题**：

- 代码运行在哪个线程；
- 谁可以直接触达 UI 状态；
- 回调如何从后台线程切回主线程；
- 何处允许批处理；
- 何处必须串行。

### 10.6 `State Contract`

**作用**：表达状态的真值来源、所有权和一致性策略。

**应回答的问题**：

- 这份状态由谁拥有；
- 哪些修改是乐观写入；
- 哪些更新必须等待远端确认；
- 是否需要持久化；
- 缓存与网络的合并优先级是什么；
- 页面销毁后哪些状态应保留。

### 10.7 `Performance Envelope`

**作用**：为该 Skill 关联的实现方案给出性能边界和预算。

**应回答的问题**：

- 是否允许在主线程做序列化或大对象转换；
- 更新频率高时是否需要合并；
- 列表是否必须虚拟化；
- Native 回调是否必须走批量投递；
- 内存与延迟的取舍是什么。

### 10.8 `Failure Model`

**作用**：定义该 Skill 覆盖场景下的典型失败方式与恢复策略。

**应回答的问题**：

- 常见编译失败是什么；
- 常见运行失败是什么；
- 顺序错乱、重复消息、超时、回调丢失时怎么办；
- 出错后是重试、降级、回滚还是中止。

### 10.9 `Verification Matrix`

**作用**：把验证从“一个测试建议”升级为“多维验证矩阵”。

**应回答的问题**：

- 哪些内容可以单测；
- 哪些内容必须集成测试；
- 哪些内容必须人工在 DevEco / 模拟器中验证；
- 哪些内容需要日志、trace、性能指标共同判定。

### 10.10 `Composition With Other Skills`

**作用**：显式描述 Skill 组合关系。

**应回答的问题**：

- 当前 Skill 常见的组合伙伴有哪些；
- 顺序是先加载谁；
- 哪些高阶 Skill 会覆盖当前 Skill 的默认做法；
- 哪些 Skill 不应同时启用。

### 10.11 `Security / Privacy Constraint`

**作用**：把安全与隐私要求提升为一等元信息。

**应回答的问题**：

- 是否涉及账号、token、聊天记录、文件路径、隐私字段；
- 日志是否必须脱敏；
- 本地存储是否必须加密；
- 哪些对象禁止写入轨迹文件。

### 10.12 `Migration Strategy`

**作用**：描述从样本级实现迁移到工程级实现时的策略。

**应回答的问题**：

- 当前写法是否只是小样本方案；
- 升级到巨型工程时需要替换哪些模块；
- 何时应该从纯 ArkTS 路线切到 Native Bridge 路线；
- 哪些测试资产可以直接复用。

---

## 11. 建议保留并继承的 V1 字段

Schema V2 不是推倒重来。以下 V1 字段仍然非常重要，建议保留：

- `Trigger Condition`：仍然是 Skill 命中入口；
- `Core Concept`：仍然是最短知识压缩层；
- `Progressive Modules`：仍然是渐进式披露的骨架；
- `Translation Mapping`：仍然适合保留源语言到目标语言的直接映射；
- `Examples`：仍然用于小而具体的示例；
- `Retrieval Fallback`：仍然是未知场景的安全出口；
- `Test & Debug`：仍然是最低限度的验证入口；
- `Sources`、`Known Gaps`、`Evolution Log`：仍然是长期维护必需字段。

也就是说，V2 不是替换 V1，而是在 V1 之上补齐系统级维度。

---

## 12. Schema V2 建议骨架

下面给出一个建议性的 V2 结构草案，后续可以再精炼，但整体形状建议保持。

```markdown
# Skill Metadata
- Skill ID:
- Skill Name:
- Skill Class:
- Scope:
- Tags:
- Version:

# Trigger Condition
- 任务触发条件：
- 强制触发条件：
- 不适用条件：

# Core Concept
- 最短知识结论：
- 一句话风险提示：

# Architecture Mapping
- 源侧角色：
- 目标侧角色：
- 保留策略：
- 重构策略：

# Dependency Constraint
- 必需依赖：
- 可选依赖：
- 冲突依赖：
- 环境前提：

# Boundary Contract
- 边界类型：
- 输入：
- 输出：
- 生命周期归属：
- 资源释放责任：
- 错误传递方式：

# Execution Topology
- 线程模型：
- 主线程提交点：
- 后台处理点：
- 串行要求：
- 批处理要求：

# State Contract
- 状态所有者：
- 真值来源：
- 可变字段：
- 衍生字段：
- 持久化策略：
- 一致性规则：

# Progressive Modules
## Module 1：概念最小版
## Module 2：常见映射
## Module 3：跨层模式
## Module 4：工程级约束

# Translation Mapping
- ArkTS 对应写法：
- 仓颉对应写法：
- 允许差异：
- 禁止直译点：

# Performance Envelope
- 主线程预算：
- 吞吐量关注点：
- 内存关注点：
- 建议优化手段：

# Failure Model
- 常见编译失败：
- 常见运行失败：
- 高风险误用：
- 恢复策略：

# Verification Matrix
- 单元测试：
- Fake / Mock：
- 集成测试：
- 手动验证：
- 观测指标：

# Composition With Other Skills
- 前置 Skill：
- 常见组合：
- 覆盖关系：
- 禁止组合：

# Retrieval Fallback
- 官方文档入口：
- 仓库检索入口：
- CLI / Python 检索示例：
- 升级提问模板：

# Security / Privacy Constraint
- 敏感数据范围：
- 脱敏规则：
- 本地存储要求：
- 日志限制：

# Migration Strategy
- 小样本做法：
- 工程级替代方案：
- 何时升级：
- 升级检查点：

# Examples
- 示例一：
- 示例二：

# Test & Debug
- 快速验证步骤：
- 排错顺序：
- 常见误判：

# Sources
- 来源列表：

# Known Gaps
- 当前空白：

# Evolution Log
- 版本演进记录：
```

---

## 13. V1 到 V2 的演进建议

为了避免一口气重写所有 Skill，建议采用分阶段演进。

### 13.1 第一阶段：保留 V1，新增 `Skill Class` 与 Tags

先不大改现有 Skill，只做最关键的元数据补充：

- 给已有 Skill 增加 `Skill Class`；
- 给已有 Skill 增加 `Tags`；
- 建立一级目录约定。

这一阶段的目标是让 Agent 至少能分辨“这是 Atomic Skill，还是更高阶的 Skill”。

### 13.2 第二阶段：只为高风险领域启用 V2 全字段

优先给以下高风险领域建立 V2 文档：

- Native Boundary / C-Interop；
- Concurrency / Main-Thread UI Boundary；
- 全局状态树与消息流；
- 协议栈与长连接；
- 离线缓存与同步补偿。

原因很简单：这些领域一旦分类错误，代价最大。

### 13.3 第三阶段：从“小样本 Skill”中提炼 Pattern Skill

当前已经完成的 UI / 路由、Preferences 样本，不应该只保留为 Atomic Skill。后续应从中抽象出：

- 页面状态初始化模式；
- 依赖注入与 Fake 测试模式；
- `Context` 注入平台适配模式；
- 手动验证 Checklist 模式。

这些 Pattern Skill 将成为大工程里的中层积木。

### 13.4 第四阶段：让 Agent 路由逻辑识别高阶边界

未来的 Skill 调度器不应只根据关键词触发，还应根据任务特征做判断。例如：

- 任务中出现 C、C++、NAPI、指针、Buffer、TDLib 时，自动加载 `60-native-boundary-and-c-interop` 下的 Architecture Skill；
- 任务中出现长连接、流式消息、批量更新、chat timeline 时，自动加载 `30-concurrency-and-execution-topology` 与 `20-state-and-dataflow` 的组合 Skill；
- 任务中出现缓存、持久化、未读状态、离线恢复时，自动加载 `40-storage-and-data-layer` 与 `20-state-and-dataflow` 的 Pattern Skill。

---

## 14. 对目录组织和调用策略的具体建议

### 14.1 目录组织建议

建议未来 Skill 仓库采用如下原则：

- 一级目录按架构层稳定；
- 二级目录按问题域细化；
- 文件级 Skill 按单一职责命名；
- 每个 Skill 都显式标注 `Skill Class`；
- 每个 Skill 都带 tags，用于横向检索。

### 14.2 调用策略建议

建议将 Skill 调用分为三段：

1. **任务识别阶段**：根据需求文本识别风险边界。
2. **主 Skill 装载阶段**：优先装载对应层级的 Architecture Skill 或 Pattern Skill。
3. **补充 Skill 装载阶段**：再加载相关 Atomic Skill 填补 API 细节。

这意味着后续 Agent 不应该直接从 API Skill 开始，而应该先判断任务的架构边界。

### 14.3 复盘策略建议

后续每完成一个高价值样本，都应该问三个问题：

1. 这次新知识属于 Atomic、Pattern 还是 Architecture；
2. 它应该进入哪个一级目录；
3. 它是否暴露了 V2 Schema 还缺的字段。

只有这样，Skill 库才会随着项目成长，而不是随着样本数量膨胀。

---

## 15. 结论

### 15.1 结论一：当前必须先做 Taxonomy，再做批量 Skill 生产

因为 Telegram 级别工程的主要难点不在单页 UI，而在：

- Native 边界；
- 并发拓扑；
- 状态所有权；
- 协议与缓存协同；
- 大型工程依赖约束。

这些问题如果不先进入分类树，后续 Skill 越多，混乱越大。

### 15.2 结论二：Skill 体系必须同时覆盖两条技术路线

Skill Taxonomy 必须同时容纳：

- 纯 ArkTS / 仓颉协议自实现路线；
- TDLib / C++ / Native Bridge 路线。

否则未来面对 Telegram 级工程时，会在核心边界上失去指导能力。

### 15.3 结论三：Schema V2 的核心升级方向是“让 Agent 理解约束”

V1 解决的是“知识怎么写”。
V2 需要解决的是“知识怎么参与系统级决策”。

所以 V2 的核心不是再增加更多示例，而是补齐：

- 架构映射；
- 依赖约束；
- 边界契约；
- 执行拓扑；
- 状态契约；
- 性能预算；
- 失败模型；
- 验证矩阵；
- Skill 组合关系；
- 安全与迁移约束。

### 15.4 结论四：后续 Skill 建设应按“Atomic → Pattern → Architecture”节奏推进

下一步不应直接自动化批量生产，而应优先挑选几个高压场景做 V2 试点：

- Native Bridge / C-Interop；
- 流式消息与主线程收敛；
- 全局状态树与缓存一致性；
- 协议栈与服务适配层。

只要这几个领域的 V2 Skill 能站稳，后续大规模 Skill 建设才有正确骨架。

---

## 16. Sources

- `skills/SKILL_SCHEMA_V1.md`
- `docs/reports/2026-03-26-frontier-research-and-skill-strategy.md`
- `https://github.com/ForestBook/TelegramHarmony`
- `https://raw.githubusercontent.com/ForestBook/TelegramHarmony/main/README.md`
- `https://core.telegram.org/tdlib`
- `https://core.telegram.org/tdlib/docs/td__json__client_8h.html`
- `https://gitee.com/openharmony/docs/raw/master/en/application-dev/napi/ndk-development-overview.md`
- `https://gitee.com/openharmony/docs/raw/master/zh-cn/application-dev/napi/napi-guidelines.md`
- `/tmp/docs_cangjie_inspect/en/Overview-of-Cangjie-capabilities-in-OpenHarmony.md`
- `/tmp/docs_cangjie_inspect/en/application-dev/reference/arkinterop/cj-apis-ark_interop.md`
