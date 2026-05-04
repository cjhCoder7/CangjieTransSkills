/**
 * Created on 2024/8/2
 */
package ohos_app_cangjie_entry.components.playground.utils

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class ToggleBar {
  // 开关绑定的布尔值
  @Link var value: Bool

  // 标签信息
  @Prop var title: String

  func handler(isOn: Bool) {
    this.value = isOn
  }

  func build() {
    Column(BAR_INNER_GRID_SIZE) {
      Row() {
        labelText(title)
        Row() {
          Text("Off")

          Toggle(ToggleType.SwitchType, isOn: value)
          .onChange(handler)
          .margin(left: 10, right: 10)

          Text("On")
        }
      }.padding(top:10, bottom: 10)
    }.width(100.percent)
    .alignItems(HorizontalAlign.Start)
  }
}
