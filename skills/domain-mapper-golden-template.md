# Skill Metadata
- Skill ID: `ARCH-DOMAIN-MAPPER-GOLDEN-TEMPLATE-001`
- Skill Name: `domain-mapper-golden-template`
- Skill Class: `Architecture`
- Scope: 为 Telegram / MTProto 场景提供最终的领域实体与 ACL Mapper 黄金模板，直接给 Translator 一份可照抄的“填空题”，消除其因害怕幻觉而不敢创造领域实体的犹豫。该 Skill 重点解决 `TLUser` / `TLMessage` 在 Service 层残留、`TelegramAclMapper` 缺席、以及 `createInputPeer` 未下沉的问题。
- Tags: `cangjie`, `telegram`, `golden-template`, `domain-model`, `acl-mapper`, `few-shot`, `service-purity`
- Version: `V2.0-initial`

# Trigger Condition
- 任务触发条件：待翻译的 Service / Repository / ViewModel 仍直接使用 `TLUser`、`TLMessage`、`TLChannel`、`InputPeer` 等协议实体，或前几轮候选稿只能生成 `PeerDTO` / `MessageDTO` 这类中间层对象，却始终不敢生成真正的领域实体。
- 强制触发条件：
  - 生成代码中的 Service 方法签名、字段、状态、cache、Signal 元素类型中仍出现任何 `TL*` 类型。
  - 生成代码中缺失 `TelegramAclMapper` / `DomainMapper` 一类的集中式映射器。
  - 生成代码中缺失 `DomainUser` / `ChatMessage` / `DomainChannel` 等明确领域实体。
  - 生成代码中仍存在 `createInputPeer`、`InputPeer*` 构造、request builder 留在 Service 的情况。
- 不适用条件：纯 Adapter / Codec / Mapper 文件本身；这些文件可以接触协议对象，但不能把协议对象继续泄漏给 Service。

# Core Concept
- 最短知识结论：
  - 领域实体不是“可选优化”，而是 Translator 在 Service 迁移中**必须主动创建**的目标对象。
  - `TelegramAclMapper` 不是建议项，而是 ACL 的标准载体。
  - `createInputPeer` 等协议对象构造器必须连根拔起，下沉到 Adapter / RequestBuilder。
- 一句话风险提示：如果 Translator 还在 Service 里保留 `TLUser` 或 `InputPeer`，说明它还没有真正完成架构迁移，只是在换一种语言继续污染业务层。

# Architecture Mapping
- 源侧角色：`TLUser`、`TLMessage`、`TLChannel`、`InputPeer` 属于协议实体 / 传输对象 / 请求构造细节。
- 目标侧角色：
  - `DomainUser`、`ChatMessage`、`DomainChannel`：纯业务层领域实体
  - `TelegramAclMapper`：集中式 DTO → Domain 映射器
  - `ITelegramProtocolAdapter` / `TelegramProtocolAdapter`：协议调用与 request builder 持有者
- 保留策略：只保留业务必需字段，如 id、name、text、timestamp、isBot。
- 重构策略：所有 `TL*`、`InputPeer*`、`ArrayBuffer`、`Uint8Array`、`TLDeserializer`、request builder、protocol flags 均不得留在 Service。

# Dependency Constraint
- 必需依赖：
  - `skills/SKILL_SCHEMA_V2.md`
  - `skills/protocol-adapter-extraction-strategy.md`
  - `skills/anti-corruption-and-concurrency-strategy.md`
  - `skills/acl-mapper-and-domain-genesis-strategy.md`
- 可选依赖：
  - `skills/async-stream-and-binary-protocol-mapping.md`
- 冲突依赖：
  - “为了避免幻觉，先保留 `TLUser` / `TLMessage`” 这类保守策略
  - 在 Service 里直接写字段搬运逻辑而不创建 Mapper
- 环境前提：当前模板是逻辑层高优先 Few-shot，优先级高于一般性解释说明；即使真实仓颉 API 细节待调整，实体 / Mapper / Adapter 的职责拆分也必须先被生成出来。

# Boundary Contract
- 边界类型：Protocol DTO ↔ TelegramAclMapper ↔ Domain Entity ↔ Service ↔ Signal/StateStore
- 输入：Adapter 产出的 `TLUser`、`TLMessage`、`TLChannel` 或等价协议对象。
- 输出：Mapper 产出的 `DomainUser`、`ChatMessage`、`DomainChannel`。
- 生命周期归属：DTO 在 Mapper 后即应被丢弃；Service 只持有领域实体。
- 资源释放责任：Adapter / Mapper 负责协议对象与请求构造细节；Service 不负责。
- 错误传递方式：字段缺失时 Mapper 负责给默认值或生成领域错误，不允许半清洗 DTO 流入 Service。

# Translation Mapping
- ArkTS `cacheUsers(users: TLUser[])` -> 仓颉 `cacheUsers(users: Array<DomainUser>)`
- ArkTS `parse TLMessage -> Message` -> 仓颉 `TelegramAclMapper.mapToChatMessage(tlMessage)`
- ArkTS `createInputPeer(peerId)` -> 仓颉 Adapter / RequestBuilder 内部实现，Service 不再持有
- 禁止直译点：
  - `TLUser` 出现在 Service 签名
  - `TLMessage` 出现在 Service 返回值或状态中
  - `createInputPeer` 留在 Service
  - `InputPeer*`、`ArrayBuffer`、`Uint8Array` 留在 Service

# White List
- `DomainUser` 允许字段：
  - `id: Int64`
  - `name: String`
  - `isBot: Bool`
- `ChatMessage` 允许字段：
  - `messageId: Int64`
  - `senderId: Int64`
  - `text: String`
  - `timestamp: Int64`
- 不允许额外加入的字段：
  - `flags`
  - `constructor`
  - `rawBytes`
  - `accessHash`
  - `peerRaw`
  - 任何 `TL*` 类型字段

# Golden Template
```cangjie
// 强制标准架构模板：防腐层与领域实体
package telegram.domain

// 1. 纯净领域实体 (严格字段白名单)
public struct DomainUser {
    public let id: Int64
    public let name: String
    public let isBot: Bool
}

public struct ChatMessage {
    public let messageId: Int64
    public let senderId: Int64
    public let text: String
    public let timestamp: Int64
}

// 2. 集中式防腐映射器 (ACL Mapper)
public class TelegramAclMapper {
    // 禁止在 Service 中直接解析 TLUser，必须调用此方法
    public static func mapToDomainUser(tlUser: TLUser): DomainUser {
        return DomainUser(
            id: tlUser.id,
            name: tlUser.first_name + " " + tlUser.last_name,
            isBot: tlUser.bot
        )
    }

    public static func mapToChatMessage(tlMessage: TLMessage): ChatMessage {
        return ChatMessage(
            messageId: tlMessage.id,
            senderId: tlMessage.peer_id.user_id,
            text: tlMessage.message,
            timestamp: tlMessage.date
        )
    }
}
```

# Golden Service Pattern
```cangjie
// Service 层只能使用 DomainUser / ChatMessage
public class RealMessageService {
    private let protocolAdapter: ITelegramProtocolAdapter

    public func cacheUsers(users: Array<DomainUser>) {
        // 这里只缓存领域对象
    }

    public func refreshHistory(peerId: PeerId): Promise<Array<ChatMessage>> {
        return protocolAdapter.fetchHistory(peerId).then { tlMessages =>
            let domainMessages = tlMessages.map { message =>
                TelegramAclMapper.mapToChatMessage(message)
            }
            return domainMessages
        }
    }
}
```

# Golden Anti-Pattern
```cangjie
// 反例：以下内容绝对不允许留在 Service 中
public func cacheUsers(users: Array<TLUser>)
private func createInputPeer(peerId: PeerId): InputPeer
public func fetchRawBytes(...): ArrayBuffer
public let messageSignal: Signal<Array<TLMessage>>
```

# Architecture Review Gates
- 必查维度：
  - `ARCH_DOMAIN_PURITY`
  - `ARCH_PROTOCOL_ISOLATION`
- 阻断条件：
  - 没有 `DomainUser` / `ChatMessage` 或等价领域实体
  - 没有 `TelegramAclMapper` / `DomainMapper` 或等价集中式 Mapper
  - Service 方法签名、字段、返回值中仍出现 `TL*`
  - Service 中仍存在 `createInputPeer` / `InputPeer*`
- 修复指令模板：
  - 立即创建最小领域实体
  - 立即创建集中式 ACL Mapper
  - 立即将协议对象构造下沉到 Adapter
  - 立即把 Service 签名切换到领域实体

# Test & Debug
- 快速验证步骤：
  1. 搜候选代码中是否出现 `DomainUser`
  2. 搜候选代码中是否出现 `ChatMessage`
  3. 搜候选代码中是否出现 `TelegramAclMapper` / `DomainMapper`
  4. 搜 Service 中是否仍出现 `TLUser` / `TLMessage` / `createInputPeer`
- 排错顺序：
  1. 先补领域实体
  2. 再补集中式 Mapper
  3. 再移除 Service 中的 TL 类型
  4. 最后清理 `InputPeer` 构造残留

# Sources
- 来源列表：
  - `skills/acl-mapper-and-domain-genesis-strategy.md`
  - `skills/anti-corruption-and-concurrency-strategy.md`
  - `skills/protocol-adapter-extraction-strategy.md`
  - `docs/traces/trace-phase-02-iron-test-real-llm-run-005-domain-genesis.md`

# Known Gaps
- 当前空白：
  - 真实业务域名是否最终采用 `DomainUser` / `ChatMessage` 还是 `AppUser` / `MessageEntity`，后续可按工程命名调整。
  - 字段白名单当前按最小业务可用集给出，后续可再扩展，但必须走显式白名单评审。

# Evolution Log
- 版本演进记录：
  - `[2026-03-26] [V2.0-initial] 新增黄金模板 Skill，直接提供领域实体白名单、ACL Mapper 标准实现和 Service 反例清单，作为 Round 5 的高优先 Few-shot 注入模板。`
