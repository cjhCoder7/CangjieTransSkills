/**
 * Created on 2024/7/30
 */
package ohos_app_cangjie_entry.components.playground.utils

import ohos.component.*
import ohos.base.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.utils.*

extend Column {
  // 操作面板的容器
  func container() {
    this.padding(top: 50, left: 20, right: 20, bottom: 50)
    .alignItems(HorizontalAlign.Start)
  }
}

extend Slider {
  // 面板设置数值的滑块
  func valueSlider() {
    this.blockColor(0x161315)
      .trackColor(0x9b80a6)
      .selectedColor(0x161315)
      .showSteps(false)
      .showTips(false)
      .width(100.percent)
  }
}

extend Toggle {
  // 面板的开关
  func barSwitch() {
    this.size(width: 28, height: 28)
        .selectedColor(0xed6f21)
  }
}

extend Text {
  // 菜单选择框的按钮
  func menuButton() {
    this.padding(top: 10, bottom: 10)
  }

  // 操控标签字体
  func labelText() {
    this.fontSize(20)
  }
}

extend Divider {
  // 菜单的分隔符
  func menuDivider() {
    this.strokeWidth(2).color(COLOR_GRAY_300)
  }
}

@Builder
public func labelText(content: String) {
  Text("${content}").fontSize(20)
  .layoutWeight(1).textAlign(TextAlign.Start)
}
