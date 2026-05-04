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
import std.collection.ArrayList

@Component
public class HomeNews{
    var controller: SwiperController = SwiperController()
    @State var newsList: ArrayList<String> = ArrayList<String>(
        ['震惊!黑吗喽销量突破1500万份',
            '震惊!今日黄金价格跌破史低' ,
            '08.30，今日证券'])

    func build() {
        Row() {
            Image(@r(app.media.ic_news_hot))
                .width(80)
                .height(80)
                .margin(left:12)
            Swiper(controller) {
                ForEach(
                    newsList,
                    itemGeneratorFunc: {
                        item: String, index: Int64 => Text(item).fontSize(20).fontColor(Color.BLACK)
                    })
            }.autoPlay(true).indicator(false).vertical(true).itemSpace(10).width(100.percent).padding(left:6,right:12,bottom:8,top:8)
        }
    }
}