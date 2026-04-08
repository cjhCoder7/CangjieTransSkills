# 图形变换

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

用于对组件进行旋转、平移、缩放、矩阵变换等操作。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func rotate(?Float32, ?Float32, ?Float32, ?Float32, ?Length, ?Length)

```cangjie
func rotate(x!: ?Float32, y!: ?Float32, z!: ?Float32, angle!: ?Float32,
    centerX!: ?Length, centerY!: ?Length): T
```

**功能：** 设置组件旋转。

> **说明：**
>
> - 可使组件在以组件左上角为坐标原点的坐标系中进行旋转（坐标系如下图所示）。其中，(x, y, z)指定一个矢量，作为旋转轴。
> - 旋转轴和旋转中心点都基于坐标系设定，组件发生位移时，坐标系不会随之移动。
> - 默认值: 在x、y、z都不指定时，x、y、z的默认值分别为0、0、1。指定了x、y、z任何一个值时，x、y、z中未指定的值默认为0。
> ![coordinates](figures/coordinates.png)

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|?Float32|是|-|**命名参数。** 旋转轴向量x坐标。初始值: 0.0|
|y|?Float32|是|-|**命名参数。** 旋转轴向量y坐标。初始值: 0.0|
|z|?Float32|是|-|**命名参数。** 旋转轴向量z坐标。初始值: 1.0|
|angle|?Float32|是|-|**命名参数。** 旋转角度。取值为正时相对于旋转轴方向顺时针转动，取值为负时相对于旋转轴方向逆时针转动。初始值: 0.0|
|centerX|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 变换中心点x轴坐标。表示组件变换中心点（即锚点）的x方向坐标。初始值：50.percent|
|centerY|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 变换中心点y轴坐标。表示组件变换中心点（即锚点）的y方向坐标。初始值：50.percent|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func scale(?Float32, ?Float32, ?Float32, ?Length, ?Length)

```cangjie
func scale(x!: ?Float32, y!: ?Float32, z!: ?Float32, centerX!: ?Length,
    centerY!: ?Length): T
```

**功能：** 设置组件的缩放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|?Float32|是|-|**命名参数。** X轴缩放分量。初始值：1.0|
|y|?Float32|是|-|**命名参数。** Y轴缩放分量。初始值：1.0|
|z|?Float32|是|-|**命名参数。** Z轴缩放分量。初始值：1.0|
|centerX|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 变换中心点x轴坐标。表示组件变换中心点（即锚点）的x方向坐标。初始值：50.percent|
|centerY|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 变换中心点y轴坐标。表示组件变换中心点（即锚点）的y方向坐标。初始值：50.percent|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func translate(?Length, ?Length, ?Length)

```cangjie
func translate(x!: ?Length, y!: ?Length, z!: ?Length): T
```

**功能：** 设置组件的平移。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** X轴平移距离。初始值：0.px|
|y|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** Y轴平移距离。初始值：0.px|
|z|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** Z轴平移距离。初始值：0.px|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## 示例代码

### 示例1（图形变换效果）

该示例演示了如何使用rotate、scale和translate方法对组件进行变换。

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
            Text("原始文本")
                .width(120)
                .height(50)
                .backgroundColor(Color.Blue)

            Text("旋转45度")
                .width(120)
                .height(50)
                .backgroundColor(Color.Blue)
                .rotate(angle: 45.0)

            Text("缩放1.5倍")
                .width(120)
                .height(50)
                .backgroundColor(Color.Green)
                .scale(x: 1.5, y: 1.5)

            Text("平移(50, 20)")
                .width(120)
                .height(50)
                .backgroundColor(Color.Gray)
                .translate(x: 50.vp, y: 20.vp)

            Text("组合变换")
                .width(120)
                .height(50)
                .backgroundColor(Color.Red)
                .rotate(angle: 30.0)
                .scale(x: 1.2, y: 1.2)
                .translate(x: 30.vp, y: 10.vp)
        }
        .width(100.percent)
        .height(100.percent)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
    }
}
```

![transform](./figures/transform.PNG)
