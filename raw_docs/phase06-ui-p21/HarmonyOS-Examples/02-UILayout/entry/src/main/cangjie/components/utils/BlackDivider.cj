/**
 * Created on 2025/8/4
 */
package ohos_app_cangjie_entry.components.utils

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*


@Component
public class BlackDivider {
    func build() {
        Row().width(100.percent).height(0).border(width: 1.lpx, color: Color(0x000000))
    }
}