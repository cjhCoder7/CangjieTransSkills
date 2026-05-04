/**
 * Created on 2024/8/24
 */
package ohos_app_cangjie_entry.utils
import ohos.base.*
import ohos.state_macro_manage.*
import cj_res_entry.app
import ohos_app_cangjie_entry.constants.*


public class ResourceUtil {
    private static let basePadding: BreakpointType<Length> =
        BreakpointType<Length>(Length(BaseConstants.BASE_PADDING_SM),
            Length(BaseConstants.BASE_PADDING_MD),
            Length(BaseConstants.BASE_PADDING_LG))

    public static func getBasePadding(): BreakpointType<Length> {
        return basePadding
    }

    private static let HOME_BANNER_SHOW_NUMBER: BreakpointType<Int32> = BreakpointType<Int32>(1, 2, 3)

    public static func getHomeBannerShowNumber(): BreakpointType<Int32> {
        return HOME_BANNER_SHOW_NUMBER
    }

    private static let HOME_MENU_LIST_LANES: BreakpointType<Int32> = BreakpointType<Int32>(2, 1, 1)

    public static func getHomeMenuListLanes(): BreakpointType<Int32> {
        return HOME_MENU_LIST_LANES
    }

    private static let HOME_MENU_LIST_SPACE: BreakpointType<Int64> = BreakpointType<Int64>(
        HomeConstants.HOME_MENU_LIST_SPACE_SM, HomeConstants.HOME_MENU_LIST_SPACE_MD, HomeConstants.HOME_MENU_LIST_SPACE_LG
    )

    public static func getHomeMenuListSpace(): BreakpointType<Int64> {
        return HOME_MENU_LIST_SPACE
    }

    private static let HOME_MENU_ITEM_HEIGHT: BreakpointType<Int64> = BreakpointType<Int64>(
        HomeConstants.HOME_MENU_ITEM_HEIGHT_SM, HomeConstants.HOME_MENU_ITEM_HEIGHT_MD, HomeConstants.HOME_MENU_ITEM_HEIGHT_LG
    )

    public static func getHomeMenuItemHeight(): BreakpointType<Int64> {
        return HOME_MENU_ITEM_HEIGHT
    }

    private static let HOME_MENU_ITEM_WIDTH: BreakpointType<Length> = BreakpointType<Length>(
        HomeConstants.HOME_MENU_ITEM_WIDTH_SM, HomeConstants.HOME_MENU_ITEM_WIDTH_MD, HomeConstants.HOME_MENU_ITEM_WIDTH_LG
    )

    public static func getHomeMenuItemWidth(): BreakpointType<Length> {
        return HOME_MENU_ITEM_WIDTH
    }
}