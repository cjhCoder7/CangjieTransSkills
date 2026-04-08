# Stepper

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

步骤导航器。当完成一个任务需要多个步骤时，可以使用步骤导航器展示当前进展。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

仅能包含子组件[StepperItem](./cj-navigation-switching-stepperitem.md)。

## 创建组件

### init(?UInt32, () -> Unit)

```cangjie
public init(index!: ?UInt32 = None, child!: () -> Unit = {=>})
```

**功能：** 构造一个步骤导航器组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|index|?UInt32|否|None| **命名参数。** 步骤导航器当前显示StepperItem的索引值。<br>初始值：0。|
|child|() -> Unit|否|{=>}| **命名参数。** 步骤导航器的子组件。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件事件

### func onChange(?(UInt32, UInt32) -> Unit)

```cangjie
public func onChange(callback: ?(UInt32, UInt32) -> Unit): This
```

**功能：** 点击当前StepperItem的[prevLabel](./cj-navigation-switching-stepperitem.md#func-prevlabelstring)进行步骤切换时触发该事件；或点击当前StepperItem的[nextLabel](./cj-navigation-switching-stepperitem.md#func-nextlabelstring)时当前页面不是步骤导航器最后一个StepperItem，并且[ItemState](./cj-common-types.md#enum-itemstate)属性为Normal时触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?(UInt32, UInt32) -> Unit|是|-|回调函数。单击步骤导航器中的左边或者右边按钮进行步骤切换时触发该事件。<br>第一个参数：切换前的步骤页索引值。<br>第二个参数：切换后的步骤页（前一页或者下一页）索引值。<br>初始值：{ _, _ => }。|

### func onFinish(?() -> Unit)

```cangjie
public func onFinish(callback: ?() -> Unit): This
```

**功能：** 步骤导航器最后一个StepperItem的nextLabel被点击时，并且ItemState属性为Normal时，触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?() -> Unit|是|-|回调函数，当步骤导航器最后一个步骤完成时触发该回调。<br>初始值：{ => }。|

### func onNext(?(UInt32, UInt32) -> Unit)

```cangjie
public func onNext(callback: ?(UInt32, UInt32) -> Unit): This
```

**功能：** 点击StepperItem的nextLabel切换下一步骤时，当前页面不是步骤导航器最后一个StepperItem，并且ItemState属性为Normal时触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?(UInt32, UInt32) -> Unit|是|-|回调函数，切换下一步骤页面时触发该回调。<br>第一个参数：当前步骤页索引值。<br>第二个参数：下一步骤页索引值。<br>初始值：{ _, _ => }。|

### func onPrevious(?(UInt32, UInt32) -> Unit)

```cangjie
public func onPrevious(callback: ?(UInt32, UInt32) -> Unit): This
```

**功能：** 点击StepperItem的prevLabel切换上一步骤时，触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?(UInt32, UInt32) -> Unit|是|-|回调函数，切换上一步骤页面时触发该回调。<br>第一个参数：当前步骤页索引值。<br>第二个参数：上一步骤页索引值。<br>初始值：{ _, _ => }。|

### func onSkip(?() -> Unit)

```cangjie
public func onSkip(callback: ?() -> Unit): This
```

**功能：** 当前显示的StepperItem状态为ItemState.Skip时，nextLabel被点击时触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?() -> Unit|是|-|回调函数，点击切换下一步骤页面时触发该回调。<br>初始值：{ => }。|

## 示例代码

该示例主要演示如何使用步骤导航器组件。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.hilog.*

extend ItemState {
    func toString(): String {
        match (this) {
            case Normal => "Normal"
            case Disabled => "Disabled"
            case Waiting => "Waiting"
            case _ => "Skip"
        }
    }
}

@Entry
@Component
class EntryView {
    @State var currentIndex: UInt32  = 0
    @State var firstState: ItemState = ItemState.Normal
    @State var secondState: ItemState = ItemState.Normal
    @State var thirdState: ItemState = ItemState.Normal

    func build() {
        Column() {
            Stepper(index:currentIndex) {
                StepperItem() {
                    Column() {
                      Text("Page One").fontSize(35).fontColor(0x182431)
                      Button("change status")
                        .backgroundColor(0x007dFF)
                        .onClick({ evt =>
                            if(this.firstState.toString() == "Skip") {
                                this.firstState = ItemState.Normal
                            } else {
                                this.firstState = ItemState.Skip
                            }
                        })
                    }
                }
                .nextLabel("Next Page")
                .status(status:this.firstState)
                StepperItem() {
                    Column() {
                      Text("Page Two").fontSize(35).fontColor(0x182431)
                      Button("change status")
                        .backgroundColor(0x007dFF)
                        .onClick({ evt =>
                            if(this.secondState.toString() == "Disabled") {
                                this.secondState = ItemState.Normal
                            } else {
                                this.secondState = ItemState.Disabled
                            }
                        })
                    }
                }
                .nextLabel("Next Page")
                .prevLabel("Previous Page")
                .status(status:this.secondState)
                StepperItem() {
                    Column() {
                      Text("Page Three").fontSize(35).fontColor(0x182431)
                      Button("change status")
                        .backgroundColor(0x007dFF)
                        .onClick({ evt =>
                            if(this.thirdState.toString() == "Waiting") {
                                this.thirdState = ItemState.Normal
                            } else {
                                this.thirdState = ItemState.Waiting
                            }
                        })
                    }
                }
                .nextLabel("Next Page")
                .prevLabel("Previous Page")
                .status(status:this.thirdState)
                StepperItem() {
                    Column() {
                        Text("Page Four").fontSize(35).fontColor(0x182431)
                    }
                }
            }
            .backgroundColor(0xF1F3F5)
            .onFinish({=>
                Hilog.info(0, "AppLogCj", "onFinish")
            })
            .onSkip({=>
                Hilog.info(0, "AppLogCj", "onSkip")
            })
            .onChange({prevIndex: UInt32, index: UInt32 =>
                if(index != 0){
                    currentIndex = index
                }
            })
        }
        .width(100.percent)
        .padding(top: 5)
    }
}
```

![stepper](./figures/stepper.gif)