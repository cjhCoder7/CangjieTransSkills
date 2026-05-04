package ohos_app_cangjie_entry

import kit.AbilityKit.{UIAbility, Want, LaunchParam}
import kit.ArkUI.WindowStage
import kit.PerformanceAnalysisKit.Hilog

func logAbility(message: String): Unit {
    Hilog.info(0, "UiRoutingSample", message)
}

class EntryAbility <: UIAbility {
    public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
        logAbility("EntryAbility onCreate")
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        logAbility("EntryAbility onWindowStageCreate")
        windowStage.loadContent("FoodCategoryListPage")
    }

    public override func onForeground(): Unit {
        logAbility("EntryAbility onForeground")
    }

    public override func onBackground(): Unit {
        logAbility("EntryAbility onBackground")
    }

    public override func onDestroy(): Unit {
        logAbility("EntryAbility onDestroy")
    }
}
