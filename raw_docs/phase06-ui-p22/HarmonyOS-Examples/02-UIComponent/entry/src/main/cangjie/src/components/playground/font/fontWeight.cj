/**
 * Created on 2024/8/2
 */
package ohos_app_cangjie_entry.components.playground.font

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.components.playground.utils.*

@Component
public class FontWeightBar {
  // 字体重量
  @Link var fontWeight: FontWeight

  // 字体重量滑动块的值
  @State var value: Int64 = 400

  // 高度
  @State var height: Int64 = 0

  // 根据fontWeight初始化value
  protected override func aboutToAppear() {
    match (fontWeight) {
      case FontWeight.W900 => this.value = 900
      case FontWeight.W800 => this.value = 800
      case FontWeight.W700 => this.value = 700
      case FontWeight.W600 => this.value = 600
      case FontWeight.W500 => this.value = 500
      case FontWeight.W400 => this.value = 400
      case FontWeight.W300 => this.value = 300
      case FontWeight.W200 => this.value = 200
      case FontWeight.W100 => this.value = 100
      case _ => this.value = 400
    }
  }

  // 字重滑块的回调
  func handler(value: Float64, mode: SliderChangeMode) {
    this.value = Int64(value)
    match (value) {
      case 900.0 => this.fontWeight = FontWeight.W900
      case 800.0 => this.fontWeight = FontWeight.W800
      case 700.0 => this.fontWeight = FontWeight.W700
      case 600.0 => this.fontWeight = FontWeight.W600
      case 500.0 => this.fontWeight = FontWeight.W500
      case 400.0 => this.fontWeight = FontWeight.W400
      case 300.0 => this.fontWeight = FontWeight.W300
      case 200.0 => this.fontWeight = FontWeight.W200
      case 100.0 => this.fontWeight = FontWeight.W100
      case _ => this.fontWeight = FontWeight.W400
    }
  }

  func onVisible() {
    if (this.height == 0) {
      this.height = SLIDER_BAR_HEIGHT
    } else {
      this.height = 0
    }
  }

  func build() {
    Column(BAR_INNER_GRID_SIZE) {
      Row() {
        labelText("FontWeight")

        Text("${value}")
      }.onClick({ e: ClickEvent => this.onVisible() })

      Column() {
        valueSlider(
          value: value,
          min: 100.0,
          max: 900.0,
          step: 100.0,
          showSteps: true,
          onChange: handler
        )
      }.animationStart(animation)
      .height(height)
      .animationEnd()
    }.width(100.percent)
    .alignItems(HorizontalAlign.Start)
  }
}