/**
 * Created on 2024/9/9
 */
package functionalscenes.model

import ohos.component.*
import std.collection.*

//实现 IDataSource，用于 List 组件加载数据
public class ListDataSource <: IDataSource<SceneModuleInfo> {
    public ListDataSource(
        let data: Array<SceneModuleInfo>
    ) {}

    public init() {
        this.data = Array<SceneModuleInfo>()
    }

    public func totalCount(): Int64 {
        return data.size
    }

    public func getData(index: Int64): SceneModuleInfo {
        return data[index]
    }

    public func onRegisterDataChangeListener(listener: DataChangeListener): Unit {
    }

    public func onUnregisterDataChangeListener(listener: DataChangeListener): Unit {
    }
}