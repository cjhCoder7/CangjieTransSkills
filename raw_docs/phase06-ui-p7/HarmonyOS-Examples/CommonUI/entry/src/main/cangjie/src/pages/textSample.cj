package ohos_app_cangjie_entry.pages

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
internal import ohos.router.*

const QHL = 0x1D4C50u32

@Entry
@Component
public class TextView {
    @State var text = "Hello Cangjie"
    @State var fontSize = 40
    @State var fontStyle: FontStyle = FontStyle.Normal
    @State var fontWeight: FontWeight = FontWeight.Normal

    func build(){
        Column(20) {
            Text(this.text)
            .fontSize(this.fontSize)
            .fontColor(Color(0xAE7F77))
            .fontStyle(this.fontStyle)
            .fontWeight(this.fontWeight)
            .margin(top: 100, bottom: 50)

            Button("修改文本").backgroundColor(QHL)
            .onClick { =>
                this.text = "Hello World"
            }

            Button("字号+").backgroundColor(QHL)
            .onClick { =>
                if(this.fontSize < 60) {
                    this.fontSize += 2
                }
            }

            Button("字号-").backgroundColor(QHL)
            .onClick { =>
                if(this.fontSize > 20) {
                    this.fontSize -= 2
                }
            }

            Row {
                Checkbox()
                .size(width: 20, height: 20)
                .selectedColor(QHL)
                .onChange({ value: Bool =>
                    if (value) {
                        this.fontStyle = FontStyle.Italic
                    } else {
                        this.fontStyle = FontStyle.Normal
                    }
                })
                Text("斜体").fontSize(20)
            }

            Row {
                Checkbox()
                .size(width: 20, height: 20)
                .selectedColor(QHL)
                .onChange({ value: Bool =>
                    if (value) {
                        this.fontWeight = FontWeight.Bold
                    } else {
                        this.fontWeight = FontWeight.Normal
                    }
                })
                Text("粗体").fontSize(20)
            }
        }.width(100.percent)
    }
}