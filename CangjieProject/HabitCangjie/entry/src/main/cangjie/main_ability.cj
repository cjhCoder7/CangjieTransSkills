package ohos_app_cangjie_entry

import kit.PerformanceAnalysisKit.Hilog
import kit.AbilityKit.Want
import kit.AbilityKit.UIAbility
import kit.AbilityKit.LaunchParam
import kit.AbilityKit.LaunchReason
import kit.ArkUI.WindowStage
import ohos_app_cangjie_entry.controllers
import ohos_app_cangjie_entry.controllers.AppStorageHolder

class MainAbility <: UIAbility {
    public init() {
        super()
        registerSelf()
    }

    public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
        Hilog.info(1, "Habit", "MainAbility OnCreated.${want.abilityName}")
        // 初始化数据库
        AppStorageHolder.dataController.initDatabase(this.context)
        match (launchParam.launchReason) {
            case LaunchReason.StartAbility => Hilog.info(1, "Habit", "START_ABILITY")
            case _ => ()
        }
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        Hilog.info(1, "Habit", "MainAbility onWindowStageCreate.")
        windowStage.loadContent("ContentView")
    }
}
