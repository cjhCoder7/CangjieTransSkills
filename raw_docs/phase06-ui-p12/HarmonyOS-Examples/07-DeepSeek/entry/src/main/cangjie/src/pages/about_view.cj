/**
 * Created on 2025/2/14
 */
package ohos_app_cangjie_entry.pages

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import cj_res_entry.*
import ohos.router.Router
import ohos.webview.*

@Entry
@Component
public class aboutView {
    // 回退的按钮点击
    func onBackBtnClick() {
        Router.back()
    }

    var title: String = Router.getParamsObject().getFields()["title"].asString().getValue()
    var src: String = Router.getParamsObject().getFields()["src"].asString().getValue()

    func build() {
        Column {
            Row {
                Image(@r(app.media.prev)).size(width: 22, height: 22).fillColor(0x000000)
                .onClick({
                    e: ClickEvent => this.onBackBtnClick()
                })

                Text(title).style(size: 16, weight: FontWeight.Bold)

                Image(@r(app.media.open)).size(width: 22, height: 22)
            }.style()
            .borderStyle(BorderStyle.Solid)
            .borderWidth(EdgeWidths(bottom:1.vp))
            .borderColor(0xf2f2f2)

            Web(src: src)
        }
    }
}