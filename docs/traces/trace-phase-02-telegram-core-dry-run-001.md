# Trace - Phase-02 Telegram 核心模块 Dry-Run 001

## 任务目标

验证当前基建在面对“真实世界复杂度”的 ArkTS / MTProto 片段时，`regex-fallback` 索引器是否出现：

- 符号丢失；
- 依赖识别断裂；
- call edge 归属失真；
- 与 `SKILL_SCHEMA_V2` 关键维度不对齐的情况。

## 外部来源版本

- 来源仓库：`https://github.com/ForestBook/TelegramHarmony`
- 分支：`main`
- commit：`31af11b6f63e7e40c447dd4274b421b800016193`
- 本地裁剪片段目录：`raw_docs/telegramharmony-phase02`

## 本次输入范围

### 目标文件

- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`

### 依赖片段

- `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoClient.ets`
- `raw_docs/telegramharmony-phase02/src/core/mtproto/TLSerialization.ets`
- `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoTransport.ets`
- `raw_docs/telegramharmony-phase02/src/core/mtproto/TLMethods.ets`
- `raw_docs/telegramharmony-phase02/src/core/mtproto/TLDialogs.ets`
- `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoConfig.ets`
- `raw_docs/telegramharmony-phase02/src/core/mtproto/CryptoUtils.ets`
- `raw_docs/telegramharmony-phase02/src/core/mtproto/AuthKeyCreator.ets`
- `raw_docs/telegramharmony-phase02/src/core/mtproto/Inflate.ets`

## 执行命令

```bash
python scripts/pipeline_runner.py   --src-root raw_docs/telegramharmony-phase02   --target-file src/services/RealMessageService.ets   --mock-mode   --verify-dry-run   --run-root artifacts/pipeline_runs/phase02-telegram-core-dry-run
```

## 执行结果摘要

- 索引文件数：`10`
- 索引符号数：`38`
- TU 依赖文件数：`9`
- parser backend：`regex-fallback`
- orchestrator repair rounds：`1`
- summary：`artifacts/pipeline_runs/phase02-telegram-core-dry-run/summary.json`
- repo map：`artifacts/pipeline_runs/phase02-telegram-core-dry-run/repo_map.txt`
- TU：`artifacts/pipeline_runs/phase02-telegram-core-dry-run/realmessageservice-ets.tu.json`

## 正向观察

### 1. import 闭包没有断

`RealMessageService.ets` 的关键相对依赖都被识别出来了：

- `../core/mtproto/MTProtoClient`
- `../core/mtproto/TLMethods`
- `../core/mtproto/TLSerialization`
- `../core/mtproto/TLDialogs`

说明当前 `IMPORT_RE + resolve_import_target(...)` 对多行 import 与相对路径解析是可用的。

### 2. Repo Map 已能看出主干拓扑

从 `repo_map.txt` 可以清楚看到：

- `RealMessageService.ets` 是 `service`
- `MTProtoClient.ets` / `MTProtoTransport.ets` 带有 `async-flow` / `callback-entry`
- `RealMessageService.ets` 带有 `signal-or-store`
- `RealMessageService -> MTProtoClient -> MTProtoTransport` 的主链已成形

这说明 **文件级 / 类级地图已经可用于 Phase-02 的第一轮闭包打包**。

## 负向观察（核心问题）

### 1. 严重的 method 级符号丢失

当前 `METHOD_RE` 只能匹配：

- `foo(...) {`

却无法匹配 ArkTS 中非常常见的：

- `foo(...): void {`
- `async foo(...): Promise<T> {`
- `bar(...): Signal<Message[]> {`

导致真实复杂文件中的 method 节点大面积缺失。

### 2. 实测丢失清单

#### `RealMessageService.ets`

- 预期 methods：`constructor`、`cacheUsers`、`cacheChannels`、`createInputPeer`、`getMessages`、`fetchMessages`、`sendMessage`、`parseMessageContent`
- 实际识别：仅 `constructor`
- 丢失：`7 / 8`

#### `MTProtoClient.ets`

- 预期 methods：`constructor`、`setUpdateCallback`、`initialize`、`createAuthKey`、`sendRequest`、`initConnection`、`onConnected`、`onDisconnected`、`onData`、`onError`
- 实际识别：仅 `constructor`
- 丢失：`9 / 10`

#### `TLSerialization.ets`

- 预期 methods：`writeInt32`、`writeInt64`、`writeBytes`、`writeString`、`getBuffer`、`constructor`、`readInt32`、`readInt64`、`readBytes`、`readString`
- 实际识别：仅 `constructor`
- 丢失：`9 / 10`

#### `MTProtoTransport.ets`

- 预期 methods：`setCallback`、`connect`、`disconnect`、`send`、`onReceive`、`getTransport`
- 实际识别：`0`
- 丢失：`6 / 6`

### 3. call edge 归属发生失真

由于 method 节点缺失，很多调用边退化成了：

- 归到整个 `class` 节点；
- 或归到错误的 owner；
- 或被记录为 external symbol。

典型例子：

- `RealMessageService` 中大量 `fetchMessages` / `createInputPeer` / `parseMessageContent` 相关调用，被挂到 `class:RealMessageService`，而不是具体方法；
- 这会直接降低 TU 的“方法级局部上下文”质量。

### 4. call graph 噪声偏高

当前 `CALL_RE` 只抓 `name(` 形态，因此容易把以下都打成同一层：

- 真正的跨文件调用；
- 容器方法调用（如 `set` / `get` / `push`）；
- 运行时 API 调用（如 `info` / `error` / `stringify`）。

这会让 repo map 中出现较多低价值 call 节点。

## 与 V2 Schema 的冲突点

### 1. `Execution Topology` 能感知到文件级风险，但不能定位到方法级流转

当前风险标签能把 `async-flow`、`callback-entry` 打到文件上，但 method 抽取缺失后，很难回答：

- 哪个具体方法构造请求；
- 哪个具体方法解析回包；
- 哪个具体方法把结果写入 cache / signal。

### 2. `State Contract` 可以知道“有 cache / signal”，但难以定位状态变更点

`RealMessageService` 确实被打上了 `signal-or-store`，但 index 还不能稳定指出：

- `messageCache.set(...)` 出现在哪些 method；
- `messageSignals.get(...).set(...)` 是不是同一 method 内发生；
- cache 与 signal 更新顺序是否稳定。

### 3. `Boundary Contract` 在当前公开仓库里应定义为“binary + transport callback”，而不是 TDLib FFI

本次验证再次确认：

- 当前公开仓库没有显式 TDLib / NAPI / C-Interop 文件；
- 当前应重点建模的是 **MTProto binary boundary + transport callback boundary**。

## 初步结论

### 可用部分

- 文件级索引：可用
- import 闭包：可用
- repo map 主干拓扑：可用
- TU 依赖打包：可用
- mock orchestrator 闭环：可用

### 不足部分

- method 级索引：**当前不可用**
- method 级 call ownership：**当前不可用**
- 复杂 ArkTS 返回类型语法支持：**当前不可用**

## 下一步建议

1. 优先修 `METHOD_RE`
   - 至少支持 `): Type {`、`): Promise<T> {`、`): Signal<T> {` 等返回类型注解。

2. 第二步修 owner 归属逻辑
   - 当 method 缺失时，避免把全部调用都落到 class 级别。

3. 第三步提升 call 过滤
   - 对 `set/get/push/toString/stringify/info/error` 这类低价值容器/日志调用做降噪。

4. 在 tree-sitter 可用后复跑本 trace
   - 将本次结果作为 `regex-fallback baseline`。

## 结论

**这次 dry-run 的价值非常高。**

它证明了我们的 Phase-01 基建已经足够把真实 MTProto 片段拉进流水线，但也明确暴露出：

- `regex-fallback` 在 ArkTS method 粒度上还有硬伤；
- 第二阶段真正的第一优先级，不是继续堆更多 Skill，而是把 parser 从“文件级可用”提升到“方法级可信”。
