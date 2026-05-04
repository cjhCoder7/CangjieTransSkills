/**
 * Created on 2024/8/2
 */
package ohos_app_cangjie_entry.components.playground.font

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.components.playground.utils.*
import std.collection.ArrayList

@Component
public class TextAlignBar {
  // 字体对齐方式
  @Link var textAlign: TextAlign

  // 字体对齐方式的文本表示
  @State var content: String = "Center"

  // 可能的所有对齐方式
  let options = ArrayList<(String)>(["Start", "Center", "End"])

  // 对齐方式选择的响应回调
  func handler(textAlign: String) {
    this.content = textAlign
    this.parse(textAlign)
  }

  func parse(textAlign: String) {
    match (textAlign) {
      case "Start" => this.textAlign = TextAlign.Start
      case "Center" => this.textAlign = TextAlign.Center
      case "End" => this.textAlign = TextAlign.End
      case _ => this.textAlign = TextAlign.Center
    }
  }

  func build() {
    SelectBar(
      title: "TextAlign",
      content: content,
      options: options,
      onSelect: handler
    )
  }
}