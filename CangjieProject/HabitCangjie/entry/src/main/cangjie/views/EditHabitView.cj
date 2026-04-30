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

/// 编辑/新增习惯视图
@Component
class EditHabitView {
    @Prop var habit: Option<Habit>
    @State var title: String = ""
    @State var motivation: String = ""
    @State var color: HabitColor = randomHabitColor()
    @State var isPresentingColorsPicker: Bool = false

    var onSave: (Habit) -> Unit = { _ => }
    var onDelete: (Habit) -> Unit = { _ => }
    var onClose: () -> Unit = { => }

    public func aboutToAppear(): Unit {
        if (let Some(h) <- this.habit) {
            this.title = h.title
            this.motivation = h.motivation
            this.color = h.color
        }
    }

    func build() {
        if (this.isPresentingColorsPicker) {
            Column() {
                Row() {
                    Button("返回")
                        .fontColor(Color.Black)
                        .onClick({ evt => this.isPresentingColorsPicker = false })
                    Blank()
                    Text("选择颜色")
                        .fontSize(17.0)
                        .fontWeight(FontWeight.Medium)
                    Blank()
                    Button("返回")
                        .fontColor(Color.Transparent)
                        .backgroundColor(Color.Transparent)
                }
                .width(100.percent)
                .padding(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0)

                ColorsPickerView(
                    selectedColor: this.color,
                    onColorSelected: { c: HabitColor =>
                        this.color = c
                        this.isPresentingColorsPicker = false
                    }
                )
            }
            .width(100.percent)
            .height(100.percent)
            .backgroundColor(Color.White)
        } else {
            Column() {
                // 标题栏
                Row() {
                    Button("关闭")
                        .fontColor(Color.Black)
                        .onClick({ evt => this.onClose() })
                    Blank()
                    Text(if (this.habit.isSome()) { "编辑习惯" } else { "添加新习惯" })
                        .fontSize(17.0)
                        .fontWeight(FontWeight.Medium)
                    Blank()
                    Button("保存")
                        .fontColor(Color.Black)
                        .onClick({ evt => this.save() })
                }
                .width(100.percent)
                .padding(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0)

                Scroll() {
                    Column(space: 0.0) {
                        // 名称输入
                        this.nameSection()
                        // 激励输入
                        this.motivationSection()
                        // 颜色选择
                        this.colorSection()
                        // 删除按钮（仅编辑模式）
                        if (this.habit.isSome()) {
                            Button("删除习惯")
                                .fontColor(Color.Red)
                                .backgroundColor(Color.Transparent)
                                .width(100.percent)
                                .padding(top: 20.0)
                                .onClick({ evt =>
                                    if (let Some(h) <- this.habit) {
                                        this.onDelete(h)
                                    }
                                })
                        }
                    }
                }
                .layoutWeight(1)
            }
            .width(100.percent)
            .height(100.percent)
            .backgroundColor(Color.White)
        }
    }

    @Builder
    func nameSection() {
        Column() {
            Row() {
                Text("名称")
                    .fontSize(12.0)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.Black)
                    .margin(left: 16.0)
                Blank()
            }
            TextInput(placeholder: "读书、冥想等", text: this.title)
                .fontColor(Color.Black)
                .width(100.percent)
                .padding(left: 16.0, right: 16.0)
                .onChange({ value: String => this.title = value })
        }
        .padding(top: 40.0, bottom: 15.0)
    }

    @Builder
    func motivationSection() {
        Column() {
            Row() {
                Text("激励自己")
                    .fontSize(12.0)
                    .fontWeight(FontWeight.Bold)
                    .margin(left: 16.0)
                Blank()
            }
            .margin(bottom: 4.0)
            TextInput(placeholder: Constants.motivationPrompts[0], text: this.motivation)
                .width(100.percent)
                .padding(left: 16.0, right: 16.0)
                .onChange({ value: String => this.motivation = value })
        }
        .padding(top: 8.0)
    }

    @Builder
    func colorSection() {
        Row() {
            Text("颜色")
            Blank()
            Circle(width: 20.0, height: 20.0)
                .fill(Color(this.color.colorValue))
        }
        .width(100.percent)
        .padding(16.0)
        .onClick({ evt => this.isPresentingColorsPicker = true })
    }

    func save(): Unit {
        if (let Some(h) <- this.habit) {
            h.title = this.title
            h.motivation = this.motivation
            h.color = this.color
            this.onSave(h)
        } else {
            let newHabit = Habit(this.title, this.motivation, this.color)
            this.onSave(newHabit)
        }
    }
}
