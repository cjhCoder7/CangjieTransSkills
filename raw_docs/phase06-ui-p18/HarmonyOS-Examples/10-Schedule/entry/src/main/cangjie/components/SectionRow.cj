/**
 * Created on 2025/7/23
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

import cj_res_entry.app

extend Text {
    func sectionTiSty() {
        this.fontSize(14)
            .fontWeight(FontWeight.W400)
            .textAlign(TextAlign.Center)
            .width(100.percent)
            .height(100.percent)
    }
}

extend Column {
    func secTime(curWidth: Int64) {
        this.justifyContent(FlexAlign.Center).width(curWidth).height(42)
    }
}

@Component
public class SectionRow {
    @Prop var weekdaysScroller: Scroller
    @Prop var classificationNames: Array<String>
    @Prop var horizontalScroller: Scroller

    public func build() {
        Row {
            Column {
                Text('节').sectionTiSty()
            }.secTime(50)

            Column {
                Text('上课时间').sectionTiSty()
            }.secTime(60)

            Column {
                Scroll (this.weekdaysScroller) {
                    Row {
                        ForEach(this.classificationNames, { item: String, _: Int64 =>
                            Column {
                                Row {
                                    Text(item)
                                    .fontSize(14)
                                    .fontWeight(FontWeight.W400)
                                    .textAlign(TextAlign.Center)
                                    .fontColor(Color.BLACK)
                                    .width(100.percent)
                                }
                            }
                            .padding(4)
                            .justifyContent(FlexAlign.Center)
                            .width(120)
                            .height(42)
                            .backgroundColor(Color.WHITE)
                        })
                    }
                }
                .height(42)
                .width(70.percent)
                .scrollBar(BarState.Off)
                .scrollable(ScrollDirection.Horizontal)
                .onScrollFrameBegin({ offset, state =>
                    this.horizontalScroller.scrollBy(xOffset: offset, yOffset: 0.0)
                    return offset
                })
            }
        }
        .width(100.percent)
        .position(x: 0, y: 0)
        .backgroundColor(Color.WHITE)
        .borderRadius(topLeft: Length(16))
        .shadow(radius: 50, color: Color(0x25000000))
        .zIndex(10)
    }
}