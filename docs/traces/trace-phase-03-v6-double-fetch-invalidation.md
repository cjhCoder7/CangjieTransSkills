# 执行轨迹：Phase 03 / V6 double_fetch_invalidation

## 1. Run 元信息

- **Trace ID**：`trace-phase-03-v6-double-fetch-invalidation`
- **执行日期**：`2026-03-30`
- **执行阶段**：`Phase 3C / Staging-Core / Linux 物理编译`
- **目标样本**：`samples/real-message-service-cache-001`
- **目标任务**：把 `Double Fetch` 高压变体从设计建议推进为可物理编译、可冒烟、可回归的 invalidation 压测样本
- **关联计划**：`docs/superpowers/plans/2026-03-30-phase3c-double-fetch-invalidation-harness-plan.md`
- **关联行为契约**：`BCM-STATE-006`、`BCM-ASYNC-006`
- **关联技能**：`using-superpowers`、`brainstorming`、`writing-plans`、`test-driven-development`、`verification-before-completion`

## 2. 本次执行目标

1. 增加 `debugInvalidateCache(peerId)`，让 force refresh fetch 真正击穿缓存；
2. 让 invalidation 在清空 cache 后显式推高 bridge epoch；
3. 用纯 `getMessages()` 形成 `A delayed fetch / B force-refresh fetch` 的 Double Fetch 竞态；
4. 把 `MockUiDatasetObserver` 的内部 delivery log 做成严格断言面；
5. 在 Linux SDK 上完成 `cjpm test` 与 `timeout 5s` 双验证。

## 3. 红灯阶段

本轮严格按 TDD 先写失败测试：

- 新建 `samples/real-message-service-cache-001/src/double_fetch_invalidation_test.cj`
- 先写两条失败测试：
  - `debugInvalidateCacheShouldClearPeerCacheAndAdvanceEpoch`
  - `forceRefreshDoubleFetchShouldLeaveOnlyBPayloadInUiObserverLog`

首次运行 `cjpm test` 后，真实红灯如下：

1. `MainContextDatasetRefreshBridge` 缺少 `debugCurrentEpoch()`；
2. `RealMessageService` 缺少 `debugInvalidateCache(peerId)`；
3. `MockUiDatasetObserver` 缺少 `debugDeliveryLog()`；
4. 红灯全部集中在新变体所需能力缺失，没有偏到无关模块。

结论：

> 红灯质量合格，说明测试确实钉住了新行为，而不是语法噪音。

## 4. 实现动作

### 4.1 桥接器 epoch 控制面

- 扩展 `DatasetRefreshBridge`，新增 `debugForceAdvanceEpoch(reason)`；
- 在 `MainContextDatasetRefreshBridge` 中实现：
  - `debugForceAdvanceEpoch(reason)`
  - `debugCurrentEpoch()`
- `drainOnMain()` 的 stale 判定改成读取 `epochRegister.currentEpoch()`，让 invalidation 自身也能构成“世界已变”的代际边界。

### 4.2 物理级缓存击穿

- 在 `RealMessageService` 中新增 `debugInvalidateCache(peerId)`；
- 它的执行顺序是：
  1. 抢占 `cacheLock`；
  2. 删除目标 `peerId` 的 cache entry；
  3. 写入 trace；
  4. 调用 `refreshBridge.debugForceAdvanceEpoch(...)` 推高 epoch；
  5. 返回 forced epoch 给测试断言。

这次不是“逻辑上当作失效”，而是明确地在物理 cache 上做删除。

### 4.3 Strict stale-read observer log

- 给 `MockUiDatasetObserver` 新增 `deliveryLog`；
- 每次 `onDatasetChanged(...)` 时都写入：
  - `ui:delivery:<context>:peer=<peerId>:size=<size>:tail=<tailText>`
- 测试不再只看 `lastMessageText()`，而是直接检查 observer 内部 delivery log：
  - 只能有 1 条有效 UI 交付；
  - 必须包含 `double-fetch-b-tail`；
  - 不得包含 `double-fetch-a-tail`。

## 5. Double Fetch 序列

本轮采用以下确定性顺序：

1. `worker-fetch-A`：正常 `getMessages(...)`，但其 UI handoff 被 `delayNextHandoffFor(...)` 挂起；
2. `worker-force-refresh-B`：先 `debugInvalidateCache(peerId)`，再执行第二次 `getMessages(...)`；
3. `main` 先 `drainOnMain()`，让 B 成为当前 UI 世界；
4. 再 `releaseDelayedHandoffs()` 释放 A；
5. 再次 `drainOnMain()`，此时 A 因 stale epoch 被 discard。

这个序列的关键点是：

- B 不是 `sendMessage()`；
- B 也不是“假装刷新”的缓存命中；
- B 是真正的 `Double Fetch` 第二次 fetch，并且前面带了物理 cache invalidate。

## 6. 最终验证

### 6.1 全量测试

真实执行：

- `cd samples/real-message-service-cache-001 && cjpm test`

结果：

- `15/15` 通过；
- 新增 V6 两条测试全绿；
- 旧有 V5 / UI refresh / concurrency / cache / domain purity 全部保持通过。

### 6.2 熔断验证

真实执行：

- `timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'`

结果：

- 正常退出；
- 未出现 invalidate 路径引入的锁悬挂或死锁。

### 6.3 物理证据

- `artifacts/behavior_runs/phase03-v6-double-fetch-invalidation/summary.json`
- `artifacts/behavior_runs/phase03-v6-double-fetch-invalidation/cjpm-test.log`
- `artifacts/behavior_runs/phase03-v6-double-fetch-invalidation/cjpm-test-timeout-5s.log`

## 7. 本轮结论

- `BCM-STATE-006`：通过
  - `debugInvalidateCache(peerId)` 会物理删除目标 `peerId` 的 cache；
  - 失效后返回的 forced epoch 严格大于失效前 epoch。
- `BCM-ASYNC-006`：通过
  - observer delivery log 中唯一有效 UI 载荷来自 `worker-force-refresh-B`；
  - A 没有留下任何幽灵 payload 到 UI 层。
- `BCM-CONC-005`：在 Double Fetch 变体下再次通过
  - `timeout 5s` 下整套测试正常退出。

## 8. 下一步建议

- 如果要把这条链再向协议真实度推进一格，下一枪建议不是继续堆 observer 断言，而是引入一个更接近真实环境的 `forceRefresh` 入口：
  - 让 invalidation 语义从 harness debug API 迁到更像业务 API 的 façade；
  - 或者给 adapter 增加显式 cache-bust / version-switch 信号，验证“不是 service 主动删 cache，而是上游版本推进导致第二次 fetch 自然赢下世界”。
