/**
 * Created on 2024/8/27
 */
package ohos_app_cangjie_entry.utils

import std.collection.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*

public class MyDataSource<T> <: IDataSource<T> {
    public MyDataSource(let data_: ArrayList<T>) {}

    private var listenerOp: Option<DataChangeListener> = None

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