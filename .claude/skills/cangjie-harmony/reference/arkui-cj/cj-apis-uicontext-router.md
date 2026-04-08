# Router

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

提供通过不同的URL访问不同的页面，包括跳转到应用内的指定页面、同一应用内的某个页面替换当前页面、返回上一页面或指定的页面等功能。

> **说明：**
>
> 以下API需先使用[UIContext](./cj-apis-uicontext-uicontext.md#class-uicontext)中的[getRouter()](./cj-apis-uicontext-uicontext.md#func-getrouter)方法获取到Router对象，再通过该对象调用对应方法。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## class Router

```cangjie
public class Router {}
```

**功能：** 路由类，提供跳转到应用内的指定页面、返回上一页面或指定的页面等功能。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func pushUrl(String,String)

```cangjie
public func pushUrl(url!: String, params!: String = ""): Unit
```

**功能：** 跳转到应用内的指定页面。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|url|String|是|-|**命名参数。** 表示目标页面的url。|
|params|String|否|""|**命名参数。** 表示路由跳转时要同时传递到目标页面的数据，切换到其他页面时，当前接收的数据失效。跳转到目标页面后，使用getParams()获取传递的参数。|

### func back(?String,String)

```cangjie
public func back(url!: ?String = None, params!: String = ""): Unit
```

**功能：** 返回上一页面或指定的页面。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|url|?String|否|None|**命名参数。** 表示目标页面的url。|
|params|String|否|""|**命名参数。** 页面返回时携带的参数。|

### func back(Int32,String)

```cangjie
public func back(index!: Int32, params!: String = ""): Unit
```

**功能：** 返回指定的页面。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|index|Int32|是|-| **命名参数。** 跳转目标页面的索引值。取值范围：[0, +∞)|
|params|String|否|""| **命名参数。** 页面返回时携带的参数。|

### func getParams()

```cangjie
public func getParams(): Option<String>
```

**功能：** 获取发起跳转的页面往当前页传入的参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Option\<String>|发起跳转的页面往当前页传入的参数。|

## class RouterState

```cangjie
public class RouterState {
    public var index: Int32
    public var name: String
    public var path: String
    public var params: String
    public init(
        index!: Int32,
        name!: String,
        path!: String,
        params!: String
    )
}
```

**功能：** 页面状态信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var index

```cangjie
public var index: Int32
```

**功能：** 表示当前页面在页面栈中的索引。从栈底到栈顶，index从1开始递增。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var name

```cangjie
public var name: String
```

**功能：** 表示当前页面的名称，即对应文件名。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var path

```cangjie
public var path: String
```

**功能：** 表示当前页面的路径。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var params

```cangjie
public var params: String
```

**功能：** 表示当前页面携带的参数。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(Int32, String, String, String)

```cangjie
public init(
    index!: Int32,
    name!: String,
    path!: String,
    params!: String
)
```

**功能：** 创建RouterState对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|index|Int32|是|-|**命名参数。** 表示当前页面在页面栈中的索引。从栈底到栈顶，index从1开始递增。|
|name|String|是|-|**命名参数。** 表示当前页面的名称，即对应文件名。|
|path|String|是|-|**命名参数。** 表示当前页面的路径。|
|params|String|是|-|**命名参数。** 表示当前页面携带的参数。|

## enum RouterMode

```cangjie
public enum RouterMode <: Equatable<RouterMode> {
    | Standard
    | Single
    | ...
}
```

**功能：** 路由跳转模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[RouterMode](#enum-routermode)>

### Standard

```cangjie
Standard
```

**功能：** 多实例模式，也是默认情况下的跳转模式。目标页面会被添加到页面栈顶，无论栈中是否存在相同url的页面。不使用路由跳转模式时，则按照默认的多实例模式进行跳转。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Single

```cangjie
Single
```

**功能：** 单实例模式。如果目标页面的url已经存在于页面栈中，则该url页面移动到栈顶。如果目标页面的url在页面栈中不存在同url页面，则按照默认的多实例模式进行跳转。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func !=(RouterMode)

```cangjie
public operator func !=(other: RouterMode): Bool
```

**功能：** 比较两个枚举值是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[RouterMode](#enum-routermode)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值不相等则返回true，否则返回false。|

### operator func ==(RouterMode)

```cangjie
public operator func ==(other: RouterMode): Bool
```

**功能：** 比较两个枚举值是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[RouterMode](#enum-routermode)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值相等则返回true，否则返回false。|
