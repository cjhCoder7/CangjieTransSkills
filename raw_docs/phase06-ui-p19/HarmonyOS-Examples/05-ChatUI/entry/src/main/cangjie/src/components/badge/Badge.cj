/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.components.badge

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*

const BG_INFORM: UInt32 = 0xdc3545
const BG_SECONDARY: UInt32 = 0x6c757d
const FONT_COLOR: UInt32 = 0xffffff

@Builder
public func MBadge(count!: Int64) {
  Text(count.toString()).fontSize(10)
  .fontColor(FONT_COLOR).height(18)
  .backgroundColor(BG_INFORM)
  .borderRadius(50.percent)
  .padding(left: 6, right: 6)
  .margin(right: 2)
}

@Builder
public func CBadge(count!: Int64) {
  Text(count.toString()).fontSize(12)
  .fontColor(0x000000).height(20)
  .backgroundColor(Color(208,207,212))
  .borderRadius(50.percent)
  .padding(left: 6, right: 6)
  .margin(right: 2)
}