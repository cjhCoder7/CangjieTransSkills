package ohos_app_cangjie_entry.utils

import std.time.*
import std.convert.*

public class EventStatusInfo {
    public var status: String = "" // "future" | "today" | "past"
    public var days: Int64 = 0
    public var text: String = ""
    public var color: UInt32 = 0xFF000000

    public init() {}
}

public class DateUtils {
    private static let CHINESE_DIGITS: Array<String> = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"]

    public static func formatSolarDate(targetTimestamp: Int64): String {
        let dateTime = DateTime.fromUnixTimeStamp(Duration.millisecond * targetTimestamp)
        let year = dateTime.year
        let month = padZero(dateTime.month.toInteger())
        let day = padZero(dateTime.dayOfMonth)
        "${year}.${month}.${day}"
    }

    public static func calculateStatus(targetTimestamp: Int64): EventStatusInfo {
        calculateStatus(targetTimestamp, DateTime.now())
    }

    public static func calculateStatus(targetTimestamp: Int64, baseDate: DateTime): EventStatusInfo {
        let baseDay = toLocalDayNumber(baseDate)
        let targetDay = toLocalDayNumber(DateTime.fromUnixTimeStamp(Duration.millisecond * targetTimestamp))
        let diffDays = targetDay - baseDay

        if (diffDays == 0) {
            let info = EventStatusInfo()
            info.status = "today"
            info.days = 0
            info.text = "今天"
            info.color = 0xFFFF5252
            return info
        }

        if (diffDays > 0) {
            let info = EventStatusInfo()
            info.status = "future"
            info.days = diffDays
            info.text = "还有 ${diffDays} 天"
            info.color = 0xFF007DFF
            return info
        }

        let pastDays = -diffDays
        let info = EventStatusInfo()
        info.status = "past"
        info.days = pastDays
        info.text = "已过 ${pastDays} 天"
        info.color = 0xFF9C27B0
        return info
    }

    public static func formatChineseYear(year: Int64): String {
        var result = ""
        let digits = year.toString()
        for (i in 0..digits.size) {
            let ch = digits[i]
            let value = Int64.parse(ch.toString())
            result = result + CHINESE_DIGITS[value]
        }
        result
    }

    private static func dayMs(): Int64 {
        1000 * 60 * 60 * 24
    }

    private static func toLocalDayNumber(date: DateTime): Int64 {
        let timestamp = date.toUnixTimeStamp().toMilliseconds()
        timestamp / dayMs()
    }

    private static func padZero(n: Int64): String {
        if (n < 10) { "0${n}" } else { "${n}" }
    }
}
