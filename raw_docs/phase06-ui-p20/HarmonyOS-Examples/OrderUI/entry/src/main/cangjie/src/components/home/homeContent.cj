/**
 * Created on 2024/8/10
 */
package ohos_app_cangjie_entry.components.home

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.concurrency.*
import ohos.state_macro_manage.*
import cj_res_entry.app
import ohos.prompt_action.*
import std.sync.*
import ohos_app_cangjie_entry.models.{ShopInfoModel}
import ohos_app_cangjie_entry.api.*

@Component
public class HomeContent {
    @State
    var shopList: ObservedArrayList<ShopInfoModel> = ObservedArrayList<ShopInfoModel>()

    @StorageLink["bottomRectHeight"] var bottomRectHeight: Length = Length(0, unitType : LengthType.px)
    @StorageLink["topRectHeight"] var topRectHeight: Length = Length(0, unitType : LengthType.px)

    let scroller = Scroller()

    var tempPage: Int64 = 1
    let tempPageSize: Int64 = 5
    var isEnd = false

    @State
    var loading = false

    private func getShopList() {
        if (isEnd) {
            return
        }
        if (loading) {
            return
        }
        launch {
            loading = true
        }
        let queryShopList = ShopApi.getShopList(tempPage, tempPageSize)
        launch {
            shopList.appendAll(queryShopList)
            AppLog.info("shopListSize = ${shopList.size}")
            tempPage++
            if (queryShopList.size < tempPageSize) {
                isEnd = true
            }
            loading = false
        }
    }

    protected override func aboutToAppear() {
        tempPage = 1
        isEnd = false
        shopList = ObservedArrayList<ShopInfoModel>()
//        spawn {
            getShopList()
//        }
    }



    func build() {
        Column() {
            HomeHeader()
            Scroll(this.scroller) {
                Column() {
                    HomeBanner()

                    HomeMenu()

                    HomeShopRecommend()

                    HomeShopList(shopList: shopList)

                    if (loading) {
                        Column() {
                            Text("努力加载中,请稍后")
                                .fontSize(@r(app.float.font_size_small))
                                .fontColor(@r(app.color.font_color_fourth))
                                .textAlign(TextAlign.Center)
                                .width(100.percent)
                             LoadingProgress()
                                .width(@r(app.float.loading_progress_width))
                                .aspectRatio(1)
                        }
                        .width(100.percent)
                        .margin(top: @r(app.float.loading_progress_margin_top), right: @r(app.float.loading_progress_margin_other),
                            bottom: @r(app.float.loading_progress_margin_other), left: @r(app.float.loading_progress_margin_other))
                    }
                }
            }
            .scrollable(ScrollDirection.Vertical)
            .scrollBar(BarState.Off)
            .height(100.percent)
            .layoutWeight(1)
            .onScrollEdge({ edge =>
                match(edge) {
                    case Edge.Top => nativeLog("Top")
                    case Edge.Bottom =>
                        spawn {
                            getShopList()
                        }
                    case _ => nativeLog("None")
                }
            })
        }
        .height(100.percent)
        .width(100.percent)
    }
}