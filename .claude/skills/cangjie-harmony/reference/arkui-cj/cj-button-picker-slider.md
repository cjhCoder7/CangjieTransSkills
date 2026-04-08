# Slider

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

滑动条组件，通常用于快速调节设置值，如音量调节、亮度调节等应用场景。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(?Float64, ?Float64, ?Float64, ?Float64, ?SliderStyle, ?Axis, ?Bool)

```cangjie
public init(
    min!: ?Float64 = None,
    max!: ?Float64 = None,
    step!: ?Float64 = None,
    value!: ?Float64 = None,
    style!: ?SliderStyle = None,
    direction!: ?Axis = None,
    reverse!: ?Bool = None
)
```

**功能：** 创建一个滑动条组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|min|?Float64|否|None| **命名参数。** 设置最小值。<br>初始值：0.0。|
|max|?Float64|否|None| **命名参数。** 设置最大值。<br>初始值：100.0。<br>**说明**：min >= max异常情况，min取初始值0，max取初始值100。<br>value不在[min, max]范围之内，取min或者max，靠近min取min，靠近max取max。|
|step|?Float64|否|None| **命名参数。** 设置滑动条滑动步长。<br>初始值：1.0。<br>**说明**：当step<=0，或step>=max\-min时，取初始值。|
|value|?Float64|否|None| **命名参数。** 当前进度值。<br>初始值：取min的值。|
|style|?[SliderStyle](./cj-common-types.md#enum-sliderstyle)|否|None| **命名参数。** 设置滑动条的滑块样式。<br>初始值：SliderStyle.OutSet。|
|direction|?[Axis](./cj-common-types.md#enum-axis)|否|None| **命名参数。** 设置滑动条滑动方向为水平或竖直方向。<br>初始值：Axis.Horizontal。|
|reverse|?Bool|否|None| **命名参数。** 设置滑动条取值范围是否反向。<br>初始值：false。<br>**说明**：<br>设置为false时，水平方向滑动条为从左向右滑动，竖直方向滑动条从上向下滑动。<br>设置为true时，水平方向滑动条为从右向左滑动，竖直方向滑动条从下向上滑动。|

## 通用属性/通用事件

通用属性：支持除触摸热区以外的通用属性。

通用事件：全部支持。

## 组件属性

### func blockBorderColor(?ResourceColor)

```cangjie
public func blockBorderColor(value: ?ResourceColor): This
```

**功能：** 设置滑块描边颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|滑块描边颜色。<br>初始值：0x00000000。|

### func blockColor(?ResourceColor)

```cangjie
public func blockColor(value: ?ResourceColor): This
```

**功能：** 设置滑块的颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|滑块的颜色。|

### func selectedColor(?ResourceColor)

```cangjie
public func selectedColor(value: ?ResourceColor): This
```

**功能：** 根据指定的Color设置滑轨已滑动部分的颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|滑轨已滑动部分的颜色。|

### func showSteps(?Bool)

```cangjie
public func showSteps(value: ?Bool): This
```

**功能：** 设置当前是否显示步长刻度值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|当前是否显示步长刻度值。<br>初始值：false。|

### func showTips(?Bool, ?ResourceStr)

```cangjie
public func showTips(value: ?Bool, content!: ?ResourceStr = None): This
```

**功能：** 设置滑动时是否显示气泡提示。

当direction的值为Axis.Horizontal时，tip显示在滑块上方，如果上方空间不够，则在下方显示。值为Axis.Vertical时，tip显示在滑块左边，如果左边空间不够，则在右边显示。不设置周边边距或者周边边距比较小时，tip会被截断。

tip的绘制区域为Slider自身节点的overlay。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|滑动时是否显示气泡提示。<br>初始值：false。|
|content|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None| **命名参数。** 气泡提示的文本内容，默认显示当前百分比。|

### func trackColor(?ResourceColor)

```cangjie
public func trackColor(value: ?ResourceColor): This
```

**功能：** 根据指定的Color设置滑轨的背景颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|滑轨的背景颜色。<br>**说明**：<br>设置渐变色时，若颜色断点颜色值为非法值或者渐变色断点为空时，渐变色不起效果。|

### func trackThickness(?Length)

```cangjie
public func trackThickness(value: ?Length): This
```

**功能：** 根据指定的Length设置滑轨的粗细。设置为小于等于0的值时，取初始值。

为保证滑块和滑轨的SliderStyle样式，blockSize跟随trackThickness同比例增减。

当style为SliderStyle.OutSet时，trackThickness:blockSize = 1:4，当style为SliderStyle.InSet时，trackThickness:blockSize = 5:3。

在变更trackThickness过程中，若trackThickness的大小或者blockSize的大小超过slider组件的width或者height（SliderStyle.OutSet时可能trackThickness没超过，但是blockSize超过了），取初始值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|滑轨的粗细。<br/>初始值：当参数style的值设置SliderStyle.OutSet 时为 4.0.vp，SliderStyle.InSet时为20.0.vp。|

## 组件事件

### func onChange(?(Float64, SliderChangeMode) -> Unit)

```cangjie
public func onChange(callback: ?(Float64, SliderChangeMode) -> Unit): This
```

**功能：** Slider拖动或点击时触发事件回调。

Begin和End状态当手势点击时都会触发，Moving和Click状态当value值发生变化时触发。

当连贯动作为拖动动作时，不触发Click状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?(Float64, [SliderChangeMode](./cj-common-types.md#enum-sliderchangemode)) -> Unit|是|-|Slider拖动或点击时触发事件回调。<br>参数一：当前滑动进度值，变化范围为对应步长steps数组。<br>参数二：事件触发的相关状态值。<br>初始值：{ _, _ => }。|

## 示例代码

### 示例1（滑动条基础样式）

该示例通过配置style、showTips、showSteps控制气泡、刻度值、滑块和滑轨的显示。

<!-- run -->

```cangjie

package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var outSetValueOne: Float64 = 40.00
    @State var inSetValueOne: Float64 = 40.00
    @State var noneValueOne: Float64 = 40.00
    @State var outSetValueTwo: Float64 = 40.00
    @State var inSetValueTwo: Float64 = 40.00
    @State var vOutSetValueOne: Float64 = 40.00
    @State var vInSetValueOne: Float64 = 40.00
    @State var vOutSetValueTwo: Float64 = 40.00
    @State var vInSetValueTwo: Float64 = 40.00

    func build() {
        Column() {
            Text('outset slider').fontSize(9).fontColor(0xCCCCCC).width(90.percent).margin(15)
            Row() {
                Slider(
                    value: this.outSetValueOne,
                    min: 0.0,
                    max: 100.0,
                    style: SliderStyle.OutSet
                ).showTips(true).onChange({
                    value: Float64, mode: SliderChangeMode => this.outSetValueOne = value
                })
                Text("${Int64(this.outSetValueOne)}").fontSize(12)
            }.width(80.percent)
            Row() {
                Slider(
                    value: this.outSetValueTwo,
                    step: 10.0,
                    style: SliderStyle.OutSet
                ).showSteps(true).onChange({
                    value: Float64, mode: SliderChangeMode => this.outSetValueTwo = value
                })
                Text("${Int64(this.outSetValueTwo)}").fontSize(12)
            }.width(80.percent)

            Text('inset slider').fontSize(9).fontColor(0xCCCCCC).width(90.percent).margin(15)
            Row() {
                Slider(
                    value: this.inSetValueOne,
                    min: 0.0,
                    max: 100.0,
                    style: SliderStyle.InSet
                )
                    .blockColor(0x191970)
                    .trackColor(0xADD8E6)
                    .selectedColor(0x4169E1)
                    .showTips(true)
                    .onChange({
                        value: Float64, mode: SliderChangeMode => this.inSetValueOne = value
                    })
                Text("${Int64(this.inSetValueOne)}").fontSize(12)
            }.width(80.percent)
            Row() {
                Slider(
                    value: this.inSetValueTwo,
                    step: 10.0,
                    style: SliderStyle.InSet
                )
                    .blockColor(0x191970)
                    .trackColor(0xADD8E6)
                    .selectedColor(0x4169E1)
                    .showSteps(true)
                    .onChange({
                        value: Float64, mode: SliderChangeMode => this.inSetValueTwo = value
                    })
                Text("${Int64(this.inSetValueTwo)}").fontSize(12)
            }.width(80.percent)

            Text('none slider').fontSize(9).fontColor(0xCCCCCC).width(90.percent).margin(15)
            Row() {
                Slider(
                    value: this.noneValueOne,
                    min: 0.0,
                    max: 100.0,
                    style: SliderStyle.OutSet
                )
                    .blockColor(0x191970)
                    .trackColor(0xADD8E6)
                    .selectedColor(0x4169E1)
                    .showTips(true)
                    .onChange({
                        value: Float64, mode: SliderChangeMode => this.noneValueOne = value
                    })
                Text("${Int64(this.noneValueOne)}").fontSize(12)
            }.width(80.percent)

            Row() {
                Column() {
                    Text('vertical outset slider').fontSize(9).fontColor(0xCCCCCC).width(50.percent).margin(15)
                    Row() {
                        Text("").width(10.percent)
                        Slider(
                            value: this.vOutSetValueOne,
                            style: SliderStyle.OutSet,
                            direction: Axis.Vertical
                        )
                            .blockColor(0x191970)
                            .trackColor(0xADD8E6)
                            .selectedColor(0x4169E1)
                            .showTips(true)
                            .onChange({
                                value: Float64, mode: SliderChangeMode => this.vOutSetValueOne = value
                            })
                        Slider(
                            value: this.vOutSetValueTwo,
                            step: 10.0,
                            style: SliderStyle.OutSet,
                            direction: Axis.Vertical
                        )
                            .blockColor(0x191970)
                            .trackColor(0xADD8E6)
                            .selectedColor(0x4169E1)
                            .showSteps(true)
                            .onChange({
                                value: Float64, mode: SliderChangeMode => this.vOutSetValueTwo = value
                            })
                    }
                }.width(50.percent).height(300)

                Column() {
                    Text('vertical inset slider').fontSize(9).fontColor(0xCCCCCC).width(50.percent).margin(15)
                    Row() {
                        Slider(
                            value: this.vInSetValueOne,
                            style: SliderStyle.InSet,
                            direction: Axis.Vertical,
                            reverse: true // 竖向的Slider默认是上端是min值，下端是max值，因此想要从下往上滑动，需要设置reverse为true
                        )
                            .showTips(true)
                            .onChange({
                                value: Float64, mode: SliderChangeMode => this.vInSetValueOne = value
                            })
                        Slider(
                            value: this.vInSetValueTwo,
                            step: 10.0,
                            style: SliderStyle.InSet,
                            direction: Axis.Vertical,
                            reverse: true
                        )
                            .showSteps(true)
                            .onChange({
                                value: Float64, mode: SliderChangeMode => this.vInSetValueTwo = value
                            })
                    }
                }.width(50.percent).height(300)
            }
        }.width(100.percent)
    }
}
```

![slider](figures/slider1.gif)
