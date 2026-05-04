# Skill Metadata
- Skill ID: `CJ-SERVICE-COMPILE-BASELINE-001-V1`
- Skill Name: `cangjie-service-compile-baseline-v1`
- Skill Class: `Architecture`
- Scope: 为 Service / Repository / Domain-Orchestrator 类翻译提供最小可编译骨架，优先消灭 `Atomic`、`null`、命名参数前缀、`??` 误用与可选链误用，帮助候选更稳定地进入真实 `cjc` 编译阶段。
- Tags: `cangjie`, `service`, `compile`, `option`, `hashmap`, `match`, `named-arguments`, `null`, `atomic`
- Version: `V1`

# Trigger Condition
- 真实 `cjc` 报错中出现以下任一项时必须触发：
  - `undeclared identifier 'Atomic'`
  - `undeclared identifier 'null'`
  - `invalid named arguments prefix`
  - `coalescing is only valid for 'Option'`
  - `cannot use optional chaining`
- 当目标角色是 `service`，且代码中同时出现缓存、领域对象、Adapter 注入时，建议默认挂载。

# Core Concept
- 当前阶段先不要追求“看起来像源语言”，而要追求“最小可编译骨架”。
- Service 层最安全的路线是：
  1. 纯领域模型；
  2. `HashMap.get/add/remove`；
  3. `Option<T>` + `match`；
  4. Adapter 调用统一走位置参数；
  5. 不引入任何未经本仓库样本验证的空值、链式调用或并发语法幻想。

# Hard Rules
- **禁止 `Atomic` 幻觉**：
  - 不要写 `Atomic<Int64>`、`AtomicLong`、`AtomicInteger`。
  - 若计数器当前不是核心行为，请先删除该字段；若必须保留，先回退到简单 `var`。
- **禁止 `null`**：
  - 仓颉当前安全基线使用 `Option<T>.Some` / `Option<T>.None`，不要写 `null`。
- **禁止普通方法调用时强加命名参数前缀**：
  - 如果签名没有明确验证过支持命名参数，就按位置参数调用。
  - 尤其是接口方法、Adapter 方法、集合方法，一律优先位置参数。
- **禁止把非 `Option` 左值塞给 `??`**：
  - `messageCache[key] ?? fallback` 是高危写法。
  - 先用 `get` 拿到 `Option<T>`，再 `match`。
- **禁止对 `HashMap.get` 的结果写可选链**：
  - 不要写 `user?.accessHash`、`channel?.accessHash`。
  - 正确写法是 `match (map.get(key)) { ... }`。
- **禁止数字后缀倒退**：
  - 不要写 `0L`、`0U`、`0UL`、`1L`。
  - 统一改成 `0`、`1` 或 `Int64(0)` 这类显式构造。

# Safe Baseline
- 当前仓库已验证过的安全路线：
  - `HashMap<String, T>()`
  - `match (map.get(key)) { case Some(value) => ... case _ => ... }`
  - `this.values.add(key, value)`
  - `this.values.remove(key)`
  - `Option<T>.Some(...)`
  - `Option<T>.None`
- 参考样本：
  - `samples/data-persistence-001/FakeKeyValueStorage.cj`
  - `samples/data-persistence-001/SettingsRuntime.cj`
  - `samples/data-persistence-001/UserSettingsManager.cj`

# Unsafe vs Safe
- **错误：直接写 `null` 判断**
  ```text
  let cached = messageCache[key]
  if (cached != null) {
      return cached
  }
  ```
- **正确：用 `get` + `match`**
  ```text
  match (this.messageCache.get(key)) {
      case Some(messages) => messages
      case _ => this.loadMessages(peerId, limit, key, accessHash)
  }
  ```

- **错误：给普通方法乱加命名参数**
  ```text
  let messages = adapter.fetchHistory(peerId: peerId, limit: limit, accessHash: accessHash)
  ```
- **正确：位置参数**
  ```text
  let messages = this.adapter.fetchHistory(peerId, limit, accessHash)
  ```

- **错误：对非 `Option` 左值用 `??`**
  ```text
  let existing = messageCache[key] ?? Array<DomainMessage>()
  ```
- **正确：显式 `match`**
  ```text
  let existing = match (this.messageCache.get(key)) {
      case Some(messages) => messages
      case _ => Array<DomainMessage>()
  }
  ```

- **错误：可选链**
  ```text
  return user?.accessHash ?? 0
  ```
- **正确：`match` 取值**
  ```text
  match (this.userCache.get(peerId)) {
      case Some(user) => user.accessHash
      case _ => Int64(0)
  }
  ```

# Minimal Service Skeleton
```text
package src.services

import std.collection.*

public class DomainUser {
    public let id: Int64
    public let accessHash: Int64

    public init(id: Int64, accessHash: Int64) {
        this.id = id
        this.accessHash = accessHash
    }
}

public class DomainMessage {
    public let id: Int32
    public let text: String
    public let peerId: Int64

    public init(id: Int32, text: String, peerId: Int64) {
        this.id = id
        this.text = text
        this.peerId = peerId
    }
}

public interface IMTProtoAdapter {
    func fetchHistory(peerId: Int64, limit: Int32, accessHash: Int64): Array<DomainMessage>
    func sendMessage(peerId: Int64, text: String, accessHash: Int64): DomainMessage
}

open class RealMessageService {
    private let userCache = HashMap<Int64, DomainUser>()
    private let messageCache = HashMap<String, Array<DomainMessage>>()
    private let adapter: IMTProtoAdapter

    public init(adapter: IMTProtoAdapter) {
        this.adapter = adapter
    }

    public func getMessages(peerId: Int64, limit: Int32): Array<DomainMessage> {
        let key = "${peerId}"
        let accessHash = this.getAccessHash(peerId)
        match (this.messageCache.get(key)) {
            case Some(messages) => messages
            case _ => this.loadMessages(peerId, limit, key, accessHash)
        }
    }

    private func loadMessages(peerId: Int64, limit: Int32, key: String, accessHash: Int64): Array<DomainMessage> {
        let fetched = this.adapter.fetchHistory(peerId, limit, accessHash)
        this.messageCache.add(key, fetched)
        fetched
    }
}
```

# Repair Checklist
- 如果看到 `Atomic`：直接删除或降级成简单字段。
- 如果看到 `null`：改成 `Option<T>` 语义，优先 `match`。
- 如果看到 `foo(bar: x)`：先确认签名是否真的支持命名参数；不确定就改位置参数。
- 如果看到 `map[key] ?? fallback`：改成 `map.get(key)` + `match`。
- 如果看到 `user?.field`：改成 `match (map.get(key))`。

# Hard Verdict
以下任一项仍出现在候选中，就说明代码还没有进入编译安全基线，必须打回：
- `Atomic<`
- ` null`
- `!= null`
- `?.`
- `peerId:`（用于普通方法调用）
- `limit:`（用于普通方法调用）
- `accessHash:`（用于普通方法调用）
- `messageCache[key] ??`
- `0L`
- `0U`
- `0UL`
