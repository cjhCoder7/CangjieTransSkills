# ohos.curves（插值计算）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

提供插值器函数，如初始化、三阶贝塞尔曲线和弹簧曲线。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## class Curves

```cangjie
public class Curves {}
```

**功能：** 包含插值器函数，如初始化、三阶贝塞尔曲线和弹簧曲线。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### static func cubicBezierCurve(Float32, Float32, Float32, Float32)

```cangjie
public static func cubicBezierCurve(x1: Float32, y1: Float32, x2: Float32, y2: Float32): ICurve
```

**功能：** 构造三阶贝塞尔曲线对象，确保曲线的值在0到1之间。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x1|Float32|是|-|确定贝塞尔曲线第一点横坐标。<br>取值范围：[0，1]<br>**说明：**<br>设置的值小于0时，按0处理；设置的值大于1时，按1处理。|
|y1|Float32|是|-|确定贝塞尔曲线第一点纵坐标。<br>取值范围：(-∞, +∞)。|
|x2|Float32|是|-|确定贝塞尔曲线第二点横坐标。<br>取值范围：[0，1]。<br>**说明：**<br>设置的值小于0时，按0处理；设置的值大于1时，按1处理。|
|y2|Float32|是|-|确定贝塞尔曲线第二点纵坐标。<br>取值范围：(-∞, +∞)。|

**返回值：**

|类型|说明|
|:----|:----|
|[ICurve](#class-icurve)|返回曲线的插值对象。|

### static func customCurve((Float32) -> Float32)

```cangjie
public static func customCurve(interpolate: (Float32) -> Float32): ICurve
```

**功能：** 创建一个自定义曲线。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|interpolate|(Float32) -> Float32|是|-|用户自定义的插值回调函数。<br>动画开始时的插值输入x值。<br>取值范围：[0,1]。<br>返回值为曲线的y值。<br>取值范围：[0,1]。<br>**说明：**<br>fraction等于0时，返回值为0对应动画起点，返回不为0，动画在起点处有跳变效果。fraction等于1时，返回值为1对应动画终点，返回值不为1将导致动画的终值不是状态变量的值，出现大于或者小于状态变量值，再跳变到状态变量值的效果。|

**返回值：**

|类型|说明|
|:----|:----|
|[ICurve](#class-icurve)|返回曲线的插值对象。|

### static func initCurve(Curve)

```cangjie
public static func initCurve(curve!: Curve = Curve.Linear): ICurve
```

**功能：** 插值曲线的初始化函数，可以根据入参创建一个插值曲线对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|curve|[Curve](./cj-common-types.md#enum-curve)|否|Curve.Linear| **命名参数。** 曲线类型。|

**返回值：**

|类型|说明|
|:----|:----|
|[ICurve](#class-icurve)|返回曲线的插值对象。|

### static func interpolatingSpring(Float32, Float32, Float32, Float32)

```cangjie
public static func interpolatingSpring(velocity: Float32, mass: Float32, stiffness: Float32, damping: Float32): ICurve
```

**功能：** 构造插值器弹簧曲线对象，生成一条从0到1的动画曲线，实际动画值根据曲线进行插值计算。动画时间由曲线参数决定，不受animation、animateTo中的duration参数控制。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|velocity|Float32|是|-|初始速度。外部因素对弹性动效产生的影响参数，目的是保证对象从之前的运动状态平滑地过渡到弹性动效。该速度是归一化速度，其值等于动画开始时的实际速度除以动画属性改变值。<br>取值范围：(-∞, +∞)。|
|mass|Float32 |是|-|质量。弹性系统的受力对象，会对弹性系统产生惯性影响。质量越大，震荡的幅度越大，恢复到平衡位置的速度越慢。<br>取值范围：(0, +∞)。<br>**说明：**<br>设置的值小于等于0时，按1处理。|
|stiffness|Float32|是|-|刚度。表示物体抵抗施加的力而形变的程度。刚度越大，抵抗变形的能力越强，恢复到平衡位置的速度越快。<br>**说明：**<br>设置的值小于等于0时，按1处理。|
|damping|Float32|是|-|阻尼。用于描述系统在受到扰动后震荡及衰减的情形。阻尼越大，弹性运动的震荡次数越少、震荡幅度越小。<br>取值范围：(0, +∞) <br>**说明：**:<br>设置的值小于等于0时，按1处理。|

**返回值：**

|类型|说明|
|:----|:----|
|[ICurve](#class-icurve)|曲线的插值对象。<br>**说明：** 弹性动画曲线为物理曲线，[animation](./cj-animation-animation.md)、[animateTo](./cj-apis-uicontext-uicontext.md#func-animatetoanimateparam-voidcallback)、[pageTransition](./cj-animation-pagetransition.md)中的duration参数不生效，动画持续时间取决于interpolatingSpring动画曲线参数。时间不能归一，故不能通过该曲线的[interpolate](#func-interpolatefloat32)函数获得插值。|

### static func responsiveSpringMotion(Float32, Float32, Float32)

```cangjie
public static func responsiveSpringMotion(response!: Float32 = 0.15, dampingFraction!: Float32 = 0.86,
    overlapDuration!: Float32 = 0.25): ICurve
```

**功能：** 创建一个响应式弹簧动画曲线。它是[springMotion](#static-func-springmotionfloat32-float32-float32)的一个特例，仅默认参数不同，可以与springMotion一起使用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|response|Float32|否|0.15| **命名参数。** 解释同springMotion中的response。<br>单位:秒。<br>取值范围：(0, +∞)。<br>**说明：**<br>设置小于等于0的值时，按默认值0.15处理。|
|dampingFraction|Float32|否|0.86| **命名参数。** 解释同springMotion中的dampingFraction。<br>单位:秒。<br>取值范围：(0, +∞)。<br>**说明：**<br>设置小于等于0的值时，按默认值0.86处理。|
|overlapDuration|Float32|否|0.25| **命名参数。** 解释同springMotion中的overlapDuration。<br>单位: 秒。<br>取值范围：(0, +∞)。<br>**说明：**<br>弹性跟手动画曲线为springMotion的一种特例，仅默认值不同。如果使用自定义参数的弹性曲线，推荐使用springMotion构造曲线。如果使用跟手动画，推荐使用默认参数的弹性跟手动画曲线。<br>[animation](./cj-animation-animation.md)、[animateTo](./cj-apis-uicontext-uicontext.md#func-animatetoanimateparam-voidcallback)、[pageTransition](./cj-animation-pagetransition.md)中的duration参数不生效，responsiveSpringMotion动画曲线参数和之前的速度，也不能通过该曲线的[interpolate](#func-interpolatefloat32)函数获得插值。|

**返回值：**

|类型|说明|
|:----|:----|
|[ICurve](#class-icurve)|曲线对象。<br>**说明：**<br>1. 弹性跟手动画曲线为springMotion的一种特例，仅默认值不同。如果使用自定义参数的弹性曲线，推荐使用springMotion构造曲线；如果使用跟手动画，推荐使用默认参数的弹性跟手动画曲线。<br>2. [animation](./cj-animation-animation.md)、[animateTo](./cj-apis-uicontext-uicontext.md#func-animatetoanimateparam-voidcallback)、[pageTransition](./cj-animation-pagetransition.md)中的duration参数不生效，动画持续时间取决于responsiveSpringMotion动画曲线参数和之前的速度，也不能通过该曲线的[interpolate](#func-interpolatefloat32)函数获得插值。|

### static func springCurve(Float32, Float32, Float32, Float32)

```cangjie
public static func springCurve(velocity: Float32, mass: Float32, stiffness: Float32, damping: Float32): ICurve
```

**功能：** 创建弹簧曲线对象，曲线形状由弹簧参数决定，动画时长受animation、animateTo中的duration参数控制。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|velocity|Float32|是|-|初始速度。是由外部因素对弹性动效产生的影响参数，其目的是保证对象从之前的运动状态平滑的过渡到弹性动效。该速度是归一化速度，其值等于动画开始时的实际速度除以动画属性改变值。<br>取值范围：(-∞, +∞)|
|mass|Float32|是|-|质量。弹性系统的受力对象，会对弹性系统产生惯性影响。质量越大，震荡的幅度越大，恢复到平衡位置的速度越慢。<br>取值范围：(0, +∞)。<br>**说明：**<br>设置的值小于等于0时，按1处理。|
|stiffness|Float32|是|-|刚度。是物体抵抗施加的力而形变的程度。在弹性系统中，刚度越大，抵抗变形的能力越强，恢复到平衡位置的速度就越快。<br>取值范围：(0, +∞)。<br>**说明：**<br>设置的值小于等于0时，按1处理。|
|damping|Float32|是|-|阻尼。用于描述系统在受到扰动后震荡及衰减的情形。阻尼越大，弹性运动的震荡次数越少、震荡幅度越小。<br>取值范围：(0, +∞)。<br>**说明：**<br>设置的值小于等于0时，按1处理。|

**返回值：**

|类型|说明|
|:----|:----|
|[ICurve](#class-icurve)|返回曲线的插值对象。|

### static func springMotion(Float32, Float32, Float32)

```cangjie
public static func springMotion(response!: Float32 = 0.55, dampingFraction!: Float32 = 0.825,
    overlapDuration!: Float32 = 0.0): ICurve
```

**功能：** 创建一个弹性动画曲线对象。如果对同一对象的同一属性进行多个弹性动画，每个动画会替换掉前一个动画，并继承之前的速度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|response|Float32|否|0.55| **命名参数。** 弹簧自然振动周期，决定弹簧复位的速度。<br>单位:秒。<br>取值范围：(0, +∞)。<br>**说明：**<br>设置小于等于0的值时，按默认值0.55处理。|
|dampingFraction|Float32|否|0.825| **命名参数。** 阻尼系数。<br>0表示无阻尼，一直处于震荡状态；<br>大于0小于1的值为欠阻尼，运动过程中会超出目标值；<br>等于1为临界阻尼；<br>大于1为过阻尼，运动过程中逐渐趋于目标值。<br>单位:秒。<br>取值范围：(0, +∞)<br>**说明：**<br>设置小于等于0的值时，按默认值0.825处理。|
|overlapDuration|Float32|否|0.0| **命名参数。** 弹性动画衔接时长。发生动画继承时，如果前后两个弹性动画response不一致，response参数会在overlapDuration时间内平滑过渡。<br>单位: 秒。<br>取值范围：(0, +∞)。<br>**说明：**<br>设置小于0的值时，按默认值0处理。<br>弹性动画曲线为物理曲线，[animation](./cj-animation-animation.md)、[animateTo](./cj-apis-uicontext-uicontext.md#func-animatetoanimateparam-voidcallback)、[pageTransition](./cj-animation-pagetransition.md)中的duration参数不生效，动画持续时间取决于springMotion动画曲线参数和之前的速度。时间不能归一，故不能通过该曲线的[interpolate](#func-interpolatefloat32)函数获得插值。|

**返回值：**

|类型|说明|
|:----|:----|
|[ICurve](#class-icurve)|曲线对象。<br>**说明：** 弹性动画曲线为物理曲线，[animation](./cj-animation-animation.md)、[animateTo](./cj-apis-uicontext-uicontext.md#func-animatetoanimateparam-voidcallback)、[pageTransition](./cj-animation-pagetransition.md)中的duration参数不生效，动画持续时间取决于springMotion动画曲线参数和之前的速度。时间不能归一，故不能通过该曲线的[interpolate](#func-interpolatefloat32)函数获得插值。|

### static func stepsCurve(Int32, Bool)

```cangjie
public static func stepsCurve(count: Int32, end: Bool): ICurve
```

**功能：** 创建阶梯曲线对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|count|Int32|是|-|阶梯的数量，需要为正整数。<br>取值范围：[1, +∞)。<br>**说明：**<br>设置小于1的值时，按值为1处理。|
|end|Bool|是|-|在每个间隔的起点或是终点发生阶跃变化。<br>-true: 在终点发生阶跃变化。<br>-false：在起点发生阶跃变化。|

**返回值：**

|类型|说明|
|:----|:----|
|[ICurve](#class-icurve)|返回曲线的插值对象。|

## class ICurve

```cangjie
public class ICurve {}
```

**功能：** 曲线对象，支持通过本模块中的[cubicBezierCurve](#static-func-cubicbeziercurvefloat32-float32-float32-float32)、[interpolatingSpring](#static-func-interpolatingspringfloat32-float32-float32-float32)等方法创建不同类型的曲线对象，并可通过曲线对象调用其[interpolate](#func-interpolatefloat32)的成员方法。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func interpolate(Float32)

```cangjie
public func interpolate(fraction: Float32): Float32
```

**功能：** 插值曲线的插值计算函数，可以通过传入的归一化时间参数返回当前的插值

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|fraction|Float32|是|-|当前的归一化时间参数。<br>取值范围：[0，1]。<br>**说明：**<br>设置的值小于0时，按0处理；设置的值大于1时，按1处理。|

**返回值：**

|类型|说明|
|:----|:----|
|Float32|返回归一化time时间点对应的曲线插值。|

## 示例代码

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

let animateOpt1 = AnimateParam(
    duration: 1200,
    curve: Curve.EaseOut
)

@Entry
@Component
class EntryView {
    @State var widthSize: Float64 = 200.0
    @State var heightSize: Float64 = 200.0
    func build() {
        Column {
            Column()
                .margin(top: 100)
                .width(this.widthSize)
                .height(this.heightSize)
                .backgroundColor(Color.Red)
                .onClick(
                    {
                        evt =>
                        let curve = Curves.cubicBezierCurve(0.25, 0.1, 0.25, 1.0)
                        this.widthSize = Float64(curve.interpolate(0.5)) * this.widthSize
                        this.heightSize = Float64(curve.interpolate(0.5)) * this.heightSize
                    }
                )
                .animation(animateOpt1)
        }
    }
}
```

![curves](figures/curves_api.gif)