package ohos_app_cangjie_entry

internal import ohos.base.AppLog
internal import ohos.ability.AbilityStage
internal import ohos.ability.LaunchReason
internal import cj_res_entry.app
import ohos.ability.AbilityContext
import ohos.window.Window
import ohos.window.findWindow

class MainAbility <: Ability {
    static var abilityContext: Option<AbilityContext> = None

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
        abilityContext = this.context

        let isLayoutFullScreen = true
        let windowClass: Window = windowStage.getMainWindow()
        let promise = windowClass.setWindowLayoutFullScreen(isLayoutFullScreen)

        AppLog.info("MainAbility onWindowStageCreate.")
        windowStage.loadContent("EntryView")
    }
}
