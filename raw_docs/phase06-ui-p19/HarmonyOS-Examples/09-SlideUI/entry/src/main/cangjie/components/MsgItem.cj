/**
 * Created on 2025/8/1
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.ArrayList
import cj_res_entry.app

@Component
public class MsgItem {
    @Prop var msgTxt: String
    @Prop var data: ArrayList<Array<String>>
    @State var rotateAngleMini: Float32 = 0.0
    @State var isShowMini: Bool = false

    public func build() {
        ListItemGroup(ListItemGroupParams()) {
            ListItem {
                Column {
                    Row {
                        Text(msgTxt)
                        .width(80.percent)
                        .textOverflow(TextOverflow.Ellipsis)
                        .maxLines(1)
                        .fontSize(20)
                        .fontWeight(FontWeight.W600)
                        .margin(top: 15, bottom: 5)

                        Image(@r(app.media.ic_public_arrow_down))
                        .width(24)
                        .height(24)
                        .rotate(x: 1.0, y: 0.0, z: 0.0, angle: rotateAngleMini)
                        .onClick {
                            evt =>
                                animateTo(AnimateParam(duration: 200), { =>
                                    this.isShowMini = !this.isShowMini
                                    this.rotateAngleMini = 180.0 - this.rotateAngleMini})
                        }
                    }

                    if(this.isShowMini) {
                        GroupItem(data: data)
                    }

                    Divider()
                    .strokeWidth(1)
                    .width(238)
                    .lineCap(LineCapStyle.Round)
                    .color(Color(0, 0, 0, alpha: 0.2))
                    .margin(top: 13)
                }
                .alignItems(HorizontalAlign.Center)
            }
            .width(98.percent)
            .backgroundColor(Color.WHITE)
        }
    }
}