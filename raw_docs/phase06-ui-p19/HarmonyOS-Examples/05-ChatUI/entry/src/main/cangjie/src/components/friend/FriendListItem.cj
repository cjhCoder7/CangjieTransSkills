/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.components.friend

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.entity.*
import ohos_app_cangjie_entry.util.*
import ohos_app_cangjie_entry.components.avatar.*

@Component
public class FriendListItem {
  // 绑定的用户对象
  @Prop var user: User

  func build() {
    Row() {
      Avatar(src: user.avatar, size: 30)

      Column(2) {
        Text(user.username).fontSize(16)

        Text(user.status()).fontSize(10).fontColor(COLOR_GRAY)
      }.alignItems(HorizontalAlign.Start)
      .margin(left: 10)
    }.width(100.percent)
  }
}