package ohos_app_cangjie_entry.pages

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Entry
@Component
class TextInputView {
    @State var text: String = ""
    func build() {
        Column(20) {
            TextInput(placeholder: "请输入...")
            .placeholderColor(QHL)
            .placeholderFont(size: 30, weight: FontWeight.W100, family: "cursive", style: FontStyle.Italic)
            .caretColor(Color.BLUE)
            .height(60)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontStyle(FontStyle.Normal)
            .margin(top: 300)
            .onChange({value: String =>
                this.text = value
            })

            Text(this.text)
            .width(80.percent)
        }
    }
}