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
import ohos_app_cangjie_entry.dataModel.CourseItem
import ohos_app_cangjie_entry.dataModel.CourseEntity

@Builder
public func courseBuilder(msg: CJResource, curHeight: Int64, curWidth: Int64, curBackgroundColor: Color, curFontColor: Color) {
    Row {
        Column {
            Stack {
                Column()
                .backgroundColor(curBackgroundColor)
                .width(100.percent)
                .height(100.percent)
                .opacity(0.7)

                Text(msg)
                .fontSize(12)
                .fontWeight(FontWeight.W400)
                .textAlign(TextAlign.Center)
                .fontColor(curFontColor)
                .opacity(0.9)
                .width(100.percent)
                .height(100.percent)
                .padding(6)
            }
        }
        .padding(6)
        .justifyContent(FlexAlign.Center)
        .width(curWidth)
        .height(curHeight)
        .backgroundColor(Color.WHITE)
    }
}

@Component
public class Course {
    @Prop var horizontalScroller: Scroller
    @Prop var verticalScroller: Scroller
    @Prop var classScroller: Scroller
    @Prop var timeScroller: Scroller
    @Prop var weekdaysScroller: Scroller
    let data = CourseEntity().data
    let arr = CourseEntity().arr

    public func build() {
        Column {
            Scroll(this.horizontalScroller) {
                Column {
                    Scroll(this.verticalScroller) {
                        Column {
                            ForEach(arr, { index: Int64, idx: Int64 =>
                                Row {
                                    ForEach(data[arr[index]], { item: CourseItem, idx: Int64 =>
                                        courseBuilder(item.name, 100, 120, item.backColor, Color.BLACK)
                                    })
                                }
                            })
                        }
                    }
                    .scrollBar(BarState.Off)
                    .scrollable(ScrollDirection.Vertical)
                    .height(100.percent)
                    .width(7 * 120 - 10)
                    .onScrollFrameBegin({ offset, state =>
                        this.classScroller.scrollBy(xOffset: 0.0, yOffset: offset)
                        this.timeScroller.scrollBy(xOffset: 0.0, yOffset: offset)
                        return offset
                    })
                }
            }
            .padding(top: 4, left: 4, right: 4, bottom: 20)
            .scrollBar(BarState.Off)
            .scrollable(ScrollDirection.Horizontal)
            .onScrollFrameBegin({ offset, state =>
                this.weekdaysScroller.scrollBy(xOffset: offset, yOffset: 0.0)
                return offset
            })
        }
        .zIndex(-100)
        .width(70.percent)
    }
}