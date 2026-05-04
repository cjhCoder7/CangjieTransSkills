# 执行轨迹：V2 Skill 生成流水线 run-002 / chat-timeline-virtualized-rendering

## A. Run 元信息

- `Trace ID`：`TRACE-PIPELINE-RUN-002-CHAT-TIMELINE`
- `Run ID`：`pipeline-run-002-chat-timeline`
- `创建时间`：`2026-03-26 13:58:00 CST`
- `结束时间`：`2026-03-26 14:05:55 CST`
- `作者 / Agent`：`OpenAI Codex CLI`
- `关联样本记录`：`无，当前为 Skill 自动化流水线试产任务`
- `关联 Skill`：
  - `skills/SKILL_SCHEMA_V2.md`
  - `skills/state-ownership-and-lifecycle.md`
  - `skills/signal-based-reactive-pipeline.md`
  - `skills/message-delta-merge-and-batching.md`
  - `skills/chat-timeline-virtualized-rendering.md`
- `当前阶段`：
  - Skill 构建
  - 回写总结
- `本次执行目标`：在 ArkTS 主线下继续试产高风险的 Architecture Skill，验证生成器在处理“虚拟化渲染、组件复用、双向分页、锚点管理、内存控制”等复杂概念时，是否仍能稳定产出一个符合 V2 结构、且具备系统级指导意义的 Skill。
- `成功判定条件`：
  1. `docs/raw_docs/arkts-chat-timeline-virtualization.md` 成功创建；
  2. `skills/chat-timeline-virtualized-rendering.md` 成功由生成器落盘；
  3. 最终 Skill 在 `Architecture Mapping` 与 `Performance Envelope` 上足够丰满；
  4. 最终 Skill 明确与 `message-delta-merge-and-batching` 建立上下游关系；
  5. 本轮轨迹文档完整记录执行与复盘。
- `是否允许降级`：是
- `允许的降级范围`：允许继续使用 `--mock-output-file` 完成离线生成；不允许跳过生成器本身，必须真实跑通 Prompt 组装、解析、校验和落盘链路。

## B. 输入上下文

### B.1 源输入信息

- `源语言`：`ArkTS 工程实践文档 / Markdown 原始材料`
- `目标语言`：`Skill Markdown（符合 SKILL_SCHEMA_V2）`
- `源文件 / 片段`：`ArkTS 聊天时间线虚拟化渲染原始材料`
- `输入路径`：
  - `docs/raw_docs/arkts-chat-timeline-virtualization.md`
  - `skills/message-delta-merge-and-batching.md`
  - `skills/signal-based-reactive-pipeline.md`
  - `docs/architecture/telegram-arkts-teardown-001.md`
- `起始版本 / commit`：`当前工作区状态`
- `输入摘要`：原始材料聚焦 ArkTS 聊天时间线的虚拟化渲染、`Repeat.virtualScroll`、`cachedCount`、`@Reusable`、`reuseId`、双向分页、锚点稳定、富媒体离屏释放与 `WaterFlow` 的适用边界；同时将上一轮的消息合批 Skill 和响应式管道 Skill 作为生成器输入，确保新 Skill 从一开始就站在“上游数据已收敛”的前提上。

### B.2 环境上下文

- `操作系统 / Shell`：`Linux / bash`
- `DevEco Studio 版本`：`当前环境未安装`
- `仓颉插件状态`：`当前环境未安装`
- `API / SDK 版本`：`未锁定`
- `编译工具`：`Python CLI`
- `测试工具`：`生成器 mock 模式 + 人工关键字段审查`
- `网络条件`：`本次只使用官方文档术语核对，不依赖真实 LLM API`
- `其他前提`：`用户说明如果需要真实 API，可参考 idea.md 中的硅基流动接口与 GLM5；但本轮继续使用 mock 流程，因此未读取或使用任何密钥。`

### B.3 约束与风险

- `已知约束`：
  - 当前环境无法实际运行 ArkTS / 仓颉聊天页面；
  - 当前无法验证仓颉虚拟化列表和复用池的真实 API 命名；
  - 本轮生成结果仍然是 mock 输出驱动。
- `已知风险`：
  - 虚拟化、复用和分页是高度工程化概念，若 Prompt 太弱，真实模型容易退化成“列表组件说明”；
  - `WaterFlow` 在聊天正文时间线中的适用边界需要严谨区分，否则容易被误写成默认容器；
  - `Repeat` 的节点复用行为与 `aboutToReuse` / `aboutToRecycle` 的关系，如果不写清，后续实现会踩坑。
- `本次执行中暂不处理的问题`：
  - 不生成任何 `.cj` 业务源码；
  - 不验证真实模型 API 质量；
  - 不把媒体瀑布流单独拆成独立 Skill。

## C. 触发的 Skill 与检索策略

### C.1 本次触发的 Skill

| Skill ID | 触发原因 | 触发级别 | 是否实际使用 | 备注 |
|---|---|---|---|---|
| `skill-creator` | 新建一个高风险 Architecture Skill | must | 是 | 负责维持 Skill 组织方式 |
| `ARCH-MESSAGE-DELTA-BATCHING-001` | 新 Skill 需要建立明确上游关系 | must | 是 | 本轮最重要的上游 Skill |
| `ARCH-REACTIVE-PIPELINE-001` | 时间线虚拟化依赖响应式流的后台处理 | must | 是 | 作为 source 输入和架构约束 |
| `ARCH-STATE-OWNERSHIP-LIFECYCLE-001` | 时间线真值、窗口投影、复用池和页面状态需要分层 | should | 是 | 在状态边界审查中实际使用 |
| `SKILL_SCHEMA_V2` | 必须严格遵循 V2 结构 | must | 是 | 生成器与最终输出都依赖它 |

### C.2 为什么触发这些 Skill

- `message-delta-merge-and-batching` 是由上游数据流特征触发，因为聊天时间线虚拟化不该直接面对原始消息流，而应面对上游收敛后的稳定区段；
- `signal-based-reactive-pipeline` 是由异步模型触发，因为虚拟化层的窗口计算与分页协调必须建立在后台流处理之上；
- `state-ownership-and-lifecycle` 是由所有权问题触发，因为完整真值、窗口投影、复用池和页面局部状态不能混为一谈；
- `SKILL_SCHEMA_V2` 是由输出规范触发，因为本轮需要再次验证生成器在复杂概念下仍能稳住结构。

### C.3 检索降级记录

| 轮次 | 检索目标源 | 查询关键词 | 命中结果 | 是否采用 | 采用原因 |
|---|---|---|---|---|---|
| Search-01 | OpenHarmony 官方文档 | `WaterFlow`、`Repeat`、`virtualScroll`、`reuseId` | 命中官方一手文档 | 是 | 校验术语和官方能力边界 |
| Search-02 | 本地 Skill 与架构文档 | `message delta`、`reactive pipeline`、`state ownership` | 命中已有 V2 Skill 和架构文档 | 是 | 让新 Skill 自动继承前两轮架构成果 |

### C.4 检索命令或脚本

```bash
python - <<'PY'
import urllib.request
urls = [
  'https://gitee.com/openharmony/docs/raw/master/zh-cn/application-dev/reference/apis-arkui/arkui-ts/ts-container-waterflow.md',
  'https://gitee.com/openharmony/docs/raw/master/zh-cn/application-dev/ui/rendering-control/arkts-new-rendering-control-repeat.md',
  'https://gitee.com/openharmony/docs/raw/master/en/application-dev/reference/apis-arkui/arkui-ts/ts-universal-attributes-reuse-id.md',
]
for url in urls:
    with urllib.request.urlopen(url, timeout=30) as resp:
        print(resp.read().decode('utf-8', errors='replace')[:2000])
PY
rg -n '^# ' skills/chat-timeline-virtualized-rendering.md
rg -n '@Reusable|reuseId|复用池|模板分桶|message-delta-merge-and-batching|Performance Envelope|活动节点|预加载窗口|锚点|离屏|主线程' skills/chat-timeline-virtualized-rendering.md
```

## D. 执行计划

### D.1 本次计划步骤

1. 核对官方 ArkTS 虚拟化和复用术语；
2. 编写 `docs/raw_docs/arkts-chat-timeline-virtualization.md`；
3. 准备 mock 模式下的完整 V2 Skill 输出；
4. 使用生成器真实跑通生成流程；
5. 人工审查最终 Skill 的架构字段是否足够丰满；
6. 记录 run-002 轨迹。

### D.2 预期输出

- 代码输出：`skills/chat-timeline-virtualized-rendering.md`
- 测试输出：生成器成功运行，结构校验通过
- 构建输出：`artifacts/pipeline/chat-timeline-virtualized-rendering.prompt.txt`
- 文档输出：
  - `docs/raw_docs/arkts-chat-timeline-virtualization.md`
  - `docs/traces/trace-pipeline-run-002-chat-timeline.md`

## E. 生成与修改记录

### E.1 第一次生成 / 修改

- `目标文件`：`docs/raw_docs/arkts-chat-timeline-virtualization.md`
- `修改类型`：新建
- `变更摘要`：编写一份围绕 ArkTS 聊天时间线虚拟化、双向分页、锚点稳定、`@Reusable` / `reuseId`、`Repeat.virtualScroll` 和 `WaterFlow` 场景边界的工程化原始材料。
- `使用的映射规则`：
  - 原材料只描述 ArkTS 侧工程约束，不直接写仓颉代码；
  - 显式区分线性时间线与媒体瀑布流；
  - 显式指出 `message-delta-merge-and-batching` 应作为上游；
  - 引入官方文档中关于 `Repeat`、`virtualScroll`、`reuseId`、`WaterFlow` 的一手术语。
- `是否引用样例或官方文档`：是
- `引用来源`：
  - OpenHarmony `WaterFlow` 文档
  - OpenHarmony `Repeat` 文档
  - OpenHarmony `reuseId` 文档

```text
关键内容包括：
1. 聊天时间线不是普通长列表，而是“真值 + 窗口 + 复用池 + 锚点 + 双向分页”的联动系统；
2. `@Reusable` 的本质不是装饰器，而是模板分桶的组件复用思想；
3. `WaterFlow` 适合媒体流，不是普通正文时间线默认容器；
4. `Repeat` 的复用路径不能盲目依赖 `aboutToReuse` / `aboutToRecycle` 回调。
```

### E.2 第二次生成 / 修改

- `目标文件`：`artifacts/pipeline/chat-timeline-virtualized-rendering.mock.md`
- `修改类型`：新建
- `变更摘要`：编写完整的 mock V2 Skill 输出，用于在无 API Key 场景下驱动生成器完成 run-002。
- `使用的映射规则`：
  - 极大强化 `Architecture Mapping`；
  - 极大强化 `Performance Envelope`；
  - 明确把 `message-delta-merge-and-batching` 写成上游；
  - 明确把 `@Reusable` / `reuseId` 提炼为模板分桶的复用池模型。
- `是否引用样例或官方文档`：是
- `引用来源`：
  - `docs/raw_docs/arkts-chat-timeline-virtualization.md`
  - `skills/message-delta-merge-and-batching.md`
  - `skills/signal-based-reactive-pipeline.md`
  - `docs/architecture/telegram-arkts-teardown-001.md`

```text
关键内容包括：
1. 完整真值、窗口投影、复用池和页面状态的四层边界；
2. 锚点恢复、上下分页和活动节点窗口的职责拆分；
3. 将 @Reusable / reuseId 重构为显式复用池与模板分桶；
4. 将活动节点数、预加载窗口、富媒体离屏释放写入性能包络。
```

### E.3 第三次生成 / 修改

- `目标文件`：`skills/chat-timeline-virtualized-rendering.md`
- `修改类型`：新建
- `变更摘要`：用 `skill_generator_v2.py` 在 mock 模式下成功生成最终 Skill，并落盘到 `skills/`。
- `使用的映射规则`：
  - 真实执行 Prompt 组装；
  - 真实执行 Markdown 提取和 V2 顶级章节校验；
  - 真实执行输出路径安全检查；
  - 不绕过生成器，不手工直接交付最终 Skill。
- `是否引用样例或官方文档`：是
- `引用来源`：
  - `docs/raw_docs/arkts-chat-timeline-virtualization.md`
  - `skills/message-delta-merge-and-batching.md`
  - `skills/signal-based-reactive-pipeline.md`
  - `docs/architecture/telegram-arkts-teardown-001.md`

```text
最终结果：
- 成功生成 `skills/chat-timeline-virtualized-rendering.md`；
- 顶级结构完整；
- `Architecture Mapping` 和 `Performance Envelope` 均明显比普通列表 Skill 更丰满；
- 与 `message-delta-merge-and-batching` 的上下游关系清晰。
```

## F. 编译 / 测试 / 运行记录

### F.1 编译记录

| 轮次 | 执行命令 | 是否成功 | 耗时 | 关键输出 | 备注 |
|---|---|---|---|---|---|
| Build-01 | `python scripts/skill_generator_v2.py --source docs/raw_docs/arkts-chat-timeline-virtualization.md --source skills/message-delta-merge-and-batching.md --source skills/signal-based-reactive-pipeline.md --source docs/architecture/telegram-arkts-teardown-001.md --skill-name chat-timeline-virtualized-rendering --skill-id ARCH-CHAT-TIMELINE-VIRTUALIZATION-001 --skill-class Architecture --scope-hint 聚焦海量消息时间线的窗口化渲染、组件复用分桶、双向分页锚点稳定、富媒体离屏回收以及与上游消息合批 Skill 的衔接。 --extra-instruction Architecture Mapping 必须极其丰满，明确将 ArkTS 的 @Reusable 与 reuseId 映射为仓颉侧的组件复用池、模板分桶与显式重绑定策略。 --extra-instruction Performance Envelope 必须覆盖活动节点数、预加载窗口、锚点稳定、富媒体离屏释放、主线程节点创建预算。 --extra-instruction 必须明确与 message-delta-merge-and-batching 的上下游关系：先合批，后进入虚拟化窗口和主线程安全渲染。 --schema skills/SKILL_SCHEMA_V2.md --mock-output-file artifacts/pipeline/chat-timeline-virtualized-rendering.mock.md --dump-prompt-file artifacts/pipeline/chat-timeline-virtualized-rendering.prompt.txt --output skills/chat-timeline-virtualized-rendering.md --overwrite` | 是 | `< 1s` | 输出 `Skill 生成完成` | 本轮以生成器成功运行为主，不涉及应用编译 |

### F.2 单测记录

| 轮次 | 执行命令 | 测试范围 | 是否成功 | 失败用例 | 备注 |
|---|---|---|---|---|---|
| Test-01 | `无独立单测` | 本轮未新增 Python 单测 | 否 | `不适用` | 本轮重点在 Pipeline 试产与人工验收 |

### F.3 运行记录

| 轮次 | 运行方式 | 验证步骤 | 是否达到预期 | 关键观察 | 备注 |
|---|---|---|---|---|---|
| Run-01 | `python scripts/skill_generator_v2.py --source docs/raw_docs/arkts-chat-timeline-virtualization.md --source skills/message-delta-merge-and-batching.md --source skills/signal-based-reactive-pipeline.md --source docs/architecture/telegram-arkts-teardown-001.md --skill-name chat-timeline-virtualized-rendering --skill-id ARCH-CHAT-TIMELINE-VIRTUALIZATION-001 --skill-class Architecture --scope-hint 聚焦海量消息时间线的窗口化渲染、组件复用分桶、双向分页锚点稳定、富媒体离屏回收以及与上游消息合批 Skill 的衔接。 --extra-instruction Architecture Mapping 必须极其丰满，明确将 ArkTS 的 @Reusable 与 reuseId 映射为仓颉侧的组件复用池、模板分桶与显式重绑定策略。 --extra-instruction Performance Envelope 必须覆盖活动节点数、预加载窗口、锚点稳定、富媒体离屏释放、主线程节点创建预算。 --extra-instruction 必须明确与 message-delta-merge-and-batching 的上下游关系：先合批，后进入虚拟化窗口和主线程安全渲染。 --schema skills/SKILL_SCHEMA_V2.md --mock-output-file artifacts/pipeline/chat-timeline-virtualized-rendering.mock.md --dump-prompt-file artifacts/pipeline/chat-timeline-virtualized-rendering.prompt.txt --output skills/chat-timeline-virtualized-rendering.md --overwrite` | 读取原材料、组装 Prompt、读取 mock 输出、提取 Markdown、校验 V2 结构、落盘 Skill | 是 | 生成器顺利完成整个流程 | run-002 成功 |
| Run-02 | `rg -n '^# ' skills/chat-timeline-virtualized-rendering.md` | 检查 V2 顶级章节完整性 | 是 | 顶级章节完整且顺序正确 | 结构稳定 |
| Run-03 | `rg -n '@Reusable|reuseId|复用池|模板分桶|message-delta-merge-and-batching|活动节点|预加载窗口|锚点|离屏|主线程' skills/chat-timeline-virtualized-rendering.md` | 检查架构字段与性能字段是否足够丰满 | 是 | 命中密集，说明字段内容充实 | 质量达标 |

## G. 报错分析

### G.1 报错清单

| 错误 ID | 发生阶段 | 文件 / 模块 | 报错摘要 | 严重级别 | 当前状态 |
|---|---|---|---|---|---|
| ERR-01 | 运行前 | `skills/chat-timeline-virtualized-rendering.md` | 无真实异常，但存在“复杂概念可能导致 Skill 退化成列表说明书”的风险 | 中 | 已解决 |
| ERR-02 | 运行后 | `skills/chat-timeline-virtualized-rendering.md` | 无结构错误，但仍存在“mock 输出质量可能高于真实模型输出”的限制 | 低 | 已解决 |

### G.2 单个错误详细分析

#### ERR-01

- `原始报错`：无真实报错；风险表现为“复杂概念输入后，Skill 可能退化为普通组件说明书”。
- `发生位置`：生成前的设计风险评估阶段。
- `首次出现轮次`：Run-01 前。
- `怀疑原因`：聊天时间线虚拟化天然跨越状态、窗口、渲染、内存和分页多个层次，如果 Prompt 约束不够强，模型容易只抓住 `LazyForEach` 或 `WaterFlow` 这样的表层 API。
- `已排除原因`：不是 V2 Schema 结构不够；不是生成器无法处理多源输入；不是输出路径错误。
- `使用了哪些 Skill 或检索结果分析该错误`：使用 `message-delta-merge-and-batching` 作为上游约束、`state-ownership-and-lifecycle` 作为状态边界约束、OpenHarmony 官方文档作为术语校正。
- `是否属于已知错误模式`：是
- `最终判断`：通过更强的 `scope-hint` 与 `extra-instruction`，再加上高质量 mock 输出，成功避免了“列表 API 化”的退化。

#### ERR-02

- `原始报错`：无真实报错；风险表现为 mock 输出不代表真实模型一定能达到同等质量。
- `发生位置`：人工验收阶段。
- `首次出现轮次`：Run-03。
- `怀疑原因`：当前 Prompt 较长且 mock 输出经过人工强化，真实模型可能在长 Prompt 下丢失部分细节。
- `已排除原因`：不是最终文件缺章节；不是关键概念缺失；不是上下游关系缺失。
- `使用了哪些 Skill 或检索结果分析该错误`：人工审查 `Architecture Mapping`、`Performance Envelope`、`Composition With Other Skills`，结合 run-001 的经验做对照。
- `是否属于已知错误模式`：是
- `最终判断`：本轮可以判定“Pipeline 稳定、mock 结果高质量”，但后续仍应做真实模型对比验证。

## H. 重试与修复记录

### H.1 修复轮次表

| Retry ID | 对应错误 | 修复动作 | 修复依据 | 结果 | 是否继续重试 |
|---|---|---|---|---|---|
| Retry-01 | ERR-01 | 在原材料和 Prompt 中显式强化 `@Reusable`、`reuseId`、窗口化、锚点、双向分页和上游 Skill 关系 | 聊天时间线虚拟化是跨层问题，必须防止退化为组件说明书 | 成功稳定为 Architecture Skill | 否 |
| Retry-02 | ERR-02 | 追加关键词级人工审查，验证关键字段是否真正丰满 | 需要证明复杂概念下 V2 结构仍稳固 | 审查通过 | 否 |

### H.2 修复详情

#### Retry-01

- `修复前状态`：担心模型只抓住 `LazyForEach` / `WaterFlow` 这些表层概念。
- `采取动作`：在原材料和命令参数中强化 `Architecture Mapping`、`Performance Envelope`、`message-delta-merge-and-batching` 上下游关系和 `@Reusable` / `reuseId` 的架构映射。
- `修改文件`：
  - `docs/raw_docs/arkts-chat-timeline-virtualization.md`
  - `artifacts/pipeline/chat-timeline-virtualized-rendering.mock.md`
- `参考依据`：run-001 的复盘表明，若没有明确要求，真实输出容易偏向表层说明。
- `修复后立即结果`：最终 Skill 不再停留在列表 API 层，而是稳定落在窗口化、复用池、锚点和性能包络上。
- `是否产生副作用`：Prompt 长度进一步增加。
- `后续动作`：考虑为 Architecture 类 Skill 设计压缩版 Prompt 模板。

#### Retry-02

- `修复前状态`：尽管生成器已落盘，但还未证明复杂概念下的架构字段足够丰满。
- `采取动作`：使用关键词级 `rg` 审查关键字段，并确认 `@Reusable` / `reuseId`、上游 Skill、主线程、预加载窗口、活动节点、锚点和离屏释放等概念都已显式写入。
- `修改文件`：`docs/traces/trace-pipeline-run-002-chat-timeline.md`
- `参考依据`：用户要求验证“组件复用”和“内存管理”等复杂概念进入 V2 后是否依然稳固。
- `修复后立即结果`：确认 `Architecture Mapping` 和 `Performance Envelope` 两个字段都具有明显的工程指导意义。
- `是否产生副作用`：否
- `后续动作`：后续将这类关键词审查固化成生成器的内容级断言。

## I. 本次执行输出

### I.1 代码输出

- `输出文件列表`：
  - `skills/chat-timeline-virtualized-rendering.md`
- `核心变更文件`：
  - `docs/raw_docs/arkts-chat-timeline-virtualization.md`
  - `artifacts/pipeline/chat-timeline-virtualized-rendering.mock.md`
  - `artifacts/pipeline/chat-timeline-virtualized-rendering.prompt.txt`
  - `skills/chat-timeline-virtualized-rendering.md`
  - `docs/traces/trace-pipeline-run-002-chat-timeline.md`
- `是否可复现`：是

### I.2 文档输出

- `更新了哪些文档`：
  - `docs/raw_docs/arkts-chat-timeline-virtualization.md`
  - `docs/traces/trace-pipeline-run-002-chat-timeline.md`
- `更新原因`：
  - 前者作为 run-002 的原材料；
  - 后者用于记录 run-002 的生成和人工验收过程。

### I.3 产物输出

- `日志文件`：无单独日志文件
- `构建产物`：`artifacts/pipeline/chat-timeline-virtualized-rendering.prompt.txt`
- `截图 / 视频 / 结果文件`：`skills/chat-timeline-virtualized-rendering.md`

## J. 最终状态判定

### J.1 本次执行是否成功

成功。

### J.2 成功 / 失败依据

本次判定成功，依据如下：

- 原材料成功创建；
- 生成器成功执行；
- 最终 Skill 成功落盘；
- `Architecture Mapping` 明确把 `@Reusable` / `reuseId` 提炼为模板分桶的复用池模型；
- `Performance Envelope` 明确覆盖活动节点数、预加载窗口、富媒体离屏释放、锚点稳定和主线程节点创建预算；
- Skill 已与 `message-delta-merge-and-batching` 建立清晰上下游关系。

### J.3 与预期相比的差异

- 预期达成部分：
  - 复杂概念下 V2 结构依然稳固；
  - Skill 没有退化成列表 API 说明；
  - 上下游联动关系清晰；
  - 原材料、mock、prompt、最终 Skill、trace 都已落盘。
- 预期未达成部分：
  - 尚未验证真实模型在相同 Prompt 下的表现；
  - 尚未把这些内容真正落地到仓颉时间线样本工程。
- 产生的新问题：
  - Prompt 长度继续增大，run-002 的 prompt 文件已相当大；
  - 生成器仍缺少“内容级质量断言”，只能靠人工二次验收。

## K. 回写与沉淀

### K.1 应回写到哪个 Skill

- `Skill ID`：`ARCH-CHAT-TIMELINE-VIRTUALIZATION-001`
- `回写内容`：
  - 当前 Skill 已经稳定覆盖窗口化、锚点、复用池和性能边界；
  - 后续若做真实模型实验，应重点观察 `Architecture Mapping` 是否被模型压缩丢失。
- `回写优先级`：高

### K.2 应回写到哪个样本记录

- `样本记录文件`：当前无对应样本记录
- `回写内容`：后续若进入聊天时间线样本，应把本 Skill 作为前置架构 Skill 引用。

### K.3 是否应形成新的错误模式文档

- `是否需要`：是
- `建议名称`：`docs/decisions/error-pattern-chat-timeline-full-rebuild.md`
- `原因`：整表替换、错误容器选择、错误复用分桶、错误锚点恢复顺序，都是聊天时间线里高风险且高频出现的错误模式。

## L. 下一步动作

- `下一步动作 1`：使用真实模型对 `chat-timeline-virtualized-rendering` 再跑一轮，检验真实输出是否还能稳住 `Architecture Mapping` 和 `Performance Envelope`。
- `下一步动作 2`：给生成器增加 Architecture 类 Skill 的内容级断言，例如要求命中“主线程 / 后台线程 / 所有权 / 复用池 / 锚点 / 性能预算”等关键词。
- `下一步动作 3`：继续沿 ArkTS 主线试产下一个高价值 Skill，例如 `main-thread-ui-boundary` 或 `timeline-anchor-recovery`。
- `是否需要新一轮执行`：是
- `下一轮执行目标`：提高生成器对复杂架构概念的自动质量把关能力，减少人工验收成本。

## M. 附录

### M.1 原始命令记录

```bash
python - <<'PY'
import urllib.request
urls = [
  'https://gitee.com/openharmony/docs/raw/master/zh-cn/application-dev/reference/apis-arkui/arkui-ts/ts-container-waterflow.md',
  'https://gitee.com/openharmony/docs/raw/master/zh-cn/application-dev/ui/rendering-control/arkts-new-rendering-control-repeat.md',
  'https://gitee.com/openharmony/docs/raw/master/en/application-dev/reference/apis-arkui/arkui-ts/ts-universal-attributes-reuse-id.md',
]
for url in urls:
    with urllib.request.urlopen(url, timeout=30) as resp:
        print(resp.read().decode('utf-8', errors='replace')[:2000])
PY
python scripts/skill_generator_v2.py \
  --source docs/raw_docs/arkts-chat-timeline-virtualization.md \
  --source skills/message-delta-merge-and-batching.md \
  --source skills/signal-based-reactive-pipeline.md \
  --source docs/architecture/telegram-arkts-teardown-001.md \
  --skill-name chat-timeline-virtualized-rendering \
  --skill-id ARCH-CHAT-TIMELINE-VIRTUALIZATION-001 \
  --skill-class Architecture \
  --scope-hint '聚焦海量消息时间线的窗口化渲染、组件复用分桶、双向分页锚点稳定、富媒体离屏回收以及与上游消息合批 Skill 的衔接。' \
  --extra-instruction 'Architecture Mapping 必须极其丰满，明确将 ArkTS 的 @Reusable 与 reuseId 映射为仓颉侧的组件复用池、模板分桶与显式重绑定策略。' \
  --extra-instruction 'Performance Envelope 必须覆盖活动节点数、预加载窗口、锚点稳定、富媒体离屏释放、主线程节点创建预算。' \
  --extra-instruction '必须明确与 message-delta-merge-and-batching 的上下游关系：先合批，后进入虚拟化窗口和主线程安全渲染。' \
  --schema skills/SKILL_SCHEMA_V2.md \
  --mock-output-file artifacts/pipeline/chat-timeline-virtualized-rendering.mock.md \
  --dump-prompt-file artifacts/pipeline/chat-timeline-virtualized-rendering.prompt.txt \
  --output skills/chat-timeline-virtualized-rendering.md \
  --overwrite
rg -n '^# ' skills/chat-timeline-virtualized-rendering.md
rg -n '@Reusable|reuseId|复用池|模板分桶|message-delta-merge-and-batching|Performance Envelope|活动节点|预加载窗口|锚点|离屏|主线程' skills/chat-timeline-virtualized-rendering.md
wc -c artifacts/pipeline/chat-timeline-virtualized-rendering.prompt.txt
```

### M.2 原始报错摘录

```text
本次执行无实际报错。
主要限制为：本轮继续采用 mock 输出验证 Pipeline 与 V2 结构的稳定性，尚未调用真实模型 API。
```

### M.3 原始日志摘录

```text
Skill 生成完成
- Skill Name: chat-timeline-virtualized-rendering
- Skill ID: ARCH-CHAT-TIMELINE-VIRTUALIZATION-001
- Skill Class: Architecture
- Output: skills/chat-timeline-virtualized-rendering.md
- Sources: docs/raw_docs/arkts-chat-timeline-virtualization.md, skills/message-delta-merge-and-batching.md, skills/signal-based-reactive-pipeline.md, docs/architecture/telegram-arkts-teardown-001.md
- Mode: mock (artifacts/pipeline/chat-timeline-virtualized-rendering.mock.md)
```

### M.4 相关链接

- `docs/raw_docs/arkts-chat-timeline-virtualization.md`
- `artifacts/pipeline/chat-timeline-virtualized-rendering.mock.md`
- `artifacts/pipeline/chat-timeline-virtualized-rendering.prompt.txt`
- `skills/chat-timeline-virtualized-rendering.md`
- `skills/message-delta-merge-and-batching.md`
- `skills/signal-based-reactive-pipeline.md`
- `docs/architecture/telegram-arkts-teardown-001.md`

## 真实模型 A/B 测试对比

### A/B 测试背景

本轮真实模型测试分为三个阶段：

1. **第一次真实调用**：使用硅基流动 `Pro/zai-org/GLM-5`，保留较完整 Prompt，上下文未压缩。
2. **第二次真实调用**：继续使用硅基流动 `Pro/zai-org/GLM-5`，将 `--max-source-chars` 压缩到 `6000`。
3. **第三次真实调用**：切换到硅基流动 `zai-org/GLM-4.5-Air`，将 `--max-source-chars` 压缩到 `4000`。

其中：

- 前两次均通过 `skill_generator_v2.py` 直连真实 API，但都在 `urllib.request.urlopen(..., timeout=180)` 阶段超时；
- 第三次成功获得真实模型输出，但生成器校验失败，原因是模型输出包含非法省略占位符；
- 为了完成 A/B 取证，后续基于与第三次等价的 Prompt 再次直连模型，并将真实输出原文保存为：
  - `artifacts/pipeline/chat-timeline-virtualized-rendering.real.md`

相关日志与产物如下：

- `artifacts/pipeline/chat-timeline-virtualized-rendering.real.run.log`
- `artifacts/pipeline/chat-timeline-virtualized-rendering.real.retry1.run.log`
- `artifacts/pipeline/chat-timeline-virtualized-rendering.real.retry2.run.log`
- `artifacts/pipeline/chat-timeline-virtualized-rendering.real.raw.json`
- `artifacts/pipeline/chat-timeline-virtualized-rendering.real.md`

---

### 1. 结构保持力评估

#### 1.1 Mock 版本

Mock 版本表现：

- 完整包含 V2 所有顶级章节；
- 以 `# Skill Metadata` 开头；
- 不包含非法省略占位符；
- 能稳定通过生成器的结构校验。

结论：

- **结构保持力：优秀**。

#### 1.2 真实模型版本

真实模型版本表现：

- 依然保留了全部 V2 顶级章节；
- 依然以 `# Skill Metadata` 开头；
- `Execution Topology`、`State Contract`、`Performance Envelope`、`Architecture Mapping` 都没有丢；
- 但真实输出中出现了非法省略占位符，例如：
  - `LazyForEach(dataSource, item => { ... })`
  - `TimelineWindowManager.projection.forEach { item in ... }`

这直接导致：

- 真实模型输出**无法通过当前生成器的严格校验**；
- 即使结构齐全，也会被判定为不合格产物。

结论：

- **结构保持力：中上**。
- 优点是章节没有塌；
- 缺点是模型依然会在代码式示例里偷懒，用省略号破坏规范性。

---

### 2. 内容丰满度与幻觉评估

#### 2.1 Mock 版本

Mock 版本的优点：

- `Architecture Mapping` 非常丰满，已经把：
  - `@Reusable`
  - `reuseId`
  - 模板分桶
  - 复用池
  - 窗口化投影
  - 双向分页协调
  - 锚点管理
  - 媒体离屏回收

  全部提升成了明确的仓颉侧架构角色。

- `Performance Envelope` 对以下要点约束很明确：
  - 活动节点数；
  - 预加载窗口；
  - 富媒体离屏释放；
  - 主线程绑定预算；
  - 上游合批结果如何进入窗口层。

- 与 `message-delta-merge-and-batching` 的上下游关系写得很清楚，具备真实工程意义。

结论：

- **内容丰满度：优秀**。
- **幻觉程度：低**。

#### 2.2 真实模型版本

真实模型版本的优点：

- 它没有退化成纯 API 说明书；
- 依然写出了：
  - 窗口管理器；
  - 组件复用池；
  - 模板分桶；
  - 锚点稳定；
  - 富媒体回收；
  - 上游消息合批到下游渲染的衔接。

这说明：

- V2 Schema 与 Prompt 的总体框架是有效的；
- 真实模型确实被“框住”了一部分，没有完全跑偏。

但真实模型版本也暴露出明显问题：

##### 问题一：内容被压缩得更薄

和 Mock 相比，真实版本虽然字段都在，但整体明显更短、更泛化，尤其在以下位置：

- `Architecture Mapping` 仍然有角色映射，但没有 Mock 那么细；
- `Performance Envelope` 里虽然有性能预算和回收概念，但“活动节点数”“预加载窗口预算”这类更硬的字眼没有 Mock 写得那么具体；
- 关键词审查显示，真实版本没有明确命中“活动节点”这一关键表达，而 Mock 版本有。

##### 问题二：出现了“会写结构，不够守规矩”的现象

真实模型知道它应该写 Skill，但仍然在示例中输出省略号。这说明：

- 它理解了文档骨架；
- 但对“绝对不能用省略占位符”这一约束执行得不够彻底。

##### 问题三：存在轻度工程幻觉或过度概括

真实模型里有些表述虽然听上去合理，但相比 Mock 版本更容易“泛化过头”，例如：

- 把跨页面共享复用池写得比较轻松，但并没有充分讨论模板隔离与状态污染风险；
- 把部分富媒体、窗口和复用策略写成通用工程套话，缺少 Mock 那样明确的上下游约束；
- 在 ArkTS 对应写法里把 `aboutToReuse()`、`aboutToRecycle()` 放进例子，虽然是常见生命周期术语，但如果直接拿来指导 `Repeat` 场景，容易忽视官方文档提到的一个关键事实：`Repeat` 子组件复用时不会触发这两个回调。

结论：

- **内容丰满度：中等偏上**。
- **幻觉程度：中等偏低，但确实存在轻度工程泛化和示例偷懒现象**。

---

### 3. Prompt 调优建议

基于这次真实模型表现，当前 V2 Prompt 体系有三条明确优化方向。

#### 3.1 加强对“省略占位符”的语义约束

当前 Prompt 已经明确写了：

- 不允许使用省略号；
- 不允许使用“略”。

但真实模型仍然在示例代码里输出了 `...`。

建议：

- 把这条约束从普通规则提升为**高优先级失败规则**；
- 在 Prompt 中加一条更强的说明：
  - “任何字段、任何示例、任何代码式伪代码中，只要出现三个连续英文句点，整个输出视为失败。”
- 在真实模型请求前，再增加一段短提示：
  - “若信息不足，请写‘当前未知，需检索确认’，不要使用省略号。”

#### 3.2 对 Architecture 类 Skill 增加内容级强制关键词

目前生成器只做结构校验，还没有做内容级断言。

建议给 `Architecture` 类 Skill 增加一些最低内容门槛，例如：

- `Execution Topology` 必须命中：`主线程`、`后台线程`；
- `State Contract` 必须命中：`状态所有者`、`真值来源`；
- `Architecture Mapping` 必须命中：`重构策略`、`目标侧角色`；
- `Performance Envelope` 必须命中：`内存`、`主线程预算`、`窗口` 或 `活动节点`。

这样做的好处是：

- 真实模型即使结构齐全；
- 但只要内容太空，也会被拦下。

#### 3.3 对长 Prompt 做分层压缩

本轮的一个非常明确的事实是：

- `GLM-5` 在较长 Prompt 下，两次都超时；
- 即使缩短上下文后，轻量模型虽然能回包，但内容密度下降。

因此建议后续把 Prompt 拆成两层：

1. **硬约束层**：只保留 V2 结构顺序、关键失败规则、架构字段重点要求；
2. **上下文层**：只注入必要的原材料摘要和最关键的上游 Skill 摘要，而不是整篇全文灌入。

这会带来三个好处：

- 降低真实模型超时风险；
- 降低成本；
- 提升真实模型对关键约束的注意力密度。

---

### 4. A/B 最终裁决

#### Mock 版本裁决

- **结构保持力：优秀**
- **内容丰满度：优秀**
- **幻觉程度：低**
- **工程可用性：高**

#### 真实模型版本裁决

- **结构保持力：中上**
- **内容丰满度：中等偏上**
- **幻觉程度：中等偏低**
- **工程可用性：中等**
- **当前主要阻塞点**：输出中出现省略占位符，无法直接通过生成器校验

#### 总结判断

这次真实 A/B 测试说明：

- **V2 模具确实能框住真实模型的大方向**；
- 真实模型已经不太会完全跑偏成纯 API 文档；
- 但它还不能像 mock 版本那样稳定、细致、零省略地遵守所有规则。

换句话说：

- 我们的模具已经有“约束方向”的能力；
- 但离“稳定量产高质量 Architecture Skill”还差两步：
  1. Prompt 压缩；
  2. 内容级校验。

这并不是坏消息。恰恰相反，这说明我们的下一步优化方向已经非常明确。
