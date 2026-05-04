/**
 * Created on 2024/7/30
 */
package ohos_app_cangjie_entry.components.index

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import ohos.resource_manager.*
import cj_res_entry.app
import ohos_app_cangjie_entry.utils.MyDataSource
import std.collection.ArrayList

@Component
public class IndexSwiper {

  let dataList = ArrayList<CJResource>([
    @r(app.media.hc_2024_cn),
    @r(app.media.hw_cloud_flexus_pc)
  ])

  func build() {
    Column() {
      Text("Swiper").outerTitle()

      Swiper() {
        ForEach(
          this.dataList,
          itemGeneratorFunc: {
            element: CJResource, index: Int64 =>
              Image(element)
              .width(100.percent)
              .height(150)
              .objectFit(ImageFit.Cover)
          }
        )
      }.cachedCount(2)  // 预加载2个子组件
      .index(0) // 开始显示第0个
      .autoPlay(true)  // 设置自动播放
      .interval(4000)  // 自动播放的时间间隔
      .loop(true)  // 设置循环播放
      .duration(1000)  // 子组件的切换时长
      .curve(Curve.Linear)  // 子组件切换的动画曲线
      .itemSpace(0)  // 子组件之间的间隙为0
    }.card().width(100.percent)
    .redirect("SwiperView")
  }
}