package ohos_app_cangjie_entry

import kit.PerformanceAnalysisKit.Hilog
import kit.AbilityKit.Want
import kit.AbilityKit.UIAbility
import kit.AbilityKit.LaunchParam
import kit.AbilityKit.WantValueType
import kit.ArkUI.WindowStage
import kit.ArkUI.Window
import kit.ArkUI.SystemBarProperties
import ohos_app_cangjie_entry.services.*
import ohos_app_cangjie_entry.utils.AppContext
import std.convert.*

public class MainAbility <: UIAbility {
    public init() {
        super()
        registerSelf()
    }

    public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
        AppContext.setup(this.context)
        handleNotificationWant(want)
        Hilog.info(1, "Cangjie", "MainAbility OnCreated")
    }

    public func onNewWant(want: Want): Unit {
        handleNotificationWant(want)
        Hilog.info(1, "Cangjie", "MainAbility onNewWant")
    }

    public override func onDestroy(): Unit {
        Hilog.info(1, "Cangjie", "MainAbility onDestroy")
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        Hilog.info(1, "Cangjie", "MainAbility onWindowStageCreate")
        windowStage.loadContent("EventListPage")
        this.configureSystemBars(windowStage)
        Hilog.info(1, "Cangjie", "Succeeded in loading the content.")
    }

    public override func onWindowStageDestroy(): Unit {
        Hilog.info(1, "Cangjie", "MainAbility onWindowStageDestroy")
    }

    public override func onForeground(): Unit {
        try {
            ReminderScheduleService.ensureAllSchedules(this.context)
        } catch (_: Exception) {
            Hilog.error(1, "Cangjie", "Failed to ensure reminder schedules")
        }
        Hilog.info(1, "Cangjie", "MainAbility onForeground")
    }

    public override func onBackground(): Unit {
        Hilog.info(1, "Cangjie", "MainAbility onBackground")
    }

    private func handleNotificationWant(want: Want): Unit {
        let eventIdParam = want.parameters.get("eventId")
        match (eventIdParam) {
            case Some(WantValueType.Int64Value(id)) => NotificationNavigationState.setPendingEventId(id)
            case Some(WantValueType.StringValue(s)) =>
                try {
                    let id = Int64.parse(s)
                    NotificationNavigationState.setPendingEventId(id)
                } catch (_: Exception) {
                    Hilog.error(1, "Cangjie", "Failed to parse eventId from want")
                }
            case _ => ()
        }
    }

    private func configureSystemBars(windowStage: WindowStage): Unit {
        try {
            let mainWindow = windowStage.getMainWindow()
            mainWindow.setWindowLayoutFullScreen(true)
            let sysBarProps = SystemBarProperties(
                statusBarColor: "#00000000",
                navigationBarColor: "#00000000",
                statusBarContentColor: "#000000",
                navigationBarContentColor: "#000000"
            )
            mainWindow.setWindowSystemBarProperties(sysBarProps)
        } catch (_: Exception) {
            Hilog.error(1, "Cangjie", "Failed to configure system bars")
        }
    }
}
