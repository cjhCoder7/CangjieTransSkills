/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.components.friend

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import ohos_app_cangjie_entry.global.*
import ohos_app_cangjie_entry.util.*
import cj_res_entry.app
import ohos.resource_manager.*
import ohos_app_cangjie_entry.mock.*

@Builder
func MoreItem(content: String) {
  Row() {
    Text(content).fontSize(16)

    Image(@r(app.media.right_arrow)).size(width: 20, height: 20)
  }.justifyContent(FlexAlign.SpaceBetween)
  .alignItems(VerticalAlign.Center)
  .width(100.percent)
}

@Component
public class FriendList {
  func build() {
    Column(10) {
      Column() {
        Row() {
          Row() {
            Image(@r(app.media.search)).size(width: 20, height: 20).margin(right: 10)

            Text("搜索").fontSize(14).fontColor(COLOR_GRAY)
          }.width(100.percent)
          .justifyContent(FlexAlign.Center)
          .padding(top: 6, bottom: 6)
          .backgroundColor(0xf2f7ff)
          .borderRadius(6)
        }.width(100.percent)
        .margin(bottom: 20)

        Text("可能想认识的人").fontSize(14)
        .fontColor(COLOR_GRAY)
        .width(100.percent)

        Column(20) {
          FriendListItem(user: user12)

          FriendListItem(user: user13)
        }.padding(top:20, bottom: 20)
        .alignItems(HorizontalAlign.Start)

      }.width(100.percent)
      .padding(left: 12, right: 12, top: 12)
      .backgroundColor(0xffffff)
      .borderRadius(topLeft: 15.vp, topRight: 15.vp)

      Column(30) {
        MoreItem("新朋友")

        MoreItem("群通知")
      }.padding(left: 12, right: 12, top: 15, bottom: 15)
      .backgroundColor(0xffffff)

      Scroll() {
        FriendTab()
      }.scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
      .align(Alignment.TopStart)
    }.width(100.percent)
    .height(100.percent)
  }
}