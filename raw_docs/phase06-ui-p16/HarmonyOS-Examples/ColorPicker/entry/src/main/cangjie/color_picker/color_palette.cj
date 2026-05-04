/**
 * Created on 2024/12/23
 * 色盘组件
 */
package ohos_app_cangjie_entry.color_picker

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.math.*
import encoding.hex.*

// 色盘组件
@Component
public class ColorPalette {
    // 渲染上下文设置，启用抗锯齿
    var settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    // 2D 渲染上下文
    var context: CanvasRenderingContext2D = CanvasRenderingContext2D(this.settings)

    // 链接到外部的 HSV 颜色值
    @Link
    var hsv: HSV

    // 构建色盘组件
    func build() {
        Stack() {
            // 背景层，显示颜色渐变
            ColorPaletteBackgroundLayer(context: this.context, hsv: this.hsv)
            // 选取层，显示当前选中的颜色点
            ColorPalettePickerLayer(hsv: this.hsv)
        }.margin(top: 16).width(100.percent) // 设置上边距和宽度
    }
}

// 色盘的选取层组件
@Component
class ColorPalettePickerLayer {
    // 渲染上下文设置，启用抗锯齿
    var settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    // 2D 渲染上下文
    var context: CanvasRenderingContext2D = CanvasRenderingContext2D(this.settings)
    // canvas 的宽度，单位 vp
    var canvasWidth: Float64 = 0.0
    // canvas 的高度，单位 vp
    var canvasHeight: Float64 = 0.0
    // 圆环的半径
    var radius: Float64 = 6.0
    // 圆环的结束角度（360度）
    let endAngle: Float64 = Float64.PI * 2.0

    // 链接到外部的 HSV 颜色值，并监听变化
    @Link
    @Watch[estimatePosition]
    var hsv: HSV

    // 当 HSV 变化时，重新计算圆环位置
    func estimatePosition() {
        drawCircle()
    }

    // 绘制圆环
    func drawCircle() {
        // 根据 HSV 中的 S（饱和度）和 V（亮度）计算圆环的位置
        let x = Float64(hsv.s) * this.canvasWidth
        let y = (1.0 - Float64(hsv.v)) * this.canvasHeight
        // 限制圆环位置在 canvas 范围内
        let areaX: Float64 = min(max(0.0, x), this.canvasWidth)
        let areaY: Float64 = min(max(0.0, y), this.canvasHeight)

        // 清空画布
        this.context.clearRect(0.0, 0.0, this.canvasWidth, this.canvasHeight)

        // 绘制黑色圆环作为描边
        this.context.beginPath()
        this.context.arc(areaX, areaY, this.radius, 0.0, this.endAngle)
        this.context.closePath()
        this.context.strokeStyle(Color.BLACK) // 设置描边颜色为黑色
        this.context.lineWidth(5) // 设置描边宽度
        this.context.stroke()

        // 绘制白色圆环
        this.context.arc(areaX, areaY, this.radius, 0.0, this.endAngle)
        this.context.closePath()
        this.context.strokeStyle(Color.WHITE) // 设置描边颜色为白色
        this.context.lineWidth(4) // 设置描边宽度
        this.context.stroke()
    }

    // 构建选取层组件
    func build() {
        Canvas(this.context)
            .width(100.percent) // 设置宽度为 100%
            .height(100.percent) // 设置高度为 100%
            .onAreaChange(
                {
                    // 当 canvas 区域变化时，更新宽度和高度，并重新绘制圆环
                    _, new =>
                    this.canvasWidth = px2vp(Length(new.width, unitType: LengthType.px))?.value ?? 0.0
                    this.canvasHeight = px2vp(Length(new.height, unitType: LengthType.px))?.value ?? 0.0
                    this.drawCircle()
                }
            )
            .onTouch(
                {
                    // 当触摸事件发生时，更新 HSV 中的 S 和 V 值，并重新绘制圆环
                    event => if (event.touches.size > 0) {
                        let touche = event.touches[0]
                        let areaX: Float64 = min(max(0.0, touche.x), this.canvasWidth)
                        let areaY: Float64 = min(max(0.0, touche.y), this.canvasHeight)
                        hsv.s = Float16(areaX / this.canvasWidth) // 更新饱和度
                        hsv.v = 1.0 - Float16(areaY / this.canvasHeight) // 更新亮度
                        this.drawCircle()
                    }
                })
    }
}

// 色盘的背景层组件
@Component
class ColorPaletteBackgroundLayer {
    // 渲染上下文设置，启用抗锯齿
    var settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    // 2D 渲染上下文
    var context: CanvasRenderingContext2D = CanvasRenderingContext2D(this.settings)
    // canvas 的宽度，单位 vp
    var canvasWidth: Float64 = 0.0
    // canvas 的高度，单位 vp
    var canvasHeight: Float64 = 0.0

    // 外部的 HSV 颜色值，并监听变化
    @Prop
    @Watch[onHsvChange]
    var hsv: HSV

    // 当 HSV 变化时，重新绘制背景渐变
    func onHsvChange() {
        this.drawGradient()
    }

    // 绘制背景渐变
    func drawGradient() {
        // 根据 HSV 中的 H（色相）生成基础颜色
        let baseColor: UInt32 = ColorUtils.hsvToRgb(this.hsv.h, 1.0, 1.0)
        // 清空画布
        this.context.clearRect(0.0, 0.0, this.canvasWidth, this.canvasHeight)

        // 创建水平渐变（从左到右）
        var horizontalGrad = this.context.createLinearGradient(0.0, 0.0, this.canvasWidth, 0.0)
        horizontalGrad.addColorStop(0, Color(0xFF, 0xFF, 0xFF)); // 起始颜色为白色
        horizontalGrad.addColorStop(1, Color(baseColor)); // 结束颜色为基础颜色
        this.context.fillStyle(horizontalGrad)
        // 填充渐变矩形
        this.context.fillRect(0.0, 0.0, this.canvasWidth, this.canvasHeight)

        // 创建垂直渐变（从上到下）
        var bwGradient = this.context.createLinearGradient(0.0, 0.0, 0.0, this.canvasHeight)
        bwGradient.addColorStop(0, Color(0xff, 0xff, 0xff, alpha: 0.0)); // 起始颜色为透明白色
        bwGradient.addColorStop(1, Color(0, 0, 0, alpha: 1.0)); // 结束颜色为黑色
        this.context.fillStyle(bwGradient)
        // 填充渐变矩形
        this.context.fillRect(0.0, 0.0, this.canvasWidth, this.canvasHeight)
    }

    // 构建背景层组件
    func build() {
        Canvas(this.context)
            .width(100.percent) // 设置宽度为 100%
            .height(100.percent) // 设置高度为 100%
            .onAreaChange(
                {
                    // 当 canvas 区域变化时，更新宽度和高度，并重新绘制渐变
                    _, new =>
                    this.canvasWidth = px2vp(Length(new.width, unitType: LengthType.px))?.value ?? 0.0
                    this.canvasHeight = px2vp(Length(new.height, unitType: LengthType.px))?.value ?? 0.0
                    this.drawGradient()
                }
            )
            .borderRadius(12.vp) // 设置圆角
    }
}