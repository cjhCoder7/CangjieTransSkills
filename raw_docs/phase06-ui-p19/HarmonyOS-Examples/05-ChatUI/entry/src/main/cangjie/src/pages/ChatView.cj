/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.pages

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.*
import ohos.resource_manager.*
import ohos_app_cangjie_entry.components.badge.*
import ohos_app_cangjie_entry.global.*
import ohos_app_cangjie_entry.entity.*
import ohos_app_cangjie_entry.mock.*
import ohos.router.Router
import ohos_app_cangjie_entry.components.avatar.*
import std.collection.ArrayList
import ohos_app_cangjie_entry.components.chat.*

@Entry
@Component
public class ChatView {
  // 对方user
  @State var targetUser: User = user1

  // 当前的聊天对象
  @State var currentChat: Chat = chat1

  // 消息列表
  @State var msgList: ArrayList<Message> = ArrayList<Message>([])

  // 底部各个图标的大小
  let bottomIconSize = 30

  // 显示聊天内容的组件
  @Builder
  func generateChatLine(e: Message, index: Int64) {
    if (e.userId == LOCAL_USER.id) {
      ChatLine(src: LOCAL_USER.avatar, content: e.content, isSelf: true)
    }
    else {
      ChatLine(src: targetUser.avatar, content: e.content, isSelf: false)
    }
  }

  // 这会在渲染组件前执行
  protected override func aboutToAppear() {
    this.targetUser = TARGET_USER.get()
    this.currentChat = CURRENT_CHAT.get()
    this.msgList = ArrayList<Message>(this.currentChat.msgs)
  }

  // 回退的按钮点击
  func onBackBtnClick() {
    Router.back()
  }

  func build() {
    Column() {
      Row() {
        Image(@r(app.media.prev)).fillColor(0x000000)
        .size(width: 20, height: 20).onClick({
          e: ClickEvent => this.onBackBtnClick()
        })

        CBadge(count: currentChat.count)

        Column(2) {
          Text(targetUser.username).fontSize(20)

          Row() {
            Row().size(width: 10, height: 10)
            .borderRadius(50.percent)
            .backgroundColor(Color(107, 224, 144))
            .margin(right: 5)

            Text(targetUser.status()).fontSize(8)
          }
        }.layoutWeight(1)
        .margin(left: 10)
        .alignItems(HorizontalAlign.Start)
      }.padding(left: 10, right: 10, bottom: 10)
      .backgroundColor(0xffffff)
      .expandSafeArea(
         types: [SafeAreaType.SYSTEM],
        edges: [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]
      )

      Scroll() {
        Column() {
          ForEach(msgList, itemGeneratorFunc: { e: Message, index: Int64 =>
             generateChatLine(e, index)
          })
        }.width(100.percent)
        .padding(left: 10, right: 10, top: 10)
        .alignItems(HorizontalAlign.Start)
      }
      .align(Alignment.TopStart)
      .layoutWeight(1)
      .backgroundColor(Color(238, 237, 242))

      Column(10) {
        Row() {
          TextInput()
          .fontColor(0x000000)
          .backgroundColor(0xffffff)
          .layoutWeight(1)
          .borderRadius(6.fp)
          .margin(right: 10)

          Button("发送").shape(ShapeType.Normal)
          .height(40)
          .width(60)
          .fontSize(12)
          .fontColor(0xffffff)
          .borderRadius(6.fp)
          .backgroundColor(Color(67, 151, 247))
        }

        Row() {
          Image(@r(app.media.microphones)).size(width: bottomIconSize, height: bottomIconSize)
          Image(@r(app.media.image)).size(width: bottomIconSize, height: bottomIconSize)
          Image(@r(app.media.camera)).size(width: bottomIconSize, height: bottomIconSize)
          Image(@r(app.media.red_gift)).size(width: bottomIconSize, height: bottomIconSize)
          Image(@r(app.media.emotion_happy_line)).size(width: bottomIconSize, height: bottomIconSize)
          Image(@r(app.media.chatview_add_icon))
          .size(width: (bottomIconSize - 4), height: (bottomIconSize - 4))
        }.width(100.percent)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
      }.padding(left: 10, right: 10, top: 5)
      .expandSafeArea(
        types: [SafeAreaType.SYSTEM],
        edges: [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]
      )
    }.width(100.percent)
    .height(100.percent)
    .backgroundColor(Color(242, 241, 247))
    .expandSafeArea(
      types: [SafeAreaType.SYSTEM],
      edges: [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]
    )
  }
}