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
public class IndexButton {
  func build() {
    Column() {
      Text("Button").title().fontColor(0xffffff)

      Column(10) {
        Button("View Domos").rounded()
        .width(140).fontColor(0x3755be)
        .backgroundColor(0xffffff)

        Button("Contect us").rounded()
        .width(140).fontColor(0xffffff)
        .backgroundColor(0x30376e)
      }.alignItems(HorizontalAlign.Start)
    }.card().layoutWeight(1).height(150)
    .padding(10).backgroundColor(0x3755be)
    .redirect("ButtonView")
  }
}