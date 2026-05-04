/**
 * Created on 2025/2/13
 */
package ohos_app_cangjie_entry.color_picker

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.math.*

//修改色调的滑动条
@Component
public class ColorSlider {
    // 创建渲染上下文的设置，启用抗锯齿
    var settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    // 创建一个2D渲染上下文，使用指定的设置
    var context: CanvasRenderingContext2D = CanvasRenderingContext2D(this.settings)

    @Link
    var hsv: HSV

    func build() {
        Column() {
            // 创建一个居中的堆叠布局
            Stack(Alignment.Center) {
                // 背景层组件
                ColorSliderBackgroundLayer(context: this.context)
                // 滑块层组件
                ColorSliderSliderLayer(hsv: this.hsv)
            }.width(100.percent) // 将堆叠布局的宽度设置为父组件的100%
        }
    }
}

// 滑块层的组件
@Component
class ColorSliderSliderLayer {
    // 创建渲染上下文的设置，启用抗锯齿
    var settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    // 创建一个2D渲染上下文，使用指定的设置
    var context: CanvasRenderingContext2D = CanvasRenderingContext2D(this.settings)
    // canvas的宽度，单位为vp
    var canvasWidth: Int64 = 0
    // canvas的高度，单位为vp
    var canvasHeight: Int64 = 0
    // 圆的半径是高度的一半，即圆的高度和滑块的高度相同
    var radius: Float64 = Float64(this.canvasHeight) / 2.0
    // 圆的结束角度，完整的一圈
    let endAngle: Float64 = Float64.PI * 2.0

    // 链接并监听HSV颜色模型的变化
    @Link
    @Watch[onHsvChange]
    var hsv: HSV

    // 当HSV值变化时调用的方法
    func onHsvChange() {
        // 绘制滑块
        this.drawSlider()
    }

    // 绘制滑块
    func drawSlider() {
        // 计算滑块的水平位置
        let x = Float64(this.hsv.h / 360.0) * (Float64(this.canvasWidth) - this.radius * 2.0) + this.radius
        let areaX: Float64 = min(max(this.radius, x), Float64(this.canvasWidth) - this.radius)
        let y: Float64 = Float64(this.canvasHeight) / 2.0
        // 清空画布
        this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight)

        // 绘制一个圆环，当作滑块
        this.context.beginPath()
        this.context.arc(areaX, y, this.radius - 3.0, 0.0, this.endAngle);
        this.context.closePath();
        this.context.strokeStyle(Color.WHITE)
        this.context.lineWidth(4.5)
        this.context.stroke()
    }

    func build() {
        // 创建一个画布
        Canvas(this.context)
            .width(100.percent) // 将画布宽度设置为父组件的100%
            .height(20) // 设定画布高度为20vp
            .onAreaChange(
                {
                    _, new =>
                    // 更新画布的宽高信息并转换为vp单位
                    this.canvasWidth = Int64(px2vp(Length(new.width, unitType: LengthType.px))?.value ?? 0.0)
                    this.canvasHeight = Int64(px2vp(Length(new.height, unitType: LengthType.px))?.value ?? 0.0)
                    // 半径稍微小一点，让其周围有一点点空隙
                    this.radius = Float64(this.canvasHeight) / 2.0
                    // 初始位置的绘制
                    this.drawSlider()
                }
            )
            // 添加触控事件处理
            .onTouch(
                {
                    event => if (event.touches.size > 0) {
                        // 当触摸事件发生时，更新 HSV 中的 H 值，并重新绘制圆环
                        let touche = event.touches[0]
                        let areaX: Float64 = min(max(this.radius, touche.x), Float64(this.canvasWidth) - this.radius)
                        this.hsv.h = Float16((areaX - this.radius) / (Float64(this.canvasWidth) - this.radius * 2.0) *
                            360.0)
                        // 重新绘制滑块
                        this.drawSlider()
                    }
                })
    }
}

// ColorSlider背景层组件，为了避免背景重绘，直接分成两层
@Component
class ColorSliderBackgroundLayer {
    // 创建渲染上下文的设置，启用抗锯齿
    var settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    // 创建一个2D渲染上下文，使用指定的设置
    var context: CanvasRenderingContext2D = CanvasRenderingContext2D(this.settings)
    // canvas的宽度，单位为vp
    var canvasWidth: Int64 = 0
    // canvas的高度，单位为vp
    var canvasHeight: Int64 = 0
    // 圆的半径是高度的一半，这个半径用来绘制滑动条左右两边的半圆，让滑动条看上去像圆角
    var radius: Float64 = Float64(this.canvasHeight) / 2.0

    // 绘制颜色渐变背景
    func drawGradient() {
        // 如果宽高等于0，说明还没准备好，直接返回
        if (this.canvasWidth == 0 || this.canvasHeight == 0) {
            return
        }
        // 填充左半圆，红色
        this.context.fillStyle(Color(255, 0, 0))
        this.context.beginPath()
        this
            .context
            .arc(this.radius + 1.0, this.radius, this.radius, Float64.PI / 2.0, 3.0 * Float64.PI / 2.0,
                anticlockwise: false)
        this.context.closePath()
        this.context.fill()

        // 创建线性渐变
        var grad = this.context.createLinearGradient(this.radius, 0.0, Float64(this.canvasWidth) - this.radius * 2.0,
            0.0)
        // 设置渐变断点值
        grad.addColorStop(0, Color(255, 0, 0)) // 红色, 0°
        grad.addColorStop(60.0 / 360.0, Color(255, 255, 0)) // 黄色, 60°
        grad.addColorStop(120.0 / 360.0, Color(0, 255, 0)) // 绿色, 120°
        grad.addColorStop(180.0 / 360.0, Color(0, 255, 255)) // 青色, 180°
        grad.addColorStop(240.0 / 360.0, Color(0, 0, 255)) // 蓝色, 240°
        grad.addColorStop(300.0 / 360.0, Color(255, 0, 255)) // 紫色, 300°
        grad.addColorStop(1, Color(255, 0, 0)) // 回到红色, 360° (等同于 0°)
        this.context.fillStyle(grad)
        // 填充渐变矩形
        this.context.fillRect(this.radius, 0.0, Float64(this.canvasWidth) - this.radius * 2.0,
            Float64(this.canvasHeight))

        // 填充右半圆，红色
        this.context.fillStyle(Color(255, 0, 0))
        this.context.beginPath()
        this
            .context
            .arc(Float64(this.canvasWidth) - this.radius - 1.0, this.radius, this.radius, Float64.PI / 2.0,
                3.0 * Float64.PI / 2.0, anticlockwise: true)
        this.context.closePath()
        this.context.fill()
    }

    func build() {
        Canvas(this.context)
            .width(100.percent) // 将画布宽度设置为父组件的100%
            .height(20) // 设定画布高度为20
            .onAreaChange(
                {
                    _, new =>
                    // 更新画布的宽高信息并转换为vp单位
                    this.canvasWidth = Int64(px2vp(Length(new.width, unitType: LengthType.px))?.value ?? 0.0)
                    this.canvasHeight = Int64(px2vp(Length(new.height, unitType: LengthType.px))?.value ?? 0.0)
                    // 更新圆的半径
                    this.radius = Float64(this.canvasHeight) / 2.0
                    // 绘制背景渐变
                    this.drawGradient()
                }
            )
            .borderRadius(12.vp) // 设置圆角半径
    }
}
