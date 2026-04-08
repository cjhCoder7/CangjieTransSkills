# TextPicker

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

滑动选择文本内容的组件。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(?Array\<String>, ?UInt32, ?String)

```cangjie
public init(
    range!: ?Array<String>,
    selected!: ?UInt32 = Option.None,
    value!: ?String = Option.None
)
```

**功能：** 根据range指定的选择范围创建文本选择器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|range|?Array\<String>|是|-|**命名参数。** 选择器的数据选择列表。|
|selected|?UInt32|否|Option.None| **命名参数。** 设置默认选中项在数组中的索引值。<br>初始值：0。|
|value|?String|否|Option.None| **命名参数。** 设置默认选中项的值，优先级低于selected。<br>初始值：第一个元素值。<br>**说明**：只有显示文本列表时该值有效。显示图片或图片加文本的列表时，该值无效。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func canLoop(?Bool)

```cangjie
public func canLoop(value: ?Bool): This
```

**功能：** 设置是否可循环滚动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|是否可循环滚动。<br>true：可循环，false：不可循环。<br>初始值：true。|

### func defaultPickerItemHeight(?Length)

```cangjie
public func defaultPickerItemHeight(value: ?Length): This
```

**功能：** 设置Picker各选择项的高度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|Picker各选择项的高度。|

## 组件事件

### func onChange(?OnTextPickerChangeCallback)

```cangjie
public func onChange(callback: ?OnTextPickerChangeCallback): This
```

**功能：** 选择器选项发生变化时触发该回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[OnTextPickerChangeCallback](#type-ontextpickerchangecallback)|是|-|选择器选项发生变化时的回调函数。<br>初始值：{ _, _ => }。|

## 基础类型定义

### type OnTextPickerChangeCallback

```cangjie
public type OnTextPickerChangeCallback = (String, UInt32) -> Unit
```

**功能：** TextPicker项目被选中事件的回调。

**类型：** (String, UInt32) -> Unit

## 示例代码

### 示例1（设置选择器列数）

该示例通过配置range实现单列或多列文本选择器。

<!-- run -->

```cangjie

package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.hilog.*

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

@Entry
@Component
class EntryView {
    var select: UInt32 = 1
    @State var fruits: Array<String> = ["apple", "banana", "orange", "peach"]
    func build() {
        Column {
            TextPicker(range: this.fruits, selected: this.select)
            .onChange({value: String, index: UInt32  =>
                    loggerInfo("Picker item changed, value: ${index}")
            })
        }
        .width(100.percent)
        .height(100.percent)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
    }
}
```

![textpicker](figures/textpicker.gif)
