# ohos.window（窗口）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

提供窗口相关功能。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func findWindow(String)

```cangjie
public func findWindow(name: String): Window
```

**功能：** 根据名称查找窗口。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-|窗口名称，即Configuration中的name值。|

**返回值：**

|类型|说明|
|:----|:----|
|[Window](#class-window)|返回找到的窗口。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

## func createWindow(Configuration)

```cangjie
public func createWindow(config: Configuration): Window
```

**功能：** 使用特定配置创建窗口。当config.windowType == TypeFloat时，需要"ohos.permission.SYSTEM_FLOAT_WINDOW"权限。

**需要权限：** ohos.permission.SYSTEM_FLOAT_WINDOW

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|config|[Configuration](#class-configuration)|是|-|窗口创建参数。|

**返回值：**

|类型|说明|
|:----|:----|
|[Window](#class-window)|返回创建的窗口。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |201|Permission verification failed. The application does not have the permission required to call the API.|
  |401|Parameter error. Possible cause: 1. Mandatory parameters are left unspecified;<br>2. Incorrect parameter types.|
  |1300003|This window manager service works abnormally.|
  |1300006|This window context is abnormal.|

## func shiftAppWindowFocus(Int32, Int32)

```cangjie
public func shiftAppWindowFocus(sourceWindowId: Int32, targetWindowId: Int32): Unit
```

**功能：** 在同应用内将窗口焦点从源窗口转移到目标窗口，仅支持应用主窗、子窗范围内的焦点转移。

目标窗口需确保具有获得焦点的能力（可通过[setWindowFocusable()](#func-setwindowfocusablebool)设置），并确保调用[showWindow()](#func-showwindow)成功且执行完毕。

> **说明：**
>
> 在调用shiftAppWindowFocus()前，建议确保目标窗口已调用[loadContent()](#func-loadcontentstring)并生效，否则可能会导致不可见窗口获取焦点，造成功能异常或影响用户体验。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|sourceWindowId|Int32|是|-|焦点转移的源窗口ID。|
|targetWindowId|Int32|是|-|焦点转移的目标窗口ID。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |401|Parameter error. Possible cause: 1. Mandatory parameters are left unspecified;<br>2. Incorrect parameter types.|
  |801|Capability not supported. Failed to call the API due to limited device capabilities.|
  |1300002|This window state is abnormal.|
  |1300003|This window manager service works abnormally.|
  |1300004|Unauthorized operation.|

## func getLastWindow(BaseContext)

```cangjie
public func getLastWindow(ctx: BaseContext): Window
```

**功能：** 获取当前应用程序的顶层窗口。如果没有子窗口，则返回应用程序的主窗口。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|ctx|[BaseContext](../AbilityKit/cj-apis-app-ability.md#class-basecontext)|是|-|当前应用程序上下文。|

**返回值：**

|类型|说明|
|:----|:----|
|[Window](#class-window)|返回获取的顶层窗口。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|
  |1300006|This window context is abnormal.|

## class AvoidArea

```cangjie
public class AvoidArea {
    public var visible: Bool
    public var leftRect: Rect
    public var topRect: Rect
    public var rightRect: Rect
    public var bottomRect: Rect
    public init(
        visible!: Bool,
        leftRect!: Rect,
        topRect!: Rect,
        rightRect!: Rect,
        bottomRect!: Rect
    )
}
```

**功能：** 避免区域。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var bottomRect

```cangjie
public var bottomRect: Rect
```

**功能：** 屏幕底部的矩形。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** [Rect](#class-rect)

**读写能力：** 可读写

**起始版本：** 22

### var leftRect

```cangjie
public var leftRect: Rect
```

**功能：** 屏幕左侧的矩形。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** [Rect](#class-rect)

**读写能力：** 可读写

**起始版本：** 22

### var rightRect

```cangjie
public var rightRect: Rect
```

**功能：** 屏幕右侧的矩形。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** [Rect](#class-rect)

**读写能力：** 可读写

**起始版本：** 22

### var topRect

```cangjie
public var topRect: Rect
```

**功能：** 屏幕顶部的矩形。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** [Rect](#class-rect)

**读写能力：** 可读写

**起始版本：** 22

### var visible

```cangjie
public var visible: Bool
```

**功能：** 避免区域是否在屏幕上可见。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Bool

**读写能力：** 可读写

**起始版本：** 22

### init(Bool, Rect, Rect, Rect, Rect)

```cangjie
public init(
    visible!: Bool,
    leftRect!: Rect,
    topRect!: Rect,
    rightRect!: Rect,
    bottomRect!: Rect
)
```

**功能：** AvoidArea构造函数。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|visible|Bool|是|-| **命名参数。** 避免区域是否可见。|
|leftRect|[Rect](#class-rect)|是|-| **命名参数。** 左侧矩形。|
|topRect|[Rect](#class-rect)|是|-| **命名参数。** 顶部矩形。|
|rightRect|[Rect](#class-rect)|是|-| **命名参数。** 右侧矩形。|
|bottomRect|[Rect](#class-rect)|是|-| **命名参数。** 底部矩形。|

## class Configuration

```cangjie
public class Configuration {
    public var name: String
    public var windowType: WindowType
    public var ctx: BaseContext
    public var displayId: Int64 = -1
    public var parentId: Int64 = -1
    public init(
        name!: String,
        windowType!: WindowType,
        ctx!: BaseContext,
        displayId!: Int64 = -1,
        parentId!: Int64 = -1
    )
}
```

**功能：** 创建子窗口或系统窗口时的参数。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var ctx

```cangjie
public var ctx: BaseContext
```

**功能：** 当前应用上下文信息。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** [BaseContext](../AbilityKit/cj-apis-app-ability.md#class-basecontext)

**读写能力：** 可读写

**起始版本：** 22

### var displayId

```cangjie
public var displayId: Int64 = -1
```

**功能：** 当前物理屏幕ID。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Int64

**读写能力：** 可读写

**起始版本：** 22

### var name

```cangjie
public var name: String
```

**功能：** 窗口名字。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** String

**读写能力：** 可读写

**起始版本：** 22

### var parentId

```cangjie
public var parentId: Int64 = -1
```

**功能：** 父窗口ID。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Int64

**读写能力：** 可读写

**起始版本：** 22

### var windowType

```cangjie
public var windowType: WindowType
```

**功能：** 窗口类型。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** [WindowType](#enum-windowtype)

**读写能力：** 可读写

**起始版本：** 22

### init(String, WindowType, BaseContext, Int64, Int64)

```cangjie
public init(
    name!: String,
    windowType!: WindowType,
    ctx!: BaseContext,
    displayId!: Int64 = -1,
    parentId!: Int64 = -1
)
```

**功能：** Configuration构造函数。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-| **命名参数。** 窗口名称。|
|windowType|[WindowType](#enum-windowtype)|是|-| **命名参数。** 窗口类型。|
|ctx|[BaseContext](../AbilityKit/cj-apis-app-ability.md#class-basecontext)|是|-| **命名参数。** 当前应用上下文信息。|
|displayId|Int64|否|-1| **命名参数。** 当前物理屏幕ID。|
|parentId|Int64|否|-1| **命名参数。** 父窗口ID。|

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

**功能：** 窗口矩形区域。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var height

```cangjie
public var height: UInt32
```

**功能：** 矩形区域的高度，单位为px。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** UInt32

**读写能力：** 可读写

**起始版本：** 22

### var left

```cangjie
public var left: Int32
```

**功能：** 矩形区域的左边界，单位为px。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Int32

**读写能力：** 可读写

**起始版本：** 22

### var top

```cangjie
public var top: Int32
```

**功能：** 矩形区域的上边界，单位为px。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Int32

**读写能力：** 可读写

**起始版本：** 22

### var width

```cangjie
public var width: UInt32
```

**功能：** 矩形区域的宽度，单位为px。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** UInt32

**读写能力：** 可读写

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
|left|Int32|是|-| **命名参数。** 矩形区域的左边界，单位为px。|
|top|Int32|是|-| **命名参数。** 矩形区域的上边界，单位为px。|
|width|UInt32|是|-| **命名参数。** 矩形区域的宽度，单位为px。|
|height|UInt32|是|-| **命名参数。** 矩形区域的高度，单位为px。|

## class Size

```cangjie
public class Size {
    public var width: UInt32
    public var height: UInt32
    public init(
        width!: UInt32,
        height!: UInt32
    )
}
```

**功能：** 窗口大小。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var height

```cangjie
public var height: UInt32
```

**功能：** 窗口的高度。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var width

```cangjie
public var width: UInt32
```

**功能：** 窗口的宽度。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### init(UInt32, UInt32)

```cangjie
public init(
    width!: UInt32,
    height!: UInt32
)
```

**功能：** Size构造函数。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|width|UInt32|是|-| **命名参数。** 窗口宽度。|
|height|UInt32|是|-| **命名参数。** 窗口高度。|

## class SystemBarProperties

```cangjie
public class SystemBarProperties {
    public var statusBarColor: String = "#66000000"
    public var isStatusBarLightIcon: Bool = false
    public var statusBarContentColor: String = "#E5FFFFFF"
    public var navigationBarColor: String = "#66000000"
    public var isNavigationBarLightIcon: Bool = false
    public var navigationBarContentColor: String = "#E5FFFFFF"
    public var enableStatusBarAnimation: Bool = false
    public var enableNavigationBarAnimation: Bool = false
    public init(
        statusBarColor!: String = "#66000000",
        isStatusBarLightIcon!: Bool = false,
        statusBarContentColor!: String = "#E5FFFFFF",
        navigationBarColor!: String = "#66000000",
        isNavigationBarLightIcon!: Bool = false,
        navigationBarContentColor!: String = "#E5FFFFFF",
        enableStatusBarAnimation!: Bool = false,
        enableNavigationBarAnimation!: Bool = false
    )
}
```

**功能：** 状态栏和导航栏的属性，不会自动更新。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var enableNavigationBarAnimation

```cangjie
public var enableNavigationBarAnimation: Bool = false
```

**功能：** 启用导航栏动画。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### var enableStatusBarAnimation

```cangjie
public var enableStatusBarAnimation: Bool = false
```

**功能：** 启用状态栏动画。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### var isNavigationBarLightIcon

```cangjie
public var isNavigationBarLightIcon: Bool = false
```

**功能：** 导航栏浅色图标。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var isStatusBarLightIcon

```cangjie
public var isStatusBarLightIcon: Bool = false
```

**功能：** 状态栏浅色图标。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var navigationBarColor

```cangjie
public var navigationBarColor: String = "#66000000"
```

**功能：** 导航栏颜色。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var navigationBarContentColor

```cangjie
public var navigationBarContentColor: String = "#E5FFFFFF"
```

**功能：** 导航栏内容颜色。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var statusBarColor

```cangjie
public var statusBarColor: String = "#66000000"
```

**功能：** 状态栏颜色。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var statusBarContentColor

```cangjie
public var statusBarContentColor: String = "#E5FFFFFF"
```

**功能：** 状态栏内容颜色。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### init(String, Bool, String, String, Bool, String, Bool, Bool)

```cangjie
public init(
    statusBarColor!: String = "#66000000",
    isStatusBarLightIcon!: Bool = false,
    statusBarContentColor!: String = "#E5FFFFFF",
    navigationBarColor!: String = "#66000000",
    isNavigationBarLightIcon!: Bool = false,
    navigationBarContentColor!: String = "#E5FFFFFF",
    enableStatusBarAnimation!: Bool = false,
    enableNavigationBarAnimation!: Bool = false
)
```

**功能：** SystemBarProperties构造函数。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|statusBarColor|String|否|"#66000000"| **命名参数。** 状态栏颜色。|
|isStatusBarLightIcon|Bool|否|false| **命名参数。** 状态栏浅色图标。|
|statusBarContentColor|String|否|"#E5FFFFFF"| **命名参数。** 状态栏内容颜色。|
|navigationBarColor|String|否|"#66000000"| **命名参数。** 导航栏颜色。|
|isNavigationBarLightIcon|Bool|否|false| **命名参数。** 导航栏浅色图标。|
|navigationBarContentColor|String|否|"#E5FFFFFF"| **命名参数。** 导航栏内容颜色。|
|enableStatusBarAnimation|Bool|否|false| **命名参数。** 启用状态栏动画。|
|enableNavigationBarAnimation|Bool|否|false| **命名参数。** 启用导航栏动画。|

## class TitleButtonRect

```cangjie
public class TitleButtonRect {
    public var right: Int32
    public var top: Int32
    public var width: UInt32
    public var height: UInt32
    public init(
      right!: Int32,
      top!: Int32,
      width!: UInt32,
      height!: UInt32
    )
}
```

**功能：** 标题栏上的最小化、最大化、关闭按钮矩形区域，该区域位置坐标相对窗口右上角。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### var height

```cangjie
public var height: UInt32
```

**功能：** 矩形区域的高度。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### var right

```cangjie
public var right: Int32
```

**功能：** 矩形区域的右边界。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### var top

```cangjie
public var top: Int32
```

**功能：** 矩形区域的上边界。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### var width

```cangjie
public var width: UInt32
```

**功能：** 矩形区域的宽度。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### init(Int32, Int32, UInt32, UInt32)

```cangjie
public init(
    right!: Int32,
    top!: Int32,
    width!: UInt32,
    height!: UInt32
)
```

**功能：** TitleButtonRect构造函数。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|right|Int32|是|-| **命名参数。** 矩形区域的右边界，单位为vp。|
|top|Int32|是|-| **命名参数。** 矩形区域的上边界，单位为vp。|
|width|UInt32|是|-| **命名参数。** 矩形区域的宽度，单位为vp。|
|height|UInt32|是|-| **命名参数。** 矩形区域的高度，单位为vp。|

## class Window

```cangjie
public class Window {}
```

**功能：** 窗口类。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### func destroyWindow()

```cangjie
public func destroyWindow(): Unit
```

**功能：** 销毁此窗口。此API仅对系统窗口或应用程序子窗口生效。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func getWindowAvoidArea(AvoidAreaType)

```cangjie
public func getWindowAvoidArea(areaType: AvoidAreaType): AvoidArea
```

**功能：** 获取避免区域。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|areaType|[AvoidAreaType](#enum-avoidareatype)|是|-|区域类型。|

**返回值：**

|类型|说明|
|:----|:----|
|[AvoidArea](#class-avoidarea)|返回窗口无法显示的区域。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |401|Parameter error. Possible causes:<br> 1. Mandatory parameters are left unspecified. <br>2. Incorrect parameter types. |
  |1300002|This window state is abnormal.|

### func getWindowColorSpace()

```cangjie
public func getWindowColorSpace(): ColorSpace
```

**功能：** 获取设置的颜色空间。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[ColorSpace](#enum-colorspace)|返回获取的颜色空间。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func getWindowProperties()

```cangjie
public func getWindowProperties(): WindowProperties
```

**功能：** 获取当前窗口的属性。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[WindowProperties](#class-windowproperties)|返回窗口属性。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func isWindowShowing()

```cangjie
public func isWindowShowing(): Bool
```

**功能：** 窗口是否显示。值true表示窗口显示，false表示相反。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回窗口是否显示。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func isWideGamutSupported()

```cangjie
public func isWideGamutSupported(): Bool
```

**功能：** 窗口是否支持宽色域设置。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|值true表示支持宽色域颜色空间，false表示相反。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func minimize()

```cangjie
public func minimize(): Unit
```

**功能：** 最小化主窗口（如果调用者是主窗口）。主窗口可以在停靠栏中还原。对于2合1设备，可以通过调用recover()来还原。
隐藏子窗口（如果调用者是子窗口）。子窗口无法在停靠栏中还原。可以通过调用showWindow()再次使其可见。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |801|Capability not supported. Failed to call the API due to limited device capabilities.|
  |1300002|This window state is abnormal.|

### func moveWindowTo(Int32, Int32)

```cangjie
public func moveWindowTo(x: Int32, y: Int32): Unit
```

**功能：** 设置窗口位置。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|Int32|是|-|指示窗口的X坐标。|
|y|Int32|是|-|指示窗口的Y坐标。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func off(WindowCallbackType)

```cangjie
public func off(callbackType: WindowCallbackType): Unit
```

**功能：** 取消注册指定事件的回调。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callbackType|[WindowCallbackType](#enum-windowcallbacktype)|是|-|事件类型。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300016|Parameter error. Possible cause: 1. Mandatory parameters are left unspecified;<br>2. Incorrect parameter types;<br>3. Parameter verification failed.|

### func off(WindowCallbackType, Callback1Argument\<UInt32>)

```cangjie
public func off(callbackType: WindowCallbackType, callback: Callback1Argument<UInt32>): Unit
```

**功能：** 取消注册keyboardHeightChange的回调。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callbackType|[WindowCallbackType](#enum-windowcallbacktype)|是|-|值固定为KeyboardHeightChange，表示键盘高度变化事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<UInt32>|是|-|用于返回当前键盘高度的回调，该高度为整数，单位为px。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300016|Parameter error. Possible cause: 1. Mandatory parameters are left unspecified;<br>2. Incorrect parameter types;<br>3. Parameter verification failed.|

### func on(WindowCallbackType, Callback1Argument\<UInt32>)

```cangjie
public func on(callbackType: WindowCallbackType, callback: Callback1Argument<UInt32>): Unit
```

**功能：** 注册keyboardHeightChange的回调。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callbackType|[WindowCallbackType](#enum-windowcallbacktype)|是|-|值固定为KeyboardHeightChange，表示键盘高度变化事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<UInt32>|是|-|用于返回当前键盘高度的回调，该高度为整数，单位为px。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300016|Parameter error. Possible cause: 1. Mandatory parameters are left unspecified;<br>2. Incorrect parameter types;<br>3. Parameter verification failed.|

### func resetAspectRatio()

```cangjie
public func resetAspectRatio(): Unit
```

**功能：** 重置窗口的宽高比。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|
  |1300004|Unauthorized operation.|

### func resize(UInt32, UInt32)

```cangjie
public func resize(width: UInt32, height: UInt32): Unit
```

**功能：** 设置窗口大小。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|width|UInt32|是|-|指示窗口的宽度。|
|height|UInt32|是|-|指示窗口的高度。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func setAspectRatio(Float64)

```cangjie
public func setAspectRatio(ratio: Float64): Unit
```

**功能：** 设置窗口的宽高比。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|ratio|Float64|是|-|窗口除装饰外的宽高比。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|
  |1300004|Unauthorized operation.|

### func setPreferredOrientation(Orientation)

```cangjie
public func setPreferredOrientation(orientation: Orientation): Unit
```

**功能：** 为主窗口设置首选方向。它不会在不支持传感器旋转的设备上、2合1设备上或子窗口上生效。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|orientation|[Orientation](#enum-orientation)|是|-|窗口的方向配置。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |401|Parameter error. Possible cause: 1. Mandatory parameters are left unspecified;<br>2. Incorrect parameter types.|
  |1300002|This window state is abnormal.|

### func setWindowBackgroundColor(String)

```cangjie
public func setWindowBackgroundColor(color: String): Unit
```

**功能：** 设置窗口背景颜色。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|color|String|是|-|指定的颜色。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |401|Parameter error. Possible cause: 1. Mandatory parameters are left unspecified;<br>2. Incorrect parameter types.|
  |1300002|This window state is abnormal.|

### func setWindowBrightness(Float32)

```cangjie
public func setWindowBrightness(brightness: Float32): Unit
```

**功能：** 设置窗口亮度。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|brightness|Float32|是|-|指定的亮度值。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func setWindowColorSpace(ColorSpace)

```cangjie
public func setWindowColorSpace(colorSpace: ColorSpace): Unit
```

**功能：** 设置指定的颜色空间。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|colorSpace|[ColorSpace](#enum-colorspace)|是|-|指定的颜色空间。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func setWindowFocusable(Bool)

```cangjie
public func setWindowFocusable(isFocusable: Bool): Unit
```

**功能：** 设置是否可获得焦点。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|isFocusable|Bool|是|-|如果为true则可获得焦点，如果为false则不可获得焦点。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func setWindowKeepScreenOn(Bool)

```cangjie
public func setWindowKeepScreenOn(isKeepScreenOn: Bool): Unit
```

**功能：** 设置是否保持屏幕常亮。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|isKeepScreenOn|Bool|是|-|如果为true则保持屏幕常亮，如果为false则不保持。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func setWindowSystemBarEnabled(Array\<SystemBarType>)

```cangjie
public func setWindowSystemBarEnabled(names: Array<SystemBarType>): Unit
```

**功能：** 设置是否显示主窗口的系统栏。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|names|Array\<[SystemBarType](#enum-systembartype)>|是|-|系统栏类型集合。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func setWindowSystemBarProperties(SystemBarProperties)

```cangjie
public func setWindowSystemBarProperties(systemBarProperties: SystemBarProperties): Unit
```

**功能：** 设置系统栏属性。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|systemBarProperties|[SystemBarProperties](#class-systembarproperties)|是|-|系统栏属性。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func setWindowLayoutFullScreen(Bool)

```cangjie
public func setWindowLayoutFullScreen(isLayoutFullScreen: Bool): Unit
```

**功能：** 设置主窗口布局或子窗口布局是否沉浸式。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|isLayoutFullScreen|Bool|是|-|窗口布局是否沉浸式。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func setWindowPrivacyMode(Bool)

```cangjie
public func setWindowPrivacyMode(isPrivacyMode: Bool): Unit
```

**功能：** 设置是否为隐私模式。

**需要权限：** ohos.permission.PRIVACY_WINDOW

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|isPrivacyMode|Bool|是|-|如果为true则为隐私模式，如果为false则不是。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func setWindowSystemBarProperties(SystemBarProperties)

```cangjie
public func setWindowSystemBarProperties(systemBarProperties: SystemBarProperties): Unit
```

**功能：** 设置系统栏属性。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|systemBarProperties|[SystemBarProperties](#class-systembarproperties)|是|-|系统栏属性。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func setWindowTouchable(Bool)

```cangjie
public func setWindowTouchable(isTouchable: Bool): Unit
```

**功能：** 设置是否可触摸。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|isTouchable|Bool|是|-|如果为true则可触摸，如果为false则不可触摸。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func showWindow()

```cangjie
public func showWindow(): Unit
```

**功能：** 显示此窗口。此API仅对系统窗口或应用程序子窗口生效。对于应用程序的主窗口，当主窗口已显示时，此API会将其移到顶部。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func snapshot()

```cangjie
public func snapshot(): PixelMap
```

**功能：** 获取窗口快照。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[PixelMap](../ImageKit/cj-apis-image.md#class-pixelmap)|返回不带值的Promise。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

## class WindowProperties

```cangjie
public class WindowProperties {
    public var windowRect: Rect
    public var drawableRect: Rect
    public var windowType: WindowType
    public var isFullScreen: Bool
    public var isLayoutFullScreen: Bool
    public var focusable: Bool
    public var touchable: Bool
    public var brightness: Float32
    public var isKeepScreenOn: Bool
    public var isPrivacyMode: Bool
    public var isTransparent: Bool
    public var id: UInt32
    public init(
        windowRect!: Rect,
        drawableRect!: Rect,
        windowType!: WindowType,
        isFullScreen!: Bool,
        isLayoutFullScreen!: Bool,
        focusable!: Bool,
        touchable!: Bool,
        brightness!: Float32,
        isKeepScreenOn!: Bool,
        isPrivacyMode!: Bool,
        isTransparent!: Bool,
        id!: UInt32
    )
}
```

**功能：** 窗口属性，不会自动更新。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### var brightness

```cangjie
public var brightness: Float32
```

**功能：** 窗口亮度值。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Float32

**读写能力：** 可读写

**起始版本：** 22

### var drawableRect

```cangjie
public var drawableRect: Rect
```

**功能：** 相对于窗口的位置和可绘制区域大小。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** [Rect](#class-rect)

**读写能力：** 可读写

**起始版本：** 22

### var focusable

```cangjie
public var focusable: Bool
```

**功能：** 窗口是否可以获得焦点。默认值为true。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Bool

**读写能力：** 可读写

**起始版本：** 22

### var id

```cangjie
public var id: UInt32
```

**功能：** 窗口ID。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** UInt32

**读写能力：** 可读写

**起始版本：** 22

### var isFullScreen

```cangjie
public var isFullScreen: Bool
```

**功能：** 窗口是否以全屏模式显示。默认值为false。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Bool

**读写能力：** 可读写

**起始版本：** 22

### var isKeepScreenOn

```cangjie
public var isKeepScreenOn: Bool
```

**功能：** 是否保持屏幕常亮。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Bool

**读写能力：** 可读写

**起始版本：** 22

### var isLayoutFullScreen

```cangjie
public var isLayoutFullScreen: Bool
```

**功能：** 窗口布局是否为全屏模式（窗口是否沉浸式）。默认值为false。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Bool

**读写能力：** 可读写

**起始版本：** 22

### var isPrivacyMode

```cangjie
public var isPrivacyMode: Bool
```

**功能：** 是否处于隐私模式。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Bool

**读写能力：** 可读写

**起始版本：** 22

### var isTransparent

```cangjie
public var isTransparent: Bool
```

**功能：** 是否透明。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Bool

**读写能力：** 可读写

**起始版本：** 22

### var touchable

```cangjie
public var touchable: Bool
```

**功能：** 窗口是否可触摸。默认值为false。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** Bool

**读写能力：** 可读写

**起始版本：** 22

### var windowType

```cangjie
public var windowType: WindowType
```

**功能：** 窗口类型。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** [WindowType](#enum-windowtype)

**读写能力：** 可读写

**起始版本：** 22

### var windowRect

```cangjie
public var windowRect: Rect
```

**功能：** 窗口的位置和大小。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**类型：** [Rect](#class-rect)

**读写能力：** 可读写

**起始版本：** 22

### init(Rect, Rect, WindowType, Bool, Bool, Bool, Bool, Float32, Bool, Bool, Bool, UInt32)

```cangjie
public init(
    windowRect!: Rect,
    drawableRect!: Rect,
    windowType!: WindowType,
    isFullScreen!: Bool,
    isLayoutFullScreen!: Bool,
    focusable!: Bool,
    touchable!: Bool,
    brightness!: Float32,
    isKeepScreenOn!: Bool,
    isPrivacyMode!: Bool,
    isTransparent!: Bool,
    id!: UInt32
)
```

**功能：** WindowProperties构造函数。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|windowRect|[Rect](#class-rect)|是|-| **命名参数。** 窗口矩形。|
|drawableRect|[Rect](#class-rect)|是|-| **命名参数。** 可绘制矩形。|
|windowType|[WindowType](#enum-windowtype)|是|-| **命名参数。** 窗口类型。|
|isFullScreen|Bool|是|-| **命名参数。** 是否全屏。|
|isLayoutFullScreen|Bool|是|-| **命名参数。** 是否布局全屏。|
|focusable|Bool|是|-| **命名参数。** 是否可获得焦点。|
|touchable|Bool|是|-| **命名参数。** 是否可触摸。|
|brightness|Float32|是|-| **命名参数。** 亮度值。|
|isKeepScreenOn|Bool|是|-| **命名参数。** 是否保持屏幕常亮。|
|isPrivacyMode|Bool|是|-| **命名参数。** 是否隐私模式。|
|isTransparent|Bool|是|-| **命名参数。** 是否透明。|
|id|UInt32|是|-| **命名参数。** 窗口ID。|

## class WindowStage

```cangjie
public class WindowStage {}
```

**功能：** 窗口管理器。管理各个基本窗口单元，即[Window](#class-window)实例。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### func createSubWindow(String)

```cangjie
public func createSubWindow(name: String): Window
```

**功能：** 创建该WindowStage实例下的子窗口。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-|子窗口名称。|

**返回值：**

|类型|说明|
|:----|:----|
|[Window](#class-window)|返回子窗口。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func getMainWindow()

```cangjie
public func getMainWindow(): Window
```

**功能：** 获取此窗口阶段的主窗口。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[Window](#class-window)|返回主窗口。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func getSubWindow()

```cangjie
public func getSubWindow(): Array<Window>
```

**功能：** 获取此窗口阶段的所有子窗口。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[Window](#class-window)>|返回所有子窗口。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[窗口错误码](./cj-errorcode-window.md)。

  |错误码|说明|
  |:----|:----|
  |1300002|This window state is abnormal.|

### func loadContent(String)

```cangjie
public func loadContent(path: String): Unit
```

**功能：** 将页面内容加载到此窗口。建议在UIAbility启动期间调用此API。
如果多次调用，此API将在加载新内容之前销毁现有页面内容(UIContent)。使用时请谨慎。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|path|String|是|-|将加载内容的页面路径。|

## enum AvoidAreaType

```cangjie
public enum AvoidAreaType <: Equatable<AvoidAreaType> {
    | TypeSystem
    | TypeCutout
    | TypeSystemGesture
    | TypeKeyboard
    | TypeNavigationIndicator
    | ...
}
```

**功能：** 描述避免区域类型。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<[AvoidAreaType](#enum-avoidareatype)>

### TypeSystem

```cangjie
TypeSystem
```

**功能：** 系统默认区域。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### TypeCutout

```cangjie
TypeCutout
```

**功能：** 刘海屏区域。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### TypeSystemGesture

```cangjie
TypeSystemGesture
```

**功能：** 系统手势区域。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### TypeKeyboard

```cangjie
TypeKeyboard
```

**功能：** 键盘区域。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### TypeNavigationIndicator

```cangjie
TypeNavigationIndicator
```

**功能：** 导航指示器区域。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### operator func !=(AvoidAreaType)

```cangjie
public operator func !=(other: AvoidAreaType): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AvoidAreaType](#enum-avoidareatype)|是|-|要比较的另一个AvoidAreaType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(AvoidAreaType)

```cangjie
public operator func ==(other: AvoidAreaType): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AvoidAreaType](#enum-avoidareatype)|是|-|要比较的另一个AvoidAreaType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## enum ColorSpace

```cangjie
public enum ColorSpace <: Equatable<ColorSpace> {
    | Default
    | WideGamut
    | ...
}
```

**功能：** 允许指定的颜色空间类型。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<[ColorSpace](#enum-colorspace)>

### Default

```cangjie
Default
```

**功能：** 默认颜色空间。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### WideGamut

```cangjie
WideGamut
```

**功能：** 宽色域颜色空间。具体宽色域取决于屏幕。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### operator func !=(ColorSpace)

```cangjie
public operator func !=(other: ColorSpace): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ColorSpace](#enum-colorspace)|是|-|要比较的另一个ColorSpace实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(ColorSpace)

```cangjie
public operator func ==(other: ColorSpace): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ColorSpace](#enum-colorspace)|是|-|要比较的另一个ColorSpace实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## enum Orientation

```cangjie
public enum Orientation <: Equatable<Orientation> {
    | Unspecified
    | Portrait
    | Landscape
    | PortraitInverted
    | LandscapeInverted
    | AutoRotation
    | AutoRotationPortrait
    | AutoRotationLandscape
    | AutoRotationRestricted
    | AutoRotationPortraitRestricted
    | AutoRotationLandscapeRestricted
    | Locked
    | ...
}
```

**功能：** 显示方向。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<[Orientation](#enum-orientation)>

### Unspecified

```cangjie
Unspecified
```

**功能：** 默认值。方向模式未明确定义，由系统决定。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### Portrait

```cangjie
Portrait
```

**功能：** 竖屏显示。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### Landscape

```cangjie
Landscape
```

**功能：** 横屏显示。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### PortraitInverted

```cangjie
PortraitInverted
```

**功能：** 倒置竖屏显示。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### LandscapeInverted

```cangjie
LandscapeInverted
```

**功能：** 倒置横屏显示。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### AutoRotation

```cangjie
AutoRotation
```

**功能：** 跟随传感器旋转，忽略自动旋转锁定。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### AutoRotationPortrait

```cangjie
AutoRotationPortrait
```

**功能：** 跟随传感器旋转，仅在竖直方向工作，忽略自动旋转锁定。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### AutoRotationLandscape

```cangjie
AutoRotationLandscape
```

**功能：** 跟随传感器旋转，仅在水平方向工作，忽略自动旋转锁定。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### AutoRotationRestricted

```cangjie
AutoRotationRestricted
```

**功能：** 跟随传感器旋转，受自动旋转锁定控制。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### AutoRotationPortraitRestricted

```cangjie
AutoRotationPortraitRestricted
```

**功能：** 跟随传感器旋转，仅在竖直方向工作，受自动旋转锁定控制。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### AutoRotationLandscapeRestricted

```cangjie
AutoRotationLandscapeRestricted
```

**功能：** 跟随传感器旋转，仅在水平方向工作，受自动旋转锁定控制。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### Locked

```cangjie
Locked
```

**功能：** 锁定模式，保持与之前相同的方向。

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

## enum SystemBarType

```cangjie
public enum SystemBarType <: Equatable<SystemBarType> {
    | Status
    | Navigation
    | ...
}
```

**功能：** 系统栏类型枚举。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<[SystemBarType](#enum-systembartype)>

### Status

```cangjie
Status
```

**功能：** 状态栏。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### Navigation

```cangjie
Navigation
```

**功能：** 导航栏。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### operator func !=(SystemBarType)

```cangjie
public operator func !=(other: SystemBarType): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SystemBarType](#enum-systembartype)|是|-|要比较的另一个SystemBarType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(SystemBarType)

```cangjie
public operator func ==(other: SystemBarType): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SystemBarType](#enum-systembartype)|是|-|要比较的另一个SystemBarType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## enum WindowCallbackType

```cangjie
public enum WindowCallbackType <: Equatable<WindowCallbackType> {
    | WindowStageEvent
    | WindowSizeChange
    | WindowAvoidAreaChange
    | KeyboardHeightChange
    | TouchOutside
    | WindowVisibilityChange
    | NoInteractionDetected
    | Screenshot
    | DialogTargetTouch
    | WindowEvent
    | WindowStatusChange
    | SubWindowClose
    | WindowTitleButtonRectChange
    | WindowRectChange
    | ...
}
```

**功能：** 监听事件枚举。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<[WindowCallbackType](#enum-windowcallbacktype)>

### WindowStageEvent

```cangjie
WindowStageEvent
```

**功能：** 表示窗口阶段生命周期变化事件。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### WindowSizeChange

```cangjie
WindowSizeChange
```

**功能：** 表示窗口大小变化事件。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### WindowAvoidAreaChange

```cangjie
WindowAvoidAreaChange
```

**功能：** 表示避免区域变化事件。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### KeyboardHeightChange

```cangjie
KeyboardHeightChange
```

**功能：** 表示键盘高度变化事件。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### TouchOutside

```cangjie
TouchOutside
```

**功能：** 表示窗口外部点击事件。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### WindowVisibilityChange

```cangjie
WindowVisibilityChange
```

**功能：** 表示窗口可见性变化。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### NoInteractionDetected

```cangjie
NoInteractionDetected
```

**功能：** 表示窗口长时间无交互。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### Screenshot

```cangjie
Screenshot
```

**功能：** 表示截图事件。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### DialogTargetTouch

```cangjie
DialogTargetTouch
```

**功能：** 表示模态窗口模式下目标窗口点击事件。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### WindowEvent

```cangjie
WindowEvent
```

**功能：** 表示窗口生命周期变化事件。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### WindowStatusChange

```cangjie
WindowStatusChange
```

**功能：** 表示窗口状态变化事件。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### SubWindowClose

```cangjie
SubWindowClose
```

**功能：** 表示子窗口关闭事件。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### WindowTitleButtonRectChange

```cangjie
WindowTitleButtonRectChange
```

**功能：** 表示标题按钮区域变化事件。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### WindowRectChange

```cangjie
WindowRectChange
```

**功能：** 表示窗口矩形变化事件。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### operator func !=(WindowCallbackType)

```cangjie
public operator func !=(other: WindowCallbackType): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WindowCallbackType](#enum-windowcallbacktype)|是|-|要比较的另一个WindowCallbackType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(WindowCallbackType)

```cangjie
public operator func ==(other: WindowCallbackType): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WindowCallbackType](#enum-windowcallbacktype)|是|-|要比较的另一个WindowCallbackType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## enum WindowEventType

```cangjie
public enum WindowEventType <: Equatable<WindowEventType> {
    | WindowShown
    | WindowActive
    | WindowInactive
    | WindowHidden
    | WindowDestroyed
    | ...
}
```

**功能：** 窗口回调事件类型枚举。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<[WindowEventType](#enum-windoweventtype)>

### WindowShown

```cangjie
WindowShown
```

**功能：** 窗口显示事件值。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### WindowActive

```cangjie
WindowActive
```

**功能：** 窗口激活事件值。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### WindowInactive

```cangjie
WindowInactive
```

**功能：** 窗口非激活事件值。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### WindowHidden

```cangjie
WindowHidden
```

**功能：** 窗口隐藏事件值。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### WindowDestroyed

```cangjie
WindowDestroyed
```

**功能：** 窗口销毁事件值。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### operator func !=(WindowEventType)

```cangjie
public operator func !=(other: WindowEventType): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WindowEventType](#enum-windoweventtype)|是|-|要比较的另一个WindowEventType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(WindowEventType)

```cangjie
public operator func ==(other: WindowEventType): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WindowEventType](#enum-windoweventtype)|是|-|要比较的另一个WindowEventType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## enum WindowStageEventType

```cangjie
public enum WindowStageEventType <: Equatable<WindowStageEventType> {
    | Shown
    | Active
    | Inactive
    | Hidden
    | Resumed
    | Paused
    | ...
}
```

**功能：** 窗口阶段回调事件类型。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<[WindowStageEventType](#enum-windowstageeventtype)>

### Shown

```cangjie
Shown
```

**功能：** 窗口阶段在前台运行。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### Active

```cangjie
Active
```

**功能：** 窗口阶段获得焦点。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### Inactive

```cangjie
Inactive
```

**功能：** 窗口阶段失去焦点。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### Hidden

```cangjie
Hidden
```

**功能：** 窗口阶段在后台运行。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### Resumed

```cangjie
Resumed
```

**功能：** 窗口阶段在前台交互。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### Paused

```cangjie
Paused
```

**功能：** 窗口阶段在前台非交互。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### operator func !=(WindowStageEventType)

```cangjie
public operator func !=(other: WindowStageEventType): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WindowStageEventType](#enum-windowstageeventtype)|是|-|要比较的另一个WindowStageEventType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(WindowStageEventType)

```cangjie
public operator func ==(other: WindowStageEventType): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WindowStageEventType](#enum-windowstageeventtype)|是|-|要比较的另一个WindowStageEventType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## enum WindowStatusType

```cangjie
public enum WindowStatusType <: Equatable<WindowStatusType> {
    | Undefined
    | FullScreen
    | Maximize
    | Minimize
    | Floating
    | SplitScreen
    | ...
}
```

**功能：** 描述应用程序的窗口状态。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**父类型：**

- Equatable\<[WindowStatusType](#enum-windowstatustype)>

### Undefined

```cangjie
Undefined
```

**功能：** 窗口未定义状态。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### FullScreen

```cangjie
FullScreen
```

**功能：** 窗口全屏状态。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### Maximize

```cangjie
Maximize
```

**功能：** 窗口最大化状态。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### Minimize

```cangjie
Minimize
```

**功能：** 窗口最小化状态。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### Floating

```cangjie
Floating
```

**功能：** 窗口浮动状态。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### SplitScreen

```cangjie
SplitScreen
```

**功能：** 窗口分屏状态。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

### operator func !=(WindowStatusType)

```cangjie
public operator func !=(other: WindowStatusType): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WindowStatusType](#enum-windowstatustype)|是|-|要比较的另一个WindowStatusType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(WindowStatusType)

```cangjie
public operator func ==(other: WindowStatusType): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.Window.SessionManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WindowStatusType](#enum-windowstatustype)|是|-|要比较的另一个WindowStatusType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## enum WindowType

```cangjie
public enum WindowType <: Equatable<WindowType> {
    | TypeApp
    | TypeMain
    | TypeFloat
    | TypeDialog
    | ...
}
```

**功能：** 窗口类型。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<[WindowType](#enum-windowtype)>

### TypeApp

```cangjie
TypeApp
```

**功能：** 应用程序窗口。此窗口类型不支持在创建窗口时使用，仅可在[getWindowProperties](#func-getwindowproperties)接口的返回值中用于读取。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### TypeMain

```cangjie
TypeMain
```

**功能：** 应用主窗口。此窗口类型不支持在创建窗口时使用，仅可在[getWindowProperties](#func-getwindowproperties)接口的返回值中用于读取。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### TypeFloat

```cangjie
TypeFloat
```

**功能：** 浮动窗口。需要"ohos.permission.SYSTEM_FLOAT_WINDOW"权限。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### TypeDialog

```cangjie
TypeDialog
```

**功能：** 对话框窗口。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

### operator func !=(WindowType)

```cangjie
public operator func !=(other: WindowType): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WindowType](#enum-windowtype)|是|-|要比较的另一个WindowType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(WindowType)

```cangjie
public operator func ==(other: WindowType): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.WindowManager.WindowManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WindowType](#enum-windowtype)|是|-|要比较的另一个WindowType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## 示例代码

### 示例1（获取主窗口设置不可触属性）

设置主窗口属性为不可触后，点击页面中的按钮将不会有弹窗。

<!-- run -example1 -->

```cangjie
// main_ability.cj

package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.app.ability.ui_ability.*

class MainAbility <: UIAbility {
    public init() {
        super()
        registerSelf()
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        // 1.获取应用主窗口。
        var window: Window = windowStage.getMainWindow()

        // 2.设置窗口主属性。以设置 ”是否可触“ 属性为例。
        window.setWindowTouchable(false)

        // 3. 为主窗口加载对应的目标页面
        windowStage.loadContent("newPage")
    }
}
```

<!-- run -example1 -->

```cangjie
// newPage.cj

package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class newPage{
    func build(){
        Flex(justifyContent: FlexAlign.Center ,alignItems: ItemAlign.Center) {
            Column{
                Text("New Page")
                Button("Untouchable").onClick({ evt
                    => AlertDialogParamWithConfirm(message:"Unreachable")
                }).margin(10.vp)
            }.margin(10.vp)
        }
    }
}
```

![img1](figures/window_touchable_is_false.png)

### 示例2（主窗口监听键盘高度变化事件）

<!-- run -example2 -->

```cangjie
// main_ability.cj

package ohos_app_cangjie_entry

import ohos.app.ability.ui_ability.*
import kit.ArkUI.*

class MainAbility <: UIAbility {

    public init() {
        super()
        registerSelf()
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        windowStage.loadContent("newPage")
        // 将该Ability的窗口管理器传入AppStorage中
        AppStorage.setOrCreate("windowStage",windowStage)
    }
}
```

<!-- run -example2 -->

```cangjie
//newPage.cj

package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.hilog.*
import ohos.arkui.state_macro_manage.*
import ohos.callback_invoke.*
import ohos.business_exception.BusinessException

@Entry
@Component
class newPage{

    public override func onPageShow(){
        let windowStage: WindowStage = AppStorage.get<WindowStage>("windowStage").getOrThrow()
        let mainWindow: Window = windowStage.getMainWindow()

        // 开启监听
        var tmp: Unit = mainWindow.on(WindowCallbackType.KeyboardHeightChange,TestCallback(0))
    }

    func build(){
        Flex(justifyContent: FlexAlign.Center ,alignItems: ItemAlign.Center) {
            Column{
                TextInput(placeholder: 'input some words here... ').margin(10.vp)
            }.margin(10.vp)
        }
    }
}

public class TestCallback <: Callback1Argument<UInt32>{

    var count: Int64

    public init(count: Int64){
        this.count = count
    }

    public func invoke(err: ?BusinessException, value: UInt32): Unit {
        count++
        // 拉起或隐藏键盘时，会触发日志打印总计的键盘高度变化计数
        Hilog.info(0,"","KeyboardHeightChangeCount: ${this.count}")
    }
}
```

运行后点击文本框触发回调，在日志中查看效果，打印日志如下。

```text
KeyboardHeightChangeCount: 1
KeyboardHeightChangeCount: 2
KeyboardHeightChangeCount: 3
```

![img3](figures/window_subwindow_created.png)
