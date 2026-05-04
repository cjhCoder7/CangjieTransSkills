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
public class TextDecorationBar {
  // 字体装饰类型
  @Link var decorationType: TextDecorationType

  // 字体装饰类型的文本表示
  @State var content: String = "None"

  let options = ArrayList<(String)>(["None", "LineThrough", "Overline", "Underline"])

  // 字体装饰颜色
  @Link var decorationColor: UInt32

  // 字体装饰方式选择的响应回调
  func handler(decorationType: String) {
    this.content = decorationType
    this.parse(decorationType)
  }

  func parse(decorationType: String) {
    match (decorationType) {
      case "None" => this.decorationType = TextDecorationType.None
      case "LineThrough" => this.decorationType = TextDecorationType.LineThrough
      case "Overline" => this.decorationType = TextDecorationType.Overline
      case "Underline" => this.decorationType = TextDecorationType.Underline
      case _ => this.decorationType = TextDecorationType.None
    }
  }


  func build() {
    Column(BAR_INNER_GRID_SIZE) {
      SelectBar(
        title: "DecorationType",
        content: content,
        options: options,
        onSelect: handler
      )

      ColorBand(
        title: "DecorationColor",
        color: decorationColor
      )
    }.width(100.percent)
    .alignItems(HorizontalAlign.Start)
  }

}