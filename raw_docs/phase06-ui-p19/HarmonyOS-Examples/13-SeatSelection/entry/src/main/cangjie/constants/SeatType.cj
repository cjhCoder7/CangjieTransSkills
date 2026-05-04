/**
 * Created on 2025/7/17
 */
package ohos_app_cangjie_entry.constants

public enum SEAT_TYPE <: ToString & Hashable & Equatable<SEAT_TYPE> {
    BEST | GOOD | CHEAP | SELECTED | SOLD

    public func toString(): String {
        match (this) {
            case BEST => "黄金区"
            case GOOD => "次黄金区"
            case CHEAP => "特惠区"
            case SELECTED => "已选"
            case SOLD => "已售"
        }
    }

    public func hashCode(): Int64 {
        this.toString().hashCode()
    }

    public operator func ==(that: SEAT_TYPE): Bool {
        this.toString() == that.toString()
    }

    public operator func !=(that: SEAT_TYPE): Bool {
        this.toString() != that.toString()
    }
}
