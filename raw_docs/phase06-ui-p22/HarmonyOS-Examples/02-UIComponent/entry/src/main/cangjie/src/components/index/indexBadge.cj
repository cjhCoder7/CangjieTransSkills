/**
 * Created on 2024/7/30
 */
package ohos_app_cangjie_entry.components.index

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import ohos.resource_manager.*

@Component
public class IndexBadge {
  let badgeStyle = BadgeStyle(color: Color(0xFFFFFF), fontSize: 20, badgeSize: 30,
              badgeColor: Color.RED)

  func build() {
    Column() {
      Text("Badge").title()

      Column(6) {
        Badge(
          BadgeParams(
            count: 12,
            style: badgeStyle,
            position: BadgePosition.Right,
          )
        ) {
          Text("Mom").msgTitle()
        }.width(90.percent)

        Badge(
          BadgeParams(
            count: 6,
            style: badgeStyle,
            position: BadgePosition.Right,
          )
        ) {
          Text("Friend").msgTitle()
        }.width(90.percent)

        Badge(
          BadgeParams(
            count: 47,
            style: badgeStyle,
            position: BadgePosition.Right,
          )
        ) {
          Text("Customer").msgTitle()
        }.width(90.percent)
      }
    }.card().layoutWeight(1).height(150)
    .padding(10).borderWidth(1)
    .redirect("BadgeView")
  }
}