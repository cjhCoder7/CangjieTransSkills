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

@Component
public class HomeSearch {
    func build() {
        Row(BaseConstants.ROW_COLUMN_SPACE_THIN) {
            Image(@r(app.media.ic_search))
                .width(@r(app.float.icon_width_small))
                .height(@r(app.float.icon_height_small))
                .margin(left: Length(BaseConstants.NUMBER_8))

            Swiper() {
                ForEach(HomeConstants.HOME_SEARCH_GUESS, itemGeneratorFunc: {item: String, _: Int64 =>
                    Text(item)
                        .width(100.percent)
                        .fontSize(@r(app.float.font_size_small))
                        .fontColor(@r(app.color.text_color_secondary))
                        .textAlign(TextAlign.Start)
                })
            }
            .cachedCount(2)
            .autoPlay(true)
            .interval(2000)
            .loop(true)
            .duration(1000)
            .itemSpace(0)
            .curve(Curve.Linear)
            .vertical(true)
            .indicator(false)
            .layoutWeight(1)


            Row() {
                Text(@r(app.string.Search))
                    .textAlign(TextAlign.Center)
                    .fontSize(@r(app.float.font_size_small))
                    .fontWeight(FontWeight.W400)
                    .height(100.percent)
                    .layoutWeight(1)
            }
            .borderRadius(Length(HomeConstants.HOME_HEADER_HEIGNT / 2))
            .backgroundColor(@r(app.color.primary))
            .width(BaseConstants.NUMBER_40)
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .height(100.percent)
        .layoutWeight(1)
        .border(width: Length(BaseConstants.BORDER_WIDTH),
            radius: Length(HomeConstants.HOME_HEADER_HEIGNT / 2),
            color: @r(app.color.primary),
            style: BorderStyle.Solid)

    }
}