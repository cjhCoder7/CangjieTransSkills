# 执行轨迹：Phase 03 / V5 delayed_handoff_with_interruptions

## 1. Run 元信息

- **Trace ID**：`trace-phase-03-v5-delayed-handoff-with-interruptions`
- **执行日期**：`2026-03-30`
- **执行阶段**：`Phase 3C / Staging-Core / Linux 物理编译`
- **目标样本**：`samples/real-message-service-cache-001`
- **目标任务**：把 `delayed_handoff_with_interruptions` 从设计稿推进为可物理编译、可回归、可熔断验证的 V5 压测样本
- **关联设计**：`docs/superpowers/specs/2026-03-30-phase3c-delayed-handoff-with-interruptions-design.md`
- **关联计划**：`docs/superpowers/plans/2026-03-30-phase3c-delayed-handoff-with-interruptions-harness-plan.md`
- **关联行为契约**：`BCM-ASYNC-005`、`BCM-CONC-005`
- **关联技能**：`using-superpowers`、`subagent-driven-development`、`test-driven-development`、`verification-before-completion`

## 2. 本次执行目标

1. 在 `MainContextDatasetRefreshBridge` 中补齐 `epoch` 寄存器与 delayed queue；
2. 建立 `A delayed / B immediate` 的确定性压测序列；
3. 证明 stale handoff 会在进入 UI 前被 discard；
4. 证明 interruption 结束后 `messageCache` 写锁不会泄漏；
5. 用真实 Linux SDK 跑通 `cjpm test` 与 `timeout 5s` 熔断验证。

## 3. 环境与工具链

- **宿主**：Linux CLI，无 GUI 依赖
- **SDK 资产**：`/volume/wzhang/cky-workspace/my_projects/Cangjie/资源/cangjie-sdk-linux-x64-6.1.0.818.zip`
- **解压工具链**：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie`
- **关键环境变量**：`DEVECO_CANGJIE_PATH`、`CANGJIE_HARMONY_SDK_PATH`、`CANGJIE_HOME`、`CANGJIE_PATH`、`PATH`、`LD_LIBRARY_PATH`
- **验证命令**：
  - `cd samples/real-message-service-cache-001 && cjpm test`
  - `timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'`

## 4. 红灯阶段

### 4.1 第一轮真实红灯

执行 `cjpm test` 后，首先命中编译错误：

- `real_message_service_cache_harness.cj` 中的全局 helper `consumeDelayedSourceLocked(...)` 直接访问 `MainContextDatasetRefreshBridge` 的私有字段 `delayedSources`；
- 编译器报错：`can not access field 'delayedSources'`；
- 这是一个纯实现级错误，说明 delayed queue 逻辑已经越过了桥接器的封装边界。

### 4.2 第二轮真实红灯

修复私有字段越界后，`cjpm test` 可以编译，但出现三处失败：

1. `delayedHandoffShouldDiscardStaleEpochBeforeUiDelivery`
   - UI 最终收到的是 A，不是 B；
   - 根因不是 epoch 判定失效，而是 B 走了缓存命中，根本没有形成第二份更新载荷。
2. `fetchShouldDispatchDatasetRefreshToMockUiOnMainContext`
3. `sendShouldDispatchUpdatedDatasetToMockUiOnMainContext`
   - 这两处是旧契约回归；
   - 根因是新的 dispatch log 把原来的精确值 `refresh:queued:worker-*` 改成了附带 `epoch=` 的新格式，打破了既有断言。

## 5. 修复动作

### 5.1 Bridge 封装与并发边界

- 将 `consumeDelayedSourceLocked(...)` 收回 `MainContextDatasetRefreshBridge` 类内，避免外部 helper 越界访问私有字段；
- 继续使用 `queueLock` 保护：
  - `pendingQueue`
  - `delayedQueue`
  - `delayedSources`
  - `latestDeliveredEpoch`
- 保持 delayed queue 的跨线程暂存是显式受锁保护的，不使用无锁 `ArrayList` 直接跨线程共享。

### 5.2 Epoch / stale handoff 收口

- 在 bridge 中保留 `MutexEpochRegister`，作为当前 Linux 物理编译链下最稳的 compile-safe `epoch` 后端；
- `notifyDatasetChanged(...)` 为每次刷新分配新 epoch；
- `drainOnMain()` 中若发现 `item.epoch < latestDeliveredEpoch`，则写入：
  - `refresh:discarded:stale-epoch:<source>:<oldEpoch>-><latestEpoch>`
- stale handoff 不再触达 `MockUiDatasetObserver`。

### 5.3 旧契约兼容

- 恢复旧的 queue log 精确值：
  - `refresh:queued:<source>`
  - `refresh:queued-delayed:<source>`
- 同时补充新的 meta log：
  - `refresh:queued-meta:<source>:epoch=<n>`
  - `refresh:queued-delayed-meta:<source>:epoch=<n>`

结论：

> 旧测试继续吃旧契约，新测试额外消费新元数据；避免“新功能上线把旧 harness 打碎”。

### 5.4 B 路径改造

原始 V5 红灯里，A/B 都走 `getMessages(...)`，导致 B 命中缓存，无法形成真正的新世代快照。

本轮将 B 改为：

- `runWorkerSendMessage(service, peerId, "request-b-tail", "worker-send-B")`

这样 B 会：

- 直接更新 cache；
- 触发新的 UI handoff；
- 形成可与 A 明确区分的新 epoch；
- 避免把 V5 压测稀释成“缓存命中假绿”。

## 6. 最终验证

### 6.1 通过的测试

V5 新增测试全部通过：

- `epochRegisterShouldAdvanceMonotonicallyForNewHandoffs`
- `delayedHandoffShouldDiscardStaleEpochBeforeUiDelivery`
- `interruptionShouldNotLeakCacheWriteLockWithinBudget`

全包结果：

- `13/13` 通过，`0` 失败

### 6.2 熔断验证

使用外层 shell 熔断再次执行完整测试：

- `timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'`

结果：

- 正常退出；
- 未出现死锁或幽灵线程把 `cjpm test` 卡死。

### 6.3 物理证据落盘

- `artifacts/behavior_runs/phase03-v5-delayed-handoff-with-interruptions/summary.json`
- `artifacts/behavior_runs/phase03-v5-delayed-handoff-with-interruptions/cjpm-test.log`
- `artifacts/behavior_runs/phase03-v5-delayed-handoff-with-interruptions/cjpm-test-timeout-5s.log`

## 7. 本轮结论

- `BCM-ASYNC-005`：通过
  - A delayed fetch、B immediate send 的序列下，UI 最终只看到 B；
  - A 在进入 UI 前被 stale-epoch 规则丢弃；
  - dispatch log 保留明确 discard 证据。
- `BCM-CONC-005`：通过
  - `debugAcquireCacheWriteLockWithin(50)` 返回 `true`；
  - 外层 `timeout 5s` 熔断下整套测试正常退出。
- 旧有 `UI refresh` 契约未被新特性破坏；
- 当前 `RealMessageService` 的 `Staging-Core` 行为证据已从 `10/10` 推进到 `13/13` 全绿。

## 8. 遗留与下一步

- 当前 `epoch` 后端仍是 `Mutex + Int64`，后续若 Linux SDK 对 `AtomicInt64` 证据更充分，可无损替换后端实现；
- 当前 V5 的 B 路径使用 `sendMessage`，下一步若需要更贴近“双 fetch 竞态”，建议补一个显式 `forceRefresh` 或 `debugInvalidateCache(peerId)` 路径，再做第二轮压力样本；
- 继续向 `Phase 3C Full Pass` 推进时，应把这套 stale discard / no-leak 契约迁移到更贴近真实 Harmony runtime 的物理链路中。
