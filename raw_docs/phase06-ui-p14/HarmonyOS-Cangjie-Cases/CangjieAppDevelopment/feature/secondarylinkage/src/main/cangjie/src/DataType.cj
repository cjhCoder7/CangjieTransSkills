/**
 * Created on 2024/9/11
 */
package secondarylinkage

import std.collection.*

/**
 * 代表自定义类型数据的接口。
 *
 * desc - 描述。
 * tag - 类别。
 */
public class CustomDataType {
    public CustomDataType(
        public let desc: String,
        public let tag: String
    ) {}
}

/**
 * 一级列表可视区域的起始索引和终点索引。
 *
 * start - 可视区域起点索引。
 * end - 可视区域终点索引。
 */
public class ListIndexPosition {
    public ListIndexPosition(
        public let start: Int64,
        public let end: Int64
    ) {}
}

/**
 * Basic implementation of IDataSource to handle data listener
 *
 * @class
 * @implements {IDataSource}
 */
public open class BasicDataSource <: IDataSource<CustomDataType> {
    private let listeners: ArrayList<DataChangeListener> = ArrayList()
    private let originDataArray: ArrayList<CustomDataType> = ArrayList()

    public open func totalCount(): Int64 {
        return 0
    }

    /**
     * 获取指定索引数据。
     * @param {number} index - 索引值。
     * @returns {CustomDataType} 返回指定索引数据。
     */
    public open func getData(index: Int64): CustomDataType {
        return originDataArray[index]
    }

    /**
     * 为LazyForEach组件向其数据源处添加listener监听。
     * @param {DataChangeListener} listener - 监听对象。
     */
    public func onRegisterDataChangeListener(listener: DataChangeListener): Unit {
        for (item in this.listeners) {
            if (refEq(item, listener)) {
                return
            }
        }
        this.listeners.append(listener)
    }

    /**
     * 为对应的LazyForEach组件在数据源处去除listener监听。
     * @param {DataChangeListener} listener - 监听对象。
     */
    public func onUnregisterDataChangeListener(listener: DataChangeListener): Unit {
        var index = 0
        while (index < this.listeners.size) {
            let item = this.listeners[index]
            if (refEq(item, listener)) {
                this.listeners.remove(index)
            } else {
                index ++
            }
        }
    }

    public func notifyDataAdd(index: Int64): Unit {
        for (item in this.listeners) {
            item.onDataAdd(index)
        }
    }

    public func notifyDataChange(index: Int64): Unit {
        for (item in this.listeners) {
            item.onDataChange(index)
        }
    }

    public func notifyDataDelete(index: Int64): Unit {
        for (item in this.listeners) {
            item.onDataDelete(index)
        }
    }

    public func notifyDataMove(from: Int64, to: Int64): Unit {
        for (item in this.listeners) {
            item.onDataMove(from, to)
        }
    }
}

/**
 * 继承自BasicDataSource的子类，重写了方法。
 *
 * @class
 * @extends {BasicDataSource}
 */
public class MyDataSource <: BasicDataSource {
    private let dataArray: ArrayList<CustomDataType> = ArrayList()

    /**
     * 获取数组长度。
     * @returns {number} 返回数组长度。
     */
    public func totalCount(): Int64 {
        return this.dataArray.size
    }

    /**
     * 获取指定索引数据。
     * @param {number} index - 索引值。
     * @returns {CustomDataType} 返回指定索引数据。
     */
    public func getData(index: Int64): CustomDataType {
        return this.dataArray[index]
    }

    /**
     * 改变单个数据。
     * @param {number} index - 索引值。
     * @param {CustomDataType} data - 修改后的值。
     */
    public func addData(index: Int64, data: CustomDataType): Unit {
        this.dataArray.insert(index, data)
        this.notifyDataAdd(index)
    }

    /**
     * 添加数据。
     * @param {CustomDataType} data - 需要添加的数据。
     */
    public func pushData(data: CustomDataType): Unit {
        this.dataArray.append(data)
        this.notifyDataAdd(this.dataArray.size - 1)
    }

    /**
     * 添加数据。
     * @param {CustomDataType} data - 需要添加的数据。
     */
    public func pushData(data: ArrayList<CustomDataType>): Unit {
        this.dataArray.appendAll(data)
        this.notifyDataAdd(this.dataArray.size - 1)
    }
}

// 常量数据
const ITEM_GUTTER = 12
const TAG_TEXT_HEIGHT = 75
const SUB_ITEM_GUTTER = 7
const SUB_ITEM_HEIGHT = 96
const SUB_ITEM_TEXT_WIDTH_TITLE = 56
const SUB_ITEM_TEXT_HEIGHT = 12
const SUB_ITEM_TEXT_WIDTH_BODY = 120
const BOTTOM_TOAST_TEXT_MAX_HEIGHT = 200
