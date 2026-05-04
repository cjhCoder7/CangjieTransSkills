# 执行轨迹：V2 Skill 生成流水线 run-003 / main-thread-ui-boundary

## 1. Run 元信息

- **Run ID**：`run-003-main-thread-ui-boundary`
- **执行日期**：`2026-03-26`
- **任务目标**：验证“压缩 Prompt + 校验驱动自动修复”是否能在真实模型上稳定产出第三个 Architecture 级 Skill。
- **目标 Skill**：`skills/main-thread-ui-boundary.md`
- **模型通道**：硅基流动 OpenAI 兼容接口
- **模型**：`zai-org/GLM-4.5-Air`
- **执行模式**：真实 API，非 mock

## 2. 背景问题与诊断结论

本轮不是简单继续试产，而是针对一个更根本的质疑进行验证：

> 如果连 GLM-5 这种旗舰模型都在上一轮超时或失稳，是否说明项目方向本身有问题？

本轮结论非常明确：

- **项目方向没有问题**；
- **真正出问题的是 Prompt 工程策略**；
- 旧版生成器把 `SKILL_SCHEMA_V2.md` 全文注入模型，导致 Prompt 体积过大、阅读负担过重、生成阶段出现超时与偷懒输出；
- 模型失败主要体现为：
  - 请求超时；
  - 输出中出现 `...` 这类省略占位；
  - 局部章节满足结构，但内容不够工程化；
  - `Retrieval Fallback` 这类章节容易出现编造式 CLI / Python 示例。

因此，本轮不是怀疑 Schema V2，而是对 `scripts/skill_generator_v2.py` 做“核心手术”。

## 3. 本轮对生成器实施的关键改造

### 3.1 Prompt 上下文压缩

已确认旧版生成器会把整个 `skills/SKILL_SCHEMA_V2.md` 塞入 Prompt。

本轮改为：

- 在 Python 代码中硬编码“压缩版 Schema 骨架”；
- 只保留：
  - 顶级章节名称；
  - 每章一条硬约束；
  - 每章必须出现的小项关键词；
- 不再把 Schema 教程文档全文注入模型。

### 3.2 System Prompt 升级为失败级规则

新增系统级强约束：

- 只能输出 Markdown 正文；
- 第一行必须是 `# Skill Metadata`；
- 禁止输出前言、JSON、闲聊；
- 禁止输出 `...`、`…`、`略`、`待补充`、`TBD`、`同上`、`自行处理`；
- 对 Architecture Skill 强化 `Architecture Mapping`、`Boundary Contract`、`Execution Topology`、`State Contract`、`Performance Envelope` 的深度约束。

### 3.3 自动修复重试机制

旧版生成器只有“生成后校验失败即退出”。

本轮新增：

- 首次调用真实模型；
- 本地提取 Markdown；
- 本地执行结构与内容校验；
- 如果失败，则将：
  - 原任务；
  - 上一版输出；
  - 校验问题清单；
  重新组织成修复 Prompt，自动发起下一轮生成。

这意味着第二轮不是“重新瞎写”，而是“针对错误做结构化修补”。

### 3.4 对 Retrieval Fallback 增加内容级约束

人工审查发现：即使结构通过，真实模型仍可能在 `# Retrieval Fallback` 中发明不存在的 CLI、假 Python 包或假参数。

因此本轮继续收紧：

- `Retrieval Fallback` 必须包含：
  - 至少一个 `rg -n` 命令；
  - 至少一个 `python scripts/skill_generator_v2.py --source ... --skill-name ... --skill-class ...` 命令；
- 校验器会拒绝：
  - `harmony-skill` 这类编造 CLI；
  - `harmony_skill_api` 这类编造 Python 包；
  - `--skill`、`--analyze` 这类并不存在于脚本中的参数。

这一步非常关键，因为它说明我们不再满足于“结构看起来像”，而是开始压实到“命令可执行”。

## 4. 输入原材料

本轮原材料位于：

- `docs/raw_docs/arkts-main-thread-ui-boundary.md`

这份材料聚焦以下知识点：

- ArkTS 中后台计算与主线程 UI 提交的边界；
- `@State`、`@StorageLink`、AppStorage 与数据源通知的线程归属；
- taskpool、最小变更包、版本校验、页面生命周期失效；
- 与 `message-delta-merge-and-batching`、`chat-timeline-virtualized-rendering` 的上下游衔接。

## 5. 真实执行命令

本轮实际执行的是：

```bash
OPENAI_BASE_URL='https://api.siliconflow.cn/v1' \
OPENAI_API_KEY='<已配置，不在文档中回显>' \
python scripts/skill_generator_v2.py \
  --source docs/raw_docs/arkts-main-thread-ui-boundary.md \
  --skill-name main-thread-ui-boundary \
  --skill-id ARCH-MAIN-THREAD-UI-BOUNDARY-001 \
  --skill-class Architecture \
  --scope-hint '聚焦 ArkTS 后台计算与主线程 UI 提交边界，约束高频消息、列表数据源通知、页面生命周期失效和状态提交出口。' \
  --extra-instruction 'Architecture Mapping 必须明确把 ArkTS 的页面组件加 taskpool 加数据源通知，映射为仓颉侧的后台协调器、主线程派发器、页面投影 Store 与统一 UI 提交出口。' \
  --extra-instruction 'Execution Topology 必须明确：解码、合批、版本校验、最小变更包生成在后台；@State 或等价 UI 绑定状态提交以及数据源通知只能在主线程。' \
  --extra-instruction '必须说明它与 message-delta-merge-and-batching、chat-timeline-virtualized-rendering 的组合关系：先后台合并，再主线程提交，再虚拟化渲染。' \
  --extra-instruction 'Retrieval Fallback 必须使用 repo 内真实命令：至少包含一个 rg -n 命令，以及一个完整的 python scripts/skill_generator_v2.py --source <path> --skill-name <name> --skill-class Architecture 命令，不要发明 CLI 或假参数。' \
  --extra-instruction 'Known Gaps 必须明确当前仍未在真实 DevEco Studio 与仓颉运行时环境做端到端验证。' \
  --model 'zai-org/GLM-4.5-Air' \
  --max-source-chars 5000 \
  --timeout-seconds 180 \
  --max-attempts 3 \
  --dump-prompt-file artifacts/pipeline/main-thread-ui-boundary.prompt.txt \
  --dump-attempt-dir artifacts/pipeline/main-thread-ui-boundary.attempts \
  --output skills/main-thread-ui-boundary.md \
  --overwrite
```

## 6. Prompt 压缩效果

对比上一轮真实 chat timeline 任务：

- 旧版真实 Prompt 大小：`114638` 字符
- 本轮最终 Prompt 大小：`7237` 字符
- 压缩幅度：`93.69%`

这个数字非常重要，因为它说明：

- 我们不再把大模型当“读完整规范文档的秘书”；
- 而是把它当“接收短契约并输出结构化结果的编译器后端”。

## 7. 实际执行结果

### 7.1 第一次生成

- 真实模型返回成功；
- 但本地校验未完全通过；
- 首轮失败原因：
  - `# Retrieval Fallback` 缺少 `CLI / Python 检索示例` 这一显式小项标签。

这一点很典型：

- 结构已经接近正确；
- 但仍需要本地校验器把模型拉回精确模板。

### 7.2 第二次生成（自动修复）

- 脚本自动构造 repair prompt；
- 真实模型再次返回；
- 最终通过校验并落盘到：
  - `skills/main-thread-ui-boundary.md`

这说明自动修复策略是有效的。

## 8. 关键输出文件

### 8.1 最终 Skill

- `skills/main-thread-ui-boundary.md`

### 8.2 原材料

- `docs/raw_docs/arkts-main-thread-ui-boundary.md`

### 8.3 Prompt 与尝试记录

- `artifacts/pipeline/main-thread-ui-boundary.prompt.txt`
- `artifacts/pipeline/main-thread-ui-boundary.run.log`
- `artifacts/pipeline/main-thread-ui-boundary.attempts/attempt-01.prompt.txt`
- `artifacts/pipeline/main-thread-ui-boundary.attempts/attempt-01.raw.txt`
- `artifacts/pipeline/main-thread-ui-boundary.attempts/attempt-01.markdown.md`
- `artifacts/pipeline/main-thread-ui-boundary.attempts/attempt-01.issues.txt`
- `artifacts/pipeline/main-thread-ui-boundary.attempts/attempt-02.prompt.txt`
- `artifacts/pipeline/main-thread-ui-boundary.attempts/attempt-02.raw.txt`
- `artifacts/pipeline/main-thread-ui-boundary.attempts/attempt-02.markdown.md`

## 9. 本轮最重要的工程判断

### 9.1 项目方向没有问题

本轮真实压测已经证明：

- 不是 Schema V2 太难；
- 不是 ArkTS 主线战略错误；
- 不是“大模型根本做不了 Architecture Skill”。

真正的问题是：

- 旧 Prompt 过长；
- 校验只做结构不做内容；
- 失败后没有自修复闭环；
- 对检索降级没有命令级真实性约束。

### 9.2 真实模型依然不能完全放养

即使 Prompt 已压缩，真实模型仍然表现出以下倾向：

- 首轮输出容易漏掉显式标签；
- 如果不加更强约束，仍可能发明 CLI、Python 包或脚本参数；
- 说明真实模型更适合“受控生成”，不适合“自由发挥”。

### 9.3 生成器已经从“长文写作器”升级为“短上下文结构编译器”

这是本轮最大的收获。

生成器的新职责是：

- 把长规范压缩成硬契约；
- 把真实模型输出当作待编译中间产物；
- 用本地校验器做静态检查；
- 用修复 Prompt 做增量纠偏。

这条路线明显比“把几百行 Schema 原文全部扔给模型”更可持续。

## 10. 仍然存在的局限

- 本轮使用的是 `zai-org/GLM-4.5-Air`，并未重新回测压缩后 Prompt 在 `GLM-5` 上的表现；
- 当前校验器仍以结构 + 少量内容规则为主，尚未覆盖所有潜在幻觉；
- `# Sources`、`# Official 回查入口` 等章节仍可能出现“泛官方描述”，未来需要继续加实证约束；
- 目前仍未在 DevEco Studio / 仓颉真实运行时做端到端验证。

## 11. 下一步建议

建议下一轮继续做两件事：

1. **重新回测压缩 Prompt 在 `GLM-5` 上的表现**，验证之前的超时是否确实由超长 Prompt 造成；
2. **继续加强内容级断言**，特别是：
   - `# Sources` 必须引用真实输入文件；
   - `# Retrieval Fallback` 必须引用真实脚本参数；
   - `# Examples` 必须显式标注为概念性伪代码，避免被误读为真实 API。

## 12. 最终结论

这轮 run-003 已经给出了清晰答案：

- **GLM-5 失败不代表项目失败；**
- **它更可能说明旧版 Prompt 设计撞上了上下文与生成惰性的物理边界；**
- **通过上下文压缩、内容约束和自动修复，真实模型已经可以产出第三个 Architecture Skill。**

换句话说：

> 我们不是该放弃这个项目，而是终于找到了更像工程系统、而不是更像写作文的生成方式。
