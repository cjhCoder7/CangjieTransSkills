/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.components.index

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import cj_res_entry.app

class TabData {
  public TabData(let src: CJResource, let title: String) {}
}


@Component
public class TabBtn{
  // 图标资源
  @Prop var src: CJResource

  // 图标下面的文本
  @Prop var title: String

  // 图标和文本的颜色,活跃是蓝色,不活跃是黑色
  @Prop var color: UInt32

  func build() {
    Column() {
      Image(src).size(width: 25, height: 25).fillColor(color)
      .margin(bottom:5)

      Text(title).fontSize(10).fontColor(color)
    }
  }
}

@Component
public class TabBar {
  // 当前活跃的Tab的序号
  @Link var activeInd: Int64

  // 点击Tab的响应函数
  func tabOnClick(index: Int64) {
    this.activeInd = index;
  }

  let dataSource = Array<TabData>([
      TabData(@r(app.media.message), "消息"),
      TabData(@r(app.media.channel), "频道"),
      TabData(@r(app.media.video), "短视频"),
      TabData(@r(app.media.associates), "联系人"),
      TabData(@r(app.media.dynamic), "动态")
    ])

  func build() {
    Row() {
      ForEach(dataSource, itemGeneratorFunc: { elem: TabData, index: Int64 =>
          Column() {
            if (index == activeInd) {
              TabBtn(src: elem.src, title: elem.title, color: 0x3087fb)
            } else {
              TabBtn(src: elem.src, title: elem.title, color: 0x000000)
            }
          }.onClick({ e: ClickEvent => tabOnClick(index) })
        }
      )
    }.width(100.percent).padding(left: 20, right: 20, top: 10)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Top)
    .backdropBlur(5)
  }
}