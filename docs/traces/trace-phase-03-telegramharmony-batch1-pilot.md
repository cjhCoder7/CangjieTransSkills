# 执行轨迹：Phase 03 / TelegramHarmony Batch-1 Pilot

## 1. Run 元信息

- **Trace ID**：`trace-phase-03-telegramharmony-batch1-pilot`
- **执行日期**：`2026-03-30 ~ 2026-03-31`
- **执行阶段**：`Phase 3C / Staging-Core / Linux / Batch Translation Pilot`
- **manifest**：
  - `docs/manifests/telegramharmony-phase02-batch1.json`
  - `docs/manifests/telegramharmony-phase02-batch1-real-compile.json`
- **批次运行目录**：
  - `artifacts/batch_runs/telegramharmony-phase02-batch1`
  - `artifacts/batch_runs/telegramharmony-phase02-batch1-real-compile`
- **执行命令**：
  - `python scripts/pipeline_batch_runner.py --manifest docs/manifests/telegramharmony-phase02-batch1.json`
  - `python scripts/pipeline_batch_runner.py --manifest docs/manifests/telegramharmony-phase02-batch1-real-compile.json`

## 2. 本轮目标

把当前单文件 `pipeline_runner.py` 升级为“可顺序调度一批 TelegramHarmony 文件，并输出批次级汇总工件”的最小 Pilot 能力；同时收紧批次状态分类，消灭 `summary.status=passed` 但 `orchestration.final_status=failed` 的假阳性。

## 3. 本轮新增内容

- 新增 `scripts/pipeline_batch_runner.py`
  - 读取 batch manifest；
  - 顺序调用 `pipeline_runner.py --target-file ...`；
  - 为每个 target 生成独立 `run_root / summary / failure / stdout / stderr`；
  - 在批次层汇总 `batch-summary.json / success-list.json / failure-list.json / pattern-candidates.json`。
- 新增 `docs/manifests/telegramharmony-phase02-batch1.json`
  - 固化首批 `4` 个低/中风险文件；
  - 追加 `RealMessageService.ets` 作为 `count_toward_kpi=false` 的冻结控制样板。
- 新增 `docs/manifests/telegramharmony-phase02-batch1-real-compile.json`
  - 在 Linux SDK 环境下复用同一批 target，切到 `mock translator + real compile` 验证口径。
- 新增 Python 单测：`tests/test_pipeline_batch_runner.py`
  - 覆盖命令构建、manifest 相对路径解析、环境继承、依赖顺序校验、fail-continue、失败 stderr 截断、`orchestration.final_status` 假阳性防线。
- 加固 `scripts/pipeline_batch_runner.py` 状态分类
  - 优先读取 `summary.orchestration.final_status`，不再盲信顶层 `summary.status`；
  - 统一 `repair_required` / `repair-required` 归一化；
  - 即使子进程 `exit_code=0`，只要最终编排态为失败，也要在批次根目录落盘 `failure/<label>.failure.json` 与 `failure/<label>.stderr.log`。

## 4. 验证命令

```bash
python -m unittest discover -s tests -p 'test_*.py' -v
python scripts/pipeline_batch_runner.py --manifest docs/manifests/telegramharmony-phase02-batch1.json
export CANGJIE_HOME="$PWD/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie"
export PATH="$CANGJIE_HOME/build-tools/bin:$CANGJIE_HOME/build-tools/tools/bin:$CANGJIE_HOME/build-tools/third_party/llvm/bin:$PATH"
export LD_LIBRARY_PATH="$CANGJIE_HOME/build-tools/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}"
python scripts/pipeline_batch_runner.py --manifest docs/manifests/telegramharmony-phase02-batch1-real-compile.json
```

## 5. 验证结果

### 5.1 Python 回归

- `17/17` 全绿。

### 5.2 Classifier Hardening 观察

- 发现旧版 `pipeline_batch_runner.py` 存在假阳性：只看 `summary.status` 与子进程 `exit_code`，会把顶层 `passed` 但内部 `orchestration.final_status=failed` 的条目标成通过。
- 修复后，批次状态以 `orchestration.final_status` 为第一优先级；旧的 Batch-1 “全绿”判决不再可信，必须以本次重跑结果为准。

### 5.3 Batch-1 dry-run（重跑后）

- 批次状态：`partial`
- 统计结果：
  - `total_entries = 5`
  - `counted_entries = 4`
  - `passed_entries = 3`
  - `failed_entries = 2`
  - `counted_passed_entries = 2`
  - `counted_failed_entries = 2`
- 逐文件结果：
  - `src/core/mtproto/MTProtoConfig.ets` → `passed`
  - `src/core/mtproto/CryptoUtils.ets` → `passed`
  - `src/core/mtproto/TLMethods.ets` → `failed`
  - `src/core/mtproto/TLSerialization.ets` → `failed`
  - `src/services/RealMessageService.ets` → `passed`（控制样板，不计入 KPI）
- 失败根因口径：`TLMethods.ets` 与 `TLSerialization.ets` 的顶层 `summary.status` 虽为 `passed`，但 `orchestration.final_status` 均为 `failed`，现已被正确识别。

权威汇总见：

- `artifacts/batch_runs/telegramharmony-phase02-batch1/batch-summary.json`
- `artifacts/batch_runs/telegramharmony-phase02-batch1/success-list.json`
- `artifacts/batch_runs/telegramharmony-phase02-batch1/failure-list.json`
- `artifacts/batch_runs/telegramharmony-phase02-batch1/pattern-candidates.json`

### 5.4 Batch-1 real-compile（Linux SDK 重跑后）

- 批次状态：`failed`
- 统计结果：
  - `total_entries = 5`
  - `counted_entries = 4`
  - `passed_entries = 0`
  - `failed_entries = 5`
  - `counted_passed_entries = 0`
  - `counted_failed_entries = 4`
- 环境快照已写入批次汇总，确认子进程继承：
  - `CANGJIE_HOME=artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie`
  - 对应 `PATH` / `LD_LIBRARY_PATH` 亦已透传到子进程。
- 根级失败工件已按 `fail-continue` 口径落盘：
  - `artifacts/batch_runs/telegramharmony-phase02-batch1-real-compile/failure/`

权威汇总见：

- `artifacts/batch_runs/telegramharmony-phase02-batch1-real-compile/batch-summary.json`
- `artifacts/batch_runs/telegramharmony-phase02-batch1-real-compile/success-list.json`
- `artifacts/batch_runs/telegramharmony-phase02-batch1-real-compile/failure-list.json`

### 5.5 失败簇归因补充（2026-03-31）

- 已新增专项报告：`docs/reports/2026-03-31-telegramharmony-batch1-failure-clusters.md`。
- 当前四个失败 target 主要聚成三类：
  - `CLUSTER-A / MOCK_ARTIFACT_COMPILE_POLLUTION`：`# mock translator artifact` 头部直接污染 real compile；
  - `CLUSTER-B / STATIC_BLACKLIST_SCOPE_LEAK`：`# target: ...TLMethods/TLSerialization...` metadata 被静态墙当成真实代码命中；
  - `CLUSTER-C / REVIEW_CONTRACT_GAP`：`missing-verification-matrix` 持续给 repair guidance 注入噪声。
- 结论：本轮失败主因仍在 pipeline / verifier / reviewer 口径层，还没有进入“这几个 ArkTS 模块已经证明不可翻译”的阶段。

### 5.6 B1-01 修复回放（2026-03-31）

- 已在 `scripts/llm_adapter.py` 中把 mock translator 候选物从 `# ...` 头部改为 `// ...` 注释元数据 + 最小 `main(): Int64 { return 0 }` stub。
- 已新增回归测试：`tests/test_llm_adapter.py`。
- 修复后重新执行：
  - `python -m unittest discover -s tests -p 'test_*.py' -v` → `18/18 OK`
  - `python scripts/pipeline_batch_runner.py --manifest docs/manifests/telegramharmony-phase02-batch1-real-compile.json` → `status=passed`
- 最新 real-compile 结果：
  - `total_entries = 5`
  - `counted_entries = 4`
  - `counted_passed_entries = 4`
  - `counted_failed_entries = 0`
- 解释口径：这次通过说明 **Batch-1 mock translator + real compile 的物理编译基线已经打通**；它不是对四个 ArkTS 模块真实语义翻译质量的最终判决。

## 6. 当前结论

这说明我们已经具备了**工业级的 Batch-1 调度骨架**：

1. 子进程工具链环境继承已验证；
2. `depends_on` 顺序守卫已验证；
3. 单文件失败不会拖垮整批，`failure/` 根级工件已验证；
4. 批次状态不再被顶层 `summary.status` 误导。

但与此同时，本轮也给出了一个更冷酷、也更真实的结论：

- 旧版 Batch-1 “全绿”结论已被推翻；
- `dry-run` 当前只是 `partial`；
- `real-compile` 在初始 classifier hardening 重跑时曾是 `0/4` counted target 通过，但在执行 `B1-01`（mock candidate compile-safe stub）后，最新结果已回到 `4/4` counted target 通过。

所以，**我们已经拿下了小批量自动翻译 Pilot 的 mock+real-compile 物理基线，但还没有进入“大规模自动翻译”放量阶段**。下一步不再是修 mock 编译壳，而是把 Batch-1 切到真实 translator / 真实候选，并开始面对真正的类型、语义和依赖修复。

## 7. 下一步建议

- 第一优先级：从 `MTProtoConfig.ets` / `CryptoUtils.ets` / `TLMethods.ets` / `TLSerialization.ets` 的 `summary.json + stderr + final_output_path` 中抽取第一批真实编译失败模式，形成 `pattern candidates -> repair backlog`。
- 第二优先级：为 Batch-1 的失败条目补 `failure_class` 归因，让后续 CI / 汇总表不止知道“失败”，还知道“为什么失败”。
- 第三优先级：只有当 Batch-1 的 counted target 在 `real-compile` 口径下至少拿到稳定的 `3/4` 通过，才进入 Batch-2（如 `AuthKeyCreator.ets` / `MTProtoClient.ets`）。
