# CheckboxGroup

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

多选框群组，用于控制多选框全选或者不全选状态。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(?String)

```cangjie
public init(group!: ?String = None)
```

**功能：** 创建多选框群组，可以控制群组内的Checkbox全选或者不全选，group值相同的Checkbox和CheckboxGroup为同一群组。

在结合带缓存组件使用时(如List)，未被创建的Checkbox选中状态需要应用手动控制。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|group|?String|否|None| **命名参数。** 多选框的群组名称。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func selectAll(?Bool)

```cangjie
public func selectAll(value: ?Bool): This
```

**功能：** 设置是否全选。若同组的[Checkbox](./cj-button-picker-checkbox.md)显式设置了select属性，则Checkbox的优先级高。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|是否全选。初始值：false。<br>值为true时，多选框群组都被选中。值为false时，多选框群组都不被选中。|

### func selectedColor(?ResourceColor)

```cangjie
public func selectedColor(value: ?ResourceColor): This
```

**功能：** 设置被选中或部分选中状态的颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|被选中或部分选中状态的颜色。|

## 组件事件

### func onChange(?OnCheckboxGroupChangeCallback)

```cangjie
public func onChange(callback: ?OnCheckboxGroupChangeCallback): This
```

**功能：** CheckboxGroup的选中状态或群组内的Checkbox的选中状态发生变化时，触发回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[OnCheckboxGroupChangeCallback](#type-oncheckboxgroupchangecallback)|是|-|多选框群组的信息。初始值：{ _ => }|

## 基础类型定义

### class CheckboxGroupResult

```cangjie
public class CheckboxGroupResult {
    public var name: Array<String>
    public var status: SelectStatus
    public init(
        status: SelectStatus,
        name: Array<String>
    )
}
```

**功能：** 多选框群组选中状态信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var name

```cangjie
public var name: Array<String>
```

**功能：** 群组内所有被选中的多选框名称。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var status

```cangjie
public var status: SelectStatus
```

**功能：** 选中状态。

**类型：** [SelectStatus](./cj-common-types.md#enum-selectstatus)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(SelectStatus, Array\<String>)

```cangjie
public init(
    status: SelectStatus,
    name: Array<String>
)
```

**功能：** 构造多选框群组选中状态信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|status|[SelectStatus](./cj-common-types.md#enum-selectstatus)|是|-|选中状态。|
|name|Array\<String>|是|-|群组内所有被选中的多选框名称。|

### type OnCheckboxGroupChangeCallback

```cangjie
public type OnCheckboxGroupChangeCallback = (CheckboxGroupResult) -> Unit
```

**功能：** (CheckboxGroupResult) -> Unit 的类型别名。

**类型：** ([CheckboxGroupResult](#class-checkboxgroupresult)) -> Unit

## 示例代码

### 示例1（设置多选框群组）

该示例用于控制多选框全选或者不全选状态。

<!-- run -->

```cangjie

package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.hilog.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

func formatNames(names: Array<String>): String {
    var result = ""
    for(name in names) {
        result += name + ";"
    }
    result
}

@Entry
@Component
class EntryView {
    func build() {
        Column(){
            Flex(justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center) {
                CheckboxGroup(group:"checkboxGroup")
                .size(width: 50.vp, height: 50.vp)
                .selectedColor(0xed6f21)
                .selectAll(false)
                .onChange({ val =>
                    loggerInfo("checkboxGroup onChange names:" + formatNames(val.name))
                })

                Text("Select All").fontSize(50)
            }
            Flex(justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center) {
                Checkbox(name: "checkbox1", group:"checkboxGroup")
                .size(width: 50.vp, height: 50.vp)

                Text("checkbox1").fontSize(50)
            }

            Flex(justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center) {
                Checkbox(name: "checkbox2", group:"checkboxGroup")
                .size(width: 50.vp, height: 50.vp)

                Text("checkbox2").fontSize(50)
            }
        }
    }
}
```

![checkbox_group](figures/checkbox_group.gif)

### 示例2

<!-- run -->

```cangjie

package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.hilog.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

func formatNames(names: Array<String>): String {
    var result = ""
    for(name in names) {
        result += name + ";"
    }
    result
}

@Entry
@Component
class EntryView {
    func build() {
        Column(){
            Flex(justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center) {
                CheckboxGroup(group:"checkboxGroup1")
                .size(width: 50.vp, height: 50.vp)
                .selectedColor(0xed6f21)
                .selectAll(true)
                .onChange({ val =>
                    loggerInfo("checkboxGroup1 onChange names:" + formatNames(val.name))
                })

                Text("Select All").fontSize(50)
            }
            Flex(justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center) {
                Checkbox(name: "checkbox1", group:"checkboxGroup1")
                .size(width: 50.vp, height: 50.vp)

                Text("checkbox1").fontSize(50)
            }

            Flex(justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center) {
                Checkbox(name: "checkbox2", group:"checkboxGroup1")
                .size(width: 50.vp, height: 50.vp)

                Text("checkbox2").fontSize(50)
            }

            Flex(justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center) {
                Checkbox(name: "checkbox3", group:"checkboxGroup1")
                .size(width: 50.vp, height: 50.vp)

                Text("checkbox3").fontSize(50)
            }
        }
    }
}
```

![checkbox_group2](figures/checkbox_group2.gif)
