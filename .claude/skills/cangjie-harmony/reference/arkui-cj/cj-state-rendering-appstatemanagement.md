# 应用级变量的状态管理

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

状态管理模块提供了应用程序的数据存储能力、持久化数据管理能力、UIAbility数据存储能力和应用程序需要的环境状态。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## class AppStorage

```cangjie
public class AppStorage {}
```

**功能：** AppStorage是应用全局的UI状态存储，是和应用的进程绑定的，由UI框架在应用程序启动时创建，为应用程序UI状态属性提供中央存储。与AppStorage中对应的propName建立单向属性绑定。如果给定的propName在AppStorage中存在，则返回与AppStorage中propName对应属性的单向绑定数据。如果AppStorage中不存在propName，则返回None。单向绑定数据的修改不会被同步回AppStorage中。

和页面级UI状态存储LocalStorage不同，AppStorage是应用级的全局UI状态存储，相当于整个应用的"中枢"，持久化数据PersistentStorage和环境变量Environment通过AppStorage中转，才可以和UI交互。

> **说明：**
>
> AppStorage仅支持纯仓颉场景，不支持用于ArkTS与仓颉混合开发场景。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### static func clear()

```cangjie
public static func clear(): Bool
```

**功能：** 删除AppStorage中所有的属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果AppStorage中的属性已经没有任何订阅者，则删除成功，并返回true。否则返回false。|

### static func delete(String)

```cangjie
public static func delete(propName: String): Bool
```

**功能：** 在AppStorage中删除propName对应的属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|AppStorage中的属性名。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果AppStorage中存在对应的属性，且该属性已经没有任何订阅者，则删除成功，并返回true。否则返回false。|

### static func get\<T>(String)

```cangjie
public static func get<T>(propName: String): ?T
```

**功能：** 获取AppStorage中propName对应的属性值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|AppStorage中的属性名。|

**返回值：**

|类型|说明|
|:----|:----|
|?T|返回AppStorage中对应属性的值，如果不存在则返回None。|

### static func has(String)

```cangjie
public static func has(propName: String): Bool
```

**功能：** 判断AppStorage中是否存在propName对应的属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|AppStorage中的属性名。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果AppStorage中存在对应的属性，则返回true，否则返回false。|

### static func keys()

```cangjie
public static func keys(): EquatableCollection<String>
```

**功能：** 获取AppStorage中所有属性的键名。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|EquatableCollection\<String>|返回AppStorage中所有属性的键名集合。|

### static func link\<T>(String)

```cangjie
public static func link<T>(propName: String): ?ObservedProperty<T>
```

**功能：** 与AppStorage中对应的propName建立双向属性绑定。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|AppStorage中的属性名。|

**返回值：**

|类型|说明|
|:----|:----|
|?ObservedProperty\<T>|返回双向绑定的数据，如果AppStorage中不存在对应的属性值，则返回None。|

### static func property\<T>(String)

```cangjie
public static func property<T>(propName: String): ?ObservedProperty<T>
```

**功能：** 与AppStorage中对应的propName建立单向属性绑定。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|AppStorage中的属性名。|

**返回值：**

|类型|说明|
|:----|:----|
|?ObservedProperty\<T>|返回单向绑定的数据，如果AppStorage中不存在对应的属性值，则返回None。|

### static func set\<T>(String, T)

```cangjie
public static func set<T>(propName: String, newValue: T): Bool
```

**功能：** 设置AppStorage中propName对应的属性值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|AppStorage中的属性名。|
|newValue|T|是|-|要设置的新值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果AppStorage中存在对应的属性，则设置成功并返回true，否则返回false。|

### static func setAndLink\<T>(String, T)

```cangjie
public static func setAndLink<T>(propName: String, defaultValue: T): ObservedProperty<T>
```

**功能：** 与AppStorage中对应的propName建立双向属性绑定，如果属性不存在则创建并初始化。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|AppStorage中的属性名。|
|defaultValue|T|是|-|属性的默认值。|

**返回值：**

|类型|说明|
|:----|:----|
|ObservedProperty\<T>|返回双向绑定的数据。|

### static func setAndProp\<T>(String, T)

```cangjie
public static func setAndProp<T>(propName: String, defaultValue: T): ObservedProperty<T>
```

**功能：** 与AppStorage中对应的propName建立单向属性绑定，如果属性不存在则创建并初始化。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|AppStorage中的属性名。|
|defaultValue|T|是|-|属性的默认值。|

**返回值：**

|类型|说明|
|:----|:----|
|ObservedProperty\<T>|返回单向绑定的数据。|

### static func setOrCreate\<T>(String, T)

```cangjie
public static func setOrCreate<T>(propName: String, newValue: T): Unit
```

**功能：** 设置AppStorage中propName对应的属性值，如果属性不存在则创建并初始化。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|AppStorage中的属性名。|
|newValue|T|是|-|要设置的新值。|

### static func size()

```cangjie
public static func size(): Int64
```

**功能：** 获取AppStorage中属性的数量。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Int64|返回AppStorage中属性的数量。|

## class Environment

```cangjie
public class Environment {}
```

**功能：** Environment是和应用的进程绑定的，由UI框架在应用程序启动时创建，为应用程序提供设备环境状态的中心存储。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### static func envProp\<T>(String, T)

```cangjie
public static func envProp<T>(key: String, defaultValue: T): Bool
```

**功能：** 创建一个与设备环境状态同步的属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|key|String|是|-|环境属性的键名。|
|defaultValue|T|是|-|属性的默认值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果创建成功则返回true，否则返回false。|

### static func keys()

```cangjie
public static func keys(): Array<String>
```

**功能：** 获取所有环境属性的键名。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<String>|返回所有环境属性的键名数组。|

## class LocalStorage

```cangjie
public class LocalStorage {
    public init()
}
```

**功能：** LocalStorage是页面级的UI状态存储，通过装饰器和AppStorage进行交互。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init()

```cangjie
public init()
```

**功能：** LocalStorage的构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func clear()

```cangjie
public func clear(): Bool
```

**功能：** 删除LocalStorage中所有的属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果LocalStorage中的属性已经没有任何订阅者，则删除成功，并返回true。否则返回false。|

### func delete(String)

```cangjie
public func delete(propName: String): Bool
```

**功能：** 在LocalStorage中删除propName对应的属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|LocalStorage中的属性名。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果LocalStorage中存在对应的属性，且该属性已经没有任何订阅者，则删除成功，并返回true。否则返回false。|

### func get\<T>(String)

```cangjie
public func get<T>(propName: String): ?T
```

**功能：** 获取LocalStorage中propName对应的属性值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|LocalStorage中的属性名。|

**返回值：**

|类型|说明|
|:----|:----|
|?T|返回LocalStorage中对应属性的值，如果不存在则返回None。|

### func has(String)

```cangjie
public func has(propName: String): Bool
```

**功能：** 判断LocalStorage中是否存在propName对应的属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|LocalStorage中的属性名。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果LocalStorage中存在对应的属性，则返回true，否则返回false。|

### func keys()

```cangjie
public func keys(): EquatableCollection<String>
```

**功能：** 获取LocalStorage中所有属性的键名。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|EquatableCollection\<String>|返回LocalStorage中所有属性的键名集合。|

### func link\<T>(String)

```cangjie
public func link<T>(propName: String): ?ObservedProperty<T>
```

**功能：** 与LocalStorage中对应的propName建立双向属性绑定。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|LocalStorage中的属性名。|

**返回值：**

|类型|说明|
|:----|:----|
|?ObservedProperty\<T>|返回双向绑定的数据，如果LocalStorage中不存在对应的属性值，则返回None。|

### func property\<T>(String)

```cangjie
public func property<T>(propName: String): ?ObservedProperty<T>
```

**功能：** 与LocalStorage中对应的propName建立单向属性绑定。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|LocalStorage中的属性名。|

**返回值：**

|类型|说明|
|:----|:----|
|?ObservedProperty\<T>|返回单向绑定的数据，如果LocalStorage中不存在对应的属性值，则返回None。|

### func set\<T>(String, T)

```cangjie
public func set<T>(propName: String, newValue: T): Bool
```

**功能：** 设置LocalStorage中propName对应的属性值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|LocalStorage中的属性名。|
|newValue|T|是|-|要设置的新值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果LocalStorage中存在对应的属性，则设置成功并返回true，否则返回false。|

### func setAndLink\<T>(String, T)

```cangjie
public func setAndLink<T>(propName: String, defaultValue: T): ObservedProperty<T>
```

**功能：** 与LocalStorage中对应的propName建立双向属性绑定，如果属性不存在则创建并初始化。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|LocalStorage中的属性名。|
|defaultValue|T|是|-|属性的默认值。|

**返回值：**

|类型|说明|
|:----|:----|
|ObservedProperty\<T>|返回双向绑定的数据。|

### func setAndProp\<T>(String, T)

```cangjie
public func setAndProp<T>(propName: String, defaultValue: T): ObservedProperty<T>
```

**功能：** 与LocalStorage中对应的propName建立单向属性绑定，如果属性不存在则创建并初始化。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|LocalStorage中的属性名。|
|defaultValue|T|是|-|属性的默认值。|

**返回值：**

|类型|说明|
|:----|:----|
|ObservedProperty\<T>|返回单向绑定的数据。|

### func setOrCreate\<T>(String, T)

```cangjie
public func setOrCreate<T>(propName: String, newValue: T): Bool
```

**功能：** 设置LocalStorage中propName对应的属性值，如果属性不存在则创建并初始化。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|propName|String|是|-|LocalStorage中的属性名。|
|newValue|T|是|-|要设置的新值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|操作成功返回true，否则返回false。|

### func size()

```cangjie
public func size(): Int64
```

**功能：** 获取LocalStorage中属性的数量。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Int64|返回LocalStorage中属性的数量。|

## class PersistentStorage

```cangjie
public class PersistentStorage {}
```

**功能：** PersistentStorage是持久化存储UI状态，通常和AppStorage配合使用，选择AppStorage中的属性持久化到文件中。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### static func deleteProp(String)

```cangjie
public static func deleteProp(key: String): Unit
```

**功能：** 删除持久化的属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|key|String|是|-|要删除的属性键名。|

### static func keys()

```cangjie
public static func keys(): Array<String>
```

**功能：** 获取所有持久化属性的键名。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<String>|返回所有持久化属性的键名数组。|

### static func persistProp\<T>(String, T)

```cangjie
public static func persistProp<T>(key: String, defaultValue: T): Unit
```

**功能：** 持久化指定的AppStorage属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|key|String|是|-|要持久化的属性键名。|
|defaultValue|T|是|-|属性的默认值。|

### static func persistProps\<T>(Array<(String, T)>)

```cangjie
public static func persistProps<T>(props: Array<(String, T)>): Unit
```

**功能：** 持久化多个AppStorage属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|props|Array\<(String, T)>|是|-|要持久化的属性键值对数组。|

## enum ColorMode

```cangjie
public enum ColorMode <: Equatable<ColorMode> {
    | Light
    | Dark
    | ...
}
```

**功能：** 定义设备的颜色模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ColorMode](#enum-colormode)>

### Light

```cangjie
Light
```

**功能：** 浅色模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Dark

```cangjie
Dark
```

**功能：** 深色模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func !=(ColorMode)

```cangjie
public operator func !=(other: ColorMode): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ColorMode](#enum-colormode)|是|-|要比较的另一个ColorMode实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(ColorMode)

```cangjie
public operator func ==(other: ColorMode): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ColorMode](#enum-colormode)|是|-|要比较的另一个ColorMode实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

## enum LayoutDirection

```cangjie
public enum LayoutDirection <: Equatable<LayoutDirection> {
    | Ltr
    | Rtl
    | Auto
    | ...
}
```

**功能：** 定义设备的布局方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[LayoutDirection](#enum-layoutdirection)>

### Ltr

```cangjie
Ltr
```

**功能：** 从左到右布局。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Rtl

```cangjie
Rtl
```

**功能：** 从右到左布局。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Auto

```cangjie
Auto
```

**功能：** 自动布局。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func !=(LayoutDirection)

```cangjie
public operator func !=(other: LayoutDirection): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[LayoutDirection](#enum-layoutdirection)|是|-|要比较的另一个LayoutDirection实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(LayoutDirection)

```cangjie
public operator func ==(other: LayoutDirection): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[LayoutDirection](#enum-layoutdirection)|是|-|要比较的另一个LayoutDirection实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|
