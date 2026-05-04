# 脚本目录

用于存放可重复执行的工具脚本，例如：

- 文档清洗；
- Skill 片段生成；
- 检索辅助；
- 样本评测；
- 结果汇总。

后续新增脚本时，请至少补充：用途、输入、输出、依赖、执行示例。


## `build_phase06_ui_source_corpus.py`

- ???? `docs/manifests/phase06_ui_sample_manifest.json` ? `priority / adoption_decision / source_type / role` ??????????? file-level slicing ??? source corpus manifest?
- ?????
  - ??? `ordered_samples`?`control_samples` ? `exception_references` ????????
  - ???? `role` ?? exception/reference ????????? `priority / adoption_decision`?
  - ? external repo ???? `repo_name` ? `repo_local_paths`?? local repo control ???? repo-local ???
  - ???? frozen ???????????? corpus ?????????? manifest?
- ?????
  - `python3 scripts/build_phase06_ui_source_corpus.py --corpus-root raw_docs/phase06-ui-p0 --manifest-name phase06-ui-source-corpus-p0 --priority P0 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p0.json`
  - `python3 scripts/build_phase06_ui_source_corpus.py --corpus-root raw_docs/phase06-ui-p1 --manifest-name phase06-ui-source-corpus-p1 --priority P1 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p1.json`
  - `python3 scripts/build_phase06_ui_source_corpus.py --sample-bucket exception_references --corpus-root raw_docs/phase06-ui-exception --manifest-name phase06-ui-source-corpus-exception --priority any --adoption-decision any --source-type external_repo --role exception --output docs/manifests/phase06_ui_source_corpus_exception.json`

## `phase06_ui_workset_audit.py`

- 用途：审计 `Phase06` file-level workset 是否已被一个或多个 prompt-pilot manifest 完整覆盖，输出 `covered / missing / overlap / unknown / exhausted` 结论，避免继续靠人工数 slice。
- 核心能力：
  - 读取一个 file manifest 与多个 prompt-pilot manifests，统一抽取 `slice_id`；
  - 输出结构化报告，包含 `missing_slice_ids`、`overlap_details`、`unknown_slice_ids` 与 `next_action_hint`；
  - 支持 `--require-exhausted`、`--fail-on-overlap`、`--fail-on-unknown`，可作为后续 residual/workset 扩量前的机器闸门。
- 执行示例：
  - `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p0_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_batch1.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_next_stage.json --output artifacts/ui_pilots/20260410-phase06-ui-p0-workset-audit.json --require-exhausted`

## `phase06_ui_expansion_audit.py`

- 用途：把 `phase06_ui_sample_manifest -> source corpus -> file manifest -> workset audit` 串成一份机器报告，判定当前 `Phase06` 应该继续消化现有 workset、冻结新的 regular corpus，还是先 hold 当前检查点。
- 核心能力：
  - 识别 regular `ordered_samples` 是否已经全部冻结为 source corpus；
  - 检查 frozen corpus 是否都已经展开为 file manifest；
  - 结合 `workset-audit` 判定当前 file-level workset 是否已经 exhausted；
  - 输出统一顶层决策：`final_decision`，并兼容保留顶层 `next_action_hint`，覆盖 `repair-manifest-chain-before-expansion`、`expand-frozen-corpus-into-file-manifest`、`continue-current-workset`、`freeze-new-regular-source-corpus`、`hold-current-checkpoint-await-sample-curation`；
  - 为 `workset_audit_reports[*]` 标注 `decision_scope=phase06-file-workset` 与 `workset_next_action_hint`，避免把局部 exhausted 提示误读成全局扩量决策。
- 执行示例：
  - `python3 scripts/phase06_ui_expansion_audit.py --output artifacts/ui_pilots/20260411-phase06-ui-regular-expansion-audit.json --require-decision hold-current-checkpoint-await-sample-curation`

## `phase06_ui_expansion_audit_validate.py`

- 用途：校验 `phase06_ui_expansion_audit.py` 产物的关键机器不变量，确保后续自动化读取的是顶层 `final_decision`，而不是误把 workset 局部 hint 当成全局扩量指令。
- 核心能力：
  - 校验 `audit_name` / `audit_version` / `decision_scope` / `final_decision` / 顶层兼容 `next_action_hint`；
  - 校验 `sample_manifest`、`source_corpus_summary`、`file_manifest_summary`、`workset_summary` 的计数字段与真实列表长度一致；
  - 校验 `workset_audit_reports[*]` 的 `decision_scope=phase06-file-workset` 与 `workset_next_action_hint` / 兼容 `next_action_hint` 一致；
  - 支持 `--require-audit-version` 与 `--require-final-decision`，可作为扩量前的 validator gate。
- 执行示例：
  - `python3 scripts/phase06_ui_expansion_audit_validate.py --audit artifacts/ui_pilots/20260411-phase06-ui-regular-expansion-audit.json --report artifacts/ui_pilots/20260411-phase06-ui-regular-expansion-audit.validation.json --require-audit-version 2 --require-final-decision hold-current-checkpoint-await-sample-curation`

## `full-pass-host-probe.sh`

- 用途：为 `Phase 3C Full Pass` 提供宿主/联调通道准入探测；在环境不满足时给出可归因的 blocker，而不是误把代码问题和环境问题混在一起。
- 核心能力：
  - 探测 `DevEco Studio`、仓颉插件、`hdc` / `adb`、本地 `cjc` / `cjpm` 与 GUI / target 状态；
  - 输出结构化 profile：`artifacts/environment/full-pass-host-profile.json`；
  - 输出联通性日志：`artifacts/environment/full-pass-connectivity-check.log`；
  - 支持 `--fail-if-blocked`，在未满足 `Staging-Full` 条件时以退出码 `2` 硬熔断。
- 执行示例：
  - `scripts/full-pass-host-probe.sh --output artifacts/environment/full-pass-host-profile.json --log artifacts/environment/full-pass-connectivity-check.log --fail-if-blocked`

## `full-pass-summary-builder.py`

- 用途：把过滤后的 Hilog / 运行时日志归一化为符合 `docs/schemas/full-pass-summary-schema.json` 的 `summary.json`。
- 核心能力：
  - 解析 `grep -nE` 过滤后的日志，保留 `raw_log:<line>` 级引用；
  - 从 `BCM-*` / `SMOKE-*` 断言 ID、事件名与线程语义推导 `assertions[]` 与 `runtime_log_capture`；
  - 支持 `--scenario-mode smoke`，为最小部署链路自动派生 `SMOKE-LAUNCH-001`；
  - 输出严格类型化的 `summary.json`，供 `full-pass-summary-validate.py` 做第二闸门校验。
- 执行示例：
  - `python scripts/full-pass-summary-builder.py --log-input docs/schemas/examples/full-pass-runtime.valid.log --raw-log-path docs/schemas/examples/full-pass-runtime.valid.log --summary-output artifacts/environment/full-pass-summary.example.json --label full-pass-example --module-name RealMessageService --source-file src/services/RealMessageService.ets --candidate-file src/services/RealMessageService.cj --host-os Linux --host-arch x86_64 --node-mode headless-host --deveco-studio-home /opt/DevEco-Studio --harmony-sdk-home /opt/HarmonySDK --hdc-path /opt/HarmonySDK/toolchains/hdc --target-type emulator --target-id emulator-5554 --target-name HarmonyEmulator --build-id build-example --bundle-name org.example.rms --install-status passed --launch-status passed --log-source file --log-capture-command 'cat docs/schemas/examples/full-pass-runtime.valid.log' --expected-assertions BCM-CONC-001,BCM-STATE-001,BCM-ASYNC-003`
  - `python scripts/full-pass-summary-builder.py --log-input docs/schemas/examples/full-pass-runtime.valid.log --raw-log-path docs/schemas/examples/full-pass-runtime.valid.log --summary-output artifacts/environment/full-pass-summary.smoke.json --label full-pass-smoke --module-name entry --source-file src/pages/Entry.ets --candidate-file src/pages/Entry.cj --host-os Windows --host-arch x86_64 --node-mode gui-host --deveco-studio-home 'C:/DevEco' --harmony-sdk-home 'C:/HarmonySdk' --hdc-path 'C:/HarmonySdk/toolchains/hdc.exe' --target-type emulator --target-id 127.0.0.1:5555 --target-name 'Enjoy 90 Pro Max' --build-id smoke-build-example --bundle-name com.example.demo --install-status passed --launch-status passed --log-source file --log-capture-command 'type smoke.log' --scenario-mode smoke --expected-assertions SMOKE-LAUNCH-001`

## `full-pass-summary-validate.py`

- 用途：作为 `Phase 3C Full Pass` 的第二道闸门，校验 `summary.json` 是否满足 `docs/schemas/full-pass-summary-schema.json`，并从 `parsed_events` / 原始 Hilog 中提取 BCM Assert ID。
- 核心能力：
  - 使用 `jsonschema` 做 Draft 2020-12 严格校验与格式检查；
  - 校验通过态/失败态 assertion 的 `failure_reason`、证据载荷与运行时 flag 一致性；
  - 从 `parsed_events.message` 与 `raw_log_path` 中提取 `BCM-*` / `SMOKE-*` 断言 ID，并检查是否与 `assertions` 声明闭环；
  - 输出分层退出码，区分“实验未通过”与“证据链断裂”。
- 依赖：`jsonschema`。
- 退出码：
  - `0`：证据有效，且 `overall_status=passed`；
  - `10`：证据有效，但实验结论为非通过（如 `failed` / `blocked` / `partial`）；
  - `20`：Schema 级证据无效；
  - `21`：语义级证据无效；
  - `22`：脚本 / 输入 / 依赖错误。
- 执行示例：
  - `python scripts/full-pass-summary-validate.py --summary docs/schemas/examples/full-pass-summary.valid.json --report artifacts/environment/full-pass-summary.validation.json`

## `full-pass-harmony-refresh.sh`

- 用途：作为 `pipeline_runner.py --full-pass-refresh-cmd` 的真实 Harmony Full Pass refresh harness，串起 `preflight -> state reset -> log capture -> install -> launch -> exercise -> filter -> summary build`。
- 核心能力：
  - 内建 `Timeout Guard`，避免真机 / 模拟器命令卡死；
  - 内建 `Log Pre-processor`，默认只抽取 `BCM/SMOKE/RMS/REFRESH/FETCH/SEND` 相关日志；
  - 支持 `FULL_PASS_SCENARIO_MODE=smoke`，此时 `FULL_PASS_EXPECTED_ASSERTIONS` 可留空并自动回填 `SMOKE-LAUNCH-001`；
  - 内建 `State Reset` 钩子，允许在每轮前清理应用状态与缓存；
  - 直接消费 `pipeline_runner.py` 的占位符参数：`{cycle}`、`{full_pass_summary_path}`、`{run_root}`、`{target_file}`、`{orchestration_output_path}`、`{final_output_path}`、`{full_pass_report_path}`。
- 必需环境变量：
  - `FULL_PASS_HDC_PATH`
  - `FULL_PASS_HDC_SERIAL`（或 `FULL_PASS_TARGET_ID`）
  - `FULL_PASS_TARGET_NAME`
  - `FULL_PASS_PKG_NAME`（或 `FULL_PASS_BUNDLE_NAME`）
  - `FULL_PASS_EXPECTED_ASSERTIONS`（`FULL_PASS_SCENARIO_MODE=bcm` 时必填）
  - `FULL_PASS_DEVECO_STUDIO_HOME`
  - `FULL_PASS_HARMONY_SDK_HOME`
  - `FULL_PASS_EXERCISE_CMD`
- Zero-Assumptions 行为：
  - 缺少关键别名时会直接报出明确错误，如 `Error: FULL_PASS_HDC_SERIAL is not set`；
  - `FULL_PASS_CLEAN_DIR` 会先做 bash 友好的路径标准化，再自动派生 `FULL_PASS_STATE_RESET_CMD`；
  - `FULL_PASS_HILOG_FILTER` 可直接作为 `FULL_PASS_LOG_FILTER_REGEX` 的别名，refresh harness 会先独占写入 `raw_log_path`，再原子生成 `filtered_log_path`，避免日志竞争写入。
- 推荐命令模板：
  - `python scripts/pipeline_runner.py --src-root raw_docs/telegramharmony-phase02 --target-file src/services/RealMessageService.ets --mock-mode --verify-dry-run --full-pass-summary-path artifacts/fullpass/summary.json --full-pass-refresh-cmd 'bash scripts/full-pass-harmony-refresh.sh --cycle {cycle} --summary {full_pass_summary_path} --run-root {run_root} --target-file {target_file} --orchestration-output {orchestration_output_path} --final-output {final_output_path} --report {full_pass_report_path}' --full-pass-max-cycles 3`
- 推荐环境变量模板：
  - `export FULL_PASS_HDC_PATH=/path/to/hdc`
  - `export FULL_PASS_TARGET_ID=emulator-5554`
  - `export FULL_PASS_TARGET_NAME=HarmonyEmulator`
  - `export FULL_PASS_BUNDLE_NAME=org.example.rms`
  - `export FULL_PASS_SCENARIO_MODE=bcm`
  - `export FULL_PASS_EXPECTED_ASSERTIONS=BCM-CONC-001,BCM-STATE-001,BCM-ASYNC-003`
  - `export FULL_PASS_DEVECO_STUDIO_HOME=/opt/DevEco-Studio`
  - `export FULL_PASS_HARMONY_SDK_HOME=/opt/HarmonySDK`
  - `export FULL_PASS_STATE_RESET_CMD='/path/to/hdc -t emulator-5554 shell rm -rf /data/storage/el2/base/files/rms-cache'`
  - `export FULL_PASS_INSTALL_CMD='/path/to/hdc -t emulator-5554 install -r /path/to/app.hap'`
  - `export FULL_PASS_LAUNCH_CMD='/path/to/hdc -t emulator-5554 shell aa start -a EntryAbility -b org.example.rms'`
  - `export FULL_PASS_EXERCISE_CMD='/path/to/hdc -t emulator-5554 shell uitest dumpLayout -b org.example.rms'`
  - `export FULL_PASS_SCENARIO_MODE=smoke`

## `find_harmony_artifact.py`

- 用途：在 DevEco / Harmony 工程根目录下定位最新 `.hap` 产物，并抽取 `bundleName` / `EntryAbility` 等可直接回填到 `.env.full-pass.local` 的事实值。
- 核心能力：
  - 默认优先读取 `AppScope/app.json5` 与 `entry/src/main/module.json5`；
  - 递归扫描工程内所有 `.hap`，按修改时间倒序选出最新候选；
  - 支持 `json` 与 `env` 两种输出格式；
  - 若额外提供 `--host-probe-json`，则会把 `full-pass-host-probe` 已探明的宿主 / `hdc` / target 信息一并编织进 `env` 输出，直接生成 `.env.full-pass.local` 所需的核心字段；
  - 当工程已识别但尚未产出 `.hap` 时，以退出码 `2` 明确提示“还差构建产物”，同时保留已解析的元数据。
- 执行示例：
  - `python scripts/find_harmony_artifact.py --project-root E:/deveco_cangjie_control_project --format json`
  - `python scripts/find_harmony_artifact.py --project-root E:/deveco_cangjie_control_project --format env`
  - `python scripts/find_harmony_artifact.py --project-root E:/deveco_cangjie_control_project --host-probe-json artifacts/environment/full-pass-host-profile.windows.json --target-name "Enjoy 90 Pro Max" --format env`

## `analyze_cangjie_interop_contract.py`

- 用途：在 DevEco / Harmony 工程根目录下诊断 ArkTS 与 Cangjie 的 interop 导出契约是否对齐，尤其用于定位 `libohos_app_cangjie_entry.so` 的 direct import / loader-object 失配。
- 核心能力：
  - 扫描 ArkTS 页面中对 `libohos_app_cangjie_entry.so` 的 direct import 与 `requireCJLib(...)` 调用形态；
  - 扫描 `src/main/cangjie/**/*.cj` 中 `JSModule.registerModule` 的 `exports["..."]` 导出名；
  - 扫描本地 `.d.ts` 声明文件与 `libark_interop_loader.so` 线索，判断当前工程更接近 `direct-default`、`direct-named` 还是 `loader-object` 契约；
  - 当发现“工程内已存在 loader-object 路径，但 ArkTS 仍直接 import `libohos_app_cangjie_entry.so`”这类高概率失配时，以退出码 `2` 明确报错。
- 执行示例：
  - `python scripts/analyze_cangjie_interop_contract.py --project-root E:/deveco_cangjie_control_project --format json`
  - `python scripts/analyze_cangjie_interop_contract.py --project-root E:/deveco_cangjie_control_project --format text`

## `skill_generator_v2.py`

- 用途：根据鸿蒙 Markdown / HTML 文档和压缩版 V2 Schema 骨架生成符合 `SKILL_SCHEMA_V2.md` 的 Skill Markdown。
- 依赖：仅依赖 Python 标准库；若走真实模型调用，需要提供 `OPENAI_API_KEY`，可选 `OPENAI_BASE_URL`。

## `repo_indexer.py`

- 用途：扫描 ArkTS / TS / JS 源码并构建仓库级 SQLite 结构索引库。
- 核心能力：
  - 初始化 `snapshots`、`nodes`、`edges` 表；
  - 优先尝试 `tree-sitter`，失败自动回退到 Regex 后备解析；
  - 提取文件节点、类/接口/函数/方法节点、`import` 依赖、跨文件调用依赖；
  - 标注状态、线程、互操作等基础风险标签。
- 执行示例：
  - `python scripts/repo_indexer.py --root third_party/TelegramHarmony --db artifacts/repo_index.sqlite --snapshot-label telegram-smoke --prefer-tree-sitter --reset-db`

## `repo_map_generator.py`

- 用途：读取 `repo_index.sqlite` 并导出适合 LLM 阅读的 `repo_map.txt`。
- 核心能力：
  - 读取最新或指定快照；
  - 聚合文件角色、关键符号、依赖、反向依赖和调用热点；
  - 输出 Aider 风格的缩进树结构地图。
- 执行示例：
  - `python scripts/repo_map_generator.py --db artifacts/repo_index.sqlite --snapshot-label telegram-smoke --output artifacts/repo_map.txt`

## `tu_bundler.py`

- 用途：基于 `repo_index.sqlite` 为单个目标文件构造 `Translation Unit` JSON。
- 核心能力：
  - 递归计算目标文件的依赖闭包；
  - 对依赖文件只提取类/接口/函数/方法签名与摘要；
  - 组装【目标文件全文】+【依赖闭包精简上下文】的标准化 TU 工件。
- 执行示例：
  - `python scripts/tu_bundler.py --db artifacts/repo_index.sqlite --snapshot-label telegram-smoke --target-file src/pages/HomePage.ets --max-depth 2 --max-dependency-files 12 --max-signatures-per-file 8`

## `llm_adapter.py`

- 用途：为 Orchestrator 提供统一的 OpenAI 兼容模型调用接口。
- 核心能力：
  - 支持 Chat Completions 请求；
  - 支持 Timeout 与 Exponential Backoff 重试；
  - 提供 `MockLLMAdapter` 供离线联调使用；
  - `MockLLMAdapter` 当前会输出 **real-compile-safe** 的最小仓颉占位候选（`//` 注释元数据 + `main(): Int64 { return 0 }`），避免在 Linux `Staging-Core` 下用 mock translator 做物理编译基线时被候选头部本身污染。
- 依赖：仅依赖 Python 标准库。

## `prompt_assembler.py`

- 用途：将 TU、Schema、架构 Skill 与 Pattern Memory 组装为角色隔离的 Translator / Reviewer Prompt。
- 核心能力：
  - Translator 角色：资深仓颉 / ArkTS 双栈架构师；
  - Reviewer 角色：苛刻的架构审查委员会；
  - 可注入 `Pattern Memory Few-Shot`。
- 依赖：`llm_adapter.py` 中的 `ChatMessage`。

## `workspace_manager.py`

- 用途：为每次 Orchestrator 运行创建物理沙盒，并把候选 `.cj` 文件落盘到唯一工作区。
- 核心能力：
  - 在 `artifacts/temp_workspace/` 下创建带时间戳的运行目录；
  - 为每个 attempt 创建独立目录；
  - 将候选代码写入 `.cj` 文件；
  - 记录 `session.json` 与 `attempt_manifest.json`。
- 依赖：仅依赖 Python 标准库。

## `verifier.py`

- 用途：提供 Compile / UnitTest / Behavior 三段式验证外壳。
- 核心能力：
  - `CompileChecker`、`UnitTestChecker`、`BehaviorMockChecker` 三阶段；
  - 支持 `subprocess` 真实调用；
  - 默认 dry-run / mock，便于在没有 `cjc` / `cjpm` 的环境中联调；
  - 能消费真实的 `candidate_file_path`、`workspace_dir`、`attempt_dir`。
- 执行示例（dry-run）：
  - `python scripts/verifier.py --tu-json artifacts/tu/HomePage.ets.tu.json --artifact-json artifacts/orchestration/HomePage.ets.tu.orchestration.json`
- 执行示例（尝试真实命令）：
  - `python scripts/verifier.py --tu-json artifacts/tu/HomePage.ets.tu.json --artifact-json artifacts/orchestration/HomePage.ets.tu.orchestration.json --no-dry-run --real-compile --compile-cmd 'cjc --diagnostic-format noColor --output-type staticlib -o {attempt_dir}/candidate_output {candidate_file_path}'`

## `pattern_memory.py`

- 用途：沉淀成功闭环后的模式记忆，并为后续翻译提供 few-shot 检索。
- 核心能力：
  - 将【ArkTS 接口签名 / 风险标签 / 依赖角色】→【目标侧代码模式摘要】写入 `pattern_memory.jsonl`；
  - 基于角色、签名、风险标签与依赖角色做相似模式查询；
  - 已具备去重逻辑，避免相同模式重复刷屏。
- 执行示例（查询）：
  - `python scripts/pattern_memory.py --memory-path artifacts/pattern_memory/pattern_memory.jsonl --tu-json artifacts/tu/HomePage.ets.tu.json --query --limit 3`

## `orchestrator.py`

- 用途：运行 `Translate -> Review -> Verify -> Repair` 的状态机闭环。
- 核心能力：
  - 支持真实 LLM 与 Mock 双模式；
  - 通过 `prompt_assembler.py` 组装 Translator / Reviewer Prompt；
  - 通过 `llm_adapter.py` 发起真实模型请求；
  - 通过 `workspace_manager.py` 创建物理沙盒并真实落盘 `.cj` 候选文件；
  - 通过 `verifier.py` 运行三段式验证；
  - 通过 `pattern_memory.py` 查询 few-shot 模式并在成功后自动沉淀模式记忆；
  - 对 Reviewer JSON 解析失败提供 Fallback，自动回落到 Repair；
  - 对 Verifier 失败时的 `stderr` 做抓取和修复回灌。
- 执行示例（Mock + dry-run verify）：
  - `python scripts/orchestrator.py --tu-json artifacts/tu/HomePage.ets.tu.json --schema skills/SKILL_SCHEMA_V2.md --max-rounds 3 --mock-mode`
- 执行示例（真实模型 + dry-run verify）：
  - `OPENAI_API_KEY=xxx OPENAI_BASE_URL=https://open.bigmodel.cn/api/paas/v4 python scripts/orchestrator.py --tu-json artifacts/tu/HomePage.ets.tu.json --schema skills/SKILL_SCHEMA_V2.md --model glm-4.5-air --max-rounds 3`
- 执行示例（真实模型 + 尝试真实编译/测试命令）：
  - `OPENAI_API_KEY=xxx python scripts/orchestrator.py --tu-json artifacts/tu/HomePage.ets.tu.json --verify-no-dry-run --verify-real-compile --verify-real-unit-test --compile-cmd 'cjc --diagnostic-format noColor --output-type staticlib -o {attempt_dir}/candidate_output {candidate_file_path}' --unit-test-cmd 'cjpm test --package-root {workspace_dir}'`

## `pipeline_runner.py`

- 用途：以单条命令顺序调度 `repo_indexer.py`、`repo_map_generator.py`、`tu_bundler.py` 与 `orchestrator.py`。
- 核心能力：
  - 支持 `argparse` + `config.json` 的集中配置；
  - 为每次运行创建独立的 `artifacts/pipeline_runs/<timestamp>/` 目录；
  - 输出 `summary.json` / `failure.json` 以及控制台执行摘要；
  - 可在行为 Harness 之后挂接第二闸门：调用 `full-pass-summary-validate.py` 对 Full Pass `summary.json` 做证据校验，并把 `report.json` 固化到当前 `run_root`；
  - 根据第二闸门退出码做铁血分流：`0=通过`、`10=repair-required`、`20/21=infrastructure-error`；
  - 当配置 `--full-pass-refresh-cmd --full-pass-max-cycles N` 时，可把 `exit=10` 的 Full Pass 判决书回灌给下一轮 Orchestrator，形成 `Orchestrate -> Build -> Validate -> Repair` 外层闭环；
  - 若未显式提供 `--full-pass-refresh-cmd`，则 `pipeline_runner.py` 会优雅降级：
    - 当 `--full-pass-summary-path` 已指向现存 `summary.json` 时，首轮仅校验证据，不主动刷新；
    - 当 `summary.json` 缺失，或进入 `retry cycle` 时，自动回落到内建的 `scripts/full-pass-harmony-refresh.sh` 标准别名模板（基于 `FULL_PASS_HDC_SERIAL / FULL_PASS_PKG_NAME / FULL_PASS_HILOG_FILTER / FULL_PASS_CLEAN_DIR` 等别名变量）。
- 执行示例（Mock 全链路）：
  - `python scripts/pipeline_runner.py --src-root third_party/TelegramHarmony --target-file src/pages/HomePage.ets --mock-mode --verify-dry-run`
- 执行示例（真实模型 + dry-run verify）：
  - `OPENAI_API_KEY=xxx OPENAI_BASE_URL=https://open.bigmodel.cn/api/paas/v4 python scripts/pipeline_runner.py --src-root third_party/TelegramHarmony --target-file src/pages/HomePage.ets --no-mock-mode --llm-model zai-org/GLM-4.5-Air --verify-dry-run`
- 执行示例（启用第二闸门）：
  - `python scripts/pipeline_runner.py --src-root raw_docs/telegramharmony-phase02 --target-file src/services/RealMessageService.ets --mock-mode --verify-dry-run --full-pass-summary-path docs/schemas/examples/full-pass-summary.valid.json --full-pass-sync-current-phase`
- 执行示例（启用外层 Full Pass repair loop，自定义 refresh 命令）：
  - `python scripts/pipeline_runner.py --src-root raw_docs/telegramharmony-phase02 --target-file src/services/RealMessageService.ets --mock-mode --verify-dry-run --full-pass-summary-path artifacts/fullpass/summary.json --full-pass-refresh-cmd 'bash -lc "...生成 summary.json ..."' --full-pass-max-cycles 3 --full-pass-sync-current-phase`
- 执行示例（启用 Staging-Full 内建标准别名模板）：
  - `python scripts/pipeline_runner.py --src-root raw_docs/telegramharmony-phase02 --target-file src/services/RealMessageService.ets --mock-mode --verify-dry-run --full-pass-summary-path artifacts/fullpass/summary.json --full-pass-max-cycles 3 --full-pass-sync-current-phase`

## `pipeline_batch_runner.py`

- 用途：读取 batch manifest，顺序调用 `pipeline_runner.py --target-file ...`，为 TelegramHarmony 小批量自动翻译 Pilot 生成批次级 `batch-summary.json` / `success-list.json` / `failure-list.json` / `pattern-candidates.json`。
- 核心批处理约束：
  - 显式继承 `CANGJIE_HOME`、`PATH`、`LD_LIBRARY_PATH`、`DYLD_LIBRARY_PATH` 到子进程，避免“父进程能找到 SDK、子进程 command not found”的断层；
  - 支持 `depends_on` 顺序校验，若 manifest 把依赖写反，会在加载阶段直接拒绝执行；
  - 强制 `fail-continue`，单文件失败只会生成根级 `failure/<label>.failure.json` 与 `failure/<label>.stderr.log`，不会拖垮整批；
  - 批次状态分类优先读取 `summary.orchestration.final_status`，不会被顶层 `summary.status=passed` 的假阳性误导。
- 当前首批 manifest：
  - `docs/manifests/telegramharmony-phase02-batch1.json`
  - `docs/manifests/telegramharmony-phase02-batch1-real-compile.json`
  - `docs/manifests/telegramharmony-phase02-batch1-real-translator.json`
- 执行示例（Batch-1 / mock + dry-run）：
  - `python scripts/pipeline_batch_runner.py --manifest docs/manifests/telegramharmony-phase02-batch1.json`
- 执行示例（Batch-1 / mock translator + real compile）：
  - `python scripts/pipeline_batch_runner.py --manifest docs/manifests/telegramharmony-phase02-batch1-real-compile.json`
- 执行示例（Batch-1 / real translator + real compile / SiliconFlow）：
  - `OPENAI_BASE_URL=https://api.siliconflow.cn/v1 OPENAI_MODEL=Pro/zai-org/GLM-4.7 python scripts/pipeline_batch_runner.py --manifest docs/manifests/telegramharmony-phase02-batch1-real-translator.json`
- 关键输出：
  - `artifacts/batch_runs/<batch-name>/manifest.json`
  - `artifacts/batch_runs/<batch-name>/batch-summary.json`
  - `artifacts/batch_runs/<batch-name>/success-list.json`
  - `artifacts/batch_runs/<batch-name>/failure-list.json`
  - `artifacts/batch_runs/<batch-name>/pattern-candidates.json`
  - `artifacts/batch_runs/<batch-name>/failure/`

## `run_mass_translation.sh`

- 用途：作为 Phase05 默认点火入口，包装 `pipeline_batch_runner.py`，统一注入 repo-local Cangjie toolchain，并把 `docs/manifests/batch_manifest_phase05.json` 设为默认 manifest。
- live key 注入顺序：
  - 优先复用当前进程中的 `SILICONFLOW_API_KEY`
  - 若当前进程未提供，则自动 `source .env.local` 并优先读取其中的 `SILICONFLOW_API_KEY`
  - 若显式传入 `--read-key-from-stdin` 且当前 shell / `.env.local` 都未提供 `SILICONFLOW_API_KEY`，则从标准输入读取 key，不落盘
  - 若前述入口仍缺失，则回退读取 `.env.local` / 当前环境中的 `OPENAI_API_KEY` 作为 SiliconFlow 兼容入口
  - 仅在交互式 TTY 且前述入口都缺失时，静默提示输入 key
  - 当 manifest 已完全 frozen 时，可在无 key 情况下直接走 verifier-only baseline
- 执行示例（当前 shell 已导出 `SILICONFLOW_API_KEY`）：
  - `scripts/run_mass_translation.sh`
- 执行示例（fresh lane 由 `.env.local` 的 `SILICONFLOW_API_KEY` 或 `OPENAI_API_KEY` fallback 提供 key）：
  - `bash scripts/run_mass_translation.sh docs/manifests/batch_manifest_phase05.json`
- 执行示例（从 stdin 注入 key，不写入磁盘）：
  - `printf '%s\n' "$SILICONFLOW_API_KEY" | scripts/run_mass_translation.sh --read-key-from-stdin`
- 执行示例（显式指定 manifest）：
  - `printf '%s\n' "$SILICONFLOW_API_KEY" | scripts/run_mass_translation.sh --read-key-from-stdin docs/manifests/batch_manifest_phase05.json`

## `build_phase06_ui_file_manifest.py`

- 用途：把 `docs/manifests/phase06_ui_source_corpus_p0.json` 的 sample-level frozen register 展开为 `docs/manifests/phase06_ui_p0_file_manifest.json` 的 file-level workset。
- 核心能力：
  - 为每个冻结文件补齐 `target_role`、`slice_kind` 与显式 `ui_prompt_tags`；
  - 允许 multi-file sample 在 file 级把 `page-shell` 与 `rich-component` 重新分流；
  - 为每个切片预计算 `recommended_few_shot_entry_ids` 与 source scan 摘要，直接服务后续 prompt pilot / batch curator。
- 执行示例：
  - `python scripts/build_phase06_ui_file_manifest.py --output docs/manifests/phase06_ui_p0_file_manifest.json`
  - `python scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p1.json --output docs/manifests/phase06_ui_p1_file_manifest.json`

## `build_phase06_ui_prompt_pilot_manifest.py`

- 用途：从 `docs/manifests/phase06_ui_p0_file_manifest.json` 中构建 `Phase06` prompt-pilot manifest；默认生成首轮 batch1，也支持排除已消费 slice 后产出 residual next-stage workset。
- 核心能力：
  - 为 `page-shell/view-model-renderer`、`rich-component/view-model-renderer`、`page-shell/controller-owned-state`、`rich-component/controller-owned-state`、`gesture rich-component/controller-owned-state` 五条必需 prompt lane 各选一个切片；
  - 预计算每个 pilot 的 `src_root`、`target_file`、`pipeline_command` 与 repo-local prompt dump 产物路径；
  - 支持通过 `--exclude-manifest` / `--exclude-slice-id` 直接排除已消费 workset，并在 `--selection-mode residual-workset` 下输出剩余 slice 的 next-stage manifest；
  - 直接服务 `artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/` 下的 batch1 prompt-dump 证据回采，以及后续 residual next-stage workset 的 repo-local 点火准备。
- 执行示例：
  - `python scripts/build_phase06_ui_prompt_pilot_manifest.py --output docs/manifests/phase06_ui_prompt_pilot_batch1.json`
  - `python scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p1_file_manifest.json --track-profile p1-batch1 --manifest-name phase06_ui_prompt_pilot_p1_batch1 --artifacts-root artifacts/ui_pilots/20260410-phase06-ui-p1-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p1_batch1.json`
  - `python scripts/build_phase06_ui_prompt_pilot_manifest.py --selection-mode residual-workset --exclude-manifest docs/manifests/phase06_ui_prompt_pilot_batch1.json --manifest-name phase06_ui_prompt_pilot_next_stage --artifacts-root artifacts/ui_pilots/20260409-phase06-ui-pilot-next-stage --output docs/manifests/phase06_ui_prompt_pilot_next_stage.json`

## `run_phase06_ui_prompt_pilot_batch.py`

- 用途：把选定的 `Phase06` prompt pilot 送入 live orchestrator lane。
- 核心能力：
  - 支持按 `--pilot-id` 或 `--slice-id` 精确点火；
  - 若 manifest entry 对应的 `base_tu_json_path` 尚未落盘，会先自动执行该 pilot 自带的 `pipeline_command` 做 bootstrap，再注入显式 `ui_prompt_tags` 生成 `explicit_tu_json_path`；
  - live curator 产物根目录会优先跟随 manifest 自己的 `selection_policy.artifact_root`，避免 next-stage 结果误落回旧 batch 目录；
  - 允许 next-stage residual manifest 直接点火，不再要求人工先补 prompt-dump / TU 基线。
- 执行示例：
  - `python scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_next_stage.json --run-label 20260409-phase06-ui-next-stage-r1-low-variance --slice-id phase06-ui-p0-ledger-entry-page --slice-id phase06-ui-p0-ledger-details-list-component --slice-id phase06-ui-p0-markdown-table-block-component --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0`
