# Circle

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

用于绘制圆形的组件。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(?Length, ?Length)

```cangjie
public init(width!: ?Length = None, height!: ?Length = None)
```

**功能：** 绘制一个宽度为width，高度为height的圆形，宽高设置不一致时以短边为直径。异常值按照初始值处理。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|width|?[Length](./cj-common-types.md#interface-length)|否|None| **命名参数。** 宽度，取值范围≥0。初始值: 0.vp|
|height|?[Length](./cj-common-types.md#interface-length)|否|None| **命名参数。** 高度，取值范围≥0。初始值: 0.vp|

## 通用属性/通用事件

通用属性：除了支持通用属性外，还支持[图形绘制通用属性](./cj-graphic-drawing-common.md#组件属性)。

通用事件：全部支持。

## 示例代码

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Column(space: 10) {
            // 绘制一个直径为150的圆
            Circle(width: 150, height: 150)
            // 绘制一个直径为150、线条为红色虚线的圆环（宽高设置不一致时以短边为直径）
            Circle()
                .width(150)
                .height(200)
                .fillOpacity(0.0)
                .strokeWidth(3)
                .stroke(Color.Red)
                .strokeDashArray([1, 2])
        }.width(100.percent)
    }
}
```

![circle2](./figures/circle2.png)
