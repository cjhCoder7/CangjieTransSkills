/**
 * Created on 2024/8/11
 */
package ohos_app_cangjie_entry.components.home


internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import ohos_app_cangjie_entry.constants.*
import cj_res_entry.app
import ohos_app_cangjie_entry.utils.ResourceUtil

@Component
public class HomeHeader {
    @StorageLink["currentBreakpoint"] var currentBreakpoint: String = ""
    func build() {
        Row(BaseConstants.ROW_COLUMN_SPACE_WIDE) {
            HomePosition()

            HomeSearch()

            Image(@r(app.media.ic_scan))
                .width(@r(app.float.icon_width_large))
                .height(@r(app.float.icon_height_large))
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .height(HomeConstants.HOME_HEADER_HEIGNT)
        .width(100.percent)
        .padding(
            right: ResourceUtil.getBasePadding().getValue(this.currentBreakpoint),
            left: ResourceUtil.getBasePadding().getValue(this.currentBreakpoint),
            top: Length(HomeConstants.HOME_HEADER_TOP_PADDING)
        )
    }
}