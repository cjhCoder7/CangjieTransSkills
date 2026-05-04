/**
 * Created on 2025/7/31
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.*
import ohos_app_cangjie_entry.constants.*
import std.collection.*

@Component
public class PaymentInfoBuilder {
    @StorageLink["addedDotString"] var addedDotString: String = ""
    @StorageLink["detailIsShow"] var isShow: Bool = false

    func build() {
        Column {
            Flex(FlexParams(justifyContent: FlexAlign.SpaceBetween)) {
                Text(@r(app.string.license_plate))
                .fontColor(@r(app.color.font_color))
                .fontWeight(FontWeight.Regular)
                .fontSize(StyleConstants.NORMAL_FONTSIZE)

                Text(this.addedDotString)
                .fontColor(@r(app.color.font_color))
                .fontWeight(FontWeight.Regular)
                .fontSize(StyleConstants.NORMAL_FONTSIZE)
            }
            .padding(StyleConstants.PADDING_TWENTY)

            Divider()
            .width(StyleConstants.DIVIDER_WIDTH)
            .strokeWidth(StyleConstants.DIVIDER_HEIGHT_ONE)

            Flex(FlexParams(justifyContent: FlexAlign.SpaceBetween)) {
                Text(@r(app.string.total_cost))
                .fontColor(@r(app.color.text_color_gray))
                .fontWeight(FontWeight.Regular)
                .fontSize(StyleConstants.NORMAL_FONTSIZE)

                Text(@r(app.string.twenty_yuan))
                .fontColor(@r(app.color.text_color_gray))
                .fontWeight(FontWeight.Regular)
                .fontSize(StyleConstants.NORMAL_FONTSIZE)
            }
            .padding(StyleConstants.PADDING_TWENTY)

            Column(StyleConstants.MARGIN_TEN) {
                Row() {
                    Text(@r(app.string.twenty_yuan_float))
                    .fontSize(StyleConstants.LARGE_FONTSIZE)
                    .fontWeight(FontWeight.Regular)
                    .textAlign(TextAlign.Center)

                    Text(@r(app.string.yuan))
                    .fontSize(StyleConstants.NORMAL_FONTSIZE)
                    .fontWeight(FontWeight.Regular)
                }

                Row() {
                    Text(@r(app.string.detail))
                    .fontSize(StyleConstants.MINI_FONTSIZE)
                    .fontWeight(FontWeight.Regular)
                    .fontColor(@r(app.color.text_color_gray1))
                    .textAlign(TextAlign.Center)

                    Image(@r(app.media.ic_public_right_arrow))
                    .width(StyleConstants.MINI_ICON_WIDTH)
                    .height(StyleConstants.MINI_ICON_HEIGHT)
                }
            }
            .width(StyleConstants.FULL_WIDTH)
            .height(StyleConstants.HEIGHT_EIGHTY)
            .justifyContent(FlexAlign.Center)

        }
        .width(StyleConstants.CONTAINER_WIDTH)
        .height(StyleConstants.SHEET_HEIGHT)
        .backgroundColor(@r(app.color.start_window_background))
        .borderRadius(StyleConstants.INFO_BORDER_RADIUS)
        .visibility(
            if(this.isShow) {
                Visibility.Visible
            } else {
            	Visibility.None
            })
    }
}