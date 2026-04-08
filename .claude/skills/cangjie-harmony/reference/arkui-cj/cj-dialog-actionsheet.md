# 列表选择弹窗（ActionSheet）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

列表弹窗。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## class SheetInfo

```cangjie
public class SheetInfo {
    public var title: ?ResourceStr
    public var icon: ?ResourceStr
    public var action: ?VoidCallback
    public init(
        title!: ?ResourceStr,
        icon!: ?ResourceStr = None,
        action!: ?VoidCallback
    )
}
```

**功能：** 设置选项内容，每个选择项支持设置图片、文本和选中的回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var action

```cangjie
public var action: ?VoidCallback
```

**功能：** 选项选中的回调。

**类型：** ?[VoidCallback](./cj-common-types.md#type-voidcallback)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var icon

```cangjie
public var icon: ?ResourceStr
```

**功能：** 选项的图标，默认无图标显示。

**类型：** ?[ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var title

```cangjie
public var title: ?ResourceStr
```

**功能：** 选项的文本内容。

**类型：** ?[ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?ResourceStr, ?ResourceStr, ?VoidCallback)

```cangjie
public init(
    title!: ?ResourceStr,
    icon!: ?ResourceStr = None,
    action!: ?VoidCallback
)
```

**功能：** SheetInfo类的构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|title|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|**命名参数。** 选项的文本内容。<br/>文本超长时会触发滚动条。|
|icon|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None|**命名参数。** 选项的图标，默认无图标显示。<br/>string格式可用于加载网络图片和本地图片，常用于加载网络图片。当使用相对路径引用本地图片时，例如Image("common/test.jpg")。|
|action|?[VoidCallback](./cj-common-types.md#type-voidcallback)|是|-|**命名参数。** 选项选中时的回调。|

## class ActionSheetButtonOptions

```cangjie
public class ActionSheetButtonOptions {
    public var enabled: ?Bool
    public var defaultFocus: ?Bool
    public var style: ?DialogButtonStyle
    public var value: ?ResourceStr
    public var action: ?VoidCallback
    public init(
        enabled!: ?Bool = None,
        defaultFocus!: ?Bool = None,
        style!: ?DialogButtonStyle = None,
        value!: ?ResourceStr,
        action!: ?VoidCallback
    )
}
```

**功能：** 弹窗中按钮的样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var action

```cangjie
public var action: ?VoidCallback
```

**功能：** Button选中时的回调。

**类型：** ?[VoidCallback](./cj-common-types.md#type-voidcallback)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var defaultFocus

```cangjie
public var defaultFocus: ?Bool
```

**功能：** 设置Button是否是默认焦点。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var enabled

```cangjie
public var enabled: ?Bool
```

**功能：** 点击Button是否响应。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var style

```cangjie
public var style: ?DialogButtonStyle
```

**功能：** 设置Button的风格样式。

**类型：** ?[DialogButtonStyle](./cj-common-types.md#enum-dialogbuttonstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var value

```cangjie
public var value: ?ResourceStr
```

**功能：** Button文本内容。

**类型：** ?[ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Bool, ?Bool, ?DialogButtonStyle, ?ResourceStr, ?VoidCallback)

```cangjie
public init(
    enabled!: ?Bool = None,
    defaultFocus!: ?Bool = None,
    style!: ?DialogButtonStyle = None,
    value!: ?ResourceStr,
    action!: ?VoidCallback
)
```

**功能：** ActionSheetButtonOptions类的构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|enabled|?Bool|否|None|**命名参数。** 点击Button是否响应，true表示Button可以响应，false表示Button不可以响应。|
|defaultFocus|?Bool|否|None|**命名参数。** 设置Button是否是默认焦点，true表示Button是默认焦点，false表示Button不是默认焦点。|
|style|?[DialogButtonStyle](./cj-common-types.md#enum-dialogbuttonstyle)|否|None|**命名参数。** 设置Button的风格样式。 |
|value|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|**命名参数。** Button文本内容。|
|action|?[VoidCallback](./cj-common-types.md#type-voidcallback)|是|-|**命名参数。** Button选中时的回调。|

## class DismissDialogAction

```cangjie
public class DismissDialogAction {
    public var reason: DismissReason
    public init(reason: DismissReason)
}
```

**功能：** Dialog关闭的信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var reason

```cangjie
public var reason: DismissReason
```

**功能：** Dialog无法关闭原因。根据开发者需要选择不同操作下，Dialog是否需要关闭。

**类型：** [DismissReason](./cj-common-types.md#enum-dismissreason)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(DismissReason)

```cangjie
public init(reason: DismissReason)
```

**功能：** DismissDialogAction类的构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|reason|[DismissReason](./cj-common-types.md#enum-dismissreason)|是|-|Dialog无法关闭原因。根据开发者需要选择不同操作下，Dialog是否需要关闭。|

### func dismiss()

```cangjie
public func dismiss(): Unit
```

**功能：** Dialog关闭回调函数。开发者需要退出时调用，不需要退出时无需调用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## class ActionSheetOffset

```cangjie
public class ActionSheetOffset {
    public var dx: ?Length
    public var dy: ?Length
    public init(
        dx!: ?Length,
        dy!: ?Length
    )
}
```

**功能：** 弹窗的对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var dx

```cangjie
public var dx: ?Length
```

**功能：** 弹出窗口相对于对齐位置dx的偏移量。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var dy

```cangjie
public var dy: ?Length
```

**功能：** 弹出窗口相对于对齐位置dy的偏移量。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Length, ?Length)

```cangjie
public init(
    dx!: ?Length,
    dy!: ?Length
)
```

**功能：** ActionSheetOffset类的构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|dx|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 弹出窗口相对于对齐位置dx的偏移量。|
|dy|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 弹出窗口相对于对齐位置dy的偏移量。|

## class ActionSheetOptions

```cangjie
public class ActionSheetOptions {
    public var title: ?ResourceStr
    public var subtitle: ?ResourceStr
    public var message: ?ResourceStr
    public var confirm: ?ActionSheetButtonOptions
    public var cancel: ?VoidCallback
    public var sheets: ?Array<SheetInfo>
    public var autoCancel: ?Bool
    public var alignment: ?DialogAlignment
    public var offset: ?ActionSheetOffset
    public var maskRect: ?Rectangle
    public var showInSubWindow: ?Bool
    public var isModal: ?Bool
    public var backgroundColor: ?ResourceColor
    public var backgroundBlurStyle: ?BlurStyle
    public var onWillDismiss: ?Callback<DismissDialogAction, Unit>
    public var transition: ?TransitionEffect
    public var cornerRadius: ?BorderRadiuses
    public var width: ?Length
    public var height: ?Length
    public var borderWidth: ?Length
    public var borderColor: ?ResourceColor
    public var borderStyle: ?EdgeStyles
    public var shadow: ?ShadowOptions
    public init(
        title!: ?ResourceStr,
        subtitle!: ?ResourceStr = None,
        message!: ?ResourceStr,
        confirm!: ?ActionSheetButtonOptions = None,
        cancel!: ?VoidCallback = None,
        sheets!: ?Array<SheetInfo>,
        autoCancel!: ?Bool = None,
        alignment!: ?DialogAlignment = None,
        offset!: ?ActionSheetOffset = None,
        maskRect!: ?Rectangle = None,
        showInSubWindow!: ?Bool = None,
        isModal!: ?Bool = None,
        backgroundColor!: ?ResourceColor = None,
        backgroundBlurStyle!: ?BlurStyle = None,
        onWillDismiss!: ?Callback<DismissDialogAction, Unit> = None,
        transition!: ?TransitionEffect = None,
        cornerRadius!: ?BorderRadiuses = None,
        width!: ?Length = None,
        height!: ?Length = None,
        borderWidth!: ?Length = None,
        borderColor!: ?ResourceColor = None,
        borderStyle!: ?EdgeStyles = None,
        shadow!: ?ShadowOptions = None
    )
}
```

**功能：** ActionSheet弹窗的配置选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var title

```cangjie
public var title: ?ResourceStr
```

**功能：** 弹窗标题。

**类型：** ?[ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var subtitle

```cangjie
public var subtitle: ?ResourceStr
```

**功能：** 弹窗副标题。

**类型：** ?[ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var message

```cangjie
public var message: ?ResourceStr
```

**功能：** 弹窗内容。

**类型：** ?[ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var confirm

```cangjie
public var confirm: ?ActionSheetButtonOptions
```

**功能：** 确认Button的使能状态、默认焦点、按钮风格、文本内容和点击回调。在弹窗获焦且未进行tab键走焦时，该按钮默认响应Enter键，且多重弹窗可自动获焦连续响应。

**类型：** ?[ActionSheetButtonOptions](#class-actionsheetbuttonoptions)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var cancel

```cangjie
public var cancel: ?VoidCallback
```

**功能：** 点击遮障层关闭dialog时的回调。

**类型：** ?[VoidCallback](./cj-common-types.md#type-voidcallback)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var sheets

```cangjie
public var sheets: ?Array<SheetInfo>
```

**功能：** 设置选项内容，每个选择项支持设置图片、文本和选中的回调。

**类型：** ?Array\<[SheetInfo](#class-sheetinfo)>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var autoCancel

```cangjie
public var autoCancel: ?Bool
```

**功能：** 点击遮障层时，是否关闭弹窗。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var alignment

```cangjie
public var alignment: ?DialogAlignment
```

**功能：** 弹窗在竖直方向上的对齐方式。

**类型：** ?[DialogAlignment](./cj-common-types.md#enum-dialogalignment)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var offset

```cangjie
public var offset: ?ActionSheetOffset
```

**功能：** 弹窗相对alignment所在位置的偏移量。

**类型：** ?[ActionSheetOffset](#class-actionsheetoffset)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var maskRect

```cangjie
public var maskRect: ?Rectangle
```

**功能：** 弹窗遮蔽层区域，在遮蔽层区域内的事件不透传，在遮蔽层区域外的事件透传。

**类型：** ?[Rectangle](./cj-common-types.md#class-rectangle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var showInSubWindow

```cangjie
public var showInSubWindow: ?Bool
```

**功能：** 某弹框需要显示在主窗口之外时，是否在子窗口显示此弹窗。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var isModal

```cangjie
public var isModal: ?Bool
```

**功能：** 弹窗是否为模态窗口，模态窗口有蒙层，非模态窗口无蒙层。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var backgroundColor

```cangjie
public var backgroundColor: ?ResourceColor
```

**功能：** 弹窗背板颜色。

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var backgroundBlurStyle

```cangjie
public var backgroundBlurStyle: ?BlurStyle
```

**功能：** 弹窗背板模糊材质。

**类型：** ?[BlurStyle](./cj-common-types.md#enum-blurstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var onWillDismiss

```cangjie
public var onWillDismiss: ?Callback<DismissDialogAction, Unit>
```

**功能：** 交互式关闭回调函数。

**类型：** ?[Callback](./cj-common-types.md#type-callbackt-v)\<[DismissDialogAction](#class-dismissdialogaction), Unit>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var transition

```cangjie
public var transition: ?TransitionEffect
```

**功能：** 设置弹窗显示和退出的过渡效果。

**类型：** ?[TransitionEffect](./cj-animation-transition.md#class-transitioneffect)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var cornerRadius

```cangjie
public var cornerRadius: ?BorderRadiuses
```

**功能：** 设置背板的圆角半径。可分别设置4个圆角的半径。

**类型：** ?[BorderRadiuses](./cj-common-types.md#class-borderradiuses)

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

### var height

```cangjie
public var height: ?Length
```

**功能：** 设置弹窗背板的高度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var borderWidth

```cangjie
public var borderWidth: ?Length
```

**功能：** 设置弹窗背板的边框宽度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var borderColor

```cangjie
public var borderColor: ?ResourceColor
```

**功能：** 设置弹窗背板的边框颜色。如果使用borderColor属性，需要和borderWidth属性一起使用。

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var borderStyle

```cangjie
public var borderStyle: ?EdgeStyles
```

**功能：** 设置弹窗背板的边框样式。如果使用borderStyle属性，需要和borderWidth属性一起使用。

**类型：** ?[EdgeStyles](./cj-common-types.md#class-edgestyles)

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

### init(?ResourceStr, ?ResourceStr, ?ResourceStr, ?ActionSheetButtonOptions, ?VoidCallback, ?Array\<SheetInfo>, ?Bool, ?DialogAlignment, ?ActionSheetOffset, ?Rectangle, ?Bool, ?Bool, ?ResourceColor, ?BlurStyle, ?Callback\<DismissDialogAction, Unit>, ?TransitionEffect, ?BorderRadiuses, ?Length, ?Length, ?Length, ?ResourceColor, ?EdgeStyles, ?ShadowOptions)

```cangjie
public init(
    title!: ?ResourceStr,
    subtitle!: ?ResourceStr = None,
    message!: ?ResourceStr,
    confirm!: ?ActionSheetButtonOptions = None,
    cancel!: ?VoidCallback = None,
    sheets!: ?Array<SheetInfo>,
    autoCancel!: ?Bool = None,
    alignment!: ?DialogAlignment = None,
    offset!: ?ActionSheetOffset = None,
    maskRect!: ?Rectangle = None,
    showInSubWindow!: ?Bool = None,
    isModal!: ?Bool = None,
    backgroundColor!: ?ResourceColor = None,
    backgroundBlurStyle!: ?BlurStyle = None,
    onWillDismiss!: ?Callback<DismissDialogAction, Unit> = None,
    transition!: ?TransitionEffect = None,
    cornerRadius!: ?BorderRadiuses = None,
    width!: ?Length = None,
    height!: ?Length = None,
    borderWidth!: ?Length = None,
    borderColor!: ?ResourceColor = None,
    borderStyle!: ?EdgeStyles = None,
    shadow!: ?ShadowOptions = None
)
```

**功能：** ActionSheetOptions类的构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|title|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|**命名参数。** 弹窗标题。<br/>当文本内容过长无法显示时，用省略号代替未显示的部分。|
|subtitle|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None|**命名参数。** 弹窗副标题。<br/>当文本内容过长无法显示时，用省略号代替未显示的部分。|
|message|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|**命名参数。** 弹窗内容。<br/>文本超长时会触发滚动条。|
|confirm|?[ActionSheetButtonOptions](#class-actionsheetbuttonoptions)|否|None|**命名参数。** 确认Button的使能状态、默认焦点、按钮风格、文本内容和点击回调。在弹窗获焦且未进行tab键走焦时，该按钮默认响应Enter键，且多重弹窗可自动获焦连续响应。默认响应Enter键能力在defaultFocus为true时不生效。<br/>enabled：点击Button是否响应，true表示Button可以响应，false表示Button不可以响应。<br/>初始值：true。<br/>defaultFocus：设置Button是否是默认焦点，true表示Button是默认焦点，false表示Button不是默认焦点。<br/>初始值：false。<br/>style：设置Button的风格样式。<br/>初始值：DialogButtonStyle.DEFAULT。<br/>value：Button文本内容。当文本内容过长无法显示时，用省略号代替未显示的部分。<br/>action: Button选中时的回调。|
|cancel|?[VoidCallback](./cj-common-types.md#type-voidcallback)|否|None|**命名参数。** 点击遮障层关闭dialog时的回调。|
|sheets|?Array\<[SheetInfo](#class-sheetinfo)>|是|-|**命名参数。** 设置选项内容，每个选择项支持设置图片、文本和选中的回调。|
|autoCancel|?Bool|否|None|**命名参数。** 点击遮障层时，是否关闭弹窗。<br/>值为true时，点击遮罩层关闭弹窗，值为false时，点击遮罩层不关闭弹窗。|
|alignment|?[DialogAlignment](./cj-common-types.md#enum-dialogalignment)|否|None|**命名参数。** 弹窗在竖直方向上的对齐方式。|
|offset|?[ActionSheetOffset](#class-actionsheetoffset)|否|None|**命名参数。** 弹窗相对alignment所在位置的偏移量。|
|maskRect|?[Rectangle](./cj-common-types.md#class-rectangle)|否|None|**命名参数。** 弹窗遮蔽层区域，在遮蔽层区域内的事件不透传，在遮蔽层区域外的事件透传。 <br>**说明:**<br> showInSubWindow为true时，maskRect不生效。|
|showInSubWindow|?Bool|否|None|**命名参数。** 某弹框需要显示在主窗口之外时，是否在子窗口显示此弹窗。<br>初始值：false，弹窗显示在应用内，而非独立子窗口。<br>**说明:**<br> showInSubWindow为true的弹窗无法触发显示另一个showInSubWindow为true的弹窗。|
|isModal|?Bool|否|None|**命名参数。** 弹窗是否为模态窗口，模态窗口有蒙层，非模态窗口无蒙层。<br/>初始值：true，此时弹窗有蒙层。|
|backgroundColor|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|None|**命名参数。** 弹窗背板颜色。<br>**说明:**<br> 当设置了backgroundColor为非透明色时，backgroundBlurStyle需要设置为BlurStyle.NONE，否则颜色显示将不符合预期效果。|
|backgroundBlurStyle|?[BlurStyle](./cj-common-types.md#enum-blurstyle)|否|None|**命名参数。**  弹窗背板模糊材质。<br>**说明:**<br>设置为BlurStyle.NONE即可关闭背景虚化。当设置了backgroundBlurStyle为非NONE值时，则不要设置backgroundColor，否则颜色显示将不符合预期效果。 |
|onWillDismiss|?[Callback](./cj-common-types.md#type-callbackt-v)\<[DismissDialogAction](#class-dismissdialogaction), Unit>|否|None|**命名参数。**  交互式关闭回调函数。 <br>**说明:**<br> 1.当用户执行点击遮障层关闭、左滑/右滑、三键back、键盘ESC关闭交互操作时，如果注册该回调函数，则不会立刻关闭弹窗。在回调函数中可以通过reason得到阻拦关闭弹窗的操作类型，从而根据原因选择是否能关闭弹窗。当前组件返回的reason中，暂不支持CLOSE_BUTTON的枚举值。<br> 2.在onWillDismiss回调中，不能再做onWillDismiss拦截。 |
|transition|?[TransitionEffect](./cj-animation-transition.md#class-transitioneffect)|否|None|**命名参数。**  设置弹窗显示和退出的过渡效果。 <br>**说明:**<br> 1.如果不设置，则使用默认的显示/退出动效。 <br>2.显示动效中按back键，打断显示动效，执行退出动效，动画效果为显示动效与退出动效的曲线叠加后的效果。<br> 3.退出动效中按back键，不会打断退出动效，退出动效继续执行，继续按back键退出应用。 |
|cornerRadius|?[BorderRadiuses](./cj-common-types.md#class-borderradiuses)|否|None| **命名参数。**  设置背板的圆角半径。可分别设置4个圆角的半径。<br>圆角大小受组件尺寸限制，最大值为组件宽或高的一半，若值为负，则按照默认值处理。 <br>百分比参数方式：以父元素弹窗宽和高的百分比来设置弹窗的圆角。 |
|width|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。**  设置弹窗背板的宽度。<br>**说明:**<br>1. 弹窗宽度默认最大值：400.vp。<br>2. 百分比参数方式：弹窗参考宽度为所在窗口的宽度，在此基础上调小或调大。 |
|height|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。**  设置弹窗背板的高度。<br>**说明:**<br>1. 弹窗高度默认最大值：0.9 *（窗口高度 - 安全区域） 。<br>2. 百分比参数方式：弹窗参考高度为（窗口高度 - 安全区域），在此基础上调小或调大。 |
|borderWidth|?[Length](./cj-common-types.md#interface-length)|否|None| **命名参数。**  设置弹窗背板的边框宽度。<br>百分比参数方式：以父元素弹窗宽和高的百分比来设置弹窗的圆角。<br>当弹窗左边框和右边框大于弹窗宽度，弹窗上边框和下边框大于弹窗高度，显示可能不符合预期。|
|borderColor|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|None|**命名参数。**  设置弹窗背板的边框颜色。如果使用borderColor属性，需要和borderWidth属性一起使用。 |
|borderStyle|?[EdgeStyles](./cj-common-types.md#class-edgestyles)|否|None|**命名参数。**  设置弹窗背板的边框样式 。 如果使用borderStyle属性，需要和borderWidth属性一起使用。 |
|shadow|?[ShadowOptions](./cj-common-types.md#class-shadowoptions)|否|None|**命名参数。** 设置弹窗背板的阴影。<br>初始值：<br>API version 26之前，初始值为ShadowOptions(radius: 0.0)；<br>从API version 26开始，初始值为ShadowOptions(radius: -1.0)。|
