---
name: cangjie-translate-lib
description: "将任意语言的三方库/SDK/工具包翻译为纯仓颉 cjpm 包。关注 API 面、依赖策略、包骨架与构建验证；不涉及 HarmonyOS 应用资源与 UI"
argument-hint: "[source-lib-path] [--lang <hint>]"
---

# 三方库翻译为仓颉 cjpm 包

将位于 $1 的三方库翻译为纯仓颉 cjpm 包。`--lang <hint>` 可选，在无法从 manifest 自动判定源语言时使用。

本 skill 面向**库级别**翻译，产物为 **`cjpm` 包**。不包含应用资源迁移、`$r()` 引用、HarmonyOS `entry/` 骨架、UI 截图辅助等 app 级逻辑 —— 这些由 `/cangjie-translate` 负责。

## LoopX 管理（强制）

开始任何读取之外的操作前，加载 `cangjie-loopx-management`：

1. 从目标项目根创建或恢复一个 Goal；
2. 按其 [库迁移映射](../cangjie-loopx-management/references/workflow-mapping.md#库迁移) 先规划、后写入有序 Todo；
3. 每轮只执行 `quota should-run` 选中的阶段；
4. 高风险语义决策、SDK 缺失或写入范围变化通过用户 Gate 管理；
5. 每个模块批次只有在 `cjpm build` 或对应测试通过后才完成 Todo。

不得因为用户直接调用了本 skill 就绕过 LoopX，也不得在 LoopX 不可用时退化为聊天内的临时进度表。

## 前置检查（启动翻译前必须完成）

| # | 检查项 | 获取方式 | 未就绪时 |
|---|-------|---------|---------|
| 1 | 源项目路径 | 参数 `$1` 或用户指定 | 询问用户提供路径 |
| 2 | 源语言 | 从 manifest 自动推断（见"源项目摸底"）；无法推断时用 `--lang` | 询问用户确认 |
| 3 | 分流判定 | 检查源项目是 app 还是 lib（见"分流判定"） | app → 切到 `/cangjie-translate` |
| 4 | 仓颉 SDK 可用 | `~/.cangjie-sdk/` 或 `.env` 中配置 | 提示用户安装（构建验证阶段需要） |
| 5 | 输出目标路径 | 默认当前目录下以源库名创建 | 确认用户是否有特殊要求 |

## 分流判定（强制）

在执行任何翻译前先判定本 skill 是否适用：

| 源项目形态 | 产物目标 | 应使用 |
|-----------|---------|--------|
| 可运行 app / HarmonyOS 应用 / 含 UI 资源（`entry/`、`Assets.xcassets/`、Android `res/`） | HAP 应用 | `/cangjie-translate` |
| 库 / SDK / CLI 工具 / 算法包 / 纯逻辑工具包 | cjpm package | **本 skill** |
| 混合仓库（app + 内部库） | — | 先用本 skill 抽出库部分，app 部分走 `/cangjie-translate` |

**自检规则**：若源项目含下列任一应用入口，属 app 场景，应切到 `/cangjie-translate`：
- HarmonyOS：`module.json5` 含 `abilities` 且有 UIAbility
- Android：`AndroidManifest.xml` 含 `<activity>` 且声明 `LAUNCHER`
- iOS：`@main` AppDelegate / `App` 结构体
- Web：`index.html` + 运行时入口
- Server/CLI **应用**：可执行二进制入口（main 函数 + 被 manifest 标记为 `bin`）。注意：CLI 参数解析库、工具函数库等**仍属于库**，应使用本 skill

判定结果在产出的翻译报告首行明确写出："分流判定：lib / 继续本 skill"。

## 翻译流程

1. **分流判定** — 确认继续本 skill（见上节），报告首行写明判定结论
2. **源项目摸底** — 识别构建系统 manifest 确定源语言（见"源项目摸底"），记录语言/工具链版本/目标运行时/入口文件/测试目录/CI 配置
3. **公共 API 盘点** — 按源语言可见性规则提取对外 API，整理"源签名 → 仓颉签名"对照写入翻译报告；签名定稿后不擅自改名
4. **依赖策略** — 对每条 `dependencies` 标记决策（见"依赖决策"），不允许悬空
5. **搭建 cjpm 骨架**（见"cjpm 骨架"）
6. **逐模块翻译** — 按依赖拓扑序，无依赖的 leaf 包先行；核对"常见映射点"；遇到不可直译项登记到"决策记录"；每完成一个模块立即构建，不积攒错误
7. **冒烟 consumer** — `tests/` 中创建最小消费者，`import` 每个公共 API 并调用一次，仅要求编译通过；源项目已有测试可移植作为功能回归
8. **构建验证** — 调用 `/cangjie-lib-build <lib-root>`，`cjpm build` 成功、`cjpm test`（如有）全部通过

## 源项目摸底

识别构建系统 manifest（命中任一即可推断源语言）：

| Manifest | 源语言 |
|----------|-------|
| `package.json` | JS/TS（含 ArkTS） |
| `tsconfig.json` + `.ts` | TypeScript |
| `Package.swift` / `*.podspec` | Swift/Obj-C |
| `pom.xml` / `build.gradle(.kts)` | Java/Kotlin |
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `setup.py` / `pyproject.toml` | Python |
| `*.cabal` / `stack.yaml` | Haskell |
| `CMakeLists.txt` + 无上述 | C/C++ |
| `mix.exs` / `rebar.config` | Elixir/Erlang |

多 manifest 共存时，以声明导出/构建主产物的那个为主。若项目依赖特定运行时特性（如 JVM 反射、Node event loop、Swift runtime 动态派发），登记到"决策记录"。

## 依赖决策

对每个依赖条目标记决策：

| 决策 | 适用条件 | 动作 |
|------|---------|------|
| `replace` | 仓颉 `std` / `stdx` 已有等价 | 查 `cangjie-kernel` 确认签名后映射 |
| `implement` | 仓颉无现成 API，但可用标准库 / compat 层 / 自写算法补齐 | 在当前库内落地最小必要实现，保持 API 语义稳定 |
| `port` | 小而纯、仓颉无等价、直接移植依赖实现更划算 | 纳入翻译范围，作为子包翻译 |
| `stub` | 大型/平台相关/经确认本次确实无法安全实现 | 定义最小 interface 占位，登记到"决策记录" |
| `drop` | 死码 / 仅构建期工具链（lint、bundler） | 完全不翻译 |

**强制**：每条依赖必须得到一个决策，不允许悬空。优先级：`replace` / `implement` / `port` > `stub` > `drop`。

## cjpm 骨架

```
<lib-name>/
├── cjpm.toml
├── src/
│   └── <root-package>/
│       ├── *.cj
│       └── <subpackage>/
│           └── *.cj
└── tests/
    └── *.cj
```

- `cjpm.toml` 至少包含：`name`、`version`、`cjc-version`、`package`、`dependencies`。版本号保留源库的 `major.minor.patch`，允许加 `-cj.0` 预发后缀标注为仓颉翻译版
- 包/目录命名全部小写下划线，禁止驼峰；与源项目模块边界对齐，避免一包打所有文件
- 禁止项：不新建 `entry/`、`module.json5`、`app.json5`；不引入 `entry/src/main/resources/`；不写 `$r("app.media.*")` 或 `$rawfile(...)`；不为跑 demo 在库本体伪造 `main()`（`tests/` 允许）

## 常见映射点

| 源语言构造 | 仓颉对应 |
|-----------|---------|
| 空值（`null`/`undefined`/`Optional<T>`） | `Option<T>` + `?.`/`??`/`if let` |
| 容器（`List`/`Dict`/`Set` 等） | `Array<T>`/`ArrayList<T>`/`HashMap<K,V>`/`HashSet<T>` |
| 数值（`number`/`int`/`long` 等） | 显式 `Int32`/`Int64`/`UInt*`/`Float32`/`Float64`，不允许隐式宽窄 |
| 异常 / `Result` / `panic` | `throw` + `try/catch` 或 `Option`/`Result`，一个库内风格统一 |
| `Promise`/`Future`/`async`/协程 | `spawn { ... }` + `Future<T>.get()` |
| 继承 / `trait` / `protocol` / `interface` | `interface` + `open class`，注意单继承多实现 |
| 泛型型变（`<out T>`/`<in T>`） | 仓颉泛型约束 `where T <: U`；需要型变时显式处理或改设计 |
| `unsafe` / 指针 / 位运算 | 限制使用，必要时 `unsafe` 块并注明原因 |

`Int` 宽窄是易错点，必须主动定型；未遇到的构造可跳过核对。

## 决策记录

下列构造**不自作主张**，登记到翻译报告的"决策记录"小节，每条形如：

```markdown
## [决策点 N] <简述>

- 现状：源代码如何用、用在哪里
- 选项：A / B / C
- 推荐：<选项 + 理由>
- 用户确认：[ ]
```

触发登记的典型场景：运行时反射/动态加载/`eval`、注解处理器/代码生成/源语言宏、DSL/builder 链/操作符重载差异、平台特定 API、运行时环境耦合（JVM 类加载、Node event loop、`process.env` 深度依赖）。

未获用户明确确认前，不做高风险语义改写。若某功能经确认无法安全实现，可局部 `skip`，但必须写清：功能点、影响范围、已尝试方案、跳过原因、后续建议。禁止用空实现冒充完成。

## 功能完整度约束（强制）

**目标：尽可能翻译完整 API 与核心行为。不要因为仓颉缺少现成 API / 运行时封装，就直接删掉功能、缩窄公共接口，或把核心路径改成空实现。**

遇到仓颉没有直接等价能力时，按优先级处理：`replace`（先确认 `std`/`stdx` 是否已有等价）→ `implement`（自写 compat/adapter/helper）→ `port`（小而纯的依赖一并移植）→ `stub`/`skip`（仅在确认无法安全实现或成本显著超出范围时）。

- 只允许跳过最小功能单元，不要因一个 API 缺失就放弃整个包或整组公共 API
- 禁止用虚构 API、无行为 stub、永远返回默认值的假实现冒充"已完成翻译"
- 只能部分降级实现时，优先保住主流程和主要公共 API，再在报告里说明差异

## 翻译规则

- 优先保全公共 API 与核心功能；仓颉缺失现成 API 时，先自行实现 compat/adapter/helper，再考虑 `stub`/`skip`
- 语义等价，不擅自加功能或改行为；用仓颉惯用写法，不逐行直译
- 数值宽窄、可空性、错误模型必须显式决定，不靠"约定"
- 翻译后代码必须 `cjpm build` 通过；不允许遗留 `// TODO: will compile later`
- 不确定的翻译先记决策点，拿到用户确认再落地
- 解决了非显而易见问题时，可选追加记录到 `experiences/experiences.md`（简要现象/原因/方案）

## 输出物清单（结案前应具备）

- cjpm 包源码（`src/` + `cjpm.toml` + `tests/`）
- 翻译报告：分流判定结论 + 公共 API 对照要点 + 依赖决策要点 + 决策记录 + 已跳过/降级项 + 验证结果

信息量大时允许自行拆分附加文件，但不作为结案硬性要求。以上内容齐备、构建与测试通过、启用的质量策略回执有效，且最终 `quota should-run` 不再选择已完成工作后，才能结案 Goal。
