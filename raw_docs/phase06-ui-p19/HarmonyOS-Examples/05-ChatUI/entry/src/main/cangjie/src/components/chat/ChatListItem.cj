/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.components.chat

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.components.avatar.*
import ohos_app_cangjie_entry.components.badge.*
import ohos_app_cangjie_entry.entity.*

const COLOR_SECONDARY: UInt32 = 0x6c757d

@Builder
public func ChatListItem(
  src!: CJResource,
  name!: String,
  msg!: String,
  time!: String,
  count!: Int64,
  bindItem!: (Chat, User),
  onClick!: ((Chat, User)) -> Unit
) {
  Row() {
      Avatar(src: src, size: 50)

      Column() {
        Row() {
          Text(name).fontSize(18).textOverflow(TextOverflow.Ellipsis)
          .maxLines(1).layoutWeight(1)

          Text(time).fontSize(12).fontColor(COLOR_SECONDARY)
          .width(80).textAlign(TextAlign.End)
        }.justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Bottom)
        .margin(bottom: 5)
        Row() {
          Text(msg).fontSize(14).fontColor(COLOR_SECONDARY)
          .textOverflow(TextOverflow.Ellipsis)
          .maxLines(1).layoutWeight(1)

          MBadge(count: count)
        }.justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
      }.layoutWeight(1).margin(left: 10)
    }.padding(top: 10, bottom: 10)
    .margin(top: 5)
  .onClick({ e:ClickEvent => onClick(bindItem)})
}

