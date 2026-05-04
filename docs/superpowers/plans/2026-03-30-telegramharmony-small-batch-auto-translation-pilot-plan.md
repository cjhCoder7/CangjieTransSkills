# TelegramHarmony 小批量自动翻译 Pilot Plan

## 1. 目标

用最小增量把当前单文件 `pipeline_runner.py` 能力升级为“可顺序调度一批 TelegramHarmony 文件，并输出批次级汇总”的 Pilot 流程。

## 2. 执行范围

### 冻结样板

- `raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`

### Batch-1

- `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoConfig.ets`
- `raw_docs/telegramharmony-phase02/src/core/mtproto/CryptoUtils.ets`
- `raw_docs/telegramharmony-phase02/src/core/mtproto/TLMethods.ets`
- `raw_docs/telegramharmony-phase02/src/core/mtproto/TLSerialization.ets`

## 3. 实施步骤

- [ ] 创建 Batch-1 manifest，记录目标文件、风险等级、验证模式与统计口径
- [ ] 设计批次运行目录布局，固定 `manifest / batch-summary / per-file summaries` 路径
- [ ] 新增轻量 batch wrapper，顺序调用 `scripts/pipeline_runner.py`
- [ ] 保持单文件 pipeline 不改语义，只在外层做批次封装
- [ ] 先跑 `mock-mode + verify-dry-run` 验证批次流程通顺
- [ ] 再对通过率最高的文件切真实 compile 验证
- [ ] 汇总 batch 级 success/failure 列表与 failure class 统计
- [ ] 回写 trace 与 pattern candidate 文档

## 4. 验证策略

### 第一轮

- 目标：证明“批次能完整跑完且每个文件有独立 summary”
- 模式：`mock-mode + verify-dry-run`

### 第二轮

- 目标：证明“批次中至少一部分文件可以真实 compile pass”
- 模式：对已通过 review / dry-run 的文件启用真实 compile

## 5. 完成判定

满足以下条件即可判定 Pilot 第一阶段完成：

1. Batch-1 全部文件都生成了独立 summary / failure；
2. 批次级 `batch-summary.json` 生成成功；
3. 至少 `3/4` 文件 compile pass 或达到可复现 repair-required；
4. 至少形成一份可回用的批量翻译模式总结。

## 6. 非目标

本轮明确不做：

- 不直接翻 `MTProtoTransport.ets`；
- 不直接做整仓目录级翻译；
- 不重写 `pipeline_runner.py` 内核；
- 不引入 GUI / DevEco / 模拟器依赖；
- 不承诺首轮就打通所有高风险异步协议模块。
