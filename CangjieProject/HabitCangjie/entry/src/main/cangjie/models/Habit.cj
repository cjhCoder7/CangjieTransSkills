package ohos_app_cangjie_entry.models

import std.collection.ArrayList
import std.collection.HashSet
import std.math.log
import std.math.pow

/// 习惯数据模型
public class Habit {
    public var id: String
    public var title: String
    public var motivation: String
    public var color: HabitColor
    public var creationDate: Int64  // 时间戳毫秒
    public var completedDates: ArrayList<Int64>  // 已完成日期的时间戳列表

    public init(
        id: String,
        title: String,
        motivation: String,
        color: HabitColor,
        creationDate: Int64,
        completedDates: ArrayList<Int64>
    ) {
        this.id = id
        this.title = title
        this.motivation = motivation
        this.color = color
        this.creationDate = creationDate
        this.completedDates = completedDates
    }

    public init(title: String, motivation: String, color: HabitColor) {
        this.id = DateHelper.generateUUID()
        this.title = title
        this.motivation = motivation
        this.color = color
        this.creationDate = DateHelper.nowTimestamp()
        this.completedDates = ArrayList<Int64>()
    }

    /// 强度计算周期（天）
    public prop strengthCalculationPeriod: Int64 {
        get() { 60 }
    }

    /// 强度百分比 0-100
    public prop strengthPercentage: Int64 {
        get() { calcStrengthPercentage(completedDates) }
    }

    /// 当前连续天数
    public prop streak: Int64 {
        get() {
            let dates = processDatesForStreakCalculation(completedDates)
            if (dates.isEmpty()) {
                return 0
            }
            if (!DateHelper.isInSameDay(dates[0], DateHelper.nowTimestamp())) {
                return 0
            }
            var previousDate = dates[0]
            var streakCount: Int64 = 1
            for (i in 1..dates.size) {
                let daysBetween = DateHelper.daysBetween(previousDate, dates[i])
                if (daysBetween <= 1) {
                    streakCount += 1
                } else {
                    return streakCount
                }
                previousDate = dates[i]
            }
            return streakCount
        }
    }

    /// 最长连续天数
    public prop longestStreak: Int64 {
        get() {
            let dates = processDatesForStreakCalculation(completedDates)
            if (dates.isEmpty()) {
                return 0
            }
            var previousDate = dates[0]
            var currentStreak: Int64 = 1
            var longest: Int64 = 0
            for (i in 1..dates.size) {
                let daysBetween = DateHelper.daysBetween(previousDate, dates[i])
                if (daysBetween <= 1) {
                    currentStreak += 1
                } else {
                    if (currentStreak > longest) {
                        longest = currentStreak
                    }
                    currentStreak = 1
                }
                previousDate = dates[i]
            }
            return if (currentStreak > longest) { currentStreak } else { longest }
        }
    }

    /// 判断某天是否已完成（按时间戳）
    public func isCompletedByTimestamp(timestamp: Int64): Bool {
        for (d in completedDates) {
            if (DateHelper.isInSameDay(d, timestamp)) {
                return true
            }
        }
        return false
    }

    /// 判断几天前是否已完成
    public func isCompletedDaysAgo(daysAgo: Int64): Bool {
        isCompletedByTimestamp(DateHelper.todayMinusDaysAgo(daysAgo))
    }

    /// 添加完成日期
    public func addCompletedDate(timestamp: Int64): Unit {
        if (!isCompletedByTimestamp(timestamp)) {
            completedDates.add(timestamp)
        }
    }

    /// 移除完成日期
    public func removeCompletedDate(timestamp: Int64): Unit {
        var i: Int64 = 0
        while (i < completedDates.size) {
            if (DateHelper.isInSameDay(completedDates[i], timestamp)) {
                completedDates.remove(at: i)
                return
            }
            i += 1
        }
    }

    /// 切换完成状态
    public func toggleCompletion(daysAgo: Int64): Unit {
        let targetDate = DateHelper.todayMinusDaysAgo(daysAgo)
        if (isCompletedDaysAgo(daysAgo)) {
            removeCompletedDate(targetDate)
        } else {
            addCompletedDate(targetDate)
        }
    }

    /// 处理日期列表用于连续天数计算
    func processDatesForStreakCalculation(dates: ArrayList<Int64>): ArrayList<Int64> {
        let now = DateHelper.nowTimestamp()
        var result = ArrayList<Int64>()
        var seen = HashSet<Int64>()
        for (d in dates) {
            let dayStart = DateHelper.startOfDay(d)
            if (dayStart > now) {
                continue
            }
            if (!seen.contains(dayStart)) {
                seen.add(dayStart)
                result.add(d)
            }
        }
        result.sortBy(comparator: { a: Int64, b: Int64 => if (b < a) { Ordering.LT } else if (b > a) { Ordering.GT } else { Ordering.EQ } })
        return result
    }

    /// 计算强度百分比
    public func calcStrengthPercentage(dates: ArrayList<Int64>): Int64 {
        var uniqueCount: Int64 = 0
        var seen = HashSet<Int64>()
        let periodStart = DateHelper.todayMinusDaysAgo(strengthCalculationPeriod)
        for (d in dates) {
            if (d >= periodStart) {
                let dayStart = DateHelper.startOfDay(d)
                if (!seen.contains(dayStart)) {
                    seen.add(dayStart)
                    uniqueCount += 1
                }
            }
        }
        let logNumber = Float64(uniqueCount + 1)
        let logBase = calculateLogarithmBase(Float64(strengthCalculationPeriod), 100.0)
        let calculatedPercentage = Int64(log(logNumber) / log(logBase))
        return if (calculatedPercentage > 100) { 100 } else { calculatedPercentage }
    }

    func calculateLogarithmBase(value: Float64, result: Float64): Float64 {
        pow(value, 1.0 / result)
    }

    /// 计算最近 N 天获得的强度
    public func strengthGainedWithinLastDays(daysAgo: Int64): Int64 {
        let habitStrength = calcStrengthPercentage(completedDates)
        var filteredDates = ArrayList<Int64>()
        let cutoffDate = DateHelper.todayMinusDaysAgo(daysAgo)
        for (d in completedDates) {
            let dayStart = DateHelper.startOfDay(d)
            let cutoffDayStart = DateHelper.startOfDay(cutoffDate)
            if (dayStart < cutoffDayStart) {
                filteredDates.add(d)
            }
        }
        let habitStrengthWithout = calcStrengthPercentage(filteredDates)
        return habitStrength - habitStrengthWithout
    }

    /// 最近 N 天的完成次数
    public func completionsWithinLastDays(daysAgo: Int64): Int64 {
        let cutoffDate = DateHelper.todayMinusDaysAgo(daysAgo)
        var count: Int64 = 0
        for (d in completedDates) {
            if (d >= cutoffDate) {
                count += 1
            }
        }
        return count
    }
}
