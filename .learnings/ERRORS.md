# Errors

Command failures and integration errors.

---

## [ERR-20260401-001] git_status_workspace_root

**Logged**: 2026-04-01T00:00:00Z
**Priority**: medium
**Status**: pending
**Area**: infra

### Summary
在 `/volume/wzhang/cky-workspace/my_projects/Cangjie` 直接执行 `git status --short` 失败，因为该目录不是 Git 仓库根目录。

### Error
```text
fatal: not a git repository (or any parent up to mount point /volume)
Stopping at filesystem boundary (GIT_DISCOVERY_ACROSS_FILESYSTEM not set).
```

### Context
- Command/operation attempted: `git status --short`
- Input or parameters used: current working directory `/volume/wzhang/cky-workspace/my_projects/Cangjie`
- Environment details if relevant: 当前项目目录下未发现 `.git`，上层近邻仓库为其他项目目录

### Suggested Fix
后续若需要 Git 状态，先显式探测真实仓库根目录；若该工程本身不是 Git 仓库，则不要把 Git 结果作为流程前提。

### Metadata
- Reproducible: yes
- Related Files: none

---

## [ERR-20260401-002] missing_build_translation_unit_script

**Logged**: 2026-04-01T03:07:02Z
**Priority**: medium
**Status**: pending
**Area**: infra

### Summary
误判存在 `scripts/build_translation_unit.py`，导致探测 `MTProtoClient.ets` TU 的命令直接失败。

### Error
```text
/usr/bin/python: can't open file '/volume/wzhang/cky-workspace/my_projects/Cangjie/scripts/build_translation_unit.py': [Errno 2] No such file or directory
Traceback (most recent call last):
  File "<stdin>", line 8, in <module>
  File "/usr/lib/python3.10/subprocess.py", line 526, in run
    raise CalledProcessError(retcode, process.args,
subprocess.CalledProcessError: Command '['/usr/bin/python', 'scripts/build_translation_unit.py', '--src-root', 'raw_docs/telegramharmony-phase02', '--target-file', 'src/core/mtproto/MTProtoClient.ets', '--output-path', 'artifacts/pipeline_runs/phase03-mtprotoclient-scout/mtprotoclient.tu.json']' returned non-zero exit status 2.
```

### Context
- Command/operation attempted: 通过假定的 `scripts/build_translation_unit.py` 单独构建 TU
- Input or parameters used: `--src-root raw_docs/telegramharmony-phase02 --target-file src/core/mtproto/MTProtoClient.ets`
- Environment details if relevant: 当前仓库应继续复用 `pipeline_runner.py` / 既有工件，而不是臆造脚本入口

### Suggested Fix
后续若要探测 TU 或目标元数据，优先复用已存在的 `pipeline_runner.py` 工件、现有 `*.tu.json` 产物或先用 `rg --files scripts` 验证脚本入口，再执行命令。

### Metadata
- Reproducible: yes
- Related Files: scripts, artifacts/pipeline_runs

---

## [ERR-20260401-003] pipeline_runner_mock_mode_misfire

**Logged**: 2026-04-01T03:35:00Z
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
重跑 `MTProtoClient` 时漏传 `--no-mock-mode`，导致 `pipeline_runner.py` 退回 Mock LLM，真实 staged compile 被 `mock translator artifact` 污染。

### Error
```text
summary.config.is_mock_mode = true
final_artifact.generated_code = "// mock translator artifact ..."
compile stderr = found more than one package declaration for the package
note: another different package declaration 'public package default'
```

### Context
- Command/operation attempted: `python scripts/pipeline_runner.py ...` for `phase03-mtprotoclient-repair-002`
- Input or parameters used: 实参未显式附带 `--no-mock-mode`
- Environment details if relevant: verifier 已启用真实 `cjc`，但翻译器仍处于 mock 模式

### Suggested Fix
后续复用真实 translator 跑法时，显式传入 `--no-mock-mode`，并在读取 `summary.json` 时首先核对 `config.is_mock_mode`，防止把 mock 候选误当真实 repair 结果。

### Metadata
- Reproducible: yes
- Related Files: scripts/pipeline_runner.py, artifacts/pipeline_runs/phase03-mtprotoclient-repair-002/summary.json

---

## [ERR-20260401-004] missing_openai_api_key_real_llm

**Logged**: 2026-04-01T03:36:00Z
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
切回真实 translator 后，`pipeline_runner.py` 在 orchestration 阶段被 `OPENAI_API_KEY` 缺失硬阻断，无法继续真实 Repair。

### Error
```text
LLMAdapterError: 未检测到 OPENAI_API_KEY，无法发起真实 LLM 调用。
```

### Context
- Command/operation attempted: `python scripts/pipeline_runner.py ... --no-mock-mode` for `phase03-mtprotoclient-repair-003`
- Input or parameters used: `--llm-model Pro/zai-org/GLM-4.7`
- Environment details if relevant: 当前 shell 环境未暴露 `OPENAI_API_KEY`

### Suggested Fix
真实 translator 运行前先核对 `OPENAI_API_KEY`，若当前节点不具备密钥，则改为只做离线 compile/staging 实验，避免把 LLM 入口阻塞误判为代码问题。

### Metadata
- Reproducible: yes
- Related Files: scripts/llm_adapter.py, artifacts/pipeline_runs/phase03-mtprotoclient-repair-003/failure.json

---
