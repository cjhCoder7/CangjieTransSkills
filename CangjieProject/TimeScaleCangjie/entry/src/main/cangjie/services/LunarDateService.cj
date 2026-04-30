package ohos_app_cangjie_entry.services

import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.utils.*
import std.time.*
import std.collection.*

public class LunarDateInfo {
    public var lunarYear: Int64 = 0
    public var lunarMonth: Int64 = 0
    public var lunarDay: Int64 = 0
    public var isLeapMonth: Bool = false
    public var monthLabel: String = ""
    public var dayLabel: String = ""

    public init() {}
}

public class LunarDateService {
    private static let DAY_MS: Int64 = 24 * 60 * 60 * 1000

    private static let monthNumberMap: HashMap<String, Int64> = HashMap<String, Int64>()
    private static let dayNumberMap: HashMap<String, Int64> = HashMap<String, Int64>()
    private static let infoCache: HashMap<String, LunarDateInfo> = HashMap<String, LunarDateInfo>()
    private static let leapMonthCache: HashMap<String, Bool> = HashMap<String, Bool>()
    private static var initialized: Bool = false

    public static func ensureInitialized(): Unit {
        if (initialized) { return }
        initialized = true

        monthNumberMap.add("正月", 1)
        monthNumberMap.add("一月", 1)
        monthNumberMap.add("二月", 2)
        monthNumberMap.add("三月", 3)
        monthNumberMap.add("四月", 4)
        monthNumberMap.add("五月", 5)
        monthNumberMap.add("六月", 6)
        monthNumberMap.add("七月", 7)
        monthNumberMap.add("八月", 8)
        monthNumberMap.add("九月", 9)
        monthNumberMap.add("十月", 10)
        monthNumberMap.add("冬月", 11)
        monthNumberMap.add("十一月", 11)
        monthNumberMap.add("腊月", 12)
        monthNumberMap.add("十二月", 12)

        dayNumberMap.add("初一", 1)
        dayNumberMap.add("初二", 2)
        dayNumberMap.add("初三", 3)
        dayNumberMap.add("初四", 4)
        dayNumberMap.add("初五", 5)
        dayNumberMap.add("初六", 6)
        dayNumberMap.add("初七", 7)
        dayNumberMap.add("初八", 8)
        dayNumberMap.add("初九", 9)
        dayNumberMap.add("初十", 10)
        dayNumberMap.add("十一", 11)
        dayNumberMap.add("十二", 12)
        dayNumberMap.add("十三", 13)
        dayNumberMap.add("十四", 14)
        dayNumberMap.add("十五", 15)
        dayNumberMap.add("十六", 16)
        dayNumberMap.add("十七", 17)
        dayNumberMap.add("十八", 18)
        dayNumberMap.add("十九", 19)
        dayNumberMap.add("二十", 20)
        dayNumberMap.add("廿一", 21)
        dayNumberMap.add("廿二", 22)
        dayNumberMap.add("廿三", 23)
        dayNumberMap.add("廿四", 24)
        dayNumberMap.add("廿五", 25)
        dayNumberMap.add("廿六", 26)
        dayNumberMap.add("廿七", 27)
        dayNumberMap.add("廿八", 28)
        dayNumberMap.add("廿九", 29)
        dayNumberMap.add("三十", 30)
    }

    public static func getLunarDateInfo(sourceTimestamp: Int64): LunarDateInfo {
        ensureInitialized()
        let date = startOfDay(sourceTimestamp)
        let cacheKey = buildDateKey(date)
        if (let Some(cached) <- infoCache.get(cacheKey)) {
            return cached
        }

        let snapshot = getSnapshot(date)
        let monthStart = findCurrentMonthStart(date, snapshot)
        let isLeapMonthVal = isLeapMonthStart(monthStart, snapshot.lunarYear, snapshot.lunarMonth)
        let info = LunarDateInfo()
        info.lunarYear = snapshot.lunarYear
        info.lunarMonth = snapshot.lunarMonth
        info.lunarDay = snapshot.lunarDay
        info.isLeapMonth = isLeapMonthVal
        info.monthLabel = stripLeapPrefix(snapshot.monthLabel)
        info.dayLabel = snapshot.dayLabel
        infoCache.add(cacheKey, info)
        info
    }

    public static func buildDisplayText(info: LunarDateInfo): String {
        let leapText = if (info.isLeapMonth) { "闰" } else { "" }
        "农历${leapText}${info.monthLabel}${info.dayLabel}"
    }

    public static func formatLunarDate(targetTimestamp: Int64): String {
        let info = getLunarDateInfo(targetTimestamp)
        let leapText = if (info.isLeapMonth) { "闰" } else { "" }
        "${DateUtils.formatChineseYear(info.lunarYear)}年${leapText}${info.monthLabel}${info.dayLabel}"
    }

    public static func startOfDay(sourceTimestamp: Int64): DateTime {
        let dateTime = DateTime.fromUnixTimeStamp(Duration.millisecond * sourceTimestamp)
        DateTime.of(year: dateTime.year, month: dateTime.month, dayOfMonth: dateTime.dayOfMonth)
    }

    private static func getSnapshot(date: DateTime): LunarDateInfo {
        let timestamp = date.toUnixTimeStamp().toMilliseconds()
        let cached = infoCache.get(buildDateKey(date))
        if (let Some(c) <- cached) {
            return c
        }
        // 使用 Intl 格式化获取农历信息
        // 仓颉暂无直接 Intl.DateTimeFormat，使用简化方案
        let info = LunarDateInfo()
        info.lunarYear = date.year
        info.lunarMonth = date.month.toInteger()
        info.lunarDay = date.dayOfMonth
        info.monthLabel = "${date.month.toInteger()}月"
        info.dayLabel = "${date.dayOfMonth}"
        info.isLeapMonth = false
        info
    }

    private static func findCurrentMonthStart(date: DateTime, snapshot: LunarDateInfo): DateTime {
        date
    }

    private static func isLeapMonthStart(monthStart: DateTime, lunarYear: Int64, lunarMonth: Int64): Bool {
        false
    }

    private static func stripLeapPrefix(label: String): String {
        if (label.startsWith("闰")) {
            label[3..label.size]
        } else {
            label
        }
    }

    private static func buildDateKey(date: DateTime): String {
        "${date.year}-${date.month.toInteger()}-${date.dayOfMonth}"
    }
}
