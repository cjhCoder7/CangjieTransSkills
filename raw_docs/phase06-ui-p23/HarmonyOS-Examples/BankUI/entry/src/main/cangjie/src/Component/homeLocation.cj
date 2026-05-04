/**
 * Created on 2024/8/30
 */
package ohos_app_cangjie_entry.Component

import cj_res_entry.app
import ohos_app_cangjie_entry.Model.*
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class HomeLocation{
    func build(){
        Column(){
            Row(){
                Text("我的网点").width(100).fontSize(24).textAlign(TextAlign.Start).fontWeight(FontWeight.W600)
                Blank()
                Image(@r(app.media.ic_public_arrow_right)).width(20).height(20).opacity(0.9).objectFit(ImageFit.Fill)
            }.width(100.percent).padding(left:12,bottom:18,right:12,top:25)
            Row(){
                Flex(FlexParams(alignItems: ItemAlign.Center)){
                    Row(){
                        Column(){
                            Row(){
                                Text("XX银行深圳XX支行").fontSize(15).fontWeight(FontWeight.W600)
                                Image(@r(app.media.ic_public_arrow_right)).width(15).height(15).objectFit(ImageFit.Fill).opacity(0.9)
                            }.width(100.percent).margin(top:10,left:30)
                            Row(){
                                Text("深圳市南山区科技园三栋一层A单元").fontSize(12)
                            }.width(100.percent).margin(top:10,left:30)
                            Row(){
                                Text("距您 888m 离您最近").fontSize(15)
                            }.width(100.percent).margin(top:10,left:30)
                        }.width(100.percent).height(100.percent)
                    }.width(80.percent)
                    Row(){
                        Column(){
                            Image(@r(app.media.ic_location_gps)).width(20).height(20).margin(bottom:8)
                            Text("导航").fontSize(12)
                        }.margin(right:10)
                        Column(){
                            Image(@r(app.media.ic_location_telephone)).width(20).height(20).margin(bottom:8)
                            Text("电话").fontSize(12)
                        }.margin(right:10)
                    }.width(30.percent).height(100.percent).margin(left:30)
                }.width(90.percent).height(90.percent)
            }.width(90.percent).height(120).backgroundColor(0x53CFFF).borderRadius(15)
        }.margin(bottom:50)
    }
}