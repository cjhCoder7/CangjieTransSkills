/**
 * Created on 2025/8/11
 */
package ohos_app_cangjie_entry.pages

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.components.global.{PageHeader, SectionTitle, DescriptionText}
import ohos_app_cangjie_entry.components.List.{SimpleList, AddMoreList}
import ohos_app_cangjie_entry.components.List.PaginationList


@Entry
@Component
public class ListView {
    let scroller: Scroller = Scroller()  // 外层垂直流动

    func build() {
        Column() {
            PageHeader(title: "列表")

            Scroll(scroller) {
                Column() {
                    SectionTitle(title: "简介")
                    DescriptionText(content: "List 是列表本身, ListItem 是列表项, ListItemGroup 则将列表项分组。")

                    SectionTitle(title: "列表示例")
                    DescriptionText(content: "简单列表")
                    SimpleList()

                    DescriptionText(content: "点击按钮显示更多")
                    AddMoreList()

                    DescriptionText(content: "分页")
                    PaginationList()

                }.padding(left: viewPadX.lpx, right: viewPadX.lpx, top: viewPadTop.lpx)
            }.padding(bottom: 100.lpx).scrollable(ScrollDirection.Vertical)
        }.padding(bottom: 100.lpx)
    }
}