# PromptAction

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

创建并显示即时反馈、对话框、操作菜单以及自定义弹窗。

> **说明：**
>
> 以下API需先使用[UIContext](./cj-apis-uicontext-uicontext.md#class-uicontext)中的[getPromptAction()](./cj-apis-uicontext-uicontext.md#func-getpromptaction)方法获取PromptAction实例，再通过此实例调用对应方法。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## class PromptAction

```cangjie
public class PromptAction {}
```

**功能：** PromptAction类。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func closeCustomDialog(Int32)

```cangjie
public func closeCustomDialog(dialogId: Int32): Unit
```

**功能：** 关闭自定义对话框。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|dialogId|Int32|是|-|要关闭的对话框ID，由openCustomDialog返回。|

### func openCustomDialog(CustomDialogOptions, (Int32) -> Unit)

```cangjie
public func openCustomDialog(options: CustomDialogOptions, callBack: (Int32) -> Unit): Unit
```

**功能：** 打开自定义对话框。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|options|[CustomDialogOptions](#class-customdialogoptions)|是|-|自定义对话框选项。|
|callBack|(Int32) -> Unit|是|-|回调函数。|

### func showActionMenu(ActionMenuOptions, ShowActionMenuCallBack)

```cangjie
public func showActionMenu(option: ActionMenuOptions, callback!: ShowActionMenuCallBack = defaultCallback)
```

**功能：** 在给定设置中显示操作菜单。此API使用异步回调返回结果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|option|[ActionMenuOptions](#class-actionmenuoptions)|是|-| 操作菜单选项。|
|callback|[ShowActionMenuCallBack](#type-showactionmenucallback)|否|defaultCallback| **命名参数。** 用于返回操作菜单响应结果的回调。defaultCallback表示{_: Option\<BusinessException>, _: Option\<Int32> =>}|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码|说明|
  |:----|:----|
  |100001|Internal error: failed to allocate memory.|

### func showDialog(ShowDialogOptions, ShowDialogCallBack)

```cangjie
public func showDialog(option: ShowDialogOptions, callback!: ShowDialogCallBack = defaultCallback)
```

**功能：** 在给定设置中显示对话框。此API使用异步回调返回结果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|option|[ShowDialogOptions](#class-showdialogoptions)|是|-| 对话框选项。|
|callback|[ShowDialogCallBack](#type-showdialogcallback)|否|defaultCallback|**命名参数。** 用于返回对话框响应结果的回调。defaultCallback表示{_: Option\<BusinessException>, _: Option\<Int32> =>}|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码|说明|
  |:----|:----|
  |100001|Internal error: failed to allocate memory.|

### func showToast(ShowToastOptions)

```cangjie
public func showToast(option: ShowToastOptions): Unit
```

**功能：** 在给定设置中显示Toast。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|option|[ShowToastOptions](#class-showtoastoptions)|是|-|Toast选项。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码|说明|
  |:----|:----|
  |100001|Internal error: failed to allocate memory.|

## class ActionMenuOptions

```cangjie
public open class ActionMenuOptions {
    public var title: ResourceStr
    public var buttons: Array<ButtonInfo>
    public var showInSubWindow: Bool
    public var isModal: Bool
    public init(
        title!: ResourceStr = '',
        buttons!: Array<ButtonInfo>,
        showInSubWindow!: Bool = false,
        isModal!: Bool = true
    )
}
```

**功能：** 菜单操作选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var buttons

```cangjie
public var buttons: Array<ButtonInfo>
```

**功能：** 对话框中的按钮数组。

**类型：** Array\<[ButtonInfo](#class-buttoninfo)>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var isModal

```cangjie
public var isModal: Bool
```

**功能：** 是否为模态对话框。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var showInSubWindow

```cangjie
public var showInSubWindow: Bool
```

**功能：** 是否在子窗口中显示。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var title

```cangjie
public var title: ResourceStr
```

**功能：** 要显示的文本标题。

**类型：** [ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(ResourceStr, Array\<ButtonInfo>, Bool, Bool)

```cangjie
public init(
    title!: ResourceStr = '',
    buttons!: Array<ButtonInfo>,
    showInSubWindow!: Bool = false,
    isModal!: Bool = true
)
```

**功能：** 菜单操作选项构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|title|[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|''| **命名参数。** 要显示的文本标题。|
|buttons|Array\<[ButtonInfo](#class-buttoninfo)>|是|-| **命名参数。** 按钮数组。|
|showInSubWindow|Bool|否|false| **命名参数。** 是否在子窗口中显示。|
|isModal|Bool|否|true| **命名参数。** 是否为模态对话框。|

## class BaseDialogOptions

```cangjie
public open class BaseDialogOptions {
    public var maskRect: Rectangle
    public var alignment: DialogAlignment
    public var offset: Offset
    public var isModal: Bool
    public var showInSubWindow: Bool
    public var autoCancel: Bool
    public var maskColor: ResourceColor
    public var transition: TransitionEffect
    public var onDidAppear: () -> Unit
    public var onDidDisappear: () -> Unit
    public var onWillAppear: () -> Unit
    public var onWillDisappear: () -> Unit
    public var keyboardAvoidMode: KeyboardAvoidMode
    public var enableHoverMode: Bool
    public var hoverModeArea: HoverModeAreaType
    public init(
        maskRect!: Rectangle = Rectangle(x: 0.vp, y: 0.vp, width: 100.percent, height: 100.percent),
        alignment!: DialogAlignment = DialogAlignment.Default,
        offset!: Offset = Offset(0.vp, 0.vp),
        isModal!: Bool = true,
        showInSubWindow!: Bool = false,
        autoCancel!: Bool = true,
        maskColor!: ResourceColor = Color(0x33000000),
        transition!: TransitionEffect = TransitionEffect.OPACITY,
        onDidAppear!: () -> Unit = {=>},
        onDidDisappear!: () -> Unit = {=>},
        onWillAppear!: () -> Unit = {=>},
        onWillDisappear!: () -> Unit = {=>},
        keyboardAvoidMode!: KeyboardAvoidMode = KeyboardAvoidMode.Default,
        enableHoverMode!: Bool = false,
        hoverModeArea!: HoverModeAreaType = HoverModeAreaType.BottomScreen
    )
}
```

**功能：** 对话框基础选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var alignment

```cangjie
public var alignment: DialogAlignment
```

**功能：** 对话框在屏幕上的对齐方式。

**类型：** [DialogAlignment](./cj-common-types.md#enum-dialogalignment)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var autoCancel

```cangjie
public var autoCancel: Bool
```

**功能：** 是否允许用户点击遮罩层退出。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var enableHoverMode

```cangjie
public var enableHoverMode: Bool
```

**功能：** 是否响应悬停模式。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var hoverModeArea

```cangjie
public var hoverModeArea: HoverModeAreaType
```

**功能：** 悬停模式下对话框的显示区域。

**类型：** [HoverModeAreaType](#enum-hovermodeareatype)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var isModal

```cangjie
public var isModal: Bool
```

**功能：** 是否为模态对话框。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var keyboardAvoidMode

```cangjie
public var keyboardAvoidMode: KeyboardAvoidMode
```

**功能：** 自定义对话框的键盘避免模式。

**类型：** [KeyboardAvoidMode](#enum-keyboardavoidmode)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var maskColor

```cangjie
public var maskColor: ResourceColor
```

**功能：** 自定义对话框遮罩颜色。

**类型：** [ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var maskRect

```cangjie
public var maskRect: Rectangle
```

**功能：** 对话框遮罩区域。大小不能超过主窗口。

**类型：** [Rectangle](./cj-common-types.md#class-rectangle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var offset

```cangjie
public var offset: Offset
```

**功能：** 对话框偏移量。

**类型：** [Offset](./cj-common-types.md#class-offset)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var onDidAppear

```cangjie
public var onDidAppear: () -> Unit
```

**功能：** 对话框出现时的回调函数。

**类型：** () -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var onDidDisappear

```cangjie
public var onDidDisappear: () -> Unit
```

**功能：** 对话框消失时的回调函数。

**类型：** () -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var onWillAppear

```cangjie
public var onWillAppear: () -> Unit
```

**功能：** 对话框打开动画开始前的回调函数。

**类型：** () -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var onWillDisappear

```cangjie
public var onWillDisappear: () -> Unit
```

**功能：** 对话框关闭动画开始前的回调函数。

**类型：** () -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var showInSubWindow

```cangjie
public var showInSubWindow: Bool
```

**功能：** 是否在子窗口中显示。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var transition

```cangjie
public var transition: TransitionEffect
```

**功能：** 自定义对话框打开/关闭时的过渡参数。

**类型：** [TransitionEffect](./cj-animation-transition.md#class-transitioneffect)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(Rectangle, DialogAlignment, Offset, Bool, Bool, Bool, ResourceColor, TransitionEffect, () -> Unit, () -> Unit, () -> Unit, () -> Unit, KeyboardAvoidMode, Bool, HoverModeAreaType)

```cangjie
public init(
    maskRect!: Rectangle = Rectangle(x: 0.vp, y: 0.vp, width: 100.percent, height: 100.percent),
    alignment!: DialogAlignment = DialogAlignment.Default,
    offset!: Offset = Offset(0.vp, 0.vp),
    isModal!: Bool = true,
    showInSubWindow!: Bool = false,
    autoCancel!: Bool = true,
    maskColor!: ResourceColor = Color(0x33000000),
    transition!: TransitionEffect = TransitionEffect.OPACITY,
    onDidAppear!: () -> Unit = {=>},
    onDidDisappear!: () -> Unit = {=>},
    onWillAppear!: () -> Unit = {=>},
    onWillDisappear!: () -> Unit = {=>},
    keyboardAvoidMode!: KeyboardAvoidMode = KeyboardAvoidMode.Default,
    enableHoverMode!: Bool = false,
    hoverModeArea!: HoverModeAreaType = HoverModeAreaType.BottomScreen
)
```

**功能：** BaseDialogOptions构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|maskRect|[Rectangle](./cj-common-types.md#class-rectangle)|否|Rectangle(x: 0.vp, y: 0.vp, width: 100.percent, height: 100.percent)| **命名参数。** 对话框遮罩区域。|
|alignment|[DialogAlignment](./cj-common-types.md#enum-dialogalignment)|否|DialogAlignment.Default| **命名参数。** 对话框在屏幕上的对齐方式。|
|offset|[Offset](./cj-common-types.md#class-offset)|否|Offset(0.vp, 0.vp)| **命名参数。** 对话框偏移量。|
|isModal|Bool|否|true| **命名参数。** 是否为模态对话框。|
|showInSubWindow|Bool|否|false| **命名参数。** 是否在子窗口中显示。|
|autoCancel|Bool|否|true| **命名参数。** 是否允许用户点击遮罩层退出。|
|maskColor|[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|Color(0x33000000)| **命名参数。** 自定义对话框遮罩颜色。|
|transition|[TransitionEffect](./cj-animation-transition.md#class-transitioneffect)|否|TransitionEffect.OPACITY| **命名参数。** 自定义对话框打开/关闭时的过渡参数。|
|onDidAppear|() -> Unit|否|{=>}| **命名参数。** 对话框出现时的回调函数。|
|onDidDisappear|() -> Unit|否|{=>}| **命名参数。** 对话框消失时的回调函数。|
|onWillAppear|() -> Unit|否|{=>}| **命名参数。** 对话框打开动画开始前的回调函数。|
|onWillDisappear|() -> Unit|否|{=>}| **命名参数。** 对话框关闭动画开始前的回调函数。|
|keyboardAvoidMode|[KeyboardAvoidMode](#enum-keyboardavoidmode)|否|KeyboardAvoidMode.Default| **命名参数。** 自定义对话框的键盘避免模式。|
|enableHoverMode|Bool|否|false| **命名参数。** 是否响应悬停模式。|
|hoverModeArea|[HoverModeAreaType](#enum-hovermodeareatype)|否|HoverModeAreaType.BottomScreen| **命名参数。** 悬停模式下对话框的显示区域。|

## class ButtonInfo

```cangjie
public class ButtonInfo {
    public var text: ResourceStr
    public var color: ResourceColor
    public var primary: Bool
    public init(text!: ResourceStr, color!: ResourceColor, primary!: Bool = false)
}
```

**功能：** 提供菜单项按钮。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var color

```cangjie
public var color: ResourceColor
```

**功能：** 按钮文本颜色。

**类型：** [ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var primary

```cangjie
public var primary: Bool
```

**功能：** 定义按钮是否默认响应Enter/Space键。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var text

```cangjie
public var text: ResourceStr
```

**功能：** 按钮中显示的文本。

**类型：** [ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(ResourceStr, ResourceColor, Bool)

```cangjie
public init(text!: ResourceStr, color!: ResourceColor, primary!: Bool = false)
```

**功能：** 构造菜单中的菜单项按钮。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|text|[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-| **命名参数。** 按钮文本内容。|
|color|[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-| **命名参数。** 按钮文本颜色。|
|primary|Bool|否|false| **命名参数。** 按钮是否默认响应Enter/Space键。|

## class CustomDialogOptions

```cangjie
public class CustomDialogOptions <: BaseDialogOptions {
    public var builder: () -> Unit
    public var backgroundColor: ResourceColor
    public var cornerRadius: BorderRadiuses
    public var borderWidth: EdgeWidths
    public var borderColor: EdgeColors
    public var borderStyle: EdgeStyles
    public var width: Length
    public var height: Length
    public var shadow: ?ShadowOptions
    public var backgroundBlurStyle: BlurStyle
    public init(
        builder!: () -> Unit,
        maskRect!: Rectangle = Rectangle(x: 0.vp, y: 0.vp, width: 100.percent, height: 100.percent),
        alignment!: DialogAlignment = DialogAlignment.Default,
        offset!: Offset = Offset(0.vp, 0.vp),
        isModal!: Bool = true,
        showInSubWindow!: Bool = false,
        autoCancel!: Bool = true,
        maskColor!: ResourceColor = Color(0x33000000),
        transition!: TransitionEffect = TransitionEffect.OPACITY,
        onDidAppear!: () -> Unit = {=>},
        onDidDisappear!: () -> Unit = {=>},
        onWillAppear!: () -> Unit = {=>},
        onWillDisappear!: () -> Unit = {=>},
        keyboardAvoidMode!: KeyboardAvoidMode = KeyboardAvoidMode.Default,
        enableHoverMode!: Bool = false,
        hoverModeArea!: HoverModeAreaType = HoverModeAreaType.BottomScreen,
        backgroundColor!: ResourceColor = Color.Transparent,
        cornerRadius!: BorderRadiuses = BorderRadiuses(topLeft: 32.vp, topRight: 32.vp, bottomLeft: 32.vp,
            bottomRight: 32.vp),
        borderWidth!: EdgeWidths = EdgeWidths(top: 0.vp, right: 0.vp, bottom: 0.vp, left: 0.vp),
        borderColor!: EdgeColors = EdgeColors(top: Color.Black, right: Color.Black, bottom: Color.Black, left: Color.Black),
        borderStyle!: EdgeStyles = EdgeStyles(),
        width!: Length = 400.vp,
        height!: Length = 100.vp,
        shadow!: ?ShadowOptions = None,
        backgroundBlurStyle!: BlurStyle = BlurStyle.ComponentUltraThick
    )
}
```

**功能：** 对话框自定义内容选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [BaseDialogOptions](#class-basedialogoptions)

### var backgroundColor

```cangjie
public var backgroundColor: ResourceColor
```

**功能：** 自定义对话框的背景颜色。

**类型：** [ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var borderColor

```cangjie
public var borderColor: EdgeColors
```

**功能：** 自定义对话框的边框颜色。

**类型：** [EdgeColors](#class-edgecolors)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var cornerRadius

```cangjie
public var cornerRadius: BorderRadiuses
```

**功能：** 自定义对话框的圆角半径。

**类型：** [BorderRadiuses](./cj-common-types.md#class-borderradiuses)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var borderStyle

```cangjie
public var borderStyle: EdgeStyles
```

**功能：** 自定义对话框的边框样式。

**类型：** [EdgeStyles](./cj-common-types.md#class-edgestyles)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var borderWidth

```cangjie
public var borderWidth: EdgeWidths
```

**功能：** 自定义对话框的边框宽度。

**类型：** [EdgeWidths](./cj-common-types.md#class-edgewidths)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var builder

```cangjie
public var builder: () -> Unit
```

**功能：** 允许开发者自定义对话框内容。

**类型：** () -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var backgroundBlurStyle

```cangjie
public var backgroundBlurStyle: BlurStyle
```

**功能：** 对话框的背景模糊样式。

**类型：** [BlurStyle](./cj-common-types.md#enum-blurstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var height

```cangjie
public var height: Length
```

**功能：** 对话框的高度。

**类型：** [Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var shadow

```cangjie
public var shadow: ?ShadowOptions
```

**功能：** 对话框的阴影。

**类型：** ?[ShadowOptions](./cj-common-types.md#class-shadowoptions)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var width

```cangjie
public var width: Length
```

**功能：** 对话框的宽度。

**类型：** [Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(() -> Unit, Rectangle, DialogAlignment, Offset, Bool, Bool, Bool, ResourceColor, TransitionEffect, () -> Unit, () -> Unit, () -> Unit, () -> Unit, KeyboardAvoidMode, Bool, HoverModeAreaType, ResourceColor, BorderRadiuses, EdgeWidths, EdgeColors, EdgeStyles, Length, Length, ?ShadowOptions, BlurStyle)

```cangjie
public init(
    builder!: () -> Unit,
    maskRect!: Rectangle = Rectangle(x: 0.vp, y: 0.vp, width: 100.percent, height: 100.percent),
    alignment!: DialogAlignment = DialogAlignment.Default,
    offset!: Offset = Offset(0.vp, 0.vp),
    isModal!: Bool = true,
    showInSubWindow!: Bool = false,
    autoCancel!: Bool = true,
    maskColor!: ResourceColor = Color(0x33000000),
    transition!: TransitionEffect = TransitionEffect.OPACITY,
    onDidAppear!: () -> Unit = {=>},
    onDidDisappear!: () -> Unit = {=>},
    onWillAppear!: () -> Unit = {=>},
    onWillDisappear!: () -> Unit = {=>},
    keyboardAvoidMode!: KeyboardAvoidMode = KeyboardAvoidMode.Default,
    enableHoverMode!: Bool = false,
    hoverModeArea!: HoverModeAreaType = HoverModeAreaType.BottomScreen,
    backgroundColor!: ResourceColor = Color.Transparent,
    cornerRadius!: BorderRadiuses = BorderRadiuses(topLeft: 32.vp, topRight: 32.vp, bottomLeft: 32.vp,
        bottomRight: 32.vp),
    borderWidth!: EdgeWidths = EdgeWidths(top: 0.vp, right: 0.vp, bottom: 0.vp, left: 0.vp),
    borderColor!: EdgeColors = EdgeColors(top: Color.Black, right: Color.Black, bottom: Color.Black, left: Color.Black),
    borderStyle!: EdgeStyles = EdgeStyles(),
    width!: Length = 400.vp,
    height!: Length = 100.vp,
    shadow!: ?ShadowOptions = None,
    backgroundBlurStyle!: BlurStyle = BlurStyle.ComponentUltraThick
)
```

**功能：** 对话框构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|builder|() -> Unit|是|-| **命名参数。** 自定义对话框内容。<br>**说明：** 仅支持接收@Builder修饰的自定义构建函数。|
|maskRect|[Rectangle](./cj-common-types.md#class-rectangle)|否|Rectangle(x: 0.vp, y: 0.vp, width: 100.percent, height: 100.percent)| **命名参数。** 对话框遮罩区域。|
|alignment|[DialogAlignment](./cj-common-types.md#enum-dialogalignment)|否|DialogAlignment.Default| **命名参数。** 对话框在屏幕上的对齐方式。|
|offset|[Offset](./cj-common-types.md#class-offset)|否|Offset(0.vp, 0.vp)| **命名参数。** 对话框偏移量。|
|isModal|Bool|否|true| **命名参数。** 是否为模态对话框。|
|showInSubWindow|Bool|否|false| **命名参数。** 是否在子窗口中显示。|
|autoCancel|Bool|否|true| **命名参数。** 是否允许用户点击遮罩层退出。|
|maskColor|[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|Color(0x33000000)| **命名参数。** 自定义对话框遮罩颜色。|
|transition|[TransitionEffect](./cj-animation-transition.md#class-transitioneffect)|否|TransitionEffect.OPACITY| **命名参数。** 自定义对话框打开/关闭时的过渡参数。|
|onDidAppear|() -> Unit|否|{=>}| **命名参数。** 对话框出现时的回调函数。|
|onDidDisappear|() -> Unit|否|{=>}| **命名参数。** 对话框消失时的回调函数。|
|onWillAppear|() -> Unit|否|{=>}| **命名参数。** 对话框打开动画开始前的回调函数。|
|onWillDisappear|() -> Unit|否|{=>}| **命名参数。** 对话框关闭动画开始前的回调函数。|
|keyboardAvoidMode|[KeyboardAvoidMode](#enum-keyboardavoidmode)|否|KeyboardAvoidMode.Default| **命名参数。** 自定义对话框的键盘避免模式。|
|enableHoverMode|Bool|否|false| **命名参数。** 是否响应悬停模式。|
|hoverModeArea|[HoverModeAreaType](#enum-hovermodeareatype)|否|HoverModeAreaType.BottomScreen| **命名参数。** 悬停模式下对话框的显示区域。|
|backgroundColor|[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|Color.Transparent| **命名参数。** 自定义对话框的背景颜色。|
|cornerRadius|[BorderRadiuses](./cj-common-types.md#class-borderradiuses)|否|BorderRadiuses(topLeft: 32.vp, topRight: 32.vp, bottomLeft: 32.vp, bottomRight: 32.vp)| **命名参数。** 自定义对话框的圆角半径。|
|borderWidth|[EdgeWidths](./cj-common-types.md#class-edgewidths)|否|EdgeWidths(top: 0.vp, right: 0.vp, bottom: 0.vp, left: 0.vp)| **命名参数。** 自定义对话框的边框宽度。|
|borderColor|[EdgeColors](#class-edgecolors)|否|EdgeColors(top: Color.Black, right: Color.Black, bottom: Color.Black, left: Color.Black)| **命名参数。** 自定义对话框的边框颜色。|
|borderStyle|[EdgeStyles](./cj-common-types.md#class-edgestyles)|否|EdgeStyles()| **命名参数。** 自定义对话框的边框样式。|
|width|[Length](./cj-common-types.md#interface-length)|否|400.vp| **命名参数。** 对话框的宽度。|
|height|[Length](./cj-common-types.md#interface-length)|否|100.vp| **命名参数。** 对话框的高度。|
|shadow|?[ShadowOptions](./cj-common-types.md#class-shadowoptions)|否|None| **命名参数。** 对话框的阴影。<br>初始值：<br>API version 26之前，初始值为ShadowOptions(radius: 0.0)；<br>从API version 26开始，初始值为ShadowOptions(radius: -1.0)。|
|backgroundBlurStyle|[BlurStyle](./cj-common-types.md#enum-blurstyle)|否|BlurStyle.ComponentUltraThick| **命名参数。** 对话框的背景模糊样式。|

## class EdgeColors

```cangjie
public class EdgeColors {
    public var top: ResourceColor
    public var right: ResourceColor
    public var bottom: ResourceColor
    public var left: ResourceColor
    public init(
        top!: ResourceColor = Color.Black,
        right!: ResourceColor = Color.Black,
        bottom!: ResourceColor = Color.Black,
        left!: ResourceColor = Color.Black
    )
}
```

**功能：** 提供边框颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var bottom

```cangjie
public var bottom: ResourceColor
```

**功能：** 边框的底部颜色。

**类型：** [ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var left

```cangjie
public var left: ResourceColor
```

**功能：** 边框的左侧颜色。

**类型：** [ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var right

```cangjie
public var right: ResourceColor
```

**功能：** 边框的右侧颜色。

**类型：** [ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var top

```cangjie
public var top: ResourceColor
```

**功能：** 边框的顶部颜色。

**类型：** [ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(ResourceColor, ResourceColor, ResourceColor, ResourceColor)

```cangjie
public init(
    top!: ResourceColor = Color.Black,
    right!: ResourceColor = Color.Black,
    bottom!: ResourceColor = Color.Black,
    left!: ResourceColor = Color.Black
)
```

**功能：** EdgeColors构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|top|[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|Color.Black| **命名参数。** 顶部边框颜色。|
|right|[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|Color.Black| **命名参数。** 右侧边框颜色。|
|bottom|[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|Color.Black| **命名参数。** 底部边框颜色。|
|left|[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|Color.Black| **命名参数。** 左侧边框颜色。|

## class ShowDialogOptions

```cangjie
public open class ShowDialogOptions {
    public var title: ResourceStr
    public var message: ResourceStr
    public var buttons: Array<ButtonInfo>
    public var alignment: DialogAlignment
    public var offset: Offset
    public var maskRect: Rectangle
    public var showInSubWindow: Bool
    public var isModal: Bool
    public var backgroundColor: ResourceColor
    public var backgroundBlurStyle: BlurStyle
    public var shadow: ?ShadowOptions
    public var enableHoverMode: Bool
    public var hoverModeArea: HoverModeAreaType
    public init(
        title!: ResourceStr = '',
        message!: ResourceStr = '',
        buttons!: Array<ButtonInfo> = [],
        alignment!: DialogAlignment = DialogAlignment.Default,
        offset!: Offset = Offset(0.vp, 0.vp),
        maskRect!: Rectangle = Rectangle(x: 0.vp, y: 0.vp, width: 100.percent, height: 100.percent),
        showInSubWindow!: Bool = false,
        isModal!: Bool = true,
        backgroundColor!: Color = Color.Transparent,
        backgroundBlurStyle!: BlurStyle = BlurStyle.ComponentUltraThick,
        shadow!: ?ShadowOptions = None,
        enableHoverMode!: Bool = false,
        hoverModeArea!: HoverModeAreaType = HoverModeAreaType.BottomScreen
    )
}
```

**功能：** 对话框显示选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var alignment

```cangjie
public var alignment: DialogAlignment
```

**功能：** 对话框在屏幕上的对齐方式。

**类型：** [DialogAlignment](./cj-common-types.md#enum-dialogalignment)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var backgroundColor

```cangjie
public var backgroundColor: ResourceColor
```

**功能：** 对话框的背景颜色。

**类型：** [ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var backgroundBlurStyle

```cangjie
public var backgroundBlurStyle: BlurStyle
```

**功能：** 对话框的背景模糊样式。

**类型：** [BlurStyle](./cj-common-types.md#enum-blurstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var buttons

```cangjie
public var buttons: Array<ButtonInfo>
```

**功能：** 对话框中的按钮数组。支持多个按钮。

**类型：** Array\<[ButtonInfo](#class-buttoninfo)>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var enableHoverMode

```cangjie
public var enableHoverMode: Bool
```

**功能：** 是否响应悬停模式。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var hoverModeArea

```cangjie
public var hoverModeArea: HoverModeAreaType
```

**功能：** 悬停模式下对话框的显示区域。

**类型：** [HoverModeAreaType](#enum-hovermodeareatype)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var isModal

```cangjie
public var isModal: Bool
```

**功能：** 是否为模态对话框。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var maskRect

```cangjie
public var maskRect: Rectangle
```

**功能：** 对话框遮罩区域。大小不能超过主窗口。

**类型：** [Rectangle](./cj-common-types.md#class-rectangle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var message

```cangjie
public var message: ResourceStr
```

**功能：** 文本主体。

**类型：** [ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var offset

```cangjie
public var offset: Offset
```

**功能：** 对话框偏移量。

**类型：** [Offset](./cj-common-types.md#class-offset)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var shadow

```cangjie
public var shadow: ?ShadowOptions
```

**功能：** 对话框的阴影选项。

**类型：** ?[ShadowOptions](./cj-common-types.md#class-shadowoptions)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var showInSubWindow

```cangjie
public var showInSubWindow: Bool
```

**功能：** 是否在子窗口中显示。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var title

```cangjie
public var title: ResourceStr
```

**功能：** 要显示的标题文本。

**类型：** [ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(ResourceStr, ResourceStr, Array\<ButtonInfo\>, DialogAlignment, Offset, Rectangle, Bool, Bool, Color, BlurStyle, ?ShadowOptions, Bool, HoverModeAreaType)

```cangjie
public init(
    title!: ResourceStr = '',
    message!: ResourceStr = '',
    buttons!: Array<ButtonInfo> = [],
    alignment!: DialogAlignment = DialogAlignment.Default,
    offset!: Offset = Offset(0.vp, 0.vp),
    maskRect!: Rectangle = Rectangle(x: 0.vp, y: 0.vp, width: 100.percent, height: 100.percent),
    showInSubWindow!: Bool = false,
    isModal!: Bool = true,
    backgroundColor!: Color = Color.Transparent,
    backgroundBlurStyle!: BlurStyle = BlurStyle.ComponentUltraThick,
    shadow!: ?ShadowOptions = None,
    enableHoverMode!: Bool = false,
    hoverModeArea!: HoverModeAreaType = HoverModeAreaType.BottomScreen
)
```

**功能：** 对话框显示选项构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|title|[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|''| **命名参数。** 标题文本。|
|message|[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|''| **命名参数。** 文本主体。|
|buttons|Array\<[ButtonInfo](#class-buttoninfo)>|否|[]| **命名参数。** 对话框中的按钮数组。|
|alignment|[DialogAlignment](./cj-common-types.md#enum-dialogalignment)|否|DialogAlignment.Default| **命名参数。** 对话框在屏幕上的对齐方式。|
|offset|[Offset](./cj-common-types.md#class-offset)|否|Offset(0.vp, 0.vp)| **命名参数。** 对话框偏移量。|
|maskRect|[Rectangle](./cj-common-types.md#class-rectangle)|否|Rectangle(x: 0.vp, y: 0.vp, width: 100.percent, height: 100.percent)| **命名参数。** 对话框遮罩区域。|
|showInSubWindow|Bool|否|false| **命名参数。** 是否在子窗口中显示。|
|isModal|Bool|否|true| **命名参数。** 是否为模态对话框。|
|backgroundColor|[Color](./cj-common-types.md#class-color)|否|Color.Transparent| **命名参数。** 对话框的背景颜色。|
|backgroundBlurStyle|[BlurStyle](./cj-common-types.md#enum-blurstyle)|否|BlurStyle.ComponentUltraThick| **命名参数。** 对话框的背景模糊样式。|
|shadow|?[ShadowOptions](./cj-common-types.md#class-shadowoptions)|否|None| **命名参数。** 对话框的阴影选项。<br>初始值：<br>API version 26之前，初始值为ShadowOptions(radius: 0.0)；<br>从API version 26开始，初始值为ShadowOptions(radius: -1.0)。|
|enableHoverMode|Bool|否|false| **命名参数。** 是否响应悬停模式。|
|hoverModeArea|[HoverModeAreaType](#enum-hovermodeareatype)|否|HoverModeAreaType.BottomScreen| **命名参数。** 悬停模式下对话框的显示区域。|

## class ShowToastOptions

```cangjie
public class ShowToastOptions {
    public var message: ResourceStr
    public var duration: UInt32
    public var bottom: Length
    public var showMode: ToastShowMode
    public var alignment: Alignment
    public var offset: Offset
    public var backgroundColor: ResourceColor
    public var textColor: ResourceColor
    public var backgroundBlurStyle: BlurStyle
    public var shadow: ?ShadowOptions = None
    public var enableHoverMode: Bool
    public var hoverModeArea: HoverModeAreaType
    public init(
        message!: ResourceStr,
        duration!: UInt32 = 1500,
        bottom!: Length = 80.vp,
        showMode!: ToastShowMode = ToastShowMode.Default,
        alignment!: Alignment = Alignment.Bottom,
        offset!: Offset = Offset(0.vp, 0.vp),
        backgroundColor!: Color = Color.Transparent,
        textColor!: Color = Color.Black,
        backgroundBlurStyle!: BlurStyle = BlurStyle.ComponentUltraThick,
        shadow!: ?ShadowOptions = None,
        enableHoverMode!: Bool = false,
        hoverModeArea!: HoverModeAreaType = HoverModeAreaType.BottomScreen
    )
}
```

**功能：** Toast显示选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var alignment

```cangjie
public var alignment: Alignment
```

**功能：** Toast在屏幕上的对齐方式。

**类型：** [Alignment](./cj-common-types.md#enum-alignment)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var backgroundColor

```cangjie
public var backgroundColor: ResourceColor
```

**功能：** Toast的背景颜色。

**类型：** [ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var bottom

```cangjie
public var bottom: Length
```

**功能：** Toast对话框与屏幕底部的距离。

**类型：** [Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var duration

```cangjie
public var duration: UInt32
```

**功能：** Toast对话框的持续时间。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var enableHoverMode

```cangjie
public var enableHoverMode: Bool
```

**功能：** 是否响应悬停模式。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var hoverModeArea

```cangjie
public var hoverModeArea: HoverModeAreaType
```

**功能：** 悬停模式下Toast的显示区域。

**类型：** [HoverModeAreaType](#enum-hovermodeareatype)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var message

```cangjie
public var message: ResourceStr
```

**功能：** 要显示的文本。

**类型：** [ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var offset

```cangjie
public var offset: Offset
```

**功能：** Toast偏移量。

**类型：** [Offset](./cj-common-types.md#class-offset)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var backgroundBlurStyle

```cangjie
public var backgroundBlurStyle: BlurStyle
```

**功能：** Toast的背景模糊样式。

**类型：** [BlurStyle](./cj-common-types.md#enum-blurstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var shadow

```cangjie
public var shadow: ?ShadowOptions = None
```

**功能：** Toast的阴影选项。

**类型：** ?[ShadowOptions](./cj-common-types.md#class-shadowoptions)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var showMode

```cangjie
public var showMode: ToastShowMode
```

**功能：** 确定Toast的显示模式。

**类型：** [ToastShowMode](#enum-toastshowmode)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var textColor

```cangjie
public var textColor: ResourceColor
```

**功能：** Toast的文本颜色。

**类型：** [ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(ResourceStr, UInt32, Length, ToastShowMode, Alignment, Offset, Color, Color, BlurStyle, ?ShadowOptions, Bool, HoverModeAreaType)

```cangjie
public init(
    message!: ResourceStr,
    duration!: UInt32 = 1500,
    bottom!: Length = 80.vp,
    showMode!: ToastShowMode = ToastShowMode.Default,
    alignment!: Alignment = Alignment.Bottom,
    offset!: Offset = Offset(0.vp, 0.vp),
    backgroundColor!: Color = Color.Transparent,
    textColor!: Color = Color.Black,
    backgroundBlurStyle!: BlurStyle = BlurStyle.ComponentUltraThick,
    shadow!: ?ShadowOptions = None,
    enableHoverMode!: Bool = false,
    hoverModeArea!: HoverModeAreaType = HoverModeAreaType.BottomScreen
)
```

**功能：** Toast显示选项构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|message|[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-| **命名参数。** 要显示的文本。|
|duration|UInt32|否|1500| **命名参数。** Toast对话框的持续时间。|
|bottom|[Length](./cj-common-types.md#interface-length)|否|80.vp| **命名参数。** Toast对话框与屏幕底部的距离。|
|showMode|[ToastShowMode](#enum-toastshowmode)|否|ToastShowMode.Default| **命名参数。** Toast的显示模式。|
|alignment|[Alignment](./cj-common-types.md#enum-alignment)|否|Alignment.Bottom| **命名参数。** Toast在屏幕上的对齐方式。|
|offset|[Offset](./cj-common-types.md#class-offset)|否|Offset(0.vp, 0.vp)| **命名参数。** Toast偏移量。|
|backgroundColor|[Color](./cj-common-types.md#class-color)|否|Color.Transparent| **命名参数。** Toast的背景颜色。|
|textColor|[Color](./cj-common-types.md#class-color)|否|Color.Black| **命名参数。** Toast的文本颜色。|
|backgroundBlurStyle|[BlurStyle](./cj-common-types.md#enum-blurstyle)|否|BlurStyle.ComponentUltraThick| **命名参数。** Toast的背景模糊样式。|
|shadow|?[ShadowOptions](./cj-common-types.md#class-shadowoptions)|否|None| **命名参数。** Toast的阴影选项。<br>初始值：<br>API version 26之前，初始值为ShadowOptions(radius: 0.0)；<br>从API version 26开始，初始值为ShadowOptions(radius: -1.0)。|
|enableHoverMode|Bool|否|false| **命名参数。** 是否响应悬停模式。|
|hoverModeArea|[HoverModeAreaType](#enum-hovermodeareatype)|否|HoverModeAreaType.BottomScreen| **命名参数。** 悬停模式下Toast的显示区域。|

## enum HoverModeAreaType

```cangjie
public enum HoverModeAreaType <: Equatable<HoverModeAreaType> {
    | TopScreen
    | BottomScreen
    | ...
}
```

**功能：** 提供悬停模式区域类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[HoverModeAreaType](#enum-hovermodeareatype)>

### TopScreen

```cangjie
TopScreen
```

**功能：** 顶部屏幕悬停模式区域类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BottomScreen

```cangjie
BottomScreen
```

**功能：** 底部屏幕悬停模式区域类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func !=(HoverModeAreaType)

```cangjie
public operator func !=(other: HoverModeAreaType): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[HoverModeAreaType](#enum-hovermodeareatype)|是|-|要比较的另一个HoverModeAreaType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(HoverModeAreaType)

```cangjie
public operator func ==(other: HoverModeAreaType): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[HoverModeAreaType](#enum-hovermodeareatype)|是|-|要比较的另一个HoverModeAreaType实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## enum KeyboardAvoidMode

```cangjie
public enum KeyboardAvoidMode <: Equatable<KeyboardAvoidMode> {
    | Default
    | None
    | ...
}
```

**功能：** 提供键盘避免模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[KeyboardAvoidMode](#enum-keyboardavoidmode)>

### Default

```cangjie
Default
```

**功能：** 默认键盘避免模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### None

```cangjie
None
```

**功能：** 无键盘避免模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func !=(KeyboardAvoidMode)

```cangjie
public operator func !=(other: KeyboardAvoidMode): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[KeyboardAvoidMode](#enum-keyboardavoidmode)|是|-|要比较的另一个KeyboardAvoidMode实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(KeyboardAvoidMode)

```cangjie
public operator func ==(other: KeyboardAvoidMode): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[KeyboardAvoidMode](#enum-keyboardavoidmode)|是|-|要比较的另一个KeyboardAvoidMode实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## enum ToastShowMode

```cangjie
public enum ToastShowMode <: Equatable<ToastShowMode> {
    | Default
    | TopMost
    | ...
}
```

**功能：** Toast显示模式枚举。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ToastShowMode](#enum-toastshowmode)>

### Default

```cangjie
Default
```

**功能：** Toast在应用内显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### TopMost

```cangjie
TopMost
```

**功能：** Toast在顶部显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func !=(ToastShowMode)

```cangjie
public operator func !=(other: ToastShowMode): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ToastShowMode](#enum-toastshowmode)|是|-|要比较的另一个ToastShowMode实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(ToastShowMode)

```cangjie
public operator func ==(other: ToastShowMode): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ToastShowMode](#enum-toastshowmode)|是|-|要比较的另一个ToastShowMode实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## type ShowDialogCallBack

```cangjie
public type ShowDialogCallBack = AsyncCallback<Int32>
```

**功能：** ShowDialogCallBack回调函数

**类型：** [AsyncCallback\<Int32>](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)

## type ShowActionMenuCallBack

```cangjie
public type ShowActionMenuCallBack = AsyncCallback<Int32>
```

**功能：** ShowActionMenuCallBack回调函数

**类型：** [AsyncCallback\<Int32>](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)
