package ohos_app_cangjie_entry.helpers

import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.services.*
import std.collection.*

public class EventListViewHelper {
    public static func filterEvents(eventList: ArrayList<EventItem>, keyword: String): ArrayList<EventItem> {
        let trimmedKeyword = keyword.trimAscii()
        if (trimmedKeyword.size == 0) {
            let result = ArrayList<EventItem>()
            for (item in eventList) { result.add(item) }
            return result
        }

        let lowerKeyword = trimmedKeyword.toAsciiLower()
        let result = ArrayList<EventItem>()
        for (item in eventList) {
            if (item.title.toAsciiLower().contains(lowerKeyword)) {
                result.add(item)
            } else if (let Some(note) <- item.note) {
                if (note.toAsciiLower().contains(lowerKeyword)) {
                    result.add(item)
                }
            }
        }
        result
    }

    public static func formatEventDate(item: EventItem): String {
        EventOccurrenceService.formatEventDateText(item)
    }

    public static func primaryDateText(item: EventItem): String {
        EventOccurrenceService.formatPrimaryDateText(item)
    }

    public static func secondaryDateText(item: EventItem): String {
        EventOccurrenceService.formatSecondaryDateText(item)
    }

    public static func isLunarEvent(item: EventItem): Bool {
        EventOccurrenceService.isLunarEvent(item)
    }

    public static func repeatLabel(item: EventItem): String {
        match (item.repeatType) {
            case Some(RepeatType.Yearly) => "每年重复"
            case Some(RepeatType.Monthly) => "每月重复"
            case _ => "单次事件"
        }
    }

    public static func reminderLabel(item: EventItem): String {
        match (item.reminderType) {
            case Some(ReminderType.OneDayBefore) => "提前一天"
            case Some(ReminderType.OnDay) => "当天提醒"
            case _ => "不提醒"
        }
    }

    public static func eventThemeColor(item: EventItem, defaultThemeColor: UInt32): UInt32 {
        item.themeColor ?? defaultThemeColor
    }

    public static func isToday(item: EventItem): Bool {
        EventOccurrenceService.resolveStatusInfo(item).status == "today"
    }

    public static func isPast(item: EventItem): Bool {
        EventOccurrenceService.resolveStatusInfo(item).status == "past"
    }

    public static func statusPrefix(item: EventItem): String {
        if (EventOccurrenceService.resolveStatusInfo(item).status == "future") { "还有" } else { "已过" }
    }

    public static func statusNumber(item: EventItem): String {
        "${EventOccurrenceService.resolveStatusInfo(item).days}"
    }

    public static func statusUnit(item: EventItem): String {
        if (EventOccurrenceService.resolveStatusInfo(item).status == "today") { "" } else { "天" }
    }
}
