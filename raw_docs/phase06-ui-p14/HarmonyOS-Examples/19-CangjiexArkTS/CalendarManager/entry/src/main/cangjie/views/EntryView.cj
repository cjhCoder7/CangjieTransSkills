package ohos_app_cangjie_entry.views

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

import ohos_app_cangjie_entry.applog.appLog

@Entry
@Component
class EntryView {
    @State
    var message: String = "Hello Cangjie"
    func build() {
        Row {
            Column {
                Button(message).onClick {
                    evt => appLog.info("Hello Cangjie")
                }.fontSize(40).height(80)
            }.width(100.percent)
        }.height(100.percent)
    }
}
