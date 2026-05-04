# 执行轨迹：Phase 03 / TelegramHarmony Batch-1 Real Translator First Blood

## 1. Run 元信息

- **Trace ID**：`trace-phase-03-telegramharmony-batch1-real-translator`
- **执行日期**：`2026-03-31`
- **执行阶段**：`Phase 3C / Staging-Core / Linux / Real Translator + Real Compile`
- **manifest**：`docs/manifests/telegramharmony-phase02-batch1-real-translator.json`
- **批次运行目录**：`artifacts/batch_runs/telegramharmony-phase02-batch1-real-translator`
- **LLM 网关**：`SiliconFlow OpenAI-Compatible API`
- **LLM 模型**：`Pro/zai-org/GLM-4.7`
- **执行命令（敏感值已省略）**：
  - `OPENAI_BASE_URL=https://api.siliconflow.cn/v1 OPENAI_MODEL=Pro/zai-org/GLM-4.7 python scripts/pipeline_batch_runner.py --manifest docs/manifests/telegramharmony-phase02-batch1-real-translator.json`

## 2. 本轮目标

在保留 `mock+real-compile` 物理基线的前提下，首次把 `Batch-1` 切入 **真实翻译引擎**，让真实 ArkTS 源码生成的仓颉候选直接面对 Linux SDK 的 `cjc` 与静态墙，收集第一批真正有工程价值的 failure / stderr / repair guidance。

## 3. 本轮新增输入与约束

- 新增 manifest：`docs/manifests/telegramharmony-phase02-batch1-real-translator.json`
- 新增架构约束文档：`docs/strategy/phase-03-source-alignment-directives.md`
- `PromptAssembler` 已固定注入 Source Alignment 铁律：
  - `BCM-ALIGN-001 / Signature Parity`
  - `BCM-ALIGN-002 / Encapsulated Enhancement`
  - `raw_docs/telegramharmony-phase02/...` 为绝对真理；
  - public API 严禁加戏；并发/锁/Epoch 只能藏在 `private / internal`。
- 对应回归测试：`tests/test_prompt_assembler.py`

## 4. 验证结果总览

### 4.1 Python 回归

- `19/19` 全绿。

### 4.2 Batch-1 Real Translator

- 批次状态：`failed`
- 统计结果：
  - `total_entries = 5`
  - `counted_entries = 4`
  - `counted_passed_entries = 0`
  - `counted_failed_entries = 4`
- 权威汇总：`artifacts/batch_runs/telegramharmony-phase02-batch1-real-translator/batch-summary.json`
- 根级失败工件：`artifacts/batch_runs/telegramharmony-phase02-batch1-real-translator/failure/`

## 5. 逐目标首轮红灯

### 5.1 `src/core/mtproto/MTProtoConfig.ets`

- `review_issue_codes`：
  - `ARCH_SOURCE_ALIGNMENT_VIOLATION`
  - `ARCH_CONTRACT_RUPTURE`
- `verify_failure_type`：`compile-failed`
- 代表性问题：真实翻译候选擅自引入 `SessionManager` / `SessionInfo` / `AuthKeyState` 等超出 TU 边界的 public 逻辑，触发 source alignment 审查红灯。
- 代表性编译器报错：
  - `error: expected declaration, found Created`
  - `error: expected declaration, found '?'`

### 5.2 `src/core/mtproto/CryptoUtils.ets`

- `review_issue_codes`：
  - `BCM_ALIGN_001_SIGNATURE_PARITY`
  - `ARCH_DOMAIN_PURITY_VIOLATION`
- `verify_failure_type`：`compile-failed`
- 代表性问题：翻译器把 `Uint8Array` / binary payload 粗暴改写成 `String`，既撕裂了源侧签名，又触发领域纯洁度误配。
- 代表性编译器报错：
  - `error: unexpected variable declaration in interface body`
  - `error: expected declaration, found '{'`

### 5.3 `src/core/mtproto/TLMethods.ets`

- `review_issue_codes`：大量 `ARCH_PROTOCOL_ISOLATION` 与 `ARCH_SYNTAX_REGRESSION`
- `verify_failure_type`：`static-blacklist-failed`
- 代表性静态墙命中：
  - `public abstract class InputPeer {}`
  - `class InputPeerChannel extends InputPeer`
- 判断：真实翻译候选仍然把 TL / InputPeer 协议层直接暴露在 public 代码体中。

### 5.4 `src/core/mtproto/TLSerialization.ets`

- `review_issue_codes`：大量 `ARCH_DOMAIN_PURITY_VIOLATION` / `ARCH_PROTOCOL_ISOLATION` / `ARCH_SYNTAX_REGRESSION`
- `verify_failure_type`：`static-blacklist-failed`
- 代表性静态墙命中：
  - `public class TLConstructors {`
- 判断：翻译器直接把 `TLConstructors` 这种协议/序列化细节留在候选 public 代码中，静态墙直接熔断。

### 5.5 `src/services/RealMessageService.ets`

- `review_issue_codes`：大量 `ARCH_SYNTAX_REGRESSION` / `ARCH_DOMAIN_PURITY_VIOLATION`
- `verify_failure_type`：`static-blacklist-failed`
- 代表性静态墙命中：
  - `HashMap<String, ArrayList<DomainMessage>>()`
- 判断：真实翻译候选再次回落到 `ArrayList` 等非仓颉/非 source-aligned 容器心智，且污染了 service 内部状态实现。

## 6. 当前结论

这是一次**合格的首轮真翻译试射**，因为我们拿到的已经不是 mock 模板错误，而是真正有修复价值的红灯：

1. `MTProtoConfig` 暴露出 **source alignment / contract rupture**；
2. `CryptoUtils` 暴露出 **signature parity + domain purity drift**；
3. `TLMethods` / `TLSerialization` / `RealMessageService` 暴露出 **protocol isolation / syntax regression / static blacklist**；
4. `pipeline_batch_runner.py` 的 `fail-continue` 机制生效，5 个目标全部跑完，根级 `failure/` 工件完整落盘。

换句话说，**我们已经正式越过“物理基线验证”阶段，进入“真实语义失败模式采集”阶段。**

## 7. 下一步建议

- 第一优先级：把这 5 个失败目标按真实失败类型再次聚成 repair backlog：
  - `REAL-ALIGN-DRIFT`
  - `REAL-SIGNATURE-RUPTURE`
  - `REAL-PROTOCOL-LEAK`
  - `REAL-SYNTAX-REGRESSION`
- 第二优先级：优先修 `MTProtoConfig` 与 `CryptoUtils`，因为它们已经给出可编译候选与明确 compile diagnostics，最适合作为第一批真实 repair 样本。
- 第三优先级：再处理 `TLMethods` / `TLSerialization` / `RealMessageService` 的静态墙协议泄漏问题，把 translator 从“会生出 TL* / InputPeer / ArrayList 幻觉”拉回 source-aligned 轨道。
