/**
 * Created on 2025/7/31
 */
package ohos_app_cangjie_entry.models

public struct TimeLineDataPoint {
    public TimeLineDataPoint(
        public let time: String,
        public let price: Float64,
        public let volume: Int64,
        public let change: Float64,
        public let avgPrice: Float64
    ) {}
}

public struct KLineDataPoint {
    public KLineDataPoint(
        public let timestamp: String,
        public let high: Float64,
        public let open: Float64,
        public let low: Float64,
        public let close: Float64,
        public let volume: Int64,
        public let changePercent: Float64
    ) {}
}

public class KLinePointWrapper {
    public let data: KLineDataPoint
    public var ma5: Float64 = 0.0

    public init(data: KLineDataPoint) {
        this.data = data
    }
}
