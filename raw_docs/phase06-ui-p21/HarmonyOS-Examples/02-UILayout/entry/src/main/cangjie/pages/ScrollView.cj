/**
 * Created on 2025/8/12
 */
package ohos_app_cangjie_entry.pages

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.components.ScrollLayout.{HouseScrollBand}
import ohos_app_cangjie_entry.components.global.{PageHeader, SectionTitle, DescriptionText}
import ohos_app_cangjie_entry.components.ScrollLayout.HouseScrollFixedBand


@Entry
@Component
public class ScrollView {
    let scroller: Scroller = Scroller()

    func build() {
        Column() {
            PageHeader(title: "滑动窗口")

            Scroll(scroller) {
                Column() {
                    SectionTitle(title: "简介")
                    DescriptionText(content: "Scroll会创建一个可滑动的区域, 当内部元素的长度/宽度超过滑动区域时, 该组件允许用户通过滑动来看到这些内容")

                    SectionTitle(title: "滑动示例")
                    HouseScrollBand()

                    SectionTitle(title: "滑动示例(每次固定滑动一页)")
                    HouseScrollFixedBand()
                }.padding(left: viewPadX.lpx, right: viewPadX.lpx, top: viewPadTop.lpx)
            }.padding(bottom: 100.lpx).scrollable(ScrollDirection.Vertical)
        }.width(100.percent)
    }
}