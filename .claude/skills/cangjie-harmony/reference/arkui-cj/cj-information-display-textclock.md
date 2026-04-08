# TextClock

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

TextClock 组件通过文本将当前系统时间显示在设备上。支持不同时区的时间显示，最高精度到秒级。

在组件不可见时时间变动将停止，组件的可见状态基于[onVisibleAreaChange](./cj-universal-event-visibleareachange.md#func-onvisibleareachangearrayfloat64-bool-float64---unit)处理，可见阈值ratios大于0即视为可见状态。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(?Float32, ?TextClockController)

```cangjie
public init(timeZoneOffset!: ?Float32 = None, controller!: ?TextClockController = None)
```

**功能：** 创建一个包含时区偏移和控制器的TextClock对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|timeZoneOffset|?Float32|否|None| **命名参数。** 时区偏移。|
|controller|?[TextClockController](#class-textclockcontroller)|否|None| **命名参数。** TextClock组件的控制器。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func fontColor(?ResourceColor)

```cangjie
public func fontColor(value: ?ResourceColor): This
```

**功能：** 设置文本的颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|文本的颜色。|

### func fontFamily(?ResourceStr)

```cangjie
public func fontFamily(value: ?ResourceStr): This
```

**功能：** 设置文本的字体族。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|文本的字体族。<br>初始值："HarmonyOS Sans"。|

### func fontSize(?Length)

```cangjie
public func fontSize(value: ?Length): This
```

**功能：** 设置文本的字体大小。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|文本的字体大小。<br>初始值：16.0.fp。|

### func fontStyle(?FontStyle)

```cangjie
public func fontStyle(value: ?FontStyle): This
```

**功能：** 设置文本的字体样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[FontStyle](./cj-common-types.md#enum-fontstyle)|是|-|文本的字体样式。<br>初始值：FontStyle.Normal。|

### func fontWeight(?FontWeight)

```cangjie
public func fontWeight(value: ?FontWeight): This
```

**功能：** 设置文本的字体粗细。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[FontWeight](./cj-common-types.md#enum-fontweight)|是|-|文本的字体粗细。<br>初始值：FontWeight.Normal。|

### func format(?ResourceStr)

```cangjie
public func format(value: ?ResourceStr): This
```

**功能：** 设置显示时间格式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|时间格式字符串。初始值：""。|

### func textShadow(?Array\<ShadowOptions>)

```cangjie
public func textShadow(values: ?Array<ShadowOptions>): This
```

**功能：** 设置文本阴影效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|values|?Array\<[ShadowOptions](./cj-common-types.md#class-shadowoptions)>|是|-|阴影选项数组。|

### func textShadow(?ShadowOptions)

```cangjie
public func textShadow(value: ?ShadowOptions): This
```

**功能：** 设置文本阴影效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ShadowOptions](./cj-common-types.md#class-shadowoptions)|是|-|阴影选项。|

## 组件事件

### func onDateChange(?(Int64) -> Unit)

```cangjie
public func onDateChange(callback: ?(Int64) -> Unit): This
```

**功能：** 提供日期变化回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?(Int64) -> Unit|是|-|日期变化时的回调函数。初始值：{ _ => }|

## 基础类型定义

### class DateTimeOptions

```cangjie
public class DateTimeOptions {
    public var locale: ?String
    public var dateStyle: ?String
    public var timeStyle: ?String
    public var hourCycle: ?String
    public var timeZone: ?String
    public var numberingSystem: ?String
    public var hour12: ?Bool
    public var weekday: ?String
    public var era: ?String
    public var year: ?String
    public var month: ?String
    public var day: ?String
    public var hour: ?String
    public var minute: ?String
    public var second: ?String
    public var timeZoneName: ?String
    public var dayPeriod: ?String
    public var localeMatcher: ?String
    public var formatMatcher: ?String
    public init(locale!: ?String = None, dateStyle!: ?String = None, timeStyle!: ?String = None,
    hourCycle!: ?String = None, timeZone!: ?String = None, numberingSystem!: ?String = None, hour12!: ?Bool = None,
    weekday!: ?String = None, era!: ?String = None, year!: ?String = None, month!: ?String = None,
    day!: ?String = None, hour!: ?String = None, minute!: ?String = None, second!: ?String = None,
    timeZoneName!: ?String = None, dayPeriod!: ?String = None, localeMatcher!: ?String = None,
    formatMatcher!: ?String = None)
}
```

**功能：** 定义DateTimeOptions对象的选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var dateStyle

```cangjie
public var dateStyle: ?String
```

**功能：** 日期显示格式。值可以是："long"、"short"、"medium"、"full"或"auto"。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var day

```cangjie
public var day: ?String
```

**功能：** 天显示格式。值可以是："numeric"或"2-digit"。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var dayPeriod

```cangjie
public var dayPeriod: ?String
```

**功能：** 时间段显示格式。值可以是："long"、"short"、"narrow"或"auto"。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var era

```cangjie
public var era: ?String
```

**功能：** 纪元显示格式。值可以是："long"、"short"、"narrow"或"auto"。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var formatMatcher

```cangjie
public var formatMatcher: ?String
```

**功能：** 格式匹配算法。值可以是："basic"（精确匹配）或"best fit"（最佳匹配）。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var hour

```cangjie
public var hour: ?String
```

**功能：** 小时显示格式。值可以是："numeric"或"2-digit"。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var hour12

```cangjie
public var hour12: ?Bool
```

**功能：** 是否使用12小时制。值true表示使用12小时制，false表示相反。如果同时设置了hour12和hourCycle，则hourCycle不生效。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var hourCycle

```cangjie
public var hourCycle: ?String
```

**功能：** 小时周期。值可以是："h11"、"h12"、"h23"或"h24"。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var locale

```cangjie
public var locale: ?String
```

**功能：** 有效的区域设置ID，例如"zh-Hans-CN"。默认值为当前系统区域设置。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var localeMatcher

```cangjie
public var localeMatcher: ?String
```

**功能：** 区域设置匹配算法。值可以是："lookup"（精确匹配）或"best fit"（最佳匹配）。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var minute

```cangjie
public var minute: ?String
```

**功能：** 分钟显示格式。值可以是："numeric"或"2-digit"。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var month

```cangjie
public var month: ?String
```

**功能：** 月份显示格式。值可以是："numeric"、"2-digit"、"long"、"short"、"narrow"或"auto"。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var numberingSystem

```cangjie
public var numberingSystem: ?String
```

**功能：** 数字系统。值可以是："adlm"、"ahom"、"arab"、"arabext"、"bali"、"beng"、"bhks"、"brah"、"cakm"、"cham"、"deva"、"diak"、"fullwide"、"gong"、"gonm"、"gujr"、"guru"、"hanidec"、"hmng"、"hmnp"、"java"、"kali"、"khmr"、"knda"、"lana"、"lanatham"、"laoo"、"latn"、"lepc"、"limb"、"mathbold"、"mathdbl"、"mathmono"、"mathsanb"、"mathsans"、"mlym"、"modi"、"mong"、"mroo"、"mtei"、"mymr"、"mymrshan"、"mymrtlng"、"newa"、"nkoo"、"olck"、"orya"、"osma"、"rohg"、"saur"、"segment"、"shrd"、"sind"、"sinh"、"sora"、"sund"、"takr"、"talu"、"tamldec"、"telu"、"thai"、"tibt"、"tirh"、"vaii"、"wara"或"wcho"。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var second

```cangjie
public var second: ?String
```

**功能：** 秒显示格式。值可以是："numeric"或"2-digit"。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var timeStyle

```cangjie
public var timeStyle: ?String
```

**功能：** 时间显示格式。值可以是："long"、"short"、"medium"、"full"或"auto"。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var timeZone

```cangjie
public var timeZone: ?String
```

**功能：** 使用的时区。值是有效的IANA时区ID。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var timeZoneName

```cangjie
public var timeZoneName: ?String
```

**功能：** 时区名称的本地化表示。值可以是："long"、"short"或"auto"。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var weekday

```cangjie
public var weekday: ?String
```

**功能：** 星期显示格式。值可以是："long"、"short"、"narrow"或"auto"。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var year

```cangjie
public var year: ?String
```

**功能：** 年份显示格式。值可以是："numeric"或"2-digit"。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?String, ?String, ?String, ?String, ?String, ?String, ?Bool, ?String, ?String, ?String, ?String, ?String, ?String, ?String, ?String, ?String, ?String, ?String, ?String)

```cangjie
public init(locale!: ?String = None, dateStyle!: ?String = None, timeStyle!: ?String = None,
    hourCycle!: ?String = None, timeZone!: ?String = None, numberingSystem!: ?String = None, hour12!: ?Bool = None,
    weekday!: ?String = None, era!: ?String = None, year!: ?String = None, month!: ?String = None,
    day!: ?String = None, hour!: ?String = None, minute!: ?String = None, second!: ?String = None,
    timeZoneName!: ?String = None, dayPeriod!: ?String = None, localeMatcher!: ?String = None,
    formatMatcher!: ?String = None)
```

**功能：** DateTimeOptions的构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|locale|?String|否|None| **命名参数。** 区域设置ID。初始值："zh-Hans-CN"。|
|dateStyle|?String|否|None| **命名参数。** 日期显示格式。初始值："long"。|
|timeStyle|?String|否|None| **命名参数。** 时间显示格式。初始值："long"。|
|hourCycle|?String|否|None| **命名参数。** 小时周期。初始值："h11"。|
|timeZone|?String|否|None| **命名参数。** 时区。初始值：""。|
|numberingSystem|?String|否|None| **命名参数。** 数字系统。初始值："adlm"。|
|hour12|?Bool|否|None| **命名参数。** 是否使用12小时制。初始值：false。|
|weekday|?String|否|None| **命名参数。** 星期显示格式。初始值："long"。|
|era|?String|否|None| **命名参数。** 纪元显示格式。初始值："long"。|
|year|?String|否|None| **命名参数。** 年份显示格式。初始值："numeric"。|
|month|?String|否|None| **命名参数。** 月份显示格式。初始值："numeric"。|
|day|?String|否|None| **命名参数。** 天显示格式。初始值："numeric"。|
|hour|?String|否|None| **命名参数。** 小时显示格式。初始值："numeric"。|
|minute|?String|否|None| **命名参数。** 分钟显示格式。初始值："numeric"。|
|second|?String|否|None| **命名参数。** 秒显示格式。初始值："numeric"。|
|timeZoneName|?String|否|None| **命名参数。** 时区名称显示格式。初始值："long"。|
|dayPeriod|?String|否|None| **命名参数。** 时间段显示格式初始值："long"。|
|localeMatcher|?String|否|None| **命名参数。** 区域设置匹配算法。初始值："lookup"。|
|formatMatcher|?String|否|None| **命名参数。** 格式匹配算法。初始值："basic"。|

### class TextClockController

```cangjie
public class TextClockController  {
    public init()
}
```

**功能：** TextClockController是TextClock组件的控制器，可以定义该类型的对象并绑定至TextClock组件，实现对TextClock组件的控制。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init()

```cangjie
public init()
```

**功能：** TextClockController的构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### func start()

```cangjie
public func start(): Unit
```

**功能：** 启动TextClock组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### func stop()

```cangjie
public func stop(): Unit
```

**功能：** 停止TextClock组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## 示例代码

### 示例1（设定文本阴影样式）

该示例通过textShadow属性设置文本时钟的文本阴影样式。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State
    var shadowoptions: Array<ShadowOptions> = [
        ShadowOptions(radius: 10.0, shadowType: ShadowType.Blur, offsetX: 10.0, offsetY: 0.0, color: 0xffff0000,
            fill: false),
        ShadowOptions(radius: 10.0, shadowType: ShadowType.Blur, offsetX: 20.0, offsetY: 0.0, color: 0xff000000,
            fill: false),
        ShadowOptions(radius: 10.0, shadowType: ShadowType.Blur, offsetX: 30.0, offsetY: 0.0, color: 0xffc0c0c0,
            fill: false),
        ShadowOptions(radius: 10.0, shadowType: ShadowType.Blur, offsetX: 40.0, offsetY: 0.0, color: 0xff00ff00,
            fill: false),
        ShadowOptions(radius: 10.0, shadowType: ShadowType.Blur, offsetX: 100.0, offsetY: 0.0, color: 0xff0000ff,
            fill: false)
    ]
    public func build() {
        Column {
            TextClock().fontSize(50).textShadow(shadowoptions)
        }
    }
}
```

![text_clock1](figures/text_clock1.gif)

### 示例2（支持启停的文本样式时钟）

该示例展示了TextClock组件的基本使用方法，通过format属性设置时钟文本的格式。

点击"start TextClock"按钮，按钮回调函数会调用TextClockController启动文本时钟。点击"stop TextClock"按钮，会调用TextClockController暂停文本时钟。

示例中的组件通过设置onDateChange回调函数，在文本时钟更新时，持续修改accumulateTime的内容。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State
    var accumulateTime: Int64 = 0
    let controller = TextClockController()
    public func build() {
        Column {
            Text('Current milliseconds is ${this.accumulateTime}').fontSize(20).margin(10)
            // 以12小时制显示东八区的系统时间，精确到秒。
            TextClock(timeZoneOffset: -8.0, controller: this.controller)
                .format('aa hh:mm:ss')
                .onDateChange({
                    value: Int64 => this.accumulateTime = value
                })
                .margin(20)
                .fontSize(30)
            Button("start TextClock").margin(bottom: 10).onClick({
                evt =>
                // 启动文本时钟
                this.controller.start()
            })
            Button("stop TextClock").onClick({
                evt =>
                // 停止文本时钟
                this.controller.stop()
            })
        }
    }
}
```

![text_clock2](figures/text_clock2.gif)