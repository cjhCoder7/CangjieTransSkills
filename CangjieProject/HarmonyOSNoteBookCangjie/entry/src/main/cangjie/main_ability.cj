package ohos_app_cangjie_entry

import kit.PerformanceAnalysisKit.Hilog
import kit.AbilityKit.Want
import kit.AbilityKit.UIAbility
import kit.AbilityKit.LaunchParam
import kit.AbilityKit.LaunchReason
import kit.ArkUI.WindowStage

class MainAbility <: UIAbility {
    public init() {
        super()
        registerSelf()
    }

    public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
        Hilog.info(1, "Cangjie", "MainAbility OnCreated.${want.abilityName}")
        match (launchParam.launchReason) {
            case LaunchReason.StartAbility => Hilog.info(1, "Cangjie", "START_ABILITY")
            case _ => ()
        }
    }

    public override func onDestroy(): Unit {
        Hilog.info(1, "Cangjie", "MainAbility onDestroy")
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        Hilog.info(1, "Cangjie", "MainAbility onWindowStageCreate.")
        windowStage.loadContent("EntryView")
    }

    public override func onWindowStageDestroy(): Unit {
        Hilog.info(1, "Cangjie", "MainAbility onWindowStageDestroy")
    }

    public override func onForeground(): Unit {
        Hilog.info(1, "Cangjie", "MainAbility onForeground")
    }

    public override func onBackground(): Unit {
        Hilog.info(1, "Cangjie", "MainAbility onBackground")
    }
}
