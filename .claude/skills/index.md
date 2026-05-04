# Skills Index

> 这是三层知识路由表，不是知识正文。
> 它负责把 Agent 从“当前问题”送到最合适的知识层与证据层。

---

## 1. Routing Priority

### L1：Kernel Knowledge
- 解决语言语法、标准库、`cjpm` / `cjc`、并发原语、CFFI 的定义问题
- 默认目录：`/.claude/skills/base-kernel/`
- 首个已准入样本：`/.claude/skills/base-kernel/option.md`

### L2：Harmony / Telegram Project Constraints
- 解决 Harmony / Telegram 翻译的项目级约束与推荐模板问题
- 默认目录：`skills/`

### L3：Real-time Pipeline Evidence
- 解决真实实验中到底发生了什么的问题
- 默认目录：`docs/traces/`、`docs/samples/`、`artifacts/pipeline_runs/`、`artifacts/pattern_memory/`

优先级：

`L3 真实证据 > L2 项目约束 > L1 一般知识`

## 2. Entry Modes

### Concept-first
默认路径：`L1 -> L2 -> L3`

### Failure-first
默认路径：`L3 -> L2 -> L1`

## 3. Bridge Rules

### Bridge A：L1 -> L2
“语言允许，不等于项目推荐；继续检查 L2 项目约束。”

### Bridge B：L2 -> L3
“项目模板已明确，继续检查 L3 是否已有真实成功或失败先例。”

### Bridge C：L3 -> L1
“现场失败已确认，回查 L1 判断是语法错误、版本差异还是示例失效。”

若 L3 证明 L1 示例已过期，必须打上 `[L3-DEPRECATED]`。

### Bridge D：L3 -> L2
“现场失败优先解释为项目级违约，先查 L2 的替代模板。”

## 4. High-value Routes

### Option
- 先去 L1 看 `/.claude/skills/base-kernel/option.md` 的 admission 结论
- 再去 L2 看项目当前是否允许把该语言特性带入 Harmony / Telegram 翻译
- 若 L3 后续实战与 admission 结论冲突，优先记录新证据并回写 `[L3-DEPRECATED]`

### ArrayList
- 先去 L1 看定义
- 再去 L2 看项目是否推荐
- 再去 L3 看真实实验里是否炸过

### Atomic
- 若是概念问题：L1 -> L2 -> L3
- 若是报错问题：L3 -> L1 -> L2

### static-blacklist-failed
- 直接走 `L3 -> L2 -> Repair`
- 不要先退回 L1 寻找保留理由

## 5. Stop Conditions

出现以下情况时，停止继续检索，开始修复：
- 已找到项目级模板与真实先例
- 报错属于已知黑名单类别
- L3 已存在高度相似失败记录
- 继续检索只会把问题从修复拖成百科漫游

## 6. Canonical Links

### L1 高频入口
- `/.claude/skills/base-kernel/option.md`

### L2 高频入口
- `skills/domain-purity-hard-template.md`
- `skills/protocol-adapter-extraction-strategy.md`
- `skills/anti-corruption-and-concurrency-strategy.md`
- `skills/acl-mapper-and-domain-genesis-strategy.md`
- `skills/main-thread-ui-boundary.md`
- `skills/state-ownership-and-lifecycle.md`
- `skills/signal-based-reactive-pipeline.md`
- `skills/tdlib-c-interop-bridge.md`

### L3 高频入口
- `docs/traces/`
- `docs/samples/`
- `artifacts/pipeline_runs/`
- `artifacts/pattern_memory/`
