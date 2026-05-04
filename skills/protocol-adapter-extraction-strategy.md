# Skill Metadata
- Skill ID: `ARCH-PROTOCOL-ADAPTER-EXTRACTION-001`
- Skill Name: `protocol-adapter-extraction-strategy`
- Skill Class: `Architecture`
- Scope: 约束 ArkTS / HarmonyOS 中混杂在 Service 层的 MTProto、TL、Buffer、二进制编解码逻辑，在仓颉侧强制重构为独立协议适配层。该 Skill 重点解决“只做语句平移、不做边界剥离”的翻译惰性问题。
- Tags: `cangjie`, `arkts`, `telegram`, `mtproto`, `protocol-adapter`, `binary-protocol`, `service-boundary`, `architecture-review`
- Version: `V2.0-initial`

# Trigger Condition
- 任务触发条件：待翻译文件属于 `service`、`repository`、`message service`、`network facade`、`protocol client consumer` 等角色，且源码中出现 `TLSerializer`、`TLDeserializer`、`ArrayBuffer`、`Uint8Array`、`sendRequest`、`send(`、`toBytes()`、`readInt32()`、`readString()`、magic number、constructor id、buffer 拼接等迹象。
- 强制触发条件：生成结果位于仓颉侧的 `Service` / `Repository` / `UseCase` 层，却仍然直接导入或调用底层序列化器、反序列化器、TL buffer、原始二进制流、低层网络发送接口时，必须装载本 Skill，并触发 `ARCH_PROTOCOL_ISOLATION` 审查。
- 不适用条件：纯 UI 页面、纯状态仓、纯路由、纯本地持久化映射；或目标对象本身就是协议适配器 / codec / bridge 层，则不应强行再抽一层 Adapter。

# Core Concept
- 最短知识结论：
  - Service 层只处理领域输入输出，不直接处理二进制协议细节。
  - 所有 `TLSerializer` / `TLDeserializer` / `Uint8Array` / TLBuffer / raw send API 都应下沉到独立 `TelegramProtocolAdapter`。
  - 协议魔数、constructor id、buffer 拼接、字节流解析都属于 Adapter / Codec 边界，不能留在业务服务内部。
- 一句话风险提示：如果只是把 ArkTS 的 `sendRequest + TLDeserializer` 平移进仓颉 Service，得到的不是迁移代码，而是把原始耦合点原封不动搬进新语言。

# Architecture Mapping
- 源侧角色：ArkTS 中的 `RealMessageService`、`MessageRepository`、`MTProtoService` 等对象，往往同时承担“领域编排 + 请求构造 + 二进制编解码 + 状态回写”多重职责。
- 目标侧角色：仓颉侧应拆为 `MessageService` / `MessageRepository`（领域层） + `TelegramProtocolAdapter`（协议适配层） + `BinaryCodec` / `TLCodec`（编解码层，可内嵌于 Adapter）。
- 保留策略：可以保留领域对象名称、领域方法语义、请求结果类型、缓存更新时序和上层调用入口；可以沿用 `sendMessage`、`fetchMessages`、`MessageData` 等任务级命名。
- 重构策略：必须剥离所有 raw request bytes、TL constructor、magic number、二进制 reader/writer、直接 `sendRequest` 的细节；Service 只允许调用诸如 `protocolAdapter.fetchHistory(...)`、`protocolAdapter.sendMessage(...)` 这类强类型接口。

# Dependency Constraint
- 必需依赖：
  - `skills/SKILL_SCHEMA_V2.md`
  - `skills/async-stream-and-binary-protocol-mapping.md`
  - `skills/state-ownership-and-lifecycle.md`
  - `skills/signal-based-reactive-pipeline.md`
- 可选依赖：
  - `skills/tdlib-c-interop-bridge.md`
  - `skills/message-delta-merge-and-batching.md`
- 冲突依赖：
  - 任何鼓励在 Service 层直接操作 `Uint8Array` / TLBuffer / `TLSerializer` / `TLDeserializer` 的临时直译模式
  - 任何把 protocol response 直接投递到 UI / Signal 的捷径模式
- 环境前提：当前可以先在文档、Prompt 与 Reviewer 层执行本 Skill；若后续接入真实仓颉编译器与 DevEco / 仓颉插件，再对 Adapter 层的命名、模块位置与编译可用性做物理校验。

# Boundary Contract
- 边界类型：领域服务层 ↔ 协议适配层 ↔ 二进制 codec 层
- 输入：Service 传入强类型领域参数，如 `PeerId`、`SendMessageCommand`、`GetHistoryQuery`、`MessageData`。
- 输出：Adapter 返回强类型领域结果，如 `MessageData[]`、`SendMessageResult`、`HistoryBatch`、领域错误对象；不直接向 Service 暴露 `Uint8Array`、TL object、magic number。
- 生命周期归属：协议连接、request id、pending RPC、重试策略、buffer 生命周期归 `TelegramProtocolAdapter` 管；Service 只持有领域状态与投影状态。
- 资源释放责任：Adapter 负责释放或回收底层二进制 reader/writer、transport handle、native callback；Service 不得承担这些底层资源管理职责。
- 错误传递方式：底层协议错误先在 Adapter 内归类，再向上抛出领域可理解的错误，不允许把原始二进制解析异常直接暴露给页面层。

# Execution Topology
- 线程模型：Service 负责编排调用与状态提交；Adapter 负责 request build、send、decode；Codec 负责纯字节读写。涉及字节流处理时，应默认在非 UI 上下文完成。
- 主线程提交点：只有领域结果归并到状态仓 / Signal / store 时才允许进入 UI 相关主线程提交流程。
- 后台处理点：`Uint8Array` 组装、TL constructor 判断、`readInt32()` / `readString()` / buffer slicing、解压缩、去重、协议错误分类都应留在 Adapter / Codec。
- 串行要求：同一协议请求必须遵循 `Service intent -> Adapter call -> Codec build/decode -> Domain result -> State merge -> Projection publish` 的顺序；不允许跳过 Adapter 让 Service 直接接管 build/decode。
- 批处理要求：若同一 peer 或同一 dialog 存在多条消息批量同步，批量协议解码在 Adapter 内完成，Service 仅接收已结构化结果集合。

# State Contract
- 状态所有者：Service 持有 message cache、signal/store、领域状态快照；Adapter 持有 transport session、pending request、协议上下文。
- 真值来源：远端协议回包经 Adapter 正规解码后形成的领域对象是真值来源；Service 中的 cache 只是本地投影。
- 可变字段：Service 中允许变化的是领域对象集合、分页游标、发送状态；Adapter 中允许变化的是 request id、session state、buffer cursor。
- 衍生字段：UI 订阅状态、排序视图、去重后的 timeline 均属于 Service / projection 层的衍生结果，不属于协议真值。
- 持久化策略：如需持久化，持久化的是领域对象或其安全投影，不直接持久化 TLBuffer、raw bytes、未解析 payload。
- 一致性规则：Service 只在收到 Adapter 返回的强类型结果后更新状态；禁止一边在 Service 中手动解析字节、一边更新 cache / signal。

# Progressive Modules
## Module 1：概念最小版
- 识别 Service 中是否存在 `TLSerializer`、`TLDeserializer`、`Uint8Array`、`sendRequest`、magic number。
- 只要存在，就将其视为“需要提取 Adapter 层”的信号，而不是翻译模板。

## Module 2：常见映射
- ArkTS `MessagesGetHistory -> serialize -> sendRequest -> deserialize` 链路，迁移为 `protocolAdapter.fetchHistory(query): HistoryBatch`。
- ArkTS `sendMessage` 中的 raw request bytes，迁移为 `protocolAdapter.sendMessage(command): SendMessageResult`。

## Module 3：跨层模式
- Service 负责：参数校验、状态合并、信号发布、幂等协调。
- Adapter 负责：协议对象构造、序列化、网络发送、反序列化、协议错误转译。
- Codec 负责：纯字节读写和 TL constructor 分发。

## Module 4：工程级约束
- 若 Reviewer 在 Service 层看到 `TLSerializer`、`TLDeserializer`、`readInt32()`、`Uint8Array`、`ArrayBuffer`、magic number、`sendRequest`，必须直接否决。
- 修复方向不是“把调用包一层函数名”，而是物理提取出 `TelegramProtocolAdapter` 或同等职责层。

# Translation Mapping
- ArkTS 对应写法：Service 中直接 `request.toBytes()` / `client.sendRequest(bytes)` / `new TLDeserializer(response)`。
- 仓颉对应写法：Service 调用 `telegramProtocolAdapter.fetchHistory(query)` / `telegramProtocolAdapter.sendMessage(command)`，由 Adapter 内部处理 codec 与 transport。
- 允许差异：Adapter 的具体命名、模块拆分、codec 是否独立成子组件可以根据仓颉工程风格调整。
- 禁止直译点：禁止把 `TLSerializer`、`TLDeserializer`、`Uint8Array`、TL constructor、magic number、buffer 操作、raw send API 直接翻进 Service。

# Performance Envelope
- 主线程预算：Service 层不承担二进制编解码，避免 UI 主线程上出现大块 buffer 处理。
- 吞吐量关注点：批量消息同步、连续发送、历史拉取分页应尽量在 Adapter 内批量 build / decode，减少跨层来回拷贝。
- 内存关注点：raw bytes 生命周期必须缩短在 Adapter / Codec 内部，不应在 Service 中长期缓存大块二进制数据。
- 建议优化手段：复用 codec、集中错误分类、限制 Service 层对象复制次数、让 Adapter 输出最小必要的领域对象。

# Failure Model
- 常见编译失败：Service 直译后往往同时依赖领域类型与 TL codec 类型，导致类型边界混乱、接口泄漏、命名冲突。
- 常见运行失败：二进制 magic number 改动、constructor 解析错误、raw bytes 被错误复用、Service 与 Adapter 同时维护协议状态导致竞态。
- 高风险误用：
  - 在 Service 中直接 `new TLSerializer()` / `new TLDeserializer()`
  - 在 Service 中直接拼 `Uint8Array`、读写 buffer、判断 `0x1cb5c415` 这类 magic number
  - 在 Service 中直接调用 `sendRequest` / `send`
  - 把 Adapter 伪装成普通 helper，但仍让 Service 暴露二进制细节
- 恢复策略：先识别并清除 Service 中所有二进制与协议 API 触点，再补一个强类型 Adapter 接口，最后把状态更新逻辑回迁到 Service。

# Verification Matrix
- 单元测试：验证 Adapter 输入强类型 command / query 后，能返回结构化领域结果；验证 Service 在不接触 raw bytes 的情况下完成状态更新。
- Fake / Mock：mock `TelegramProtocolAdapter`，让 Service 只面向领域对象测试；mock transport 只在 Adapter 层测试，不上浮到 Service。
- 集成测试：验证 `Service -> Adapter -> Codec/Transport -> Adapter -> Service` 的完整链路，不允许跳过 Adapter。
- 手动验证：检查生成代码中 Service 是否仍导入 `TLSerializer`、`TLDeserializer`、`Uint8Array`、`ArrayBuffer`、`sendRequest` 等底层对象。
- 观测指标：
  - Service 层二进制 API 命中数应为 `0`
  - Service 层 raw bytes 变量数应为 `0`
  - Service 层底层协议 import 数应为 `0`
  - Adapter 层负责的 request/decode 调用数应为预期值

# Composition With Other Skills
- 前置 Skill：
  - `async-stream-and-binary-protocol-mapping`
  - `state-ownership-and-lifecycle`
- 常见组合：
  - 与 `signal-based-reactive-pipeline` 组合，用于确保 Service 只做状态投影；
  - 与 `tdlib-c-interop-bridge` 组合，用于未来原生桥接场景。
- 覆盖关系：当本 Skill 触发时，它会覆盖“Service 可暂时直接持有 codec / transport 细节”的任何默认宽松做法。
- 禁止组合：禁止与“快捷直译原协议栈到 Service 层”的临时迁移策略同时启用。

# Retrieval Fallback
- 官方文档入口：
  - HarmonyOS / ArkTS 并发与状态管理文档
  - MTProto / Telegram protocol 公开资料
- 仓库检索入口：
  - `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`
  - `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoClient.ets`
  - `raw_docs/telegramharmony-phase02/src/core/mtproto/TLSerialization.ets`
  - `raw_docs/telegramharmony-phase02/src/core/mtproto/TLMethods.ets`
- CLI / Python 检索示例：
  - `rg -n "TLSerializer|TLDeserializer|Uint8Array|ArrayBuffer|sendRequest\(|toBytes\(|readInt32\(|readString\(|0x[0-9a-fA-F]+" raw_docs/telegramharmony-phase02`
  - `python scripts/pipeline_runner.py --src-root raw_docs/telegramharmony-phase02 --target-file src/services/RealMessageService.ets --parser-mode ast --dump-prompt-only --prompt-dump-path artifacts/pipeline_runs/protocol-isolation-prompt.txt`
- 升级提问模板：若当前仓颉侧是否已有 `TelegramProtocolAdapter` 仍未知，应先向人类确认“目标工程是否允许新增协议适配层模块、命名空间和模块位置”，再继续实现。

# Security / Privacy Constraint
- 敏感数据范围：auth key、access hash、session bytes、原始消息 payload、用户标识、网络回包。
- 脱敏规则：trace 中只记录协议类别、长度、constructor 名称或摘要，不回显完整 payload 与完整凭据。
- 本地存储要求：除调试专门工件外，不在 Service 层落盘原始二进制流；如需落盘，限定在 Adapter 调试上下文并做脱敏。
- 日志限制：Service 不得直接打印 raw bytes、TL buffer、完整回包、完整 access hash。

# Migration Strategy
- 小样本做法：先在 Prompt / Reviewer 层明确“Service 不碰协议”，哪怕 Adapter 仍为伪代码或接口壳。
- 工程级替代方案：在真实仓颉工程中落地独立 `TelegramProtocolAdapter` 模块，并将 codec / transport / retry policy 逐步下沉到该层。
- 何时升级：一旦目标文件出现二进制流、magic number、raw request / response、`sendRequest`、TL codec 迹象，就必须从普通翻译升级为协议隔离迁移。
- 升级检查点：
  - Service import 中是否还出现底层协议依赖
  - Adapter 是否只暴露强类型接口
  - 编解码逻辑是否全部离开 Service
  - 错误是否已被翻译为领域错误

# Examples
- 示例一：ArkTS 耦合反例
  ```ts
  async fetchMessages(peerId: PeerId): Promise<Message[]> {
    const request = new MessagesGetHistory()
    request.peer = this.createInputPeer(peerId)
    const bytes = request.toBytes()
    const response = await this.client.sendRequest(bytes)
    const deserializer = new TLDeserializer(response)
    const vectorId = deserializer.readInt32()
    if (vectorId !== 0x1cb5c415) {
      return []
    }
    return this.parseMessages(deserializer)
  }
  ```
- 示例二：仓颉侧解耦目标伪代码
  ```text
  class MessageService {
      func fetchMessages(query: GetHistoryQuery): Array<MessageData> {
          let history = telegramProtocolAdapter.fetchHistory(query)
          stateStore.mergeHistory(query.peerId, history.messages)
          projector.publishHistory(query.peerId, stateStore.currentHistory(query.peerId))
          return history.messages
      }
  }

  class TelegramProtocolAdapter {
      func fetchHistory(query: GetHistoryQuery): HistoryBatch {
          let request = historyCodec.buildRequest(query)
          let payload = transport.send(request)
          return historyCodec.decodeHistory(payload)
      }
  }
  ```

# Test & Debug
- 快速验证步骤：
  1. 搜 Service 代码里是否还出现 `TLSerializer`、`TLDeserializer`、`Uint8Array`、`ArrayBuffer`、`sendRequest`；
  2. 若出现，直接判定 `ARCH_PROTOCOL_ISOLATION` 失败；
  3. 确认是否已有 `TelegramProtocolAdapter` 或等价职责层；
  4. 再检查 Service 是否只做状态归并与信号投影。
- 排错顺序：
  1. 先清除 Service 中所有协议 import；
  2. 再抽 Adapter 接口；
  3. 再下沉 codec / magic number / bytes handling；
  4. 最后修正状态回流与错误翻译。
- 常见误判：
  - “我只是包了一层 helper，所以不算协议泄漏”——错误，只要 Service 仍显式接触 bytes / codec / raw send，就仍然失败。
  - “我只保留一个 `readInt32()` 判断，不影响架构”——错误，magic number 判断本身就是协议边界。

# Sources
- 来源列表：
  - `skills/SKILL_SCHEMA_V2.md`
  - `skills/async-stream-and-binary-protocol-mapping.md`
  - `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`
  - `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoClient.ets`
  - `raw_docs/telegramharmony-phase02/src/core/mtproto/TLSerialization.ets`
  - `artifacts/pipeline_runs/phase02-iron-test-glm47/RealMessageService.orchestration.json`
  - `docs/traces/trace-phase-02-iron-test-real-llm-run-002-glm47.md`

# Known Gaps
- 当前空白：
  - 还未在真实仓颉编译器下验证 `TelegramProtocolAdapter` 的最终模块命名与工程位置；
  - 真实 TelegramHarmony 中某些协议路径可能进一步下沉到 transport / native bridge，本 Skill 当前先约束 Service ↔ Adapter 的主边界；
  - 若未来目标工程直接对接 TDLib，本 Skill 需要与 `tdlib-c-interop-bridge` 联合细化。

# Evolution Log
- 版本演进记录：
  - `[2026-03-26] [V2.0-initial] 新增协议适配器提取专项 Skill，针对真实 LLM Iron Test 中暴露出的“Service 层残留 TL codec / raw send / magic number”问题，提供反模式、目标分层与 Reviewer 否决口径。`
