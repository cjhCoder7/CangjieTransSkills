# Trace: Phase 03 Physical Iron Test — RealMessageService Round 27 Compile Baseline

- 日期：`2026-03-30`
- 目标：`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`
- 新运行目录：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-024-round27-compile-baseline`
- 本轮新增 Skill：`skills/cangjie-service-compile-baseline-v1.md`
- 本轮新增 curated pattern：`curated::service::compile-safe::2026-03-30`

## 1. 本轮目的

本轮不是直接追求 `RealMessageService` 编译通过，而是把系统推进到更稳定的“审查通过 -> 真实编译报错”状态，并消灭最近一轮最稳定复现的低层语法幻觉：

- `Atomic`
- `null`
- 普通方法调用上的命名参数前缀
- 对非 `Option` 左值使用 `??`
- 可选链误用

## 2. 本轮改动

### 2.1 Skill 层

新增 `skills/cangjie-service-compile-baseline-v1.md`，明确：

- Service 层 compile-safe 写法统一回到 `Option<T>`、`match`、`HashMap.get/add/remove`、位置参数；
- 明确禁止 `Atomic`、`null`、命名参数乱用、`messageCache[key] ?? fallback`、`user?.accessHash` 之类写法；
- 直接给出最小 Service 骨架示例。

### 2.2 Prompt 层

修改 `scripts/prompt_assembler.py`：

- Translator Prompt 不再只读取前 2 份 Skill 摘要；
- 改为按 compile / syntax / option / null / named arguments / hashmap / match 等关键词优先排序；
- Reviewer 与 Translator 共用同一套摘要选择逻辑；
- 摘要容量提高到最多 4 份 Skill，并带总字符上限，避免把关键信号挤掉。

### 2.3 Pattern Memory 层

向 `artifacts/pattern_memory/pattern_memory.jsonl` 追加 curated pattern：

- `pattern_id=curated::service::compile-safe::2026-03-30`
- 角色对齐 `service`
- 风险标签对齐 `async-flow` / `signal-or-store`
- 目标方法名对齐 `cacheUsers` / `cacheChannels` / `getMessages` / `sendMessage`
- 代码摘录展示 `HashMap.get + match + 位置参数` 的 compile-safe 基线

### 2.4 验证器修复

本轮实弹暴露了一个附带问题：`scripts/verifier.py` 接收相对工具链路径时，没有在 `normalize_verification_config` 中做绝对化，导致实际运行阶段把相对路径带入 attempt 工作目录后报 `command-not-found`。

本轮已修复为：

- `compiler_home`
- `compiler_executable`
- `package_manager_executable`
- `tool_bin_path`
- `stdlib_path`
- `runtime_lib_path`
- `working_directory`

都会先转成绝对路径。

## 3. 本轮验证

### 3.1 Prompt 绿灯

命令：一段最小 Python 验证脚本，构造 3 份 Skill，其中 compile-safe Skill 刻意放在第 3 位。

结果：通过。

结论：`PromptAssembler` 现在会把 compile-safe Skill 提前纳入 Prompt，不再只截断前 2 份。

### 3.2 Pattern Memory 绿灯

命令：对 `RealMessageService.tu.json` 调用 `PatternMemoryEngine.query_for_tu(..., limit=5)`。

结果：通过。

命中列表包含：

- `curated::service::compile-safe::2026-03-30`

结论：新的 curated compile-safe pattern 已经能被 few-shot 检索命中。

### 3.3 Verifier 路径归一化红绿灯

#### 红灯

在修复前，对 `normalize_verification_config` 传入相对路径后断言 `compiler_executable` 为绝对路径，失败。

#### 绿灯

修复后，同一断言通过。

结论：验证器的相对路径 bug 已被定位并修复。

### 3.4 真实 compile 证据回放

为了确认路径修复不是“纸面修复”，本轮直接用旧的 Round 26 attempt 02 候选重新跑 `scripts/verifier.py`，并且继续使用相对工具链路径。

输出文件：`artifacts/verification/realmessageservice-round26-attempt02-pathfix.verify.json`

结果：

- `failure_type=compile-failed`
- 不再是 `command-not-found`
- 重新拿回真实 `cjc` 物理错误：
  - `undeclared identifier 'Atomic'`
  - `undeclared identifier 'null'`
  - `invalid named arguments prefix 'peerId:'`

结论：路径归一化修复生效，验证链已重新能触达真实 `cjc`。

## 4. Round 27 新实弹运行结果

运行目录：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-024-round27-compile-baseline`

结果没有达到本轮主目标，原因不是 Prompt / Pattern 失效，而是出现了两个外部阻塞：

1. Reviewer / Translator 的真实 LLM 调用返回 `HTTP 401`；
2. 初次运行中还叠加了 verifier 相对路径 bug，导致 `command-not-found`。

其中第 2 点本轮已修复并通过独立真实 compile 验证回放确认；第 1 点属于外部凭证问题，当前无法在仓库内自行消除。

## 5. 本轮结论

### 已完成

- compile-safe Skill 已补齐；
- Prompt Skill 摘要选择逻辑已改造；
- curated Pattern Memory 已追加并可命中；
- verifier 相对路径 bug 已修复；
- 真实 compile 能再次回到 `Atomic/null/named-arguments` 这一层物理错误。

### 仍阻塞

- 真实 LLM 凭证无效，导致无法完成新的“Reviewer 通过 -> 真实 compile”完整闭环；
- 因此本轮无法证明新的 Skill / Prompt / Pattern 组合已经在真实 LLM 输出上取得稳定收益，只能证明相关基础设施和 compile-side 验证已经就位。

## 6. 下一步建议

当有效 LLM 凭证恢复后，直接复跑：

- `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-024-round27-compile-baseline`

并保持：

- `skills/cangjie-service-compile-baseline-v1.md` 在 Skill 顺序前列；
- curated compile-safe pattern 继续参与 few-shot；
- verifier 使用当前已修复的绝对路径归一化逻辑。
