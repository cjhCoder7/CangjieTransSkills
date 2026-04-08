# 悬浮事件

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

光标滑动或手写笔在屏幕上悬浮移动扫过组件时触发。

> **说明：**
>
> 目前支持通过外接鼠标、手写笔以及触控板触发。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func onHover(?(Bool) -> Unit)

```cangjie
func onHover(event: ?(Bool) -> Unit): T
```

**功能：** 鼠标进入或退出组件时，触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?(Bool) -> Unit|是|-|回调函数，鼠标进入或退出组件时触发的回调。<br>鼠标进入时为true，退出时为false。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|