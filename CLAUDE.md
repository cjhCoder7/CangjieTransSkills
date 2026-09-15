# 仓颉语言应用开发 — 项目说明

## Skill 使用规则

遇到仓颉语言或 HarmonyOS 开发相关问题时，**必须按以下顺序查阅资源**：

1. **首先**查阅 `.claude/skills/base-skill/SKILL.md` 获取开发指引和路由信息
2. **操作型请求**（翻译、修改、构建、测试、UI 验证）→ 先使用 `cangjie-loopx-management` 自动创建或恢复 LoopX Goal；只读咨询不创建 Goal
3. **语言问题**（语法/类型/标准库/并发/宏等）→ 使用 `cangjie-kernel` skill
4. **鸿蒙开发问题**（ArkUI/Ability/系统API/互操作等）→ 使用 `cangjie-harmony` skill
5. **代码翻译**：
   - **应用级**（任意语言的应用 → 仓颉应用）→ 使用 `/cangjie-translate` skill
   - **库级**（任意语言库/SDK/CLI → 纯仓颉 cjpm 包）→ 使用 `/cangjie-translate-lib` skill
6. **编译构建**：
   - **应用级**（HarmonyOS 应用，产物 HAP）→ 使用 `/build`，需 `DEVECO_HOME`
   - **库级**（cjpm 库，产物 `.cjo`/静态/动态库）→ 使用 `/cangjie-lib-build`，仅需仓颉 SDK
7. **UI 验证** → 使用 `/harmonyos-ui-inspect` 采集截图、控件树、执行交互场景
8. **以上未覆盖** → 使用 `/download-script` 下载原始文档查询
9. **经验记录（可选）** → `experiences/experiences.md`

## LoopX 管理规则

用户直接调用仓颉操作型 Skill 时自动进入 LoopX，不要求先手工执行 `/loopx`。Goal、Todo、Gate、quota、证据、隐私、自修复和结案的完整规则，以 [`.claude/skills/cangjie-loopx-management/SKILL.md`](.claude/skills/cangjie-loopx-management/SKILL.md) 为唯一事实来源，本文件仅负责入口路由。

## 前置问答清单（重要）

**执行任何操作型 skill 前，必须先由 `cangjie-loopx-management` 接管，再完成 `base-skill` 中的三步领域前置检查：**

1. **模型能力确认** — 多模态还是纯文本？影响截图相关流程
2. **项目类型判定** — 应用（`entry/` + `module.json5`）还是库（`cjpm.toml`）？决定构建和翻译路由
3. **环境配置检查** — `.env` 中 `DEVECO_HOME` 等变量是否就绪？

各操作型 skill 还有各自的额外前置检查，详见各 SKILL.md 中的"前置检查"章节。

## 经验记录规则

开发中如解决了非显而易见的问题，可选记录到 `.claude/skills/experiences/experiences.md`；所有经验记在同一个文件里，不再分类；不是结案的必需条件。

## 开发工作流

```
LoopX Goal/Todo → 编写代码 → /build 编译 → /harmonyos-ui-inspect --auto-hap --emulator 5555 验证 UI → 质量回写 → 结案
```

对于库项目：

```
LoopX Goal/Todo → 编写代码 → /cangjie-lib-build 编译 + 测试 → 质量回写 → 结案
```

## 环境配置（.env）

项目根目录的 `.env` 文件为 `/build` 和 `/harmonyos-ui-inspect` 提供环境信息。`/cangjie-lib-build` 也会读取但非必需（可自动检测）。

> **注意**：`CANGJIE_SDK_HOME-8k` / `CANGJIE_SDK_HOME-15k` 中的连字符仅用于 `.env` 文件键名解析，非 shell 环境变量名。

### DEVECO_HOME（必填）

DevEco Studio 安装路径。`/build` 用它定位 ohpm/hvigor/node/Java，`/harmonyos-ui-inspect` 用它自动检测 hdc。

各平台典型值：

| 平台 | 值 |
|------|---|
| macOS | `DEVECO_HOME=/Applications/DevEco-Studio.app/Contents` |
| Windows | `DEVECO_HOME=C:\Program Files\Huawei\DevEco Studio` |
| Linux | `DEVECO_HOME=/opt/deveco-studio` |

### CANGJIE_SDK_HOME 系列（可选）

仓颉 SDK 路径。不配置时自动在 `~/.cangjie-sdk/` 下检测。

| 变量 | 优先级 | 说明 |
|------|--------|------|
| `CANGJIE_SDK_HOME-8k` | 最高（8k 版本专用） | 覆盖 8k 版本的 SDK 路径 |
| `CANGJIE_SDK_HOME-15k` | 最高（15k 版本专用） | 覆盖 15k 版本的 SDK 路径 |
| `CANGJIE_SDK_HOME` | 通用回退 | 未配置版本专用路径时的默认 SDK |

示例：

| 平台 | 示例 |
|------|------|
| macOS/Linux | `CANGJIE_SDK_HOME=/Users/xxx/.cangjie-sdk/6.0/cangjie` |
| Windows | `CANGJIE_SDK_HOME=C:\Users\xxx\.cangjie-sdk\6.0\cangjie` |

### hdc 路径

无需单独配置。`ui_capture.py` 按以下顺序自动检测：
1. 系统 PATH 中的 `hdc`
2. `.env` 中 `DEVECO_HOME` 推导：`$DEVECO_HOME/sdk/default/openharmony/toolchains/hdc`
3. macOS 默认路径：`/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc`

> Windows 用户注意：`.env` 中的路径使用反斜杠（`C:\...`）或正斜杠（`C:/...`）均可，脚本内部会统一处理。

## 语言与风格

- 文档和代码注释使用**中文**
- 代码标识符使用英文
- 仓颉代码遵循官方编码规范
- Commit message 使用中文

## 项目结构

```
.claude/skills/
├── base-skill/              # 入口路由（自动加载）
├── cangjie-loopx-management/ # LoopX 目标/Todo/Gate/状态管理适配
├── build/                   # 应用级编译构建（/build，产物 HAP）
├── cangjie-lib-build/       # 库级编译构建（/cangjie-lib-build，产物 cjpm 包）
├── cangjie-kernel/          # 仓颉语言核心文档（语法/类型/标准库）
├── cangjie-harmony/         # HarmonyOS 应用开发文档（ArkUI/Ability/系统API）
├── cangjie-translate/       # 应用级翻译（/cangjie-translate）
├── cangjie-translate-lib/   # 库级翻译（/cangjie-translate-lib，源语言无关）
├── harmonyos-ui-inspect/    # UI 采集与交互验证（/harmonyos-ui-inspect）
├── download-script/         # 原始文档下载（/download-script）
└── experiences/             # 共享经验记录（单文件，非强制）
```
