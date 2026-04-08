# 点击事件

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

点击事件指组件被点击时触发的事件。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func onClick(?(ClickEvent) -> Unit)

```cangjie
func onClick(event: ?(ClickEvent) -> Unit): T
```

**功能：** 组件被点击时触发的事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?([ClickEvent](./cj-common-types.md#class-clickevent)) -> Unit|是|-|回调函数，组件被点击时触发该回调。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|