# Preferences 用户首选项到仓颉的映射

## Skill ID
data-persistence-preferences

## Skill Name
用户首选项持久化映射

## Scope
- domain: data-persistence
- source_language: ArkTS
- target_language: Cangjie
- platform: HarmonyOS NEXT
- priority: P0
- applies_to:
  - 用户主题、通知开关、显示模式、字体大小等轻量偏好设置
  - ArkTS 中使用 `@ohos.data.preferences` 的页面、服务或设置模块
  - 需要从 ArkTS 迁移到仓颉并保留默认值、显式落盘与状态恢复的场景
  - 需要通过接口抽象和 Fake Store 保证单测可执行性的场景
- not_applies_to:
  - 关系型数据库建表、事务、联表查询、复杂检索
  - 大体量业务数据存储
  - 以文件系统为核心的读写场景

## Trigger Condition
- must_trigger_when:
  - 源代码中出现 `@ohos.data.preferences`
  - 源代码中出现 `getPreferences`、`get(`、`put(`、`flush(`、`delete(`
  - 页面需求包含“应用重启后恢复用户设置”
  - 任务要求把持久化逻辑做成可注入、可测试的仓颉实现
- should_trigger_when:
  - 任务要求增加 Fake Store、Mock Store 或离线单测能力
  - 需要把 ArkTS 的 `as string` 弱类型读取改成显式类型分支
  - 需要把页面、业务层和平台存储解耦
- must_not_trigger_when:
  - 任务核心是 `RelationalStore` 或 SQL
  - 任务只涉及日志、网络或纯 UI 布局
  - 任务需要的是文件上传、下载或媒体缓存，而不是首选项存储
- related_keywords:
  - Preferences
  - KeyValue
  - theme
  - notification
  - flush
  - default value
  - Fake Store
  - dependency injection
- related_files:
  - `samples/data-persistence-001/StorageCore.cj`
  - `samples/data-persistence-001/HarmonyPreferencesStorage.cj`
  - `samples/data-persistence-001/FakeKeyValueStorage.cj`
  - `samples/data-persistence-001/UserSettingsManager.cj`
  - `samples/data-persistence-001/UserSettingsManagerTests.cj`
  - `docs/samples/data-persistence-001.md`
- common_error_signals:
  - 写入设置后重新打开应用无法恢复
  - 代码执行了 `put` 但没有执行 `flush`
  - 业务层直接依赖 `Preferences` 导致无法单测
  - 读取时使用错误类型，结果变成空值或异常状态
  - 页面内散落多处存储读写逻辑，后续难以维护

## Core Concept
- one_sentence_summary: Preferences 迁移的关键不是逐字复制 ArkTS API，而是沉淀一套“强类型值对象 + 通用存储接口 + 真实实现 + Fake Store + 业务管理器”的稳定架构。
- key_facts:
  - ArkTS 的 `get('theme', 'default') as string` 在仓颉中应转换为显式类型匹配
  - `put()` 与 `flush()` 必须分开理解，不能把缓存写入误判为持久化完成
  - 页面不应直接依赖 `kit.ArkData.*`，应优先依赖业务管理器
  - Fake Store 的目标不是占位，而是提供完整、可观察的测试替身
- critical_constraints:
  - 必须保留默认值回退逻辑
  - 必须保留显式 `flush()` 的提交语义
  - 必须把平台实现和业务逻辑解耦
  - 若当前没有 IDE 环境，不得声称已完成真实持久化验证
- mental_model: 先把 Preferences 看成“一个可落盘的键值仓库”，再把页面逻辑拆成“业务读取 / 业务写入 / 平台适配 / Fake 测试替身”四层。

## Progressive Modules
### Module 0 - Minimum
- purpose: 在最少上下文中快速落地可测试的 Preferences 迁移骨架。
- content:
  - 定义 `StorageValue`
  - 定义 `KeyValueStorage`
  - 保留 `flush()`
  - 把 `theme` 等设置键从页面里提出来
- first_action:
  - 先找出键名、默认值和恢复时机
  - 再决定业务层方法名和测试入口

### Module 1 - Basic Mapping
- purpose: 完成 ArkTS Preferences API 到仓颉的直接映射。
- content:
  - `preferences.getPreferences(getContext(this), name)` -> `Preferences.getPreferences(context, PreferencesOptions(name))`
  - `get('theme', 'default') as string` -> `get("theme", PreferencesValueType.StringData("default"))` + `match`
  - `put('theme', value)` -> `put("theme", PreferencesValueType.StringData(value))`
  - `delete('theme')` -> `delete("theme")`
  - `flush()` -> `flush()`

### Module 2 - Architecture / Business
- purpose: 建立可扩展的工程结构，而不是让页面直接操作 Preferences。
- content:
  - 真实平台层使用 `HarmonyPreferencesStorage`
  - 业务层使用 `UserSettingsManager`
  - 页面层只依赖 `UserSettingsManager.currentTheme()`、`saveTheme()` 等业务方法
  - Fake 测试层使用 `FakeKeyValueStorage`

### Module 3 - Test / Evolution
- purpose: 把离线测试和后续演进空间一起纳入 Skill。
- content:
  - 用 Fake Store 验证默认值、保存、读取、删除、快照与清空逻辑
  - 用 `flushCount()` 检查提交时机
  - 后续可逐步扩展 `Integer`、`Double`、更多设置键和真实设置页 UI

## Translation Mapping
- syntax_mapping:
  - `let data = await preferenceTheme.get('theme', 'default') as string` -> `let raw = storage.get("theme", StorageValue.StringValue("default"))`
  - `await preferenceTheme.put('theme', value)` -> `storage.put("theme", StorageValue.StringValue(value))`
  - `await preferenceTheme.flush()` -> `storage.flush()`
- component_mapping:
  - ArkTS 页面生命周期读取 -> 页面调用 `UserSettingsManager.snapshot()` 或 `currentTheme()`
  - ArkTS 主题切换按钮 -> 页面调用 `UserSettingsManager.saveTheme(theme)`
  - ArkTS 通知开关 -> 页面调用 `UserSettingsManager.setNotificationEnabled(enabled)`
- state_mapping:
  - `theme` -> `StorageValue.StringValue`
  - `notificationEnabled` -> `StorageValue.BoolValue`
  - 聚合设置状态 -> `UserSettingsSnapshot`
- routing_mapping:
  - 本 Skill 不直接负责路由，但常与设置页生命周期恢复联动
- api_mapping:
  - ArkTS `@ohos.data.preferences` -> 仓颉 `kit.ArkData.*`
  - ArkTS `getContext(this)` -> 由 Ability 或页面外部传入 `UIAbilityContext`
  - ArkTS `preferences.Preferences` -> 仓颉 `Preferences`
  - ArkTS 默认值断言 -> 仓颉 `StorageValue` + `readStringValue` / `readBoolValue`
- fallback_mapping:
  - 无法获取真实 `UIAbilityContext` 时，先用 `FakeKeyValueStorage` 跑通业务测试
  - 无法确认页面层时，先稳定 `UserSettingsManager` 的接口和测试
- anti_patterns:
  - 不要让页面直接散落 `Preferences.getPreferences`
  - 不要省略 `flush()`
  - 不要把 ArkTS 的 `as string` 原样迁移为不加校验的读取
  - 不要在没有 Fake Store 的情况下把业务逻辑和平台实现绑死

## Examples
### Positive Example
- source_snippet:

```arkts
import preferences from '@ohos.data.preferences'

let preferenceTheme: preferences.Preferences = null

async getPreference() {
  let data = 'default'
  if (preferenceTheme !== null) {
    data = await preferenceTheme.get('theme', 'default') as string
  }
  return data
}

async putPreference(value: string) {
  if (preferenceTheme !== null) {
    await preferenceTheme.put('theme', value)
    await preferenceTheme.flush()
  }
}
```

- target_snippet:

```cangjie
enum StorageValue {
    | StringValue(String)
    | BoolValue(Bool)
    | IntValue(Int64)
    | DoubleValue(Float64)
}

interface KeyValueStorage {
    func has(key: String): Bool
    func get(key: String, defaultValue: StorageValue): StorageValue
    func put(key: String, value: StorageValue): Unit
    func remove(key: String): Unit
    func flush(): Unit
}

func readStringValue(value: StorageValue, fallback: String): String {
    match (value) {
        case StorageValue.StringValue(text) => text
        case _ => fallback
    }
}

class UserSettingsManager {
    private let storage: KeyValueStorage
    private let themeKey: String
    private let defaultThemeValue: String

    public init(storage: KeyValueStorage) {
        this.storage = storage
        this.themeKey = "theme"
        this.defaultThemeValue = "default"
    }

    public func currentTheme(): String {
        let value = this.storage.get(this.themeKey, StorageValue.StringValue(this.defaultThemeValue))
        readStringValue(value, this.defaultThemeValue)
    }

    public func saveTheme(theme: String): Unit {
        this.storage.put(this.themeKey, StorageValue.StringValue(theme))
        this.storage.flush()
    }
}
```

- why_this_mapping: 这里保留了 ArkTS 原本的默认值与显式落盘语义，同时把存储读写从页面中抽离到了业务层和接口层。

### Negative Example
- source_snippet:

```arkts
await preferenceTheme.put('theme', value)
await preferenceTheme.flush()
```

- target_snippet:

```cangjie
class UserSettingsManager {
    public func saveTheme(theme: String): Unit {
        Preferences.getPreferences(this.context, PreferencesOptions("user-settings.db"))
            .put("theme", theme)
    }
}
```

- why_it_fails: 这段错误翻译同时犯了三个问题：业务层直接依赖平台实现、`put` 没有使用 `PreferencesValueType.StringData`、而且完全遗漏了 `flush()`。

### Edge Case Example
- source_snippet:

```arkts
let data = await preferenceTheme.get('theme', 'default') as string
```

- target_snippet:

```cangjie
let raw = storage.get("theme", StorageValue.StringValue("default"))
let theme = readStringValue(raw, "default")
```

- special_note: 当底层值类型错误或键不存在时，业务层仍能稳定回退到默认值，而不会暴露脆弱的类型假设。

## Retrieval Fallback
- fallback_when:
  - 需要确认 `PreferencesValueType` 的完整枚举分支
  - 需要确认 `UIAbilityContext` 的最佳注入位置
  - 需要把当前 Skill 从字符串 / 布尔值扩展到更多类型
  - 需要定位官方样本中真实的 `theme.db` 使用方式
- priority_sources:
  - OpenHarmony ArkTS Preferences 文档
  - OpenHarmony 仓颉 Preferences 文档
  - 官方样本 `Preferences/entry/src/main/ets/pages/Index.ets`
  - 本项目 `samples/data-persistence-001/` 下的代码骨架
- query_templates:
  - `Preferences getPreferences flush StringData BoolData`
  - `Index.ets theme.db preferences aboutToAppear`
  - `UIAbilityContext PreferencesOptions Cangjie`
  - `Fake Store dependency injection preferences`
- python_script_examples:
  - |
    ```bash
    python - <<'PY'
    import requests
    url = "https://raw.githubusercontent.com/openharmony/applications_app_samples/master/code/BasicFeature/DataManagement/Preferences/entry/src/main/ets/pages/Index.ets"
    text = requests.get(url, timeout=20).text
    for index, line in enumerate(text.splitlines(), 1):
        if "preferences" in line or "theme" in line or "flush(" in line:
            print(f"{index}: {line}")
    PY
    ```
  - |
    ```bash
    python - <<'PY'
    from pathlib import Path
    path = Path("/tmp/docs_cangjie_inspect/zh-cn/application-dev/reference/ArkData/cj-apis-preferences.md")
    for index, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if "PreferencesValueType" in line or "getPreferences" in line or "flush()" in line:
            print(f"{index}: {line}")
    PY
    ```
- cli_examples:
  - `curl -L https://raw.githubusercontent.com/openharmony/applications_app_samples/master/code/BasicFeature/DataManagement/Preferences/entry/src/main/ets/pages/Index.ets | rg -n "preferences|getPreferences|get\(|put\(|flush\(|theme"`
  - `rg -n "Preferences|getPreferences|put\(|get\(|flush\(|delete\(|PreferencesValueType" /tmp/docs_cangjie_inspect/zh-cn/application-dev/database/cj-data-persistence-by-preferences.md /tmp/docs_cangjie_inspect/zh-cn/application-dev/reference/ArkData/cj-apis-preferences.md`
  - `rg -n "KeyValueStorage|FakeKeyValueStorage|UserSettingsManager|StorageValue" samples/data-persistence-001`
- result_recording_rule:
  - 回写时必须记录：默认值是什么、提交时机在哪里、业务层是否已经与平台层解耦、Fake Store 能否覆盖关键场景。

## Test & Debug
- unit_test_strategy:
  - 先写 `KeyValueStorage` 接口
  - 再写 `FakeKeyValueStorage`
  - 用 `UserSettingsManager` 作为业务层入口
  - 覆盖默认值、保存、读取、删除、类型错误回退、快照、清空、`flush` 次数
- compile_check:
  - 当前若无 DevEco Studio 与仓颉插件，只能验证代码结构、命名与测试设计，不声称已完成真实构建
- runtime_check:
  - 在具备 IDE 的环境中，把 `HarmonyPreferencesStorage` 注入设置页，执行“保存主题 -> 退出应用 -> 重启应用 -> 恢复设置”验证
- common_failures:
  - 业务层直接 new `Preferences` 导致无法单测
  - `put` 使用了裸字符串或裸布尔值
  - 少调一次 `flush()` 导致设备重进后状态丢失
  - Fake Store 只存值不记录提交行为，导致测试无法检查提交时机
- debug_steps:
  - 先检查键名和默认值
  - 再检查 `StorageValue` 到 `PreferencesValueType` 的映射
  - 再检查 `UserSettingsManager` 是否统一负责 `flush()`
  - 最后检查 Fake Store 测试是否覆盖“未设置、已设置、已清空”三种路径
- when_to_update_skill:
  - 当新增更多设置键类型时
  - 当真实设置页落地并形成稳定注入模式时
  - 当进入 `RDB` 或更复杂数据存储样本时

## Sources
- official_docs:
  - name: OpenHarmony ArkTS 用户首选项文档
    url: https://gitee.com/openharmony/docs/raw/master/zh-cn/application-dev/database/data-persistence-by-preferences.md
    accessed_at: 2026-03-26
    version: docs master
  - name: OpenHarmony 仓颉 Preferences API 文档
    url: https://gitcode.com/openharmony/docs_cangjie
    accessed_at: 2026-03-26
    version: docs_cangjie
- sample_projects:
  - name: OpenHarmony Preferences 官方样本 README
    path_or_url: https://raw.githubusercontent.com/openharmony/applications_app_samples/master/code/BasicFeature/DataManagement/Preferences/README_zh.md
    accessed_at: 2026-03-26
    version_or_commit: master
  - name: OpenHarmony Preferences 官方样本源码
    path_or_url: https://raw.githubusercontent.com/openharmony/applications_app_samples/master/code/BasicFeature/DataManagement/Preferences/entry/src/main/ets/pages/Index.ets
    accessed_at: 2026-03-26
    version_or_commit: master
- target_repositories:
  - name: 本地持久化样本代码骨架
    path_or_url: samples/data-persistence-001
    accessed_at: 2026-03-26
    version_or_commit: workspace-current
- internal_records:
  - path: docs/samples/data-persistence-001.md
    note: 持久化样本记录，包含 API 映射、语法差异与测试策略
  - path: docs/traces/trace-data-persistence-001.md
    note: 本轮从样本准备推进到代码骨架的执行轨迹

## Version Notes
- sdk_version: 待后续通过 DevEco Studio 自动适配确认
- api_version: 当前以 OpenHarmony Preferences 文档和本地 docs_cangjie 参考为准
- toolchain_version: 当前环境未安装 DevEco Studio 与仓颉插件
- compatibility_note: 当前 Skill 已支持“接口抽象 + Fake Store + 业务层 + 真实实现”的持久化迁移模式

## Known Gaps
- 真实 `HarmonyPreferencesStorage` 尚未在 IDE 中完成编译验证
- 当前代码骨架优先覆盖 `String / Bool / Int64 / Float64`，尚未涉及数组类型
- 当前尚未把 `UserSettingsManager` 接进真实 ArkUI 设置页

## Evolution Log
- [2026-03-26] [Codex] 创建首版 `data-persistence-preferences` Skill，确立 Preferences 作为第二个小样本的迁移方向。[原因：它最适合先建立轻量持久化闭环]
- [2026-03-26] [Codex] 将 Skill 升级为“接口抽象 + Harmony 实现 + Fake Store + 业务管理器 + 单测骨架”的标准方案。[原因：需要支持无 IDE 环境下的离线验证与未来大工程扩展]
- [2026-03-26] [Codex] 补充 `EntryAbility -> SettingsRuntime -> ThemeSettingsPage` 的 UI 注入模式与独立工程装配建议。[原因：让持久化样本从业务骨架进化为可导入的页面闭环样本]


## UI Integration Pattern
- entry_ability_bootstrap:
  - 在 `EntryAbility.onWindowStageCreate()` 中调用 `bootstrapUserSettings(this.context)`
  - 由 Ability 负责创建真实 `HarmonyPreferencesStorage` 并注入 `UserSettingsManager`
  - 再执行 `windowStage.loadContent("ThemeSettingsPage")`
- runtime_bridge:
  - 使用 `SettingsRuntime` 作为极轻量的运行时注册表
  - 页面只从运行时读取业务管理器，不直接依赖 `UIAbilityContext`
- page_lifecycle_pattern:
  - `ThemeSettingsPage.aboutToAppear()` 中执行 `attachManager()` 和 `syncFromManager()`
  - `onPageShow()` 中再次同步，确保页面回到前台后状态仍与持久化层一致
- fallback_rule:
  - 当运行时未完成真实注入时，页面允许降级到 `FakeKeyValueStorage`
  - 这种降级只用于开发、演示和无 IDE 场景，不可当作真实持久化成功
- recommended_files:
  - `samples/data-persistence-001/SettingsRuntime.cj`
  - `samples/data-persistence-001/ThemeSettingsPage.cj`
  - `samples/data-persistence-001/EntryAbility.cj`
