package ohos_app_cangjie_entry.models

import std.collection.ArrayList
import std.collection.HashSet
import std.random.Random
import std.time.DateTime

/// 日期工具类 — 替代 Swift Date 扩展
public class DateHelper {
    /// 当前时间戳（毫秒）
    public static func nowTimestamp(): Int64 {
        DateTime.nowUTC().toUnixTimeStamp().toMilliseconds()
    }

    /// 生成 UUID 字符串
    public static func generateUUID(): String {
        let chars = "0123456789abcdef"
        var sb = StringBuilder()
        let rng = Random()
        for (_ in 0..32) {
            let idx = rng.nextUInt64() % 16
            sb.append(chars[Int64(idx)])
        }
        sb.toString()
    }

    /// 获取某天起始时间戳
    public static func startOfDay(timestamp: Int64): Int64 {
        let msPerDay: Int64 = 86400000
        (timestamp / msPerDay) * msPerDay
    }

    /// 判断两个时间戳是否同一天
    public static func isInSameDay(ts1: Int64, ts2: Int64): Bool {
        startOfDay(ts1) == startOfDay(ts2)
    }

    /// 获取 N 天前的时间戳
    public static func todayMinusDaysAgo(daysAgo: Int64): Int64 {
        let msPerDay: Int64 = 86400000
        let now = nowTimestamp()
        let todayStart = startOfDay(now)
        todayStart - daysAgo * msPerDay
    }

    /// 计算两个时间戳之间的天数差
    public static func daysBetween(timestamp1: Int64, timestamp2: Int64): Int64 {
        let msPerDay: Int64 = 86400000
        let d1 = startOfDay(timestamp1) / msPerDay
        let d2 = startOfDay(timestamp2) / msPerDay
        if (d1 >= d2) { d1 - d2 } else { d2 - d1 }
    }

    /// 获取星期几（0=周日, 1=周一, ..., 6=周六）
    public static func dayOfWeek(timestamp: Int64): Int64 {
        let msPerDay: Int64 = 86400000
        let daysSinceEpoch = startOfDay(timestamp) / msPerDay
        (daysSinceEpoch + 4) % 7
    }

    /// 获取月中的日期（1-31）
    /// 使用 Civil Date Algorithm 纯数学计算
    public static func dayOfMonth(timestamp: Int64): Int64 {
        let msPerDay: Int64 = 86400000
        let jdn = startOfDay(timestamp) / msPerDay + 2440588
        let f = jdn + 1401 + (((4 * jdn + 274277) / 146097) * 3) / 4 - 38
        let e = 4 * f + 3
        let g = (e % 1461) / 4
        let h = 5 * g + 2
        let day = (h % 153) / 5 + 1
        day
    }

    /// 获取月份（1-12）
    public static func month(timestamp: Int64): Int64 {
        let msPerDay: Int64 = 86400000
        let jdn = startOfDay(timestamp) / msPerDay + 2440588
        let f = jdn + 1401 + (((4 * jdn + 274277) / 146097) * 3) / 4 - 38
        let e = 4 * f + 3
        let g = (e % 1461) / 4
        let h = 5 * g + 2
        let month = (h / 153) + 3
        if (month > 12) { month - 12 } else { month }
    }

    /// 获取年份
    public static func year(timestamp: Int64): Int64 {
        let msPerDay: Int64 = 86400000
        let jdn = startOfDay(timestamp) / msPerDay + 2440588
        let f = jdn + 1401 + (((4 * jdn + 274277) / 146097) * 3) / 4 - 38
        let e = 4 * f + 3
        let g = (e % 1461) / 4
        let h = 5 * g + 2
        let month = (h / 153) + 3
        let year = (e / 1461) - 4716 + (month + 9) / 12
        year
    }

    /// 获取星期缩写名称
    public static func weekdayShortName(dayOfWeek: Int64): String {
        let names = ["日", "一", "二", "三", "四", "五", "六"]
        if (dayOfWeek >= 0 && dayOfWeek < 7) {
            names[Int64(dayOfWeek)]
        } else {
            ""
        }
    }

    /// 生成随机日期列表（预览用）
    public static func getRandomDates(maxDaysBack: Int64, chance: Int64): ArrayList<Int64> {
        var dates = ArrayList<Int64>()
        let rng = Random()
        for (i in 0..maxDaysBack) {
            let roll = rng.nextUInt64() % 100
            if (Int64(roll) < chance) {
                dates.add(todayMinusDaysAgo(i))
            }
        }
        dates
    }
}
