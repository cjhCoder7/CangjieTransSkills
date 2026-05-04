# Trace - Phase-03 RealMessageService 物理编译 Iron Test 002（Round 7 / Dual Evidence）

## 1. 本轮目标

本轮目标不是追求 `RealMessageService.ets` 编译通过，而是验证三件更关键的事情：

1. `orchestrator.py` 是否已经从“Reviewer 串行阻塞”升级为“Reviewer / Compile 双路并联”；
2. Repair 提示词中是否同时融合了：
   - Reviewer 的架构违规 JSON
   - `cjc` 的真实物理编译错误
3. 在新增 `skills/cangjie-syntax-pitfalls-v1.md` 后，Translator 是否能在自动循环里同时推进：
   - 去掉 `0L` 等仓颉字面量误用
   - 推进协议隔离 / Adapter 抽离

## 2. 本轮执行配置

运行目录：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-003-round7`

关键参数：

- 源码根：`raw_docs/telegramharmony-phase02`
- 目标文件：`src/services/RealMessageService.ets`
- 模型：`Pro/zai-org/GLM-4.7`
- 真实编译器：Linux x64 `cjc`
- 验证模式：`--verify-no-dry-run --verify-real-compile`
- 挂载 Skill：
  - `async-stream-and-binary-protocol-mapping`
  - `protocol-adapter-extraction-strategy`
  - `anti-corruption-and-concurrency-strategy`
  - `acl-mapper-and-domain-genesis-strategy`
  - `domain-mapper-golden-template`
  - `cangjie-syntax-pitfalls-v1`

## 3. 双路并联是否生效

**结论：已生效。**

关键日志：

- `review_passed=False -> invoke verifier`
- `verify passed=False status=failed failure_type=compile-failed`

这说明：

- 即使 Reviewer 未放行，`CompileChecker` 也已经被强制触发；
- `repair_guidance` 中同时出现了：
  - 架构违规（如 `ARCH_PROTOCOL_ISOLATION_LEAK`、`ARCH_DOMAIN_PURITY_VIOLATION`）
  - 物理编译错误（`compile-failed` + `cjc stderr`）

换句话说，Round 7 已经不是单裁判模式，而是：

> `Reviewer + cjc` 双证据并联驱动 Repair。

## 4. Round 7 的自动修复表现

### 4.1 第一轮就触发了真实 compile

第 1 轮的真实编译错误不再是 `0L`，而是：

- `import std.unsafe.*` 中的 `unsafe` 关键字冲突
- `public class RealMessageService : IMessageService` 的继承语法不符合当前仓颉写法
- `!` 非空断言、`Promise<T> { () => ... }` 这类残留语法

这说明一个非常关键的事实：

- **`0L` 已经不再是最前面的物理阻塞点。**
- 也就是说，新增的 `cangjie-syntax-pitfalls-v1` 至少在“整数字面量”这一类问题上，已经把模型从更早期的坑里拉了出来。

### 4.2 `0L` 是否被删掉了？

**是，被删掉了。**

最终第 5 轮候选中已不再出现 `0L`，而变成：

- `peer.accessHash = userHashes.get("${peerId.id}") ?? 0`
- `peer.accessHash = channelHashes.get("${peerId.id}") ?? 0`

因此：

> “删除 `0L`” 这一项，Round 7 自动循环已经做到了。

### 4.3 Adapter 是否被真正抽离了？

**没有彻底完成。**

观察结果：

- 第 1 轮候选中曾短暂出现：`TelegramProtocolAdapter`
- 但到第 5 轮最终候选时，Service 层仍保留：
  - `createInputPeer`
  - `request.toBytes()`
  - `client.sendRequest(...)`
  - `TLDeserializer(response)`
  - `cacheUsers(users: Array<TLUser>)`
  - `cacheChannels(channels: Array<TLChannel>)`

这说明：

- Translator 已经尝试理解“要抽 Adapter”；
- 但在多轮 Repair 中，它为了追着编译器消火，又把协议细节重新卷回了 Service；
- 即：**Adapter 抽离意识存在，但尚不稳定，容易在物理修语法时回退。**

## 5. 本轮最关键的系统结论

### 5.1 双证据 Repair 闭环已经打通

这是本轮最大的工程胜利：

- Review 未通过时，Compile 仍会执行；
- Compile 的 `stderr` 与 Reviewer 的 blocker 已经同时进入下一轮 Prompt；
- Orchestrator 没有 JSON 崩溃；
- 全 5 轮候选、review、verify 结果都被稳定落盘。

### 5.2 模型确实会响应“物理痛觉”

具体表现：

- `0L` 被去掉；
- 编译器开始把问题推进到更深层的仓颉语法：
  - `std.unsafe.*` 关键字冲突
  - `!` 非空断言
  - `Promise<T> { () => ... }` 形式
  - `Message?` 这类可空与返回类型写法

说明：

> 双路证据并联之后，模型确实不再只做“架构口头整改”，而是开始对真实 `cjc` 的痛点做局部手术。

### 5.3 但“同时完成 Adapter 抽离 + 语法修正”还没有一次到位

本轮更准确的结论是：

- **语法修正能力开始起效；**
- **架构隔离能力仍不稳定；**
- 二者同时达成，当前还没发生。

## 6. 当前最终状态

- `summary.json` 的 stage 级状态仍是 `passed`，表示“流水线执行完成”；
- 但 `orchestration.final_status` 实际为：`failed`

原因不是基建崩溃，而是：

- 5 轮内 Reviewer 仍持续拦截；
- 同时真实 `cjc` 仍持续报 syntax-level compile error。

这正符合本轮实验目的：

> 我们验证的是“修复逻辑链是否贯通”，不是“单文件翻译是否侥幸成功”。

## 7. 下一步建议

下一步最值得做的，不再是继续堆 Reviewer 规则，而是：

1. 为 `cangjie-syntax-pitfalls-v1` 出一个 `v1.1`：
   - 增补 `std.unsafe` 关键字转义
   - 增补 `!` 非空断言禁用
   - 增补 `Promise<T> { () => ... }` 这一类 closure / constructor 写法陷阱
2. 在 Translator Prompt 中进一步加入：
   - “若你暂时无法完全抽 Adapter，也不要把协议解析重新卷回 Service”
3. 若需要更强收敛，可以把 Repair 分成两个显式阶段：
   - 先做 `physical syntax stabilization`
   - 再做 `architecture isolation enforcement`

## 8. 最终裁决

Round 7 的结果不是“编译通过”，而是一个更重要的里程碑：

- **双路并联成功；**
- **真实 `cjc` 已进入自动主循环；**
- **模型已经开始在真实编译器压力下修改自身输出；**
- **`0L` 这类典型仓颉语法陷阱已被自动修掉；**
- **但 Adapter / ACL / Domain Purity 仍需要下一轮更强的约束与语法模板联动。**

