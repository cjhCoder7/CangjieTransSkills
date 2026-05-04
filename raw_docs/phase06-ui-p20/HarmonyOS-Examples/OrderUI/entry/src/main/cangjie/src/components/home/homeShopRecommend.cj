/**
 * Created on 2024/8/11
 */
package ohos_app_cangjie_entry.components.home

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import cj_res_entry.app
import ohos_app_cangjie_entry.constants.*
import ohos_app_cangjie_entry.models.{ShopInfoModel}
import std.collection.ArrayList
import ohos_app_cangjie_entry.utils.ResourceUtil

@Component
public class HomeShopRecommend {
    @StorageLink["currentBreakpoint"]
    var currentBreakpoint: String = ""
    @Builder
    func shopInfo(shopInfoModel: ShopInfoModel) {
        Column(BaseConstants.ROW_COLUMN_SPACE_THIN) {
            Stack(Alignment.Bottom) {
                Image(shopInfoModel.getIcon()).height(80.percent).aspectRatio(1)

                Text(shopInfoModel.getScore() + " 分").fontSize(@r(app.float.font_size_small)).fontColor(
                    @r(app.color.font_color_highlight))
            }

            Text(shopInfoModel.getTitle()).fontSize(@r(app.float.font_size_normal))
        }.width(100.percent).height(100.percent)
    }

    @Builder
    func shopSwiper(shopInfos: ArrayList<ShopInfoModel>, showNumber: Int32) {
        Swiper() {
            ForEach(
                shopInfos,
                itemGeneratorFunc: {
                    item: ShopInfoModel, _: Int64 => shopInfo(item)
                }
            )
        }.displayCount(showNumber).cachedCount(2).autoPlay(true).interval(4000).loop(true).duration(1000).itemSpace(
            Length(BaseConstants.SWIPER_SPACE_NORMAL)).curve(Curve.Linear).vertical(false).indicator(false).width(
            100.percent).layoutWeight(1)
    }

    @Builder
    func shopRecommend(title: String, shopInfos: ArrayList<ShopInfoModel>, showNumber: Int32) {
        Column() {
            Text(title).width(100.percent).textAlign(TextAlign.Start).fontSize(@r(app.float.font_size_large)).fontWeight(
                BaseConstants.FONT_WEIGHT_WIDE)
            shopSwiper(shopInfos, showNumber)
        }.width(100.percent).height(100.percent)
    }

    func build() {
        GridRow(
            columns: GridRowColumnOption(sm: BreakpointConstants.GRID_ROW_COLUMNS[2],
                md: BreakpointConstants.GRID_ROW_COLUMNS[1], lg: BreakpointConstants.GRID_ROW_COLUMNS[0]),
            gutter: GutterOption(x: Length(BaseConstants.GRID_ROW_GUTTER_X), y: Length(BaseConstants.GRID_ROW_GUTTER_Y))
        ) {
            GridCol() {
                Row() {
                    shopRecommend("附近商家", HomeConstants.NEARBY_SHOP_LIST, 4)
                }
                .height(HomeConstants.HOME_SHOP_RECOMMEND_HEIGHT)
                .width(100.percent)
                .padding(
                    right: ResourceUtil.getBasePadding().getValue(this.currentBreakpoint),
                    left: ResourceUtil.getBasePadding().getValue(this.currentBreakpoint)
                )
                .backgroundColor(@r(app.color.background_primary))
            }.span(
                GridColColumnOption(sm: BreakpointConstants.GRID_COL_SPANS[4], md: BreakpointConstants.GRID_COL_SPANS[4],
                lg: BreakpointConstants.GRID_COL_SPANS[4])
            )

            GridCol() {
                Row() {
                    shopRecommend("优惠专区", HomeConstants.DISCOUNT_SHOP_LIST, 2)
                }
                .height(HomeConstants.HOME_SHOP_RECOMMEND_HEIGHT)
                .width(100.percent)
                .padding(
                    right: ResourceUtil.getBasePadding().getValue(this.currentBreakpoint),
                    left: ResourceUtil.getBasePadding().getValue(this.currentBreakpoint)
                )
                .backgroundColor(@r(app.color.background_primary))
            }
            .span(
                GridColColumnOption(sm: BreakpointConstants.GRID_COL_SPANS[2], md: BreakpointConstants.GRID_COL_SPANS[2],
                lg: BreakpointConstants.GRID_COL_SPANS[2])
            )

            GridCol() {
                 Row() {
                     shopRecommend("秒杀专区", HomeConstants.SECKILL_SHOP_LIST, 2)
                }
                .height(HomeConstants.HOME_SHOP_RECOMMEND_HEIGHT)
                .width(100.percent)
                .padding(
                    right:  ResourceUtil.getBasePadding().getValue(this.currentBreakpoint),
                    left:  ResourceUtil.getBasePadding().getValue(this.currentBreakpoint)
                )
                .backgroundColor(@r(app.color.background_primary))
            }.span(
                GridColColumnOption(sm: BreakpointConstants.GRID_COL_SPANS[2], md: BreakpointConstants.GRID_COL_SPANS[2],
                lg: BreakpointConstants.GRID_COL_SPANS[2]))

            GridCol() {
                Row() {
                    shopRecommend("新品商家", HomeConstants.NEW_SHOP_LIST, 4)
                }.height(HomeConstants.HOME_SHOP_RECOMMEND_HEIGHT).width(100.percent).backgroundColor(
                    @r(app.color.background_primary)).padding(
                    right: ResourceUtil.getBasePadding().getValue(this.currentBreakpoint),
                    left: ResourceUtil.getBasePadding().getValue(this.currentBreakpoint)
                )
            }.span(
                GridColColumnOption(sm: BreakpointConstants.GRID_COL_SPANS[4], md: BreakpointConstants.GRID_COL_SPANS[4],
                lg: BreakpointConstants.GRID_COL_SPANS[4]))
        }
        .padding(
            right:  ResourceUtil.getBasePadding().getValue(this.currentBreakpoint),
            left:  ResourceUtil.getBasePadding().getValue(this.currentBreakpoint)
        )
        .width(100.percent)
    }
}
