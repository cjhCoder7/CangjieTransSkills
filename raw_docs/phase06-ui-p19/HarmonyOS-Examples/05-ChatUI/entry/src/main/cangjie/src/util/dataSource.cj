/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.util

import ohos.base.*
import ohos.component.*

public class MyDataSource<T> <: IDataSource<T> {
    public MyDataSource(let data: Array<T>) {}

    public var listenerOp: Option<DataChangeListener> = None

    public func totalCount(): Int64 {
        return data.size
    }

    public func getData(index: Int64): T {
        return data[index]
    }

    public func onRegisterDataChangeListener(listener: DataChangeListener): Unit {
        listenerOp = listener
    }

    public func onUnregisterDataChangeListener(listener:DataChangeListener): Unit {
        listenerOp = None
    }
}