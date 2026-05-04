/**
 * Created on 2025/7/17
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.*
import std.collection.*

extend Text {
    func timeText() {
        this.fontSize(12)
            .textAlign(TextAlign.Start)
            .fontColor(Color.BLACK)
            .width(100.percent)
            .height(30.percent)
            .align(Alignment.Bottom)
            .lineHeight(10)
    }
}

extend Scroll {
    func ScrollSty(curScroller1: Scroller, curScroller2: Scroller) {
        this.backgroundColor(Color(0xF8F8FF))
            .scrollBar(BarState.Off)
            .onScrollFrameBegin({ offset, state =>
                curScroller1.scrollBy(xOffset: 0.0, yOffset: offset)
                curScroller2.scrollBy(xOffset: 0.0, yOffset: offset)
                return offset
            })
    }
}

extend Column {
    func ColumnSty(curTop: Int64, curBottom: Int64, curLeft: Int64, curRight: Int64, curWidth: Int64) {
        this.padding(top: curTop, bottom: curBottom, left: curLeft, right: curRight)
            .justifyContent(FlexAlign.Center)
            .width(curWidth)
            .height(100)
            .backgroundColor(Color.WHITE)
    }
}

@Component
public class SectionTime {
    @Prop var classIndex: Array<String>
    @Prop var classScroller: Scroller
    @Prop var verticalScroller: Scroller
    @Prop var timeScroller: Scroller
    @Prop var classTime: Array<String>

    public func build() {
        Column {
            Row {
                Column {
                    Scroll(classScroller) {
                        Column {
                            ForEach(classIndex, { item: String, _: Int64 =>
                                Column {
                                    Text(item)
                                        .fontSize(14)
                                        .fontWeight(FontWeight.W400)
                                        .textAlign(TextAlign.Center)
                                        .fontColor(Color.BLACK)
                                        .width(100.percent)
                                        .height(30.percent)
                                        .align(Alignment.Bottom)
                                        .lineHeight(10)
                                }.ColumnSty(4, 4, 4, 4, 50)
                            })
                        }
                    }.ScrollSty(this.verticalScroller, this.timeScroller)
                }

                Column {
                    Scroll(timeScroller) {
                        Column {
                            ForEach(this.classTime, { item: String, _: Int64 =>
                                Column {
                                    Text(item.split('-')[0] + ' -')
                                        .timeText()
                                    Text(item.split('-')[1])
                                        .timeText()
                                }.ColumnSty(10, 10, 6, 6, 60)
                            })
                        }
                    }.ScrollSty(this.verticalScroller, this.classScroller)
                }
            }
        }
        .width(110)
        .height(100.percent)
        .backgroundColor(Color.WHITE)
        .shadow(radius: 45, color: Color(0x25000000), offsetY: -15)
        .padding(top: 4, bottom: 20)
    }
}