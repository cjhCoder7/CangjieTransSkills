# 框架接口

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

本页面描述UI框架使用的公开接口。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## func bind((CustomView) -> ViewBuilder, CustomView)

```cangjie
public func bind(builder: (CustomView) -> ViewBuilder, thisView: CustomView): () -> Unit
```

**功能：** 用于将@Builder修饰的函数与自定义组件对象进行绑定。详情见bind函数使用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|builder|([CustomView](#class-customview))->ViewBuilder|是|-|[@Builder](../../arkui-cj/paradigm/cj-macro-builder.md)修饰的函数类型。|
|thisView|[CustomView](#class-customview)|是|-|当前自定义组件对象（一般为this）。|

**返回值：**

|类型|说明|
|:----|:----|
|() -> Unit|返回builder函数。|

> **说明：**
>
> bind推荐在使用属性[title](./cj-navigation-switching-navdestination.md#func-titlecustombuilder-navigationtitleoptions)、[tabBar](./cj-navigation-switching-tabcontent.md#func-tabbarcustombuilder)以及构造[MenuItemGroup对象](./cj-menu-menuitemgroup.md#initcustombuilder-custombuilder----unit)时使用。

## func bind\<T1>((CustomView,ObservedProperty\<T1>) -> ViewBuilder, CustomView)

```cangjie
public func bind<T1>(builder: (CustomView, ObservedProperty<T1>) -> ViewBuilder, thisView: CustomView): (T1) -> Unit
```

**功能：** 用于将@Builder修饰的函数与自定义组件对象进行绑定。详情见bind函数使用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|builder|([CustomView](#class-customview),ObservedProperty\<T1>)->ViewBuilder|是|-|[@Builder](../../arkui-cj/paradigm/cj-macro-builder.md)修饰的函数类型。|
|thisView|[CustomView](#class-customview)|是|-|当前自定义组件对象（一般为this）。|

**返回值：**

|类型|说明|
|:----|:----|
|(T1) -> Unit|返回builder函数。|

> **说明：**
>
> bind推荐在使用属性[title](./cj-navigation-switching-navdestination.md#func-titlecustombuilder-navigationtitleoptions)、[tabBar](./cj-navigation-switching-tabcontent.md#func-tabbarcustombuilder)以及构造[MenuItemGroup对象](./cj-menu-menuitemgroup.md#initcustombuilder-custombuilder----unit)时使用。

## func bind\<T1, T2>((CustomView,ObservedProperty\<T1>,ObservedProperty\<T2>) -> ViewBuilder, CustomView)

```cangjie
public func bind<T1, T2>(
    builder: (CustomView, ObservedProperty<T1>, ObservedProperty<T2>) -> ViewBuilder,
    thisView: CustomView
): (T1, T2) -> Unit
```

**功能：** 用于将@Builder修饰的函数与自定义组件对象进行绑定。详情见bind函数使用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|builder|([CustomView](#class-customview),ObservedProperty\<T1>,ObservedProperty\<T2>)->ViewBuilder|是|-|[@Builder](../../arkui-cj/paradigm/cj-macro-builder.md)修饰的函数类型。|
|thisView|[CustomView](#class-customview)|是|-|当前自定义组件对象（一般为this）。|

**返回值：**

|类型|说明|
|:----|:----|
|(T1, T2) -> Unit|返回builder函数。|

> **说明：**
>
> bind推荐在使用属性[title](./cj-navigation-switching-navdestination.md#func-titlecustombuilder-navigationtitleoptions)、[tabBar](./cj-navigation-switching-tabcontent.md#func-tabbarcustombuilder)以及构造[MenuItemGroup对象](./cj-menu-menuitemgroup.md#initcustombuilder-custombuilder----unit)时使用。

## func bind\<T1, T2, T3>((CustomView,ObservedProperty\<T1>,ObservedProperty\<T2>,ObservedProperty\<T3>) -> ViewBuilder, CustomView)

```cangjie
public func bind<T1, T2, T3>(builder: (CustomView, ObservedProperty<T1>, ObservedProperty<T2>,
    ObservedProperty<T3>) -> ViewBuilder, thisView: CustomView)
```

**功能：** 用于将@Builder修饰的函数与自定义组件对象进行绑定。详情见bind函数使用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|builder|([CustomView](#class-customview),ObservedProperty\<T1>,ObservedProperty\<T2>,ObservedProperty\<T3>)->ViewBuilder|是|-|[@Builder](../../arkui-cj/paradigm/cj-macro-builder.md)修饰的函数类型。|
|thisView|[CustomView](#class-customview)|是|-|当前自定义组件对象（一般为this）。|

> **说明：**
>
> bind推荐在使用属性[title](./cj-navigation-switching-navdestination.md#func-titlecustombuilder-navigationtitleoptions)、[tabBar](./cj-navigation-switching-tabcontent.md#func-tabbarcustombuilder)以及构造[MenuItemGroup对象](./cj-menu-menuitemgroup.md#initcustombuilder-custombuilder----unit)时使用。


## class RemoteView

```cangjie
public abstract class RemoteView {
    public init()
}
```

**功能：** UI框架使用的组件基础类。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

> **说明：**
>
> 该类型仅供框架内部使用，应用开发者请勿使用，否则可能产生不可预期的行为。

### init()

```cangjie
public init()
```

**功能：** 构造一个RemoteView类型的对象，仅在UI框架场景下有效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

> **说明：**
>
> 该接口仅供框架内部使用，应用开发者请勿调用，否则可能产生不可预期的行为。

### func build()

```cangjie
public func build(): Unit
```

**功能：** 用于定义自定义组件的声明式UI描述，自定义组件必须定义build()函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## class CustomView

```cangjie
public abstract class CustomView <: RemoteView {
}
```

**功能：** UI框架使用的组件基础类。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [RemoteView](#class-remoteview)

> **说明：**
>
> 该类型仅供框架内部使用，应用开发者请勿使用，否则可能产生不可预期的行为。

### func getLocalStorage()

```cangjie
public func getLocalStorage(): LocalStorage
```

**功能：** 获取LocalStorage实例。仅供UI框架使用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[LocalStorage](./cj-state-rendering-appstatemanagement.md#class-localstorage)|持久化存储对象。|

> **说明：**
>
> 该接口仅供框架内部使用，应用开发者请勿调用，否则可能产生不可预期的行为。

### func build()

```cangjie
public func build(): Unit
```

**功能：** 用于定义自定义组件的声明式UI描述，自定义组件必须定义build()函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func aboutToBeDeleted()

```cangjie
public func aboutToBeDeleted(): Unit
```

**功能：** 组件销毁阶段由框架自动触发。仅供UI框架使用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

> **说明：**
>
> 该接口仅供框架内部使用，应用开发者请勿调用，否则可能产生不可预期的行为。

### func getUIContext()

```cangjie
public func getUIContext(): UIContext
```

**功能：** 获取UIContext对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[UIContext](./cj-apis-uicontext-uicontext.md#class-uicontext)|UI上下文。|

> **说明：**
>
> 该接口仅供框架内部使用，应用开发者请勿调用，否则可能产生不可预期的行为。
