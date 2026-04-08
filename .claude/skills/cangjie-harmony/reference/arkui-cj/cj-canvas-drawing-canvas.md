# Canvas

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

提供画布组件，用于自定义绘制图形。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

不支持子组件。

## 创建组件

### init(?CanvasRenderingContext2D)

```cangjie
public init(context: ?CanvasRenderingContext2D)
```

**功能：** 构造一个Canvas组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|?[CanvasRenderingContext2D](./cj-canvas-drawing-canvasrenderingcontext2d.md#class-canvasrenderingcontext2d)|是|-|Canvas上下文对象。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件事件

### func onReady(?() -> Unit)

```cangjie
public func onReady(callback: ?() -> Unit): This
```

**功能：** Canvas组件构造完成后的事件通知。此时可以开始绘制Canvas。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?() -> Unit|是|-|事件回调。<br>初始值：{ => }。|

## 基础类型定义

### class RenderingContextSettings

```cangjie
public class RenderingContextSettings {
    public var antialias: ?Bool
    public init(antialias!: ?Bool = None)
}
```

**功能：** 用于创建渲染上下文时设置相关属性的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var antialias

```cangjie
public var antialias: ?Bool
```

**功能：** 表示Canvas是否启用抗锯齿功能，默认值为false。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?Bool)

```cangjie
public init(antialias!: ?Bool = None)
```

**功能：** 根据抗锯齿参数创建一个RenderingContextSettings对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|antialias|?Bool|否|None|**命名参数。** 是否启用抗锯齿。|

### class TextMetrics

```cangjie
public class TextMetrics {
    public let width: Float64
    public let height: Float64
}
```

**功能：** 文本的尺寸信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### let width

```cangjie
public let width: Float64
```

**功能：** 字符串的宽度，类型为double。

**类型：** Float64

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### let height

```cangjie
public let height: Float64
```

**功能：** 字符串的高度，类型为double。

**类型：** Float64

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### class CanvasGradient

```cangjie
public class CanvasGradient {}
```

**功能：** 描述渐变的不透明对象，由createLinearGradient()或createRadialGradient()创建。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### func addColorStop(Float64, ?ResourceColor)

```cangjie
public func addColorStop(offset: Float64, color: ?ResourceColor): Unit
```

**功能：** 向渐变中添加由偏移量和颜色定义的断点。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|offset|Float64|是|-|0到1之间的值，超出范围会抛出INDEX_SIZE_ERR错误。|
|color|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|设置渐变颜色。|

## 示例代码

### 示例1（使用CanvasRenderingContext2D中的方法）

该示例实现了如何在Canvas组件使用CanvasRenderingContext2D中的方法进行绘制。

<!-- run -->

```cangjie

package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    var settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    var context: CanvasRenderingContext2D = CanvasRenderingContext2D(this.settings)

    func build() {
        Flex(direction: FlexDirection.Column, alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.Center) {
            Canvas(this.context).width(100.percent).height(100.percent).backgroundColor(0xffff00).onReady(
                {
                => this.context.fillRect(0.0, 30.0, 100.0, 100.0)
            })
        }.width(100.percent).height(100.percent)
    }
}
```

![canvas](./figures/drawingCanvas.PNG)
