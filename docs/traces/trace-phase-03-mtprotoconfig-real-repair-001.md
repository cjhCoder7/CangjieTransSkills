# Trace：Phase 03 `MTProtoConfig.ets` 真实 Repair 循环（Linux SDK）

- **日期**：2026-03-31
- **目标文件**：`raw_docs/telegramharmony-phase02/src/core/mtproto/MTProtoConfig.ets`
- **目标阶段**：`Staging-Core / Real Translator + Real Compile`
- **物理工具链**：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie`
- **结果**：`MTProtoConfig.ets` 已在真实 Reviewer + 真实 `cjc` 编译链路下通过

## 1. 初始红灯

首轮真实批跑表明 `MTProtoConfig.ets` 同时暴露了三类问题：

1. **Reviewer 误判 source alignment**：同文件内真实存在的 `SessionInfo` / `SessionManager` / `AuthKeyState` 被误判为越界 public surface。
2. **静态墙误杀 module**：`static-binary-buffer-in-service` 规则把 `module` 角色的 `[BINARY_PROTO]` 文件按 `service` 口径封杀。
3. **物理编译假红灯**：单文件 TU 默认按可执行程序编译，导致大量合法库/模块文件被 `main is missing` 假拦截。

## 2. 本轮落地修复

### 2.1 `scripts/prompt_assembler.py`

- 给 Translator / Reviewer 同步注入更强的 `Source Alignment` 上下文：
  - 展开同文件 `public symbols`；
  - 展开 `target.signatures`；
  - 明确“同文件已声明 public symbols 不得误判为越界发明”。
- 增加真实 repair 指令：
  - `?T / None / Array<UInt8>` 可空与二进制映射；
  - `enum` 物理语法：`public enum X { | A | B }`；
  - 命名参数禁令：构造器必须回到**位置参数**；
  - accessor 语法禁令：必须写成 `func getX(): T`，不能写 `get x(): T`。
- 对 Reviewer 增加一条关键等价映射口径：
  - 当 ArkTS `public interface` 含属性，而仓颉 `interface` 不支持存储字段时，允许降级为 **getter/setter accessor-based interface + private/internal 实现类**；
  - 这种 private/internal 实现不计入 public surface rupture。

### 2.2 `scripts/static_blacklist_checker.py` + `scripts/orchestrator.py`

- 为 `static-binary-buffer-in-service` 加入 **TU 上下文门控**；
- 当目标 `role != service` 时跳过该规则，避免再把 `module` / `BINARY_PROTO` 文件误杀；
- `StaticReviewerFirewall` 改为把 `tu` 一并传给 `StaticBlacklistChecker`。

### 2.3 `scripts/verifier.py` / `scripts/pipeline_runner.py` / `scripts/orchestrator.py`

- 将默认单文件 compile template 切到：

```text
cjc --diagnostic-format noColor --output-type staticlib -o {attempt_dir}/candidate_output {candidate_file_path}
```

- 这样单文件 TU 的物理编译目标变为 **静态库**，不再因为缺少 `main()` 被错误判死。

## 3. 定向测试

本轮新增 / 通过的定向测试：

- `tests/test_prompt_assembler.py`
  - source alignment public symbols 注入；
  - binary/option repair 指令；
  - enum repair 指令；
  - named-argument repair 指令；
  - accessor-syntax repair 指令；
  - reviewer accessor-based interface 等价映射提示。
- `tests/test_static_blacklist_checker.py`
  - `module + [BINARY_PROTO]` 不再命中 `static-binary-buffer-in-service`；
  - `service` 仍继续命中该规则。
- `tests/test_verifier.py`
  - 默认 compile template 已切到 `--output-type staticlib`；
  - 旧 artifact 的 `candidate_bytes_written` 缺失 fallback 仍保持通过。

## 4. 真实收敛轨迹

### 4.1 中间 run

- `artifacts/pipeline_runs/phase03-mtprotoconfig-repair-002/`
  - 解决了 reviewer 对同文件 public symbols 的误判；
  - 红灯收敛到 `enum` 语法与 interface/property 等价映射。
- `artifacts/pipeline_runs/phase03-mtprotoconfig-repair-003/`
  - 收敛到 `named arguments prefix` 与 `main is missing`。
- `artifacts/pipeline_runs/phase03-mtprotoconfig-repair-004/`
  - 进一步收敛到 accessor 语法细节（`get dcId()` vs `func getDcId()`）。

### 4.2 最终通关 run

- **Run Root**：`artifacts/pipeline_runs/phase03-mtprotoconfig-repair-005/`
- **Orchestration**：`artifacts/pipeline_runs/phase03-mtprotoconfig-repair-005/mtprotoconfig-ets.orchestration.json`
- **Summary**：`artifacts/pipeline_runs/phase03-mtprotoconfig-repair-005/summary.json`
- **Final Candidate**：
  `artifacts/pipeline_runs/phase03-mtprotoconfig-repair-005/temp_workspace/20260331T023845Z-tu-pipeline-mtprotoconfig-src-core-mtproto-mtprotoconfig.ets/attempt-03/src/core/mtproto/MTProtoConfig.cj`

最终判定：

- `final_status = passed`
- `final_review_result.passed = true`
- `final_verify.passed = true`
- `final_verify.failure_type = ""`

## 5. 最终候选的关键形态

最终通过的 `MTProtoConfig.cj` 体现出如下稳定模式：

1. `AuthKeyState` 使用仓颉可编译的 `enum` 写法：`| None | Created`；
2. `SessionInfo` 保持 `public interface` 外壳；
3. 属性等价映射下沉为 `func getX(): T` 访问器；
4. 存储字段藏在 `internal class SessionInfoImpl` 内；
5. `SessionManager.getSession(...)` 继续返回 `SessionInfo`，但内部以**位置参数**构造 `SessionInfoImpl`；
6. 真实 compile 使用 `staticlib` 输出模式，避免 `main` 假红灯。

## 6. 阶段结论

这次 repair 证明了三件事：

1. **Source Alignment 铁律** 可以在真实 LLM + 真实编译链路下落地，不再只是纸面规则；
2. **Linux SDK 无头物理编译** 足以把 TelegramHarmony 的低风险基础模块推进到真实通关；
3. 后续批量自动翻译应优先复用本轮沉淀出的四条稳定模式：
   - 同文件 public symbols 注入；
   - accessor-based interface 等价映射；
   - `staticlib` 单文件编译口径；
   - named-argument / enum / accessor 物理语法回灌。

## 7. 下一步建议

- 按同样策略切入 `raw_docs/telegramharmony-phase02/src/core/mtproto/CryptoUtils.ets`；
- 将 `MTProtoConfig` 本轮成功模式抽成可复用 repair recipe，供 Batch-1 后续真实 repair 循环复用；
- 在 `Batch-1 real-translator` 汇总里把 `MTProtoConfig.ets` 从“失败样本”迁移到“已打通样本”。
