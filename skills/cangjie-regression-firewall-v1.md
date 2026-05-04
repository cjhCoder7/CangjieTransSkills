# Skill Metadata
- Skill ID: `CJ-REGRESSION-FIREWALL-001-V1`
- Skill Name: `cangjie-regression-firewall-v1`
- Skill Class: `Architecture`
- Scope: 专门针对 `Round 28` 已经打穿静态墙、但后续轮次又回退到 `std.unsafe`、`TL*`、`InputPeer`、`createInputPeer`、`SignalPipe`、`ValueSignal` 等污染物的情况，建立“只许前进、不许回头”的防回退硬墙。
- Tags: `cangjie`, `regression`, `firewall`, `compile`, `static-blacklist`, `domain-purity`, `service`, `anti-regression`
- Version: `V1`

# Trigger Condition
- 当 repair guidance / verify evidence 中出现以下任一项时必须触发：
  - `static-blacklist-failed`
  - `std.unsafe`
  - `TLUser` / `TLChannel` / 任意 `TL*`
  - `InputPeer`
  - `createInputPeer`
  - `ProtocolContext`
  - `SignalPipe` / `Signal` / `ValueSignal`
  - `HashMap[` 或下标写缓存的残留迹象
- 当系统已经证明自己能到达 `review_passed -> compile-failed`，但随后又退回静态墙时，必须把本 Skill 置于高优先级队列。

# Core Concept
- **Round 28 已经证明：系统有能力写出足够纯净的候选，从而进入真实 `cjc` 编译错误。**
- 因此当前任务不是“再发明一套更花哨的架构”，而是：
  1. 冻结已经清除过的污染 token family；
  2. 保住已获得的 deep compile 区域；
  3. 只在 compile-safe 语法轨道内继续修深层错误。
- 这意味着：
  - **如果不确定怎么写，优先收缩为最小领域骨架 / helper，而不是重新引入协议对象或伪异步框架。**
  - **如果一个 token family 曾经被清掉，它就再也不该回来。**

# Regression Iron Laws
- **铁律 1：已清除污染永不复活**
  - 一旦某轮已经证明可以不使用这些词汇，就永久禁止它们再次出现：
    - `std.unsafe`
    - `TLUser` / `TLChannel` / 任意 `TL*`
    - `InputPeer`
    - `createInputPeer`
    - `ProtocolContext`
    - `SignalPipe` / `Signal` / `ValueSignal` / `Observable`
    - `ohos.*`
  - 这些都不是“可暂时借用”的过渡写法，而是明确回退。

- **铁律 2：Service 只保留基础类型 + 纯领域模型**
  - Service 方法签名、字段、返回值中只允许：
    - `Int32` / `Int64` / `String` / `Bool`
    - `Array<DomainUser>` / `Array<DomainChannel>` / `Array<DomainMessage>`
    - `HashMap<K, Domain*>`
  - 严禁在 Service 层出现任何协议边界对象、伪信号流、传输上下文和字节级对象。

- **铁律 3：如果不确定，就缩成 helper，而不是扩回协议层**
  - 当前首要目标是第一次真实 compile pass。
  - 遇到复杂分支时：
    - 优先 `case _ => this.helper(...)`
    - 优先显式 helper
    - 优先最小可编译骨架
  - 严禁因为“想把功能补全”而把 `TL*`、`InputPeer`、`sendRequest`、`SignalPipe` 重新塞回 Service。

- **铁律 4：缓存更新走显式 helper / `add(...)`，不要回到下标赋值幻觉**
  - 高危坏味道：`messageCache[key] = value`
  - 当前 compile-safe 路线：
    - `this.messageCache.add(key, value)`
    - 或封装成 `this.storeMessages(key, value)`

- **铁律 5：不要试图用注释解释违禁词还存在**
  - `import std.unsafe.* // 实际不会用`
  - `TLUser // TODO later migrate`
  - 这种写法不会被视为“部分修复”，只会被视为彻底失败。

# Hard Ban Table
- **协议 / 架构污染**
  - `TL*`
  - `InputPeer`
  - `createInputPeer`
  - `ProtocolContext`
  - `sendRequest(`
  - `TLSerializer` / `TLDeserializer`
- **伪异步 / 伪基础设施**
  - `SignalPipe`
  - `Signal`
  - `ValueSignal`
  - `Observable`
- **语法 / 静态墙倒退**
  - `std.unsafe`
  - `ohos.*`
  - `export class`
  - `implements`
  - `extends`
  - `0L` / `0U` / `0UL`
- **集合写法倒退**
  - `HashMap[...] =`
  - `ArrayList`

# Compile-Safe Positive Template
```text
import std.collection.*

open class RealMessageService {
    private let userCache = HashMap<Int64, DomainUser>()
    private let channelCache = HashMap<Int64, DomainChannel>()
    private let messageCache = HashMap<String, Array<DomainMessage>>()
    private let adapter: IMTProtoAdapter

    public init(adapter: IMTProtoAdapter) {
        this.adapter = adapter
    }

    public func cacheUsers(users: Array<DomainUser>): Unit {
        for (user in users) {
            this.userCache.add(user.id, user)
        }
    }

    public func cacheChannels(channels: Array<DomainChannel>): Unit {
        for (channel in channels) {
            this.channelCache.add(channel.id, channel)
        }
    }

    public func getMessages(peerId: Int64, limit: Int32): Array<DomainMessage> {
        let key = "${peerId}"
        match (this.messageCache.get(key)) {
            case Some(messages) => messages
            case _ => this.loadMessages(peerId, limit, key)
        }
    }

    private func loadMessages(peerId: Int64, limit: Int32, key: String): Array<DomainMessage> {
        let accessHash = this.getAccessHash(peerId)
        let fetched = this.adapter.fetchHistory(peerId, limit, accessHash)
        this.messageCache.add(key, fetched)
        fetched
    }

    private func getAccessHash(peerId: Int64): Int64 {
        match (this.userCache.get(peerId)) {
            case Some(user) => user.accessHash
            case _ => this.resolveChannelAccessHash(peerId)
        }
    }

    private func resolveChannelAccessHash(peerId: Int64): Int64 {
        match (this.channelCache.get(peerId)) {
            case Some(channel) => channel.accessHash
            case _ => Int64(0)
        }
    }
}
```

# Negative Examples
- **回退到协议污染**
  ```text
  public func cacheUsers(users: Array<TLUser>): Unit
  private func createInputPeer(peerId: Int64): InputPeer
  ```

- **回退到伪异步基础设施**
  ```text
  private let signals = HashMap<String, ValueSignal<Array<DomainMessage>>>()
  ```

- **回退到危险缓存写法**
  ```text
  this.messageCache[key] = fetched
  ```

- **回退到静态墙**
  ```text
  import std.unsafe.*
  ```

# Repair Checklist
- 先扫一遍候选，确认以下 token 是否完全消失：
  - `std.unsafe`
  - `TL*`
  - `InputPeer`
  - `createInputPeer`
  - `ProtocolContext`
  - `SignalPipe` / `Signal` / `ValueSignal`
  - `HashMap[`
- 如果这些 token 中任意一个还在：
  - 不要继续修深层编译错误；
  - 先物理删除回退源，再谈 compile pass。
- 如果语义不确定：
  - 用最小 helper 保住纯领域骨架；
  - 不要通过新增协议类型来“补功能”。

# Hard Verdict
只要候选中还出现以下任一项，就说明还没有进入 Round 30 的正确轨道：
- `std.unsafe`
- `TL*`
- `InputPeer`
- `createInputPeer`
- `ProtocolContext`
- `SignalPipe` / `Signal` / `ValueSignal`
- `HashMap[` 下标赋值式缓存更新
- `case _ => {` 与深层语法块同时回潮

# Sources
- 来源列表：
  - `docs/traces/trace-phase-03-physical-iron-test-realmessageservice-010-round28-number-suffix-push.md`
  - `docs/traces/trace-phase-03-physical-iron-test-realmessageservice-011-round29-lambda-match-push.md`
  - `skills/cangjie-service-compile-baseline-v1.md`
  - `skills/cangjie-lambda-match-syntax-v1.md`
  - `skills/domain-purity-hard-template.md`
  - `scripts/orchestrator.py`
  - `scripts/static_blacklist_checker.py`

# Evolution Log
- 版本演进记录：
  - `[2026-03-30] [V1.0-initial] 基于 Round 28 深编译突破与 Round 29 静态墙回退证据，新增防回退硬墙 Skill，目标是在后续轮次冻结已清除污染族并保住 compile-safe 轨道。`
