/**
 * Created on 2024/10/23
 */
package ohos_app_cangjie_entry.widget

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class Score {
    var title: String

    //这里需要使用@Link绑定数据
    @Link var score: Int64


    func build() {
        Column {
            Text(title).fontSize(18).width(100).height(50).textAlign(TextAlign.Center)
            Text(score.toString()).fontSize(28).width(100).height(50).textAlign(TextAlign.Center)
        }.backgroundColor(0xEEE4DA).border(width: 5.px, radius: 20.px).margin(right: 5.percent)
    }
}
