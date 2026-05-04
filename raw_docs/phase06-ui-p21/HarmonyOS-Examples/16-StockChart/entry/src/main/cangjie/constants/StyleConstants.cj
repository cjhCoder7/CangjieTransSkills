/**
 * Created on 2025/7/30
 */
package ohos_app_cangjie_entry.constants

import ohos.base.*

public class StyleConstants {
    public static let FULL_WIDTH: Length  = 100.percent
    public static let FULL_HEIGHT: Length = 100.percent

    // Chart Colors
    public static let INCREASE_COLOR: Color  = Color(0xe63535)
    public static let DECREASE_COLOR: Color  = Color(0x1caa3c)
    public static let MA5_COLOR: Color       = Color(0xff399f)
    public static let GRAY_COLOR: Color      = Color(0x999999)
    public static let TIME_LINE_COLOR: Color = Color(0x0078f9)
    public static let GRID_LINE_COLOR: Color = Color(0xeeeeee)
    public static let ANNOTATION_LINE_COLOR: Color = Color(0xaaaaaa)
    public static let TIME_LINE_AREA_COLOR: Color  = Color(0x80e6f2ff)
    public static let TIME_LINE_DASH_LINE_COLOR: Color = Color(0xffa500)

    // Chart Dimensions & Layout
    public static let MAIN_CHART_HEIGHT: Float64 = 240.0
    public static let VOLUME_CHART_HEIGHT: Float64 = 120.0
    public static let KLINE_CANDLE_WIDTH: Float64 = 8.0

    // Chart Drawing Parameters
    public static let SMOOTHING_FACTOR: Float64 = 6.0
    public static let DASH_LINE_STYLE: Array<Float64> = [10.0, 6.0]
    public static let DASH_LINE_WIDTH: Float64 = 2.0
    public static let TIME_LINE_DOT_RADIUS: Float64 = 4.0
    public static let KLINE_PRICE_BUFFER_RATIO: Float64 = 0.3
    public static let TIME_LINE_PRICE_BUFFER_RATIO: Float64 = 1.2

    // Canvas
    public static let CANVAS_PADDING_TOP: Float64    = 10.0
    public static let CANVAS_PADDING_BOTTOM: Float64 = 20.0
    public static let CANVAS_PADDING_LEFT: Float64   = 5.0
    public static let CANVAS_PADDING_RIGHT: Float64  = 3.0
    public static let CANVAS_WIDTH: Float64          = 343.0
    public static let CANVAS_POINT_SPACING: Float64  = 10.0

    // Font Sizes
    public static let AXIS_LABEL_FONT_SIZE: Length = 10.fp
    public static let ANNOTATION_FONT_SIZE: Length = 10.fp
}