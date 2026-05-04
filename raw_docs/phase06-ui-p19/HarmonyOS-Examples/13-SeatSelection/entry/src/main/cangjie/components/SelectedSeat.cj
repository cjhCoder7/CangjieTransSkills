/**
 * Created on 2025/7/17
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import cj_res_entry.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.constants.*
import ohos_app_cangjie_entry.view_model.SeatSelection

@Component
public class SelectedSeat {
    @Prop
    var seatInfo: SeatInfo

    @LocalStorageLink['viewModel']
    var viewModel: SeatSelection = SeatSelection()

    func build() {
        Row {
            Text(seatInfo.toString()).fontSize(14.fp)

            Divider()
                .height(14.fp)
                .vertical(true)
                .margin(left: 5, right: 5)

            Image(@r(app.media.delete))
                .height(14.fp)
                .aspectRatio(1)
                .onClick { _ => viewModel.deleteSelected(seatInfo) }
        }
        .padding(8)
        .borderRadius(8)
        .backgroundColor(0xf6f6f6)
        .justifyContent(FlexAlign.SpaceEvenly)
    }
}
