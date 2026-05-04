# Trace - Phase-02 Telegram 核心模块 Dry-Run 002（Method Indexer Fix）

## 任务目标

验证 `repo_indexer.py` 在修复后是否已经能够：

- 正确识别带返回类型注解的 ArkTS methods；
- 将 method 正确挂到所属 class；
- 将 call edge 从 class 级细化到 method 级；
- 为 async / binary protocol 场景补充精确风险标签。

## 输入与执行命令

- 输入目录：`raw_docs/telegramharmony-phase02`
- 目标文件：`src/services/RealMessageService.ets`
- 执行命令：

```bash
python scripts/pipeline_runner.py \
  --src-root raw_docs/telegramharmony-phase02 \
  --target-file src/services/RealMessageService.ets \
  --mock-mode \
  --verify-dry-run \
  --run-root artifacts/pipeline_runs/phase02-telegram-core-dry-run-002
```

## 对比结果

### 基线（修复前）

- run root：`artifacts/pipeline_runs/phase02-telegram-core-dry-run`
- `Symbols Indexed = 38`
- `TU Dependency Count = 9`
- `Repair Rounds = 1`
- `regex-fallback` 下 `RealMessageService.ets` 仅识别出 `constructor`
- 大量调用边被挂到 class 节点

### 修复后

- run root：`artifacts/pipeline_runs/phase02-telegram-core-dry-run-002`
- `Symbols Indexed = 80`
- `TU Dependency Count = 9`
- `Repair Rounds = 1`
- method 级识别恢复，call edge 已显著细化到 method → method

## 识别率对比

### `RealMessageService.ets`

- 修复前：`1 / 8`（仅 `constructor`）
- 修复后：`8 / 8`
- 恢复 methods：
  - `cacheUsers`
  - `cacheChannels`
  - `createInputPeer`
  - `getMessages`
  - `fetchMessages`
  - `sendMessage`
  - `parseMessageContent`

### `MTProtoClient.ets`

- 修复前：`1 / 10`
- 修复后：`10 / 10`（另有一个 `RPCCallback.constructor` 也会被识别）

### `TLSerialization.ets`

- 修复前：`1 / 10`
- 修复后：`10 / 10`

### `MTProtoTransport.ets`

- 修复前：`0 / 6`
- 修复后：`6 / 6`

## 关键结构性改进

### 1. method header 不再只依赖单条正则闭眼匹配

当前实现改为：

- `METHOD_RE` 负责发现 method header 起点；
- `scan_method_body_start(...)` 负责跨参数区、返回类型区与换行位置寻找真正的 body `{`；
- 这使得以下形式均可识别：
  - `async foo(x: T): Promise<U> { ... }`
  - `bar(peerId: PeerId): Signal<Message[]> { ... }`
  - `baz<T>(arg: T): CustomResult<T> { ... }`

### 2. owner binding 已恢复

新增了 `container_contains_method` 边：

- `RealMessageService` class → 其 8 个 methods
- `TCPTransport` class → `setCallback/connect/disconnect/send/onReceive`
- `TransportManager` class → `getTransport`

这意味着 L2 Repo Map 与 L3 TU Bundler 终于可以利用 class 内 method 层次，而不是只看 file summary。

### 3. call edge 已从 class 级回落到 method 级

典型改进：

- `getMessages -> fetchMessages`
- `fetchMessages -> createInputPeer`
- `fetchMessages -> sendRequest`
- `fetchMessages -> parseMessageContent`
- `sendMessage -> createInputPeer`
- `sendMessage -> sendRequest`
- `sendMessage -> parseMessageContent`

这正是后续做 method-scale TU 与错误驱动 repair 的必要前提。

### 4. async / binary 语义标签已进索引

示例：

- `sendRequest` method 风险标签：`[ASYNC_FLOW]`, `[BINARY_PROTO]`
- `fetchMessages` method 风险标签：`[ASYNC_FLOW]`, `[BINARY_PROTO]`
- `readBytes` method 风险标签：`[BINARY_PROTO]`

这会直接提升：

- Skill 检索触发精度；
- Reviewer 对 `Execution Topology` / `Boundary Contract` 的感知能力；
- 后续 Pattern Memory 对协议类方法的 few-shot 检索质量。

## 仍存在的已知问题

1. `CALL_RE` 仍会抓到 `set/get/push/info/error` 这类容器与日志调用，噪声仍偏高。
2. destination symbol resolution 目前按“同文件优先 + method/function 优先”排序，已明显改善，但还不是完整的静态绑定。
3. 当前仍是 `regex-fallback`，并不替代真正的 AST；后续接入 `tree-sitter` 后应再复跑一次对比。

## 结论

这轮修复已经把 `repo_indexer.py` 从“文件级可用、方法级失真”推进到了“方法级基本可信”。

对第二阶段而言，这意味着：

- L1 Repo Index 不再是空壳；
- L2 Repo Map 开始具备 method 级价值；
- L3 TU Bundler 能更可信地打包 `RealMessageService -> MTProtoClient -> TLSerialization` 的真实闭包；
- L4 Reviewer / Repair 终于有机会基于真实 method 结构工作，而不是在 class 级摘要上盲修。
