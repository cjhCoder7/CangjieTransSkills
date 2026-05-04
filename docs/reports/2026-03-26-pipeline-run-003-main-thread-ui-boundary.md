# Pipeline Run-003 总结：Main Thread UI Boundary Skill 真实压测

## 1. 文档目的

本报告用于总结 run-003 的真实 API 压测结果，回答一个战略级问题：

> 当旗舰模型在超长 Prompt 场景下表现不稳时，是否说明项目方向本身有问题？

本轮结论是：项目方向没有问题，问题主要在 Prompt 工程与本地约束策略。

## 2. 本轮采取的关键策略

### 2.1 不再注入 Schema 全文

`skill_generator_v2.py` 不再把 `skills/SKILL_SCHEMA_V2.md` 全文塞给模型，而是改为：

- 硬编码压缩版 Schema 骨架；
- 每章只保留一条硬约束和必含小项；
- 让模型在短上下文里完成结构化写作。

### 2.2 加入自动修复重试

首次输出失败时，脚本不会直接退出，而是会把：

- 原始任务；
- 上一次输出；
- 本地校验发现的问题；

一起重新组织成 repair prompt，让模型做定向修复。

### 2.3 加强命令级真实性校验

本轮特别针对 `# Retrieval Fallback` 做了收紧：

- 必须包含 `rg -n`；
- 必须包含 `python scripts/skill_generator_v2.py --source ... --skill-name ... --skill-class ...`；
- 明确拒绝编造 CLI、假 Python 包和假参数。

## 3. 输入与输出

### 3.1 输入原材料

- `docs/raw_docs/arkts-main-thread-ui-boundary.md`

### 3.2 最终输出

- `skills/main-thread-ui-boundary.md`

### 3.3 运行产物

- `artifacts/pipeline/main-thread-ui-boundary.prompt.txt`
- `artifacts/pipeline/main-thread-ui-boundary.run.log`
- `artifacts/pipeline/main-thread-ui-boundary.attempts/`

## 4. 核心结果

### 4.1 Prompt 体积显著下降

- 旧版真实 Prompt：`114638` 字符
- 本轮 Prompt：`7237` 字符
- 压缩幅度：`93.69%`

这直接证明：

- 之前的失败更像是 Prompt 过载；
- 而不是任务本身超出模型能力上限。

### 4.2 真实模型成功产出第三个 Architecture Skill

本轮使用硅基流动通道下的 `zai-org/GLM-4.5-Air`，最终成功生成：

- `main-thread-ui-boundary`

这是继：

- `signal-based-reactive-pipeline`
- `message-delta-merge-and-batching`
- `chat-timeline-virtualized-rendering`

之后，又一个通过真实 API 验证的高风险 Architecture Skill 方向。

### 4.3 自动修复机制有效

首轮生成时，模型仍然漏掉了 `CLI / Python 检索示例` 的显式标签。

但第二轮修复后成功通过本地校验，这说明：

- 模型第一次输出可以视为“粗骨架”；
- 校验器和 repair prompt 能把它稳定拉回模板。

## 5. 对“项目是否出了问题”的最终回答

我的判断是：**项目没有出问题，旧 Prompt 出了问题。**

更具体地说：

- V2 Schema 的方向是对的；
- ArkTS 主线战略是对的；
- Architecture Skill 的目标粒度是对的；
- 真正的问题是：
  - 旧 Prompt 太长；
  - 约束过于依赖全文说明；
  - 缺少自动修复；
  - 缺少内容级真实性校验。

这轮 run-003 已经把这些短板中的前三项显著修正，并开始处理第四项。

## 6. 仍需继续补强的点

- 未来应把 `# Sources`、`# Official 回查入口` 也做成更硬的真实性断言；
- 应继续回测压缩 Prompt 在 `GLM-5` 上的表现，验证旗舰模型是否在短上下文下也能稳定通过；
- 应逐步积累一套“高风险 Architecture Skill 的内容级规则库”，降低幻觉空间。

## 7. 最终裁决

本轮 run-003 的意义不是“又生成了一个 Skill”，而是：

- 我们证明了大模型不是不能做，而是不能被错误地使用；
- 我们把生成器从“全文喂给模型的写作文脚本”，推进成了“短契约 + 静态校验 + 自动修复”的工程流水线；
- 这条路线值得继续投资。
