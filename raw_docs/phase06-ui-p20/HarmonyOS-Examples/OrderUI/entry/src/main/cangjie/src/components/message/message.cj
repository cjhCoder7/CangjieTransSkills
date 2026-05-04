/**
 * Created on 2024/8/10
 */
package ohos_app_cangjie_entry.components.message

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import ohos.resource_manager.*
import cj_res_entry.app

@Component
public class Message {
    func build() {
        Column() {
            Text("Message")
            .height(100.percent)
            .width(100.percent)
            .textAlign(TextAlign.Center)
        }
        .height(100.percent)
        .width(100.percent)
        .backgroundColor(@r(app.color.background_secondary))
        .padding(top: 0,right: 10, bottom: 0, left: 10)
    }
}