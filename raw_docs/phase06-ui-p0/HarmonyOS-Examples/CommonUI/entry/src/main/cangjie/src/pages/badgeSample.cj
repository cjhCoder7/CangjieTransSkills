package ohos_app_cangjie_entry.pages

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

// 使用 @Component 定制 UI 组件，@Link 变量可实现父子组件双向绑定
@Component
class NumberBadge {
    @Link var count: Int32
    @Link var pos: BadgePosition
    func build() {
        Badge(
            BadgeParams(count: count,
                style: BadgeStyle(color: Color.WHITE, fontSize: 16, badgeSize: 20, badgeColor: Color.RED),
                position: pos,
                maxCount: 99)
        ) {
            Button("message")
            .width(100)
            .height(50)
            .backgroundColor(0x1D4C50)
            .onClick { =>
                count++
            }
        }
        .width(100)
        .height(50)
    }
}

@Component
class TextBadge {
    @Link var text: String
    func build() {
        Badge(
            BadgeParams(value: text,
                style: BadgeStyle(color: Color.WHITE, fontSize: 9, badgeSize: 20, badgeColor: Color.RED))
        ) {
            Text("message")
            .width(80)
            .height(50)
            .fontSize(16)
            .lineHeight(37)
            .borderRadius(10)
            .textAlign(TextAlign.Center)
            .fontColor(Color.WHITE)
            .backgroundColor(0x24271E)
        }
        .width(80)
        .height(50)
    }
}

@Entry
@Component
class BadgeView {
    @State var count1: Int32 = 199
    @State var count2: Int32 = 95
    @State var count3: Int32 = 1
    func build() {
        Column() {
            Text("Badge with Number").fontSize(25).margin(top: 100, bottom: 10)
            Grid {
                GridItem { NumberBadge(count: count1, pos: BadgePosition.RightTop) }
                GridItem { NumberBadge(count: count2, pos: BadgePosition.Left) }
                GridItem { NumberBadge(count: count3, pos: BadgePosition.Right) }
                GridItem { Text(count1.toString()) }
                GridItem { Text(count2.toString()) }
                GridItem { Text(count3.toString()) }
            }
            .columnsTemplate("1fr 1fr 1fr")
            .rowsTemplate("1fr 1fr")
            .height(110)

            Text("Badge with Text").margin(top: 50, bottom: 10).fontSize(25)
            Row(40) {
                TextBadge(text: "new")
                TextBadge(text: "")
            }
        }
    }
}