package ohos_app_cangjie_entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.app
import ohos.resource_manager.*
import ohos.router.*
import ohos_app_cangjie_entry.components.entry.EntryItem


@Entry
@Component
class EntryView {
    let padX: Int64 = 40
    let padTop: Int64 = 100
    let itemGap: Int64 = 40


    func build() {
        Column(itemGap.lpx) {
            EntryItem(iconSrc: @r(app.media.scroll_icon), title: "滑动窗口",
                components: "Scroll", url: "ScrollView")
            EntryItem(iconSrc: @r(app.media.list_icon), title: "列表",
                components: "List ListItem ListItemGroup", url: "ListView")
            EntryItem(iconSrc: @r(app.media.badge_icon), title: "消息气泡 Badge",
                components: "Badge", url: "BadgeView")
            EntryItem(iconSrc: @r(app.media.block_icon), title: "块 / 矩形 / 水平布局 / 垂直布局",
                components: "Row Column RowSplit ColumnSplit", url: "SimpleLayoutView")
        }.padding(left: padX, right: padX, top: padTop).width(100.percent)
    }
}
