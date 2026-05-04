# 2026-04-01 MTProtoClient 阶段检查点

## 目标

记录当前 Linux `Staging-Core` 主战线在 `MTProtoClient.ets` 上的真实战况、当前阻塞与下次开机后的直接续航动作。

## 已确认状态

- `MTProtoConfig.ets`：真实编译绿灯。
- `CryptoUtils.ets`：真实编译绿灯。
- `TLMethods.ets`：真实编译绿灯。
- `TLSerialization.ets`：真实编译绿灯。
- `TLDialogs.ets`：真实编译绿灯。
- `MTProtoClient.ets`：仍为当前头号红灯，但系统性阻塞已经被拆开。

## 本轮新增基建结论

- 已为 `[ASYNC_FLOW]` 模块补齐 translator / reviewer / static blacklist 护栏。
- 已新增 `scripts/precompiled_dependency_registry.py`，用于注册 `MTProtoConfig`、`CryptoUtils`、`TLMethods`、`TLSerialization`、`TLDialogs` 这些已绿候选。
- `workspace_manager.py` 与 `verifier.py` 已支持“依赖 staged compile + 多文件喂给 `cjc`”。
- 物理实验已确认：将已绿依赖在 staging 时统一 package 为 `core.mtproto` 后，可以一起通过多文件 `cjc` 编译。

## 本轮运行结果

### 1. `phase03-mtprotoclient-repair-002`

- 这是无效样本。
- 根因：命令漏传 `--no-mock-mode`，导致 `pipeline_runner.py` 仍然使用 Mock LLM。
- 物理证据：`summary.json` 中 `config.is_mock_mode = true`，最终候选为 `// mock translator artifact`。
- 工件：
  - `artifacts/pipeline_runs/phase03-mtprotoclient-repair-002/summary.json`
  - `artifacts/pipeline_runs/phase03-mtprotoclient-repair-002/mtprotoclient-ets.orchestration.json`

### 2. `phase03-mtprotoclient-repair-003`

- 真实 translator 起点被阻断。
- 根因：当前 shell 未暴露 `OPENAI_API_KEY`。
- 物理证据：`failure.json` 中为 `LLMAdapterError: 未检测到 OPENAI_API_KEY，无法发起真实 LLM 调用。`
- 工件：
  - `artifacts/pipeline_runs/phase03-mtprotoclient-repair-003/failure.json`
  - `artifacts/pipeline_runs/phase03-mtprotoclient-repair-003/summary.json`

## 离线 staged compile 结论

在无法继续真实 translator 的情况下，已拿 `phase03-mtprotoclient-repair-001` 的 attempt-05 真实候选做本地 staged compile，继续逼出下一层物理红灯。

### 已确认的收敛链

1. 原始多文件并编时，先撞上 `match => { ... }` / `lambda` 多语句体语法错误。
2. 本地把多语句 `match` 分支抽成 helper 后，红灯切换为伪造包导入：
   - `import core.mtproto.config.*`
   - `import core.mtproto.crypto.*`
   - `import core.mtproto.serialization.*`
   - `import core.mtproto.transport.*`
   - `import core.mtproto.methods.*`
   - `import core.mtproto.inflate.*`
   - `import core.mtproto.auth.*`
3. 再删除这些伪导入后，红灯继续下沉为真实缺失依赖和接口写法问题：
   - `TransportManager` 未定义；
   - `AuthKeyCreator` 未定义；
   - `SessionInfo` 不能按 `session.authKey/session.authKeyState/session.authKeyId` 直接字段写入；
   - `SessionManager.getSession(...)` 期望 `Int32`，当前传入 `Int64`。

### 当前最可信的物理结论

- 新的 staging 口径是成立的。
- `MTProtoClient` 已经从“被 verifier 单文件口径误杀”收敛为“真实代码实体问题”。
- 下一轮 Repair 应该盯住真实 `cjc` 红灯，而不是继续修旧的制度噪声。

## 下一步任务

### 优先级 P0：恢复真实 translator

- 在继续跑 `MTProtoClient` 前，先确认当前 shell 存在 `OPENAI_API_KEY`。
- 真实重跑必须显式传入 `--no-mock-mode`。
- 建议下次 run root 直接使用：
  - `artifacts/pipeline_runs/phase03-mtprotoclient-repair-004`

### 优先级 P1：`MTProtoClient` Repair 指令锚点

- 同包直用，删除所有 `import core.mtproto.*` 伪包导入。
- `TransportManager`、`AuthKeyCreator`、`decompress` 仅允许 `internal/private` 极简 seam，不得新增 source 中不存在的 public surface。
- `SessionInfo` 必须回到 accessor 心智，不再直写接口字段。
- `dcId` 传参收口到 `Int32`。
- Promise 异步合同仍要保住，不能把 `initialize/createAuthKey/sendRequest` 再塌成同步 `Unit`。

### 优先级 P2：如果仍无 API Key

- 继续使用离线 staged compile。
- 先本地压平以下物理红灯，再等待真实 translator 燃料补齐：
  - `lambda` / `match` 多语句体；
  - 伪 package import；
  - `TransportManager/AuthKeyCreator` 缺失；
  - `SessionInfo` accessor 不匹配；
  - `Int32/Int64` 错配。

## 关键工件

- 真实旧 run：
  - `artifacts/pipeline_runs/phase03-mtprotoclient-repair-001/summary.json`
  - `artifacts/pipeline_runs/phase03-mtprotoclient-repair-001/mtprotoclient.orchestration.json`
- 无效 mock run：
  - `artifacts/pipeline_runs/phase03-mtprotoclient-repair-002/summary.json`
- API key 阻断 run：
  - `artifacts/pipeline_runs/phase03-mtprotoclient-repair-003/failure.json`
- 离线 staged compile 沙盒：
  - `artifacts/tmp_mtprotoclient_real_compile/src/core/mtproto/MTProtoClient.cj`
  - `artifacts/tmp_mtprotoclient_real_compile/compile.stderr`
