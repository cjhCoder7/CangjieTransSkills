/**
 * Created on 2025/7/31
 */
package ohos_app_cangjie_entry.views

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

import ohos_app_cangjie_entry.constants.StyleConstants

@Component
public class Quotes {
    @State var isIntraday: Bool = true // true：分时，false：日K

    @Builder
    func switcher() {
        Row {
            Text("分时")
                .switcherStyle(isIntraday)
                .onClick { _ => isIntraday = true }

            Text("日K")
                .switcherStyle(!isIntraday)
                .onClick { _ => isIntraday = false }
        }
        .padding(3)
        .borderRadius(5)
        .backgroundColor(0xeeeeee)
    }

    func build() {
        Column(5) {
            Row {
                Text(if (isIntraday) { "分时走势" } else { "日K线图" })
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                switcher()
            }
            .width(StyleConstants.FULL_WIDTH)
            .justifyContent(FlexAlign.SpaceBetween)

            Stack {
                Column {
                    TimeLineView()
                }.visibility(if (isIntraday) { Visibility.Visible } else { Visibility.Hidden })

                Column {
                    KLineView()
                }.visibility(if (!isIntraday) { Visibility.Visible } else { Visibility.Hidden })
            }
        }
    }
}