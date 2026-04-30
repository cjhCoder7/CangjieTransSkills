package ohos_app_cangjie_entry.services

import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.utils.*
import std.time.*
import std.convert.*

public class EventOccurrenceService {
    private static let DAY_MS: Int64 = 24 * 60 * 60 * 1000

    public static func resolveOccurrenceDate(item: EventItem): DateTime {
        resolveOccurrenceDate(item, DateTime.now())
    }

    public static func resolveOccurrenceDate(item: EventItem, fromDate: DateTime): DateTime {
        let baseDate = LunarDateService.startOfDay(fromDate.toUnixTimeStamp().toMilliseconds())
        let calendarType = item.calendarType ?? (if (item.isLunarDate ?? false) { CalendarType.Lunar } else { CalendarType.Solar })
        if (calendarType == CalendarType.Lunar) {
            return resolveLunarOccurrence(item, baseDate)
        }
        return resolveSolarOccurrence(item, baseDate)
    }

    public static func resolveStatusInfo(item: EventItem): EventStatusInfo {
        resolveStatusInfo(item, DateTime.now())
    }

    public static func resolveStatusInfo(item: EventItem, fromDate: DateTime): EventStatusInfo {
        let occurrenceDate = resolveOccurrenceDate(item, fromDate)
        DateUtils.calculateStatus(occurrenceDate.toUnixTimeStamp().toMilliseconds(), fromDate)
    }

    public static func formatEventDateText(item: EventItem): String {
        let calendarType = item.calendarType ?? (if (item.isLunarDate ?? false) { CalendarType.Lunar } else { CalendarType.Solar })
        if (calendarType == CalendarType.Lunar) {
            let info = getLunarAnchor(item)
            return LunarDateService.buildDisplayText(info)
        }
        DateUtils.formatSolarDate(item.targetDate)
    }

    public static func formatPrimaryDateText(item: EventItem): String {
        let calendarType = item.calendarType ?? (if (item.isLunarDate ?? false) { CalendarType.Lunar } else { CalendarType.Solar })
        if (calendarType == CalendarType.Lunar) {
            let lunarText = LunarDateService.formatLunarDate(item.targetDate)
            if (lunarText.startsWith("农历")) {
                return lunarText[6..lunarText.size]
            }
            return lunarText
        }
        DateUtils.formatSolarDate(item.targetDate)
    }

    public static func formatSecondaryDateText(item: EventItem): String {
        let calendarType = item.calendarType ?? (if (item.isLunarDate ?? false) { CalendarType.Lunar } else { CalendarType.Solar })
        if (calendarType == CalendarType.Lunar) {
            return DateUtils.formatSolarDate(item.targetDate)
        }
        ""
    }

    public static func isLunarEvent(item: EventItem): Bool {
        (item.calendarType ?? (if (item.isLunarDate ?? false) { CalendarType.Lunar } else { CalendarType.Solar })) == CalendarType.Lunar
    }

    public static func getReminderDate(item: EventItem): DateTime {
        getReminderDate(item, DateTime.now())
    }

    public static func getReminderDate(item: EventItem, fromDate: DateTime): DateTime {
        let occurrenceDate = resolveOccurrenceDate(item, fromDate)
        // 仓颉 DateTime 是不可变的，这里返回原始日期
        // 提醒时间的小时/分钟设置需要在调用方处理
        occurrenceDate
    }

    private static func resolveSolarOccurrence(item: EventItem, baseDate: DateTime): DateTime {
        if (item.repeatType != RepeatType.Monthly && item.repeatType != RepeatType.Yearly) {
            return LunarDateService.startOfDay(item.targetDate)
        }

        let referenceDate = DateTime.fromUnixTimeStamp(Duration.millisecond * item.targetDate)
        let solarMonth = item.solarMonth ?? referenceDate.month.toInteger()
        let solarDay = item.solarDay ?? referenceDate.dayOfMonth

        if (item.repeatType == RepeatType.Yearly) {
            var year = baseDate.year
            var candidate = buildClampedSolarDate(year, solarMonth, solarDay)
            if (candidate.toUnixTimeStamp().toMilliseconds() < baseDate.toUnixTimeStamp().toMilliseconds()) {
                candidate = buildClampedSolarDate(year + 1, solarMonth, solarDay)
            }
            return candidate
        }

        // monthly
        var year = baseDate.year
        var month = baseDate.month.toInteger()
        var candidate = buildClampedSolarDate(year, month, solarDay)
        if (candidate.toUnixTimeStamp().toMilliseconds() < baseDate.toUnixTimeStamp().toMilliseconds()) {
            // 下个月
            let nextMonth = month + 1
            if (nextMonth > 12) {
                year = year + 1
                candidate = buildClampedSolarDate(year, 1, solarDay)
            } else {
                candidate = buildClampedSolarDate(year, nextMonth, solarDay)
            }
        }
        candidate
    }

    private static func resolveLunarOccurrence(item: EventItem, baseDate: DateTime): DateTime {
        if (item.repeatType == None || item.repeatType == Some(RepeatType.Once)) {
            return LunarDateService.startOfDay(item.targetDate)
        }
        // 简化实现：返回目标日期
        LunarDateService.startOfDay(item.targetDate)
    }

    private static func getLunarAnchor(item: EventItem): LunarDateInfo {
        let source = LunarDateService.getLunarDateInfo(item.targetDate)
        let info = LunarDateInfo()
        info.lunarYear = source.lunarYear
        info.lunarMonth = item.lunarMonth ?? source.lunarMonth
        info.lunarDay = item.lunarDay ?? source.lunarDay
        info.isLeapMonth = item.isLeapMonth ?? source.isLeapMonth
        info.monthLabel = source.monthLabel
        info.dayLabel = source.dayLabel
        info
    }

    private static func buildClampedSolarDate(year: Int64, month: Int64, day: Int64): DateTime {
        let lastDay = daysInMonth(year, month)
        let clampedDay = if (day > lastDay) { lastDay } else { day }
        DateTime.of(year: year, month: Month.of(month), dayOfMonth: clampedDay)
    }

    private static func daysInMonth(year: Int64, month: Int64): Int64 {
        let daysPerMonth: Array<Int64> = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        var days = daysPerMonth[month - 1]
        if (month == 2 && isLeapYear(year)) {
            days = 29
        }
        days
    }

    private static func isLeapYear(year: Int64): Bool {
        (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
    }
}
