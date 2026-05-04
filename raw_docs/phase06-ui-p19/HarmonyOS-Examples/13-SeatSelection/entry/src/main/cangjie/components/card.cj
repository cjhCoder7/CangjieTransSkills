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
public class Card {
    @LocalStorageLink['viewModel']
    var viewModel: SeatSelection = SeatSelection()

    var dialogController: CustomDialogController = CustomDialogController(
        CustomDialogControllerOptions(builder: MyDialog()))

    func build() {
        Column {
            Column {
                MovieInfo()

                Divider().margin(top: 20)

                SeatSelectionBar()
            }
            .borderRadius(15)
            .margin(bottom: 10)
            .backgroundColor(Color.WHITE)
            .padding(top: 20, left: 20, right: 20)
            .shadow(radius: 50, color: Color(0x25000000))

            Button("确认")
                .margin(bottom: 10)
                .width(StyleConstants.FULL_WIDTH)
                .onClick { _ => dialogController.open() }
                .enabled(viewModel.selectedSeats.size > 0)
        }
        .margin(left: 20, right: 20)
    }
}
