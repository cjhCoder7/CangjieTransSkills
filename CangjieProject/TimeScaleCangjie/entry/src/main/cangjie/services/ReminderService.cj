package ohos_app_cangjie_entry.services

import ohos_app_cangjie_entry.model.*
import std.time.*

public class ReminderSyncResult {
    public var scheduled: Bool = false
    public var calendarScheduled: ?Bool = None
    public var agentScheduled: ?Bool = None
    public var calendarEventId: ?Int64 = None
    public var agentReminderId: ?Int64 = None
    public var reason: ?String = None
    public var errorCode: ?Int64 = None
    public var errorMessage: ?String = None

    public init() {}
}

public class ReminderService {
    private static let ACCOUNT_NAME: String = "timescale_calendar"
    private static let ACCOUNT_DISPLAY_NAME: String = "时光刻度"

    public static func syncReminder(context: Object, event: EventItem): ReminderSyncResult {
        let result = ReminderSyncResult()

        if (event.reminderType == ReminderType.Off || event.reminderHour == None || event.reminderMinute == None) {
            result.scheduled = false
            result.reason = "disabled"
            return result
        }

        // 简化实现：后续接入 CalendarKit 和 reminderAgentManager
        result.scheduled = false
        result.reason = "permission_denied"
        result
    }

    public static func scheduleReminderAt(context: Object, event: EventItem, reminderDate: DateTime): ReminderSyncResult {
        let result = ReminderSyncResult()
        result.scheduled = false
        result.calendarScheduled = false
        result.agentScheduled = false

        if (event.reminderType == ReminderType.Off || event.reminderHour == None || event.reminderMinute == None) {
            result.reason = "disabled"
            return result
        }

        if (reminderDate.toUnixTimeStamp().toMilliseconds() <= DateTime.now().toUnixTimeStamp().toMilliseconds()) {
            result.reason = "past"
            return result
        }

        // 简化实现：后续接入 CalendarKit
        result.reason = "permission_denied"
        result
    }

    public static func cancelReminder(context: Object, calendarEventId: ?Int64): Unit {
        // 后续接入 CalendarKit
    }

    public static func cancelAgentReminder(agentReminderId: ?Int64): Unit {
        // 后续接入 reminderAgentManager
    }
}
