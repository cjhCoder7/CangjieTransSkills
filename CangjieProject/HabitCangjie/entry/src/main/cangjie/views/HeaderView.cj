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

/// 顶部标题和星期指示栏
@Component
class HeaderView {
    func build() {
        Row() {
            Text("Habit")
                .fontSize(28.0)
                .fontWeight(FontWeight.Bold)
                .margin(left: 8.0)
            Blank()
            Row(space: 0.0) {
                ForEach([4, 3, 2, 1, 0], itemGeneratorFunc: { daysAgo: Int64, idx: Int64 =>
                    this.dayColumn(daysAgo)
                }, keyGeneratorFunc: { daysAgo: Int64, idx: Int64 => daysAgo.toString() })
            }
            .margin(left: 16.0, right: 10.0)
        }
        .padding(left: 12.0, right: 12.0, top: 12.0, bottom: 4.0)
    }

    @Builder
    func dayColumn(daysAgo: Int64) {
        Column(space: 0.0) {
            Text("${DateHelper.dayOfMonth(DateHelper.todayMinusDaysAgo(daysAgo))}")
                .fontSize(11.0)
                .fontWeight(FontWeight.Bold)
            Text(DateHelper.weekdayShortName(DateHelper.dayOfWeek(DateHelper.todayMinusDaysAgo(daysAgo))))
                .fontSize(11.0)
                .fontWeight(FontWeight.Bold)
        }
        .width(Constants.dayOfTheWeekFrameSize)
        .height(Constants.dayOfTheWeekFrameSize)
        .opacity(if (daysAgo == 0) { 1.0 } else { 0.5 })
    }
}
