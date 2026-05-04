/**
 * Created on 2025/8/3
 */
package ohos_app_cangjie_entry.components.global

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*


@Component
public class SectionTitle {
    @Prop var title: String  // 块标签,

    @Builder
    public func blackLine() {
        Row().height(0).width(50.lpx).border(width: 1.lpx, color: Color(0x000000))
    }

    func build() {
        Row() {
            blackLine()
            Text(title).fontSize(30.lpx).fontColor(0x000000)
                .margin(left: 20.lpx, right: 20.lpx)
            blackLine()
        }.width(100.percent).justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center).margin(top: 60.lpx, bottom: 20.lpx)
    }
}