/**
 * Created on 2024/9/9
 */
package ohos_app_cangjie_entry.utils

import ohos.base.*
import ohos.component.*
import std.math.*
import std.time.DateTime

public class Clock {
    var hour: Float64 = 0.0
    var minute: Float64 = 0.0
    var second: Float64 = 0.0
    let radius: Float64

    public Clock(let context: CanvasRenderingContext2D,
        let width: Float64) { radius = width / 2.0 }

    public func draw(time: DateTime) {
        hour = Float64(time.hour)
        minute = Float64(time.minute)
        second = Float64(time.second)

        context.save()
        background()
        context.translate(radius, radius) // 以下内容绘制，需要以画布中心为坐标原点
        frame()
        cursor()
        center()
        text(time.toString('HH:mm:ss'))
        context.restore()
    }

    // 绘制渐变背景
    func background() {
        let grad = context.createRadialGradient(radius, radius, radius - 32.0, radius, radius, radius)
        grad.addColorStop(0.0, Color.WHITE)
        grad.addColorStop(0.9, 0xEEEEEE)
        grad.addColorStop(1.0, Color.WHITE)
        context.fillStyle(grad)
        context.fillRect(0.0, 0.0, width, width)
    }

    // 绘制边框与刻度
    func frame() {
        context.save()
        // 边框
        context.lineWidth(6.0)
        context.beginPath()
        context.strokeStyle(0xffffff)
        context.arc(0.0, 0.0, radius - 5.0, 0.0, 2.0 * Float64.PI, anticlockwise: false)
        context.stroke()

        // 小时数字
        context.font(size: 40.px)
        context.textAlign(TextAlignStyle.Center)
        context.textBaseline(TextBaseline.Middle)
        context.fillStyle(0x000000)
        for (hour in 1..=12) {
            let rad = 2.0 * Float64.PI / 12.0 * Float64(hour - 3)
            let x = cos(rad) * (radius - 38.0)
            let y = sin(rad) * (radius - 38.0)
            context.fillText(hour.toString(), x, y)
        }

        // 刻度
        for (i in 0..60) {
            let rad = 2.0 * Float64.PI / 60.0 * Float64(i)
            let x = cos(rad) * (radius - 12.0)
            let y = sin(rad) * (radius - 12.0)
            context.beginPath()
            context.moveTo(x, y)
            if (i % 5 == 0) {
                let x = cos(rad) * (radius - 20.0)
                let y = sin(rad) * (radius - 20.0)
                context.strokeStyle(0x000000)
                context.lineWidth(2.0)
                context.lineTo(x, y)
            } else {
                let x = cos(rad) * (radius - 18.0)
                let y = sin(rad) * (radius - 18.0)
                context.strokeStyle(0xCCCCCC)
                context.lineWidth(1.0)
                context.lineTo(x, y)
            }
            context.stroke()
        }
        context.restore()
    }

    // 绘制指针
    func cursor() {
        let hourAngle = 2.0 * Float64.PI / 12.0 * (hour + minute / 60.0)
        let minuteAngle = 2.0 * Float64.PI / 60.0 * minute
        let secondAngle = 2.0 * Float64.PI / 60.0 * second
        for (params in [(8.0, hourAngle, 0u32, 0.5),
                        (5.0, minuteAngle, 0u32, 0.8),
                        (2.0, secondAngle, 0x0055FFu32, 0.9)]) {
            context.save()
            context.beginPath()
            context.lineWidth(params[0])
            context.lineCap(LineCapStyle.Round)
            context.rotate(params[1])
            context.moveTo(0, 10)
            context.strokeStyle(params[2])
            context.lineTo(0.0, -radius * params[3])
            context.stroke()
            context.restore()
        }
    }

    // 绘制中心点
    func center() {
        context.save()
        context.beginPath()
        context.fillStyle(0x0055ff)
        context.arc(0.0, 0.0, 4.0, 0.0, 2.0 * Float64.PI, anticlockwise: false)
        context.fill()
        context.restore()
    }

    // 绘制时间文本
    func text(time: String) {
        context.save()
        context.beginPath()
        context.font(size: 90.px)
        context.textAlign(TextAlignStyle.Center)
        context.textBaseline(TextBaseline.Middle)
        context.fillStyle(0x000)
        context.fillText(time, 0.0, radius + 80.0)
        context.restore()
    }
}