# 颜色渐变

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

设置组件的颜色渐变效果。

> **说明：**
>
> - 颜色渐变属于组件内容，绘制在背景上方。
> - 颜色渐变不支持宽高显式动画，执行宽高动画时颜色渐变会直接过渡到终点。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func linearGradient(?Float64, ?GradientDirection, ?Array\<(ResourceColor, Float64)>, ?Bool)

```cangjie
func linearGradient(angle!: ?Float64, direction!: ?GradientDirection,
    colors!: ?Array<(ResourceColor, Float64)>, repeating!: ?Bool): T
```

**功能：** 设置线性渐变。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
| angle | ?Float64 | 是 | - | **命名参数。** 线性渐变的起始角度。0点方向顺时针旋转为正向角度。|
| direction | ?[GradientDirection](./cj-common-types.md#enum-gradientdirection) | 是 | - | **命名参数。** 线性渐变的方向，设置angle后不生效。<br>初始值：GradientDirection.Bottom。|
| colors | ?Array\<([ResourceColor](./cj-common-types.md#interface-resourcecolor), Float64)> | 是 | - | **命名参数。** 指定渐变色颜色和其对应的百分比位置的数组，设置非法颜色直接跳过。<br>初始值：[(Color.Transparent, 0.0)]。|
| repeating | ?Bool | 是 | - | **命名参数。** 为渐变的颜色重复着色。 <br>初始值：false。|

## func sweepGradient(?(Length, Length), ?Float64, ?Float64, ?Float64, ?Array\<(ResourceColor, Float64)>, ?Bool)

```cangjie
func sweepGradient(center: ?(Length, Length), start!: ?Float64, end!: ?Float64 ,
    rotation!: ?Float64, colors!: ?Array<(ResourceColor, Float64)>,
    repeating!: ?Bool): T
```

**功能：** 设置角度渐变。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
| center | ?([Length](./cj-common-types.md#interface-length), [Length](./cj-common-types.md#interface-length)) | 是 | - | 中心点坐标，相对于当前组件左上角的坐标。 <br>初始值：(0.0.vp, 0.0.vp)。|
| start | ?Float64 | 是 | - | **命名参数。** 角度渐变的起点。 <br>初始值：0.0。|
| end | ?Float64 | 是 | - | **命名参数。** 角度渐变的终点。 <br>初始值：0.0。|
| rotation | ?Float64 | 是 | - | **命名参数。** 角度渐变的旋转角度。 <br>初始值：0.0。|
| colors | ?Array\<([ResourceColor](./cj-common-types.md#interface-resourcecolor), Float64)> | 是 | - | **命名参数。** 指定渐变色颜色和其对应的百分比位置的数组，设置非法颜色直接跳过。 <br>初始值：[(Color.Transparent, 0.0)]。|
| repeating | ?Bool | 是 | - | **命名参数。** 为渐变的颜色重复着色。 <br>初始值：false。|

## func radialGradient(?(Length, Length), ?Length, ?Array\<(ResourceColor, Float64)>, ?Bool)

```cangjie
func radialGradient(center: ?(Length, Length), radius: ?Length, colors: ?Array<(ResourceColor, Float64)>,
    repeating!: ?Bool): T
```

**功能：** 设置径向渐变。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
| center | ?([Length](./cj-common-types.md#interface-length), [Length](./cj-common-types.md#interface-length)) | 是 | - | 中心点坐标，相对于当前组件左上角的坐标。 <br>初始值：(0.0.px, 0.0.px)。|
| radius | ?[Length](./cj-common-types.md#interface-length) | 是 | - | 径向渐变的半径。 |
| colors | ?Array\<([ResourceColor](./cj-common-types.md#interface-resourcecolor), Float64)> | 是 | - | 指定渐变色颜色和其对应的百分比位置的数组，设置非法颜色直接跳过。 <br>初始值：[]。|
| repeating | ?Bool | 是 | - | **命名参数。** 为渐变的颜色重复着色。 <br>初始值：false。|

## 示例代码

### 示例1（颜色从右向左线性渐变）

该示例通过linearGradient来实现组件颜色线性渐变。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Column() {
            Text("linearGradient")
                .fontSize(24.px)
                .width(90.percent)
                .fontColor(Color(0xCCCCCC))
            Row()
                .width(100.percent)
                .height(100.px)
                .linearGradient(
                    angle: 90.0,
                    colors: [(Color(0x0000ff), 0.0), (Color(0xff0000), 0.3), (Color(0xffff00), 1.0)],
                    repeating: false
                )

            Text("linearGradient Repeat")
                .fontSize(24.px)
                .width(90.percent)
                .fontColor(Color(0xCCCCCC))
            Row()
                .width(100.percent)
                .height(100.px)
                .linearGradient(
                    colors: [(Color(0x0000ff), 0.0), (Color(0xff0000), 0.3), (Color(0xffff00), 0.5)],
                    direction: GradientDirection.Left,
                    repeating: true
                )
        }
    }
}
```

![gradientColor1](figures/gradientColor1.png)

### 示例2（颜色按旋转角度渐变）

该示例通过sweepGradient来实现组件颜色旋转角度渐变。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Column() {
            Text("sweepGradient")
                .fontSize(24.px)
                .width(30.percent)
                .fontColor(Color(0xCCCCCC))
            Row()
                .width(200.px)
                .height(200.px)
                .sweepGradient(
                    (100.0.px, 100.0.px),
                    start: 0.0,
                    end: 359.0,
                    colors: [(Color(0xff0000), 0.0), (Color(0x0000ff), 0.3), (Color(0xffff00), 1.0)],
                    repeating: false
                )

            Text("sweepGradient Reapeat")
                .fontSize(24.px)
                .width(30.percent)
                .fontColor(Color(0xCCCCCC))
            Row()
                .width(200.px)
                .height(200.px)
                .sweepGradient(
                    (100.0.px, 100.0.px),
                    start: 0.0,
                    end: 359.0,
                    rotation: 45.0,
                    colors: [(Color(0xff0000), 0.0), (Color(0x0000ff), 0.3), (Color(0xffff00), 0.5)],
                    repeating: true
                )
        }
    }
}
```

![gradientColor2](figures/gradientColor2.png)

### 示例3（颜色按径向渐变）

该示例通过radialGradient来实现组件颜色径向渐变。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Column() {
            Text("radialGradient")
                .fontSize(24.px)
                .width(30.percent)
                .fontColor(Color(0xCCCCCC))
            Row()
                .width(200.px)
                .height(200.px)
                .radialGradient(
                    (100.0.px, 100.0.px),
                    120.0,
                    [(Color(0xff0000), 0.0), (Color(0x0000ff), 0.3), (Color(0xffff00), 1.0)]
                )

            Text("radialGradient Repeat")
                .fontSize(24.px)
                .width(30.percent)
                .fontColor(Color(0xCCCCCC))
            Row()
                .width(200.px)
                .height(200.px)
                .radialGradient(
                    (100.0.px, 100.0.px),
                    120.0,
                    [(Color(0xff0000), 0.0), (Color(0x0000ff), 0.3), (Color(0xffff00), 0.5)],
                    repeating: true
                )
        }
    }
}
```

![gradientColor3](figures/gradientColor3.png)
