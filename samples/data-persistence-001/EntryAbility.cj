import kit.AbilityKit.{UIAbility, Want, LaunchParam}
import kit.ArkUI.WindowStage
import kit.PerformanceAnalysisKit.Hilog

func logPersistenceAbility(message: String): Unit {
    Hilog.info(0, "PersistenceSample", message)
}

class EntryAbility <: UIAbility {
    public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
        logPersistenceAbility("EntryAbility onCreate")
        registerAbilityContext(this.context)
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        logPersistenceAbility("EntryAbility onWindowStageCreate")
        bootstrapUserSettings(this.context)
        windowStage.loadContent("ThemeSettingsPage")
    }

    public override func onForeground(): Unit {
        logPersistenceAbility("EntryAbility onForeground")
    }

    public override func onBackground(): Unit {
        logPersistenceAbility("EntryAbility onBackground")
    }

    public override func onDestroy(): Unit {
        logPersistenceAbility("EntryAbility onDestroy")
    }
}
