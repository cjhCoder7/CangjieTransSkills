/**
 * Created on 2024/9/9
 */
package customtabbar.view

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_customtabbar.*
import ohos.router.*

import customtabbar.model.*

const HOME_TAB_BAR_INDEX = 0        // 首页的tab下表
const COMMUNITY_TAB_BAR_INDEX = 2   // 社区的tab下标
const ARC_MARGIN_TOP    = -15       // 圆弧的上外间距为 -15

@Builder
public func buildCustonTab() {
    CustomTabBarPage()
}

@Entry
@Component
public class CustomTabBarPage {
    @Provide var selectedIndex: Int64 = 0   // 初始化被选定的 tabBar 下表
    private let controller: TabsController = TabsController()

    func build() {
        Column() {
            Tabs(BarPosition.End, this.controller, Int32(this.selectedIndex)) {
                // 首页模块
                TabContent() {
                    Text("首页")
                        .fontSize(26)
                }

                // 新品模块
                TabContent() {
                    Text("新品")
                        .fontSize(26)
                }

                // 社区模块
                TabContent() {
                    Text("社区")
                        .fontSize(26)
                }

                // 购物车模块
                TabContent() {
                    Text("购物车")
                        .fontSize(26)
                }

                // 我的模块
                TabContent() {
                    Text("我的")
                        .fontSize(26)
                }
            }
            .vertical(false)
            .scrollable(false)
            .layoutWeight(1)
            .backgroundColor(0xFFDBD9D9)
            .barHeight(0)
            .onChange({ index: Int32 => this.selectedIndex = Int64(index) })

            // 自定义 TabBar 组件
            CustomTabBar(selectedIndex: this.selectedIndex)
        }
        .width(100.percent)
        .height(100.percent)
    }
}

@Component
class CustomTabBar {
    @Link var selectedIndex: Int64
    @State var iconOffset: Int64 = 0    //初始化 tabBar 图片的偏移量

    func build() {
        Flex(FlexParams(direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center)) {
            // 数据量比较少的情况下推荐使用 ForEach，遇到数据量比较多的场景，如列表场景、瀑布流场景等，推荐使用 LazyForEach。
            ForEach(TABINFO, { item: TabBarDataType, index: Int64 =>
                TabItem(iconOffset: this.iconOffset, tabBarIndex: index, selectedIndex: this.selectedIndex)
            })
        }
        .height(60)
    }
}

@Component
class TabItem {
    @Prop var iconOffset: Int64     // 初始化 tabBar 图片的偏移量
    @Prop var tabBarIndex: Int64    // tabBar 下标
    @Link var selectedIndex: Int64  // 初始化被选定的 tabBar 下表

    func build() {
        Column() {
            Stack() {
                // 判断 tab 的下标是否为 2
                if (this.tabBarIndex == COMMUNITY_TAB_BAR_INDEX) {
                    Column() {
                        Image(
                            if (this.selectedIndex == this.tabBarIndex) {
                                TABINFO[this.tabBarIndex].selectedIcon
                            } else {
                                TABINFO[this.tabBarIndex].defaultIcon
                            }
                        )
                        .size(width: 43, height: 43)
                        .interpolation(ImageInterpolation.High) // TODO：知识点：使用interpolation属性对图片进行插值，使图片显示得更清晰
                    }
                    .width(52)
                    .height(52)
                    .borderRadius(24)
                    .margin(top: ARC_MARGIN_TOP)
                    .backgroundColor(Color.WHITE)
                    .justifyContent(FlexAlign.Center)
                } else {
                    Column() {
                        Image(
                            if (this.selectedIndex == this.tabBarIndex) {
                                TABINFO[this.tabBarIndex].selectedIcon
                            } else {
                                TABINFO[this.tabBarIndex].defaultIcon
                            }
                        )
                        .interpolation(ImageInterpolation.High)
                        .size(
                            width: if (this.selectedIndex == HOME_TAB_BAR_INDEX && this.selectedIndex == this.tabBarIndex) { 43 } else { 28 },
                            height: if (this.selectedIndex == HOME_TAB_BAR_INDEX && this.selectedIndex == this.tabBarIndex) { 43 } else { 28 }
                        )
                        // TODO：知识点：通过offset控制图片的纵向偏移。
                        .offset(
                            x: 0,   // FIXME: 差异点：ArkTS 中允许省略 x 的赋值，但仓颉必须指定。
                            y: if (this.selectedIndex == this.tabBarIndex && this.selectedIndex != COMMUNITY_TAB_BAR_INDEX) { this.iconOffset } else { 0 }
                        )
                        //.animation(...) // FIXME: 仓颉不支持该属性
                    }
                    .width(if (this.selectedIndex == HOME_TAB_BAR_INDEX && this.selectedIndex == this.tabBarIndex) {43} else {37})
                    .height(if (this.selectedIndex == HOME_TAB_BAR_INDEX && this.selectedIndex == this.tabBarIndex) {43} else {37})
                    .justifyContent(FlexAlign.Center)
                }
            }

            Text(TABINFO[this.tabBarIndex].title)
                .fontSize(14)
                .fontColor(if (this.selectedIndex == this.tabBarIndex) { Color(0xE6304F) } else { Color.BLACK })
                .visibility(if (this.selectedIndex == HOME_TAB_BAR_INDEX && this.selectedIndex == this.tabBarIndex) { Visibility.None } else { Visibility.Visible })
        }
        .width(60)
        .onClick({ event =>
            // 更新被选中的 tabBar 下标
            this.selectedIndex = this.tabBarIndex
            // 此处控制tabBar的Image 图片向上偏移
            this.iconOffset = -3
        })
    }
}