# DataPanel

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

数据面板组件，用于将多个数据占比情况使用占比图进行展示。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(Array\<Float64>, ?Float64, ?DataPanelType)

```cangjie
public init(values!: Array<Float64>, max!: ?Float64 = None, panelType!: ?DataPanelType = None)
```

**功能：** 创建一个数据面板组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|values|Array\<Float64>|是|-|**命名参数。** 数据值列表，最多包含9个数据，大于9个数据则取前9个数据。若数据值小于0则置为0。|
|max|?Float64|否|None|**命名参数。** 初始值: 100.0 \- max大于0，表示数据的最大值。 <br> \- max小于等于0，max等于value数组各项的和，按比例显示。|
|panelType|?[DataPanelType](./cj-common-types.md#enum-datapaneltype)|否|None|**命名参数。** 初始值: DataPanelType.Circle 数据面板的类型（不支持动态修改）。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func closeEffect(?Bool)

```cangjie
public func closeEffect(value: ?Bool): This
```

**功能：** 设置关闭数据占比图表旋转动效和投影效果。

> **说明：**
>
> 若未设置[trackShadow属性](#func-trackshadowdatapanelshadowoptions)，则该属性控制投影效果的开关，开启投影的效果为投影的默认效果。若设置trackShadow属性，则由trackShadow属性值控制投影效果的开关。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|关闭数据占比图表旋转动效和投影效果。初始值: true<br>false表示关闭数据占比图表旋转动效和投影效果，true表示开启数据占比图表旋转动效和投影效果。|

### func strokeWidth(?Length)

```cangjie
public func strokeWidth(value: ?Length): This
```

**功能：** 根据Length设置圆环粗细。

> **说明：**
>
> 数据面板的类型为DataPanelType.Line时该属性不生效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|圆环粗细。初始值: 24.0.vp。<br>单位：vp。<br>设置小于0的值时，按默认值显示。|

### func trackBackgroundColor(?ResourceColor)

```cangjie
public func trackBackgroundColor(value: ?ResourceColor): This
```

**功能：** 设置底板颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|底板颜色。初始值: 0x08182431|

### func trackShadow(?DataPanelShadowOptions)

```cangjie
public func trackShadow(value: ?DataPanelShadowOptions): This
```

**功能：** 设置投影样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[DataPanelShadowOptions](#class-datapanelshadowoptions)|是|-|投影样式。<br>不设置时，默认不开启投影。<br>初始值：DataPanelShadowOptions()。|

### func valueColors(?Array\<LinearGradient>)

```cangjie
public func valueColors(value: ?Array<LinearGradient>): This
```

**功能：** 设置各数据段颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Array\<[LinearGradient](#class-lineargradient)>|是|-|各数据段颜色，ResourceColor为纯色，LinearGradient为渐变色。|

## 基础类型定义

### class ColorStop

```cangjie
public class ColorStop {
    public var color: ResourceColor
    public var offset: Length
    public init(color: ResourceColor, offset: Length)
}
```

**功能：** 颜色断点类型，用于描述渐进色颜色断点。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var color

```cangjie
public var color: ResourceColor
```

**功能：** 颜色值。

**类型：** [ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var offset

```cangjie
public var offset: Length
```

**功能：** 渐变色断点（0~1之间的比例值，若数据值小于0则置为0，若数据值大于1则置为1）。

**类型：** [Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(ResourceColor, Length)

```cangjie
public init(color: ResourceColor, offset: Length)
```

**功能：** 创建ColorStop对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|color|[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|颜色值。|
|offset|[Length](./cj-common-types.md#interface-length)|是|-|渐变色断点（0~1之间的比例值，若数据值小于0则置为0，若数据值大于1则置为1）。|

### class DataPanelShadowOptions

```cangjie
public class DataPanelShadowOptions <: MultiShadowOptions {
    public var colors: ?Array<LinearGradient>
    public init(radius!: ?Length = None, colors!: ?Array<LinearGradient> = None, offsetX!: ?Length = None, offsetY!: ?Length = None)
}
```

**功能：** 投影样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [MultiShadowOptions](./cj-common-types.md#class-multishadowoptions)

#### var colors

```cangjie
public var colors: ?Array<LinearGradient>
```

**功能：** 各数据段投影的颜色。

> **说明：**
>
> - 若设置的投影颜色的个数少于数据段个数时，则显示的投影颜色的个数和设置的投影颜色个数一致。
> - 若设置的投影颜色的个数多于数据段个数时，则显示的投影颜色的个数和数据段个数一致。

**类型：** ?Array\<[LinearGradient](#class-lineargradient)>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?Length, ?Array\<LinearGradient>, ?Length, ?Length)

```cangjie
public init(radius!: ?Length = None, colors!: ?Array<LinearGradient> = None, offsetX!: ?Length = None, offsetY!: ?Length = None)
```

**功能：** 创建DataPanelShadowOptions对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|radius|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 初始值: 20.vp 投影模糊半径。|
|colors|?Array\<[LinearGradient](#class-lineargradient)>|否|None|**命名参数。** 初始值: [] 各数据段投影的颜色。<br>若设置的投影颜色的个数少于数据段个数时，则显示的投影颜色的个数和设置的投影颜色个数一致。<br>若设置的投影颜色的个数多于数据段个数时，则显示的投影颜色的个数和数据段个数一致。|
|offsetX|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 初始值: 5.vp X轴的偏移量。|
|offsetY|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 初始值: 5.vp Y轴的偏移量。|

### class LinearGradient

```cangjie
public class LinearGradient {
    public init(colorStops: Array<ColorStop>)
    public init(color: ResourceColor)
}
```

**功能：** 线性渐变颜色描述。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(Array\<ColorStop>)

```cangjie
public init(colorStops: Array<ColorStop>)
```

**功能：** 渐变颜色描述。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|colorStops|Array\<[ColorStop](#class-colorstop)>|是|-| 存储渐变颜色和渐变点。|

#### init(ResourceColor)

```cangjie
public init(color: ResourceColor)
```

**功能：** 渐变颜色描述。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|color|[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|单一渐变颜色。|

## 示例代码

### 示例1（设置数据面板类型）

该示例通过type属性，实现了设置数据面板的类型的功能。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    var valueArr: Array<Float64> = [10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0]
    func build() {
        Column {
            Row() {
                Stack() {
                    DataPanel(values: [30.0], max: 100.0, panelType: DataPanelType.Circle).width(168).height(168)
                    Column() {
                        Text("30")
                            .fontSize(35)
                            .fontColor(0x182431)
                        Text("1.0.0")
                            .fontSize(9.33)
                            .lineHeight(12.83)
                            .fontWeight(FontWeight.W500)
                            .opacity(0.6)
                    }
                    Text("%")
                        .fontSize(9.33)
                        .lineHeight(12.83)
                        .fontWeight(FontWeight.W500)
                        .opacity(0.6)
                        .position(x: 104.42, y: 78.17)
                }.margin(right: 44)
                Stack() {
                    DataPanel(values: [50.0, 12.0, 8.0, 5.0], max: 100.0, panelType: DataPanelType.Circle)
                        .width(168)
                        .height(168)
                    Column() {
                        Text("75")
                            .fontSize(35)
                            .fontColor(0x182431)
                        Text("已使用98GB/128GB")
                            .fontSize(8.17)
                            .lineHeight(11.08)
                            .fontWeight(FontWeight.W500)
                            .opacity(0.6)
                    }
                    Text("%")
                        .fontSize(9.33)
                        .lineHeight(12.83)
                        .fontWeight(FontWeight.W500)
                        .opacity(0.6)
                        .position(x: 104.42, y: 78.17)
                }
            }
                .margin(bottom: 59)
            DataPanel(values: this.valueArr, max: 100.0, panelType: DataPanelType.Line)
                .width(300)
                .height(10)
        }
            .width(100.percent)
            .margin(top: 5)
    }
}
```

![dataPanel](./figures/dataPanel.png)

### 示例2（设置渐变色和阴影）

该示例通过valueColors和trackShadow接口设置LinearGradient颜色，实现了设置渐变色效果和阴影效果。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    var values1: Array<Float64> = [20.0, 20.0, 20.0, 20.0]
    var color1: LinearGradient = LinearGradient([ColorStop(0x65EEC9A3, 0), ColorStop(0xFFEF629F, 1)])
    var color2: LinearGradient = LinearGradient([ColorStop(0xFF67F9D4, 0), ColorStop(0xFFFF9554, 1)])
    var colorShadow1: LinearGradient = LinearGradient([ColorStop(0x65EEC9A3, 0), ColorStop(0x65EF629F, 1)])
    var colorShadow2: LinearGradient = LinearGradient([ColorStop(0x65e26709, 0), ColorStop(0x65efbd08, 1)])
    var colorShadow3: LinearGradient = LinearGradient([ColorStop(0x6572B513, 0), ColorStop(0x6508efa6, 1)])
    var colorShadow4: LinearGradient = LinearGradient([ColorStop(0x65ed08f5, 0), ColorStop(0x65ef0849, 1)])
    var color3: LinearGradient = LinearGradient(0x00FF00)
    var color4: LinearGradient = LinearGradient(0x20FF0000)
    @State var bgColor: UInt32 = 0x08182431
    @State var offsetX: Int64 = 15
    @State var offsetY: Int64 = 15
    @State var radius: Int64 = 5
    @State var colorArray: Array<LinearGradient> = [this.color1, this.color2, this.color3, this.color4]
    @State var shadowColorArray: Array<LinearGradient> = [this.colorShadow1, this.colorShadow2, this.colorShadow3,this.colorShadow4]
    func build() {
        Column {
            Text("LinearGradient")
                .fontSize(9)
                .fontColor(0xCCCCCC)
                .textAlign(TextAlign.Start)
                .width(100.percent)
                .margin(top: 20, left: 20)
            DataPanel(values: this.values1, max: 100.0, panelType: DataPanelType.Circle)
                .width(300)
                .height(300).
                valueColors(this.colorArray)
                .trackShadow(
                DataPanelShadowOptions(
                    radius: this.radius,
                    colors: this.shadowColorArray,
                    offsetX: this.offsetX,
                    offsetY: this.offsetY
                )
            )
                .strokeWidth(30)
                .trackBackgroundColor(this.bgColor)
        }
            .width(100.percent)
            .margin(top: 5)
    }
}
```

![LinearGradientDataPanel](./figures/LinearGradientDataPanel.png)

### 示例3（设置关闭动画和阴影）

该示例通过closeEffect接口，实现了关闭数据面板动画和阴影的功能。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    var values1: Array<Float64> = [20.0, 20.0, 20.0, 20.0]
    var color1: LinearGradient = LinearGradient([ColorStop(0x65EEC9A3, 0), ColorStop(0xFFEF629F, 1)])
    var color2: LinearGradient = LinearGradient([ColorStop(0xFF67F9D4, 0), ColorStop(0xFFFF9554, 1)])
    var colorShadow1: LinearGradient = LinearGradient([ColorStop(0x65EEC9A3, 0), ColorStop(0x65EF629F, 1)])
    var colorShadow2: LinearGradient = LinearGradient([ColorStop(0x65e26709, 0), ColorStop(0x65efbd08, 1)])
    var colorShadow3: LinearGradient = LinearGradient([ColorStop(0x6572B513, 0), ColorStop(0x6508efa6, 1)])
    var colorShadow4: LinearGradient = LinearGradient([ColorStop(0x65ed08f5, 0), ColorStop(0x65ef0849, 1)])
    var color3: LinearGradient = LinearGradient(0x00FF00)
    var color4: LinearGradient = LinearGradient(0x20FF0000)
    @State var bgColor: UInt32 = 0x08182431
    @State var offsetX: Int64 = 15
    @State var offsetY: Int64 = 15
    @State var radius: Int64 = 5
    @State var colorArray: Array<LinearGradient> = [this.color1, this.color2, this.color3, this.color4]
    @State var shadowColorArray: Array<LinearGradient> = [this.colorShadow1, this.colorShadow2, this.colorShadow3,this.colorShadow4]
    func build() {
        Column {
            Text("LinearGradient")
                .fontSize(9)
                .fontColor(0xCCCCCC)
                .textAlign(TextAlign.Start)
                .width(100.percent)
                .margin(top: 20, left: 20)
            DataPanel(values: this.values1, max: 100.0, panelType: DataPanelType.Circle)
                .width(300)
                .height(300).
                valueColors(this.colorArray)
                .strokeWidth(30)
                .closeEffect(true)
                .trackBackgroundColor(this.bgColor)
        }
            .width(100.percent)
            .margin(top: 5)
    }
}
```

![LinearGradientDataPanel1](./figures/LinearGradientDataPanel1.png)