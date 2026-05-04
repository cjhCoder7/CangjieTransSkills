package ohos_app_cangjie_entry

internal import ohos.base.LengthProp
internal import ohos.component.*
internal import ohos.router.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

// 使用 extend 特性封装公共属性、定制组件
const QHL = 0x1D4C50u32
extend Button {
    func jump(url: String) {
        this.fontSize(25).height(50).width(70.percent).backgroundColor(QHL)
        .onClick {
            Router.push(url: url)
        }
    }
}

@Entry
@Component
class EntryView {
    func build() {
        Scroll() {
            Column(20) {
                Text("基础 UI 组件").fontSize(30).margin(top: 25, bottom: 25)
                Button("Badge").jump("BadgeView")
                Button("Button").jump("ButtonView")
                Button("CheckBox").jump("CheckBoxView")
                Button("Text").jump("TextView")
                Button("Tabs").jump("TabsView")
                Button("Swiper").jump("SwiperView")
                Button("TextInput").jump("TextInputView")
                Button("Slider").jump("SliderView")
            }.width(100.percent)
        }
    }
}
