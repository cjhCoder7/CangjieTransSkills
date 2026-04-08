# 滚动组件通用API

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

滚动组件通用属性和事件目前只支持[List](./cj-scroll-swipe-list.md)、[Grid](./cj-scroll-swipe-grid.md)、[Scroll](./cj-scroll-swipe-scroll.md)。

## 组件属性

### func scrollBar(?BarState)

```cangjie
public func scrollBar(barState: ?BarState): T
```

**功能：** 设置滚动条状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|barState|?[BarState](./cj-common-types.md#enum-barstate)|是|-|滚动条状态。<br>初始值：<br>List、Grid、Scroll组件初始值为：BarState.Auto。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func scrollBarColor(?ResourceColor)

```cangjie
public func scrollBarColor(color: ?ResourceColor): T
```

**功能：** 设置滚动条的颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|color|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|滚动条的颜色。<br> 初始值：0x182431（40%不透明度）。为HEX格式颜色，支持rgb或者argb，示例：0xffffff。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func scrollBarWidth(?Length)

```cangjie
public func scrollBarWidth(value: ?Length): T
```

**功能：** 设置滚动条的宽度，不支持百分比设置。宽度设置后，滚动条正常状态和按压状态宽度均为滚动条的宽度值。如果滚动条的宽度超过滚动组件主轴方向的高度，则滚动条的宽度会变为初始值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|滚动条的宽度。<br> 初始值：4 <br> 单位：vp <br> 取值范围：设置为小于0的值时，按初始值处理。设置为0时，不显示滚动条。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func clipContent(?ContentClipMode)

```cangjie
public func clipContent(clip: ?ContentClipMode): T
```

**功能：** 设置滚动容器的内容层裁剪区域。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|clip|?[ContentClipMode](./cj-scroll-swipe-scroll.md#enum-contentclipmode)|是|-|裁剪只针对滚动容器的内容，即其子节点，背景不受影响。<br>初始值：Grid、Scroll的初始值为ContentClipMode.Boundary，List的初始值为ContentClipMode.ContentOnly。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func clipContent(?RectShape)

```cangjie
public func clipContent(clip: ?RectShape): T
```

**功能：** 设置滚动容器的内容层裁剪区域。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|clip|?[RectShape](./cj-apis-shape.md#class-rectshape)|是|-|裁剪只针对滚动容器的内容，即其子节点，背景不受影响。通过RectShape传入自定义矩形区域时仅支持设置宽高和相对于组件左上角的[offset](./cj-universal-attribute-location.md#func-offsetlength-length)，不支持圆角。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func enableScrollInteraction(?Bool)

```cangjie
public func enableScrollInteraction(value: ?Bool): T
```

**功能：** 设置是否支持滚动手势。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|是否支持滚动手势，当设置为false时，无法通过手指或者鼠标滚动，但不影响控制器[Scroller](./cj-scroll-swipe-scroll.md#class-scroller)的滚动接口。<br>初始值：true。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func fadingEdge(Option\<Bool>)

```cangjie
public func fadingEdge(enabled: Option<Bool>): T
```

**功能：** 设置是否开启边缘渐隐效果及设置边缘渐隐长度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|enabled|Option\<Bool>|是|-|fadingEdge生效时，会覆盖原组件的.overlay()属性。<br/>fadingEdge生效时，建议不在该组件上设置background相关属性，会影响渐隐的显示效果。<br>fadingEdge生效时，组件会裁剪到边界，设置组件的clip属性为false不生效。<br/>初始值：false，不开启边缘渐隐效果。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func fadingEdge(Option\<Bool>,?FadingEdgeOptions)

```cangjie
public func fadingEdge(enabled: Option<Bool>, options: ?FadingEdgeOptions): T
```

**功能：** 设置是否开启边缘渐隐效果及设置边缘渐隐长度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|enabled|Option\<Bool>|是|-|fadingEdge生效时，会覆盖原组件的.overlay()属性。<br/>fadingEdge生效时，建议不在该组件上设置background相关属性，会影响渐隐的显示效果。<br>fadingEdge生效时，组件会裁剪到边界，设置组件的clip属性为false不生效。<br/>初始值：false，不开启边缘渐隐效果。|
|options|?[FadingEdgeOptions](./cj-scroll-swipe-scroll.md#class-fadingedgeoptions)|是|-|边缘渐隐参数对象。可以通过该对象定义边缘渐隐效果属性，比如设置渐隐长度。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func flingSpeedLimit(?Float64)

```cangjie
public func flingSpeedLimit(speedLimit: ?Float64): T
```

**功能：** 限制跟手滑动结束后，Fling动效开始时的最大初始速度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|speedLimit|?Float64|是|-|Fling动效开始时的最大初始速度。<br> 初始值：9000.0 <br> 单位：vp/s <br> 取值范围：(0, +∞)，设置为小于等于0的值时，按初始值处理。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func friction(?Float64)

```cangjie
public func friction(value: ?Float64): T
```

**功能：** 设置摩擦系数，手动划动滚动区域时生效，只对惯性滚动过程有影响，对惯性滚动过程中的链式效果有间接影响。设置为小于等于0的值时，按初始值处理。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Float64|是|-|摩擦系数。<br>初始值：非可穿戴设备为0.75，可穿戴设备为0.9。<br> 取值范围：(0, +∞)，设置为小于等于0的值时，按初始值处理。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func friction(?AppResource)

```cangjie
public func friction(value: ?AppResource): T
```

**功能：** 设置摩擦系数，手动划动滚动区域时生效，只对惯性滚动过程有影响，对惯性滚动过程中的链式效果有间接影响。设置为小于等于0的值时，按初始值处理。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[AppResource](../LocalizationKit/cj-apis-resource.md#class-appresource)|是|-|摩擦系数。<br>初始值：非可穿戴设备为0.75，可穿戴设备为0.9。<br> 取值范围：(0, +∞)，设置为小于等于0的值时，按初始值处理。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func nestedScroll(?NestedScrollOptions)

```cangjie
public func nestedScroll(value: ?NestedScrollOptions): T
```

**功能：** 设置向前和向后两个方向上的嵌套滚动模式，实现与父组件的滚动联动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[NestedScrollOptions](./cj-scroll-swipe-scroll.md#class-nestedscrolloptions)|是|-|嵌套滚动选项。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

## 组件事件

### func onDidScroll(?OnScrollCallBack)

```cangjie
public func onDidScroll(handler: ?OnScrollCallBack): T
```

**功能：** 滚动组件滑动时触发，返回当前帧滑动的偏移量和当前滑动状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|handler|?[OnScrollCallBack](./cj-scroll-swipe-scroll.md#type-onscrollcallback)|是|-|滚动组件滑动时触发的回调。<br> 参数一：每帧滚动的偏移量，滚动组件的内容向上滚动时偏移量为正，向下滚动时偏移量为负。单位vp。 <br> 参数二：当前滑动状态。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func onReachEnd(?() -> Unit)

```cangjie
public func onReachEnd(event: ?() -> Unit): T
```

**功能：** 滚动组件到达末尾位置时触发。滚动组件边缘效果为弹簧效果时，划动经过末尾位置时触发一次，回弹回末尾位置时再触发一次。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?() -> Unit|是|-|回调函数，滚动组件到达末尾位置时触发。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func onReachStart(?() -> Unit)

```cangjie
public func onReachStart(event: ?() -> Unit): T
```

**功能：** 滚动组件到达起始位置时触发。滚动组件初始化时会触发一次，滚动到起始位置时触发一次。边缘效果为弹簧效果时，划动经过起始位置时触发一次，回弹回起始位置时再触发一次。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?() -> Unit|是|-|回调函数，滚动组件到达起始位置时触发。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func onScrollStart(?() -> Unit)

```cangjie
public func onScrollStart(event: ?() -> Unit): T
```

**功能：** 滚动开始时触发。手指拖动滚动组件或拖动滚动组件的滚动条触发的滚动开始时，会触发该事件。使用[Scroller](./cj-scroll-swipe-scroll.md#class-scroller)滚动控制器触发的带动画的滚动，动画开始时会触发该事件。

触发该事件的条件：<br>

1、滚动组件开始滚动时触发，支持键鼠操作等其他触发滚动的输入设置。<br>

2、通过滚动控制器API接口调用后开始，带过渡动效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?() -> Unit|是|-|回调函数，滚动开始时触发。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func onScrollStop(?() -> Unit)

```cangjie
public func onScrollStop(event: ?() -> Unit): T
```

**功能：** 滚动停止时触发。手拖动滚动组件或拖动滚动组件的滚动条触发的滚动，手离开屏幕并且滚动停止时会触发该事件。使用[Scroller](./cj-scroll-swipe-scroll.md#class-scroller)滚动控制器触发的带动画的滚动，动画停止时会触发该事件。

触发该事件的条件：<br>

1、滚动组件触发滚动后停止，支持键鼠操作等其他触发滚动的输入设置。<br>

2、通过滚动控制器API接口调用后开始，带过渡动效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?() -> Unit|是|-|回调函数，滚动停止时触发。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func onWillScroll(Option\<(Float64,ScrollState,ScrollSource) -> ScrollResult>)

```cangjie
public func onWillScroll(handler: Option<(Float64, ScrollState, ScrollSource) -> ScrollResult>): T
```

**功能：** 滚动事件回调，滚动组件滚动前触发。回调当前帧将要滚动的偏移量和当前滚动状态和滚动操作来源，其中回调的偏移量为计算得到的将要滚动的偏移量值，并非最终实际滚动偏移。可以通过该回调返回值指定滚动组件将要滚动的偏移。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|handler|Option\<(Float64, [ScrollState](./cj-common-types.md#enum-scrollstate), [ScrollSource](./cj-common-types.md#enum-scrollsource)) -> [ScrollResult](./cj-scroll-swipe-scroll.md#class-scrollresult)>|是|-|滚动组件滑动前触发的回调。<br> 参数一：每帧滑动的偏移量，滚动组件的内容向上滚动时偏移量为正，向下滚动时偏移量为负，单位vp。 <br> 参数二：当前滑动状态。 <br> 参数三：当前滑动操作的来源。<br> 返回值：将要滑动偏移量，单位vp。|

> **说明：**
>
> 调用scrollEdge和不带动画的scrollToIndex时，不触发onWillScroll。

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|

### func onWillScroll(Option\<(Float64,ScrollState,ScrollSource) -> Unit>)

```cangjie
public func onWillScroll(handler: Option<(Float64, ScrollState, ScrollSource) -> Unit>): T
```

**功能：** 滚动事件回调，滚动组件滚动前触发。回调当前帧将要滚动的偏移量和当前滚动状态和滚动操作来源，其中回调的偏移量为计算得到的将要滚动的偏移量值，并非最终实际滚动偏移。

> **说明：**
>
> 调用scrollEdge和不带动画的scrollToIndex时，不触发onWillScroll。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|handler|Option<(Float64, [ScrollState](./cj-common-types.md#enum-scrollstate), [ScrollSource](./cj-common-types.md#enum-scrollsource)) -> Unit>|是|-|滚动组件滑动前触发的回调。|

**返回值：**

|类型|说明|
|:----|:----|
|T|返回组件实例。|
