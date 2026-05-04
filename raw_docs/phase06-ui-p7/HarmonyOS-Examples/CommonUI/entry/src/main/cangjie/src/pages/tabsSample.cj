/**
 * Created on 2024/5/14
 */
package ohos_app_cangjie_entry.pages

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Entry
@Component
class TabsView {
    var controller: TabsController = TabsController()
    func build() {
        Column() {
            Tabs(BarPosition.Start, this.controller) {
                TabContent {
                    Column()
                    .width(100.percent)
                    .height(100.percent)
                    .backgroundColor(0x283F3E)
                }
                .tabBar("铜器青")

                TabContent {
                    Column()
                    .width(100.percent)
                    .height(100.percent)
                    .backgroundColor(0x970804)
                }
                .tabBar("淡枣红")

                TabContent() {
                    Column()
                    .width(100.percent)
                    .height(100.percent)
                    .backgroundColor(0xF0A72E)
                }
                .tabBar("金鸢黄")

                TabContent() {
                    Column()
                    .width(100.percent)
                    .height(100.percent)
                    .backgroundColor(0xDFBE96)
                }
                .tabBar("鹿角棕")
            }
            .vertical(true)
            .scrollable(true)
            .barMode(BarMode.Fixed)
            .barWidth(70)
            .barHeight(150)
            .animationDuration(400)
            .onChange({index: Int32 =>
                nativeLog("${index}")
            })
            .width(90.percent)
            .backgroundColor(0xEEEEEE)
        }
        .width(100.percent)
        .height(150)
        .margin(top: 5)
    }
}