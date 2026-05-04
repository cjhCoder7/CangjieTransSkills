# Skill Metadata
- Skill ID: `ARCH-ASYNC-STREAM-BINARY-PROTOCOL-001`
- Skill Name: `async-stream-and-binary-protocol-mapping`
- Skill Class: `Architecture`
- Scope: 聚焦 ArkTS 服务层与 MTProto 协议层之间的异步调用、二进制序列化/反序列化、transport callback 回流、Signal 状态更新与缓存一致性映射。
- Tags: `Architecture`, `AsyncFlow`, `Promise`, `Signal`, `BinaryProtocol`, `MTProto`, `Transport`, `StateContract`
- Version: `2.0.0`

# Trigger Condition
- 任务触发条件: 当源代码同时出现 `async/await`、`Promise<...>`、`Signal<...>`、序列化器/反序列化器、请求发送与回包解析链路时触发。
- 强制触发条件:
  - 检测到 `sendRequest(...)` + `TLSerializer` / `TLDeserializer` 组合；
  - 检测到 `SignalPipe` / `ValueSignal` 与本地缓存并存；
  - 检测到 transport callback、pending request map、或回包驱动状态更新。
- 不适用条件:
  - 纯静态 UI 页面；
  - 只有简单 HTTP JSON 请求、没有协议对象与状态回流；
  - 只有单函数算法转换、没有仓库级依赖闭包。

# Core Concept
- 最短知识结论: 不要把这类源码看成“几个 async 方法”，而要把它看成“请求构造 → 发送 → 二进制回包解析 → 本地缓存更新 → Signal 投递”的完整执行拓扑。
- 一句话风险提示: 如果把协议对象、缓存、Signal 和 transport callback 拍扁成一个同步函数，翻译结果几乎一定在状态一致性与边界语义上出错。

# Architecture Mapping
- 源侧角色:
  - Service Layer: `RealMessageService` 一类业务服务，持有 cache 与 signal。
  - Protocol Client Layer: `MTProtoClient` 一类会话与 RPC 管理器。
  - Binary Codec Layer: `TLSerializer` / `TLDeserializer`。
  - Transport Layer: `TCPTransport` / callback。
- 目标侧角色:
  - Message Gateway / Repository Facade
  - Async Request Coordinator
  - Binary Protocol Adapter
  - Signal / Store Projection Layer
  - Transport Event Bridge
- 保留策略:
  - 保留“缓存是真值投影、Signal 是订阅出口、协议对象负责边界建模”的分层。
- 重构策略:
  - 将 `Promise` 链与 transport callback 明确重构为可追踪的异步拓扑；
  - 将 parser / serializer 提炼为边界对象，不与 UI / Store 混写；
  - 将 cache 更新与 signal 提交分离为两个明确步骤。

# Dependency Constraint
- 必需依赖:
  - 协议对象定义（如 `InputPeer`、`MessagesSendMessage`）
  - 编解码器定义（如 `TLSerializer`、`TLDeserializer`）
  - 异步请求入口（如 `sendRequest`）
  - 状态出口（如 `Signal` / `Store`）
- 可选依赖:
  - 压缩/解压层（如 `Inflate`）
  - crypto / auth key 管理
- 冲突依赖:
  - 不要把 transport callback 直接与 UI 组件耦合；
  - 不要让 `TLDeserializer` 在页面层被直接操作；
  - 不要让缓存变更和 UI 提交复用同一个隐式副作用块。

# Boundary Contract
- 边界类型:
  - Async Boundary
  - Binary Protocol Boundary
  - Transport Callback Boundary
  - State Projection Boundary
- 输入:
  - 业务请求参数
  - 协议对象字节流
  - transport 回包字节流
- 输出:
  - 协议层响应对象或错误
  - 本地 cache 变更
  - Signal / Store 更新
- 生命周期归属:
  - pending RPC map 归协议客户端；
  - message cache 归业务服务；
  - Signal / Store 归投影层；
  - transport callback 归连接层。
- 错误传递方式:
  - 网络/transport 错误 → request coordinator 或 gateway error；
  - 协议解析错误 → binary adapter error；
  - 业务状态错误 → service-level validation error。

# Execution Topology
- 线程/阶段模型:
  - Request Build Stage: 组装 `InputPeer` / request bytes
  - Async Send Stage: `sendRequest` 发出协议请求
  - Decode Stage: `TLDeserializer` 解析回包
  - State Merge Stage: 更新 cache / accessHash / message list
  - Projection Stage: 将新状态投递给 `Signal` / store
- 主线程提交点:
  - 如果最终状态影响 UI，提交点必须被显式隔离，不能隐式藏在 transport callback 里。
- 后台处理点:
  - 编解码、协议字段读取、Delta 合并、去重等应优先在非 UI 上下文完成。
- 串行要求:
  - 同一 request 的 build → send → decode → merge 必须保序；
  - 同一 peer 的 cache merge 不能与 UI 投递交错失序。

# State Contract
- 状态所有者:
  - accessHash cache: service 层
  - message cache: service 层
  - pending RPCs: protocol client 层
  - Signal / projected state: 响应式层
- 真值来源:
  - 协议回包是真值来源；
  - cache 是本地投影；
  - Signal 只是订阅出口，不应成为隐式真值源。
- 一致性规则:
  - 先更新 cache，再刷新 signal；
  - 失败请求不得污染成功缓存；
  - parser 错误不得伪造默认消息对象吞掉异常。

# Translation Mapping
- ArkTS `async fetchMessages(...): Promise<Message[]>` -> 仓颉异步请求协调器 + 显式结果类型
- ArkTS `TLDeserializer.readInt32()/readString()` -> 仓颉二进制 reader 封装
- ArkTS `messageCache.set(...)` -> 仓颉本地状态仓更新
- ArkTS `signal.set(newState)` -> 仓颉投影提交层
- ArkTS transport callback -> 仓颉事件桥 / 后台事件入口

# Verification Matrix
| 验证目标 | 输入条件 | 预期结果 | 验证层次 |
|---|---|---|---|
| 请求构造顺序正确 | 给定 peerId / text | 先构造协议对象再发送 | 单测 |
| 编解码边界未被拍扁 | 给定字节流回包 | 解析逻辑仍在 binary adapter 中 | 单测 |
| cache 与 signal 顺序正确 | 收到消息列表更新 | 先 cache 后 signal | 集成测试 |
| 失败不会污染状态 | sendRequest 抛错 | cache 不写脏数据 | 单测 |
| callback 不直写 UI | transport 收到数据 | 通过状态投影层回流 | 架构审查 |

# Composition With Other Skills
- 上游 Skill:
  - `state-ownership-and-lifecycle`
  - `signal-based-reactive-pipeline`
  - `main-thread-ui-boundary`
- 并行参考 Skill:
  - `message-delta-merge-and-batching`
- 后续组合 Skill:
  - 若未来引入 Native TDLib，则与 `tdlib-c-interop-bridge` 叠加
- 组合顺序:
  1. 先确定状态所有权；
  2. 再确定 async / protocol 拓扑；
  3. 最后确定 UI 提交边界。

# Retrieval Fallback
- CLI / Python 检索示例:
  - `rg -n "sendRequest\(|TLDeserializer|TLSerializer|SignalPipe|ValueSignal|Promise<" raw_docs/telegramharmony-phase02`
  - `python scripts/pipeline_runner.py --src-root raw_docs/telegramharmony-phase02 --target-file src/services/RealMessageService.ets --mock-mode --verify-dry-run`
- 官方资料回查入口:
  - Telegram MTProto 文档
  - HarmonyOS ArkTS 响应式与并发文档
- 降级策略:
  - 若当前只能使用 regex 索引，则必须在 reviewer 阶段人为补查 method 级语义，避免把 class 级摘要当成真实执行拓扑。

# Security / Privacy Constraint
- 不要在日志中回显完整协议 payload 或鉴权字段；
- 不要把 access hash、auth key、session bytes 作为普通字符串在跨层传递；
- 不要把 transport error object 原样透传到 UI。

# Migration Strategy
- 最小迁移路径:
  1. 先锁定 `sendRequest`、codec、cache、signal 四段式链路；
  2. 再补 peer / request object 映射；
  3. 最后处理 callback / main-thread 细节。
- 过渡层:
  - 可先保留协议对象名称与字段结构，避免第一轮就扁平化重写。
- 回滚点:
  - 若协议 adapter 不稳定，可先冻结在“请求构造 + 回包记录 + 不提交 UI”的阶段进行调试。

# Examples
- 概念性示例:
  ```
  RequestBuilder -> BinaryClient.send -> ResponseDecoder -> CacheMerger -> SignalProjector
  ```
- 伪代码:
  ```
  let request = buildHistoryRequest(peer)
  let bytes = await protocolClient.send(request)
  let parsed = responseDecoder.decodeHistory(bytes)
  cache.merge(peer, parsed.messages)
  projector.publish(peer, cache.current(peer))
  ```
- 反例:
  ```
  // 反例：把 build / send / decode / cache / UI 更新揉成一个函数
  async func bad() {
      let x = await sendRaw(...)
      state.messages = parseEverything(x)
  }
  ```

# Test & Debug
- 单测策略:
  - 分别验证 request build、decode、cache merge；
- 集成验证:
  - 验证 `fetchMessages` / `sendMessage` 的状态回流；
- 诊断日志:
  - 记录 request id、peer key、cache size、signal publish 次数；
- 排错步骤:
  - 先看 repo index 是否抓到 method；
  - 再看 TU 是否带齐 codec / client / transport；
  - 再看 reviewer 是否识别出 state / execution topology 维度。

# Sources
- 输入来源:
  - `raw_docs/telegramharmony-phase02/SOURCE_METADATA.json`
  - `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`
  - `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoClient.ets`
  - `raw_docs/telegramharmony-phase02/src/core/mtproto/TLSerialization.ets`
  - `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoTransport.ets`
- 引用依据:
  - `https://github.com/ForestBook/TelegramHarmony`

# Known Gaps
- 当前公开仓库未见显式 TDLib / NAPI bridge，因此本 Skill 当前聚焦“纯 ArkTS MTProto 栈”；
- regex fallback 无法稳定抽取带返回类型注解的 class methods；
- 若后续引入 tree-sitter，本 Skill 的 Trigger Condition 可更精细化。

# Evolution Log
- 版本记录: `2.0.0`
- 本次改动: 新增 Phase-02 Telegram 核心通信模块专项 Skill，覆盖 async 流、binary protocol、transport callback 与状态投影边界。
- 后续补强方向: 与未来真实 TDLib bridge、编译期类型检查器与错误分类器联动。
