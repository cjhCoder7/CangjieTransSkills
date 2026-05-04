package ohos_app_cangjie_entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.display.*
import std.random.*

const N = 1024
let random = Random()

@Entry
@Component
class EntryView {
    let words = Array<Rune>(N) { _ =>
        Rune(0x4E00 + random.nextUInt32(0x9FFF - 0x4E00))
    }
    let width = Int64(getDefaultDisplaySync().width)
    let fontSize = width / 8
    let height = N * fontSize

    func build() {
        Stack {
            Text("仓颉").fontSize((width / 4).px).fontColor(0xCCCCCC)
            Scroll {
                Stack {
                    ForEach(words, itemGeneratorFunc: { word: Rune, _: Int64 =>
                        Text(String(word))
                        .fontSize(fontSize.px)
                        .borderWidth(1)
                        .position(x: random.nextInt64(100).percent,
                            y: random.nextInt64(height).px)
                    })
                }
                .width(100.percent)
                .height(height.px)
            }
        }
    }
}