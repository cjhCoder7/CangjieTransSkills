/**
 * Created on 2024/8/23
 */
package ohos_app_cangjie_entry.utils
internal import ohos.display.*
internal import ohos.base.AppLog
import ohos_app_cangjie_entry.constants.BreakpointConstants
import ohos.state_manage.*
import ohos.window.*
import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*


public class WindowUtil {
    private static let windowUtil: WindowUtil = WindowUtil()
    private static var windowStageObj: Option<WindowStage> = Option<WindowStage>.None
    private static var windowObj: Option<Window> = Option<Window>.None
    private WindowUtil() {

    }
    public static func getInstance(): WindowUtil {
        return windowUtil
    }

    public static func setWindowStage(windowStage: WindowStage) {
        windowStageObj = Option<WindowStage>.Some(windowStage)
    }

    public static func setWindow(window: Window) {
        windowObj = Option<Window>.Some(window)
    }

    public static func setFullScreen() {
        match (windowObj) {
            case Some(window) => window.setWindowLayoutFullScreen(true)
            case None => AppLog.error("window is not set")
        }
    }

    public static func setAvoidRectHeight() {
         match (windowObj) {
            case Some(window) =>
                let topHeight: UInt32 = window.getWindowAvoidArea(AvoidAreaType.TYPE_SYSTEM).topRect.height
                AppStorage.setOrCreate('topRectHeight', Length(Int64(topHeight), unitType : LengthType.px))
                let bottomRectHeight = window.getWindowAvoidArea(AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height
                AppStorage.setOrCreate('bottomRectHeight', Length(Int64(bottomRectHeight), unitType : LengthType.px))
            case None => AppLog.error("window is not set")
        }
    }

    public static func updateBreakpoint(windowWidth: UInt32) {
        let windowWidthVp = Float32(windowWidth) / getDefaultDisplaySync().densityPixels
        var curBp: String = ''
        if (windowWidthVp < BreakpointConstants.BREAKPOINT_RANGES[1]) {
            curBp = BreakpointConstants.BREAKPOINT_SM
        } else if (windowWidthVp < BreakpointConstants.BREAKPOINT_RANGES[2]) {
            curBp = BreakpointConstants.BREAKPOINT_MD
        } else {
            curBp = BreakpointConstants.BREAKPOINT_LG
        }
        AppStorage.setOrCreate('currentBreakpoint', curBp)
    }
}