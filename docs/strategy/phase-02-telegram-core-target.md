# Phase-02 Telegram 核心模块压测目标

## 文档目的

本文件用于定义第二阶段的首个“核心通信模块”压测目标，明确：

- 为什么选它，而不是其它文件；
- 它会暴露我们当前 Repo Index / Repo Map / TU / Orchestrator 哪些短板；
- 当前 TelegramHarmony 公开仓库与我们原先设想（TDLib bridge / MessageRepository）的差异在哪里；
- 后续压测与 Skill 精调应该围绕哪些高风险点推进。

## 外部来源版本

- 来源仓库：`https://github.com/ForestBook/TelegramHarmony`
- 默认分支：`main`
- 调研日期：`2026-03-26`
- 调研时锁定 commit：`31af11b6f63e7e40c447dd4274b421b800016193`
- 说明：以下判断均以该 commit 的公开内容为准，后续若仓库结构调整，应重新核对。

## 一、典型架构判断

基于公开目录树与文档，当前 TelegramHarmony 更接近“纯 ArkTS MTProto 栈”，而不是“ArkTS + TDLib C++ 桥接栈”。

### 1.1 当前公开结构的关键层次

- `entry/src/main/ets/core/mtproto/`
  - 协议核心层，包含 `MTProtoClient.ets`、`MTProtoTransport.ets`、`TLSerialization.ets`、`TLMethods.ets`、`AuthKeyCreator.ets` 等。
- `entry/src/main/ets/services/`
  - 服务编排层，包含 `RealMessageService.ets`、`RealChatListService.ets`、`RealServiceAdapter.ets` 等。
- `core/services/src/main/ets/`
  - 抽象接口层，包含 `IMessageService.ets`、`IChatListService.ets` 等。
- `common/signalkit/`
  - 响应式基础设施。

### 1.2 与预期差异

用户最初建议的“`MTProtoService` / `MessageRepository` / TDLib 桥接点”在当前公开仓库里并没有以这些名字直接出现。

当前更贴近现实的判断是：

- **消息业务边界**：`RealMessageService.ets`
- **协议会话边界**：`MTProtoClient.ets`
- **二进制编解码边界**：`TLSerialization.ets`
- **网络与平台边界**：`MTProtoTransport.ets`

因此，本阶段不应虚构一个“已经存在的 TDLib/NAPI 模块”，而应先围绕当前真实存在的 MTProto 栈压测。

## 二、“最终 Boss”候选名单

| 候选 | 位置 | 优势 | 不足 | 结论 |
|---|---|---|---|---|
| `RealMessageService.ets` | `entry/src/main/ets/services/RealMessageService.ets` | 同时碰到消息缓存、Signal、InputPeer 构造、请求发送、响应解析，是业务层与协议层的交界面 | 没有显式 C++ FFI | **主目标** |
| `MTProtoClient.ets` | `entry/src/main/ets/core/mtproto/MTProtoClient.ets` | 覆盖 Promise、pending RPC、transport callback、auth key 生命周期 | 更偏协议引擎，不直接代表消息业务语义 | **一级依赖目标** |
| `TLSerialization.ets` | `entry/src/main/ets/core/mtproto/TLSerialization.ets` | 高密度二进制序列化/反序列化，是最容易翻译失真的区域 | 单独看业务意义较弱 | **一级依赖目标** |
| `MTProtoTransport.ets` | `entry/src/main/ets/core/mtproto/MTProtoTransport.ets` | 最接近平台网络边界，暴露 callback / socket / 错误对象处理 | 业务语义不足 | **二级依赖目标** |
| `RealServiceAdapter.ets` | `entry/src/main/ets/services/RealServiceAdapter.ets` | 会话恢复、服务装配、存储回调都在此汇聚 | 更像装配层，不是第一刀最好的 TU | 候补 |

## 三、最终选定目标

### 3.1 主目标

**`RealMessageService.ets`** 作为 Phase-02 首个压测目标。

### 3.2 依赖闭包中的关键伴随模块

- `MTProtoClient.ets`
- `TLSerialization.ets`
- `TLMethods.ets`
- `TLDialogs.ets`
- `MTProtoTransport.ets`
- `AuthKeyCreator.ets`
- `MTProtoConfig.ets`
- `CryptoUtils.ets`
- `Inflate.ets`

### 3.3 选择理由

`RealMessageService.ets` 是当前公开仓库里最像“仓库级翻译真正会撞墙的地方”的文件，因为它同时覆盖：

1. **复杂异步逻辑**
   - `Promise` / `async` / `await`
   - 服务调用与回包解析
   - 响应式信号刷新

2. **高复杂度协议编解码**
   - `TLSerializer` / `TLDeserializer`
   - `InputPeer` / `MessagesSendMessage` / `MessagesGetHistory`
   - 二进制协议字段读写与解析分支

3. **跨层状态协调**
   - `messageCache`
   - `messageSignals`
   - `userAccessHashes` / `channelAccessHashes`

4. **边界风险集中**
   - 服务层调用协议层
   - 协议层调用 transport 层
   - transport callback 回流到业务层与 UI 响应式层

## 四、它会重点压测哪些基建能力

### 4.1 对 L1 Repo Index 的压力

- 多行 import 提取是否完整；
- 类 / 方法 / 顶层函数抽取是否稳定；
- `Promise<...>`、`Signal<...>`、联合类型与泛型是否会导致符号识别断裂；
- call edge 是否能正确归属于方法，而不是错误归到整个 class。

### 4.2 对 L2 Repo Map 的压力

- 地图能否把“业务服务 → 协议客户端 → 编解码器 → 传输层”的结构看清楚；
- 能否把 `signal-or-store`、`async-flow`、`callback-entry` 这些风险标签提炼出来；
- 能否在不爆 token 的前提下保留必要闭包。

### 4.3 对 L3 TU Bundler 的压力

- `RealMessageService` 不应孤立翻译，必须自带 `MTProtoClient`、`TLSerialization`、`TLMethods` 这些签名摘要；
- TU 中不仅要有依赖文件，还要显式带出：
  - 访问 hash 缓存语义；
  - 发送请求与解析响应的顺序；
  - Signal 与本地 cache 的双层状态结构。

### 4.4 对 L4 Verify / Repair 的压力

- Reviewer 不能只看 Markdown 结构，要能识别：
  - 状态所有权是否漂移；
  - async 边界是否被错误平铺；
  - parser / serializer 是否被拍扁成字符串拼接；
  - transport callback 是否直接污染 UI 状态。

## 五、当前与“TDLib 桥接”目标的关系

当前公开仓库**未发现显式 TDLib / NAPI / CPointer / ffi / native bridge 文件**。这意味着：

- 第二阶段第一刀应该先在 **纯 ArkTS MTProto 栈** 上验证仓库级翻译底座；
- 一旦后续拿到私有或新增的 TDLib bridge 源码，再把已有 `skills/tdlib-c-interop-bridge.md` 串进来；
- 当前不应把 `Boundary Contract` 错误地写成“已存在的 C++ 互操作实现”，而应写成“**二进制协议边界 + socket 回调边界 + 未来可扩展的 native boundary 占位**”。

## 六、Phase-02 首批检查清单

### 6.1 必查冲突点

- `Promise` / `async` 方法签名是否在索引中丢失；
- `Signal<Message[]>` 这类泛型返回值是否导致 method 节点断裂；
- `TLDeserializer` / `TLSerializer` 的 method 粒度是否在 repo map 中丢失；
- `MTProtoTransport` 中 callback 相关 method 是否能被识别；
- 服务层方法内的 call edge 是否被错误归到 class 级别。

### 6.2 Skill 侧必须补的能力

- 异步流与回调合流映射；
- 二进制协议对象与解析器映射；
- 服务层状态缓存 + Signal 更新的一致性约束；
- Transport callback 与主线程状态提交的隔离策略。

## 七、下一阶段建议执行顺序

1. 先用当前 `regex-fallback` 结果建立 parser gap 基线；
2. 再引入 `tree-sitter` 或更强结构解析补强 method 抽取；
3. 用 `RealMessageService.ets` 做第一批 TU / Review / Verify 针对性调参；
4. 等纯 ArkTS MTProto 栈稳定后，再进入更重的 TDLib / C-Interop 模块。

## 结论

Phase-02 的“最终 Boss”不是一个想象中的 `MessageRepository`，而是 **`RealMessageService.ets` 及其 MTProto 闭包**。

它足够真实、足够复杂、足够靠近协议核心，又不会因为仓库中尚未公开的 TDLib bridge 而让我们的压测目标失真。这是当前最适合拿来检验第二阶段基建硬度的第一块真石头。
