# 样本记录：Preferences 主题持久化（数据持久化）

## A. 基本信息

- `Record ID`：sample-data-persistence-preferences-001
- `创建日期`：2026-03-26
- `最近更新日期`：2026-03-26
- `代码骨架更新日期`：2026-03-26
- `作者 / Agent`：Codex CLI
- `样本类别`：数据持久化
- `当前状态`：UI 页面与独立工程骨架已完成
- `优先级`：P0
- `对应阶段`：Phase 2
- `是否为第一批核心样本`：是

## B. 样本选择原因

### B.1 样本来源

- `来源仓库`：OpenHarmony applications_app_samples
- `来源链接`：https://github.com/openharmony/applications_app_samples
- `访问日期`：2026-03-26
- `分支 / commit / tag`：master（本次通过 GitHub tree API 与 raw 源码链接访问）
- `本地路径`：当前仓库未镜像完整源工程，本次以官方样本源码和官方文档为主进行准备
- `License / 使用限制`：示例仓库与源码文件头指向 Apache License 2.0

### B.2 为什么选择这个样本

选择 `Preferences` 官方样本作为第二个小样本，原因有四个：

1. **它直接覆盖“轻量级持久化设置”这一高频场景**。
   - 当前样本的核心语义不是复杂业务存储，而是“保存一个简单用户设置，并在应用下次启动时恢复”。
   - 这与后续 Telegram 工程中大量“用户偏好设置、功能开关、展示模式持久化”的需求高度一致。

2. **它的 API 面积小，适合作为第二个样本**。
   - 与关系型数据库相比，Preferences 只涉及 `getPreferences`、`get`、`put`、`flush`、`delete`、`on/off` 等少量接口。
   - 先攻克它，能快速建立“状态 -> 持久化 -> 重启恢复 -> 测试”的闭环。

3. **它同时覆盖了生命周期与状态恢复**。
   - 官方样本在页面 `aboutToAppear` 中读取首选项，并将持久化值恢复到 UI 状态。
   - 这非常适合我们继续验证 ArkTS 与仓颉在状态管理、生命周期、上下文获取方面的映射关系。

4. **它有完整的一手资料链**。
   - 有官方应用样本；
   - 有 OpenHarmony ArkTS Preferences 文档；
   - 有 OpenHarmony 仓颉 Preferences 文档；
   - 非常适合沉淀成高质量 Skill。

### B.3 本样本要验证的 Skill

- `Skill 列表`：
  - `data-persistence-preferences`
- `主验证 Skill`：`data-persistence-preferences`
- `希望从样本中反推形成的新 Skill`：
  - `arkts-to-cangjie-context-acquisition`
  - `settings-state-restoration`

## C. 样本概述

### C.1 原始样本功能描述

本样本的 ArkTS 原始目标非常清晰：

- 维护一个当前主题 `theme`；
- 当页面出现时，从 `Preferences` 中读取已保存的 `theme` 值；
- 根据这个主题值决定当前 UI 使用哪一套主题数据；
- 当用户点击“切换”并选择新主题时，把新的主题值写回 `Preferences`；
- 调用 `flush()` 把缓存中的配置真正落盘；
- 退出应用后再次进入，页面应恢复到上一次退出前的主题。

### C.2 工程结构概览

本次重点关注以下官方源码文件：

- `entry/src/main/ets/pages/Index.ets`
  - 持久化逻辑和主题切换逻辑的核心入口。
- `entry/src/main/ets/common/ThemeDesktop.ets`
  - 负责展示主题内容，但不是本轮持久化转换的主目标。
- `entry/src/main/ets/model/Logger.ts`
  - 日志工具，可在后续日志样本中单独抽取。

### C.3 关键路径说明

本轮最关键的执行链路如下：

1. 页面生命周期 `aboutToAppear` 触发；
2. 获取 `Preferences` 实例；
3. 读取键 `theme`；
4. 根据 `theme` 更新当前 UI 所使用的主题数据；
5. 用户点击切换主题；
6. 写入新值到 `Preferences`；
7. 调用 `flush()` 落盘；
8. 应用重启后再次读取并恢复状态。

## D. ArkTS 源代码片段

### D.1 源代码片段清单

#### 片段 1

- `来源文件`：`Index.ets`
- `主题`：持久化上下文、页面状态与生命周期读取
- `为什么关键`：它定义了本样本的“页面出现时恢复状态”核心行为

```ts
import Logger from '../model/Logger'
import preferences from '@ohos.data.preferences'
import ThemeDesktop from '../common/ThemeDesktop'
import emitter from '@ohos.events.emitter'

const TAG: string = '[Index]'
const PREFERENCES_NAME = 'theme.db'
const THEME_NAMES: string[] = ['default', 'simplicity', 'pomeloWhtie']
let preferenceTheme: preferences.Preferences = null

@Entry
@Component
struct Index {
  @State nowTheme: string = ''
  @State themeDatas: Array<{
    image: Resource,
    name: string
  }> = []

  async aboutToAppear() {
    await this.getPreferencesFromStorage()
    this.nowTheme = await this.getPreference()
    console.info(`nowTheme__get ${this.nowTheme}`)
    emitter.emit({ eventId: 0, priority: 0 }, { data: {
      nowTheme: this.nowTheme
    } })
    let index = THEME_NAMES.indexOf(this.nowTheme)
    this.themeDatas = THEMES[index]
  }
}
```

#### 片段 2

- `来源文件`：`Index.ets`
- `主题`：获取 `Preferences` 实例、读取主题值、写入主题值
- `为什么关键`：它定义了本样本中最核心的 ArkTS 持久化 API 映射点

```ts
async getPreferencesFromStorage() {
  let context = getContext(this) as any
  preferenceTheme = await preferences.getPreferences(context, PREFERENCES_NAME)
}

async putPreference(data: string) {
  Logger.info(TAG, `Put begin`)
  if (preferenceTheme !== null) {
    await preferenceTheme.put('theme', data)
    await preferenceTheme.flush()
  }
  Logger.info(TAG, `Put end`)
}

async getPreference() {
  Logger.info(TAG, `Get begin`)
  let data = 'default'
  if (preferenceTheme !== null) {
    data = await preferenceTheme.get('theme', 'default') as string
  }
  Logger.info(TAG, `Get end`)
  return data
}
```

#### 片段 3

- `来源文件`：`Index.ets`
- `主题`：用户触发主题切换后写回存储
- `为什么关键`：它把“UI 操作”和“持久化更新”真正连在一起

```ts
async changeTheme(value: string) {
  this.nowTheme = value
  await this.putPreference(value)
  let index = THEME_NAMES.indexOf(value)
  this.themeDatas = THEMES[index]
  emitter.emit({ eventId: 0, priority: 0 }, { data: {
    nowTheme: this.nowTheme
  } })
}
```

### D.2 ArkTS 语义摘要

- 当前片段表达的是“主题设置持久化”能力，而不是通用数据库管理能力；
- 必须在仓颉中保持一致的行为包括：
  - 首次进入页面时读取已保存主题；
  - 用户变更主题后写回存储；
  - 下次进入应用时恢复到最近一次保存的主题；
- ArkTS 特有且不适合直接照搬的部分包括：
  - `getContext(this)` 的页面上下文获取方式；
  - `await preferences.getPreferences(getContext(this), PREFERENCES_NAME)` 的异步调用风格；
  - `preferenceTheme.get('theme', 'default') as string` 这种弱类型断言；
- 该样本依赖页面生命周期、状态绑定和应用上下文，但不依赖网络、权限或复杂外部服务。

## E. 目标语言预期（Cangjie）

### E.1 目标行为预期

本轮对仓颉版本的预期目标如下：

- 页面初始化时能够读取 `theme.db` 中的 `theme` 值；
- 如果没有存储值，则返回默认值 `default`；
- 用户修改主题时，把新值写入 `Preferences` 并调用 `flush()` 落盘；
- 后续再次进入页面时能够恢复之前保存的主题；
- 在当前阶段，允许把完整主题 UI 降级为“主题名 + 简化预览”，但不允许丢失持久化语义。

### E.2 目标代码结构预期

- `目标模块划分`：
  - `ThemePreferenceStore.cj` 负责封装 `Preferences` 读写；
  - `ThemeSettingsPage.cj` 负责页面状态与用户交互；
- `目标页面 / 组件划分`：
  - 一个设置页即可，不要求先完整复刻官方样本的所有视觉元素；
- `目标状态管理方式`：
  - 使用 `@State currentTheme` 承接当前主题；
- `目标存储方式`：
  - 使用 `Preferences` 的 `StringData` 保存 `theme` 键；
- `目标日志策略`：
  - 记录读取开始、读取完成、写入开始、写入完成、默认值回退等关键路径；
- `目标测试切入点`：
  - 默认值读取；
  - 写入后再读取；
  - 多次覆盖写入；
  - 删除后回退默认值；
  - 应用重进后的手动恢复验证。

### E.3 目标代码草案

以下代码是“本轮翻译准备阶段”的目标结构草案，不代表正式完成的仓颉翻译结果，但已能说明最核心的 API 映射方向。

```cangjie
package ohos_app_cangjie_entry

import kit.ArkData.*
import kit.AbilityKit.UIAbilityContext

class ThemePreferenceStore {
    private let context: UIAbilityContext
    private let storeName: String

    public init(context: UIAbilityContext, storeName: String = "theme.db") {
        this.context = context
        this.storeName = storeName
    }

    private func store(): Preferences {
        return Preferences.getPreferences(this.context, PreferencesOptions(this.storeName))
    }

    public func loadTheme(): String {
        let preferences = this.store()
        let value = preferences.get("theme", PreferencesValueType.StringData("default"))
        match (value) {
            case PreferencesValueType.StringData(theme) => return theme
            case _ => return "default"
        }
    }

    public func saveTheme(theme: String): Unit {
        let preferences = this.store()
        preferences.put("theme", PreferencesValueType.StringData(theme))
        preferences.flush()
    }

    public func clearTheme(): Unit {
        let preferences = this.store()
        if (preferences.has("theme")) {
            preferences.delete("theme")
            preferences.flush()
        }
    }
}
```

## F. 转换过程记录

### F.1 转换轮次概览

| 轮次 | 当前目标 | 输出结果 | 状态 |
|---|---|---|---|
| Round 1 | 选择代表性持久化样本 | 选定官方 `Preferences` 样本 | 已完成 |
| Round 2 | 核对 ArkTS 与仓颉 Preferences API | 完成 API 映射草案 | 已完成 |
| Round 3 | 初始化样本记录、轨迹与 Skill | 已创建本记录、轨迹与 Skill | 已完成 |
| Round 4 | 正式翻译仓颉代码 | 尚未开始 | 未开始 |

### F.2 每轮详细记录

#### Round 1

- `输入`：首批四类小样本规划中的“持久化”方向
- `动作`：从官方样本库检索可直接用于小样本验证的 ArkTS Preferences 示例
- `结果`：确认 `code/BasicFeature/DataManagement/Preferences` 为最合适的第二个小样本

#### Round 2

- `输入`：官方样本 `Index.ets`、OpenHarmony ArkTS Preferences 文档、OpenHarmony 仓颉 Preferences 文档
- `动作`：抽取核心读写链路，并建立 `getPreferences -> get -> put -> flush` 的仓颉侧映射
- `结果`：确认该样本可以先聚焦 `theme: String` 的持久化，不必一开始引入更复杂的数据结构

#### Round 3

- `输入`：`docs/sample-record-template.md`、`docs/execution-trace-template.md`、`skills/SKILL_SCHEMA_V1.md`
- `动作`：初始化样本记录、执行轨迹与持久化 Skill
- `结果`：当前准备工作完成，可进入正式翻译实现阶段

## G. 转换难点记录

### G.1 语法映射难点

1. ArkTS 使用 `await` 风格，而仓颉 Preferences 文档展示的是同步式对象方法调用与显式异常处理。
2. ArkTS 可以直接把 `get('theme', 'default') as string` 断言为字符串；仓颉需要通过 `PreferencesValueType` 做显式匹配。

### G.2 持久化语义难点

1. Preferences 的“写入缓存”和“真正落盘”不是同一步，必须保留 `flush()`。
2. 默认值回退逻辑不能省略，否则第一次启动时会出现未定义状态。
3. Preferences 更适合轻量配置，不适合把它误当成复杂业务数据库来翻译。

### G.3 生命周期与上下文难点

1. ArkTS 页面常直接通过 `getContext(this)` 获取上下文；仓颉更适合由 `UIAbility` 或全局上下文显式传入。
2. 页面“出现时读取”与“点击后写入”分别对应生命周期和事件处理，后续翻译时必须避免把初始化读取和用户交互写回混在一起。

### G.4 依赖与环境难点

1. 当前环境没有 DevEco Studio + 仓颉插件，无法进行真实读盘验证。
2. 当前只能做 API 映射、文档准备和测试策略设计，真实持久化文件路径验证需要 IDE 环境。

## H. 单测生成策略

### H.1 单测目标

本样本的单测目标是验证“持久化语义是否成立”，而不是先追求完整 UI 视觉一致性。

### H.2 单测切分

1. **仓库层测试**
   - 空存储时 `loadTheme()` 返回 `default`；
   - `saveTheme("simplicity")` 后再次读取应返回 `simplicity`；
   - 多次覆盖写入时，以最后一次写入值为准；
   - 删除键后回退默认值；

2. **页面状态测试**
   - 页面初始化时，`currentTheme` 与存储值一致；
   - 用户点击主题切换按钮后，状态变量立即更新；
   - 状态更新后，仓库层的写入接口被调用；

3. **IDE 手动验证**
   - 运行应用，切换主题；
   - 关闭应用后再次打开；
   - 验证主题是否恢复到上次保存值。

### H.3 单测生成策略说明

- 在正式翻译时，建议优先把 Preferences 访问封装到 `ThemePreferenceStore` 中；
- 再通过一个内存版 Fake Store 替代真实 `Preferences`，先完成纯逻辑单测；
- 最后在 IDE 中通过人工重启应用进行真实持久化验证。

## I. 编译与运行验证

### I.1 编译验证

- `构建命令`：当前未执行
- `构建环境`：当前工作空间未安装可用的 DevEco Studio + 仓颉插件环境
- `是否成功`：否（未执行）
- `关键输出`：无
- `关键报错位置`：无
- `报错解释`：本轮为样本选择、文档初始化与 Skill 构建阶段，尚未进入正式仓颉代码翻译和编译验证

### I.2 运行验证

- `运行环境`：当前未执行
- `验证步骤`：
  1. 在具备 DevEco Studio + 仓颉插件的环境中导入后续翻译工程；
  2. 首次运行设置页，确认默认主题值加载为 `default`；
  3. 点击切换主题为 `simplicity` 或 `pomeloWhtie`；
  4. 退出应用并重新打开；
  5. 确认主题恢复到最近一次写入值；
- `观察结果`：当前未执行设备侧验证
- `是否达到目标行为`：部分达到
- `截图 / 日志 / 视频索引`：本轮无设备侧产物

## J. 结果评估

### J.1 当前结果评分

| 评估项 | 分数 | 说明 |
|---|---|---|
| 样本代表性 | 5 / 5 | 直接对应用户设置持久化场景 |
| 一手资料完整度 | 5 / 5 | 官方样本、ArkTS 文档、仓颉文档均已具备 |
| API 映射清晰度 | 5 / 5 | 关键接口链路已经明确 |
| 翻译完成度 | 1 / 5 | 仅完成准备与草案，尚未进入正式实现 |
| 测试可设计性 | 5 / 5 | 非常适合作为第二个小样本 |

### J.2 当前结论

- `Preferences` 适合作为第二个样本立即启动；
- 它比关系型数据库更轻、更快、更适合先建立“持久化闭环”；
- 下一步应直接进入“正式仓颉翻译 + Fake Store 单测设计 + IDE 手动验证 Checklist”的实现阶段。

## K. 回写建议

### K.1 应回写到哪些 Skill

- `data-persistence-preferences`
- 后续若发现上下文获取模式稳定，可新增 `arkts-to-cangjie-context-acquisition`

### K.2 是否应新增 Skill

- 是。
- 当前已经新增 `data-persistence-preferences.md`，后续随着正式翻译推进，可继续扩展为更完整的持久化 Skill 组。

### K.3 是否应调整评测标准

- 暂不调整项目级评测标准；
- 但建议在持久化样本专项评测中增加“应用重启后状态恢复正确”这一人工验证项。

## L. 附录

### L.1 相关文件

- `docs/samples/data-persistence-001.md`
- `docs/traces/trace-data-persistence-001.md`
- `skills/data-persistence-preferences.md`

### L.2 相关执行轨迹

- `docs/traces/trace-data-persistence-001.md`

### L.3 相关文档与链接

- https://github.com/openharmony/applications_app_samples
- https://raw.githubusercontent.com/openharmony/applications_app_samples/master/code/BasicFeature/DataManagement/Preferences/README_zh.md
- https://raw.githubusercontent.com/openharmony/applications_app_samples/master/code/BasicFeature/DataManagement/Preferences/entry/src/main/ets/pages/Index.ets
- https://gitee.com/openharmony/docs/raw/master/zh-cn/application-dev/database/data-persistence-by-preferences.md
- https://gitcode.com/openharmony/docs_cangjie

### L.4 备注

- 本记录属于“翻译准备阶段”的初始化文档；
- 当前尚未输出正式仓颉页面代码；
- 后续实现阶段将以本记录为基线继续推进。

## M. 本轮新增仓颉代码产物

### M.1 目录结构

```text
samples/data-persistence-001/
├── StorageCore.cj
├── HarmonyPreferencesStorage.cj
├── FakeKeyValueStorage.cj
├── UserSettingsManager.cj
└── UserSettingsManagerTests.cj
```

### M.2 文件职责说明

- `StorageCore.cj`
  - 定义 `StorageValue` 与 `KeyValueStorage`；
  - 负责把业务层和底层存储实现解耦；
  - 同时提供 `readStringValue`、`readBoolValue`、`readIntValue`、`readDoubleValue` 四个显式读取辅助函数。
- `HarmonyPreferencesStorage.cj`
  - 是面向 HarmonyOS NEXT 仓颉 API 的真实实现；
  - 内部把 `StorageValue` 映射到 `PreferencesValueType`；
  - 保留 `put` 与 `flush` 分离的语义，不伪装成“写入即持久化”。
- `FakeKeyValueStorage.cj`
  - 使用 `HashMap<String, StorageValue>` 做纯内存实现；
  - 用 `flushCounter` 与 `operations` 记录测试可观察行为；
  - 允许在没有 IDE 和真机的情况下验证业务逻辑。
- `UserSettingsManager.cj`
  - 作为应用层业务入口，不直接依赖 `kit.ArkData.*`；
  - 提供 `currentTheme`、`saveTheme`、`notificationEnabled`、`setNotificationEnabled`、`snapshot`、`clearAllSettings` 等方法；
  - 负责在合适时机调用 `flush()`，形成统一的持久化提交规则。
- `UserSettingsManagerTests.cj`
  - 使用 `FakeKeyValueStorage` 完成默认值、保存、读取、类型回退、重置、快照、清空等完整单测用例；
  - 当前即使没有真实 Preferences 文件，也可以验证核心业务语义。

## N. ArkTS 到仓颉 API 映射关系

### N.1 核心 API 映射表

| ArkTS 写法 | 仓颉写法 | 说明 |
|---|---|---|
| `import preferences from '@ohos.data.preferences'` | `import kit.ArkData.*` | ArkTS 模块导入改为仓颉 Kit 导入。 |
| `preferences.getPreferences(getContext(this), PREFERENCES_NAME)` | `Preferences.getPreferences(context, PreferencesOptions(storeName))` | 仓颉侧显式构造 `PreferencesOptions`，上下文建议由外部注入。 |
| `preferenceTheme.get('theme', 'default') as string` | `preferences.get("theme", PreferencesValueType.StringData("default"))` + `match` | ArkTS 的弱类型断言在仓颉中改为显式类型匹配。 |
| `preferenceTheme.put('theme', value)` | `preferences.put("theme", PreferencesValueType.StringData(value))` | 仓颉写入时必须包一层 `PreferencesValueType`。 |
| `preferenceTheme.flush()` | `preferences.flush()` | 两侧都要显式落盘，但仓颉里更适合通过接口层统一提交。 |
| `preferenceTheme.delete('theme')` | `preferences.delete("theme")` | 删除键后仍需根据业务决定是否再执行 `flush()`。 |
| `preferenceTheme.has('theme')` | `preferences.has("theme")` | 语义一致。 |

### N.2 从 ArkTS 生命周期到仓颉业务层的映射

| ArkTS 位置 | 本轮仓颉设计 | 原因 |
|---|---|---|
| `aboutToAppear` 中直接取 Preferences | 页面未来调用 `UserSettingsManager.currentTheme()` 或 `snapshot()` | 把存储细节从页面中抽离，页面只关心业务值。 |
| `changeTheme(value)` 中直接写 Preferences | `UserSettingsManager.saveTheme(theme)` | 保证写入逻辑、默认值和 `flush()` 规则集中在业务层。 |
| 页面里混合上下文获取、读写、UI 状态更新 | `HarmonyPreferencesStorage + UserSettingsManager + FakeKeyValueStorage` | 分层后更容易单测，也更适合大项目演进。 |

## O. 语法差异与架构决策

### O.1 弱类型断言与显式匹配

ArkTS 常见写法是：

```ts
let data = await preferenceTheme.get('theme', 'default') as string
```

仓颉不宜照搬为“直接假设它就是字符串”，而应改写为：

```cangjie
let value = preferences.get("theme", PreferencesValueType.StringData("default"))
match (value) {
    case PreferencesValueType.StringData(text) => text
    case _ => "default"
}
```

这带来两个直接收益：

1. 类型分支更清晰；
2. 一旦底层存了错误类型，业务层仍能稳定回退默认值。

### O.2 页面上下文获取方式差异

ArkTS 样本常在页面内部直接调用 `getContext(this)`。本轮仓颉设计没有把这种模式直接扩散到业务层，而是采用：

1. 页面或 Ability 持有 `UIAbilityContext`；
2. 通过 `HarmonyPreferencesStorage(context, storeName)` 构造真实存储；
3. 再把真实存储注入 `UserSettingsManager`；
4. 页面只依赖 `UserSettingsManager` 暴露的业务方法。

这样做的好处是：

- 页面层不直接依赖 ArkData；
- 单测时无需构造真实上下文；
- 后续若把 Preferences 换成别的实现，页面不需要改签名。

### O.3 `put` 与 `flush` 的职责边界

ArkTS 与仓颉都不是“调用 `put` 就已经永久持久化”。因此本轮特意保留：

- `put`：修改内存中的首选项实例；
- `flush`：把变更提交到持久化文件。

`UserSettingsManager` 统一负责在保存主题、修改通知开关、重置设置、清空设置时调用 `flush()`，避免页面或调用方忘记提交。

### O.4 为什么一定要引入 Fake Store

如果业务类直接依赖真实 `Preferences`：

- 当前云端环境无法执行；
- 单测必须依赖设备或 IDE 环境；
- 业务层和平台层耦合过深。

Fake Store 的价值在于：

1. 它让“保存、读取、默认值回退、删除、快照组合”这些业务语义可以离线验证；
2. 它允许我们统计 `flush` 次数，确保业务提交时机没有丢失；
3. 它为未来更复杂的 Telegram 设置中心提供统一测试模式。

## P. 单测骨架与验证策略

### P.1 当前已实现的用例

- `themeShouldFallbackToDefaultWhenUnset`
  - 验证主题在未写入时回退到 `default`。
- `saveThemeShouldWriteValueAndFlush`
  - 验证保存主题后既写入 Fake Store，也触发 `flush()`。
- `themeShouldFallbackWhenUnderlyingTypeIsWrong`
  - 验证底层类型错误时不会把异常状态传播到业务层。
- `notificationShouldFallbackToTrueWhenUnset`
  - 验证通知开关有稳定默认值。
- `setNotificationEnabledShouldPersistFalseAndFlush`
  - 验证布尔值写入与提交逻辑。
- `resetThemeShouldRemoveKeyAndRestoreDefault`
  - 验证删除主题后恢复默认值。
- `snapshotShouldCombineThemeAndNotificationState`
  - 验证聚合读取逻辑。
- `clearAllSettingsShouldRestoreDefaultsWithSingleFinalFlush`
  - 验证多键清理与统一提交时机。

### P.2 下一步可继续扩展的测试

- 引入 `HarmonyPreferencesStorage` 的集成测试，验证真实 Preferences 文件是否落盘；
- 新增 `Integer` 与 `Double` 类型设置项测试；
- 增加“多次覆盖写入”与“删除后再次保存”的回归用例；
- 在后续设置页中验证页面生命周期与 `UserSettingsManager.snapshot()` 的衔接。

## Q. 本轮结论

- Preferences 样本已经从“文档准备阶段”进入“可执行代码骨架阶段”；
- 当前实现建立了三层结构：
  1. 存储抽象层；
  2. Harmony 平台实现层；
  3. 应用层业务与 Fake Store 测试层；
- 这套结构已经足以支撑下一步继续补齐设置页 UI，或者直接扩展更多 Preferences 键值场景。

## R. 本轮新增 UI 与工程装配

### R.1 新增文件结构

```text
samples/data-persistence-001/
├── AppScope/app.json5
├── EntryAbility.cj
├── README.md
├── SettingsRuntime.cj
├── ThemeSettingsPage.cj
├── build-profile.json5
├── oh-package.json5
└── entry/
    ├── cjpm.toml
    └── src/main/
        ├── cangjie/
        │   ├── entryability/EntryAbility.cj
        │   ├── model/
        │   │   ├── FakeKeyValueStorage.cj
        │   │   ├── HarmonyPreferencesStorage.cj
        │   │   ├── SettingsRuntime.cj
        │   │   ├── StorageCore.cj
        │   │   └── UserSettingsManager.cj
        │   └── pages/ThemeSettingsPage.cj
        ├── module.json5
        └── resources/base/
            ├── element/string.json
            ├── media/icon.png
            └── profile/main_pages.json
```

### R.2 设置页设计说明

本轮新增的 `ThemeSettingsPage.cj` 不是简单把按钮堆到页面上，而是明确围绕“状态恢复闭环”来设计：

1. 页面在 `aboutToAppear()` 中执行 `attachManager()`；
2. `attachManager()` 优先尝试从 `SettingsRuntime` 获取由 `EntryAbility` 注入的真实 `UserSettingsManager`；
3. 若当前不在标准 Ability 环境中，则自动降级为 `FakeKeyValueStorage`，保证页面仍然能演示完整交互逻辑；
4. `syncFromManager()` 把业务状态同步给 `@State currentTheme` 与 `@State notificationEnabled`；
5. 用户点击主题按钮或切换通知开关后，页面调用 `UserSettingsManager`，再重新同步状态，保证 UI 与持久化值保持一致。

### R.3 EntryAbility 注入说明

本轮新增了 `SettingsRuntime.cj` 作为一个极轻量的运行时注册表。注入链路如下：

1. `EntryAbility.onCreate()` 中记录 `this.context`；
2. `EntryAbility.onWindowStageCreate()` 中调用 `bootstrapUserSettings(this.context)`；
3. `bootstrapUserSettings()` 内部创建真实 `HarmonyPreferencesStorage`；
4. 再创建 `UserSettingsManager(storage: storage)`；
5. 最后把业务管理器注册到全局运行时；
6. 页面在 `aboutToAppear()` 中读取这个已注入的业务管理器。

这个设计的优势在于：

- 页面不直接 new `Preferences`；
- 页面仍然只依赖业务层接口；
- 当未来把设置页扩展到更复杂的 Telegram 工程时，仍然可以保留同一套注入模式；
- 当注入失败时，页面还能自动切回 Fake Store，便于调试和演示。

### R.4 工程配置说明

本轮为持久化样本补齐了可独立导入的最小工程装配文件：

- `AppScope/app.json5`
  - 定义应用的 bundleName、版本、图标与应用级文案引用。
- `entry/src/main/module.json5`
  - 声明 `EntryAbility` 为主入口，并注册 `ThemeSettingsPage` 页面集合。
- `entry/src/main/resources/base/profile/main_pages.json`
  - 将 `pages/ThemeSettingsPage` 注册为页面入口。
- `entry/cjpm.toml`
  - 指向 `entry/src/main/cangjie` 作为仓颉源码目录。
- `oh-package.json5`
  - 提供工程级依赖和 IDE 同步信息。
- `build-profile.json5`
  - 继续沿用双 product 位策略，同时避免在当前环境伪造本地签名信息。

### R.5 与前一阶段代码骨架的衔接关系

- 上一阶段完成了 `StorageCore`、`HarmonyPreferencesStorage`、`FakeKeyValueStorage` 与 `UserSettingsManager`；
- 本轮完成了：
  - UI 页面；
  - Ability 注入；
  - 独立工程配置；
  - README 导入说明；
- 至此，这个持久化样本已经形成了：
  1. 业务层；
  2. 平台持久化层；
  3. Fake 测试层；
  4. UI 页面层；
  5. Ability 注入层；
  6. IDE 导入工程层。

## 附录：手动验证 Checklist

以下清单用于在拿到 DevEco Studio + 仓颉插件 + 可用 SDK 后，人工验证 Preferences 持久化样本的闭环是否成立。

### A. 工程导入与同步

- [ ] 通过 `File -> Open` 打开 `samples/data-persistence-001/` 后，IDE 能识别工程根目录。
- [ ] `AppScope/app.json5`、`build-profile.json5`、`oh-package.json5`、`entry/src/main/module.json5`、`entry/cjpm.toml` 均能被 IDE 正常解析。
- [ ] 首次导入后若出现 `Sync Now`、`Update`、`Use IDE Recommended Version` 等提示，点击后能够完成同步。
- [ ] 若 IDE 自动生成 `oh-package-lock.json5`、`.hvigor/`、`hvigor/`、`local.properties` 等文件，生成过程无阻塞性错误。
- [ ] 若需要签名，能在 `Signing Configs` 中完成自动签名或本地签名配置。

### B. Ability 注入与页面启动

- [ ] 应用启动后，`EntryAbility` 能正常执行 `onCreate` 与 `onWindowStageCreate`。
- [ ] `EntryAbility` 在 `onWindowStageCreate` 中成功执行 `bootstrapUserSettings(this.context)`。
- [ ] 首页能够正确加载 `ThemeSettingsPage`。
- [ ] 页面首次进入时不会白屏或崩溃。
- [ ] 页面状态文案能够显示“已接入 EntryAbility 注入的真实 Preferences 存储”或等价信息。

### C. 默认值恢复

- [ ] 首次安装或首次运行时，页面默认主题显示为 `default`。
- [ ] 首次安装或首次运行时，通知开关默认为开启。
- [ ] 状态摘要区显示的主题与通知开关状态正确。
- [ ] 点击“重新同步状态”后，页面仍然维持正确默认值。

### D. 主题切换持久化

- [ ] 点击 `切换到 simplicity` 后，页面当前主题更新为 `simplicity`。
- [ ] 点击 `切换到 pomeloWhtie` 后，页面当前主题更新为 `pomeloWhtie`。
- [ ] 每次切换主题后，状态文案能提示主题已持久化。
- [ ] 退出应用并重新打开后，页面能恢复到上次保存的主题。

### E. 通知开关持久化

- [ ] 切换通知开关到关闭后，摘要区显示为“通知开关：关闭”。
- [ ] 切换通知开关到开启后，摘要区显示为“通知开关：开启”。
- [ ] 每次切换通知开关后，状态文案能提示通知开关已持久化。
- [ ] 退出应用并重新打开后，通知开关状态能够恢复到上次保存值。

### F. 恢复默认设置

- [ ] 点击“恢复默认设置”后，主题恢复为 `default`。
- [ ] 点击“恢复默认设置”后，通知开关恢复为开启。
- [ ] 恢复默认设置后，状态文案提示所有设置已恢复默认值。
- [ ] 恢复默认设置后退出并重新进入，页面仍然保持默认值。

### G. 日志与稳定性

- [ ] 日志中可看到 `EntryAbility onCreate`、`EntryAbility onWindowStageCreate`、`EntryAbility onForeground` 等生命周期输出。
- [ ] 日志中可看到 `SettingsRuntime` 完成 `UserSettingsManager` 注入的输出。
- [ ] 日志中可看到 `PrefsStore` 的读取、写入与 `flush` 输出。
- [ ] 连续执行“切换主题 -> 切换通知开关 -> 恢复默认设置 -> 重启应用”后，应用保持稳定。

### H. 完成判定

- [ ] 若以上条目全部勾选完成，可判定持久化样本已经完成“人工验证闭环”。
- [ ] 若存在失败项，应将失败现象、触发步骤、日志与截图回写到本样本记录与执行轨迹中。
