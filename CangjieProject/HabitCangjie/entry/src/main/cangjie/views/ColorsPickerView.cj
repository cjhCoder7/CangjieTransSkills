package ohos_app_cangjie_entry.views

import kit.ArkUI.*
import ohos.resource.__GenerateResource__
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

/// 颜色选择器视图
@Component
class ColorsPickerView {
    @Prop var selectedColor: HabitColor
    var onColorSelected: (HabitColor) -> Unit = { _ => }

    func build() {
        Column() {
            Text("选择颜色")
                .fontSize(18.0)
                .fontWeight(FontWeight.Bold)
                .margin(top: 16.0, bottom: 16.0)

            Grid() {
                ForEach(allHabitColors, itemGeneratorFunc: { color: HabitColor, idx: Int64 =>
                    GridItem() {
                        this.colorCircle(color)
                    }
                }, keyGeneratorFunc: { color: HabitColor, idx: Int64 => color.resourceName })
            }
            .columnsTemplate("1fr 1fr 1fr")
            .rowsTemplate("1fr 1fr 1fr")
            .width(100.percent)
            .height(260.0)
            .padding(left: 16.0, right: 16.0)
        }
        .width(100.percent)
    }

    @Builder
    func colorCircle(color: HabitColor) {
        Stack() {
            Circle(width: 60.0, height: 60.0)
                .fill(Color(color.colorValue))
            if (this.selectedColor == color) {
                Image(@r(app.media.checkmark))
                    .width(20.0)
                    .height(20.0)
                    .fillColor(Color.White)
            }
        }
        .width(80.0)
        .height(80.0)
        .onClick({ evt => this.onColorSelected(color) })
    }
}
