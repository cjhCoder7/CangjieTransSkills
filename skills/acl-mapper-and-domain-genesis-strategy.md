# Skill Metadata
- Skill ID: `ARCH-ACL-DOMAIN-GENESIS-001`
- Skill Name: `acl-mapper-and-domain-genesis-strategy`
- Skill Class: `Architecture`
- Scope: 解决大模型在仓库级迁移中“因为害怕幻觉而不敢创造领域模型”的问题，明确授权 Translator 在仓颉侧定义最小可用的纯净领域实体，并强制通过 `TelegramAclMapper` / `DomainMapper` 将 `TL*` 协议 DTO 清洗为领域对象。该 Skill 重点覆盖 `TLUser`、`TLMessage`、`TLChannel` 等协议实体的去污染与 Service 层实体重建。
- Tags: `cangjie`, `telegram`, `acl`, `domain-genesis`, `domain-model`, `mapper`, `dto-to-domain`, `service-purity`
- Version: `V2.0-initial`

# Trigger Condition
- 任务触发条件：ArkTS 源代码中的 Service / Repository / ViewModel 直接使用 `TLUser`、`TLMessage`、`TLChannel`、`TLDialog`、`TL*` DTO 作为方法入参、返回值、字段、cache 元素或状态对象；或者候选仓颉代码因害怕“无中生有”而继续保留这些类型。
- 强制触发条件：
  - 生成代码中的 Service 层方法签名、返回值、字段、状态、cache、Signal 元素类型中出现任何 `TL*` 前缀类型时，必须触发本 Skill。
  - 生成代码中存在 `createInputPeer`、`buildRequestFromPeer`、`mapTlUserInService` 等把协议对象构造或 DTO 清洗逻辑留在 Service 内部的模式时，必须触发本 Skill。
- 不适用条件：纯 DTO Mapper、纯 Protocol Adapter、纯 Codec、纯 Transport 层；这些对象本身就是领域实体诞生之前的污染区，不要求它们只持有领域模型。

# Core Concept
- 最短知识结论：
  - 如果源 ArkTS 直接把 `TLUser` 当业务模型用，Translator **必须**在仓颉侧新建纯净领域模型，例如 `DomainUser`、`ChatMessage`、`ChannelSummary`。
  - 领域模型只保留业务所需字段，绝不复刻整个 TL 协议对象。
  - `TelegramAclMapper` 必须成为 Service 与 Protocol Adapter 之间的固定隔离层。
- 一句话风险提示：不敢创建领域模型，本质上就是默认让协议 DTO 永久污染业务层；这不是保守，而是放弃架构迁移。

# Architecture Mapping
- 源侧角色：ArkTS 中的 `TLUser`、`TLMessage`、`TLChannel` 常被直接当作“业务可消费对象”，因为项目历史上把协议对象和业务对象混用了。
- 目标侧角色：仓颉侧必须显式分为 `Protocol DTO`、`AclMapper`、`Domain Entity`、`Service State` 四层；其中 `Service` 只接触 `DomainUser`、`ChatMessage`、`HistoryBatch` 等领域模型。
- 保留策略：可保留源侧的业务含义，如用户 id、显示名、消息 id、文本、时间戳、发送状态、peerId 等。
- 重构策略：不得保留 TL 对象的协议专属字段、constructor id、flags、raw payload、access hash 细节到 Service 领域模型中；如业务确实需要某个字段，应以领域语义重命名后重新建模。

# Dependency Constraint
- 必需依赖：
  - `skills/SKILL_SCHEMA_V2.md`
  - `skills/protocol-adapter-extraction-strategy.md`
  - `skills/anti-corruption-and-concurrency-strategy.md`
- 可选依赖：
  - `skills/state-ownership-and-lifecycle.md`
  - `skills/message-delta-merge-and-batching.md`
- 冲突依赖：
  - 任何声称“先让 Service 继续使用 `TLUser`，以后再清洗”的过渡方案
  - 任何把 Mapper 逻辑拆碎到 Service 各方法中的分散式写法
- 环境前提：当前阶段可以先输出领域实体和 Mapper 骨架，不要求真实仓颉编译器立即验证所有字段类型；但实体与 Mapper 的层级关系必须在代码结构上明确存在。

# Boundary Contract
- 边界类型：Protocol DTO ↔ ACL Mapper ↔ Domain Entity ↔ Service API
- 输入：Adapter 返回 `TLUser`、`TLMessage`、`TLChannel`、`TLHistoryBatch` 等协议对象。
- 输出：Mapper 输出 `DomainUser`、`ChatMessage`、`DomainChannel`、`HistoryBatch` 等纯领域实体；Service 的方法签名只能使用这些领域实体或更高层命令对象。
- 生命周期归属：DTO 生命周期归 Adapter / Mapper；领域实体生命周期归 Service / StateStore；UI 投影不直接持有 DTO。
- 资源释放责任：DTO 及其原始 payload 在 Mapper 阶段即可被丢弃；Service 不缓存 TL 对象。
- 错误传递方式：Mapper 如发现 DTO 字段缺失，应转成领域错误或空安全字段，不允许把半解析 TL 对象抛回 Service。

# Execution Topology
- 线程模型：DTO→Domain 转换可在 Adapter 返回后立即执行，再将领域实体交给 Service；Service 不参与协议字段清洗。
- 主线程提交点：只有领域实体与快照发布进入 UI/Signal 阶段时才进入主线程或 UI 提交点。
- 后台处理点：DTO 解析、Mapper 清洗、字段裁剪、默认值补齐都应在 ACL 层完成。
- 串行要求：`Adapter fetch -> Mapper map -> Service merge -> Snapshot publish`，任何跳过 Mapper 的路径都视为违约。
- 批处理要求：批量 `TLUser[]`、`TLMessage[]` 必须先批量映射成 `DomainUser[]`、`ChatMessage[]`，再统一交给 Service。

# State Contract
- 状态所有者：Service / StateStore 只保存领域实体；绝不保存 `TLUser[]`、`TLMessage[]`、`TLChannel[]`。
- 真值来源：经过 Mapper 清洗后的领域实体是真值来源；DTO 只是一过性的传输载体。
- 可变字段：领域实体可根据业务需要保留最小可变字段；DTO 字段不应透传进 Service 状态。
- 衍生字段：显示名、消息摘要、发送状态标签、排序键等可以在领域层保留；protocol flags 等不应保留。
- 持久化策略：只持久化领域实体和领域快照，不持久化 `TL*` DTO。
- 一致性规则：Service 中任何 `Array<TL*>`、`Map<String, TL*>`、`Signal<TL*>` 都视为领域纯洁度失败。

# Progressive Modules
## Module 1：实体创造授权
- 如果找不到现成的领域模型，Translator **必须创建** 最小实体，而不是继续保留 `TL*` 类型。
- 允许以 `DomainUser`、`DomainChannel`、`ChatMessage`、`MessageSummary` 等语义化命名新建结构体 / 类。

## Module 2：最小字段原则
- 新建领域实体时只保留业务需要的字段，例如：
  - `DomainUser { id, displayName }`
  - `ChatMessage { id, peerId, text, sentAt, deliveryState }`
- 不得把 `flags`、`constructor`、`rawBytes`、`accessHash` 原样塞进领域模型，除非它们被重新论证为业务字段。

## Module 3：Mapper 强制范式
- 必须有集中式 `TelegramAclMapper` / `DomainMapper`：
  - `mapUser(tlUser: TLUser): DomainUser`
  - `mapMessage(tlMessage: TLMessage): ChatMessage`
  - `mapHistory(batch: TLHistoryBatch): HistoryBatch`
- 不允许把字段搬运逻辑散落在 `cacheUsers`、`fetchMessages`、`sendMessage` 中。

## Module 4：彻底切断协议构造
- 类似 `createInputPeer` 这类协议对象构造器绝对不允许留在 Service 中。
- `PeerId -> InputPeer` 的映射必须下沉到 Adapter / Mapper / RequestBuilder 层。

# Translation Mapping
- ArkTS 对应写法：`cacheUsers(users: TLUser[])`、`parseMessage(tlMessage)`、`createInputPeer(peerId)`。
- 仓颉对应写法：
  - `cacheUsers(users: Array<DomainUser>)`
  - `aclMapper.mapUsers(tlUsers)`
  - `protocolAdapter.fetchHistory(query) -> tlBatch -> aclMapper.mapHistory(tlBatch)`
  - `protocolAdapter.sendMessage(command)` 由 Adapter 内部决定如何构建 `InputPeer`
- 允许差异：领域模型命名可根据目标工程实际命名为 `DomainUser`、`AppUser`、`UserProfile`；关键是不能再用 `TL*`。
- 禁止直译点：禁止 `TLUser`、`TLMessage`、`TLChannel` 出现在 Service 签名、字段、返回值；禁止 `createInputPeer` 留在 Service。

# Performance Envelope
- 主线程预算：领域实体应尽量轻量，只保留业务必需字段，避免 DTO 整包上浮造成 UI 投影负担。
- 吞吐量关注点：批量 DTO→Domain 映射应集中进行，避免在 Service 多处重复搬运字段。
- 内存关注点：防止同时缓存 DTO 和领域实体双份对象图；Mapper 后应尽快丢弃 DTO。
- 建议优化手段：批量 Mapper、只读领域快照、统一字段裁剪、集中式实体构造工厂。

# Failure Model
- 常见编译失败：Service 同时依赖 `TL*` 和领域类型，导致接口混乱；Mapper 缺位导致类型边界无法收敛。
- 常见运行失败：Service 订阅者误消费 protocol flags / access hash；DTO 与领域实体混用导致状态不可预期。
- 高风险误用：
  - `cacheUsers(users: Array<TLUser>)`
  - `return Promise<ArrayBuffer>` from Service
  - `signal: Signal<Array<TLMessage>>`
  - `private func createInputPeer(peerId): InputPeer` inside Service
- 恢复策略：先在 Service 边界剔除所有 `TL*` 类型，再补 `DomainEntity + Mapper`，最后把协议构造器和请求对象映射下沉到 Adapter。

# Verification Matrix
- 单元测试：
  - 验证 `TelegramAclMapper.mapUser(TLUser) -> DomainUser`
  - 验证 `TelegramAclMapper.mapMessage(TLMessage) -> ChatMessage`
  - 验证领域实体不包含 protocol-only 字段
- Fake / Mock：
  - Mock Adapter 返回 `TL*` DTO
  - Mock Mapper 输出最小领域实体
- 集成测试：
  - `Adapter -> Mapper -> Service -> StateStore`
  - 验证 Service API 不暴露任何 `TL*` 类型
- 手动验证：
  - 搜索 Service 文件中是否还存在 `TL[A-Z]`
  - 搜索是否存在 `ArrayBuffer` / `Uint8Array` 作为 Service 方法入参或返回值
- 观测指标：
  - Service 签名中的 `TL*` 类型数量必须为 `0`
  - Service 返回值中的 `ArrayBuffer` / `Uint8Array` 数量必须为 `0`
  - Mapper 方法数量应覆盖关键 DTO→Domain 路径

# Architecture Review Gates
- 必查维度：
  - `ARCH_DOMAIN_PURITY`
  - `ARCH_PROTOCOL_ISOLATION`
- 阻断条件：
  - 只要 Service 的方法签名（入参 / 返回值）、字段、内部状态、cache、Signal 元素类型中出现 `TL*` 类型，必须阻断。
  - 只要 Service 的方法签名直接返回 `ArrayBuffer`、`Uint8Array`、raw bytes、protocol response entity，也必须阻断。
  - 只要 Service 内还存在 `createInputPeer` 或其他协议对象构造器，也必须阻断。
- 修复指令模板：
  - 授权并要求 Translator 明确创建最小领域实体，如 `DomainUser`、`ChatMessage`、`DomainChannel`。
  - 要求引入 `TelegramAclMapper` / `DomainMapper`，集中处理 DTO→Domain 转换。
  - 要求把 `PeerId -> InputPeer`、request builder、protocol object construction 全部下沉到 Adapter / RequestBuilder。

# Composition With Other Skills
- 前置 Skill：
  - `protocol-adapter-extraction-strategy`
  - `anti-corruption-and-concurrency-strategy`
- 常见组合：
  - 与 `async-stream-and-binary-protocol-mapping` 组合，形成“协议下沉 + 实体清洗 + 状态发布”完整链路。
- 覆盖关系：当本 Skill 触发时，它会覆盖“先保留 TL 类型避免幻觉”的任何保守策略，并授权模型主动创造领域实体。
- 禁止组合：禁止与“Service 暂时继续暴露 `TL*`，等后面再补 Mapper”的做法一起视为通过标准。

# Retrieval Fallback
- 官方文档入口：
  - DDD / Anti-Corruption Layer 设计模式资料
  - HarmonyOS / ArkTS 领域层建模实践
- 仓库检索入口：
  - `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`
  - `raw_docs/telegramharmony-phase02/src/core/mtproto/TLDialogs.ets`
  - `raw_docs/telegramharmony-phase02/src/core/mtproto/TLMethods.ets`
- CLI / Python 检索示例：
  - `rg -n "TLUser|TLMessage|TLChannel|ArrayBuffer|Uint8Array|createInputPeer|InputPeer" raw_docs/telegramharmony-phase02 artifacts/pipeline_runs`
  - `rg -n "DomainUser|ChatMessage|AclMapper|DomainMapper|mapUser|mapMessage" artifacts/pipeline_runs`
- 升级提问模板：若领域实体最小字段仍不明确，应先让人类确认“用户、频道、消息在业务层真正需要哪些字段”，再继续实现。

# Security / Privacy Constraint
- 敏感数据范围：用户 id、频道 id、消息文本、access hash、协议 payload。
- 脱敏规则：领域实体示例可展示字段名，不应在 trace 中回显完整真实消息文本或完整 hash。
- 本地存储要求：不将协议 DTO 作为长期调试快照保留；仅记录映射规则和领域实体摘要。
- 日志限制：不要在 Mapper 调试日志中输出完整原始 `TLMessage` 载荷。

# Migration Strategy
- 小样本做法：先让 Translator 显式生成 `DomainUser` / `ChatMessage` / `TelegramAclMapper` 骨架，即使字段是最小子集，也必须存在。
- 工程级替代方案：后续结合真实仓颉编译器与业务需求，细化领域实体字段、Mapper 位置和模块命名。
- 何时升级：只要发现 Service 还暴露 `TL*` 类型或不敢创建领域实体，就必须启用本 Skill。
- 升级检查点：
  - Service 是否彻底不含 `TL*` 类型
  - 是否已有 `DomainUser` / `ChatMessage` / 等价领域实体
  - 是否已有集中式 Mapper
  - 协议对象构造是否已离开 Service

# Examples
- 示例一：反例
  ```ts
  class RealMessageService {
      cacheUsers(users: TLUser[]): void { ... }
      private createInputPeer(peerId: PeerId): InputPeer { ... }
  }
  ```
- 示例二：目标伪代码
  ```text
  struct DomainUser {
      let id: String
      let displayName: String
  }

  struct ChatMessage {
      let id: String
      let peerId: PeerId
      let text: String
  }

  class TelegramAclMapper {
      func mapUser(tlUser: TLUser): DomainUser {
          return DomainUser(id: tlUser.id.toString(), displayName: tlUser.name)
      }

      func mapMessage(tlMessage: TLMessage): ChatMessage {
          return ChatMessage(id: tlMessage.id.toString(), peerId: tlMessage.peerId, text: tlMessage.message)
      }
  }

  class RealMessageService {
      let aclMapper: TelegramAclMapper
      let protocolAdapter: ITelegramProtocolAdapter

      func refreshHistory(query: HistoryQuery): Promise<Array<ChatMessage>> {
          return protocolAdapter.fetchHistory(query).then { tlBatch =>
              let batch = aclMapper.mapHistory(tlBatch)
              stateStore.merge(batch.messages)
              return batch.messages
          }
      }
  }
  ```

# Test & Debug
- 快速验证步骤：
  1. 搜候选 Service 代码里是否还出现 `TL[A-Z]`
  2. 搜是否存在 `DomainUser`、`ChatMessage`、`TelegramAclMapper` 或等价实体 / Mapper
  3. 搜 Service 中是否还存在 `createInputPeer` / `InputPeer`
  4. 确认 Service API 入参和返回值是否只剩领域模型
- 排错顺序：
  1. 先砍掉签名中的 `TL*`
  2. 再创造最小领域实体
  3. 再补集中式 Mapper
  4. 最后清掉 Service 内协议对象构造器
- 常见误判：
  - “不敢新建 `DomainUser`，怕是幻觉”——错误，本 Skill 已经明确授权领域实体创造。
  - “我已经有 Adapter，所以 `TLUser[]` 出现在 Service 也没关系”——错误，DTO 污染仍然存在。

# Sources
- 来源列表：
  - `skills/SKILL_SCHEMA_V2.md`
  - `skills/protocol-adapter-extraction-strategy.md`
  - `skills/anti-corruption-and-concurrency-strategy.md`
  - `docs/traces/trace-phase-02-iron-test-real-llm-run-004-acl-concurrency.md`
  - `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`

# Known Gaps
- 当前空白：
  - 真实业务层最终采用 `DomainUser` 还是 `AppUser` 仍可按工程命名规范调整；
  - 某些协议字段是否应提升为业务字段，需要后续结合真实功能需求再裁剪；
  - 当前规则强调“敢于创造最小领域实体”，但尚未把每个实体的字段白名单完全固定死。

# Evolution Log
- 版本演进记录：
  - `[2026-03-26] [V2.0-initial] 新增 ACL Mapper 与 Domain Genesis 专项 Skill，显式授权大模型在仓颉侧创建最小领域实体，并强制要求集中式 DTO→Domain 映射与 Service 签名去 TL 化。`
