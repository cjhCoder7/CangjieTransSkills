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
public class FooterBuilder {

     @StorageLink["detailIsShow"] var isShow: Bool = false
     var dialogController: CustomDialogController = CustomDialogController(CustomDialogControllerOptions(builder: MyDialog()))

    func build() {
        //***footerBuilder
            Flex(FlexParams(justifyContent: FlexAlign.SpaceBetween)) {
                Row() {
                    Text(@r(app.string.to_be_paid))
                    .fontSize(StyleConstants.SMALL_FONTSIZE)
                    .fontWeight(FontWeight.Regular)
                    .fontColor(@r(app.color.black_color))
                    .textAlign(TextAlign.Center)

                    Text(@r(app.string.twenty_yuan_char))
                    .fontSize(StyleConstants.SMALL_FONTSIZE)
                    .fontWeight(FontWeight.Regular)
                    .fontColor(@r(app.color.red_color))
                    .textAlign(TextAlign.Center)
                }
                .width(StyleConstants.FOOTER_TEXT_WIDTH)
                .height(StyleConstants.FOOTER_HEIGHT)
                .margin(left: StyleConstants.MARGIN_FOOTER_TEXT)

              Row() {
                    Button(@r(app.string.confirm))
                    .width(StyleConstants.CONFIRM_BUTTON_WIDTH)
                    .height(StyleConstants.CONFIRM_BUTTON_HEIGHT)
                    .margin(right: StyleConstants.MARGIN_TWENTY)
                    .onClick({evt =>
                        this.dialogController.open()
                        })
              }
              .height(StyleConstants.FOOTER_HEIGHT)
            }
            .position(x: 0, y:670)
            .backgroundColor(@r(app.color.start_window_background))
            .width(StyleConstants.FULL_WIDTH)
            .height(StyleConstants.HEIGHT_NINETY_FIVE)
            .visibility(
                        if(this.isShow){
                            Visibility.Visible
                        } else {
                            Visibility.None
                        })
    }
}


//***支付成功弹窗
@CustomDialog
class MyDialog {
    var controller: Option<CustomDialogController> = Option.None
    func build() {
        Column {
            Flex(FlexParams(justifyContent: FlexAlign.SpaceBetween)) {
                Image(@r(app.media.ICON))
                .width(StyleConstants.ICON_WIDTH)
                .height(StyleConstants.ICON_HEIGHT)

                Text(@r(app.string.pay_success))
                .fontSize(StyleConstants.LARGE_FONTSIZE)
                .fontWeight(FontWeight.Bold)

                Image(@r(app.media.Public_ic_public_cancel))
                .width(StyleConstants.ICON_WIDTH)
                .height(StyleConstants.ICON_HEIGHT)
            }
            .width(StyleConstants.FULL_WIDTH)
            .height(StyleConstants.HEADER_TEXT_HEIGHT)
            .margin(bottom: StyleConstants.MARGIN_SIXTEEN)

             Row() {
                Text(@r(app.string.pay_success_detail))
            }
            .width(StyleConstants.FULL_WIDTH)
            .margin(bottom: StyleConstants.MARGIN_SIXTEEN)

            Button(@r(app.string.i_know))
            .width(StyleConstants.KNOW_BUTTON_WIDTH)
            .height(StyleConstants.CONFIRM_BUTTON_HEIGHT)
            .onClick({ evt =>
                this.controller?.close()
            })
        }
        .padding(StyleConstants.PADDING_TWENTY)
        .backgroundColor(Color.WHITE)
        .borderRadius(StyleConstants.DIALOG_BORDER_RADIUS)
    }
}




