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
import ohos_app_cangjie_entry.models.{HomeMenuModel}
import ohos_app_cangjie_entry.utils.{ResourceUtil, BreakpointType}

@Component
public class HomeMenu {
    @StorageLink["currentBreakpoint"] var currentBreakpoint: String = ""
    func build() {
        Row() {
            List(space: ResourceUtil.getHomeMenuListSpace().getValue(this.currentBreakpoint)) {
                ForEach(HomeConstants.HOME_MENU_LIST, itemGeneratorFunc: {homeMenuModel: HomeMenuModel, index: Int64 =>
                    ListItem() {
                        Column(BaseConstants.ROW_COLUMN_SPACE_THIN) {
                            Image(homeMenuModel.getIcon())
                                .width(80.percent)
                                .aspectRatio(1)
                                .objectFit(ImageFit.ScaleDown)

                            Text(homeMenuModel.getTitle())
                                .fontSize(@r(app.float.font_size_small))
                        }
                        .width(100.percent)
                        .height(100.percent)
                        .justifyContent(FlexAlign.Center)
                        .padding(@r(app.float.home_menu_item_padding))
                    }
                    .width(ResourceUtil.getHomeMenuItemWidth().getValue(this.currentBreakpoint))
                    .height(ResourceUtil.getHomeMenuItemHeight().getValue(this.currentBreakpoint))

                })
            }
            .lanes(ResourceUtil.getHomeMenuListLanes().getValue(this.currentBreakpoint))
            .listDirection(Axis.Horizontal) // 排列方向
            .scrollBar(BarState.Off)
            .width(100.percent)
            .height(
                BreakpointType<Length>(Length(HomeConstants.HOME_MENU_HEIGHT_SM),
                    Length(HomeConstants.HOME_MENU_HEIGHT_MD),
                    Length(HomeConstants.HOME_MENU_HEIGHT_LG)).getValue(this.currentBreakpoint)
            )
        }
        .width(100.percent)
        .height(
            BreakpointType<Length>(Length(HomeConstants.HOME_MENU_HEIGHT_SM),
                Length(HomeConstants.HOME_MENU_HEIGHT_MD),
                Length(HomeConstants.HOME_MENU_HEIGHT_LG)).getValue(this.currentBreakpoint)
        )
        .margin(
            top: Length(HomeConstants.HOME_MENU_TOP_MARGIN)
        )
        .padding(
            right:  ResourceUtil.getBasePadding().getValue(this.currentBreakpoint),
            left:  ResourceUtil.getBasePadding().getValue(this.currentBreakpoint)
        )
    }
}