# TabContent

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

仅在Tabs中使用，对应一个切换页签的内容视图。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

支持单个子组件。

> **说明：**
>
> 可内置系统组件和自定义组件，支持渲染控制类型（[if/else](../../arkui-cj/rendering_control/cj-rendering-control-ifelse.md)、[ForEach](cj-state-rendering-foreach.md)和[LazyForEach](cj-state-rendering-lazyforeach.md)）。

## 创建组件

### init()

```cangjie
public init()
```

**功能：** 创建一个不包含子组件的TabContent容器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(() -> Unit)

```cangjie
public init(child: () -> Unit)
```

**功能：** 创建一个包含子组件的TabContent容器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|child|()->Unit|是|-|声明容器内的子组件。|

## 通用属性/通用事件

通用属性：全部支持。

> **说明：**
>
> - TabContent组件不支持设置通用宽度属性，其宽度默认撑满Tabs父组件。
> - TabContent组件不支持设置通用高度属性，其高度由Tab父组件与TabBar组件高度决定。
> - vertical属性为false值，交换上述2个限制。
> - TabContent组件不支持内容过长时页面的滑动，如需页面滑动，可嵌套List使用。
> - 建议对Tabs组件的所有TabContent子组件的tabBar属性，采用统一的参数类型。
> - 若TabContent内部有可获焦组件，Tabs组件内TabContent组件和TabBar组件之间的走焦，仅支持通过键盘的方向键控制。

通用事件：全部支持。

## 组件属性

### func tabBar(?CustomBuilder)

```cangjie
public func tabBar(content: ?CustomBuilder): This
```

**功能：** 设置TabBar上显示内容。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|content|?[CustomBuilder](./cj-common-types.md#type-custombuilder)|是|-|TabBar上显示内容。初始值：{ => }。|

> **说明：**
>
> - 如果设置的内容超出TabBar提供的空间，则会被裁剪。
> - 传入[CustomBuilder](./cj-common-types.md#type-custombuilder)类型的参数时，需使用bind管理自定义构建函数的调用，bind使用方式请参见[框架接口](./cj-ui-framework.md)中的bind函数说明。

### func tabBar(?ResourceStr)

```cangjie
public func tabBar(content: ?ResourceStr): This
```

**功能：** 设置TabBar上显示内容。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|content|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|TabBar上显示内容。初始值：""。|

> **说明：**
>
> 如果设置的内容超出TabBar提供的空间，则会被裁剪。

### func tabBar(?ResourceStr, ?ResourceStr)

```cangjie
public func tabBar(icon!: ?ResourceStr = None, text!: ?ResourceStr = None): This
```

**功能：** 设置TabBar上显示内容。

> **说明：**
>
> - 底部标签样式不包含指示器。
> - 当图标显示错误时，会显示灰色空白块。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|icon|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None| **命名参数。** TabBar图标。初始值：""。|
|text|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None| **命名参数。** TabBar文本。初始值：""。|

## 示例代码

见[tabs](cj-navigation-switching-tabs.md)