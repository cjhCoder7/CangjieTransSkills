/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.components.dynamic

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.*
import ohos.resource_manager.*

let DYNAMIC_LIST_ITEM_PADDING_HORIZONTAL = 20

@Builder
func DynamicListItem(icon!: CJResource, title!: String) {
  // 纯图标+文本的动态项目
  Row() {
    Row(5) {
      Image(icon).size(width: 30, height: 30)

      Text(title)
    }

    Image(@r(app.media.right_arrow)).size(width: 30, height: 30)
  }.width(100.percent)
  .padding(left: 10, right: 10)
  .justifyContent(FlexAlign.SpaceBetween)
}

@Component
public class DynamicList {
  func build() {
    Column() {
      DynamicListItem(icon: @r(app.media.oo_zone), title: "好友动态")

      Divider().strokeWidth(8).color(0xf1f3f5).margin(top: 10)

      Column(20) {
        DynamicListItem(icon: @r(app.media.game_center), title: "游戏中心")

        DynamicListItem(icon: @r(app.media.partner), title: "结伴")

        DynamicListItem(icon: @r(app.media.close_sides), title: "附近")

        DynamicListItem(icon: @r(app.media.emaoshiji), title: "鹅毛市集")

        DynamicListItem(icon: @r(app.media.battalion), title: "元梦营地")
      }.padding(top: 10, bottom: 10)

      Divider().strokeWidth(8).color(0xf1f3f5)

      Column(20) {
        DynamicListItem(icon: @r(app.media.sports), title: "运动")

        DynamicListItem(icon: @r(app.media.small_games), title: "小游戏")

        DynamicListItem(icon: @r(app.media.live), title: "直播")

        DynamicListItem(icon: @r(app.media.collect_cards), title: "集卡")

        DynamicListItem(icon: @r(app.media.shop), title: "购物")

        DynamicListItem(icon: @r(app.media.cartoon), title: "动漫")

        DynamicListItem(icon: @r(app.media.read), title: "阅读")

        DynamicListItem(icon: @r(app.media.small_videos), title: "微视")

        DynamicListItem(icon: @r(app.media.music), title: "音乐")

        DynamicListItem(icon: @r(app.media.more), title: "更多")
      }.padding(top: 10, bottom: 10)
    }.width(100.percent)
    .padding(top: 20)
    .backgroundColor(0xffffff)
  }
}
