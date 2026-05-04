/**
 * Created on 2025/8/8
 */
package ohos_app_cangjie_entry.views

import std.math.max
import std.collection.ArrayList

import ohos.base.*
import ohos.component.*

import ohos_app_cangjie_entry.models.*
import ohos_app_cangjie_entry.constants.StyleConstants
import ohos_app_cangjie_entry.viewmodels.TimeLineViewModel
import ohos_app_cangjie_entry.constants.DataConstants

public class TimeLineRenderer {

    public func drawPriceChart(ctx: CanvasRenderingContext2D, params: TimeLineRenderContext) {
        if (params.displayData.isEmpty()) { return }

        let dims = ChartDimensions(StyleConstants.CANVAS_WIDTH, StyleConstants.MAIN_CHART_HEIGHT)
        let helper = ChartDrawingHelper(ctx, dims)

        helper.prepareBackground(5, 5)
        drawPriceLines(ctx, dims, params)
        drawPriceAxes(helper, dims, params)
    }

    public func drawVolumeChart(ctx: CanvasRenderingContext2D, params: TimeLineRenderContext) {
        if (params.displayData.isEmpty()) { return }

        let dims = ChartDimensions(StyleConstants.CANVAS_WIDTH, StyleConstants.VOLUME_CHART_HEIGHT)
        let helper = ChartDrawingHelper(ctx, dims)

        helper.prepareBackground(3, 5)
        drawVolumeBars(ctx, dims, params)
    }

    private func drawPriceAxes(helper: ChartDrawingHelper, dims: ChartDimensions, params: TimeLineRenderContext) {
        let yLabels = ArrayList<(text: String, y: Float64)>()
        let yPercentLabels = ArrayList<(text: String, y: Float64)>()
        let labelsCount = 2
        for (i in 0..labelsCount) {
            let y = dims.paddingTop + (Float64(i) / Float64(labelsCount - 1)) * dims.chartHeight
            let priceValue = params.yAxisMax - (Float64(i) / Float64(labelsCount - 1)) * (params.yAxisMax - params.yAxisMin)
            let percentValue = if (params.yesterdayClose == 0.0) { 0.0 } else { (priceValue / params.yesterdayClose - 1.0) * 100.0 }

            let yOffset = if (i == 0) { 6.0 } else { -6.0 }
            yLabels.append((priceValue.toFixed(2), y + 4.0 + yOffset))
            yPercentLabels.append((percentValue.toPercent(), y + 4.0 + yOffset))
        }
        helper.drawYAxisLabels(yLabels.toArray(), TextAlignStyle.Start, dims.paddingLeft)
        helper.drawYAxisLabels(yPercentLabels.toArray(), TextAlignStyle.End, StyleConstants.CANVAS_WIDTH - dims.paddingRight)

        let bottomY = StyleConstants.MAIN_CHART_HEIGHT - 5.0
        let xLabels = ArrayList<(text: String, x: Float64, align: TextAlignStyle)>()
        xLabels.append((DataConstants.TIME_AXIS_LABELS[0], dims.paddingLeft, TextAlignStyle.Start))
        xLabels.append((DataConstants.TIME_AXIS_LABELS[1], dims.paddingLeft + dims.chartWidth / 2.0, TextAlignStyle.Center))
        xLabels.append((DataConstants.TIME_AXIS_LABELS[2], StyleConstants.CANVAS_WIDTH - dims.paddingRight, TextAlignStyle.End))
        helper.drawXAxisLabels(xLabels.toArray(), bottomY)
    }

    private func drawPriceLines(ctx: CanvasRenderingContext2D, dims: ChartDimensions, params: TimeLineRenderContext) {
        if (params.displayData.isEmpty() || params.yAxisMax - params.yAxisMin <= 0.0) { return }

        let points = mapDataToCanvasPoints(params.displayData, params.totalDataSize, params.yAxisMax - params.yAxisMin, dims, params.yAxisMin)
        if (points.isEmpty()) { return }

        ctx.drawSmoothArea(points, dims.paddingTop + dims.chartHeight, StyleConstants.TIME_LINE_AREA_COLOR, StyleConstants.TIME_LINE_COLOR, 1.0, StyleConstants.SMOOTHING_FACTOR)

        let lastPoint = points[points.size - 1]
        ctx.strokeStyle(StyleConstants.TIME_LINE_DASH_LINE_COLOR)
        ctx.drawLine(dims.paddingLeft, lastPoint[1], dims.paddingLeft + dims.chartWidth, lastPoint[1], dash: StyleConstants.DASH_LINE_STYLE, width: StyleConstants.DASH_LINE_WIDTH)
        ctx.fillStyle(StyleConstants.TIME_LINE_COLOR)
        ctx.drawCircle(lastPoint[0], lastPoint[1], StyleConstants.TIME_LINE_DOT_RADIUS, true)
    }

    private func mapDataToCanvasPoints(displayData: ArrayList<TimeLineDataPoint>, totalPoints: Int64, yRange: Float64, dims: ChartDimensions, yAxisMin: Float64): ArrayList<Array<Float64>> {
        let points = ArrayList<Array<Float64>>()
        for (i in 0..displayData.size) {
            let x = dims.paddingLeft + (Float64(i) / Float64(totalPoints - 1)) * dims.chartWidth
            let y = dims.paddingTop + (1.0 - (displayData[i].price - yAxisMin) / yRange) * dims.chartHeight
            points.append([x, y])
        }
        return points
    }

    private func drawVolumeBars(ctx: CanvasRenderingContext2D, dims: ChartDimensions, params: TimeLineRenderContext) {
        if (params.displayData.isEmpty() || params.yAxisMaxVolume <= 0) { return }

        let totalPoints = params.totalDataSize
        let pointSlotWidth = dims.chartWidth / Float64(max(1, totalPoints - 1))
        let barWidth = pointSlotWidth / 2.0

        for (i in 0..params.displayData.size) {
            let point = params.displayData[i]
            if (point.volume <= 0) { continue }

            let previousPrice = if (i > 0) { params.displayData[i - 1].price } else { params.yesterdayClose }
            ctx.fillStyle(if (point.price >= previousPrice) { StyleConstants.INCREASE_COLOR } else { StyleConstants.DECREASE_COLOR })

            let xCenter = dims.paddingLeft + (Float64(i) / Float64(max(1, totalPoints - 1))) * dims.chartWidth
            let x = xCenter - barWidth / 2.0
            let barHeight = (Float64(point.volume) / Float64(params.yAxisMaxVolume)) * dims.chartHeight
            let finalBarHeight = max(1.0, barHeight)
            let y = dims.paddingTop + dims.chartHeight - finalBarHeight

            ctx.fillRect(x, y, barWidth, finalBarHeight)
        }
    }
}