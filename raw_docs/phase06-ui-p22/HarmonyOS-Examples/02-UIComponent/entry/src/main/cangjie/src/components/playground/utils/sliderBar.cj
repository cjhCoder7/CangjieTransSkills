/**
 * Created on 2024/8/2
 */
package ohos_app_cangjie_entry.components.playground.utils

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

// 滑块的设置
public struct SliderParams {
  public SliderParams(
    let min: Float64,
    let max: Float64,
    let step: Float64
  ){}
}

@Component
public class SliderBar {
  // 绑定的值
  @Link var value: Int64

  // 滑块设定
  @Prop var sliderParams: SliderParams

  // 标题
  @Prop var title: String

  // 高度
  @State var height: Int64 = 0

  func handler(value: Float64, mode: SliderChangeMode) {
    this.value = Int64(value)
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
        labelText(title)

        Text("${value}")
      }.padding(top:10, bottom: 10)
      .onClick({ e: ClickEvent => this.onVisible() })

      Column() {
        valueSlider(
          value: value,
          min: sliderParams.min,
          max: sliderParams.max,
          step: sliderParams.step,
          onChange: handler
        )
      }.animationStart(animation)
      .height(height)
      .animationEnd()
    }.width(100.percent)
    .alignItems(HorizontalAlign.Start)
  }
}