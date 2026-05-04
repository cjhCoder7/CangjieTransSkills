package ohos_app_cangjie_entry

import ohos.base.*
import ohos.hilog.Hilog
import ohos.ability.AbilityStage
import ohos.ability.LaunchReason
import ohos.window.AvoidAreaType
import ohos.state_manage.AppStorage

class MainAbility <: Ability {
    public init() {
        super()
        registerSelf()
    }

    public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
        AppLog.info("MainAbility OnCreated.${want.abilityName}")
        match (launchParam.launchReason) {
            case LaunchReason.START_ABILITY => AppLog.info("START_ABILITY")
            case _ => ()
        }
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        AppLog.info("MainAbility onWindowStageCreate.")
        windowStage.loadContent("EntryView")

        let windowClass = windowStage.getMainWindow()

        windowClass.setWindowLayoutFullScreen(true)

        let avoidAreaType = AvoidAreaType.TYPE_SYSTEM
        let avoidArea = windowClass.getWindowAvoidArea(avoidAreaType)

        let topRectHeight = avoidArea.topRect.height
        Hilog.info(0, "onWindowStageCreate", "topRectHeight: ${topRectHeight}")

        AppStorage.setOrCreate<Length>('topRectHeight', Length(Int64(topRectHeight), unitType: LengthType.px))
    }
}
