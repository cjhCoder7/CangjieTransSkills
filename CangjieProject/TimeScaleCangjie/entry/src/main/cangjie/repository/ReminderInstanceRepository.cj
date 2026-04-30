package ohos_app_cangjie_entry.repository

import kit.ArkData.*
import kit.AbilityKit.UIAbilityContext
import ohos_app_cangjie_entry.database.RdbManager
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.utils.AppLogger
import std.collection.*

public class ReminderInstanceRepository {
    private static let TABLE_NAME: String = "reminder_instances"

    public static func getInstancesByEventId(context: UIAbilityContext, eventId: Int64): ArrayList<ReminderInstance> {
        let rdb = RdbManager.getRdb(context)
        let result = ArrayList<ReminderInstance>()
        var rs: ?ResultSet = None

        try {
            let predicates = RdbPredicates(TABLE_NAME)
            predicates.equalTo("eventId", RelationalStoreValueType.Integer(eventId))
                .orderByAsc("reminderTime")
            rs = rdb.query(predicates)
            if (let Some(resultSet) <- rs) {
                while (resultSet.goToNextRow()) {
                    result.add(fromResultSet(resultSet))
                }
            }
        } catch (_: Exception) {
            AppLogger.error("ReminderInstanceRepository", "Failed to query by eventId")
        }

        if (let Some(resultSet) <- rs) {
            resultSet.close()
        }
        result
    }

    public static func getFutureInstancesByEventId(context: UIAbilityContext, eventId: Int64, fromTime: Int64): ArrayList<ReminderInstance> {
        let rdb = RdbManager.getRdb(context)
        let result = ArrayList<ReminderInstance>()
        var rs: ?ResultSet = None

        try {
            let predicates = RdbPredicates(TABLE_NAME)
            predicates.equalTo("eventId", RelationalStoreValueType.Integer(eventId))
                .greaterThan("reminderTime", RelationalStoreValueType.Integer(fromTime))
                .orderByAsc("reminderTime")
            rs = rdb.query(predicates)
            if (let Some(resultSet) <- rs) {
                while (resultSet.goToNextRow()) {
                    result.add(fromResultSet(resultSet))
                }
            }
        } catch (_: Exception) {
            AppLogger.error("ReminderInstanceRepository", "Failed to query future instances")
        }

        if (let Some(resultSet) <- rs) {
            resultSet.close()
        }
        result
    }

    public static func addInstance(context: UIAbilityContext, instance: ReminderInstance): Int64 {
        let rdb = RdbManager.getRdb(context)
        let values = toValuesBucket(instance)
        rdb.insert(TABLE_NAME, values)
    }

    public static func updateInstance(context: UIAbilityContext, instance: ReminderInstance): Unit {
        let rdb = RdbManager.getRdb(context)
        let values = toValuesBucket(instance)
        let predicates = RdbPredicates(TABLE_NAME)
        predicates.equalTo("id", RelationalStoreValueType.Integer(instance.id))
        rdb.update(values, predicates)
    }

    public static func deleteInstance(context: UIAbilityContext, id: Int64): Unit {
        let rdb = RdbManager.getRdb(context)
        let predicates = RdbPredicates(TABLE_NAME)
        predicates.equalTo("id", RelationalStoreValueType.Integer(id))
        rdb.delete(predicates)
    }

    public static func deleteInstancesByEventId(context: UIAbilityContext, eventId: Int64): Unit {
        let rdb = RdbManager.getRdb(context)
        let predicates = RdbPredicates(TABLE_NAME)
        predicates.equalTo("eventId", RelationalStoreValueType.Integer(eventId))
        rdb.delete(predicates)
    }

    private static func fromResultSet(rs: ResultSet): ReminderInstance {
        let instance = ReminderInstance()
        instance.id = getLong(rs, "id")
        instance.eventId = getLong(rs, "eventId")
        instance.occurrenceDate = getLong(rs, "occurrenceDate")
        instance.reminderTime = getLong(rs, "reminderTime")
        instance.calendarEventId = getOptionalLong(rs, "calendarEventId")
        instance.agentReminderId = getOptionalLong(rs, "agentReminderId")

        let statusStr = getString(rs, "status")
        instance.status = if (statusStr == "failed") { ReminderInstanceStatus.Failed }
            else if (statusStr == "cancelled") { ReminderInstanceStatus.Cancelled }
            else { ReminderInstanceStatus.Scheduled }

        instance.reason = getOptionalString(rs, "reason")
        instance.createTime = getLong(rs, "createTime")
        instance.updateTime = getLong(rs, "updateTime")
        instance
    }

    private static func toValuesBucket(instance: ReminderInstance): HashMap<String, RelationalStoreValueType> {
        var values = HashMap<String, RelationalStoreValueType>()
        values.add("eventId", RelationalStoreValueType.Integer(instance.eventId))
        values.add("occurrenceDate", RelationalStoreValueType.Integer(instance.occurrenceDate))
        values.add("reminderTime", RelationalStoreValueType.Integer(instance.reminderTime))

        if (let Some(ceId) <- instance.calendarEventId) {
            values.add("calendarEventId", RelationalStoreValueType.Integer(ceId))
        }
        if (let Some(arId) <- instance.agentReminderId) {
            values.add("agentReminderId", RelationalStoreValueType.Integer(arId))
        }

        let statusStr = if (instance.status == ReminderInstanceStatus.Failed) { "failed" }
            else if (instance.status == ReminderInstanceStatus.Cancelled) { "cancelled" }
            else { "scheduled" }
        values.add("status", RelationalStoreValueType.StringValue(statusStr))

        if (let Some(reason) <- instance.reason) {
            values.add("reason", RelationalStoreValueType.StringValue(reason))
        }

        values.add("createTime", RelationalStoreValueType.Integer(instance.createTime))
        values.add("updateTime", RelationalStoreValueType.Integer(instance.updateTime))
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
