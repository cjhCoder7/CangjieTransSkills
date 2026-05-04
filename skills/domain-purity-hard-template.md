# Skill Metadata
- Skill ID: `ARCH-DOMAIN-PURITY-HARD-TEMPLATE-001`
- Skill Name: `domain-purity-hard-template`
- Skill Class: `Architecture`
- Scope: 对 Telegram / MTProto / HarmonyOS 迁移中的防腐层进行零容忍约束，专门封堵 `ProtocolContext`、`createInputPeer`、`TL*`、`InputPeer`、`Buffer` 等伪隔离与协议泄漏逃生门。
- Tags: `architecture`, `acl`, `domain-purity`, `protocol-isolation`, `anti-cheat`, `telegram`, `mtproto`
- Version: `V1`

# Trigger Condition
- 只要目标是 `Service` / `Repository` / `UseCase` / `ViewModel` 之一，就应优先审视是否存在协议泄漏。
- 一旦代码中出现任意下列关键词，必须强制装载本 Skill：
  - `ProtocolContext`
  - `TLUser`, `TLMessage`, `TLChannel`, 任意 `TL*`
  - `InputPeer`, `createInputPeer`
  - `ArrayBuffer`, `Uint8Array`, `Buffer`, `ByteBuffer`
  - `TLSerializer`, `TLDeserializer`, `toBytes`, `sendRequest`

# Core Judgment

# Golden Bridge / Domain Model Hard Template
- **警告：Service 层绝不允许直接使用 `TLUser` / `TLChannel` / `TLMessage`！**
- **死命令**：遇到需要缓存或传递用户信息的地方，必须使用 `DomainUser`；`TLUser -> DomainUser` 的转换逻辑必须 100% 扔进 Adapter。
- **死命令**：遇到需要缓存或传递频道信息的地方，必须使用 `DomainChannel`；绝不允许把 `TLChannel` 塞进 `HashMap` / `Array` / `ArrayList`。
- **你可以直接照抄下面的极简模板，不允许再发明 `TL*` 容器缓存：**
  ```text
  // 警告：Service 层绝不允许直接使用 TLUser/TLChannel！
  // 你必须在 Service 层顶部（或同包内）定义极其轻量的领域模型（Domain Model），例如：
  public class DomainUser {
      public let id: Int64
      public let accessHash: Int64
      public init(id: Int64, accessHash: Int64) {
          this.id = id
          this.accessHash = accessHash
      }
  }

  public class DomainChannel {
      public let id: Int64
      public let accessHash: Int64
      public init(id: Int64, accessHash: Int64) {
          this.id = id
          this.accessHash = accessHash
      }
  }

  // 你的缓存必须使用领域模型：
  private let userCache = HashMap<Int64, DomainUser>()
  private let channelCache = HashMap<Int64, DomainChannel>()
  ```
- **禁止写法**：
  ```text
  private let userCache = HashMap<Int64, TLUser>()
  public func cacheUsers(users: Array<TLUser>)
  public func cacheChannels(channels: ArrayList<TLChannel>)
  ```
- **允许写法**：
  ```text
  public func cacheUsers(users: Array<DomainUser>)
  public func cacheChannels(channels: ArrayList<DomainChannel>)
  ```

- **点名批评伪隔离**：`ProtocolContext` 这类“把底层协议对象或协议元数据打包后再交给 Service”的做法，本质上仍然是把协议污染上浮到业务层，是一种 **作弊式伪隔离**。
- **架构底线**：Service 层不是协议层，也不是上下文缓存层。只要 Service 还能看见协议对象、协议元数据、协议构造器，说明迁移没有完成职责剥离。

# Absolute Blacklist
- 下列内容在 Service 层 **绝对禁止** 出现：
  - 任意 `TL*` 类型
  - `InputPeer` 及其子类
  - `ArrayBuffer`, `Uint8Array`, `Buffer`, raw bytes
  - `ProtocolContext`, `ProtocolState`, `ProtocolEnv`, 任意带 `Protocol` 字样的上下文对象
  - `createInputPeer` 方法
  - `TLSerializer`, `TLDeserializer`, `toBytes`, `sendRequest`
- 适用位置包括：
  - 构造函数参数
  - 方法签名（入参 / 返回值）
  - 字段 / 内部状态 / 缓存元素类型
  - 内部帮助方法
  - Adapter Interface 暴露面
- **额外硬限制**：
  - `createInputPeer` 必须 100% 下沉到 Adapter 的私有方法里；
  - 连 Adapter 的 Interface 也不允许暴露 `InputPeer`、`TL*`、`Buffer`；
  - Service 不得接收任何“包装后的协议上下文对象”来曲线救国。

# Strict Whitelist
- Service 层允许认识的类型仅限：
  - 基础类型：`Int64`, `Int32`, `UInt64`, `String`, `Bool`, `Float64`
  - 纯净领域模型：`DomainUser`, `ChatMessage`, `DomainChannel`, `MessageId`, `PeerId`
  - 纯业务参数对象：`SendMessageCommand`, `GetHistoryQuery` 等不含协议字段的 command / query
- 允许 Service 调用的边界对象：
  - `TelegramProtocolAdapter` 这类高层接口
  - 但其接口参数 / 返回值必须仍然是领域类型，而不是协议类型

# Anti-Pattern Verdicts
- **反例 1：ProtocolContext 作弊**
  ```text
  public init(context: ProtocolContext)
  ```
  - 判定：失败
  - 原因：Service 仍依赖协议元数据与协议上下文。
- **反例 2：Service 构造 InputPeer**
  ```text
  private func createInputPeer(peerId: PeerId): InputPeer
  ```
  - 判定：失败
  - 原因：协议构造逻辑未下沉到 Adapter 私有层。
- **反例 3：Service 接收 TLUser**
  ```text
  public func cacheUsers(users: Array<TLUser>): Unit
  ```
  - 判定：失败
  - 原因：领域纯洁性破坏，DTO 直接穿透业务层。

# Best Practice Template
- 正确方向：
  ```text
  public class RealMessageService {
      private let adapter: TelegramProtocolAdapter

      public func getMessages(peerId: PeerId, limit: Int32): Signal<Array<ChatMessage>>
      public func sendMessage(command: SendMessageCommand): Promise<ChatMessage>
  }
  ```
- Adapter 负责：
  - 将 `PeerId` 映射到底层协议目标
  - 发送请求、处理序列化/反序列化
  - 把 `TL*` DTO 映射成 `DomainUser` / `ChatMessage`
- Service 负责：
  - 编排业务流程
  - 管理纯领域状态与纯业务信号
  - 不碰协议对象与二进制细节

# Reviewer Hard Gates
- 一旦 Reviewer 发现：
  - `ProtocolContext`
  - `createInputPeer`
  - `TL*`
  - `InputPeer`
  - `Buffer` / raw bytes
  - 任意带 `Protocol` 字样的上下文对象进入 Service
- 必须直接：
  - `pass = false`
  - issue code 使用 `ARCH_DOMAIN_PURITY_VIOLATION` 或 `ARCH_PROTOCOL_ISOLATION`
  - 在 `message` 中明确指出：**这是伪隔离作弊，不允许放行**

# Repair Instruction Template
- 必须强制要求 Translator：
  1. 删除 Service 中所有 `TL*` / `InputPeer` / `ProtocolContext` / `createInputPeer`
  2. 新建或强化 `TelegramProtocolAdapter` 私有实现，接管协议构造与 DTO 映射
  3. 将 Service 方法签名收缩为基础类型与纯领域模型
  4. 若模型试图通过新造 `XXXProtocolContext`、`BridgeContext`、`InteropContext` 等别名继续包裹协议对象，同样视作失败
