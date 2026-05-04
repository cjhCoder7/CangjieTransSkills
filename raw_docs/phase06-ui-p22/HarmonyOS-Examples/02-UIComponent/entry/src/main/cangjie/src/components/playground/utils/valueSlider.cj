/**
 * Created on 2024/8/2
 */
package ohos_app_cangjie_entry.components.playground.utils

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

@Builder
public func valueSlider(
  value!: Int64,
  min!: Float64,
  max!: Float64,
  step!: Float64,
  showSteps!: Bool = false,
  onChange!: (value: Float64, mode: SliderChangeMode) -> Unit) {
  Slider(
    value: Float64(value),
    min: min,
    max: max,
    step: step,
    style: SliderStyle.OutSet
  ).blockColor(0x161315)
  .trackColor(0x9b80a6)
  .selectedColor(0x161315)
  .showSteps(showSteps)
  .showTips(false)
  .width(100.percent)
  .onChange(onChange)
}

@Builder
public func valueSlider(
  value!: UInt32,
  min!: Float64,
  max!: Float64,
  step!: Float64,
  showSteps!: Bool = false,
  onChange!: (value: Float64, mode: SliderChangeMode) -> Unit) {
  Slider(
    value: Float64(value),
    min: min,
    max: max,
    step: step,
    style: SliderStyle.OutSet
  ).blockColor(0x161315)
  .trackColor(0x9b80a6)
  .selectedColor(0x161315)
  .showSteps(showSteps)
  .showTips(false)
  .width(100.percent)
  .onChange(onChange)
}

@Builder
public func valueSlider(
  value!: Float64,
  min!: Float64,
  max!: Float64,
  step!: Float64,
  showSteps!: Bool = false,
  onChange!: (value: Float64, mode: SliderChangeMode) -> Unit) {
  Slider(
    value: value,
    min: min,
    max: max,
    step: step,
    style: SliderStyle.OutSet
  ).blockColor(0x161315)
  .trackColor(0x9b80a6)
  .selectedColor(0x161315)
  .showSteps(showSteps)
  .showTips(false)
  .width(100.percent)
  .onChange(onChange)
}