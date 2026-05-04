# Trace: Phase 03 Physical Iron Test — RealMessageService Round 13

- 日期：`2026-03-27`
- 目标：`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`
- 运行目录：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-010-round13-class-promise-regression-guard`
- 核心新增约束：`skills/cangjie-class-and-promise-syntax-v1.md`
- 关键机制：
  - 注释脱敏静态铁穹（先扫黑名单，再决定是否放行）
  - 双证据修复（Reviewer + 真实 `cjc`）
  - 协议残留回归保护（Ratchet / Regression Guard）

## 1. 本轮目的

Round 12 已经证明系统第一次可以让候选代码穿过：

`静态墙 -> LLM Reviewer -> 真实 cjc`

但卡在更深层的仓颉语法问题：

- `implements`
- `export class`
- `Promise(=> { ... })`

因此 Round 13 的目的非常明确：

1. 挂载 `cangjie-class-and-promise-syntax-v1`，逼模型修正类实现/继承语法与异步写法；
2. 继续观察模型在压力下是否会把 `TLUser` / `createInputPeer` 再捡回来；
3. 重点验证回归保护是否开始形成“只能向前、不能回头”的棘轮效应。

## 2. 本轮配置

- 模型：`Pro/zai-org/GLM-4.7`
- 最大轮数：`5`
- Parser：`AST / tree-sitter`
- Verify：真实 `cjc` 编译，单测与行为层保持 mock
- 挂载 Skill：
  - `skills/domain-purity-hard-template.md`
  - `skills/cangjie-syntax-pitfalls-v1.2.md`
  - `skills/protocol-adapter-extraction-strategy.md`
  - `skills/anti-corruption-and-concurrency-strategy.md`
  - `skills/acl-mapper-and-domain-genesis-strategy.md`
  - `skills/domain-mapper-golden-template.md`
  - `skills/async-stream-and-binary-protocol-mapping.md`
  - `skills/cangjie-class-and-promise-syntax-v1.md`

## 3. 总体结果

- `summary.json.status = passed`
- `RealMessageService.orchestration.json.final_status = failed`

流水线层面成功完成了：索引、Repo Map、TU 打包、Orchestrator 全五轮执行。

但业务层面最终候选仍未通过，失败原因是：

> 模型在本轮中**确实向更深层仓颉语法推进了一步**，但尚未稳定掌握“类声明 + 导入语法 + 布尔逻辑”三件套；同时 `unsafe` 仍是最顽固的静态回弹点。

## 4. 五轮战况

### Attempt 1

- 结果：静态拦截
- 主要命中：
  - `unsafe`
  - `TLUser`
  - `TLChannel`

结论：

> 模型开局仍然带着明显的协议污染与关键字残留进入候选，静态墙直接击落。

### Attempt 2

- 结果：静态拦截
- 主要命中：
  - ArkTS / TypeScript 风格 `import ... from`
  - `TelegramProtocolAdapter` 也以 TS 导入形式出现

结论：

> 第二轮没有回到 `TL*` 协议对象，但模型退化回了源语言导入语法，说明它开始尝试“做分层”，却还没有真正切到仓颉语法脑回路。

### Attempt 3

- 结果：静态拦截
- 主要命中：
  - `unsafe`
  - `TLUser`
  - `TLChannel`
  - `InputPeer`
  - `createInputPeer`

结论：

> 这一轮发生了典型的“智力枯竭回退”：模型在前一轮试图做 Adapter 抽离失败后，又把最熟悉的协议对象和作弊构造器全捡回来了。

### Attempt 4（本轮最关键突破）

- 结果：静态通过 + Reviewer 进入 + 真实 `cjc` 编译失败
- Reviewer 主要问题：
  - `!` 布尔取反/TS 风格非空断言残留
  - `State Contract` 风险
  - `Execution Topology` 不完整
- 真实 `cjc` 关键报错：
  - `export class RealMessageService implements IMessageService`
  - `expected '{' or '<', found 'implements'`

这一轮非常关键，因为它说明：

1. 协议污染、`TL*`、`InputPeer`、`createInputPeer` 在这一轮**没有再触发静态黑名单**；
2. `Promise(=> { ... })` 这一类错误写法**本轮没有再出现**；
3. 新 Skill 的效果已经开始显现：模型把异步写法推进到了更保守的 `spawn` 路线；
4. 剩余阻塞点从“协议毒瘤”推进成了更纯粹的仓颉声明语法：`export class`、`implements`、`!`。

换句话说：

> `cangjie-class-and-promise-syntax-v1` 对“Promise 伪构造”这条线产生了正向影响，但模型还没有彻底学会把 `implements` 改成 `<:`，也没有彻底清理掉 TS 风格布尔写法。

### Attempt 5

- 结果：静态拦截
- 主要命中：
  - `unsafe`

结论：

> Attempt 5 没有重新引入 `TLUser`、`TLChannel`、`InputPeer`、`createInputPeer`，但又退化回了 `unsafe` 导入，说明模型在协议隔离这条线上出现了**局部保持**，但在仓颉底层语法清洁度上仍然不稳定。

## 5. 回归保护（Ratchet Effect）观察

本轮用户特别要求观察：

> 当模型在 Attempt 3/4 再次想把 `TLUser` / `createInputPeer` 捡回来时，Orchestrator 的红色警告是否会像鞭子一样把它抽回去？

本轮的实际情况是：

1. **Attempt 3 的协议回退发生在第一次“协议全绿”之前**，因此此时还没有满足 `protocol_bleed cleared` 的棘轮前提；
2. **Attempt 4 才是第一次真正清掉显式协议毒瘤并穿过静态墙**；
3. **Attempt 5 没有再出现协议毒瘤回退**，只回退了 `unsafe`。

因此本轮对回归保护的裁决是：

- **协议棘轮尚未被“正面触发”一次**，因为协议回退发生得太早；
- 但从 Attempt 4 -> Attempt 5 的走势看，协议污染没有再次大面积回潮，这说明“协议隔离压力”已经开始稳定生效；
- 当前真正需要继续上棘轮的，已经不只是 `TL*`，还包括：
  - `unsafe`
  - `export class`
  - `implements`
  - `!`

一句话总结：

> Round 13 中，协议层的棘轮开始起作用，但语法层的棘轮还没有焊死。

## 6. 对新 Skill 的直接评估

### 6.1 成功点

`skills/cangjie-class-and-promise-syntax-v1.md` 的作用已经开始显现：

- Round 12 暴露的 `Promise(=> { ... })` 在 Round 13 的突破候选中没有再成为主报错；
- 模型开始尝试：
  - `spawn { ... }`
  - `Signal` / `ValueSignal`
  - Adapter 注入 + Service 编排

这说明：

> 模型至少已经被逼着从“伪 Promise 翻译”切换到“更保守的异步编排”。

### 6.2 未完成点

但类声明语法还没有真正收敛：

- 仍写出 `export class`
- 仍写出 `implements`
- 仍夹带 `!`

说明：

> 模型已经开始接受“不要照搬 ArkTS Promise”，但还没有完全放弃 Java / TS 的类声明肌肉记忆。

## 7. 最终裁决

Round 13 的结论不是“通过”，而是一次非常有价值的**前移胜利**：

1. **系统再次证明可以把候选推进到真实 `cjc`**；
2. **`Promise(=> { ... })` 这条老坑明显被压下去了**；
3. **协议污染没有在最终轮次全面回潮**；
4. **新的主战场已经收缩到仓颉类声明与 TS 残余布尔/导入语法**。

如果用一句最精炼的话概括：

> Round 13 并没有一枪打穿，但它成功把模型从“协议污染 + 伪 Promise”这个旧泥潭里拽出来，逼到了更靠近真实仓颉语法核心的战壕前沿。

## 8. 本轮最有价值的证据文件

- 总运行摘要：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-010-round13-class-promise-regression-guard/summary.json`
- 编排结果：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-010-round13-class-promise-regression-guard/RealMessageService.orchestration.json`
- Attempt 4 候选：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-010-round13-class-promise-regression-guard/temp_workspace/20260327T101445Z-tu-pipeline-realmessageservice-src-services-realmessageservice.ets/attempt-04/src/services/RealMessageService.cj`
- Attempt 5 候选：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-010-round13-class-promise-regression-guard/temp_workspace/20260327T101445Z-tu-pipeline-realmessageservice-src-services-realmessageservice.ets/attempt-05/src/services/RealMessageService.cj`

## 9. 阶段性判断

当前最值得肯定的不是“模型终于会写对仓颉”，而是：

- 静态铁穹已经足够稳定；
- 真实 `cjc` 反馈链已经稳定贯通；
- Skill 补丁确实能把错误从“脏协议残留”推进到“深层语法映射”；
- Ratchet 思想是对的，只是下一步要从“协议棘轮”扩展到“语法棘轮”。

本轮可判定为：

> **失败，但方向完全正确，而且失败质量明显提高。**
