package ohos_app_cangjie_entry.services

import kit.AbilityKit.UIAbilityContext
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.*

public class ReminderSyncState {
    public var scheduled: Bool = false
    public var calendarScheduled: Bool = false
    public var agentScheduled: Bool = false
    public var plannedCount: Int64 = 0
    public var calendarSuccessCount: Int64 = 0
    public var agentSuccessCount: Int64 = 0
    public var failedCount: Int64 = 0
    public var partialCount: Int64 = 0
    public var calendarEventId: ?Int64 = None
    public var agentReminderId: ?Int64 = None
    public var reason: ?String = None
    public var errorCode: ?Int64 = None

    public init() {}
}

public class EventSaveRequest {
    public var isEditing: Bool = false
    public var eventId: Int64 = 0
    public var draftEvent: EventItem = EventItem()

    public init() {}
}

public class EventSaveService {
    public static func saveEvent(context: UIAbilityContext, request: EventSaveRequest): ReminderSyncState {
        let reminderResult = ReminderSyncState()

        if (request.isEditing) {
            let latestEvent = EventRepository.getEventById(context, request.eventId)
            if (let Some(latest) <- latestEvent) {
                request.draftEvent.sortIndex = latest.sortIndex
                request.draftEvent.calendarEventId = latest.calendarEventId
                request.draftEvent.agentReminderId = latest.agentReminderId
            }
            let syncResult = ReminderScheduleService.rebuildEventSchedule(context, request.draftEvent)
            applyReminderResult(reminderResult, syncResult)
            let updatedEvent = request.draftEvent.cloneWithId(newId: request.draftEvent.id, calendarEventId: None, agentReminderId: None)
            EventRepository.updateEvent(context, updatedEvent)
            return reminderResult
        }

        let insertedId = EventRepository.addEvent(context, request.draftEvent)
        let createdEvent = request.draftEvent.cloneWithId(newId: insertedId, calendarEventId: request.draftEvent.calendarEventId, agentReminderId: request.draftEvent.agentReminderId)
        let insertedEvent = EventRepository.getEventById(context, insertedId)
        if (let Some(ie) <- insertedEvent) {
            createdEvent.sortIndex = ie.sortIndex
        }
        let syncResult = ReminderScheduleService.rebuildEventSchedule(context, createdEvent)
        applyReminderResult(reminderResult, syncResult)
        let updatedEvent = createdEvent.cloneWithId(newId: insertedId, calendarEventId: None, agentReminderId: None)
        EventRepository.updateEvent(context, updatedEvent)
        reminderResult
    }

    private static func applyReminderResult(target: ReminderSyncState, source: ReminderScheduleResult): Unit {
        target.scheduled = source.scheduled
        target.calendarScheduled = source.calendarScheduled
        target.agentScheduled = source.agentScheduled
        target.plannedCount = source.plannedCount
        target.calendarSuccessCount = source.calendarSuccessCount
        target.agentSuccessCount = source.agentSuccessCount
        target.failedCount = source.failedCount
        target.partialCount = source.partialCount
        target.calendarEventId = None
        target.agentReminderId = None
        target.reason = source.reason
        target.errorCode = source.errorCode
    }
}
