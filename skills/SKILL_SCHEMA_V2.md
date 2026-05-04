# 鸿蒙仓颉 Skill Schema V2

## 1. 定位

本文件是当前仓库中 Skill 的正式标准模板。从本文件起：

- 新建 Skill 默认使用 V2；
- `SKILL_SCHEMA_V1.md` 作为历史参考保留，不再作为新增 Skill 的主模板；
- 若某个旧 Skill 仍沿用 V1，应在后续重构时补齐 V2 的系统级字段。

V2 的核心目标不是单纯增加字段，而是让 Skill 从“知识卡片”升级为“可参与系统级决策的结构化约束”。

V2 继续保留 V1 的渐进式披露优点，同时正式补齐以下能力：

- 区分 Atomic / Pattern / Architecture 三种粒度；
- 明确架构角色映射，而不仅是 API 对应关系；
- 明确边界契约、线程拓扑、状态所有权和生命周期；
- 明确依赖约束、性能预算、失败模型与验证矩阵；
- 明确 Skill 之间的组合关系，降低误用风险。

---

## 2. 使用原则

### 2.1 适用范围

V2 适用于以下三类 Skill：

- **Atomic Skill**：单点 API、组件、语法特性、局部模式映射；
- **Pattern Skill**：跨文件、跨对象、跨职责的设计模式迁移；
- **Architecture Skill**：线程边界、状态边界、Native 边界、协议拓扑、系统性约束。

### 2.2 编写原则

编写 Skill 时，必须遵守以下原则：

1. **先写约束，再写示例。** 对高风险问题，架构和边界比代码片段更重要。
2. **先写角色，再写实现。** 先说明源侧和目标侧分别由谁负责，再写转换方法。
3. **先写生命周期，再写共享方式。** 跨页面共享状态不能只说明怎么访问，必须说明何时创建、何时释放、谁能写入。
4. **先写主线程边界，再写 UI 绑定。** 凡是涉及响应式更新、网络、消息流、Signal、Native 回调，都要先明确线程归属。
5. **先写验证矩阵，再宣称可用。** 只给示例、不写验证方案的 Skill 视为不完整。

### 2.3 填写约定

- 所有字段都必须填写；如果当前确实未知，写“当前未知，需检索确认”，不能留空。
- 示例代码、CLI 示例、检索入口都必须是可执行或可直接照抄的形式。
- 不允许使用“同上”“略”“自行处理”“按需扩展”等空泛占位语句。
- `Architecture Skill` 必须重点填写：`Architecture Mapping`、`Boundary Contract`、`Execution Topology`、`State Contract`、`Failure Model`、`Verification Matrix`、`Architecture Review Gates`。
- 只要 Skill 涉及协议编解码、二进制 buffer、TL / MTProto / TDLib、低层网络包或原始 send API，就必须显式声明 `ARCH_PROTOCOL_ISOLATION` 的触发信号、否决条件与修复方向。
- 只要 Skill 涉及 DTO / Domain 边界清洗、协议对象上浮、共享状态并发写入、异步回调更新状态或 Signal 发布，就必须显式声明 `ARCH_DOMAIN_PURITY` 与 `ARCH_CONCURRENCY_SAFETY` 的触发信号、否决条件与修复方向。
- `Atomic Skill` 可以写得更精简，但仍必须保留 V2 全结构。

---

## 3. 字段总览与填写规范

下面按正式模板顺序给出字段定义与填写规范。每个字段都包含两部分：

- **字段作用**：该字段在 Agent 决策中的作用；
- **填写规范**：实际写 Skill 时应该填什么。

---

# Skill Metadata

## 字段作用

用于标识 Skill 的基础身份、粒度、版本和可检索标签，是所有后续自动路由和人工维护的入口。

## 填写规范

- `Skill ID`：使用稳定、可检索的唯一 ID，建议包含层级与主题，例如 `ARCH-STATE-OWNERSHIP-001`。
- `Skill Name`：使用简洁、可读的英文或中英混合名称，便于文件名和检索关键词统一。
- `Skill Class`：只能填 `Atomic`、`Pattern`、`Architecture` 三者之一。
- `Scope`：用一到三句话说明 Skill 覆盖的问题边界，不要把不相关能力写进来。
- `Tags`：使用逗号分隔的主题标签，覆盖技术域、平台、风险点、验证方式。
- `Version`：建议使用 `V2.0`、`V2.1` 这类版本号；如果是首个版本，填 `V2.0-initial`。

---

# Trigger Condition

## 字段作用

用于告诉 Agent 何时必须装载该 Skill，何时应优先装载，何时明确不应使用。

## 填写规范

- `任务触发条件`：列出任务文本中出现哪些需求、关键词或问题形态时应触发。
- `强制触发条件`：列出高风险场景，只要出现就必须装载该 Skill，不能依赖低层 Skill 替代。
- `不适用条件`：列出该 Skill 不应处理的问题，避免误命中。

触发条件应写成“问题类型 + 技术迹象”的形式，例如“跨页面共享状态 + `AppStorage` / `@StorageLink` / 全局 Store 关键词”。

---

# Core Concept

## 字段作用

用于在最短篇幅内压缩这个 Skill 的本质结论，让 Agent 在上下文有限时也能抓住主轴。

## 填写规范

- `最短知识结论`：只写一到三条最关键原则。
- `一句话风险提示`：写清最容易犯的致命错误。

这里不要写背景故事，只写“必须记住什么”。

---

# Architecture Mapping

## 字段作用

用于表达源工程角色与目标工程角色的映射关系，是 V2 相比 V1 最重要的升级字段之一。

## 填写规范

- `源侧角色`：列出源语言或源框架中承担该职责的对象、机制或模式。
- `目标侧角色`：列出目标侧应该对应到哪些对象或层次。
- `保留策略`：说明哪些设计可以近似保留，哪些命名或结构可以延续。
- `重构策略`：说明哪些设计不能直译，必须重建职责边界。

写法重点是“角色映射”，不是“语法替换”。

---

# Dependency Constraint

## 字段作用

用于表达 Skill 的前提条件、常见组合和冲突边界，避免 Agent 在缺少上下文时误用 Skill。

## 填写规范

- `必需依赖`：列出必须先理解或先加载的 Skill / 能力 / 环境。
- `可选依赖`：列出常见增强项。
- `冲突依赖`：列出会导致错误设计的 Skill 或模式。
- `环境前提`：列出需要的 IDE、插件、平台文档、运行环境、版本假设。

如果某个前提缺失，应写清“只能输出设计稿，不应直接输出实现”。

---

# Boundary Contract

## 字段作用

用于描述跨边界交互时的数据、职责和资源归属，是处理 Native、状态共享、消息流、缓存同步等场景的关键字段。

## 填写规范

- `边界类型`：说明是 UI 与后台边界、页面与全局状态边界、ArkTS 与 C 边界、缓存与网络边界等。
- `输入`：说明进入该边界的数据和控制信号。
- `输出`：说明边界产出的状态、事件、对象或错误。
- `生命周期归属`：说明边界两侧对象由谁创建、谁销毁。
- `资源释放责任`：说明谁负责订阅取消、句柄释放、缓存清理或回调解绑。
- `错误传递方式`：说明错误如何从底层传到上层。

该字段要像接口契约一样写，不能只写“负责通信”这种空话。

---

# Execution Topology

## 字段作用

用于表达线程模型、执行路径和调度责任，是并发安全和 UI 安全的核心字段。

## 填写规范

- `线程模型`：说明是否存在主线程、后台线程、worker、taskpool、native callback thread。
- `主线程提交点`：说明哪些状态更新必须在主线程发生。
- `后台处理点`：说明哪些计算、合并、解析应在后台完成。
- `串行要求`：说明哪些流程必须单消费者或严格有序。
- `批处理要求`：说明是否需要节流、聚合、背压或窗口化处理。

填写时务必写清“谁在什么线程干什么”。

---

# State Contract

## 字段作用

用于表达状态真值来源、所有权、生命周期和一致性规则，是状态类 Skill 的核心字段。

## 填写规范

- `状态所有者`：列出每类状态真正归谁拥有。
- `真值来源`：说明最终以页面内存、全局 Store、磁盘缓存、远端响应中的哪一方为准。
- `可变字段`：说明哪些字段允许直接修改。
- `衍生字段`：说明哪些字段只能计算得出，不能直接写入。
- `持久化策略`：说明是否需要刷盘、何时刷盘、由谁刷盘。
- `一致性规则`：说明网络、缓存、页面状态冲突时如何决策。

该字段不只是“状态有哪些”，而是“状态如何活着、谁能动它、什么时候失效”。

---

# Progressive Modules

## 字段作用

这是 V1 继承下来的渐进式披露骨架，用于把知识从最小概念逐层展开到工程级约束。

## 填写规范

必须至少包含以下四层：

- `Module 1：概念最小版`：用最短内容说清这个 Skill 的核心分层和禁止事项。
- `Module 2：常见映射`：列出源侧常见写法与目标侧常见写法。
- `Module 3：跨层模式`：说明跨页面、跨模块、跨线程、跨边界时的组织方式。
- `Module 4：工程级约束`：说明性能、生命周期、诊断、验证、迁移限制。

渐进模块不是复制粘贴四次，而是从浅到深真正递进。

---

# Translation Mapping

## 字段作用

用于表达源语言或源框架到目标架构或目标实现的具体映射关系。

## 填写规范

- `ArkTS 对应写法`：写源侧常见语法、装饰器、模式、对象关系。
- `仓颉对应写法`：写目标侧推荐的类、接口、Store、Adapter、状态模型或伪代码结构。
- `允许差异`：写哪些地方可以做实现差异化。
- `禁止直译点`：写哪些源侧机制绝对不能直接机械翻译。

映射内容可以是表格、要点列表或分段说明，但必须体现“何处可译、何处要重构”。

---

# Performance Envelope

## 字段作用

用于表达该 Skill 关联方案的性能预算和性能红线，防止 Agent 产出可编译但不可运行的设计。

## 填写规范

- `主线程预算`：写明主线程不应做什么。
- `吞吐量关注点`：写明高频事件下的风险点。
- `内存关注点`：写明缓存、对象复制、列表规模、订阅数量等风险。
- `建议优化手段`：写明可接受的优化策略。

这里不要求写具体毫秒数，但要明确禁止事项和优化方向。

---

# Failure Model

## 字段作用

用于表达典型失败路径和恢复方式，让 Skill 具备真正的工程鲁棒性。

## 填写规范

- `常见编译失败`：列出类型不匹配、缺少上下文、生命周期对象无法注入等问题。
- `常见运行失败`：列出状态错乱、线程越界、重复订阅、缓存污染等问题。
- `高风险误用`：列出最容易出现的设计性错误。
- `恢复策略`：说明如何定位和恢复。

不要只写“检查代码”，要写具体失效模式。

---

# Verification Matrix

## 字段作用

用于把验证要求拆成多层，帮助 Agent 和人类知道哪些内容能单测、哪些必须集成验证、哪些必须人工检查。

## 填写规范

- `单元测试`：列出纯逻辑、纯状态、纯映射部分的验证方式。
- `Fake / Mock`：列出应替换哪些外部依赖。
- `集成测试`：列出需要组合运行的模块。
- `手动验证`：列出必须在 DevEco、模拟器或真机中验证的点。
- `观测指标`：列出应记录哪些日志、trace、计数器或状态快照。

验证矩阵应体现“从轻到重”的验证层次。

---

# Architecture Review Gates

## 字段作用

用于把 Reviewer 的一票否决规则写成可执行的硬门槛，避免模型只做语句平移、不做职责剥离。该字段主要服务于 `Architecture Skill`，尤其适用于协议边界、线程边界、状态边界、Native 边界等高风险迁移。

## 填写规范

- `必查维度`：列出本 Skill 对 Reviewer 的默认强制检查项。
- `阻断条件`：写清哪些代码迹象一旦出现，Reviewer 必须直接判定为失败，而不是给出“建议优化”。
- `修复指令模板`：写清失败后应如何要求 Translator 重构。

其中，以下维度在涉及协议与二进制场景时为默认硬门槛：

- `ARCH_PROTOCOL_ISOLATION`：
  - **触发条件**：生成的 `Service` / `Repository` / `UseCase` / `ViewModel` 代码中，直接导入、实例化或调用 `TLSerializer`、`TLDeserializer`、`ArrayBuffer`、`Uint8Array`、TLBuffer、raw payload reader/writer、magic number 判断、constructor id 判断、`sendRequest` / `send` / `toBytes()` 等底层协议与二进制 API。
  - **判定规则**：只要上述任一迹象发生，Reviewer 必须返回 `pass = false`，并产生 `ARCH_PROTOCOL_ISOLATION` 问题码，不允许以“可接受的临时实现”放行。
  - **强制修复方向**：要求 Translator 提取独立 `TelegramProtocolAdapter`（或同等职责层），让 `Service` 只传递强类型领域对象与命令，不直接碰触二进制流、协议魔数、序列化器与原始发送接口。

- `ARCH_DOMAIN_PURITY`：
  - **触发条件**：生成的 `Service` / `Repository` / `UseCase` / `ViewModel` 代码的字段、方法签名（入参 / 返回值）、内部状态、cache、Signal 元素类型中，直接出现 `TLUser`、`TLMessage`、`TLChannel`、任意 `TL*` DTO、网络传输对象、协议 response entity，或直接返回 `ArrayBuffer`、`Uint8Array`、raw bytes。
  - **判定规则**：只要业务层直接暴露或持有上述 DTO / 协议对象，或在方法签名中保留 `TL*` / `ArrayBuffer` / `Uint8Array` 这类底层类型，Reviewer 必须返回 `pass = false`，并产生 `ARCH_DOMAIN_PURITY` 问题码，不允许以“后续再清洗”作为通过理由。
  - **强制修复方向**：要求 Translator 明确创建最小领域实体（如 `DomainUser`、`ChatMessage`、`DomainChannel`），并引入 `TelegramAclMapper` / `DomainMapper` 或同等 ACL 层，在 Adapter 边界将 DTO 转换为纯领域模型后再进入 Service；若存在 `createInputPeer` 等协议对象构造器，也必须同步下沉到 Adapter / RequestBuilder。

- `ARCH_CONCURRENCY_SAFETY`：
  - **触发条件**：共享 `Map` / `Cache` / `Store` / `Signal` 在 `spawn`、Promise `then/catch`、异步 callback、线程切换边界中被直接读写，或出现锁内 `Signal.set()`、无锁共享状态更新、缺少 `Mutex` / `Atomic` / 线程安全发布机制等迹象。
  - **判定规则**：只要 Reviewer 观察到 async 流中的共享状态写入没有明确同步策略，或观察到锁内 Signal 发布，就必须返回 `pass = false`，并产生 `ARCH_CONCURRENCY_SAFETY` 问题码。
  - **强制修复方向**：要求 Translator 使用明确的并发原语收口共享状态更新，并采用“锁内更新快照、锁外发布 Signal”的两阶段提交策略；必要时引入 Actor / dispatcher / thread-safe Signal 机制。

- `ARCH_SYNTAX_REGRESSION`：
  - **触发条件**：生成代码中出现已被明确禁止的目标语言倒退迹象，例如 `0L`、`0U`、`0UL` 等数字后缀，`import ... from` 这类 ArkTS / TypeScript 风格导入，`std.unsafe.*` 未转义导入，或 `!` / `!!` 非空断言与布尔强转等语法回退。
  - **判定规则**：只要出现任一语法倒退迹象，Reviewer 必须直接返回 `pass = false`，并产生 `ARCH_SYNTAX_REGRESSION` 问题码，不允许等待编译器再判定。
  - **强制修复方向**：要求 Translator 立即回到仓颉语法白名单，删除所有源语言语法残留与数字后缀幻觉，再继续处理架构整改。

- `THOUGHT_CODE_CONSISTENCY`：
  - **触发条件**：Translator 的 `repair_thought_process` 宣称将隔离 Adapter / ACL / Domain，但实际 `code` 仍出现 `ProtocolContext`、`TL*`、`InputPeer`、`createInputPeer`、`Buffer`、`ArrayBuffer` 等协议泄漏迹象。
  - **判定规则**：只要思维链与代码实现自相矛盾，Reviewer 必须返回 `pass = false`；若矛盾点涉及协议泄漏或领域纯洁性，问题码应优先使用 `ARCH_DOMAIN_PURITY_VIOLATION`，并在 message 中明确指出“思路与代码不一致”。
  - **强制修复方向**：要求 Translator 严格按 `repair_thought_process` 自己声明的边界整改执行，不允许只在思维链里说“会隔离”，却在代码里保留伪隔离壳层。

---

# Composition With Other Skills

## 字段作用

用于表达 Skill 之间的组合关系，避免同一任务中装载错顺序或重复装载互相冲突的 Skill。

## 填写规范

- `前置 Skill`：列出应优先加载的 Skill。
- `常见组合`：列出一起使用时能形成完整解决方案的 Skill。
- `覆盖关系`：说明当前 Skill 是否会覆盖低层 Skill 的默认做法。
- `禁止组合`：说明哪些 Skill 或模式不应一起启用。

这是未来自动化路由的重要依据。

---

# Retrieval Fallback

## 字段作用

用于在 Skill 不足时提供安全降级路径，保证 Agent 能从官方文档、仓库源码和 CLI 检索中继续推进。

## 填写规范

- `官方文档入口`：列出优先检索的官方资料和入口页面。
- `仓库检索入口`：列出优先检索的示例仓库或目标仓库路径。
- `CLI / Python 检索示例`：必须给出可直接运行的命令示例。
- `升级提问模板`：给出当信息不足时应如何向人类或上层系统提问。

注意：降级路径必须具体，不能只写“去查文档”。

---

# Security / Privacy Constraint

## 字段作用

用于显式标记是否涉及账号、密钥、聊天记录、设备标识、文件路径等敏感信息。

## 填写规范

- `敏感数据范围`：明确涉及哪些敏感对象。
- `脱敏规则`：说明日志和轨迹里必须如何处理。
- `本地存储要求`：说明是否要加密、是否要避免明文。
- `日志限制`：说明哪些字段绝不能写入日志。

任何会触碰用户数据、会话状态、网络包、密钥的 Skill，都必须认真填写此项。

---

# Migration Strategy

## 字段作用

用于描述小样本做法如何演化到真实工程做法，避免把实验方案误当成量产方案。

## 填写规范

- `小样本做法`：说明当前最小可验证实现是什么。
- `工程级替代方案`：说明未来正式工程要升级成什么形态。
- `何时升级`：说明哪些信号出现时必须升级实现。
- `升级检查点`：列出升级时必须重新验证的内容。

该字段特别适合当前项目，因为我们正在从小样本走向 Telegram 级巨型工程。

---

# Examples

## 字段作用

用于给出最小但完整的示意样例，帮助快速理解 Skill 的落地方式。

## 填写规范

- `示例一`：优先提供最小安全写法。
- `示例二`：优先提供典型错误与修正对照，或提供更接近真实工程的进阶写法。

示例可以是伪代码、类关系图、流程图文字版，但必须完整且可读。

---

# Test & Debug

## 字段作用

用于给出该 Skill 的快速验证路径和排错优先级，是日常使用时最直接的操作入口。

## 填写规范

- `快速验证步骤`：按最省成本的顺序给出验证步骤。
- `排错顺序`：按高概率、高影响问题优先排序。
- `常见误判`：列出看起来像问题、实际不是根因的假象。

该字段应尽量面向执行，而不是面向理论。

---

# Sources

## 字段作用

用于记录 Skill 的来源依据，保证后续复盘和升级时可追溯。

## 填写规范

- 列出官方文档、样例仓库、目标仓库、研究报告、本地检索文档等。
- 优先使用官方和一手资料。
- 如果是推断结论，应在来源附近注明“基于源码结构推断”。

---

# Known Gaps

## 字段作用

用于诚实记录当前 Skill 未覆盖的空白、环境限制和待验证项。

## 填写规范

- 写清当前没有验证的部分；
- 写清依赖 IDE、插件、真机、私有文档的部分；
- 写清哪些映射仍是推导，不是编译验证结论。

该字段不是缺点，而是风险透明化机制。

---

# Evolution Log

## 字段作用

用于记录版本演化与关键调整，支撑 Skill 长期维护。

## 填写规范

- 每次调整至少记录日期、调整点、原因。
- 如果是从 V1 升到 V2，应明确说明升级动因。
- 若某字段改动影响已有 Skill 兼容性，也应明确记录。

---

## 4. 正式模板

以下为新增 Skill 时应直接复制使用的正式结构。

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

# Architecture Review Gates
- 必查维度：
- 阻断条件：
- 修复指令模板：

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

## 5. 推荐填写顺序

为了减少遗漏，建议按以下顺序填写：

1. `Skill Metadata`
2. `Trigger Condition`
3. `Core Concept`
4. `Architecture Mapping`
5. `Dependency Constraint`
6. `Boundary Contract`
7. `Execution Topology`
8. `State Contract`
9. `Progressive Modules`
10. `Translation Mapping`
11. `Failure Model`
12. `Verification Matrix`
13. `Architecture Review Gates`
14. `Composition With Other Skills`
15. `Retrieval Fallback`
16. `Security / Privacy Constraint`
17. `Migration Strategy`
18. `Examples`
19. `Test & Debug`
20. `Sources`
21. `Known Gaps`
22. `Evolution Log`

先写系统级字段，再写示例和排错内容，可以避免 Skill 只剩“代码片段集合”。

---

## 6. 最终判断标准

一个 V2 Skill 要达到“可用”标准，至少应满足：

- Agent 能从 `Trigger Condition` 判断何时装载；
- Agent 能从 `Architecture Mapping` 知道是否应该重构而不是直译；
- Agent 能从 `Execution Topology` 和 `State Contract` 避免跨线程和跨生命周期误用；
- Agent 能从 `Verification Matrix` 知道如何验证；
- Reviewer 能从 `Architecture Review Gates` 对 `ARCH_PROTOCOL_ISOLATION`、`ARCH_DOMAIN_PURITY`、`ARCH_CONCURRENCY_SAFETY`、`ARCH_SYNTAX_REGRESSION` 等高风险架构泄漏与语法倒退执行一票否决；
- 人类维护者能从 `Known Gaps` 和 `Evolution Log` 理解风险和后续改造方向。

如果一个 Skill 只有代码示例而缺少上述字段，即使内容看起来丰富，也不能视为 V2 合格 Skill。
