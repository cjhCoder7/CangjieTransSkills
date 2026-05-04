/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.components.chat

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import ohos_app_cangjie_entry.components.avatar.*

@Component
public class ChatLine {
  @Prop var src: CJResource

  @Prop var content: String

  @Prop var isSelf: Bool

  func build() {

    if (isSelf) {
      Row() {
        Row() {
          Text(content)
        }
        .padding(10)
        .backgroundColor(0xffffff)
        .borderRadius(10)
        .constraintSize(maxWidth: 90.percent)
        .margin(right: 10)

        Avatar(src: src, size: 40)
      }.justifyContent(FlexAlign.End)
      .width(100.percent)
      .padding(left: 10)
      .margin(top: 10, bottom: 10)
    } else {
      Row() {
        Avatar(src: src, size: 40)

        Row() {
          Text(content)
        }
        .padding(10)
        .backgroundColor(0xffffff)
        .constraintSize(maxWidth: 90.percent)
        .borderRadius(10)
        .margin(left: 10)
      }.width(100.percent)
      .padding(right: 10)
      .margin(top: 10, bottom: 10, right: 10)
    }
  }
}
