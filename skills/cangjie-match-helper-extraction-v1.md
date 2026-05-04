# Skill Metadata
- Skill ID: `CJ-MATCH-HELPER-EXTRACTION-001-V1`
- Skill Name: `cangjie-match-helper-extraction-v1`
- Skill Class: `Architecture`
- Scope: 专门针对真实 `cjc` 中由 `match` 分支块触发的 `expected '=>' in lambda expression` 致命错误，强制执行“`case ... =>` 后零代码块、零 `let`、零副作用直写”的 helper 提取策略。
- Tags: `cangjie`, `match`, `helper extraction`, `zero-block`, `lambda`, `compile`, `syntax`, `service`
- Version: `V1`

# Trigger Condition
- 真实 `cjc` / repair guidance 中出现以下任一项时必须触发：
  - `expected '=>' in lambda expression`
  - `found keyword 'let'`
  - `found keyword 'this'`
  - `found keyword 'match'`
- 候选代码中出现以下任一坏味道时必须触发：
  - `case Some(...) => {`
  - `case _ => {`
  - `case ... => { let ... }`
  - `case ... => { this.... }`
  - `case ... => { match (...) { ... } }`

# Core Concept
- 当前物理环境下，`match` 分支不是小函数体，不是 `switch-case`，更不是用来塞多语句块的临时垃圾桶。
- **只要 `=>` 后面接 `{`，你就已经半只脚踩进了 `expected '=>'` 的地雷区。**
- 因此本 Skill 的目标只有一个：
  - **把所有 `case ... => { ... }` 变成 `case ... => this.handleXxx(...)` 这类单行 helper 调用。**

# 铁血军规
- **军规 1：The Zero-Block Rule**
  - 在 `match` 表达式的 `=>` 后面，**绝对禁止**使用 `{}` 代码块。
  - 在 `match` 表达式的 `=>` 后面，**绝对禁止**出现 `let` 声明。
  - 在 `match` 表达式的 `=>` 后面，**绝对禁止**直接写 `this.xxx(...)` 与多步更新组合。

- **军规 2：Mandatory Helper Extraction**
  - 只要分支内需要超过一个操作，就必须提取 helper。
  - 典型“超过一个操作”的情形包括：
    - 先计算，再更新 Cache，再返回
    - 先查值，再嵌套 `match`，再返回
    - 先构造 `Array`，再 `cache.add(...)`
    - 先调用 `adapter`，再更新本地状态
  - 统一改成：
    - `case Some(msg) => this.handleMessageUpdate(msg)`
    - `case _ => this.seedMessageCache(key, message)`
    - `case _ => this.resolveChannelAccessHash(peerId)`

- **军规 3：The Golden Pattern**
  - **绝对禁止**：
    ```text
    case Some(msg) => {
        let updated = msg.update()
        this.cache.add(updated)
    }
    ```
  - **唯一生路**：
    ```text
    case Some(msg) => this.handleMessageUpdate(msg)
    ```

# Positive Contrast
- **反面例子：必炸**
  ```text
  match (this.messageCache.get(key)) {
      case Some(existing) => {
          let newMessages = Array<DomainMessage>(existing.size + 1, { index: Int64 =>
              match (index == existing.size) {
                  case true => message
                  case _ => existing[index]
              }
          })
          this.messageCache.add(key, newMessages)
      }
      case _ => {
          this.messageCache.add(key, [message])
      }
  }
  ```

- **正面例子：compile-safe 方向**
  ```text
  match (this.messageCache.get(key)) {
      case Some(existing) => this.appendExistingMessages(key, existing, message)
      case _ => this.seedMessageCache(key, message)
  }
  ```

- **对应 helper**
  ```text
  private func appendExistingMessages(key: String, existing: Array<DomainMessage>, message: DomainMessage): Unit {
      let newMessages = Array<DomainMessage>(existing.size + 1, { index: Int64 =>
          match (index == existing.size) {
              case true => message
              case _ => existing[index]
          }
      })
      this.messageCache.add(key, newMessages)
  }

  private func seedMessageCache(key: String, message: DomainMessage): Unit {
      this.messageCache.add(key, [message])
  }
  ```

# RealMessageService Golden Templates
- **消息缓存更新**
  ```text
  private func appendMessageToCache(key: String, message: DomainMessage): Unit {
      match (this.messageCache.get(key)) {
          case Some(existing) => this.appendExistingMessages(key, existing, message)
          case _ => this.seedMessageCache(key, message)
      }
  }
  ```

- **访问哈希回退**
  ```text
  private func resolveAccessHash(peerId: Int64): Int64 {
      match (this.userCache.get(peerId)) {
          case Some(user) => user.accessHash
          case _ => this.resolveChannelAccessHash(peerId)
      }
  }
  ```

- **嵌套 `match` 拆 helper**
  ```text
  private func resolveChannelAccessHash(peerId: Int64): Int64 {
      match (this.channelCache.get(peerId)) {
          case Some(channel) => channel.accessHash
          case _ => Int64(0)
      }
  }
  ```

# Hard Rewrite Rules
- 看到 `case ... => { let ... }`：直接拆 helper
- 看到 `case ... => { this.... }`：直接拆 helper
- 看到 `case ... => { match ... }`：直接拆 helper
- 看到 `case ... => { adapter... ; cache... }`：直接拆 helper
- **任何 `case` 分支里只要操作数 > 1，就一律拆 helper，不讨论。**

# Repair Checklist
- 先全局扫描：
  - `case Some(`
  - `case _ => {`
  - `=> {`
- 只要命中任一项：
  - 不要继续局部修修补补；
  - 先把每个分支块提成 `private func handleXxx(...)`。
- 提取后复查：
  - `match` 分支是否都只剩单表达式？
  - `let` 是否全部离开了 `case` 分支？
  - `this.cache.add(...)` 是否离开了 `case` 分支？

# Hard Verdict
只要候选中还出现以下任一项，就说明这层还没修穿：
- `case Some(` 后紧跟 `{`
- `case _ => {`
- `=> { let`
- `=> { this.`
- `=> { match`

# Sources
- 来源列表：
  - `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-030-round31-init-array-push/RealMessageService.orchestration.json`
  - `skills/cangjie-lambda-match-syntax-v1.md`
  - `skills/cangjie-init-array-time-syntax-v1.md`
  - `docs/traces/trace-phase-03-physical-iron-test-realmessageservice-013-round31-init-array-push.md`

# Evolution Log
- 版本演进记录：
  - `[2026-03-30] [V1.0-initial] 基于 Round 31 中“init 已修正但 match 分支块仍触发 lambda 致命错误”的真实证据，新增 zero-block / helper extraction 专项 Skill。`
