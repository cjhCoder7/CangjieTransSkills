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
public class HomeAdvertisement{
    func build(){
        Column(){
            Row(){
                Text("热门活动").width(100).fontSize(24).textAlign(TextAlign.Start).fontWeight(FontWeight.W600)
                Blank()
                Text("更多").fontSize(18).textAlign(TextAlign.End).fontWeight(FontWeight.W400).margin(right:2)
                Image(@r(app.media.ic_public_arrow_right)).width(20).height(20).opacity(0.9).objectFit(ImageFit.Fill)
            }.width(100.percent).padding(left:12,bottom:12,right:12)
            Row(){
             ForEach(
                advertisementItems,
                itemGeneratorFunc: {
                    item: iconItem, index: Int64 => Column() {
                        Stack(Alignment.TopStart){
                            Image(item.getImage()).width(100.percent).height(100.percent).objectFit(ImageFit.Fill)
                            Text("广告").width(90.percent).height(100.percent).fontColor(Color.WHITE).fontSize(10).fontWeight(FontWeight.W500).align(Alignment.BottomEnd).margin(bottom:6, left:6)
                            Text(item.getTitle()).fontSize(15).fontColor(Color.WHITE).textAlign(TextAlign.Center).fontWeight(FontWeight.W600).align(Alignment.TopStart).margin(top:6,left:6,bottom:6)
                    }.width(100.percent).height(100.percent)
                }.width(50.percent).height(80.percent).padding(left:10,right:10)
            })
        }.padding(top:6)
        }.width(100.percent).height(300)
    }
}