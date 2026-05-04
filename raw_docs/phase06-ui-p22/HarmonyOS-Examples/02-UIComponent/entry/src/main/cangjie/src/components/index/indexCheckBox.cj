/**
 * Created on 2024/7/30
 */
package ohos_app_cangjie_entry.components.index

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import ohos.resource_manager.*

@Component
public class IndexCheckBox {
  func build() {
    Column() {
      Text("CheckBox").title()

      Column() {
        Row() {
          Checkbox().shape(CheckBoxShape.ROUNDED_SQUARE)
          .select(true)

          Text("Todo 1")
        }
        Row() {
          Checkbox().shape(CheckBoxShape.ROUNDED_SQUARE)
          .select(true)

          Text("Todo 2")
        }
        Row() {
          Checkbox().shape(CheckBoxShape.ROUNDED_SQUARE)
          .select(false)

          Text("Todo 3")
        }
      }
    }.card().layoutWeight(1).height(150)
    .padding(10).borderWidth(1)
    .redirect("CheckboxView")
  }
}