# StepperItem

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

用作[Stepper](cj-navigation-switching-stepper.md)组件的页面子组件。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

支持单个子组件。

## 创建组件

### init(() -> Unit)

```cangjie
public init(child: () -> Unit)
```

**功能：** 创建[Stepper](cj-navigation-switching-stepper.md)组件的页面子组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|child|() -> Unit|是|-|StepperItem的子组件。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func nextLabel(?String)

```cangjie
public func nextLabel(value: ?String): This
```

**功能：** 设置右侧文本按钮内容，最后一页默认值为"开始"，其余页默认值为"下一步"。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?String|是|-|右侧文本按钮内容。字符串超长时，先缩小再换行（2行）最后截断。<br>初始值：""。|

### func prevLabel(?String)

```cangjie
public func prevLabel(value: ?String): This
```

**功能：** 设置左侧文本按钮内容，第一页没有左侧文本按钮，当步骤导航器大于一页时，除第一页外默认值都为"返回"。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?String|是|-|左侧文本按钮内容。字符串超长时，先缩小再换行（2行）最后截断。<br>初始值：""。|

### func status(?ItemState)

```cangjie
public func status(status!: ?ItemState = None): This
```

**功能：** 设置步骤导航器nextLabel的显示状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|status|?[ItemState](./cj-common-types.md#enum-itemstate)|否|None| **命名参数。** 步骤导航器nextLabel的显示状态。<br>初始值：ItemState.Normal。|

> **说明：**
>
> - StepperItem组件不支持设置通用宽度属性，其宽度默认撑满Stepper父组件。
> - StepperItem组件不支持设置通用高度属性，其高度由Stepper父组件高度减去label按钮组件高度。

## 示例代码

见[Stepper](cj-navigation-switching-stepper.md)