/**
 * Created on 2024/7/30
 */
package ohos_app_cangjie_entry.components.index

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import ohos.resource_manager.*

extend Column {
  // 表单中的一组输入单元,至少有一个标签Text和一个文本输入TextInput
  func formInputGroup() {
    this.width(100.percent).margin(top: 10, bottom: 10)
    .alignItems(HorizontalAlign.Start)
  }
}

extend TextInput {
  // 表单输入框
  func formInput() {
    this.fontSize(24).backgroundColor(0xffffff)
    .borderRadius(6.fp).borderWidth(1).borderColor(0xe5e8e8)
  }
}

@Component
public class IndexTextInput {
  func build() {
    Column() {
      Text("TextInput").title().fontColor(0xffffff)

      Column(10) {
        Text("Your phone number").fontColor(0xf1b980)
        TextInput(placeholder: "xxx-xxxx-xxxx").formInput()
      }.formInputGroup()

      Column(10) {
        Text("Your email").fontColor(0xf1b980)
        TextInput(placeholder: "example@huawei.com").formInput()
      }.formInputGroup()

      Column() {
        Button("Join Cangjie").rounded()
        .width(100.percent)
        .backgroundColor(0x0065ff)
      }.formInputGroup()
    }.card().width(100.percent)
    .padding(20).backgroundColor(0x005246)
    .redirect("TextInputView")
  }
}