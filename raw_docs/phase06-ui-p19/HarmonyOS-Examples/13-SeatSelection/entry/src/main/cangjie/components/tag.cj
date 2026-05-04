/**
 * Created on 2025/7/17
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.constants.AreaInfo

@Component
class Tag {
    @Prop
    var info: AreaInfo

    func build() {
        Row {
            Rect()
                .width(12)
                .radius(3)
                .aspectRatio(1)
                .fill(info.fillColor)
                .stroke(info.strokeColor)

            Text(info.str)
                .fontSize(13)
                .margin(left: 10)
                .fontColor(Color(0X737373))
        }
    }
}
