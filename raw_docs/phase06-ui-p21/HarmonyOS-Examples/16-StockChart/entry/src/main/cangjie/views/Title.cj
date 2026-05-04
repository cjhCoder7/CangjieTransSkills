/**
 * Created on 2025/7/30
 */
package ohos_app_cangjie_entry.views

import ohos.base.*
import ohos.component.*
import cj_res_entry.app
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.constants.*
import ohos_app_cangjie_entry.viewmodels.TimeLineViewModel

@Component
public class Title {
    @LocalStorageLink['timeLineViewModel']
    var viewModel: TimeLineViewModel = TimeLineViewModel()

    func build() {
        Row {
            Image(@r(app.media.back))
                .width(20)
                .position(x: 10, y: 0)

            Column(2) {
                Text(DataConstants.TITLE)
                    .fontSize(16)
                    .fontWeight(FontWeight.W600)

                Text(viewModel.subtitle)
                    .fontSize(12)
                    .fontColor(StyleConstants.GRAY_COLOR)
            }
            .width(StyleConstants.FULL_WIDTH)
        }
        .borderColor(0xdddddd)
        .padding(top: 12, bottom: 4)
        .width(StyleConstants.FULL_WIDTH)
        .borderWidth(EdgeWidths(bottom: 1.px))
    }
}