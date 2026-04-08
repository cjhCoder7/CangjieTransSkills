# 图形绘制通用属性

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

图形绘制通用属性目前支持[Circle](./cj-graphic-drawing-circle.md)、[Ellipse](./cj-graphic-drawing-ellipse.md)、[Line](./cj-graphic-drawing-line.md)、[Path](./cj-graphic-drawing-path.md)、[Rect](./cj-graphic-drawing-rect.md)、[Shape](./cj-graphic-drawing-shape.md)等组件。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 组件属性

### func fill(?ResourceColor)

```cangjie
public func fill(value: ?ResourceColor): T
```

**功能：** 设置填充区域的颜色，异常值按照初始值处理。与通用属性[foregroundColor](./cj-universal-attribute-foregroundcolor.md#func-foregroundcolorcoloringstrategy)同时设置时，后设置的属性生效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|填充颜色。初始值：Color.Black。|

### func fillOpacity(?Float64)

```cangjie
public func fillOpacity(value: ?Float64): T
```

**功能：** 设置填充区域透明度。取值范围是[0.0,1.0]，若给定值小于0.0，则取值为0.0；若给定值大于1.0，则取值为1.0，其余异常值按1.0处理。取值为1.0代表不透明，取值为0.0代表完全透明。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Float64|是|-|填充透明度。初始值：1.0。|

### func fillOpacity(?AppResource)

```cangjie
public func fillOpacity(value: ?AppResource): T
```

**功能：** 设置填充区域透明度。取值范围是[0, 1]，若给定值小于0，则取值为0；若给定值大于1，则取值为1，其余异常值按1处理。取值为1代表不透明，取值为0代表完全透明。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[AppResource](../LocalizationKit/cj-apis-resource.md#class-appresource)|是|-|填充透明度。初始值：1.0。|

### func stroke(?ResourceColor)

```cangjie
public func stroke(value: ?ResourceColor): T
```

**功能：** 设置边框颜色。默认没有边框。异常值不会绘制边框。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|边框颜色。初始值：Color.Transparent。|

### func strokeDashArray(?Array\<Length>)

```cangjie
public func strokeDashArray(value: ?Array<Length>): T
```

**功能：** 设置边框间隙。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Array\<[Length](./cj-common-types.md#interface-length)>|是|-|边框虚线数组。初始值：[]。|

### func strokeDashOffset(?Length)

```cangjie
public func strokeDashOffset(value: ?Length): T
```

**功能：** 设置边框绘制起点的偏移量。异常值按照初始值处理。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|边框虚线偏移量。初始值：0.vp。|

### func strokeLineCap(?LineCapStyle)

```cangjie
public func strokeLineCap(value: ?LineCapStyle): T
```

**功能：** 设置边框端点绘制样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[LineCapStyle](./cj-common-types.md#enum-linecapstyle)|是|-|边框线帽样式。初始值：LineCapStyle.Butt。|

### func strokeLineJoin(?LineJoinStyle)

```cangjie
public func strokeLineJoin(value: ?LineJoinStyle): T
```

**功能：** 设置边框拐角绘制样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[LineJoinStyle](./cj-common-types.md#enum-linejoinstyle)|是|-|边框连接点样式。初始值：LineJoinStyle.Miter。|

### func strokeMiterLimit(?Float64)

```cangjie
public func strokeMiterLimit(miterLimit: ?Float64): T
```

**功能：** 设置斜接长度与边框宽度比值的极限值。斜接长度表示外边框外边交点到内边交点的距离，边框宽度即strokeWidth属性的值。该属性取值需在strokeLineJoin属性取值LineJoinStyle.Miter时生效。<br>该属性的合法值范围应当大于等于1.0，当取值范围在[0,1)时按1.0处理，其余异常值按初始值处理。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|miterLimit|?Float64|是|-|斜接长度与边框宽度比值的极限值。<br>初始值：4.0。|

### func strokeOpacity(?Float64)

```cangjie
public func strokeOpacity(value: ?Float64): T
```

**功能：** 设置边框透明度。该属性的取值范围是[0.0, 1.0]，若给定值小于0.0，则取值为0.0；若给定值大于1.0，则取值为1.0，其余异常值按1.0处理。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Float64|是|-|边框透明度。初始值：1.0。|

### func strokeOpacity(?AppResource)

```cangjie
public func strokeOpacity(value: ?AppResource): T
```

**功能：** 设置边框透明度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[AppResource](../LocalizationKit/cj-apis-resource.md#class-appresource)|是|-|边框透明度。初始值：1.0。|

### func strokeWidth(?Length)

```cangjie
public func strokeWidth(value: ?Length): T
```

**功能：** 设置边框宽度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|边框宽度。初始值：1.vp。|

### func antiAlias(?Bool)

```cangjie
public func antiAlias(value: ?Bool): T
```

**功能：** 设置是否开启抗锯齿。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|是否开启抗锯齿。初始值：true。|

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