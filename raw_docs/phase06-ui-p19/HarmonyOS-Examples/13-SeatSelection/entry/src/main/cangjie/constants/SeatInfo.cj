/**
 * Created on 2025/7/18
 */
package ohos_app_cangjie_entry.constants

public struct SeatInfo <: ToString & Hashable & Equatable<SeatInfo> {
    public let row: Int64
    public let col: Int64

    public init(row: Int64, col: Int64) {
        this.row = row
        this.col = col
    }

    public operator func ==(that: SeatInfo): Bool {
        this.row == that.row && this.col == that.col
    }

    public operator func !=(that: SeatInfo): Bool {
        this.row != that.row || this.col != that.col
    }

    public func toString(): String {
        "${row + 1}排${col + 1}座"
    }

    // ForEach 遍历的数组元素的类型需要实现 Hashable 接口
    public func hashCode(): Int64 {
        this.toString().hashCode()
    }
}