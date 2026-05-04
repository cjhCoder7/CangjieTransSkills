package ohos_app_cangjie_entry.Component

import ohos_app_cangjie_entry.Model.*
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class HomeBanner {
    func build() {
        Row() {
            ForEach(
                BannerList,
                itemGeneratorFunc: {
                    item: iconItem, index: Int64 => Column() {
                        Image(item.getImage()).width(40.vp).height(40.vp).margin(bottom: 4.vp).fillColor(0xF0FFF0)
                        Text(item.getTitle()).fontSize(12).textAlign(TextAlign.Center).fontWeight(FontWeight.W400)
                    }
                }
            )
        }.width(100.percent).height(200.vp).justifyContent(FlexAlign.SpaceEvenly).padding(left: 12.vp, right: 12.vp,
            top: 80.vp).backgroundImage(src: "/resources/base/media/ic_app_background.png").backgroundColor(0xff0000)
    }
}
