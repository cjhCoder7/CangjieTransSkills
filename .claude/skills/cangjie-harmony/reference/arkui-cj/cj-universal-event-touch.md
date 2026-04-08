# 触摸事件

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

当手指在组件上按下、滑动、抬起时触发。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func onTouch(?(TouchEvent) -> Unit)

```cangjie
func onTouch(event: ?(TouchEvent) -> Unit): T
```

**功能：** 手指触摸动作触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?([TouchEvent](./cj-common-types.md#class-touchevent)) -> Unit|是|-|回调函数，手指触摸动作触发该回调。<br>初始值：{ _: TouchEvent => }。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|