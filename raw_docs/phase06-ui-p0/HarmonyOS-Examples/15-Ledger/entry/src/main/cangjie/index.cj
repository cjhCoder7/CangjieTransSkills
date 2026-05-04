package ohos_app_cangjie_entry

import ohos_app_cangjie_entry.constant.*
import ohos_app_cangjie_entry.utils.*
import ohos_app_cangjie_entry.ui.*
import ohos_app_cangjie_entry.ui.entity.*

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import cj_res_entry.app
import std.format.*
import std.time.*
import std.collection.*

@Entry
@Component
public class EntryView  {
    @State
    var dynamicTime: DynamicTime = DynamicTime()
    @State
    var dynamicStyle: DynamicStyle = DynamicStyle()
    @State
    var dynamicBill: DynamicBill = DynamicBill()
    // 内存数据源 后续可接服务
    var sourceData: ArrayList<SourceData> = ArrayList<SourceData>()

    public func aboutToAppear() {
        dynamicTime.reset()
        sourceData = mockSourceData()
        dynamicStyle.dynamicTime = dynamicTime
        dynamicBill.dynamicStyle = dynamicStyle
        update()
    }

    @Builder
    func mainBody() {
        Column {
            // 顶栏
            TopBar()
            MonthPickerRow(
                dynamicTime: dynamicTime,
                dynamicStyle: dynamicStyle,
                dynamicBill: dynamicBill
            )
            WeekHeader()
            CalendarGrid(
                dynamicTime: dynamicTime,
                dynamicStyle: dynamicStyle,
                dynamicBill: dynamicBill,
                update: update
            )
            SummaryBar(dynamicBill: dynamicBill)
            DetailsList(dynamicBill: dynamicBill)
        }
        .padding(left: 16, right: 16)
        .backgroundColor(@r(app.color.background_color))
        .width(100.percent)
        .height(100.percent)
        .foregroundBlurStyle(dynamicStyle.getForegroundBlurStyle())
        .zIndex(1)
    }

    public func build() {
        Stack {
            DatePickerComponent(
                dynamicStyle: dynamicStyle,
                dynamicTime: dynamicTime,
                update: update
            )
            mainBody()
        }
    }
    func update() {
        dynamicStyle.update(sourceData)
        dynamicBill.update(sourceData)
        dynamicTime.update(sourceData)
    }

    // mock数据
    private func mockSourceData(): ArrayList<SourceData> {
        let tz = TimeZone.Local
        ArrayList<SourceData>([
            SourceData(false, "慈善捐助", 10.0, "现金", "159****1700",
                DateTime.of(year: 2025, month: 8, dayOfMonth: 12, hour: 9, minute: 24, timeZone: tz), @r(app.media.heart)),
            SourceData(false, "晚餐", 24.3, "现金", "159****1700",
                DateTime.of(year: 2025, month: 8, dayOfMonth: 12, hour: 18, minute: 23, timeZone: tz), @r(app.media.knives)),
            SourceData(true, "工资", 3000.0, "现金", "159****1700",
                DateTime.of(year: 2025, month: 8, dayOfMonth: 17, hour: 15, minute: 39, timeZone: tz), @r(app.media.heart)),
            SourceData(false, "午餐", 56.8, "现金", "159****1700",
                DateTime.of(year: 2025, month: 8, dayOfMonth: 17, hour: 11, minute: 39, timeZone: tz), @r(app.media.knives)),
            SourceData(true, "退款", 123.0, "现金", "159****1700",
                DateTime.of(year: 2025, month: 8, dayOfMonth: 25, hour: 10, minute: 35, timeZone: tz), @r(app.media.heart)),
            SourceData(false, "晚餐", 56.8, "现金", "159****1700",
                DateTime.of(year: 2025, month: 8, dayOfMonth: 25, hour: 17, minute: 59, timeZone: tz), @r(app.media.knives))
        ])
    }
}
