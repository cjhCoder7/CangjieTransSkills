/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.components.chat

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.app
import ohos.resource_manager.*
import ohos_app_cangjie_entry.util.*
import ohos_app_cangjie_entry.entity.*
import ohos_app_cangjie_entry.mock.*
import ohos.router.Router
import ohos_app_cangjie_entry.global.*

@Component
public class ChatList {
  // 聊天项点击的回调
  func privateChatOnClick(target: (Chat, User)) {
    CURRENT_CHAT.set(target[0])
    TARGET_USER.set(target[1])
    Router.push(url: "ChatView")
  }

  let tabsController: TabsController = TabsController()

  let privateChatDataSource = Array<(Chat, User)>([
      (chat1, user2), (chat2, user3), (chat3, user4),
      (chat4, user5), (chat5, user6), (chat6, user7),
      (chat7, user8), (chat8, user9), (chat9, user10)
    ])

  func build() {
    Column() {
      Row() {
        Row() {
          Image(@r(app.media.search)).size(width: 20, height: 20).margin(right: 10)

          Text("搜索").fontSize(16).fontColor(COLOR_GRAY)
        }.width(100.percent)
        .justifyContent(FlexAlign.Center)
        .padding(top: 8, bottom: 8)
        .backgroundColor(0xffffff)
        .borderRadius(6)
      }.width(100.percent)
      .padding(left: 20, right: 20)
      .margin(bottom: 20)

      List() {
        ForEach(privateChatDataSource, itemGeneratorFunc: {elem: (Chat, User), index: Int64 =>
          ListItem() {
            ChatListItem(
              src: elem[1].avatar,
              name: elem[1].username,
              msg: elem[0].msgs[0].content,
              time: elem[0].msgs[0].time,
              count: elem[0].count,
              bindItem: elem,
              onClick: privateChatOnClick
            )
          }
        })
      }.padding(left: 20, right: 20, bottom: 50)
      .backgroundColor(0xffffff)
    }.width(100.percent)
    .height(100.percent)
  }
}