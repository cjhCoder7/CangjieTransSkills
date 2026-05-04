/**
 * Created on 2025/7/30
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.app

extend Text {
    func txtSty(curFontSize: Int64, curFontWeight: FontWeight) {
        this.textOverflow(TextOverflow.Ellipsis).maxLines(1).fontSize(curFontSize).fontWeight(curFontWeight)
    }
}

extend Column {
    func colSty(curHeight: Int64, curWidth: Int64) {
        this.height(curHeight.percent).width(curWidth.percent).justifyContent(FlexAlign.SpaceAround).alignItems(HorizontalAlign.Center)
    }
}

extend Image {
    func imgSty() {
        this.height(18).width(18).objectFit(ImageFit.Contain)
    }
}

@Component
public class ShipDirection {
    public func build() {
        ListItemGroup(ListItemGroupParams()) {
            ListItem {
                Column {
                    Text('当前航次')
                    .width(95.percent)
                    .margin(top: 15, bottom: 5)
                    .txtSty(20, FontWeight.W600)

                    Row {
                        Column {
                            Text('宁波')
                            .txtSty(18, FontWeight.W400)
                            Row {
                                Text('07-17 09:05')
                                .txtSty(12, FontWeight.W400)
                                Image(@r(app.media.ic_ligang))
                                .imgSty()
                            }
                            .alignItems(VerticalAlign.Center)
                        }
                        .colSty(80, 25)

                        Column {
                            Text('靠泊')
                            .txtSty(14, FontWeight.W400)
                            .padding(bottom: 10)
                            Image(@r(app.media.ic_line))
                            .width(95.percent)
                            .height(5)
                            .objectFit(ImageFit.Cover)
                            .borderRadius(2)
                            Row{
                                Text('4.16kn')
                                .txtSty(12, FontWeight.W400)
                                .padding(top: 15)
                            }
                            .alignItems(VerticalAlign.Center)
                        }
                        .colSty(100, 50)
                        .margin(bottom: 20)

                        Column {
                            Text('舟山')
                            .txtSty(18, FontWeight.W400)
                            Row {
                                Image(@r(app.media.ic_dida))
                                .imgSty()
                                .margin(left: -12, right: 6)
                                Text('07-17 09:05')
                                .txtSty(12, FontWeight.W400)
                            }
                            .alignItems(VerticalAlign.Center)
                        }
                        .colSty(80, 25)
                    }
                    .justifyContent(FlexAlign.Start)
                    .height(60)
                    .width(90.percent)
                }
                .alignItems(HorizontalAlign.Center)
            }
            .width(98.percent)
            .backgroundColor(Color.WHITE)
            .borderRadius(9)
            .margin(top: 5, bottom: 5)
        }
    }
}