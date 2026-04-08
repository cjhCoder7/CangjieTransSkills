# 尺寸设置

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

设置组件的宽度、高度、尺寸、内边距、外边距等尺寸相关属性。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func width(Option\<Length>)

```cangjie
func width(value: Option<Length>): T
```

**功能：** 设置组件的宽度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|Option\<[Length](./cj-common-types.md#interface-length)>|是|-|组件的宽度|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func height(Option\<Length>)

```cangjie
func height(value: Option<Length>): T
```

**功能：** 设置组件的高度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|Option\<[Length](./cj-common-types.md#interface-length)>|是|-|组件的高度|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func size(?Length, ?Length)

```cangjie
func size(width!: ?Length, height!: ?Length): T
```

**功能：** 设置组件的尺寸。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|width|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 组件的宽度<br>初始值：0.0.vp。|
|height|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 组件的高度<br>初始值：0.0.vp。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func padding(?Length)

```cangjie
func padding(value: ?Length): T
```

**功能：** 设置组件的内边距。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|组件的内边距|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func padding(?Length, ?Length, ?Length, ?Length)

```cangjie
func padding(top!: ?Length, right!: ?Length, bottom!: ?Length, left!: ?Length): T
```

**功能：** 分别设置组件四个方向的内边距。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|top|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 上内边距<br>初始值：0.vp。|
|right|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 右内边距<br>初始值：0.vp。|
|bottom|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 下内边距<br>初始值：0.vp。|
|left|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 左内边距<br>初始值：0.vp。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func margin(?Length)

```cangjie
func margin(value: ?Length): T
```

**功能：** 设置组件的外边距。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|组件的外边距|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func margin(?Length, ?Length, ?Length, ?Length)

```cangjie
func margin(top!: ?Length, right!: ?Length, bottom!: ?Length, left!: ?Length): T
```

**功能：** 分别设置组件四个方向的外边距。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|top|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 上外边距<br>初始值：0.vp。|
|right|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 右外边距<br>初始值：0.vp。|
|bottom|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 下外边距<br>初始值：0.vp。|
|left|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 左外边距<br>初始值：0.vp。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func layoutWeight(?Int32)

```cangjie
func layoutWeight(value: ?Int32): T
```

**功能：** 设置组件的布局权重。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Int32|是|-|组件的布局权重<br>初始值：0。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func aspectRatio(Float64)

```cangjie
func aspectRatio(value: Float64): T
```

**功能：** 设置组件的宽高比。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|Float64|是|-|组件的宽高比|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func displayPriority(?Int32)

```cangjie
func displayPriority(value: ?Int32): T
```

**功能：** 设置组件的显示优先级。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Int32|是|-|组件的显示优先级<br>初始值：1。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|
