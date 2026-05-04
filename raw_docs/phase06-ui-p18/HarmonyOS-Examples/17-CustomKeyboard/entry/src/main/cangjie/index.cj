package ohos_app_cangjie_entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.*
import ohos_app_cangjie_entry.constants.*
import ohos.hilog.Hilog
import std.collection.*
import ohos_app_cangjie_entry.components.*

let _ = AppStorage.setOrCreate("detailIsShow", false)
let _ = AppStorage.setOrCreate("keyboardIsShow", true)
let _ = AppStorage.setOrCreate("addedDotString", "")
let _ = AppStorage.setOrCreate<ObservedArrayList<String>>("licensePlate", ObservedArrayList<String>(["", "", '·', "","","","",""]))


@Entry
@Component
class EntryView {

    @StorageLink["detailIsShow"] var isShow: Bool = false
    @StorageLink["keyboardIsShow"] var keyboardIsShow: Bool = true
    @StorageLink["addedDotString"] var addedDotString: String = ""
    @StorageLink["licensePlate"] var licensePlate: ObservedArrayList<String> = ObservedArrayList<String>(["", "", '·', "","","","",""])

    //***主入口
    func build() {
        Column {
            TitleBuilder()
            Column {
                Column {
                    LicensePlateInputBuilder()
                }
                .width(StyleConstants.FULL_WIDTH)
                .height(StyleConstants.CAR_INFO_HEIGHT)
                .borderRadius(StyleConstants.BORDER_RADIUS_TEN)
                .justifyContent(FlexAlign.Center)
                .margin(top: StyleConstants.MARGIN_TWENTY)
                .padding(left: StyleConstants.PADDING_SIXTEEN,right: StyleConstants.PADDING_SIXTEEN)

                Button(@r(app.string.select))
                .id('button')
                .width(StyleConstants.BUTTON_WIDTH)
                .height(StyleConstants.BUTTON_HEIGHT)
                .borderRadius(StyleConstants.BORDER_RADIUS_THIRTY)
                .fontSize(StyleConstants.NORMAL_FONTSIZE)
                .fontWeight(FontWeight.Regular)
                .fontColor(@r(app.color.start_window_background))
                .margin(top: StyleConstants.MARGIN_EIGHTEEN)
                .onClick({ evt =>
                    this.isShow = true
                    this.addedDotString = this.licensePlate[0] + this.licensePlate[1] + '·' + this.licensePlate[3] + this.licensePlate[4] + this.licensePlate[5]+ this.licensePlate[6]+ this.licensePlate[7]
                        this.keyboardIsShow = false
                        }) //***

                Row() {
                    Text(@r(app.string.info))
                    .fontSize(StyleConstants.NORMAL_FONTSIZE)
                    .fontWeight(FontWeight.Regular)
                    .fontColor(@r(app.color.font_color))
                    .margin(left: StyleConstants.MARGIN_SIXTEEN)
                }
                .width(StyleConstants.FULL_WIDTH)
                .height(StyleConstants.HEIGHT_TWENTY_EIGHT)
                .margin(top: StyleConstants.MARGIN_TWENTY_EIGHT, bottom: StyleConstants.MARGIN_SIX)

                PaymentInfoBuilder()
                FooterBuilder()
            }
            .width(StyleConstants.FULL_WIDTH)
            .height(StyleConstants.FULL_HEIGHT)
        }
        .justifyContent(FlexAlign.Start)
        .width(StyleConstants.FULL_WIDTH)
        .height(StyleConstants.FULL_HEIGHT)
        .backgroundColor(@r(app.color.main_background))
    }
}


