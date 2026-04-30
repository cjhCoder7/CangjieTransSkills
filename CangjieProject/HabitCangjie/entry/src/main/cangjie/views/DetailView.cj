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

/// 习惯详情视图
@Component
class DetailView {
    @Prop var habit: Habit
    @State var overviewPageIndex: Int32 = 0

    var onClose: () -> Unit = { => }
    var onEdit: (Habit) -> Unit = { _ => }
    var onDelete: (Habit) -> Unit = { _ => }
    var onToggleCompletion: (Habit, Int64) -> Unit = { _, _ => }

    func build() {
        Column() {
            // 顶部操作栏
            Row() {
                Button("关闭")
                    .fontColor(Color.Black)
                    .onClick({ evt => this.onClose() })
                Blank()
                Button("编辑")
                    .fontColor(Color.Black)
                    .onClick({ evt => this.onEdit(this.habit) })
            }
            .width(100.percent)
            .padding(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0)

            Scroll() {
                Column(space: 0.0) {
                    // 规律性和提醒
                    this.regularityAndReminder()
                    // 概览
                    this.overview()
                    // 图表
                    ChartView(dates: this.habit.completedDates, color: this.habit.color)
                    // 日历
                    CalendarView(habit: this.habit, onToggleCompletion: { daysAgo: Int64 =>
                        this.onToggleCompletion(this.habit, daysAgo)
                    })
                }
            }
            .layoutWeight(1)
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(Color.White)
    }

    @Builder
    func regularityAndReminder() {
        Row() {
            Column() {
                Text("规律性")
                    .fontSize(12.0)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.Black)
                Text("每天")
                    .fontColor(Color.Black)
            }
            .margin(left: 16.0, right: 70.0)

            Column() {
                Text("提醒我")
                    .fontSize(12.0)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.Black)
                Text("--:--")
                    .fontColor(Color.Black)
            }
            Blank()
        }
        .padding(top: 40.0, bottom: 15.0)
        .width(100.percent)
    }

    @Builder
    func overview() {
        Column() {
            Text("概览")
                .fontSize(12.0)
                .fontWeight(FontWeight.Bold)
                .margin(left: 16.0, bottom: 8.0)

            Tabs() {
                TabContent() {
                    Column(space: 0.0) {
                        Text("习惯强度")
                            .fontSize(18.0)
                            .fontWeight(FontWeight.Bold)
                            .margin(bottom: 4.0)
                        Text("${this.habit.strengthPercentage}%")
                            .fontSize(50.0)
                            .fontWeight(FontWeight.Bold)
                        Row() {
                            Text("月: +${this.habit.strengthGainedWithinLastDays(30)}%")
                                .margin(right: 60.0)
                                .fontSize(14.0)
                            Text("年: +${this.habit.strengthGainedWithinLastDays(365)}%")
                                .fontSize(14.0)
                        }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .padding(16.0)
                }.tabBar("强度")

                TabContent() {
                    Column(space: 0.0) {
                        Text("完成次数")
                            .fontSize(18.0)
                            .fontWeight(FontWeight.Bold)
                            .margin(bottom: 4.0)
                        Text("${this.habit.completedDates.size}")
                            .fontSize(50.0)
                            .fontWeight(FontWeight.Bold)
                        Row() {
                            Text("月: +${this.habit.completionsWithinLastDays(30)}")
                                .margin(right: 60.0)
                                .fontSize(14.0)
                            Text("年: +${this.habit.completionsWithinLastDays(365)}")
                                .fontSize(14.0)
                        }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .padding(16.0)
                }.tabBar("完成")

                TabContent() {
                    Column(space: 0.0) {
                        Text("连续天数")
                            .fontSize(18.0)
                            .fontWeight(FontWeight.Bold)
                            .margin(bottom: 4.0)
                        Text("${this.habit.streak} 天")
                            .fontSize(50.0)
                            .fontWeight(FontWeight.Bold)
                        Row() {
                            Text("最长连续: ${this.habit.longestStreak} 天")
                                .margin(right: 60.0)
                                .fontSize(14.0)
                            Text("")
                                .fontSize(14.0)
                        }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .padding(16.0)
                }.tabBar("连续")
            }
            .height(190.0)
            .onChange({ idx: Int32 => this.overviewPageIndex = idx })
        }
    }
}
