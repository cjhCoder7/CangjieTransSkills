package ohos_app_cangjie_entry.widget

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
public class WidgetCard {
    @State
    var firstTitle: String = "赶快去应用里添加吧！"
    @State
    var event1Title: String = ""
    @State
    var event1CountdownText: String = ""
    @State
    var event1Color: Int64 = 0xFF8C939F
    @State
    var event1DateText: String = ""
    @State
    var event1Status: String = "future"

    public func build(): Unit {
        Row {
            if (event1Title.size > 0) {
                Column(space: 14) {
                    Row(space: 8) {
                        Row {
                            Circle()
                                .width(14).height(14)
                                .fill(this.event1Color)
                        }.width(16).height(16)
                            .justifyContent(FlexAlign.Center)
                            .alignItems(VerticalAlign.Center)
                        Text(this.event1Title)
                            .layoutWeight(1)
                            .fontSize(17)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(0xFF10233C)
                            .maxLines(2)
                            .textOverflow(TextOverflow.Ellipsis)
                    }.width(76.percent).alignItems(VerticalAlign.Center).margin(left: 12.percent)

                    Text(this.event1DateText)
                        .width(100.percent).fontSize(14).fontColor(0xFF5F738D)
                        .maxLines(1).textAlign(TextAlign.Center)

                    Text(this.primaryStatusValue(this.event1Status, this.event1CountdownText))
                        .width(100.percent).fontSize(18)
                        .fontWeight(FontWeight.Medium).fontColor(this.event1Color)
                        .maxLines(1).textAlign(TextAlign.Center)
                }.width(100.percent).height(100.percent)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Start)
            } else {
                Column(space: 8) {
                    Text("暂无事件")
                        .fontSize(15).fontWeight(FontWeight.Medium).fontColor(0xFF10233C)
                    Text(this.firstTitle)
                        .fontSize(11).fontColor(0xFF5F738D)
                        .maxLines(2).textAlign(TextAlign.Center)
                        .textOverflow(TextOverflow.Ellipsis)
                }.width(100.percent).height(100.percent).justifyContent(FlexAlign.Center)
            }
        }.width(100.percent).height(100.percent)
            .padding(16)
            .linearGradient(angle: 135.0, colors: [(0xFFF5F9FD, 0.0), (0xFFEAF2FA, 1.0)])
            .borderRadius(26.0)
            .borderWidth(1).borderColor(0xCCFFFFFF)
            .clip(true)
    }

    private func primaryStatusValue(status: String, countdownText: String): String {
        if (countdownText.size == 0) { return "--" }
        if (status == "today") { return "今天" }
        countdownText
    }
}
