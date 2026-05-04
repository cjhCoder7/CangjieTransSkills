# Preferences 持久化样本 README

## 项目目标

本样本用于演示：

1. 如何在仓颉工程中使用真实 `Preferences` 存储用户设置；
2. 如何通过 `EntryAbility` 获取 `UIAbilityContext`；
3. 如何把真实的 `HarmonyPreferencesStorage` 注入到 `UserSettingsManager`；
4. 如何在设置页 `ThemeSettingsPage` 中读取并更新主题与通知开关；
5. 如何在无 IDE / 真机环境时，继续通过 `FakeKeyValueStorage` 保持测试能力。

## 项目结构说明

```text
samples/data-persistence-001/
├── AppScope/app.json5
├── EntryAbility.cj
├── FakeKeyValueStorage.cj
├── HarmonyPreferencesStorage.cj
├── README.md
├── SettingsRuntime.cj
├── StorageCore.cj
├── ThemeSettingsPage.cj
├── UserSettingsManager.cj
├── UserSettingsManagerTests.cj
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

## 真实 Context 注入链路

本样本最关键的装配动作如下：

1. `EntryAbility.onCreate()` 中先记录 `this.context`；
2. `EntryAbility.onWindowStageCreate()` 中调用 `bootstrapUserSettings(this.context)`；
3. `bootstrapUserSettings()` 内部执行：
   - `createUserSettingsStorage(context)` 创建真实 `HarmonyPreferencesStorage`；
   - `UserSettingsManager(storage: storage)` 创建业务管理器；
   - 将管理器注册到 `SettingsRuntime` 全局运行时；
4. `ThemeSettingsPage.aboutToAppear()` 中通过 `tryResolveUserSettingsManager()` 读取已注入的 Manager；
5. 页面把读取到的主题和通知开关同步给 `@State`，再由 ArkUI 自动刷新界面。

## EntryAbility 中的关键注入代码

```cangjie
class EntryAbility <: UIAbility {
    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        bootstrapUserSettings(this.context)
        windowStage.loadContent("ThemeSettingsPage")
    }
}
```

## 设置页中的关键初始化逻辑

```cangjie
protected override func aboutToAppear(): Unit {
    this.attachManager()
    this.syncFromManager()
}
```

其中：

- `attachManager()` 负责获取已注入的真实 `UserSettingsManager`；
- 如果当前不是在标准 Ability 环境中运行，则自动降级为 `FakeKeyValueStorage`；
- `syncFromManager()` 负责把业务状态同步到 `@State currentTheme` 与 `@State notificationEnabled`。

## DevEco Studio 导入指南

### 前置条件

1. 已安装 **DevEco Studio**；
2. 已安装 **仓颉插件**；
3. 已安装可用的 HarmonyOS NEXT 或 OpenHarmony SDK；
4. 若需要真机运行，已准备可用签名配置。

### 导入步骤

1. 启动 DevEco Studio；
2. 选择 `File -> Open`；
3. 打开目录 `samples/data-persistence-001/`；
4. 等待 IDE 识别 `AppScope/app.json5`、`build-profile.json5`、`oh-package.json5`、`entry/src/main/module.json5`、`entry/cjpm.toml`；
5. 如出现 `Sync Now`、`Update` 或 `Use IDE Recommended Version` 提示，直接点击接受 IDE 自动修复；
6. 如出现签名提示，进入 `File -> Project Structure -> Project -> Signing Configs` 完成自动签名或本地签名配置。

## 若导入后出现同步问题

### Hvigor 或依赖同步失败

1. 优先点击 IDE 顶部的 `Sync Now`；
2. 若继续提示版本升级，点击 `Update` 或 `Use IDE Recommended Version`；
3. 若提示缺少 `oh-package-lock.json5`，使用 IDE 的同步或依赖安装按钮自动生成；
4. 若提示 SDK 版本不匹配，以本地 SDK 为准更新 `build-profile.json5`，再重新同步。

### 运行时检查顺序

1. 先确认 `EntryAbility` 能被 IDE 正确识别；
2. 再确认 `ThemeSettingsPage` 已在 `main_pages.json` 注册；
3. 再确认设置页能显示默认主题和默认通知状态；
4. 然后验证切换主题、切换通知开关、退出应用、重新打开后的恢复效果。

## 当前样本边界

- 当前样本已经包含：
  - UI 页面；
  - EntryAbility 注入逻辑；
  - 工程级配置；
  - 真实 Preferences 实现；
  - Fake Store 单测骨架。
- 当前样本尚未包含：
  - `hvigorfile.ts`；
  - `oh-package-lock.json5`；
  - `.hvigor/`；
  - `local.properties`；
  - 这些更适合在真实 DevEco Studio 环境中由 IDE 自动生成。

## 推荐下一步

1. 在 IDE 中完成首次导入与同步；
2. 运行设置页，验证主题与通知开关的持久化；
3. 若成功，再继续把同一套 `UserSettingsManager` 注入更复杂的设置中心页面。
