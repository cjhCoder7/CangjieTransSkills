# 布局约束

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

通过约束组件的尺寸、对齐方式等来控制组件在布局中的表现。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func constraintSize(?Length, ?Length, ?Length, ?Length)

```cangjie
func constraintSize(minWidth!: ?Length, maxWidth!: ?Length, minHeight!: ?Length, maxHeight!: ?Length ): T
```

**功能：** 设置组件约束尺寸。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|minWidth|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 组件最小宽度 <br>初始值: 0.vp。|
|maxWidth|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 组件最大宽度 <br>初始值: (Float64.Inf).vp。|
|minHeight|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 组件最小高度 <br>初始值: 0.vp。|
|maxHeight|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 组件最大高度 <br>初始值: (Float64.Inf).vp。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func align(?Alignment)

```cangjie
func align(value: ?Alignment): T
```

**功能：** 设置组件在父容器中的对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Alignment](cj-common-types.md#enum-alignment)|是|-|设置容器元素绘制区域内的子元素的对齐方式。<br>只在[Stack](cj-row-column-stack-stack.md)、[Shape](cj-graphic-drawing-shape.md)、[Button](cj-button-picker-button.md)、[StepperItem](cj-navigation-switching-stepperitem.md)、[Text](cj-text-input-text.md)、[TextArea](cj-text-input-textarea.md)、[TextInput](cj-text-input-textinput.md)、[RichEditor](cj-text-input-richeditor.md)、[ListItem](cj-scroll-swipe-listitem.md)、[GridItem](cj-scroll-swipe-griditem.md)、[Scroll](cj-scroll-swipe-scroll.md)、[LoadingProgress](cj-information-display-loadingprogress.md)、[PatternLock](cj-information-display-patternlock.md)、[Progress](cj-information-display-progress.md)、[QRCode](cj-information-display-qrcode.md)、[TextClock](cj-information-display-textclock.md)、[TextTimer](cj-information-display-texttimer.md)、[MenuItem](cj-menu-menuitem.md)、[Toggle](cj-button-picker-toggle.md)、[Checkbox](cj-button-picker-checkbox.md)中生效，其中和文本相关的组件[Text](cj-text-input-text.md)、[TextArea](cj-text-input-textarea.md)、[TextInput](cj-text-input-textinput.md)、[RichEditor](cj-text-input-richeditor.md)的align结果参考[textAlign](cj-text-input-text.md#func-textaligntextalign)。<br>不支持textAlign属性的组件则无法设置水平方向的文字对齐。<br>初始值：Alignment.Center。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func direction(?Direction)

```cangjie
func direction(value: ?Direction): T
```

**功能：** 设置组件的布局方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Direction](./cj-common-types.md#enum-direction)|是|-|布局方向<br>初始值：Direction.Auto。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## 示例代码

### 示例1（设置组件宽高比）

通过aspectRatio设置不同的宽高比。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

var children = ["1", "2", "3", "4", "5", "6"]

@Entry
@Component
class EntryView {
    func build(): Unit {
        Column(space: 20) {
            Text("using container: row")
                .fontSize(14)
                .fontColor(0xCCCCCC)
                .width(100.percent)
            Row(space: 10) {
                ForEach(
                    children,
                    itemGeneratorFunc: {
                        item: String, _: Int64 =>
                        // 组件宽度 = 组件高度*1.5 = 90
                        Text(item)
                            .backgroundColor(0xbbb2cb)
                            .fontSize(20)
                            .aspectRatio(1.5)
                            .height(60)
                        // 组件高度 = 组件宽度/1.5 = 60/1.5 = 40
                        Text(item)
                            .backgroundColor(0xbbb2cb)
                            .fontSize(20)
                            .aspectRatio(1.5)
                            .width(60)
                    }
                )
            }
            .size(width: 100.percent, height: 100.vp)
            .backgroundColor(0xd2cab3)
            .clip(true)

            // grid子元素width/height=3/2
            Text("using container: grid")
                .fontSize(14)
                .fontColor(0xCCCCCC)
                .width(100.percent)
            Grid() {
                ForEach(
                    children,
                    itemGeneratorFunc: {
                        item: String, _: Int64 => GridItem() {
                            Text(item)
                                .backgroundColor(0xbbb2cb)
                                .fontSize(40)
                                .width(100.percent)
                                .aspectRatio(1.5)
                        }
                    }
                )
            }
            .columnsTemplate("1fr 1fr 1fr")
            .columnsGap(10)
            .rowsGap(10)
            .size(width: 100.percent, height: 165.vp)
            .backgroundColor(0xd2cab3)
        }
        .padding(10)
    }
}
```

![uni_constraints](figures/uni_constraints.png)

### 示例2（设置组件显示优先级）

使用displayPriority给子组件绑定显示优先级。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

class ContainerInfo {
    var label: String
    var size: Length
    public init(label!: String, size!: Length) {
        this.label = label
        this.size = size
    }
}

class ChildInfo {
    var text: String
    var priority: Int32
    public init(text!: String, priority!: Int32) {
        this.text = text
        this.priority = priority
    }
}

@Entry
@Component
class EntryView {
    private let container: Array<ContainerInfo> = [
        ContainerInfo( label: 'Big container', size: 100.percent ),
        ContainerInfo( label: 'Middle container', size: 60.percent ),
        ContainerInfo( label: 'Small container', size: 30.percent )
    ]
    private let children: Array<ChildInfo> = [
        ChildInfo( text: '1\n(priority:2)', priority: 2 ),
        ChildInfo( text: '2\n(priority:1)', priority: 1 ),
        ChildInfo( text: '3\n(priority:3)', priority: 3 ),
        ChildInfo( text: '4\n(priority:1)', priority: 1 ),
        ChildInfo( text: '5\n(priority:2)', priority: 2 )
    ]

    @State var currentIndex: Int64 = 0;

    func build(): Unit {
        Column(space: 10) {
            // 切换父级容器大小
            Button(this.container[this.currentIndex].label)
                .backgroundColor(0x317aff)
                .onClick({e =>
                    this.currentIndex = (this.currentIndex + 1) % this.container.size
                })
            // 通过变量设置Flex父容器宽度
            Flex(justifyContent: FlexAlign.SpaceBetween) {
                ForEach(
                    this.children, itemGeneratorFunc:
                    {
                        item: ChildInfo, idx: Int64 =>
                            // 使用displayPriority给子组件绑定显示优先级
                            Text(item.text)
                                .width(50)
                                .height(60)
                                .fontSize(10)
                                .textAlign(TextAlign.Center)
                                .backgroundColor(0xbbb2cb)
                                .displayPriority(item.priority)
                    }
                 )
             }
            .width(this.container[this.currentIndex].size)
            .backgroundColor(0xd2cab3)
        }
        .width(100.percent)
        .margin( top: 50 )
    }
}
```

![uni_constraints](figures/uni_constraints2.gif)