/**
 * Created on 2024/8/25
 */
package ohos_app_cangjie_entry.components.home

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import ohos_app_cangjie_entry.constants.*
import cj_res_entry.app
import ohos_app_cangjie_entry.utils.ResourceUtil
import std.collection.ArrayList
import ohos_app_cangjie_entry.models.{TabBar, Temp}
import ohos_app_cangjie_entry.components.me.Me
import ohos_app_cangjie_entry.components.message.Message

@Component
public class Home {
    @State
    var currentIndex: Int32 = 0
    @StorageLink["bottomRectHeight"] var bottomRectHeight: Length = Length(0, unitType : LengthType.px)
    @StorageLink["topRectHeight"] var topRectHeight: Length = Length(0, unitType : LengthType.px)

    let tabList: ArrayList<TabBar> =  ArrayList<TabBar>(
            TabBar(@r(app.media.ic_home), @r(app.media.ic_home_select), "首页", "home"),
            TabBar(@r(app.media.ic_message), @r(app.media.ic_message_select), "消息", "message"),
            TabBar(@r(app.media.ic_me), @r(app.media.ic_me_select), "我的", "me")
        )

    @Builder
    func tabBarBuilder(index: Int64) {
        Column() {
//            if (item.getName() == this.tabList.getData(Int64(this.currentIndex)).getName()) {
            if(index == Int64(this.currentIndex)) {
                Image(this.tabList[index].getSelectIcon())
                .width(20)
                .height(20)

                Text(this.tabList[index].getTitle())
                .fontSize(@r(app.float.font_size_small))
                .fontColor(@r(app.color.text_color_primary))

            }else {
                Image(this.tabList[0].getIcon())
                .width(20)
                .height(20)

                Text(this.tabList[0].getTitle())
                .fontSize(@r(app.float.font_size_small))
                .fontColor(@r(app.color.text_color_primary))
            }
        }
    }


    func build() {
        Tabs(BarPosition.End) {
            ForEach(this.tabList, itemGeneratorFunc: { tabBar: TabBar, index: Int64 =>
                TabContent() {
                    if (index == 0) {
                        HomeContent()
                    } else if (index == 1) {
                        Message()
                    } else if (index == 2) {
                        Me()
                    }
                }
                // TODO 这里图标先写死，等搞清楚如何自定义tabBar时再来实现，自定义tabBar，使用tabBarBuilder()函数
                // TODO 这里icon目前还不支持@r(app.media.ic_home)这种写法，等官方回复再说
                .tabBar(icon: @r(app.media.ic_home), text: tabBar.getTitle())
            })
        }
        .vertical(false)
        .scrollable(true)
        .barMode(BarMode.Fixed)
        .animationDuration(400)
        .onChange({index: Int32 => this.currentIndex = index})
        .width(100.percent)
        .backgroundColor(@r(app.color.background_secondary))
    }
}
