# 2026-03-26 前沿调研与 Skill 构建方案（V1）

## 1. 调研目标

本次调研聚焦两个问题：

1. 当前与本项目最相关的技术前沿是什么；
2. 基于现有资源，项目的 Skill / Agent / 验证体系应该如何落地。

本次调研不尝试直接给出最终 Skill 文件夹结构，而是优先回答：

- Skill 为什么会影响结果；
- 什么样的 Skill 结构才真正重要；
- 本项目第一阶段最应该搭哪一层能力；
- 当前哪些官方资源已经足够支撑小样本验证。

## 2. 核心结论

### 2.1 对“Skill 结构是否重要”的判断

结论是：**重要，但要分清“文件夹结构”和“知识结构”。**

- **文件夹结构** 不是最关键的，后续可以调整；
- **知识结构 / Skill schema** 非常关键，会直接影响：
  - 检索命中率；
  - Agent 是否能在合适时机调用正确知识；
  - 翻译后能否验证；
  - 后续维护成本；
  - 失败案例是否能回写成资产。

换句话说：

- 目录先简单一点没关系；
- 但 Skill 单元内部必须先有一套稳定 schema。

### 2.2 对项目当前最合适路线的判断

基于现有资源和前沿趋势，本项目当前最适合采用：

**“少量高质量手工 Skill + 仓库级检索 + 编译/运行反馈 + 轨迹回写”**

而不是：

- 一开始就做全量大文档 RAG；
- 一开始就固化庞大的 Skill 文件夹树；
- 一开始就直接翻译完整 Telegram 工程。

### 2.3 当前阶段最值得投入的资产

当前最值得建设的不是“尽可能多的 Skill 文件”，而是以下四类资产：

1. **Skill schema**：统一最小单元定义；
2. **高频场景 Skill**：优先做 UI、路由、状态、网络、构建、日志等高复用知识；
3. **小样本验证集**：能快速编译 / 运行 / 观察结果的 ArkTS Demo；
4. **轨迹与评测体系**：让每轮实验都能形成新资产。

## 3. 项目初始资源现状快照

### 3.1 ArkTS 小样本仓库：`applications_app_samples`

OpenHarmony 官方样例仓库当前仍是最适合本项目 Phase 1 / Phase 2 的起点之一。

从其 README 可见，该仓库提供了大量 **独立 DevEco Studio 工程**，覆盖 UI、网络、数据管理、日志、路由、分布式能力等多个主题，且每个样本可以单独导入、编译、运行、调试。

这对本项目非常重要，因为它意味着：

- 可以先在小体量工程里验证翻译；
- 可以按功能域构建 Skill，而不是直接面对超大工程；
- 每个样本都天然适合作为 Skill 验证靶子。

当前建议优先考虑以下四类样本：

1. **页面布局和连接**（`DefiningPageLayoutAndConnection`）
   - 价值：覆盖 `List`、`Grid`、`Tabs`、路由跳转、页面间数据传递；
   - 适合验证：`UI 组件 Skill`、`页面路由 Skill`、`数据模型映射 Skill`。

2. **首选项**（`Preferences`）
   - 价值：覆盖本地持久化、状态恢复、页面主题切换；
   - 适合验证：`状态与存储 Skill`。

3. **Http**（`Http`）
   - 价值：覆盖请求配置、参数传递、结果展示、权限声明；
   - 适合验证：`网络接口 Skill`、`权限与配置 Skill`。

4. **日志打印**（`Logger`）
   - 价值：覆盖日志输出、文件写入、hilog、性能提示；
   - 适合验证：`DFX / 诊断 Skill`、`运行日志回写模板`。

> 补充判断：`Chat` 样本更接近真实 IM 场景，但复杂度明显更高，更适合作为第二批桥接样本，而不是第一批最小验证样本。

### 3.2 Telegram ArkTS 版本：`TelegramHarmony`

`TelegramHarmony` 当前已经具备比较清晰的 ArkTS 工程结构，包括：

- 页面层（pages）；
- 视图模型层（viewmodel）；
- UI 组件层（components）；
- 应用状态层（app state）；
- 核心 models / services / mock 分层；
- 自研响应式框架 `SignalKit`；
- Service Locator 模式。

这说明后续真正的翻译难点不会只在 UI 组件语法，而会同时落在：

- 状态管理；
- 服务注入与模块边界；
- 协议层与业务模型；
- 多模块组织方式；
- 工程级依赖与构建。

因此，后续 Skill 设计必须覆盖的不只是“组件怎么写”，还要覆盖“工程怎么组织、状态怎么流动、依赖怎么切换、日志怎么留”。

### 3.3 仓颉官方文档与工具能力

从仓颉官方网站与官方文档可以确认，仓颉当前公开资料已经覆盖：

- 语言基础与工具链；
- 仓颉鸿蒙应用开发入门；
- C / Python 互操作相关能力；
- `cjc` 编译选项；
- `cjpm` 构建与测试命令；
- 覆盖率、PGO / profiling 等工具入口。

这意味着本项目的第一阶段不必等待“所有资料完美齐备”才能开始；只要能获取稳定的官方页面和少量样本，就足以建立首轮 Skill 与验证闭环。

## 4. 当前前沿趋势总结（与本项目最相关）

### 4.1 趋势一：代码 Agent 的关键不只是模型，而是“可执行接口”

`SWE-agent` 的核心启发是：在真实软件工程任务中，语言模型是否能成功，不只取决于模型本身，还取决于它能否通过合适的接口与代码仓库、终端命令、文件系统和反馈环境交互。

对本项目的启发：

- Skill 不应只是静态知识卡片；
- Skill 应尽量能指向可执行动作：查文档、查样例、运行构建、执行测试、读取日志；
- 对翻译任务来说，**可执行反馈** 比“长上下文提示词”更重要。

### 4.2 趋势二：复杂 Agent 不一定总优于分步可验证流程

`Agentless` 说明，多轮自治 Agent 并不是唯一正确方向；把任务拆成更稳定、可验证的步骤，往往更容易落地，也更容易诊断问题。

对本项目的启发：

- 不要过早构建一个“全自动翻译智能体”；
- 先把任务拆成：样本选择、上下文选择、翻译、编译、运行、修复、回写；
- 每一步都应该能单独记录和验证。

### 4.3 趋势三：仓库级检索优于盲目扩大上下文

`RepoCoder` 和后续仓库级代码生成研究表明，真实工程任务要成功，必须做 **repository-level retrieval**，也就是：

- 找到相关文件；
- 找到相关接口和模式；
- 在较小且高相关的上下文中完成生成；
- 结合新一轮检索继续修复。

对本项目的启发：

- 后续翻译 TelegramHarmony 时，不能只把整个仓库塞给模型；
- 需要做“局部上下文挑选”；
- Skill 应当帮助 Agent 判断“这次需要哪些文档、哪些样本、哪些仓库文件”。

### 4.4 趋势四：代码 RAG 只有在检索质量高时才真正有效

`CodeRAG-Bench` 的启发非常直接：对代码任务而言，RAG 不是天然有效，错误或低相关的检索上下文会明显拉低结果。

对本项目的启发：

- 不应把“文档全量向量化”当成自动成功；
- 应优先维护一批高置信度的核心 Skill；
- 检索层应作为补充，不应替代核心规范化知识；
- 检索结果要带来源、版本、场景标签，避免混用旧资料与不相关资料。

### 4.5 趋势五：执行反馈与自调试是代码翻译闭环中的关键能力

近年的 self-debugging / execution-feedback 研究都指向同一个事实：

- 代码生成一次成的概率有限；
- 编译错误、测试失败、运行时行为偏差，应该被当作一等输入；
- 生成、运行、修复、再次验证，是更可靠的闭环。

对本项目的启发：

- 翻译不是“生成一份代码就结束”；
- 编译日志、运行日志、页面结果和问题分类，必须进入 Skill 回写或实验复盘；
- 评测体系必须强调执行证据，而不是只看代码长得像不像。

## 5. 适合本项目的构建方案（V1）

#### 5.1 总体原则

建议采用：

- **schema 先行，目录后定**；
- **高频问题优先，长尾问题后补**；
- **少量高质量 Skill 优先于大量低质量 Skill**；
- **检索是补充，不是替代**；
- **执行反馈必须进入主流程**；
- **所有实验都要变成可复用资产**。

#### 5.2 四层能力架构

#### L0：规范层（先搭）

这是所有后续工作的地基，当前已经部分具备。

内容包括：

- 需求基线；
- 评测标准；
- 样本记录模板；
- 轨迹记录模板；
- Skill 最小 schema；
- 目录职责与来源记录约定。

#### L1：核心 Skill 层（第一阶段重点）

这一层只做 **20~40 个高复用、高价值 Skill 单元**，而不是一开始做全量库。

建议优先覆盖六类：

1. **语言与基础运行时**
   - 仓颉语法、模块、包管理、测试、构建、常见编译选项。

2. **ArkUI 组件与页面结构**
   - List、Grid、Tabs、页面路由、导航、页面生命周期、状态绑定。

3. **状态与数据管理**
   - preferences、本地数据、信号 / 状态流、主题切换、页面间状态传递。

4. **网络与系统能力**
   - http、socket、权限声明、异步调用、错误处理。

5. **构建、调试与 DFX**
   - DevEco、构建约束、hilog、文件日志、常见错误分类。

6. **翻译映射类 Skill**
   - ArkTS → 仓颉常见语法 / 组件 / 状态模式映射；
   - 常见反模式与降级策略；
   - “无法直译时”的替代实现建议。

#### L2：动态检索层（与 L1 并行建设）

这一层负责在核心 Skill 不够时补知识。

建议包含三类检索：

- **官方文档检索**：针对 docs_cangjie / 官方文档页面；
- **样例检索**：针对 applications_app_samples 中的相似示例；
- **仓库检索**：针对 TelegramHarmony / 后续目标工程的相关文件和模式。

这一层的重点不是“多”，而是“知道何时检索、检索什么、如何标注来源”。

#### L3：执行反馈与进化层（必须进入主链路）

这一层负责把生成结果与真实反馈连起来。

必须保留：

- 编译结果；
- 测试结果；
- 运行结果；
- 页面观察记录；
- 失败原因；
- 修复轮次；
- 回写结论。

这一层决定 Skill 是否会越用越好。

### 5.3 Skill 最小 schema 建议

建议先固定 Skill 单元的字段，而不要急着固定目录树。

每个 Skill 单元至少应包含：

- `id`
- `name`
- `domain`
- `scenario`
- `trigger`
- `core_facts`
- `translation_mapping`
- `examples`
- `verification`
- `fallback`
- `sources`
- `version_notes`
- `gaps`

#### 5.4 推荐的 Skill 单元粒度

推荐按“问题域”切，而不是按原始文档章节切。

好的粒度示例：

- `ui-list-grid-layout`
- `page-routing-and-param-passing`
- `preferences-state-persistence`
- `http-request-and-permission`
- `hilog-and-file-logger`
- `arkts-to-cangjie-state-mapping`

不推荐的粒度示例：

- `第 1 章-UI`
- `ArkTS 全量语法`
- `全部网络能力`

原因很简单：

- 太大了不利于检索；
- 太大了不利于验证；
- 太大了不利于增量迭代。

## 6. 样本路线建议

#### 6.1 第一批样本（建议 3~4 个）

建议按“一个样本覆盖一类核心能力”的思路选：

1. `DefiningPageLayoutAndConnection`
   - 验证 UI、路由、页面间数据传递。

2. `Preferences`
   - 验证状态与持久化。

3. `Http`
   - 验证网络请求、权限与参数配置。

4. `Logger`
   - 验证日志、诊断与运行反馈记录。

#### 6.2 第二批样本（桥接样本）

在第一批样本稳定后，再考虑：

- `Chat` 或更接近真实 IM 场景的样本；
- 带多模块依赖的样本；
- 带状态管理与复杂 UI 组合的样本。

#### 6.3 为什么不建议第一批直接上 TelegramHarmony

因为 TelegramHarmony 当前已经包含：

- 工程级结构；
- 协议实现；
- 依赖注入；
- 响应式框架；
- 多页面协同；
- 敏感配置依赖。

它更适合做 **Phase 3 的真实工程验证对象**，不适合做第一批最小样本。

## 7. 推荐实施步骤

### Step 1：先定 schema，不定最终目录

第一步产出：

- Skill 最小 schema；
- 样本记录模板；
- 轨迹记录模板；
- 样本选择表。

### Step 2：围绕第一批样本建立 20~40 个 Skill 单元

不要一开始追求全量覆盖，而是让每个 Skill 都能直接服务于样本验证。

### Step 3：打通翻译闭环

针对每个样本，固定流程：

- 输入分析；
- 选 Skill；
- 选补充资料；
- 翻译；
- 编译；
- 运行；
- 记录；
- 回写。

### Step 4：提炼失败模式

第一批样本结束后，应形成至少一版：

- 语法映射错误清单；
- UI / 路由 / 状态问题分类；
- 构建与工具链问题分类；
- Skill 缺口清单。

### Step 5：再进入 TelegramHarmony

只有在第一批样本形成稳定闭环之后，才建议进入 TelegramHarmony 的模块级翻译。

## 8. 风险与应对

### 8.1 风险：过度追求全量 Skill

应对：先限定为高频场景单元，优先做能被样本直接验证的内容。

### 8.2 风险：把 RAG 当成万能方案

应对：始终保留高置信度核心 Skill；检索结果必须标来源、标版本、标场景。

### 8.3 风险：只看生成代码，不看执行反馈

应对：把编译、测试、运行和日志都纳入主流程与评测标准。

### 8.4 风险：样本选择过难

应对：先从 `UI + 路由`、`持久化`、`网络`、`日志` 四类低复杂样本入手。

### 8.5 风险：文档与仓库资源版本混用

应对：所有外部来源必须记录访问时间、链接、版本或 commit 信息。

## 9. 下一步建议

基于这轮调研，最自然的下一步不是继续讨论大而全的 Skill 目录，而是直接做以下三件事：

1. **定义 Skill 最小 schema（V1）**；
2. **挑选第一批 3~4 个样本并建立样本记录模板**；
3. **建立轨迹记录模板与首轮评测表**。

如果这三件事完成，后续再讨论“最终 Skill 目录长什么样”，就会非常清晰。

## 10. 参考来源

### 官方与项目资源

- OpenHarmony ArkTS 样例仓库：
  - https://github.com/openharmony/applications_app_samples
- Telegram HarmonyOS ArkTS 工程：
  - https://github.com/ForestBook/TelegramHarmony
- 仓颉语言官网：
  - https://cangjie-lang.cn/
- 仓颉鸿蒙应用开发入门指南：
  - https://docs.cangjie-lang.cn/docs/0.53.18/guide/source_zh_cn/%E4%BB%93%E9%A2%89%E9%B8%BF%E8%92%99%E5%BA%94%E7%94%A8%E5%BC%80%E5%8F%91%E5%85%A5%E9%97%A8%E6%8C%87%E5%8D%97.html
- 仓颉用户手册（基础 / 工具 / 编译选项）：
  - https://docs.cangjie-lang.cn/cjnative/user_manual/source_zh_cn/first_understanding/basic.html
  - https://docs.cangjie-lang.cn/cjnative/user_manual/source_zh_cn/Appendix/compile_options.html
  - https://docs.cangjie-lang.cn/cjnative/user_manual/tools/source_zh_cn/tools/cjpm_manual_cjnative_community.html
- 你提供的 GitCode 参考入口：
  - https://gitcode.com/Cangjie-SIG/CangjieSkills
  - https://gitcode.com/openharmony/docs_cangjie
  - https://gitcode.com/openharmony/applications_app_samples

### 前沿论文 / 一手研究

- SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering
  - https://arxiv.org/abs/2405.15793
- Agentless: Demystifying LLM-based Software Engineering Agents
  - https://arxiv.org/abs/2407.01489
- RepoCoder: Repository-Level Code Completion Through Iterative Retrieval and Generation
  - https://arxiv.org/abs/2303.12570
- CodeRAG-Bench: Can Retrieval Augment Code Generation?
  - https://arxiv.org/abs/2406.14497
- Revisit Self-Debugging with Self-Generated Tests for Code Generation
  - https://arxiv.org/abs/2501.12793
- LeDex: Training LLMs to Better Self-Debug and Explain Code
  - https://arxiv.org/abs/2405.18649
