# SideBarContainer

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

提供可以显示和隐藏的侧边栏容器，通过子组件定义侧边栏和内容区，第一个子组件表示侧边栏，第二个子组件表示内容区。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

可以包含子组件。

> **说明：**
>
> - 子组件类型：系统组件和自定义组件，不支持渲染控制类型（[if/else](../../arkui-cj/rendering_control/cj-rendering-control-ifelse.md)、[ForEach](cj-state-rendering-foreach.md)、[LazyForEach](cj-state-rendering-lazyforeach.md)）。
> - 子组件个数：必须且仅包含2个子组件。
> - 子组件个数异常时：3个或以上子组件，显示第一个和第二个。1个子组件，显示侧边栏，内容区为空白。

## 创建组件

### init(?SideBarContainerType, () -> Unit)

```cangjie
public init(sideBarType!: ?SideBarContainerType = None, child!: () -> Unit = {=>})
```

**功能：** 创建一个侧边栏容器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|sideBarType|?[SideBarContainerType](./cj-common-types.md#enum-sidebarcontainertype)|否|None| **命名参数。** 设置侧边栏的显示类型。<br>初始值：SideBarContainerType.Embed。|
|child|() -> Unit|否|{=>}| **命名参数。** 定义侧边栏和内容区。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func autoHide(?Bool)

```cangjie
public func autoHide(value: ?Bool): This
```

**功能：** 设置当侧边栏拖拽到小于最小宽度后，是否自动隐藏。

> **说明：**
>
> - 受[minSideBarWidth](#func-minsidebarwidthlength)属性方法影响，当该属性方法未设置值时使用初始值。
> - 拖拽过程中判断是否要自动隐藏。小于最小宽度时需要阻尼效果触发隐藏（越界一段距离）。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|侧边栏拖拽到小于最小宽度后，是否自动隐藏。<br>true：会自动隐藏。<br>false：不会自动隐藏。<br>初始值：true。|

### func controlButton(?ButtonStyle)

```cangjie
public func controlButton(value: ?ButtonStyle): This
```

**功能：** 设置侧边栏控制按钮的属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ButtonStyle](#class-buttonstyle)|是|-|侧边栏控制按钮的属性。|

### func divider(?DividerStyle)

```cangjie
public func divider(value: ?DividerStyle): This
```

**功能：** 设置分割线的样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[DividerStyle](#class-dividerstyle)|是|-|分割线的样式，默认显示分割线。<br>初始值：DividerStyle(strokeWidth: 1.vp)|

### func maxSideBarWidth(?Length)

```cangjie
public func maxSideBarWidth(value: ?Length): This
```

**功能：** 设置侧边栏最大宽度。

> **说明：**
>
> - 设置为小于0的值时按默认值显示。值不能超过侧边栏容器本身宽度，超过使用侧边栏容器本身宽度。
> - maxSideBarWidth优先于侧边栏子组件maxWidth，maxSideBarWidth未设置时默认值优先级高于侧边栏子组件maxWidth。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|设置侧边栏最大宽度。<br>单位：vp。<br>初始值：280.vp。|

### func minContentWidth(?Length)

```cangjie
public func minContentWidth(value: ?Length): This
```

**功能：** 设置SideBarContainer组件内容区可显示的最小宽度。

> **说明：**
>
> - 当最小宽度设置为小于0，内容区显示的最小宽度为360.vp；未设置该属性时，组件内容区的可缩小到0。
> - Embed场景下，增大组件尺寸时仅增大内容区的尺寸。
> - 缩小组件尺寸时，先缩小内容区的尺寸至minContentWidth。继续缩小组件尺寸时，保持内容区宽度minContentWidth不变，优先缩小侧边栏的尺寸。当缩小侧边栏的尺寸至minSideBarWidth后，继续缩小组件尺寸时：
>
>     - 如果autoHide属性为false，则会保持侧边栏宽度minSideBarWidth和内容区宽度minContentWidth不变，但内容区会被截断显示；
>     - 如果autoHide属性为true，则会优先隐藏侧边栏，然后继续缩小至内容区宽度minContentWidth后，内容区宽度保持不变，但内容区会被截断显示。
>
> - minContentWidth优先于侧边栏的[maxSideBarWidth](#func-maxsidebarwidthlength)与[sideBarWidth](#func-sidebarwidthlength)属性，minContentWidth未设置时，默认值优先级低于设置的[minSideBarWidth](#func-minsidebarwidthlength)与[maxSideBarWidth](#func-maxsidebarwidthlength)属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|SideBarContainer组件内容区可显示的最小宽度。<br>单位：vp。<br>初始值：360.vp。|

### func minSideBarWidth(?Length)

```cangjie
public func minSideBarWidth(value: ?Length): This
```

**功能：** 设置侧边栏最小宽度。

> **说明：**
>
> - 设置为小于0的值时按默认值显示。值不能超过侧边栏容器本身宽度，超过使用侧边栏容器本身宽度。
> - minSideBarWidth优先于侧边栏子组件minWidth，minSideBarWidth未设置时默认值优先级高于侧边栏子组件minWidth。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|侧边栏最小宽度。<br>初始值：240.vp。|

### func showControlButton(?Bool)

```cangjie
public func showControlButton(value: ?Bool): This
```

**功能：** 设置是否显示控制按钮。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|是否显示控制按钮。<br>true：显示控制按钮。<br>false：不显示控制按钮。<br>初始值：true。|

### func showSideBar(?Bool)

```cangjie
public func showSideBar(value: ?Bool): This
```

**功能：** 设置是否显示侧边栏。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|是否显示侧边栏。<br>true：显示侧边栏。<br>false：不显示侧边栏。<br>初始值：true。|

### func sideBarPosition(?SideBarPosition)

```cangjie
public func sideBarPosition(value: ?SideBarPosition): This
```

**功能：** 设置侧边栏显示位置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[SideBarPosition](./cj-common-types.md#enum-sidebarposition)|是|-|侧边栏显示位置。<br>初始值：SideBarPosition.Start。|

### func sideBarWidth(?Length)

```cangjie
public func sideBarWidth(value: ?Length): This
```

**功能：** 设置侧边栏的宽度。

> **说明：**
>
> 设置为小于0的值时按默认值显示。受最小宽度和最大宽度限制，不在限制区域内取最近的点。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|侧边栏的宽度。<br>单位：vp。<br>初始值：240.vp。|

## 组件事件

### func onChange(?(Bool) -> Unit)

```cangjie
public func onChange(callback: ?(Bool) -> Unit): This
```

**功能：** 当侧边栏的状态在显示和隐藏之间切换时触发该事件。

> **说明：**
>
> 满足以下任意条件时触发该事件：
>
> - [showSideBar](#func-showsidebarbool)属性值变换时。
> - [showSideBar](#func-showsidebarbool)属性自适应行为变化时。
> - 分割线拖拽触发[autoHide](#func-autohidebool)时。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?(Bool)->Unit|是|-|回调函数，当侧边栏的状态由隐藏变为显示时，参数值为true；当侧边栏的状态由显示变为隐藏时，参数值为false。<br>初始值：{ _ => }。|

## 基础类型定义

### class ButtonIconOptions

```cangjie
public class ButtonIconOptions {
    public var shown: ?ResourceStr
    public var hidden: ?ResourceStr
    public var switching: ?ResourceStr
    public init(shown!: ?ResourceStr, hidden!: ?ResourceStr, switching!: ?ResourceStr = None)
}
```

**功能：** 表示图标类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var shown

```cangjie
public var shown: ?ResourceStr
```

**功能：** 侧边栏显示时控制按钮的图标。

**类型：** ?[ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var hidden

```cangjie
public var hidden: ?ResourceStr
```

**功能：** 侧边栏隐藏时控制按钮的图标。

**类型：** ?[ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var switching

```cangjie
public var switching: ?ResourceStr
```

**功能：** 侧边栏显示和隐藏状态切换时控制按钮的图标。

**类型：** ?[ResourceStr](./cj-common-types.md#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?ResourceStr, ?ResourceStr, ?ResourceStr)

```cangjie
public init(shown!: ?ResourceStr, hidden!: ?ResourceStr, switching!: ?ResourceStr = None)
```

**功能：** 构造 ButtonIconOptions对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|shown|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|**命名参数。** 设置侧边栏显示时控制按钮的图标。|
|hidden|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|**命名参数。** 设置侧边栏隐藏时控制按钮的图标。|
|switching|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None|**命名参数。** 设置侧边栏显示和隐藏状态切换时控制按钮的图标。<br>初始值：""|

### class ButtonStyle

```cangjie
public class ButtonStyle {
    public var left: ?Float64
    public var top: ?Float64
    public var width: ?Float64
    public var height: ?Float64
    public var icons: ?ButtonIconOptions
    public init(
        left!: ?Float64 = None,
        top!: ?Float64 = None,
        width!: ?Float64 = None,
        height!: ?Float64 = None,
        icons!: ?ButtonIconOptions = None
    )
}
```

**功能：** 侧边栏控制按钮属性类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var left

```cangjie
public var left: ?Float64
```

**功能：** 设置侧边栏控制按钮距离容器左界限的间距。<br>单位：vp。

**类型：** ?Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var top

```cangjie
public var top: ?Float64
```

**功能：** 设置侧边栏控制按钮距离容器上界限的间距。<br>单位：vp。

**类型：** ?Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var width

```cangjie
public var width: ?Float64
```

**功能：** 设置侧边栏控制按钮的宽度。<br>单位：vp。

**类型：** ?Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var height

```cangjie
public var height: ?Float64
```

**功能：** 设置侧边栏控制按钮的高度。<br>单位：vp。

**类型：** ?Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var icons

```cangjie
public var icons: ?ButtonIconOptions
```

**功能：** 设置侧边栏控制按钮的图标。

**类型：** ?[ButtonIconOptions](#class-buttoniconoptions)

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**读写能力：** 可读写

**起始版本：** 22

#### init(?Float64, ?Float64, ?Float64, ?Float64, ?ButtonIconOptions)

```cangjie
public init(
    left!: ?Float64 = None,
    top!: ?Float64 = None,
    width!: ?Float64 = None,
    height!: ?Float64 = None,
    icons!: ?ButtonIconOptions = None
)
```

**功能：** 构造ButtonStyle对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|left|?Float64|否|None|**命名参数。** 设置侧边栏控制按钮距离容器左界限的间距。<br>单位：vp。<br>初始值：16.0。|
|top|?Float64|否|None|**命名参数。** 设置侧边栏控制按钮距离容器上界限的间距。<br>单位：vp。<br>初始值：48.0。|
|width|?Float64|否|None|**命名参数。** 设置侧边栏控制按钮的宽度。<br>单位：vp。<br>初始值：24.0。|
|height|?Float64|否|None|**命名参数。** 设置侧边栏控制按钮的高度。<br>单位：vp。<br>初始值：24.0。|
|icons|?[ButtonIconOptions](#class-buttoniconoptions)|否|None|**命名参数。** 设置侧边栏控制按钮的图标。<br>初始值：ButtonIconOptions(shown: "", hidden: "")。|

### class DividerStyle

```cangjie
public class DividerStyle {
    public var strokeWidth: ?Length
    public var color: ?ResourceColor
    public var startMargin: ?Length
    public var endMargin: ?Length
    public init(strokeWidth!: ?Length, color!: ?ResourceColor = None, startMargin!: ?Length = None,
        endMargin!: ?Length = None)
}
```

**功能：** SideBar分割线样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

> **说明：**
>
> 针对侧边栏内容区设置[通用属性宽高](./cj-universal-attribute-size.md)时，宽高都不生效，默认占满SideBarContainer的剩余空间。
> 当showSideBar属性未设置时，依据组件大小进行自动显示：
>
> - 小于minSideBarWidth + minContentWidth：默认不显示侧边栏。
> - 大于等于minSideBarWidth + minContentWidth：默认显示侧边栏。

#### var strokeWidth

```cangjie
public var strokeWidth: ?Length
```

**功能：** 分割线的线宽。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var color

```cangjie
public var color: ?ResourceColor
```

**功能：** 分割线的颜色。

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var startMargin

```cangjie
public var startMargin: ?Length
```

**功能：** 分割线与侧边栏顶端的距离。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var endMargin

```cangjie
public var endMargin: ?Length
```

**功能：** 分割线与侧边栏底端的距离。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?Length, ?ResourceColor, ?Length, ?Length)

```cangjie
public init(strokeWidth!: ?Length, color!: ?ResourceColor = None, startMargin!: ?Length = None,
    endMargin!: ?Length = None)
```

**功能：** 构造DividerStyle对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|strokeWidth|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 分割线的线宽。<br>初始值：1.vp。|
|color|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|None|**命名参数。** 分割线的颜色。<br>初始值：0x08000000。|
|startMargin|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 分割线与侧边栏顶端的距离。<br>初始值：0.vp。|
|endMargin|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 分割线与侧边栏底端的距离。<br>初始值：0.vp。|

## 示例代码

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_management.*
import ohos.arkui.state_macro_manage.*
import ohos.i18n.*
import ohos.resource_manager.*
import ohos.resource.__GenerateResource__

@Entry
@Component
class EntryView {
    @State var arr: Array<Int64> = [1, 2, 3]
    @State var current: Int64 = 1
    var normalIcon: AppResource = @r(app.media.startIcon)
    let ctrlButton: ButtonStyle = ButtonStyle(left: 17.0, top: 49.0, width: 20.0, height: 31.0,
        icons: ButtonIconOptions(shown: "", hidden: "", switching: ""))
    func build() {
        SideBarContainer() {
            Column() {
                ForEach(
                    this.arr,
                    itemGeneratorFunc: {
                        item: Int64, idx: Int64 => Column() {
                            Image(this.normalIcon)
                                .width(50)
                                .height(50)
                            Text("Index${item}")
                                .fontSize(25)
                                .fontColor(0x0A59F7)
                                .fontFamily("source-sans-pro,cursive,sans-serif")
                        }.onClick({
                            event => this.current = idx
                        })
                    }
                )
            }
                .width(100.percent)
                .justifyContent(FlexAlign.SpaceEvenly)
                .backgroundColor(0x19000000)
            Column() {
                Text('SideBarContainer content text1')
                    .fontSize(20)
                Text('SideBarContainer content text2')
                    .fontSize(20)
            }
        }
            .id("SideBarDefault")
            .showSideBar(true)
            .showControlButton(true)
            .showControlButton(true)
            .autoHide(false)
            .sideBarWidth(150.vp)
            .minSideBarWidth(50.vp)
            .maxSideBarWidth(300.vp)
            .minContentWidth(1.vp)
            .sideBarPosition(SideBarPosition.Start)
            .controlButton(ctrlButton)
            .width(90.percent)
            .height(85.percent)
    }
}
```

![SideBarContainer](./figures/sidebarcontainer.gif)
