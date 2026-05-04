/**
 * Created on 2024/9/9
 */
package functionalscenes

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.*

import std.collection.*

import functionalscenes.model.*
import cj_res_functionalscenes.*

// 主页瀑布流列表
// FIXME: 由于仓颉暂不支持WaterFlow组件，因此只能先用List组件替代
@Component
public class FunctionalScenes {
    @Link var listData: Array<SceneModuleInfo>
    var dataSource: ListDataSource = ListDataSource()
    @State var tabsIndex: Int64 = 0
    let tabsController = TabsController()
    private let scrollController = Scroller()

    protected override func aboutToAppear(): Unit {
        this.dataSource = ListDataSource(this.listData)
    }

    @Builder
    func tabBuilder(index: Int64, name: String) {
        Stack() {
            Column() {
            }
            .width(if (this.tabsIndex == index) { 97 } else { 71 })
            .backgroundColor(if (this.tabsIndex == index) { 0x0A59F7 } else { 0x000000 })
            .opacity(if (this.tabsIndex == index) { 1.0 } else { 0.05 })
            .height(38)
            .borderRadius(21)

            Text(name)
                .fontSize(14)
                .fontColor(if (this.tabsIndex == index) { Color.WHITE } else { Color.BLACK })
                .opacity(if (this.tabsIndex == index) { 1.0 } else { 0.8 })
                .height(100.percent)
        }
        .margin(
            left: if (index != 0 && index != TAB_DATA.size) {9} else {0},
            right: if (index != 0 && index != TAB_DATA.size) {9} else {0}
        )
        .align(Alignment.Center)
        .onClick({ event =>
            this.tabsIndex = index
            this.tabsController.changeIndex(Int32(index))
        })
    }

    @Builder
    func tabsMemu() {
        Menu() {
            ForEach(TAB_DATA, itemGeneratorFunc: { item: TabDataModel, index: Int64 =>
                MenuItem(startIcon: "", content: item.navData, endIcon: "", labelInfo: "")
                    .onClick({event =>
                        this.tabsIndex = item.id
                        this.tabsController.changeIndex(Int32(item.id))
                        if (item.id > 2) {
                            this.scrollController.scrollToIndex(Int32(item.id))
                        }
                    })
            })
        }
    }

    func build() {
        Column() {
            Row() {
                Stack() {
                    List(scroller: this.scrollController) {
                        ForEach(TAB_DATA, itemGeneratorFunc: { item: TabDataModel, index: Int64 =>
                            ListItem() {
                                this.tabBuilder(index, item.navData)
                            }
                        })
                    }
                    .margin(top: 3)
                    .height(38)
                    .listDirection(Axis.Horizontal)
                    .padding(right: 46)
                    .scrollBar(BarState.Off)

                    Row() {
                        Row() {
                            Image(@r(app.media.ic_public_more))
                                .width(20)
                        }
                        .bindMenu(builder: this.tabsMemu)   // FIXME: 差异点：ArkTS接口没有命名参数
                        .justifyContent(FlexAlign.Center)
                        .width(43)
                        .height(43)
                        .borderRadius(100)
                        .backgroundColor(0xD8D8D8)
                    }
                    .linearGradient(
                        angle: 90.0,
                        colors: [(Color(241, 241, 241, alpha: 0.0), 0.0), (Color(0xF1F3F5), 0.2), (Color(0xF1F3F5), 1.0)]
                    )
                    .justifyContent(FlexAlign.End)
                    .width(60)
                    .height(43)
                }
                .alignment(Alignment.TopEnd)    //FIXME: ArkTS中对应接口为 alignContent()
            }
            .padding(left: 13, right: 13)
            .margin(top: 8)

            Tabs(this.tabsController) {
                ForEach(TAB_DATA, itemGeneratorFunc: { tabItem: TabDataModel, index: Int64 =>
                    TabContent() {
                        Column() {
                            List() {    //FIXME: 仓颉暂不支持 WaterFlow，只能先用List
                                LazyForEach(this.dataSource, itemGeneratorFunc: { item: SceneModuleInfo, index =>
                                    ListItem() {
                                        if (tabItem.navData == "全部" || tabItem.navData == item.category) {
                                            MethodPoints(listData: item)
                                        }
                                    }
                                })
                            }
                            .nestedScroll(NestedScrollOptions(NestedScrollMode.PARENT_FIRST, NestedScrollMode.SELF_FIRST))
                            .cachedCount(1)
                            .width(100.percent)
                            .scrollBar(BarState.Off)

                            // TODO: 由于TabContent无法将元素顶部对齐，此处使用 Blank 将元素挤到顶部。
                            Blank().layoutWeight(1)

                        }
                    }
                    .backgroundColor(0xF1F1F1)
                })
            }
            .margin(top: 8)
            .padding(left: 13, right: 13)
            .barWidth(0)
            .barHeight(0)
            .animationDuration(0)
            .onChange({ index: Int32 =>
                this.tabsIndex = Int64(index)
                this.scrollController.scrollToIndex(index)
            })
            //.onAnimationStart   // FIXME: 仓颉 Tabs 组件暂不支持 onAnimationStart 属性
        }
        .padding(bottom: 80)
        .height(100.percent)
        .backgroundColor(0xF1F1F1)
    }
}

/**
 * 瀑布流列表项组件布局
 */
//@Reusable //FIXME: 仓颉暂不支持 Reusable 宏
@Component
class MethodPoints {
    @State var listData: SceneModuleInfo = SceneModuleInfo(imageSrc: @r(app.media.ic_public_more), name: "", appUri: "", category: "UI布局")

    func build() {
        Column() {
            Text(this.listData.name)
                .padding(left: 16, right: 16)
                .width(100.percent)
                .fontColor(Color.BLACK)
                .textAlign(TextAlign.Start)
                .maxLines(1)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .margin(top: 10, bottom: 10)
                .textOverflow(TextOverflow.Ellipsis)

            Row() {
                Column() {
                    Row() {
                        Text("难度")
                            .fontColor(Color.BLACK)
                            .opacity(0.6)
                            .textAlign(TextAlign.Start)
                            .maxLines(1)
                            .height(18)
                            .fontSize(12)
                        Rating(rating: Float64(this.listData.ratingNumber), indicator: true)
                            .stars(5)
                    }
                }
                .width(50.percent)
                .alignItems(HorizontalAlign.Start)
                .margin(left: 8)

                Column() {
                    Image(this.listData.imageSrc)
                        .objectFit(ImageFit.Contain)
                        .shadow(radius: 8)
                }
                .width(45.percent)
            }
            .alignItems(VerticalAlign.Top)
            .margin(bottom: 8)
        }
        .backgroundColor(Color.WHITE)
        .borderRadius(8)
        .margin(top: 4, bottom: 4)
        .onClick({event =>
            Router.push(url: this.listData.appUri)
        })
    }
}