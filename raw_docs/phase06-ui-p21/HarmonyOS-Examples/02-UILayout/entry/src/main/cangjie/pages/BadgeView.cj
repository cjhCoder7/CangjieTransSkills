/**
 * Created on 2025/8/5
 */
package ohos_app_cangjie_entry.pages

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.components.global.{PageHeader, SectionTitle, DescriptionText}
import ohos_app_cangjie_entry.utils.{countInnerWidth, countSubWidth}
import ohos_app_cangjie_entry.components.Badge.{NumberBadgeBand, PositionBadgeBand, ChatAvatar, PseudoBadgeBand, PseudoBadgeWithPadBand}
import ohos.resource_manager.*
import cj_res_entry.app


@Entry
@Component
class BadgeView {
    let scroller: Scroller = Scroller()

    func build() {
        Column() {
            PageHeader(title: "消息气泡")

            Scroll(scroller) {
                Column() {
                    SectionTitle(title: "简介")
                    DescriptionText(content: "Badge 主要用于聊天场景下描绘消息气泡")
                    NumberBadgeBand()
                    PositionBadgeBand()

                    SectionTitle(title: "伪消息气泡")
                    DescriptionText(content: "通过绝对布局来模仿消息气泡")
                    PseudoBadgeBand()
                    DescriptionText(content: "带空隙的版本")
                    PseudoBadgeWithPadBand()
                }.padding(left: viewPadX.lpx, right: viewPadX.lpx, bottom: viewPadTop.lpx)
            }.padding(bottom: 100.lpx).scrollable(ScrollDirection.Vertical)
        }
    }
}