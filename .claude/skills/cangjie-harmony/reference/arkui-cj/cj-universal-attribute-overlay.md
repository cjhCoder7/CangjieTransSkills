# 浮层

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

设置组件的遮罩文本。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func overlay(?String, ?Alignment, ?OverlayOffset)

```cangjie
func overlay(value!: ?String, align!: ?Alignment,
    offset!: ?OverlayOffset): T
```

**功能：** 在当前组件上，增加遮罩文本作为该组件的浮层。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?String|是|-|**命名参数。** 遮罩文本内容。|
|align|?[Alignment](./cj-common-types.md#enum-alignment)|是|-|**命名参数。** 浮层相对于组件的方位。初始值：Alignment.Center|
|offset|?[OverlayOffset](./cj-common-types.md#class-overlayoffset)|是|-|**命名参数。** 浮层基于自身左上角的偏移量。浮层默认处于组件左上角。初始值：OverlayOffset(x: 0.0, y: 0.0)|

> **说明：**
>
> align和offset都设置时，效果重叠，浮层相对于组件方位定位后，再基于当前位置的左上角进行偏移。

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## 示例代码

### 示例1（浮层效果）

该示例演示了如何使用overlay方法为组件添加浮层文本。

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
            Text("默认居中浮层")
                .width(200)
                .height(100)
                .backgroundColor(0xf48899)
                .align(Alignment.Top)
                .overlay(value: "Overlay Text")
            
            Text("左上角浮层")
                .width(200)
                .height(100)
                .backgroundColor(0xf7b0bb)
                .overlay(value: "Top Left", align: Alignment.TopStart)
            
            Text("带偏移的浮层")
                .width(200)
                .height(100)
                .backgroundColor(0xfbd7dd)
                .overlay(
                    value: "Offset Text", 
                    align: Alignment.BottomEnd,
                    offset: OverlayOffset(x: -20.0, y: -20.0)
                )
        }
        .width(100.percent)
        .height(100.percent)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
    }
}
```

![overlay](./figures/overlay.PNG)
