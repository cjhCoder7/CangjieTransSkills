# Trace - Phase-02 Telegram 核心模块 Real LLM Iron Test 003（Protocol Isolation Round 2）

## 任务目标

在不修改任何基建代码、继续保持 `--verify-dry-run` 的前提下，使用真实旗舰模型对
`RealMessageService.ets` 再次执行完整仓库级翻译压测，重点检验两项新补丁是否真正生效：

- `skills/protocol-adapter-extraction-strategy.md`
- `skills/SKILL_SCHEMA_V2.md` 中新增的 `Architecture Review Gates` 与 `ARCH_PROTOCOL_ISOLATION` 天条

本轮核心问题不是“模型能否把代码写出来”，而是：

1. Translator 是否会主动把协议细节剥离出 `Service` 层；
2. Reviewer 是否会在第一时间用 `ARCH_PROTOCOL_ISOLATION` 精准拦截；
3. Repair 回路是否能逼着模型从“平移源码”升级到“分层重构”。

## 输入与执行命令

- 输入目录：`raw_docs/telegramharmony-phase02`
- 目标文件：`src/services/RealMessageService.ets`
- 模型：`Pro/zai-org/GLM-4.7`
- 网关：OpenAI 兼容网关（硅基流动）
- Parser：`ast`
- Verify：`--verify-dry-run`
- 额外挂载 Skill：
  - `skills/async-stream-and-binary-protocol-mapping.md`
  - `skills/protocol-adapter-extraction-strategy.md`

执行命令：

```bash
python scripts/pipeline_runner.py \
  --src-root raw_docs/telegramharmony-phase02 \
  --target-file src/services/RealMessageService.ets \
  --run-root artifacts/pipeline_runs/phase02-iron-test-glm47-round2-protocol-isolation \
  --db-path artifacts/pipeline_runs/phase02-iron-test-glm47-round2-protocol-isolation/repo_index.sqlite \
  --repo-map-path artifacts/pipeline_runs/phase02-iron-test-glm47-round2-protocol-isolation/repo_map.txt \
  --tu-json-path artifacts/pipeline_runs/phase02-iron-test-glm47-round2-protocol-isolation/RealMessageService.tu.json \
  --orchestration-output-path artifacts/pipeline_runs/phase02-iron-test-glm47-round2-protocol-isolation/RealMessageService.orchestration.json \
  --summary-path artifacts/pipeline_runs/phase02-iron-test-glm47-round2-protocol-isolation/summary.json \
  --failure-path artifacts/pipeline_runs/phase02-iron-test-glm47-round2-protocol-isolation/failure.json \
  --schema-path skills/SKILL_SCHEMA_V2.md \
  --architecture-skill skills/async-stream-and-binary-protocol-mapping.md \
  --architecture-skill skills/protocol-adapter-extraction-strategy.md \
  --pattern-memory-path artifacts/pattern_memory/pattern_memory.jsonl \
  --workspace-root artifacts/pipeline_runs/phase02-iron-test-glm47-round2-protocol-isolation/temp_workspace \
  --llm-model 'Pro/zai-org/GLM-4.7' \
  --parser-mode ast \
  --verify-dry-run \
  --max-rounds 3 \
  --timeout-seconds 120 \
  --llm-max-retries 1 \
  --no-mock-mode
```

说明：

- 本轮 API 凭证通过命令级临时环境变量注入，未写入仓库、文档或脚本；
- 命令结束后不存在持久 shell 环境残留；
- `/volume/wzhang/cky-workspace/my_projects/Cangjie/资源` 中的 Harmony 软件与插件本轮未启用，因为验证仍处于 dry-run。

## 产物路径

- Run Root：`artifacts/pipeline_runs/phase02-iron-test-glm47-round2-protocol-isolation`
- Summary：`artifacts/pipeline_runs/phase02-iron-test-glm47-round2-protocol-isolation/summary.json`
- Orchestration：`artifacts/pipeline_runs/phase02-iron-test-glm47-round2-protocol-isolation/RealMessageService.orchestration.json`
- Console Log：`artifacts/pipeline_runs/phase02-iron-test-glm47-round2-protocol-isolation/console.log`
- 最终候选：`artifacts/pipeline_runs/phase02-iron-test-glm47-round2-protocol-isolation/temp_workspace/20260326T154512Z-tu-pipeline-realmessageservice-src-services-realmessageservice.ets/attempt-03/src/services/RealMessageService.cj`
- 本 Trace：`docs/traces/trace-phase-02-iron-test-real-llm-run-003-protocol-isolation.md`

## 全局结果摘要

- `Run Started At`：从工作区时间戳可见为 `2026-03-26T15:45:12Z` 对应批次
- `summary.json.status = passed`
- `RealMessageService.orchestration.json.final_status = failed`
- `final_verify.failure_type = review-blocked`
- `Files Indexed = 10`
- `Symbols Indexed = 79`
- `Edges Indexed = 258`
- `TU Dependency Count = 9`
- `Pattern Examples Used = 3`
- `Repair Rounds = 2`
- `Round Count = 3`
- `Orchestration Duration ≈ 92.53s`

结论先行：

- **新规则生效非常明显。**
- `ARCH_PROTOCOL_ISOLATION` 在首轮就被精准触发。
- Translator 在第二轮开始明显收敛，主动抽出了 `TelegramProtocolAdapter`。
- 但最终仍未完全通过，因为问题焦点从“协议未剥离”转移到了“状态契约 / 执行拓扑 / 协议对象残留依赖”。

## 第一轮：Translator 的首次反应

### 结论

**第一轮没有乖乖听话。**

模型依然沿用了“源码平移”思路，只是在注释里口头承认应该隔离协议边界，但代码本体仍把二进制协议揉在 `RealMessageService` 里。

### 直接证据

第一轮候选文件中可以直接观察到：

- 没有出现 `TelegramProtocolAdapter`
- 没有出现 `protocolAdapter`
- 仍然出现 `TLDeserializer`
- 仍然出现 `sendRequest`
- 仍然出现 magic number `0x1cb5c415`
- 仍然在 Service 内部执行 `readInt32()` / `readString()` 与 `parseMessageContent(...)`

说明大模型的第一反应依然是典型的**翻译惰性**：

- 它“知道规则”；
- 但它优先保留了源代码结构；
- 即使 notes 中已经承认风险，它仍然选择“先保持功能等价，再说重构”。

这正是本次补丁要击中的行为模式。

## 第一轮：Reviewer 的雷霆打击

### 结论

**Reviewer 精准触发了我们刚刚写入 Schema 的协议隔离天条。**

第一轮 `review_result.json` 的问题码为：

- `ARCH_PROTOCOL_ISOLATION_VIOLATION`（blocker）
- `DEPENDENCY_CONSTRAINT_VIOLATION`（blocker）
- `BOUNDARY_CONTRACT_INFRACTION`（major）
- `ERROR_HANDLING_CONTRACT_VIOLATION`（major）

### 命中效果

这次拦截非常漂亮，因为它不是泛泛地说“架构不好”，而是直接把 Service 中不该存在的协议细节钉死：

- `TLDeserializer`
- `readInt32`
- `readString`
- magic number `0x1cb5c415`
- `request.toBytes()`
- `client.sendRequest(...)`
- `parseMessageContent(deserializer, ...)`

Repair Guidance 也非常明确，没有给 Translator 留“糊弄过去”的空间：

- 提取独立 `TelegramProtocolAdapter`
- 把 `TLSerialization` / `TLMethods` / `TLDialogs` 等低层依赖从 Service 抽走
- 让 Service 停止直接操作字节流和协议对象

换句话说：

- **这条天条不是写在纸上的。它在第一轮就被真正执行了。**

## 第二轮：Translator 是否开始学会剥离？

### 结论

**是，第二轮出现了非常明显的结构性转向。**

第二轮候选稿已经呈现出清晰的“Service + Adapter”雏形：

- 出现了 `TelegramProtocolAdapter`
- 出现了 `protocolAdapter` 成员注入
- 不再直接出现 `TLDeserializer`
- 不再直接出现 `sendRequest`
- 不再直接出现 `0x1cb5c415`
- notes 中明确写出“Extracted all TLSerialization/TLDeserializer logic into 'TelegramProtocolAdapter'”

### 这一轮的重要意义

这说明新 Schema + 新 Skill 的组合已经不只是“提升评论质量”，而是**真正改变了 Translator 的生成策略**：

- 第一轮：口头承认，代码不改
- 第二轮：开始主动做职责分层

这就是本轮压测最重要的胜利。

### 第二轮为什么仍被打回

虽然协议剥离已明显起效，但 Reviewer 第二轮仍然拦截了这些问题：

- `ARCH_STATE_CONTRACT_VIOLATION`
- `ARCH_EXECUTION_TOPOLOGY_RACE`
- `ARCH_DEPENDENCY_MISSING`
- `ARCH_BOUNDARY_LEAK`

焦点已经从“你为什么还在 Service 里读二进制”转移为：

1. cache 与 signal 的一致性仍然不严谨；
2. `spawn -> fetchMessages(...)` 的异步初始化仍然存在竞态；
3. import 与依赖声明不够干净；
4. 某些协议边界职责尚未完全下沉。

这意味着：

- **协议剥离战术已经奏效；**
- **下一阶段瓶颈不再是 raw protocol，而是 Service/Adapter 之间剩余的边界清洗。**

## 第三轮：最终产物形态

### 结论

**最终候选稿已经呈现出比较清晰的分层轮廓，但还没有“完全洁净”。**

第三轮候选稿中的积极变化：

- `RealMessageService` 持有 `protocolAdapter: TelegramProtocolAdapter`
- `fetchMessages(...)` 通过 `protocolAdapter.fetchHistory(req)` 获取领域结果
- `sendMessage(...)` 通过 `protocolAdapter.sendMessage(req)` 发出请求
- `createInputPeer` 已经不在 Service 中出现
- `TLDeserializer`、`sendRequest`、magic number 等 raw protocol 操作已不再留在 Service 主流程中

这说明经过 Repair 循环后，系统已经能够把最危险的协议细节逼出 Service 层。

### 但为什么仍未通过

第三轮剩余问题是：

- `ARCH_STATE_CONTRACT_VIOLATION`
- `ARCH_EXECUTION_TOPOLOGY_RACE`
- `ARCH_DEPENDENCY_MISSING`

对应残留症状：

1. **状态契约仍不达标**
   - `cacheLock` 持有期间直接调用 `Signal.set()`；
   - Reviewer 认为这会造成锁内同步投影，违反状态提交边界。

2. **执行拓扑仍有竞态**
   - `getMessages` 里仍然通过 `spawn` 触发异步刷新；
   - 但对 Promise 完成后的回流、去重与生命周期归属处理仍不够严谨。

3. **协议对象仍有残留依赖**
   - `cacheUsers(users: TLUser[])`
   - `cacheChannels(channels: TLChannel[])`
   - 这意味着 Service 虽然不再直接读 buffer，但仍然直接依赖 TL 协议对象，而不是纯领域对象。

### 一个很有意思的细节

第三轮 notes 中声称“移除了 Service 层对 TLSerializer/TLDeserializer/InputPeer* 的直接引用”，这在主流程上基本属实；
但 Reviewer 继续揪出了更深一层的问题：

- **协议隔离不只是“不碰字节流”，还包括“不让协议对象类型污染领域服务接口”。**

这说明 Reviewer 已经开始从“二进制剥离”升级到“类型边界剥离”。

## 对本轮三大关注点的直接回答

### 1. Translator 的首次反应如何？

**第一轮依旧死性不改。**

它仍然把 `TLDeserializer`、`sendRequest`、magic number 和 `parseMessageContent` 留在 `Service` 里，只是在注释和 notes 中承认这是风险。

### 2. Reviewer 是否精准触发了 `ARCH_PROTOCOL_ISOLATION`？

**是，而且命中非常精准。**

第一轮直接打出 `ARCH_PROTOCOL_ISOLATION_VIOLATION`，并明确要求：

- Service 不得直接操作 `TLDeserializer`
- Service 不得直接做 `readInt32()` / `readString()` / magic number 判断
- 必须提取 `TelegramProtocolAdapter`

这证明新 Schema 天条已经具备真实的“尚方宝剑”效果。

### 3. 最终 `.cj` 是否呈现清晰分层？

**部分达成。**

已经出现：

- Service 负责编排
- Adapter 负责协议调用
- raw protocol 细节已基本离开主 Service 流程

但还未完全达成，因为：

- Service 仍直接接触 `TLUser` / `TLChannel`
- Signal 提交与锁边界设计还不够干净
- 异步初始化拓扑还不够稳定

因此，当前最终产物应被判定为：

- **“协议剥离初步成功，但尚未达到架构可接受状态”。**

## 与上一轮 Iron Test 的对比结论

相比上一轮没有 `ARCH_PROTOCOL_ISOLATION` 天条的实弹结果，本轮最关键的进步是：

1. **Reviewer 首轮就把协议泄漏打成 blocker**，不再容忍“先保留源码结构”；
2. **Translator 在第二轮就开始主动引入 `TelegramProtocolAdapter`**；
3. **最终问题重心从 raw TL 解析转移到了状态、拓扑与残留类型污染**。

这说明：

- 新补丁没有白加；
- 它真的改变了多智能体博弈的走向；
- 大模型开始被迫学习“做边界剥离”，而不是只做字面翻译。

## 结论

这场“协议剥离之战”的结论非常积极：

- **第一枪就命中。** `ARCH_PROTOCOL_ISOLATION` 在真实模型上立即奏效；
- **第二轮开始，Translator 被逼出了真实的架构反应。** 它不再把 TLDeserializer 塞在 Service 里，而是开始提取 `TelegramProtocolAdapter`；
- **最终仍未完全通过，但失败原因已经升级。** 现在系统真正卡住的是更高阶的边界洁净度，而不是最粗糙的协议残留。

换句话说：

- 我们已经成功治住了大模型最危险的“翻译惰性”；
- 下一轮若继续压测，最值得强化的不再是“协议剥离”本身，而是：
  - Service 对协议对象类型的彻底脱敏；
  - Signal 提交与锁边界分离；
  - 异步初始化 / pending RPC 的生命周期收敛。

这不是一次“仍然失败”的 run。

这是一场已经把模型从“抄源码”逼到“开始做分层重构”的关键胜利。
