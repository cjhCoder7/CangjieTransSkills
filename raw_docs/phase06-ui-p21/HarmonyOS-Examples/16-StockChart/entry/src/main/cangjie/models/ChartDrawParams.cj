/**
 * Created on 2025/8/8
 */
package ohos_app_cangjie_entry.models

import std.collection.ArrayList

public class KLineRenderContext {
    // 原始数据和基础状态
    public var fullData: ArrayList<KLinePointWrapper> = ArrayList<KLinePointWrapper>()
    public var startIndex: Int64 = 0
    public var scrollOffset: Float64 = 0.0
    public var totalWidth: Float64 = 0.0

    // 计算出的用于渲染的参数
    public var minPrice: Float64 = 0.0
    public var maxPrice: Float64 = 0.0
    public var maxVolume: Int64 = 0
    public var highPricePointIndex: Int64 = -1
    public var lowPricePointIndex: Int64 = -1

    // 为渲染预先计算好的可见数据
    public var visibleCandles: ArrayList<CandleStickDrawInfo> = ArrayList<CandleStickDrawInfo>()
    public var visibleBars: ArrayList<VolumeBarDrawInfo> = ArrayList<VolumeBarDrawInfo>()
}

public class TimeLineRenderContext {
    // 原始数据和基础状态
    public var fullData: ArrayList<TimeLineDataPoint> = ArrayList<TimeLineDataPoint>()
    public var displayData: ArrayList<TimeLineDataPoint> = ArrayList<TimeLineDataPoint>()
    public var currentIndex: Int64 = 0
    public var yesterdayClose: Float64 = 0.0
    public var totalDataSize: Int64 = 0

    // 计算出的Y轴范围和统计数据
    public var yAxisMax: Float64 = 0.0
    public var yAxisMin: Float64 = 0.0
    public var yAxisMaxVolume: Int64 = 0

    // 日内统计数据
    public var dayHigh: Float64 = 0.0
    public var dayLow: Float64 = 0.0
    public var cumulativeVolume: Int64 = 0
    public var cumulativeTurnover: Float64 = 0.0
}

public struct CandleStickDrawInfo {
    public CandleStickDrawInfo(
        public let pointWrapper: KLinePointWrapper,
        public let index: Int64
    ) {}
}

public struct VolumeBarDrawInfo {
    public VolumeBarDrawInfo(
        public let data: KLineDataPoint,
        public let index: Int64
    ) {}
}