package ohos_app_cangjie_entry.database

import kit.ArkData.*
import kit.AbilityKit.UIAbilityContext
import ohos_app_cangjie_entry.utils.AppLogger

public class RdbManager {
    private static let DB_NAME: String = "event.db"
    private static let TABLE_NAME: String = "events"
    private static let REMINDER_INSTANCE_TABLE_NAME: String = "reminder_instances"
    private static var rdb: ?RdbStore = None

    public static func getRdb(context: UIAbilityContext): RdbStore {
        if (let Some(store) <- rdb) {
            return store
        }

        let config = StoreConfig(
            RelationalStoreSecurityLevel.S1,
            name: DB_NAME
        )
        let store = getRdbStore(context, config)
        rdb = store
        initSchema(store)
        store
    }

    private static func initSchema(store: RdbStore): Unit {
        store.executeSql(
            "CREATE TABLE IF NOT EXISTS events (" +
            "id INTEGER PRIMARY KEY AUTOINCREMENT," +
            "title TEXT NOT NULL," +
            "targetDate INTEGER," +
            "sortIndex INTEGER," +
            "themeColor TEXT," +
            "isLunarDate INTEGER," +
            "type TEXT NOT NULL DEFAULT 'countdown'," +
            "status TEXT NOT NULL DEFAULT 'future'," +
            "note TEXT," +
            "reminderType TEXT," +
            "reminderHour INTEGER," +
            "reminderMinute INTEGER," +
            "createTime INTEGER," +
            "repeatType TEXT," +
            "calendarEventId INTEGER," +
            "agentReminderId INTEGER," +
            "calendarType TEXT," +
            "solarMonth INTEGER," +
            "solarDay INTEGER," +
            "lunarMonth INTEGER," +
            "lunarDay INTEGER," +
            "isLeapMonth INTEGER)"
        )

        store.executeSql(
            "CREATE TABLE IF NOT EXISTS reminder_instances (" +
            "id INTEGER PRIMARY KEY AUTOINCREMENT," +
            "eventId INTEGER NOT NULL," +
            "occurrenceDate INTEGER NOT NULL," +
            "reminderTime INTEGER NOT NULL," +
            "calendarEventId INTEGER," +
            "agentReminderId INTEGER," +
            "status TEXT NOT NULL DEFAULT 'scheduled'," +
            "reason TEXT," +
            "createTime INTEGER," +
            "updateTime INTEGER)"
        )

        tryExecuteMigration(store,
            "CREATE UNIQUE INDEX IF NOT EXISTS idx_reminder_instances_event_time ON reminder_instances (eventId, reminderTime)",
            "reminder instance unique index")
        tryExecuteMigration(store, "ALTER TABLE events ADD COLUMN themeColor TEXT", "events.themeColor")
        tryExecuteMigration(store, "ALTER TABLE events ADD COLUMN isLunarDate INTEGER", "events.isLunarDate")
        tryExecuteMigration(store, "ALTER TABLE events ADD COLUMN calendarEventId INTEGER", "events.calendarEventId")
        tryExecuteMigration(store, "ALTER TABLE events ADD COLUMN agentReminderId INTEGER", "events.agentReminderId")
        tryExecuteMigration(store, "ALTER TABLE events ADD COLUMN calendarType TEXT", "events.calendarType")
        tryExecuteMigration(store, "ALTER TABLE events ADD COLUMN solarMonth INTEGER", "events.solarMonth")
        tryExecuteMigration(store, "ALTER TABLE events ADD COLUMN solarDay INTEGER", "events.solarDay")
        tryExecuteMigration(store, "ALTER TABLE events ADD COLUMN lunarMonth INTEGER", "events.lunarMonth")
        tryExecuteMigration(store, "ALTER TABLE events ADD COLUMN lunarDay INTEGER", "events.lunarDay")
        tryExecuteMigration(store, "ALTER TABLE events ADD COLUMN isLeapMonth INTEGER", "events.isLeapMonth")
    }

    private static func tryExecuteMigration(store: RdbStore, sql: String, label: String): Unit {
        try {
            store.executeSql(sql)
        } catch (_: Exception) {
            AppLogger.warn("RdbManager", "Skip migration ${label}")
        }
    }
}
