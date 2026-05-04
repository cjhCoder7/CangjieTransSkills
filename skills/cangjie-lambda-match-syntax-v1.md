# Skill Metadata
- Skill ID: `CJ-LAMBDA-MATCH-SYNTAX-001-V1`
- Skill Name: `cangjie-lambda-match-syntax-v1`
- Skill Class: `Architecture`
- Scope: 专门针对真实 `cjc` 中的 `expected '=>' in lambda expression`、`found keyword 'match'`、`found keyword 'let'` 这类深层语法错误，矫正闭包起手式、`match` 分支表达式写法，以及多语句逻辑的 helper 提取策略。
- Tags: `cangjie`, `lambda`, `closure`, `match`, `expression`, `case`, `helper`, `compile`, `syntax`
- Version: `V1`

# Trigger Condition
- 真实 `cjc` 报错出现以下任一项时必须触发：
  - `expected '=>' in lambda expression`
  - `found keyword 'match'`
  - `found keyword 'let'`
- 当候选代码中出现 `case _ => {` 或 `case Some(x) => {` 这类分支块时，建议默认挂载。

# Core Concept
- 当前物理环境下，`match` 分支应优先视为“单表达式返回位”。
- 一旦你在 `case _ =>` 后面直接塞 `{ let ... ; match ... }`，编译器极有可能把这个 `{ ... }` 误判成 lambda / closure 开头，并要求你立刻给出 `=>`。
- 因此：
  1. 需要多语句时，优先抽 helper 函数；
  2. 需要真正写闭包时，必须明确写出参数头和 `=>`；
  3. `match` 是表达式，不要把它当 `switch-case + 外部赋值` 使用。

# Syntax Iron Laws
- **铁律 1：闭包标准起手式**
  - 标准闭包写法：`{ param: Type => ... }`
  - 严禁：`(param) => { ... }`
  - 严禁：只写 `{ ... }` 却不提供参数头或 `=>`

- **铁律 2：`match` 分支优先保持单表达式**
  - 允许：
    ```text
    match (value) {
        case Some(item) => item.id
        case _ => Int64(0)
    }
    ```
  - 严禁：
    ```text
    match (value) {
        case _ => {
            let fallback = Int64(0)
            fallback
        }
    }
    ```

- **铁律 3：`case _ =>` 里如果要写 `let` / 嵌套 `match`，先抽 helper**
  - 当前最稳的 compile-safe 路线不是在分支里硬塞块，而是：
    - 分支里直接调用 helper：`case _ => this.loadMessages(peerId, limit, key)`
    - helper 内部再写 `let`、副作用、嵌套 `match`

- **铁律 4：`match` 是表达式，不要用它模拟 `switch`**
  - 如果目标是返回值，就直接在 `case` 分支里返回表达式。
  - 不要先声明外部变量，再在每个分支里给它赋值。

# Physically Verified Positive Example
以下写法已在本地真实 `cjc` 下通过 `--output-type staticlib` 编译：

```text
let myFunc = { msg: Message =>
    let id = msg.id
    match (id) {
        case 0 => 1
        case _ => 2
    }
}
```

要点：
- 闭包头必须显式写成 `{ msg: Message =>`
- `let` 与 `match` 出现在 `=>` 之后的闭包体中，这是安全的

# Physically Verified Negative Example
以下写法已被本地真实 `cjc` 证明会触发你当前看到的主错误：

```text
match (flag) {
    case true => 1
    case _ => {
        let value = 2
        value
    }
}
```

对应真实报错：
- `expected '=>' in lambda expression, found keyword 'let'`

# Compile-Safe Replacement Pattern
如果 `case _ =>` 分支里需要多语句，请改成 helper：

```text
private func buildFallbackValue(): Int64 {
    let value = 2
    value
}

func ok(flag: Bool): Int64 {
    match (flag) {
        case true => 1
        case _ => this.buildFallbackValue()
    }
}
```

# RealMessageService-Safe Pattern
- **错误方向**：
  ```text
  public func getMessages(peerId: Int64, limit: Int32): Array<DomainMessage> {
      let key = "${peerId}"
      match (this.messageCache.get(key)) {
          case Some(messages) => messages
          case _ => {
              let accessHash = this.getAccessHash(peerId)
              let fetched = this.adapter.fetchHistory(peerId, limit, accessHash)
              this.messageCache.add(key, fetched)
              fetched
          }
      }
  }
  ```

- **当前 compile-safe 方向**：
  ```text
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
  ```

- **嵌套 `match` 同理**：
  ```text
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
  ```

# Repair Checklist
- 如果报错里出现 `expected '=>' in lambda expression, found keyword 'match'`：
  - 检查是否把 `{ match (...) { ... } }` 直接塞进了 `case _ =>` 后面；
  - 立刻把这段逻辑抽成 helper。
- 如果报错里出现 `expected '=>' in lambda expression, found keyword 'let'`：
  - 检查是否把多语句块直接放进 `case _ =>`；
  - 立刻改成 helper 返回值。
- 如果真的需要闭包：
  - 必须写成 `{ param: Type => ... }`
  - 不要写成 `(param) => { ... }`

# Hard Verdict
只要候选里还出现以下任一项，就说明还没修到位：
- `case _ => {`
- `case Some(` 后紧跟块级 `{` 且块内有 `let` / `match`
- `(param) => {`
- `match` 被当成 `switch + 外部赋值` 使用
