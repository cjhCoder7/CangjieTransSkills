# Trace - Phase-03 RealMessageService 物理编译 Iron Test 005（Round 10 / Hard Template + Zero-Tolerance Reviewer）

## 1. 本轮目标

Round 10 的目标非常明确：

1. 用 `domain-purity-hard-template` 封死 `ProtocolContext`、`createInputPeer`、`TL*`、`InputPeer`、`Buffer` 等所有协议泄漏逃生门；
2. 给 Reviewer 增加 `ARCH_SYNTAX_REGRESSION` 零容忍门槛，发现 `0L` / `0UL` / `import ... from` / `std.unsafe.*` / `!` / `!!` 就直接打回；
3. 观察大模型在“黑名单 + 白名单 + 真实编译器”三重高压下，是否终于放弃投机取巧。

## 2. 本轮改造

### 2.1 新增硬模板 Skill

新增：`skills/domain-purity-hard-template.md`

核心策略：

- **点名批评伪隔离**：`ProtocolContext` 这类把协议对象或协议元数据打包后再喂给 Service 的行为，一律视作作弊；
- **绝对黑名单**：Service 层构造函数、字段、方法签名、内部变量中，严禁出现：
  - `TL*`
  - `InputPeer`
  - `ArrayBuffer` / `Uint8Array` / `Buffer`
  - 任意带 `Protocol` 字眼的上下文对象
  - `createInputPeer`
- **严格白名单**：Service 只能认识基础类型和纯领域模型，如 `Int64`、`String`、`Bool`、`DomainUser`、`ChatMessage`。

### 2.2 升级 Reviewer 零容忍规则

修改内容：

- `skills/SKILL_SCHEMA_V2.md`
- `scripts/prompt_assembler.py`

新增硬门槛：

- `ARCH_SYNTAX_REGRESSION`
  - 一旦代码里出现 `0L`、`0U`、`0UL`、ArkTS `import ... from`、`std.unsafe.*`、`!`、`!!`，Reviewer 必须直接判失败；
- `THOUGHT_CODE_CONSISTENCY`
  - 如果 `repair_thought_process` 里说“会隔离 Adapter / ACL / Domain”，但代码里仍保留 `ProtocolContext`、`TL*`、`InputPeer`、`createInputPeer`、`Buffer`，则按 `ARCH_DOMAIN_PURITY_VIOLATION` 或 `ARCH_PROTOCOL_ISOLATION` 直接打回。

## 3. 本轮执行配置

运行目录：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-007-round10-hard-template`

关键参数：

- 模型：`Pro/zai-org/GLM-4.7`
- Parser：`ast`
- 真实编译器：Linux x64 `cjc`
- 最大轮数：`5`
- 架构 Skill 顺序：
  1. `domain-purity-hard-template`
  2. `cangjie-syntax-pitfalls-v1.2`
  3. `protocol-adapter-extraction-strategy`
  4. `anti-corruption-and-concurrency-strategy`
  5. `acl-mapper-and-domain-genesis-strategy`
  6. `domain-mapper-golden-template`
  7. `async-stream-and-binary-protocol-mapping`

## 4. 最终结果

- `summary.json.status = passed`（表示流水线阶段跑完）
- `RealMessageService.orchestration.json.final_status = failed`（表示业务结果未通过）

五轮结果：

1. Round 1：Reviewer 未通过，Compile 未通过
2. Round 2：Reviewer 未通过，Compile 未通过
3. Round 3：**Reviewer 通过，Compile 未通过**
4. Round 4：Reviewer 未通过，Compile 未通过
5. Round 5：Reviewer 未通过，Compile 未通过

## 5. 本轮关键发现

### 5.1 黑名单生效了：语法倒退会被直接点名

Round 10 最大的正向变化是：

- Reviewer 已不再“等编译器再说”；
- 只要发现语法倒退，立即用 `ARCH_SYNTAX_REGRESSION` 打回。

首轮就直接命中：

- `import std.unsafe.*`
- `getOrThrow()` 这类非空断言变体

第二轮继续命中：

- `import std.\`unsafe\`.*`
- `!this.messageSignals.containsKey(key)`

也就是说：

> Round 10 的 Reviewer 已经从“架构审查员”升级成“语法退化哨兵”。

### 5.2 硬模板确实逼住了伪隔离，但没有彻底逼出白名单产物

正面变化：

- `ProtocolContext` 没再成为主逃生门；
- 模型更频繁地显式讨论 `DomainUser`、`DomainChannel`、`TelegramProtocolAdapter`。

但坏消息是：

- 它仍然持续把 `TLUser` / `TLChannel` 留在 Service 方法签名中；
- `createInputPeer` 仍未完全下沉；
- 甚至改头换面成 `MTProtoAdapter`、`IProtocolAdapter` 等新壳子继续留协议痕迹。

也就是说：

> 模型已经不敢直接玩 `ProtocolContext` 了，但仍在尝试用“新壳子 + 旧污染”继续绕规则。

### 5.3 Round 3 出现了一次 Reviewer 漏判

这是本轮最关键的反直觉现象。

Attempt 3 中：

- `review_passed = true`
- 但代码里仍能检索到：
  - `TLUser`
  - `TLChannel`
  - `0UL`
  - `import std.unsafe.*`
  - `!this.messageSignals.contains...`
  - `implements IMessageService`

随后 `cjc` 立即把它打爆，错误包括：

- `implements` 语法不合法
- lambda / 类型注解写法不合法

这说明：

> 黑名单规则已经进入 Reviewer Prompt，但 Reviewer 仍然存在一次明显漏判。

换句话说，Round 10 并没有证明“Reviewer 完美可靠”，反而证明了：

- Prompt 级零容忍已经有效；
- 但在极端复杂输出上，LLM Reviewer 仍然可能短暂失手；
- 真实编译器依旧是不可替代的第二裁判。

### 5.4 `repair_thought_process` 继续稳定命中

和 Round 9 一样，Round 10 的五轮里：

- 五轮全部成功落下 `repair_thought_process`；
- 这说明内置 JSON 思维链已经稳定，不再是偶然现象。

所以本轮可以确认：

> `repair_thought_process` 已经成为流水线的稳定观测点，不需要再回退到 XML 方案。

### 5.5 模型仍未真正接受“Service 白名单”

虽然硬模板已经明确规定：

- Service 只能认识基础类型和纯领域模型；
- 不能认识 `TL*`、`InputPeer`、`Buffer`、任何带 `Protocol` 字样的上下文对象；

但最终第 5 轮候选仍出现：

- `TLUser`
- `TLChannel`
- `getOrThrow()`
- `MTProtoAdapter` / `IProtocolAdapter`
- `import std.unsafe.*` 的畸形残留（甚至被拆成多行）

这说明模型的当前真实状态是：

> 它已经知道什么是“正确方向”，但还没学会稳定地产出“极其粗暴、干净”的 Service 白名单切分。

## 6. 本轮裁决

Round 10 的结果不是“通过”，但它完成了两件非常重要的事：

1. **语法黑名单终于前置生效**
   - `ARCH_SYNTAX_REGRESSION` 已经能在 Reviewer 阶段直接触发；
2. **伪隔离逃生门被压缩**
   - `ProtocolContext` 这种显眼作弊路线基本被打掉；
   - 但模型仍然会通过 `TLUser` / `createInputPeer` / `IProtocolAdapter` 等残留继续挣扎。

一句话结论：

> Round 10 把模型从“明目张胆作弊”逼到了“偷偷夹带协议残留”的阶段；防腐网已经明显收紧，但距离真正的白名单 Service 还有最后一刀。

## 7. 下一步最合理的方向

如果继续推进，最值钱的不是再加抽象原则，而是再补一把**结构化硬断言**：

1. 在 Orchestrator 里增加“候选代码 grep 黑名单”前置检查；
2. 只要命中 `TL*`、`InputPeer`、`createInputPeer`、`Protocol`、`unsafe`、`0L/0UL`、`import ... from`，直接在进入 Reviewer 前就标记为结构违规；
3. 用规则引擎补 Reviewer 的偶发漏判，而不是继续完全依赖 LLM 自觉。
