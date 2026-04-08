# 鼠标事件

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

在单个动作触发多个事件时，事件的顺序是固定的，鼠标事件默认透传。

> **说明：**
>
> 目前仅支持通过外接鼠标触发。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func onMouse(?(MouseEvent) -> Unit)

```cangjie
func onMouse(event: ?(MouseEvent) -> Unit): T
```

**功能：** 当前组件被鼠标按键点击时或者鼠标在组件上移动时，触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?([MouseEvent](./cj-common-types.md#class-mouseevent)) -> Unit|是|-|组件被鼠标按键点击时或者鼠标在组件上移动时触发该回调。MouseEvent参数包含触发事件时的时间戳、鼠标按键、动作、点击触点在整个屏幕上的坐标和点击触点相对于当前组件的坐标。<br>初始值：{ _: MouseEvent => }。|

**返回值：**

| 类型 | 说明 |
| :--- | :--- |
| T | 返回通用方法接口类型。 |