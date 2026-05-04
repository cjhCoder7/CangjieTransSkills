# Pipeline Runner Runbook

> 这里是当前仓库的命令入口手册，不重复解释所有背景。
> 默认 first-read order：`AGENTS.md` -> `docs/status/INDEX.md` -> `docs/current_state.v2.md` -> `docs/status/current_task_handoff.md`。
> `/.claude/status/current-phase.md` 仅在需要追旧背景或长历史时再读，不是默认首跳。

---

## 1. Mock 全链路

```bash
python scripts/pipeline_runner.py \
  --src-root third_party/TelegramHarmony \
  --target-file src/pages/HomePage.ets \
  --mock-mode \
  --verify-dry-run
```

## 2. 真实模型 + dry-run verify

```bash
OPENAI_API_KEY=xxx OPENAI_BASE_URL=https://open.bigmodel.cn/api/paas/v4 \
python scripts/pipeline_runner.py \
  --src-root third_party/TelegramHarmony \
  --target-file src/pages/HomePage.ets \
  --no-mock-mode \
  --llm-model zai-org/GLM-4.5-Air \
  --verify-dry-run
```

## 3. 真实模型 + 真实编译验证

```bash
OPENAI_API_KEY=xxx \
python scripts/orchestrator.py \
  --tu-json artifacts/tu/HomePage.ets.tu.json \
  --schema skills/SKILL_SCHEMA_V2.md \
  --verify-no-dry-run \
  --verify-real-compile \
  --compile-cmd 'cjc --build-path {workspace_dir} {candidate_file_path}'
```

## 4. Short-circuit

命中以下情况时，优先走 `L3 -> L2 -> Repair`：

- `static-blacklist-failed`
- `std.unsafe`
- `Signal`
- `ValueSignal`
- `import ... from`
- `sendRequest`
- `Array<UInt8>` 在 Service 层直出

不要先去 L1 寻找“保留脏代码”的理由。

## 5. 跳转说明

- 想知道当前 active lane / blocker / allowed moves：先看 `docs/current_state.v2.md`
- 想知道当前 task / latest report / raw_log_root：先看 `docs/status/INDEX.md` 与 `docs/status/current_task_handoff.md`
- 想追旧阶段滚动历史：`/.claude/status/current-phase.md`
- 想知道理论 / 项目 / 现场之间如何跳转：`/.claude/skills/index.md`
- 想找项目专项约束：`skills/`
