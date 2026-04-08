# DatePicker

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

日期选择器组件，用于根据指定日期范围创建日期滑动选择器。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(?DateTime, ?DateTime, ?DateTime)

```cangjie
public init(
    start!: ?DateTime = None,
    end!: ?DateTime = None,
    selected!: ?DateTime = None
)
```

**功能：**  根据指定范围的DateTime创建可以选择日期的滑动选择器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

| 参数名      | 类型       | 必填  | 默认值                                                          | 说明                    |
|:-------- |:-------- |:--- |:------------------------------------------------------------ |:--------------------- |
| start    | ?[DateTime](../ImageKit/cj-apis-image.md#datetime) | 否   | None | **命名参数。** 指定选择器的起始日期。<br>初始值: DateTime.of(year: 1970, month: Month.of(1), dayOfMonth: 1)。|
| end      | ?[DateTime](../ImageKit/cj-apis-image.md#datetime) | 否   | None | **命名参数。** 指定选择器的结束日期。<br>初始值: DateTime.of(year: 2100, month: Month.of(12), dayOfMonth: 31)。|
| selected | ?[DateTime](../ImageKit/cj-apis-image.md#datetime) | 否   | None | **命名参数。** 设置选中项的日期。<br>初始值: DateTime.now()。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func disappearTextStyle(?PickerTextStyle)

```cangjie
public func disappearTextStyle(value: ?PickerTextStyle): This
```

**功能：** 设置过渡项（以选中项为基准向上或向下的第二项）的文本样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

| 参数名   | 类型 | 必填  | 默认值 | 说明|
|:----- |:----------------------------------------------------------------------- |:--- |:--- |:---------------------------------------------------------------------------------------------- |
| value | ?[PickerTextStyle](./cj-common-types.md#class-pickertextstyle)| 是   | -   | 过渡项的文本颜色、字号、字体粗细。<br>初始值：{color: '#ff182431',font: {size: '14.fp', weight: FontWeight.Regular, family: 'HarmonyOS Sans', style: FontStyle.Normal}}。|

### func lunar(?Bool)

```cangjie
public func lunar(value: ?Bool): This
```

**功能：** 设置弹窗的日期是否显示农历。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

| 参数名   | 类型   | 必填  | 默认值 | 说明                                                            |
|:----- |:---- |:--- |:--- |:------------------------------------------------------------- |
| value | ?Bool | 是   | -   | 日期是否显示农历。<br/> - true：展示农历。<br/> - false：不展示农历。<br>初始值: false。|

### func selectedTextStyle(?PickerTextStyle)

```cangjie
public func selectedTextStyle(value: ?PickerTextStyle): This
```

**功能：**设置选中项的文本样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

| 参数名   | 类型                                                                      | 必填  | 默认值 | 说明                                                                                 |
|:----- |:----------------------------------------------------------------------- |:--- |:--- |:---------------------------------------------------------------------------------- |
| value |?[PickerTextStyle](./cj-common-types.md#class-pickertextstyle) | 是   | -   | 文本样式值，<br>初始值：{color: '#ff007dff',font: {size: '20fp', weight: FontWeight.Medium, family: 'HarmonyOS Sans', style: FontStyle.Normal}}。|

### func textStyle(?PickerTextStyle)

```cangjie
public func textStyle(value: ?PickerTextStyle): This
```

**功能：** 设置一般项（以选中项为基准向上或向下的第一项）的文本样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

| 参数名   | 类型                                                                      | 必填  | 默认值 | 说明                                                                                             |
|:----- |:----------------------------------------------------------------------- |:--- |:--- |:---------------------------------------------------------------------------------------------- |
| value | ?[PickerTextStyle](./cj-common-types.md#class-pickertextstyle) | 是   | -   | 一般项的文本颜色、字号、字体粗细。<br>初始值：{color: '#ff182431',font: {size: '16.fp', weight: FontWeight.Regular, family: 'HarmonyOS Sans', style: FontStyle.Normal}}。|

## 组件事件

### func onDateChange(?Callback\<DateTime,Unit>)

```cangjie
public func onDateChange(callback: ?Callback<DateTime, Unit>): This
```

**功能：** 选择日期时触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

| 参数名      | 类型                                                                                                                                       | 必填  | 默认值 | 说明                                      |
|:-------- |:---------------------------------------------------------------------------------------------------------------------------------------- |:--- |:--- |:--------------------------------------- |
| callback | ?[Callback](./cj-common-types.md#type-callbackt-v)\<[DateTime](../ImageKit/cj-apis-image.md#datetime),Unit> | 是   | -   | 返回选中的时间，年月日为选中的日期，时分取决于当前系统时间的时分，秒恒为00。<br>初始值: { _ => } |

## 基础类型定义

### class DatePickerResult

```cangjie
public class DatePickerResult {
    public var year: Int64
    public var month: Int64
    public var day: Int64
    public init(
        year: Int64,
        month: Int64,
        day: Int64
    )
}
```

**功能：** 记录日期选择器弹窗的选择结果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var year

```cangjie
public var year: Int64
```

**功能：** 选中日期的年。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var month

```cangjie
public var month: Int64
```

**功能：** 选中日期的月。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var day

```cangjie
public var day: Int64
```

**功能：** 选中日期的日。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(Int64, Int64, Int64)

```cangjie
public init(
    year: Int64,
    month: Int64,
    day: Int64
)
```

**功能：** 记录日期选择器弹窗的选择结果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

| 参数名   | 类型    | 必填  | 默认值 | 说明                           |
|:----- |:----- |:--- |:--- |:---------------------------- |
| year  | Int64 | 是   | -   | 选中日期的年。                      |
| month | Int64 | 是   | -   | 选中日期的月。(0~11)，0表示1月，11表示12月。 |
| day   | Int64 | 是   | -   | 选中日期的日。                      |

## 示例代码

该示例实现了日期选择器组件，点击按钮可以切换公历农历。

<!-- run -->

```cangjie

package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.hilog.*
import ohos.arkui.state_macro_manage.*
import std.time.DateTime
import std.time.Month
import ohos.arkui.component.common.Font as CommonFont

@Entry
@Component
class EntryView {
    @State var isLunar: Bool = false
    @State var selectedDate: DateTime = DateTime.of(year: 2024, month: Month.of(4), dayOfMonth: 28)
    @State var resultedDate: DateTime = DateTime.of(year: 2024, month: Month.of(4), dayOfMonth: 28)

    func build() {
        Column() {
            Button("Switch Gregorian/lunar calendars")
                .backgroundColor(0x2788D9)
                .onClick({
                    event => this.isLunar = !this.isLunar
                })
                .width(200.vp)

            DatePicker(
                start: DateTime.of(year: 2012, month: Month.of(8), dayOfMonth: 8),
                end: DateTime.of(year: 2045, month: Month.of(8), dayOfMonth: 8),
                selected: this.selectedDate
            )
                .disappearTextStyle(PickerTextStyle(color: Color.Gray, font: CommonFont(size: 16.fp, weight: FontWeight.Bold)))
                .textStyle(PickerTextStyle(color: 0xff182431, font: CommonFont(size: 18.fp, weight: FontWeight.Normal)))
                .selectedTextStyle(PickerTextStyle(color: 0xff0000FF, font: CommonFont(size: 26.fp, weight: FontWeight.Regular)))
                .lunar(this.isLunar)
                .onDateChange(
                    { res =>
                        this.resultedDate = DateTime.of(year: res.year, month: res.month, dayOfMonth: res.dayOfMonth)
                        Hilog.info(0, "AppLogCj", "select current date is: " + res.year.toString() + "-" + res.month.toString() + "-" +
                        res.dayOfMonth.toString(), "")
                })
                .margin(top: 30)
        }.width(100.percent)
    }
}
```

![datepicker_cj](./figures/datepicker.gif)
