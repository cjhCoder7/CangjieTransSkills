/**
 * Created on 2024/7/30
 */
package ohos_app_cangjie_entry.components.index

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import ohos.resource_manager.*

extend Text {
  // 字重的文本
  func fontWeightText(fontWeight!: FontWeight) {
    this.fontSize(12).fontWeight(fontWeight).fontColor(0xffffff)
  }
}

@Component
public class IndexText {
  func build() {
    Column() {
      Text("Text").title().fontColor(0xffffff)

      Row() {
        Text("Aa").fontSize(60)
        .fontWeight(FontWeight.W700).fontColor(0xffffff)

        Column() {
          Text("Lighther").fontWeightText(fontWeight: FontWeight.Lighter)
          Text("Regular").fontWeightText(fontWeight: FontWeight.Regular)
          Text("Medium").fontWeightText(fontWeight: FontWeight.Medium)
          Text("Bold").fontWeightText(fontWeight: FontWeight.Bold)
        }.alignItems(HorizontalAlign.Start)
      }.width(100.percent).justifyContent(FlexAlign.SpaceBetween)
    }.card().layoutWeight(1).height(150)
    .padding(10).backgroundColor(0x073835)
    .redirect("TextView")
  }
}
