/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.component.card

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.sync.{Timer, sleep}
import std.time.{Duration}
import ohos_app_cangjie_entry.entity.*
import ohos_app_cangjie_entry.mock.VideoData
import ohos_app_cangjie_entry.utils.*

let TOP_BORDER_RADIUS = 6.fp

@Component
public class CoverCard {
    // 资源类型
    @Prop var mediaType: MediaType

    // 标题
    @Prop var title: String

    // 文本描述
    @Prop var desc: String

    @State var onPlaying: Bool = false

    func build() {
        Column(10) {
            if (let IMAGE(src) <- mediaType) {
                Image(src).width(100.percent)
                .borderRadius(topLeft: TOP_BORDER_RADIUS, topRight: TOP_BORDER_RADIUS)
                .objectFit(ImageFit.Cover)
            }

            Column(10) {
                Text(title).fontSize(14).width(100.percent)

                Text(desc).fontSize(12).width(100.percent)
            }.padding(left: 10, right: 10, bottom: 10)
        }.width(100.percent)
        .alignItems(HorizontalAlign.Start)
        .borderRadius(TOP_BORDER_RADIUS)
        .backgroundColor(0xffffff)
    }
}