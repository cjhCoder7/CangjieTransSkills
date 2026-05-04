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
public class HomeBanner {

    @StorageLink["currentBreakpoint"] var currentBreakpoint: String = ""
    
    func build() {
        Row() {
            Swiper() {
                ForEach(HomeConstants.HOME_BANNER_LIST, itemGeneratorFunc: {item: CJResource, index: Int64 =>
                    Image(item)
                        .height(100.percent)
                        .width(100.percent)
                })
            }
            .displayCount(ResourceUtil.getHomeBannerShowNumber().getValue(this.currentBreakpoint))
            .itemSpace(Length(BaseConstants.SWIPER_SPACE_NORMAL))
            .cachedCount(2)
            .autoPlay(true)
            .interval(4000)
            .loop(true)
            .duration(1000)
            .curve(Curve.Linear)
            .vertical(false)
            .indicator(true)
            .layoutWeight(1)
        }
        .width(100.percent)
        .height(HomeConstants.HOME_BANNER_HEIGHT)
        .margin(
            top: Length(HomeConstants.HOME_BANNER_TOP_MARGIN)
        )
        .padding(
            right:  ResourceUtil.getBasePadding().getValue(this.currentBreakpoint),
            left:  ResourceUtil.getBasePadding().getValue(this.currentBreakpoint)
        )
    }
}