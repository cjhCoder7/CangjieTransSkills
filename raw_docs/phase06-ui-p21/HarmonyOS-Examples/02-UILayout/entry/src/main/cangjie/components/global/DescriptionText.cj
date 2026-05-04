/**
 * Created on 2025/8/3
 */
package ohos_app_cangjie_entry.components.global

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*


@Component
public class DescriptionText {
    @Prop var content: String

    func build() {
        Text(content).fontSize(26.lpx).fontColor(0x000000)
            .fontWeight(FontWeight.W400).lineHeight(42.lpx) // 1.5倍行间距
            .width(100.percent).margin(top: 10.lpx, bottom: 30.lpx)
    }
}