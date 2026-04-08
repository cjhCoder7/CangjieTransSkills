---
name: base-skill
description: "仓颉语言 HarmonyOS 开发的入口路由。遇到仓颉语法、HarmonyOS API、编译构建等问题时自动加载，引导使用正确的 skill"
---

# 仓颉语言应用开发指引

遇到仓颉相关问题时，按以下优先级选择 skill：

## 资源查找流程

### 1. 语言核心 → `cangjie-kernel`

仓颉语言本身的语法、类型系统、标准库用法。

覆盖：基本类型、String、函数/Lambda、类/结构体/接口/枚举、泛型、扩展、Option/模式匹配、错误处理、并发（spawn/Mutex/Future）、宏、反射、包管理（cjpm）、集合（Array/ArrayList/HashMap）、网络、CFFI。

### 2. 鸿蒙开发 → `cangjie-harmony`

HarmonyOS 平台应用开发，涉及框架、组件、系统 API。

覆盖：Stage 模型、Ability Kit（UIAbility/Want）、ArkUI 声明式 UI（组件/布局/状态管理/渲染控制/动画/弹窗/导航）、ArkData（Preferences/KV-Store/RDB）、互操作、安全/网络/媒体/文件/本地化、API 参考与错误码。

### 3. 编译构建 → `/build`

编译、打包仓颉 HarmonyOS 应用。用户说"编译"、"构建"、"build"、"打包"时使用。

### 4. 代码翻译 → `/cangjie-translate`

将 ArkTS/Swift/Java 代码翻译为仓颉，在子代理中隔离执行。用法：`/cangjie-translate arkts [code]`。

### 5. 经验总结 → `evolution`

已积累的仓颉开发经验和踩坑记录。解决新问题后应追加记录。

### 6. UI 检测 → `harmonyos-ui-inspect`

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
