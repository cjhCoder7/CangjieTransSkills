/**
 * Created on 2025/7/16
 */
package ohos_app_cangjie_entry.constants

import ohos.base.*

public class DataConstants {
    public static let AREALIST: Array<AreaInfo> = [
        AreaInfo(GOOD),
        AreaInfo(SOLD),
        AreaInfo(SELECTED),
        AreaInfo(BEST),
        AreaInfo(CHEAP)
    ]

    public static let SEATS: Array<Array<SEAT_TYPE>> = [
        Array<SEAT_TYPE>(10, item: CHEAP),
        Array<SEAT_TYPE>(10, item: GOOD),
        [GOOD, GOOD, GOOD, BEST, BEST, BEST, BEST, GOOD, GOOD, GOOD],
        [GOOD, GOOD, BEST, BEST, BEST, BEST, BEST, BEST, GOOD, GOOD],
        [GOOD, GOOD, BEST, BEST, SOLD, BEST, BEST, BEST, GOOD, GOOD],
        [GOOD, GOOD, BEST, BEST, BEST, BEST, BEST, BEST, GOOD, GOOD],
        Array<SEAT_TYPE>(10, item: GOOD)
    ]

    public static let TITLE: String = "电影院"
    public static let PLACE: String = "1号荧幕厅"
    public static let MOVIE_NAME: String = "长安的荔枝"
    public static let MOVIE_DATE: String = "7月16日"
    public static let MOVIE_TIME: String = "19:10-21:12"
    public static let MOVIE_TYPE: String = "国语2D"
}
