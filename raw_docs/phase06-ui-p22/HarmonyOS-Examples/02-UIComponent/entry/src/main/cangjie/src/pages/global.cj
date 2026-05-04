/**
 * Created on 2024/7/31
 */
package ohos_app_cangjie_entry.pages

import ohos.base.*
import ohos.component.*
import ohos_app_cangjie_entry.utils.*

extend Column {
  // 操作面板的容器
  func pageContainer() {
    this.width(100.percent).padding(top: CONTAINER_PADDING_TOP, left: CONTAINER_PADDING_LEFT,
        right: CONTAINER_PADDING_RIGHT, bottom: CONTAINER_PADDING_BOTTOM)
  }

  // 章节容器
  func section(){
    this.alignItems(HorizontalAlign.Start)
  }

  // 样例代码的卡片
  func codeCard() {
    this.width(100.percent)
    .padding(20).borderWidth(1)
    .borderRadius(10).borderColor(0xdee2e6)
  }

  // playground卡片
  func playgroundCard() {
    this.margin(bottom: 20)
  }
}

extend Scroll {
  func playgound() {
    this.scrollable(ScrollDirection.Vertical)
      .padding(bottom: 50)
  }
}