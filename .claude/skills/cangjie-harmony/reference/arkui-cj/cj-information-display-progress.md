# Progress

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

进度条组件，用于显示内容加载或操作处理等进度。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(?Float64, ?Float64, ?ProgressType)

```cangjie
public init(value!: ?Float64, total!: ?Float64 = None, progressType!: ?ProgressType = None)
```

**功能：** 创建进度条组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Float64|是|-|**命名参数。** 指定当前进度值。设置小于0的数值时置为0.0，设置大于total的数值时置为total。初始值：0.0|
|total|?Float64|否|None|**命名参数。** 指定进度总长。设置小于等于0的数值时置为100.0。|
|progressType|?[ProgressType](./cj-common-types.md#enum-progresstype)|否|None|**命名参数。** 指定进度条类型。|

## 通用属性/通用事件

通用属性：全部支持。

> **说明：**
>
> 该组件重写了通用属性backgroundColor，直接添加在Progress组件上，生效进度条的底色。如需设置整个Progress组件的背景色，需要在外层容器上添加backgroundColor，容器再包裹Progress组件。

通用事件：全部支持。

## 组件属性

### func color(?ResourceColor)

```cangjie
public func color(value: ?ResourceColor): This
```

**功能：** 设置进度条前景色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|进度条前景色。|

### func style(?Length, ?Int32, ?Length)

```cangjie
public func style(strokeWidth!: ?Length = None, scaleCount!: ?Int32 = None, scaleWidth!: ?Length = None): This
```

**功能：** 设置进度条的样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|strokeWidth|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 设置进度条宽度（不支持百分比设置）。初始值：4.vp。|
|scaleCount|?Int32|否|None|**命名参数。** 设置环形进度条总刻度数。初始值：120。|
|scaleWidth|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 设置环形进度条刻度粗细（不支持百分比设置），刻度粗细大于进度条宽度时，为系统默认粗细。初始值：2.vp。|

### func style(?RingStyleOptions)

```cangjie
public func style(value: ?RingStyleOptions): This
```

**功能：** 设置进度条Ring的样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[RingStyleOptions](#class-ringstyleoptions)|是|-|设置Ring的样式。<br>初始值：RingStyleOptions()。|

### func value(?Float64)

```cangjie
public func value(value: ?Float64): This
```

**功能：** 设置当前进度值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Float64|是|-|当前进度值。初始值：0.0。|

## 基础类型定义

### interface CommonProgressStyleOptions

```cangjie
sealed interface CommonProgressStyleOptions {}
```

**功能：** 进度条通用样式选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### class RingStyleOptions

```cangjie
public class RingStyleOptions <: CommonProgressStyleOptions {
    public var strokeWidth: ?Length
    public var shadow: ?Bool
    public var status: ?ProgressStatus
    public var enableSmoothEffect: ?Bool
    public var enableScanEffect: ?Bool
    public init(strokeWidth!: ?Length = None, shadow!: ?Bool = None, status!: ?ProgressStatus = None, enableSmoothEffect!: ?Bool = None, enableScanEffect!: ?Bool = None)
}
```

**功能：** 环形进度条样式选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [CommonProgressStyleOptions](#interface-commonprogressstyleoptions)

#### var enableScanEffect

```cangjie
public var enableScanEffect: ?Bool
```

**功能：** 扫光效果的开关。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var enableSmoothEffect

```cangjie
public var enableSmoothEffect: ?Bool
```

**功能：** 进度平滑动效的开关。开启平滑动效后设置进度，进度会从当前值渐变至设定值，否则进度从当前值突变至设定值。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var shadow

```cangjie
public var shadow: ?Bool
```

**功能：** 进度条阴影开关。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var status

```cangjie
public var status: ?ProgressStatus
```

**功能：** 进度条状态，当设置为LOADING时会开启检查更新动效，此时设置进度值不生效。当从LOADING设置为PROGRESSING，检查更新动效会执行到终点再停止。

**类型：** ?[ProgressStatus](#enum-progressstatus)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var strokeWidth

```cangjie
public var strokeWidth: ?Length
```

**功能：** 设置进度条宽度（不支持百分比设置）。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?Length, ?Bool, ?ProgressStatus, ?Bool, ?Bool)

```cangjie
public init(strokeWidth!: ?Length = None, shadow!: ?Bool = None, status!: ?ProgressStatus = None, enableSmoothEffect!: ?Bool = None, enableScanEffect!: ?Bool = None)
```

**功能：** 创建一个RingStyleOptions对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|strokeWidth|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 设置进度条宽度（不支持百分比设置），宽度大于等于半径时，默认修改宽度至半径值的二分之一。初始值：4.0.vp。|
|shadow|?Bool|否|None|**命名参数。** 进度条阴影开关。初始值：false。|
|status|?[ProgressStatus](#enum-progressstatus)|否|None|**命名参数。** 进度条状态，当设置为LOADING时会开启检查更新动效，此时设置进度值不生效。当从LOADING设置为PROGRESSING，检查更新动效会执行到终点再停止。初始值：ProgressStatus.Progressing。|
|enableSmoothEffect|?Bool|否|None|**命名参数。** 进度平滑动效的开关。开启平滑动效后设置进度，进度会从当前值渐变至设定值，否则进度从当前值突变至设定值。初始值：true。|
|enableScanEffect|?Bool|否|None|**命名参数。** 扫光效果的开关。初始值：false。|

### enum ProgressStatus

```cangjie
public enum ProgressStatus <: Equatable<ProgressStatus> {
    | Loading
    | Progressing
    | ...
}
```

**功能：** 当前进度条的状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ProgressStatus](#enum-progressstatus)>

#### Loading

```cangjie
Loading
```

**功能：** 加载状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### Progressing

```cangjie
Progressing
```

**功能：** 处理中状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### operator func !=(ProgressStatus)

```cangjie
public operator func !=(other: ProgressStatus): Bool
```

**功能：** 比较两个枚举值是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ProgressStatus](#enum-progressstatus)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值不相等则返回true，否则返回false。|

#### operator func ==(ProgressStatus)

```cangjie
public operator func ==(other: ProgressStatus): Bool
```

**功能：** 比较两个枚举值是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ProgressStatus](#enum-progressstatus)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值相等则返回true，否则返回false。|

## 示例代码

### 示例1（设置进度条的类型）

该示例通过type属性，实现了设置进度条类型的功能。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    let scaleStyle0 = RingStyleOptions(strokeWidth: 15.vp, enableSmoothEffect: true)
    let scaleStyle1 = RingStyleOptions(strokeWidth: 20.vp, enableSmoothEffect: true)
    let scaleStyle2 = RingStyleOptions(strokeWidth: 20.vp, enableSmoothEffect: true)
    let ringStyle = RingStyleOptions(strokeWidth: 20.vp)
    func build() {
        Column(space: 15) {
            Text("Linear Progress").fontSize(20).fontColor(0xCCCCCC).width(90.percent)
            Progress(value: 10.0, progressType: ProgressType.Linear).width(200)
            Progress(value: 20.0, total: 150.0, progressType: ProgressType.Linear)
                .color(Color.Gray)
                .value(50.0)
                .width(200)

            Text("Eclipse Progress").fontSize(20).fontColor(0xCCCCCC).width(90.percent)
            Row(space: 40) {
                Progress(value: 10.0, progressType: ProgressType.Eclipse).width(100)
                Progress(value: 20.0, total: 150.0, progressType: ProgressType.Eclipse)
                    .width(100)
                    .color(Color.Gray)
                    .value(50.0)
            }

            Text("ScaleRing Progress").fontSize(20).fontColor(0xCCCCCC).width(90.percent)
            Row(space: 40) {
                Progress(value: 10.0, progressType: ProgressType.ScaleRing).width(100)
                Progress(value: 20.0, total: 150.0, progressType: ProgressType.ScaleRing)
                    .color(Color.Gray)
                    .value(50.0)
                    .width(100)
                    .style(scaleStyle0)
            }

            Row(space: 40) {
                Progress(value: 20.0, total: 150.0, progressType: ProgressType.ScaleRing)
                    .color(Color.Gray)
                    .value(50.0)
                    .width(100)
                    .style(scaleStyle1)
                Progress(value: 20.0, total: 150.0, progressType: ProgressType.ScaleRing)
                    .color(Color.Gray)
                    .value(50.0)
                    .width(100)
                    .style(scaleStyle2)
            }

            Text("Ring Progress").fontSize(20).fontColor(0xCCCCCC).width(90.percent)
            Row(space: 40) {
                Progress(value: 10.0, progressType: ProgressType.Ring).width(100)
                Progress(value: 20.0, total: 150.0, progressType: ProgressType.Ring)
                    .color(Color.Gray)
                    .value(50.0)
                    .width(100)
                    .style(ringStyle)
            }

            Text("Capsule Progress").fontSize(20).fontColor(0xCCCCCC).width(90.percent)
            Row(space: 40) {
                Progress(value: 10.0, progressType: ProgressType.Capsule).width(100).height(50)
                Progress(value: 20.0, total: 150.0, progressType: ProgressType.Capsule)
                    .color(Color.Gray)
                    .value(50.0)
                    .width(100)
                    .height(50)
            }
        }
    }
}
```

![progress1](./figures/progress1.PNG)

### 示例2（设置环形进度条属性）

该示例通过style接口的strokeWidth、shadow属性，实现了环形进度条视觉属性设置功能。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    let ringStyle0 = RingStyleOptions(strokeWidth: 20.vp)
    let ringStyle1 = RingStyleOptions(strokeWidth: 20.vp, shadow: true)
    func build() {
        Column(space: 15) {
            Text("Gradient Color").fontSize(20).fontColor(0xCCCCCC).width(90.percent)
            Row(space: 40) {
                Progress(value: 70.0, progressType: ProgressType.Ring)
                    .width(100)
                    .style(ringStyle0)
                    .color(0X02fd03)
            }
            Text("Shadow").fontSize(20).fontColor(0xCCCCCC).width(90.percent)
            Row(space: 40) {
                Progress(value: 70.0, progressType: ProgressType.Ring).width(120).color(Color.Blue).style(ringStyle1)
            }
        }
    }
}
```

![progress2](./figures/progress2.PNG)

### 示例3（设置环形进度条动画）

该示例通过style接口的status、enableScanEffect属性，实现了环形进度条动效的开关功能。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry

import ohos.arkui.state_management.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.component.*
import ohos.base.*
import ohos.resource_manager.*

@Entry
@Component
class EntryView {
    let ringStyle0 = RingStyleOptions(strokeWidth: 20.vp, status: ProgressStatus.Loading)
    let ringStyle1 = RingStyleOptions(strokeWidth: 20.vp, enableScanEffect: true)
    func build() {
        Column(space: 15) {
            Text("Loading Effect").fontSize(20).fontColor(0xCCCCCC).width(90.percent)
            Row(space: 40) {
                Progress(value: 0.0, progressType: ProgressType.Ring).width(100).style(ringStyle0).color(Color.Blue)
            }
            Text("Shadow").fontSize(20).fontColor(0xCCCCCC).width(90.percent)
            Row(space: 40) {
                Progress(value: 30.0, progressType: ProgressType.Ring).width(100).color(0X02fd03).style(ringStyle1)
            }
        }
    }
}
```

![progress3](figures/progress3.gif)

### 示例4（设置进度平滑动效）

该示例通过style接口的enableSmoothEffect属性，实现了进度平滑动效开关的功能。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State
    var value: Float64 = 0.0

    func build() {
        Column(space: 10) {
            Text('enableSmoothEffect: true').fontSize(9).fontColor(0xCCCCCC).width(90.percent).margin(5).margin( top: 20 )
            Progress( value: this.value, total: 100.0, progressType: ProgressType.Linear ).style(RingStyleOptions(strokeWidth: 10, enableSmoothEffect: true ))
            Text('enableSmoothEffect: false').fontSize(9).fontColor(0xCCCCCC).width(90.percent).margin(5)
            Progress( value: this.value, total: 100.0, progressType: ProgressType.Linear ).style(RingStyleOptions(strokeWidth: 10, enableSmoothEffect: false ))
            Button('value +10')
                .onClick({ evt =>
                    this.value += 10.0
            }).width(75).height(15).fontSize(9)
        }.width(50.percent).height(100.percent).margin( left: 20 )
    }
}
```

![progress5](figures/progress5.gif)