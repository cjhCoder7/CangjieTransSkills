# Navigation

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

Navigation组件是路由导航的根视图容器，一般作为Page页面的根容器使用，其内部默认包含了标题栏、内容区和工具栏，其中内容区默认首页显示导航内容（Navigation的子组件）或非首页显示（[NavDestination](./cj-navigation-switching-navdestination.md)的子组件），首页和非首页通过路由进行切换。

> **说明：**
>
> - Navigation嵌套使用Navigation时，内层Navigation的生命周期不和外层Navigation以及[全模态](./cj-universal-attribute-bindcontentcover.md)的生命周期进行联动。
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

**功能：** 构造一个包含子组件的Navigation容器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|child|() -> Unit|否|{ => }|**命名参数。** Navigation容器的子组件。|

### init(?NavPathStack, () -> Unit)

```cangjie
public init(pathInfos: ?NavPathStack, child!: () -> Unit = { => })
```

**功能：** 构造一个包含子组件的Navigation容器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|pathInfos|?[NavPathStack](#class-navpathstack)|是|- |绑定到Navigation组件的路由栈。|
|child|() -> Unit|否|{ => }|**命名参数。** Navigation容器的子组件。|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func hideTitleBar(?Bool, ?Bool)

```cangjie
public func hideTitleBar(hide: ?Bool, animated!: ?Bool = None): This
```

**功能：** 设置是否隐藏标题栏。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|hide|?Bool|是|-|是否隐藏标题栏。初始值：false。|
|animated|?Bool|否|None|**命名参数。** 是否使用动画显隐标题栏。初始值：false。|

### func navDestination(?(String, Any) -> Unit)

```cangjie
public func navDestination(builder: ?(String, Any) -> Unit): This
```

**功能：** 创建NavDestination组件。使用builder函数，基于name构造NavDestination组件。builder下只能有一个根节点。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|builder|?(String, Any) -> Unit|是|-|NavDestination组件。<br/>参数一：NavDestination页面名称。<br/>参数二：开发者设置的NavDestination页面详细参数，当前不支持此参数设置（设置后不生效）。<br/>初始值：{ _: String, _: Any => }。|

### func title(?CustomBuilder, ?NavigationTitleOptions)

```cangjie
public func title(value: ?CustomBuilder, options!: ?NavigationTitleOptions = None): This
```

**功能：** 设置页面标题。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[CustomBuilder](./cj-common-types.md#type-custombuilder)|是|-|页面标题。初始值：{ => }。|
|options|?[NavigationTitleOptions](#class-navigationtitleoptions)|否|None|**命名参数。** 标题栏选项。|

> **说明：**
>
> 传入[CustomBuilder](./cj-common-types.md#type-custombuilder)类型的参数时，需使用bind管理自定义构建函数的调用，bind使用方式请参见[框架接口](./cj-ui-framework.md)中的bind函数说明。

### func title(?ResourceStr, ?NavigationTitleOptions)

```cangjie
public func title(value: ?ResourceStr, options!: ?NavigationTitleOptions = None): This
```

**功能：** 设置页面标题。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|页面标题。初始值：""。|
|options|?[NavigationTitleOptions](#class-navigationtitleoptions)|否|None|**命名参数。** 标题栏选项。|

## 基础类型定义

### class NavigationOptions

```cangjie
public class NavigationOptions {
    public var launchMode: ?LaunchMode
    public var animated: ?Bool
    public init(launchMode!: ?LaunchMode = None, animated!: ?Bool = None)
}
```

**功能：** 表示栈操作的选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var animated

```cangjie
public var animated: ?Bool
```

**功能：** 是否支持过渡动画。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var launchMode

```cangjie
public var launchMode: ?LaunchMode
```

**功能：** 导航栈操作模式。

**类型：** ?[LaunchMode](#enum-launchmode)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?LaunchMode, ?Bool)

```cangjie
public init(launchMode!: ?LaunchMode = None, animated!: ?Bool = None)
```

**功能：** NavigationOptions的构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|launchMode|?[LaunchMode](#enum-launchmode)|否|None|导航栈操作模式。初始值：LaunchMode.Standard。|
|animated|?Bool|否|None|是否支持过渡动画。初始值：true。|

### class NavigationTitleOptions

```cangjie
public class NavigationTitleOptions {
    public var backgroundColor: ?ResourceColor
    public var backgroundBlurStyle: ?BlurStyle
    public var barStyle: ?BarStyle
    public var paddingStart: ?Length
    public var paddingEnd: ?Length
    public init(backgroundColor!: ?ResourceColor = None, backgroundBlurStyle!: ?BlurStyle = None,
        barStyle!: ?BarStyle = None, paddingStart!: ?Length = None, paddingEnd!: ?Length = None
    )
}
```

**功能：** Navigation标题栏的选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var backgroundBlurStyle

```cangjie
public var backgroundBlurStyle: ?BlurStyle
```

**功能：** 标题栏的背景模糊样式。如果未设置此参数，则禁用背景模糊效果。

**类型：** ?[BlurStyle](./cj-common-types.md#enum-blurstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var backgroundColor

```cangjie
public var backgroundColor: ?ResourceColor
```

**功能：** 标题栏的背景颜色。如果未设置此参数，则使用默认颜色。

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var barStyle

```cangjie
public var barStyle: ?BarStyle
```

**功能：** 标题栏的布局样式。

**类型：** ?[BarStyle](#enum-barstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var paddingEnd

```cangjie
public var paddingEnd: ?Length
```

**功能：** 设置标题栏结束边距。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var paddingStart

```cangjie
public var paddingStart: ?Length
```

**功能：** 设置标题栏起始边距。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?ResourceColor, ?BlurStyle, ?BarStyle, ?Length, ?Length)

```cangjie
public init(backgroundColor!: ?ResourceColor = None, backgroundBlurStyle!: ?BlurStyle = None,
    barStyle!: ?BarStyle = None, paddingStart!: ?Length = None, paddingEnd!: ?Length = None)
```

**功能：** NavigationTitleOptions的构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|backgroundColor|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|None|标题栏背景颜色。|
|backgroundBlurStyle|?[BlurStyle](./cj-common-types.md#enum-blurstyle)|否|None|标题栏背景模糊样式。|
|barStyle|?[BarStyle](#enum-barstyle)|否|None|标题栏布局样式。初始值：BarStyle.Standard。|
|paddingStart|?[Length](./cj-common-types.md#interface-length)|否|None|标题栏起始边距。|
|paddingEnd|?[Length](./cj-common-types.md#interface-length)|否|None|标题栏结束边距。|

### class NavPathInfo

```cangjie
public class NavPathInfo {
    public var name: ?String
    public var param: ?String
    public var onPop: ?Callback<PopInfo, Unit> = None
    public init(name!: ?String, param!: ?String, onPop!: ?Callback<PopInfo, Unit> = None)
}
```

**功能：** 表示NavDestination的信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var name

```cangjie
public var name: ?String
```

**功能：** 导航目标页面的名称。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var onPop

```cangjie
public var onPop: ?Callback<PopInfo, Unit> = None
```

**功能：** 导航目标页面触发pop时的回调函数。

**类型：** ?[Callback](./cj-common-types.md#type-callbackt-v)\<[PopInfo](#class-popinfo), Unit>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var param

```cangjie
public var param: ?String
```

**功能：** 导航目标页面的详细参数。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?String, ?String, ?Callback\<PopInfo, Unit>)

```cangjie
public init(name!: ?String, param!: ?String, onPop!: ?Callback<PopInfo, Unit> = None)
```

**功能：** NavPathInfo的构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|?String|是|-|**命名参数。** NavDestination的名称。初始值：""。|
|param|?String|是|-|**命名参数。** NavDestination的详细参数。初始值：""。|
|onPop|?[Callback](./cj-common-types.md#type-callbackt-v)\<[PopInfo](#class-popinfo), Unit>|否|None|**命名参数。**  NavDestination页面触发pop时的回调函数。|

### class NavPathStack

```cangjie
public class NavPathStack {
    public init()
}
```

**功能：** 表示NavDestinations的信息。提供控制栈中目标页面的方法。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init()

```cangjie
public init()
```

**功能：** 创建NavPathStack的实例。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### func pop(?Bool)

```cangjie
public func pop(animated!: ?Bool = None): ?NavPathInfo
```

**功能：** 将顶部NavDestination弹出栈。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|animated|?Bool|否|None|**命名参数。** 是否支持过渡动画。初始值：true。|

**返回值：**

|类型|说明|
|:---|:---|
|?[NavPathInfo](#class-navpathinfo)|如果栈不为空则返回顶部NavPathInfo，否则返回None。|

#### func pushPath(?NavPathInfo, ?NavigationOptions)

```cangjie
public func pushPath(info: ?NavPathInfo, options!: ?NavigationOptions = None): Unit
```

**功能：** 将指定的NavDestination推入栈中。根据options参数中指定的launchMode，将触发不同的行为。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|info|?[NavPathInfo](#class-navpathinfo)|是|-|要推入的NavDestination。|
|options|?[NavigationOptions](#class-navigationoptions)|否|None|**命名参数。** 导航选项。|

#### func pushPathByName(?String, ?String, ?Bool)

```cangjie
public func pushPathByName(name: ?String, param: ?String, animated!: ?Bool = None)
```

**功能：** 将指定的NavDestination推入栈中。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|?String|是|-|要推入的NavDestination的名称。初始值：""。|
|param|?String|是|-|要推入的NavDestination的详细参数。初始值：""。|
|animated|?Bool|否|None|**命名参数。** 是否支持过渡动画。|

### class PopInfo

```cangjie
public class PopInfo {
    public let info: NavPathInfo
    public let result: String
}
```

**功能：** 表示弹出页面的信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### let info

```cangjie
public let info: NavPathInfo
```

**功能：** 导航路径信息。

**类型：** [NavPathInfo](#class-navpathinfo)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### let result

```cangjie
public let result: String
```

**功能：** 弹出操作的结果。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### enum BarStyle

```cangjie
public enum BarStyle <: Equatable<BarStyle> {
    | Standard
    | Stack
    | ...
}
```

**功能：** 标题栏或工具栏的布局样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[BarStyle](#enum-barstyle)>

#### Stack

```cangjie
Stack
```

**功能：** 在此模式下，标题栏或工具栏在内容区域上层叠加布局。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### Standard

```cangjie
Standard
```

**功能：** 在此模式下，标题栏或工具栏在内容区域上方布局。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### operator func !=(BarStyle)

```cangjie
public operator func !=(other: BarStyle): Bool
```

**功能：** 比较两个枚举值是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BarStyle](#enum-barstyle)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值不相等则返回true，否则返回false。|

#### operator func ==(BarStyle)

```cangjie
public operator func ==(other: BarStyle): Bool
```

**功能：** 比较两个枚举值是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BarStyle](#enum-barstyle)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值相等则返回true，否则返回false。|

### enum LaunchMode

```cangjie
public enum LaunchMode <: Equatable<LaunchMode> {
    | Standard
    | MoveToTopSingleTon
    | PopToSingleTon
    | NewInstance
    | ...
}
```

**功能：** 定义栈操作的模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[LaunchMode](#enum-launchmode)>

#### MoveToTopSingleTon

```cangjie
MoveToTopSingleTon
```

**功能：** 当具有指定名称的NavDestination存在时，将其移到栈顶，否则行为与Standard模式一致。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### NewInstance

```cangjie
NewInstance
```

**功能：** 此模式创建NavDestination实例。与Standard相比，此模式不会重用栈中同名实例。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### PopToSingleTon

```cangjie
PopToSingleTon
```

**功能：** 当具有指定名称的NavDestination存在时，栈将弹出直到该NavDestination，否则行为与Standard模式一致。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### Standard

```cangjie
Standard
```

**功能：** 默认导航栈操作模式。在此模式下，push操作将指定的NavDestination页面添加到栈中；replace操作替换当前顶部的NavDestination页面。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### operator func !=(LaunchMode)

```cangjie
public operator func !=(other: LaunchMode): Bool
```

**功能：** 比较两个枚举值是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[LaunchMode](#enum-launchmode)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值不相等则返回true，否则返回false。|

#### operator func ==(LaunchMode)

```cangjie
public operator func ==(other: LaunchMode): Bool
```

**功能：** 比较两个枚举值是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[LaunchMode](#enum-launchmode)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值相等则返回true，否则返回false。|

## 示例代码

Navigation组件是路由导航的根视图容器。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Builder
func pageMap(name: String, param: Any) {
    if (name == "pageOne") {
        PageOne()
    } else {
        PageTwo()
    }
}

@Entry
@Component
class EntryView {
    @Provide
    var stack: NavPathStack = NavPathStack()

    func build() {
        Navigation(this.stack) {
            Stack(alignContent: Alignment.Center) {
                Button("push PageOne", ButtonOptions(shape: ButtonType.Capsule))
                .width(80.percent)
                .height(40)
                .onClick({ evt =>
                    this.stack.pushPath(NavPathInfo(name: "pageOne", param: "pageOne test"))
                })
            }
            .width(100.percent)
            .height(50.percent)
        }
        .title("PageHome")
        .navDestination(bind(pageMap, this))
    }
}

@Component
class PageOne {
    @Consume
    var stack: NavPathStack

    func build() {
        NavDestination() {
            Stack(alignContent: Alignment.Center) {
                Button("push PageTwo", ButtonOptions(shape: ButtonType.Capsule))
                .width(80.percent)
                .height(40)
                .onClick({ evt =>
                    this.stack.pushPathByName("pageTwo", "pageOne test")
                })
            }
            .width(100.percent)
            .height(50.percent)
        }
        .title("PageOne")
    }
}

@Component
class PageTwo {
    private var pathStack: NavPathStack = NavPathStack()

    func build() {
        NavDestination() {
            Stack(alignContent: Alignment.Center) {
                Button("pop PageOne", ButtonOptions(shape: ButtonType.Capsule))
                .width(80.percent)
                .height(40)
                .onClick({ evt =>
                    this.pathStack.pop()
                })
            }
            .width(100.percent)
            .height(50.percent)
        }
        .title("PageTwo")
        .onReady({ context =>
            this.pathStack = context.pathStack
        })
        .onBackPressed({ =>
            this.pathStack.pop()
            return true
        })
    }
}
```

![navigation](./figures/navigationExample1.gif)