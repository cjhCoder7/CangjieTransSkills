package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class FallbackView {
    func build() {
        Column(space: 16) {
            Text("页面加载失败")
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color(0xFF172326))

            Text("请稍后重新打开应用")
                .fontSize(15)
                .fontColor(Color(0xFF6B7A80))
        }
        .width(100.percent)
        .height(100.percent)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding(32)
        .backgroundColor(Color(0xFFF5F8F8))
    }
}
