# Skill Metadata
- Skill ID: `ARCH-ACL-CONCURRENCY-001`
- Skill Name: `anti-corruption-and-concurrency-strategy`
- Skill Class: `Architecture`
- Scope: 约束 Telegram / MTProto 场景中 Service 层的领域纯洁度与异步并发安全，防止 `TL*` 协议对象、DTO、网络实体或跨线程裸写共享状态污染仓颉侧的业务层。该 Skill 重点解决“协议对象残留”和“锁内发射 Signal / 锁外裸写共享状态”的最后漏洞。
- Tags: `cangjie`, `telegram`, `anti-corruption-layer`, `acl`, `domain-purity`, `dto-mapping`, `concurrency`, `signal`, `thread-safety`
- Version: `V2.0-initial`

# Trigger Condition
- 任务触发条件：待翻译对象属于 `service`、`repository`、`view-model-like service`、`message facade`、`state orchestrator`，且源码或候选代码中出现 `TLUser`、`TLMessage`、`TLChannel`、`TL*` DTO、raw response object、共享 `Map` / `Cache` / `Signal`、`spawn` / callback / Promise / async 回调 / 多线程同步原语等迹象。
- 强制触发条件：
  - Service 层方法签名、字段、返回值或内部状态中直接出现 `TL*` 协议对象、DTO 或网络传输实体时，必须触发 `ARCH_DOMAIN_PURITY`。
  - 共享状态（如 `cache`、`Map`、`store`、`Signal`）在异步回调、`spawn`、Promise `then/catch`、线程切换边界中被直接读写，而没有明确并发原语、快照边界或线程安全发布机制时，必须触发 `ARCH_CONCURRENCY_SAFETY`。
- 不适用条件：纯协议 Adapter、纯 Codec、纯 DTO Mapper、纯 transport 层；这些对象本身就是协议污染的隔离区，不应要求其只持有领域模型。

# Core Concept
- 最短知识结论：
  - Service 层只能看见领域模型，不能看见 `TLUser`、`TLMessage`、`TLChannel` 这类网络协议对象。
  - Adapter 必须承担 Anti-Corruption Layer 责任，把 `TL*` DTO 转换成 `AppUser`、`ChatMessage`、`HistoryBatch` 等领域对象后再返回给 Service。
  - 共享状态更新与 Signal 投递必须分阶段执行：先在并发原语保护下写入状态快照，再在锁外发布不可变投影。
- 一句话风险提示：如果 Service 同时握着 `TL*` DTO 和锁内 `Signal.set()`，就等于把协议污染与并发风险一起带进业务层，后续再聪明的 LLM 也只会越修越乱。

# Architecture Mapping
- 源侧角色：ArkTS 中 `RealMessageService` 等对象常常同时接触 `TL*` 协议对象、UI 订阅状态与异步回调；由于 ArkTS 偏单线程事件模型，这种写法在仓颉真多线程语境下风险会急剧放大。
- 目标侧角色：仓颉侧应拆为 `Service`（只处理领域命令、领域状态、投影发布） + `TelegramProtocolAdapter`（协议调用） + `TelegramAclMapper` / `DomainMapper`（DTO→Domain 清洗层） + `ConcurrentStateStore` / 线程安全状态仓（可并入 Service，但边界必须明确）。
- 保留策略：可保留 `fetchMessages`、`sendMessage`、`cacheUsers` 等业务意图和领域操作顺序；可保留状态快照、分页、发送中状态等业务语义。
- 重构策略：必须将 `TL*` DTO、网络响应对象、协议字节流与 Service 断开；必须把共享状态的跨线程写入收口到明确的锁、原子变量、Actor 或线程安全发布机制，不允许 async 回调里裸写共享 `Map` / `Signal`。

# Dependency Constraint
- 必需依赖：
  - `skills/SKILL_SCHEMA_V2.md`
  - `skills/protocol-adapter-extraction-strategy.md`
  - `skills/async-stream-and-binary-protocol-mapping.md`
  - `skills/state-ownership-and-lifecycle.md`
  - `skills/signal-based-reactive-pipeline.md`
- 可选依赖：
  - `skills/message-delta-merge-and-batching.md`
  - `skills/main-thread-ui-boundary.md`
- 冲突依赖：
  - 允许在 Service 层直接暴露 DTO / TL type 的快捷翻译模式
  - 允许在 `spawn` / Promise callback 中直接 `cache[key] = ...`、`signal.set(...)` 而无同步策略的简化实现
- 环境前提：当前阶段可仅通过 Prompt + Reviewer + dry-run 验证此 Skill 的逻辑效果；待真实仓颉编译器、DevEco Studio 与仓颉插件接入后，再对 `Mutex` / `Atomic` / `Signal` 的具体 API 形式做物理校验。

# Boundary Contract
- 边界类型：Protocol DTO / Transport Entity ↔ ACL Mapper ↔ Domain Model ↔ Service State ↔ UI Projection
- 输入：Adapter 输出 `TL*` DTO 或协议响应对象；ACL Mapper 负责吃掉这些 DTO，吐出纯领域对象，如 `AppUser`、`ChatMessage`、`HistoryBatch`、`SendReceipt`。
- 输出：Service 仅接收领域模型、领域错误、不可变快照，不直接接收 `TL*` DTO、transport response、原始 callback payload。
- 生命周期归属：DTO / 协议对象生命周期归 Adapter / Mapper；领域对象生命周期归 Service / StateStore；UI 投影生命周期归 Signal / projection 层。
- 资源释放责任：Mapper 和 Adapter 负责 DTO 临时对象与原始 payload 的生命周期；Service 不缓存 `TL*` 对象，不持有协议 response。
- 错误传递方式：协议错误和 DTO 不完整错误先在 Adapter / Mapper 中转译为领域错误；Service 只能处理领域可理解错误，不直接判断 TL constructor 或字段缺失。

# Execution Topology
- 线程模型：仓颉侧默认按真多线程风险建模。任何 async 回调、Promise `then/catch`、`spawn`、后台任务都视为潜在跨线程执行点。
- 主线程提交点：UI 相关 `Signal` / 投影发布必须在明确的发布阶段进行，禁止在持锁代码块或底层 callback 内直接同步发射。
- 后台处理点：DTO→Domain 映射、delta merge、cache snapshot 构建、错误分类可以在后台完成，但共享状态写入必须通过同步原语收口。
- 串行要求：建议采用两阶段提交：`lock/update state snapshot -> unlock -> publish signal(snapshot)`；严禁 `lock -> state update -> signal.set(...)` 的锁内发射。
- 批处理要求：批量消息 / 用户更新必须先在局部不可变集合中完成 merge，再一次性提交到共享状态仓，避免多次细粒度锁竞争与半成品状态暴露。

# State Contract
- 状态所有者：Service / StateStore 只持有领域模型集合、不可变快照、UI 投影状态；不持有 `TL*` DTO。
- 真值来源：经过 ACL Mapper 清洗后的领域对象是真值来源；DTO 只是传输壳，不得成为 Service 中的长期真值。
- 可变字段：共享 `cache`、`messageSignals`、用户索引、分页状态等必须在并发原语保护下更新。
- 衍生字段：Signal 中发布的应是不可变或只读快照，不应直接把可变 `Map` / `List` 引用暴露给订阅者。
- 持久化策略：持久化领域对象与领域快照，不持久化 `TL*` DTO、transport entity、裸 Promise 结果。
- 一致性规则：
  - 先完成 DTO→Domain 映射，再写入 Service 状态；
  - 先在锁 / 线程安全状态仓中更新共享状态，再在锁外发布 Signal；
  - 不允许锁内 `Signal.set()`；
  - 不允许 async 回调中裸写共享 `Map` / `Cache` / `Signal`。

# Progressive Modules
## Module 1：领域纯洁度最低线
- 检查 Service 方法签名、字段、返回值、状态字段是否出现 `TLUser`、`TLMessage`、`TLChannel`、`TL*` DTO。
- 一旦出现，默认视为 ACL 失效，必须补 Mapper。

## Module 2：ACL Mapper 迁移模式
- Adapter 返回 `TLMessagesHistory` / `TLUser[]` 等协议对象后，不直接交给 Service。
- 必须引入 `TelegramAclMapper`、`DomainMapper` 或同等职责层，将其转换为 `HistoryBatch`、`AppUser[]`、`ChatMessage[]`。

## Module 3：并发安全写入模式
- 推荐模式：
  1. async 回调获得领域结果
  2. 在 `Mutex` / `ReentrantLock` / Actor 中更新共享状态
  3. 复制出不可变快照
  4. 解锁
  5. 通过线程安全 Signal / dispatcher 发布快照
- 反模式：在 `spawn` / `then` / callback 中直接同时写 cache 与发 Signal。

## Module 4：工程级约束
- Reviewer 若看到 Service 持有 `TL*` 类型，必须打 `ARCH_DOMAIN_PURITY`。
- Reviewer 若看到锁内 `Signal.set()`、无锁共享状态写入、callback 内裸写 `Map`、Promise 完成后直接改共享状态而无同步，必须打 `ARCH_CONCURRENCY_SAFETY`。

# Translation Mapping
- ArkTS 对应写法：`cacheUsers(users: TLUser[])`、`parseMessage(dto: TLMessage): Message`、`this.messageCache.set(...); this.messageSignals.get(key)?.set(...)`。
- 仓颉对应写法：`cacheUsers(users: AppUser[])`、`aclMapper.mapUsers(tlUsers)`、`stateStore.updateHistory(...) -> snapshot -> signal.publish(snapshot)`。
- 允许差异：ACL Mapper 的命名可为 `TelegramAclMapper`、`ProtocolEntityMapper`、`DomainTranslator`；并发原语可根据仓颉标准库选 `Mutex`、`Atomic`、Actor 或线程安全 Signal。
- 禁止直译点：禁止将 `TL*` DTO 直接放进 Service 方法签名、字段、返回值、cache；禁止锁内 `Signal.set()`；禁止 async 回调中裸写共享状态。

# Performance Envelope
- 主线程预算：DTO→Domain 映射与共享状态 merge 尽量脱离 UI 提交路径，避免订阅者在主线程消费半成品状态。
- 吞吐量关注点：批量消息拉取与用户列表同步时，Mapper 应批量转换后再统一提交状态，减少锁竞争。
- 内存关注点：不要在 Service 中长期保留 DTO 副本；发布给 Signal 的应是最小必要快照，而不是携带协议字段的大对象图。
- 建议优化手段：采用 snapshot publish、批量 merge、局部不可变副本、Actor 化更新队列或统一状态仓。

# Failure Model
- 常见编译失败：Service 同时引用领域类型和 `TL*` 协议类型，导致接口污染、依赖错位、测试替身困难。
- 常见运行失败：锁内发射 Signal 导致死锁/阻塞；无锁共享状态更新导致数据竞争；DTO 与领域对象混存导致错误字段被 UI 订阅者误消费。
- 高风险误用：
  - `cacheUsers(users: TLUser[])`
  - `messageCache[key] = messages` 直接发生在 async callback 中且无锁
  - `lock { ... signal.set(snapshot) }`
  - 将 `TLMessage` 直接塞进 `Signal<Array<Message>>`
- 恢复策略：先清除 Service 对 `TL*` 的所有类型依赖，再引入 Mapper；然后将共享状态更新收口到单一并发边界，并把 Signal 发布移动到锁外快照阶段。

# Verification Matrix
- 单元测试：
  - 验证 `TelegramAclMapper` 能把 `TLUser` → `AppUser`、`TLMessage` → `ChatMessage`
  - 验证共享状态更新函数返回不可变快照，而不是直接暴露内部可变集合
- Fake / Mock：
  - Mock Adapter 返回 `TL*` DTO，由 Mapper 单测负责清洗
  - Mock Signal 发布器，验证锁外发布顺序
- 集成测试：
  - `Adapter -> Mapper -> Service State -> Signal Projection` 全链路
  - 并发初始化同一 peer 时不得创建多个冲突状态版本
- 手动验证：
  - 检查 Service 文件中是否还出现 `TLUser`、`TLMessage`、`TLChannel`
  - 检查是否仍有锁内 `Signal.set()` 或 async callback 内裸写共享状态
- 观测指标：
  - Service 层 `TL*` 类型命中数必须为 `0`
  - 锁内 Signal 发射次数必须为 `0`
  - 无保护共享状态写入次数必须为 `0`
  - Mapper 命中次数与领域对象产出量应可追踪

# Architecture Review Gates
- 必查维度：
  - `ARCH_DOMAIN_PURITY`
  - `ARCH_CONCURRENCY_SAFETY`
- 阻断条件：
  - 只要 Service 方法签名、字段、返回值、内部 cache / state 中出现 `TL*` DTO、网络传输对象、协议 response entity，必须判定 `ARCH_DOMAIN_PURITY` 失败。
  - 只要 Reviewer 发现锁内 `Signal.set()`、async callback / `spawn` / Promise `then` 中裸写共享 `Map` / `Cache` / `Signal`、缺少 `Mutex` / `Atomic` / 线程安全发布机制，就必须判定 `ARCH_CONCURRENCY_SAFETY` 失败。
- 修复指令模板：
  - 对 `ARCH_DOMAIN_PURITY`：要求引入 `TelegramAclMapper` 或同等 Mapper，将 `TL*` DTO 在 Adapter 边界转换为 `AppUser`、`ChatMessage`、`HistoryBatch` 等领域模型后再进入 Service。
  - 对 `ARCH_CONCURRENCY_SAFETY`：要求将共享状态更新收口到并发原语中，并采用“锁内生成新快照、锁外发布 Signal”的两阶段提交策略。

# Composition With Other Skills
- 前置 Skill：
  - `protocol-adapter-extraction-strategy`
  - `async-stream-and-binary-protocol-mapping`
- 常见组合：
  - 与 `state-ownership-and-lifecycle` 组合，明确快照所有权
  - 与 `signal-based-reactive-pipeline` 组合，约束投影发布顺序
- 覆盖关系：当本 Skill 触发时，它会覆盖任何默认允许 DTO 直接上浮到 Service 的宽松做法，并覆盖“锁内可直接发 Signal”的临时策略。
- 禁止组合：禁止与“Service 暂时继续持有 TL* 类型，后续再清洗”的过渡做法同时作为通过标准。

# Retrieval Fallback
- 官方文档入口：
  - 仓颉并发与同步原语文档
  - HarmonyOS / ArkTS 异步与状态管理文档
  - Anti-Corruption Layer / Domain Model 设计模式资料
- 仓库检索入口：
  - `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`
  - `raw_docs/telegramharmony-phase02/src/core/mtproto/TLDialogs.ets`
  - `raw_docs/telegramharmony-phase02/src/core/mtproto/TLMethods.ets`
- CLI / Python 检索示例：
  - `rg -n "TLUser|TLMessage|TLChannel|TL[A-Z][A-Za-z0-9_]*|spawn\s*\{|then\s*\{|catch\s*\{|Signal\.set|\.set\(" raw_docs/telegramharmony-phase02`
  - `rg -n "cacheUsers\(|cacheChannels\(|messageCache|messageSignals|ReentrantLock|Mutex|Atomic" artifacts/pipeline_runs`
- 升级提问模板：若目标仓颉工程中领域模型命名尚未确定，应先确认“用户模型、消息模型、历史批次模型的领域命名是什么”，再继续输出最终实现。

# Security / Privacy Constraint
- 敏感数据范围：消息内容、用户标识、频道标识、访问 hash、会话状态、网络回包、线程调度日志。
- 脱敏规则：Mapper 调试与并发日志只记录类型名、计数、key 和状态版本号，不打印完整消息 payload 或完整用户隐私数据。
- 本地存储要求：不将 `TL*` DTO 直接持久化到 Service 调试日志；必要时仅记录 DTO 类型摘要与映射结果计数。
- 日志限制：不要在并发错误日志中输出完整消息文本、完整 access hash、完整 transport payload。

# Migration Strategy
- 小样本做法：先用 Prompt + Reviewer 强制 `TL*` 不得上浮到 Service，并要求锁外 Signal 发布。
- 工程级替代方案：在真实仓颉工程中落地独立 `TelegramAclMapper` 与线程安全状态仓，必要时采用 Actor/dispatcher 模式取代手写锁。
- 何时升级：一旦出现 `TL*` 类型残留、锁内 `Signal.set()`、async callback 裸写共享状态，就必须升级到 ACL + 并发安全模式。
- 升级检查点：
  - Service 签名是否只剩领域模型
  - DTO→Domain 映射是否全部在 Adapter / Mapper 完成
  - Signal 发布是否锁外完成
  - 并发初始化与重复请求是否有明确收口机制

# Examples
- 示例一：协议对象污染反例
  ```ts
  class MessageService {
      cacheUsers(users: TLUser[]): void {
          this.userCache = users
      }
  }
  ```
- 示例二：ACL + 并发安全目标伪代码
  ```text
  class TelegramAclMapper {
      func mapUsers(tlUsers: Array<TLUser>): Array<AppUser> { ... }
      func mapMessages(tlMessages: Array<TLMessage>): Array<ChatMessage> { ... }
  }

  class MessageService {
      func refreshHistory(query: HistoryQuery) {
          let tlBatch = protocolAdapter.fetchHistory(query)
          let domainBatch = aclMapper.mapHistory(tlBatch)
          let snapshot = stateMutex.lockAndGet {
              stateStore.merge(domainBatch)
              return stateStore.snapshot()
          }
          historySignal.publish(snapshot)
      }
  }
  ```

# Test & Debug
- 快速验证步骤：
  1. 搜候选 Service 代码里是否还出现 `TLUser`、`TLMessage`、`TLChannel`、`TL*`
  2. 搜是否存在 `lock { ... signal.set(...) }` 或同义锁内发布模式
  3. 搜 `spawn` / Promise callback 中是否直接改 `cache` / `Map` / `Signal`
  4. 确认是否已出现 `AclMapper` / `DomainMapper` / 纯领域模型输入输出
- 排错顺序：
  1. 先拔掉 `TL*` 类型残留
  2. 再补 DTO→Domain Mapper
  3. 再把锁内 Signal 发布改为锁外快照发布
  4. 最后处理并发去重、pending request 与初始化竞态
- 常见误判：
  - “我已经有 Adapter，所以 Service 里保留 `TLUser[]` 没关系”——错误，协议对象类型污染仍然存在。
  - “我用了锁，所以锁内 `Signal.set()` 就安全”——错误，锁内发布会把订阅侧副作用带回同步临界区。

# Sources
- 来源列表：
  - `skills/SKILL_SCHEMA_V2.md`
  - `skills/protocol-adapter-extraction-strategy.md`
  - `skills/async-stream-and-binary-protocol-mapping.md`
  - `artifacts/pipeline_runs/phase02-iron-test-glm47-round2-protocol-isolation/RealMessageService.orchestration.json`
  - `docs/traces/trace-phase-02-iron-test-real-llm-run-003-protocol-isolation.md`
  - `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`

# Known Gaps
- 当前空白：
  - 真实仓颉标准库中的 `Mutex` / `Atomic` / Signal API 形式尚未通过编译器验证，本 Skill 当前描述的是架构约束，不是最终 API 签名。
  - TelegramHarmony 的某些 `TL*` 类型可能兼具协议与业务语义，后续需在人类确认下区分“领域模型”与“协议 DTO”的最终命名。
  - 如果未来引入 actor 风格状态仓，本 Skill 可进一步从“锁 + 快照”升级为“单线程状态执行器”。

# Evolution Log
- 版本演进记录：
  - `[2026-03-26] [V2.0-initial] 新增 ACL 与并发安全专项 Skill，针对第二轮真实 Iron Test 中暴露出的 TL 类型残留、锁内 Signal 发射和 async 共享状态写入问题，提供 DTO 清洗与两阶段状态发布约束。`
