# Skill Metadata
- Skill ID: `CJ-SYNTAX-PITFALLS-001`
- Skill Name: `cangjie-syntax-pitfalls-v1`
- Skill Class: `Architecture`
- Scope: 为 ArkTS / TypeScript -> 仓颉迁移提供一份“高频、细微、致命”的语法陷阱速查表，专门对冲 LLM 沿用 Java / TypeScript / Swift 书写习惯而导致的物理编译错误。
- Tags: `cangjie`, `syntax`, `pitfalls`, `compiler-feedback`, `lambda`, `nullable`, `literal`
- Version: `V1.0-initial`

# Trigger Condition
- 任务触发条件：真实 `cjc` 编译日志开始出现“unknown suffix”、“expected '=>'”、“expected ';' or '<NL>'”、“nullable type syntax”一类本体语法报错。
- 强制触发条件：
  - 生成代码中出现 `0L`、`1L`、`123L` 一类整数字面量后缀；
  - 生成代码中把闭包 / lambda 写成 `->`、裸 block 或沿用 TS/Java 风格；
  - 生成代码中出现 `Type?`、`value?.method()`、`??` 等写法与当前仓颉语法不匹配；
  - 生成代码明显把 ArkTS / TS 的集合字面量、空值合并、可选链直接平移到仓颉。
- 不适用条件：纯文档总结任务；不进入真实编译链的纯假设性草案。

# Core Concept
- 最短知识结论：仓颉迁移第一步不是“把架构写漂亮”，而是先避免那些会被 `cjc` 当场击落的细微语法误用。
- 一句话风险提示：只要模型还在沿用 Java / TS / Kotlin / Swift 的微语法习惯，它就会在真正进入 undefined symbol 之前，先被仓颉本体语法拦截。

# Translation Mapping
- ArkTS / TS `0n`, Java `0L`, Kotlin `0L` -> 仓颉 `0`
- ArkTS / TS `items.map((x) => x.id)` -> 仓颉 lambda 必须遵循当前编译器接受的 `=>` 风格，而不是 `->`
- ArkTS / TS `value?: Type` / `Type | null` / `Type?` -> 仓颉中不要想当然直接照抄，先参考当前工程已验证写法
- ArkTS / TS `obj?.call()` / `a ?? b` -> 仓颉中必须先确认当前编译器支持的空值与可空表达语法，不允许盲目平移

# Cangjie Literal Rule
- **整数字面量**：
  - `Int64` 默认不要加 `L` 后缀；
  - 当需要 `Int64` 时，优先直接写数字，并让类型由上下文或显式类型标注约束；
  - 禁止写法：`0L`、`1L`、`123456L`
- 典型错误：
  - `unknown suffix 'L' for number literal`
- 修正示例：
  ```text
  // 错误
  peer.accessHash = cache.get(key) ?? 0L

  // 更安全的修正思路
  peer.accessHash = cache.get(key) ?? 0
  ```

# Lambda Rule
- **Lambda / 闭包符号**：
  - 当前编译器压测中，lambda 必须遵循 `=>` 风格；
  - 不要沿用 Java / Swift / Kotlin 的 `->`；
  - 也不要把 block 直接塞进 `lock(...)` 调用而不写 lambda 头。
- 典型错误：
  - `expected '=>' in lambda expression`
- 修正示例：
  ```text
  // 错误
  cacheLock.lock({
      messageCache.put(cacheKey, messages)
  })

  // 正确思路（示意）
  cacheLock.lock(() => {
      messageCache.put(cacheKey, messages)
  })
  ```

# Nullable Rule
- **可空类型 / 空值表达**：
  - 不要把 `Message?`、`Signal?`、`Type?` 当成跨语言通用真理；
  - 当前编译器报错若指向 `?`，先优先怀疑“可空类型声明或空值表达语法不符合仓颉当前规则”；
  - `?.`、`??`、返回类型 `Type?` 都需要结合真实 `cjc` 报错与工程内已验证写法修正。
- 典型错误：
  - `expected ';' or '<NL>', found '?'`
- 修正策略：
  - 优先把可空逻辑显式拆成 if/else；
  - 优先把可空返回值改写为显式 Result / Optional 风格，或者与当前工程已验证的仓颉写法对齐；
  - 不要在一轮修复里同时保留 `?.`、`??`、`Type?` 三种未验证语法赌运气。

# Few-Shot Contrast
- 对比一：整数字面量
  ```text
  // ArkTS / Java 习惯
  let fallback = 0L

  // 仓颉压测安全写法
  let fallback: Int64 = 0
  ```
- 对比二：lambda
  ```text
  // ArkTS / Kotlin / Swift 风格迁移残留
  lock({
      updateState()
  })

  // 仓颉压测安全写法
  lock(() => {
      updateState()
  })
  ```
- 对比三：可空返回
  ```text
  // 盲目平移
  private func parse(...): Message?

  // 更稳的修正思路
  private func parse(...): Message {
      // 或改成显式 Optional / Result 风格，以真实 cjc 允许语法为准
  }
  ```
- 对比四：空值合并
  ```text
  // ArkTS 直译残留
  let existing = cache.get(key) ?? []

  // 更稳的修正思路
  let existing = cache.get(key)
  if (existing == None) {
      // 显式初始化
  }
  ```

# Architecture Mapping
- 源侧角色：ArkTS / TS / Java / Swift 的通用语言微语法。
- 目标侧角色：真实 `cjc` 当前版本下可接受的仓颉语法子集。
- 保留策略：保留业务语义，不保留源语言的字面量后缀、lambda 记号、可空写法习惯。
- 重构策略：一旦编译器在“字面量 / lambda / ?”层报错，优先修这个层，不要急着引入更多抽象。

# Boundary Contract
- 输入：Translator 当前轮生成的仓颉候选。
- 输出：能够继续进入下一层类型 / 依赖错误的语法更正版本。
- 生命周期归属：此 Skill 属于“物理编译反馈层”，优先级高于一般性风格建议。
- 错误传递方式：必须把真实 `cjc stderr` 原样摘要化后喂回 Translator，不允许只抽象成“语法有错”。

# Execution Topology
- 推荐修复顺序：
  1. 先修 `unknown suffix` 这类字面量错误；
  2. 再修 lambda / closure 记号；
  3. 再修 `?` 相关的可空类型与空值表达；
  4. 最后才进入 undefined symbol / missing import / 类型不匹配。
- 原因：前 3 类会阻断编译器继续深入分析。

# Verification Matrix
- 最低通过标准：
  - 不再出现 `unknown suffix 'L'`；
  - 不再出现 `expected '=>' in lambda expression`；
  - 不再出现直接由 `?` 导致的解析错误；
  - 编译器能继续前进到更深层的类型或依赖问题。
- 失败判据：
  - 模型在 notes 中声称“已修复字面量 / lambda / 可空语法”，但生成代码中仍保留相同错误模式；
  - 模型通过删除主逻辑来绕开这些语法点。

# Examples
- 示例一：真实物理错误
  ```text
  error: unknown suffix 'L' for number literal
  error: expected '=>' in lambda expression
  error: expected ';' or '<NL>', found '?'
  ```
- 示例二：修复策略摘要
  ```text
  先把 0L 改成 0
  再把 lock({ ... }) 改成 lock(() => { ... })
  再把 Message? / signal?.set(...) / ?? 这类表达拆成当前编译器能接受的显式写法
  ```

# Composition With Other Skills
- 前置 Skill：
  - `SKILL_SCHEMA_V2`
- 常见组合：
  - `protocol-adapter-extraction-strategy`
  - `anti-corruption-and-concurrency-strategy`
  - `domain-mapper-golden-template`
- 覆盖关系：当真实 `cjc` 已报物理语法错误时，本 Skill 的优先级高于一般性架构美化建议。
- 禁止组合：禁止与“先不管编译器语法、先继续做高级架构改写”的策略同时优先执行。

# Retrieval Fallback
- 仓库检索入口：
  - `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002/attempt-05.verify.real.json`
  - `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002/manual_repair_round6.verify.real.json`
  - `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002/manual_repair_round6_literalfix.verify.real.json`
- CLI / Python 检索示例：
  - `rg -n "unknown suffix|expected '=>'|found '\?'" artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002`

# Sources
- 来源列表：
  - `docs/traces/trace-phase-03-physical-iron-test-realmessageservice-001.md`
  - `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002/attempt-05.verify.real.json`
  - `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002/manual_repair_round6.verify.real.json`
  - `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002/manual_repair_round6_literalfix.verify.real.json`

# Known Gaps
- 当前空白：
  - 当前 Skill 只覆盖本轮已经被真实 `cjc` 咬出的高频语法坑；
  - 还未覆盖泛型约束、宏、trait、包导入、模块可见性等更深层仓颉语法问题；
  - 某些可空语法最终正确写法仍需以更多真实 `cjc` 样本继续校正。
