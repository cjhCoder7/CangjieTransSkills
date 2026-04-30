package ohos_app_cangjie_entry.store

import kit.AbilityKit.UIAbilityContext
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.services.*
import ohos_app_cangjie_entry.utils.*
import std.collection.*
import std.time.*

public class EventStore {
    public var eventList: ArrayList<EventItem> = ArrayList<EventItem>()

    private func getDataContext(): UIAbilityContext {
        AppContext.get()
    }

    public func load(): Unit {
        try {
            eventList = EventRepository.getAllEvents(getDataContext())
        } catch (_: Exception) {
            eventList = ArrayList<EventItem>()
        }
    }

    public func add(title: String, targetTime: Int64, themeColor: UInt32, note: ?String, reminderType: ReminderType, hour: Int64, minute: Int64, repeatType: RepeatType): Unit {
        let newEvent = EventItem()
        newEvent.id = DateTime.now().toUnixTimeStamp().toMilliseconds()
        newEvent.title = title
        newEvent.targetDate = targetTime
        newEvent.sortIndex = Int64(eventList.size)
        newEvent.themeColor = themeColor
        newEvent.note = note
        newEvent.reminderType = if (reminderType == ReminderType.Off) { None } else { reminderType }
        newEvent.reminderHour = if (reminderType == ReminderType.Off) { None } else { hour }
        newEvent.reminderMinute = if (reminderType == ReminderType.Off) { None } else { minute }
        newEvent.createTime = DateTime.now().toUnixTimeStamp().toMilliseconds()
        newEvent.repeatType = repeatType

        try {
            EventRepository.addEvent(getDataContext(), newEvent)
            load()
        } catch (_: Exception) {
            AppLogger.error("EventStore", "Failed to add event")
        }
    }

    public func delete(event: EventItem): Unit {
        try {
            ReminderScheduleService.cancelEventSchedule(getDataContext(), event)
            EventRepository.deleteEvent(getDataContext(), event.id)
            load()
        } catch (_: Exception) {
            AppLogger.error("EventStore", "Failed to delete event")
            throw Exception("Failed to delete event")
        }
    }

    public func update(event: EventItem): Unit {
        try {
            EventRepository.updateEvent(getDataContext(), event)
            load()
        } catch (_: Exception) {
            AppLogger.error("EventStore", "Failed to update event")
        }
    }

    public func moveItem(from: Int64, to: Int64): Unit {
        try {
            EventRepository.moveItem(getDataContext(), from, to)
            load()
        } catch (_: Exception) {
            AppLogger.error("EventStore", "Failed to move event")
            throw Exception("Failed to move event")
        }
    }
}

let eventStore = EventStore()
