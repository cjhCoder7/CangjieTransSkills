package ohos_app_cangjie_entry.pages

import kit.AbilityKit.UIAbilityContext
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.services.*
import ohos_app_cangjie_entry.theme.*
import ohos_app_cangjie_entry.utils.AppContext
import std.collection.ArrayList

@Entry
@Component
public class StatisticsPage {
    @State
    var dashboard: StatisticsDashboard = StatisticsService.emptyDashboard()
    @State
    var isLoading: Bool = true

    protected override func aboutToAppear(): Unit {
        loadEvents()
    }

    private func getDataContext(): UIAbilityContext {
        AppContext.get()
    }

    private func loadEvents(): Unit {
        isLoading = true
        try {
            let eventList = EventRepository.getAllEvents(getDataContext())
            dashboard = StatisticsService.buildDashboard(eventList)
        } catch (_: Exception) {
            dashboard = StatisticsService.emptyDashboard()
        }
        isLoading = false
    }

    public func build(): Unit {
        Column {
            // 页面头部
            Column(space: 8) {
                Stack {
                    Row {
                        Button {
                            Image(@r(app.media.back))
                                .width(16).height(16)
                                .fillColor(AppTheme.COLOR_PRIMARY_DARK)
                        }.shape(ButtonType.Normal)
                            .width(28).height(28)
                            .backgroundColor(Color.Transparent)
                            .borderWidth(0)
                            .onClick({
                                _ => this.getUIContext().getRouter().back()
                            })
                        Blank()
                    }.width(100.percent)
                    Text("时光概览")
                        .fontSize(AppTheme.FONT_PAGE_TITLE)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                        .textAlign(TextAlign.Center)
                }.width(100.percent)
            }.width(100.percent)
                .padding(top: 50, left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING, bottom: 14)

            if (isLoading) {
                Column {
                    Text("正在整理统计数据...")
                        .fontSize(AppTheme.FONT_BODY)
                        .fontColor(AppTheme.COLOR_TEXT_SECONDARY)
                }.width(100.percent).layoutWeight(1)
                    .justifyContent(FlexAlign.Center)
            } else if (dashboard.summary.totalCount == 0) {
                // 空状态
                Column(space: 14) {
                    Text("还没有记录")
                        .fontSize(AppTheme.FONT_EMPTY_TITLE)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                    Text("添加一个重要日子后，这里会自动整理。")
                        .fontSize(AppTheme.FONT_BODY)
                        .fontColor(AppTheme.COLOR_TEXT_SECONDARY)
                    Button("去添加")
                        .height(42)
                        .padding(left: 18, right: 18)
                        .linearGradient(angle: 180.0, colors: [(AppTheme.COLOR_PRIMARY, 0.0), (AppTheme.COLOR_PRIMARY_DARK, 1.0)])
                        .fontColor(Color.White)
                        .borderRadius(42.0)
                        .onClick({
                            _ => this.getUIContext().getRouter().pushUrl(url: "EventFormPage")
                        })
                }.width(100.percent).layoutWeight(1)
                    .justifyContent(FlexAlign.Center)
                    .padding(left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING)
            } else {
                Scroll {
                    Column(space: 16) {
                        // 概览卡片
                        Row(space: 10) {
                            this.OverviewItem("全部", "${dashboard.summary.totalCount}")
                            this.OverviewItem("7天内", "${dashboard.summary.next7DaysCount}")
                            this.OverviewItem("30天内", "${dashboard.summary.next30DaysCount}")
                            this.OverviewItem("提醒", "${dashboard.summary.reminderOnCount}")
                        }.width(100.percent)

                        // 本月提醒
                        Column(space: 14) {
                            Column(space: 4) {
                                Text("本月待提醒事件")
                                    .fontSize(AppTheme.FONT_CARD_TITLE)
                                    .fontWeight(FontWeight.Bold)
                                    .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                                Text("统计本月到来事件的提醒覆盖")
                                    .fontSize(AppTheme.FONT_CAPTION)
                                    .fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                            }.width(100.percent).alignItems(HorizontalAlign.Start)

                            Row(space: 10) {
                                this.MonthMetric("本月到来", "${dashboard.monthReminder.monthEventCount}", AppTheme.COLOR_INFO_SOFT, AppTheme.COLOR_PRIMARY)
                                this.MonthMetric("有提醒", "${dashboard.monthReminder.reminderCount}", AppTheme.COLOR_SUCCESS_SOFT, AppTheme.COLOR_SUCCESS_DARK)
                                this.MonthMetric("无提醒", "${dashboard.monthReminder.noReminderCount}", AppTheme.COLOR_WARNING_SOFT, AppTheme.COLOR_WARNING_DARK)
                            }.width(100.percent)
                        }.width(100.percent)
                            .padding(left: 16, right: 16, top: 16, bottom: 16)
                            .backgroundColor(AppTheme.COLOR_SURFACE)
                            .borderRadius(AppTheme.CARD_RADIUS)
                            .borderWidth(1).borderColor(AppTheme.COLOR_BORDER)
                            .shadow(radius: 14.0, color: AppTheme.SHADOW_COLOR, offsetX: 0.0, offsetY: 8.0)

                        // 自动洞察
                        if (dashboard.insights.size > 0) {
                            Column(space: 12) {
                                Text("自动洞察")
                                    .fontSize(AppTheme.FONT_CARD_TITLE)
                                    .fontWeight(FontWeight.Bold)
                                    .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                                ForEach(dashboard.insights, itemGenerator: {
                                    text: String, _: Int64 => Row(space: 8) {
                                        Row().width(6).height(6).borderRadius(3.0).backgroundColor(AppTheme.COLOR_PRIMARY)
                                        Text(text)
                                            .fontSize(AppTheme.FONT_BODY_SMALL)
                                            .lineHeight(20.0)
                                            .fontColor(AppTheme.COLOR_TEXT_SECONDARY)
                                            .layoutWeight(1)
                                    }.width(100.percent).alignItems(VerticalAlign.Center)
                                }, keyGenerator: {
                                    text: String, _: Int64 => text
                                })
                            }.width(100.percent)
                                .padding(left: 16, right: 16, top: 16, bottom: 16)
                                .backgroundColor(AppTheme.COLOR_SURFACE)
                                .borderRadius(AppTheme.CARD_RADIUS)
                                .borderWidth(1).borderColor(AppTheme.COLOR_BORDER)
                                .shadow(radius: 14.0, color: AppTheme.SHADOW_COLOR, offsetX: 0.0, offsetY: 8.0)
                        }

                        // 整体数据分布
                        Column(space: 14) {
                            Text("整体数据分布")
                                .fontSize(AppTheme.FONT_CARD_TITLE)
                                .fontWeight(FontWeight.Bold)
                                .fontColor(AppTheme.COLOR_TEXT_PRIMARY)

                            // 时间分布
                            Column(space: 8) {
                                Text("时间").fontSize(AppTheme.FONT_CAPTION).fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                                ForEach(dashboard.countdownBuckets, itemGenerator: {
                                    item: CountdownBucket, _: Int64 => Column(space: 6) {
                                        Row {
                                            Text(item.label)
                                                .fontSize(AppTheme.FONT_BODY_SMALL).fontColor(AppTheme.COLOR_TEXT_SECONDARY)
                                            Blank()
                                            Text("${item.value}")
                                                .fontSize(AppTheme.FONT_BODY_SMALL)
                                                .fontWeight(FontWeight.Medium).fontColor(AppTheme.COLOR_TEXT_PRIMARY)
                                        }.width(100.percent)
                                        Stack(alignContent: Alignment.Start) {
                                            Row().width(100.percent).height(8).backgroundColor(AppTheme.COLOR_CHART_TRACK).borderRadius(4.0)
                                            Row().width(this.structureWidthPercent(item.value).percent).height(8).backgroundColor(item.color).borderRadius(4.0)
                                        }.width(100.percent).height(8)
                                    }.width(100.percent).padding(top: 2, bottom: 2)
                                }, keyGenerator: {
                                    item: CountdownBucket, _: Int64 => item.key
                                })
                            }.width(100.percent)

                            // 重复分布
                            Column(space: 8) {
                                Text("重复").fontSize(AppTheme.FONT_CAPTION).fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                                Row(space: 12) {
                                    ForEach(dashboard.repeatBuckets, itemGenerator: {
                                        item: RepeatBucket, _: Int64 => Row(space: 6) {
                                            Row().width(8).height(8).borderRadius(4.0).backgroundColor(item.color)
                                            Text("${item.label} ${item.value}")
                                                .fontSize(AppTheme.FONT_HINT).fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                                        }
                                    }, keyGenerator: {
                                        item: RepeatBucket, _: Int64 => item.key
                                    })
                                }.width(100.percent).justifyContent(FlexAlign.Center)
                            }.width(100.percent)

                            // 日期分布
                            Column(space: 8) {
                                Text("日期").fontSize(AppTheme.FONT_CAPTION).fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                                Row(space: 12) {
                                    ForEach(dashboard.calendarBuckets, itemGenerator: {
                                        item: CalendarBucket, _: Int64 => Row(space: 6) {
                                            Row().width(8).height(8).borderRadius(4.0).backgroundColor(item.color)
                                            Text("${item.label} ${item.value}")
                                                .fontSize(AppTheme.FONT_HINT).fontColor(AppTheme.COLOR_TEXT_TERTIARY)
                                        }
                                    }, keyGenerator: {
                                        item: CalendarBucket, _: Int64 => item.key
                                    })
                                }.width(100.percent).justifyContent(FlexAlign.Center)
                            }.width(100.percent)
                        }.width(100.percent)
                            .padding(left: 16, right: 16, top: 16, bottom: 16)
                            .backgroundColor(AppTheme.COLOR_SURFACE)
                            .borderRadius(AppTheme.CARD_RADIUS)
                            .borderWidth(1).borderColor(AppTheme.COLOR_BORDER)
                            .shadow(radius: 14.0, color: AppTheme.SHADOW_COLOR, offsetX: 0.0, offsetY: 8.0)
                    }.width(100.percent)
                        .padding(left: AppTheme.PAGE_PADDING, right: AppTheme.PAGE_PADDING, top: 6, bottom: 30)
                }.scrollBar(BarState.Off).layoutWeight(1)
            }
        }.width(100.percent).height(100.percent)
            .linearGradient(angle: 180.0, colors: [(AppTheme.COLOR_BG_TOP, 0.0), (AppTheme.COLOR_SURFACE_SOFT, 0.42), (AppTheme.COLOR_BG_BOTTOM, 1.0)])
    }

    @Builder
    func OverviewItem(label: String, value: String): Unit {
        Column(space: 6) {
            Text(value)
                .fontSize(AppTheme.FONT_NUMBER_SMALL)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.COLOR_TEXT_PRIMARY)
            Text(label)
                .fontSize(AppTheme.FONT_HINT)
                .fontColor(AppTheme.COLOR_TEXT_TERTIARY)
        }.layoutWeight(1).height(84).padding(top: 4)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor(AppTheme.COLOR_SURFACE)
            .borderRadius(18.0)
            .borderWidth(1).borderColor(AppTheme.COLOR_BORDER)
            .shadow(radius: 12.0, color: AppTheme.SHADOW_COLOR, offsetX: 0.0, offsetY: 6.0)
    }

    @Builder
    func MonthMetric(label: String, value: String, bgColor: UInt32, textColor: UInt32): Unit {
        Column(space: 6) {
            Text(value)
                .fontSize(AppTheme.FONT_NUMBER_SMALL)
                .fontWeight(FontWeight.Bold)
                .fontColor(textColor)
            Text(label)
                .fontSize(AppTheme.FONT_HINT)
                .fontColor(AppTheme.COLOR_TEXT_TERTIARY)
        }.layoutWeight(1).height(76)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor(bgColor)
            .borderRadius(16.0)
    }

    private func structureWidthPercent(value: Int64): Float64 {
        if (value <= 0) { return 0.0 }
        let total = if (dashboard.summary.totalCount > 0) { dashboard.summary.totalCount } else { 1 }
        let ratio = value * 100 / total
        let percent = if (ratio < 6) { 6 } else { ratio }
        Float64(percent)
    }
}
