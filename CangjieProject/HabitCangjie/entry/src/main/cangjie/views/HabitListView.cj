package ohos_app_cangjie_entry.views

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos_app_cangjie_entry.models
import ohos_app_cangjie_entry.models.Habit
import ohos_app_cangjie_entry.models.HabitColor
import ohos_app_cangjie_entry.models.DateHelper
import ohos_app_cangjie_entry.models.Constants
import ohos_app_cangjie_entry.models.randomHabitColor
import ohos_app_cangjie_entry.models.allHabitColors
import ohos_app_cangjie_entry.controllers
import ohos_app_cangjie_entry.controllers.DataController
import ohos_app_cangjie_entry.controllers.AppStorageHolder
import std.collection.ArrayList

/// 习惯列表视图
@Component
class HabitListView {
    @Prop var habits: ArrayList<Habit>
    @Prop var sortingOption: SortingOption
    @Prop var isSortingOrderAscending: Bool
    var onToggleCompletion: (Habit, Int64) -> Unit = { _, _ => }
    var onDelete: (Habit) -> Unit = { _ => }
    var onHabitTap: (Habit) -> Unit = { _ => }

    /// 排序后的习惯列表
    prop sortedHabits: ArrayList<Habit> {
        get() {
            let list = ArrayList<Habit>()
            for (h in habits) {
                list.add(h)
            }
            match (sortingOption) {
                case SortingOption.ByDate =>
                    if (isSortingOrderAscending) {
                        list.sortBy(comparator: { a: Habit, b: Habit =>
                            if (a.creationDate < b.creationDate) { Ordering.LT } else if (a.creationDate > b.creationDate) { Ordering.GT } else { Ordering.EQ }
                        })
                    } else {
                        list.sortBy(comparator: { a: Habit, b: Habit =>
                            if (b.creationDate < a.creationDate) { Ordering.LT } else if (b.creationDate > a.creationDate) { Ordering.GT } else { Ordering.EQ }
                        })
                    }
                case SortingOption.ByName =>
                    if (isSortingOrderAscending) {
                        list.sortBy(comparator: { a: Habit, b: Habit =>
                            if (a.title < b.title) { Ordering.LT } else if (a.title > b.title) { Ordering.GT } else { Ordering.EQ }
                        })
                    } else {
                        list.sortBy(comparator: { a: Habit, b: Habit =>
                            if (b.title < a.title) { Ordering.LT } else if (b.title > a.title) { Ordering.GT } else { Ordering.EQ }
                        })
                    }
            }
            list
        }
    }

    func build() {
        List(space: 0, initialIndex: 0) {
            ForEach(this.sortedHabits, itemGeneratorFunc: { habit: Habit, idx: Int64 =>
                ListItem() {
                    HabitRowView(
                        habit: habit,
                        onToggleCompletion: { daysAgo: Int64 => this.onToggleCompletion(habit, daysAgo) },
                        onTap: { => this.onHabitTap(habit) }
                    )
                }
                .margin(top: 8.0, bottom: 6.0, left: 16.0, right: 16.0)
                .swipeAction(end: { =>
                    Button("删除")
                        .backgroundColor(Color.Red)
                        .fontColor(Color.White)
                        .onClick({ evt => this.onDelete(habit) })
                })
            }, keyGeneratorFunc: { habit: Habit, idx: Int64 => habit.id })
        }
        .divider(ListDividerOptions(strokeWidth: 0.0))
    }
}
