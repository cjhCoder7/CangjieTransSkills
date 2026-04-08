# 自定义弹窗（CustomDialog）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

通过CustomDialogController类显示自定义弹窗。使用弹窗组件时，可优先考虑自定义弹窗，便于自定义弹窗的样式与内容。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## class CustomDialogController

```cangjie
public class CustomDialogController {
    public init(value: CustomDialogControllerOptions)
}
```

**功能：** 构造一个CustomDialogController类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(CustomDialogControllerOptions)

```cangjie
public init(value: CustomDialogControllerOptions)
```

**功能：** 创建自定义弹窗的构造器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|[CustomDialogControllerOptions](#class-customdialogcontrolleroptions)|是|-|配置自定义弹窗的参数。|

### func closeDialog()

```cangjie
public func closeDialog(): Unit
```

**功能：** 关闭显示的自定义弹窗，若已关闭，则不生效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func openDialog()

```cangjie
public func openDialog(): Unit
```

**功能：** 显示自定义弹窗内容，允许多次使用，但如果弹框为SubWindow模式，则该弹框不允许再弹出SubWindow弹框。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func releaseSelf()

```cangjie
public func releaseSelf(): Unit
```

**功能：** UI框架使用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## class CustomDialogControllerOptions

```cangjie
public class CustomDialogControllerOptions {
    public var cancel: ?VoidCallback
    public var autoCancel: ?Bool
    public var alignment: ?DialogAlignment
    public var offset: ?Offset
    public var customStyle: ?Bool
    public var gridCount: ?UInt32
    public var maskColor: ?ResourceColor
    public var maskRect: ?Rectangle
    public var openAnimation: ?AnimateParam
    public var closeAnimation: ?AnimateParam
    public var showInSubWindow: ?Bool
    public var backgroundColor: ?ResourceColor
    public var cornerRadius: ?Length
    public var isModal: ?Bool
    public var onWillDismiss: ?Callback<DismissDialogAction, Unit>
    public var width: ?Length
    public var height: ?Length
    public var borderWidth: ?Length
    public var borderColor: ?ResourceColor
    public var borderStyle: ?EdgeStyles
    public var shadow: ?ShadowOptions
    public var backgroundBlurStyle: ?BlurStyle
    public init(
        builder!: CustomView,
        cancel!: ?VoidCallback = None,
        autoCancel!: ?Bool = None,
        alignment!: ?DialogAlignment = None,
        offset!: ?Offset = None,
        customStyle!: ?Bool = None,
        gridCount!: ?UInt32 = None,
        maskColor!: ?ResourceColor = None,
        maskRect!: ?Rectangle = None,
        openAnimation!: ?AnimateParam = None,
        closeAnimation!: ?AnimateParam = None,
        showInSubWindow!: ?Bool = None,
        backgroundColor!: ?ResourceColor = None,
        cornerRadius!: ?Length = None,
        isModal!: ?Bool = None,
        onWillDismiss!: ?Callback<DismissDialogAction, Unit> = None,
        width!: ?Length = None,
        height!: ?Length = None,
        borderWidth!: ?Length = None,
        borderColor!: ?ResourceColor = None,
        borderStyle!: ?EdgeStyles = None,
        shadow!: ?ShadowOptions = None,
        backgroundBlurStyle!: ?BlurStyle = None
    )
}
```

**功能：** 声明自定义弹窗相关设置的参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var alignment

```cangjie
public var alignment: ?DialogAlignment
```

**功能：** 弹窗在竖直方向上的对齐方式。初始值：DialogAlignment.Default

**类型：** ?[DialogAlignment](./cj-common-types.md#enum-dialogalignment)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var autoCancel

```cangjie
public var autoCancel: ?Bool
```

**功能：** 是否允许点击遮障层退出。true表示关闭弹窗，false表示不关闭弹窗。初始值：true

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var backgroundBlurStyle

```cangjie
public var backgroundBlurStyle: ?BlurStyle
```

**功能：** 弹窗背板模糊材质。初始值：BlurStyle.ComponentUltraThick

**类型：** ?[BlurStyle](./cj-common-types.md#enum-blurstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var backgroundColor

```cangjie
public var backgroundColor: ?ResourceColor
```

**功能：** 设置弹窗背板填充。初始值：Color.Transparent

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var borderColor

```cangjie
public var borderColor: ?ResourceColor
```

**功能：** 设置弹窗背板的边框颜色。初始值：Color.Black

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var borderStyle

```cangjie
public var borderStyle: ?EdgeStyles
```

**功能：** 设置弹窗背板的边框样式。初始值：EdgeStyles()

**类型：** ?[EdgeStyles](./cj-common-types.md#class-edgestyles)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var borderWidth

```cangjie
public var borderWidth: ?Length
```

**功能：** 设置弹窗背板的边框宽度。初始值：0.vp

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var cancel

```cangjie
public var cancel: ?VoidCallback
```

**功能：** 返回、ESC键和点击遮障层弹窗退出时的回调。初始值： { => }

**类型：** ?[VoidCallback](./cj-common-types.md#type-voidcallback)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var closeAnimation

```cangjie
public var closeAnimation: ?AnimateParam
```

**功能：** 自定义设置弹窗关闭的动画效果相关参数。

**类型：** ?[AnimateParam](./cj-common-types.md#class-animateparam)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var cornerRadius

```cangjie
public var cornerRadius: ?Length
```

**功能：** 设置背板的圆角半径。初始值：32.vp

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var customStyle

```cangjie
public var customStyle: ?Bool
```

**功能：** 弹窗容器样式是否自定义。初始值：false

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var gridCount

```cangjie
public var gridCount: ?UInt32
```

**功能：** 弹窗宽度占栅格宽度的个数。

**类型：** ?UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var height

```cangjie
public var height: ?Length
```

**功能：** 设置弹窗背板的高度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var isModal

```cangjie
public var isModal: ?Bool
```

**功能：** 弹窗是否为模态窗口，模态窗口有蒙层，非模态窗口无蒙层。初始值：true

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var maskColor

```cangjie
public var maskColor: ?ResourceColor
```

**功能：** 自定义蒙层颜色。初始值：Color(0x33000000)

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var maskRect

```cangjie
public var maskRect: ?Rectangle
```

**功能：** 弹窗遮蔽层区域，在遮蔽层区域内的事件不透传，在遮蔽层区域外的事件透传。初始值：Rectangle()

**类型：** ?[Rectangle](./cj-common-types.md#class-rectangle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var offset

```cangjie
public var offset: ?Offset
```

**功能：** 弹窗相对alignment所在位置的偏移量。初始值：Offset(0.vp, 0.vp)

**类型：** ?[Offset](./cj-common-types.md#class-offset)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var onWillDismiss

```cangjie
public var onWillDismiss: ?Callback<DismissDialogAction, Unit>
```

**功能：** 交互式关闭回调函数。

**类型：** ?[Callback](./cj-common-types.md#type-callbackt-v)\<[DismissDialogAction](./cj-dialog-actionsheet.md#class-dismissdialogaction),Unit>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var openAnimation

```cangjie
public var openAnimation: ?AnimateParam
```

**功能：** 自定义设置弹窗弹出的动画效果相关参数。

**类型：** ?[AnimateParam](./cj-common-types.md#class-animateparam)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var shadow

```cangjie
public var shadow: ?ShadowOptions
```

**功能：** 设置弹窗背板的阴影。

**类型：** ?[ShadowOptions](./cj-common-types.md#class-shadowoptions)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var showInSubWindow

```cangjie
public var showInSubWindow: ?Bool
```

**功能：** 某弹框需要显示在主窗口之外时，是否在子窗口显示此弹窗。初始值：false

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var width

```cangjie
public var width: ?Length
```

**功能：** 设置弹窗背板的宽度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(CustomView, ?VoidCallback, ?Bool, ?DialogAlignment, ?Offset, ?Bool, ?UInt32, ?ResourceColor, ?Rectangle, ?AnimateParam, ?AnimateParam, ?Bool, ?ResourceColor, ?Length, ?Bool, ?Callback\<DismissDialogAction,Unit>, ?Length, ?Length, ?Length, ?ResourceColor, ?EdgeStyles, ?ShadowOptions, ?BlurStyle)

```cangjie
public init(
    builder!: CustomView,
    cancel!: ?VoidCallback = None,
    autoCancel!: ?Bool = None,
    alignment!: ?DialogAlignment = None,
    offset!: ?Offset = None,
    customStyle!: ?Bool = None,
    gridCount!: ?UInt32 = None,
    maskColor!: ?ResourceColor = None,
    maskRect!: ?Rectangle = None,
    openAnimation!: ?AnimateParam = None,
    closeAnimation!: ?AnimateParam = None,
    showInSubWindow!: ?Bool = None,
    backgroundColor!: ?ResourceColor = None,
    cornerRadius!: ?Length = None,
    isModal!: ?Bool = None,
    onWillDismiss!: ?Callback<DismissDialogAction, Unit> = None,
    width!: ?Length = None,
    height!: ?Length = None,
    borderWidth!: ?Length = None,
    borderColor!: ?ResourceColor = None,
    borderStyle!: ?EdgeStyles = None,
    shadow!: ?ShadowOptions = None,
    backgroundBlurStyle!: ?BlurStyle = None
)
```

**功能：** 创建一个CustomDialogControllerOptions对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|builder|CustomView|是|-| **命名参数。** 自定义弹窗内容构造器。|
|cancel|?[VoidCallback](./cj-common-types.md#type-voidcallback)|否|None| **命名参数。** 返回、ESC键和点击遮障层弹窗退出时的回调。初始值: { => }|
|autoCancel|?Bool|否|None| **命名参数。** 是否允许点击遮障层退出，true表示关闭弹窗。false表示不关闭弹窗。初始值: true|
|alignment|?[DialogAlignment](./cj-common-types.md#enum-dialogalignment)|否|None| **命名参数。** 弹窗在竖直方向上的对齐方式。初始值: DialogAlignment.Default|
|offset|?[Offset](./cj-common-types.md#class-offset)|否|None| **命名参数。** 弹窗相对alignment所在位置的偏移量。初始值: Offset(0.vp, 0.vp)|
|customStyle|?Bool|否|None| **命名参数。**  弹窗容器样式是否自定义。初始值: false<br>设置为false时（默认值）：<br/>1、圆角为32.vp。<br/>2、未设置弹窗宽度高度：弹窗容器的宽度根据栅格系统自适应。高度自适应自定义的内容节点。<br/>3、设置弹窗宽度高度：弹窗容器的宽度不超过默认样式下的最大宽度（自定义节点设置100%的宽度），弹窗容器的高度不超过默认样式下的最大高度（自定义节点设置100%的高度）。<br/>设置为true时：<br/>1、圆角为0，弹窗背景色为透明色。<br/>2、不支持设置弹窗宽度、高度、边框宽度、边框样式、边框颜色以及阴影宽度。|
|gridCount|?UInt32|否|None| **命名参数。** 弹窗宽度占栅格宽度的个数。<br>默认为按照窗口大小自适应，异常值按默认值处理，最大栅格数为系统最大栅格数。|
|maskColor|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|None| **命名参数。** 自定义蒙层颜色。初始值: Color(0x33000000)|
|maskRect|?[Rectangle](./cj-common-types.md#class-rectangle)|否|None| **命名参数。** 弹窗遮蔽层区域，在遮蔽层区域内的事件不透传，在遮蔽层区域外的事件透传。初始值: Rectangle() <br/>**说明：**<br/>showInSubWindow为true时，maskRect不生效。|
|openAnimation|?[AnimateParam](./cj-common-types.md#class-animateparam)|否|None| **命名参数。** 自定义设置弹窗弹出的动画效果相关参数。<br>**说明**：<br>tempo默认值为1，当设置小于等于0的值时按默认值处理。<br/>iterations默认值为1，默认播放一次，设置为其他数值时按默认值处理。<br>playMode控制动画播放模式，默认值为PlayMode.Normal，设置为其他数值时按照默认值处理。|
|closeAnimation|?[AnimateParam](./cj-common-types.md#class-animateparam)|否|None| **命名参数。** 自定义设置弹窗关闭的动画效果相关参数。<br>**说明**：<br>tempo默认值为1，当设置小于等于0的值时按默认值处理。<br/>iterations默认值为1，默认播放一次，设置为其他数值时按默认值处理。<br>playMode控制动画播放模式，默认值为PlayMode.Normal，设置为其他数值时按照默认值处理。<br/>页面转场切换时，建议使用默认关闭动效。|
|showInSubWindow|?Bool|否|None| **命名参数。** 某弹框需要显示在主窗口之外时，是否在子窗口显示此弹窗。初始值: false<br>初始值：false，弹窗显示在应用内，而非独立子窗口。<br>**说明**：showInSubWindow为true的弹窗无法触发显示另一个showInSubWindow为true的弹窗。|
|backgroundColor|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|None| **命名参数。** 设置弹窗背板填充。初始值: Color.Transparent<br/>**说明：** 如果同时设置了内容构造器的背景色，则backgroundColor会被内容构造器的背景色覆盖。<br/>当设置了backgroundColor为非透明色时，backgroundBlurStyle需要设置为BlurStyle.NONE，否则颜色显示将不符合预期效果。|
|cornerRadius|?[Length](./cj-common-types.md#interface-length)|否|None| **命名参数。** 设置背板的圆角半径。初始值: 32.vp<br/>可分别设置4个圆角的半径。<br/>**说明**：自定义弹窗默认的背板圆角半径为32.vp，如果需要使用cornerRadius属性，请和[borderRadius](./cj-universal-attribute-border.md#func-borderradiuslength-length-length-length)属性一起使用。|
|isModal|?Bool|否|None| **命名参数。** 弹窗是否为模态窗口，模态窗口有蒙层，非模态窗口无蒙层。初始值: true|
|onWillDismiss|?[Callback](./cj-common-types.md#type-callbackt-v)\<[DismissDialogAction](./cj-dialog-actionsheet.md#class-dismissdialogaction),Unit>|否|None| **命名参数。** 交互式关闭回调函数。<br/>**说明：**<br/>1.当用户执行点击遮障层关闭、左滑/右滑、三键back、键盘ESC关闭交互操作时，如果注册该回调函数，则不会立刻关闭弹窗。在回调函数中可以通过reason得到阻拦关闭弹窗的操作类型，从而根据原因选择是否能关闭弹窗。当前组件返回的reason中，暂不支持CloseButton的枚举值。<br/>2.在onWillDismiss回调中，不能再做onWillDismiss拦截。|
|width|?[Length](./cj-common-types.md#interface-length)|否|None| **命名参数。** 设置弹窗背板的宽度。<br/>**说明：**<br>- 弹窗宽度默认最大值：400.vp。<br/>- 百分比参数方式：弹窗参考宽度为所在窗口的宽度，在此基础上调小或调大。|
|height|?[Length](./cj-common-types.md#interface-length)|否|None| **命名参数。** 设置弹窗背板的高度。<br/>**说明：**<br/>- 弹窗高度默认最大值：0.9 *（窗口高度 - 安全区域）。<br/>- 百分比参数方式：弹窗参考高度为（窗口高度 - 安全区域），在此基础上调小或调大。|
|borderWidth|?[Length](./cj-common-types.md#interface-length)|否|None| **命名参数。** 设置弹窗背板的边框宽度。初始值: 0.vp<br/>可分别设置4个边框宽度。<br/> 百分比参数方式：以父元素弹窗宽的百分比来设置弹窗的边框宽度。<br/>当弹窗左边框和右边框大于弹窗宽度，弹窗上边框和下边框大于弹窗高度，显示可能不符合预期。|
|borderColor|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|None| **命名参数。** 设置弹窗背板的边框颜色。初始值: Color.Black<br/>如果使用borderColor属性，需要和borderWidth属性一起使用。|
|borderStyle|?[EdgeStyles](./cj-common-types.md#class-edgestyles)|否|None| **命名参数。** 设置弹窗背板的边框样式。初始值: EdgeStyles()<br/>如果使用borderStyle属性，需要和borderWidth属性一起使用。|
|shadow|?[ShadowOptions](./cj-common-types.md#class-shadowoptions)|否|None| **命名参数。** 设置弹窗背板的阴影。<br>初始值：<br>API version 26之前，初始值为ShadowOptions(radius: 0.0)；<br>从API version 26开始，初始值为ShadowOptions(radius: -1.0)。|
|backgroundBlurStyle|?[BlurStyle](./cj-common-types.md#enum-blurstyle)|否|None| **命名参数。** 弹窗背板模糊材质。 初始值: BlurStyle.ComponentUltraThick<br/>**说明：** <br/>设置为BlurStyle.None即可关闭背景虚化。当设置了backgroundBlurStyle为非None值时，则不要设置backgroundColor，否则颜色显示将不符合预期效果。|

## 示例代码

<!-- run -->

```cangjie

package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@CustomDialog
class MyDialog {
    var controller: Option<CustomDialogController> = Option.None
    func build() {
        Row(space: 60) {
            Button("cancel").onClick({ evt =>
                controller?.releaseSelf()
            })

            Button("confirm").onClick({ evt =>
                controller?.releaseSelf()
            })
        }.height(500.px)
    }
}

@Entry
@Component
class EntryView {
    var dialogController: CustomDialogController = CustomDialogController(CustomDialogControllerOptions(builder: MyDialog()))
    func build() {
        Column {
            Button("open dialog").onClick({evt =>
                dialogController.openDialog()
            }).margin(top: 40.percent, left: 35.percent)
              .width(30.percent)
        }
    }
}

```

![custom_dialog](./figures/custom_dialog.gif)
