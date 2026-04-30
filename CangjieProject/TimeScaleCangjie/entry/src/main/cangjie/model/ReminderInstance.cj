package ohos_app_cangjie_entry.model

import std.deriving.*

@Derive[Equatable]
public enum ReminderInstanceStatus {
    | Scheduled
    | Failed
    | Cancelled
}

public class ReminderInstance {
    public var id: Int64 = 0
    public var eventId: Int64 = 0
    public var occurrenceDate: Int64 = 0
    public var reminderTime: Int64 = 0
    public var calendarEventId: ?Int64 = None
    public var agentReminderId: ?Int64 = None
    public var status: ReminderInstanceStatus = ReminderInstanceStatus.Scheduled
    public var reason: ?String = None
    public var createTime: Int64 = 0
    public var updateTime: Int64 = 0

    public init() {}
}
