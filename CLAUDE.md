# 仓颉语言应用开发 — 项目说明

## Skill 使用规则

遇到仓颉语言或 HarmonyOS 开发相关问题时，**必须按以下顺序查阅资源**：

1. **首先**查阅 `.claude/skills/base-skill/SKILL.md` 获取开发指引和路由信息
2. **语言问题**（语法/类型/标准库/并发/宏等）→ 使用 `cangjie-kernel` skill
3. **鸿蒙开发问题**（ArkUI/Ability/系统API/互操作等）→ 使用 `cangjie-harmony` skill
4. **代码翻译**（ArkTS/Swift/Java → 仓颉）→ 使用 `/cangjie-translate` skill
5. **编译构建** → 使用 `/build` 执行编译打包
6. **UI 验证** → 使用 `/harmonyos-ui-inspect` 采集截图、控件树、执行交互场景
7. **经验查阅** → 使用 `evolution` skill 查阅已积累的踩坑记录
8. **以上未覆盖** → 使用 `/download-script` 下载原始文档查询

## 经验积累规则

开发中解决了**非显而易见**的问题后，**必须**将经验记录到对应 skill：
- 仓颉通用问题 → `evolution/cangjie/` 下按主题文件记录
- 翻译差异问题 → `cangjie-translate/` 对应语言子目录记录

记录格式参见 `.claude/skills/evolution/SKILL.md` 中的规范。

## 开发工作流

```
编写代码 → /build 编译 → /harmonyos-ui-inspect --auto-hap --emulator 5555 验证 UI
```

## 环境配置（.env）

项目根目录的 `.env` 文件为 `build` 和 `harmonyos-ui-inspect` 两个 skill 提供环境信息。

### DEVECO_HOME（必填）

DevEco Studio 安装路径。`build` 用它定位 ohpm/hvigor/node/Java，`ui-inspect` 用它自动检测 hdc。

各平台典型值：

| 平台 | 值 |
|------|---|
| macOS | `DEVECO_HOME=/Applications/DevEco-Studio.app/Contents` |
| Windows | `DEVECO_HOME=C:\Program Files\Huawei\DevEco Studio` |
| Linux | `DEVECO_HOME=/opt/deveco-studio` |

### CANGJIE_SDK_HOME-8k（可选）

覆盖仓颉 SDK 路径。不配置时自动在 `~/.cangjie-sdk/` 下检测。

| 平台 | 示例 |
|------|------|
| macOS/Linux | `CANGJIE_SDK_HOME-8k=/Users/xxx/.cangjie-sdk/6.0/cangjie` |
| Windows | `CANGJIE_SDK_HOME-8k=C:\Users\xxx\.cangjie-sdk\6.0\cangjie` |

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
├── build/                   # 编译构建（/build）
├── cangjie-kernel/          # 仓颉语言核心文档
├── cangjie-harmony/         # HarmonyOS 应用开发文档
├── cangjie-translate/       # 代码翻译（/cangjie-translate）
│   ├── arkts2cangjie/       #   ArkTS → 仓颉经验
│   ├── swift2cangjie/       #   Swift → 仓颉经验
│   └── java2cangjie/        #   Java → 仓颉经验
├── harmonyos-ui-inspect/    # UI 采集与交互验证（/harmonyos-ui-inspect）
├── download-script/         # 原始文档下载（/download-script）
└── evolution/               # 开发经验总结
    └── cangjie/             #   通用经验（syntax.md/arkui.md/state.md）
```
