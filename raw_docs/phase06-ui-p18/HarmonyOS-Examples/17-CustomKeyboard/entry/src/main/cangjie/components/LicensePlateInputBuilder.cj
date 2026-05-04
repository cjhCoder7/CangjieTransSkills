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
import ohos.hilog.Hilog
import ohos_app_cangjie_entry.model.*

//***牌照输入栏
@Component
public class LicensePlateInputBuilder {
    @StorageLink["addedDotString"] var addedDotString: String = ""
    @StorageLink["licensePlate"] var licensePlate: ObservedArrayList<String> = ObservedArrayList<String>(["", "", '·', "","","","",""])
    @StorageLink["keyboardIsShow"] var isShow: Bool = true

    var numbers: ArrayList<String> = ArrayList<String>(["1", "2", "3"]) //
    @State var inputIndex: Int64 = -1
    var controller: TextInputController = TextInputController()
    @State var keyboard: KeyBoard = KeyBoard(PROVINCE)


    func build() {
        Column() {
            Column{
                Row {
                ForEach(this.licensePlate, {value:String, index:Int64 =>

                        if (value == '·') {
                        	Text('·')
                      .fontColor(@r(app.color.black_color))
                      .fontSize(KeyboardConstants.DOT_FONTSIZE)
                      .fontWeight(FontWeight.Bold)
                      .margin(right: KeyboardConstants.MARGIN_TEN)
                        } else {
                                Stack() {
                                      Text(value)
                                        .fontSize(KeyboardConstants.KEYBOARD_FONTSIZE)
                                        .height(KeyboardConstants.KEYBOARD_HEIGHT)
                                        .fontColor(if (this.inputIndex == index) {
                                            @r(app.color.start_window_background)
                                        } else {
                                            @r(app.color.black_color)
                                        } )
                                        .textAlign(TextAlign.Center)

                                      Image(@r(app.media.subscript))
                                        .visibility(if (this.inputIndex == index) {
                                            Visibility.Visible
                                        }else {
                                        	Visibility.Hidden
                                        })
                                        .width(KeyboardConstants.SUBSCRIPT_WIDTH)
                                        .height(KeyboardConstants.SUBSCRIPT_HEIGHT)
                                        .margin(top: KeyboardConstants.MARGIN_TWENTY)
                                    }
                                    .width(KeyboardConstants.KEYBOARD_WIDTH)
                                    .height(KeyboardConstants.KEYBOARD_HEIGHT)
                                    .borderRadius(KeyboardConstants.BORDER_RADIUS_FOUR)
                                    .backgroundColor(if (this.inputIndex == index) {
                                           @r(app.color.blue_color)
                                        }else {
                                        	@r(app.color.license_plate_color)
                                        })
                                    .margin(right: KeyboardConstants.MARGIN_TEN)
                                    .onClick({ evt =>
                                    this.inputIndex = index
                                    this.isShow = true
                                    if (this.inputIndex == 0) {
                                    	    this.keyboard = KeyBoard(PROVINCE)
                                    } else if(this.inputIndex == 1) {
                                            this.keyboard = KeyBoard(UPPERCASE)
                                    } else {
                                            this.keyboard = KeyBoard(NUMBERIC)
                                    }
                                      FocusControl.requestFocus('myInput') // 通过ID激活输入框


                                    })
                        }

                            })
                Text("新能源")
                  .width(KeyboardConstants.LABEL_WIDTH)
                  .height(KeyboardConstants.KEYBOARD_HEIGHT)
                  .textAlign(TextAlign.Center)
                  .fontSize(KeyboardConstants.SMALL_FONTSIZE)
                  .fontColor(@r(app.color.gray_font))
                  .fontWeight(FontWeight.Regular)
                  .backgroundColor(@r(app.color.license_plate_color))
                  .borderWidth(KeyboardConstants.BORDER_WIDTH)
                    .borderColor(@r(app.color.gray_border))
                    .borderRadius(KeyboardConstants.BORDER_RADIUS_FOUR)
                    .borderStyle(BorderStyle.Dashed)
                }
                .width(KeyboardConstants.KEYBOARD_ROW_WIDTH)
                .height(KeyboardConstants.KEYBOARD_HEIGHT)
                .justifyContent(FlexAlign.Center)

                 TextInput(text: "", placeholder: 'input your word...', controller: this.controller)
                .id('myInput')
                .position(x: -999, y: -999)
                .width(0)
                .height(0)
                .customKeyboard(bind(keyboardBuilder, this),options: true)
                .focusable(true)
                .enabled(this.isShow)


            }
            .margin(top: StyleConstants.MARGIN_SIXTEEN,
          bottom: StyleConstants.MARGIN_EIGHTEEN)

        }
        .width(StyleConstants.FULL_WIDTH)
        .height(StyleConstants.CAR_INFO_HEIGHT)
        .borderRadius(StyleConstants.MARGIN_TEN)
        .backgroundColor(@r(app.color.start_window_background))

    }

    @Builder
    public func keyboardBuilder() {
        Column() {
            Grid {
                ForEach(this.keyboard.keyboardValue, {item: String, _: Int64 =>
                            GridItem {
                                Text(item)
                                .fontSize(16)
                                .fontColor(Color.BLACK)
                                .textAlign(TextAlign.Center)

                            }
                            .width(100.percent)
                            .height(100.percent)
                            .backgroundColor(Color.WHITE)
                            .borderRadius(KeyboardConstants.BORDER_RADIUS_FOUR)
                            .onClick({ evt =>
                                if(this.inputIndex != 2) {
                                    this.licensePlate[this.inputIndex] = item
                                }
                                this.inputIndex += 1
                                if (this.inputIndex == 0) {
                                    	this.keyboard = KeyBoard(PROVINCE)
                                    } else if(this.inputIndex == 1) {
                                            this.keyboard = KeyBoard(UPPERCASE)
                                    } else {
                                            this.keyboard = KeyBoard(NUMBERIC)
                                    }
                                })
                        })
                GridItem {
                     Image(@r(app.media.delete))
                    .width(16)
                    .height(16)
                    .objectFit(ImageFit.Contain)
                    .fillColor(Color.BLACK)
                }
                .width(100.percent)
                .height(100.percent)
                .backgroundColor(Color.WHITE)
                .borderRadius(KeyboardConstants.BORDER_RADIUS_FOUR)
                .onClick({ evt =>
                        this.licensePlate[this.inputIndex] = ""
                    })

            }
            .rowsTemplate(this.keyboard.rowTemplateStr)
            .columnsTemplate(this.keyboard.columnTemplateStr)
            .rowsGap(5)
            .columnsGap(5)
            .width(KeyboardConstants.FULL_WIDTH)
            .height(42 * this.keyboard.rowCount + 5 * (this.keyboard.rowCount - 1))
        }
        .width(KeyboardConstants.FULL_WIDTH)
        .height(KeyboardConstants.TEXT_INPUT_HEIGHT)
        .padding(
          left: 5,
          right: 5,
          top: 5,
          bottom: 5
        )
        .backgroundColor(@r(app.color.text_input_color))
    }
}