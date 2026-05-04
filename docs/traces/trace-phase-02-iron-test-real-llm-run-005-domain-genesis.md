# Trace - Phase-02 Telegram 核心模块 Real LLM Iron Test 005（Domain Genesis Round 4）

## 任务目标

在不修改任何 Python 基建、继续保持 `--verify-dry-run` 的前提下，使用真实旗舰模型对
`RealMessageService.ets` 发起第四轮实弹压测，验证“实体创造授权”是否真的能逼着 Translator 生成领域实体与 ACL Mapper。

本轮挂载四张架构 Skill：

- `skills/async-stream-and-binary-protocol-mapping.md`
- `skills/protocol-adapter-extraction-strategy.md`
- `skills/anti-corruption-and-concurrency-strategy.md`
- `skills/acl-mapper-and-domain-genesis-strategy.md`

本轮核心问题：

1. Translator 是否终于敢于创建领域实体，例如 `DomainUser` / `ChatMessage`；
2. Translator 是否会生成 `TelegramAclMapper` / `DomainMapper`；
3. `createInputPeer` 这类协议对象构造器能否被彻底从 Service 中拔除；
4. 最终能否拿到真正的 `passed`。

## 输入与执行命令

- 输入目录：`raw_docs/telegramharmony-phase02`
- 目标文件：`src/services/RealMessageService.ets`
- 模型：`Pro/zai-org/GLM-4.7`
- 网关：OpenAI 兼容网关（硅基流动）
- Parser：`ast`
- Verify：`--verify-dry-run`

执行命令：

```bash
python scripts/pipeline_runner.py \
  --src-root raw_docs/telegramharmony-phase02 \
  --target-file src/services/RealMessageService.ets \
  --run-root artifacts/pipeline_runs/phase02-iron-test-glm47-round4-domain-genesis \
  --db-path artifacts/pipeline_runs/phase02-iron-test-glm47-round4-domain-genesis/repo_index.sqlite \
  --repo-map-path artifacts/pipeline_runs/phase02-iron-test-glm47-round4-domain-genesis/repo_map.txt \
  --tu-json-path artifacts/pipeline_runs/phase02-iron-test-glm47-round4-domain-genesis/RealMessageService.tu.json \
  --orchestration-output-path artifacts/pipeline_runs/phase02-iron-test-glm47-round4-domain-genesis/RealMessageService.orchestration.json \
  --summary-path artifacts/pipeline_runs/phase02-iron-test-glm47-round4-domain-genesis/summary.json \
  --failure-path artifacts/pipeline_runs/phase02-iron-test-glm47-round4-domain-genesis/failure.json \
  --schema-path skills/SKILL_SCHEMA_V2.md \
  --architecture-skill skills/async-stream-and-binary-protocol-mapping.md \
  --architecture-skill skills/protocol-adapter-extraction-strategy.md \
  --architecture-skill skills/anti-corruption-and-concurrency-strategy.md \
  --architecture-skill skills/acl-mapper-and-domain-genesis-strategy.md \
  --pattern-memory-path artifacts/pattern_memory/pattern_memory.jsonl \
  --workspace-root artifacts/pipeline_runs/phase02-iron-test-glm47-round4-domain-genesis/temp_workspace \
  --llm-model 'Pro/zai-org/GLM-4.7' \
  --parser-mode ast \
  --verify-dry-run \
  --max-rounds 3 \
  --timeout-seconds 120 \
  --llm-max-retries 1 \
  --no-mock-mode
```

说明：

- 本轮真实 API 调用仍采用命令级临时环境变量注入，没有写入仓库；
- 因为仍处于 dry-run，本轮未切换到真实仓颉编译器与插件。

## 新增规则

### 1. 领域实体创造授权

`skills/acl-mapper-and-domain-genesis-strategy.md` 明确告诉 Translator：

- 如果源 ArkTS 直接使用 `TLUser` / `TLMessage` 等协议实体，**你必须创造对应的最小领域模型**；
- 可以显式创建 `DomainUser`、`ChatMessage`、`DomainChannel` 等结构；
- 不允许因为“怕幻觉”就把 `TL*` 类型继续塞在 Service 里。

### 2. Mapper 强制范式

同一 Skill 还规定：

- 必须有集中式 `TelegramAclMapper` / `DomainMapper`
- 必须存在类似：
  - `mapUser(tlUser: TLUser): DomainUser`
  - `mapMessage(tlMessage: TLMessage): ChatMessage`
- 不允许把 DTO 字段搬运逻辑散落在 Service 各处。

### 3. Schema 极限施压

`skills/SKILL_SCHEMA_V2.md` 中的 `ARCH_DOMAIN_PURITY` 进一步升级：

- Reviewer 不仅检查字段和内部状态；
- 还强制检查 **方法签名（入参 / 返回值）**；
- 只要出现 `TL*`、`ArrayBuffer`、`Uint8Array` 这类底层类型，直接一票否决。

## 产物路径

- Run Root：`artifacts/pipeline_runs/phase02-iron-test-glm47-round4-domain-genesis`
- Summary：`artifacts/pipeline_runs/phase02-iron-test-glm47-round4-domain-genesis/summary.json`
- Orchestration：`artifacts/pipeline_runs/phase02-iron-test-glm47-round4-domain-genesis/RealMessageService.orchestration.json`
- Console Log：`artifacts/pipeline_runs/phase02-iron-test-glm47-round4-domain-genesis/console.log`
- 最终候选：`artifacts/pipeline_runs/phase02-iron-test-glm47-round4-domain-genesis/temp_workspace/20260326T160703Z-tu-pipeline-realmessageservice-src-services-realmessageservice.ets/attempt-03/src/services/RealMessageService.cj`
- 本 Trace：`docs/traces/trace-phase-02-iron-test-real-llm-run-005-domain-genesis.md`

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

结论先行：

- **Round 4 依然没有拿到真正的 `passed`。**
- 但这轮第一次出现了“领域实体雏形”的尝试：第二轮生成了 `UserInfo` / `ChannelInfo`。
- 然而模型仍然没有真正生成 `DomainUser` / `ChatMessage` / `TelegramAclMapper`。
- 第三轮甚至出现了一个新的偏航：它开始创造 `PeerDTO` / `MessageDTO`，但这仍然不是纯领域实体，而是另一层 DTO。

## 第一轮：终极 Skill 是否立刻生效？

### 结论

**Reviewer 立刻生效，但 Translator 首稿非常保守。**

第一轮问题码：

- `ARCH_PROTOCOL_ISOLATION`
- `ARCH_DOMAIN_PURITY`
- `ARCH_CONCURRENCY_SAFETY`
- `ARCH_STATE_CONTRACT`

第一轮候选稿仍然保留：

- `cacheUsers(users: Array<TLUser>)`
- `cacheChannels(channels: Array<TLChannel>)`
- `createInputPeer(peerId): InputPeer`
- `TLDeserializer`
- 同步块外/异步回调内直接更新 `messageCache` 与 `messageSignals`

最关键的是：

- **没有 `DomainUser`**
- **没有 `ChatMessage`**
- **没有 `TelegramAclMapper`**
- **没有 `DomainMapper`**

说明：

- 尽管终极 Skill 已经明确授权“可以创造领域实体”；
- 但模型第一反应依然是：先尽量保守，不敢主动重建领域层。

## 第二轮：Translator 第一次出现“实体创造尝试”

### 结论

**第二轮第一次出现了真正的实体重命名动作。**

这轮候选稿出现了：

- `cacheUsers(users: Array<UserInfo>)`
- `cacheChannels(channels: Array<ChannelInfo>)`
- `ReentrantLock`
- `TelegramProtocolAdapter`

这是 Round 4 最大的亮点。

因为相比前几轮一直死守 `TLUser` / `TLChannel`，这一次模型终于迈出了“自创业务实体壳”的第一步。

### 为什么这一步仍不够

尽管有进步，但第二轮仍然被打回，主要原因有四个：

1. **领域实体还不够彻底**
   - 虽然 `TLUser` / `TLChannel` 从部分签名中消失了；
   - 但 `createInputPeer` 仍然在 Service 中保留；
   - 说明协议构造责任还没真正下沉。

2. **没有生成集中式 Mapper**
   - `UserInfo` / `ChannelInfo` 只是“换了个壳”；
   - 但没有 `TelegramAclMapper` / `DomainMapper` 来承担 DTO→Domain 的集中清洗。

3. **并发契约仍然不稳定**
   - 锁确实出现了；
   - 但 `spawn` 与锁范围仍然相互缠绕；
   - Reviewer 继续打 `ARCH_CONCURRENCY_RACE_CONDITION`。

4. **状态契约仍有细小窗口期**
   - 尽管开始尝试拆分更新与发布；
   - 但信号引用的获取和发布边界仍然不够纯净。

### 第二轮最重要的信号

- **实体创造授权不是无效的。**
- 模型已经第一次敢于不照抄 `TLUser` / `TLChannel`，而是尝试生成 `UserInfo` / `ChannelInfo`。

这说明 Domain Genesis Skill 已经开始改变它的生成心理模型。

## 第三轮：模型为什么又“拐弯”了？

### 结论

第三轮没有走到真正的领域模型，反而生成了：

- `PeerDTO`
- `MessageDTO`
- `ITelegramProtocolAdapter`

也就是说，模型终于学会了“不要直接暴露 `InputPeer`”，但它并没有走到 `DomainUser` / `ChatMessage`；
它选择了一个更保守的中间解：**继续创造 DTO，而不是创造 Domain Entity。**

### 第三轮的积极变化

- `createInputPeer` 已经从第三轮候选中消失；
- `ITelegramProtocolAdapter` 明确出现；
- `ReentrantLock` 仍然保留；
- `fetchMessages` / `sendMessage` 通过 Adapter 做主要交互；
- `sig.set()` 与锁边界分离得比前几轮更清晰。

### 第三轮为什么仍然失败

最终 Reviewer 仍然给出：

- `ARCH_DOMAIN_PURITY_VIOLATION`
- `ARCH_DEPENDENCY_ISOLATION_LEAK`
- `ARCH_CONCURRENCY_RACE_CONDITION`

根因是：

1. **模型创造了 DTO，但没有创造 Domain**
   - `PeerDTO` / `MessageDTO` 仍然是“传输对象思维”；
   - 它们没有完成“业务语义提纯”；
   - 也没有出现 `DomainUser` / `ChatMessage` 这种业务命名。

2. **`TLUser` / `TLChannel` 依然残留在 Service 签名中**
   - Reviewer 明确指出：
     - `cacheUsers(users: Array<TLUser>)`
     - `cacheChannels(channels: Array<TLChannel>)`
   - 说明领域纯洁度仍未达标。

3. **Mapper 仍然缺席**
   - 虽然 DTO 层多了一层；
   - 但没有集中式 `TelegramAclMapper` / `DomainMapper` 来做 DTO→Domain 清洗；
   - 所以服务层的语义纯化仍然没有完成闭环。

## 对本轮核心问题的直接回答

### 1. Translator 是否终于敢于定义 `DomainUser`？

**没有完全做到。**

- 第一轮：完全不敢
- 第二轮：第一次敢创造 `UserInfo` / `ChannelInfo`
- 第三轮：转而创造 `PeerDTO` / `MessageDTO`

所以这轮的真实结论是：

- **模型已经被我们逼到敢“创造新类型”**；
- **但它还不稳定，不总能创造出真正的领域实体。**

### 2. Translator 是否写出了 Mapper 转换逻辑？

**没有写出我们想要的集中式 `TelegramAclMapper`。**

- 没有出现 `TelegramAclMapper`
- 没有出现 `DomainMapper`
- 没有出现明确的 `mapUser(TLUser) -> DomainUser`
- 没有出现明确的 `mapMessage(TLMessage) -> ChatMessage`

也就是说：

- 它学会了造“壳”；
- 但还没学会把“DTO→Domain 变换”单独抽象成稳定层。

### 3. `createInputPeer` 这种协议构造器有没有被彻底拔掉？

**到第三轮，基本被拔掉了。**

这说明我们对“协议对象构造不能留在 Service”的压制开始真正起效。

但因为 DTO / Domain 边界还没完全建立，系统仍然不能通过最终审查。

### 4. 这次拿到真正的 `passed` 了吗？

**没有。**

`summary.json` 仍然只是流水线完成；
真正的 `orchestration.final_status` 仍然是 `failed`，原因依旧是 `review-blocked`。

## 与 Round 3 相比，Round 4 赢在哪里？

Round 4 的关键胜利不是“通过了”，而是：

1. **领域实体创造授权首次产生可见效果**
   - 第二轮第一次出现 `UserInfo` / `ChannelInfo`
   - 这说明模型终于开始摆脱“只能照抄 TL 类型”的心理惯性

2. **协议构造器进一步下沉**
   - 第三轮里 `createInputPeer` 已不再是主要残留问题的中心
   - 模型已经更接近“Service 不碰协议构造”的目标

3. **模型开始区分 DTO 与 Domain 的概念，但仍然停留在 DTO 层**
   - 这是本轮最微妙也最重要的观察：
   - 它不是完全不会抽象；
   - 它是在“DTO”这一级就停住了，没再向“Domain”迈最后一步。

## 结论

Round 4 仍未打通，但它把我们的认知推进到了一个非常关键的位置：

- 模型已经不是单纯不会分层；
- 它已经会：
  - 提取 Adapter
  - 提取接口
  - 引入锁
  - 移动 Signal 发布边界
  - 创造新的类型壳
- 但它还不会稳定地完成：
  - **DTO → Domain 的最后一步语义跃迁**
  - **集中式 ACL Mapper 的成型**

换句话说：

- 我们已经把它从“源码平移器”训练成了“会分层、会收口、会局部创造新类型的架构候选生成器”；
- 当前真正差的，就是最后一脚：
  - 从 `UserInfo` / `PeerDTO` 这种模糊中间层
  - 走到 `DomainUser` / `ChatMessage` / `TelegramAclMapper` 这种明确业务层。

这是一种非常高质量的失败。

它说明下一步如果要真正冲击 `passed`，最有价值的方向不是再泛化规则，而是：

- **专门围绕“Mapper 层产出模板 + Domain 字段最小白名单”做最后一次定点打击。**
