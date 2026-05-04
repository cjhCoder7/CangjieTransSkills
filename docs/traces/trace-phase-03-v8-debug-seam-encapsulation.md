# 执行轨迹：Phase 03 / V8 debug_seam_encapsulation

## 1. Run 元信息

- **Trace ID**：`trace-phase-03-v8-debug-seam-encapsulation`
- **执行日期**：`2026-03-30`
- **执行阶段**：`Phase 3C / Staging-Core / Linux 物理编译`
- **目标样本**：`samples/real-message-service-cache-001`
- **目标任务**：把 `RealMessageService` 在 V7 source parity 之后残留的 harness public seam 继续下沉，完成 `BCM-ALIGN-002` 的 public surface 收口
- **真理源**：`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:74`、`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:111`
- **关联契约**：`BCM-ALIGN-001`、`BCM-ALIGN-002`、`BCM-CONC-005`
- **关联脚本**：`scripts/phase3_source_alignment_asserts.py`

## 2. 红灯阶段

本轮没有继续发明新的业务 API，而是先把“public 面是否已经真正 source-aligned”固化成显式断言：

- 新增 `scripts/phase3_source_alignment_asserts.py`；
- 用它扫描 `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj` 的 public type / member；
- 只允许以下 public type 留在外面：
  - `PeerId`
  - `DomainMessage`
  - `SendMessageParams`
  - `MessageSignal`
  - `RealMessageService`
- 只允许以下 public member 留在 source-aligned public 面：
  - `MessageSignal.currentSnapshot()`
  - `RealMessageService.getMessages(peerId, limit)`
  - `RealMessageService.sendMessage(params)`

首轮红灯真实暴露出以下问题：

1. `MessageSignal.replace()` 仍是 public；
2. `IMTProtoAdapter`、`DatasetRefreshBridge`、`EpochRegister`、`MainContextDatasetRefreshBridge`、各类 adapter / observer scaffolding 仍是 public；
3. `RealMessageService.attachRefreshBridge(...)` 仍在 public 面；
4. `debugCacheSize`、`debugInvalidateCache`、`debugAcquireCacheWriteLockWithin` 等 harness seam 仍以 public 形式外漏。

红灯证据：

- `artifacts/behavior_runs/phase03-v8-debug-seam-encapsulation-red/source-alignment-asserts.json`
- `artifacts/behavior_runs/phase03-v8-debug-seam-encapsulation-red/summary.json`

## 3. 绿灯实现

### 3.1 Public whitelist 固化

- `scripts/phase3_source_alignment_asserts.py` 现在会对白名单 public surface 做静态断言；
- 任何新的 public type / member 若无 source 依据，都会直接把本轮验证打成红灯。

### 3.2 Harness seam 下沉

本轮没有删除 V5 / V6 的取证能力，只是把它们从 public 面压回同包内部可见：

- `MessageSignal.replace()` 改为同包内部可见；
- `RealMessageService.attachRefreshBridge(...)` 改为同包内部可见；
- `RealMessageService.debugCacheSize(...)`、`debugInvalidateCache(...)`、`debugAcquireCacheWriteLockWithin(...)` 等 seam 改为同包内部可见；
- `IMTProtoAdapter`、`DatasetRefreshObserver`、`DatasetRefreshBridge`、`EpochRegister`、`MainContextDatasetRefreshBridge`、`MockUiDatasetObserver`、各类 fake / probe adapter 改为同包内部可见。

这一步的关键点不是“删掉测试能力”，而是把取证能力继续压回水下，让 public 面只保留翻译真正需要对齐的源侧接口。

## 4. 最终验证

### 4.1 Public surface 断言

执行：

- `python scripts/phase3_source_alignment_asserts.py --target-file samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`

结果：

- `passed`；
- `RealMessageService` public 面当前只剩 `init`、`getMessages(peerId, limit)`、`sendMessage(params)`；
- `MessageSignal` public 面当前只剩 `init` 与 `currentSnapshot()`。

### 4.2 Linux SDK 物理测试

在显式注入以下 Linux SDK 环境变量后执行：

- `CANGJIE_HOME=artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie`
- `PATH+=build-tools/bin:build-tools/tools/bin:build-tools/third_party/llvm/bin`
- `LD_LIBRARY_PATH+=runtime/lib/linux_x86_64_cjnative:build-tools/third_party/llvm/lib`

真实执行：

- `cd samples/real-message-service-cache-001 && cjpm test`
- `timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'`

结果：

- `17/17` 通过；
- `timeout 5s` 熔断验证正常退出；
- V5 delayed handoff、V6 Double Fetch、V7 source parity 全部未回归。

### 4.3 物理证据

- `artifacts/behavior_runs/phase03-v8-debug-seam-encapsulation-red/source-alignment-asserts.json`
- `artifacts/behavior_runs/phase03-v8-debug-seam-encapsulation-red/summary.json`
- `artifacts/behavior_runs/phase03-v8-debug-seam-encapsulation-green/source-alignment-asserts.json`
- `artifacts/behavior_runs/phase03-v8-debug-seam-encapsulation-green/summary.json`
- `artifacts/behavior_runs/phase03-v8-debug-seam-encapsulation-green/cjpm-help-head.log`
- `artifacts/behavior_runs/phase03-v8-debug-seam-encapsulation-green/cjpm-test.log`
- `artifacts/behavior_runs/phase03-v8-debug-seam-encapsulation-green/cjpm-test-timeout-5s.log`

## 5. 本轮结论

- `BCM-ALIGN-001`：继续保持通过
  - `getMessages(peerId, limit)` 与 `sendMessage(params)` 未被 V8 收口破坏；
  - source parity public shape 保持稳定。
- `BCM-ALIGN-002`：通过
  - V5 / V6 / V7 中保留下来的增强能力已下沉到同包内部可见；
  - `RealMessageService` 的对外 public 面已经收口到 source-aligned whitelist。
- `BCM-CONC-005`：再次通过
  - 在 Linux SDK 的 `cjpm test` 与 `timeout 5s` 双验证下没有出现新死锁或挂起。

## 6. 下一步

下一击不应该再回到“public API 长什么样”的争论，而是继续对照 ArkTS 真理源，逐段收平 source semantics：

- `messageSignals` 的生命周期与复用时机；
- `fetchMessages()` 的 source 侧行为边界；
- `sendMessage()` 更新 signal / cache 的顺序细节；
- `Signal<Message[]>` 与当前 `MessageSignal` 之间剩余的运行时语义差距。
