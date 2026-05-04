package ohos_app_cangjie_entry

import ohos.base.*
import ohos.window.*
import ohos.ability.*
import ohos.hilog.Hilog
import ohos.state_manage.AppStorage
import ohos.resource_manager.ResourceManager

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

        let windowClass = windowStage.getMainWindow()

        windowClass.setWindowLayoutFullScreen(true)

        var avoidAreaType = AvoidAreaType.TYPE_SYSTEM
        var avoidArea = windowClass.getWindowAvoidArea(avoidAreaType)

        let topRectHeight = avoidArea.topRect.height
        Hilog.info(0, "onWindowStageCreate", "topRectHeight: ${topRectHeight}")
        AppStorage.setOrCreate<Length>('topRectHeight', Length(Int64(topRectHeight), unitType: LengthType.px))

        avoidAreaType = AvoidAreaType.TYPE_NAVIGATION_INDICATOR
        avoidArea = windowClass.getWindowAvoidArea(avoidAreaType)

        let bottomRectHeight = avoidArea.bottomRect.height
        Hilog.info(0, "onWindowStageCreate", "bottomRectHeight: ${bottomRectHeight}")
        AppStorage.setOrCreate<Length>('bottomRectHeight', Length(Int64(bottomRectHeight), unitType: LengthType.px))

        let resourceManager: Option<ResourceManager> = ResourceManager.getResourceManager(getStageContext(this.context))
        AppStorage.setOrCreate<Option<ResourceManager>>('resMgr', resourceManager)

        windowStage.loadContent("EntryView")
    }
}
