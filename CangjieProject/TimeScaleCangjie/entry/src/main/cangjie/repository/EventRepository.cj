package ohos_app_cangjie_entry.repository

import kit.ArkData.*
import kit.AbilityKit.UIAbilityContext
import ohos_app_cangjie_entry.database.RdbManager
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.utils.AppLogger
import std.collection.*
import std.convert.*

public class EventRepository {
    private static let DEFAULT_THEME_COLOR: UInt32 = 0xFF2563EB

    public static func getAllEvents(context: UIAbilityContext): ArrayList<EventItem> {
        let rdb = RdbManager.getRdb(context)
        let events = ArrayList<EventItem>()
        var result: ?ResultSet = None

        try {
            result = rdb.querySql("SELECT * FROM events ORDER BY sortIndex ASC")
            if (let Some(rs) <- result) {
                while (rs.goToNextRow()) {
                    events.add(fromResultSet(rs))
                }
            }
        } catch (e: Exception) {
            AppLogger.error("EventRepository", "Failed to query events")
        }

        if (let Some(rs) <- result) {
            rs.close()
        }
        events
    }

    public static func getEventById(context: UIAbilityContext, id: Int64): ?EventItem {
        let events = getAllEvents(context)
        for (event in events) {
            if (event.id == id) {
                return event
            }
        }
        None
    }

    public static func addEvent(context: UIAbilityContext, event: EventItem): Int64 {
        let rdb = RdbManager.getRdb(context)
        let list = getAllEvents(context)
        let values = toValuesBucket(event)
        values.add("sortIndex", RelationalStoreValueType.Integer(Int64(list.size)))
        rdb.insert("events", values)
    }

    public static func updateEvent(context: UIAbilityContext, event: EventItem): Unit {
        let rdb = RdbManager.getRdb(context)
        let values = toValuesBucket(event)
        let predicates = RdbPredicates("events")
        predicates.equalTo("id", RelationalStoreValueType.Integer(event.id))
        rdb.update(values, predicates)
    }

    public static func deleteEvent(context: UIAbilityContext, id: Int64): Unit {
        let rdb = RdbManager.getRdb(context)
        let predicates = RdbPredicates("events")
        predicates.equalTo("id", RelationalStoreValueType.Integer(id))
        rdb.delete(predicates)
    }

    public static func moveItem(context: UIAbilityContext, from: Int64, to: Int64): Unit {
        let rdb = RdbManager.getRdb(context)
        let list = getAllEvents(context)
        if (from < 0 || from >= Int64(list.size) || to < 0 || to >= Int64(list.size)) {
            return
        }

        let item = list[from]
        list.remove(at: from)
        list.add(item, at: to)

        var transactionOpened: Bool = false
        try {
            rdb.beginTransaction()
            transactionOpened = true
        } catch (_: Exception) {
            AppLogger.warn("EventRepository", "Transaction not supported, fallback")
        }

        try {
            for (i in 0..list.size) {
                if (let Some(ev) <- list.get(i)) {
                    ev.sortIndex = Int64(i)
                    let predicates = RdbPredicates("events")
                    predicates.equalTo("id", RelationalStoreValueType.Integer(ev.id))
                    var values = HashMap<String, RelationalStoreValueType>()
                    values.add("sortIndex", RelationalStoreValueType.Integer(ev.sortIndex))
                    rdb.update(values, predicates)
                }
            }
            if (transactionOpened) {
                rdb.commit()
            }
        } catch (_: Exception) {
            if (transactionOpened) {
                try { rdb.rollBack() } catch (_: Exception) {}
            }
        }
    }

    public static func saveSortOrder(context: UIAbilityContext, list: ArrayList<EventItem>): Unit {
        let rdb = RdbManager.getRdb(context)
        var transactionOpened: Bool = false
        try {
            rdb.beginTransaction()
            transactionOpened = true
        } catch (_: Exception) {
            AppLogger.warn("EventRepository", "Transaction not supported, fallback")
        }

        try {
            for (i in 0..list.size) {
                if (let Some(ev) <- list.get(i)) {
                    ev.sortIndex = Int64(i)
                    let predicates = RdbPredicates("events")
                    predicates.equalTo("id", RelationalStoreValueType.Integer(ev.id))
                    var values = HashMap<String, RelationalStoreValueType>()
                    values.add("sortIndex", RelationalStoreValueType.Integer(ev.sortIndex))
                    rdb.update(values, predicates)
                }
            }
            if (transactionOpened) {
                rdb.commit()
            }
        } catch (_: Exception) {
            if (transactionOpened) {
                try { rdb.rollBack() } catch (_: Exception) {}
            }
        }
    }

    private static func fromResultSet(rs: ResultSet): EventItem {
        let event = EventItem()
        event.id = getLong(rs, "id")
        event.title = getString(rs, "title") ?? ""
        event.targetDate = getLong(rs, "targetDate")
        event.sortIndex = getLong(rs, "sortIndex")

        let themeColorStr = getString(rs, "themeColor")
        if (let Some(s) <- themeColorStr) {
            if (s.size > 0) {
                try {
                    event.themeColor = Some(UInt32(Int64.parse(s)))
                } catch (_: Exception) {
                    event.themeColor = Some(DEFAULT_THEME_COLOR)
                }
            } else {
                event.themeColor = Some(DEFAULT_THEME_COLOR)
            }
        } else {
            event.themeColor = Some(DEFAULT_THEME_COLOR)
        }

        event.isLunarDate = if (getLong(rs, "isLunarDate") == 1) { Some(true) } else { Some(false) }
        event.note = getOptionalString(rs, "note")

        let reminderTypeStr = getString(rs, "reminderType")
        event.reminderType = if (reminderTypeStr == "on_day") { Some(ReminderType.OnDay) }
            else if (reminderTypeStr == "one_day_before") { Some(ReminderType.OneDayBefore) }
            else { None }

        event.reminderHour = getOptionalLong(rs, "reminderHour")
        event.reminderMinute = getOptionalLong(rs, "reminderMinute")
        event.createTime = getLong(rs, "createTime")

        let repeatTypeStr = getString(rs, "repeatType")
        event.repeatType = if (repeatTypeStr == "monthly") { Some(RepeatType.Monthly) }
            else if (repeatTypeStr == "yearly") { Some(RepeatType.Yearly) }
            else { None }

        event.calendarEventId = getOptionalLong(rs, "calendarEventId")
        event.agentReminderId = getOptionalLong(rs, "agentReminderId")

        let calendarTypeStr = getString(rs, "calendarType")
        if (calendarTypeStr == "lunar") {
            event.calendarType = Some(CalendarType.Lunar)
        } else {
            event.calendarType = Some(CalendarType.Solar)
        }

        event.solarMonth = getOptionalLong(rs, "solarMonth")
        event.solarDay = getOptionalLong(rs, "solarDay")
        event.lunarMonth = getOptionalLong(rs, "lunarMonth")
        event.lunarDay = getOptionalLong(rs, "lunarDay")

        let isLeapMonthVal = getOptionalLong(rs, "isLeapMonth")
        event.isLeapMonth = if (isLeapMonthVal == Some(1)) { Some(true) } else { Some(false) }

        // 补全旧数据字段
        if (event.calendarType == None) {
            event.calendarType = if (event.isLunarDate ?? false) { Some(CalendarType.Lunar) } else { Some(CalendarType.Solar) }
        }

        event
    }

    private static func toValuesBucket(event: EventItem): HashMap<String, RelationalStoreValueType> {
        var values = HashMap<String, RelationalStoreValueType>()
        values.add("title", RelationalStoreValueType.StringValue(event.title))
        values.add("targetDate", RelationalStoreValueType.Integer(event.targetDate))
        values.add("sortIndex", RelationalStoreValueType.Integer(event.sortIndex))

        let colorStr = if (let Some(c) <- event.themeColor) { "${c}" } else { "${DEFAULT_THEME_COLOR}" }
        values.add("themeColor", RelationalStoreValueType.StringValue(colorStr))
        values.add("isLunarDate", RelationalStoreValueType.Integer(if (event.isLunarDate ?? false) { 1 } else { 0 }))

        if (let Some(note) <- event.note) {
            values.add("note", RelationalStoreValueType.StringValue(note))
        }

        if (let Some(rt) <- event.reminderType) {
            let rtStr = if (rt == ReminderType.OnDay) { "on_day" } else { "one_day_before" }
            values.add("reminderType", RelationalStoreValueType.StringValue(rtStr))
        }
        if (let Some(h) <- event.reminderHour) {
            values.add("reminderHour", RelationalStoreValueType.Integer(h))
        }
        if (let Some(m) <- event.reminderMinute) {
            values.add("reminderMinute", RelationalStoreValueType.Integer(m))
        }

        values.add("createTime", RelationalStoreValueType.Integer(event.createTime))

        if (let Some(rpt) <- event.repeatType) {
            let rptStr = if (rpt == RepeatType.Monthly) { "monthly" } else if (rpt == RepeatType.Yearly) { "yearly" } else { "none" }
            values.add("repeatType", RelationalStoreValueType.StringValue(rptStr))
        }

        if (let Some(ceId) <- event.calendarEventId) {
            values.add("calendarEventId", RelationalStoreValueType.Integer(ceId))
        }
        if (let Some(arId) <- event.agentReminderId) {
            values.add("agentReminderId", RelationalStoreValueType.Integer(arId))
        }

        let calTypeStr = if (event.calendarType == Some(CalendarType.Lunar)) { "lunar" } else { "solar" }
        values.add("calendarType", RelationalStoreValueType.StringValue(calTypeStr))

        if (let Some(sm) <- event.solarMonth) {
            values.add("solarMonth", RelationalStoreValueType.Integer(sm))
        }
        if (let Some(sd) <- event.solarDay) {
            values.add("solarDay", RelationalStoreValueType.Integer(sd))
        }
        if (let Some(lm) <- event.lunarMonth) {
            values.add("lunarMonth", RelationalStoreValueType.Integer(lm))
        }
        if (let Some(ld) <- event.lunarDay) {
            values.add("lunarDay", RelationalStoreValueType.Integer(ld))
        }
        values.add("isLeapMonth", RelationalStoreValueType.Integer(if (event.isLeapMonth ?? false) { 1 } else { 0 }))

        values
    }

    private static func getLong(rs: ResultSet, name: String): Int64 {
        try {
            let col = rs.getColumnIndex(name)
            rs.getLong(col)
        } catch (_: Exception) {
            0
        }
    }

    private static func getOptionalLong(rs: ResultSet, name: String): ?Int64 {
        try {
            let col = rs.getColumnIndex(name)
            if (col < 0) { return None }
            let v = rs.getLong(col)
            if (v == 0) { None } else { Some(v) }
        } catch (_: Exception) {
            None
        }
    }

    private static func getString(rs: ResultSet, name: String): ?String {
        try {
            let col = rs.getColumnIndex(name)
            if (col < 0) { return None }
            let s = rs.getString(col)
            if (s.size == 0) { None } else { Some(s) }
        } catch (_: Exception) {
            None
        }
    }

    private static func getOptionalString(rs: ResultSet, name: String): ?String {
        try {
            let col = rs.getColumnIndex(name)
            if (col < 0) { return None }
            let s = rs.getString(col)
            if (s.size == 0) { None } else { Some(s) }
        } catch (_: Exception) {
            None
        }
    }
}
