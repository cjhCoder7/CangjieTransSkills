# Blank

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

空白填充组件，在容器主轴方向上，空白填充组件具有自动填充容器空余部分的能力。仅当父组件为[Row](./cj-row-column-stack-row.md)/[Column](./cj-row-column-stack-column.md)/[Flex](./cj-row-column-stack-flex.md)时生效。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(?Length)

```cangjie
public init(min!: ?Length = None)
```

**功能：** 创建一个 Blank 组件。

> **说明：**
>
> - Blank在父容器[Row](./cj-row-column-stack-row.md)、[Column](./cj-row-column-stack-column.md)、[Flex](./cj-row-column-stack-flex.md)主轴方向上未设置大小时会自动拉伸、压缩，设置了大小或容器自适应子节点大小时不会自动拉伸、压缩。
> - Blank设置主轴方向大小（size）与min时约束关系为max(min, size)。
> - Blank在父容器交叉轴上设置大小时不会撑满父容器交叉轴，交叉轴不设置大小时alignSelf默认值为ItemAlign.Stretch，会撑满容器交叉轴。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|min|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 空白填充组件在容器主轴上的最小大小。不指定像素单位时，默认单位vp。不支持设置百分比。负值使用初始值。当最小值大于容器可用空间时，使用最小值作为自身大小并超出容器。初始值：0.vp|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func color(?ResourceColor)

```cangjie
public func color(value: ?ResourceColor): This
```

**功能：** 设置当前空白填充的填充颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|空白填充的填充颜色。<br>初始值：Color.Transparent。|

## 示例代码

### 示例1（占满空余空间）

Blank组件在横竖屏占满空余空间效果。

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
                Text("Bluetooth").fontSize(18)
                Blank()
                Toggle(ToggleType.Switch).margin(top: 14, bottom: 14, left: 6, right: 6)
            }.width(100.percent).backgroundColor(0xFFFFFF).borderRadius(15).padding( left: 12 )
        }.backgroundColor(0xEFEFEF).padding(20)
    }
}
```

![blank1](./figures/blank1.gif)

### 示例2（填充固定宽度）

Blank组件的父组件未设置宽度时，min参数的使用效果。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Column(space: 20) {
            Row() {
                Text("Bluetooth").fontSize(18)
                Blank().color(0xFFFF00)
                Toggle(ToggleType.Switch).margin(top: 14, bottom: 14, left: 6, right: 6)
            }.backgroundColor(0xFFFFFF).borderRadius(15).padding(left: 12)

            Row() {
                Text("Bluetooth").fontSize(18)
                Blank(min: 160.vp).color(0xFFFF00)
                Toggle(ToggleType.Switch).margin(top: 14, bottom: 14, left: 6, right: 6)
            }.backgroundColor(0xFFFFFF).borderRadius(15).padding(left: 12)
        }.backgroundColor(0xEFEFEF).padding(20).width(100.percent)
    }
}
```

![blank2](./figures/blank2.gif)
