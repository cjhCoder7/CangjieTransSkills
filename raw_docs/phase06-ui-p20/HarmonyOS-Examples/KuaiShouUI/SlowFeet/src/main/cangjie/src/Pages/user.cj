package ohos_app_cangjie_SlowFeet.Pages

import ohos_app_cangjie_SlowFeet.Model.*
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.*
import std.convert.*
import std.collection.*

@Entry
@Component
public class UserInfo {
    func build() {
        Column {
            Stack {
                Image("/resources/base/media/bg.jpg").width(100.percent).position(x: 0.fp, y: 0.fp).margin(left: 0.fp, top: 0.fp)
                Column {
                    Row {
                        Column {
                            Text("114").margin(bottom: 10.fp).fontWeight(FontWeight.W900)
                            Text("粉丝").fontWeight(FontWeight.W300).fontSize(13)
                        }
                        Column {
                            Text("11").margin(bottom: 10.fp).fontWeight(FontWeight.W900)
                            Text("关注").fontWeight(FontWeight.W300).fontSize(13)
                        }.margin(left: 50.fp, right: 50.fp)
                        Column {
                            Text("1145").margin(bottom: 10.fp).fontWeight(FontWeight.W900)
                            Text("获赞").fontWeight(FontWeight.W300).fontSize(13)
                        }
                    }.width(100.percent).justifyContent(FlexAlign.End).margin(right: 50.fp, top: 20.fp)
                    Text("TA").margin(top: 10.fp, bottom: 15.fp).fontSize(24).width(85.percent).fontWeight(FontWeight.Bold)// .margin(top: 20.fp)
                    Text("慢脚号：homo114514").fontSize(14).margin(bottom: 7.fp).width(85.percent).fontWeight(FontWeight.W300)
                    Text("♂114 岁 · 命座  |  山东 菏泽市 曹县").fontSize(12).width(85.percent).fontWeight(FontWeight.W300).fontColor(0x7F7F7F)
                }.width(100.percent).height(80.percent).margin(bottom: 0.fp).backgroundColor(0xFFFFFF).borderRadius(topLeft: 20.fp, topRight: 20.fp)
                Image("/resources/base/media/avater.jpg").width(105.fp).height(105.fp).borderColor(0xFFFFFF).borderWidth(5.fp).borderRadius(114514).position(x: 30.fp, y: 100.fp)
            }.width(100.percent).height(100.percent).alignment(Alignment.Bottom)
        }.width(100.percent).height(100.percent)
    }
}