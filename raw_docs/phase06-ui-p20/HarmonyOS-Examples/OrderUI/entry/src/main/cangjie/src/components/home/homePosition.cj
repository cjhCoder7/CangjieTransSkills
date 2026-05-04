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
public class HomePosition {
    func build() {
        Row(BaseConstants.ROW_COLUMN_SPACE_THIN) {
            Image(@r(app.media.ic_position))
                .width(@r(app.float.icon_width_large))
                .height(@r(app.float.icon_height_large))

            Text(BaseConstants.POSITION)
                .textAlign(TextAlign.Center)
                .fontSize(@r(app.float.font_size_large))
                .fontWeight(BaseConstants.FONT_WEIGHT_WIDE)
                .height(100.percent)

            Image(@r(app.media.ic_down_arrow))
                .width(@r(app.float.icon_width_small))
                .height(@r(app.float.icon_height_small))
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
    }
}