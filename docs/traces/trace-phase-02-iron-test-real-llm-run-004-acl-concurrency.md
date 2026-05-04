# Trace - Phase-02 Telegram 核心模块 Real LLM Iron Test 004（ACL + Concurrency Round 3）

## 任务目标

在不修改任何 Python 基建、继续保持 `--verify-dry-run` 的前提下，使用真实旗舰模型对
`RealMessageService.ets` 发起第三轮实弹压测，重点验证三张架构 Skill 的联合压制效果：

- `skills/async-stream-and-binary-protocol-mapping.md`
- `skills/protocol-adapter-extraction-strategy.md`
- `skills/anti-corruption-and-concurrency-strategy.md`

本轮关注点：

1. Reviewer 是否能在前两轮精准抓住 `TLUser` / `TLChannel` 这类协议对象残留；
2. Translator 是否会主动引入 ACL Mapper / DomainMapper，把 `TL*` DTO 清洗为领域模型；
3. Translator 是否会真正收敛到“锁内更新快照、锁外发布 Signal”的并发契约；
4. 最终是否有机会拿到真正的 `passed`。

## 输入与执行命令

- 输入目录：`raw_docs/telegramharmony-phase02`
- 目标文件：`src/services/RealMessageService.ets`
- 模型：`Pro/zai-org/GLM-4.7`
- 网关：OpenAI 兼容网关（硅基流动）
- Parser：`ast`
- Verify：`--verify-dry-run`
- 挂载 Skill：
  - `skills/async-stream-and-binary-protocol-mapping.md`
  - `skills/protocol-adapter-extraction-strategy.md`
  - `skills/anti-corruption-and-concurrency-strategy.md`

执行命令：

```bash
python scripts/pipeline_runner.py \
  --src-root raw_docs/telegramharmony-phase02 \
  --target-file src/services/RealMessageService.ets \
  --run-root artifacts/pipeline_runs/phase02-iron-test-glm47-round3-acl-concurrency \
  --db-path artifacts/pipeline_runs/phase02-iron-test-glm47-round3-acl-concurrency/repo_index.sqlite \
  --repo-map-path artifacts/pipeline_runs/phase02-iron-test-glm47-round3-acl-concurrency/repo_map.txt \
  --tu-json-path artifacts/pipeline_runs/phase02-iron-test-glm47-round3-acl-concurrency/RealMessageService.tu.json \
  --orchestration-output-path artifacts/pipeline_runs/phase02-iron-test-glm47-round3-acl-concurrency/RealMessageService.orchestration.json \
  --summary-path artifacts/pipeline_runs/phase02-iron-test-glm47-round3-acl-concurrency/summary.json \
  --failure-path artifacts/pipeline_runs/phase02-iron-test-glm47-round3-acl-concurrency/failure.json \
  --schema-path skills/SKILL_SCHEMA_V2.md \
  --architecture-skill skills/async-stream-and-binary-protocol-mapping.md \
  --architecture-skill skills/protocol-adapter-extraction-strategy.md \
  --architecture-skill skills/anti-corruption-and-concurrency-strategy.md \
  --pattern-memory-path artifacts/pattern_memory/pattern_memory.jsonl \
  --workspace-root artifacts/pipeline_runs/phase02-iron-test-glm47-round3-acl-concurrency/temp_workspace \
  --llm-model 'Pro/zai-org/GLM-4.7' \
  --parser-mode ast \
  --verify-dry-run \
  --max-rounds 3 \
  --timeout-seconds 120 \
  --llm-max-retries 1 \
  --no-mock-mode
```

说明：

- 本轮真实 API 凭证仍使用命令级临时环境变量注入，没有写入仓库文件；
- 因为命令在单次 shell 中执行，结束后不存在持久环境残留；
- `/volume/wzhang/cky-workspace/my_projects/Cangjie/资源` 中的 Harmony 软件与插件本轮未启用，因为验证仍然是 dry-run。

## 新规则补丁

### 新增 Skill

- `skills/anti-corruption-and-concurrency-strategy.md`

其核心新增了两条硬约束：

1. **ARCH_DOMAIN_PURITY**
   - Service 层绝对禁止出现 `TLUser`、`TLMessage`、`TLChannel` 等协议 DTO；
   - Adapter / ACL Mapper 必须把 `TL*` DTO 清洗为 `AppUser`、`ChatMessage`、`HistoryBatch` 等领域模型后再返回给 Service。

2. **ARCH_CONCURRENCY_SAFETY**
   - async callback / `spawn` / Promise `then` 中不得裸写共享状态；
   - 锁内禁止 `Signal.set()`；
   - 必须使用明确的并发原语收口共享状态，并采用“锁内更新快照、锁外发布 Signal”的两阶段提交策略。

### Schema 升级

`skills/SKILL_SCHEMA_V2.md` 新增 Reviewer 硬门槛：

- `ARCH_DOMAIN_PURITY`
- `ARCH_CONCURRENCY_SAFETY`

这意味着：

- Reviewer 不再只查“有没有 TLDeserializer / sendRequest”；
- 还会继续追杀“有没有 `TLUser[]` 残留在 Service 签名里”；
- 以及“有没有在异步流中裸写 cache / Signal，或锁内发射 Signal”。

## 产物路径

- Run Root：`artifacts/pipeline_runs/phase02-iron-test-glm47-round3-acl-concurrency`
- Summary：`artifacts/pipeline_runs/phase02-iron-test-glm47-round3-acl-concurrency/summary.json`
- Orchestration：`artifacts/pipeline_runs/phase02-iron-test-glm47-round3-acl-concurrency/RealMessageService.orchestration.json`
- Console Log：`artifacts/pipeline_runs/phase02-iron-test-glm47-round3-acl-concurrency/console.log`
- 最终候选：`artifacts/pipeline_runs/phase02-iron-test-glm47-round3-acl-concurrency/temp_workspace/20260326T155708Z-tu-pipeline-realmessageservice-src-services-realmessageservice.ets/attempt-03/src/services/RealMessageService.cj`
- 本 Trace：`docs/traces/trace-phase-02-iron-test-real-llm-run-004-acl-concurrency.md`

## 全局结果摘要

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
- `Orchestration Duration ≈ 103.36s`

结论先行：

- **这一次依旧没有拿到真正的 `passed`。**
- 但新补丁在首轮就起效，并把问题从“有没有协议字节流残留”进一步上移到“有没有 DTO 污染”和“有没有并发契约违约”。
- 这说明系统仍在向更高阶的架构标准收敛，而不是停留在表层修修补补。

## 第一轮：ACL 与并发规则是否立即生效？

### 结论

**是，而且是双命中。**

第一轮 Reviewer 直接给出：

- `ARCH_DOMAIN_PURITY_VIOLATION`（blocker）
- `ARCH_CONCURRENCY_SAFETY_VIOLATION`（blocker）
- `ARCH_PROTOCOL_ISOLATION_LEAK`（major）
- `STATE_CONTRACT_INVALIDATION`（major）

### 直接观察

第一轮候选代码仍然存在以下问题：

- `cacheUsers(users: Array<TLUser>)`
- `cacheChannels(channels: Array<TLChannel>)`
- `createInputPeer(...)` 仍在 Service 内部构造 `InputPeerUser` / `InputPeerChannel`
- `fetchMessages` 与 `sendMessage` 的 async Promise 回调中直接裸写 `messageCache` 与 `messageSignals`
- 没有 `TelegramAclMapper`
- 没有 `DomainMapper`
- 没有 `Mutex` / `ReentrantLock`

这说明：

- Translator 第一轮仍然偏向“源码平移 + 注释自我解释”；
- 但 Reviewer 已经不再放过 DTO 类型残留和并发裸写这两类问题。

### 第一轮最关键的意义

相比上一轮只靠协议隔离天条，本轮第一时间就把：

- `TLUser` / `TLChannel` 残留
- 异步回调里无锁共享状态写入

都打成了硬性 blocker。

这意味着新的 ACL / 并发规则已经成为真正的审查武器，而不是装饰性文档。

## 第二轮：Translator 是否出现 ACL / 锁语义进化？

### 结论

**出现了明显进化，但还不够彻底。**

第二轮候选稿的积极变化：

- 出现了 `ITelegramProtocolAdapter`
- 出现了 `TelegramProtocolAdapter`
- 出现了 `ReentrantLock`
- 开始尝试把 serialization / deserialization 收口到 Adapter 内部
- 开始用锁保护缓存和信号更新

### 但它为什么仍被打回

第二轮 Reviewer 给出的主要问题是：

- `ARCH_DOMAIN_PURITY_VIOLATION`
- `ARCH_PROTOCOL_ISOLATION_LEAK`
- `ARCH_CONCURRENCY_SAFETY_VIOLATION`
- `ASYNC_TOPOLOGY_MISMATCH`

关键原因：

1. **ACL 仍然缺位**
   - 虽然长出了 Adapter，但没有长出 `TelegramAclMapper` / `DomainMapper`；
   - `cacheUsers(users: ArrayList<TLDialogs.TLUser>)` 这类签名依然直接暴露协议对象。

2. **协议隔离仍不彻底**
   - `createInputPeer(peerId)` 依然留在 Service 内；
   - 这说明模型学会了“把二进制解析下沉”，但还没有学会“把协议对象构造也一并下沉”。

3. **并发修复方式还不成熟**
   - 模型选择了最直接的 `synchronized` / `ReentrantLock`；
   - 但仍然把 `sig.set(...)` 放进同步块里，触发了新的并发契约警报。

### 第二轮最重要的判断

- **模型开始有了修复动作，但修复是局部的、工具化的。**
- 它能加锁，能抽接口，但还不会自然地引入“ACL Mapper + 锁外发布快照”这种更高阶模式。

## 第三轮：最终候选稿长什么样？

### 结论

**第三轮候选稿比第二轮更像一个“规范化的 Service + Adapter”骨架，但仍然没有达到通过标准。**

第三轮积极变化：

- 明确保留了 `protocolAdapter: ITelegramProtocolAdapter`
- `fetchMessages(...)` / `sendMessage(...)` 通过 Adapter 执行主要协议调用
- 使用了 `ReentrantLock`
- 将 `sig?.set(...)` 挪到了锁外
- 不再直接出现 `TLDeserializer`、magic number 和 raw bytes 解析主流程

### 但最终仍然失败的原因

第三轮仍被 Reviewer 拦下：

- `ARCH_DOMAIN_PURITY_VIOLATION`（blocker）
- `ARCH_PROTOCOL_ISOLATION_LEAK`（blocker）
- `ASYNC_TOPOLOGY_MISMATCH`（major）

具体残留问题：

1. **领域纯洁度仍不合格**
   - `cacheUsers(users: ArrayList<TLUser>)`
   - `cacheChannels(channels: ArrayList<TLChannel>)`
   - 说明 Service 仍然直接消费协议 DTO，没有真正长出 Mapper。

2. **协议隔离仍有缺口**
   - `createInputPeer(peerId: PeerId): InputPeer` 依然由 Service 构造；
   - 这意味着协议对象虽然不再参与 bytes 解析，但仍然污染了 Service 的职责边界。

3. **异步拓扑仍不够纯净**
   - 虽然 `sig?.set(...)` 已经移到锁外；
   - 但 Reviewer 进一步提高了要求：`sig?.set(rawMessages)` 仍然紧贴锁释放点，且没有显式不可变快照 / 专门 publish 阶段；
   - 它认为这仍然不足以证明“发布动作不会触发重入或状态不一致”。

### 这轮最值得注意的进步

- 第二轮被打的 `ARCH_CONCURRENCY_SAFETY_VIOLATION` 到第三轮已经不再出现；
- 这说明锁内 Signal 发布这件事，**Translator 确实被我们逼着改掉了**。

也就是说：

- ACL 还没完全长出来；
- 但并发契约已经被逼近了一大步。

## 对本轮核心问题的直接回答

### 1. Reviewer 在前两轮是否精准指出 `TLUser` 残留？

**是。**

- 第一轮直接指出 `cacheUsers(users: Array<TLUser>)` 与 `cacheChannels(channels: Array<TLChannel>)`；
- 第二轮继续追打 `ArrayList<TLDialogs.TLUser>` 这种变体签名；
- 第三轮仍然抓到 `ArrayList<TLUser>` / `ArrayList<TLChannel>`。

这说明 `ARCH_DOMAIN_PURITY` 的命中效果非常稳定，不会被简单的命名调整绕过去。

### 2. Translator 是否被逼出了 Mapper 映射逻辑？

**没有完全逼出来。**

- 它学会了 Adapter；
- 学会了 Interface；
- 学会了锁；
- 甚至学会了把 `sig.set()` 挪到锁外；
- 但它始终没有真正生成 `TelegramAclMapper` / `DomainMapper`，也没有把 `TLUser` / `TLChannel` 替换成 `AppUser` / `ChatMessage` 这类纯领域模型。

这说明当前模型对“协议剥离”理解得更深，对“DTO→Domain 防腐层”理解得还不够本能。

### 3. 第三轮是否拿到了真正的 `passed`？

**没有。**

`summary.json` 仍然只是表示流水线执行完成；真正的 `orchestration.final_status` 仍然是 `failed`，失败原因仍是 `review-blocked`。

## 与上一轮相比，本轮到底赢在哪里？

尽管仍未通过，但本轮有三点实质性进展：

1. **ACL 天条首轮即生效**
   - `TLUser` / `TLChannel` 的协议对象残留第一次被明确打成 blocker；
   - 这意味着 Service 层的“最后一丝协议毒瘤”已经被正式纳入硬审查范围。

2. **并发天条迫使模型修正锁/Signal 边界**
   - 第二轮仍然锁内 `sig.set(...)`；
   - 到第三轮，这个问题已经被修到锁外；
   - 虽然仍未完全满足更严苛的发布阶段要求，但方向是明显正确的。

3. **系统失败的位置继续上移**
   - 第一阶段：卡在协议 bytes / TLDeserializer
   - 第二阶段：卡在 Adapter 提取
   - 第三阶段：卡在 DTO→Domain ACL 与最终发布契约

这说明：

- 我们不是在原地打转；
- 而是在一层层拔掉架构毒瘤后，被更高阶的 Reviewer 继续逼上去。

## 结论

这次 Round 3 没有拿到真正的 `passed`，但它再次证明了一件更重要的事：

- **只靠 Skill / Prompt / Reviewer，而不改基建，我们依然能持续抬高大模型的架构下限。**

当前系统的真实状态可以概括为：

- 协议 bytes 与 raw TL 解析：大体已能逼出 Service
- Adapter 提取：已经开始稳定出现
- 锁内 Signal 发布：已经被逼着改掉
- DTO→Domain ACL：仍然是当前最大的硬骨头

也就是说，距离真正 `passed`，现在只差最后一层最顽固的“类型防腐层本能”。

如果把前几轮比作“让模型别抄原文”，那这一轮已经进入了：

- **逼模型学会业务分层语言学**
- **逼模型理解 DTO 与 Domain 不是同一种东西**

这是非常高阶、也非常有价值的失败。

对项目来说，这轮并不意味着停滞，而意味着：

- 下一枪已经非常明确——
- **不是再加更多锁，也不是再强调 Adapter，而是要专门训练它生成 `AclMapper` / `DomainMapper` 这一层。**
