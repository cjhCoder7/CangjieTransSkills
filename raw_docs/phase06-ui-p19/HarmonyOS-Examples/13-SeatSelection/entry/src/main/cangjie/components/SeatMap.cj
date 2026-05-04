/**
 * Created on 2025/7/16
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.constants.*

@Component
public class SeatMap {
    func build() {
        Stack {
            SeatCanvas()

            Column { // Tag of rows
                ForEach(DataConstants.SEATS, { _: Array<SEAT_TYPE>, i: Int64 =>
                    Text('${i + 1}')
                        .fontSize(12)
                        .fontColor(Color.WHITE)
                        .margin(left: 4, right: 4)
                        .height(StyleConstants.MATRIX_SPACE + StyleConstants.MATRIX_RECT_SIZE)
                })
            }
            .borderRadius(10)
            .position(x: -5, y: 0)
            .backgroundColor(0Xa8a8a8)
        }
    }
}
