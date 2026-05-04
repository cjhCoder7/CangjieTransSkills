package ohos_app_cangjie_entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.components.avatar.Avatar
import ohos_app_cangjie_entry.components.index.*
import ohos.resource_manager.*
import cj_res_entry.app
import ohos_app_cangjie_entry.components.index.*
import ohos_app_cangjie_entry.util.*
import ohos_app_cangjie_entry.components.chat.ChatList
import ohos_app_cangjie_entry.components.friend.FriendList
import ohos_app_cangjie_entry.components.dynamic.DynamicList

@Entry
@Component
class IndexView {
  // 当前选中的tab的Index
  @State var activeInd: Int64 = 0

  func build() {
    Column() {
      if (activeInd != 4) {
        Row() {
          Avatar(src: @r(app.media.avatar_01), size: 30)

          Row() {
            if (activeInd == 0) {
              Column() {
                Text("Michael")

                Row() {
                  Row().size(width: 10, height: 10)
                  .borderRadius(50.percent)
                  .backgroundColor(Color(107, 224, 144))
                  .margin(right: 5)

                  Text("手机在线").fontSize(8)
                }
              }.alignItems(HorizontalAlign.Start)

              Image(@r(app.media.add)).size(width: 20, height: 20)
            } else if (activeInd == 3) {
              Text("联系人")

              Image(@r(app.media.add_user)).size(width: 25, height: 25)
            }
          }.justifyContent(FlexAlign.SpaceBetween)
          .layoutWeight(1)
          .margin(left: 10)
          .alignItems(VerticalAlign.Center)
        }.padding(20)
        .width(100.percent)
        .alignItems(VerticalAlign.Center)
      }

      Scroll() {
        if(activeInd == 0) {
          ChatList()
        } else if (activeInd == 3) {
          FriendList()
        } else if (activeInd == 4) {
          DynamicList()
        }
      }.width(100.percent)
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .align(Alignment.TopStart)

      Row() {
        TabBar(activeInd: activeInd)
      }
    }.height(100.percent)
    .width(100.percent)
    .backgroundColor(0xf2f7ff)
    .expandSafeArea(
      types: [SafeAreaType.SYSTEM],
      edges: [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]
    )
  }
}
