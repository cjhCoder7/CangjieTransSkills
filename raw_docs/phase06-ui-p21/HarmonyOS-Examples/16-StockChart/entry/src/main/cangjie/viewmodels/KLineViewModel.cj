/**
 * Created on 2025/8/6
 */
package ohos_app_cangjie_entry.viewmodels

import std.math.*
import std.collection.HashMap

import ohos.state_manage.*
import ohos.state_macro_manage.Observed

import ohos_app_cangjie_entry.models.*
import ohos_app_cangjie_entry.constants.StyleConstants
import ohos_app_cangjie_entry.services.ChartDataServices

@Observed
public class KLineViewModel {
    public var renderContext: KLineRenderContext = KLineRenderContext()

    private var tmpOffset: Float64 = 0.0
    private var redrawCallbacks: HashMap<String, () -> Unit> = HashMap<String, () -> Unit>()

    private let pointSpacing: Float64 = StyleConstants.CANVAS_POINT_SPACING
    private let viewportWidth: Float64 = StyleConstants.CANVAS_WIDTH
    private let indexSpacing: Int64 = Int64(viewportWidth / pointSpacing)

    public func addRedrawCallback(str: String, callback: () -> Unit) {
        redrawCallbacks[str] = callback
    }

    private func triggerRedraw() {
        for ((_, callback) in redrawCallbacks) {
            callback()
        }
    }

    public func initialize(dataService: ChartDataServices) {
        renderContext.fullData = dataService.loadKLineData()
        if (!renderContext.fullData.isEmpty()) {
            renderContext.totalWidth = Float64(renderContext.fullData.size) * pointSpacing + StyleConstants.CANVAS_PADDING_LEFT + StyleConstants.CANVAS_PADDING_RIGHT
            updateVisibleRange(0.0, isInitial: true)
        }
    }

    public func updateVisibleRange(offsetX: Float64, isInitial!: Bool = false) {
        if (renderContext.fullData.isEmpty() || pointSpacing <= 0.0) { return }

        if (!isInitial) {
            updateScrollIndex(offsetX)
        }
        calculateVisibleStats()
        prepareVisibleDrawData()
        triggerRedraw()
    }

    private func updateScrollIndex(offsetX: Float64) {
        renderContext.scrollOffset += offsetX
        tmpOffset += offsetX

        let offsetIndex = Int64(tmpOffset / pointSpacing)
        tmpOffset -= Float64(offsetIndex) * pointSpacing

        renderContext.startIndex += offsetIndex

        let maxStartIndex = if (renderContext.fullData.size > indexSpacing) { renderContext.fullData.size - indexSpacing } else { 0 }
        renderContext.startIndex = max(0, min(renderContext.startIndex, maxStartIndex))
    }

    private func calculateVisibleStats() {
        let visibleRange = getVisibleDataRange()
        if (visibleRange.start >= visibleRange.end) { return }

        let firstIndex = visibleRange.start
        var minP = renderContext.fullData[firstIndex].data.low
        var maxP = renderContext.fullData[firstIndex].data.high
        var maxV = renderContext.fullData[firstIndex].data.volume
        var tmpHighIndex = firstIndex
        var tmpLowIndex  = firstIndex

        for (i in visibleRange) {
            let point = renderContext.fullData[i]
            if (point.data.low < minP) {
                minP = point.data.low
                tmpLowIndex = i
            }
            if (point.data.high > maxP) {
                maxP = point.data.high
                tmpHighIndex = i
            }
            maxV = max(maxV, point.data.volume)
        }

        renderContext.highPricePointIndex = tmpHighIndex
        renderContext.lowPricePointIndex  = tmpLowIndex

        let priceBuffer = (maxP - minP) * StyleConstants.KLINE_PRICE_BUFFER_RATIO
        renderContext.minPrice  = max(0.0, minP - priceBuffer)
        renderContext.maxPrice  = maxP + priceBuffer
        renderContext.maxVolume = maxV
    }

    private func prepareVisibleDrawData() {
        renderContext.visibleCandles.clear()
        renderContext.visibleBars.clear()

        let visibleRange = getVisibleDataRange()
        for(i in visibleRange) {
            renderContext.visibleCandles.append(CandleStickDrawInfo(renderContext.fullData[i], i))
            renderContext.visibleBars.append(VolumeBarDrawInfo(renderContext.fullData[i].data, i))
        }
    }

    private func getVisibleDataRange() {
        let startIndex = renderContext.startIndex
        let endIndex = min(startIndex + indexSpacing + 2, renderContext.fullData.size)
        return startIndex..endIndex
    }
}