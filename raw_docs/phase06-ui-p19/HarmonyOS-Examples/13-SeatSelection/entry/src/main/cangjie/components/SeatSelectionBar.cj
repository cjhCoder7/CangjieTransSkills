/**
 * Created on 2025/7/25
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.constants.*
import ohos_app_cangjie_entry.view_model.SeatSelection

@Component
public class SeatSelectionBar {
    @LocalStorageLink['viewModel']
    var viewModel: SeatSelection = SeatSelection()

    func build() {
        Scroll {
            Row(10) {
                if (viewModel.selectedSeats.size == 0) {
                    Text("推荐座位")
                        .fontSize(14)
                        .padding(top: 8, bottom: 8)
                    ForEach([1, 2, 3, 4, 5], { personCount: Int64, _: Int64 =>
                        Button("${personCount}人")
                            .padding(8)
                            .borderRadius(8)
                            .fontSize(14.fp)
                            .fontColor(Color.BLACK)
                            .shape(ShapeType.Normal)
                            .backgroundColor(0xF6F6F6)
                            .onClick { _ =>
                                viewModel.recommendSeats(personCount)
                            }
                    })
                } else {
                    ForEach(viewModel.selectedSeats, { seat: SeatInfo, _: Int64 =>
                        SelectedSeat(seatInfo: seat)
                    })
                }
            }
            .margin(top: 20, bottom: 20)
            .height(30)
        }
        .scrollBar(BarState.Off)
        .width(StyleConstants.FULL_WIDTH)
        .scrollable(ScrollDirection.Horizontal)
        .align(
            if (viewModel.selectedSeats.size == 0) { Alignment.Center }
            else { Alignment.Start })
    }
}