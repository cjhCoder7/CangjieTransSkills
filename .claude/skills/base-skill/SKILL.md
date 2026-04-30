---
name: base-skill
description: "仓颉语言 HarmonyOS 开发的入口路由。遇到仓颉语法、HarmonyOS API、编译构建等问题时自动加载，引导使用正确的 skill"
---

# 仓颉语言应用开发指引

遇到仓颉相关问题时，按以下优先级选择 skill：

## 前置问答清单（使用任何操作型 skill 前必须完成）

在执行构建、翻译、UI 检测等操作前，**必须依次完成以下三步确认**。任何步骤未通过时不要启动主流程，先向用户确认缺失项。

### 第 1 步：模型能力确认

确认当前模型是**多模态**还是**纯文本**，影响多个 skill 的行为分支：

| 自检方法 | 结论 | 影响 |
|---------|------|------|
| 尝试 Read 一张 `.png`/`.jpg` 能解析为图像内容 | **多模态** | `/cangjie-translate` 可启用截图辅助；`/harmonyos-ui-inspect` 可读取 `screenshot.png` |
| Read 图像报错或仅返回文件元信息 | **纯文本** | `/cangjie-translate` 跳过截图流程；`/harmonyos-ui-inspect` 必须加 `--no-screenshot` |
| 不确定 | **按纯文本处理** | 安全降级，不主动索要截图 |

确认后在本次会话中记住结果，后续 skill 不再重复自检。

### 第 2 步：项目类型判定

根据工作目录结构判断当前是**应用项目**还是**库项目**，决定构建和翻译的路由：

| 工程根含 | 项目类型 | 构建用 | 翻译用 |
|---------|---------|--------|--------|
| `entry/` + `module.json5` + `app.json5` | HarmonyOS 应用 | `/build` | `/cangjie-translate` |
| `cjpm.toml`，无 `entry/` | 仓颉 cjpm 库 | `/cangjie-lib-build` | `/cangjie-translate-lib` |
| 其他语言项目（待翻译） | 源项目 | — | 按形态选择（见各翻译 skill 的 Phase 0） |

### 第 3 步：环境配置检查（.env）

项目根目录的 `.env` 为多个 skill 提供环境信息。

1. 读取项目根 `.env`，确认以下变量：
   - **`DEVECO_HOME`**（`/build` 和 `/harmonyos-ui-inspect` 必需）— DevEco Studio 安装路径
   - **`CANGJIE_SDK_HOME`**（`/cangjie-lib-build` 可选但推荐）— 仓颉 SDK 安装路径，未配置时自动扫描 `~/.cangjie-sdk/`
   - **`CANGJIE_SDK_HOME-8k`** / **`CANGJIE_SDK_HOME-15k`**（可选）— 按版本锁定的 SDK 路径，优先级高于 `CANGJIE_SDK_HOME`

2. 检查规则：
   - 若 `.env` 不存在或缺少必要变量，**主动提示用户补充**，给出平台典型值示例后再继续
   - `CANGJIE_SDK_HOME` 系列缺失时可以继续（自动检测兜底），但 `DEVECO_HOME` 缺失时 `/build` 和 `/harmonyos-ui-inspect` 无法运行，必须补充

### 各变量与 skill 的依赖关系

| 变量 | 依赖的 skill | 必要性 |
|------|------------|--------|
| `DEVECO_HOME` | `/build`、`/harmonyos-ui-inspect` | 必填 |
| `CANGJIE_SDK_HOME` | `/cangjie-lib-build` | 可选（自动扫描 `~/.cangjie-sdk/`） |
| `CANGJIE_SDK_HOME-8k` | `/cangjie-lib-build` | 可选（覆盖通用路径） |
| `CANGJIE_SDK_HOME-15k` | `/cangjie-lib-build` | 可选（覆盖通用路径） |

> **注意**：`CANGJIE_SDK_HOME-8k` / `CANGJIE_SDK_HOME-15k` 中的连字符仅用于 `.env` 文件键名解析，非 shell 环境变量名。

### 平台典型值

| 变量 | macOS | Windows |
|------|-------|---------|
| `DEVECO_HOME` | `/Applications/DevEco-Studio.app/Contents` | `C:\Program Files\Huawei\DevEco Studio` |
| `CANGJIE_SDK_HOME` | `/Users/xxx/.cangjie-sdk/6.0/cangjie` | `C:\Users\xxx\.cangjie-sdk\6.0\cangjie` |

### 各 skill 前置检查速查

| skill | 模型能力 | 项目类型 | `.env` | 额外前置 |
|-------|---------|---------|--------|---------|
| `/cangjie-translate` | ✅ 影响截图流程 | ✅ 需确认是应用 | ⚠️ 翻译完构建时需要 | 源项目路径、截图就绪（多模态时） |
| `/cangjie-translate-lib` | — | ✅ 需确认是库 | ⚠️ 构建验证时需要 | 源项目路径、源语言 |
| `/build` | — | ✅ 必须是应用 | ✅ `DEVECO_HOME` 必填 | — |
| `/cangjie-lib-build` | — | ✅ 必须是库 | ⚠️ 可选 | 仓颉 SDK 可用性 |
| `/harmonyos-ui-inspect` | ✅ 影响截图读取 | ✅ 必须是应用 | ✅ `DEVECO_HOME` 必填 | 设备连接、HAP 就绪 |

## 资源查找流程

### 1. 语言核心 → `cangjie-kernel`

仓颉语言本身的语法、类型系统、标准库用法。

覆盖：基本类型、String、函数/Lambda、类/结构体/接口/枚举、泛型、扩展、Option/模式匹配、错误处理、并发（spawn/Mutex/Future）、宏、反射、包管理（cjpm）、集合（Array/ArrayList/HashMap）、网络、CFFI。

### 2. 鸿蒙开发 → `cangjie-harmony`

HarmonyOS 平台应用开发，涉及框架、组件、系统 API。

覆盖：Stage 模型、Ability Kit（UIAbility/Want）、ArkUI 声明式 UI（组件/布局/状态管理/渲染控制/动画/弹窗/导航）、ArkData（Preferences/KV-Store/RDB）、互操作、安全/网络/媒体/文件/本地化、API 参考与错误码。

### 3a. 应用级编译构建 → `/build`

编译、打包仓颉 HarmonyOS 应用（产物 HAP）。需要 `.env` 中的 `DEVECO_HOME`。用户在含 `entry/` + `module.json5` 的项目说"编译/构建/build/打包"时使用。

### 3b. 库级编译构建 → `/cangjie-lib-build`

编译纯仓颉 cjpm 库（`cjpm build` + `cjpm test`，产物 `.cjo`/静态/动态库）。不需要 `DEVECO_HOME`，仅需仓颉 SDK（自动检测）。用户在含 `cjpm.toml` 的库根说"编译/构建/跑测试"时使用。

### 4a. 应用级翻译 → `/cangjie-translate`

源项目是可运行应用（含 UI/资源），目标输出 HarmonyOS HAP。会执行资源迁移、`$r()` 引用改写、UI 截图辅助等流程。用法：`/cangjie-translate [arkts|swift|java|python] [code]`。

### 4b. 库级翻译 → `/cangjie-translate-lib`

源项目是库 / SDK / CLI 工具 / 算法包等任意语言纯逻辑代码，目标输出**纯仓颉 cjpm 包**。语言无关，关注 API 面、依赖策略、cjpm 包骨架与构建验证；不处理 UI 资源、`entry/`、`module.json5`。判定不明时先看 SKILL.md 中的 Phase 0 决策表。用法：`/cangjie-translate-lib [source-lib-path]`。

### 5. 经验总结 → `evolution`

已积累的仓颉开发经验和踩坑记录。解决新问题后应追加记录。

### 6. UI 检测 → `/harmonyos-ui-inspect`

构建后验证 UI 表现。采集设备截图 + 控件树，执行交互场景验证，输出差异报告和迭代建议。支持 `--auto-hap`、`--hilog`、`--timestamp`。

### 7. 原始文档 → `/download-script`

以上 skill 未覆盖时的兜底手段，从 GitCode 下载最新文档（stdlib/stdx/syntax/ui-dev/tools）。

## 技术栈

1. **应用层** — 业务代码
2. **ArkUI（仓颉声明式范式）** — 组件布局、状态管理（@State/@Prop/@Link 等）、渲染控制（ForEach/LazyForEach）、动画
3. **应用框架** — Ability Kit（UIAbility/Want）、ArkData（Preferences/KV-Store/RDB）、系统服务 Kits
4. **仓颉-ArkTS 互操作层** — 互操作宏、双向调用、类型映射
5. **仓颉语言** — 类型系统、并发、宏与反射、cjpm
6. **HarmonyOS 平台** — 底层系统能力

## 通用开发规范

- **项目结构**: Stage 模型，`cjpm.toml` 管理配置，`app.json5`（应用级）+ `module.json5`（模块级）
- **UI**: 声明式 UI，大列表用 `LazyForEach`，导航用 `Navigation`
- **权限**: `module.json5` 声明权限，敏感权限运行时申请
- **错误处理**: 优先 `Option<T>` + `?.`/`??`/`if-let`，异常用 `try/catch`
- **并发**: `spawn` 创建线程，`Future<T>` 获取结果，UI 操作在主线程
- **日志**: `HiLog` 分级日志
