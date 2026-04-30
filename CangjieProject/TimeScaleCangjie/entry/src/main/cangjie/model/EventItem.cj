package ohos_app_cangjie_entry.model

import std.deriving.*

@Derive[Equatable]
public enum ReminderType {
    | OnDay
    | OneDayBefore
    | Off
}

@Derive[Equatable]
public enum CalendarType {
    | Solar
    | Lunar
}

@Derive[Equatable]
public enum RepeatType {
    | Once
    | Monthly
    | Yearly
}

public class EventItem {
    public var id: Int64 = 0
    public var title: String = ""
    public var targetDate: Int64 = 0
    public var sortIndex: Int64 = 0
    public var themeColor: ?UInt32 = None
    public var isLunarDate: ?Bool = None
    public var note: ?String = None
    public var reminderType: ?ReminderType = None
    public var reminderHour: ?Int64 = None
    public var reminderMinute: ?Int64 = None
    public var createTime: Int64 = 0
    public var repeatType: ?RepeatType = None
    public var calendarEventId: ?Int64 = None
    public var agentReminderId: ?Int64 = None
    public var calendarType: ?CalendarType = None
    public var solarMonth: ?Int64 = None
    public var solarDay: ?Int64 = None
    public var lunarMonth: ?Int64 = None
    public var lunarDay: ?Int64 = None
    public var isLeapMonth: ?Bool = None

    public init() {}

    public func cloneWithId(newId!: Int64, calendarEventId!: ?Int64, agentReminderId!: ?Int64): EventItem {
        let copy = EventItem()
        copy.id = newId
        copy.title = this.title
        copy.targetDate = this.targetDate
        copy.sortIndex = this.sortIndex
        copy.themeColor = this.themeColor
        copy.isLunarDate = this.isLunarDate
        copy.note = this.note
        copy.reminderType = this.reminderType
        copy.reminderHour = this.reminderHour
        copy.reminderMinute = this.reminderMinute
        copy.createTime = this.createTime
        copy.repeatType = this.repeatType
        copy.calendarEventId = calendarEventId
        copy.agentReminderId = agentReminderId
        copy.calendarType = this.calendarType
        copy.solarMonth = this.solarMonth
        copy.solarDay = this.solarDay
        copy.lunarMonth = this.lunarMonth
        copy.lunarDay = this.lunarDay
        copy.isLeapMonth = this.isLeapMonth
        copy
    }
}
