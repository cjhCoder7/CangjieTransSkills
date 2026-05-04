/**
 * Created on 2025/8/6
 */
package ohos_app_cangjie_entry.models

import ohos.base.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

@Observed
public class DisplayNumberData {
    @Publish public var dataColor: Color = Color.BLACK

    @Publish public var priceText: String     = "--"
    @Publish public var changeText: String    = "--"
    @Publish public var percentText: String   = "--"
    @Publish public var volumeText: String    = "--"
    @Publish public var turnoverText: String  = "--"
    @Publish public var amplitudeText: String = "--"
}