/**
 * Created on 2025/8/6
 */
package ohos_app_cangjie_entry.views

import std.math.*
import std.format.*
import std.collection.ArrayList

import ohos.base.*
import ohos.component.*

import ohos_app_cangjie_entry.models.ChartDimensions
import ohos_app_cangjie_entry.constants.StyleConstants

extend CanvasRenderingContext2D {
    func drawLine(x1: Float64, y1: Float64, x2: Float64, y2: Float64, dash!: Array<Float64> = [0.0, 0.0], width!: Float64 = 1.0) {
        this.lineWidth(width)
        this.lineDash(dash)
        this.beginPath()
        this.moveTo(x1, y1)
        this.lineTo(x2, y2)
        this.stroke()
        this.lineWidth(1)
        this.lineDash([0, 0])
    }

    func drawCircle(x: Float64, y: Float64, radius: Float64, isFill: Bool) {
        this.beginPath()
        this.arc(x, y, radius, 0.0, 6.283) // 2 * PI
        if (isFill) {
            this.fill()
        } else {
            this.stroke()
        }
    }

    func drawText(text: String, x: Float64, y: Float64, align: TextAlignStyle) {
        this.textAlign(align)
        this.fillText(text, x, y)
    }

    func drawGrid(dims: ChartDimensions, rows: Int64, cols: Int64) {
        this.strokeStyle(StyleConstants.GRID_LINE_COLOR)
        if (rows > 1) {
            for (i in 0..rows) {
                let y = dims.paddingTop + (Float64(i) / Float64(rows - 1)) * dims.chartHeight
                let isDashed = (i == (rows - 1) / 2)
                this.drawLine(dims.paddingLeft, y, dims.paddingLeft + dims.chartWidth, y,
                    dash: if (isDashed) { StyleConstants.DASH_LINE_STYLE } else { [0.0, 0.0] },
                    width: if (isDashed) { StyleConstants.DASH_LINE_WIDTH } else { 1.0 })
            }
        }
        if (cols > 1) {
            for (i in 0..cols) {
                let x = dims.paddingLeft + (Float64(i) / Float64(cols - 1)) * dims.chartWidth
                if (i > 0 && i < cols - 1) {
                    this.drawLine(x, dims.paddingTop, x, dims.paddingTop + dims.chartHeight)
                }
            }
        }
    }

    func drawSmoothArea(points: ArrayList<Array<Float64>>, bottomY: Float64, areaColor: Color, lineColor: Color, lineWidth: Float64, smoothing: Float64) {
        if (points.isEmpty()) { return }

        this.fillStyle(areaColor)
        this.beginPath()
        this.createSmoothCurvePath(points, smoothing)
        this.lineTo(points[points.size - 1][0], bottomY)
        this.lineTo(points[0][0], bottomY)
        this.closePath()
        this.fill()

        this.strokeStyle(lineColor)
        this.lineWidth(lineWidth)
        this.beginPath()
        this.createSmoothCurvePath(points, smoothing)
        this.stroke()
    }

    func drawCandle(x: Float64, yHigh: Float64, yLow: Float64, yOpen: Float64, yClose: Float64, width: Float64, color: Color) {
        this.strokeStyle(color)
        this.fillStyle(color)
        this.lineWidth(1.0)

        this.beginPath()
        this.moveTo(x, yHigh)
        this.lineTo(x, yLow)
        this.stroke()

        let bodyTop = min(yOpen, yClose)
        let bodyHeight = abs(yOpen - yClose)
        this.fillRect(x - width / 2.0, bodyTop, width, max(1.0, bodyHeight))
    }

    func createSmoothCurvePath(points: ArrayList<Array<Float64>>, smoothing: Float64) {
        if (points.size < 2) {
            if (!points.isEmpty()) {
                this.moveTo(points[0][0], points[0][1])
                this.lineTo(points[0][0], points[0][1])
            }
            return
        }

        this.moveTo(points[0][0], points[0][1])
        for (i in 0..points.size - 1) {
            let p0 = if (i > 0) { points[i - 1] } else { points[i] }
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = if (i < points.size - 2) { points[i + 2] } else { p2 }

            let cp1x = p1[0] + (p2[0] - p0[0]) / smoothing
            let cp1y = p1[1] + (p2[1] - p0[1]) / smoothing
            let cp2x = p2[0] - (p3[0] - p1[0]) / smoothing
            let cp2y = p2[1] - (p3[1] - p1[1]) / smoothing

            this.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, p2[0], p2[1])
        }
    }
}

extend ContainerBase {
    func cardStyle() {
        this.padding(10)
            .borderRadius(10)
            .backgroundColor(Color.WHITE)
            .width(StyleConstants.FULL_WIDTH)
    }
}

extend Text {
    func wordStyle() {
        this.fontSize(12)
            .fontColor(StyleConstants.GRAY_COLOR)
    }

    func numberStyle(color!: Color = Color.BLACK, size!: Int64 = 12) {
        this.fontSize(size)
            .fontColor(color)
            .fontWeight(FontWeight.Medium)
    }

    func tagStyle(bgColor: Color, ftColor: Color) {
        this.padding(3)
            .fontSize(12)
            .borderRadius(3)
            .fontColor(ftColor)
            .backgroundColor(bgColor)
    }

    func switcherStyle(on: Bool) {
        this.fontSize(12)
            .borderRadius(5)
            .fontWeight(FontWeight.Medium)
            .padding(left: 6, right: 6, top: 3, bottom: 3)
            .fontColor(if (on) { Color(0x0078fd) } else { StyleConstants.GRAY_COLOR })
            .backgroundColor(if (on) { Color.WHITE } else { Color(0xeeeeee) })
    }
}

extend Float64 {
    func toFixed(digits: Int64): String {
        "${this.format(".2")}"
    }

    func toPercent(): String {
        "${if (this > 0.0) { "+" } else { "" }}${this.format(".2")}%"
    }
}