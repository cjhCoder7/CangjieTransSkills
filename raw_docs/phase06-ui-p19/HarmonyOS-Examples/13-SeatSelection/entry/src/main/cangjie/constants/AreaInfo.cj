/**
 * Created on 2025/7/17
 */
package ohos_app_cangjie_entry.constants

import ohos.base.*

public class AreaInfo {
    public let str: String
    public let fillColor: Color
    public let strokeColor: Color

    init(t: SEAT_TYPE) {
        this(t.toString(), StyleConstants.FILL_COLOR[t], StyleConstants.STROKE_COLOR[t])
    }

    init(str: String, fillColor: Color, strokeColor: Color) {
        this.str = str
        this.fillColor = fillColor
        this.strokeColor = strokeColor
    }
}
