/**
 * Created on 2024/7/30
 */
package ohos_app_cangjie_entry.utils
import std.collection.*
internal import ohos.component.*

public class MyDataSource<T> <: IDataSource<T> {
    public MyDataSource(let data_: ArrayList<T>) {}

    public var listenerOp: Option<DataChangeListener> = None

    public func getData(index: Int64): T {
        return data_[index]
    }

    public func onRegisterDataChangeListener(listener: DataChangeListener): Unit {
        listenerOp = listener
    }

    public func onUnregisterDataChangeListener(listener: DataChangeListener): Unit {
        listenerOp = None
    }

    public func totalCount(): Int64 {
        return data_.size
    }
}