# Linux Staging-Core 资产锚定 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 Linux SDK 原始资产和 `Staging-Core` 无头物理工具链写成仓库级共识，并用新鲜命令验证当前主战线可继续推进。

**Architecture:** 通过三处文档形成统一锚点：`AGENTS.md` 负责项目级战术口径，`docs/resources.md` 负责资产索引，`docs/strategy/phase-03-physical-compiler-setup.md` 负责工具链接线事实。随后运行最小 Linux 冒烟命令，确认 `cjc/cjpm/verifier` 仍能与现有 SDK 工作目录正确接线。

**Tech Stack:** Markdown、bash、Linux x86_64 Cangjie SDK、`scripts/verifier.py`

---

### Task 1: 写入项目级战术锚点

**Files:**
- Modify: `AGENTS.md`

- [ ] **Step 1: 在“当前精确坐标”段补充 Linux 原生 Staging-Core 工具链事实**

写入内容需明确包含：

```text
- 当前宿主已确认存在 Linux 原生 Staging-Core 物理工具链；
- 原始压缩包路径：/volume/wzhang/cky-workspace/my_projects/Cangjie/资源/cangjie-sdk-linux-x64-6.1.0.818.zip；
- 解压工作目录：artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip；
- 不得把 Staging-Full 条件误当成 Staging-Core 的前置门槛。
```

- [ ] **Step 2: 人工检查术语是否与现有 Phase 03 口径一致**

运行：

```bash
rg -n 'Staging-Core|Staging-Full|cangjie-sdk-linux-x64-6.1.0.818' AGENTS.md
```

预期：新增条目出现，且不把 `Staging-Core` 与 `Staging-Full` 混写。

### Task 2: 写入资源索引

**Files:**
- Modify: `docs/resources.md`

- [ ] **Step 1: 新增“本地关键资产”小节**

内容至少包含：

```text
- 资产名：Linux x86_64 Cangjie SDK 6.1.0.818
- 原始压缩包绝对路径：/volume/wzhang/cky-workspace/my_projects/Cangjie/资源/cangjie-sdk-linux-x64-6.1.0.818.zip
- 解压目录：artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip
- 用途：Staging-Core 真实编译/单测/runtime 接线
- 注意：必须使用可保留 symlink 的方式解压
```

- [ ] **Step 2: 检查资源条目已可被检索**

运行：

```bash
rg -n '本地关键资产|cangjie-sdk-linux-x64-6.1.0.818.zip|symlink' docs/resources.md
```

预期：新增资产条目全部命中。

### Task 3: 补原始压缩包到工作目录映射

**Files:**
- Modify: `docs/strategy/phase-03-physical-compiler-setup.md`

- [ ] **Step 1: 在 Linux SDK 资源段补充绝对路径与映射说明**

写入内容需明确说明：

```text
- 当前宿主绝对路径：/volume/wzhang/cky-workspace/my_projects/Cangjie/资源/cangjie-sdk-linux-x64-6.1.0.818.zip
- 对应解压目录：artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip
- 它是当前 Linux Staging-Core 物理编译链的权威源资产
```

- [ ] **Step 2: 检查映射条目已落盘**

运行：

```bash
rg -n '/volume/wzhang/cky-workspace/my_projects/Cangjie/资源/cangjie-sdk-linux-x64-6.1.0.818.zip|权威源资产|解压目录' docs/strategy/phase-03-physical-compiler-setup.md
```

预期：绝对路径与映射说明均可检索到。

### Task 4: 执行 Linux toolchain 冒烟验证

**Files:**
- Modify: `artifacts/verification/` 下新增或刷新验证产物（若命令会输出）

- [ ] **Step 1: 验证 `cjc` 真实入口**

运行：

```bash
artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin/cjc --version
```

预期：输出 `Cangjie Compiler` 与 Linux target 信息。

- [ ] **Step 2: 验证 `cjpm` 真实入口**

运行：

```bash
artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin/cjpm --help >/tmp/cjpm-help.txt && head -n 5 /tmp/cjpm-help.txt
```

预期：输出帮助头部，命令退出码为 0。

- [ ] **Step 3: 运行 `verifier.py` 的真实编译 smoke**

运行：

```bash
python3 scripts/verifier.py \
  --tu-json artifacts/temp_workspace/phase03-physical-smoke-001/hello.tu.json \
  --artifact-json artifacts/temp_workspace/phase03-physical-smoke-001/hello.artifact.json \
  --output artifacts/verification/hello.verify.real.json \
  --no-dry-run \
  --real-compile \
  --compiler-home artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie \
  --compiler-executable artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin/cjc \
  --package-manager-executable artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin/cjpm \
  --runtime-lib-path artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/runtime/lib/linux_x86_64_cjnative \
  --tool-bin-path artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin
```

预期：真实编译阶段通过；若后续阶段因 mock / artifact 约束失败，只记录真实失败点，不扩大范围。

### Task 5: 汇总结论与下一轮路线

**Files:**
- No file changes required for this step

- [ ] **Step 1: 汇总新鲜证据并明确术语边界**

结果必须同时说明：

```text
- 当前 Linux 宿主可继续推进 Staging-Core
- 当前结论不等于 Phase 3C Full Pass
- 下一轮应继续在无头物理编译与行为证据上推进业务模块
```

