# GridItem

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

网格容器中单项内容容器。

> **说明：**
>
> - 仅支持作为[Grid](./cj-scroll-swipe-grid.md)组件的子组件使用。
> - 当GridItem配合[LazyForEach](cj-state-rendering-lazyforeach.md)使用时，GridItem子组件在GridItem创建时创建。配合[if/else](../../arkui-cj/rendering_control/cj-rendering-control-ifelse.md)、[ForEach](../../arkui-cj/rendering_control/cj-rendering-control-foreach.md)使用时，或父组件为Grid时，GridItem子组件在GridItem布局时创建。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

可以包含单个子组件。

## 创建组件

### init()

```cangjie
public init()
```

**功能：** 创建网格容器中单项内容组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(() -> Unit)

```cangjie
public init(child: () -> Unit)
```

**功能：** 创建一个可包含子组件的网格容器单项内容组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|child|() -> Unit|是|-|GridItem 容器的子组件。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func columnEnd(?Int32)

```cangjie
public func columnEnd(value: ?Int32): This
```

**功能：** 设置当前元素终点列号。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Int32|是|-|当前元素终点列号，与columnStart配套使用。|

### func columnStart(?Int32)

```cangjie
public func columnStart(value: ?Int32): This
```

**功能：** 设置当前元素起始列号。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Int32|是|-|当前元素起始列号，与columnEnd配套使用。|

### func rowEnd(?Int32)

```cangjie
public func rowEnd(value: ?Int32): This
```

**功能：** 设置当前元素终点行号。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Int32|是|-|当前元素终点行号，与rowStart配套使用。|

### func rowStart(?Int32)

```cangjie
public func rowStart(value: ?Int32): This
```

**功能：** 设置当前元素起始行号。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Int32|是|-|当前元素起始行号，与rowEnd配套使用。|

## 示例代码

### 示例1（GridItem设置自身位置）

GridItem通过设置合理的ColumnStart、ColumnEnd、RowStart、RowEnd属性来设置自身位置。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.{ArrayList, HashMap}

@Entry
@Component
class EntryView {
    let scroller = Scroller()
    @State
    var numbers: ArrayList<String> = ArrayList(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13",
        "14", "15"])

    func build() {
        Column() {
            Grid {
                //指定当前GridItem组件的起始行号为1，终点行号为4
                GridItem {
                    Text("4")
                        .fontSize(16)
                        .backgroundColor(0xFAEEE0)
                        .width(100.percent)
                        .height(100.percent)
                        .textAlign(TextAlign.Center)
                        .id("gridItem1")
                }.rowStart(1).rowEnd(4)

                //循环渲染Griditem，标记为0-15
                ForEach(
                    this.numbers,
                    itemGeneratorFunc: {
                        num: String, idx: Int64 => GridItem {
                            Text(num)
                                .fontSize(16)
                                .backgroundColor(0xF9CF93)
                                .width(100.percent)
                                .height(100.percent)
                                .textAlign(TextAlign.Center)
                        }
                    }
                )
                //指定当前GridItem组件的起始列号为1，终点列号为5
                GridItem {
                    Text("5")
                        .fontSize(16)
                        .backgroundColor(0xDBD0C0)
                        .width(100.percent)
                        .height(100.percent)
                        .textAlign(TextAlign.Center)
                        .id("gridItem2")
                }.columnStart(1).columnEnd(5)
            }
                .columnsTemplate("1fr 1fr 1fr 1fr 1fr")
                .rowsTemplate("1fr 1fr 1fr 1fr 1fr")
                .width(90.percent)
                .backgroundColor(0xFAEEE0)
                .height(300)
        }.width(100.percent).margin(top: 5)
    }
}
```

![griditem](figures/griditem1.gif)