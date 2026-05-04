# RealMessageService 编译安全基线设计

## 背景

`RealMessageService` 的最新 Phase 03 实弹结果表明，链路已经能在部分轮次穿过 Reviewer，但仍不稳定地回退到静态墙，且穿过审查后的候选会卡在真实 `cjc` 的低层仓颉语法与类型问题上。

最新可复现的物理错误集中在以下几类：

- `Atomic<Int64>` 一类 Java / C# 并发原语幻觉；
- `null`、可选链、`map[key] ?? fallback` 等非仓颉安全写法；
- 对普通方法误加命名参数前缀；
- Service 骨架未稳定复用仓库里已经验证过的 `Option` / `match` / `HashMap.get` 语法基线。

当前目标不是让 `RealMessageService` 一步编译通过，而是把系统推到“稳定穿过审查，并稳定进入真实编译报错”的状态，使后续 repair 能围绕真实 `cjc` 证据继续收敛，而不是反复倒退到静态黑名单。

## 目标

本轮设计聚焦一个明确里程碑：

1. 让 `RealMessageService` 在新一轮自动试验中更稳定地进入 `review_passed=true`；
2. 让候选代码更稳定地落到真实 `compile-failed`，并把错误集中到更深层、可修复的仓颉问题；
3. 把已知可靠的编译安全写法沉淀到 Skill、Prompt 和 Pattern Memory，避免后续轮次再次回退到 `Atomic/null/named-args/optional-chaining` 这一层。

## 非目标

- 本轮不追求 `RealMessageService` 直接通过最终编译；
- 本轮不改 Orchestrator 的总体状态机，不引入新的预清洗器或代码重写器；
- 本轮不扩展到下一个 Telegram 模块；
- 本轮不尝试建立完整的仓颉项目级构建，只围绕单 TU 的真实编译验证推进。

## 方案对比

### 方案 A：只加静态黑名单

优点：实施快，能更早阻断明显坏模式。

缺点：只能“拦”，不能“教”；模型仍会在静态墙前反复碰撞，无法提升进入真实编译阶段的概率。

### 方案 B：补“编译安全基线”到 Skill + Prompt + Pattern Memory

优点：同时具备约束、示例和 few-shot 引导，能把模型往仓库中已经验证过的安全写法上拉；与当前 Phase 03 的目标最一致。

缺点：需要同时调整文档、Prompt 和经验库，改动面比单纯加黑名单稍大。

### 方案 C：引入更强硬的预清洗/硬模板

优点：短期命中率可能最高。

缺点：会把问题从“模型真实能力”转移到“后处理补丁”，不利于当前阶段积累可复用的翻译能力证据。

## 选定方案

采用方案 B。

## 设计细节

### 1. 新增编译安全 Skill

新增一个面向 Service 翻译的语法安全 Skill，专门覆盖当前最稳定复现的低层物理错误：

- 禁止 `Atomic` 幻觉；
- 禁止 `null`；
- 禁止普通方法调用时强加命名参数前缀；
- 禁止 `map[key] ?? fallback` 这类对非 `Option` 左值使用合并运算；
- 禁止对 `HashMap` 取值结果使用可选链；
- 推荐统一落到 `Option<T>`、`match`、`HashMap.get/add/remove` 和位置参数调用。

Skill 中直接引用仓库已有样本的安全风格，给出可复制的 Service 骨架。

### 2. Prompt 中的 Skill 摘要不再只吃前两个

当前 `PromptAssembler` 只截取前两个 Skill 摘要，这会导致后挂载的语法类 Skill 在长链试验里失效。

本轮把 Prompt 的 Architecture Skill 选择改为：

- 引入更高的摘要容量；
- 优先保留与“编译/语法/Option/null/named args”相关的 Skill；
- 再补充其它高优先级架构 Skill。

这样即使挂载的 Skill 超过两个，Translator / Reviewer 仍能看到编译安全基线。

### 3. 增补 curated Pattern Memory

新增一条人工整理的 compile-safe pattern，目标不是展示完整业务逻辑，而是提供 Service 级骨架：

- 使用纯领域模型；
- 使用 `HashMap.get` + `match` 处理缓存命中；
- Adapter 调用使用位置参数；
- 避免 `null`、可选链、`Atomic` 与 `ArrayList`。

该 pattern 通过 `service` 角色、风险标签和目标方法名与 `RealMessageService` 对齐，确保在 few-shot 检索时能被命中。

## 数据流

1. `pipeline_runner.py` / `orchestrator.py` 挂载新的 compile-safe Skill；
2. `PromptAssembler` 输出更完整、更偏向编译安全的 Skill 摘要；
3. `PatternMemoryEngine` 为 `RealMessageService` 检索到 curated compile-safe few-shot；
4. Translator 生成候选；
5. 静态墙与 Reviewer 过滤架构问题；
6. 候选进入真实 `cjc`；
7. 如果失败，则把更深层的仓颉物理错误回灌给下一轮 repair。

## 验证标准

本轮认为“有效推进”的判据是：

- 新一轮 `RealMessageService` 试验中，至少出现一轮 `review_passed=true`；
- 该轮进入真实 `compile-failed`，而不是在 `static-blacklist-failed` 被挡回；
- 编译错误不再包含本轮明确定义要消灭的低层幻觉（优先关注 `Atomic`、`null`、命名参数前缀、对非 `Option` 的 `??`、可选链）。

## 风险与缓解

### 风险 1：Prompt 变长导致信号稀释

缓解：不是无上限拼接，而是增加容量并按编译相关关键词做优先排序。

### 风险 2：curated Pattern 与 TU 不够相似，检索不到

缓解：对齐 `service` 角色、风险标签、方法名和 `RealMessageService` 的核心方法签名。

### 风险 3：单文件真实编译最终仍停在 `main is missing`

缓解：这类错误本轮视为“已稳定进入真实编译阶段”的可接受终点，不属于本轮失败。

