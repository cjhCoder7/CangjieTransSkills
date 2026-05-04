# Skill Metadata
- Skill ID: `CJ-SYNTAX-PITFALLS-001-V1.1`
- Skill Name: `cangjie-syntax-pitfalls-v1.1`
- Skill Class: `Architecture`
- Scope: 基于真实 `cjc` 物理压测结果，为 ArkTS / TypeScript -> 仓颉迁移提供更细粒度的语法防坑指南，重点解决关键字冲突、非空断言、Promise / 闭包签名，以及上一轮已验证的整数字面量问题。
- Tags: `cangjie`, `syntax`, `pitfalls`, `keyword-conflict`, `non-null`, `promise`, `closure`, `compiler-feedback`
- Version: `V1.1`

# Trigger Condition
- 任务触发条件：真实 `cjc` 报错出现以下任一关键词：
  - `unknown suffix`
  - `expected a '*' or identifier after '.'`
  - `expected ';' or '<NL>', found '!'`
  - `expected ';' or '<NL>', found '=>'`
  - `expected '->' in function type`
- 强制触发条件：
  - 代码中出现 `0L` / `1L` / `123L`
  - 代码中出现 `std.unsafe.*` 一类关键字冲突导入
  - 代码中出现 `value!`、`map.get(key)!`、`signal!` 等 TypeScript 风格非空断言
  - 代码中出现 `Promise<T> { () => ... }`、`Promise<T> { ... }` 这类把泛型实例化与闭包块粘连的写法
- 不适用条件：纯文档讨论、不进入真实编译器的离线草案。

# Core Concept
- 最短知识结论：真实仓颉迁移里，很多“看起来像对的”微语法都会在 `cjc` 第一时间爆炸；必须优先消灭这些语法级阻塞点，编译器才会继续暴露更深层的类型与依赖问题。
- 一句话风险提示：模型如果继续沿用 Java / TS / Kotlin / Swift 的局部语法习惯，就会在进入 Adapter / ACL 重构之前先被仓颉编译器击落。

# Cangjie Literal Rule
- **整数字面量**：
  - `Int64` 默认不要写 `L` 后缀；
  - 优先通过上下文类型或显式类型标注让编译器推断；
  - 禁止写法：`0L`、`1L`、`123L`
- 典型修正：
  ```text
  // 错误
  accessHash ?? 0L

  // 更安全
  accessHash ?? 0
  ```

# Keyword Conflict Rule
- **关键字冲突**：
  - 若标识符恰好与仓颉关键字冲突，不允许直接裸写；
  - 对 import / qualified name 中的冲突标识符，优先使用反引号转义；
  - 对本地变量、字段、类型名，优先重命名成语义化别名，而不是到处堆反引号。
- 典型错误：
  - `import std.unsafe.*`
- 推荐修正：
  ```text
  // 导入路径冲突：优先转义
  import std.`unsafe`.*

  // 本地命名冲突：优先重命名
  let unsafe -> let rawBytes / unsafeBlock / rawMemory
  ```

# Non-Null Assertion Rule
- **禁用 TypeScript 风格 `!` 非空断言**：
  - 不要写：`value!`、`map.get(key)!`、`signal!`；
  - 当前项目的物理压测已经证明这类写法会直接触发解析错误；
  - 可空值必须用显式判空、默认值或受控解包 helper 处理。
- 推荐范式：
  ```text
  // 错误
  let signal = messageSignals.get(key)!

  // 更稳的修正方向
  let signal = messageSignals.get(key)
  if (signal == None) {
      throw StateError("missing signal")
  }
  return signal
  ```
- 如果场景允许默认值：
  ```text
  let signal = messageSignals.get(key) ?? fallbackSignal
  ```
- 如果项目后续确定统一 helper，可采用：
  ```text
  let signal = getOrThrow(messageSignals.get(key), "missing signal")
  ```

# Promise And Closure Rule
- **闭包与函数类型要分开理解**：
  - **函数类型签名**使用 `() -> T`
  - **lambda / 闭包实现**使用 `() => { ... }`
- 典型误区：
  - 把“函数类型语法”和“lambda 体语法”混在一起；
  - 把泛型实例化和闭包块直接粘成：`Promise<T> { () => ... }`
- 禁止写法：
  ```text
  return Promise<Array<Message>> { () =>
      ...
  }
  ```
- 当前项目推荐的稳妥写法：
  ```text
  let producer: () -> Array<Message> = () => {
      ...
      return messages
  }

  return Promise<Array<Message>>(producer)
  ```
- 如果当前 SDK 的 Promise 构造器签名仍未被真实验证：
  - 不要临时手造 `Promise<T> { ... }` 形式；
  - 优先使用项目中已存在的异步封装、`spawn` 协调器、或先保留同步返回直到语法层稳定。

# Nullable Rule
- **可空类型 / 空值表达**：
  - 不要把 `Type?`、`?.`、`??` 当成跨语言完全通用；
  - 一旦 `cjc` 报错指向 `?`，优先怀疑可空声明或空值表达与当前仓颉语法不匹配；
  - 最稳妥的策略是先拆成显式判空分支，再逐步收敛回更精炼的写法。

# Few-Shot Contrast
- 对比一：关键字导入
  ```text
  // 错误
  import std.unsafe.*

  // 正确方向
  import std.`unsafe`.*
  ```
- 对比二：非空断言
  ```text
  // 错误
  let signal = messageSignals.get(key)!

  // 正确方向
  let signal = messageSignals.get(key)
  if (signal == None) {
      throw StateError("missing signal")
  }
  ```
- 对比三：函数类型 vs lambda
  ```text
  // 错误混写
  Promise<Array<Message>> { () => ... }

  // 正确拆分思路
  let producer: () -> Array<Message> = () => {
      return messages
  }
  return Promise<Array<Message>>(producer)
  ```
- 对比四：整数字面量
  ```text
  // 错误
  userHash ?? 0L

  // 正确方向
  userHash ?? 0
  ```

# Execution Topology
- 推荐修复顺序：
  1. 先修关键字冲突（如 `unsafe`）
  2. 再修 `0L` / 数字后缀
  3. 再修 `!` 非空断言
  4. 再修 Promise / lambda / function type
  5. 最后才继续推进 Adapter / ACL / 并发与状态边界
- 原因：前四类问题会阻断编译器继续深入分析。

# Verification Matrix
- 最低通过标准：
  - 不再出现 `unknown suffix 'L'`
  - 不再出现 `std.unsafe` 关键字冲突
  - 不再出现裸 `!` 非空断言解析错误
  - 不再出现 `Promise<T> { () => ... }` 形式导致的解析错误
- 失败判据：
  - notes 中声称“已修复”，但源码里仍残留同型问题；
  - 为了避开编译器而删除主逻辑或回退到 fake stub。

# Sources
- 来源列表：
  - `docs/traces/trace-phase-03-physical-iron-test-realmessageservice-001.md`
  - `docs/traces/trace-phase-03-physical-iron-test-realmessageservice-002-round7-dual-evidence.md`
  - `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-003-round7/RealMessageService.orchestration.json`
  - `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-003-round7/summary.json`

# Known Gaps
- 当前空白：
  - `Promise<Array<Message>>(producer)` 是否为最终项目可用 API，仍需以后续真实编译样本继续验证；
  - 某些可空写法与 helper 形式仍需结合更多 `cjc` 反馈校准；
  - 本 Skill 聚焦物理语法层，不替代 `protocol-adapter-extraction`、`acl-mapper-and-domain-genesis` 等架构层 Skill。
