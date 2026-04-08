# NavDestination

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

作为子页面的根容器，用于显示[Navigation](./cj-navigation-switching-navigation.md)的内容区。

> **说明：**
>
> - NavDestination组件必须配合Navigation使用，作为Navigation目的页面的根节点，单独使用只能作为普通容器组件，不具备路由相关属性能力。
> - 如果页面栈中间页面的生命周期发生变化，跳转之前的栈顶Destination的生命周期(onWillShow, onShown, onHidden, onWillDisappear)与跳转之后的栈顶Destination的生命周期(onWillShow, onShown, onHidden, onWillDisappear)均在最后触发。
> - NavDestination未设置主副标题并且没有返回键时，不显示标题栏。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 子组件

可以包含子组件。

## 创建组件

### init(() -> Unit)

```cangjie
public init(child!: () -> Unit = { => })
```

**功能：** 构造一个NavDestination容器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|child|() -> Unit|否|{ => }|**命名参数。** NavDestination容器的子组件。|

## 通用属性/通用事件

通用属性：支持通用属性。

不推荐设置位置、大小等布局相关属性，可能会造成页面显示异常。

通用事件：全部支持。

## 组件属性

### func hideTitleBar(?Bool)

```cangjie
public func hideTitleBar(value: ?Bool): This
```

**功能：** 指定是否隐藏标题栏。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|是否隐藏标题栏。初始值：false。|

### func title(?CustomBuilder, ?NavigationTitleOptions)

```cangjie
public func title(value: ?CustomBuilder, options!: ?NavigationTitleOptions = None): This
```

**功能：** 设置页面标题。当NavigationCustomTitle类型用于设置高度时，titleMode属性不生效。当标题字符串过长时：(1)未设置副标题时，字符串会缩小、换两行，再截断加省略号(...); (2)设置副标题时，副标题会缩小再截断加省略号(...)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[CustomBuilder](./cj-common-types.md#type-custombuilder)|是|-|页面标题。初始值：{=>}。|
|options|?[NavigationTitleOptions](./cj-navigation-switching-navigation.md#class-navigationtitleoptions)|否|None|**命名参数。** 标题栏选项。|

> **说明：**
>
> 传入[CustomBuilder](./cj-common-types.md#type-custombuilder)类型的参数时，需使用bind管理自定义构建函数的调用，bind使用方式请参见[框架接口](./cj-ui-framework.md)中的bind函数说明。

### func title(?ResourceStr, ?NavigationTitleOptions)

```cangjie
public func title(value: ?ResourceStr, options!: ?NavigationTitleOptions = None): This
```

**功能：** 设置页面标题。当NavigationCustomTitle类型用于设置高度时，titleMode属性不生效。当标题字符串过长时：(1)未设置副标题时，字符串会缩小、换两行，再截断加省略号(...); (2)设置副标题时，副标题会缩小再截断加省略号(...)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|页面标题。<br>初始值：{=>}。|
|options|?[NavigationTitleOptions](./cj-navigation-switching-navigation.md#class-navigationtitleoptions)|否|None|**命名参数。** 标题栏选项。|

## 组件事件

### func onBackPressed(?() -> Bool)

```cangjie
public func onBackPressed(callback: ?() -> Bool): This
```

**功能：** 当与Navigation绑定的页面栈中存在内容时，此回调生效。当点击返回键时，触发该事件。返回值为true时，表示重写返回键逻辑，返回值为false时，表示回退到上一个页面。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?() -> Bool|是|-|回调函数，当点击返回键时，触发该回调。返回值为true时，表示重写返回键逻辑，返回值为false时，表示回退到上一个页面。初始值：{ => true }。|

### func onReady(?Callback\<NavDestinationContext, Unit>)

```cangjie
public func onReady(callback: ?Callback<NavDestinationContext, Unit>): This
```

**功能：** 当NavDestination即将构建子组件之前会触发此事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[Callback](./cj-common-types.md#type-callbackt-v)\<[NavDestinationContext](#class-navdestinationcontext), Unit>|是|-|回调函数，即将构建子组件之前会触发此回调。初始值：{ _ => }。|

## 基础类型定义

### class NavDestinationContext

```cangjie
public class NavDestinationContext {
    public var pathInfo: NavPathInfo
    public var pathStack: NavPathStack
    public var navDestinationId: String
}
```

**功能：** NavDestination上下文信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var navDestinationId

```cangjie
public var navDestinationId: String
```

**功能：** 当前NavDestination的唯一ID，由系统自动生成，和组件通用属性id无关。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var pathInfo

```cangjie
public var pathInfo: NavPathInfo
```

**功能：** 跳转NavDestination时指定的参数。

**类型：** [NavPathInfo](./cj-navigation-switching-navigation.md#class-navpathinfo)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var pathStack

```cangjie
public var pathStack: NavPathStack
```

**功能：** 当前NavDestination所处的页面栈。

**类型：** [NavPathStack](./cj-navigation-switching-navigation.md#class-navpathstack)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## 示例代码

NavDestination用法可参考[Navigation示例](./cj-navigation-switching-navigation.md#示例代码)。