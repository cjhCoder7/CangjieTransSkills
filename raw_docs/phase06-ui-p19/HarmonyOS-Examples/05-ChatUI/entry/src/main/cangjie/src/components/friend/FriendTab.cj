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
public class FriendTab {
  @State var activeInd: UInt32 = 0;

  let tabBarArr = ["好友", "分组"]

  let userList = [user2, user3, user4, user5, user6, user7, user8, user9, user10]

  func tabOnChange(index: UInt32) {
    if (activeInd != index) {
      this.activeInd = index
    }
  }

  @Builder
  func swiperContent() {
    Column(10) {
      ForEach(userList, itemGeneratorFunc: { user: User, index: Int64 =>
            FriendListItem(user: user);
      })
    }.width(100.percent)
    .padding(left: 12, right: 12)
  }

  func build() {
    Column(20) {
      Row(10) {
        ForEach(tabBarArr, itemGeneratorFunc:{content: String, ind: Int64 =>
          if(UInt32(ind) == activeInd) {
            Text(content).fontColor(Color(68, 147, 230))
            .decoration(decorationType: TextDecorationType.Underline, color: Color(68, 147, 230))
            .onClick({ e: ClickEvent => tabOnChange(UInt32(ind))})
          } else {
            Text(content).onClick({ e: ClickEvent => tabOnChange(UInt32(ind))})
          }
        })
      }.width(100.percent).padding(left: 12, right: 12)

      Swiper() {
        swiperContent()

        swiperContent()
      }.loop(false)
      .index(activeInd)
      .indicator(false)
      .onChange({
        index => tabOnChange(UInt32(index))
      })
    }.backgroundColor(0xffffff)
    .padding(top: 20, bottom: 50)
  }
}