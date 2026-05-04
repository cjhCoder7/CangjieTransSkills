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
public class HomeRecommend{
    func build(){
        Column(){
            Row(){
                Text("为您推荐").width(100).fontSize(24).textAlign(TextAlign.Start).fontWeight(FontWeight.W600)
            }.width(100.percent).padding(left:12,bottom:12,right:12)
            Row(){
                Stack(Alignment.TopStart){
                    Column(){
                        Row(){
                            ForEach(
                                recommendList,
                                itemGeneratorFunc: {
                                    item: itemsValue, index: Int64 => Column(){
                                        Text(item.getValue().toString()).fontSize(15).fontWeight(FontWeight.W600)
                                        Text(item.getTitle()).fontSize(15)
                                    }
                                    })
                        }.width(100.percent).height(25.percent).justifyContent(FlexAlign.SpaceEvenly)
                        Divider()
                        ForEach(
                                recommendSubList,
                                itemGeneratorFunc: {
                                    item: recommendSubItem, index: Int64 => Row(){
                                    Column(){
                                        Text(item.getTitle()).fontSize(25).fontWeight(FontWeight.W700).fontColor(Color.RED)
                                        Text(item.getSubTitle()).fontSize(12).margin(top:6)
                                    }
                                    Column(){
                                        Text(item.getDescription()).fontSize(18).fontWeight(FontWeight.W500)
                                        Text(item.getSubDescription()).fontSize(12).margin(top:6)
                                    }
                                    }.width(100.percent).height(30.percent).justifyContent(FlexAlign.SpaceEvenly)
                                    })
                        Divider()
                        Row(){
                            Text("查看更多").fontSize(12)
                            Image(@r(app.media.ic_public_arrow_right)).width(15).height(15).objectFit(ImageFit.Fill)
                        }.margin(top:12).align(Alignment.Center)
                    }
                }.height(90.percent).borderWidth(6).borderRadius(15).borderColor(Color.BLACK).margin(left:15,right:15,bottom:15)
            }
        }.width(100.percent).height(320).padding(bottom:12)
    }
}