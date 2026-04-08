# 组件内容填充方式

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

用于决定在组件的宽高动画过程中，如何将动画最终的组件内容绘制在组件上。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func renderFit(?RenderFit)

```cangjie
func renderFit(fitMode: ?RenderFit): T
```

**功能：** 设置宽高动画过程中的组件内容填充方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
| fitMode | ?[RenderFit](./cj-common-types.md#enum-renderfit)  | 是  | - | 宽高动画过程中的组件内容填充方式。 <br/>初始值：RenderFit.TopLeft。|

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|
