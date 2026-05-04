package ohos_app_cangjie_entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.color_picker.*

@Entry
@Component
class EntryView {
    // 定义一个状态变量，用于存储“你好，仓颉”文本的颜色
    @State
    var helloCangjieFontColor: UInt32 = 0x000000; // 初始颜色为黑色

    // 创建一个自定义对话框控制器，用于管理颜色选择对话框
    let colorPickerController: CustomDialogController = CustomDialogController(
        CustomDialogControllerOptions(
            // 使用ColorPickerDialog作为对话框的内容
            builder: ColorPickerDialog(
                // 传入当前的颜色值
                colorValue: this.helloCangjieFontColor,
                // 当用户选择颜色时，更新helloCangjieFontColor状态变量
                onColorSeleted: {
                    color => this.helloCangjieFontColor = color
                }
            ),
            autoCancel: false // 设置对话框不会自动取消
        )
    )

    // 构建UI界面
    func build() {
        Column {
            // 显示“你好，仓颉”文本，并使用helloCangjieFontColor变量设置字体颜色
            Text("你好，仓颉").fontColor(this.helloCangjieFontColor).fontSize(32)
            // 创建一个按钮，点击时打开颜色选择对话框
            Button("更换颜色").onClick {
                evt => this.colorPickerController.open()
            }.margin(top: 32) // 设置按钮的上边距为32
        }.width(100.percent).height(100.percent).justifyContent(FlexAlign.Center) // 设置列布局的宽度和高度为100%，并居中对齐
    }
}