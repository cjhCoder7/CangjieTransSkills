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
import ohos_app_cangjie_entry.controllers
import ohos_app_cangjie_entry.controllers.DataController
import ohos_app_cangjie_entry.controllers.AppStorageHolder
import std.collection.ArrayList

/// 日历视图 — 显示已完成日期的月历
@Component
class CalendarView {
    @Prop var habit: Habit
    @State var currentYear: Int64 = 2026
    @State var currentMonth: Int64 = 1

    var onToggleCompletion: (Int64) -> Unit = { _ => }

    /// 月份名称
    let monthNames = ["一月", "二月", "三月", "四月", "五月", "六月",
                      "七月", "八月", "九月", "十月", "十一月", "十二月"]

    func build() {
        Column(space: 8.0) {
            Text("历史")
                .fontSize(12.0)
                .fontWeight(FontWeight.Bold)
                .width(100.percent)

            // 月份导航
            Row() {
                Button("<")
                    .fontSize(16.0)
                    .width(36.0)
                    .height(36.0)
                    .onClick({ evt => this.prevMonth() })
                Blank()
                Text("${this.monthNames[Int64(this.currentMonth - 1)]} ${this.currentYear}")
                    .fontSize(16.0)
                    .fontWeight(FontWeight.Bold)
                Blank()
                Button(">")
                    .fontSize(16.0)
                    .width(36.0)
                    .height(36.0)
                    .onClick({ evt => this.nextMonth() })
            }
            .width(100.percent)

            // 星期标题
            Row() {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], itemGeneratorFunc: { name: String, idx: Int64 =>
                    Text(name)
                        .fontSize(12.0)
                        .textAlign(TextAlign.Center)
                        .width((100.0 / 7.0).percent)
                }, keyGeneratorFunc: { name: String, idx: Int64 => idx.toString() })
            }
            .width(100.percent)

            // 日期网格
            this.dateGrid()
        }
        .width(100.percent)
    }

    func blankIndices(): ArrayList<Int64> {
        let firstDayOffset = this.getFirstDayOffset()
        var arr = ArrayList<Int64>()
        var i: Int64 = 0
        while (i < firstDayOffset) {
            arr.add(i)
            i += 1
        }
        arr
    }

    func dayIndices(): ArrayList<Int64> {
        let daysInMonth = this.getDaysInMonth()
        var arr = ArrayList<Int64>()
        var i: Int64 = 1
        while (i <= daysInMonth) {
            arr.add(i)
            i += 1
        }
        arr
    }

    @Builder
    func dateGrid() {
        Flex(wrap: FlexWrap.Wrap) {
            ForEach(this.blankIndices(), itemGeneratorFunc: { idx: Int64, i: Int64 =>
                Row() {}
                    .width((100.0 / 7.0).percent)
                    .height(36.0)
            }, keyGeneratorFunc: { idx: Int64, i: Int64 => "blank_${i.toString()}" })
            ForEach(this.dayIndices(), itemGeneratorFunc: { day: Int64, idx: Int64 =>
                this.dayCell(day)
            }, keyGeneratorFunc: { day: Int64, idx: Int64 => day.toString() })
        }
        .width(100.percent)
    }

    @Builder
    func dayCell(day: Int64) {
        Stack() {
            if (this.isDayCompleted(day)) {
                Circle(width: 32.0, height: 32.0)
                    .fill(Color(this.habit.color.colorValue))
            }
            Text("${day}")
                .fontSize(14.0)
                .fontColor(this.dayCellFontColor(day))
                .textAlign(TextAlign.Center)
        }
        .width((100.0 / 7.0).percent)
        .height(36.0)
        .onClick({ evt =>
            this.onToggleCompletion(this.getTimestampForDay(day))
        })
    }

    func isDayCompleted(day: Int64): Bool {
        this.habit.isCompletedByTimestamp(this.getTimestampForDay(day))
    }

    func dayCellFontColor(day: Int64): Color {
        let completed = this.isDayCompleted(day)
        let isToday = DateHelper.isInSameDay(this.getTimestampForDay(day), DateHelper.nowTimestamp())
        if (completed) { Color.White } else if (isToday) { Color.Blue } else { Color.Black }
    }

    func prevMonth(): Unit {
        if (this.currentMonth == 1) {
            this.currentMonth = 12
            this.currentYear -= 1
        } else {
            this.currentMonth -= 1
        }
    }

    func nextMonth(): Unit {
        if (this.currentMonth == 12) {
            this.currentMonth = 1
            this.currentYear += 1
        } else {
            this.currentMonth += 1
        }
    }

    func getFirstDayOffset(): Int64 {
        let approxTimestamp = this.getTimestampForDay(1)
        DateHelper.dayOfWeek(approxTimestamp)
    }

    func getDaysInMonth(): Int64 {
        let daysInMonths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        var days = daysInMonths[Int64(this.currentMonth - 1)]
        if (this.currentMonth == 2) {
            if (this.currentYear % 4 == 0 && (this.currentYear % 100 != 0 || this.currentYear % 400 == 0)) {
                days = 29
            }
        }
        days
    }

    func getTimestampForDay(day: Int64): Int64 {
        let now = DateHelper.nowTimestamp()
        let nowDayStart = DateHelper.startOfDay(now)
        let msPerDay: Int64 = 86400000
        let currentDay = DateHelper.dayOfMonth(now)
        let offset = day - currentDay
        nowDayStart + offset * msPerDay
    }
}
