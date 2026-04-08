# 触摸热区设置

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

设置组件的响应热区。在ArkUI开发框架中，处理触屏事件和鼠标事件时，会在事件触发前进行按压点与组件响应热区的触摸测试，以收集需响应事件的组件。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func responseRegion(?Rectangle)

```cangjie
func responseRegion(value: ?Rectangle): T
```

**功能：** 设置组件的响应区域。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[Rectangle](./cj-common-types.md#class-rectangle)|是|-|组件的响应区域<br>初始值：[Rectangle()]。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|

## func responseRegion(?Array\<Rectangle>)

```cangjie
func responseRegion(value: ?Array<Rectangle>): T
```

**功能：** 设置组件的响应区域数组。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Array\<[Rectangle](./cj-common-types.md#class-rectangle)>|是|-|组件的响应区域数组<br>初始值：[Rectangle()]。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|
