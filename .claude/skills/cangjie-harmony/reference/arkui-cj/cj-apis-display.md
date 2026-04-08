# ohos.display（屏幕属性）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

提供屏幕属性相关功能。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func getAllDisplays()

```cangjie
public func getAllDisplays(): Array<Display>
```

**功能：** 获取所有显示屏。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[Display](#class-display)>|返回所有显示屏的结果。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1400001|Invalid display or screen.|
  |1400003|This display manager service works abnormally.|

**示例：**

<!-- code_check_manual -->

```cangjie
import kit.ArkUI.*
import kit.PerformanceAnalysisKit.Hilog

func getAllDisplaysExample() {
    try {
        let displayClass: Array<Display> = getAllDisplays()
        if (displayClass.size > 0) {
            Hilog.info(0, "CangjieTest", displayClass[0].name)
        }
    } catch (exception: Exception) {
        Hilog.error(0, "CangjieTest", exception.toString())
    }
}
```

## func getCurrentFoldCreaseRegion()

```cangjie
public func getCurrentFoldCreaseRegion(): FoldCreaseRegion
```

**功能：** 获取当前显示模式下的折叠 crease 区域。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[FoldCreaseRegion](#class-foldcreaseregion)|返回当前显示模式下的折叠 crease 区域。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1400003|This display manager service works abnormally.|

**示例：**

<!-- code_check_manual -->

```cangjie
import kit.ArkUI.*
import kit.PerformanceAnalysisKit.Hilog

func getCurrentFoldCreaseRegionExample() {
    try {
        let region = getCurrentFoldCreaseRegion()
        Hilog.info(0, "CangjieTest", "${region.displayId}")
    } catch (exception: Exception) {
        Hilog.error(0, "CangjieTest", exception.toString())
    }
}
```

## func getDefaultDisplaySync()

```cangjie
public func getDefaultDisplaySync(): Display
```

**功能：** 获取默认显示屏。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[Display](#class-display)|返回显示屏的结果。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1400001|Invalid display or screen.|
  |1400003|This display manager service works abnormally.|

**示例：**

<!-- code_check_manual -->

```cangjie
import kit.ArkUI.*
import kit.PerformanceAnalysisKit.Hilog

func getDefaultDisplaySyncExample() {
    try {
        let displayClass: Display = getDefaultDisplaySync()
        Hilog.info(0, "CangjieTest", displayClass.name)
    } catch (exception: Exception) {
        Hilog.error(0, "CangjieTest", exception.toString())
    }
}
```

## func getFoldDisplayMode()

```cangjie
public func getFoldDisplayMode(): FoldDisplayMode
```

**功能：** 获取折叠设备的显示模式。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[FoldDisplayMode](#enum-folddisplaymode)|返回折叠设备的显示模式。|

## func getFoldStatus()

```cangjie
public func getFoldStatus(): FoldStatus
```

**功能：** 获取折叠设备的当前折叠状态。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[FoldStatus](#enum-foldstatus)|返回设备的折叠状态。|

## func isFoldable()

```cangjie
public func isFoldable(): Bool
```

**功能：** 检查设备是否可折叠。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|true表示设备可折叠。|

## func off(ListenerType)

```cangjie
public func off(listenerType: ListenerType): Unit
```

**功能：** 禁用所有显示屏设备变化的监听器。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|listenerType|[ListenerType](#enum-listenertype)|是|-|监听事件类型。|

## func off(ListenerType, Callback1Argument\<FoldDisplayMode>)

```cangjie
public func off(listenerType: ListenerType, callback: Callback1Argument<FoldDisplayMode>): Unit
```

**功能：** 取消注册折叠显示模式变化的回调。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|listenerType|[ListenerType](#enum-listenertype)|是|-|折叠显示模式变化的事件。|
|callback|Callback1Argument\<[FoldDisplayMode](#enum-folddisplaymode)>|是|-|用于返回当前折叠显示模式的回调。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |401|Parameter error. Possible causes:<br> 1. Mandatory parameters are left unspecified. <br>2. Incorrect parameter types. |
  |1400003|This display manager service works abnormally.|

**示例：**

<!-- code_check_manual -->

```cangjie
import kit.ArkUI.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.callback_invoke.Callback1Argument
import ohos.business_exception.BusinessException

class TestCallback <: Callback1Argument<FoldDisplayMode> {
    public init() {}
    public open func invoke(error: ?BusinessException, value: FoldDisplayMode): Unit {
        Hilog.info(0, "CangjieTest", "Display fold status changed, current fold status: " + match (value) {
            case FoldDisplayModeUnknown => "FoldDisplayModeUnknown"
            case FoldDisplayModeFull => "FoldDisplayModeFull"
            case FoldDisplayModeMain => "FoldDisplayModeMain"
            case FoldDisplayModeSub => "FoldDisplayModeSub"
            case FoldDisplayModeCoordination => "FoldDisplayModeCoordination"
            case _ => "Failed to get fold display mode."
        })
    }
}

func test() {
    let testCallback = TestCallback()
    try {
        var temp: Unit = off(ListenerTypeFoldDisplayModeChange, testCallback)
    } catch (e: BusinessException) {
        Hilog.error(0, "CangjieTest", e.toString())
    }
}
```

## func off(ListenerType, Callback1Argument\<FoldStatus>)

```cangjie
public func off(listenerType: ListenerType, callback: Callback1Argument<FoldStatus>): Unit
```

**功能：** 取消注册折叠状态变化的回调。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|listenerType|[ListenerType](#enum-listenertype)|是|-|折叠状态变化的事件。|
|callback|Callback1Argument\<[FoldStatus](#enum-foldstatus)>|是|-|用于返回设备当前折叠状态的回调。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |401|Parameter error. Possible causes:<br> 1. Mandatory parameters are left unspecified. <br>2. Incorrect parameter types. |
  |1400003|This display manager service works abnormally.|

**示例：**

<!-- code_check_manual -->

```cangjie
import kit.ArkUI.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.callback_invoke.Callback1Argument
import ohos.business_exception.BusinessException

class TestCallback <: Callback1Argument<FoldStatus> {
    public init() {}
    public open func invoke(error: ?BusinessException, value: FoldStatus): Unit {
        Hilog.info(0, "CangjieTest", "Display fold status changed, current fold status: " + match (value) {
            case FoldStatusUnknown => "FoldStatusUnknown"
            case FoldStatusExpanded => "FoldStatusExpanded"
            case FoldStatusFolded => "FoldStatusFolded"
            case FoldStatusHalfFolded => "FoldStatusHalfFolded"
            case _ => "Failed to get fold status."
        })
    }
}

func test() {
    let testCallback = TestCallback()
    try {
        var temp: Unit = off(ListenerTypeFoldStatusChange, testCallback)
    } catch (e: BusinessException) {
        Hilog.error(0, "CangjieTest", e.toString())
    }
}
```

## func on(ListenerType, Callback1Argument\<FoldDisplayMode>)

```cangjie
public func on(listenerType: ListenerType, callback: Callback1Argument<FoldDisplayMode>): Unit
```

**功能：** 注册折叠显示模式变化的回调。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|listenerType|[ListenerType](#enum-listenertype)|是|-|折叠显示模式变化的事件。|
|callback|Callback1Argument\<[FoldDisplayMode](#enum-folddisplaymode)>|是|-|用于返回当前折叠显示模式的回调。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |401|Parameter error. Possible causes:<br> 1. Mandatory parameters are left unspecified. <br>2. Incorrect parameter types. |
  |1400003|This display manager service works abnormally.|

**示例：**

<!-- code_check_manual -->

```cangjie
import kit.ArkUI.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.callback_invoke.Callback1Argument
import ohos.business_exception.BusinessException

class TestCallback <: Callback1Argument<FoldDisplayMode> {
    public init() {}
    public open func invoke(error: ?BusinessException, value: FoldDisplayMode): Unit {
        Hilog.info(0, "CangjieTest", "Display fold status changed, current fold status: " + match (value) {
            case FoldDisplayModeUnknown => "FoldDisplayModeUnknown"
            case FoldDisplayModeFull => "FoldDisplayModeFull"
            case FoldDisplayModeMain => "FoldDisplayModeMain"
            case FoldDisplayModeSub => "FoldDisplayModeSub"
            case FoldDisplayModeCoordination => "FoldDisplayModeCoordination"
            case _ => "Failed to get fold display mode."
        })
    }
}

func test() {
    let testCallback = TestCallback()
    try {
        var temp: Unit = on(ListenerTypeFoldDisplayModeChange, testCallback)
    } catch (e: BusinessException) {
        Hilog.error(0, "CangjieTest", e.toString())
    }
}
```

## func on(ListenerType, Callback1Argument\<FoldStatus>)

```cangjie
public func on(listenerType: ListenerType, callback: Callback1Argument<FoldStatus>): Unit
```

**功能：** 注册折叠状态变化的回调。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|listenerType|[ListenerType](#enum-listenertype)|是|-|折叠状态变化的事件。|
|callback|Callback1Argument\<[FoldStatus](#enum-foldstatus)>|是|-|用于返回设备当前折叠状态的回调。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |401|Parameter error. Possible causes:<br> 1. Mandatory parameters are left unspecified. <br>2. Incorrect parameter types. |
  |1400003|This display manager service works abnormally.|

**示例：**

<!-- code_check_manual -->

```cangjie
import kit.ArkUI.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.callback_invoke.Callback1Argument
import ohos.business_exception.BusinessException

class TestCallback <: Callback1Argument<FoldStatus> {
    public init() {}
    public open func invoke(error: ?BusinessException, value: FoldStatus): Unit {
        Hilog.info(0, "CangjieTest", "Display fold status changed, current fold status: " + match (value) {
            case FoldStatusUnknown => "FoldStatusUnknown"
            case FoldStatusExpanded => "FoldStatusExpanded"
            case FoldStatusFolded => "FoldStatusFolded"
            case FoldStatusHalfFolded => "FoldStatusHalfFolded"
            case _ => "Failed to get fold status."
        })
    }
}

func test() {
    let testCallback = TestCallback()
    try {
        var temp: Unit = on(ListenerTypeFoldStatusChange, testCallback)
    } catch (e: BusinessException) {
        Hilog.error(0, "CangjieTest", e.toString())
    }
}
```

## class CutoutInfo

```cangjie
public class CutoutInfo {
    public let boundingRects: Array<Rect>
    public let waterfallDisplayAreaRects: WaterfallDisplayAreaRects
    public init(
    boundingRects!: Array<Rect>,
    waterfallDisplayAreaRects!: WaterfallDisplayAreaRects
    )
}
```

**功能：** 显示屏的刘海信息。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### let boundingRects

```cangjie
public let boundingRects: Array<Rect>
```

**功能：** 显示屏刘海区域的边界矩形。

**类型：** Array\<[Rect](#class-rect)>

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### let waterfallDisplayAreaRects

```cangjie
public let waterfallDisplayAreaRects: WaterfallDisplayAreaRects
```

**功能：** 瀑布屏各侧弯曲部分的矩形。

**类型：** [WaterfallDisplayAreaRects](#class-waterfalldisplayarearects)

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### init(Array\<Rect>, WaterfallDisplayAreaRects)

```cangjie
public init(
    boundingRects!: Array<Rect>,
    waterfallDisplayAreaRects!: WaterfallDisplayAreaRects
)
```

**功能：** CutoutInfo构造函数。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|boundingRects|Array\<[Rect](#class-rect)>|是|-| **命名参数。** 刘海区域的边界矩形数组。|
|waterfallDisplayAreaRects|[WaterfallDisplayAreaRects](#class-waterfalldisplayarearects)|是|-| **命名参数。** 瀑布屏各侧弯曲部分的矩形。|

## class Display

```cangjie
public class Display {
}
```

**功能：** 定义显示屏的属性。它们不会自动更新。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### prop alive

```cangjie
public prop alive: Bool
```

**功能：** 显示屏是否处于活动状态。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### prop densityDpi

```cangjie
public prop densityDpi: Float64
```

**功能：** 显示屏密度，以像素为单位，是物理像素和逻辑像素之间的缩放系数。低分辨率显示屏的值为1.0。

**类型：** Float64

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### prop densityPixels

```cangjie
public prop densityPixels: Float64
```

**功能：** 显示分辨率，即每英寸的像素数。

**类型：** Float64

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### prop height

```cangjie
public prop height: Int64
```

**功能：** 显示屏高度，以像素为单位。

**类型：** Int64

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### prop id

```cangjie
public prop id: Int64
```

**功能：** 显示屏ID。

**类型：** Int64

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### prop name

```cangjie
public prop name: String
```

**功能：** 显示屏名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### prop orientation

```cangjie
public prop orientation: Orientation
```

**功能：** 显示屏方向。

**类型：** [Orientation](#enum-orientation)

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### prop refreshRate

```cangjie
public prop refreshRate: UInt32
```

**功能：** 刷新率，以Hz为单位。

**类型：** UInt32

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### prop rotation

```cangjie
public prop rotation: UInt32
```

**功能：** 显示屏旋转度数的枚举值。
值0表示显示屏顺时针旋转0°。
值1表示显示屏顺时针旋转90°。
值2表示显示屏顺时针旋转180°。
值3表示显示屏顺时针旋转270°。

**类型：** UInt32

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### prop scaledDensity

```cangjie
public prop scaledDensity: Float64
```

**功能：** 显示屏文本缩放密度。

**类型：** Float64

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### prop state

```cangjie
public prop state: DisplayState
```

**功能：** 显示屏状态。

**类型：** [DisplayState](#enum-displaystate)

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### prop width

```cangjie
public prop width: Int64
```

**功能：** 显示屏宽度，以像素为单位。

**类型：** Int64

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### prop xDpi

```cangjie
public prop xDpi: Float64
```

**功能：** x轴上的DPI。

**类型：** Float64

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### prop yDpi

```cangjie
public prop yDpi: Float64
```

**功能：** y轴上的DPI。

**类型：** Float64

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### func getCutoutInfo()

```cangjie
public func getCutoutInfo(): CutoutInfo
```

**功能：** 获取显示屏的刘海信息。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[CutoutInfo](#class-cutoutinfo)|返回显示屏的刘海信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1400001|Invalid display or screen.|
  |1400003|This display manager service works abnormally.|

**示例：**

<!-- code_check_manual -->

```cangjie
import kit.ArkUI.*
import kit.PerformanceAnalysisKit.Hilog

func getCutoutInfoExample() {
    try {
        let displayClass = getDefaultDisplaySync()
        let cutout = displayClass.getCutoutInfo()
        Hilog.info(0, "CangjieTest", cutout.boundingRects.size)
    } catch (exception: Exception) {
        Hilog.error(0, "CangjieTest", exception.toString())
    }
}
```

## class FoldCreaseRegion

```cangjie
public class FoldCreaseRegion {
    public let displayId: UInt32
    public let creaseRects: Array<Rect>
    public init(
        displayId!: UInt32,
        creaseRects!: Array<Rect>
    )
}
```

**功能：** 构造一个FoldCreaseRegion类型的对象。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### let displayId

```cangjie
public let displayId: UInt32
```

**功能：** 显示ID，用于标识crease所在的屏幕。

**类型：** UInt32

**读写能力：** 只读

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**功能：** 折叠 crease 区域。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### let creaseRects

```cangjie
public let creaseRects: Array<Rect>
```

**功能：** crease 区域。

**类型：** Array\<[Rect](#class-rect)>

**读写能力：** 只读

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### init(UInt32, Array\<Rect>)

```cangjie
public init(
    displayId!: UInt32,
    creaseRects!: Array<Rect>
)
```

**功能：** FoldCreaseRegion构造函数。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|displayId|UInt32|是|-| **命名参数。** 显示屏ID。|
|creaseRects|Array\<[Rect](#class-rect)>|是|-| **命名参数。** crease区域。|

## class Rect

```cangjie
public class Rect {
    public var left: Int32
    public var top: Int32
    public var width: UInt32
    public var height: UInt32
    public init(
    left!: Int32,
    top!: Int32,
    width!: UInt32,
    height!: UInt32
    )
}
```

**功能：** 矩形。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var height

```cangjie
public var height: UInt32
```

**功能：** 矩形高度，以像素为单位。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var left

```cangjie
public var left: Int32
```

**功能：** 矩形左上顶点的Y轴坐标，以像素为单位。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var top

```cangjie
public var top: Int32
```

**功能：** 矩形左上顶点的Y轴坐标，以像素为单位。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var width

```cangjie
public var width: UInt32
```

**功能：** 矩形宽度，以像素为单位。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### init(Int32, Int32, UInt32, UInt32)

```cangjie
public init(
    left!: Int32,
    top!: Int32,
    width!: UInt32,
    height!: UInt32
)
```

**功能：** Rect构造函数。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|left|Int32|是|-| **命名参数。** 矩形左边界坐标。|
|top|Int32|是|-| **命名参数。** 矩形上边界坐标。|
|width|UInt32|是|-| **命名参数。** 矩形宽度。|
|height|UInt32|是|-| **命名参数。** 矩形高度。|

## class WaterfallDisplayAreaRects

```cangjie
public class WaterfallDisplayAreaRects {
    public let left: Rect
    public let top: Rect
    public let right: Rect
    public let bottom: Rect
    public init(
    left!: Rect,
    top!: Rect,
    right!: Rect,
    bottom!: Rect
    )
}
```

**功能：** 瀑布屏的弯曲区域矩形。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### let bottom

```cangjie
public let bottom: Rect
```

**功能：** 瀑布屏底部弯曲区域的大小。

**类型：** [Rect](#class-rect)

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### let left

```cangjie
public let left: Rect
```

**功能：** 瀑布屏左侧弯曲区域的大小。

**类型：** [Rect](#class-rect)

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### let right

```cangjie
public let right: Rect
```

**功能：** 瀑布屏右侧弯曲区域的大小。

**类型：** [Rect](#class-rect)

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### let top

```cangjie
public let top: Rect
```

**功能：** 瀑布屏顶部弯曲区域的大小。

**类型：** [Rect](#class-rect)

**读写能力：** 只读

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### init(Rect, Rect, Rect, Rect)

```cangjie
public init(
    left!: Rect,
    top!: Rect,
    right!: Rect,
    bottom!: Rect
)
```

**功能：** WaterfallDisplayAreaRects构造函数。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|left|[Rect](#class-rect)|是|-| **命名参数。** 左侧弯曲区域。|
|top|[Rect](#class-rect)|是|-| **命名参数。** 顶部弯曲区域。|
|right|[Rect](#class-rect)|是|-| **命名参数。** 右侧弯曲区域。|
|bottom|[Rect](#class-rect)|是|-| **命名参数。** 底部弯曲区域。|

## enum DisplayState

```cangjie
public enum DisplayState <: Equatable<DisplayState> {
    | StateUnknown
    | StateOff
    | StateOn
    | StateDoze
    | StateDozeSuspend
    | StateVr
    | StateOnSuspend
    | ...
}
```

**功能：** 枚举显示状态。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<[DisplayState](#enum-displaystate)>

### StateUnknown

```cangjie
StateUnknown
```

**功能：** 未知状态。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### StateOff

```cangjie
StateOff
```

**功能：** 屏幕关闭。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### StateOn

```cangjie
StateOn
```

**功能：** 屏幕开启。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### StateDoze

```cangjie
StateDoze
```

**功能：** 屏幕打盹，但会针对部分重要系统消息进行更新。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### StateDozeSuspend

```cangjie
StateDozeSuspend
```

**功能：** 屏幕打盹且不更新。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### StateVr

```cangjie
StateVr
```

**功能：** VR模式。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### StateOnSuspend

```cangjie
StateOnSuspend
```

**功能：** 屏幕开启但不更新。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### operator func !=(DisplayState)

```cangjie
public operator func !=(other: DisplayState): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DisplayState](#enum-displaystate)|是|-|要比较的另一个DisplayState实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(DisplayState)

```cangjie
public operator func ==(other: DisplayState): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DisplayState](#enum-displaystate)|是|-|要比较的另一个DisplayState实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## enum FoldDisplayMode

```cangjie
public enum FoldDisplayMode <: Equatable<FoldDisplayMode> {
    | FoldDisplayModeUnknown
    | FoldDisplayModeFull
    | FoldDisplayModeMain
    | FoldDisplayModeSub
    | FoldDisplayModeCoordination
    | ...
}
```

**功能：** 枚举折叠显示模式。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**父类型：**

- Equatable\<[FoldDisplayMode](#enum-folddisplaymode)>

### FoldDisplayModeUnknown

```cangjie
FoldDisplayModeUnknown
```

**功能：** 未知显示模式。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### FoldDisplayModeFull

```cangjie
FoldDisplayModeFull
```

**功能：** 全屏显示模式。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### FoldDisplayModeMain

```cangjie
FoldDisplayModeMain
```

**功能：** 主屏显示模式。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### FoldDisplayModeSub

```cangjie
FoldDisplayModeSub
```

**功能：** 副屏显示模式。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### FoldDisplayModeCoordination

```cangjie
FoldDisplayModeCoordination
```

**功能：** 协同显示模式。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### operator func !=(FoldDisplayMode)

```cangjie
public operator func !=(other: FoldDisplayMode): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FoldDisplayMode](#enum-folddisplaymode)|是|-|要比较的另一个FoldDisplayMode实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(FoldDisplayMode)

```cangjie
public operator func ==(other: FoldDisplayMode): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FoldDisplayMode](#enum-folddisplaymode)|是|-|要比较的另一个FoldDisplayMode实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## enum FoldStatus

```cangjie
public enum FoldStatus <: Equatable<FoldStatus> {
    | FoldStatusUnknown
    | FoldStatusExpanded
    | FoldStatusFolded
    | FoldStatusHalfFolded
    | ...
}
```

**功能：** 枚举折叠状态。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**父类型：**

- Equatable\<[FoldStatus](#enum-foldstatus)>

### FoldStatusUnknown

```cangjie
FoldStatusUnknown
```

**功能：** 折叠状态未知。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### FoldStatusExpanded

```cangjie
FoldStatusExpanded
```

**功能：** 展开状态。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### FoldStatusFolded

```cangjie
FoldStatusFolded
```

**功能：** 折叠状态。对于双折叠轴设备，第一个轴处于折叠状态，第二个轴也处于折叠状态。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### FoldStatusHalfFolded

```cangjie
FoldStatusHalfFolded
```

**功能：** 半折叠状态。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### operator func !=(FoldStatus)

```cangjie
public operator func !=(other: FoldStatus): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FoldStatus](#enum-foldstatus)|是|-|要比较的另一个FoldStatus实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(FoldStatus)

```cangjie
public operator func ==(other: FoldStatus): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FoldStatus](#enum-foldstatus)|是|-|要比较的另一个FoldStatus实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## enum ListenerType

```cangjie
public enum ListenerType <: Equatable<ListenerType> {
    | ListenerTypeAdd
    | ListenerTypeRemove
    | ListenerTypeChange
    | ListenerTypeFoldStatusChange
    | ListenerTypeFoldAngleChange
    | ListenerTypeCaptureStatusChange
    | ListenerTypeFoldDisplayModeChange
    | ListenerTypeAvailableAreaChange
    | ...
}
```

**功能：** 监听事件枚举。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**父类型：**

- Equatable\<[ListenerType](#enum-listenertype)>

### ListenerTypeAdd

```cangjie
ListenerTypeAdd
```

**功能：** 添加显示变化事件类型。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### ListenerTypeRemove

```cangjie
ListenerTypeRemove
```

**功能：** 移除显示变化事件类型。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### ListenerTypeChange

```cangjie
ListenerTypeChange
```

**功能：** 显示变化事件类型。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### ListenerTypeFoldStatusChange

```cangjie
ListenerTypeFoldStatusChange
```

**功能：** 折叠状态变化事件类型。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### ListenerTypeFoldAngleChange

```cangjie
ListenerTypeFoldAngleChange
```

**功能：** 折叠角度变化事件类型。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### ListenerTypeCaptureStatusChange

```cangjie
ListenerTypeCaptureStatusChange
```

**功能：** 捕获状态变化事件类型。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### ListenerTypeFoldDisplayModeChange

```cangjie
ListenerTypeFoldDisplayModeChange
```

**功能：** 折叠显示模式变化事件类型。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### ListenerTypeAvailableAreaChange

```cangjie
ListenerTypeAvailableAreaChange
```

**功能：** 可用区域变化事件类型。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### operator func !=(ListenerType)

```cangjie
public operator func !=(other: ListenerType): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ListenerType](#enum-listenertype)|是|-|要比较的另一个ListenerType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(ListenerType)

```cangjie
public operator func ==(other: ListenerType): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ListenerType](#enum-listenertype)|是|-|要比较的另一个ListenerType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## enum Orientation

```cangjie
public enum Orientation <: Equatable<Orientation> {
    | Portrait
    | Landscape
    | PortraitInverted
    | LandscapeInverted
    | ...
}
```

**功能：** 枚举屏幕方向。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<[Orientation](#enum-orientation)>

### Portrait

```cangjie
Portrait
```

**功能：** 竖屏模式。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### Landscape

```cangjie
Landscape
```

**功能：** 横屏模式。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### PortraitInverted

```cangjie
PortraitInverted
```

**功能：** 竖屏反向模式。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### LandscapeInverted

```cangjie
LandscapeInverted
```

**功能：** 横屏反向模式。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### operator func !=(Orientation)

```cangjie
public operator func !=(other: Orientation): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Orientation](#enum-orientation)|是|-|要比较的另一个Orientation实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(Orientation)

```cangjie
public operator func ==(other: Orientation): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Orientation](#enum-orientation)|是|-|要比较的另一个Orientation实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|