/**
 * Created on 2025/8/8
 */
package ohos_app_cangjie_entry.views

import std.math.min
import std.collection.ArrayList

import ohos.base.*
import ohos.component.*

import ohos_app_cangjie_entry.models.*
import ohos_app_cangjie_entry.constants.StyleConstants

public class KLineRenderer {

    public func drawKLineChart(ctx: CanvasRenderingContext2D, params: KLineRenderContext) {
        if (params.maxPrice <= params.minPrice) { return }

        let dims = ChartDimensions(params.totalWidth, StyleConstants.MAIN_CHART_HEIGHT)
        let helper = ChartDrawingHelper(ctx, dims)

        helper.prepareBackground(5, 1)
        drawKLineAxes(ctx, dims, params)
        drawCandlesAndMA(ctx, dims, params)
        drawPriceAnnotations(ctx, dims, params)
    }

    public func drawVolumeChart(ctx: CanvasRenderingContext2D, params: KLineRenderContext) {
        if (params.maxVolume <= 0) { return }

        let dims = ChartDimensions(params.totalWidth, StyleConstants.VOLUME_CHART_HEIGHT)
        let helper = ChartDrawingHelper(ctx, dims)

        helper.prepareBackground(3, 1)
        drawVolumeBars(ctx, dims, params)
    }

    private func drawCandlesAndMA(ctx: CanvasRenderingContext2D, dims: ChartDimensions, params: KLineRenderContext) {
        let priceRange = params.maxPrice - params.minPrice
        let ma5Points = ArrayList<Array<Float64>>()

        let priceToY: (Float64) -> Float64 = { p => dims.paddingTop + (1.0 - (p - params.minPrice) / priceRange) * dims.chartHeight }

        for (candleInfo in params.visibleCandles) {
            let pointWrapper = candleInfo.pointWrapper
            let point = pointWrapper.data
            let x = dims.paddingLeft + Float64(candleInfo.index) * StyleConstants.CANVAS_POINT_SPACING + StyleConstants.CANVAS_POINT_SPACING / 2.0

            let color = if (point.close >= point.open) { StyleConstants.INCREASE_COLOR } else { StyleConstants.DECREASE_COLOR }
            ctx.drawCandle(x, priceToY(point.high), priceToY(point.low), priceToY(point.open), priceToY(point.close), StyleConstants.KLINE_CANDLE_WIDTH, color)

            if (pointWrapper.ma5 > 0.0) {
                ma5Points.append([x, priceToY(pointWrapper.ma5)])
            }
        }

        drawMA5Line(ctx, ma5Points)
    }

    private func drawMA5Line(ctx: CanvasRenderingContext2D, points: ArrayList<Array<Float64>>) {
        if(points.size < 2) { return }
        ctx.strokeStyle(StyleConstants.MA5_COLOR)
        ctx.lineWidth(1.5)
        ctx.beginPath()
        ctx.createSmoothCurvePath(points, StyleConstants.SMOOTHING_FACTOR)
        ctx.stroke()
    }

    private func drawKLineAxes(ctx: CanvasRenderingContext2D, dims: ChartDimensions, params: KLineRenderContext) {
        drawKLineYAxis(ctx, dims, params)
        drawKLineXAxisAndGrid(ctx, dims, params)
    }

    private func drawKLineYAxis(ctx: CanvasRenderingContext2D, dims: ChartDimensions, params: KLineRenderContext) {
        ctx.font(size: StyleConstants.AXIS_LABEL_FONT_SIZE, family: "sans-serif")
        ctx.fillStyle(StyleConstants.GRAY_COLOR)
        let labelsCount = 2
        let priceStep = (params.maxPrice - params.minPrice) / Float64(labelsCount - 1)
        for (i in 0..labelsCount) {
            let y = dims.paddingTop + (Float64(i) / Float64(labelsCount - 1)) * dims.chartHeight
            let priceValue = params.maxPrice - (Float64(i) * priceStep)

            let yOffset = if (i == 0) { 6.0 } else { -6.0 }
            ctx.drawText(priceValue.toFixed(2), dims.paddingLeft + params.scrollOffset, y + 4.0 + yOffset, TextAlignStyle.Start)
        }
    }

    private func drawKLineXAxisAndGrid(ctx: CanvasRenderingContext2D, dims: ChartDimensions, params: KLineRenderContext) {
        ctx.font(size: StyleConstants.AXIS_LABEL_FONT_SIZE, family: "sans-serif")

        let startIndex = params.startIndex
        let pointSpacing = StyleConstants.CANVAS_POINT_SPACING
        let viewportWidth = StyleConstants.CANVAS_WIDTH
        let indexSpacing = Int64(viewportWidth / pointSpacing)
        let endIndex = min(params.fullData.size, startIndex + indexSpacing + 2)

        var lastDrawnMonthYear = ""
        let viewportCenter = params.scrollOffset + viewportWidth / 2.0
        let textPaddingX: Float64 = 4.0

        for (i in startIndex..endIndex) {
            if (i >= params.fullData.size) { continue }

            let timestamp = params.fullData[i].data.timestamp
            if (timestamp.size < 6) { continue }

            let currentMonthYear = timestamp[0..6]
            if (i == startIndex) { lastDrawnMonthYear = currentMonthYear }
            if (currentMonthYear == lastDrawnMonthYear) { continue }

            let x = dims.paddingLeft + Float64(i) * pointSpacing
            ctx.strokeStyle(StyleConstants.GRID_LINE_COLOR)
            ctx.lineWidth(1.0)
            ctx.drawLine(x, dims.paddingTop, x, dims.paddingTop + dims.chartHeight)

            let labelText = "${timestamp[0..4]}-${timestamp[4..6]}"
            let textAlign = if (x < viewportCenter) { TextAlignStyle.Start } else { TextAlignStyle.End }
            let textX = if (x < viewportCenter) { x + textPaddingX } else { x - textPaddingX }

            ctx.fillStyle(StyleConstants.GRAY_COLOR)
            ctx.textAlign(textAlign)
            ctx.fillText(labelText, textX, StyleConstants.MAIN_CHART_HEIGHT - 5.0)

            lastDrawnMonthYear = currentMonthYear
        }
    }

    private func drawVolumeBars(ctx: CanvasRenderingContext2D, dims: ChartDimensions, params: KLineRenderContext) {
        for (barInfo in params.visibleBars) {
            let point = barInfo.data
            let x = dims.paddingLeft + Float64(barInfo.index) * StyleConstants.CANVAS_POINT_SPACING + (StyleConstants.CANVAS_POINT_SPACING - StyleConstants.KLINE_CANDLE_WIDTH) / 2.0

            let barHeight = (Float64(point.volume) / Float64(params.maxVolume)) * dims.chartHeight
            let y = dims.paddingTop + dims.chartHeight - barHeight

            ctx.fillStyle(if (point.close >= point.open) { StyleConstants.INCREASE_COLOR } else { StyleConstants.DECREASE_COLOR })
            ctx.fillRect(x, y, StyleConstants.KLINE_CANDLE_WIDTH, barHeight)
        }
    }

    private func drawPriceAnnotations(ctx: CanvasRenderingContext2D, dims: ChartDimensions, params: KLineRenderContext) {
        if (params.highPricePointIndex < 0 || params.lowPricePointIndex < 0 || params.fullData.isEmpty()) {
            return
        }
        let priceRange = params.maxPrice - params.minPrice
        if (priceRange <= 0.0) { return }

        let highPointIndex = params.highPricePointIndex
        let highPointWrapper = params.fullData[highPointIndex]
        let highPointValue = highPointWrapper.data.high
        let highX = dims.paddingLeft + Float64(highPointIndex) * StyleConstants.CANVAS_POINT_SPACING + StyleConstants.CANVAS_POINT_SPACING / 2.0
        let highY = dims.paddingTop + (1.0 - (highPointValue - params.minPrice) / priceRange) * dims.chartHeight
        drawAnnotation(ctx, highPointValue, highX, highY, true, params)

        let lowPointIndex = params.lowPricePointIndex
        let lowPointWrapper = params.fullData[lowPointIndex]
        let lowPointValue = lowPointWrapper.data.low
        let lowX = dims.paddingLeft + Float64(lowPointIndex) * StyleConstants.CANVAS_POINT_SPACING + StyleConstants.CANVAS_POINT_SPACING / 2.0
        let lowY = dims.paddingTop + (1.0 - (lowPointValue - params.minPrice) / priceRange) * dims.chartHeight
        drawAnnotation(ctx, lowPointValue, lowX, lowY, false, params)
    }

    private func drawAnnotation(ctx: CanvasRenderingContext2D, value: Float64, pointX: Float64, pointY: Float64, isHigh: Bool, params: KLineRenderContext) {
        let viewportCenter = params.scrollOffset + StyleConstants.CANVAS_WIDTH / 2.0
        let isLeftOfCenter = pointX < viewportCenter

        let text = value.toFixed(2)
        let lineLengthX: Float64 = 25.0
        let lineLengthY: Float64 = 15.0
        let textPaddingX: Float64 = 5.0

        ctx.strokeStyle(StyleConstants.ANNOTATION_LINE_COLOR)
        ctx.fillStyle(StyleConstants.GRAY_COLOR)
        ctx.font(size: StyleConstants.ANNOTATION_FONT_SIZE, family: "sans-serif")
        ctx.lineWidth(1.0)

        let xDirection = if (isLeftOfCenter) { 1.0 } else { -1.0 }
        let yDirection = if (isHigh) { -1.0 } else { 1.0 }

        let lineEndX = pointX + lineLengthX * xDirection
        let lineEndY = pointY + lineLengthY * yDirection

        ctx.beginPath()
        ctx.moveTo(pointX, pointY)
        ctx.lineTo(lineEndX, lineEndY)
        ctx.stroke()

        ctx.textAlign(if (isLeftOfCenter) { TextAlignStyle.Start } else { TextAlignStyle.End })
        let textX = lineEndX + textPaddingX * xDirection
        let textY = if (isHigh) { lineEndY } else { lineEndY + 14.0 }

        ctx.fillText(text, textX, textY)
    }
}