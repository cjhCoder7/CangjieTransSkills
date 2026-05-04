# 执行轨迹：Phase 03 / V10 signal_runtime

## 1. Run 元信息

- **Trace ID**：`trace-phase-03-v10-signal-runtime`
- **执行日期**：`2026-03-30`
- **执行阶段**：`Phase 3C / Staging-Core / Linux 物理编译`
- **目标样本**：`samples/real-message-service-cache-001`
- **目标任务**：在不新增未经 source 证明的 public API 前提下，收平 `Signal<Message[]>` 的最小运行时语义
- **真理源**：`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:74`、`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:107`、`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:127`
- **关联设计**：`docs/superpowers/specs/2026-03-30-phase3c-realmessageservice-signal-runtime-v10-design.md`
- **关联计划**：`docs/superpowers/plans/2026-03-30-phase3c-realmessageservice-signal-runtime-v10-plan.md`
- **关联契约**：`BCM-STATE-007`、`BCM-ASYNC-008`、`BCM-ALIGN-005`

## 2. 红灯阶段

本轮先用测试把缺失的 runtime seam 钉出来：

- `samePeerShouldReuseSignalInstanceUntilInvalidation`
- `signalVersionShouldAdvanceMonotonicallyAcrossFetchAndSend`
- `invalidateShouldDetachOldSignalFromFutureUpdates`

首轮 `cjpm test` 的红灯集中在：

1. `MessageSignal.runtimeId()` 缺失；
2. `MessageSignal.updateVersion()` 缺失；
3. `MessageSignal.observeRuntime(...)` 缺失。

这说明 V10 的缺口确实是 signal runtime 行为，而不是其它无关模块。

红灯证据：

- `artifacts/behavior_runs/phase03-v10-signal-runtime-red/cjpm-test.log`
- `artifacts/behavior_runs/phase03-v10-signal-runtime-red/summary.json`

## 3. 绿灯实现

### 3.1 internal runtime seam

`MessageSignal` 现在新增了同包内部可见的最小 runtime seam：

- `runtimeId()`：标识 signal 实例身份；
- `updateVersion()`：记录该 signal 已经历的更新次数；
- `observeRuntime(observer)`：允许 harness observer 观察后续更新。

这些 seam 全部停留在 package-local 层，没有污染 public 面。

### 3.2 锁外 observer 回调

为避免 signal 更新时自锁：

- `replace(messages)` 先在锁内更新 snapshot / version；
- 再复制 observer 列表并释放锁；
- 最终在锁外依次调用 observer。

因此，即使 observer 自己回读 `currentSnapshot()`，也不会和 `replace()` 形成锁重入死锁。

### 3.3 invalidate 与旧 signal 摘离

V10 继续复用 V9 的 signal-evict 逻辑：

- `debugInvalidateCache()` 不仅清 cache，还驱逐旧 signal；
- invalidate 之后的新 `getMessages()` 会拿到新实例；
- 旧 signal 上挂的 observer 不会再收到后续更新。

## 4. 最终验证

### 4.1 Public surface 白名单

执行：

- `python scripts/phase3_source_alignment_asserts.py --target-file samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`

结果：

- `passed`；
- `MessageSignal` public 面仍只有 `init` 与 `currentSnapshot()`；
- V10 没有往 public 层偷渡 `subscribe()` / `runtimeId()` / `updateVersion()`。

### 4.2 Linux SDK 物理测试

真实执行：

- `cd samples/real-message-service-cache-001 && cjpm test`
- `timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'`

结果：

- `22/22` 通过；
- `V5`、`V6`、`V7`、`V8`、`V9`、`V10` 全部共存；
- `timeout 5s` 熔断验证正常退出。

### 4.3 物理证据

- `artifacts/behavior_runs/phase03-v10-signal-runtime-red/cjpm-test.log`
- `artifacts/behavior_runs/phase03-v10-signal-runtime-red/summary.json`
- `artifacts/behavior_runs/phase03-v10-signal-runtime-green/source-alignment-asserts.json`
- `artifacts/behavior_runs/phase03-v10-signal-runtime-green/summary.json`
- `artifacts/behavior_runs/phase03-v10-signal-runtime-green/cjpm-test.log`
- `artifacts/behavior_runs/phase03-v10-signal-runtime-green/cjpm-test-timeout-5s.log`

## 5. 本轮结论

- `BCM-ALIGN-005`：通过
  - invalidation 前，同一 `peerId` 持续复用同一 signal 实例；
  - invalidation 后，才切换到新 signal identity。
- `BCM-ASYNC-008`：通过
  - signal 的 runtime version 在 fetch / send 间单调推进；
  - observer 看到的最终版本与 signal 内部版本一致。
- `BCM-STATE-007`：通过
  - invalidate 后旧 signal observer 不再接收新事件；
  - 新 signal 才是后续 fetch / send 的唯一更新落点。

## 6. 下一步

如果继续打 `V11`，最自然的目标已经收束到一个点：

- `Promise<Message>` / `Promise<Message[]>` 的源侧运行时语义。
