/**
 * Created on 2024/8/5
 */
package ohos_app_cangjie_entry.components.playground.utils

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

public let animation = AnimateParam(
  duration: 600,
  curve: Curve.EaseOut,
  iterations: 1,
  playMode: PlayMode.Normal,
  expectedFrameRateRange: ExpectedFrameRateRange(
    min: 20,
    max: 120,
    expected: 90
  )
)

public let colorPickerAnimation = AnimateParam(
  duration: 400,
  curve: Curve.EaseOut,
  iterations: 1,
  playMode: PlayMode.Normal,
  expectedFrameRateRange: ExpectedFrameRateRange(
    min: 20,
    max: 120,
    expected: 90
  )
)

