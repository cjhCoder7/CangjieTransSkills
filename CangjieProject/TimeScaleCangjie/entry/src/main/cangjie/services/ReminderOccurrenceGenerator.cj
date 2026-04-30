package ohos_app_cangjie_entry.services

import ohos_app_cangjie_entry.model.*
import std.time.*
import std.collection.*

public class ReminderOccurrence {
    public var occurrenceDate: DateTime = DateTime.now()
    public var reminderDate: DateTime = DateTime.now()

    public init() {}
}

public class ReminderOccurrenceGenerator {
    public static let MONTHLY_WINDOW_COUNT: Int64 = 12
    public static let YEARLY_WINDOW_COUNT: Int64 = 3

    public static func generateFutureOccurrences(event: EventItem): ArrayList<ReminderOccurrence> {
        generateFutureOccurrences(event, DateTime.now())
    }

    public static func generateFutureOccurrences(event: EventItem, fromDate: DateTime): ArrayList<ReminderOccurrence> {
        if (event.reminderType == ReminderType.Off || event.reminderHour == None || event.reminderMinute == None) {
            return ArrayList<ReminderOccurrence>()
        }

        if (event.repeatType == RepeatType.Monthly) {
            return generateRepeatedOccurrences(event, MONTHLY_WINDOW_COUNT, fromDate)
        }

        if (event.repeatType == RepeatType.Yearly) {
            return generateRepeatedOccurrences(event, YEARLY_WINDOW_COUNT, fromDate)
        }

        let occurrenceDate = EventOccurrenceService.resolveOccurrenceDate(event, fromDate)
        let reminderDate = EventOccurrenceService.getReminderDate(event, fromDate)
        if (reminderDate.toUnixTimeStamp().toMilliseconds() <= fromDate.toUnixTimeStamp().toMilliseconds()) {
            return ArrayList<ReminderOccurrence>()
        }

        let list = ArrayList<ReminderOccurrence>()
        let occurrence = ReminderOccurrence()
        occurrence.occurrenceDate = occurrenceDate
        occurrence.reminderDate = reminderDate
        list.add(occurrence)
        list
    }

    private static func generateRepeatedOccurrences(event: EventItem, count: Int64, fromDate: DateTime): ArrayList<ReminderOccurrence> {
        let occurrences = ArrayList<ReminderOccurrence>()
        let seenReminderTimes = HashSet<Int64>()
        var cursor = LunarDateService.startOfDay(fromDate.toUnixTimeStamp().toMilliseconds())
        let referenceTime = fromDate.toUnixTimeStamp().toMilliseconds()
        var guard: Int64 = 0

        while (Int64(occurrences.size) < count && guard < count * 450) {
            let occurrenceDate = EventOccurrenceService.resolveOccurrenceDate(event, cursor)
            let reminderDate = EventOccurrenceService.getReminderDate(event, cursor)
            let reminderTime = reminderDate.toUnixTimeStamp().toMilliseconds()

            if (reminderTime > referenceTime && !seenReminderTimes.contains(reminderTime)) {
                seenReminderTimes.add(reminderTime)
                let occurrence = ReminderOccurrence()
                occurrence.occurrenceDate = occurrenceDate
                occurrence.reminderDate = reminderDate
                occurrences.add(occurrence)
            }

            // 下一天
            cursor = LunarDateService.startOfDay(cursor.toUnixTimeStamp().toMilliseconds() + 24 * 60 * 60 * 1000)
            guard++
        }

        occurrences
    }
}
