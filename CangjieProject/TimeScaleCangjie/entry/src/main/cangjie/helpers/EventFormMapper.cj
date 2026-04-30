package ohos_app_cangjie_entry.helpers

import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.services.*
import std.time.*

public class EventFormStateData {
    public var isEditing: Bool = false
    public var eventId: Int64 = 0
    public var currentSortIndex: Int64 = 0
    public var currentCreateTime: Int64 = 0
    public var currentCalendarEventId: ?Int64 = None
    public var currentAgentReminderId: ?Int64 = None
    public var selectedColor: UInt32 = 0xFF2563EB
    public var isLunarDate: Bool = false
    public var title: String = ""
    public var note: String = ""
    public var selectedDate: DateTime = DateTime.now()
    public var repeatType: RepeatType = RepeatType.Once
    public var reminderType: ReminderType = ReminderType.Off
    public var reminderHour: Int64 = 12
    public var reminderMinute: Int64 = 0

    public init() {}
}

public class BuildEventRecordParams {
    public var id: Int64 = 0
    public var title: String = ""
    public var selectedDate: DateTime = DateTime.now()
    public var sortIndex: Int64 = 0
    public var selectedColor: UInt32 = 0xFF2563EB
    public var isLunarDate: Bool = false
    public var note: String = ""
    public var reminderType: ReminderType = ReminderType.Off
    public var reminderHour: Int64 = 12
    public var reminderMinute: Int64 = 0
    public var createTime: Int64 = 0
    public var repeatType: RepeatType = RepeatType.Once
    public var calendarEventId: ?Int64 = None
    public var agentReminderId: ?Int64 = None

    public init() {}
}

public class EventFormMapper {
    public static func createEmpty(primaryColor: UInt32): EventFormStateData {
        let state = EventFormStateData()
        state.selectedColor = primaryColor
        state.selectedDate = DateTime.now()
        state
    }

    public static func fromEvent(event: EventItem, primaryColor: UInt32): EventFormStateData {
        let state = EventFormStateData()
        state.isEditing = true
        state.eventId = event.id
        state.currentSortIndex = event.sortIndex
        state.currentCreateTime = event.createTime
        state.currentCalendarEventId = event.calendarEventId
        state.currentAgentReminderId = event.agentReminderId
        state.selectedColor = event.themeColor ?? primaryColor
        state.isLunarDate = event.isLunarDate ?? false
        state.title = event.title
        state.note = event.note ?? ""
        state.selectedDate = DateTime.fromUnixTimeStamp(Duration.millisecond * event.targetDate)
        state.repeatType = event.repeatType ?? RepeatType.Once
        state.reminderType = event.reminderType ?? ReminderType.Off
        state.reminderHour = event.reminderHour ?? 12
        state.reminderMinute = event.reminderMinute ?? 0
        state
    }

    public static func buildEventRecord(params: BuildEventRecordParams): EventItem {
        let event = EventItem()
        let selectedDate = params.selectedDate
        event.id = params.id
        event.title = params.title.trimAscii()
        event.targetDate = selectedDate.toUnixTimeStamp().toMilliseconds()
        event.sortIndex = params.sortIndex
        event.themeColor = params.selectedColor
        event.isLunarDate = params.isLunarDate
        let trimmedNote = params.note.trimAscii()
        event.note = if (trimmedNote.size > 0) { Some(trimmedNote) } else { None }
        event.reminderType = if (params.reminderType == ReminderType.Off) { None } else { params.reminderType }
        event.reminderHour = if (params.reminderType == ReminderType.Off) { None } else { params.reminderHour }
        event.reminderMinute = if (params.reminderType == ReminderType.Off) { None } else { params.reminderMinute }
        event.createTime = params.createTime
        event.repeatType = params.repeatType
        event.calendarEventId = params.calendarEventId
        event.agentReminderId = params.agentReminderId
        event.calendarType = if (params.isLunarDate) { CalendarType.Lunar } else { CalendarType.Solar }
        event.solarMonth = selectedDate.month.toInteger()
        event.solarDay = selectedDate.dayOfMonth
        if (params.isLunarDate) {
            let lunarInfo = LunarDateService.getLunarDateInfo(selectedDate.toUnixTimeStamp().toMilliseconds())
            event.lunarMonth = lunarInfo.lunarMonth
            event.lunarDay = lunarInfo.lunarDay
            event.isLeapMonth = lunarInfo.isLeapMonth
        }
        event
    }

    public static func cloneEvent(event: EventItem, id: Int64, calendarEventId: ?Int64): EventItem {
        cloneEvent(event, id, calendarEventId, None)
    }

    public static func cloneEvent(event: EventItem, id: Int64, calendarEventId: ?Int64, agentReminderId: ?Int64): EventItem {
        let clone = EventItem()
        clone.id = id
        clone.title = event.title
        clone.targetDate = event.targetDate
        clone.sortIndex = event.sortIndex
        clone.themeColor = event.themeColor
        clone.isLunarDate = event.isLunarDate
        clone.note = event.note
        clone.reminderType = event.reminderType
        clone.reminderHour = event.reminderHour
        clone.reminderMinute = event.reminderMinute
        clone.createTime = event.createTime
        clone.repeatType = event.repeatType
        clone.calendarEventId = calendarEventId
        clone.agentReminderId = agentReminderId
        clone.calendarType = event.calendarType
        clone.solarMonth = event.solarMonth
        clone.solarDay = event.solarDay
        clone.lunarMonth = event.lunarMonth
        clone.lunarDay = event.lunarDay
        clone.isLeapMonth = event.isLeapMonth
        clone
    }
}
