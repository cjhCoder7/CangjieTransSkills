# 执行轨迹：Phase 03 / V11 promise_runtime

## 1. Run 元信息

- **Trace ID**：`trace-phase-03-v11-promise-runtime`
- **执行日期**：`2026-03-30`
- **执行阶段**：`Phase 3C / Staging-Core / Linux 物理编译`
- **目标样本**：`samples/real-message-service-cache-001`
- **目标任务**：在不发明新的 public Promise API 的前提下，补齐 `fetchMessages()` / `sendMessage()` 的最小 Promise 运行时语义
- **真理源**：`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:74`、`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:86`、`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:107`、`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:111`、`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:127`
- **关联设计**：`docs/superpowers/specs/2026-03-30-phase3c-realmessageservice-promise-runtime-v11-design.md`
- **关联计划**：`docs/superpowers/plans/2026-03-30-phase3c-realmessageservice-promise-runtime-v11-plan.md`

## 2. 本轮要解决的偏差

V10 之后，`MessageSignal` 的持续实例与 runtime update 已经就位，但 Promise 边界仍然过于扁平：

1. `getMessages()` 首次创建 signal 时，会同步把 fetch 结果立刻写回 signal；
2. 这让 `Promise<Message[]>` 的“先返回 signal，再回流远端结果”心智被压没；
3. `sendMessage(params)` 仍然没有任何 Promise settlement 级账本痕迹。

## 3. 设计落点

本轮采纳的收口策略：

- **fetch**：新增 package-local `pendingPromiseResolutions` 队列；
- **fetch**：新增 package-local `debugDrainPromiseResolutions()`，显式触发 Promise resolve 回流；
- **send**：保持 V9 的 optimistic signal update，不改变 public / visible behavior；
- **send**：追加 `promise:queued:send:*` / `promise:settled:send:*` trace；
- **invalidate**：清 cache / 驱逐旧 signal 的同时，顺手丢弃同 peer 的 pending fetch promise，避免旧 fetch 在 drain 后回魂。

## 4. 红灯目标

新增 `samples/real-message-service-cache-001/src/promise_runtime_v11_test.cj`，锁死三条红灯：

1. `getMessagesShouldExposeSeededSnapshotBeforeFetchPromiseDrain`
   - drain 前 signal 只能看到 local seed / current snapshot；
   - drain 后才允许切换到远端历史。
2. `fetchPromiseDrainShouldQueueUiRefreshOnlyAfterResolution`
   - drain 前 bridge 不得提前排队 refresh；
   - drain 后才允许出现 `refresh:queued:*`。
3. `sendMessageShouldKeepOptimisticSignalContractAndLeavePromiseSettlementTrace`
   - send 仍保留 V9 optimistic signal update；
   - 同时必须留下 queued / settled promise trace。

## 5. 关键实现点

- `PendingPromiseResolution`
  - 只保存 `peerId + kind + payload`，停留在同包内部；
- `RealMessageService.fetchMessages(params)`
  - 仍立即触发 `adapter.getHistory(...)`；
  - 但把结果先塞进 `pendingPromiseResolutions`；
- `RealMessageService.debugDrainPromiseResolutions()`
  - drain 时统一 apply fetch resolution：
    - 写 cache
    - 更新现有 signal
    - 走 UI refresh bridge
- `RealMessageService.sendMessage(params)`
  - 不改变 V9 可见行为；
  - 只新增 Promise settlement trace。

## 6. 回归修口

首轮全量跑 `cjpm test` 时，新引入的 Promise boundary 触发了一个 V10 回归：

- `signalVersionShouldAdvanceMonotonicallyAcrossFetchAndSend`
  - observer 同时看到了 fetch 与 send 两次更新；
  - 断言原本只想统计 send。

修复方式：

- 先 `debugDrainPromiseResolutions()` 完成 fetch；
- 再注册 runtime observer；
- 最终把断言重新收紧回“只看 send 更新”。

## 7. 物理验证命令

```bash
python scripts/phase3_source_alignment_asserts.py \
  --target-file samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj

cd samples/real-message-service-cache-001 && cjpm test

timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'
```

## 8. 验证结果

- `phase3_source_alignment_asserts.py`：通过；
- `cjpm test`：`25/25` 全绿；
- `timeout 5s` smoke：再次 `25/25` 全绿；
- public whitelist 未被 V11 污染；
- 当前仅剩少量 non-blocking `unused variable` warning。

## 9. 新增契约回写

- `BCM-ASYNC-009`：Fetch Promise Drain Boundary
- `BCM-ASYNC-010`：Collapsed Send Promise Settlement Trace

## 10. 下一步

V11 之后，`RealMessageService` 在 `Signal` 与 `Promise` 两条源侧运行时语义上都已经具备最小闭环证据。下一枪最自然的方向有两个：

1. **V12：继续收平 `SignalPipe` / observer lifecycle 的 source 级订阅语义**；
2. **把已验证的翻译模式抽成批量自动翻译模板**，开始在 TelegramHarmony 中选取同类 Service / Store / Adapter 模块做小批量自动翻译试运行。
