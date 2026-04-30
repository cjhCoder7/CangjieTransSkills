package ohos_app_cangjie_entry.controllers

import ohos_app_cangjie_entry.models
import ohos_app_cangjie_entry.models.Habit
import ohos_app_cangjie_entry.models.HabitColor
import ohos_app_cangjie_entry.models.DateHelper
import ohos_app_cangjie_entry.models.habitColorFromString
import ohos_app_cangjie_entry.models.randomHabitColor
import kit.ArkData.*
import kit.AbilityKit.UIAbilityContext
import kit.PerformanceAnalysisKit.Hilog
import std.collection.ArrayList
import std.collection.HashMap
import std.convert.*

/// 数据控制器 — 使用 RDB 管理习惯数据
public class DataController {
    private var rdbStore: Option<RdbStore> = Option<RdbStore>.None

    private static let SQL_CREATE_TABLE = "CREATE TABLE IF NOT EXISTS habit(" +
        "id TEXT PRIMARY KEY," +
        "title TEXT NOT NULL DEFAULT ''," +
        "motivation TEXT NOT NULL DEFAULT ''," +
        "color TEXT NOT NULL DEFAULT 'habit_blue'," +
        "creation_date INTEGER NOT NULL DEFAULT 0," +
        "completed_dates TEXT NOT NULL DEFAULT '')"

    /// 初始化数据库
    public func initDatabase(context: UIAbilityContext): Unit {
        let storeConfig = StoreConfig(
            RelationalStoreSecurityLevel.S1,
            name: "habit.db",
            encrypt: false
        )
        try {
            let store = getRdbStore(context, storeConfig)
            store.executeSql(DataController.SQL_CREATE_TABLE)
            rdbStore = store
            Hilog.info(1, "Habit", "数据库初始化成功")
        } catch (e: Exception) {
            Hilog.error(1, "Habit", "数据库初始化失败: ${e.message}")
        }
    }

    /// 获取数据库（安全方式）
    private func getStore(): Option<RdbStore> {
        rdbStore
    }

    /// 保存习惯（新增或更新）
    public func saveHabit(habit: Habit): Unit {
        if (let Some(store) <- rdbStore) {
            try {
                let values = habitToValues(habit)
                let updatePredicates = RdbPredicates("habit")
                updatePredicates.equalTo("id", RelationalStoreValueType.StringValue(habit.id))
                let rows = store.update(values, updatePredicates)
                if (rows == 0) {
                    store.insert("habit", values)
                }
            } catch (e: Exception) {
                Hilog.error(1, "Habit", "保存习惯失败: ${e.message}")
            }
        } else {
            Hilog.error(1, "Habit", "数据库未初始化，无法保存习惯")
        }
    }

    /// 删除习惯
    public func deleteHabit(habit: Habit): Unit {
        if (let Some(store) <- rdbStore) {
            try {
                let predicates = RdbPredicates("habit")
                predicates.equalTo("id", RelationalStoreValueType.StringValue(habit.id))
                store.delete(predicates)
            } catch (e: Exception) {
                Hilog.error(1, "Habit", "删除习惯失败: ${e.message}")
            }
        } else {
            Hilog.error(1, "Habit", "数据库未初始化，无法删除习惯")
        }
    }

    /// 获取所有习惯（按创建日期排序）
    public func getAllHabits(): ArrayList<Habit> {
        let habits = ArrayList<Habit>()
        if (let Some(store) <- rdbStore) {
            try {
                let predicates = RdbPredicates("habit")
                predicates.orderByAsc("creation_date")
                let resultSet = store.query(predicates, columns: ["id", "title", "motivation", "color", "creation_date", "completed_dates"])
                let rowCount = resultSet.rowCount
                var i: Int32 = 0
                while (i < rowCount) {
                    resultSet.goToRow(i)
                    let habit = resultSetToHabit(resultSet)
                    habits.add(habit)
                    i += 1
                }
                resultSet.close()
            } catch (e: Exception) {
                Hilog.error(1, "Habit", "查询习惯失败: ${e.message}")
            }
        }
        habits
    }

    /// 按 ID 查找习惯
    public func findHabit(id: String): Option<Habit> {
        if (let Some(store) <- rdbStore) {
            try {
                let predicates = RdbPredicates("habit")
                predicates.equalTo("id", RelationalStoreValueType.StringValue(id))
                let resultSet = store.query(predicates, columns: ["id", "title", "motivation", "color", "creation_date", "completed_dates"])

                if (resultSet.rowCount > 0) {
                    resultSet.goToRow(0)
                    let habit = resultSetToHabit(resultSet)
                    resultSet.close()
                    Some(habit)
                } else {
                    resultSet.close()
                    None
                }
            } catch (e: Exception) {
                Hilog.error(1, "Habit", "查找习惯失败: ${e.message}")
                None
            }
        } else {
            None
        }
    }

    /// 删除所有习惯
    public func deleteAll(): Unit {
        if (let Some(store) <- rdbStore) {
            try {
                let predicates = RdbPredicates("habit")
                store.delete(predicates)
            } catch (e: Exception) {
                Hilog.error(1, "Habit", "删除所有习惯失败: ${e.message}")
            }
        }
    }

    /// 创建示例数据
    public func createSampleData(): Unit {
        for (i in 0..10) {
            let habit = Habit("习惯 ${i}", "", randomHabitColor())
            let randomDates = DateHelper.getRandomDates(180, 40)
            habit.completedDates = randomDates
            saveHabit(habit)
        }
    }

    /// Habit 转数据库值
    private func habitToValues(habit: Habit): HashMap<String, RelationalStoreValueType> {
        var values = HashMap<String, RelationalStoreValueType>()
        values.add("id", RelationalStoreValueType.StringValue(habit.id))
        values.add("title", RelationalStoreValueType.StringValue(habit.title))
        values.add("motivation", RelationalStoreValueType.StringValue(habit.motivation))
        values.add("color", RelationalStoreValueType.StringValue(habit.color.resourceName))
        values.add("creation_date", RelationalStoreValueType.Integer(habit.creationDate))
        var sb = StringBuilder()
        var first = true
        for (d in habit.completedDates) {
            if (!first) {
                sb.append(",")
            }
            sb.append(d.toString())
            first = false
        }
        values.add("completed_dates", RelationalStoreValueType.StringValue(sb.toString()))
        values
    }

    /// 数据库行转 Habit
    private func resultSetToHabit(resultSet: ResultSet): Habit {
        let id = resultSet.getString(resultSet.getColumnIndex("id"))
        let title = resultSet.getString(resultSet.getColumnIndex("title"))
        let motivation = resultSet.getString(resultSet.getColumnIndex("motivation"))
        let colorStr = resultSet.getString(resultSet.getColumnIndex("color"))
        let creationDate = resultSet.getLong(resultSet.getColumnIndex("creation_date"))
        let completedDatesStr = resultSet.getString(resultSet.getColumnIndex("completed_dates"))

        let color = habitColorFromString(colorStr)
        var completedDates = ArrayList<Int64>()
        if (completedDatesStr.size > 0) {
            let parts = completedDatesStr.split(",")
            for (part in parts) {
                if (part.size > 0) {
                    try {
                        completedDates.add(Int64.parse(part))
                    } catch (_: Exception) {
                        // 跳过无效数据
                    }
                }
            }
        }

        Habit(id, title, motivation, color, creationDate, completedDates)
    }
}
