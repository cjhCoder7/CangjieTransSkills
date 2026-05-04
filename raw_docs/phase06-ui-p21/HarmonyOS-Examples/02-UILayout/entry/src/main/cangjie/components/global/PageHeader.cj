/**
 * Created on 2025/7/31
 */
package ohos_app_cangjie_entry.components.global

import ohos.base.*
import ohos.state_manage.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import cj_res_entry.app
import ohos.router.*


@Component
public class PageTitle {
    @Prop var title: String

    func build(){
        Text(title).fontColor(0x575757).fontSize(30.lpx)
            .fontWeight(FontWeight.W600).width(100.percent)
    }
}

@Component
public class BackIcon {
    func build() {
        Row() {
            Image(@r(app.media.back_icon)).width(50.lpx).height(50.lpx)
        }.padding(left: 10.lpx).onClick({ e: ClickEvent => Router.back() })
    }
}

@Component
public class PageHeader {
    @Prop var title: String

    func build() {
        Row() {
            BackIcon()

            PageTitle(title: title)
        }.width(100.percent).alignItems(VerticalAlign.Center)
    }
}