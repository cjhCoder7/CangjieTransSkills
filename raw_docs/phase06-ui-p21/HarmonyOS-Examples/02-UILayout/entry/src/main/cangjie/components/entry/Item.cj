/**
 * Created on 2025/8/5
 */
package ohos_app_cangjie_entry.components.entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.*


@Component
public class EntryItem {
    @Prop var iconSrc: CJResource
    @Prop var title: String
    @Prop var components: String
    @Prop var url: String  // 子页面的名称

    let titleFontSize: Int64 = 26
    let componentsFontSize: Int64 = 22
    let iconSize: Int64 = 80

    func build() {
        Row(20.lpx) {
            Image(iconSrc).width(iconSize.lpx).height(iconSize.lpx)

            Column(4.lpx) {
                Text(title).fontSize(titleFontSize.lpx).fontColor(0x000000).fontWeight(FontWeight.W700)
                Text(components).fontSize(componentsFontSize.lpx).fontColor(0x535353).fontWeight(FontWeight.W300)
            }.alignItems(HorizontalAlign.Start)
        }.width(100.percent).alignItems(VerticalAlign.Center)
        .onClick({ e: ClickEvent => Router.push(url: url) })
    }
}