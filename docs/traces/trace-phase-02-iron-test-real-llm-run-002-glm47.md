# Trace - Phase-02 Telegram 核心模块 Real LLM Iron Test 002（GLM-4.7）

## 任务目标

在**不修改现有基建代码**、并继续保持 `--verify-dry-run` 的前提下，使用真实大模型对
`RealMessageService.ets` 执行一次完整的仓库级翻译流水线压测，验证以下三点：

- `Translator` 能否在 `9` 个依赖文件、`51` 条签名上下文与架构 Skill 约束下产出可读候选稿；
- `Reviewer` 能否稳定返回结构化 JSON，并拦截异步流 / 二进制协议 / 状态契约层面的架构缺陷；
- `Orchestrator` 的 `Translate -> Review -> Repair` 回路能否在真实模型下稳定迭代，并给出明确收敛或失败结论。

## 输入与执行命令

- 输入目录：`raw_docs/telegramharmony-phase02`
- 目标文件：`src/services/RealMessageService.ets`
- 目标模型：`Pro/zai-org/GLM-4.7`
- 调用网关：OpenAI 兼容网关（硅基流动）
- 验证模式：`--verify-dry-run`
- 解析模式：`--parser-mode ast`
- 依赖 Skill：
  - `skills/SKILL_SCHEMA_V2.md`
  - `skills/async-stream-and-binary-protocol-mapping.md`

执行命令：

```bash
python scripts/pipeline_runner.py \
  --src-root raw_docs/telegramharmony-phase02 \
  --target-file src/services/RealMessageService.ets \
  --run-root artifacts/pipeline_runs/phase02-iron-test-glm47 \
  --db-path artifacts/pipeline_runs/phase02-iron-test-glm47/repo_index.sqlite \
  --repo-map-path artifacts/pipeline_runs/phase02-iron-test-glm47/repo_map.txt \
  --tu-json-path artifacts/pipeline_runs/phase02-iron-test-glm47/RealMessageService.tu.json \
  --orchestration-output-path artifacts/pipeline_runs/phase02-iron-test-glm47/RealMessageService.orchestration.json \
  --summary-path artifacts/pipeline_runs/phase02-iron-test-glm47/summary.json \
  --failure-path artifacts/pipeline_runs/phase02-iron-test-glm47/failure.json \
  --schema-path skills/SKILL_SCHEMA_V2.md \
  --architecture-skill skills/async-stream-and-binary-protocol-mapping.md \
  --pattern-memory-path artifacts/pattern_memory/pattern_memory.jsonl \
  --workspace-root artifacts/pipeline_runs/phase02-iron-test-glm47/temp_workspace \
  --llm-model 'Pro/zai-org/GLM-4.7' \
  --parser-mode ast \
  --verify-dry-run \
  --max-rounds 3 \
  --timeout-seconds 120 \
  --llm-max-retries 1 \
  --no-mock-mode
```

## 模型探针结果

本轮先对可用旗舰模型做了最小 JSON mode 探针：

- `Pro/deepseek-ai/DeepSeek-V3.2`：可返回合法 JSON，但单次响应约 `29.05s`；
- `Pro/zai-org/GLM-4.7`：可返回合法 JSON，单次响应约 `1.20s`。

因此本轮正式 Iron Test 选用 `GLM-4.7`。

## 产物路径

- Run Root：`artifacts/pipeline_runs/phase02-iron-test-glm47`
- Summary：`artifacts/pipeline_runs/phase02-iron-test-glm47/summary.json`
- Orchestration：`artifacts/pipeline_runs/phase02-iron-test-glm47/RealMessageService.orchestration.json`
- Console Log：`artifacts/pipeline_runs/phase02-iron-test-glm47/console.log`
- TU：`artifacts/pipeline_runs/phase02-iron-test-glm47/RealMessageService.tu.json`
- 最终候选产物：`artifacts/pipeline_runs/phase02-iron-test-glm47/temp_workspace/20260326T145937Z-tu-pipeline-realmessageservice-src-services-realmessageservice.ets/attempt-03/src/services/RealMessageService.cj`
- 本 Trace：`docs/traces/trace-phase-02-iron-test-real-llm-run-002-glm47.md`

## 全局结果摘要

- `Run Started At = 2026-03-26T14:59:37Z`
- `Run Finished At = 2026-03-26T15:01:25Z`
- `Indexed Files = 10`
- `Symbols Indexed = 79`
- `Edges Indexed = 258`
- `TU Dependency Count = 9`
- `Pattern Examples Used = 3`
- `Repair Rounds = 2`
- `Pipeline Exit Code = 0`

需要特别说明：

- `summary.json` 的顶层 `status = passed`，表示流水线**执行完成**；
- 但 `RealMessageService.orchestration.json` 中 `final_status = failed`，且 `final_verify.failure_type = review-blocked`；
- 也就是说，本轮**工程链路跑通了，但翻译结果并未通过架构审查**。

这不是“业务翻译成功”，而是一次**真实模型博弈成功触发、且审查器有效拦截**的压测结果。

## 第一轮：Translator 初稿表现

第一轮候选稿落盘长度约 `4948 chars`，具备明显的上下文吸收能力：

- 正确保留了 `RealMessageService` 的服务层角色；
- 成功引用了 `MTProtoClient`、`TLMethods`、`TLSerialization`、`TLDialogs` 等关键依赖；
- 明确保留了“请求构造 -> 发送 -> TL 反序列化 -> Cache 更新 -> Signal 推送”的异步流拓扑；
- 在 `notes` 中主动声明了以下映射意识：
  - `Architecture Mapping`
  - `State Contract`
  - `Execution Topology`
  - `Dependency Constraint`

这说明：

- `async-stream-and-binary-protocol-mapping` 这张 Skill **已经真实进入 Translator 的注意力范围**；
- 但第一轮主要体现为“概念性吸收”，尚未上升为“结构性遵守”。

### 第一轮 Reviewer 拦截结果

Reviewer 返回了稳定的 JSON，并给出 `4` 条问题：

- `ARCH_STATE_CONTRACT_VIOLATION`（blocker）
- `ARCH_BINARY_PROTO_BOUNDARY_LEAK`（blocker）
- `ARCH_EXECUTION_TOPOLOGY_RACE`（major）
- `ARCH_STATE_CONSISTENCY_RISK`（major）

这说明 Reviewer 并没有被“大模型写得像样”所迷惑，而是准确地从架构约束层面否掉了初稿。

## 第二轮：Repair 后的改稿表现

第二轮候选稿长度约 `5018 chars`。相较第一轮，它开始显式响应 Repair Guidance：

- 试图更明确地对齐 `async-stream-and-binary-protocol-mapping`；
- 继续保留 Signal / Cache 双结构；
- 开始在 notes 中直接回应上轮的 blocker。

但 Reviewer 依然返回 `4` 条问题，变为：

- `ARCH_STATE_CONTRACT_VIOLATION`（blocker）
- `ARCH_EXECUTION_TOPOLOGY_RACE`（major）
- `ARCH_BINARY_PROTO_BOUNDARY_LEAK`（major）
- `ARCH_DEPENDENCY_MISSING`（major）

这里最关键的现象是：

- 模型开始“修旧病”，同时又引入了新的依赖契约问题；
- 这体现出真实仓库级翻译的典型难点：**局部修复可能打破另一层架构约束**。

## 第三轮：最终候选稿与收敛情况

第三轮候选稿长度约 `6509 chars`，已经出现明显的“修复性结构重写”：

- 新增 `pendingRequests` 去重表，试图解决并发请求竞态；
- 将 `fetchMessages` 拆为 `fetchMessages` + `doFetchMessages` 两段；
- 显式使用 `TLSerializer` 代替隐式 `toBytes()`；
- 保留了 `0x1cb5c415` 的向量边界检查；
- 继续将 `messageCache` 与 `messageSignals` 绑定更新。

从“自动修复意愿”角度看，这一轮明显更接近我们预期的工业级行为：

- 它不是简单重写原函数；
- 它已经开始根据 Reviewer 的批注重构执行拓扑；
- 它也能将修复说明写回 `notes`。

### 第三轮 Reviewer 仍然拦截的 4 个问题

最终仍被 Reviewer 拦下，问题为：

- `ARCH_STATE_CONTRACT_VIOLATION`（blocker）
- `ARCH_EXECUTION_TOPOLOGY_RACE`（blocker）
- `ARCH_DEPENDENCY_MISSING`（major）
- `ARCH_BINARY_PROTO_BOUNDARY_LEAK`（major）

关键证据点：

1. **State Contract**
   - `messageCache.set(...)` 与 `signal.set(...)` 仍然是分离语句；
   - Reviewer 认为这依旧不是严格意义上的“原子更新”。

2. **Execution Topology**
   - `getMessages` 仍然以 fire-and-forget 方式触发 `fetchMessages(...).catch(...)`；
   - Reviewer 认为这会让调用方在旧 Signal 上继续前进，仍属竞态。

3. **Dependency Constraint**
   - 第三轮虽然显式补上了 `TLSerializer`，但 Reviewer 进一步提升了要求；
   - 它认为 Service 层**根本不应该直接 new `TLSerializer` / `TLDeserializer`**，而应依赖更高层的协议客户端抽象。

4. **Binary Protocol Boundary Leak**
   - `0x1cb5c415` 这种 magic number 和协议解析逻辑仍然停留在 Service 层；
   - Reviewer 明确要求将其下沉到 Binary Protocol Adapter。

## 对三项实战问题的直接回答

### 1. Translator 初稿是否准确应用了 `async-stream-and-binary-protocol-mapping`？

**结论：部分应用，未完全落地。**

证据：

- 初稿已经体现出对异步请求链路、TL 编解码、Signal / Cache 双态结构的理解；
- 但它把这些规则更多地落实为“代码注释与流程保留”，而不是“架构边界收缩”；
- 尤其是在 `TLDeserializer`、协议 magic number、fire-and-forget Signal 刷新这三处，仍然没有真正满足 Skill 的高压约束。

### 2. Reviewer 是否成功指出瑕疵并返回有效 JSON？

**结论：是，而且非常稳定。**

证据：

- 三轮 `review_result.json` 都成功生成；
- 每轮都给出了结构化 issue list；
- issue 包含 `code / severity / message / evidence` 四类关键字段；
- 没有出现 JSON 解析失败或协议层崩溃。

这说明当前 Multi-Agent 闭环里，**Reviewer 已经是可信的架构守门员**。

### 3. Orchestrator 跑了几轮才结束？

**结论：共 3 轮翻译，发生了 2 次 Repair，最终因 Review Blocked 收束。**

也就是说：

- `Attempt 1`：初稿失败；
- `Attempt 2`：修复后仍失败；
- `Attempt 3`：再次修复后仍失败；
- 达到 `--max-rounds 3` 后停止。

## 最终 `.cj` 产物摘要

尽管本轮未通过最终架构审查，但第三轮产物已经具备高价值研究意义：

- 它实现了从“源代码直译”向“带执行拓扑修复意识的重构候选稿”演进；
- 其核心新增结构是：
  - `pendingRequests` 并发去重；
  - `doFetchMessages(...)` 内部拆分；
  - `TLSerializer` 显式序列化路径；
  - 更明确的 cache / signal 回写；
- 失败点已经不再是“模型不会写”，而是“模型还不能稳定地把协议层彻底下沉出 Service 层”。

换句话说：

- **Translator 已经有能力提出接近目标的候选实现；**
- **真正限制当前通过率的，是架构边界抽象还不够强。**

## 对项目的直接启示

这轮 Iron Test 给出的最重要信号不是“模型翻译失败”，而是：

1. 现有 L1/L2/L3 基建已经足够强，能够把复杂依赖、风险标签、架构 Skill 稳定喂给真实模型；
2. Reviewer 的 JSON 审查协议已经达到实战可用级别；
3. 当前卡点已从“上下文不足”正式升级为“架构抽象深度不足”；
4. `RealMessageService` 这种 MTProto / Signal / Binary Codec 混合模块，的确是第二阶段极佳的压测 Boss。

## 结论

本轮不是业务意义上的“翻译通过”，但它是一次**成功的真实世界基建压测**：

- 真实 LLM 已成功接入；
- Repo Index / Repo Map / TU / Prompt / Orchestrator 整条链已在真实模型上跑通；
- Reviewer 能稳定压住不合格候选稿；
- 系统已经不再是“盲翻代码”，而是在执行**有审查、有修复、有证据链的仓库级翻译博弈**。

对 Phase-02 来说，这一步非常关键：

- **我们已经确认：问题不在基建能不能跑，而在下一步要不要继续强化“协议适配器抽象”与“异步拓扑 Skill”。**

