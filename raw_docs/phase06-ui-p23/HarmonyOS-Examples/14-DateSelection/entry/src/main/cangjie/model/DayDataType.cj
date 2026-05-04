/**
 * Created on 2025/7/21
 */
package ohos_app_cangjie_entry.model
import std.time.*
import std.collection.*

public  class MyDay {
    private var currentTime: DateTime

    public init (currentTime: DateTime) {
        this.currentTime = currentTime
    }

    public func getDate(): Int64 {
        return this.currentTime.dayOfMonth
    }

    public func getMonth(): Int64 {
        return this.currentTime.month.value()
    }

    public func getWeekValue(): Int64 {
        return this.currentTime.dayOfWeek.value()
    }

    public func getWeekString(): String {
        let week: Array<String> = ["日","一","二","三","四","五","六"]
        let index = this.currentTime.dayOfWeek.value()
        return week[index + 1]
    }
}