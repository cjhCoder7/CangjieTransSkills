# 组件内容模糊

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

为当前组件添加内容模糊效果。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func foregroundBlurStyle(?BlurStyle)

```cangjie
func foregroundBlurStyle(value: ?BlurStyle): T
```

**功能：** 为当前组件提供内容模糊能力。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|名称|类型|必填|默认值|说明|
| :-------   | :---------- | :------- | :-------- | :----------|
| value | ?[BlurStyle](./cj-common-types.md#enum-blurstyle) |是|-| 内容模糊样式。 <br/>初始值：BlurStyle.None。 |

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|

## func foregroundBlurStyle(?BlurStyle, ?ForegroundBlurStyleOptions)

```cangjie
func foregroundBlurStyle(value: ?BlurStyle, options: ?ForegroundBlurStyleOptions): T
```

**功能：** 为当前组件提供内容模糊能力。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|名称|类型|必填|默认值|说明|
| :-------   | :---------- | :------- | :-------- | :----------|
| value | ?[BlurStyle](./cj-common-types.md#enum-blurstyle) |是|-| 内容模糊样式。 |
| options | ?[ForegroundBlurStyleOptions](./cj-common-types.md#class-foregroundblurstyleoptions) |是|-| 内容模糊选项。 |

**返回值：**

|类型|说明|
|:---|:---|
|T|返回调用此接口的组件实例本身。|
