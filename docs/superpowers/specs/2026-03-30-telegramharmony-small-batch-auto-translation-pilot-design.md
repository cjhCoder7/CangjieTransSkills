# TelegramHarmony 小批量自动翻译 Pilot Design

## 1. 设计目的

本设计回答两个问题：

1. **什么时候可以开始大规模自动翻译？**
2. **在真正放量前，第一轮自动翻译 Pilot 应该怎么打？**

结论先行：

- **现在就可以开始“小批量自动翻译试运行”**；
- 但**还不应该直接做整仓全量翻译**；
- 最稳妥的推进方式是：先用 `TelegramHarmony` 当前已落盘的 `raw_docs/telegramharmony-phase02` 做一轮**风险分层的文件组 Pilot**，把批量翻译、批量审查、批量验证与批量回写链路打通，再决定何时放量。

本设计不直接发明新的翻译架构，而是严格服从当前项目宪章：

- 以 `raw_docs/telegramharmony-phase02` 为源侧真理；
- 继续沿用 `Translate -> Review -> Verify -> Repair` 主链；
- 优先保留可追溯工件；
- 严守 `Source Alignment`，尤其禁止 public API 契约撕裂。

## 2. 当前真实上下文

### 2.1 已知可直接开火的模块池

当前 `raw_docs/telegramharmony-phase02/src` 内实际可见文件共 `10` 个：

- `src/services/RealMessageService.ets`
- `src/core/mtproto/AuthKeyCreator.ets`
- `src/core/mtproto/MTProtoConfig.ets`
- `src/core/mtproto/TLDialogs.ets`
- `src/core/mtproto/CryptoUtils.ets`
- `src/core/mtproto/TLMethods.ets`
- `src/core/mtproto/TLSerialization.ets`
- `src/core/mtproto/MTProtoClient.ets`
- `src/core/mtproto/Inflate.ets`
- `src/core/mtproto/MTProtoTransport.ets`

### 2.2 当前已拿到的样板能力

我们已经围绕 `RealMessageService` 打通：

- `Source Alignment` 守门；
- `Signal<Message[]>` runtime 收口；
- `Promise<Message>` / `Promise<Message[]>` 最小语义收口；
- Linux `Staging-Core` 下的 `cjpm test` 与 `timeout smoke` 证据链。

这意味着我们已经具备 **一个高可信样板模块**，可以作为后续自动翻译批次的“回归锚点”和“翻译模板源”。

### 2.3 为什么现在还不能直接整仓全量

不是因为工具链不行，而是因为**模块风险分布非常不均匀**：

- `RealMessageService`：已拿到深度行为证据；
- `MTProtoConfig / TLMethods / TLSerialization / CryptoUtils`：偏数据结构与纯工具，可较早自动化；
- `AuthKeyCreator / MTProtoClient`：涉及 `Promise`、回调、pending map、状态生命周期；
- `MTProtoTransport`：直接触碰 `@kit.NetworkKit` / socket / Harmony runtime，是明显更高风险层。

如果现在直接全仓一把梭，本质上是在把“已验证的翻译问题”和“未验证的系统互操作问题”绑死在一起，失败信号会变脏。

## 3. 三种推进路线

### 方案 A：继续单文件深挖（保守）

做法：

- 一次只翻一个文件；
- 每个文件都单独建样本、单独建断言、单独跑编译。

优点：

- 风险最低；
- 单次失败面最小。

缺点：

- 推进过慢；
- 无法证明“批量自动翻译链路”已经可用；
- 很难回答“大规模什么时候开始”。

### 方案 B：风险分层的小批量 Pilot（推荐）

做法：

- 不整仓翻，而是先做**第一批 4 文件低/中风险 Pilot**；
- 用现有 `pipeline_runner.py` 做逐文件编排，再由一个 batch manifest / wrapper 统一驱动；
- 保留 `RealMessageService` 作为已验证样板，不纳入首批失败预算，而作为回归锚点；
- 第一批成功后，再做**第二批 2~3 文件中高风险 Pilot**。

优点：

- 能尽快验证“批量翻译流程”本身；
- 又不至于把高风险网络层一起引爆；
- 最适合作为从样板工程走向目录级翻译的闸门。

缺点：

- 需要先定义批次 manifest、分组策略和批量工件落盘规则；
- 首轮更多是流程建设，不是规模炫技。

### 方案 C：直接目录级全量翻译（激进）

做法：

- 把当前 `raw_docs/telegramharmony-phase02/src` 全部丢进自动翻译流水线；
- 统一生成候选与失败报告。

优点：

- 很快能看到“全仓级别”的表面进展。

缺点：

- 失败信号会混叠；
- 很难区分是翻译失真、互操作缺件、还是 Harmony runtime 阻塞；
- 极大概率引发无意义 repair 风暴。

## 4. 采纳方案

采纳 **方案 B：风险分层的小批量 Pilot**。

核心原则：

- **先证明批量翻译流程可控，再证明规模可扩张**；
- **先挑“纯工具 / 数据结构 / 二进制工具”类文件，再碰“连接 / socket / runtime 回调”类文件**；
- **所有批量翻译都必须以 source parity 和 artifact 可追溯为前提**。

## 5. Pilot 范围设计

### 5.1 冻结控制样板（不计入首批失败预算）

- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`

用途：

- 作为当前最强样板模块；
- 用于回归对照、repair prompt anchor、模式记忆抽取；
- 不作为首批“自动翻译成功率 KPI”的统计对象。

### 5.2 Batch-1：低 / 中风险 Pilot（推荐立即执行）

首批建议文件：

1. `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoConfig.ets`
2. `raw_docs/telegramharmony-phase02/src/core/mtproto/CryptoUtils.ets`
3. `raw_docs/telegramharmony-phase02/src/core/mtproto/TLMethods.ets`
4. `raw_docs/telegramharmony-phase02/src/core/mtproto/TLSerialization.ets`

选择理由：

- 文件短，反馈快；
- 具备代表性：常量 / 配置、纯工具、协议方法定义、序列化 / 反序列化；
- 避开了 `socket` / `NetworkKit` / 长生命周期连接状态；
- 非常适合沉淀第一版“协议工具类翻译模板”。

### 5.3 Batch-2：中高风险 Pilot（Batch-1 通过后）

建议文件：

1. `raw_docs/telegramharmony-phase02/src/core/mtproto/AuthKeyCreator.ets`
2. `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoClient.ets`
3. `raw_docs/telegramharmony-phase02/src/core/mtproto/TLDialogs.ets`

选择理由：

- 已开始触碰 `Promise`、pending callback、初始化状态、请求回流；
- 能验证我们在 `V11` 刚收口的 Promise runtime 经验，是否能迁移到协议层。

### 5.4 暂缓批次（不进入当前 Pilot）

暂缓文件：

- `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoTransport.ets`
- `raw_docs/telegramharmony-phase02/src/core/mtproto/Inflate.ets`

原因：

- `MTProtoTransport.ets` 直接触碰 `@kit.NetworkKit` 与 socket runtime，当前更适合作为 `Staging-Full` 或更高互操作阶段的问题；
- `Inflate.ets` 文件极短，但其真实价值依赖后续压缩 / 解压互操作上下文，适合并入协议层专项，而不是首批 Pilot KPI。

## 6. 批量翻译链路设计

### 6.1 执行单位

批量 Pilot 的最小执行单位不是“整个目录”，而是：

- **一个 manifest 文件 + 多个 target-file 顺序跑**。

manifest 中至少包含：

- 源文件路径；
- 风险等级；
- 分组标签；
- 期望验证方式（dry-run / real-compile / harness-only）；
- 是否允许进入 batch KPI 统计。

### 6.2 调度方式

首轮不重写主流水线，优先复用：

- `scripts/pipeline_runner.py`
- `scripts/orchestrator.py`
- `scripts/verifier.py`
- `scripts/repo_indexer.py`
- `scripts/repo_map_generator.py`

推荐做法：

- 新增一个轻量 batch wrapper / runner；
- 逐个调用 `pipeline_runner.py --target-file ...`；
- 每个文件保留独立 `run_root / summary / failure / orchestration`；
- 批次层再汇总出一个 `batch-summary.json`。

### 6.3 输出工件

每个 target file 继续保留当前单文件工件；批次新增：

- `artifacts/batch_runs/<batch-name>/manifest.json`
- `artifacts/batch_runs/<batch-name>/batch-summary.json`
- `artifacts/batch_runs/<batch-name>/success-list.json`
- `artifacts/batch_runs/<batch-name>/failure-list.json`
- `artifacts/batch_runs/<batch-name>/pattern-candidates.json`

## 7. 何时允许进入“大规模自动翻译”

不是按日期开闸，而是按以下 **3 道闸门**：

### 闸门 G1：Batch-1 通过

要求：

- Batch-1 的 `4` 个文件中，至少 `3` 个达成 source-aligned compile pass；
- 失败文件必须能归类到明确 failure class，而不是混沌报错；
- 批次汇总工件完整落盘。

### 闸门 G2：Batch-2 至少拿下一个高风险异步模块

要求：

- `AuthKeyCreator` 或 `MTProtoClient` 至少有 `1` 个通过 compile / review 主链；
- Promise / callback / pending-state 相关 repair guidance 能稳定回放。

### 闸门 G3：批量 reject/repair 流程稳定

要求：

- 批量运行不会因为某一个文件失败而导致整批无摘要；
- verifier / summary / failure report 都能按文件归档；
- pattern memory 能从成功样本中抽回可复用模式。

**当 G1 + G2 + G3 同时满足时，就可以进入目录级自动翻译。**

## 8. 成功指标

Pilot 成功不等于“全部翻完”，而是满足以下指标：

1. **流程指标**
   - 能连续跑一批文件；
   - 每个文件都有独立 summary / failure；
   - 批次级汇总文件生成成功。
2. **翻译指标**
   - 首批 `4` 文件至少 `75%` compile pass；
   - 失败文件能被归类并重试。
3. **知识沉淀指标**
   - 至少抽出 `1` 份“协议工具类翻译模式”文档；
   - 至少抽出 `1` 份“Promise / callback 协议层修复模式”草案。

## 9. 推荐的下一步动作

如果立即执行，我建议顺序如下：

1. 新增 `Batch-1 manifest`；
2. 新增 `batch wrapper`（只做顺序调度与汇总，不改核心 pipeline）；
3. 先用 `mock-mode + verify-dry-run` 跑 Batch-1；
4. 再对通过率最高的文件打开真实 compile 验证；
5. 将成功样本和失败模式回写到 pattern memory / trace 文档。

## 10. 最终判断

因此，对“什么时候才能开始大规模自动翻译？”的正式回答是：

- **现在就能开始小批量自动翻译 Pilot**；
- **当 Batch-1、Batch-2 和批量 reject/repair 三道闸门都过了，就可以开始目录级大规模自动翻译。**

换句话说：

> 我们已经跨过了“不能自动翻译”的阶段，正在进入“可以受控放量”的阶段；
> 但还没有到“可以不分层直接全仓扫射”的阶段。
