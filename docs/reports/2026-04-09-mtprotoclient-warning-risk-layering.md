# 2026-04-09 MTProtoClient Frozen Baseline Warning Risk Layering

## 目标

完成 `MTProtoClient.ets` 当前 frozen baseline compile warnings 的风险分层，明确哪些 warning 需要继续修复、哪些 warning 可以按当前基线口径接受。

## 输入

- 执行命令：
  - `env -u SILICONFLOW_API_KEY bash scripts/run_mass_translation.sh docs/manifests/batch_manifest_phase05.json`
- 批次汇总：
  - `artifacts/batch_runs/telegramharmony-phase05-mass-translation-initialization/batch-summary.json`
- `MTProtoClient` 当前批次 run root：
  - `artifacts/batch_runs/telegramharmony-phase05-mass-translation-initialization/runs/src-core-mtproto-MTProtoClient.ets/`
- 冻结候选执行证据：
  - `artifacts/batch_runs/telegramharmony-phase05-mass-translation-initialization/runs/src-core-mtproto-MTProtoClient.ets/mtprotoclient-ets.orchestration.json`
  - `artifacts/batch_runs/telegramharmony-phase05-mass-translation-initialization/runs/src-core-mtproto-MTProtoClient.ets/temp_workspace/20260409T131320Z-tu-pipeline-mtprotoclient-src-core-mtproto-mtprotoclient.ets/attempt-01/verify_result.json`
- 冻结候选源码：
  - `artifacts/batch_runs/telegramharmony-phase05-mass-translation-initialization/runs/src-core-mtproto-MTProtoClient.ets/temp_workspace/20260407T064732Z-tu-pipeline-mtprotoclient-src-core-mtproto-mtprotoclient.ets/attempt-01/src/core/mtproto/MTProtoClient.cj`
- 源侧对照：
  - `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoClient.ets`
  - `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoConfig.ets`

## 方法

1. 确认本轮 `Phase05` baseline 仍是 `10/10 passed`，排除 warning 已升级为真实失败的可能。
2. 确认 `MTProtoClient` 本轮执行模式是 `frozen-candidate`，避免把 live translator 候选和 frozen baseline warning 混在一起。
3. 读取 `verify_result.json` 的 compile `stderr`，提取 warning 原文。
4. 将 warning 落点与 frozen candidate / source truth 对照，判断其是否构成：
   - 语义漂移；
   - 行为回退；
   - source contract 破坏；
   - 仅限编译器 hygiene / constant-folding 噪声。

## 结果

### Warning 1

- 文本：`unused import 'std.sync.*'`
- 位置：`MTProtoClient.cj:3`
- 当前判断：`Low / Cosmetic / Accepted Baseline Compiler Noise`
- 依据：
  - frozen candidate 在当前 verifier real compile 下 `exit_code=0`；
  - 该 import 未参与 public contract、状态机、I/O、singleton、callback contract 或 async control flow；
  - 该 warning 只说明当前 anchor 还带一条未清理的 import hygiene，不指向 source drift 或 behavior regression。

### Warning 2

- 文本：`unreachable block in 'if' expression`
- 位置：`MTProtoClient.cj:27`
- 触发代码：
  - `let dcId = if (MTProtoConfig.USE_TEST_DC) { 2 } else { 1 }`
- 当前判断：`Low / Source-Backed Constant-Folding Noise / Accepted Baseline Compiler Noise`
- 依据：
  - source truth `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoConfig.ets` 明确固定 `USE_TEST_DC = true`；
  - frozen baseline 的 `MTProtoConfig.cj` 也把 `USE_TEST_DC` 落成 `true`；
  - 因此编译器把 `else` 分支视为不可达，是当前 repo-local source corpus 下的常量折叠结果，不代表 `MTProtoClient` 的控制流语义已经偏离源侧。

## 决策

- `MTProtoClient` 当前 frozen baseline 的 2 条 compile warnings 均收口为 `Accepted Baseline Compiler Noise`。
- 后续对 `docs/manifests/batch_manifest_phase05.json` 中 `MTProtoClient.ets` 这条 frozen baseline，维持 `exit=0 即通过` 的口径。
- 不再为这 2 条 warning 单独消耗 repair 轮次。

## 触发重新打开的条件

- `MTProtoClient` 或 `MTProtoConfig` 的 frozen anchor 被有意 restage。
- `raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoConfig.ets` 改动了 `USE_TEST_DC` 的常量语义。
- warning 数量增加，或 warning 类型从 hygiene / constant-folding 演化为 async contract、singleton safety、callback contract、binary I/O 等结构性问题。

## 结论

`MTProtoClient.ets` 当前不再存在 `compile warnings risk layering pending`。在当前 frozen baseline 口径下，这 2 条 warning 都是可解释、可复现、且不构成 active blocker 的编译器噪声。
