# RichEditor

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

支持图文混排和文本交互式编辑的组件。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(?RichEditorController)

```cangjie
public init(controller: ?RichEditorController)
```

**功能：** 创建RichEditor组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|controller|?[RichEditorController](#class-richeditorcontroller)|是|-|富文本控制器。|

## 通用属性/通用事件

通用属性：全部支持。

> **说明：**
>
> - align属性只支持上方、中间和下方位置的对齐方式。
> - 不支持borderImage属性。

通用事件：全部支持。

## 组件属性

### func bindSelectionMenu(?RichEditorSpanType, ?CustomBuilder, ?ResponseType, ?SelectionMenuOptions)

```cangjie
public func bindSelectionMenu(
    spanType!: ?RichEditorSpanType = None,
    content!: ?CustomBuilder,
    responseType!: ?ResponseType = None,
    options!: ?SelectionMenuOptions
): This
```

**功能：** 设置自定义选择菜单。

> **说明：**
>
> 自定义菜单超长时，建议内部嵌套[Scroll](cj-scroll-swipe-scroll.md)组件使用，避免键盘被遮挡。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|spanType|?[RichEditorSpanType](./cj-common-types.md#enum-richeditorspantype)|否|None|**命名参数。** 指定选择菜单的类型。<br>初始值：RichEditorSpanType.Text。|
|content|?[CustomBuilder](./cj-common-types.md#type-custombuilder)|是|-|**命名参数。** 指定选择菜单的内容。使用时结合[@Builder](../../arkui-cj/paradigm/cj-macro-builder.md)和bind方法使用。<br>初始值：{ => }。|
|responseType|?[ResponseType](./cj-common-types.md#enum-responsetype)|否|None|**命名参数。** 指定选择菜单的响应类型。<br>初始值：ResponseType.LongPress。|
|options|?[SelectionMenuOptions](#class-selectionmenuoptions)|是|-|**命名参数。** 指定选择菜单的选项。<br>初始值：SelectionMenuOptions()。|

### func copyOptions(?CopyOptions)

```cangjie
public func copyOptions(value: ?CopyOptions): This
```

**功能：** 设置文本内容支持复制粘贴的能力。

> **说明：**
>
> - copyOptions不为CopyOptions.None时，长按组件内容，会弹出文本选择弹框。如果通过bindSelectionMenu等方式自定义文本选择菜单，则会弹出自定义的菜单。
> - 设置copyOptions为CopyOptions.None，复制、剪切功能不生效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[CopyOptions](./cj-common-types.md#enum-copyoptions)|是|-|复制粘贴的能力。初始值：CopyOptions.LocalDevice。|

### func customKeyboard(?CustomBuilder)

```cangjie
public func customKeyboard(value!: ?CustomBuilder): This
```

**功能：** 定义自定义键盘。

> **说明：**
>
> - 当设置自定义键盘时，输入框激活后不会打开系统输入法，而是加载指定的自定义组件。
> - 自定义键盘的高度可以通过自定义组件根节点的height属性设置，宽度不可设置，使用系统默认值。
> - 自定义键盘采用覆盖原始界面的方式呈现，不会对应用原始界面产生压缩或者上提。
> - 自定义键盘无法获取焦点，但是会拦截手势事件。
> - 默认在输入控件失去焦点时，关闭自定义键盘。
> - 如果设备支持拍摄输入，设置自定义键盘后，该输入框会不支持拍摄输入。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[CustomBuilder](./cj-common-types.md#type-custombuilder)|是|-|**命名参数。** 富文本编辑器的自定义键盘。使用时结合[@Builder](../../arkui-cj/paradigm/cj-macro-builder.md)和bind方法使用。<br>初始值：{ => }。|

## 组件事件

### func onReady(?VoidCallback)

```cangjie
public func onReady(callback: ?VoidCallback): This
```

**功能：** 富文本组件初始化完成后，触发事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[VoidCallback](./cj-common-types.md#type-voidcallback)|是|-|回调函数，富文本组件初始化完成后触发回调。<br>初始值：{ => }。|

### func aboutToImeInput(?Callback\<RichEditorInsertValue, Bool>)

```cangjie
public func aboutToImeInput(callback: ?Callback<RichEditorInsertValue, Bool>): This
```

**功能：** 输入法输入内容前，触发事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[Callback](./cj-common-types.md#type-callbackt-v)\<[RichEditorInsertValue](#class-richeditorinsertvalue), Bool>|是|-|回调函数，输入法输入内容前触发。RichEditorInsertValue：输入法将要输入内容信息。true：组件执行添加内容操作。false：组件不执行添加内容操作。<br>初始值：{ _ => false }。|

### func onImeInputComplete(?Callback\<RichEditorTextSpanResult, Unit>)

```cangjie
public func onImeInputComplete(callback: ?Callback<RichEditorTextSpanResult, Unit>): This
```

**功能：** 输入法完成输入后，触发事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[Callback](./cj-common-types.md#type-callbackt-v)\<[RichEditorTextSpanResult](#class-richeditortextspanresult), Unit>|是|-|回调函数，输入法完成输入后触发回调。RichEditorTextSpanResult：输入法完成输入后的文本Span信息。<br>初始值：{ _ => false }。|

### func onDeleteComplete(?VoidCallback)

```cangjie
public func onDeleteComplete(callback: ?VoidCallback): This
```

**功能：** 输入法完成删除后，触发事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[VoidCallback](./cj-common-types.md#type-voidcallback)|是|-|回调函数，订阅输入法完成删除时触发。<br>初始值：{ => }。|

### func aboutToDelete(?Callback\<RichEditorDeleteValue, Bool>)

```cangjie
public func aboutToDelete(callback: ?Callback<RichEditorDeleteValue, Bool>): This
```

**功能：** 输入法删除内容前，触发事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[Callback](./cj-common-types.md#type-callbackt-v)\<[RichEditorDeleteValue](#class-richeditordeletevalue), Bool>|是|-|回调函数，输入法删除内容前触发该回调 。RichEditorDeleteValue：准备删除的内容所在的文本Span信息。true：组件执行删除操作。false：组件不执行删除操作。<br>初始值：{ _ => false }。|

### func onSelect(?Callback\<RichEditorSelection, Unit>)

```cangjie
public func onSelect(callback: ?Callback<RichEditorSelection, Unit>): This
```

**功能：** 鼠标左键双击选中内容时，会触发事件；松开鼠标左键后，会再次触发事件。手指长按选中内容时，会触发事件；松开手指后，会再次触发事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[Callback](./cj-common-types.md#type-callbackt-v)\<[RichEditorSelection](#class-richeditorselection), Unit>|是|-|回调函数，RichEditorSelection为选中的所有Span信息。<br>初始值：{ _ => }。|

### func onPaste(?PasteEventCallback)

```cangjie
public func onPaste(callback: ?PasteEventCallback): This
```

**功能：** 完成粘贴前，触发事件。

> **说明：**
>
> 开发者可以通过该方法，覆盖系统默认行为，实现图文的粘贴。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[PasteEventCallback](#type-pasteeventcallback)|是|-|回调函数，完成粘贴前，触发回调。PasteEvent：定义用户粘贴事件。<br>初始值：{ _ => }。|

### func onDidChange(?OnDidChangeCallback)

```cangjie
public func onDidChange(callback: ?OnDidChangeCallback): This
```

**功能：** 组件执行增删操作后，触发事件。文本实际未发生增删时，不触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[OnDidChangeCallback](#type-ondidchangecallback)|是|-|回调函数，组件执行增删操作后，触发回调。文本实际未发生增删时，不触发该回调。参数：图文变化前后的内容范围。<br>初始值：{ rangeBefore: TextRange, rangeAfter: TextRange => }。|

## 基础类型定义

### interface RichEditorSpanResult

```cangjie
public interface RichEditorSpanResult {}
```

**功能：** 定义RichEditor span结果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### class RichEditorSpanPosition

```cangjie
public class RichEditorSpanPosition {
    public var spanIndex: ?Int32
    public var spanRange: ?(Int32, Int32)
    public init(
        spanIndex: ?Int32,
        spanRange: ?(Int32, Int32)
    )
}
```

**功能：** 定义span位置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var spanIndex

```cangjie
public var spanIndex: ?Int32
```

**功能：** 定义span的索引。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var spanRange

```cangjie
public var spanRange: ?(Int32, Int32)
```

**功能：** span的范围。

**类型：** ?(Int32, Int32)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?Int32, ?(Int32, Int32))

```cangjie
public init(
    spanIndex: ?Int32,
    spanRange: ?(Int32, Int32)
)
```

**功能：** RichEditorSpanPosition构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|spanIndex|?Int32|是|-|span索引。初始值：0。|
|spanRange|?(Int32, Int32)|是|-|span范围。初始值：(0, 0)。|

### class RichEditorTextStyleResult

```cangjie
public class RichEditorTextStyleResult {
    public var fontColor: String
    public var fontSize: Float64
    public var fontStyle: FontStyle
    public var fontWeight: Int32
    public var fontFamily: String
    public var decoration: DecorationStyleResult
    public init(
        fontColor: String,
        fontSize: Float64,
        fontStyle: FontStyle,
        fontWeight: Int32,
        fontFamily: String,
        decoration: DecorationStyleResult
    )
}
```

**功能：** 定义文本样式结果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var fontColor

```cangjie
public var fontColor: String
```

**功能：** 字体颜色。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var fontSize

```cangjie
public var fontSize: Float64
```

**功能：** 字体大小。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var fontStyle

```cangjie
public var fontStyle: FontStyle
```

**功能：** 字体样式。

**类型：** [FontStyle](./cj-common-types.md#enum-fontstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var fontWeight

```cangjie
public var fontWeight: Int32
```

**功能：** 字体粗细。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var fontFamily

```cangjie
public var fontFamily: String
```

**功能：** 字体族。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var decoration

```cangjie
public var decoration: DecorationStyleResult
```

**功能：** 字体装饰。

**类型：** [DecorationStyleResult](#class-decorationstyleresult)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(String, Float64, FontStyle, Int32, String, DecorationStyleResult)

```cangjie
public init(
    fontColor: String,
    fontSize: Float64,
    fontStyle: FontStyle,
    fontWeight: Int32,
    fontFamily: String,
    decoration: DecorationStyleResult
)
```

**功能：** RichEditorTextStyleResult构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|fontColor|String|是|-|字体颜色。|
|fontSize|Float64|是|-|字体大小。|
|fontStyle|[FontStyle](./cj-common-types.md#enum-fontstyle)|是|-|字体样式。|
|fontWeight|Int32|是|-|字体粗细。|
|fontFamily|String|是|-|字体族。|
|decoration|[DecorationStyleResult](#class-decorationstyleresult)|是|-|字体装饰。|

### class RichEditorImageSpanStyleResult

```cangjie
public class RichEditorImageSpanStyleResult {
    public var size: ?(Float64, Float64)
    public var verticalAlign: ?ImageSpanAlignment
    public var objectFit: ?ImageFit
    public var layoutStyle: ?RichEditorLayoutStyle
}
```

**功能：** 定义span图像样式结果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var size

```cangjie
public var size: ?(Float64, Float64)
```

**功能：** 图像大小。

**类型：** ?(Float64, Float64)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var verticalAlign

```cangjie
public var verticalAlign: ?ImageSpanAlignment
```

**功能：** 图像垂直对齐。

**类型：** ?[ImageSpanAlignment](./cj-common-types.md#enum-imagespanalignment)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var objectFit

```cangjie
public var objectFit: ?ImageFit
```

**功能：** 图像适应方式。

**类型：** ?[ImageFit](./cj-common-types.md#enum-imagefit)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var layoutStyle

```cangjie
public var layoutStyle: ?RichEditorLayoutStyle
```

**功能：** RichEditor图像布局样式。

**类型：** ?[RichEditorLayoutStyle](#class-richeditorlayoutstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### class RichEditorTextSpanResult

```cangjie
public class RichEditorTextSpanResult <: RichEditorSpanResult {
    public var spanPosition: RichEditorSpanPosition
    public var value: String
    public var textStyle: RichEditorTextStyleResult
    public var offsetInSpan: (Int32, Int32)
    public init(
        spanPosition: RichEditorSpanPosition,
        value: String,
        textStyle: RichEditorTextStyleResult,
        offsetInSpan: (Int32, Int32)
    )
}
```

**功能：** 定义文本span结果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [RichEditorSpanResult](#interface-richeditorspanresult)

#### var spanPosition

```cangjie
public var spanPosition: RichEditorSpanPosition
```

**功能：** 文本span的位置。

**类型：** [RichEditorSpanPosition](#class-richeditorspanposition)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var value

```cangjie
public var value: String
```

**功能：** 文本span的内容。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var textStyle

```cangjie
public var textStyle: RichEditorTextStyleResult
```

**功能：** 文本样式。

**类型：** [RichEditorTextStyleResult](#class-richeditortextstyleresult)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var offsetInSpan

```cangjie
public var offsetInSpan: (Int32, Int32)
```

**功能：** span中的偏移量。

**类型：** (Int32, Int32)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(RichEditorSpanPosition, String, RichEditorTextStyleResult, (Int32, Int32))

```cangjie
public init(
    spanPosition: RichEditorSpanPosition,
    value: String,
    textStyle: RichEditorTextStyleResult,
    offsetInSpan: (Int32, Int32)
)
```

**功能：** RichEditorTextSpanResult构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|spanPosition|[RichEditorSpanPosition](#class-richeditorspanposition)|是|-|文本span的位置。|
|value|String|是|-|文本span的内容。|
|textStyle|[RichEditorTextStyleResult](#class-richeditortextstyleresult)|是|-|文本样式。|
|offsetInSpan|(Int32, Int32)|是|-|span中的偏移量。|

### class RichEditorImageSpanResult

```cangjie
public class RichEditorImageSpanResult <: RichEditorSpanResult {
    public var spanPosition: ?RichEditorSpanPosition
    public var valuePixelMap: Option<PixelMap>
    public var valueResourceStr: ?String
    public var imageStyle: ?RichEditorImageSpanStyleResult
    public var offsetInSpan: ?(Int32, Int32)
    public init(
        spanPosition!: ?RichEditorSpanPosition = Option.None,
        valuePixelMap!: Option<PixelMap> = Option.None,
        valueResourceStr!: ?String = None,
        imageStyle!: ?RichEditorImageSpanStyleResult = None,
        offsetInSpan!: ?(Int32, Int32) = None
    )
}
```

**功能：** 定义图像span。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [RichEditorSpanResult](#interface-richeditorspanresult)

#### var spanPosition

```cangjie
public var spanPosition: ?RichEditorSpanPosition
```

**功能：** 图像span的位置。

**类型：** ?[RichEditorSpanPosition](#class-richeditorspanposition)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var valuePixelMap

```cangjie
public var valuePixelMap: Option<PixelMap>
```

**功能：** 图像span的像素图。

**类型：** Option\<[PixelMap](../ImageKit/cj-apis-image.md#class-pixelmap)>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var valueResourceStr

```cangjie
public var valueResourceStr: ?String
```

**功能：** 图像span的资源字符串。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var imageStyle

```cangjie
public var imageStyle: ?RichEditorImageSpanStyleResult
```

**功能：** 图像属性。

**类型：** ?[RichEditorImageSpanStyleResult](#class-richeditorimagespanstyleresult)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var offsetInSpan

```cangjie
public var offsetInSpan: ?(Int32, Int32)
```

**功能：** span中的偏移量。

**类型：** ?(Int32, Int32)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?RichEditorSpanPosition, Option\<PixelMap>, ?String, ?RichEditorImageSpanStyleResult, ?(Int32, Int32))

```cangjie
public init(
    spanPosition!: ?RichEditorSpanPosition = Option.None,
    valuePixelMap!: Option<PixelMap> = Option.None,
    valueResourceStr!: ?String = None,
    imageStyle!: ?RichEditorImageSpanStyleResult = None,
    offsetInSpan!: ?(Int32, Int32) = None
)
```

**功能：** RichEditorImageSpanResult构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|spanPosition|?[RichEditorSpanPosition](#class-richeditorspanposition)|否|Option.None|**命名参数。** 图像span的位置。初始值：RichEditorSpanPosition(0, (0, 0))。|
|valuePixelMap|Option\<[PixelMap](../ImageKit/cj-apis-image.md#class-pixelmap)>|否|Option.None|**命名参数。** 图像span的像素图。|
|valueResourceStr|?String|否|None|**命名参数。** 图像span的资源字符串。初始值：""。|
|imageStyle|?[RichEditorImageSpanStyleResult](#class-richeditorimagespanstyleresult)|否|None|**命名参数。** 图像属性。初始值：RichEditorImageSpanStyleResult()。|
|offsetInSpan|?(Int32, Int32)|否|None|**命名参数。** span中的偏移量。初始值：(0, 0)。|

### class RichEditorSelection

```cangjie
public class RichEditorSelection {
    public var selection: (Int32, Int32)
    public var spans: ArrayList<RichEditorSpanResult>
    public init(selection: ?(Int32, Int32), spans: ?ArrayList<RichEditorSpanResult>)
}
```

**功能：** 选中内容信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var selection

```cangjie
public var selection: (Int32, Int32)
```

**功能：** 选中范围。

**类型：** (Int32, Int32)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var spans

```cangjie
public var spans: ArrayList<RichEditorSpanResult>
```

**功能：** 选中的文本内容。

**类型：** ArrayList\<[RichEditorSpanResult](#interface-richeditorspanresult)>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?(Int32, Int32), ?ArrayList\<RichEditorSpanResult>)

```cangjie
public init(selection: ?(Int32, Int32), spans: ?ArrayList<RichEditorSpanResult>)
```

**功能：** RichEditorSelection构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|selection|?(Int32, Int32)|是|-|选中范围。初始值：(0, 0)。|
|spans|?ArrayList\<[RichEditorSpanResult](#interface-richeditorspanresult)>|是|-|选中的文本内容。初始值：ArrayList\<RichEditorSpanResult>()。|

### class RichEditorDeleteValue

```cangjie
public class RichEditorDeleteValue {
    public var offset: Int32
    public var direction: RichEditorDeleteDirection
    public var length: Int32
    public var richEditorDeleteSpans: ArrayList<RichEditorSpanResult>
    public init(
        offset: Int32,
        direction: RichEditorDeleteDirection,
        length: Int32,
        richEditorDeleteSpans: ArrayList<RichEditorSpanResult>
    )
}
```

**功能：** 提供从文本中删除值的接口。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var offset

```cangjie
public var offset: Int32
```

**功能：** 删除的偏移量。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var direction

```cangjie
public var direction: RichEditorDeleteDirection
```

**功能：** 删除的方向。

**类型：** [RichEditorDeleteDirection](./cj-common-types.md#enum-richeditordeletedirection)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var length

```cangjie
public var length: Int32
```

**功能：** 删除的文本长度。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var richEditorDeleteSpans

```cangjie
public var richEditorDeleteSpans: ArrayList<RichEditorSpanResult>
```

**功能：** 删除的span对象。

**类型：** ArrayList\<[RichEditorSpanResult](#interface-richeditorspanresult)>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(Int32, RichEditorDeleteDirection, Int32, ArrayList\<RichEditorSpanResult>)

```cangjie
public init(
    offset: Int32,
    direction: RichEditorDeleteDirection,
    length: Int32,
    richEditorDeleteSpans: ArrayList<RichEditorSpanResult>
)
```

**功能：** RichEditorDeleteValue构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|offset|Int32|是|-|删除的偏移量。|
|direction|[RichEditorDeleteDirection](./cj-common-types.md#enum-richeditordeletedirection)|是|-|删除的方向。|
|length|Int32|是|-|删除的文本长度。|
|richEditorDeleteSpans|ArrayList\<[RichEditorSpanResult](#interface-richeditorspanresult)>|是|-|删除的span对象。|

### class TextRange

```cangjie
public class TextRange {
    public var start: ?Int32
    public var end: ?Int32
    public init(start: ?Int32, end: ?Int32)
}
```

**功能：** 定义文本类型组件的范围。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var start

```cangjie
public var start: ?Int32
```

**功能：** 起始偏移量。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var end

```cangjie
public var end: ?Int32
```

**功能：** 结束偏移量。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?Int32, ?Int32)

```cangjie
public init(start: ?Int32, end: ?Int32)
```

**功能：** TextRange构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|start|?Int32|是|-|起始偏移量。初始值：-1。|
|end|?Int32|是|-|结束偏移量。初始值：-1。|

### class PasteEvent

```cangjie
public class PasteEvent {}
```

**功能：** 定义粘贴事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### func preventDefault()

```cangjie
public func preventDefault(): Unit
```

**功能：** 覆盖系统粘贴事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### class RichEditorInsertValue

```cangjie
public class RichEditorInsertValue {
    public var insertOffset: Int32
    public var insertValue: String
    public init(
        insertOffset: ?Int32,
        insertValue: ?String
    )
}
```

**功能：** 定义RichEditor插入值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var insertOffset

```cangjie
public var insertOffset: Int32
```

**功能：** 插入偏移量。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var insertValue

```cangjie
public var insertValue: String
```

**功能：** 插入值。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?Int32, ?String)

```cangjie
public init(
    insertOffset: ?Int32,
    insertValue: ?String
)
```

**功能：** RichEditorInsertValue构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|insertOffset|?Int32|是|-|插入偏移量。初始值：0。|
|insertValue|?String|是|-|插入值。初始值：""。|

### class DecorationStyleResult

```cangjie
public class DecorationStyleResult {
    public var decorationType: ?TextDecorationType
    public var color: ResourceColor
    public init(
        decorationType: TextDecorationType,
        color: ResourceColor
    )
}
```

**功能：** 定义装饰样式结果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var decorationType

```cangjie
public var decorationType: ?TextDecorationType
```

**功能：** 装饰类型。

**类型：** ?[TextDecorationType](./cj-common-types.md#enum-textdecorationstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var color

```cangjie
public var color: ResourceColor
```

**功能：** 颜色。

**类型：** [ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(TextDecorationType, ResourceColor)

```cangjie
public init(
    decorationType: TextDecorationType,
    color: ResourceColor
)
```

**功能：** DecorationStyleResult构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|decorationType|[TextDecorationType](./cj-common-types.md#enum-textdecorationstyle)|是|-|装饰类型。|
|color|[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|颜色。|

### class SelectionMenuOptions

```cangjie
public class SelectionMenuOptions {
    public var onAppear: ?VoidCallback
    public var onDisappear: ?VoidCallback
    public init(onAppear!: ?() -> Unit = None, onDisappear!: ?() -> Unit = None)
}
```

**功能：** 定义选择菜单选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var onAppear

```cangjie
public var onAppear: ?VoidCallback
```

**功能：** 选择菜单出现时的回调函数。

**类型：** ?[VoidCallback](./cj-common-types.md#type-voidcallback)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var onDisappear

```cangjie
public var onDisappear: ?VoidCallback
```

**功能：** 选择菜单消失时的回调函数。

**类型：** ?[VoidCallback](./cj-common-types.md#type-voidcallback)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?() -> Unit, ?() -> Unit)

```cangjie
public init(onAppear!: ?() -> Unit = None, onDisappear!: ?() -> Unit = None)
```

**功能：** SelectionMenuOptions构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|onAppear|?() -> Unit|否|None|**命名参数。** 选择菜单出现时的回调函数。初始值：{=>}。|
|onDisappear|?() -> Unit|否|None|**命名参数。** 选择菜单消失时的回调函数。初始值：{=>}。|

### class RichEditorTextStyle

```cangjie
public class RichEditorTextStyle {
    public var fontColor: ?ResourceColor
    public var fontSize: ?Length
    public var fontStyle: ?FontStyle
    public var fontWeight: ?FontWeight
    public var fontFamily: ?ResourceStr
    public var decoration: ?TextDecorationOptions
    public init(
        fontColor!: ?ResourceColor = None,
        fontSize!: ?Length = None,
        fontStyle!: ?FontStyle = None,
        fontWeight!: ?FontWeight = None,
        fontFamily!: ?ResourceStr = None,
        decoration!: ?TextDecorationOptions = None
    )
}
```

**功能：** 定义span文本样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var fontColor

```cangjie
public var fontColor: ?ResourceColor
```

**功能：** 字体颜色。

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var fontSize

```cangjie
public var fontSize: ?Length
```

**功能：** 字体大小。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var fontStyle

```cangjie
public var fontStyle: ?FontStyle
```

**功能：** 字体样式。

**类型：** ?[FontStyle](./cj-common-types.md#enum-fontstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var fontWeight

```cangjie
public var fontWeight: ?FontWeight
```

**功能：** 字体粗细。

**类型：** ?[FontWeight](./cj-common-types.md#enum-fontweight)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var fontFamily

```cangjie
public var fontFamily: ?ResourceStr
```

**功能：** 字体族。

**类型：** ?[ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var decoration

```cangjie
public var decoration: ?TextDecorationOptions
```

**功能：** 字体装饰。

**类型：** ?[TextDecorationOptions](#class-textdecorationoptions)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?ResourceColor, ?Length, ?FontStyle, ?FontWeight, ?ResourceStr, ?TextDecorationOptions)

```cangjie
public init(
    fontColor!: ?ResourceColor = None,
    fontSize!: ?Length = None,
    fontStyle!: ?FontStyle = None,
    fontWeight!: ?FontWeight = None,
    fontFamily!: ?ResourceStr = None,
    decoration!: ?TextDecorationOptions = None
)
```

**功能：** RichEditorTextStyle构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|fontColor|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|None|**命名参数。** 字体颜色。初始值：Color.Black。|
|fontSize|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 字体大小。初始值：16.vp。|
|fontStyle|?[FontStyle](./cj-common-types.md#enum-fontstyle)|否|None|**命名参数。** 字体样式。初始值：FontStyle.Normal。|
|fontWeight|?[FontWeight](./cj-common-types.md#enum-fontweight)|否|None|**命名参数。** 字体粗细。初始值：FontWeight.Normal。|
|fontFamily|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None|**命名参数。** 字体族。初始值：DEFAULT_FONT。|
|decoration|?[TextDecorationOptions](#class-textdecorationoptions)|否|None|**命名参数。** 字体装饰。初始值：TextDecorationOptions(decorationType: TextDecorationType.None, color: Color.Black)。|

### class RichEditorTextSpanOptions

```cangjie
public class RichEditorTextSpanOptions {
    public var offset: ?Int32
    public var style: ?RichEditorTextStyle
    public init(offset!: ?Int32 = None, style!: ?RichEditorTextStyle = None)
}
```

**功能：** 定义RichEditor的span选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var offset

```cangjie
public var offset: ?Int32
```

**功能：** 添加文本span的偏移量。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var style

```cangjie
public var style: ?RichEditorTextStyle
```

**功能：** 文本样式。

**类型：** ?[RichEditorTextStyle](#class-richeditortextstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?Int32, ?RichEditorTextStyle)

```cangjie
public init(offset!: ?Int32 = None, style!: ?RichEditorTextStyle = None)
```

**功能：** RichEditorTextSpanOptions构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|offset|?Int32|否|None|**命名参数。** 添加文本span的偏移量。初始值：Int32.Max。|
|style|?[RichEditorTextStyle](#class-richeditortextstyle)|否|None|**命名参数。** 文本样式。初始值：RichEditorTextStyle()。|

### class RichEditorLayoutStyle

```cangjie
public class RichEditorLayoutStyle {
    public var margin: ?Margin
    public var borderRadius: ?BorderRadiuses
    public init(margin!: ?Margin = None, borderRadius!: ?BorderRadiuses = None)
    public init(margin!: ?Length, borderRadius!: ?Length)
}
```

**功能：** 定义richEditor图像布局样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var margin

```cangjie
public var margin: ?Margin
```

**功能：** 边距。

**类型：** ?[Margin](./cj-common-types.md#class-margin)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var borderRadius

```cangjie
public var borderRadius: ?BorderRadiuses
```

**功能：** 边框圆角。

**类型：** ?[BorderRadiuses](./cj-common-types.md#class-borderradiuses)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?Margin, ?BorderRadiuses)

```cangjie
public init(margin!: ?Margin = None, borderRadius!: ?BorderRadiuses = None)
```

**功能：** RichEditorLayoutStyle构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|margin|?[Margin](./cj-common-types.md#class-margin)|否|None|**命名参数。** 边距。初始值：Margin()。|
|borderRadius|?[BorderRadiuses](./cj-common-types.md#class-borderradiuses)|否|None|**命名参数。** 边框圆角。初始值：BorderRadiuses()。|

#### init(?Length, ?Length)

```cangjie
public init(margin!: ?Length, borderRadius!: ?Length)
```

**功能：** RichEditorLayoutStyle构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|margin|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 边距。|
|borderRadius|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 边框圆角。|

### class RichEditorImageSpanStyle

```cangjie
public class RichEditorImageSpanStyle {
    public var size: Option<(Length, Length)>
    public var verticalAlign: ?ImageSpanAlignment
    public var objectFit: ?ImageFit
    public init(
        size!: Option<(Length, Length)> = Option.None,
        verticalAlign!: ?ImageSpanAlignment = Option.None,
        objectFit!: ?ImageFit = Option.None
    )
}
```

**功能：** 定义span图像样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var size

```cangjie
public var size: Option<(Length, Length)>
```

**功能：** 图像大小。

**类型：** Option\<([Length](./cj-common-types.md#interface-length), [Length](./cj-common-types.md#interface-length))>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var verticalAlign

```cangjie
public var verticalAlign: ?ImageSpanAlignment
```

**功能：** 图像垂直对齐。

**类型：** ?[ImageSpanAlignment](./cj-common-types.md#enum-imagespanalignment)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var objectFit

```cangjie
public var objectFit: ?ImageFit
```

**功能：** 图像适应方式。

**类型：** ?[ImageFit](./cj-common-types.md#enum-imagefit)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(Option\<(Length, Length)>, ?ImageSpanAlignment, ?ImageFit)

```cangjie
public init(
    size!: Option<(Length, Length)> = Option.None,
    verticalAlign!: ?ImageSpanAlignment = Option.None,
    objectFit!: ?ImageFit = Option.None
)
```

**功能：** RichEditorImageSpanStyle构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|size|Option\<([Length](./cj-common-types.md#interface-length), [Length](./cj-common-types.md#interface-length))>|否|Option.None|**命名参数。** 图像大小。|
|verticalAlign|?[ImageSpanAlignment](./cj-common-types.md#enum-imagespanalignment)|否|Option.None|**命名参数。** 图像垂直对齐。初始值：ImageSpanAlignment.Bottom。|
|objectFit|?[ImageFit](./cj-common-types.md#enum-imagefit)|否|Option.None|**命名参数。** 图像适应方式。初始值：ImageFit.Cover。|

### class RichEditorImageSpanOptions

```cangjie
public class RichEditorImageSpanOptions {
    public var offset: ?Int32
    public var imageStyle: ?RichEditorImageSpanStyle
    public init(
        offset!: ?Int32 = None,
        imageStyle!: ?RichEditorImageSpanStyle = None
    )
}
```

**功能：** 定义RichEditor的图像span选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var offset

```cangjie
public var offset: ?Int32
```

**功能：** 添加图像span的偏移量。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var imageStyle

```cangjie
public var imageStyle: ?RichEditorImageSpanStyle
```

**功能：** 图像样式。

**类型：** ?[RichEditorImageSpanStyle](#class-richeditorimagespanstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?Int32, ?RichEditorImageSpanStyle)

```cangjie
public init(
    offset!: ?Int32 = None,
    imageStyle!: ?RichEditorImageSpanStyle = None
)
```

**功能：** RichEditorImageSpanOptions构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|offset|?Int32|否|None|**命名参数。** 添加图像span的偏移量。初始值：Int32.Max。|
|imageStyle|?[RichEditorImageSpanStyle](#class-richeditorimagespanstyle)|否|None|**命名参数。** 图像样式。初始值：RichEditorImageSpanStyle()。|

### class RichEditorParagraphStyle

```cangjie
public class RichEditorParagraphStyle {
    public var textAlign: ?TextAlign
    public var leadingMargin: ?LeadingMarginType
    public init(textAlign!: ?TextAlign = None)
    public init(textAlign!: ?TextAlign = None, leadingMargin!: ?Length)
    public init(textAlign!: ?TextAlign = None, leadingMargin!: ?LeadingMarginPlaceholder)
}
```

**功能：** 定义段落样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var textAlign

```cangjie
public var textAlign: ?TextAlign
```

**功能：** 文本对齐。

**类型：** ?[TextAlign](./cj-common-types.md#enum-textalign)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var leadingMargin

```cangjie
public var leadingMargin: ?LeadingMarginType
```

**功能：** 首行缩进。

**类型：** ?[LeadingMarginType](#enum-leadingmargintype)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?TextAlign)

```cangjie
public init(textAlign!: ?TextAlign = None)
```

**功能：** RichEditorParagraphStyle构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|textAlign|?[TextAlign](./cj-common-types.md#enum-textalign)|否|None|**命名参数。** 文本对齐。初始值：TextAlign.Start。|

#### init(?TextAlign, ?Length)

```cangjie
public init(textAlign!: ?TextAlign = None, leadingMargin!: ?Length)
```

**功能：** RichEditorParagraphStyle构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|textAlign|?[TextAlign](./cj-common-types.md#enum-textalign)|否|None|**命名参数。** 文本对齐。初始值：TextAlign.Start。|
|leadingMargin|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 首行缩进。|

#### init(?TextAlign, ?LeadingMarginPlaceholder)

```cangjie
public init(textAlign!: ?TextAlign = None, leadingMargin!: ?LeadingMarginPlaceholder)
```

**功能：** RichEditorParagraphStyle构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|textAlign|?[TextAlign](./cj-common-types.md#enum-textalign)|否|None|**命名参数。** 文本对齐。初始值：TextAlign.Start。|
|leadingMargin|?[LeadingMarginPlaceholder](#class-leadingmarginplaceholder)|是|-|**命名参数。** 首行缩进。|

### class TextDecorationOptions

```cangjie
public class TextDecorationOptions {
    public var decorationType: ?TextDecorationType
    public var color: ?ResourceColor
    public init(decorationType!: ?TextDecorationType, color!: ?ResourceColor = None)
}
```

**功能：** 定义文本装饰选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var decorationType

```cangjie
public var decorationType: ?TextDecorationType
```

**功能：** 装饰类型。

**类型：** ?[TextDecorationType](./cj-common-types.md#enum-textdecorationstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var color

```cangjie
public var color: ?ResourceColor
```

**功能：** 颜色。

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?TextDecorationType, ?ResourceColor)

```cangjie
public init(decorationType!: ?TextDecorationType, color!: ?ResourceColor = None)
```

**功能：** TextDecorationOptions构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|decorationType|?[TextDecorationType](./cj-common-types.md#enum-textdecorationstyle)|是|-|**命名参数。** 装饰类型。初始值：TextDecorationType.None。|
|color|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|None|**命名参数。** 颜色。初始值：Color.Black。|

### class LeadingMarginPlaceholder

```cangjie
public class LeadingMarginPlaceholder {
    public var pixelMap: PixelMap
    public var size: ?(Length, Length)
    public init(pixelMap!: PixelMap, size!: ?(Length, Length))
}
```

**功能：** 定义段落的首行缩进占位符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var pixelMap

```cangjie
public var pixelMap: PixelMap
```

**功能：** 占位符像素图。

**类型：** [PixelMap](../ImageKit/cj-apis-image.md#class-pixelmap)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var size

```cangjie
public var size: ?(Length, Length)
```

**功能：** 占位符大小。

**类型：** ?([Length](./cj-common-types.md#interface-length), [Length](./cj-common-types.md#interface-length))

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(PixelMap, ?(Length, Length))

```cangjie
public init(pixelMap!: PixelMap, size!: ?(Length, Length))
```

**功能：** LeadingMarginPlaceholder构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|pixelMap|[PixelMap](../ImageKit/cj-apis-image.md#class-pixelmap)|是|-|**命名参数。** 占位符像素图。|
|size|?([Length](./cj-common-types.md#interface-length), [Length](./cj-common-types.md#interface-length))|是|-|**命名参数。** 占位符大小。初始值：(0.0.px, 0.0.px)。|

### class RichEditorBaseController

```cangjie
public open class RichEditorBaseController {
    protected init(id: Int64)
}
```

**功能：** 提供RichEditor的基础控制器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(Int64)

```cangjie
protected init(id: Int64)
```

**功能：** 创建实例。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|id|Int64|是|-|标识号|

#### func getCaretOffset()

```cangjie
public func getCaretOffset(): Int32
```

**功能：** 从控制器获取光标偏移量。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:---|:---|
|Int32|光标偏移量。|

#### func setCaretOffset(?Int32)

```cangjie
public func setCaretOffset(offset: ?Int32): Bool
```

**功能：** 设置光标偏移量。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|offset|?Int32|是|-|光标偏移量。初始值：-1。|

**返回值：**

|类型|说明|
|:---|:---|
|Bool|设置结果。|

### class RichEditorController

```cangjie
public class RichEditorController <: RichEditorBaseController {
    public init()
}
```

**功能：** 提供RichEditor的控制器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [RichEditorBaseController](#class-richeditorbasecontroller)

#### init()

```cangjie
public init()
```

**功能：** 创建RichEditorController类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### func addTextSpan(?ResourceStr, ?RichEditorTextSpanOptions)

```cangjie
public func addTextSpan(content!: ?ResourceStr, options!: ?RichEditorTextSpanOptions = None): Int32
```

**功能：** 添加文本内容，如果组件光标闪烁，插入后光标位置更新为新插入文本的后面。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|content|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|**命名参数。** 文本内容。初始值：""。|
|options|?[RichEditorTextSpanOptions](#class-richeditortextspanoptions)|否|None|**命名参数。** 文本选项。初始值：RichEditorTextSpanOptions()。|

**返回值：**

|类型|说明|
|:---|:---|
|Int32|添加完成的TextSpan所在的位置。|

#### func addImageSpan(?ResourceStr, ?RichEditorImageSpanOptions)

```cangjie
public func addImageSpan(value!: ?ResourceStr, options!: ?RichEditorImageSpanOptions = None): Int32
```

**功能：** 添加图片内容，如果组件光标闪烁，插入后光标位置更新为新插入图片的后面。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|**命名参数。** 图片内容。初始值：""。|
|options|?[RichEditorImageSpanOptions](#class-richeditorimagespanoptions)|否|None|**命名参数。** 图片选项。初始值：RichEditorImageSpanOptions()。|

**返回值：**

|类型|说明|
|:---|:---|
|Int32|添加完成的ImageSpan所在的位置。|

#### func updateSpanStyle(?Int32, ?Int32, ?RichEditorTextStyle)

```cangjie
public func updateSpanStyle(start!: ?Int32 = None, end!: ?Int32 = None, textStyle!: ?RichEditorTextStyle): Unit
```

**功能：** 修改span样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|start|?Int32|否|None|**命名参数。** 起始位置。初始值：0。|
|end|?Int32|否|None|**命名参数。** 结束位置。初始值：Int32.Max。|
|textStyle|?[RichEditorTextStyle](#class-richeditortextstyle)|是|-|**命名参数。** 文本样式。初始值：RichEditorTextStyle()。|

#### func updateSpanStyle(?Int32, ?Int32, ?RichEditorImageSpanStyle)

```cangjie
public func updateSpanStyle(start!: ?Int32 = None, end!: ?Int32 = None, imageStyle!: ?RichEditorImageSpanStyle): Unit
```

**功能：** 修改span样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|start|?Int32|否|None|**命名参数。** 起始位置。初始值：0。|
|end|?Int32|否|None|**命名参数。** 结束位置。初始值：Int32.Max。|
|imageStyle|?[RichEditorImageSpanStyle](#class-richeditorimagespanstyle)|是|-|**命名参数。** 图像样式。初始值：RichEditorImageSpanStyle()。|

#### func deleteSpans(?Int32, ?Int32)

```cangjie
public func deleteSpans(start!: ?Int32 = None, end!: ?Int32 = None): Unit
```

**功能：** 删除指定范围内的文本和图片。

> **说明：**
>
> 当所有参数省略时，删除所有文本和图片。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|start|?Int32|否|None|**命名参数。** 起始位置，省略或者设置负值时表示从0开始。初始值：0。|
|end|?Int32|否|None|**命名参数。** 结束位置，省略或者超出文本范围时表示到结尾。初始值：Int32.Max。|

#### func closeSelectionMenu()

```cangjie
public func closeSelectionMenu(): Unit
```

**功能：** 关闭自定义选择菜单或系统默认选择菜单。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### func updateParagraphStyle(?Int32, ?Int32, ?RichEditorParagraphStyle)

```cangjie
public func updateParagraphStyle(start!: ?Int32 = None, end!: ?Int32 = None, style!: ?RichEditorParagraphStyle): Unit
```

**功能：** 修改span样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|start|?Int32|否|None|**命名参数。** 起始位置。初始值：0。|
|end|?Int32|否|None|**命名参数。** 结束位置。初始值：-1。|
|style|?[RichEditorParagraphStyle](#class-richeditorparagraphstyle)|是|-|**命名参数。** 段落样式。初始值：RichEditorParagraphStyle()。|

#### func getSpans(?Int32, ?Int32)

```cangjie
public func getSpans(start!: ?Int32 = None, end!: ?Int32 = None): ArrayList<RichEditorSpanResult>
```

**功能：** 获取Span信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|start|?Int32|否|None|**命名参数。** 起始位置。初始值：-1。|
|end|?Int32|否|None|**命名参数。** 结束位置。初始值：-1。|

**返回值：**

|类型|说明|
|:---|:---|
|ArrayList\<[RichEditorSpanResult](#interface-richeditorspanresult)>|Span内容。|

### enum LeadingMarginType

```cangjie
public enum LeadingMarginType {
    | LengthType(Length)
    | PlaceholderType(LeadingMarginPlaceholder)
    | None
    | ...
}
```

**功能：** 定义首行缩进类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### LengthType(Length)

```cangjie
LengthType(Length)
```

**功能：** 长度类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### PlaceholderType(LeadingMarginPlaceholder)

```cangjie
PlaceholderType(LeadingMarginPlaceholder)
```

**功能：** 占位符类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### None

```cangjie
None
```

**功能：** 无。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### type PasteEventCallback

```cangjie
public type PasteEventCallback = (PasteEvent) -> Unit
```

**功能：** 执行粘贴操作时的回调函数。

**类型：** ([PasteEvent](#class-pasteevent)) -> Unit

### type OnDidChangeCallback

```cangjie
public type OnDidChangeCallback = (rangeBefore: TextRange, rangeAfter: TextRange) -> Unit
```

**功能：** 内容更改后的回调函数。

**类型：** ([TextRange](#class-textrange), [TextRange](#class-textrange)) -> Unit

## 示例代码

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.i18n.*
import ohos.resource_manager.*
import ohos.hilog.*
import ohos.resource.*

@Entry
@Component
class EntryView {
    let controller = RichEditorController()

    @State var position: Int32 = 0

    @Builder
    func builder(){
        Column {
            ForEach(["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"], itemGeneratorFunc: {item: String, idx: Int64 =>
                Button(item)
                .width(40.vp)
                .height(40.vp)
                .fontColor(0x66000000)
                .fontSize(16.fp)
            })
        }
        .borderRadius(24.vp)
        .padding(top: 4.vp, bottom: 4.vp, left: 16.vp, right: 16.vp)
        .backgroundColor(Color.Green)
        .margin(right: 24.vp, bottom: 4.vp, top: 0.vp)
        .width(130.vp)
    }

    func build() {
        Column(space: 30) {
            Row {
                Button("getCaretOffset")
                .onClick({
                    evt =>
                    Hilog.info(0, "AppLogCj", controller.getCaretOffset().toString())
                    this.position = controller.getCaretOffset()
                }).width(400.px).height(150.px)

                Text("position: ${this.position.toString()}")
            }

            Row {
                Button("setCaretOffset 0")
                .onClick({
                    evt =>
                    controller.setCaretOffset(0)
                }).width(400.px).height(150.px)

                Text("position: ${this.position.toString()}")
            }

            Row {
                Button("addText Hello")
                .onClick({
                    evt =>
                    controller.addTextSpan(
                        content: "Hello",
                        options: RichEditorTextSpanOptions(
                            style: RichEditorTextStyle(
                                fontColor: Color(0XFF1298),
                                fontSize: 20.fp,
                                fontStyle: FontStyle.Italic,
                                decoration: TextDecorationOptions(
                                    decorationType: TextDecorationType.Overline,
                                    color: Color(0X12FF98)
                                ),
                            )
                        )
                    )
                }).width(400.px).height(150.px)

                Button("addImage")
                .onClick({
                    evt =>
                    controller.addImageSpan(
                        value: @r(app.media.startIcon),
                        options: RichEditorImageSpanOptions(
                            imageStyle: RichEditorImageSpanStyle(
                                size: (24.vp, 24.vp)
                            )
                        )
                    )
                }).width(400.px).height(150.px)
            }

            Row {
                Button("updateParagraphStyle")
                .onClick({
                    evt =>
                    let array = controller.updateParagraphStyle(
                        start: 0,
                        end: 100,
                        style: RichEditorParagraphStyle(
                            textAlign: TextAlign.Center,
                            leadingMargin: 24.px
                        )
                    )
                }).width(400.px).height(150.px)
            }

            RichEditor(controller)
            .customKeyboard(value: builder)
            .bindSelectionMenu(
                spanType: RichEditorSpanType.Text,
                content: builder,
                responseType: ResponseType.LongPress,
                options: SelectionMenuOptions(onAppear: { => Hilog.info(0, "AppLogCj", "SelectionMenuOptions onAppear")}, onDisappear: { => Hilog.info(0, "AppLogCj", "SelectionMenuOptions onDisappear")})
            )
            .copyOptions(CopyOptions.None)
            .onReady({ => Hilog.info(0, "AppLogCj", "RichEditor onReady!!")})
            .onDeleteComplete({ => Hilog.info(0, "AppLogCj", "RichEditor onDeleteComplete!!")})
            .onSelect({ value =>
                Hilog.info(0, "AppLogCj", "RichEditor onSelect. ${value.selection[0]} ~ ${value.selection[1]}")
            })
        }
    }
}
```

![richeditor](figures/richeditor.gif)
