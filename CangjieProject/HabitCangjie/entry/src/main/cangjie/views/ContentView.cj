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

/// 主页面内容视图
@Entry
@Component
class ContentView {
    @State var habits: ArrayList<Habit> = ArrayList<Habit>()
    @State var sortingOption: SortingOption = SortingOption.ByDate
    @State var isSortingOrderAscending: Bool = false
    @State var isPresentingEditView: Bool = false
    @State var editingHabit: Option<Habit> = Option<Habit>.None
    @State var isPresentingDetailView: Bool = false
    @State var selectedHabit: Option<Habit> = Option<Habit>.None

    func build() {
        if (this.isPresentingEditView) {
            EditHabitView(
                habit: this.editingHabit,
                onSave: { habit: Habit =>
                    this.dataController.saveHabit(habit)
                    this.refreshHabits()
                    this.isPresentingEditView = false
                },
                onDelete: { habit: Habit =>
                    this.dataController.deleteHabit(habit)
                    this.refreshHabits()
                    this.isPresentingEditView = false
                },
                onClose: { =>
                    this.isPresentingEditView = false
                }
            )
        } else if (this.isPresentingDetailView) {
            if (let Some(habit) <- this.selectedHabit) {
                DetailView(
                    habit: habit,
                    onClose: { =>
                        this.isPresentingDetailView = false
                    },
                    onEdit: { h: Habit =>
                        this.isPresentingDetailView = false
                        this.editingHabit = Some(h)
                        this.isPresentingEditView = true
                    },
                    onDelete: { h: Habit =>
                        this.dataController.deleteHabit(h)
                        this.refreshHabits()
                        this.isPresentingDetailView = false
                    },
                    onToggleCompletion: { h: Habit, daysAgo: Int64 =>
                        h.toggleCompletion(daysAgo)
                        this.dataController.saveHabit(h)
                        this.refreshHabits()
                    }
                )
            }
        } else {
            Navigation(this.pageStack) {
                Column(space: 0.0) {
                    Divider()
                    HeaderView()
                    Row() {
                        Blank()
                        Text("排序")
                            .fontSize(14.0)
                            .fontColor(Color.Gray)
                            .onClick({ evt =>
                                this.isSortingOrderAscending = !this.isSortingOrderAscending
                            })
                        Text("+")
                            .fontSize(28.0)
                            .fontWeight(FontWeight.Bold)
                            .margin(left: 16.0, right: 16.0)
                            .onClick({ evt =>
                                this.editingHabit = Option<Habit>.None
                                this.isPresentingEditView = true
                            })
                    }
                    .width(100.percent)
                    .padding(right: 12.0)
                    HabitListView(
                        habits: this.habits,
                        sortingOption: this.sortingOption,
                        isSortingOrderAscending: this.isSortingOrderAscending,
                        onToggleCompletion: { habit: Habit, daysAgo: Int64 =>
                            habit.toggleCompletion(daysAgo)
                            this.dataController.saveHabit(habit)
                            this.refreshHabits()
                        },
                        onDelete: { habit: Habit =>
                            this.dataController.deleteHabit(habit)
                            this.refreshHabits()
                        },
                        onHabitTap: { habit: Habit =>
                            this.selectedHabit = Some(habit)
                            this.isPresentingDetailView = true
                        }
                    )
                    if (this.habits.size == 0) {
                        Column() {
                            Text("还没有习惯")
                                .fontSize(18.0)
                                .fontColor(Color.Gray)
                                .margin(top: 80.0)
                            Text("点击 + 添加新习惯")
                                .fontSize(14.0)
                                .fontColor(Color.Gray)
                                .margin(top: 8.0)
                        }
                        .width(100.percent)
                        .alignItems(HorizontalAlign.Center)
                    }
                }
            }
            .title("Habit")
            .onAppear({ =>
                this.refreshHabits()
            })
        }
    }

    let pageStack: NavPathStack = NavPathStack()

    prop dataController: DataController {
        get() { AppStorageHolder.dataController }
    }

    func refreshHabits(): Unit {
        try {
            this.habits = this.dataController.getAllHabits()
        } catch (_: Exception) {
            this.habits = ArrayList<Habit>()
        }
    }
}
