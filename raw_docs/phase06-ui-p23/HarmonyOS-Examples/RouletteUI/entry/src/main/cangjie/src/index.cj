package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.hilog.Hilog
import ohos.ability.*
import ohos_app_cangjie_entry.model.{TabItemData, TabList}
import ohos_app_cangjie_entry.page.home.{Home}

@Entry
@Component
class MyView {
    @Provide
    var currentIndex: Int32 = 0

    var controller: TabsController = TabsController()

    protected override func aboutToAppear() {
    }

    func build() {
        Column {
            Tabs(BarPosition.End, this.controller, this.currentIndex) {
                TabContent() {
                    Home()
                }
                TabContent() {
                    Text("随机数")
                }
                TabContent() {
                    Text("更多")
                }
            }.scrollable(false).barHeight(0).layoutWeight(1).onChange({
                index: Int32 => this.currentIndex = index
            })
            //自定义TabBar
            CustomTabBar()
        }
    }
}

@Component
public class CustomTabBar {
    func build() {
        Flex(
            FlexParams(direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center
        )) {
            ForEach(
                TabList,
                itemGeneratorFunc: {
                    item: TabItemData, tabIndex: Int64 => TabItem(tabBarIndex: Int32(tabIndex), data: item)
                }
            )
        }.height(60)
    }
}

@Component
public class TabItem {
    @Consume
    var currentIndex: Int32

    var tabBarIndex: Int32
    var data: TabItemData

    func build() {
        Column(5) {
            // 图标
            Image(if (this.currentIndex == this.tabBarIndex) {
                data.sel_img
            } else {
                data.nor_img
            }).width(25).height(25)

            //页签名称
            Text(data.text).fontSize(16).fontColor(
                if (this.currentIndex == this.tabBarIndex) {
                @r(app.color.home_table_sel)
            } else {
                @r(app.color.home_table_nor)
            })
        }.onClick({
            event => this.currentIndex = this.tabBarIndex
        }).width(100.percent)
    }
}
