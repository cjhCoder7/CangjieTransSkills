/**
 * Created on 2024/8/12
 */
package ohos_app_cangjie_entry.components.home

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import cj_res_entry.app
import ohos_app_cangjie_entry.constants.*
import ohos_app_cangjie_entry.models.{ShopInfoModel, ProductInfoModel}
import std.collection.ArrayList
import std.format.*
import ohos_app_cangjie_entry.utils.ResourceUtil

@Component
public class HomeShopList {
    @StorageLink["currentBreakpoint"] var currentBreakpoint: String = ""
    @Prop
    var shopList: ObservedArrayList<ShopInfoModel>
    func build() {
        GridRow(
            columns: GridRowColumnOption(sm: BreakpointConstants.GRID_ROW_COLUMNS[2],
                md: BreakpointConstants.GRID_ROW_COLUMNS[1], lg: BreakpointConstants.GRID_ROW_COLUMNS[0]),
            gutter: GutterOption(x: Length(BaseConstants.GRID_ROW_GUTTER_X), y: Length(BaseConstants.GRID_ROW_GUTTER_Y))
        ) {
            ForEach(shopList, itemGeneratorFunc: {item: ShopInfoModel, index: Int64 =>
                GridCol() {
                    Row() {
                        Image(item.getIcon())
                            .layoutWeight(3)
                            .aspectRatio(1)
                        Column(BaseConstants.ROW_COLUMN_SPACE_THIN) {
                            Text(item.getTitle())
                                .fontSize(@r(app.float.font_size_large))
                                .fontColor(@r(app.color.font_color_primary))
                                .width(100.percent)
                            Row(BaseConstants.ROW_COLUMN_SPACE_NORMAL) {
                                Text(item.getScore() + " 分")
                                    .fontSize(@r(app.float.font_size_small))
                                    .fontColor(@r(app.color.font_color_highlight))
                                Text("月销售 ${item.getSaleNumber()} + ")
                                    .fontSize(@r(app.float.font_size_small))
                            }
                            .width(100.percent)
                            Row(BaseConstants.ROW_COLUMN_SPACE_NORMAL) {
                                ForEach(item.getLabels(), itemGeneratorFunc: {label: String, _: Int64 =>
                                    Row() {
                                        Text(label)
                                            .fontSize(@r(app.float.font_size_normal))
                                            .fontColor(@r(app.color.font_color_secondary))
                                            .fontWeight(BaseConstants.FONT_WEIGHT_THIN)
                                    }
                                    .borderColor(@r(app.color.primary))
                                    .borderStyle(BorderStyle.Solid)
                                    .borderWidth(BaseConstants.BORDER_WIDTH)
                                })
                            }
                            .width(100.percent)


                            Swiper() {
                                ForEach(item.getProducts(), itemGeneratorFunc: {item: ProductInfoModel, _: Int64 =>
                                    Column() {
                                        Image(item.getIcon())
                                            .width(100.percent)
                                            .aspectRatio(1)
                                        Text(item.getTitle())
                                            .fontSize(@r(app.float.font_size_normal))
                                            .fontColor(@r(app.color.font_color_primary))
                                        Text("￥${(Float64(item.getSalePrice()) / Float64(100)).format(".2") }")
                                            .fontSize(@r(app.float.font_size_normal))
                                            .fontColor(@r(app.color.font_color_highlight))

                                    }
                                })
                            }
                            .displayCount(3)
                            .cachedCount(2)
                            .autoPlay(true)
                            .interval(4000)
                            .loop(true)
                            .duration(1000)
                            .itemSpace(Length(BaseConstants.SWIPER_SPACE_NORMAL))
                            .curve(Curve.Linear)
                            .vertical(false)
                            .indicator(false)
                            .width(100.percent)
                         }
                        .layoutWeight(7)
                    }
                    .width(100.percent)
                    .backgroundColor(@r(app.color.background_primary))
                    .padding(
                        right:  ResourceUtil.getBasePadding().getValue(this.currentBreakpoint),
                        left:  ResourceUtil.getBasePadding().getValue(this.currentBreakpoint),
                        top: ResourceUtil.getBasePadding().getValue(this.currentBreakpoint),
                        bottom: ResourceUtil.getBasePadding().getValue(this.currentBreakpoint)
                    )
                }
                .span(
                    GridColColumnOption(sm: BreakpointConstants.GRID_COL_SPANS[4], md: BreakpointConstants.GRID_COL_SPANS[3],
                    lg: BreakpointConstants.GRID_COL_SPANS[6])
                )
            }, keyGeneratorFunc: {item: ShopInfoModel, index: Int64 =>
                "${item.getId()} - ${index} - ${shopList.size}"
            })
        }
        .padding(
            right:  ResourceUtil.getBasePadding().getValue(this.currentBreakpoint),
            left:  ResourceUtil.getBasePadding().getValue(this.currentBreakpoint),
            top: ResourceUtil.getBasePadding().getValue(this.currentBreakpoint)
        )
        .width(100.percent)
    }
}