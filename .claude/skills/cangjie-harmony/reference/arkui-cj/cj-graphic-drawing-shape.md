# Shape

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

绘制组件的父组件，父组件中会描述所有绘制组件均支持的通用属性。

1、绘制组件使用Shape作为父组件，实现类似SVG的效果。

2、绘制组件单独使用，用于在页面上绘制指定的图形。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

包含 [Rect](./cj-graphic-drawing-rect.md)、[Circle](./cj-graphic-drawing-circle.md)、[Ellipse](./cj-graphic-drawing-ellipse.md)、[Image](./cj-image-video-image.md)、[Text](./cj-text-input-text.md)、[Column](./cj-row-column-stack-column.md)、[Row](./cj-row-column-stack-row.md)、Shape子组件。

## 创建组件

### init(() -> Unit)

```cangjie
public init(child!: () -> Unit = { => })
```

**功能：** Shape组件构造器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|child|() -> Unit|否|{ => }|**命名参数。** 声明Shape容器内支持的子组件。|

### init(?PixelMap)

```cangjie
public init(value!: ?PixelMap)
```

**功能：** Shape组件构造器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[PixelMap](../ImageKit/cj-apis-image.md#class-pixelmap)|是|-|**命名参数。** 绘制目标，可将图形绘制在指定的PixelMap对象中，若未设置，则在当前绘制目标中进行绘制。|

## 通用属性/通用事件

通用属性：除了支持通用属性外，还支持[图形绘制通用属性](./cj-graphic-drawing-common.md#组件属性)。

通用事件：全部支持。

## 组件属性

### func viewPort(?Length, ?Length, ?Length, ?Length)

```cangjie
public func viewPort(
    x!: ?Length = None,
    y!: ?Length = None,
    width!: ?Length = None,
    height!: ?Length = None
): This
```

**功能：** 设置Shape的视口。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 视口起始点x坐标。初始值：0.vp。|
|y|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 视口起始点y坐标。初始值：0.vp。|
|width|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 视口宽度。初始值：0.vp。|
|height|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 视口高度。初始值：0.vp。|

### func mesh(?Array\<Float64>, ?UInt32, ?UInt32)

```cangjie
public func mesh(value: ?Array<Float64>, column: ?UInt32, row: ?UInt32): This
```

**功能：** 设置网格变形数据，按给定列数与行数定义网格，并用坐标数组对内容进行网格扭曲/采样变换。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Array\<Float64>|是|-|长度（column + 1）\*（row + 1）\* 2的数组，它记录了扭曲后的位图各个顶点位置。网格控制点坐标序列（按 [x0, y0, x1, y1, …] 排列）。初始值：[]。|
|column|?UInt32|是|-|mesh矩阵列数。初始值：0。|
|row|?UInt32|是|-|mesh矩阵行数。初始值：0。|

## 示例代码

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_management.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Column(space: 10) {
            Text("basic")
                .fontSize(11)
                .fontColor(0xCCCCCC)
                .width(320)
            Shape() {
                Rect()
                    .width(300)
                    .height(50)
                Ellipse()
                    .width(300)
                    .height(50)
                    .offset(x: 0, y: 60)
                Path()
                    .width(300)
                    .height(10)
                    .commands("M0 0 L900 0")
                    .offset(x: 0, y: 120)
            }
            .width(350)
            .height(140)
            .viewPort(x: -2, y: -2, width: 304, height: 130)
            .fill(0x317AF7)
            .stroke(Color.Black)
            .strokeWidth(4)
            .strokeDashArray([20])
            .strokeDashOffset(10)
            .strokeLineCap(LineCapStyle.Round)
            .strokeLineJoin(LineJoinStyle.Round)
            .antiAlias(true)
            // 分别在Shape的(0, 0)、(-5, -5)点绘制一个 300 * 50 带边框的矩形,可以看出之所以将视口的起始位置坐标设为负值是因为绘制的起点默认为线宽的中点位置，因此要让边框完全显示则需要让视口偏移半个线宽
            Shape() {
                Rect()
                    .width(300)
                    .height(50)
            }
            .width(350)
            .height(80)
            .viewPort(x: 0, y: 0, width: 320, height: 70)
            .fill(0x317AF7)
            .stroke(Color.Black)
            .strokeWidth(10)

            Shape() {
                Rect()
                    .width(300)
                    .height(50)
            }
            .width(350)
            .height(80)
            .viewPort(x: -5, y: -5, width: 320, height: 70)
            .fill(0x317AF7)
            .stroke(Color.Black)
            .strokeWidth(10)

            Text("path")
                .fontSize(11)
                .fontColor(0xCCCCCC)
                .width(320)
            // 在Shape的(0, -5)点绘制一条直线路径,颜色0xEE8443,线条宽度10,线条间隙20
            Shape() {
                Path()
                    .width(300)
                    .height(10)
                    .commands("M0 0 L900 0")
            }
            .width(350)
            .height(20)
            .viewPort(x: 0, y: -5, width: 300, height: 20)
            .stroke(0xEE8443)
            .strokeWidth(10)
            .strokeDashArray([20])
            // 在Shape的(0, -5)点绘制一条直线路径,颜色0xEE8443,线条宽度10,线条间隙20,向左偏移10
            Shape() {
                Path()
                    .width(300)
                    .height(10)
                    .commands("M0 0 L900 0")
            }
            .width(350)
            .height(20)
            .viewPort(x: 0, y: -5, width: 300, height: 20)
            .stroke(0xEE8443)
            .strokeWidth(10)
            .strokeDashArray([20])
            .strokeDashOffset(10)
            // 在Shape的(0, -5)点绘制一条直线路径,颜色0xEE8443,线条宽度10,透明度0.5
            Shape() {
                Path()
                    .width(300)
                    .height(10)
                    .commands("M0 0 L900 0")
            }
            .width(350)
            .height(20)
            .viewPort(x: 0, y: -5, width: 300, height: 20)
            .stroke(0xEE8443)
            .strokeWidth(10)
            .strokeOpacity(0.5)
            // 在Shape的(0, -5)点绘制一条直线路径,颜色0xEE8443,线条宽度10,线条间隙20,线条两端样式为半圆
            Shape() {
                Path()
                    .width(300)
                    .height(10)
                    .commands("M0 0 L900 0")
            }
            .width(350)
            .height(20)
            .viewPort(x: 0, y: -5, width: 300, height: 20)
            .stroke(0xEE8443)
            .strokeWidth(10)
            .strokeDashArray([20])
            .strokeLineCap(LineCapStyle.Round)
            // 在Shape的(-20, -5)点绘制一个封闭路径,颜色0x317AF7,线条宽度10,边框颜色0xEE8443,拐角样式锐角（初始值）
            Shape() {
                Path()
                    .width(200)
                    .height(60)
                    .commands("M0 0 L400 0 L400 150 Z")
            }
            .width(300)
            .height(200)
            .viewPort(x: -20, y: -5, width: 310, height: 90)
            .fill(0x317AF7)
            .stroke(0xEE8443)
            .strokeWidth(10)
            .strokeLineJoin(LineJoinStyle.Miter)
            .strokeMiterLimit(5.0)
        }.width(100.percent).margin(top: 15)
    }
}
```

![shape2](./figures/shape2.png)
