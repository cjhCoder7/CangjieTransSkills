package ohos_app_cangjie_entry.views

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos_app_cangjie_entry.models
import ohos_app_cangjie_entry.models.Habit
import ohos_app_cangjie_entry.models.HabitColor
import ohos_app_cangjie_entry.models.DateHelper
import ohos_app_cangjie_entry.models.Constants
import ohos_app_cangjie_entry.models.randomHabitColor
import ohos_app_cangjie_entry.models.allHabitColors
import std.collection.ArrayList

/// 图表显示模式
public enum ChartDisplayMode {
    | SixMonths
    | OneYear

    public operator func ==(right: ChartDisplayMode): Bool {
        match (this) {
            case SixMonths => match (right) { case SixMonths => true case _ => false }
            case OneYear => match (right) { case OneYear => true case _ => false }
        }
    }

    public prop displayName: String {
        get() {
            match (this) {
                case SixMonths => "六个月"
                case OneYear   => "一年"
            }
        }
    }
}

/// GitHub 风格贡献图
@Component
class ChartView {
    @Prop var dates: ArrayList<Int64>
    @Prop var color: HabitColor
    @State var displayMode: ChartDisplayMode = ChartDisplayMode.SixMonths

    let rows: Int64 = 7

    prop columns: Int64 {
        get() {
            match (displayMode) {
                case SixMonths => 26
                case OneYear   => 53
            }
        }
    }

    prop spacing: Float64 {
        get() {
            match (displayMode) {
                case SixMonths => 2.5
                case OneYear   => 1.0
            }
        }
    }

    prop cornerRadius: Float64 {
        get() { 2.0 }
    }

    func build() {
        Column(space: 0.0) {
            Row() {
                Text("历史")
                    .fontSize(12.0)
                    .fontWeight(FontWeight.Bold)
                Blank()
                Row() {
                    Text(this.displayMode.displayName)
                        .fontSize(14.0)
                        .fontColor(Color.Gray)
                        .onClick({ evt =>
                            if (this.displayMode == ChartDisplayMode.SixMonths) {
                                this.displayMode = ChartDisplayMode.OneYear
                            } else {
                                this.displayMode = ChartDisplayMode.SixMonths
                            }
                        })
                }
            }
            .width(100.percent)
            .margin(bottom: 8.0)

            Scroll() {
                Row(space: this.spacing) {
                    ForEach(this.columnIndices(), itemGeneratorFunc: { colIdx: Int64, idx: Int64 =>
                        this.columnView(colIdx)
                    }, keyGeneratorFunc: { colIdx: Int64, idx: Int64 => colIdx.toString() })
                }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
        }
        .width(100.percent)
    }

    func columnIndices(): ArrayList<Int64> {
        var arr = ArrayList<Int64>()
        var i: Int64 = 0
        while (i < columns) {
            arr.add(i)
            i += 1
        }
        arr
    }

    func rowIndices(): ArrayList<Int64> {
        var arr = ArrayList<Int64>()
        var i: Int64 = 0
        while (i < rows) {
            arr.add(i)
            i += 1
        }
        arr
    }

    @Builder
    func columnView(colIdx: Int64) {
        Column(space: this.spacing) {
            ForEach(this.rowIndices(), itemGeneratorFunc: { rowIdx: Int64, idx: Int64 =>
                this.cellView(colIdx, rowIdx)
            }, keyGeneratorFunc: { rowIdx: Int64, idx: Int64 => "${colIdx}_${rowIdx}" })
        }
    }

    @Builder
    func cellView(colIdx: Int64, rowIdx: Int64) {
        Column() {}
            .width(this.cellWidth())
            .height(this.cellHeight())
            .borderRadius(this.cornerRadius)
            .backgroundColor(this.getCellColor(colIdx, rowIdx))
    }

    func cellWidth(): Float64 {
        if (this.displayMode == ChartDisplayMode.SixMonths) { 10.0 } else { 6.0 }
    }

    func cellHeight(): Float64 {
        if (this.displayMode == ChartDisplayMode.SixMonths) { 10.0 } else { 6.0 }
    }

    func getCellColor(colIdx: Int64, rowIdx: Int64): Color {
        let cellCount = this.columns * this.rows
        let index = (this.rows * colIdx) + rowIdx
        let reverseIndex = cellCount - index - 1
        let daysShiftOffset = calculateDaysShiftOffset()
        let shiftedIndex = reverseIndex - daysShiftOffset
        getColorForCell(shiftedIndex)
    }

    func getColorForCell(index: Int64): Color {
        if (index < 0) {
            return Color.Transparent
        }
        let date = DateHelper.todayMinusDaysAgo(index)
        let now = DateHelper.nowTimestamp()
        if (date > now) {
            return Color.Transparent
        }
        if (isDateCompleted(date)) {
            return Color(this.color.colorValue)
        }
        return Color(0xFFEBEDF0)
    }

    func isDateCompleted(timestamp: Int64): Bool {
        for (d in dates) {
            if (DateHelper.isInSameDay(d, timestamp)) {
                return true
            }
        }
        return false
    }

    func calculateDaysShiftOffset(): Int64 {
        if (rows != 7) {
            return 0
        }
        let now = DateHelper.nowTimestamp()
        let dow = DateHelper.dayOfWeek(now)
        (7 - dow) % 7
    }
}
