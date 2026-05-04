# Phase 03 关机交接（2026-04-01 / MTProtoClient）

## 1. 当前任务

- 当前主战线：`raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoClient.ets`
- 当前 run：`artifacts/pipeline_runs/phase03-mtprotoclient-repair-004`
- 当前状态：`real translator 已打通，但 run 在关机前被人工中止以冻结证据面`
- 当前宿主：`Headless Linux CLI + 本地 .env.local 已具备真实 SiliconFlow OpenAI-Compatible 配置`

## 2. 本轮已确认的新证据

### 2.1 真实 API 路径已恢复

- 本轮不是 `mock-mode`。
- `phase03-mtprotoclient-repair-003` 的起点阻断（缺失 `OPENAI_API_KEY`）在本轮已被解除。
- `phase03-mtprotoclient-repair-004` 已成功跑到真实翻译 / 静态墙 / review / compile 阶段，不再是环境起点问题。

### 2.2 当前 run 落盘状态

当前已落盘：

- `artifacts/pipeline_runs/phase03-mtprotoclient-repair-004/repo_index.sqlite`
- `artifacts/pipeline_runs/phase03-mtprotoclient-repair-004/repo_map.txt`
- `artifacts/pipeline_runs/phase03-mtprotoclient-repair-004/mtprotoclient-ets.tu.json`
- `artifacts/pipeline_runs/phase03-mtprotoclient-repair-004/temp_workspace/20260401T054430Z-tu-pipeline-mtprotoclient-src-core-mtproto-mtprotoclient.ets/`

关机前未落盘：

- 根级 `summary.json`
- 根级 `failure.json`
- 根级 orchestration 汇总 JSON

说明：本轮 `pipeline_runner.py` 在关机前被人工 `kill`，目的是冻结当前 attempt 工件，避免继续写盘。

## 3. attempt 截面

### attempt-01

- `static_check_result.json`：`passed = false`
- `verify_result.json`：`status = blocked`, `failure_type = static-blacklist-failed`
- 已确认的回潮词：
  - `async`
  - `clientSingleton!`

### attempt-02

- `static_check_result.json`：`passed = true`
- `review_result.json`：`passed = false`, `issue_count = 4`
- `verify_result.json`：`status = failed`, `failure_type = compile-failed`

### attempt-03

- `static_check_result.json`：`passed = true`
- `review_result.json`：`passed = false`, `issue_count = 4`
- `verify_result.json`：`status = failed`, `failure_type = compile-failed`
- 候选文件：
  - `artifacts/pipeline_runs/phase03-mtprotoclient-repair-004/temp_workspace/20260401T054430Z-tu-pipeline-mtprotoclient-src-core-mtproto-mtprotoclient.ets/attempt-03/src/core/mtproto/MTProtoClient.cj`

## 4. 当前最可信红灯

### 4.1 已被证明可以先压掉的层

- `async` 关键字残留；
- `clientSingleton!` 非空断言残留。

### 4.2 现在真正需要盯住的层

- `initialize(forceNewAuthKey: boolean = false)` 默认参数在候选里丢失，出现 `Signature Parity` 违约；
- 候选重新发明了 `TransportManager`、`TCPTransport`、`AuthKeyCreator`、`AuthKeyResult`、`InitConnection`、`InvokeWithLayer`、`HelpGetConfig`、`decompress` 等内部 stub，已经偏离“极简 internal seam”约束；
- `SessionInfo` 仍有字段直写风险；
- compile 阶段已经再次触发真实 `compile-failed`，说明问题已从“纯制度噪声”继续下沉。

## 5. 续跑指令

下次开机后优先执行：

```bash
set -a; source .env.local; set +a
SDK="$PWD/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie"
export CANGJIE_HOME="$SDK"
export PATH="$SDK/build-tools/bin:$SDK/build-tools/tools/bin:$SDK/build-tools/third_party/llvm/bin:$PATH"
export LD_LIBRARY_PATH="$SDK/build-tools/runtime/lib/linux_x86_64_cjnative:$SDK/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}"
export CANGJIE_STDLIB_PATH="$SDK/build-tools/modules/linux_x86_64_cjnative/std"
python3 scripts/pipeline_runner.py \
  --src-root raw_docs/telegramharmony-phase02 \
  --target-file src/core/mtproto/MTProtoClient.ets \
  --run-root artifacts/pipeline_runs/phase03-mtprotoclient-repair-005 \
  --schema-path skills/SKILL_SCHEMA_V2.md \
  --architecture-skill docs/strategy/phase-03-source-alignment-directives.md \
  --repair-anchor-file samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj \
  --llm-model 'Pro/zai-org/GLM-4.7' \
  --timeout-seconds 180 \
  --llm-max-retries 3 \
  --max-rounds 5 \
  --parser-mode hybrid \
  --no-mock-mode \
  --verify-no-dry-run \
  --verify-real-compile \
  --verify-mock-unit-test \
  --verify-mock-behavior \
  --verify-compiler-home "$SDK" \
  --verify-compiler-executable "$SDK/build-tools/bin/cjc" \
  --verify-package-manager-executable "$SDK/build-tools/tools/bin/cjpm" \
  --verify-runtime-lib-path "$SDK/build-tools/runtime/lib/linux_x86_64_cjnative" \
  --verify-tool-bin-path "$SDK/build-tools/tools/bin"
```

## 6. 续跑铁律

下次 repair 指令必须继续死守：

1. 同包直用，删除 `import core.mtproto.*`、`async`、`clientSingleton!` 等回潮词。
2. `TransportManager`、`AuthKeyCreator`、`decompress` 只允许 `internal/private` 极简 seam，不得扩成新的 source 事实。
3. `initialize` 默认参数、`sendRequest` public surface、`SessionInfo` accessor 与 `dcId: Int32` 必须与 source 对齐。

## 7. 关联工件

- 检查点：`docs/reports/2026-04-01-mtprotoclient-status-checkpoint.md`
- 旧真实 run：`artifacts/pipeline_runs/phase03-mtprotoclient-repair-001/`
- 本轮 partial run：`artifacts/pipeline_runs/phase03-mtprotoclient-repair-004/`
- 当前状态板：`.claude/status/current-phase.md`
