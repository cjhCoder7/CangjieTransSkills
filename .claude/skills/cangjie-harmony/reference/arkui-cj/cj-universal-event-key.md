# 按键事件

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

按键事件指组件与键盘、遥控器等按键设备交互时触发的事件，适用于所有可获焦组件，例如Button。对于Text和Image等默认不可获焦的组件，当前暂不支持，后续可以设置focusable属性为true后使用按键事件。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func onKeyEvent(?(KeyEvent) -> Unit)

```cangjie
func onKeyEvent(event: ?(KeyEvent) -> Unit): T
```

**功能：** 绑定该方法的组件获焦后，按键动作触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?([KeyEvent](./cj-common-types.md#class-keyevent)) -> Unit|是|-|绑定该方法的组件获焦后，按键动作触发该回调。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回通用方法接口类型。|