# Rect

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

矩形绘制组件。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

无

## 创建组件

### init(?Length, ?Length)

```cangjie
public init(width!: ?Length = None, height!: ?Length = None)
```

**功能：** 绘制一个宽度为width，高度为height的矩形。异常值按照初始值处理。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|width|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 矩形宽度，取值范围≥0。初始值：0。默认单位：vp。|
|height|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 矩形高度，取值范围≥0。初始值：0。默认单位：vp。|

## 通用属性/通用事件

通用属性：除了支持通用属性外，还支持[图形绘制通用属性](./cj-graphic-drawing-common.md#组件属性)。

通用事件：全部支持。

## 组件属性

### func radiusWidth(?Length)

```cangjie
public func radiusWidth(value: ?Length): This
```

**功能：** 设置圆角的宽度，仅设置宽时宽高一致。异常值按照初始值处理。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|圆角的宽度。初始值：0.vp|

### func radiusHeight(?Length)

```cangjie
public func radiusHeight(value: ?Length): This
```

**功能：** 设置圆角的高度，仅设置高时宽高一致。异常值按照初始值处理。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|设置圆角的高度。初始值：0.vp。|

### func radius(?Length)

```cangjie
public func radius(value: ?Length): This
```

**功能：** 设置圆角半径大小，取值范围≥0。异常值按照初始值处理。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|圆角半径大小。初始值：0.vp。|

### func radius(?Array\<Length>)

```cangjie
public func radius(value: ?Array<Length>): This
```

**功能：** 设置圆角半径大小，取值范围≥0。异常值按照初始值处理。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Array\<[Length](./cj-common-types.md#interface-length)>|是|-|左上、右上、右下、左下圆角半径大小。<br>初始值：0.vp。|

### func radius(?Array\<(Length, Length)>)

```cangjie
public func radius(value: ?Array<(Length, Length)>): This
```

**功能：** 设置圆角半径大小，取值范围≥0。异常值按照初始值处理。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Array\<([Length](./cj-common-types.md#interface-length), [Length](./cj-common-types.md#interface-length))>|是|-|左上、右上、右下、左下圆角宽、高大小。<br>初始值：0。<br>默认单位：vp。|

## 示例代码

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_management.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    func build() {
        Column(space: 10) {
            Text("normal").fontSize(11).fontColor(0xCCCCCC).width(90.percent)
            // 绘制90% * 50的矩形
            Column(space: 5) {
                Text("normal").fontSize(9).fontColor(0xCCCCCC).width(90.percent)
                // 绘制90% * 50矩形
                Rect().width(90.percent).height(50).fill(Color.Green)
                // 绘制90% * 50的矩形框
                Rect()
                .width(90.percent)
                .height(50)
                .fillOpacity(0.0)
                .stroke(Color.Red)
                .strokeWidth(3)

                Text("with rounded corners").fontSize(11).fontColor(0xCCCCCC).width(90.percent)
                // 绘制90% * 80的矩形, 圆角宽高分别为40、20
                Rect()
                .width(90.percent)
                .height(50)
                .radiusHeight(20)
                .radiusWidth(40)
                .fill(Color.Green)
                // 绘制90% * 80的矩形, 圆角宽高为20
                Rect()
                .width(90.percent)
                .height(80)
                .radius(20)
                .fill(Color.Green)
                .stroke(Color.Transparent)
            }.width(100.percent).margin(top: 10)
            // 绘制90% * 50矩形, 左上圆角宽高40,右上圆角宽高20,右下圆角宽高40,左下圆角宽高20
            Rect()
            .width(90.percent)
            .height(80)
            .radius([(40, 40), (20, 20), (40, 40), (20, 20)])
            .fill(Color.Green)
        }.width(100.percent).margin(top: 5)
    }
}
```

![rect2](./figures/rect2.png)
