package ohos_app_cangjie_entry

internal import ohos_app_cangjie_entry.utils.*
internal import ohos.ability.*
internal import ohos.window.WindowStage
internal import cj_res_entry.app

class MainAbility <: Ability {
    public init() {
        super()
        registerSelf()
    }

    public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
        HiLog.info("MainAbility OnCreated.${want.abilityName}")
        match (launchParam.launchReason) {
            case LaunchReason.START_ABILITY => HiLog.info("START_ABILITY")
            case _ => ()
        }
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        HiLog.info("MainAbility onWindowStageCreate.")
        let deviceType: String = getScreenType()
        AppStorage.setOrCreate<String>("deviceType", deviceType) // 设置全局变量，将获取到的设备类型存放进去
        windowStage.loadContent("EntryView")
    }
}
