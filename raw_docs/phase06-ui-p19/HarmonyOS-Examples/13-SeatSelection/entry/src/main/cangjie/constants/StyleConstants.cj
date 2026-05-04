/**
 * Created on 2025/7/16
 */
package ohos_app_cangjie_entry.constants

import ohos.base.*
import std.collection.HashMap

public class StyleConstants {
    public static let FULL_WIDTH: Length = 100.percent
    public static let FULL_HEIGHT: Length = 100.percent
    public static let CANVAS_PADDING: Int64 = 1
    public static let MATRIX_SPACE: Int64 = 10
    public static let MATRIX_RECT_SIZE: Int64 = 24
    public static let BACKGROUND_COLOR: Color = Color(0xf5f5f5)

    public static let FILL_COLOR: HashMap<SEAT_TYPE, Color> = HashMap<SEAT_TYPE, Color>(
        [
            (SEAT_TYPE.BEST, Color(0Xfefcfd)),
            (SEAT_TYPE.GOOD, Color(0Xfaffff)),
            (SEAT_TYPE.SOLD, Color(0Xc60000)),
            (SEAT_TYPE.SELECTED, Color(0X00965C)),
            (SEAT_TYPE.CHEAP, Color(0xfffefa))
        ]
    )

    public static let STROKE_COLOR: HashMap<SEAT_TYPE, Color> = HashMap<SEAT_TYPE, Color>(
        [
            (SEAT_TYPE.BEST, Color(0Xfc2c54)),
            (SEAT_TYPE.GOOD, Color(0X1872f8)),
            (SEAT_TYPE.SOLD, Color(0Xc60000)),
            (SEAT_TYPE.SELECTED, Color(0X00965C)),
            (SEAT_TYPE.CHEAP, Color(0Xff9400))
        ]
    )
}
