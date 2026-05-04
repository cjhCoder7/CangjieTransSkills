import kit.AbilityKit.*
import kit.PerformanceAnalysisKit.Hilog

var globalAbilityContext: Option<UIAbilityContext> = Option<UIAbilityContext>.None
var globalUserSettingsManager: Option<UserSettingsManager> = Option<UserSettingsManager>.None

func registerAbilityContext(context: UIAbilityContext): Unit {
    globalAbilityContext = Option<UIAbilityContext>.Some(context)
    Hilog.info(0, "SettingsRuntime", "UIAbilityContext 已注册")
}

func bootstrapUserSettings(context: UIAbilityContext): Unit {
    registerAbilityContext(context)
    let storage = createUserSettingsStorage(context)
    globalUserSettingsManager = Option<UserSettingsManager>.Some(UserSettingsManager(storage: storage))
    Hilog.info(0, "SettingsRuntime", "UserSettingsManager 已使用真实 Preferences 完成注入")
}

func tryResolveUserSettingsManager(): Option<UserSettingsManager> {
    globalUserSettingsManager
}

func hasInjectedUserSettingsManager(): Bool {
    match (globalUserSettingsManager) {
        case Some(_) => true
        case _ => false
    }
}
