/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.components.friend

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.mock.*
import ohos_app_cangjie_entry.entity.*

@Component
public class FriendBar {
  let userList = [user2, user3, user4, user5, user6, user7, user8, user9, user10]

  // 当前轮播页的序号
  @State var index: UInt32 = 0

  func tabOnClick() {

  }

  @Builder
  func UserList() {
    Column(10) {
      ForEach(userList, itemGeneratorFunc: { user: User, index: Int64 =>
            FriendListItem(user: user);
      })
    }.borderWidth(1)
  }

  func build() {
    Tabs(BarPosition.Start) {
      TabContent() {
        UserList()
      }.tabBar("好友").borderWidth(1).padding(0)

      TabContent() {
        UserList()
      }.tabBar("分组").borderWidth(1).padding(0)
    }.vertical(false)
    .barMode(BarMode.Scrollable)
    .barHeight(50)
    .scrollable(true)
    .backgroundColor(0xffffff)
  }
}