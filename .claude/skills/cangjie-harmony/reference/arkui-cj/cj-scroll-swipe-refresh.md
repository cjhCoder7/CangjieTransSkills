# Refresh

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

可以进行页面下拉操作并显示刷新动效的容器组件。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

支持单个子组件。

## 创建组件

### init(?RefreshOptions, () -> Unit)

```cangjie
public init(value: ?RefreshOptions, child: () -> Unit)
```

**功能：** 创建refresh组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[RefreshOptions](#class-refreshoptions)|是|-|设置组件刷新时的参数。|
|child|() -> Unit|是|-|声明容器子组件。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件事件

### func onStateChange(?(RefreshStatus) -> Unit)

```cangjie
public func onStateChange(callback: ?(RefreshStatus) -> Unit): This
```

**功能：** 设置刷新状态变更时，触发回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?([RefreshStatus](./cj-common-types.md#enum-refreshstatus))-> Unit|是|-|刷新状态。<br>初始值：{res: RefreshStatus =>}。|

### func onRefreshing(?() -> Unit)

```cangjie
public func onRefreshing(callback: ?() -> Unit): This
```

**功能：** 进入刷新状态时触发回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?()->Unit|是|-|进入刷新状态时触发回调。<br>初始值：{=>}。|

## 基础类型定义

### class RefreshOptions

```cangjie
public class RefreshOptions {
    public var refreshing: ?Bool
    public var changeEvent: ?(Bool) -> Unit
    public init(refreshing!: ?Bool)
    public init(refreshing!: ?Bindable<Bool>)
}
```

**功能：** 用于设置Refresh组件参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var refreshing

```cangjie
public var refreshing: ?Bool
```

**功能：** 当前组件是否正在刷新。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var changeEvent

```cangjie
public var changeEvent: ?(Bool) -> Unit
```

**功能：** 配合 @Binder 宏使用，用于refreshing属性的双向绑定。

**类型：** ?(Bool) -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?Bool)

```cangjie
public init(refreshing!: ?Bool)
```

**功能：** 创建一个 RefreshOptions 对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|refreshing|?Bool|是|-| **命名参数。** 标识刷新组件当前是否正在刷新。|

#### init(?Bindable\<Bool>)

```cangjie
public init(refreshing!: ?Bindable<Bool>)
```

**功能：** 根据刷新状态创建一个 RefreshOptions 对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|refreshing|?[Bindable](./cj-common-types.md#class-bindablet)\<Bool>|是|-| **命名参数。** 标识刷新组件当前是否正在刷新。|

## 示例代码

### 示例1（默认刷新样式）

刷新区域使用默认刷新样式。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import std.time.*
import std.sync.*

class MyDataSource <: IDataSource<Int64> {
    public MyDataSource(let data_: ArrayList<Int64>) {}
    public var listenerOp: Option<DataChangeListener> = None
    public func getData(index: Int64): Int64 {
        return data_[index]
    }

    public func registerDataChangeListener(listener: DataChangeListener): Unit {
        listenerOp = listener
    }

    public func unregisterDataChangeListener(listener: DataChangeListener): Unit {
        listenerOp = None
    }

    public func totalCount(): Int64 {
        return data_.size
    }
}

@Entry
@Component
class EntryView {
    @State
    var isRefreshing: Bool = false
    let myDataSource: MyDataSource = MyDataSource(ArrayList<Int64>(10, {i => i}))
    @State
    var status: String = "Inactive"
    @State
    var onRefreshStatus: String = "noRefresh"
    @State
    var ratio: Float64 = 1.0
    @State
    var maxRefreshingHeight: Float64 = 100.0

    func build() {
        Column() {
            Text(status)
                    .size(width: 50.percent, height: 50.vp)
                    .borderWidth(1)
                    .borderColor(Color.Black)
                    .backgroundColor(0xFFFFFF)
                    .borderRadius(15)
                    .textAlign(TextAlign.Center)
                    .fontSize(30)
                    .margin(top: 20.vp)
                    .id("StatusText")
            Text(onRefreshStatus)
                    .size(width: 50.percent, height: 50.vp)
                    .borderWidth(1)
                    .borderColor(Color.Black)
                    .backgroundColor(0xFFFFFF)
                    .borderRadius(15)
                    .textAlign(TextAlign.Center)
                    .fontSize(30)
                    .margin(top: 20.vp)
                    .id("OnRefreshText")

            Refresh(RefreshOptions(refreshing: @Binder(isRefreshing))) {
                Column {
                    LazyForEach(
                            myDataSource,
                            itemGeneratorFunc: {
                                element: Int64, index: Int64 => Text(element.toString())
                            .size(width: 50.percent, height: 50.vp)
                            .borderWidth(1)
                            .borderColor(Color.Black)
                            .backgroundColor(0xFFFFFF)
                            .borderRadius(15)
                            .textAlign(TextAlign.Center)
                            .fontSize(30)
                            .margin(top: 20.vp)
                            }
                    )
                }.width(100.percent).backgroundColor(0x89CFF0)
            }
                    .width(100.percent)
                    .height(100.percent)
                    .id("refresh")
                    .onRefreshing(
                            {
                                =>
                                onRefreshStatus = "Refresh"
                                Timer.once(2000 * Duration.millisecond) {
                                    => launch {
                                    this.isRefreshing = false
                                    onRefreshStatus = "NoRefresh"
                                }
                                }
                            }
                    )
                    .onStateChange({
                        refreshStatus: RefreshStatus =>
                        this.status = match (refreshStatus) {
                            case Inactive => "Inactive"
                            case Drag => "Drag"
                            case OverDrag => "OverDrag"
                            case Refresh => "Refresh"
                            case Done => "Done"
                            case _ => ""
                        }
                    })
                    .backgroundColor(0x89CFF0)
        }
    }
}
```

![refresh_ex1](figures/refresh_ex1.gif)
