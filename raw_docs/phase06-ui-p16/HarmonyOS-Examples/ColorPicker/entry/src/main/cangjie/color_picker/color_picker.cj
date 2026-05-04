/**
 * Created on 2024/12/22
 * 颜色选择框组件
 */
package ohos_app_cangjie_entry.color_picker

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import encoding.hex.*

// 颜色选择框组件
@Component
public class ColorPicker {
    // 标记当前是否为输入状态
    var isInput: Bool = true

    // 链接到外部的颜色值（UInt32 格式）
    @Link
    var colorValue: UInt32

    // 颜色值的十六进制字符串表示，并监听变化
    @State
    @Watch[onColorStrChange]
    var colorStr: String = ""

    // HSV 颜色值，并监听变化
    @State
    @Watch[onHsvChange]
    var hsv: HSV = HSV()

    // 当 colorStr 变化时的回调
    func onColorStrChange() {
        this.isInput = false // 标记为非输入状态
    }

    // 当 hsv 变化时的回调
    func onHsvChange() {
        // 将 HSV 转换为 RGB 颜色值
        this.colorValue = ColorUtils.hsvToRgb(this.hsv.h, this.hsv.s, this.hsv.v)
        // 将 RGB 颜色值转换为十六进制字符串
        this.colorStr = toHexString(
            [
                UInt8(this.colorValue >> 16 & 0xFF), // 提取红色分量
                UInt8(this.colorValue >> 8 & 0xFF),  // 提取绿色分量
                UInt8(this.colorValue & 0xFF)         // 提取蓝色分量
            ]
        )
    }

    // 根据输入的十六进制字符串更新颜色值
    func updateColorFromInput(colorStr: String) {
        // 如果输入的长度不是 6，直接返回
        if (colorStr.size != 6) {
            return
        }
        // 解析红色分量
        let rInt: Byte = fromHexString(colorStr[0..2])?[0] ?? 0
        // 解析绿色分量
        let gInt: Byte = fromHexString(colorStr[2..4])?[0] ?? 0
        // 解析蓝色分量
        let bInt: Byte = fromHexString(colorStr[4..6])?[0] ?? 0

        // 将 RGB 分量打包为 UInt32 颜色值
        this.colorValue = ColorUtils.packRGB(rInt, gInt, bInt)

        // 将 RGB 颜色值转换为 HSV
        this.hsv = ColorUtils.rgbToHsv(this.colorValue)
    }

    // 构建颜色选择框组件
    func build() {
        Column() {
            // 第一行：显示颜色块和输入框
            Row() {
                // 颜色块，显示当前颜色
                Row().height(100.percent).layoutWeight(1).backgroundColor(this.colorValue)
                // 显示 "#" 符号
                Text("#").margin(left: 12)
                // 输入框，用于输入十六进制颜色值
                TextInput(text: this.colorStr.toAsciiUpper())
                    .width(96)
                    .onChange({
                        str => if (isInput) {
                            // 如果是输入状态，更新颜色值
                            this.updateColorFromInput(str)
                        } else {
                            // 否则重置为输入状态
                            isInput = true
                        }
                    })
            }.margin(top: 16).height(32)

            // 色盘组件
            Column() {
                ColorPalette(hsv: this.hsv)
            }.layoutWeight(1)

            // 添加间隔
            Row().height(12)

            // 颜色滑块组件
            ColorSlider(hsv: this.hsv)
        }.onAppear {
            // 当组件出现时，初始化 HSV 值
            => this.hsv = ColorUtils.rgbToHsv(this.colorValue)
        }
    }
}

// 颜色选择对话框组件
@CustomDialog
public class ColorPickerDialog {
    // 对话框控制器
    var controller: Option<CustomDialogController> = Option.None

    // 颜色选择回调函数
    var onColorSeleted: (color: UInt32) -> Unit

    // 当前选择的颜色值
    @State
    var colorValue: UInt32 = 0x000000

    // 构建颜色选择对话框
    func build() {
        Scroll() {
            Column() {
                // 标题
                Text("选择颜色")
                    .fontWeight(FontWeight.Bold)
                    .width(100.percent)
                    .textAlign(TextAlign.Center)
                    .alignSelf(ItemAlign.Center)
                // 颜色选择框
                Column() {
                    ColorPicker(colorValue: this.colorValue)
                }.layoutWeight(1)
                // 底部按钮
                Row() {
                    // 取消按钮
                    Button('取消').shape(ShapeType.Capsule).onClick {
                        evt => controller?.close()
                    }
                    // 确认按钮
                    Button('确认')
                        .margin(left: 12, right: 12)
                        .shape(ShapeType.Capsule)
                        .onClick {
                            evt =>
                            // 触发颜色选择回调
                            this.onColorSeleted(colorValue)
                            // 关闭对话框
                            controller?.close()
                        }
                }.margin(top: 12).width(100.percent).justifyContent(FlexAlign.End)
            }.margin(16)
        }
    }
}