# 边框设置

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

设置组件边框样式。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func border(?Length, ?ResourceColor, ?Length, ?BorderStyle)

```cangjie
func border(width!: ?Length, color!: ?ResourceColor, radius!: ?Length,
    style!: ?BorderStyle): T
```

**功能：** 设置组件的边框样式。

> **说明：**
>
> 当color、radius缺省时，为了保证[borderColor](#func-bordercolorresourcecolor)、[borderRadius](#func-borderradiuslength)设置生效，需要将borderColor、borderRadius设置在[border](#func-borderlength-resourcecolor-length-borderstyle)后。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|width|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 边框宽度。初始值：0.vp|
|color|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|**命名参数。** 边框颜色。初始值：Color.Black|
|radius|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 边框圆角半径。初始值：0.vp|
|style|?[BorderStyle](./cj-common-types.md#enum-borderstyle)|是|-|**命名参数。** 边框样式。初始值：BorderStyle.Solid|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func borderColor(?ResourceColor)

```cangjie
func borderColor(value: ?ResourceColor): T
```

**功能：** 设置组件的边框颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor) |是|-|边框颜色。初始值：Color.Black|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func borderRadius(?Length)

```cangjie
func borderRadius(value: ?Length): T
```

**功能：** 设置组件的圆角半径。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|圆角半径。初始值：0.0.vp|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func borderRadius(?Length, ?Length, ?Length, ?Length)

```cangjie
func borderRadius(topLeft!: ?Length, topRight!: ?Length, bottomLeft!: ?Length,
    bottomRight!: ?Length): T
```

**功能：** 设置组件的四个角的圆角半径。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|topLeft|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 左上角圆角半径。初始值：0.vp|
|topRight|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 右上角圆角半径。初始值：0.vp|
|bottomLeft|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 左下角圆角半径。初始值：0.vp|
|bottomRight|?[Length](./cj-common-types.md#interface-length)|是|-|**命名参数。** 右下角圆角半径。初始值：0.vp|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func borderStyle(?BorderStyle)

```cangjie
func borderStyle(value: ?BorderStyle): T
```

**功能：** 设置组件的边框样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[BorderStyle](./cj-common-types.md#enum-borderstyle)|是|-|边框样式值。初始值：BorderStyle.Solid|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func borderWidth(?EdgeWidths)

```cangjie
func borderWidth(value: ?EdgeWidths): T
```

**功能：** 设置组件的边框宽度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[EdgeWidths](./cj-common-types.md#class-edgewidths)|是|-|边缘宽度。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func borderWidth(?Length)

```cangjie
func borderWidth(value: ?Length): T
```

**功能：** 设置组件的边框宽度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Length](./cj-common-types.md#interface-length)|是|-|边框宽度。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|
