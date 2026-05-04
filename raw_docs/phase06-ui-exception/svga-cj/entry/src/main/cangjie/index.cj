package ohos_app_cangjie_entry

import tpc.UIKit.Text
import tpc.UIKit.Button
import tpc.UIKit.Column
import tpc.UIKit.CustomView
import ohos.state_macro_manage.State
import ohos.state_macro_manage.Component
import ohos.state_manage.LocalStorage
import ohos.state_manage.ObservedProperty
import ohos.state_manage.SubscriberManager
import ohos.state_manage.ViewStackProcessor
import ohos.state_macro_manage.HybridComponentEntry
import ohos.hybrid_base.CJPageEntry
import ohos.hybrid_base.HybridComponentBase
import cj_res_entry.app

@HybridComponentEntry
@Component
class Index {
    @State
    var msg: String = "Hello"

    public func build() {
        Column {
            Text(msg)
            Button("click to change Text").onClick {
                => msg = "world"
            }
        }
    }
}
