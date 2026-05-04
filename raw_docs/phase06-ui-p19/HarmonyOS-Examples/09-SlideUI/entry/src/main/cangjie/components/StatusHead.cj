/**
 * Created on 2025/7/30
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class StatusHead {

    @Prop var isShow: Bool

    public func build() {
        Column {
            Blank()
            .width(290)
            .backgroundColor(Color.WHITE)
            .height(38)
        }
        .id('statusHead')
        .visibility(if(isShow){Visibility.Visible}else{Visibility.None})
    }
}