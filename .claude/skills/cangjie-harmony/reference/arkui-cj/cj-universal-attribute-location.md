# 位置设置

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

设置组件的位置、锚点和偏移量。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func position(?Length, ?Length)

```cangjie
func position(x!: ?Length, y!: ?Length): T
```

**功能：** 设置组件的位置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 组件的x坐标|
|y|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 组件的y坐标|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func markAnchor(?Length, ?Length)

```cangjie
func markAnchor(x!: ?Length, y!: ?Length): T
```

**功能：** 设置锚点。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 锚点的x坐标|
|y|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 锚点的y坐标|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func offset(?Length, ?Length)

```cangjie
func offset(x!: ?Length, y!: ?Length): T
```

**功能：** 设置偏移量。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** x轴偏移量|
|y|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** y轴偏移量|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func alignRules(?AlignRuleOption)

```cangjie
func alignRules(value: ?AlignRuleOption): T
```

**功能：** 设置组件的对齐规则。

> **说明：**
>
> 仅当父容器为RelativeContainer时生效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[AlignRuleOption](./cj-common-types.md#class-alignruleoption)|是|-|对齐规则选项<br>初始值：AlignRuleOption()。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## 示例代码

### 示例1（对齐方式和主轴方向上的布局）

设置内容在元素内的对齐方式和子元素在父容器主轴方向上的布局。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build(): Unit {
        Column {
            Column(space: 10) {
                // 设置子组件左上角相对于父组件左上角的偏移位置
                // 元素内容<元素宽高，设置内容在元素内的对齐方式
                Text("align")
                    .fontSize(9)
                    .fontColor(0xCCCCCC)
                    .width(90.percent)
                Stack() {
                    Text("First show in bottom end")
                        .height(65.percent)
                        .backgroundColor(0xD2B48C)
                    Text("Second show in bottom end")
                        .backgroundColor(0xF5DEB3)
                        .opacity(0.9)
                }
                .width(90.percent)
                .height(50)
                .margin(top: 5)
                .backgroundColor(0xFFE4C4)
                .align(Alignment.BottomEnd)
                Stack() {
                    Text("top start")
                }
                .width(90.percent)
                .height(50)
                .margin(top: 5)
                .backgroundColor(0xFFE4C4)
                .align(Alignment.TopStart)

                // 父容器设置direction为Direction.Ltr，子元素从左到右排列
                Text("direction")
                    .fontSize(9)
                    .fontColor(0xCCCCCC)
                    .width(90.percent)
                Row() {
                    Text("1")
                        .height(50)
                        .width(25.percent)
                        .fontSize(16)
                        .backgroundColor(0xF5DEB3)
                    Text("2")
                        .height(50)
                        .width(25.percent)
                        .fontSize(16)
                        .backgroundColor(0xD2B48C)
                    Text("3")
                        .height(50)
                        .width(25.percent)
                        .fontSize(16)
                        .backgroundColor(0xF5DEB3)
                    Text("4")
                        .height(50)
                        .width(25.percent)
                        .fontSize(16)
                        .backgroundColor(0xD2B48C)
                }
                .width(90.percent)
                .direction(Direction.Ltr)
                // 父容器设置direction为Direction.Rtl，子元素从右到左排列
                Row() {
                    Text("1")
                        .height(50)
                        .width(25.percent)
                        .fontSize(16)
                        .backgroundColor(0xF5DEB3)
                        .textAlign(TextAlign.End)
                    Text("2")
                        .height(50)
                        .width(25.percent)
                        .fontSize(16)
                        .backgroundColor(0xD2B48C)
                        .textAlign(TextAlign.End)
                    Text("3")
                        .height(50)
                        .width(25.percent)
                        .fontSize(16)
                        .backgroundColor(0xF5DEB3)
                        .textAlign(TextAlign.End)
                    Text("4")
                        .height(50)
                        .width(25.percent)
                        .fontSize(16)
                        .backgroundColor(0xD2B48C)
                        .textAlign(TextAlign.End)
                }
                .width(90.percent)
                .direction(Direction.Rtl)
            }
        }
    }
}
```

![uni_location](figures/uni_location1.png)

### 示例2（位置偏移）

基于父组件、相对定位、锚点作出位置偏移。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build(): Unit {
        Scroll() {
            Column(space: 20) {
                // 设置子组件左上角相对于父组件左上角的偏移位置
                Text("position")
                    .fontSize(12)
                    .fontColor(0xCCCCCC)
                    .width(90.percent)
                Row() {
                    Text("1")
                        .size(width: 30.percent, height: 50.vp)
                        .backgroundColor(0xdeb887)
                        .borderWidth(1)
                        .fontSize(16)
                    Text("2 position(30, 10)")
                        .size(width: 60.percent, height: 30.vp)
                        .backgroundColor(0xbbb2cb)
                        .borderWidth(1)
                        .fontSize(16)
                        .align(Alignment.Start)
                        .position(x: 30, y: 10)
                    Text("3")
                        .size(width: 45.percent, height: 50.vp)
                        .backgroundColor(0xdeb887)
                        .borderWidth(1)
                        .fontSize(16)
                    Text("4 position(50%, 70%)")
                        .size(width: 50.percent, height: 50.vp)
                        .backgroundColor(0xbbb2cb)
                        .borderWidth(1)
                        .fontSize(16)
                        .position(x: 50.percent, y: 70.percent)
                }
                .width(90.percent)
                .height(100)
                .border(width: 1.vp, style: BorderStyle.Dashed)

                // 相对于起点偏移，其中x为最终定位点距离起点水平方向间距，x>0往左，反之向右。
                // y为最终定位点距离起点垂直方向间距，y>0向上，反之向下
                Text("markAnchor")
                    .fontSize(12)
                    .fontColor(0xCCCCCC)
                    .width(90.percent)
                Stack(alignContent: Alignment.TopStart) {
                    Row()
                        .size(width: 100, height: 100)
                        .backgroundColor(0xdeb887)
                    Text("A")
                        .size(width: 25, height: 25)
                        .backgroundColor(Color.Green)
                        .markAnchor(x: 25, y: 25)
                    Text("B")
                        .size(width: 25, height: 25)
                        .backgroundColor(Color.Green)
                        .markAnchor(x: -100, y: -25)
                    Text("C")
                        .size(width: 25, height: 25)
                        .backgroundColor(Color.Green)
                        .markAnchor(x: 25, y: -25)
                }
                .margin(top: 25)
                .border(width: 1.vp, style: BorderStyle.Dashed)

                // 相对定位，x>0向右偏移，反之向左，y>0向下偏移，反之向上
                Text("offset")
                    .fontSize(12)
                    .fontColor(0xCCCCCC)
                    .width(90.percent)
                Row() {
                    Text("1")
                        .size(width: 15.percent, height: 50.vp)
                        .backgroundColor(0xdeb887)
                        .borderWidth(1)
                        .fontSize(16)
                    Text("2  offset(15, 30)")
                        .size(width: 120.vp, height: 50.vp)
                        .backgroundColor(0xbbb2cb)
                        .borderWidth(1)
                        .fontSize(16)
                        .align(Alignment.Start)
                        .offset(x: 15, y: 30)
                    Text("3")
                        .size(width: 15.percent, height: 50.vp)
                        .backgroundColor(0xdeb887)
                        .borderWidth(1)
                        .fontSize(16)
                    Text("4 offset(-10%, 20%)")
                        .size(width: 100.vp, height: 50.vp)
                        .backgroundColor(0xbbb2cb)
                        .borderWidth(1)
                        .fontSize(16)
                        .offset(x: (-5).percent, y: 20.percent)
                }
                .width(90.percent)
                .height(100)
                .border(width: 1.vp, style: BorderStyle.Dashed)
            }
            .width(100.percent)
            .margin(top: 25)
        }
    }
}
```

![uni_location](figures/uni_location2.png)