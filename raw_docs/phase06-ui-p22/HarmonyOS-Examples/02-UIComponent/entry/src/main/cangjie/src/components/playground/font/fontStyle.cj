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
public class FontStyleBar {
  // 字体的样式
  @Link var fontStyle: FontStyle

  // 字体样式的文本表示
  @State var content: String = "Normal"

  // 可能的所有样式选项
  let options = ArrayList<String>(["Normal", "Italic"])

  func handler(fontStyle: String) {
    this.content = fontStyle
    this.parse(fontStyle)
  }

  func parse(fontStyle: String) {
    match (fontStyle) {
      case "Normal" => this.fontStyle = FontStyle.Normal
      case "Italic" => this.fontStyle = FontStyle.Italic
      case _ => this.fontStyle = FontStyle.Normal
    }
  }

  func build() {
    SelectBar(
      title: "FontStyle",
      content: content,
      options: options,
      onSelect: handler
    )
  }
}
