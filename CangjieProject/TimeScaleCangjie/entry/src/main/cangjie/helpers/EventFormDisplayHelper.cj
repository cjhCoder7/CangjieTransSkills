package ohos_app_cangjie_entry.helpers

import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.services.*
import ohos_app_cangjie_entry.utils.*
import std.time.*

public class EventFormDisplayHelper {
    public static func buildEventDateDisplayText(selectedDate: DateTime, isLunarDate: Bool): String {
        if (isLunarDate) {
            return LunarDateService.formatLunarDate(selectedDate.toUnixTimeStamp().toMilliseconds())
        }
        DateUtils.formatSolarDate(selectedDate.toUnixTimeStamp().toMilliseconds())
    }

    public static func buildRepeatDisplayText(repeatType: RepeatType): String {
        match (repeatType) {
            case RepeatType.Yearly => "每年重复"
            case RepeatType.Monthly => "每月重复"
            case _ => "不重复"
        }
    }

    public static func buildReminderDisplayText(reminderType: ReminderType, reminderHour: Int64, reminderMinute: Int64): String {
        if (reminderType == ReminderType.Off) {
            return "不提醒"
        }
        let modeText = if (reminderType == ReminderType.OnDay) { "当天" } else { "提前一天" }
        let hourStr = if (reminderHour < 10) { "0${reminderHour}" } else { "${reminderHour}" }
        let minuteStr = if (reminderMinute < 10) { "0${reminderMinute}" } else { "${reminderMinute}" }
        "${modeText} ${hourStr}:${minuteStr}"
    }
}
