package ohos_app_cangjie_entry.services

import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.theme.*
import ohos_app_cangjie_entry.utils.*
import std.collection.*
import std.time.*

public class CountdownBucket {
    public var key: String = "" // "today" | "week" | "month" | "later" | "past"
    public var label: String = ""
    public var value: Int64 = 0
    public var color: UInt32 = 0xFF000000

    public init() {}
}

public class RepeatBucket {
    public var key: String = "" // "none" | "monthly" | "yearly"
    public var label: String = ""
    public var value: Int64 = 0
    public var color: UInt32 = 0xFF000000

    public init() {}
}

public class CalendarBucket {
    public var key: String = "" // "solar" | "lunar"
    public var label: String = ""
    public var value: Int64 = 0
    public var color: UInt32 = 0xFF000000

    public init() {}
}

public class StatisticsSummary {
    public var totalCount: Int64 = 0
    public var next7DaysCount: Int64 = 0
    public var next30DaysCount: Int64 = 0
    public var reminderOnCount: Int64 = 0

    public init() {}
}

public class MonthReminderStats {
    public var monthEventCount: Int64 = 0
    public var reminderCount: Int64 = 0
    public var noReminderCount: Int64 = 0

    public init() {}
}

public class StatisticsDashboard {
    public var summary: StatisticsSummary = StatisticsSummary()
    public var countdownBuckets: ArrayList<CountdownBucket> = ArrayList<CountdownBucket>()
    public var repeatBuckets: ArrayList<RepeatBucket> = ArrayList<RepeatBucket>()
    public var calendarBuckets: ArrayList<CalendarBucket> = ArrayList<CalendarBucket>()
    public var monthlyTrend: Array<Int64> = Array<Int64>(12, repeat: 0)
    public var monthReminder: MonthReminderStats = MonthReminderStats()
    public var insights: ArrayList<String> = ArrayList<String>()

    public init() {}
}

public class StatisticsService {
    public static func emptyDashboard(): StatisticsDashboard {
        let dashboard = StatisticsDashboard()
        dashboard.monthlyTrend = Array<Int64>(12, repeat: 0)
        dashboard
    }

    public static func buildDashboard(eventList: ArrayList<EventItem>): StatisticsDashboard {
        buildDashboard(eventList, DateTime.now())
    }

    public static func buildDashboard(eventList: ArrayList<EventItem>, baseDate: DateTime): StatisticsDashboard {
        let dashboard = StatisticsDashboard()
        dashboard.summary = summary(eventList, baseDate)
        dashboard.monthlyTrend = monthlyTrend(eventList, baseDate)
        dashboard.monthReminder = monthReminderStats(eventList, baseDate)
        dashboard.countdownBuckets = countdownBuckets(eventList, baseDate)
        dashboard.repeatBuckets = repeatBuckets(eventList)
        dashboard.calendarBuckets = calendarBuckets(eventList)
        dashboard.insights = insightTexts(dashboard.summary, dashboard.monthlyTrend, baseDate)
        dashboard
    }

    public static func countdownBuckets(eventList: ArrayList<EventItem>, baseDate: DateTime): ArrayList<CountdownBucket> {
        var overdue: Int64 = 0
        var today: Int64 = 0
        var week: Int64 = 0
        var month: Int64 = 0
        var later: Int64 = 0

        for (item in eventList) {
            let info = EventOccurrenceService.resolveStatusInfo(item, baseDate)
            if (info.status == "past") {
                overdue++
            } else if (info.status == "today") {
                today++
            } else if (info.days <= 7) {
                week++
            } else if (info.days <= 30) {
                month++
            } else {
                later++
            }
        }

        let list = ArrayList<CountdownBucket>()
        list.add(makeCountdownBucket("today", "今天", today, AppTheme.COLOR_DANGER))
        list.add(makeCountdownBucket("week", "1-7天", week, AppTheme.COLOR_WARNING))
        list.add(makeCountdownBucket("month", "8-30天", month, AppTheme.COLOR_SUCCESS))
        list.add(makeCountdownBucket("later", "30天+", later, AppTheme.COLOR_INFO))
        list.add(makeCountdownBucket("past", "已过", overdue, AppTheme.COLOR_ACCENT))
        list
    }

    public static func repeatBuckets(eventList: ArrayList<EventItem>): ArrayList<RepeatBucket> {
        var oneTime: Int64 = 0
        var monthly: Int64 = 0
        var yearly: Int64 = 0

        for (item in eventList) {
            if (item.repeatType == RepeatType.Monthly) {
                monthly++
            } else if (item.repeatType == RepeatType.Yearly) {
                yearly++
            } else {
                oneTime++
            }
        }

        let list = ArrayList<RepeatBucket>()
        list.add(makeRepeatBucket("none", "单次", oneTime, AppTheme.COLOR_TEXT_MUTED))
        list.add(makeRepeatBucket("monthly", "每月", monthly, AppTheme.COLOR_SKY))
        list.add(makeRepeatBucket("yearly", "每年", yearly, AppTheme.COLOR_PRIMARY))
        list
    }

    public static func calendarBuckets(eventList: ArrayList<EventItem>): ArrayList<CalendarBucket> {
        var solar: Int64 = 0
        var lunar: Int64 = 0

        for (item in eventList) {
            let calendarType = item.calendarType ?? (if (item.isLunarDate ?? false) { CalendarType.Lunar } else { CalendarType.Solar })
            if (calendarType == CalendarType.Lunar) {
                lunar++
            } else {
                solar++
            }
        }

        let list = ArrayList<CalendarBucket>()
        list.add(makeCalendarBucket("solar", "公历", solar, AppTheme.COLOR_SUCCESS))
        list.add(makeCalendarBucket("lunar", "农历", lunar, AppTheme.COLOR_ORANGE))
        list
    }

    public static func monthlyTrend(eventList: ArrayList<EventItem>, baseDate: DateTime): Array<Int64> {
        let list = Array<Int64>(12, repeat: 0)
        for (item in eventList) {
            let occurrenceDate = EventOccurrenceService.resolveOccurrenceDate(item, baseDate)
            let index = (occurrenceDate.year - baseDate.year) * 12 +
                (occurrenceDate.month.toInteger() - baseDate.month.toInteger())
            if (index >= 0 && index < 12) {
                list[index] = list[index] + 1
            }
        }
        list
    }

    public static func monthLabel(offset: Int64): String {
        monthLabel(offset, DateTime.now())
    }

    public static func monthLabel(offset: Int64, baseDate: DateTime): String {
        let month = baseDate.month.toInteger() + offset
        "${((month - 1) % 12 + 12) % 12 + 1}月"
    }

    public static func summary(eventList: ArrayList<EventItem>, baseDate: DateTime): StatisticsSummary {
        let s = StatisticsSummary()
        s.totalCount = Int64(eventList.size)

        var next7: Int64 = 0
        var next30: Int64 = 0
        var reminderOn: Int64 = 0

        for (item in eventList) {
            let info = EventOccurrenceService.resolveStatusInfo(item, baseDate)
            if (info.status == "today" || (info.status == "future" && info.days <= 7)) {
                next7++
            }
            if (info.status == "today" || (info.status == "future" && info.days <= 30)) {
                next30++
            }
            if (item.reminderType != None && item.reminderType != ReminderType.Off) {
                reminderOn++
            }
        }

        s.next7DaysCount = next7
        s.next30DaysCount = next30
        s.reminderOnCount = reminderOn
        s
    }

    public static func monthReminderStats(eventList: ArrayList<EventItem>, baseDate: DateTime): MonthReminderStats {
        let stats = MonthReminderStats()
        var monthEventCount: Int64 = 0
        var reminderCount: Int64 = 0

        for (item in eventList) {
            if (isOccurrenceInMonth(item, baseDate)) {
                monthEventCount++
                if (isReminderEnabled(item)) {
                    reminderCount++
                }
            }
        }

        stats.monthEventCount = monthEventCount
        stats.reminderCount = reminderCount
        stats.noReminderCount = if (monthEventCount - reminderCount > 0) { monthEventCount - reminderCount } else { 0 }
        stats
    }

    public static func insightTexts(summary: StatisticsSummary, monthlyTrend: Array<Int64>, baseDate: DateTime): ArrayList<String> {
        let texts = ArrayList<String>()

        if (summary.totalCount <= 0) {
            return texts
        }

        let noReminderCount = summary.totalCount - summary.reminderOnCount
        if (noReminderCount > 0) {
            texts.add("还有 ${noReminderCount} 个记录没有提醒，可按重要程度补充。")
        } else {
            texts.add("所有记录都已设置提醒，提醒覆盖比较完整。")
        }

        var maxCount: Int64 = 0
        var maxIndex: Int64 = 0
        for (i in 0..monthlyTrend.size) {
            if (monthlyTrend[i] > maxCount) {
                maxCount = monthlyTrend[i]
                maxIndex = Int64(i)
            }
        }
        if (maxCount > 0) {
            texts.add("未来一年里，${monthLabel(maxIndex, baseDate)}是高峰月份，共 ${maxCount} 个重要日子。")
        }

        var activeMonthCount: Int64 = 0
        for (i in 0..monthlyTrend.size) {
            if (monthlyTrend[i] > 0) {
                activeMonthCount++
            }
        }
        if (activeMonthCount > 0 && activeMonthCount <= 3) {
            texts.add("未来一年的记录集中在 ${activeMonthCount} 个月，适合提前关注高峰月份。")
        } else if (activeMonthCount > 3) {
            texts.add("未来一年的记录分布在 ${activeMonthCount} 个月，整体节奏比较分散。")
        }

        texts
    }

    private static func isOccurrenceInMonth(item: EventItem, baseDate: DateTime): Bool {
        let occurrenceDate = EventOccurrenceService.resolveOccurrenceDate(item, baseDate)
        occurrenceDate.year == baseDate.year && occurrenceDate.month == baseDate.month
    }

    private static func isReminderEnabled(item: EventItem): Bool {
        item.reminderType != None && item.reminderType != ReminderType.Off
    }

    private static func makeCountdownBucket(key: String, label: String, value: Int64, color: UInt32): CountdownBucket {
        let b = CountdownBucket()
        b.key = key; b.label = label; b.value = value; b.color = color
        b
    }

    private static func makeRepeatBucket(key: String, label: String, value: Int64, color: UInt32): RepeatBucket {
        let b = RepeatBucket()
        b.key = key; b.label = label; b.value = value; b.color = color
        b
    }

    private static func makeCalendarBucket(key: String, label: String, value: Int64, color: UInt32): CalendarBucket {
        let b = CalendarBucket()
        b.key = key; b.label = label; b.value = value; b.color = color
        b
    }
}
