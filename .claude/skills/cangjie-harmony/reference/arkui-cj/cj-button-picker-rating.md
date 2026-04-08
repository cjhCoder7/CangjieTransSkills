# Rating

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

一个提供在给定范围内选择评分的组件。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(?Float64, ?Bool)

```cangjie
public init(rating!: ?Float64, indicator!: ?Bool = None)
```

**功能：** 构造一个在给定范围内选择评分的组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|rating|?Float64|是|-|**命名参数。** 设置并接收评分值。<br>初始值：0.0。<br>**说明**：取值范围： [0, stars] ，小于0取0，大于stars取最大值stars。|
|indicator|?Bool|否|None|**命名参数。** 设置评分组件作为指示器使用，不可改变评分。<br>初始值：false，可进行评分。<br>**说明**：indicator=true时，默认组件高度height=12.0.vp，组件width=height * stars。indicator=false时，默认组件高度height=28.0.vp，组件width=height * stars。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func stars(?Int32)

```cangjie
public func stars(value: ?Int32): This
```

**功能：** 设置评分总数。设置为小于等于0的值时，按初始值显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Int32|是|-|设置评分总数。<br>初始值：5。|

### func stepSize(?Float64)

```cangjie
public func stepSize(size: ?Float64): This
```

**功能：** 设置操作评级的步长。设置为小于等于0.0的值时，按初始值显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|size|?Float64|是|-|操作评级的步长。<br>初始值：0.5。<br>取值范围：（0.0, stars]。|

### func starStyle(?ResourceStr, ?ResourceStr, ?ResourceStr)

```cangjie
public func starStyle(backgroundUri!: ?ResourceStr, foregroundUri!: ?ResourceStr, secondaryUri!: ?ResourceStr = None): This
```

**功能：** 设置评分的样式。该属性所支持的图片类型能力参考[Image](./cj-image-video-image.md)组件。支持加载本地图片和网络图片，暂不支持PixelMap类型和Resource资源。

> **说明：**
>
> - backgroundUri：未选中的星级的图片链接，可由用户自定义或使用系统默认图片。
> - foregroundUri：选中的星级的图片路径，可由用户自定义或使用系统默认图片。
> - secondaryUri：部分选中的星级的图片路径，可由用户自定义或使用系统默认图片。
> - rating宽高为[width, height]时，单个图片的绘制区域为[width / stars, height]。
> - 为了指定绘制区域为方形，建议自定义宽高时采取[height * stars, height], width = height * stars的方式。
> - backgroundUri或者foregroundUri或者secondaryUri设置的图片路径错误时，图片不显示。
> - backgroundUri或者foregroundUri设置为空字符串时，rating会选择加载系统默认星型图源。
> - secondaryUri不设置或者设置的值为空字符串时，优先设置为backgroundUri，效果上等同于只设置了foregroundUri、backgroundUri。

默认图片加载方式为异步，暂不支持同步加载。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|backgroundUri|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|**命名参数。** 未选中的星级的图片链接，可由用户自定义或使用系统默认图片。<br>初始值：""。|
|foregroundUri|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|**命名参数。** 选中的星级的图片路径，可由用户自定义或使用系统默认图片。<br>初始值：""。|
|secondaryUri|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None|**命名参数。** 部分选中的星级的图片路径，可由用户自定义或使用系统默认图片。<br>初始值： 取backgroundUri的值。|

## 组件事件

### func onChange(?(Float64) -> Unit)

```cangjie
public func onChange(callback: ?(Float64) -> Unit): This
```

**功能：** 操作评分条的评星发生改变时触发该回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?(Float64)->Unit|是|-|评分条的评分。<br>初始值：{ _ => }。|

## 示例代码

### 示例1（设置默认评分样式）

该示例为创建默认星型评分样式。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.i18n.*
import ohos.resource_manager.*
import ohos.resource.__GenerateResource__

@Entry
@Component
class EntryView {
    @State var rating: Float64 = 3.5

    func build() {
        Column() {
            Column() {
                Rating(rating: rating,indicator: false)
                  .stars(5)
                  .stepSize(0.5)
                  .margin(24)
                  .onChange({value: Float64 =>
                    this.rating = value
                    })
                Text("current score is ${this.rating}")
                    .fontSize(16)
                    .fontColor(0x182431)
                    .margin( 16 )
              }.width(360).height(113).backgroundColor(Color.White).margin(top: 68 )
            Row() {
                Image(@r(app.media.startIcon))
                    .width(40)
                    .height(40)
                    .borderRadius(20)
                    .margin(left: 24 )
                Column() {
                    Text("Cangjie")
                        .fontSize(16)
                        .fontColor(Color.Black)
                        .fontWeight(FontWeight.Bold)
                    Row() {
                        Rating(rating: 3.5, indicator: false ).margin(top: 1, right: 8 )
                        Text("2024/07/01")
                            .fontSize(10)
                            .fontColor(Color.Black)
                        }
                }.margin(left: 12 ).alignItems(HorizontalAlign.Start)

                Text("1st Floor")
                    .fontSize(10)
                    .fontColor(Color.Black)
                    .position( x: 295, y: 8 )
             }.width(360).height(56).backgroundColor(Color.White).margin(top: 64 )
        }.width(100.percent).height(100.percent)
    }
}
```

![rating](figures/rating2.gif)

### 示例2（设置评分的样式）

该示例通过配置starStyle实现自定义星级的图片链接。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var rating: Float64 = 3.5
    @State var backPng: String = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAj1JREFUSEu11UuojWEUBuDnOC5nIISSQoQyQRIZIRSiiHCKESMiBiTFDCEZSZmgTGRAuSYdQq6JxEQhl1JCkmukfOv0/adtt8/ePzpf7f6997/Wetda71rv16SLT1MXx9cZQA9MyeCv8RI/q5LphqEYRnucW/hRnXA1wEBsSgFXIr4X5yv2YC/i++5sM6DC5iOOYAfeFv9XAgzCFYzGtQSwH+/QC/OxGu8xHcvz8wQeJuDeyXZt/u9Z8p+Zq+5oUQS5jlGYgXs1uBmDU7myObhTw2Ys2lIybzAZ34oKNmMXVqWeHqpD/OBcXV9MwvMatstwDFujXQXAI/zC+BJTFSCR/XpEi2qdu+iZ3o8LgO55QqLn60oAlDHZhw1oDoB+KZsPRUllvEvYbEkV7ExtbwmA+HzJBLaWcC5jEhzMioEoODiHiWmOhwfzZSLUsWnBC1xGawGwBMcT0dsSJ9v/EyAWNZYyKmgrAOJ5AzHHUcnjfwSJXQnJeJAqmBYxKjc5NjjGK7QnluTTX4KELt3Mmx869rQaIH7PxZk851FikF/m9M+ZD8HUnGi7Xy01XYGjSTKuYh4+N0AIwbuACViQE+xw6Uyul+Jwcrifyp5dp5IIfilzFzITPn+cehdOlHoyq+JihEpWnpG4mO+ERWk4TteqtNGNFntxFiMQIlYECc06n1u8MHF3u7M2NgIIvz5Z1OIeOJBFcQ2eJGJDtl/V46gMQPg3J7I3ZjmPy+VgvtW+NxqxsgCN4nT6vssBfgOltGMhyH2RwgAAAABJRU5ErkJggg=="
    @State var forePng: String = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAcdJREFUSEu11b9LVXEYx/GXKWU4RGAN4RBESFNQkEQUBkrRkOHUUtQ/EARNtbZFlDgKDjU4SSFOOilCRZBISxTYELUUQUuUVnQeOScO955z77l0/E7nx/N83t/n++PzdNnm0bXN+soAOzGEbvzGM/wqmMwADrKl8xybjTGNgP24jWvYkwv+lLw/wCR+4gIe4nAu5gumcQ/xvDXygANYxqEWy/Yao9iLRUQFjeMtziIm9Q/Qm5Z4tMKevEshsXyxLPsKclZxMqrNKriDuxXEs5D3OJMAzmOqJO8W7meANxjsABChHxCVF1UQ/1/heAB6ina/Q1hR+AZ2BaAfn2sQLJLoCcAOfA9azZCPccqyPVhIT0adjMe4mgEuJ5s8U6c6TmMlA8SZfhG7XhNkCcONN/kIXiZXve8/Id9wAnGjm8xuDE8Kvldlhk+FTYQ5NnlR9u0KHlVVzMWF617CfD63zK5vJIY20QHkD64XTaxVw7kZXlJhuX4ktnAxddemObXraCOYw+6SatYxjrWyatsBIi9c82naA/I6ceLCTb+2WsoqgMiPtjibVHMsFYs7cw5xJFuOqoAQCdc9laqtpL26nX5p02+bWDXgL/kuQxxwPkE6AAAAAElFTkSuQmCC"

    func build() {
        Column() {
            Rating(rating: rating,indicator: false)
                .stars(5)
                .stepSize(0.5)
                .starStyle(
                    backgroundUri: backPng,
                    foregroundUri: forePng
                )
                .margin(24)
                .onChange({value: Float64 =>
                    this.rating = value
                })
            Text("current score is ${this.rating}")
                .fontSize(16)
                .fontColor(0x182431)
                .margin(16)
        }
        .width(100.percent)
        .padding(top: 5)
    }
}
```

![rating](figures/rating1.gif)
