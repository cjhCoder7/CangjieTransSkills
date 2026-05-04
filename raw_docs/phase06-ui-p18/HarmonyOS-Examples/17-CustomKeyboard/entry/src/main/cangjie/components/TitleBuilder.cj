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
public class TitleBuilder {

    //**顶部标题栏
    func build() {
        //***titleBuilder***
            Row {
                Image(@r(app.media.ic_public_left_arrow))
                .width(StyleConstants.ICON_WIDTH)
                .height(StyleConstants.ICON_HEIGHT)
                .margin(left: StyleConstants.MARGIN_HEADER_ARROW)

                Row {
                    Text(@r(app.string.text_info))
                    .fontColor(@r(app.color.font_color))
                    .fontWeight(FontWeight.Regular)
                    .fontSize(StyleConstants.HEADER_TEXT_FONTSIZE)
                }
                .width(StyleConstants.HEADER_TEXT_WIDTH)
                .height(StyleConstants.HEADER_TEXT_HEIGHT)
                .margin(left: StyleConstants.MARGIN_HEADER_TEXT)
            }
            .width(StyleConstants.FULL_WIDTH)
            .height(StyleConstants.HEADER_HEIGHT)
            .margin(top: StyleConstants.MARGIN_TEN)
    }
}