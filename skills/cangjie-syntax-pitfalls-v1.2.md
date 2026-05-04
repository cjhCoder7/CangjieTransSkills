# Skill Metadata
- Skill ID: `CJ-SYNTAX-PITFALLS-001-V1.2`
- Skill Name: `cangjie-syntax-pitfalls-v1.2`
- Skill Class: `Architecture`
- Scope: 基于真实 `cjc` 物理压测结果，为 ArkTS / TypeScript -> 仓颉迁移提供更强硬的语法防坑与修复模板，重点终结数字后缀幻觉、关键字冲突、`!` / `!!` 恶习、以及 Promise / Lambda 写法漂移。
- Tags: `cangjie`, `syntax`, `pitfalls`, `number-literal`, `keyword-conflict`, `non-null`, `promise`, `lambda`, `compiler-feedback`
- Version: `V1.2`

# Trigger Condition
- 任务触发条件：真实 `cjc` 报错出现以下任一关键词：
  - `unknown suffix`
  - `expected a '*' or identifier after '.'`
  - `expected ';' or '<NL>', found '!'`
  - `expected '=>' in lambda expression`
  - `expected '->' in function type`
- 强制触发条件：
  - 代码中出现 `0L` / `1L` / `123L`
  - 代码中出现 `0U` / `1U` / `0UL` / `1UL`
  - 代码中出现 `std.unsafe.*` 或其他保留字冲突导入
  - 代码中出现 `value!`、`map.get(key)!`、`signal!!`、`!!value`
  - 代码中出现 `Promise<T> { ... }`、`Promise<T> { () => ... }`
- 不适用条件：纯文档讨论、不进入真实编译器的离线草案。

# Core Concept
- 最短知识结论：真实仓颉编译器会优先击落微语法错误；如果不先消灭这些低层阻塞点，模型就无法稳定推进 Adapter / ACL / Domain 重构。
- 一句话风险提示：不要把 Java / TypeScript / Kotlin 的局部语法习惯偷偷带进仓颉；任何“看起来差不多”的写法都必须优先怀疑。

# Number Literal Rule
- **彻底终结后缀幻觉**：
  - 仓颉中不要写任何 `L`、`U`、`UL` 后缀；
  - 需要整数时直接写 `0`、`1`、`42`；
  - 若必须匹配目标类型，使用显式构造或类型转换，而不是后缀。
- 禁止写法：
  ```text
  0L
  0U
  0UL
  accessHash ?? 0UL
  ```
- 推荐修正：
  ```text
  accessHash ?? 0
  UInt64(0)
  Int64(0)
  ```

# Keyword Conflict Rule
- **关键字避让**：
  - 若名字命中仓颉保留字，优先直接重命名；
  - `std.unsafe` 在当前项目中属于高危禁区，不要尝试通过反引号继续保留。
- 典型错误：
  ```text
  import std.unsafe.*
  ```
- 推荐修正：
  ```text
  let rawBytes = payload as Array<UInt8>
  match (value) {
      case Some(actual) => actual
      case None => throw StateError("missing value")
  }
  ```
- 规则优先级：
  - `std.unsafe`：直接删除，改用 `as`、模式匹配或显式领域转换；
  - 本地命名冲突：优先重命名。

# Non-Null And Boolean Bang Rule
- **彻底禁用 TypeScript 恶习**：
  - 禁止 `value!` 作为非空断言；
  - 禁止 `!!value` 作为强转布尔；
  - 禁止 `map.get(key)!!`、`signal!!` 这类双叹号变体。
- 推荐修正：
  ```text
  let signal = messageSignals.get(key)
  if (signal == None) {
      throw StateError("missing signal")
  }
  return signal
  ```
- 若要表达布尔判断：
  ```text
  let hasValue = value != None
  ```
- 若要提供默认值：
  ```text
  let signal = messageSignals.get(key) ?? fallbackSignal
  ```

# Promise And Lambda Rule
- **函数类型与 lambda 体必须分离理解**：
  - 函数类型使用 `() -> T`
  - lambda / closure 实现使用 `() => { ... }`
- 禁止写法：
  ```text
  Promise<Array<Message>> { () =>
      ...
  }
  ```
- 推荐写法：
  ```text
  let producer: () -> Array<Message> = () => {
      return messages
  }
  return Promise<Array<Message>>(producer)
  ```
- 如果当前 SDK 的 Promise 构造器签名没有通过真实验证：
  - 不要手写模糊形式；
  - 优先采用项目已有的同步封装、明确的工厂函数或经验证的异步桥接。

# Few-Shot Contrast
- 对比一：数字后缀
  ```text
  // 错误
  peer.accessHash = hashes.get(key) ?? 0UL

  // 正确方向
  peer.accessHash = hashes.get(key) ?? 0
  // 或
  peer.accessHash = hashes.get(key) ?? UInt64(0)
  ```
- 对比二：关键字导入
  ```text
  // 错误
  import std.unsafe.*

  // 正确方向
  import std.`unsafe`.*
  ```
- 对比三：非空断言 / 双叹号
  ```text
  // 错误
  return this.messageSignals[key]!!

  // 正确方向
  let signal = this.messageSignals.get(key)
  if (signal == None) {
      throw StateError("missing signal")
  }
  return signal
  ```
- 对比四：Promise + lambda
  ```text
  // 错误
  return Promise<Array<Message>> { () => ... }

  // 正确方向
  let producer: () -> Array<Message> = () => {
      return messages
  }
  return Promise<Array<Message>>(producer)
  ```

# Enforcement Checklist
- 输出候选前必须自检：
  1. 是否还残留任何 `L` / `U` / `UL` 数字后缀？
  2. 是否还出现 `std.unsafe.*` 这类未转义关键字导入？
  3. 是否还出现 `!` / `!!` 非空断言或布尔强转？
  4. Promise / Lambda 是否采用了已知稳定写法？
- 若任一项为“是”，必须先修语法，再继续架构整改。

# Output Contract
- 若 Repair Guidance 同时包含 Review 与 Compile 证据，必须在候选中同时修：
  - 架构问题：Adapter / ACL / Domain Mapper / 并发契约
  - 语法问题：数字后缀、关键字冲突、`!` / `!!`、Promise / Lambda
- 禁止策略：
  - 不能通过删除主逻辑、留 TODO、塞 fake stub、或把问题推迟到 later 来绕过编译器。


# Minimal Escape Guide
- 想用 `ArrayList`？ -> 请用 `Vector<T>`。
- 想用 `std.unsafe` 强转？ -> 请用 `as` 关键字或模式匹配。
- 想用 `ohos.state` / `ohos.signal`？ -> 请用简单变量、`Vector`、或当前项目已允许的并发原语，不要再引入 `ohos.*`。
