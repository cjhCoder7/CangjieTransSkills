# Sync and Admission Pipelines

这里同时承载：
- Phase 2：外来 kernel 文档的准入体检
- Phase 3：官方文档同步与切片

## 当前已实现

### `kernel_admission.py`
- 用途：对单个外来 Markdown 执行最小 admission 流程
- 当前支持：`standalone` / `wrappable` / `context-only`
- 当前已验证样本：`Option`

执行示例：

```bash
python scripts/sync/kernel_admission.py \
  --source-markdown research/external-baselines/CangjieTransSkills/option/README.md \
  --topic option \
  --output-skill .claude/skills/base-kernel/option.md \
  --admission-root artifacts/knowledge_admission \
  --compiler-executable artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin/cjc \
  --compiler-home artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie \
  --runtime-lib-path artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/runtime/lib/linux_x86_64_cjnative \
  --tool-bin-path artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin
```

关键产物：
- `artifacts/knowledge_admission/source-manifest.jsonl`
- `artifacts/knowledge_admission/admission-index.json`
- `artifacts/knowledge_admission/runs/option/`
- `.claude/skills/base-kernel/option.md`

验证命令：

```bash
python scripts/validate_kernel_admission.py \
  --admission-root artifacts/knowledge_admission \
  --accepted-skill .claude/skills/base-kernel/option.md
```

## 未来预置位

### `sync_docs.py`
- 从官方源同步文档镜像

### `index_to_skill.py`
- 将文档切片并映射到当前 Skill 体系

目标：
- 把官方文档同步、切片、回写接入当前 `skills/`、`docs/`、`artifacts/` 流程
- 避免继续依赖散落在 `/tmp` 的一次性文档镜像
