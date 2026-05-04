/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.components.avatar

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

@Builder
public func Avatar(src!: CJResource, size!: Int64 = 50) {
  Image(src).width(size).height(size).borderRadius(size / 2)
}