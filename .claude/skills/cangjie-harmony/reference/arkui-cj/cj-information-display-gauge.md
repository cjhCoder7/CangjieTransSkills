# Gauge

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

数据量规图表组件，用于将数据展示为环形图表。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

可以包含子组件。

## 创建组件

### init(?Float32, ?Float32, ?Float32, () -> Unit)

```cangjie
public init(value!: ?Float32, min!: ?Float32 = None, max!: ?Float32 = None, child!: () -> Unit = { => })
```

**功能：** 创建一个数据量规图表组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Float32|是|-| **命名参数。** 初始值: 0.0。 量规图的当前数据值，即图中指针指向位置。用于组件创建时量规图初始值的预置。<br>**说明：**<br>value不在min和max范围内时使用min作为默认值。|
|min|?Float32|否|None| **命名参数。** 初始值: 0.0。 当前数据段最小值。|
|max|?Float32|否|None| **命名参数。** 初始值: 100.0。 当前数据段最大值。<br>**说明：**<br>max小于min时使用默认值0.0和100.0。<br>max和min支持负数。|
|child|()->Unit|否|{ => }| **命名参数。** 声明当前组件的子组件。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func colors(?Array\<(ResourceColor, Int32)>)

```cangjie
public func colors(value: ?Array<(ResourceColor, Int32)>): This
```

**功能：** 设置量规图的颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Array\<([ResourceColor](./cj-common-types.md#interface-resourcecolor), Int32)>|是|-|量规图的颜色，支持分段颜色设置。|

### func colors(?Array\<(LinearGradient, Int32)>)

```cangjie
public func colors(value: ?Array<(LinearGradient, Int32)>): This
```

**功能：** 设置量规图的分段渐变颜色组。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Array\<([LinearGradient](cj-information-display-datapanel.md#class-lineargradient), Int32)>|是|-|量规图的渐变色，支持分段颜色设置，最多9组。LinearGradient类型见datapanel组件，Int32为该段颜色的宽度范围。|

### func colors(?LinearGradient)

```cangjie
public func colors(value: ?LinearGradient): This
```

**功能：** 设置量规图的分段渐变颜色组。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[LinearGradient](./cj-information-display-datapanel.md#class-lineargradient)|是|-|量规图的渐变色，支持分段颜色设置，最多9组。|

### func colors(?ResourceColor)

```cangjie
public func colors(value: ?ResourceColor): This
```

**功能：** 设置量规图的颜色。

参数类型为ResourceColor，则圆环类型为单色环。

参数类型为LinearGradient，则圆环类型为渐变环。

参数类型为数组，则圆环类型为分段渐变环，第一个参数为颜色值，若设置为非颜色类型，则置为"0xFFE84026"。第二个参数为颜色所占比重，若设置为负数或是非数值类型，则将比重置为0。

分段渐变环最大显示段数为9段，若多于9段，则多于部分不显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|量规图的颜色，支持分段颜色设置。|

### func description(?CustomBuilder)

```cangjie
public func description(builder: ?CustomBuilder): This
```

**功能：** 设置量规图的说明内容。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|builder|?[CustomBuilder](./cj-common-types.md#type-custombuilder)|是|-|说明内容，@Builder中的内容由开发者自定义，建议使用文本。<br>初始值：{ => }。|

### func endAngle(?Float32)

```cangjie
public func endAngle(angle: ?Float32): This
```

**功能：** 设置终止角度位置。

> **说明：**
>
> 当起始角度位置和终止角度位置差过小时，会绘制出异常图像，请选取合理的起始角度位置和终止角度位置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|angle|?Float32|是|-|终止角度位置，时钟0点为0度，顺时针方向为正角度。<br>初始值: 360.0。|

### func indicator(?ResourceStr, ?Length)

```cangjie
public func indicator(icon!: ?ResourceStr = None, space!: ?Length = None): This
```

**功能：** 设置指针样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|icon|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None| **命名参数。** 初始值: "SystemStyle"。 指针样式："SystemStyle"为三角箭头，"null"为无指针。|
|space|?[Length](./cj-common-types.md#interface-length)|否|None| **命名参数。** 初始值: 8.0.vp。 指针距离圆环外边的间距(不支持百分比)。<br>单位：vp。|

### func startAngle(?Float32)

```cangjie
public func startAngle(angle: ?Float32): This
```

**功能：** 设置量规图起始角度位置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|angle|?Float32|是|-|起始角度位置，时钟0点为0度，顺时针方向为正角度。初始值: 0.0。|

### func strokeWidth(?Length)

```cangjie
public func strokeWidth(length: ?Length): This
```

**功能：** 设置环形量规图的环形厚度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|length|?[Length](./cj-common-types.md#interface-length)|是|-|环形量规图的环形厚度。<br>初始值: 4.0.vp。<br>单位：vp。<br>**说明：**<br>设置小于0的值时，按默认值显示。<br>环形厚度的最大值为圆环的半径，超过最大值按最大值处理。<br>不支持百分比。|

### func trackShadow(?Float32, ?Float32, ?Float32)

```cangjie
public func trackShadow(radius!: ?Float32 = None, offsetX!: ?Float32 = None, offsetY!: ?Float32 = None): This
```

**功能：** 设置阴影样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|radius|?Float32|否|None| **命名参数。** 初始值: 20.0 投影模糊半径。<br>单位：vp。|
|offsetX|?Float32|否|None| **命名参数。** 初始值: 5.0 X轴的偏移量。|
|offsetY|?Float32|否|None| **命名参数。** 初始值: 5.0 Y轴的偏移量 。|

### func value(?Float32)

```cangjie
public func value(value: ?Float32): This
```

**功能：** 设置量规图的数据值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Float32|是|-|量规图的数据值，可用于动态修改量规图的数据值。<br>初始值: 0.0。|