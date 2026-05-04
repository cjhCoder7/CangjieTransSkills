/**
 * Created on 2024/8/24
 */
package ohos_app_cangjie_entry.constants

import std.collection.{ArrayList, HashMap}

public class BreakpointConstants {
    public static let BREAKPOINT_SM: String = "sm"
    public static let BREAKPOINT_MD: String = "md"
    public static let BREAKPOINT_LG: String = "lg"
    public static let BREAKPOINT_RANGES: ArrayList<Float32> = ArrayList<Float32>(320.00, 600.00, 840.00)
    /**
     * Grid row column list.
     */
    public static let GRID_ROW_COLUMNS: ArrayList<Int32> = ArrayList<Int32>(12, 6, 4)
    public static let GRID_COL_SPANS: ArrayList<Int32> = ArrayList<Int32>(0, 1, 2, 3, 4, 5, 6)
}
