package ohos_app_cangjie_entry.services

import kit.AbilityKit.UIAbilityContext
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.utils.*
import std.collection.*
import std.time.*

public class ReminderScheduleResult {
    public var scheduled: Bool = false
    public var calendarScheduled: Bool = false
    public var agentScheduled: Bool = false
    public var plannedCount: Int64 = 0
    public var calendarSuccessCount: Int64 = 0
    public var agentSuccessCount: Int64 = 0
    public var scheduledCount: Int64 = 0
    public var partialCount: Int64 = 0
    public var failedCount: Int64 = 0
    public var reason: ?String = None
    public var errorCode: ?Int64 = None

    public init() {}
}

public class ReminderScheduleService {
    public static func rebuildEventSchedule(context: UIAbilityContext, event: EventItem): ReminderScheduleResult {
        cancelEventSchedule(context, event)
        event.calendarEventId = None
        event.agentReminderId = None

        if (isReminderDisabled(event)) {
            return disabledResult()
        }

        ensureEventSchedule(context, event)
    }

    public static func ensureAllSchedules(context: UIAbilityContext): Unit {
        let events = EventRepository.getAllEvents(context)
        for (event in events) {
            try {
                ensureEventSchedule(context, event)
            } catch (_: Exception) {
                AppLogger.error("ReminderScheduleService", "Failed to ensure schedule. eventId=${event.id}")
            }
        }
    }

    public static func cancelEventSchedule(context: UIAbilityContext, event: EventItem): Unit {
        let instances = ReminderInstanceRepository.getInstancesByEventId(context, event.id)
        for (instance in instances) {
            ReminderService.cancelReminder(context, instance.calendarEventId)
            ReminderService.cancelAgentReminder(instance.agentReminderId)
            ReminderInstanceRepository.deleteInstance(context, instance.id)
        }

        ReminderService.cancelReminder(context, event.calendarEventId)
        ReminderService.cancelAgentReminder(event.agentReminderId)
    }

    public static func ensureEventSchedule(context: UIAbilityContext, event: EventItem): ReminderScheduleResult {
        if (isReminderDisabled(event)) {
            cancelEventSchedule(context, event)
            event.calendarEventId = None
            event.agentReminderId = None
            EventRepository.updateEvent(context, event)
            return disabledResult()
        }

        if (event.calendarEventId != None || event.agentReminderId != None) {
            ReminderService.cancelReminder(context, event.calendarEventId)
            ReminderService.cancelAgentReminder(event.agentReminderId)
            event.calendarEventId = None
            event.agentReminderId = None
            EventRepository.updateEvent(context, event)
        }

        cleanupExpiredInstances(context, event.id)

        let occurrences = ReminderOccurrenceGenerator.generateFutureOccurrences(event)
        if (occurrences.size == 0) {
            return pastResult()
        }

        let result = ReminderScheduleResult()
        result.plannedCount = Int64(occurrences.size)

        for (occurrence in occurrences) {
            let syncResult = ReminderService.scheduleReminderAt(context, event, occurrence.reminderDate)
            let now = DateTime.now().toUnixTimeStamp().toMilliseconds()

            let instance = ReminderInstance()
            instance.id = 0
            instance.eventId = event.id
            instance.occurrenceDate = occurrence.occurrenceDate.toUnixTimeStamp().toMilliseconds()
            instance.reminderTime = occurrence.reminderDate.toUnixTimeStamp().toMilliseconds()
            instance.calendarEventId = syncResult.calendarEventId
            instance.agentReminderId = syncResult.agentReminderId
            instance.status = if ((syncResult.calendarScheduled ?? false) || (syncResult.agentScheduled ?? false) || syncResult.scheduled) { ReminderInstanceStatus.Scheduled } else { ReminderInstanceStatus.Failed }
            instance.reason = syncResult.reason
            instance.createTime = now
            instance.updateTime = now
            ReminderInstanceRepository.addInstance(context, instance)

            mergeSyncResult(result, syncResult)
        }

        result
    }

    private static func mergeSyncResult(target: ReminderScheduleResult, source: ReminderSyncResult): Unit {
        let calendarScheduled = source.calendarScheduled ?? false
        target.calendarScheduled = target.calendarScheduled || calendarScheduled
        if (calendarScheduled) {
            target.calendarSuccessCount++
        }
        if (source.scheduled) {
            target.scheduled = true
            if (calendarScheduled) {
                target.scheduledCount++
            } else {
                target.partialCount++
                target.reason = source.reason
                target.errorCode = source.errorCode
            }
            return
        }

        if (calendarScheduled) {
            target.scheduled = true
            target.partialCount++
        } else {
            target.failedCount++
        }

        target.reason = source.reason
        target.errorCode = source.errorCode
    }

    private static func cleanupExpiredInstances(context: UIAbilityContext, eventId: Int64): Unit {
        let instances = ReminderInstanceRepository.getInstancesByEventId(context, eventId)
        let now = DateTime.now().toUnixTimeStamp().toMilliseconds()
        for (instance in instances) {
            if (instance.reminderTime <= now) {
                ReminderService.cancelReminder(context, instance.calendarEventId)
                ReminderService.cancelAgentReminder(instance.agentReminderId)
                ReminderInstanceRepository.deleteInstance(context, instance.id)
            }
        }
    }

    private static func isReminderDisabled(event: EventItem): Bool {
        event.reminderType == ReminderType.Off || event.reminderHour == None || event.reminderMinute == None
    }

    private static func disabledResult(): ReminderScheduleResult {
        let result = ReminderScheduleResult()
        result.reason = "disabled"
        result
    }

    private static func pastResult(): ReminderScheduleResult {
        let result = ReminderScheduleResult()
        result.reason = "past"
        result
    }
}
