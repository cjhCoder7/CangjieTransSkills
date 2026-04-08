# Checkbox

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

多选框组件，通常用于某选项的打开或关闭。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(?String, ?String, ?CustomBuilder)

```cangjie
public init(name!: ?String = None, group!: ?String = None, indicatorBuilder!: ?CustomBuilder = None)
```

**功能：** 创建多选框组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|?String|否|None|**命名参数。** 多选框名称。|
|group|?String|否|None|**命名参数。** 用于指定多选框所属群组的名称（即所属[CheckboxGroup](./cj-button-picker-checkboxgroup.md)的名称）。<br/>**说明**：<br/>未配合使用[CheckboxGroup](./cj-button-picker-checkboxgroup.md)组件时，此值无用。|
|indicatorBuilder|?[CustomBuilder](./cj-common-types.md#type-custombuilder)|否|None|**命名参数。** 配置多选框的选中样式为自定义UI描述。自定义UI描述与Checkbox组件为中心点对齐显示。indicatorBuilder设置为None时，默认为indicatorBuilder未设置状态。使用时结合[@Builder](../../arkui-cj/paradigm/cj-macro-builder.md)和bind方法使用。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func select(?Bool)

```cangjie
public func select(value: ?Bool): This
```

**功能：** 设置多选框是否被选中。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|多选框是否被选中。初始值：false。<br>值为true时，多选框被选中。值为false时，多选框不被选中。|

### func selectedColor(?ResourceColor)

```cangjie
public func selectedColor(value: ?ResourceColor): This
```

**功能：** 设置多选框选中状态颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|多选框选中状态颜色。初始值：0xff007dff。<br>异常值按照默认值处理。|

### func shape(?CheckBoxShape)

```cangjie
public func shape(value: ?CheckBoxShape): This
```

**功能：** 设置CheckBox组件形状，包括圆形和圆角方形。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[CheckBoxShape](./cj-common-types.md#enum-checkboxshape)|是|-|切换CheckBox组件形状，包括圆形和圆角方形。初始值：CheckBoxShape.Circle|

## 组件事件

### func onChange(?OnCheckboxChangeCallback)

```cangjie
public func onChange(callback: ?OnCheckboxChangeCallback): This
```

**功能：** 当选中状态发生变化时，触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[OnCheckboxChangeCallback](#type-oncheckboxchangecallback)|是|-|当选中状态发生变化时，触发该回调。初始值：{ _: Bool => }。<br>\- Bool值为true时，表示已选中。<br>\- Bool值为false时，表示未选中。|

## 基础类型定义

### type OnCheckboxChangeCallback

```cangjie
public type OnCheckboxChangeCallback = (Bool) -> Unit
```

**功能：** (Bool) -> Unit 的类型别名。

**类型：** (Bool) -> Unit

## 示例代码

### 示例一（设置多选框形状）

该示例通过配置CheckBoxShape实现圆形和圆角方形多选框样式。

<!-- run -->

```cangjie

package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.PerformanceAnalysisKit.Hilog

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

@Entry
@Component
class EntryView {
    func build(){
        Flex(justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center){
            Checkbox(name: "checkbox1", group: "checkboxGroup")
            .select(true)
            .selectedColor(0xed6f21)
            .shape(CheckBoxShape.Circle)
            .onChange({value: Bool =>
                loggerInfo("Checkbox1 change is" + value.toString())
            })
            .size(width: 50.vp, height: 50.vp)
            Checkbox(name: "checkbox2", group: "checkboxGroup")
            .select(false)
            .selectedColor(0x39a2db)
            .shape(CheckBoxShape.RoundedSquare)
            .onChange({value: Bool =>
                loggerInfo("Checkbox2 change is" + value.toString())
            })
            .width(50.vp)
            .height(50.vp)
        }
        .height(400.vp)
    }
}
```

![checkbox](figures/checkbox.gif)

### 示例二（自定义多选框样式）

该示例实现了自定义复选框样式的功能。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Column() {
            Row() {
                Checkbox(name: "checkbox")
                Text("normal")
            }
            Row() {
                Checkbox(name: "mark")
                    .selectedColor(Color.Red)
                    .width(60.vp)
                    .height(60.vp)
                Text("mark")
            }
            Row() {
                Checkbox(name: "mark")
                    .selectedColor(Color.Green)
                    .width(40.vp)
                    .height(40.vp)
                Text("mark")
            }
        }.width(100.percent)
    }
}
```

![checkbox3](figures/checkbox_3.png)

### 示例三（设置文本多选框样式）

该示例通过配置indicatorBuilder实现选中样式为Text。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @Builder
    func indicatorA() {
        Column() {
            Text("A").fontColor(Color.White)
        }
    }
    func build() {
        Column() {
            Row() {
                Checkbox(name: "AAA", indicatorBuilder: indicatorA)
                Text("AAA")
            }
            Row() {
                Checkbox(name: "BBB")
                Text("BBB")
            }
            Row() {
                Checkbox(name: "CCC").selectedColor(Color.Red)
                Text("CCC")
            }
            Row() {
                Checkbox(name: "DDD").selectedColor(Color.Blue)
                Text("DDD")
            }
        }.width(100.percent)
    }
}
```

![checkbox2](figures/checkbox_2.png)
