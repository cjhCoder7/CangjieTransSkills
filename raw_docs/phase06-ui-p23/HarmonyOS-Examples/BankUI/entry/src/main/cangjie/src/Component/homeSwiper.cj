/**
 * Created on 2024/8/30
 */
package ohos_app_cangjie_entry.Component

import cj_res_entry.app
import ohos_app_cangjie_entry.Model.*
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class HomeSwiper {
    var controller: SwiperController = SwiperController()

    func build() {
        Swiper(controller) {
            ForEach(
                SwiperList,
                itemGeneratorFunc: {
                    item: CJResource, index: Int64 => Image(item).width(100.percent).aspectRatio(2.5).objectFit(
                        ImageFit.Fill)
                }
            )
        }.autoPlay(true).indicator(false).itemSpace(10).width(100.percent).padding(16.vp)
    }
}
