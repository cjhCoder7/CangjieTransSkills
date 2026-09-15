---
name: base-skill
description: "仓颉语言 HarmonyOS 开发的入口路由。遇到仓颉语法、HarmonyOS API、翻译或构建等问题时自动加载，并将操作型任务接入 LoopX 管理"
---

# 仓颉语言应用开发指引

遇到仓颉相关问题时，按以下优先级选择 skill：

## LoopX 管理入口

先区分请求是否会改变项目：

- **只读请求**：仓颉语法解释、API 查询、文档定位、代码分析。直接路由到对应领域 skill，不创建 LoopX Goal。
- **操作型请求**：翻译、写代码、迁移资源、构建、测试、UI 验证、修复。必须加载 `cangjie-loopx-management`，由它按固定顺序完成运行前检查（第一步即本节三步确认）、`loopx doctor` 探活、建立或恢复 Goal，再以 Todo、Gate、quota 和状态投影管理全过程。

用户不需要先手工执行 `/loopx`。直接调用 `/cangjie-translate`、`/cangjie-translate-lib`、`/build`、`/cangjie-lib-build`、`/harmonyos-ui-inspect` 或执行 `/download-script` 下载时，操作型 skill 应主动进入上述管理流程。

LoopX 只管理任务状态，不替代下方项目类型、模型能力和环境检查，也不扩大当前会话的写入、网络、凭据或外部系统权限。

## 前置问答清单（`cangjie-loopx-management` 运行前检查第一步）

这三步确认是 `cangjie-loopx-management`"运行前检查"的第一步，先于解析 LoopX 命令前缀、`loopx doctor` 探活和建立/恢复 Goal 执行。**必须依次完成以下三步确认**。任何步骤未通过时不要启动领域执行流程；将缺失项写为适当的用户 Gate 或阻塞证据。

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
| 其他语言项目（待翻译） | 源项目 | — | 按形态选择（见各翻译 skill 的分流判定） |

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

| skill | LoopX | 模型能力 | 项目类型 | `.env` | 额外前置 |
|-------|-------|---------|---------|--------|---------|
| `/cangjie-translate` | ✅ Goal/Todo | ✅ 影响截图流程 | ✅ 需确认是应用 | ⚠️ 翻译完构建时需要 | 源项目路径、截图就绪（多模态时） |
| `/cangjie-translate-lib` | ✅ Goal/Todo | — | ✅ 需确认是库 | ⚠️ 构建验证时需要 | 源项目路径、源语言 |
| `/build` | ✅ Goal/Todo | — | ✅ 必须是应用 | ✅ `DEVECO_HOME` 必填 | — |
| `/cangjie-lib-build` | ✅ Goal/Todo | — | ✅ 必须是库 | ⚠️ 可选 | 仓颉 SDK 可用性 |
| `/harmonyos-ui-inspect` | ✅ Goal/Todo | ✅ 影响截图读取 | ✅ 必须是应用 | ✅ `DEVECO_HOME` 必填 | 设备连接、HAP 就绪 |
| `/download-script`（实际下载） | ✅ Goal/Todo | — | — | — | 网络权限、下载目标路径 |

## 资源查找流程

### 0. 操作型任务管理 → `cangjie-loopx-management`

创建或恢复 Goal，按计划写入 Todo，每轮读取 quota 与用户 Gate，执行后写回可验证证据，并在状态漂移时自修复。所有操作型领域 skill 均通过此入口运行。

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

源项目是库 / SDK / CLI 工具 / 算法包等任意语言纯逻辑代码，目标输出**纯仓颉 cjpm 包**。语言无关，关注 API 面、依赖策略、cjpm 包骨架与构建验证；不处理 UI 资源、`entry/`、`module.json5`。判定不明时先看 SKILL.md 中的分流判定表。用法：`/cangjie-translate-lib [source-lib-path]`。

### 5. UI 检测 → `/harmonyos-ui-inspect`

构建后验证 UI 表现。采集设备截图 + 控件树，执行交互场景验证，输出差异报告和迭代建议。支持 `--auto-hap`、`--hilog`、`--timestamp`。

### 6. 原始文档 → `/download-script`

以上 skill 未覆盖时的兜底手段，从 GitCode 下载最新文档（stdlib/stdx/syntax/ui-dev/tools）。

### 7. 经验记录（可选） → `experiences`

跨领域共享的单文件经验日志，遇到非显而易见问题时可查阅或追加，非强制。

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
