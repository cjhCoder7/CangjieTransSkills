package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State
    var message: String = "Hello World"

    func build() {
        Row {
            Column(space: 20) {
                Text(this.message)
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
                    .onClick ({
                        evt => this.message = "Hello Cangjie"
                    })
                
                Button("汉字书写练习")
                    .fontSize(20)
                    .margin(top: 30.vp)
                    .onClick ({
                        evt => getUIContext().getRouter().pushUrl(url: "PrototypePage")
                    })

                Button("沉浸式汉字学习")
                    .fontSize(20)
                    .margin(top: 20.vp)
                    .onClick ({
                        evt => getUIContext().getRouter().pushUrl(url: "HanziPage")
                    })

                Button("汉字听力练习")
                    .fontSize(20)
                    .margin(top: 20.vp)
                    .onClick ({
                        evt => getUIContext().getRouter().pushUrl(url: "ListenPage")
                    })

                Button("汉字朗读练习")
                    .fontSize(20)
                    .margin(top: 20.vp)
                    .onClick ({
                        evt => getUIContext().getRouter().pushUrl(url: "SpeakPage")
                    })

                Button("画卷首页")
                    .fontSize(20)
                    .margin(top: 20.vp)
                    .onClick ({
                        evt => getUIContext().getRouter().pushUrl(url: "HomePage")
                    })
            }.width(100.percent)
        }.height(100.percent)
    }
}
