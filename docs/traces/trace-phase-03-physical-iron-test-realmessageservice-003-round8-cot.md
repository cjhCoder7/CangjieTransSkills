# Trace - Phase-03 RealMessageService 物理编译 Iron Test 003（Round 8 / CoT + Syntax v1.1）

## 1. 本轮目标

Round 8 的目标不是让 `RealMessageService.ets` 在单文件条件下侥幸编译通过，而是验证以下三件事：

1. 新增的 `skills/cangjie-syntax-pitfalls-v1.1.md` 是否能继续压缩真实仓颉语法错误；
2. `scripts/prompt_assembler.py` 注入的 `<repair_plan>` 强制思维链，是否真的被模型遵守并落入产物；
3. 在“双证据并联”（Reviewer + 真实 `cjc`）下，Translator 是否能在同一轮里同时推进：
   - `TelegramProtocolAdapter` / 协议隔离
   - ACL / Domain Purity
   - 仓颉语法修复（关键字冲突、数字后缀、闭包/Promise 写法等）

## 2. 本轮执行配置

运行目录：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-004-round8-cot`

关键参数：

- 源码根：`raw_docs/telegramharmony-phase02`
- 目标文件：`src/services/RealMessageService.ets`
- 模型：`Pro/zai-org/GLM-4.7`
- 解析模式：`ast`
- 真实编译器：Linux x64 `cjc`
- 验证模式：`--verify-no-dry-run --verify-real-compile`
- 最大轮数：`5`
- 挂载 Skill：
  - `async-stream-and-binary-protocol-mapping`
  - `protocol-adapter-extraction-strategy`
  - `anti-corruption-and-concurrency-strategy`
  - `acl-mapper-and-domain-genesis-strategy`
  - `domain-mapper-golden-template`
  - `cangjie-syntax-pitfalls-v1.1`

本轮关键运行产物：

- 控制台日志：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-004-round8-cot/console.log`
- 编排结果：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-004-round8-cot/RealMessageService.orchestration.json`
- 摘要：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-004-round8-cot/summary.json`
- 最终候选：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-004-round8-cot/temp_workspace/20260327T085042Z-tu-pipeline-realmessageservice-src-services-realmessageservice.ets/attempt-05/src/services/RealMessageService.cj`

## 3. `cangjie-syntax-pitfalls-v1.1` 的核心增量

本轮新 Skill 的核心增量确实已经进入流水线，重点包括：

1. **关键字冲突**
   - `import std.unsafe.*` 在仓颉里会触发关键字冲突；
   - 应改为 `import std.\`unsafe\`.*` 或重命名局部标识符。
2. **禁用 TypeScript 风格非空断言**
   - `value!`、`map.get(key)!`、`signal!` 不应继续沿用；
   - 应改成显式判空、默认值、或受控的 helper 解包。
3. **Promise / 闭包签名拆分**
   - 不允许再写 `Promise<T> { () => ... }` 这类把泛型实例化和闭包体粘在一起的结构；
   - 应先定义函数类型，再显式构造 Promise。
4. **整数字面量后缀继续严管**
   - 不仅 `0L` 禁用，实战中还暴露了 `0UL` 也会被 `cjc` 直接击落。

## 4. Round 8 的总体结果

### 4.1 物理主循环稳定跑完 5 轮

**结论：已完整跑完，主循环稳定。**

`console.log` 清楚显示：

- index -> repo-map -> tu -> orchestration 全部完成；
- 5 轮中每轮都发生了：
  - translate
  - review
  - verify
  - repair
- 且在 `review_passed=False` 时依然继续触发了 `verify`。

说明 Round 7 建立的“双证据并联”在 Round 8 继续稳定生效，没有出现 JSON 崩溃或编排中断。

### 4.2 `summary.json` 与 `orchestration` 状态存在口径差异

- `summary.json` 顶层 `status` 为 `passed`
- 但 `RealMessageService.orchestration.json` 中 `final_status` 为 `failed`

这不是流水线崩溃，而是当前摘要口径表示“阶段执行完成”；真正的业务结果仍应以：

> `orchestration.final_status = failed`

为准。

## 5. `<repair_plan>` 是否真的生效

### 5.1 Prompt 侧已经注入

本轮代码侧已经完成：

- `prompt_assembler.py` 要求 Repair 前先输出 `<repair_plan>...</repair_plan>`；
- `orchestrator.py` 也已具备提取 `repair_plan` 的逻辑。

### 5.2 实战结果：**没有真正落盘**

对 5 个 `translation_artifact.json` 逐个检查后发现：

- `metadata.raw_text` 全部直接以 JSON 开头；
- 未发现 `<repair_plan>` 标签；
- `metadata.repair_plan` 也未出现。

这说明：

> Round 8 的 CoT 强锚定“已注入 Prompt，但尚未被模型实际遵守”。

换句话说，当前模型仍然倾向于直接返回结构化 JSON，而没有先吐出显式的计划块。

## 6. Round 8 的逐轮演化

### 6.1 Attempt 1：Adapter 开始出现，但协议残留非常重

Attempt 1 的一个积极信号是：

- 候选代码里已经出现 `TelegramProtocolAdapter`；
- 说明模型确实接收到了“协议隔离”的高压信号。

但同时仍然保留：

- `import std.unsafe.*`
- `createInputPeer(...)`
- `TLUser` / `TLChannel`
- `TLDeserializer`
- `request.toBytes()`
- `client.sendRequest(...)`

也就是：

- **Adapter 的“名字”出现了；**
- **协议层的“脏活”并没有真正离开 Service。**

Attempt 1 的 Reviewer blocker 主要为：

- `ARCH_DOMAIN_PURITY_VIOLATION`
- `ARCH_CONCURRENCY_SAFETY_VIOLATION`
- `ARCH_PROTOCOL_LEAKAGE`
- `STATE_CONTRACT_BREACH`

Attempt 1 的真实 `cjc` 报错首先击中：

- `import std.unsafe.*` 的关键字冲突；
- `public class TelegramProtocolAdapter : ITelegramProtocolAdapter` 的继承语法问题。

这说明模型首次尝试“造 Adapter”时，马上被仓颉语法细节打断。

### 6.2 Attempt 2：仍被 `std.unsafe` 和协议泄漏拖住

Attempt 2 继续保留 `TelegramProtocolAdapter`，但仍然出现：

- `std.unsafe.*`
- `messageSignals[...]`
- `TLDeserializer`
- `TLUser` / `TLChannel`
- `createInputPeer`

Reviewer 本轮进一步明确指出：

- 二进制协议解析逻辑仍在 Service 内；
- `cacheUsers/cacheChannels` 仍直接接收 TL DTO；
- `messageSignals` 共享状态仍缺锁保护；
- Service 层直接 new `MessagesGetHistory` 并 `request.toBytes()`。

这说明模型虽然“知道要抽 Adapter”，但它仍然采取了典型的 **名义隔离**：

> 新建了一个 Adapter 类，但没有完成依赖反转和协议边界内聚。

### 6.3 Attempt 3：`0L` 没了，但新的 `0UL` 又出现了

Attempt 3 的一个重要进展是：

- Round 7 里常见的 `0L` 已经没有再出现；
- 但模型新引入了 `0UL`。

真实编译错误直接命中：

- `unknown suffix 'UL' for number literal`

对应代码表现为：

- `peer.accessHash = userAccessHashes.get("${peerId.id}") ?? 0UL`
- `peer.accessHash = channelAccessHashes.get("${peerId.id}") ?? 0UL`

这非常关键，说明：

1. `cangjie-syntax-pitfalls-v1.1` 让模型基本摆脱了旧的 `0L` 惯性；
2. 但模型仍在用“别的语言数字后缀”补位，说明其仓颉数值字面量知识尚未稳定收敛。

本轮 Review 还新增暴露：

- `ARCH_PROTOCOL_ISOLATION_FAILURE`
- `ARCH_CONCURRENCY_DEADLOCK_RISK`
- `ARCH_STATE_MUTATION_RACE`

表明在语法补坑之外，Reviewer 已经把焦点推进到更细的锁顺序与共享状态修改风险。

### 6.4 Attempt 4：短暂摆脱 `std.unsafe`，但继承 / 可空语法继续出错

Attempt 4 的明显变化是：

- 代码命中中不再出现 `std.unsafe`；
- 说明物理编译反馈确实在推动模型局部修复。

但新的 `cjc` 错误又冒了出来：

- `public class TelegramProtocolAdapter : ITelegramProtocolAdapter` 仍不合法；
- `parseMessageContent(...): Message?` 一类可空/返回类型写法仍然不稳。

这说明 Round 8 的真实状态不是“完全无效”，而是：

> 一类语法错被压下去之后，下一层仓颉语法问题才开始浮现。

也就是编译器的“痛觉链”确实在逐层推进。

### 6.5 Attempt 5：最终候选保住了 Adapter，但仍未形成 ACL / Domain Model

最终第 5 轮候选保留了：

- `TelegramProtocolAdapter`
- `protocolAdapter.fetchHistory(...)`
- `protocolAdapter.sendMessage(...)`

说明模型没有完全退回“纯 Service 平移”状态，这是本轮最积极的一点。

但它仍然保留了以下高危残留：

- `import std.unsafe.*`
- `cacheUsers(users: ArrayList<TLUser>)`
- `cacheChannels(channels: ArrayList<TLChannel>)`
- `createInputPeer(peerId: PeerId): InputPeer`
- `this.messageSignals[key]!!`
- `spawn { ... }` + 阻塞式 Adapter 调用
- `TLDeserializer` / `toBytes()` / `sendRequest(...)` 仍在候选整体中可见

更关键的是，**本轮完全没有出现**：

- `TelegramAclMapper`
- `DomainUser`
- `ChatMessage`
- `AppUser` / `AppChannel`

也就是说：

> Round 8 成功逼出了 “Adapter 抽壳”，但还没有逼出 “ACL Mapper + Domain Genesis”。

Attempt 5 的 Reviewer blocker 主要是：

- `ARCH_DOMAIN_PURITY_VIOLATION`
- `ARCH_ASYNC_TOPOLOGY_ERROR`
- `ARCH_STATE_CONTRACT_VIOLATION`
- `ARCH_DEPENDENCY_LEAK`

Attempt 5 的真实编译错误则主要为：

- `import std.unsafe.*` 关键字冲突；
- `expected '=>' in lambda expression, found '}'` 等闭包 / 语法细节问题。

## 7. 本轮最关键的判断

### 7.1 CoT 注入没有白费，但“显式计划”还没被模型执行

虽然 `<repair_plan>` 没真正出现在输出里，但从 5 轮的行为看，模型确实表现出“分阶段修补”的迹象：

- 先尝试抽出 `TelegramProtocolAdapter`
- 再局部处理 `std.unsafe` / `0UL` / 继承语法 / 闭包语法

因此，更准确的判断是：

- **隐式的修复顺序意识有增强；**
- **显式的 XML 计划约束还没被它服从。**

### 7.2 `TelegramProtocolAdapter` 已经能被逼出来，但还只是半截胜利

本轮最大的积极信号不是“编译通过”，而是：

- `TelegramProtocolAdapter` 在多轮候选中稳定出现；
- 说明 Reviewer + Skill 补丁已经足够强，能够改变模型的结构性输出；
- 但 `createInputPeer`、`TLUser`、`TLChannel` 仍留在 Service 中，表明协议剥离只完成了第一层。

### 7.3 真正缺失的是 `ACL Mapper + Domain Genesis` 的落地本能

Round 8 最清楚地揭示出：

- 模型已经愿意“新建 Adapter”；
- 但仍然不愿意彻底创造领域实体并引入 Mapper。

具体症状：

- 保留 `cacheUsers(users: ArrayList<TLUser>)`
- 保留 `cacheChannels(channels: ArrayList<TLChannel>)`
- 没有 `TelegramAclMapper`
- 没有 `DomainUser` / `ChatMessage`

这与项目此前的判断完全一致：

> LLM 不是完全不会做 ACL，而是默认不敢主动“创生领域类型”。

## 8. 本轮裁决

Round 8 的最终业务状态仍然是：`failed`。

但它带来了三个非常关键的系统级结论：

1. **双路并联继续稳定**
   - Reviewer 未通过时仍会强制真实编译；
   - 5 轮全部落盘，无 JSON 崩溃。
2. **`cjc` 痛觉继续有效推进**
   - 从 `0L` 推进到 `0UL`、关键字冲突、可空写法、闭包语法等更细颗粒问题；
   - 说明物理修复回路真正参与了演化。
3. **结构重构已进入“半成功”阶段**
   - `TelegramProtocolAdapter` 已稳定出现；
   - 但 `TelegramAclMapper` / `DomainUser` / `ChatMessage` 仍未出现；
   - Domain Purity、Async Topology、State Contract 仍未同时收敛。

## 9. 下一步最值得做什么

基于 Round 8 的证据，下一刀最合理的方向不是继续泛化说理，而是：

1. 给 Translator 更强的 **Domain Genesis 模板刚性**；
2. 直接把 `TelegramAclMapper`、`DomainUser`、`ChatMessage` 做成必须仿写的黄金模板；
3. 进一步把 `0UL`、`std.unsafe`、`!!`、继承语法、Promise / lambda 误写纳入下一版语法铁律；
4. 若要继续强化 CoT，不能只“要求输出 `<repair_plan>`”，还要在解析失败时把“未输出计划块”本身视作可观测缺陷。

## 10. 最终裁决

Round 8 不是“通过”，但它是一次非常有价值的硬碰硬：

- `cjc` 的真实痛觉已经成功推动了语法层持续迭代；
- Reviewer 的架构高压已经逼出了 `TelegramProtocolAdapter`；
- 但模型仍然没有完全跨过 `ACL Mapper + Domain Model` 这道坎；
- `<repair_plan>` 约束尚未真正落地，说明 CoT 仍需要更强的结构化约束或解析回压。

一句话总结本轮：

> Round 8 已经证明模型会在真实编译器压力下“开始做架构重构”，但还没有被逼到能够稳定完成“协议剥离 + ACL 清洗 + 语法修复”三线同时收敛的程度。
