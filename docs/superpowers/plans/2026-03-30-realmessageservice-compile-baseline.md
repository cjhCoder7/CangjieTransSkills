# RealMessageService Compile Baseline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让 `RealMessageService` 的自动翻译链更稳定地穿过审查，并进入真实 `cjc` 编译报错，而不是反复退回到低层语法黑名单。

**Architecture:** 通过“编译安全 Skill + Prompt 摘要优先级调整 + curated Pattern Memory”三层协同，把模型拉回仓库里已经验证过的仓颉安全写法。实现重点不在改状态机，而在提升 Translator 能看到并复用的 compile-safe 证据。

**Tech Stack:** Python 3、仓库现有 `scripts/orchestrator.py` / `scripts/prompt_assembler.py` / `scripts/pattern_memory.py`、Markdown Skill、真实 `cjc` 编译链。

---

### Task 1: 固化设计与红灯验证

**Files:**
- Create: `docs/superpowers/specs/2026-03-30-realmessageservice-compile-baseline-design.md`
- Create: `docs/superpowers/plans/2026-03-30-realmessageservice-compile-baseline.md`

- [ ] **Step 1: 记录当前失败基线**

运行：

```bash
python - <<'PY'
from scripts.prompt_assembler import PromptAssembler

tu = {
    "tu_id": "tu::demo",
    "target": {
        "path": "src/services/RealMessageService.ets",
        "role": "service",
        "summary": "demo",
        "risk_tags": ["async-flow"],
        "state_tags": ["signal-or-store"],
        "thread_tags": ["async-flow"],
        "interop_tags": [],
        "signatures": [],
        "source": ""
    },
    "dependency_closure": []
}

assembler = PromptAssembler(
    schema_text="# Architecture Mapping\nbody",
    architecture_skill_texts=[
        "SKILL_A domain",
        "SKILL_B protocol",
        "COMPILE_SAFE_MARKER null Option named arguments",
    ],
)
prompt = assembler.build_translator_prompt(
    tu=tu,
    required_dimensions=["Architecture Mapping"],
    attempt=1,
    repair_guidance=["compile-failed", "undeclared identifier 'null'"],
    pattern_examples=[],
)
content = prompt.messages[1].content
assert "COMPILE_SAFE_MARKER" in content, "compile-safe skill 未进入 prompt"
PY
```

预期：当前代码失败，报 `compile-safe skill 未进入 prompt`。

### Task 2: 新增编译安全 Skill

**Files:**
- Create: `skills/cangjie-service-compile-baseline-v1.md`

- [ ] **Step 1: 写入 compile-safe 规则**

规则至少覆盖：

```text
- 禁止 Atomic
- 禁止 null
- 禁止普通方法调用强加 named arguments
- 禁止 map[key] ?? fallback
- 禁止 optional chaining 访问 HashMap.get 结果
- 推荐 Option<T> / match / HashMap.get / 位置参数
```

- [ ] **Step 2: 补一段最小 Service 骨架示例**

示例应包含：

```text
match (this.messageCache.get(key)) {
    case Some(messages) => messages
    case _ => {
        let fetched = this.adapter.fetchHistory(peerId, limit, accessHash)
        this.messageCache.add(key, fetched)
        fetched
    }
}
```

### Task 3: 调整 Prompt Skill 摘要策略

**Files:**
- Modify: `scripts/prompt_assembler.py`

- [ ] **Step 1: 先让红灯验证失败一次**

运行：

```bash
python - <<'PY'
from scripts.prompt_assembler import PromptAssembler

tu = {
    "tu_id": "tu::demo",
    "target": {
        "path": "src/services/RealMessageService.ets",
        "role": "service",
        "summary": "demo",
        "risk_tags": ["async-flow"],
        "state_tags": ["signal-or-store"],
        "thread_tags": ["async-flow"],
        "interop_tags": [],
        "signatures": [],
        "source": ""
    },
    "dependency_closure": []
}

assembler = PromptAssembler(
    schema_text="# Architecture Mapping\nbody",
    architecture_skill_texts=[
        "SKILL_A domain",
        "SKILL_B protocol",
        "COMPILE_SAFE_MARKER null Option named arguments",
    ],
)
prompt = assembler.build_translator_prompt(
    tu=tu,
    required_dimensions=["Architecture Mapping"],
    attempt=1,
    repair_guidance=["compile-failed", "undeclared identifier 'null'"],
    pattern_examples=[],
)
content = prompt.messages[1].content
assert "COMPILE_SAFE_MARKER" in content
PY
```

预期：FAIL。

- [ ] **Step 2: 修改摘要选择逻辑**

实现目标：

```python
def _build_architecture_excerpt(self, limit: int, repair_guidance: Sequence[str] | None = None) -> str:
    ...
```

要求：

- 优先保留命中编译/语法关键词的 Skill；
- 再补足其它 Skill；
- Reviewer 与 Translator 走同一套选择逻辑；
- 保持输出为可读的多段摘要，而不是原样拼完整文件。

- [ ] **Step 3: 跑同一条验证命令确认转绿**

运行同 Step 1 命令。

预期：PASS。

### Task 4: 增补 curated Pattern Memory

**Files:**
- Modify: `artifacts/pattern_memory/pattern_memory.jsonl`

- [ ] **Step 1: 追加 compile-safe curated pattern**

条目至少包含：

```json
{
  "pattern_id": "curated::service::compile-safe::2026-03-30",
  "target_role": "service",
  "verification_status": "passed"
}
```

并对齐：

- `target_path=src/services/RealMessageService.ets`
- `risk_tags` 含 `async-flow`、`signal-or-store`
- `target_signatures` 包含 `cacheUsers`、`cacheChannels`、`getMessages`、`sendMessage`

- [ ] **Step 2: 验证 curated pattern 可被检索**

运行：

```bash
python - <<'PY'
import json
from pathlib import Path
from scripts.pattern_memory import PatternMemoryEngine

tu = json.loads(Path("artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-023-round26-nested-legacy-smuggling-purge/RealMessageService.tu.json").read_text())
engine = PatternMemoryEngine(Path("artifacts/pattern_memory/pattern_memory.jsonl"))
patterns = engine.query_for_tu(tu, limit=5)
ids = [item.get("pattern_id") for item in patterns]
assert "curated::service::compile-safe::2026-03-30" in ids, ids
PY
```

预期：PASS。

### Task 5: 执行新的 RealMessageService 实弹验证

**Files:**
- Modify: `docs/traces/` 下新增本轮轨迹文档
- Generate: `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-024-*`

- [ ] **Step 1: 用新的 Skill 顺序启动一轮运行**

运行命令应保证 compile-safe Skill 在前两位，并保持真实编译开启：

```bash
python scripts/orchestrator.py \
  --tu-json artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-023-round26-nested-legacy-smuggling-purge/RealMessageService.tu.json \
  --schema skills/SKILL_SCHEMA_V2.md \
  --architecture-skill skills/cangjie-service-compile-baseline-v1.md \
  --architecture-skill skills/cangjie-syntax-pitfalls-v1.2.md \
  --architecture-skill skills/cangjie-class-and-promise-syntax-v1.md \
  --architecture-skill skills/domain-purity-hard-template.md \
  --architecture-skill skills/protocol-adapter-extraction-strategy.md \
  --architecture-skill skills/anti-corruption-and-concurrency-strategy.md \
  --pattern-memory artifacts/pattern_memory/pattern_memory.jsonl \
  --output artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-024-compile-baseline/RealMessageService.orchestration.json \
  --max-rounds 5 \
  --verify-no-dry-run \
  --verify-real-compile \
  --compiler-home artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie \
  --compiler-executable artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin/cjc \
  --package-manager-executable artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin/cjpm \
  --runtime-lib-path artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/runtime/lib/linux_x86_64_cjnative \
  --tool-bin-path artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin
```

- [ ] **Step 2: 检查结果是否满足本轮目标**

检查点：

- 至少一轮 `review_passed=true`
- 至少一轮 `verify_failure_type=compile-failed`
- 不再出现 `Atomic`、`null`、命名参数前缀、对非 `Option` 使用 `??`、可选链 这几类错误

### Task 6: 记录证据

**Files:**
- Create: `docs/traces/trace-phase-03-physical-iron-test-realmessageservice-009-round27-compile-baseline.md`

- [ ] **Step 1: 写轨迹文档**

内容至少包括：

- 本轮挂载的 Skill 列表；
- curated pattern 的命中情况；
- 最佳 attempt 的 Reviewer / `cjc` 证据；
- 与 Round 26 的对比；
- 是否达到“稳定穿过审查并进入真实编译报错”的目标。

