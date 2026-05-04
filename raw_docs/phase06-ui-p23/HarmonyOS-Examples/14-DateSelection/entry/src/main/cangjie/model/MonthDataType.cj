/**
 * Created on 2025/7/21
 */
package ohos_app_cangjie_entry.model
import std.collection.ArrayList
import std.time.Month
import std.time.*

public class MyMonth {
    private var currentTime: DateTime

    public init (currentTime: DateTime) {
        this.currentTime = currentTime
    }

    public func getMonth(): Int64 {
        return this.currentTime.month.value()
    }

    public func getYear(): Int64 {
        return this.currentTime.year
    }

     public func totalAllDays(): Int64 {
        return currentTime.addMonths(1).dayOfYear - currentTime.dayOfYear
    }

    public func getStartDay(): MyDay {
        let index = 1 - this.currentTime.dayOfMonth
        var startDay:MyDay = MyDay(this.currentTime.addDays(index))
        return startDay
    }

    public func getEndDay(): MyDay {
        let index = this.totalAllDays() - this.currentTime.dayOfMonth
        var endDay:MyDay = MyDay(this.currentTime.addDays(index))
        return endDay
    }

    public func getDateList(): ArrayList<Int64> {
        var dateList: ArrayList<Int64> = ArrayList<Int64>()
        let index = this.totalAllDays() + this.getStartDay().getWeekValue() - 1 + 7 - this.getEndDay().getWeekValue()

        for (i in 1..=index) {
            if(i <= this.getStartDay().getWeekValue() - 1) {
                dateList.append(0)
            } else if(i > this.getStartDay().getWeekValue() - 1 && i <= this.getStartDay().getWeekValue() - 1 + this.totalAllDays()) {
                dateList.append(i - (this.getStartDay().getWeekValue() - 1))
            } else {
                dateList.append(0)
            }
        }

        return dateList
    }


}