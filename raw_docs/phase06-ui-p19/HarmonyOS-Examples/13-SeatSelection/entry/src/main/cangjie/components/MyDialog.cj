/**
 * Created on 2025/7/18
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import std.collection.ArrayList
import ohos.state_macro_manage.*
import ohos.prompt_action.PromptAction
import ohos_app_cangjie_entry.constants.*
import ohos_app_cangjie_entry.view_model.SeatSelection

@CustomDialog
public class MyDialog {
    var controller: Option<CustomDialogController> = Option.None

    @LocalStorageLink['viewModel']
    var viewModel: SeatSelection = SeatSelection()

    func build() {
        Column {
            Text("确认支付吗？").fontWeight(FontWeight.Bold)

            Row {
                Button("取消").onClick { _ => controller?.close() }

                Button("确定").onClick { _ =>
                    controller?.close()
                    viewModel.soldSelected()
                    PromptAction.showToast(message: "已支付成功")
                }
            }
            .margin(top: 20)
            .width(StyleConstants.FULL_WIDTH)
            .justifyContent(FlexAlign.SpaceAround)
        }
        .padding(20)
        .borderRadius(10)
    }
}
