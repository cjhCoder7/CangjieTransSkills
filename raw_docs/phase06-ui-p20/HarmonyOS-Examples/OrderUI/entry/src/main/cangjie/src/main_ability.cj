package ohos_app_cangjie_entry

internal import ohos.base.AppLog
internal import ohos.ability.AbilityStage
internal import ohos.ability.LaunchReason
internal import cj_res_entry.app
import ohos.window.*
import ohos_app_cangjie_entry.utils.WindowUtil

class MainAbility <: Ability {
    private var windowObj: Option<Window> = Option<Window>.None
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
        WindowUtil.setWindowStage(windowStage)
        let window = windowStage.getMainWindow()
        this.windowObj = Option<Window>.Some(window)
        window.setWindowLayoutFullScreen(true)
        WindowUtil.setWindow(window)
        WindowUtil.updateBreakpoint(this.windowObj.getOrThrow().getWindowProperties().windowRect.width)
        WindowUtil.setFullScreen()
        WindowUtil.setAvoidRectHeight()
        windowStage.loadContent("MyView")
    }
}
