package ohos_app_cangjie_entry.views

import kit.ArkUI.*
import ohos.resource.__GenerateResource__
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

/// 习惯列表行视图
@Component
class HabitRowView {
    @Prop var habit: Habit
    var onToggleCompletion: (Int64) -> Unit = { _ => }
    var onTap: () -> Unit = { => }

    func build() {
        Column(space: 0.0) {
            // 上半部分：百分比 + 勾选框
            Row() {
                this.percentageView()
                Blank()
                this.checkmarksView()
            }
            .margin(left: 22.0, top: 12.0)

            // 下半部分：标题（可点击进入详情）
            Row() {
                Text(this.habit.title)
                    .fontSize(19.0)
                    .maxLines(2)
                    .textOverflow(TextOverflow.Ellipsis)
                    .margin(left: 22.0, right: 22.0)
                Blank()
            }
            .layoutWeight(1)
            .onClick({ evt => this.onTap() })
        }
        .width(100.percent)
        .height(95.0)
        .borderRadius(10.0)
        .backgroundColor(Color(0xFFF7F7F7))
    }

    @Builder
    func percentageView() {
        Text("${this.habit.strengthPercentage}%")
            .fontSize(11.0)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)
            .width(30.0)
            .height(30.0)
            .textAlign(TextAlign.Center)
            .borderWidth(Float64(this.habit.strengthPercentage) * 0.64)
            .borderColor(Color(this.habit.color.colorValue))
            .borderRadius(15.0)
            .backgroundColor(Color(this.habit.color.colorValue))
    }

    @Builder
    func checkmarksView() {
        Row(space: 0.0) {
            ForEach([4, 3, 2, 1, 0], itemGeneratorFunc: { daysAgo: Int64, idx: Int64 =>
                this.checkmarkButton(daysAgo)
            }, keyGeneratorFunc: { daysAgo: Int64, idx: Int64 => daysAgo.toString() })
        }
        .margin(right: 10.0)
    }

    @Builder
    func checkmarkButton(daysAgo: Int64) {
        if (this.habit.isCompletedDaysAgo(daysAgo)) {
            Image(@r(app.media.checkmark))
                .width(Constants.dayOfTheWeekFrameSize)
                .height(Constants.dayOfTheWeekFrameSize)
                .fillColor(Color.Black)
                .onClick({ evt =>
                    this.onToggleCompletion(daysAgo)
                })
        } else {
            Image(@r(app.media.circle))
                .width(Constants.dayOfTheWeekFrameSize)
                .height(Constants.dayOfTheWeekFrameSize)
                .fillColor(Color.Black)
                .onClick({ evt =>
                    this.onToggleCompletion(daysAgo)
                })
        }
    }
}
