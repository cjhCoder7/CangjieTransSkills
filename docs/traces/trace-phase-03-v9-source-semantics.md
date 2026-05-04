# 执行轨迹：Phase 03 / V9 source_semantics

## 1. Run 元信息

- **Trace ID**：`trace-phase-03-v9-source-semantics`
- **执行日期**：`2026-03-30`
- **执行阶段**：`Phase 3C / Staging-Core / Linux 物理编译`
- **目标样本**：`samples/real-message-service-cache-001`
- **目标任务**：把 `messageSignals / fetchMessages / sendMessage` 的 source semantics 收平到更接近 ArkTS 真理源的状态
- **真理源**：`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:74`、`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:86`、`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:111`
- **关联设计**：`docs/superpowers/specs/2026-03-30-phase3c-realmessageservice-source-semantics-v9-design.md`
- **关联计划**：`docs/superpowers/plans/2026-03-30-phase3c-realmessageservice-source-semantics-v9-plan.md`
- **关联契约**：`BCM-STATE-006`、`BCM-ASYNC-007`、`BCM-ALIGN-003`、`BCM-ALIGN-004`

## 2. 红灯阶段

本轮先打两类红灯：

### 2.1 静态红灯：internal fetch 入口偏差

新增 `scripts/phase3_source_semantics_asserts.py`，首轮扫描结果显示：

1. `GetHistoryParams` 缺失；
2. `private func fetchMessages(params: GetHistoryParams)` 缺失；
3. 旧的 `private func fetchMessages(peerId, limit)` 仍然存在。

红灯证据：

- `artifacts/behavior_runs/phase03-v9-source-semantics-red/source-semantics-asserts.json`

### 2.2 运行时红灯：首次 signal 创建没有 fetch

新增 `samples/real-message-service-cache-001/src/source_semantics_v9_test.cj`，其中：

- `firstSignalCreationShouldFetchEvenWhenCacheAlreadySeeded`
- `sendMessageShouldOptimisticallyUpdateExistingSignalBeforeUiDrain`

首次运行 `cjpm test` 后，真实失败点集中在第一条：

- 本地 `sendMessage()` seed cache 后，第一次 `getMessages()` 仍未触发 `adapter.getHistory()`；
- 说明旧逻辑仍被 `hasCache` 短路，而不是按 source 语义走“signal first-create -> fetch”。

红灯证据：

- `artifacts/behavior_runs/phase03-v9-source-semantics-red/cjpm-test.log`
- `artifacts/behavior_runs/phase03-v9-source-semantics-red/summary.json`

## 3. 绿灯实现

### 3.1 `GetHistoryParams` 与 internal fetch params bag

- 新增 package-local `GetHistoryParams(peerId, limit)`；
- `fetchMessages` 现在改为 `private func fetchMessages(params: GetHistoryParams)`；
- `scripts/phase3_source_semantics_asserts.py` 已把这条 internal shape 固化成静态哨兵。

### 3.2 `getMessages` 生命周期收口

- `getMessages` 的分支条件从“是否有 cache”改为“是否已有 signal”；
- 若 signal 不存在：
  - 先用现有 cache 作为初始 snapshot 建立 signal；
  - 再立即触发一次 `fetchMessages(GetHistoryParams(...))`；
- 若 signal 已存在：
  - 直接复用，不再 refetch。

这一步让 `messageSignals` 的生命周期更接近 ArkTS 真理源，而不是继续被旧的 cache 命中逻辑带偏。

### 3.3 `sendMessage` 乐观 signal 更新守护

- `sendMessage(params)` 继续保持 source-aligned public 签名；
- 测试已明确证明：`sendMessage` 成功后，signal snapshot 会先更新，而 observer 仍要等到 `main drain` 才收到第二次可见交付。

### 3.4 `debugInvalidateCache` 的 signal 驱逐补口

V9 首轮绿灯实现一度引发 `V6 Double Fetch` 回归：

- 原因不是 V9 设计错了，而是 `debugInvalidateCache()` 只删 cache，不删旧 signal；
- 在新的“signal first-create 才 fetch”规则下，旧 signal 若残留，force-refresh B 就不会重新 fetch。

最终修复：

- `debugInvalidateCache()` 现在会同时驱逐目标 peer 的旧 signal；
- 这样既保住 V6 的 Double Fetch invalidation，又不违背 V9 的 source semantics 收口方向。

## 4. 最终验证

### 4.1 静态闸门

执行：

- `python scripts/phase3_source_semantics_asserts.py --target-file samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`
- `python scripts/phase3_source_alignment_asserts.py --target-file samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`

结果：

- 两道静态闸门全部通过；
- public whitelist 没有被 V9 收口破坏；
- internal fetch params bag 已固定为 `GetHistoryParams`。

### 4.2 Linux SDK 物理测试

真实执行：

- `cd samples/real-message-service-cache-001 && cjpm test`
- `timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'`

结果：

- `19/19` 通过；
- `V5`、`V6`、`V7`、`V8`、`V9` 全部共存；
- `timeout 5s` 熔断验证正常退出，无新增死锁或挂起。

### 4.3 物理证据

- `artifacts/behavior_runs/phase03-v9-source-semantics-red/source-semantics-asserts.json`
- `artifacts/behavior_runs/phase03-v9-source-semantics-red/cjpm-test.log`
- `artifacts/behavior_runs/phase03-v9-source-semantics-red/summary.json`
- `artifacts/behavior_runs/phase03-v9-source-semantics-green/source-semantics-asserts.json`
- `artifacts/behavior_runs/phase03-v9-source-semantics-green/source-alignment-asserts.json`
- `artifacts/behavior_runs/phase03-v9-source-semantics-green/summary.json`
- `artifacts/behavior_runs/phase03-v9-source-semantics-green/cjpm-test.log`
- `artifacts/behavior_runs/phase03-v9-source-semantics-green/cjpm-test-timeout-5s.log`

## 5. 本轮结论

- `BCM-ALIGN-003`：通过
  - 第一次 signal 创建不再受 cache 是否已存在的影响；
  - source 侧“先建 signal，再 fetch”心智已被钉进 harness。
- `BCM-ALIGN-004`：通过
  - `fetchMessages` 已回到 private/internal params bag 入口；
  - 旧的扁平 `peerId + limit` 内部签名已被清除。
- `BCM-ASYNC-007`：通过
  - `sendMessage(params)` 会先刷新 signal snapshot，再等待 main-context drain 完成 UI 可见交付。
- `BCM-STATE-006`：加强通过
  - `debugInvalidateCache()` 现在同时驱逐 cache 和旧 signal，确保 Double Fetch invalidation 与 V9 source semantics 不冲突。

## 6. 下一步

RealMessageService 作为 Phase 3C 样板工程，剩余最像“深水区尾巴”的部分已经非常集中：

- `Signal<Message[]>` 的更真实运行时语义；
- `Promise<Message>` 的等价映射策略；
- 从 Staging-Core harness 向更贴近真实翻译产物的代码形态继续迁移。
