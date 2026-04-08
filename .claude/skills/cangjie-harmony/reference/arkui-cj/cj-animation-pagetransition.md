# 页面间转场（pageTransition）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

当路由（[Router](./cj-apis-uicontext-router.md)）进行切换时，可以通过在[pageTransition](./cj-custom-component-lifecycle.md#func-pagetransition)函数中自定义页面入场和页面退场的转场动效。详细指导请参考[页面转场动画](../../arkui-cj/cj-page-transition-animation.md)。

> **说明：**
>
> 为了实现更好的转场效果，推荐使用Navigation组件和[模态转场](../../arkui-cj/cj-modal-transition.md)。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## class CommonTransition

```cangjie
abstract sealed class CommonTransition {}
```

**功能：** 页面转场通用动效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func slide(SlideEffect)

```cangjie
public func slide(value: SlideEffect): This
```

**功能：** 设置页面转场时的滑入滑出效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|[SlideEffect](#enum-slideeffect)|是|-|页面转场时的滑入滑出效果。|

### func translate(?Length, ?Length, ?Length)

```cangjie
public func translate(x!: ?Length = None, y!: ?Length = None, z!: ?Length = None): This
```

**功能：** 设置页面转场时的平移效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** x轴的平移距离。<br>取值范围为(-∞, +∞)。<br>初始值：0.0.vp。|
|y|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** y轴的平移距离。<br>取值范围为(-∞, +∞)。<br>初始值：0.0.vp。|
|z|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** z轴的平移距离。<br>取值范围为(-∞, +∞)。<br>初始值：0.0.vp。|

### func scale(?Float32, ?Float32, ?Float32, ?Length, ?Length)

```cangjie
public func scale(
    x!: ?Float32 = None,
    y!: ?Float32 = None,
    z!: ?Float32 = None,
    centerX!: ?Length = None,
    centerY!: ?Length = None
): This
```

**功能：** 设置页面转场时的缩放效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|?Float32|否|None|**命名参数。** x轴的缩放倍数。x>1时以x轴方向放大，0<x<1时以x轴方向缩小，x<0时沿x轴反向并缩放。<br>初始值：1.0。|
|y|?Float32|否|None|**命名参数。** y轴的缩放倍数。y>1时以y轴方向放大，0<y<1时以y轴方向缩小，y<0时沿y轴反向并缩放。<br>初始值：1.0。|
|z|?Float32|否|None|**命名参数。** z轴的缩放倍数。z>1时以z轴方向放大，0<z<1时以z轴方向缩小，z<0时沿z轴反向并缩放。<br>初始值：1.0。|
|centerX|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 变换中心点x轴坐标。<br>初始值：50.percent。|
|centerY|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 变换中心点y轴坐标。<br>初始值：50.percent。|

### func opacity(Float64)

```cangjie
public func opacity(value: Float64): This
```

**功能：** 设置入场的起点透明度值或者退场的终点透明度值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|Float64|是|-|设置入场的起点透明度值或者退场的终点透明度值。取值范围[0.0, 1.0]，0.0表示完全透明，1.0表示完全不透明。|

## class PageTransitionEnter

```cangjie
public class PageTransitionEnter <: CommonTransition {
    public init(
        routeType!: ?RouteType = Option.None,
        duration!: ?Int32 = None,
        curve!: ?Curve = None,
        delay!: ?Int32 = None
    )
}
```

**功能：** 当前页面的自定义入场动效类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [CommonTransition](#class-commontransition)

### init(?RouteType, ?Int32, ?Curve, ?Int32)

```cangjie
public init(
    routeType!: ?RouteType = Option.None,
    duration!: ?Int32 = None,
    curve!: ?Curve = None,
    delay!: ?Int32 = None
)
```

**功能：** 创建当前页面的自定义入场动效对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|routeType|?[RouteType](#enum-routetype) |否|Option.None|**命名参数。** 页面转场效果生效的路由类型。<br>初始值：RouteType.None。|
|duration|?Int32|否|None|**命名参数。** 动画的时长。<br>单位：毫秒。<br>取值范围：[0, +∞)。<br>初始值：1000。|
|curve|?[Curve](./cj-common-types.md#enum-curve)|否|None|**命名参数。** 动画曲线。<br>Curve.Linear|
|delay|?Int32|否|None|**命名参数。** 动画延迟时长。<br>单位：毫秒。<br>初始值：1000。|

### func onEnter(?PageTransitionCallback)

```cangjie
public func onEnter(event: ?PageTransitionCallback)
```

**功能：** 逐帧回调，直到入场动画结束，转场进度从0变化到1。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?[PageTransitionCallback](#type-pagetransitioncallback)|是|-|入场动画的逐帧回调直到入场动画结束，转场进度从0变化到1。|

## class PageTransitionExit

```cangjie
public class PageTransitionExit <: CommonTransition {
    public init(
        routeType!: ?RouteType = Option.None,
        duration!: ?Int32 = None,
        curve!: ?Curve = None,
        delay!: ?Int32 = None
    )
}
```

**功能：** 当前页面的自定义退场动效类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [CommonTransition](#class-commontransition)

### init(?RouteType, ?Int32, ?Curve, ?Int32)

```cangjie
public init(
    routeType!: ?RouteType = Option.None,
    duration!: ?Int32 = None,
    curve!: ?Curve = None,
    delay!: ?Int32 = None
)
```

**功能：** 创建当前页面的自定义退场动效对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|routeType|?[RouteType](#enum-routetype) |否|Option.None|**命名参数。** 页面转场效果生效的路由类型。<br>初始值：RouteType.None。|
|duration|?Int32|否|None|**命名参数。** 动画的时长。<br>单位：毫秒。<br>取值范围：[0, +∞)。<br>初始值：1000。|
|curve|?[Curve](./cj-common-types.md#enum-curve)|否|None|**命名参数。** 动画曲线。<br>Curve.Linear|
|delay|?Int32|否|None|**命名参数。** 动画延迟时长。<br>单位：毫秒。<br>初始值：1000。|

### func onExit(?PageTransitionCallback)

```cangjie
public func onExit(event: ?PageTransitionCallback)
```

**功能：** 逐帧回调，直到出场动画结束，转场进度从0变化到1。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?[PageTransitionCallback](#type-pagetransitioncallback)|是|-|出场动画的逐帧回调直到出场动画结束，转场进度从0变化到1。|

## enum RouteType

```cangjie
public enum RouteType <: Equatable<RouteType> {
    | None
    | Push
    | Pop
    | ...
}
```

**功能：** 页面转场类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[RouteType](#enum-routetype)>

### None

```cangjie
None
```

**功能：** 页面未重定向。如Push和Pop描述中RouteType为None的情形，即页面进场时PageTransitionEnter的转场效果生效；退场时PageTransitionExit的转场效果生效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Push

```cangjie
Push
```

**功能：** 跳转到下一页面。PageA跳转到下一个新的界面PageB。对于PageA，指定RouteType为None或者Push的PageTransitionExit组件样式生效，对于PageB，指定RouteType为None或者Push的PageTransitionEnter组件样式生效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Pop

```cangjie
Pop
```

**功能：** 重定向指定页面。从PageB回退到之前的页面PageA。对于PageB，指定RouteType为None或者Pop的PageTransitionExit组件样式生效，对于PageA，指定RouteType为None或者Pop的PageTransitionEnter组件样式生效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func !=(RouteType)

```cangjie
public operator func !=(other: RouteType): Bool
```

**功能：** 比较两个枚举值是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[RouteType](#enum-routetype)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值不相等则返回true，否则返回false。|

### operator func ==(RouteType)

```cangjie
public operator func ==(other: RouteType): Bool
```

**功能：** 比较两个枚举值是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[RouteType](#enum-routetype)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值相等则返回true，否则返回false。|

## enum SlideEffect

```cangjie
public enum SlideEffect <: Equatable<SlideEffect> {
    | Left
    | Right
    | Top
    | Bottom
    | ...
}
```

**功能：** 页面转场时的滑入滑出效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SlideEffect](#enum-slideeffect)>

### Left

```cangjie
Left
```

**功能：** 入场时表示从左边滑入，出场时表示滑出到左边。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Right

```cangjie
Right
```

**功能：** 入场时表示从右边滑入，出场时表示滑出到右边。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Top

```cangjie
Top
```

**功能：** 入场时表示从上边滑入，出场时表示滑出到上边。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Bottom

```cangjie
Bottom
```

**功能：** 入场时表示从下边滑入，出场时表示滑出到下边。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func !=(SlideEffect)

```cangjie
public operator func !=(other: SlideEffect): Bool
```

**功能：** 比较两个枚举值是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SlideEffect](#enum-slideeffect)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值不相等则返回true，否则返回false。|

### operator func ==(SlideEffect)

```cangjie
public operator func ==(other: SlideEffect): Bool
```

**功能：** 比较两个枚举值是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SlideEffect](#enum-slideeffect)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值相等则返回true，否则返回false。|

## type PageTransitionCallback

```cangjie
public type PageTransitionCallback = (RouteType, Float64) -> Unit
```

**功能：** 页面转场事件回调。

**类型：** ([RouteType](#enum-routetype) , Float64) -> Unit

|类型参数|说明|
|:---|:---|
|[RouteType](#enum-routetype)|页面转场类型。|
|Float64|转场进度，从0变化到1。|

## 示例代码

### 示例代码1(设置退入场动画)

通过不同的退入场类型配置不同的退场，入场动画。

<!-- run -->

```cangjie
//index.cj
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.resource.*

@Entry
@Component
class EntryView {
    @State var scale2: Float32 = 1.0
    @State var opacity2: Float64 = 1.0

    func build() {
        Column() {
            Image(@r(app.media.background))
                .width(100.percent)
                .height(100.percent)
        }
        .width(100.percent)
        .height(100.percent)
        .scale(x: scale2, y: 1.0)
        .opacity(this.opacity2)
        .onClick({
                e => getUIContext().getRouter().pushUrl(url: "Page1")
            })
    }

    protected func pageTransition(): Unit {
        PageTransitionEnter(duration: 1200, curve: Curve.Linear,).onEnter({
            ty: RouteType, progress: Float64 => 
                if (ty == RouteType.Push || ty ==  RouteType.Pop) {
                    scale2 = Float32(progress)
                    opacity2 = progress
                }
        })
        PageTransitionExit(duration: 1200, curve: Curve.Ease, ).onExit({
            ty: RouteType, progress: Float64 =>
                if (ty == RouteType.Push) {
                    this.scale2 = Float32(1.0 - progress)
                    this.opacity2 = 1.0 - progress
                }
        })
    }
}
```

<!-- run -->

```cangjie
//page1.cj
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.resource.*

@Entry
@Component
class Page1 {
    @State var scale1: Float32 = 1.0
    @State var opacity1: Float64 = 1.0

    func build() {
        Column() {
            Image(@r(app.media.background))
                .width(50.percent)
                .height(50.percent)
        }
        .width(100.percent)
        .height(100.percent)
        .scale(x: scale1, y: 1.0)
        .opacity(opacity1)
        .onClick({
                e => getUIContext().getRouter().pushUrl(url: "EntryView")
            })
    }

    protected func pageTransition(): Unit {
        PageTransitionEnter(duration: 1200, curve: Curve.Linear).onEnter({
            ty: RouteType, progress: Float64 => 
                if (ty == RouteType.Push || ty ==  RouteType.Pop) {
                    scale1 = Float32(progress)
                    opacity1 = progress
                }
        })
        PageTransitionExit(duration: 1200, curve: Curve.Ease).onExit({
            ty: RouteType, progress: Float64 => 
                if (ty == RouteType.Push) {
                    this.scale1 = Float32(1.0 - progress)
                    this.opacity1 = 1.0 - progress
                }
        })
    }
}
```

![page_transition](figures/pagetransition.gif)

### 示例代码2（设置退入场平移效果）

配置提供的不同退入场平移效果，将系统语言排版模式改为RTL。

<!-- run -->

```cangjie
//index.cj
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var scale2: Float32 = 1.0
    @State var opacity2: Float64 = 1.0

    func build() {
        Column() {
            Button("Page1").onClick({
                e => getUIContext().getRouter().pushUrl(url: "Page1")
            })
                .width(200)
                .height(60)
                .fontSize(36)
            Text("START")
                .fontSize(36)
                .textAlign(TextAlign.Center)
        }
        .width(100.percent)
        .height(100.percent)
        .scale(x: scale2, y: 1.0)
        .opacity(this.opacity2)
        .justifyContent(FlexAlign.Center)
    }

    protected func pageTransition(): Unit {
        PageTransitionEnter(duration: 1200, curve: Curve.Linear).slide(SlideEffect.Left)
        PageTransitionExit(duration: 1200, curve: Curve.Ease).slide(SlideEffect.Left)
    }
}
```

<!-- run -->

```cangjie

//page1.cj
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class Page1 {
    @State var scale1: Float32 = 1.0
    @State var opacity1: Float64 = 1.0

    func build() {
        Column() {
            Button("Page2").onClick({
                e => getUIContext().getRouter().pushUrl(url: "EntryView")
            })
                .width(200)
                .height(60)
                .fontSize(36)
            Text("END")
                .fontSize(36)
                .textAlign(TextAlign.Center)
        }
        .width(100.percent)
        .height(100.percent)
        .scale(x: scale1, y: 1.0)
        .opacity(this.opacity1)
        .justifyContent(FlexAlign.Center)
    }

    protected func pageTransition(): Unit {
        PageTransitionEnter(duration: 1200).slide(SlideEffect.Right)
        PageTransitionExit(duration: 1200).slide(SlideEffect.Right)
    }
}
```

![page_transition2](figures/pagetransition2.gif)