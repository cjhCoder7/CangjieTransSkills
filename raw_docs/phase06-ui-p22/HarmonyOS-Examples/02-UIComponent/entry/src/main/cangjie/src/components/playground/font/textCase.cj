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
public class TextCaseBar {
  // 字体的大小写
  @Link var textCase: TextCase

  // 字体大小写
  @State var content: String = "Normal"

  let options = ArrayList<(String)>(["Normal", "LowerCase", "UpperCase"])

  // 字体大小写选择的回调
  func handler(textCase: String) {
    this.content = textCase
    this.parse(textCase)
  }

  func parse(textCase: String) {
    match (textCase) {
      case "Normal" => this.textCase = TextCase.Normal
      case "LowerCase" => this.textCase = TextCase.LowerCase
      case "UpperCase" => this.textCase = TextCase.UpperCase
      case _ => this.textCase = TextCase.Normal
    }
  }

  func build() {
    SelectBar(
      title: "TextCase",
      content: content,
      options: options,
      onSelect: handler
    )
  }
}