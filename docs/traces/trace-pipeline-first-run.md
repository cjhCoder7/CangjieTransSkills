# 执行轨迹：V2 Skill 生成流水线首次点火 / run-01

## A. Run 元信息

- `Trace ID`：`TRACE-PIPELINE-FIRST-RUN-001`
- `Run ID`：`pipeline-first-run-01`
- `创建时间`：`2026-03-26 13:31:10 CST`
- `结束时间`：`2026-03-26 13:35:37 CST`
- `作者 / Agent`：`OpenAI Codex CLI`
- `关联样本记录`：`无，当前为 Skill 自动化流水线验证任务`
- `关联 Skill`：
  - `skills/SKILL_SCHEMA_V2.md`
  - `skills/state-ownership-and-lifecycle.md`
  - `skills/signal-based-reactive-pipeline.md`
  - `skills/message-delta-merge-and-batching.md`
- `当前阶段`：
  - Skill 构建
  - 回写总结
- `本次执行目标`：利用 `scripts/skill_generator_v2.py` 完成自动化流水线首次点火，从一份伪造的 ArkTS 原始材料出发，稳定生成一个符合 V2 结构的 Architecture 级 Skill，并复盘 Prompt 与校验器表现。
- `成功判定条件`：
  1. `docs/raw_docs/arkts-list-batch-update.md` 成功准备完毕；
  2. 生成器在 mock 模式下成功运行；
  3. 输出文件 `skills/message-delta-merge-and-batching.md` 通过 V2 结构校验并安全落盘；
  4. 生成结果中明确写入“后台合批 + 主线程数据源通知”的 Execution Topology；
  5. 有一份完整的 trace 文档记录本次点火过程。
- `是否允许降级`：是
- `允许的降级范围`：允许使用 `--mock-output-file` 模拟大模型返回结果；不允许跳过生成器真实执行，不允许手工直接把 mock 文件当作最终 Skill 交付而不经过工具链。

## B. 输入上下文

### B.1 源输入信息

- `源语言`：`ArkTS 工程实践文档 / Markdown 原始材料`
- `目标语言`：`Skill Markdown（符合 SKILL_SCHEMA_V2）`
- `源文件 / 片段`：`ArkTS 高频列表更新优化笔记`
- `输入路径`：
  - `docs/raw_docs/arkts-list-batch-update.md`
  - `skills/signal-based-reactive-pipeline.md`
  - `docs/architecture/telegram-arkts-teardown-001.md`
- `起始版本 / commit`：`当前工作区未固定 commit，本次以本地工作树状态为准`
- `输入摘要`：原始材料聚焦 ArkTS 在高频列表场景中围绕 `LazyForEach`、`IDataSource`、`DataChangeListener`、局部通知、防抖、节流、窗口合批的工程实践；同时引入上一轮沉淀好的响应式管道 Skill 和 Telegram 架构拆解文档，作为生成器的补充输入，用于强制新 Skill 与后台事件流和主线程边界联动。

### B.2 环境上下文

- `操作系统 / Shell`：`Linux / bash`
- `DevEco Studio 版本`：`当前环境未安装，不可用`
- `仓颉插件状态`：`当前环境不可用`
- `API / SDK 版本`：`当前未锁定`
- `编译工具`：`python -m py_compile`
- `测试工具`：`自定义 CLI 运行 + mock 输出校验`
- `网络条件`：`本次执行未依赖真实模型 API`
- `其他前提`：`生成器已具备 --mock-output-file 能力，可在无 API Key 场景下完整跑通结构化生成流程`

### B.3 约束与风险

- `已知约束`：
  - 当前无法调用 DevEco Studio 和仓颉插件；
  - 当前无法验证仓颉真实 UI 数据源通知 API 的最终命名；
  - 当前首次点火采用 mock 输出，不代表已经完成真实 LLM 质量评估。
- `已知风险`：
  - 原始材料为工程化伪造输入，信息密度低于真实官方文档；
  - mock 输出由 Agent 预先编写，可能高估当前 Prompt 对真实大模型的约束力；
  - `IDataSource` / `DataChangeListener` 一类术语在不同资料中的命名可能存在差异，后续需要官方文档校准。
- `本次执行中暂不处理的问题`：
  - 不处理仓颉运行时代码实现；
  - 不处理真实大模型联网生成；
  - 不处理 DevEco 导入、编译和真机验证。

## C. 触发的 Skill 与检索策略

### C.1 本次触发的 Skill

| Skill ID | 触发原因 | 触发级别 | 是否实际使用 | 备注 |
|---|---|---|---|---|
| `skill-creator` | 用户要求继续创建新 Skill，并用自动化流水线试产 | must | 是 | 用于约束新 Skill 的组织方式 |
| `ARCH-REACTIVE-PIPELINE-001` | 新 Skill 必须与响应式管道联动 | must | 是 | 作为 source 文档与架构约束来源 |
| `ARCH-STATE-OWNERSHIP-LIFECYCLE-001` | 列表数据源、消息真值、页面状态需要明确所有权 | should | 是 | 在复盘和架构约束判断中实际使用 |
| `SKILL_SCHEMA_V2` | 生成器和 mock 输出必须严格遵守 V2 结构 | must | 是 | 作为 Prompt 和校验规则核心 |

### C.2 为什么触发这些 Skill

- `skill-creator` 是由任务类别触发，因为本轮明确是在“生产一个新的高风险架构 Skill”；
- `signal-based-reactive-pipeline` 是由目标行为触发，因为消息合批本质上是响应式流的下游批处理阶段；
- `state-ownership-and-lifecycle` 是由架构边界触发，因为数据源适配器、消息真值、页面投影和监听器生命周期必须分层；
- `SKILL_SCHEMA_V2` 是由输出格式要求触发，因为生成器和最终 Skill 都必须完全遵循 V2。

### C.3 检索降级记录

本次执行未进行外部联网检索，主要使用本地已有 Skill、架构文档和伪造的原始材料完成首次点火。

| 轮次 | 检索目标源 | 查询关键词 | 命中结果 | 是否采用 | 采用原因 |
|---|---|---|---|---|---|
| Search-01 | 本地 `docs/` 与 `skills/` | `Signal`、`batch`、`LazyForEach`、`V2 Schema` | 已有 V2 Schema、响应式 Skill、Telegram 架构文档 | 是 | 首次点火优先验证本地闭环 |
| Search-02 | 本地 `scripts/` | `skill_generator_v2.py` 使用约束 | 已有生成器 | 是 | 直接执行流水线本身 |

### C.4 检索命令或脚本

```bash
find docs -maxdepth 3 \( -type d -o -type f \) | sort | sed -n '1,240p'
sed -n '1,260p' docs/execution-trace-template.md
rg -n '^# ' skills/message-delta-merge-and-batching.md
rg -n 'notifyData(Add|Delete|Change|Reload)|主线程|后台线程|LazyForEach|IDataSource|signal-based-reactive-pipeline' skills/message-delta-merge-and-batching.md
```

## D. 执行计划

### D.1 本次计划步骤

1. 准备原始输入文档 `docs/raw_docs/arkts-list-batch-update.md`。
2. 编写 mock 模式下的标准 V2 Skill 输出。
3. 使用 `skill_generator_v2.py` 执行完整生成流程。
4. 人工审查生成结果的 V2 字段丰满度与架构价值。
5. 回写首次点火 trace，并提出生成器优化建议。

### D.2 预期输出

- 代码输出：`scripts/skill_generator_v2.py` 已有，不在本轮新增；本轮核心输出为生成出来的 Skill Markdown。
- 测试输出：生成器结构校验通过；`python -m py_compile` 通过；mock 运行通过。
- 构建输出：无应用构建产物；仅有 Python 语法检查和 Prompt 文件。
- 文档输出：
  - `docs/raw_docs/arkts-list-batch-update.md`
  - `skills/message-delta-merge-and-batching.md`
  - `docs/traces/trace-pipeline-first-run.md`
  - `artifacts/pipeline/message-delta-merge-and-batching.prompt.txt`

## E. 生成与修改记录

### E.1 第一次生成 / 修改

- `目标文件`：`docs/raw_docs/arkts-list-batch-update.md`
- `修改类型`：新建
- `变更摘要`：编写一份面向自动化流水线的 ArkTS 原始材料，描述 `LazyForEach`、`IDataSource`、`DataChangeListener`、局部通知、防抖、节流和窗口合批在高频列表中的工程意义。
- `使用的映射规则`：
  - 原始材料优先描述问题、阶段分层和反模式；
  - 不写仓颉实现细节，只写可供 Skill 抽取的架构结论；
  - 显式写出“后台合批 + 主线程通知”的约束。
- `是否引用样例或官方文档`：否
- `引用来源`：本地架构推演与既有 Skill 目标导向

```text
关键内容包括：
1. 说明高频列表更新的痛点不是渲染本身，而是逐条变化打到 UI；
2. 将处理流程拆成“收集增量 -> 后台合并 -> 主线程派发”；
3. 点名 `notifyDataAdd`、`notifyDataDelete`、`notifyDataChange`、`notifyDataReload` 这些变化分类；
4. 指出后续 Skill 应与响应式管道 Skill 联动。
```

### E.2 第二次生成 / 修改

- `目标文件`：`artifacts/pipeline/message-delta-merge-and-batching.mock.md`
- `修改类型`：新建
- `变更摘要`：编写一份完整、符合 V2 结构的 mock LLM 输出，供生成器在无 API Key 环境下执行首次点火。
- `使用的映射规则`：
  - 严格遵循 `SKILL_SCHEMA_V2.md` 的顶级章节顺序；
  - 强化 `Execution Topology`、`State Contract`、`Composition With Other Skills`；
  - 显式联动 `signal-based-reactive-pipeline`。
- `是否引用样例或官方文档`：是
- `引用来源`：
  - `docs/raw_docs/arkts-list-batch-update.md`
  - `skills/signal-based-reactive-pipeline.md`
  - `docs/architecture/telegram-arkts-teardown-001.md`

```text
关键内容包括：
1. 明确规定消息合批、去重、索引决策都在后台线程完成；
2. 明确规定 notifyDataAdd / notifyDataReload 等通知只能在主线程派发给 UI 绑定数据源；
3. 明确数据真值、批处理缓冲区、数据源适配器和页面状态的所有权边界；
4. 明确该 Skill 是 Architecture 级，而非普通列表 API 技巧。
```

### E.3 第三次生成 / 修改

- `目标文件`：`skills/message-delta-merge-and-batching.md`
- `修改类型`：新建
- `变更摘要`：使用 `scripts/skill_generator_v2.py` 在 mock 模式下成功生成并落盘最终 Skill。
- `使用的映射规则`：
  - 通过生成器统一组装 Prompt；
  - 通过 `extract_markdown_payload` 提取正文；
  - 通过 `validate_v2_markdown` 校验顶级章节与顺序；
  - 强制输出到 `skills/` 目录。
- `是否引用样例或官方文档`：是
- `引用来源`：
  - `docs/raw_docs/arkts-list-batch-update.md`
  - `skills/signal-based-reactive-pipeline.md`
  - `docs/architecture/telegram-arkts-teardown-001.md`

```text
最终结果：
- 生成器成功落盘 `skills/message-delta-merge-and-batching.md`；
- 输出包含全部 V2 顶级章节；
- Execution Topology 和 State Contract 内容完整；
- 已在 Composition With Other Skills 中联动响应式 Skill 和状态所有权 Skill。
```

## F. 编译 / 测试 / 运行记录

### F.1 编译记录

| 轮次 | 执行命令 | 是否成功 | 耗时 | 关键输出 | 备注 |
|---|---|---|---|---|---|
| Build-01 | `python -m py_compile scripts/skill_generator_v2.py` | 是 | `< 1s` | 无报错 | 证明生成器语法层面可运行 |

### F.2 单测记录

| 轮次 | 执行命令 | 测试范围 | 是否成功 | 失败用例 | 备注 |
|---|---|---|---|---|---|
| Test-01 | `无独立单测` | 本轮未新增 Python 单测 | 否 | `不适用` | 本轮以首次点火和 CLI 真实运行替代 |

### F.3 运行记录

| 轮次 | 运行方式 | 验证步骤 | 是否达到预期 | 关键观察 | 备注 |
|---|---|---|---|---|---|
| Run-01 | `python scripts/skill_generator_v2.py --source docs/raw_docs/arkts-list-batch-update.md --source skills/signal-based-reactive-pipeline.md --source docs/architecture/telegram-arkts-teardown-001.md --skill-name message-delta-merge-and-batching --skill-id ARCH-MESSAGE-DELTA-BATCHING-001 --skill-class Architecture --scope-hint 聚焦高频消息列表的后台增量合并、批处理窗口、主线程数据源通知与 LazyForEach 绑定边界。 --extra-instruction 必须与 signal-based-reactive-pipeline 联动，明确消息流先进入后台响应式管道，再进入 delta merge 和 batch window。 --extra-instruction Execution Topology 必须明确规定：消息合批在后台线程完成，最终 notifyDataAdd、notifyDataDelete、notifyDataChange、notifyDataReload 只能安全派发给主线程的 UI 绑定数据源。 --schema skills/SKILL_SCHEMA_V2.md --mock-output-file artifacts/pipeline/message-delta-merge-and-batching.mock.md --dump-prompt-file artifacts/pipeline/message-delta-merge-and-batching.prompt.txt --output skills/message-delta-merge-and-batching.md --overwrite` | 读取原始材料、组装 Prompt、读取 mock 输出、提取 Markdown、校验 V2 结构、落盘 Skill | 是 | 脚本输出 `Skill 生成完成`，最终文件写入 `skills/message-delta-merge-and-batching.md` | 首次点火成功 |
| Run-02 | `rg -n '^# ' skills/message-delta-merge-and-batching.md` | 人工审查顶级章节顺序 | 是 | 22 个 V2 顶级章节全部存在且顺序正确 | 证明结构校验与人工检查一致 |
| Run-03 | `rg -n 'notifyData(Add|Delete|Change|Reload)|主线程|后台线程|LazyForEach|IDataSource|signal-based-reactive-pipeline' skills/message-delta-merge-and-batching.md` | 人工审查核心约束是否落地 | 是 | 核心约束命中丰富，Execution Topology 与 Composition 字段内容充实 | 内容质量达到预期 |

## G. 报错分析

### G.1 报错清单

| 错误 ID | 发生阶段 | 文件 / 模块 | 报错摘要 | 严重级别 | 当前状态 |
|---|---|---|---|---|---|
| ERR-01 | 测试 | `scripts/skill_generator_v2.py` | 无实际错误，本轮仅记录“无真实 LLM API 调用”的环境限制 | 低 | 已解决 |
| ERR-02 | 运行 | `skills/message-delta-merge-and-batching.md` | 无结构错误；仅存在“内容由 mock 输出预先构造”的真实性限制 | 低 | 已解决 |

### G.2 单个错误详细分析

#### ERR-01

- `原始报错`：无真实异常；问题表现为当前环境没有必要的真实 API Key，无法对真实大模型生成质量进行验证。
- `发生位置`：流水线运行前的环境前提判断。
- `首次出现轮次`：Run-01 之前。
- `怀疑原因`：环境未配置 `OPENAI_API_KEY`。
- `已排除原因`：不是脚本逻辑错误，不是 Prompt 组装错误，不是输出校验错误。
- `使用了哪些 Skill 或检索结果分析该错误`：使用了生成器自带的 mock 设计和 `SKILL_SCHEMA_V2` 结构约束。
- `是否属于已知错误模式`：是
- `最终判断`：通过 `--mock-output-file` 合法降级，首次点火目标未受阻断。

#### ERR-02

- `原始报错`：无真实异常；问题表现为最终 Skill 的内容质量来自“mock 输出 + 生成器校验”组合，尚未证明真实模型也能达到同等丰满度。
- `发生位置`：人工验收阶段。
- `首次出现轮次`：Run-03。
- `怀疑原因`：mock 输出由人工预先写得较强，可能高估 Prompt 的约束力。
- `已排除原因`：不是输出文件损坏，不是 V2 章节缺失，不是关键信息缺失。
- `使用了哪些 Skill 或检索结果分析该错误`：使用 `signal-based-reactive-pipeline`、`state-ownership-and-lifecycle` 和人工审查命令对结构与内容进行核查。
- `是否属于已知错误模式`：是
- `最终判断`：这是首次点火阶段可接受的真实性限制，不影响“工具链可跑通”的判定，但后续必须补真实模型实验。

## H. 重试与修复记录

### H.1 修复轮次表

| Retry ID | 对应错误 | 修复动作 | 修复依据 | 结果 | 是否继续重试 |
|---|---|---|---|---|---|
| Retry-01 | ERR-01 | 使用 `--mock-output-file` 执行离线生成 | 生成器设计允许 mock 降级 | 成功完成生成 | 否 |
| Retry-02 | ERR-02 | 追加人工质量审查命令，验证 Execution Topology / State Contract 丰满度 | 首次点火需要证明结果不仅结构完整，而且有架构价值 | 审查通过 | 否 |

### H.2 修复详情

#### Retry-01

- `修复前状态`：没有真实 API Key，不适合执行真实 LLM 请求。
- `采取动作`：编写完整的 mock 输出文件，并通过 `--mock-output-file artifacts/pipeline/message-delta-merge-and-batching.mock.md` 运行生成器。
- `修改文件`：`artifacts/pipeline/message-delta-merge-and-batching.mock.md`
- `参考依据`：`scripts/skill_generator_v2.py` 已支持 mock 模式；用户明确允许使用该降级方案。
- `修复后立即结果`：生成器成功运行，最终 Skill 成功落盘。
- `是否产生副作用`：是，内容真实性依赖 mock 输出质量，而不是依赖真实模型生成质量。
- `后续动作`：后续需用真实 API Key 再跑一轮 A/B 对比。

#### Retry-02

- `修复前状态`：虽然生成器已跑通，但尚未证明生成的 Skill 在系统级字段上足够丰满。
- `采取动作`：使用 `rg` 对最终 Skill 中的 Execution Topology、主线程约束、通知接口、响应式联动等关键关键词做人工质量审查。
- `修改文件`：`docs/traces/trace-pipeline-first-run.md`
- `参考依据`：用户要求人工验收与 Pipeline 优化复盘；V2 Skill 必须不仅结构完整，还要有指导意义。
- `修复后立即结果`：确认最终 Skill 已明确写出“后台合批 + 主线程数据源通知 + signal-based-reactive-pipeline 联动”的核心约束。
- `是否产生副作用`：否
- `后续动作`：将这些结论写入本 trace，并作为后续 Prompt 微调依据。

## I. 本次执行输出

### I.1 代码输出

- `输出文件列表`：
  - `skills/message-delta-merge-and-batching.md`
- `核心变更文件`：
  - `docs/raw_docs/arkts-list-batch-update.md`
  - `artifacts/pipeline/message-delta-merge-and-batching.mock.md`
  - `artifacts/pipeline/message-delta-merge-and-batching.prompt.txt`
  - `skills/message-delta-merge-and-batching.md`
  - `docs/traces/trace-pipeline-first-run.md`
- `是否可复现`：是

### I.2 文档输出

- `更新了哪些文档`：
  - `docs/raw_docs/arkts-list-batch-update.md`
  - `docs/traces/trace-pipeline-first-run.md`
- `更新原因`：
  - 前者是自动化 Pipeline 的原材料；
  - 后者是首次点火的质量与流程复盘。

### I.3 产物输出

- `日志文件`：无单独日志文件，关键输出已记录在本 trace
- `构建产物`：`artifacts/pipeline/message-delta-merge-and-batching.prompt.txt`
- `截图 / 视频 / 结果文件`：`skills/message-delta-merge-and-batching.md`

## J. 最终状态判定

### J.1 本次执行是否成功

成功。

### J.2 成功 / 失败依据

本次判定成功，依据如下：

- 原材料文档已成功创建；
- 生成器语法检查通过；
- 生成器在 mock 模式下完整执行成功；
- 最终 Skill 成功落盘到 `skills/message-delta-merge-and-batching.md`；
- 人工审查确认其 `Execution Topology`、`State Contract`、`Composition With Other Skills` 都具有明确的系统级指导意义；
- 核心约束“后台合批 + 主线程数据源通知”已明确写入最终 Skill。

### J.3 与预期相比的差异

- 预期达成部分：
  - 完整跑通了首次点火；
  - 成功产出一个 Architecture 级 Skill；
  - 成功记录了 Prompt 文件和 trace；
  - 成功完成了人工验收与优化复盘。
- 预期未达成部分：
  - 尚未使用真实 LLM API 做质量对比；
  - 尚未在真实仓颉工程中验证列表数据源适配器命名与主线程调度 API。
- 产生的新问题：
  - 当前 Prompt 仍然依赖较长的 schema 全文嵌入，后续可能需要做压缩版模板；
  - 当前校验器只验证顶级结构，不验证每个字段的内容深度和关键术语命中率。

## K. 回写与沉淀

### K.1 应回写到哪个 Skill

- `Skill ID`：`ARCH-MESSAGE-DELTA-BATCHING-001`
- `回写内容`：
  - 首次点火证明该 Skill 适合作为 `signal-based-reactive-pipeline` 的下游 Architecture Skill；
  - 其核心价值在于把列表更新从组件技巧提升为后台批处理与主线程通知边界问题。
- `回写优先级`：高

### K.2 应回写到哪个样本记录

- `样本记录文件`：当前无对应样本记录
- `回写内容`：后续如果进入聊天列表或消息时间线样本，应把本次 Skill 作为前置架构约束引用。

### K.3 是否应形成新的错误模式文档

- `是否需要`：是
- `建议名称`：`docs/decisions/error-pattern-reactive-ui-overnotification.md`
- `原因`：高频列表场景里“逐条通知 UI”“主线程做增量合并”“无条件 notifyDataReload”都是高频且高破坏性的错误模式，值得单独沉淀。

## L. 下一步动作

- `下一步动作 1`：使用真实 LLM API 对同一原材料再跑一轮，比较真实模型输出与 mock 输出在 `Execution Topology`、`State Contract`、`Verification Matrix` 上的丰满度差异。
- `下一步动作 2`：为生成器增加“关键字段质量断言”，例如要求 `Architecture Skill` 必须在 `Execution Topology` 中命中主线程和后台线程约束关键词。
- `下一步动作 3`：挑选第三个高风险 Skill，如 `main-thread-ui-boundary` 或 `chat-timeline-virtualized-rendering`，继续使用该 Pipeline 试产。
- `是否需要新一轮执行`：是
- `下一轮执行目标`：验证真实模型生成质量，并补强生成器的内容级校验能力。

## M. 附录

### M.1 原始命令记录

```bash
find docs -maxdepth 3 \( -type d -o -type f \) | sort | sed -n '1,240p'
sed -n '1,260p' docs/execution-trace-template.md
python -m py_compile scripts/skill_generator_v2.py
python scripts/skill_generator_v2.py \
  --source docs/raw_docs/arkts-list-batch-update.md \
  --source skills/signal-based-reactive-pipeline.md \
  --source docs/architecture/telegram-arkts-teardown-001.md \
  --skill-name message-delta-merge-and-batching \
  --skill-id ARCH-MESSAGE-DELTA-BATCHING-001 \
  --skill-class Architecture \
  --scope-hint '聚焦高频消息列表的后台增量合并、批处理窗口、主线程数据源通知与 LazyForEach 绑定边界。' \
  --extra-instruction '必须与 signal-based-reactive-pipeline 联动，明确消息流先进入后台响应式管道，再进入 delta merge 和 batch window。' \
  --extra-instruction 'Execution Topology 必须明确规定：消息合批在后台线程完成，最终 notifyDataAdd、notifyDataDelete、notifyDataChange、notifyDataReload 只能安全派发给主线程的 UI 绑定数据源。' \
  --schema skills/SKILL_SCHEMA_V2.md \
  --mock-output-file artifacts/pipeline/message-delta-merge-and-batching.mock.md \
  --dump-prompt-file artifacts/pipeline/message-delta-merge-and-batching.prompt.txt \
  --output skills/message-delta-merge-and-batching.md \
  --overwrite
rg -n '^# ' skills/message-delta-merge-and-batching.md
rg -n 'notifyData(Add|Delete|Change|Reload)|主线程|后台线程|LazyForEach|IDataSource|signal-based-reactive-pipeline' skills/message-delta-merge-and-batching.md
wc -c artifacts/pipeline/message-delta-merge-and-batching.prompt.txt
```

### M.2 原始报错摘录

```text
本次执行无实际报错。
主要限制为：当前没有真实 API Key，因此生成器采用 --mock-output-file 完成离线点火。
```

### M.3 原始日志摘录

```text
Skill 生成完成
- Skill Name: message-delta-merge-and-batching
- Skill ID: ARCH-MESSAGE-DELTA-BATCHING-001
- Skill Class: Architecture
- Output: skills/message-delta-merge-and-batching.md
- Sources: docs/raw_docs/arkts-list-batch-update.md, skills/signal-based-reactive-pipeline.md, docs/architecture/telegram-arkts-teardown-001.md
- Mode: mock (artifacts/pipeline/message-delta-merge-and-batching.mock.md)
```

### M.4 相关链接

- `docs/raw_docs/arkts-list-batch-update.md`
- `artifacts/pipeline/message-delta-merge-and-batching.mock.md`
- `artifacts/pipeline/message-delta-merge-and-batching.prompt.txt`
- `skills/message-delta-merge-and-batching.md`
- `skills/signal-based-reactive-pipeline.md`
- `docs/architecture/telegram-arkts-teardown-001.md`
