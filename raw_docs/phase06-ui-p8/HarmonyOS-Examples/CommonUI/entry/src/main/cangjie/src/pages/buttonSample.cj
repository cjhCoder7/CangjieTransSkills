/**
 * Created on 2024/5/14
 */
package ohos_app_cangjie_entry.pages

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

extend Text {
    func title() {
        this.fontSize(18).fontColor(0xCCCCCC)
    }
}

extend Button {
    func style(shape: ShapeType) {
        this
        .shape(shape)
        .stateEffect(true)
        .borderRadius(8)
        .backgroundColor(0x317aff)
        .width(90)
    }
}

@Entry
@Component
class ButtonView {
    @Builder
    func buttonGroup(shape: ShapeType) {
        Button("Ok").style(shape)
        Button {
            Text("loading").fontSize(12).fontColor(0xffffff).margin(left: 5, right: 12)
        }.style(shape)
        Button("Disable").style(shape).opacity(0.5)
    }

    func build() {
        Flex(FlexParams(direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween)) {
            Text("Common button").title()

            Flex(FlexParams(alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween)) {
                buttonGroup(ShapeType.Normal)
            }

            Text("Capsule button").title()

            Flex(FlexParams(alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween)) {
                buttonGroup(ShapeType.Capsule)
            }

            Text("Circle button").title()

            Flex(FlexParams(alignItems: ItemAlign.Center, wrap: FlexWrap.Wrap)) {
                Button("YES")
                    .shape(ShapeType.CircleType)
                    .stateEffect(true)
                    .width(100) // 将取短边长作为圆形按钮的直径
                    .height(200)
                    .backgroundColor(0x317aff)
                Button("NO")
                    .shape(ShapeType.Capsule)
                    .stateEffect(true)
                    .width(55) // 宽高一致的胶囊型按钮等效于圆形按钮
                    .height(55)
                    .margin(left: 20)
                    .backgroundColor(0xF55A42)
            }
        }
        .height(400)
        .padding(left: 35, right: 35, top: 35)
    }
}