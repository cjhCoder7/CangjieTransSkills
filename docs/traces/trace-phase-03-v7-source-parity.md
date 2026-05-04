# 执行轨迹：Phase 03 / V7 source_parity

## 1. Run 元信息

- **Trace ID**：`trace-phase-03-v7-source-parity`
- **执行日期**：`2026-03-30`
- **执行阶段**：`Phase 3C / Staging-Core / Linux 物理编译`
- **目标样本**：`samples/real-message-service-cache-001`
- **目标任务**：把 `RealMessageService` 的 public API 从验证壳形态收口到 ArkTS source parity 方向
- **真理源**：`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:74`、`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets:111`
- **关联契约**：`BCM-ALIGN-001`、`BCM-ALIGN-002`
- **关联设计**：`docs/superpowers/specs/2026-03-30-phase3c-realmessageservice-source-parity-design.md`
- **关联计划**：`docs/superpowers/plans/2026-03-30-phase3c-realmessageservice-source-parity-plan.md`

## 2. 红灯阶段

本轮先新增 `samples/real-message-service-cache-001/src/source_parity_signature_test.cj`，直接以 source parity 心智去调用：

- `service.getMessages(peerId, limit)` 后要求返回值提供 `currentSnapshot()`；
- `service.sendMessage(params)` 要求 public 面接受 `SendMessageParams` bag。

真实红灯如下：

1. `getMessages` 当前返回的是 `Array<DomainMessage>`，没有 `currentSnapshot()`；
2. `SendMessageParams` 尚未定义；
3. `sendMessage` 仍要求 `(peerId, text)` 两参数。

红灯证据：

- `artifacts/behavior_runs/phase03-v7-source-parity-red/summary.json`
- `artifacts/behavior_runs/phase03-v7-source-parity-red/cjpm-test.log`

## 3. 绿灯实现

### 3.1 `sendMessage` 收口为 params bag

- 新增 `SendMessageParams(peerId, text)`；
- `RealMessageService.sendMessage` 的 public 面收口为 `sendMessage(params)`；
- adapter 内核仍保留 `sendMessage(peerId, text)`，从而把 source parity 约束留在业务公开面，而不是把整个内核重写一遍。

### 3.2 `getMessages` 收口为 signal-like public shape

- 新增 `MessageSignal`；
- `RealMessageService.getMessages(peerId, limit)` 现在返回 `MessageSignal`；
- `MessageSignal.currentSnapshot()` 提供当前快照读取能力；
- 这样既保住了 source 侧的 “signal-like public shape”，又不需要在当前阶段强行完整复刻 ArkTS `Signal<Message[]>` 的运行时语义。

### 3.3 V5 / V6 内核保持不动

以下能力全部保留：

- cache `Mutex` 串行化；
- `Epoch` 世代推进；
- stale handoff discard；
- Double Fetch invalidation；
- No-Leak lock probe；
- strict observer log。

它们现在是“披着 ArkTS 外壳运行的仓颉强内核”，而不是新的 public API。

## 4. 最终验证

### 4.1 全量测试

执行：

- `cd samples/real-message-service-cache-001 && cjpm test`

结果：

- `17/17` 通过；
- 新增 source parity 两条测试全绿；
- V5 / V6 / 包 A-B-C / UI refresh 全部未回归。

### 4.2 熔断验证

执行：

- `timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'`

结果：

- 正常退出；
- source parity 收口未引入新的死锁或挂起。

### 4.3 物理证据

- `artifacts/behavior_runs/phase03-v7-source-parity-green/summary.json`
- `artifacts/behavior_runs/phase03-v7-source-parity-green/cjpm-test.log`
- `artifacts/behavior_runs/phase03-v7-source-parity-green/cjpm-test-timeout-5s.log`

## 5. 本轮结论

- `BCM-ALIGN-001`：通过
  - `getMessages(peerId, limit)` 保持源侧参数形态；
  - `sendMessage` 已收口为 `SendMessageParams` bag；
  - public API 已不再停留在扁平验证壳阶段。
- `BCM-ALIGN-002`：部分达成
  - V5 / V6 强并发内核已压回 source-aligned public 面之下；
  - 但 `debugInvalidateCache` / `debugForceAdvanceEpoch` 等 seam 仍是 harness-only public 口，后续仍需继续下沉。

## 6. 下一步

真正的下一击已经很清楚：

- 不再继续争论 public API 长什么样；
- 直接回到 `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`，对照 source 真实实现，逐段把 `Signal` / `messageSignals` / `fetchMessages` / `sendMessage` 的剩余语义差距一项项收平。
