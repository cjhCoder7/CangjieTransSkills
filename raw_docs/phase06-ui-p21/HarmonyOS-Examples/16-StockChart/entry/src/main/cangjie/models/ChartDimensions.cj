/**
 * Created on 2025/8/6
 */
package ohos_app_cangjie_entry.models

import ohos_app_cangjie_entry.constants.StyleConstants

public class ChartDimensions {
    public let chartWidth: Float64
    public let chartHeight: Float64
    public let paddingTop: Float64    = StyleConstants.CANVAS_PADDING_TOP
    public let paddingBottom: Float64 = StyleConstants.CANVAS_PADDING_BOTTOM
    public let paddingLeft: Float64   = StyleConstants.CANVAS_PADDING_LEFT
    public let paddingRight: Float64  = StyleConstants.CANVAS_PADDING_RIGHT

    public init(width: Float64, height: Float64) {
        chartWidth  = width - paddingLeft - paddingRight
        chartHeight = height - paddingTop - paddingBottom
    }
}