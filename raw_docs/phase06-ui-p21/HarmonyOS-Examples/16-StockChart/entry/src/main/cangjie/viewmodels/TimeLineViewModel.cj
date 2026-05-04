/**
 * Created on 2025/8/5
 */
package ohos_app_cangjie_entry.viewmodels

import std.math.*
import std.format.*
import std.sync.Timer
import std.time.Duration
import std.collection.HashMap

import ohos.state_manage.*
import ohos.concurrency.launch
import ohos.state_macro_manage.*

import ohos_app_cangjie_entry.models.*
import ohos_app_cangjie_entry.constants.StyleConstants
import ohos_app_cangjie_entry.services.ChartDataServices

@Observed
public class TimeLineViewModel {
    @Publish public var displayNumberData: DisplayNumberData = DisplayNumberData()
    @Publish public var subtitle: String = "未开盘"

    public var renderContext: TimeLineRenderContext = TimeLineRenderContext()

    private var updateTimer: Option<Timer>             = Option.None
    private var latestPoint: Option<TimeLineDataPoint> = Option.None
    private var dataService: Option<ChartDataServices> = Option.None
    private let onChartDataChange: HashMap<String, ()->Unit> = HashMap<String, ()->Unit>()

    public func addRedrawCallback(str: String, callback: () -> Unit) {
        onChartDataChange[str] = callback
    }

    public func initialize(dataService: ChartDataServices) {
        this.dataService = Some(dataService)
    }

    public func startUpdating() {
        match(dataService) {
            case Some(service) =>
                subtitle = "数据加载中..."
                renderContext.fullData = service.loadTimeLineData()
                renderContext.totalDataSize = renderContext.fullData.size

                if (renderContext.totalDataSize > 0) {
                    renderContext.yesterdayClose = renderContext.fullData[0].price
                    renderContext.currentIndex = 0
                    renderContext.displayData.clear()

                    processNewPoint(renderContext.fullData[0])

                    startTimer()
                }
            case None => ()
        }
    }

    public func stopUpdating() {
        match(updateTimer) {
            case Some(t) => t.cancel()
            case None => ()
        }
        match(latestPoint) {
            case Some(p) => subtitle = "已收盘 ${p.time}"
            case None => subtitle = "已收盘"
        }
    }

    private func triggerRedraw() {
        for ((_, callback) in onChartDataChange) {
            callback()
        }
    }

    private func startTimer() {
        updateTimer = Some(Timer.repeat(Duration.second * 2, Duration.second * 2, { =>
            launch {
                updateChartData()
            }
        }))
    }

    private func updateChartData() {
        if (renderContext.currentIndex < renderContext.fullData.size - 1) {
            renderContext.currentIndex += 1
            let nextPoint = renderContext.fullData[renderContext.currentIndex]
            processNewPoint(nextPoint)
        } else {
            stopUpdating()
        }
    }

    private func calculateVolumeMax() {
        if(renderContext.displayData.isEmpty()) { return }
        var maxVolume: Int64 = 0
        for (point in renderContext.displayData) {
            maxVolume = max(maxVolume, point.volume)
        }
        renderContext.yAxisMaxVolume = maxVolume
    }

    private func updateDisplayNumbers(point: TimeLineDataPoint) {
        let price  = point.price
        let change = point.change
        let delta  = price - change

        let dayHigh = renderContext.dayHigh
        let dayLow  = renderContext.dayLow
        let cumulativeVolume = renderContext.cumulativeVolume
        let cumulativeTurnover = renderContext.cumulativeTurnover

        let changePercent = if (delta == 0.0) { 0.0 } else { (change / delta) * 100.0 }
        let amplitude     = if (delta == 0.0) { 0.0 } else { (dayHigh - dayLow) / delta * 100.0 }
        let dataColor     = if (change >= 0.0) { StyleConstants.INCREASE_COLOR } else { StyleConstants.DECREASE_COLOR }

        let data = DisplayNumberData(
            dataColor: dataColor,
            priceText:     "${price.format(".2")}",
            changeText:    "${change.format("+.2")}",
            percentText:   "${changePercent.format("+.2") + "%"}",
            volumeText:    "${(Float64(cumulativeVolume) / 1000000.0).format(".2")}万手",
            turnoverText:  "${(cumulativeTurnover / 100000000.0).format(".2")}亿",
            amplitudeText: "${amplitude.format(".2")}%"
        )

        displayNumberData = data
    }

    private func calculateBoundaries() {
        if(renderContext.displayData.isEmpty()) { return }

        let yesterdayClose = renderContext.yesterdayClose
        var maxPrice = yesterdayClose
        var minPrice = yesterdayClose
        for (point in renderContext.displayData) {
            maxPrice = max(maxPrice, point.price)
            minPrice = min(minPrice, point.price)
        }
        let delta = max(abs(maxPrice - yesterdayClose), abs(minPrice - yesterdayClose))
        let bufferedDelta = if (delta == 0.0) { 1.0 } else { delta * StyleConstants.TIME_LINE_PRICE_BUFFER_RATIO }
        renderContext.yAxisMax = yesterdayClose + bufferedDelta
        renderContext.yAxisMin = yesterdayClose - bufferedDelta
    }

    private func processNewPoint(point: TimeLineDataPoint) {
        renderContext.dayHigh = max(renderContext.dayHigh, point.price)
        renderContext.dayLow  = min(renderContext.dayLow,  point.price)
        renderContext.cumulativeVolume   += point.volume
        renderContext.cumulativeTurnover += point.avgPrice * Float64(point.volume)

        subtitle = "更新于 ${point.time}"
        renderContext.displayData.append(point)
        latestPoint = Some(point)

        updateDisplayNumbers(point)
        calculateBoundaries()
        calculateVolumeMax()
        triggerRedraw()
    }
}