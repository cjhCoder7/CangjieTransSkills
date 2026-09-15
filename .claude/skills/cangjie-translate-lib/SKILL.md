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
| 2 | 源语言 | 从 manifest 自动推断（见 Phase 1）；无法推断时用 `--lang` | 询问用户确认 |
| 3 | 分流判定 | 检查源项目是 app 还是 lib（见 Phase 0） | app → 切到 `/cangjie-translate` |
| 4 | 仓颉 SDK 可用 | `~/.cangjie-sdk/` 或 `.env` 中配置 | 提示用户安装（Phase 9 构建验证需要） |
| 5 | 输出目标路径 | 默认当前目录下以源库名创建 | 确认用户是否有特殊要求 |

## Phase 0 — 分流自检（强制前置）

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

## 翻译流程（10 阶段，源语言无关）

### Phase 1 — 源项目摸底

1. **识别构建系统 manifest**（命中任一即可推断源语言）：

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

   多 manifest 共存时，以声明导出/构建主产物的那个为主。

2. **记录事实**：语言与版本、工具链版本、目标运行时（Node / JVM / Swift runtime / 裸机 …）、入口文件、测试目录、CI 配置。
3. **警示**：若项目依赖特定运行时特性（如 JVM 反射、Node event loop、Swift runtime 动态派发），在 `decisions.md`（Phase 6）中登记。

### Phase 2 — 公共 API 面盘点

1. 按源语言可见性规则提取对外 API：
   - TS/JS：`export` / `export default` / `.d.ts`
   - Swift：`public` / `open`
   - Java/Kotlin：`public` / 模块 `exports`
   - Rust：`pub` + `mod.rs` 再导出
   - Go：首字母大写标识符
   - Python：`__all__` / 未 `_` 前缀
2. 产出 `<lib-name>_api.md`：

   ```markdown
   ## 公共 API 清单

   | 源签名 | 仓颉目标签名 | 备注 |
   |--------|-------------|------|
   | `func add(a: number, b: number): number` | `public func add(a: Int64, b: Int64): Int64` | 数值宽窄已锁定 |

   ## 内部 API（不对外导出）

   - `internalHelper(...)` — 保留但不 public
   ```
3. 翻译过程中 API 签名定稿后不得擅自改名；若必须改名（仓颉保留字冲突等），在备注列写明原因。

### Phase 2.5 — 功能完整度约束（强制）

**目标：尽可能翻译完整 API 与核心行为。不要因为仓颉缺少现成 API / 运行时封装，就直接删掉功能、缩窄公共接口，或把核心路径改成空实现。**

遇到仓颉没有直接等价能力时，按以下优先级处理：

1. **replace**：先确认 `std` / `stdx` / 已有仓颉生态是否已有等价能力
2. **implement**：若无现成 API，但可用仓颉标准库、自写算法、compat 层、adapter、薄封装实现，优先自己实现
3. **port**：若相关能力本身就是小而纯的依赖模块，且直接翻译其实现更划算，则一并移植
4. **stub / skip**：只有在确认无法安全实现、或实现成本显著超出本次翻译范围时，才允许最小化占位或跳过

补充约束：

- 只允许跳过最小功能单元，不要因为一个 API 缺失就放弃整个包或整组公共 API
- 禁止用虚构 API、无行为 stub、永远返回默认值的假实现来冒充"已完成翻译"
- 若只能做部分降级实现，必须优先保住主流程和主要公共 API，再在报告里明确差异

### Phase 3 — 依赖策略

对每个 `dependencies` 条目逐一标记决策，产出 `deps_plan.md`：

| 决策 | 适用条件 | 动作 |
|------|---------|------|
| `replace` | 仓颉 `std` / `stdx` 已有等价 | 查 `cangjie-kernel` 确认签名后映射 |
| `implement` | 仓颉无现成 API，但可用标准库 / compat 层 / 自写算法补齐 | 在当前库内落地最小必要实现，并保持 API 语义稳定 |
| `port` | 小而纯、仓颉无等价、直接移植依赖实现更划算 | 纳入翻译范围，作为子包翻译 |
| `stub` | 大型/平台相关/经确认本次确实无法安全实现 | 定义最小 interface 占位，明确缺口、影响范围与后续方案 |
| `drop` | 死码 / 仅构建期工具链（lint、bundler） | 完全不翻译 |

**强制**：每条依赖必须得到一个决策，不允许悬空。
**优先级**：`replace` / `implement` / `port` > `stub` > `drop`。只要核心功能仍可在仓颉侧落地，就不要因为缺少现成 API 直接 `stub` 或删功能。

### Phase 4 — cjpm 骨架搭建

1. 创建目录：
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
2. `cjpm.toml` 至少包含：`name`、`version`、`cjc-version`、`package`、`dependencies`。版本号保留源库的 `major.minor.patch`，允许加 `-cj.0` 预发后缀以示为仓颉翻译版。
3. **包/目录命名**：全部小写下划线，禁止驼峰；与源项目模块边界对齐，避免一包打所有文件。
4. **禁止项**（与 app skill 划界）：
   - ❌ 不新建 `entry/`、`module.json5`、`app.json5`
   - ❌ 不引入 `entry/src/main/resources/`
   - ❌ 不写 `$r("app.media.*")` 或 `$rawfile(...)`
   - ❌ 不为跑 demo 伪造 `main()` 入口（`tests/` 允许 main，库本体不允许）

### Phase 5 — 源语言特性到仓颉的映射清单

每文件翻译前按此 checklist 逐条核对，不漏项：

| 源语言构造 | 仓颉对应 |
|-----------|---------|
| `null` / `undefined` / `nil` / `Optional<T>` / `T?` | `Option<T>` + `?.` / `??` / `if let` |
| 泛型协变逆变 / `<out T>` / `<in T>` | 仓颉泛型约束 `where T <: U`；需要型变时显式 `@!` 或改设计 |
| 继承 / `trait` / `protocol` / `interface` | 仓颉 `interface` + `open class`；注意单继承多实现 |
| `List` / `Array` / `Vec` | 固定长度 `Array<T>` / 可变 `ArrayList<T>` |
| `Dict` / `Map` / `HashMap` | `HashMap<K, V>` |
| `Set` / `HashSet` | `HashSet<T>` |
| 数值：`number` / `int` / `Int` / `long` | 显式 `Int32` / `Int64` / `UInt*` / `Float32` / `Float64` —— 不允许隐式宽窄 |
| 异常 / Result / panic | `throw` + `try/catch` 或 `Option`/`Result`；一个库内风格统一 |
| `Promise` / `Future` / `async/await` / coroutine | `spawn { ... }` + `Future<T>.get()` |
| 正则 / 日期 / 格式化 | 查 `cangjie-kernel` 对应标准库 API |
| 迭代器 / lazy seq / stream | 仓颉迭代器协议 |
| `unsafe` / 指针 / 位运算 | 限制使用；必要时 `unsafe` 块并在注释一行说明原因 |

每条映射若在本次翻译中未遇到可跳过，但 `Int` 宽窄是易错点，必须主动定型。

### Phase 6 — 不可直接翻译项

下列构造**不自作主张**，登记到 `decisions.md`，每条形如：

```markdown
## [决策点 N] <简述>

- 现状：源代码如何用、用在哪里
- 选项：A / B / C
- 推荐：<选项 + 理由>
- 用户确认：[ ]
```

触发登记的典型场景：
- 运行时反射 / 动态加载 / `eval`
- 注解处理器 / 代码生成 / 源语言宏（仓颉宏语义不同，不直译）
- DSL / builder 链 / 操作符重载差异
- 平台 API（文件系统、线程模型、网络栈的平台特定扩展）
- 运行时环境耦合（JVM 类加载、Node event loop、`process.env` 深度依赖）

未获用户明确确认前，不做高风险语义改写。若某功能经确认无法在当前仓颉能力下安全实现，可局部 `skip`，但必须在 `decisions.md` 和翻译报告中写清：功能点、影响范围、已尝试方案、跳过原因、后续建议。禁止用空实现冒充完成。

### Phase 7 — 分模块翻译

- 按依赖拓扑序翻译：无依赖的 leaf 包 → 依赖其他包的模块
- 每完成一个模块立即进入 Phase 9 编译，不积攒错误
- 模块完成与验证结果写回当前 LoopX Todo；编译失败时保持 Todo 未完成并记录紧凑失败证据
- 翻译每个文件前先查 `evolution` skill 的已知坑，解决新坑后回写到 `cangjie-translate-lib/experience/`（Phase 10）
- 不要一次 diff 写几十个文件；保持"写一个 → 编一次 → 记一笔"节奏

### Phase 8 — 冒烟 consumer

在 `tests/` 中创建最小使用者，`import` 本库每个公共 API 并至少调用一次：

- 目的：验证 API 可见性、签名在消费者侧成立
- 仅要求**编译通过**，不等价功能测试
- 源项目如有测试，另行移植到 `tests/` 作为功能回归（可能进入 `port` 决策的一部分）

### Phase 9 — 构建验证

直接调用 `/cangjie-lib-build` 完成自动化编译与测试（脚本位于 `.claude/skills/cangjie-lib-build/lib_build.py`）：

```bash
python3 ${CLAUDE_SKILL_DIR}/../cangjie-lib-build/lib_build.py <lib-root>
```

或在交互中直接下发 `/cangjie-lib-build <lib-root>`（推荐，无路径依赖）。该命令会：

- 自动检测仓颉 SDK（`.env` 或 `~/.cangjie-sdk/`）
- 跑 `cjpm build`，产物落到 `<lib-root>/target/`
- 若库根含 `tests/` 或 `cjpm.toml` 含 `[test]`/`[[test]]` 段，跑 `cjpm test`

要求：
- `cjpm build` 成功，无 error
- `cjpm test`（如执行）全部通过
- Warning 按常规处理；`deprecated` / `unused` 视情况保留
- 失败时先查 `evolution/cangjie/syntax.md`、`evolution/cangjie/arkui.md`；若是库级工程化问题（包循环、导出不一致），写入 `cangjie-translate-lib/experience/build.md`

### Phase 10 — 经验沉淀

解决了**非显而易见**问题后追加到 `cangjie-translate-lib/experience/`，按主题分文件：

- `type-mapping.md` — 任意语言 → 仓颉的类型/语义对应细节
- `deps.md` — 依赖替代策略（哪些能 replace，哪些必须 port，常见 stub 形态）
- `build.md` — cjpm 工程化（多包、版本、导出）
- `api-design.md` — 库对外 API 设计取舍（异常 vs Result、可选参数、默认值）

**不预先创建空文件**，按需生成并更新 `experience/README.md` 索引。格式遵循 `evolution/SKILL.md` 的"单条经验格式"。

**与 `cangjie-translate/*2cangjie/` 的区别**：那里沉淀应用翻译中"源语言 → 仓颉"的语法/表达差异；这里沉淀**库工程化**经验（包布局、API 面、依赖替代、cjpm 构建）。两边有交叉的语法点优先记到 `cangjie-translate/*2cangjie/`，本目录只记库独有的。

经验文件只有在问题已复现、方案已验证后写入。将其稳定相对路径记录到当前 LoopX Todo；未验证猜测保留为风险或 successor，不进入经验库。

## 翻译总则

- 优先保全公共 API 与核心功能；仓颉缺失现成 API 时，先自行实现 compat / adapter / helper，再考虑 `stub` 或 `skip`
- 语义等价，不擅自加功能或改行为
- 用仓颉惯用写法，不逐行直译
- 数值宽窄、可空性、错误模型必须显式决定，不靠"约定"
- 翻译后代码必须 `cjpm build` 通过；不允许遗留 `// TODO: will compile later`
- 不确定的翻译先进 `decisions.md`，拿到用户确认再落地

## 输出物清单（翻译完成后应同时交付）

1. cjpm 包源码（`src/` + `cjpm.toml` + `tests/`）
2. `<lib-name>_api.md` — 公共 API 对照表
3. `deps_plan.md` — 依赖决策记录
4. `decisions.md` — 不可直译项的决策点（即使为空也保留文件）
5. 翻译报告：分流判定结论 + 关键取舍 + 已跳过 / 降级项 + 已知遗留项 + 验证结果

以上输出物齐备、构建与测试通过、启用的质量策略回执有效，且最终 `quota should-run` 不再选择已完成工作后，才能结案 Goal。
