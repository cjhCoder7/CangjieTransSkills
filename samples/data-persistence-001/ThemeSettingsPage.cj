import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*

@Entry
@Component
class ThemeSettingsPage {
    var manager: Option<UserSettingsManager> = Option<UserSettingsManager>.None

    @State
    var currentTheme: String = "default"

    @State
    var notificationEnabled: Bool = true

    @State
    var statusMessage: String = "等待 EntryAbility 注入真实 Preferences 存储"

    let availableThemes = ArrayList<String>([
        "default",
        "simplicity",
        "pomeloWhtie"
    ])

    func attachManager(): Unit {
        match (tryResolveUserSettingsManager()) {
            case Some(existingManager) =>
                this.manager = Option<UserSettingsManager>.Some(existingManager)
                this.statusMessage = "已接入 EntryAbility 注入的真实 Preferences 存储"
            case _ =>
                let fallbackManager = UserSettingsManager(storage: FakeKeyValueStorage())
                this.manager = Option<UserSettingsManager>.Some(fallbackManager)
                this.statusMessage = "未检测到 EntryAbility 注入，当前降级为内存 Fake Store"
        }
    }

    func syncFromManager(): Unit {
        match (this.manager) {
            case Some(settingsManager) =>
                let snapshot = settingsManager.snapshot()
                this.currentTheme = snapshot.theme
                this.notificationEnabled = snapshot.notificationEnabled
            case _ =>
                this.currentTheme = "default"
                this.notificationEnabled = true
        }
    }

    func themeButtonLabel(theme: String): String {
        if (theme == this.currentTheme) {
            return "当前主题：${theme}"
        }
        return "切换到 ${theme}"
    }

    func notificationSummary(): String {
        if (this.notificationEnabled) {
            return "通知开关：开启"
        }
        return "通知开关：关闭"
    }

    func withManagerLoaded(actionName: String): Bool {
        match (this.manager) {
            case Some(_) => true
            case _ =>
                this.statusMessage = "${actionName} 失败：UserSettingsManager 尚未完成初始化"
                false
        }
    }

    func onThemeSelected(theme: String): Unit {
        if (!this.withManagerLoaded("主题切换")) {
            return
        }
        match (this.manager) {
            case Some(settingsManager) =>
                this.currentTheme = theme
                settingsManager.saveTheme(theme)
                this.syncFromManager()
                this.statusMessage = "主题已持久化为 ${this.currentTheme}"
            case _ => ()
        }
    }

    func onNotificationChanged(isOn: Bool): Unit {
        if (!this.withManagerLoaded("通知开关切换")) {
            return
        }
        match (this.manager) {
            case Some(settingsManager) =>
                this.notificationEnabled = isOn
                settingsManager.setNotificationEnabled(isOn)
                this.syncFromManager()
                this.statusMessage = "通知开关已持久化为 ${this.notificationSummary()}"
            case _ => ()
        }
    }

    func resetAllSettings(): Unit {
        if (!this.withManagerLoaded("恢复默认设置")) {
            return
        }
        match (this.manager) {
            case Some(settingsManager) =>
                settingsManager.clearAllSettings()
                this.syncFromManager()
                this.statusMessage = "所有设置已恢复默认值"
            case _ => ()
        }
    }

    protected override func aboutToAppear(): Unit {
        this.attachManager()
        this.syncFromManager()
    }

    protected override func onPageShow(): Unit {
        this.attachManager()
        this.syncFromManager()
    }

    func buildHeader(): Unit {
        Column {
            Text("Theme Settings")
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .margin(bottom: 8.vp)
            Text("Preferences 持久化样本：主题与通知开关")
                .fontSize(16)
        }
        .width(100.percent)
        .padding(top: 16.vp, bottom: 12.vp, left: 16.vp, right: 16.vp)
    }

    func buildStatusCard(): Unit {
        Column {
            Text("当前主题：${this.currentTheme}")
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin(bottom: 8.vp)
            Text(this.notificationSummary())
                .margin(bottom: 8.vp)
            Text(this.statusMessage)
                .fontSize(14)
        }
        .width(100.percent)
        .padding(16.vp)
    }

    func buildThemeSelector(): Unit {
        Column {
            Text("主题切换")
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .margin(bottom: 10.vp)
            Scroll {
                Row {
                    for (theme in this.availableThemes) {
                        Button(this.themeButtonLabel(theme))
                            .margin(right: 8.vp, bottom: 8.vp)
                            .onClick({evt => this.onThemeSelected(theme)})
                    }
                }
            }
        }
        .width(100.percent)
        .padding(left: 16.vp, right: 16.vp, bottom: 16.vp)
    }

    func buildNotificationSection(): Unit {
        Column {
            Text("通知开关")
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .margin(bottom: 10.vp)
            Row {
                Text(this.notificationSummary())
                    .margin(right: 16.vp)
                Toggle(ToggleType.Switch, isOn: this.notificationEnabled)
                    .onChange({
                        isOn => this.onNotificationChanged(isOn)
                    })
            }
        }
        .width(100.percent)
        .padding(left: 16.vp, right: 16.vp, bottom: 16.vp)
    }

    func buildActions(): Unit {
        Row {
            Button("恢复默认设置")
                .margin(right: 12.vp)
                .onClick({evt => this.resetAllSettings()})
            Button("重新同步状态")
                .onClick({evt =>
                    this.attachManager()
                    this.syncFromManager()
                    this.statusMessage = "已从 Manager 重新同步当前状态"
                })
        }
        .width(100.percent)
        .padding(left: 16.vp, right: 16.vp, bottom: 24.vp)
    }

    func build() {
        Scroll {
            Column {
                this.buildHeader()
                this.buildStatusCard()
                this.buildThemeSelector()
                this.buildNotificationSection()
                this.buildActions()
            }
            .width(100.percent)
        }
        .width(100.percent)
        .height(100.percent)
    }
}
