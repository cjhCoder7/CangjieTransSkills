# 基础类型定义

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

此页面记录UI框架使用的公共类型定义。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## interface CollectionEx\<T>

```cangjie
public interface CollectionEx<T> {
    prop size: Int64
    operator func [](idx: Int64, value!: T): Unit
    operator func [](idx: Int64): T
}
```

**功能：** 集合扩展接口。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### extend\<T> Array\<T> <: CollectionEx\<T>

```cangjie
extend<T> Array<T> <: CollectionEx<T> {}
```

**功能：** 扩展泛型Array为CollectionEx子类型。

### extend\<T> ArrayList\<T> <: CollectionEx\<T>

```cangjie
extend<T> ArrayList<T> <: CollectionEx<T> {}
```

**功能：** 扩展泛型ArrayList为CollectionEx子类型。

### prop size

```cangjie
prop size: Int64
```

**功能：** 集合大小。

**类型：** Int64

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func [](Int64, T)

```cangjie
operator func [](idx: Int64, value!: T): Unit
```

**功能：** 设置指定索引位置的元素值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|idx|Int64|是|-|元素索引。|
|value|T|是|-|**命名参数。** 元素值。|

### operator func [](Int64)

```cangjie
operator func [](idx: Int64): T
```

**功能：** 获取指定索引位置的元素值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|idx|Int64|是|-|元素索引。|

**返回值：**

|类型|说明|
|:----|:----|
|T|指定索引位置的元素值。|

## interface Length

```cangjie
public interface Length {
    prop value: Float64
    prop unitType: LengthUnit
}
```

**功能：** Float64、Int64、AppResource 均实现了 Length 接口类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### prop value

```cangjie

prop value: Float64
```

**功能：** 长度属性的值。

**类型：** Float64

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### prop unitType

```cangjie
prop unitType: LengthUnit
```

**功能：** 长度属性的单位。

**类型：** [LengthUnit](#enum-lengthunit)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## interface LengthProp

```cangjie
public interface LengthProp {
    prop px: Length
    prop vp: Length
    prop fp: Length
    prop percent: Length
    prop lpx: Length
}
```

**功能：** 长度属性标准接口。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### prop px

```cangjie
prop px: Length
```

**功能：** 以px为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### prop vp

```cangjie
prop vp: Length
```

**功能：** 以vp为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### prop fp

```cangjie
prop fp: Length
```

**功能：** 以fp为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### prop percent

```cangjie
prop percent: Length
```

**功能：** 以百分比为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### prop lpx

```cangjie
prop lpx: Length
```

**功能：** 以lpx为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### extend Float64 <: LengthProp & Length

```cangjie
extend Float64 <: LengthProp & Length {}
```

**功能：** 扩展Float64为LengthProp和Length的子类。

#### prop px

```cangjie
public prop px: Length
```

**功能：** 以px为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### prop vp

```cangjie
public prop vp: Length
```

**功能：** 以vp为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### prop fp

```cangjie
public prop fp: Length
```

**功能：** 以fp为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### prop percent

```cangjie
public prop percent: Length
```

**功能：** 以百分比为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### prop lpx

```cangjie
public prop lpx: Length
```

**功能：** 以lpx为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### prop value

```cangjie
public prop value: Float64
```

**功能：** 长度属性的值。

**类型：** Float64

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### prop unitType

```cangjie
public prop unitType: LengthUnit
```

**功能：** 长度属性的单位。

**类型：** [LengthUnit](#enum-lengthunit)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### extend Int64 <: LengthProp & Length

```cangjie
extend Int64 <: LengthProp & Length {}
```

**功能：** 扩展Int64为LengthProp和Length的子类。

#### prop px

```cangjie
public prop px: Length
```

**功能：** 以px为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### prop vp

```cangjie
public prop vp: Length
```

**功能：** 以vp为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### prop fp

```cangjie
public prop fp: Length
```

**功能：** 以fp为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### prop percent

```cangjie
public prop percent: Length
```

**功能：** 以百分比为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### prop lpx

```cangjie
public prop lpx: Length
```

**功能：** 以lpx为单位的长度属性。

**类型：** [Length](#interface-length)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### prop value

```cangjie
public prop value: Float64
```

**功能：** 长度属性的值。

**类型：** Float64

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### prop unitType

```cangjie
public prop unitType: LengthUnit
```

**功能：** 长度属性的单位。

**类型：** [LengthUnit](#enum-lengthunit)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## interface ResourceColor

```cangjie
public interface ResourceColor {
    func toUInt32(): UInt32
}
```

**功能：** Color、UInt32、Int64、AppResource 均实现了 ResourceColor 接口类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### extend Int64 <: ResourceColor

```cangjie
extend Int64 <: ResourceColor {
    public func toUInt32(): UInt32
}
```

**功能：** 扩展Int64为ResourceColor子类型。

#### func toUInt32()

```cangjie
public func toUInt32(): UInt32
```

**功能：** 转为UInt32颜色取值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|UInt32|ResourceColor的UInt32值。|

### extend UInt32 <: ResourceColor

```cangjie
extend UInt32 <: ResourceColor {
    public func toUInt32(): UInt32
}
```

**功能：** 扩展UInt32为ResourceColor子类型。

#### func toUInt32()

```cangjie
public func toUInt32(): UInt32
```

**功能：** 转为UInt32颜色取值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|UInt32|ResourceColor的UInt32值。|

### func toUInt32()

```cangjie
func toUInt32(): UInt32
```

**功能：** 转为UInt32颜色取值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|UInt32|ResourceColor的UInt32值。|

## interface ResourceStr

```cangjie
public interface ResourceStr {}
```

**功能：** 字符串类型，用于描述字符串入参可以使用的类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### extend String <: ResourceStr

```cangjie
extend String <: ResourceStr {}
```

**功能：** 扩展String为ResourceStr子类。

## interface TextContentControllerBase

```cangjie
public interface TextContentControllerBase {}
```

**功能：** 文本内容控制器基础接口。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## class Bindable\<T>

```cangjie
public class Bindable<T> {
    public let value: T
    public let onChange: (T) -> Unit
    public init(value: T, onChange: (T) -> Unit)
}
```

**功能：** 定义可绑定属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(T, (T) -> Unit)

```cangjie
public init(value: T, onChange: (T) -> Unit)
```

**功能：** Bindable构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|T|是|-|可绑定属性的值。|
|onChange|(T) -> Unit|是|-|可绑定属性的回调函数，当属性改变时将调用该回调函数。|

### let value

```cangjie
public let value: T
```

**功能：** 定义可绑定属性的值。

**类型：** T

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### let onChange

```cangjie
public let onChange: (T) -> Unit
```

**功能：** 可绑定属性的回调函数，当属性改变时将调用该回调函数。

**类型：** (T) -> Unit

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## class LengthMetrics

```cangjie
public class LengthMetrics <: Length {
    public init(value: Float64, unit!: LengthUnit = LengthUnit.Vp)
}
```

**功能：** 表示长度属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [Length](#interface-length)

### init(Float64, LengthUnit)

```cangjie
public init(value: Float64, unit!: LengthUnit = LengthUnit.Vp)
```

**功能：** 长度属性构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|Float64|是|-|长度值。|
|unit|[LengthUnit](#enum-lengthunit)|否|LengthUnit.Vp|**命名参数。** 长度单位。|

### prop value

```cangjie
public prop value: Float64
```

**功能：** 长度属性的值。

**类型：** Float64

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### prop unitType

```cangjie
public prop unitType: LengthUnit
```

**功能：** 长度属性的单位。

**类型：** [LengthUnit](#enum-lengthunit)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## class Color

```cangjie
public class Color <: ResourceColor {
    public static let Black: Color = Color(0xff000000)
    public static let Blue: Color = Color(0xff0000ff)
    public static let Gray: Color = Color(0xff808080)
    public static let Green: Color = Color(0xff008000)
    public static let Red: Color = Color(0xffff0000)
    public static let White: Color = Color(0xffffffff)
    public static let Transparent: Color = Color(0, 0, 0, alpha: 0.0)
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha!: ?Float32 = None)
    public init(value: UInt32)
}
```

**功能：** 颜色类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [ResourceColor](#interface-resourcecolor)

### static let Black

```cangjie
public static let Black: Color = Color(0xff000000)
```

**功能：** 黑色。

**类型：** [Color](#class-color)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### static let Blue

```cangjie
public static let Blue: Color = Color(0xff0000ff)
```

**功能：** 蓝色。

**类型：** [Color](#class-color)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### static let Gray

```cangjie
public static let Gray: Color = Color(0xff808080)
```

**功能：** 灰色。

**类型：** [Color](#class-color)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### static let Green

```cangjie
public static let Green: Color = Color(0xff008000)
```

**功能：** 绿色。

**类型：** [Color](#class-color)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### static let Red

```cangjie
public static let Red: Color = Color(0xffff0000)
```

**功能：** 红色。

**类型：** [Color](#class-color)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### static let White

```cangjie
public static let White: Color = Color(0xffffffff)
```

**功能：** 白色。

**类型：** [Color](#class-color)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### static let Transparent

```cangjie
public static let Transparent: Color = Color(0, 0, 0, alpha: 0.0)
```

**功能：** 透明色。

**类型：** [Color](#class-color)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(UInt8, UInt8, UInt8, ?Float32)

```cangjie
public init(red: UInt8, green: UInt8, blue: UInt8, alpha!: ?Float32 = None)
```

**功能：** 使用红、绿、蓝和透明度值创建颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|red|UInt8|是|-|RGB中红色通道取值。|
|green|UInt8|是|-|RGB中绿色通道取值。|
|blue|UInt8|是|-|RGB中蓝色通道取值。|
|alpha|?Float32|否|None|**命名参数。** 透明通道取值，取值范围 [0.0-1.0]。|

### init(UInt32)

```cangjie
public init(value: UInt32)
```

**功能：** 使用32位无符号整数值创建颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|UInt32|是|-|Uint32颜色取值。alpha，R，G，B通道按顺序各占输入的8位，若只输入R,G,B三个通道，则alpha通道默认取0xff。|

### func toUInt32()

```cangjie
public func toUInt32(): UInt32
```

**功能：** 转为UInt32颜色取值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|UInt32|UInt32颜色取值。|

## class ReuseParams

```cangjie
public class ReuseParams {
    public init(arr: Array<(String, Any)>)
}
```

**功能：** aboutToReuse生命周期函数的参数，开发者可以从中获取可复用组件的构造参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(Array\<(String, Any)>)

```cangjie
public init(arr: Array<(String, Any)>)
```

**功能：** 创建一个ReuseParams对象，通常情况下开发者不会调用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|arr|Array\<(String, Any)>|是|-|存放组件构造参数元组的数组。|

### func get\<T>(String)

```cangjie
public func get<T>(key: String): ?T
```

**功能：** 通过key获取对应的构造参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|key|String|是|-|构造参数的名称。|

**返回值：**

|类型|说明|
|:----|:----|
|?T|构造参数的值。|

## class KeyEvent

```cangjie
public class KeyEvent {
    public var keyType: KeyType
    public var keyCode: Int32
    public var keyText: String
    public var keySource: KeySource
    public var deviceId: Int64
    public var metaKey: Int32
    public var timestamp: Int64
    public init(keyText: String, keyType: KeyType, keyCode: Int32, keySource: KeySource, metaKey: Int32,
        deviceId: Int64, timestamp: Int64)
}
```

**功能：** 按键事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var keyText

```cangjie
public var keyText: String
```

**功能：** 按键的键值。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var keyType

```cangjie
public var keyType: KeyType
```

**功能：** 按键的类型。

**类型：** [KeyType](./cj-common-types.md#enum-keytype)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var keyCode

```cangjie
public var keyCode: Int32
```

**功能：** 按键的键值。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var keySource

```cangjie
public var keySource: KeySource
```

**功能：** 触发当前按键的输入设备类型。

**类型：** [KeySource](./cj-common-types.md#enum-keysource)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var metaKey

```cangjie
public var metaKey: Int32
```

**功能：** 按键发生时元键的状态，1表示按压态，0表示未按压态。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var deviceId

```cangjie
public var deviceId: Int64
```

**功能：** 触发当前按键的输入设备ID。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var timestamp

```cangjie
public var timestamp: Int64
```

**功能：** 按键发生时的时间戳。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(String, KeyType, Int32, KeySource, Int32, Int64, Int64)

```cangjie
public init(keyText: String, keyType: KeyType, keyCode: Int32, keySource: KeySource, metaKey: Int32,
        deviceId: Int64, timestamp: Int64)
```

**功能：** 构造按键事件类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|keyText|String|是|-|按键的键值。|
|keyType|[KeyType](./cj-common-types.md#enum-keytype)|是|-|按键的类型。|
|keyCode|Int32|是|-|按键的键值。|
|keySource|[KeySource](./cj-common-types.md#enum-keysource)|是|-|触发当前按键的输入设备类型。|
|metaKey|Int32|是|-|按键发生时元键的状态，1表示按压态，0表示未按压态。|
|deviceId|Int64|是|-|触发当前按键的输入设备ID。|
|timestamp|Int64|是|-|按键发生时的时间戳。|

### func stopPropagation()

```cangjie
public func stopPropagation(): Unit
```

**功能：** 阻塞事件冒泡传递。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## class TouchObject

```cangjie
public class TouchObject {
    public var touchType: TouchType
    public var id: Int32
    public var screenX: Float64
    public var screenY: Float64
    public var x: Float64
    public var y: Float64
    public init(touchType: TouchType, id: Int32, screenX: Float64, screenY: Float64, x: Float64, y: Float64)
}
```

**功能：** 表示当前发生变化的手指信息类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var id

```cangjie
public var id: Int32
```

**功能：** 手指唯一标识符。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var screenX

```cangjie
public var screenX: Float64
```

**功能：** 触摸点相对于设备屏幕左边沿的X坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var screenY

```cangjie
public var screenY: Float64
```

**功能：** 触摸点相对于设备屏幕上边沿的Y坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var touchType

```cangjie
public var touchType: TouchType
```

**功能：** 触摸事件的类型。

**类型：** [TouchType](cj-common-types.md#enum-touchtype)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var x

```cangjie
public var x: Float64
```

**功能：** 触摸点相对于被触摸元素左边沿的X坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var y

```cangjie
public var y: Float64
```

**功能：** 触摸点相对于被触摸元素上边沿的Y坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(TouchType, Int32, Float64, Float64, Float64, Float64)

```cangjie
public init(touchType: TouchType, id: Int32, screenX: Float64, screenY: Float64, x: Float64, y: Float64)
```

**功能：** 构造触摸事件类型对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|touchType|[TouchType](cj-common-types.md#enum-touchtype)|是|-|触摸事件的类型。|
|id|Int32|是|-|手指唯一标识符。|
|screenX|Float64|是|-|触摸点相对于设备屏幕左边沿的X坐标。|
|screenY|Float64|是|-|触摸点相对于设备屏幕上边沿的Y坐标。|
|x|Float64|是|-|触摸点相对于被触摸元素左边沿的X坐标。|
|y|Float64|是|-|触摸点相对于被触摸元素上边沿的Y坐标。|

## class BaseEvent

```cangjie
abstract sealed class BaseEvent {
    public var target: ?EventTarget
    public var timestamp: Int64
    public var source: ?SourceType
    public var deviceId: ?Int64
}
```

**功能：** 基础事件类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var target

```cangjie
public var target: ?EventTarget
```

**功能：** 触发事件的元素对象。

**类型：** ?[EventTarget](#class-eventtarget)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var timestamp

```cangjie
public var timestamp: Int64
```

**功能：** 事件时间戳，触发事件时距离系统启动的时间间隔。单位：ns

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var source

```cangjie
public var source: ?SourceType
```

**功能：** 事件输入设备的类型。

**类型：** ?[SourceType](#enum-sourcetype)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var deviceId

```cangjie
public var deviceId: ?Int64
```

**功能：** 触发当前事件的输入设备ID。初始值：0，取值范围：[0, +∞)。

**类型：** ?Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## class ClickEvent

```cangjie
public class ClickEvent <: BaseEvent {
    public var displayX: Float64
    public var displayY: Float64
    public var windowX: Float64
    public var windowY: Float64
    public var x: Float64
    public var y: Float64
}
```

**功能：** 描述点击事件的类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [BaseEvent](#class-baseevent)

### var displayX

```cangjie
public var displayX: Float64
```

**功能：** 标记点击点在屏幕左上角的横向绝对坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var displayY

```cangjie
public var displayY: Float64
```

**功能：** 标记点击点在屏幕左上角的纵向绝对坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var windowX

```cangjie
public var windowX: Float64
```

**功能：** 定位点击点在应用窗口左上角的横向坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var windowY

```cangjie
public var windowY: Float64
```

**功能：** 定位点击点在应用窗口左上角的纵向坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var x

```cangjie
public var x: Float64
```

**功能：** 记录点击点在元素内部的横向位置坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var y

```cangjie
public var y: Float64
```

**功能：** 记录点击点在元素内部的纵向位置坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## class DragItemInfo

```cangjie
public class DragItemInfo {
    public var pixelMap: ?PixelMap
    public var builder: ?CustomBuilder
    public var extraInfo: ?String
    public init(pixelMap: ?PixelMap, builder: ?CustomBuilder, extraInfo: ?String)
}
```

**功能：** 拖拽过程中显示的组件信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var builder

```cangjie
public var builder: ?CustomBuilder
```

**功能：** 使用自定义的生成器进行绘图，如果设置了pixelMap，则该值无效。

**类型：** ?[CustomBuilder](./cj-common-types.md#type-custombuilder)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var extraInfo

```cangjie
public var extraInfo: ?String
```

**功能：** 配置拖拽项的描述。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var pixelMap

```cangjie
public var pixelMap: ?PixelMap
```

**功能：** 设置拖拽过程中显示的图片。

**类型：** ?[PixelMap](../ImageKit/cj-apis-image.md#class-pixelmap)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?PixelMap, ?CustomBuilder, ?String)

```cangjie
public init(pixelMap: ?PixelMap, builder: ?CustomBuilder, extraInfo: ?String)
```

**功能：** 创建一个DragItemInfo类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|pixelMap|?[PixelMap](../ImageKit/cj-apis-image.md#class-pixelmap)|是|-|设置拖拽过程中显示的图片。|
|builder|?[CustomBuilder](./cj-common-types.md#type-custombuilder)|是|-|使用自定义生成器进行绘图，如果设置了pixelMap，则忽略此值。|
|extraInfo|?String|是|-|拖拽项的描述。|

## class MouseEvent

```cangjie
public class MouseEvent <: BaseEvent {
    public var button: MouseButton
    public var screenX: Float64
    public var screenY: Float64
    public var x: Float64
    public var y: Float64
    public var action: MouseAction
    public init(timestamp: Int64, screenX: Float64, screenY: Float64, x: Float64, y: Float64, button: MouseButton, action: MouseAction)
}
```

**功能：** 用于描述鼠标事件的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [BaseEvent](#class-baseevent)

### var button

```cangjie
public var button: MouseButton
```

**功能：** 鼠标按键。

**类型：** [MouseButton](./cj-common-types.md#enum-mousebutton)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var screenX

```cangjie
public var screenX: Float64
```

**功能：** 点击触点相对于屏幕左上角的x轴坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var screenY

```cangjie
public var screenY: Float64
```

**功能：** 点击触点相对于屏幕左上角的y轴坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var x

```cangjie
public var x: Float64
```

**功能：** 点击触点相对于当前组件左上角的x轴坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var y

```cangjie
public var y: Float64
```

**功能：** 点击触点相对于当前组件左上角的y轴坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var action

```cangjie
public var action: MouseAction
```

**功能：** 事件动作。

**类型：** [MouseAction](./cj-common-types.md#enum-mouseaction)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(Int64, Float64, Float64, Float64, Float64, MouseButton, MouseAction)

```cangjie
public init(timestamp: Int64, screenX: Float64, screenY: Float64, x: Float64, y: Float64, button: MouseButton,action: MouseAction)
```

**功能：** 构造鼠标事件类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|timestamp|Int64|是|-|触发事件时的时间戳。|
|screenX|Float64|是|-|点击触点相对于屏幕左上角的x轴坐标。|
|screenY|Float64|是|-|点击触点相对于屏幕左上角的y轴坐标。|
|x|Float64|是|-|点击触点相对于当前组件左上角的x轴坐标。|
|y|Float64|是|-|点击触点相对于当前组件左上角的y轴坐标。|
|button|[MouseButton](./cj-common-types.md#enum-mousebutton)|是|-|鼠标按键。|
|action|[MouseAction](./cj-common-types.md#enum-mouseaction)|是|-|事件动作。|

## class TouchEvent

```cangjie
public class TouchEvent <: BaseEvent {
    public var eventType: TouchType
    public var touches: Array<TouchObject>
    public var changedTouches: Array<TouchObject>
}
```

**功能：** 非事件注入场景下，changedTouches是按屏幕显示刷新率重采样的点，touches是按器件刷新率报上来的点，changedTouches的数据可能会和touches里面的不相同。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [BaseEvent](#class-baseevent)

### var eventType

```cangjie
public var eventType: TouchType
```

**功能：** 触摸事件的类型。

**类型：** [TouchType](cj-common-types.md#enum-touchtype)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var touches

```cangjie
public var touches: Array<TouchObject>
```

**功能：** 全部手指信息。

**类型：** Array\<[TouchObject](#class-touchobject)>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var changedTouches

```cangjie
public var changedTouches: Array<TouchObject>
```

**功能：** 当前发生变化的手指信息。

**类型：** Array\<[TouchObject](#class-touchobject)>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func stopPropagation()

```cangjie
public func stopPropagation(): Unit
```

**功能：** 停止事件传播。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## class EventTarget

```cangjie
public class EventTarget {
    public var area: Area
    public init(area: Area)
}
```

**功能：** 事件目标对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var area

```cangjie
public var area: Area
```

**功能：** 事件目标区域。

**类型：** [Area](#class-area)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(Area)

```cangjie
public init(area: Area)
```

**功能：** 构造一个EventTarget对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|area|[Area](#class-area)|是|-|事件目标区域。|

## class Area

```cangjie
public class Area {
    public var width: Length
    public var height: Length
    public var position: Position
    public var globalPosition: Position
    public init(width: Length, height: Length, position: Position, globalPosition: Position)
}
```

**功能：** 当前目标区域。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var width

```cangjie
public var width: Length
```

**功能：** 定义目标元素的宽度。

**类型：** [Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var height

```cangjie
public var height: Length
```

**功能：** 定义目标元素的高度。

**类型：** [Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var position

```cangjie
public var position: Position
```

**功能：** 定义目标元素左上角与父元素左上角的相对位置。

**类型：** [Position](#class-position)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var globalPosition

```cangjie
public var globalPosition: Position
```

**功能：** 定义目标元素左上角与屏幕左上角的位置关系。

**类型：** [Position](#class-position)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(Length, Length, Position, Position)

```cangjie
public init(width: Length, height: Length, position: Position, globalPosition: Position)
```

**功能：** 构造一个Area类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|width|[Length](./cj-common-types.md#interface-length)|是|-|目标元素的宽度，单位为vp。|
|height|[Length](./cj-common-types.md#interface-length)|是|-|目标元素的高度，单位为vp。|
|position|[Position](#class-position)|是|-|目标元素左上角相对父元素左上角的位置。|
|globalPosition|[Position](#class-position)|是|-|目标元素左上角相对页面左上角的位置。|

## class Position

```cangjie
public class Position {
    public var x: ?Length
    public var y: ?Length
    public init(x!: ?Length = None, y!: ?Length = None)
}
```

**功能：** 位置信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var x

```cangjie
public var x: ?Length
```

**功能：** 定义x轴坐标。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var y

```cangjie
public var y: ?Length
```

**功能：** 定义y轴坐标。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Length, ?Length)

```cangjie
public init(x!: ?Length = None, y!: ?Length = None)
```

**功能：** 构造一个Position类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** x轴坐标，单位为vp。|
|y|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** y轴坐标，单位为vp。|

## class MotionPathOptions

```cangjie
public class MotionPathOptions {
    public var path: ?String
    public var from: ?Float64
    public var to: ?Float64
    public var rotatable: ?Bool
    public init(path!: ?String, from!: ?Float64 = None, to!: ?Float64 = None, rotatable!: ?Bool = None)
}
```

**功能：** 设置动画路径选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var path

```cangjie
public var path: ?String
```

**功能：** 设置动画路径。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var from

```cangjie
public var from: ?Float64
```

**功能：** 设置动画路径的起始位置。

**类型：** ?Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var to

```cangjie
public var to: ?Float64
```

**功能：** 设置动画路径的结束位置。

**类型：** ?Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var rotatable

```cangjie
public var rotatable: ?Bool
```

**功能：** 设置动画路径是否可旋转。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?String, ?Float64, ?Float64, ?Bool)

```cangjie
public init(path!: ?String, from!: ?Float64 = None, to!: ?Float64 = None, rotatable!: ?Bool = None)
```

**功能：** 构造一个MotionPathOptions对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|path|?String|是|-|**命名参数。** 设置动画路径的起始位置。|
|from|?Float64|否|None|**命名参数。** 设置动画路径的起始位置。初始值为0.0。|
|to|?Float64|否|None|**命名参数。** 设置动画路径的结束位置。初始值为1.0。|
|rotatable|?Bool|否|None|**命名参数。** 设置动画路径是否可旋转。初始值为false。|

## class SharedTransitionOptions

```cangjie
public class SharedTransitionOptions {
    public var duration: ?Int32
    public var curve: ?Curve
    public var delay: ?Int32
    public var motionPath: ?MotionPathOptions
    public var zIndex: ?Int32
    public var effectType: ?SharedTransitionEffectType
    public init(duration!: ?Int32 = None, curve!: ?Curve = None, delay!: ?Int32 = None, motionPath!: ?MotionPathOptions = None, zIndex!: ?Int32 = None, effectType!: ?SharedTransitionEffectType = None)
}
```

**功能：** 共享转场选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var duration

```cangjie
public var duration: ?Int32
```

**功能：** 描述共享元素转场动效播放时长。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var curve

```cangjie
public var curve: ?Curve
```

**功能：** 动画曲线。

**类型：** ?[Curve](#enum-curve)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var delay

```cangjie
public var delay: ?Int32
```

**功能：** 延迟播放时间。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var motionPath

```cangjie
public var motionPath: ?MotionPathOptions
```

**功能：** 设置共享转场的运动路径。

**类型：** ?[MotionPathOptions](#class-motionpathoptions)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var zIndex

```cangjie
public var zIndex: ?Int32
```

**功能：** 设置Z轴。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var effectType

```cangjie
public var effectType: ?SharedTransitionEffectType
```

**功能：** 动画类型。

**类型：** ?[SharedTransitionEffectType](#enum-sharedtransitioneffecttype)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Int32, ?Curve, ?Int32, ?MotionPathOptions, ?Int32, ?SharedTransitionEffectType)

```cangjie
public init(duration!: ?Int32 = None, curve!: ?Curve = None, delay!: ?Int32 = None, motionPath!: ?MotionPathOptions = None, zIndex!: ?Int32 = None, effectType!: ?SharedTransitionEffectType = None)
```

**功能：** 构造一个SharedTransitionOptions对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|duration|?Int32|否|None|**命名参数。** 描述共享元素转场动效播放时长。<br>初始值：1000。<br>单位：毫秒。<br>取值范围：[0, +∞)。|
|curve|?[Curve](./cj-common-types.md#enum-curve)|否|None|**命名参数。** 动画曲线。<br>初始值：Curve.Linear。|
|delay|?Int32|否|None|**命名参数。** 延迟播放时间。<br>初始值：0。<br>单位：毫秒。|
|motionPath|?[MotionPathOptions](#class-motionpathoptions)|否|None|**命名参数。** 设置共享转场的运动路径。<br>初始值：MotionPathOptions(path: "")。|
|zIndex|?Int32|否|None|**命名参数。** 设置Z轴。<br>取值范围：(-∞, +∞)。<br>初始值：0。|
|effectType|?[SharedTransitionEffectType](./cj-common-types.md#enum-sharedtransitioneffecttype)|否|None|**命名参数。** 动画类型。<br>初始值为SharedTransitionEffectType.Exchange。|

## class AnimateParam

```cangjie
public class AnimateParam {
    public var duration: ?Int32
    public var tempo: ?Float32
    public var curve: ?Curve
    public var delay: ?Int32
    public var iterations: ?Int32
    public var playMode: ?PlayMode
    public var onFinish: Option<() -> Unit>
    public var finishCallbackType: ?FinishCallbackType
    public var expectedFrameRateRange: Option<ExpectedFrameRateRange>
    public init(duration!: ?Int32 = None, tempo!: ?Float32 = None, curve!: ?Curve = None, delay!: ?Int32 = None, iterations!: ?Int32 = None, playMode!: ?PlayMode = None, onFinish!: Option<() -> Unit> = Option.None, finishCallbackType!: ?FinishCallbackType = None, expectedFrameRateRange!: Option<ExpectedFrameRateRange> = Option.None)
}
```

**功能：** 设置动画效果相关参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var duration

```cangjie
public var duration: ?Int32
```

**功能：** 动画持续时间，单位为毫秒。设置小于0的值时按0处理。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var tempo

```cangjie
public var tempo: ?Float32
```

**功能：** 动画播放速度，值越大动画播放越快，值越小播放越慢，为0时无动画效果。

**类型：** ?Float32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var curve

```cangjie
public var curve: ?Curve
```

**功能：** 动画曲线。

**类型：** ?[Curve](#enum-curve)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var delay

```cangjie
public var delay: ?Int32
```

**功能：** 动画延迟播放时间，单位为ms(毫秒)，默认不延时播放。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var iterations

```cangjie
public var iterations: ?Int32
```

**功能：** 动画播放次数。默认播放一次，设置为-1时表示无限次播放。设置为0时表示无动画效果。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var playMode

```cangjie
public var playMode: ?PlayMode
```

**功能：** 动画播放模式，默认播放完成后重头开始播放。

**类型：** ?[PlayMode](#enum-playmode)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var onFinish

```cangjie
public var onFinish: Option<() -> Unit>
```

**功能：** 动画播放完成回调。

**类型：** Option\<() -> Unit>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var finishCallbackType

```cangjie
public var finishCallbackType: ?FinishCallbackType
```

**功能：** 在动画中定义onFinish回调的类型。

**类型：** ?[FinishCallbackType](#enum-finishcallbacktype)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var expectedFrameRateRange

```cangjie
public var expectedFrameRateRange: Option<ExpectedFrameRateRange>
```

**功能：** 设置动画的期望帧率。

**类型：** Option<[ExpectedFrameRateRange](#class-expectedframeraterange)>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Int32, ?Float32, ?Curve, ?Int32, ?Int32, ?PlayMode, Option\<() -> Unit>, ?FinishCallbackType, Option\<ExpectedFrameRateRange>)

```cangjie
public init(duration!: ?Int32 = None, tempo!: ?Float32 = None, curve!: ?Curve = None, delay!: ?Int32 = None, iterations!: ?Int32 = None, playMode!: ?PlayMode = None, onFinish!: Option<() -> Unit> = Option.None, finishCallbackType!: ?FinishCallbackType = None, expectedFrameRateRange!: Option<ExpectedFrameRateRange> = Option.None)
```

**功能：** 构造一个AnimateParam对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|duration|?Int32|否|None|**命名参数。** 动画持续时间，单位为毫秒。设置小于0的值时按0处理。<br>初始值：1000。<br>**说明：**<br>1. 可以通过在持续时间为0的动画闭包函数中改变属性，以实现停止该属性动画的效果。<br>2. 设置小于0的值时按0处理。|
|tempo|?Float32|否|None|**命名参数。** 动画播放速度，值越大动画播放越快，值越小播放越慢，为0时无动画效果。<br>初始值：1.0。<br>取值范围：[0, +∞)。|
|curve|?[Curve](./cj-common-types.md#enum-curve)|否|None|**命名参数。** 动画曲线。初始值为Curve.EaseInOut。|
|delay|?Int32|否|None|**命名参数。** 动画延迟播放时间，单位为ms(毫秒)。<br>初始值：0。<br>取值范围：(-∞, +∞)。<br>**说明：**<br>delay>=0为延迟播放，delay<0表示提前播放。对于delay<0的情况：当delay的绝对值小于实际动画时长，动画将在开始后第一帧直接运动到delay绝对值的时刻的状态；当delay的绝对值大于等于实际动画时长，动画将在开始后第一帧直接运动到终点状态。其中实际动画时长等于单次动画时长乘以动画播放次数。|
|iterations|?Int32|否|None|**命名参数。** 动画播放次数。设置为-1时表示无限次播放。设置为0时表示无动画效果。<br>初始值：1。<br>取值范围：[-1, +∞)。|
|playMode|?[PlayMode](./cj-common-types.md#enum-playmode)|否|None|**命名参数。** 动画播放模式，默认播放完成后重头开始播放。<br>初始值：PlayMode.Normal。|
|onFinish|Option\<() -> Unit>|否|Option.None|**命名参数。** 动画播放完成回调。|
|finishCallbackType|?[FinishCallbackType](./cj-common-types.md#enum-finishcallbacktype)|否|None|**命名参数。** 在动画中定义onFinish回调的类型。<br>初始值：FinishCallbackType.Removed。|
|expectedFrameRateRange|Option<[ExpectedFrameRateRange](#class-expectedframeraterange)>|否|Option.None|**命名参数。** 设置动画的期望帧率。|

## class HorizontalAlignParam

```cangjie
public class HorizontalAlignParam {
    public var anchor: ?String
    public var align: ?HorizontalAlign
    public init(anchor: ?String, align: ?HorizontalAlign)
}
```

**功能：** 水平对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var anchor

```cangjie
public var anchor: ?String
```

**功能：** 设置组件水平对齐的锚点。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var align

```cangjie
public var align: ?HorizontalAlign
```

**功能：** 设置组件水平方向对齐方式。

**类型：** ?[HorizontalAlign](#enum-horizontalalign)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?String, ?HorizontalAlign)

```cangjie
public init(anchor: ?String, align: ?HorizontalAlign)
```

**功能：** 构造一个HorizontalAlignment对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|anchor|?String|是|-|设置组件水平对齐的锚点。|
|align|?[HorizontalAlign](#enum-horizontalalign)|是|-|设置组件水平方向对齐方式。|

## class VerticalAlignParam

```cangjie
public class VerticalAlignParam {
    public var anchor: ?String
    public var align: ?VerticalAlign
    public init(anchor: ?String, align: ?VerticalAlign)
}
```

**功能：** 垂直对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var anchor

```cangjie
public var anchor: ?String
```

**功能：** 设置组件垂直对齐的锚点。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var align

```cangjie
public var align: ?VerticalAlign
```

**功能：** 设置组件垂直方向对齐方式。

**类型：** ?[VerticalAlign](#enum-verticalalign)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?String, ?VerticalAlign)

```cangjie
public init(anchor: ?String, align: ?VerticalAlign)
```

**功能：** 构造一个VerticalAlignment对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|anchor|?String|是|-|设置组件垂直对齐的锚点。|
|align|?[VerticalAlign](#enum-verticalalign)|是|-|设置组件垂直方向对齐方式。|

## class Bias

```cangjie
public class Bias {
    public var horizontal: ?Float32
    public var vertical: ?Float32
    public init(horizontal!: ?Float32 = None, vertical!: ?Float32 = None)
}
```

**功能：** 设置组件对齐的偏移量。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var horizontal

```cangjie
public var horizontal: ?Float32
```

**功能：** 设置组件水平方向的偏移量。

**类型：** ?Float32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var vertical

```cangjie
public var vertical: ?Float32
```

**功能：** 设置组件垂直方向的偏移量。

**类型：** ?Float32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Float32, ?Float32)

```cangjie
public init(horizontal!: ?Float32 = None, vertical!: ?Float32 = None)
```

**功能：** 构造一个Bias对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|horizontal|?Float32|否|None|**命名参数。** 设置组件水平方向的偏移量。初始值为0.5。|
|vertical|?Float32|否|None|**命名参数。** 设置组件垂直方向的偏移量。初始值为0.5。|

## class Fonts

```cangjie
public class Fonts {
    public var size: ?Length
    public var weight: ?FontWeight
    public var family: ?String
    public var style: ?FontStyle
    public init(size!: ?Length = None, weight!: ?FontWeight = None, family!: ?ResourceStr = None, style!: ?FontStyle = None)
}
```

**功能：** 文本样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var size

```cangjie
public var size: ?Length
```

**功能：** 设置文本尺寸，使用fp单位。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var weight

```cangjie
public var weight: ?FontWeight
```

**功能：** 设置文本的字体粗细。

**类型：** ?[FontWeight](#enum-fontweight)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var family

```cangjie
public var family: ?String
```

**功能：** 设置文本的字体列表。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var style

```cangjie
public var style: ?FontStyle
```

**功能：** 设置文本的字体样式。

**类型：** ?[FontStyle](#enum-fontstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Length, ?FontWeight, ?ResourceStr, ?FontStyle)

```cangjie
public init(size!: ?Length = None, weight!: ?FontWeight = None, family!: ?ResourceStr = None, style!: ?FontStyle = None)
```

**功能：** 构造一个Fonts对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|size|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 设置文本尺寸，Length为Int64、Float64类型时，使用fp单位。不支持百分比设置。初始值为16.fp。|
|weight|?[FontWeight](./cj-common-types.md#enum-fontweight)|否|None|**命名参数。** 设置文本的字体粗细。初始值为FontWeight.Normal。|
|family|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None|**命名参数。** 设置文本的字体列表。使用多个字体，使用','进行分割，优先级按顺序生效。例如：'Arial, HarmonyOS Sans'。当前支持'HarmonyOS Sans'字体。初始值为"HarmonyOS Sans"。|
|style|?[FontStyle](./cj-common-types.md#enum-fontstyle)|否|None|**命名参数。** 设置文本的字体样式。初始值为FontStyle.Normal。|

## class BorderRadiuses

```cangjie
public class BorderRadiuses {
    public var topLeft: ?Length
    public var topRight: ?Length
    public var bottomLeft: ?Length
    public var bottomRight: ?Length
    public init(topLeft!: ?Length = None, topRight!: ?Length = None, bottomLeft!: ?Length = None, bottomRight!: ?Length = None)
}
```

**功能：** 圆角类型，用于描述组件边框圆角半径。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var topLeft

```cangjie
public var topLeft: ?Length
```

**功能：** 组件左上角圆角半径。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var topRight

```cangjie
public var topRight: ?Length
```

**功能：** 组件右上角圆角半径。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var bottomLeft

```cangjie
public var bottomLeft: ?Length
```

**功能：** 组件左下角圆角半径。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var bottomRight

```cangjie
public var bottomRight: ?Length
```

**功能：** 组件右下角圆角半径。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Length, ?Length, ?Length, ?Length)

```cangjie
public init(topLeft!: ?Length = None, topRight!: ?Length = None, bottomLeft!: ?Length = None, bottomRight!: ?Length = None)
```

**功能：** 初始化一个BorderRadiuses对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|topLeft|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 组件左上角圆角半径。初始值为0.vp。|
|topRight|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 组件右上角圆角半径。，初始值为0.vp。|
|bottomLeft|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 组件左下角圆角半径。初始值为0.v2。|
|bottomRight|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 组件右下角圆角半径。初始值为0.vp。|

## class Margin

```cangjie
public class Margin {
    public init(top!: ?Length = None, right!: ?Length = None, bottom!: ?Length = None, left!: ?Length = None)
}
```

**功能：** 外边距类型，用于描述组件不同方向的外边距。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Length, ?Length, ?Length, ?Length)

```cangjie
public init(top!: ?Length = None, right!: ?Length = None, bottom!: ?Length = None, left!: ?Length = None)
```

**功能：** 初始化外边距类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|top|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 上外边距，组件顶部距组件外元素的尺寸。初始值为0.vp。|
|right|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 右外边距，组件右边界距组件外元素的尺寸。初始值为0.vp。|
|bottom|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 下外边距，组件底部距组件外元素的尺寸。初始值为0.vp。|
|left|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 左外边距，组件左边界距组件外元素的尺寸。初始值为0.vp。|

## class ShadowOptions

```cangjie
public class ShadowOptions {
    public var radius: ?Float64
    public var shadowType: ?ShadowType
    public var color: ?ResourceColor
    public var offsetX: ?Float64
    public var offsetY: ?Float64
    public var fill: ?Bool
    public init(radius!: ?Float64, shadowType!: ?ShadowType = None, color!: ?ResourceColor = None, offsetX!: ?Float64 = None, offsetY!: ?Float64 = None, fill!: ?Bool = None)
}
```

**功能：** 阴影选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var radius

```cangjie
public var radius: ?Float64
```

**功能：** 设置阴影的模糊半径。

**类型：** ?Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var shadowType

```cangjie
public var shadowType: ?ShadowType
```

**功能：** 设置阴影类型。

**类型：** ?[ShadowType](#enum-shadowtype)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var color

```cangjie
public var color: ?ResourceColor
```

**功能：** 设置阴影颜色。

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var offsetX

```cangjie
public var offsetX: ?Float64
```

**功能：** 设置阴影的水平偏移量。

**类型：** ?Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var offsetY

```cangjie
public var offsetY: ?Float64
```

**功能：** 设置阴影的垂直偏移量。

**类型：** ?Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var fill

```cangjie
public var fill: ?Bool
```

**功能：** 是否填充。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Float64, ?ShadowType, ?ResourceColor, ?Float64, ?Float64, ?Bool)

```cangjie
public init(radius!: ?Float64, shadowType!: ?ShadowType = None, color!: ?ResourceColor = None, offsetX!: ?Float64 = None, offsetY!: ?Float64 = None, fill!: ?Bool = None)
```

**功能：** 构造一个ShadowOptions对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|radius|?Float64|是|-|**命名参数。** 设置阴影的模糊半径。<br>初始值：<br>API version 26之前，初始值为0.0，设置大于0.0时，阴影生效；<br>从API version 26开始，初始值为-1.0，大于等于0.0时，阴影生效。|
|shadowType|?[ShadowType](./cj-common-types.md#enum-shadowtype)|否|None|**命名参数。** 设置阴影类型。初始值为ShadowType.Color。|
|color|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|None|**命名参数。** 设置阴影颜色。初始值为Color.Black。|
|offsetX|?Float64|否|None|**命名参数。** 设置阴影的水平偏移量。初始值为0.0。|
|offsetY|?Float64|否|None|**命名参数。** 设置阴影的垂直偏移量。初始值为0.0。|
|fill|?Bool|否|None|**命名参数。** 设置阴影是否填充。初始值为false。|

## class Offset

```cangjie
public class Offset {
    public var dx: ?Length
    public var dy: ?Length
    public init(dx: ?Length, dy: ?Length)
}
```

**功能：** 相对布局完成位置坐标偏移量。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var dx

```cangjie
public var dx: ?Length
```

**功能：** 水平方向偏移量。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var dy

```cangjie
public var dy: ?Length
```

**功能：** 竖直方向偏移量。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Length, ?Length)

```cangjie
public init(dx: ?Length, dy: ?Length)
```

**功能：** 构建一个Offset类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|dx|?[Length](./cj-common-types.md#interface-length)|是|-|x点坐标。|
|dy|?[Length](./cj-common-types.md#interface-length)|是|-|y点坐标。|

## class ExpectedFrameRateRange

```cangjie
public class ExpectedFrameRateRange {
    public var min: ?Int32
    public var max: ?Int32
    public var expected: ?Int32
    public init(min!: ?Int32, max!: ?Int32, expected!: ?Int32)
}
```

**功能：** 设置动画的期望帧率范围。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var min

```cangjie
public var min: ?Int32
```

**功能：** 最小帧率值。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var max

```cangjie
public var max: ?Int32
```

**功能：** 最大帧率值。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var expected

```cangjie
public var expected: ?Int32
```

**功能：** 期望的帧率值。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Int32, ?Int32, ?Int32)

```cangjie
public init(min!: ?Int32, max!: ?Int32, expected!: ?Int32)
```

**功能：** 构造一个ExpectedFrameRateRange对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|min|?Int32|是|-|**命名参数。** 最小帧率值。|
|max|?Int32|是|-|**命名参数。** 最大帧率值。|
|expected|?Int32|是|-|**命名参数。** 期望的帧率值。|

## class AlignRuleOption

```cangjie
public class AlignRuleOption {
    public var left: ?HorizontalAlignParam
    public var right: ?HorizontalAlignParam
    public var middle: ?HorizontalAlignParam
    public var top: ?VerticalAlignParam
    public var bottom: ?VerticalAlignParam
    public var center: ?VerticalAlignParam
    public var bias: ?Bias
    public init(left!: ?HorizontalAlignParam = None, right!: ?HorizontalAlignParam = None, middle!: ?HorizontalAlignParam = None, top!: ?VerticalAlignParam = None, bottom!: ?VerticalAlignParam = None, center!: ?VerticalAlignParam = None, bias!: ?Bias = None)
}
```

**功能：** 设置组件对齐规则选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var left

```cangjie
public var left: ?HorizontalAlignParam
```

**功能：** 设置组件左侧对齐方式。

**类型：** ?[HorizontalAlignParam](#class-horizontalalignparam)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var right

```cangjie
public var right: ?HorizontalAlignParam
```

**功能：** 设置组件右侧对齐方式。

**类型：** ?[HorizontalAlignParam](#class-horizontalalignparam)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var middle

```cangjie
public var middle: ?HorizontalAlignParam
```

**功能：** 设置组件水平居中对齐方式。

**类型：** ?[HorizontalAlignParam](#class-horizontalalignparam)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var top

```cangjie
public var top: ?VerticalAlignParam
```

**功能：** 设置组件顶部对齐方式。

**类型：** ?[VerticalAlignParam](#class-verticalalignparam)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var bottom

```cangjie
public var bottom: ?VerticalAlignParam
```

**功能：** 设置组件底部对齐方式。

**类型：** ?[VerticalAlignParam](#class-verticalalignparam)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var center

```cangjie
public var center: ?VerticalAlignParam
```

**功能：** 设置组件垂直居中对齐方式。

**类型：** ?[VerticalAlignParam](#class-verticalalignparam)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var bias

```cangjie
public var bias: ?Bias
```

**功能：** 设置组件对齐的偏移量。

**类型：** ?[Bias](#class-bias)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?HorizontalAlignParam, ?HorizontalAlignParam, ?HorizontalAlignParam, ?VerticalAlignParam, ?VerticalAlignParam, ?VerticalAlignParam, ?Bias)

```cangjie
public init(left!: ?HorizontalAlignParam = None, right!: ?HorizontalAlignParam = None, middle!: ?HorizontalAlignParam = None, top!: ?VerticalAlignParam = None, bottom!: ?VerticalAlignParam = None, center!: ?VerticalAlignParam = None, bias!: ?Bias = None)
```

**功能：** 构造一个AlignRuleOptions对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|left|?[HorizontalAlignParam](#class-horizontalalignparam)|否|None|**命名参数。** 设置组件左侧对齐方式。|
|right|?[HorizontalAlignParam](#class-horizontalalignparam)|否|None|**命名参数。** 设置组件右侧对齐方式。|
|middle|?[HorizontalAlignParam](#class-horizontalalignparam)|否|None|**命名参数。** 设置组件水平居中对齐方式。|
|top|?[VerticalAlignParam](#class-verticalalignparam)|否|None|**命名参数。** 设置组件顶部对齐方式。|
|bottom|?[VerticalAlignParam](#class-verticalalignparam)|否|None|**命名参数。** 设置组件顶部对齐方式。|
|center|?[VerticalAlignParam](#class-verticalalignparam)|否|None|**命名参数。** 设置组件垂直居中对齐方式。|
|bias|?[Bias](#class-bias)|否|None|**命名参数。** 设置组件对齐的偏移量。初始值为Bias()。|

## class EdgeStyles

```cangjie
public class EdgeStyles {
    public var top: ?BorderStyle
    public var right: ?BorderStyle
    public var bottom: ?BorderStyle
    public var left: ?BorderStyle
    public init(top!: ?BorderStyle = None, right!: ?BorderStyle = None, bottom!: ?BorderStyle = None, left!: ?BorderStyle = None)
}
```

**功能：** 边框样式，用于描述组件边框四条边的样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var top

```cangjie
public var top: ?BorderStyle
```

**功能：** 设置组件上边框样式。

**类型：** ?[BorderStyle](#enum-borderstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var right

```cangjie
public var right: ?BorderStyle
```

**功能：** 设置组件右边框样式。

**类型：** ?[BorderStyle](#enum-borderstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var bottom

```cangjie
public var bottom: ?BorderStyle
```

**功能：** 设置组件下边框样式。

**类型：** ?[BorderStyle](#enum-borderstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var left

```cangjie
public var left: ?BorderStyle
```

**功能：** 设置组件左边框样式。

**类型：** ?[BorderStyle](#enum-borderstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?BorderStyle, ?BorderStyle, ?BorderStyle, ?BorderStyle)

```cangjie
public init(top!: ?BorderStyle = None, right!: ?BorderStyle = None, bottom!: ?BorderStyle = None, left!: ?BorderStyle = None)
```

**功能：** 构造EdgeStyles对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|top|?[BorderStyle](./cj-common-types.md#enum-borderstyle)|否|None|**命名参数。** 组件上边框样式。初始值为BorderStyle.Solid。|
|right|?[BorderStyle](./cj-common-types.md#enum-borderstyle)|否|None|**命名参数。** 组件右边框样式。初始值为BorderStyle.Solid。|
|bottom|?[BorderStyle](./cj-common-types.md#enum-borderstyle)|否|None|**命名参数。** 组件下边框样式。初始值为BorderStyle.Solid。|
|left|?[BorderStyle](./cj-common-types.md#enum-borderstyle)|否|None|**命名参数。** 组件左边框样式。初始值为BorderStyle.Solid。|

## class MultiShadowOptions

```cangjie
public open class MultiShadowOptions {
    public var radius: ?Length
    public var offsetX: ?Length
    public var offsetY: ?Length
    protected init(radius: ?Length, offsetX: ?Length, offsetY: ?Length)
}
```

**功能：** 多阴影选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var radius

```cangjie
public var radius: ?Length
```

**功能：** 阴影模糊半径。
单位：vp。
<p>**NOTE**:
<br>小于或等于0的值将作为默认值处理。
</p>

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var offsetX

```cangjie
public var offsetX: ?Length
```

**功能：** 设置阴影的水平偏移量。
单位：vp。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var offsetY

```cangjie
public var offsetY: ?Length
```

**功能：** 设置阴影的垂直偏移量。
单位：vp。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Length, ?Length, ?Length)

```cangjie
protected init(radius: ?Length, offsetX: ?Length, offsetY: ?Length)
```

**功能：** 构造一个MultiShadowOptions对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
| radius | ?[Length](./cj-common-types.md#interface-length) | 是 | - | 半径 |
| offsetX | ?[Length](./cj-common-types.md#interface-length) | 是 | - | X轴偏移 |
| offsetY | ?[Length](./cj-common-types.md#interface-length) | 是 | - | Y轴偏移 |

## class PickerTextStyle

```cangjie
public class PickerTextStyle {
    public var color: ?ResourceColor
    public var font: ?Font
    public init(color!: ?ResourceColor = None, font!: ?Font = None)
}
```

**功能：** 选择器文本样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var color

```cangjie
public var color: ?ResourceColor
```

**功能：** 设置选择器文本颜色。

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var font

```cangjie
public var font: ?Font
```

**功能：** 设置选择器文本字体。

**类型：** ?[Font](#class-font)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?ResourceColor, ?Font)

```cangjie
public init(color!: ?ResourceColor = None, font!: ?Font = None)
```

**功能：** 构造一个PickerTextStyle对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|color|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|None|**命名参数。** 设置选择器文本颜色。|
|font|?[Font](#class-font)|否|None|**命名参数。** 设置选择器文本字体。|

## class Font

```cangjie
public class Font {
    public var size: ?Length
    public var weight: ?FontWeight
    public var family: ?ResourceStr
    public var style: ?FontStyle
    public init(size!: ?Length = None, weight!: ?FontWeight = None, family!: ?ResourceStr = None, style!: ?FontStyle = None)
}
```

**功能：** 字体样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var size

```cangjie
public var size: ?Length
```

**功能：** 设置文本尺寸，使用fp单位。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var weight

```cangjie
public var weight: ?FontWeight
```

**功能：** 设置文本的字体粗细。

**类型：** ?[FontWeight](#enum-fontweight)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var family

```cangjie
public var family: ?ResourceStr
```

**功能：** 设置文本的字体列表。

**类型：** ?[ResourceStr](#interface-resourcestr)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var style

```cangjie
public var style: ?FontStyle
```

**功能：** 设置文本的字体样式。

**类型：** ?[FontStyle](#enum-fontstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Length, ?FontWeight, ?ResourceStr, ?FontStyle)

```cangjie
public init(size!: ?Length = None, weight!: ?FontWeight = None, family!: ?ResourceStr = None, style!: ?FontStyle = None)
```

**功能：** 构造一个Font对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|size|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 设置文本尺寸，Length为Int64、Float64类型时，使用fp单位。不支持百分比设置。初始值为16.fp。|
|weight|?[FontWeight](./cj-common-types.md#enum-fontweight)|否|None|**命名参数。** 设置文本的字体粗细。初始值为FontWeight.Normal。|
|family|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None|**命名参数。**设置文本的字体列表。使用多个字体，使用','进行分割，优先级按顺序生效。例如：'Arial, HarmonyOS Sans'。初始值为"HarmonyOS Sans"。|
|style|?[FontStyle](./cj-common-types.md#enum-fontstyle)|否|None|**命名参数。** 设置文本的字体样式。初始值为FontStyle.Normal。|

## class BlurOptions

```cangjie
public class BlurOptions {
    public var grayscale: ?VArray<Float32, $2>
    public init(grayscale: ?VArray<Float32, $2>)
}
```

**功能：** 灰阶模糊参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var grayscale

```cangjie
public var grayscale: ?VArray<Float32, $2>
```

**功能：** 灰阶模糊参数，参数取值范围[0, 127]。

**类型：** ?VArray<Float32, $2>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?VArray\<Float32, \$2>)

```cangjie
public init(grayscale: ?VArray<Float32, $2>)
```

**功能：** 构造BlurOptions对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|grayscale|?VArray<Float32, $2>|是|-|灰阶模糊参数，参数取值范围[0, 127]。|

## class ForegroundBlurStyleOptions

```cangjie
public class ForegroundBlurStyleOptions {
    public var colorMode: ?ThemeColorMode
    public var adaptiveColor: ?AdaptiveColor
    public var blurOptions: ?BlurOptions
    public var scale: ?Float32
    public init(colorMode!: ?ThemeColorMode = None, adaptiveColor!: ?AdaptiveColor = None, blurOptions!: ?BlurOptions = None, scale!: ?Float32 = None)
}
```

**功能：** 内容模糊选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var colorMode

```cangjie
public var colorMode: ?ThemeColorMode
```

**功能：** 内容模糊效果使用的深浅色模式。

**类型：** ?[ThemeColorMode](#enum-themecolormode)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var adaptiveColor

```cangjie
public var adaptiveColor: ?AdaptiveColor
```

**功能：** 内容模糊效果使用的取色模式。

**类型：** ?[AdaptiveColor](#enum-adaptivecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var blurOptions

```cangjie
public var blurOptions: ?BlurOptions
```

**功能：** 灰阶模糊参数。

**类型：** ?[BlurOptions](#class-bluroptions)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var scale

```cangjie
public var scale: ?Float32
```

**功能：** 内容模糊效果程度。取值范围：[0.0, 1.0]。

**类型：** ?Float32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?ThemeColorMode, ?AdaptiveColor, ?BlurOptions, ?Float32)

```cangjie
public init(colorMode!: ?ThemeColorMode = None, adaptiveColor!: ?AdaptiveColor = None, blurOptions!: ?BlurOptions = None, scale!: ?Float32 = None)
```

**功能：** 构造一个ForegroundBlurStyleOptions类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|colorMode|?[ThemeColorMode](./cj-common-types.md#enum-themecolormode)|否|None|**命名参数。** 内容模糊效果使用的深浅色模式。初始值为ThemeColorMode.System。|
|adaptiveColor|?[AdaptiveColor](./cj-common-types.md#enum-adaptivecolor)|否|None|**命名参数。** 内容模糊效果使用的取色模式。初始值为AdaptiveColor.Default。|
|blurOptions|?[BlurOptions](#class-bluroptions)|否|None|**命名参数。** 灰阶模糊参数。初始值为BlurOptions([0.0, 0.0])。|
|scale|?Float32|否|None|**命名参数。** 内容模糊效果程度。<br>取值范围：[0.0, 1.0]。初始值为1.0。|

## class PopupButton

```cangjie
public class PopupButton {
    public var value: ?String
    public var action: () -> Unit
    public init(value!: ?String, action!: () -> Unit)
}
```

**功能：** 构建弹窗按钮。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var value

```cangjie
public var value: ?String
```

**功能：** 按钮的文本内容。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var action

```cangjie
public var action: () -> Unit
```

**功能：** 按钮的点击事件。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?String, () -> Unit)

```cangjie
public init(value!: ?String, action!: () -> Unit)
```

**功能：** 构建弹窗按钮。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?String|是|-|**命名参数。** 按钮的文本内容。|
|action|() -> Unit|是|-|**命名参数。** 按钮的点击事件。|

## class PopupStateChangeParam

```cangjie
public class PopupStateChangeParam {
    public var isVisible: Bool
    public init(value: Bool)
}
```

**功能：** 按钮的点击事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var isVisible

```cangjie
public var isVisible: Bool
```

**功能：** 弹窗是否可见。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(Bool)

```cangjie
public init(value: Bool)
```

**功能：** 设置弹窗状态参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|Bool|是|-|弹窗是否可见。|

## class PopupOptions

```cangjie
public class PopupOptions {
    public var message: ?String
    public var placement: ?Placement
    public var primaryButton: ?PopupButton
    public var secondaryButton: ?PopupButton
    public var onStateChange: ?(PopupStateChangeParam) -> Unit
    public var arrowOffset: ?Length
    public var showInSubWindow: ?Bool
    public var mask: ?ResourceColor
    public var messageOptions: ?PopupMessageOptions
    public var targetSpace: ?Length
    public var enableArrow: ?Bool
    public var offset: ?Position
    public var popupColor: ?ResourceColor
    public var autoCancel: ?Bool
    public var width: ?Length
    public var arrowPointPosition: Option<ArrowPointPosition>
    public var arrowWidth: ?Length
    public var arrowHeight: ?Length
    public var radius: ?Length
    public var shadow: ?ShadowStyle
    public var backgroundBlurStyle: ?BlurStyle
    public var transition: ?TransitionEffect
    public var onWillDismiss: ?(DismissPopupAction) -> Unit
    public var followTransformOfTarget: ?Bool
    public init(
        message!: ?String,
        placement!: ?Placement = Option.None,
        primaryButton!: ?PopupButton = None,
        secondaryButton!: ?PopupButton = None,
        onStateChange!: Option<(PopupStateChangeParam) -> Unit> = Option.None,
        arrowOffset!: ?Length = None,
        showInSubWindow!: ?Bool = None,
        mask!: ?Color = None,
        messageOptions!: ?PopupMessageOptions = None,
        targetSpace!: ?Length = None,
        enableArrow!: ?Bool = None,
        offset!: ?Position = None,
        popupColor!: ?Color = None,
        autoCancel!: ?Bool = None,
        width!: ?Length = None,
        arrowPointPosition!: ?ArrowPointPosition = None,
        arrowWidth!: ?Length = None,
        arrowHeight!: ?Length = None,
        radius!: ?Length = None,
        shadow!: ?ShadowStyle = None,
        backgroundBlurStyle!: ?BlurStyle = Option.None,
        transition!: ?TransitionEffect = Option.None,
        onWillDismiss!: Option<(DismissPopupAction) -> Unit> = None,
        followTransformOfTarget!: ?Bool = None
    )
}
```

**功能：** 弹窗的参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var message

```cangjie
public var message: ?String
```

**功能：** 设置弹窗信息内容。

**类型：** ?String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var placement

```cangjie
public var placement: ?Placement
```

**功能：** 设置popup组件相对于目标的显示位置，默认值为Placement.Bottom。如果同时设置了placementOnTop和placement，则以placement的设置生效。

**类型：** ?[Placement](#enum-placement)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var primaryButton

```cangjie
public var primaryButton: ?PopupButton
```

**功能：** 设置第一个按钮。value: 弹窗里主按钮的文本。action: 点击主按钮的回调函数。

**类型：** ?[PopupButton](#class-popupbutton)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var secondaryButton

```cangjie
public var secondaryButton: ?PopupButton
```

**功能：** 设置第二个按钮。 value: 弹窗里辅助按钮的文本。action: 点击辅助按钮的回调函数。

**类型：** ?[PopupButton](#class-popupbutton)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var onStateChange

```cangjie
public var onStateChange: ?(PopupStateChangeParam) -> Unit
```

**功能：** 设置弹窗状态变化事件回调，参数为弹窗当前的显示状态。

**类型：** ?([PopupStateChangeParam](#class-popupstatechangeparam)) -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var arrowOffset

```cangjie
public var arrowOffset: ?Length
```

**功能：** 设置popup箭头在弹窗处的偏移。箭头在气泡上下方时，数值为0表示箭头居最左侧，偏移量为箭头至最左侧的距离，默认居中。箭头在气泡左右侧时，偏移量为箭头至最上侧的距离，默认居中。如果显示在屏幕边缘，气泡会自动左右偏移，数值为0时箭头始终指向绑定组件。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var showInSubWindow

```cangjie
public var showInSubWindow: ?Bool
```

**功能：** 设置是否在子窗口显示气泡，默认值为false，不显示。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var mask

```cangjie
public var mask: ?ResourceColor
```

**功能：** 设置遮罩层的颜色。

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var messageOptions

```cangjie
public var messageOptions: ?PopupMessageOptions
```

**功能：** 设置弹窗信息文本参数。

**类型：** ?[PopupMessageOptions](#class-popupmessageoptions)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var targetSpace

```cangjie
public var targetSpace: ?Length
```

**功能：** 设置popup与目标的间隙。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var offset

```cangjie
public var offset: ?Position
```

**功能：** 设设置popup组件相对于placement设置的显示位置的偏移。不支持设置百分比。

**类型：** ?[Position](#class-position)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var enableArrow

```cangjie
public var enableArrow: ?Bool
```

**功能：** 设置是否显示箭头。默认值：true。当页面可用空间无法让气泡完全避让时，气泡会覆盖到组件上并且不显示箭头。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var popupColor

```cangjie
public var popupColor: ?ResourceColor
```

**功能：** 设置提示气泡的颜色。如需去除模糊背景填充效果，需将backgroundBlurStyle设置为BlurStyle.NONE。

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var autoCancel

```cangjie
public var autoCancel: ?Bool
```

**功能：** 页面有操作时，是否自动关闭气泡。默认值：true。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var width

```cangjie
public var width: ?Length
```

**功能：** 设置弹出窗口的宽度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var arrowPointPosition

```cangjie
public var arrowPointPosition: Option<ArrowPointPosition>
```

**功能：** 设置气泡尖角相对于父组件显示位置，气泡尖角在垂直和水平方向上有 "Start"、"Center"、"End"三个位置点可选。以上所有位置点均位于父组件区域所在的范围内，不会超出父组件的边界范围。

**类型：** Option<[ArrowPointPosition](#enum-arrowpointposition)>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var arrowWidth

```cangjie
public var arrowWidth: ?Length
```

**功能：** 箭头的宽度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var arrowHeight

```cangjie
public var arrowHeight: ?Length
```

**功能：** 箭头的高度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var radius

```cangjie
public var radius: ?Length
```

**功能：** 弹出窗口的圆角。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var shadow

```cangjie
public var shadow: ?ShadowStyle
```

**功能：** 设置气泡阴影。

**类型：** ?[ShadowStyle](#enum-shadowstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var backgroundBlurStyle

```cangjie
public var backgroundBlurStyle: ?BlurStyle
```

**功能：** 设置气泡模糊背景参数。

**类型：** ?[BlurStyle](#enum-blurstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var transition

```cangjie
public var transition: ?TransitionEffect
```

**功能：** 自定义设置popup弹窗显示和退出的动画效果。

> **说明：**
>
> - 如果不设置，则使用默认的显示/退出动效。
> - 显示动效中按back键，打断显示动效，执行退出动效，动画效果为显示动效与退出动效的曲线叠加后的效果。
> - 退出动效中按back键，不会打断退出动效，退出动效继续执行，back键不被响应。

**类型：** ?[TransitionEffect](./cj-animation-transition.md#class-transitioneffect)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var onWillDismiss

```cangjie
public var onWillDismiss: ?(DismissPopupAction) -> Unit
```

**功能：** 设置拦截退出事件且执行回调函数。

> **说明：**
>
> 在onWillDismiss回调中，不能再做onWillDismiss拦截。

**类型：** ?([DismissPopupAction](#class-dismisspopupaction)) -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var followTransformOfTarget

```cangjie
public var followTransformOfTarget: ?Bool
```

**功能：** 气泡绑定的宿主组件或其宿主组件的父容器添加了旋转、缩放等变换时，设置气泡是否能显示在对应变化后的位置上。默认值：false。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?String, ?Placement, ?PopupButton, ?PopupButton, Option\<(PopupStateChangeParam) -> Unit>, ?Length, ?Bool, ?Color, ?PopupMessageOptions, ?Length, ?Bool, ?Position, ?Color, ?Bool, ?Length, ?ArrowPointPosition, ?Length, ?Length, ?Length, ?ShadowStyle, ?BlurStyle, ?TransitionEffect, Option\<(DismissPopupAction) -> Unit>, ?Bool)

```cangjie
public init(
    message!: ?String,
    placement!: ?Placement = Option.None,
    primaryButton!: ?PopupButton = None,
    secondaryButton!: ?PopupButton = None,
    onStateChange!: Option<(PopupStateChangeParam) -> Unit> = Option.None,
    arrowOffset!: ?Length = None,
    showInSubWindow!: ?Bool = None,
    mask!: ?Color = None,
    messageOptions!: ?PopupMessageOptions = None,
    targetSpace!: ?Length = None,
    enableArrow!: ?Bool = None,
    offset!: ?Position = None,
    popupColor!: ?Color = None,
    autoCancel!: ?Bool = None,
    width!: ?Length = None,
    arrowPointPosition!: ?ArrowPointPosition = None,
    arrowWidth!: ?Length = None,
    arrowHeight!: ?Length = None,
    radius!: ?Length = None,
    shadow!: ?ShadowStyle = None,
    backgroundBlurStyle!: ?BlurStyle = Option.None,
    transition!: ?TransitionEffect = Option.None,
    onWillDismiss!: Option<(DismissPopupAction) -> Unit> = None,
    followTransformOfTarget!: ?Bool = None
)
```

**功能：** 构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|message|?String|是|-|**命名参数。** 设置弹窗信息内容。|
|placement|?[Placement](#enum-placement)|否|Option.None|**命名参数。** 设置popup组件相对于目标的显示位置。|
|primaryButton|?[PopupButton](#class-popupbutton)|否|None|**命名参数。** 设置第一个按钮。初始值为PopupButton(value: "", action: {=>})。|
|secondaryButton|?[PopupButton](#class-popupbutton)|否|None|**命名参数。** 设置第二个按钮。初始值为PopupButton(value: "", action: {=>})。|
|onStateChange|Option<([PopupStateChangeParam](#class-popupstatechangeparam)) -> Unit>|否|Option.None|**命名参数。** 设置弹窗状态变化事件回调。|
|arrowOffset|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 设置popup箭头在弹窗处的偏移。初始值为0.vp。|
|showInSubWindow|?Bool|否|None|**命名参数。** 设置是否在子窗口显示气泡。初始值为false。|
|mask|?[Color](./cj-common-types.md#class-color)|否|None|**命名参数。** 设置遮罩层的颜色。初始值为Color(0x1000000)。|
|messageOptions|?[PopupMessageOptions](#class-popupmessageoptions)|否|None|**命名参数。** 设置弹窗信息文本参数。初始值为PopupMessageOptions()。|
|targetSpace|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 设置popup与目标的间隙。初始值为0.vp。|
|enableArrow|?Bool|否|None|**命名参数。** 是否启用箭头，初始值为true。|
|offset|?[Position](#class-position)|否|None|**命名参数。** 设置popup组件相对于placement设置的显示位置的偏移。初始值为Position(x:0.0, y: 0.0)。|
|popupColor|?[Color](./cj-common-types.md#class-color)|否|None|**命名参数。** 设置提示气泡的颜色。初始值为Color(0x1000000)。|
|autoCancel|?Bool|否|None|**命名参数。** 页面有操作时，设置是否自动关闭气泡。初始值为true。|
|width|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 设置弹窗宽度。初始值为0.vp。|
|arrowPointPosition|?[ArrowPointPosition](./cj-common-types.md#enum-arrowpointposition)|否|None|**命名参数。** 设置气泡尖角相对于父组件显示位置。|
|arrowWidth|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 箭头宽度。初始值为16.vp。|
|arrowHeight|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 箭头高度。初始值为8.vp。|
|radius|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 设置气泡圆角半径。初始值为20.vp。|
|shadow|?[ShadowStyle](./cj-common-types.md#enum-shadowstyle)|否|None|**命名参数。** 设置气泡阴影。初始值为ShadowStyle.OuterDefaultMD。|
|backgroundBlurStyle|?[BlurStyle](#enum-blurstyle)|否|Option.None|**命名参数。** 设置气泡模糊背景参数。初始值为BlurStyle.ComponentUltraThick。|
|transition|?[TransitionEffect](./cj-animation-transition.md#class-transitioneffect)|否|Option.None|**命名参数。** 自定义设置popup弹窗显示和退出的动画效果。|
|onWillDismiss|Option\<([DismissPopupAction](#class-dismisspopupaction)) -> Unit>|否|None|**命名参数。**设置拦截退出事件且执行回调函数。|
|followTransformOfTarget|?Bool|否|None|**命名参数。** 气泡绑定的宿主组件或其宿主组件的父容器添加了旋转、缩放等变换时，设置气泡是否能显示在对应变化后的位置上。|

## class MenuElement

```cangjie
public class MenuElement {
    public init(value!: ?ResourceStr, action!: () -> Unit)
}
```

**功能：** 配置菜单项图标和文本。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?ResourceStr, () -> Unit)

```cangjie
public init(value!: ?ResourceStr, action!: () -> Unit)
```

**功能：** 创建MenuElement对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|**命名参数。** 菜单项文本。|
|action|() -> Unit|是|-|**命名参数。** 点击菜单项的事件回调。|

## class CustomPopupOptions

```cangjie
public class CustomPopupOptions {
    public var builder: CustomBuilder
    public var placement: ?Placement
    public var backgroundColor: ?Color
    public var enableArrow: ?Bool
    public var autoCancel: ?Bool
    public var onStateChange: Option<(PopupStateChangeParam) -> Unit>
    public var popupColor: ?Color
    public var arrowOffset: ?Length
    public var showInSubWindow: ?Bool
    public var mask: ?Color
    public var targetSpace: ?Length
    public var offset: ?Position
    public var width: ?Length
    public var arrowPointPosition: Option<ArrowPointPosition>
    public var arrowWidth: ?Length
    public var arrowHeight: ?Length
    public var radius: ?Length
    public var shadow: ?ShadowStyle
    public var backgroundBlurStyle: ?BlurStyle
    public var focusable: ?Bool
    public var transition: Option<TransitionEffect>
    public var onWillDismiss: Option<(DismissPopupAction) -> Unit>
    public var followTransformOfTarget: ?Bool
    public init(
        builder!: () -> Unit,
        placement!: ?Placement = Option.None,
        popupColor!: ?Color = None,
        enableArrow!: ?Bool = None,
        autoCancel!: ?Bool = None,
        onStateChange!: Option<(PopupStateChangeParam) -> Unit> = Option.None,
        showInSubWindow!: ?Bool = None,
        backgroundColor!: ?Color = None,
        arrowOffset!: ?Length = None,
        mask!: ?Color = None,
        targetSpace!: ?Length = None,
        offset!: ?Position = None,
        width!: ?Length = None,
        arrowPointPosition!: ?ArrowPointPosition = None,
        arrowWidth!: ?Length = None,
        arrowHeight!: ?Length = None,
        radius!: ?Length = None,
        shadow!: ?ShadowStyle = None,
        backgroundBlurStyle!: ?BlurStyle = Option.None,
        focusable!: ?Bool = None,
        transition!: Option<TransitionEffect> = Option.None,
        onWillDismiss!: Option<(DismissPopupAction) -> Unit> = None,
        followTransformOfTarget!: ?Bool = None
    )
}
```

**功能：** 弹出弹窗的参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var builder

```cangjie
public var builder: CustomBuilder
```

**功能：** 提示气泡内容的构造器。

> **说明：**
>
> popup为通用属性，自定义popup中不支持再次弹出popup。对builder下的第一层容器组件不支持使用position属性，如果使用将导致气泡不显示。builder中若使用自定义组件，自定义组件的aboutToAppear和aboutToDisappear生命周期与popup弹窗的显隐无关，不能使用其生命周期判断popup弹窗的显隐。

**类型：** [CustomBuilder](#type-custombuilder)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var placement

```cangjie
public var placement: ?Placement
```

**功能：** 设置气泡组件优先显示的位置，当前位置显示不下时，会自动调整位置

**类型：** ?[Placement](#enum-placement)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var backgroundColor

```cangjie
public var backgroundColor: ?Color
```

**功能：** 设置提示气泡背景颜色。

**类型：** ?[Color](./cj-common-types.md#class-color)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var enableArrow

```cangjie
public var enableArrow: ?Bool
```

**功能：** 设置是否显示箭头。如果箭头所在方位侧的气泡长度不足以显示下箭头，则会默认不显示箭头。例如placement设置为Left，此时如果气泡高度小于箭头的宽度（32.vp）与气泡圆角两倍（48.vp）之和（80.vp），则实际不会显示箭头。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var autoCancel

```cangjie
public var autoCancel: ?Bool
```

**功能：** 页面有操作时，设置是否自动关闭气泡。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var onStateChange

```cangjie
public var onStateChange: Option<(PopupStateChangeParam) -> Unit>
```

**功能：** 设置弹窗状态变化事件回调，参数为弹窗当前的显示状态。

**类型：** Option<([PopupStateChangeParam](#class-popupstatechangeparam)) -> Unit>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var popupColor

```cangjie
public var popupColor: ?Color
```

**功能：** 设置提示气泡的颜色。如需去除模糊背景填充效果，需将backgroundBlurStyle设置为BlurStyle.NONE。

**类型：** ?[Color](./cj-common-types.md#class-color)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var arrowOffset

```cangjie
public var arrowOffset: ?Length
```

**功能：** 设置popup箭头在弹窗处的偏移。箭头在气泡上下方时，数值为0表示箭头居最左侧，偏移量为箭头至最左侧的距离，默认居中。箭头在气泡左右侧时，偏移量为箭头至最上侧的距离，默认居中。如果显示在屏幕边缘，气泡会自动左右偏移，数值为0时箭头始终指向绑定组件。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var showInSubWindow

```cangjie
public var showInSubWindow: ?Bool
```

**功能：** 设置是否在子窗口显示气泡，默认值为false，不显示。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var mask

```cangjie
public var mask: ?Color
```

**功能：** 设置遮罩层的颜色。

**类型：** ?[Color](./cj-common-types.md#class-color)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var targetSpace

```cangjie
public var targetSpace: ?Length
```

**功能：** 设置popup与目标的间隙。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var offset

```cangjie
public var offset: ?Position
```

**功能：** 设置popup组件相对于placement设置的显示位置的偏移。不支持设置百分比。

**类型：** ?[Position](#class-position)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var width

```cangjie
public var width: ?Length
```

**功能：** 设置弹窗宽度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var arrowPointPosition

```cangjie
public var arrowPointPosition: Option<ArrowPointPosition>
```

**功能：** 设置气泡尖角相对于父组件显示位置，气泡尖角在垂直和水平方向上有 "Start"、"Center"、"End"三个位置点可选。以上所有位置点均位于父组件区域所在的范围内，不会超出父组件的边界范围。

**类型：** Option<[ArrowPointPosition](#enum-arrowpointposition)>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var arrowWidth

```cangjie
public var arrowWidth: ?Length
```

**功能：** 设置箭头宽度。若所设置的箭头宽度超过所在边的长度减去两倍的气泡圆角大小，则不绘制气泡箭头。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var arrowHeight

```cangjie
public var arrowHeight: ?Length
```

**功能：** 箭头的高度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var radius

```cangjie
public var radius: ?Length
```

**功能：** 弹出窗口的圆角。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var shadow

```cangjie
public var shadow: ?ShadowStyle
```

**功能：** 弹出窗口阴影的样式。

**类型：** ?[ShadowStyle](#enum-shadowstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var backgroundBlurStyle

```cangjie
public var backgroundBlurStyle: ?BlurStyle
```

**功能：** 弹出窗口的背景模糊样式。

**类型：** ?[BlurStyle](#enum-blurstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var focusable

```cangjie
public var focusable: ?Bool
```

**功能：** 设置气泡弹出后是否获焦。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var transition

```cangjie
public var transition: Option<TransitionEffect>
```

**功能：** 自定义设置popup弹窗显示和退出的动画效果。

**类型：** Option<[TransitionEffect](./cj-animation-transition.md#class-transitioneffect)>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var onWillDismiss

```cangjie
public var onWillDismiss: Option<(DismissPopupAction) -> Unit>
```

**功能：** 设置拦截退出事件且执行回调函数。

> **说明：**
>
> 在onWillDismiss回调中，不能再做onWillDismiss拦截。

**类型：** Option<([DismissPopupAction](#class-dismisspopupaction)) -> Unit>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var followTransformOfTarget

```cangjie
public var followTransformOfTarget: ?Bool
```

**功能：** 气泡绑定的宿主组件或其宿主组件的父容器添加了旋转、缩放等变换时，气泡是否能显示在对应变化后的位置上。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(() -> Unit, ?Placement, ?Color, ?Bool, ?Bool, Option\<(PopupStateChangeParam) -> Unit>, ?Bool, ?Color, ?Length, ?Color, ?Length, ?Position, ?Length, ?ArrowPointPosition, ?Length, ?Length, ?Length, ?ShadowStyle, ?BlurStyle, ?Bool, Option\<TransitionEffect>, Option\<(DismissPopupAction) -> Unit>, ?Bool)

```cangjie
public init(
    builder!: () -> Unit,
    placement!: ?Placement = Option.None,
    popupColor!: ?Color = None,
    enableArrow!: ?Bool = None,
    autoCancel!: ?Bool = None,
    onStateChange!: Option<(PopupStateChangeParam) -> Unit> = Option.None,
    showInSubWindow!: ?Bool = None,
    backgroundColor!: ?Color = None,
    arrowOffset!: ?Length = None,
    mask!: ?Color = None,
    targetSpace!: ?Length = None,
    offset!: ?Position = None,
    width!: ?Length = None,
    arrowPointPosition!: ?ArrowPointPosition = None,
    arrowWidth!: ?Length = None,
    arrowHeight!: ?Length = None,
    radius!: ?Length = None,
    shadow!: ?ShadowStyle = None,
    backgroundBlurStyle!: ?BlurStyle = Option.None,
    focusable!: ?Bool = None,
    transition!: Option<TransitionEffect> = Option.None,
    onWillDismiss!: Option<(DismissPopupAction) -> Unit> = None,
    followTransformOfTarget!: ?Bool = None
)
```

**功能：** 构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|builder|() -> Unit|是|-|**命名参数。** 提示气泡内容的构造器。<br> **说明：** 仅支持接收@Builder修饰的自定义构建函数。|
|placement|?[Placement](#enum-placement)|否|Option.None|**命名参数。** 气泡组件优先显示的位置。<br>**说明：** 当前位置显示不下时，会自动调整位置。初始值为Placement.Bottom。|
|popupColor|?[Color](./cj-common-types.md#class-color)|否|None|**命名参数。** 提示气泡的背景颜色。初始值为Color(0x1000000)。|
|enableArrow|?Bool|否|None|**命名参数。** 是否显示箭头。<br>**说明：** 如果箭头所在方位侧的气泡长度不足以显示下箭头，则会默认不显示箭头。比如：placement设置为Left，但气泡高度小于箭头的宽度（32vp），则实际不会显示箭头。初始值为true。|
|autoCancel|?Bool|否|None|**命名参数。** 页面有操作时，是否自动关闭气泡。初始值为true。|
|onStateChange|Option<([PopupStateChangeParam](#class-popupstatechangeparam)) -> Unit>|否|Option.None|**命名参数。** 弹窗状态变化事件回调，参数为弹窗当前的显示状态。|
|showInSubWindow|?Bool|否|None|**命名参数。** 是否在子窗口显示气泡。初始值为false。|
|backgroundColor|?[Color](./cj-common-types.md#class-color)|否|None|**命名参数。** 提示气泡的背景颜色。初始值为Color(0x1000000)。|
|arrowOffset|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** popup箭头在弹窗处的偏移。<br>**说明：** 箭头在气泡上下方时，数值为0表示箭头居最左侧，偏移量为箭头至最左侧的距离，默认居中。箭头在气泡左右侧时，偏移量为箭头至最上侧的距离，默认居中。如果显示在屏幕边缘，气泡会自动左右偏移，数值为0时箭头始终指向绑定组件。初始值为0.vp。|
|mask|?[Color](./cj-common-types.md#class-color)|否|None|**命名参数。** 提示气泡遮障层的颜色。|
|targetSpace|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 设置popup与目标的间隙。初始值为0.vp。|
|offset|?[Position](#class-position)|否|None|**命名参数。** popup组件相对于placement设置的显示位置的偏移。<br>**说明：** 不支持设置百分比。 |
|width|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 弹窗宽度。<br>**说明：**  showInSubWindow=true时最大高度为设备屏幕高度，showInSubWindow=false时最大高度为应用窗口高度。高度限定逻辑=最大高度-状态栏高度（没有时高度为0）-dock栏高度（没有时高度为0）-40VP-40VP。初始值为0.vp。|
|arrowPointPosition|?[ArrowPointPosition](./cj-common-types.md#enum-arrowpointposition)|否|None|**命名参数。** 气泡尖角相对于父组件显示位置，气泡尖角在垂直和水平方向上有 ”Start“、”Center“、”End“三个位置点可选。以上所有位置点均位于父组件区域的范围内，不会超出父组件的边界范围。|
|arrowWidth|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 箭头宽度。<br>**说明：** 若所设置的箭头宽度超过所在边的长度减去两倍的气泡圆角大小，则不绘制气泡箭头。初始值为16.vp。|
|arrowHeight|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 箭头高度。<br>**说明：** 不支持设置百分比。初始值为16.vp。|

## class SheetOptions

```cangjie
public class SheetOptions <: BindOptions {
    public init(backgroundColor!: Option<ResourceColor> = Option.None, onAppear!: Option<() -> Unit> = Option.None, onDisappear!: Option<() -> Unit> = Option.None, onWillAppear!: Option<() -> Unit> = Option.None, onWillDisappear!: Option<() -> Unit> = Option.None, height!: Option<SheetSize> = Option.None, detents!: Option<Array<SheetSize>> = Option.None, preferType!: Option<SheetType> = Option.None, showClose!: Option<Bool> = Option.None, dragBar!: Option<Bool> = Option.None, blurStyle!: Option<BlurStyle> = Option.None, maskColor!: Option<Color> = Option.None, title!: Option<() -> Unit> = Option.None, enableOutsideInteractive!: Option<Bool> = Option.None, shouldDismiss!: Option<(SheetDismiss) -> Unit> = Option.None, onWillDismiss!: Option<(DismissSheetAction) -> Unit> = Option.None, onWillSpringBackWhenDismiss!: Option<(SpringBackAction) -> Unit> = Option.None, onHeightDidChange!: Option<(Float32) -> Unit> = Option.None, onDetentsDidChange!: Option<(Float32) -> Unit> = Option.None, onWidthDidChange!: Option<(Float32) -> Unit> = Option.None, onTypeDidChange!: Option<(Float32) -> Unit> = Option.None, borderWidth!: Option<Length> = None, borderColor!: Option<Color> = None, borderStyle!: Option<EdgeStyles> = None, width!: Option<Length> = None, shadow!: Option<ShadowOptions> = None, mode!: Option<SheetMode> = None, scrollSizeMode!: Option<ScrollSizeMode> = None)
}
```

**功能：** 配置半模态页面的可选属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [BindOptions](#class-bindoptions)

### init(Option\<ResourceColor>, Option\<() -> Unit>, Option\<() -> Unit>, Option\<() -> Unit>, Option\<() -> Unit>, Option\<SheetSize>, Option\<Array\<SheetSize>>, Option\<SheetType>, Option\<Bool>, Option\<Bool>, Option\<BlurStyle>, Option\<Color>, Option\<() -> Unit>, Option\<Bool>, Option\<(SheetDismiss) -> Unit>, Option\<(DismissSheetAction) -> Unit>, Option\<(SpringBackAction) -> Unit>, Option\<(Float32) -> Unit>, Option\<(Float32) -> Unit>, Option\<(Float32) -> Unit>, Option\<(Float32) -> Unit>, Option\<Length>, Option\<Color>, Option\<EdgeStyles>, Option\<Length>, Option\<ShadowOptions>, Option\<SheetMode>, Option\<ScrollSizeMode>)

```cangjie
public init(backgroundColor!: Option<ResourceColor> = Option.None, onAppear!: Option<() -> Unit> = Option.None, onDisappear!: Option<() -> Unit> = Option.None, onWillAppear!: Option<() -> Unit> = Option.None, onWillDisappear!: Option<() -> Unit> = Option.None, height!: Option<SheetSize> = Option.None, detents!: Option<Array<SheetSize>> = Option.None, preferType!: Option<SheetType> = Option.None, showClose!: Option<Bool> = Option.None, dragBar!: Option<Bool> = Option.None, blurStyle!: Option<BlurStyle> = Option.None, maskColor!: Option<Color> = Option.None, title!: Option<() -> Unit> = Option.None, enableOutsideInteractive!: Option<Bool> = Option.None, shouldDismiss!: Option<(SheetDismiss) -> Unit> = Option.None, onWillDismiss!: Option<(DismissSheetAction) -> Unit> = Option.None, onWillSpringBackWhenDismiss!: Option<(SpringBackAction) -> Unit> = Option.None, onHeightDidChange!: Option<(Float32) -> Unit> = Option.None, onDetentsDidChange!: Option<(Float32) -> Unit> = Option.None, onWidthDidChange!: Option<(Float32) -> Unit> = Option.None, onTypeDidChange!: Option<(Float32) -> Unit> = Option.None, borderWidth!: Option<Length> = None, borderColor!: Option<Color> = None, borderStyle!: Option<EdgeStyles> = None, width!: Option<Length> = None, shadow!: Option<ShadowOptions> = None, mode!: Option<SheetMode> = None, scrollSizeMode!: Option<ScrollSizeMode> = None)
```

**功能：** 构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|backgroundColor|Option<[ResourceColor](./cj-common-types.md#interface-resourcecolor)>|否|Option.None|**命名参数。** 半模态页面的背板颜色。默认值为Color.White。|
|onAppear|Option\<() -> Unit>|否|Option.None|**命名参数。** 半模态页面显示（动画结束后）回调函数。|
|onDisappear|Option\<() -> Unit>|否|Option.None|**命名参数。** 半模态页面回退（动画结束后）回调函数。|
|onWillAppear|Option\<() -> Unit>|否|Option.None|**命名参数。** 半模态页面显示（动画开始前）回调函数。|
|onWillDisappear|Option\<() -> Unit>|否|Option.None|**命名参数。** 半模态页面回退（动画开始前）回调函数。<br>**说明：**<br>不允许在onWillDisappear函数中修改状态变量，可能会导致组件行为不稳定。|
|height|Option<[SheetSize](#enum-sheetsize)>|否|Option.None|**命名参数。** 半模态高度。<br>**说明：**<br>底部弹窗竖屏时，当设置detents时，该属性设置无效。<br>底部弹窗竖屏时，最大高度为距离信号栏8vp。<br>底部弹窗横屏时，该属性设置无效，高度为距离屏幕顶部8vp。<br>居中弹窗和跟手弹窗设置类型为SheetSize.Large和SheetSize.Mudium无效，显示默认高度560vp。居中弹窗和跟手弹窗最小高度为320vp，最大高度为窗口短边的90%。当使用Length设置的高度和使用SheetSize.FitContent自适应的高度大于最大高度，则显示最大高度，小于最小高度，则显示最小高度。|
|detents|Option<Array<[SheetSize](#enum-sheetsize)>>|否|Option.None|**命名参数。** 半模态页面的切换高度档位。<br>**说明：**<br>底部弹窗竖屏生效，元组中第一个高度为初始高度。<br>面板可跟手滑动切换档位，松手后是否滑动至目标档位有两个判断条件：速度和距离。速度超过阈值，则执行滑动至与手速方向一致的目标档位；速度小于阈值，则引入距离判断条件，当位移距离>当前位置与目标位置的1/2，滑动至与手速方向一致的目标档位，位移距离当前位置与目标位置的1/2，返回至当前档位。速度阈值：1000，距离阈值：50%。|
|preferType|Option<[SheetType](#enum-sheettype)>|否|Option.None|**命名参数。** 半模态页面的样式。<br>**说明：**<br>preferType不可设置为SheetType.Bottom|
|showClose|Option\<Bool>|否|Option.None|**命名参数。** 是否显示关闭图标，默认显示关闭图标。使用关闭图标关闭半模态页面时，需要在onDisappear回调函数中将isShow参数置为false。|
|dragBar|Option\<Bool>|否|Option.None|**命名参数。** 是否显示控制条。<br>**说明：**<br>半模态面板的dentents属性设置多个不同高度并且设置生效时，默认显示控制条。否则不显示控制条。|
|blurStyle|Option\<[BlurStyle](#enum-blurstyle)>|否|Option.None|**命名参数。** 半模态面板的模糊背景。|
|maskColor|Option<[Color](./cj-common-types.md#class-color)>|否|Option.None|**命名参数。** 半模态页面的背景蒙层颜色。|
|title|Option\<() -> Unit>|否|Option.None|**命名参数。** 半模态面板的标题。<br>**说明：** 仅支持接收@Builder修饰的自定义构建函数。|
|enableOutsideInteractive|Option\<Bool>|否|Option.None|**命名参数。** **命名参数。**  半模态所在页面是否允许交互。<br>**说明：**<br>设置为true时允许交互，不显示蒙层；设置为false时不允许交互，显示蒙层；若不进行设置，默认底部弹窗与居中弹窗不允许交互，跟手弹窗允许交互。当设置为true时，maskColor设置无效。|
|shouldDismiss|Option<([SheetDismiss](#class-sheetdismiss)) -> Unit>|否|Option.None|**命名参数。** 半模态页面交互式关闭回调函数。<br>**说明：**<br>当用户执行下拉关闭/back事件/点击蒙层关闭/关闭按钮关闭交互操作时，如果注册该回调函数，则不会立刻关闭。|
|onWillDismiss|Option<([DismissSheetAction](#class-dismisssheetaction)) -> Unit>|否|Option.None|**命名参数。** 半模态页面的交互式关闭回调函数允许开发者注册，以获取关闭操作的类型，并决定是否关闭半模态状态。<br>**说明：**<br>当用户触发关闭操作时，若已注册回调函数，则不会立即关闭页面，而是由开发者通过回调函数中的reason参数判断关闭操作的类型，进而根据具体原因自主选择是否关闭半模态页面。如果不注册该回调函数，则用户执行关闭操作时，正常关闭半模态，无其他行为。在onWillDismiss回调中，不能再做onWillDismiss拦截。建议在二次确认场景使用。|
|onWillSpringBackWhenDismiss|Option<([SpringBackAction](#class-springbackaction)) -> Unit>|否|Option.None|**命名参数。**  半模态页面交互式关闭前控制回弹函数允许开发者注册，以控制半模态页面交互式关闭时的回弹效果。<br>**说明：**<br>当用户触发执行下拉关闭操作并同时注册该回调函数与shouldDimiss或onWillDismiss时，由开发者控制下滑关闭时是否回弹。在回调函数中可以通过调用springBack来实现回弹效果。也可以通过不调用springBack来取消回弹效果。<br>若不注册该回调函数，但注册shouldDimiss或onWillDismiss时，则默认在下滑关闭时，会触发回弹效果，回弹后再根据shouldDimiss或onWillDismiss内的回调行为决定半模态是否关闭。<br>如果不注册该回调函数，且未注册shouldDimiss或onWillDismiss时，默认在下滑关闭时，触发半模态关闭。|
|onHeightDidChange|Option\<(Float32) -> Unit>|否|Option.None|**命名参数。** **命名参数。**  半模态页面高度变化回调函数。<br>**说明：**<br>底部弹窗时，只有档位变化和拖拽跟手才返回每一帧高度，拉起半模态和避让软键盘只返回最后的高度，其他弹窗只在半模态拉起返回最后高度。返回值为px。|
|onDetentsDidChange|Option\<(Float32) -> Unit>|否|Option.None|**命名参数。**  半模态页面档位变化回调函数。<br>**说明：**<br>底部弹窗时，档位变化返回最后的高度。返回值为px。|
|onWidthDidChange|Option\<(Float32) -> Unit>|否|Option.None|**命名参数。**  半模态页面宽度变化回调函数。<br>**说明：**<br>宽度变化时返回最后的宽度。返回值为px。|
|onTypeDidChange|Option\<(Float32) -> Unit>|否|Option.None|**命名参数。**  半模态页面形态变化回调函数。<br>**说明：**<br>形态变化时返回最后的形态。|
|borderWidth|Option<[Length](./cj-common-types.md#interface-length)>|否|None|**命名参数。**  设置半模态页面的边框宽度。可分别设置4个边框宽度。<br>百分比参数方式：以父元素半模态页面宽的百分比来设置半模态页面的边框宽度。<br>当半模态页面左边框和右边框大于半模态页面宽度，半模态页面上边框和下边框大于半模态页面高度，显示可能不符合预期。<br>**说明：**<br>底部弹窗时，底部边框宽度设置无效。|
|borderColor|Option<[Color](./cj-common-types.md#class-color)>|否|None|**命名参数。**  设置半模态页面的边框颜色。如果使用borderColor属性，需要和borderWidth属性一起使用。<br>**说明：**<br>底部弹窗时，底部边框颜色设置无效。|
|borderStyle|Option<[EdgeStyles](#class-edgestyles)>|否|None|**命名参数。**  设置半模态页面的边框样式。如果使用borderStyle属性，需要和borderWidth属性一起使用。<br>**说明：**<br>底部弹窗时，底部边框样式设置无效。|
|width|Option<[Length](./cj-common-types.md#interface-length)>|否|None|**命名参数。**  设置半模态页面的宽度。百分比参数方式：以父元素宽的百分比来设置半模态页面的宽度。|
|shadow|Option<[ShadowOptions](#class-shadowoptions)>|否|None|**命名参数。** 阴影。<br>初始值：<br>API version 26之前，初始值为ShadowOptions(radius: 0.0)；<br>从API version 26开始，初始值为ShadowOptions(radius: -1.0)。|
|mode|Option<[SheetMode](#enum-sheetmode)>|否|None|**命名参数。**  设置半模态页面的阴影。|
|scrollSizeMode|Option<[ScrollSizeMode](#enum-scrollsizemode)>|否|None|**命名参数。**  设置半模态面板滑动时，内容区域刷新时机。|

## class PopupMessageOptions

```cangjie
public class PopupMessageOptions {
    public var textColor: ?ResourceColor
    public var font: ?Font
    public init(textColor!: ?ResourceColor = None, font!: ?Font = None)
}
```

**功能：** 弹窗信息文本参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var textColor

```cangjie
public var textColor: ?ResourceColor
```

**功能：** 设置弹窗信息文本颜色。

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var font

```cangjie
public var font: ?Font
```

**功能：** 设置弹窗信息字体属性。不支持设置family。

**类型：** ?[Font](#class-font)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?ResourceColor, ?Font)

```cangjie
public init(textColor!: ?ResourceColor = None, font!: ?Font = None)
```

**功能：** 构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|textColor|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|None|**命名参数。** 弹窗信息文本颜色。初始值为Color(0x000000)。|
|font|?[Font](#class-font)|否|None|**命名参数。** 弹窗信息字体属性。初始值为Font()。|

## class OverlayOffset

```cangjie
public class OverlayOffset {
    public var x: ?Float64
    public var y: ?Float64
    public init(x!: ?Float64 = None, y!: ?Float64 = None)
}
```

**功能：** 设置浮层的偏移量。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var x

```cangjie
public var x: ?Float64
```

**功能：** 横向偏移量。

**类型：** ?Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var y

```cangjie
public var y: ?Float64
```

**功能：** 纵向偏移量。

**类型：** ?Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Float64, ?Float64)

```cangjie
public init(x!: ?Float64 = None, y!: ?Float64 = None)
```

**功能：** 构造浮层偏移量。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|?Float64|否|None|**命名参数。** 横向偏移量。初始值为0.0。|
|y|?Float64|否|None|**命名参数。** 纵向偏移量。初始值为0.0。|

## class EdgeWidths

```cangjie
public class EdgeWidths {
    public var top: ?Length
    public var right: ?Length
    public var bottom: ?Length
    public var left: ?Length
    public init(top!: ?Length = None, right!: ?Length = None, bottom!: ?Length = None, left!: ?Length = None)
}
```

**功能：** 设置弹窗背板的边框宽度。引入该对象时，至少传入一个参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var top

```cangjie
public var top: ?Length
```

**功能：** 上侧边框宽度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var right

```cangjie
public var right: ?Length
```

**功能：** 右侧边框宽度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var bottom

```cangjie
public var bottom: ?Length
```

**功能：** 下侧边框宽度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var left

```cangjie
public var left: ?Length
```

**功能：** 左侧边框宽度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Length, ?Length, ?Length, ?Length)

```cangjie
public init(top!: ?Length = None, right!: ?Length = None, bottom!: ?Length = None, left!: ?Length = None)
```

**功能：** 构造EdgeWidths对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|top|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 上侧边框宽度。初始值为0.vp。|
|right|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 右侧边框宽度。初始值为0.vp。|
|bottom|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 下侧边框宽度。初始值为0.vp。|
|left|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 左侧边框宽度。初始值为0.vp。|

## class BindOptions

```cangjie
public open class BindOptions {
    public init(backgroundColor!: ?ResourceColor = None, onAppear!: ?() -> Unit = None, onDisappear!: ?() -> Unit = None, onWillAppear!: ?() -> Unit = None, onWillDisappear!: ?() -> Unit = None)
}
```

**功能：** 配置半模态页面的可选属性

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?ResourceColor, ?() -> Unit, ?() -> Unit, ?() -> Unit, ?() -> Unit)

```cangjie
public init(backgroundColor!: ?ResourceColor = None, onAppear!: ?() -> Unit = None, onDisappear!: ?() -> Unit = None, onWillAppear!: ?() -> Unit = None, onWillDisappear!: ?() -> Unit = None)
```

**功能：** 配置半模态页面的可选属性构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|backgroundColor|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|None|**命名参数。** 半模态页面的背板颜色。默认值：**Color.White**。|
|onAppear|?() -> Unit|否|None|**命名参数。** 半模态页面显示（动画结束后）回调函数。|
|onDisappear|?() -> Unit|否|None|**命名参数。** 半模态页面回退（动画结束后）回调函数。|
|onWillAppear|?() -> Unit|否|None|**命名参数。** 半模态页面显示（动画开始前）回调函数。|
|onWillDisappear|?() -> Unit|否|None|**命名参数。** 半模态页面回退（动画开始前）回调函数。<br>**说明：** 不允许在onWillDisappear函数中修改状态变量，可能会导致组件行为不稳定。|

## class ContentCoverOptions

```cangjie
public class ContentCoverOptions <: BindOptions {
    public init(
        modalTransition!: ?ModalTransition = Option.None,
        onWillDismiss!: ?(DismissContentCoverAction) -> Unit = Option.None,
        transition!: ?TransitionEffect = Option.None,
        backgroundColor!: ?ResourceColor = Option.None,
        onAppear!: ?() -> Unit = Option.None,
        onDisappear!: ?() -> Unit = Option.None,
        onWillAppear!: ?() -> Unit = Option.None,
        onWillDisappear!: ?() -> Unit = Option.None
    )
}
```

**功能：** 全屏模态页面转场

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- [BindOptions](#class-bindoptions)

### init(?ModalTransition, ?(DismissContentCoverAction) -> Unit, ?TransitionEffect, ?ResourceColor, ?() -> Unit, ?() -> Unit, ?() -> Unit, ?() -> Unit)

```cangjie
public init(
    modalTransition!: ?ModalTransition = Option.None,
    onWillDismiss!: ?(DismissContentCoverAction) -> Unit = Option.None,
    transition!: ?TransitionEffect = Option.None,
    backgroundColor!: ?ResourceColor = Option.None,
    onAppear!: ?() -> Unit = Option.None,
    onDisappear!: ?() -> Unit = Option.None,
    onWillAppear!: ?() -> Unit = Option.None,
    onWillDisappear!: ?() -> Unit = Option.None
)
```

**功能：** 构造一个ContentCoverOptions类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|modalTransition|?[ModalTransition](./cj-common-types.md#enum-modaltransition)|否|Option.None|**命名参数。** 全屏模态页面的转场方式。|
|onWillDismiss|?([DismissContentCoverAction](#class-dismisscontentcoveraction))-> Unit|否|Option.None|**命名参数。** 内容覆盖交互式关闭时的回调函数。|
|transition|?[TransitionEffect](./cj-animation-transition.md#class-transitioneffect)|否|Option.None|**命名参数。** 全屏模态页面交互式关闭回调函数。|
|backgroundColor|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|Option.None|**命名参数。** sheet的背景色。默认值：**Color.White**。|
|onAppear|?() -> Unit|否|Option.None|**命名参数。** 全模态页面显示（动画结束后）回调函数。|
|onDisappear|?() -> Unit|否|Option.None|**命名参数。** 全模态页面回退（动画结束后）回调函数。|
|onWillAppear|?() -> Unit|否|Option.None|**命名参数。** 全模态页面显示（动画开始前）回调函数。|
|onWillDisappear|?() -> Unit|否|Option.None|**命名参数。** 全模态页面回退（动画开始前）回调函数。|

## class SheetDismiss

```cangjie
public class SheetDismiss {}
```

**功能：** 控制半模态的关闭类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func dismiss()

```cangjie
public func dismiss(): Unit
```

**功能：** 半模态面板关闭回调函数。开发者需要退出时调用，不需要退出时无需调用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## class SpringBackAction

```cangjie
public class SpringBackAction {}
```

**功能：** 控制半模态关闭前的回弹类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func springBack()

```cangjie
public func springBack(): Unit
```

**功能：** 半模态页面关闭前控制回弹函数，开发者需要半模态回弹时调用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## class Rectangle

```cangjie
public class Rectangle {
    public var x: ?Length
    public var y: ?Length
    public var width: ?Length
    public var height: ?Length
    public init(x!: ?Length = None, y!: ?Length = None, width!: ?Length = None, height!: ?Length = None)
}
```

**功能：** 定义区域位置类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var x

```cangjie
public var x: ?Length
```

**功能：** 触摸点相对于组件左上角的x轴坐标。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var y

```cangjie
public var y: ?Length
```

**功能：** 触摸点相对于组件左上角的y轴坐标。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var width

```cangjie
public var width: ?Length
```

**功能：** 触摸热区的宽度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var height

```cangjie
public var height: ?Length
```

**功能：** 触摸热区的高度。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Length, ?Length, ?Length, ?Length)

```cangjie
public init(x!: ?Length = None, y!: ?Length = None, width!: ?Length = None, height!: ?Length = None)
```

**功能：** 构造一个Rectangle类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 触摸点相对于组件左上角的x轴坐标。初始值为0.vp。|
|y|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 触摸点相对于组件左上角的y轴坐标。初始值为0.vp。|
|width|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 触摸热区的宽度。初始值为100.percent。|
|height|?[Length](./cj-common-types.md#interface-length)|否|None|**命名参数。** 触摸热区的高度。初始值为100.percent。|

## class DismissPopupAction

```cangjie
public class DismissPopupAction {
    public let reason: DismissReason
}
```

**功能：** 设置popup交互式关闭拦截开关及拦截回调函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### let reason

```cangjie
public let reason: DismissReason
```

**功能：** 关闭原因，返回本次拦截popup消失的事件原因。

**类型：** [DismissReason](#enum-dismissreason)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func dismiss()

```cangjie
public func dismiss(): Unit
```

**功能：** 半模态页面关闭回调函数。开发者需要退出页面时调用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## class ContextMenuOptions

```cangjie
public class ContextMenuOptions {
    public var offset: ?Position
    public var placement: Option<Placement>
    public var enableArrow: ?Bool
    public var arrowOffset: ?Length
    public var preview: ?CustomBuilder
    public var previewAnimationOptions: ?ContextMenuAnimationOptions
    public var onAppear: ?() -> Unit
    public var onDisappear: ?() -> Unit
    public var aboutToAppear: ?() -> Unit
    public var aboutToDisappear: ?() -> Unit
    public var backgroundColor: ?ResourceColor
    public var backgroundBlurStyle: ?BlurStyle
    public var transition: ?TransitionEffect
    public init(
        offset!: ?Position = None,
        placement!: Option<Placement> = Option.None,
        enableArrow!: ?Bool = None,
        arrowOffset!: ?Length = None,
        preview!: Option<() -> Unit> = Option.None,
        previewAnimationOptions!: ?ContextMenuAnimationOptions = None,
        onAppear!: ?() -> Unit = None,
        onDisappear!: ?() -> Unit = None,
        aboutToAppear!: ?() -> Unit = None,
        aboutToDisappear!: ?() -> Unit = None,
        backgroundColor!: ?ResourceColor = None,
        backgroundBlurStyle!: ?BlurStyle = Option.None,
        transition!: ?TransitionEffect = None,
        borderRadius!: ?BorderRadiuses = None,
        layoutRegionMargin!: ?Margin = None
    )
}
```

**功能：** 配置弹出菜单的参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var offset

```cangjie
public var offset: ?Position
```

**功能：** 菜单弹出位置的偏移量，不会导致菜单显示超出屏幕范围。

**类型：** ?[Position](#class-position)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var placement

```cangjie
public var placement: Option<Placement>
```

**功能：** 菜单组件优先显示的位置，当前位置显示不下时，会自动调整位置。

**类型：** Option<[Placement](#enum-placement)>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var enableArrow

```cangjie
public var enableArrow: ?Bool
```

**功能：** 是否显示箭头。如果菜单的大小和位置不足以放置箭头时，不会显示箭头。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var arrowOffset

```cangjie
public var arrowOffset: ?Length
```

**功能：** 箭头在菜单处的偏移。偏移量必须合法且转换为具体数值时大于0才会生效，另外该值生效时不会导致箭头超出菜单四周的安全距离。

**类型：** ?[Length](./cj-common-types.md#interface-length)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var preview

```cangjie
public var preview: ?CustomBuilder
```

**功能：** 长按悬浮菜单或使用bindContextMenu显示菜单的预览内容样式，为用户自定义的内容。

**类型：** ?[CustomBuilder](#type-custombuilder)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var previewAnimationOptions

```cangjie
public var previewAnimationOptions: ?ContextMenuAnimationOptions
```

**功能：** 控制长按预览显示动画开始倍率和结束倍率（相对预览原图比例）。

**类型：** ?[ContextMenuAnimationOptions](#class-contextmenuanimationoptions)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var onAppear

```cangjie
public var onAppear: ?() -> Unit
```

**功能：** 菜单弹出时的事件回调。

**类型：** ?() -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var onDisappear

```cangjie
public var onDisappear: ?() -> Unit
```

**功能：** 菜单消失时的事件回调。

**类型：** ?() -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var aboutToAppear

```cangjie
public var aboutToAppear: ?() -> Unit
```

**功能：** 菜单显示动效前的事件回调。

**类型：** ?() -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var aboutToDisappear

```cangjie
public var aboutToDisappear: ?() -> Unit
```

**功能：** 菜单退出动效前的事件回调。

**类型：** ?() -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var backgroundColor

```cangjie
public var backgroundColor: ?ResourceColor
```

**功能：** 弹窗背板颜色。

**类型：** ?[ResourceColor](./cj-common-types.md#interface-resourcecolor)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var backgroundBlurStyle

```cangjie
public var backgroundBlurStyle: ?BlurStyle
```

**功能：** 弹窗背板模糊材质。

**类型：** ?[BlurStyle](#enum-blurstyle)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var transition

```cangjie
public var transition: ?TransitionEffect
```

**功能：** 设置菜单显示和退出的过渡效果。

**类型：** ?[TransitionEffect](./cj-animation-transition.md#class-transitioneffect)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Position, Option\<Placement>, ?Bool, ?Length, Option\<() -> Unit>, ?ContextMenuAnimationOptions, ?() -> Unit, ?() -> Unit, ?() -> Unit, ?() -> Unit, ?ResourceColor, ?BlurStyle, ?TransitionEffect, ?BorderRadiuses, ?Margin)

```cangjie
public init(
    offset!: ?Position = None,
    placement!: Option<Placement> = Option.None,
    enableArrow!: ?Bool = None,
    arrowOffset!: ?Length = None,
    preview!: Option<() -> Unit> = Option.None,
    previewAnimationOptions!: ?ContextMenuAnimationOptions = None,
    onAppear!: ?() -> Unit = None,
    onDisappear!: ?() -> Unit = None,
    aboutToAppear!: ?() -> Unit = None,
    aboutToDisappear!: ?() -> Unit = None,
    backgroundColor!: ?ResourceColor = None,
    backgroundBlurStyle!: ?BlurStyle = Option.None,
    transition!: ?TransitionEffect = None,
    borderRadius!: ?BorderRadiuses = None,
    layoutRegionMargin!: ?Margin = None
)
```

**功能：** 创建ContextMenuOptions对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|offset|?[Position](#class-position)|否|None|**命名参数。** 菜单弹出位置的偏移量，不会导致菜单显示超出屏幕范围。<br> **说明：**<br> 菜单类型为相对⽗组件区域弹出时，⾃动根据菜单位置属性 (placement)将区域的宽或⾼计⼊偏移量中。<br> 当菜单相对父组件出现在上侧时（placement设置为Placement.TopLeft，Placement.Top，Placement.TopRight），x为正值，菜单相对组件向右进行偏移，y为正值，菜单相对组件向上进行偏移。<br> 当菜单相对父组件出现在下侧时（placement设置为Placement.BottomLeft，Placement.Bottom，Placement.BottomRight），x为正值，菜单相对组件向右进行偏移，y为正值，菜单相对组件向下进行偏移。<br> 当菜单相对父组件出现在左侧时（placement设置为Placement.LeftTop，Placement.Left，Placement.LeftBottom），x为正值，菜单相对组件向左进行偏移，y为正值，菜单相对组件向下进行偏移。<br> 当菜单相对父组件出现在右侧时（placement设置为Placement.RightTop，Placement.Right，Placement.RightBottom），x为正值，菜单相对组件向右进行偏移，y为正值，菜单相对组件向下进行偏移。<br> 如果菜单调整了显示位置（与placement初始值主方向不⼀致），则偏移值 (offset) 失效。|
|placement|Option\<[Placement](#enum-placement)>|否|Option.None|**命名参数。** 菜单组件优先显示的位置，当前位置显示不下时，会自动调整位置。<br> **说明：**<br> placement值设置为undefined、null或没有设置此选项时，按未设置placement处理，当使用bindMenu，按初始值：Placement.BottomLeft设置。|
|enableArrow|?Bool|否|None| **命名参数。** 是否显示箭头。如果菜单的大小和位置不足以放置箭头时，不会显示箭头。<br> **说明：** <br> enableArrow为true时，placement未设置或者值为非法值，默认在目标物上方显示，否则按照placement的位置优先显示。当前位置显示不下时，会自动调整位置，enableArrow为undefined时，不显示箭头。|
|arrowOffset|?[Length](./cj-common-types.md#interface-length)|否|None| **命名参数。** 箭头在菜单处的偏移。偏移量必须合法且转换为具体数值时大于0才会生效，另外该值生效时不会导致箭头超出菜单四周的安全距离。<br> 单位：vp<br> **说明：**<br> 箭头距菜单四周的安全距离为菜单圆角大小与箭头宽度的一半之和。<br> 根据配置的placement来计算是在水平还是垂直方向上偏移。<br> 箭头在菜单水平方向时，偏移量为箭头至最左侧箭头安全距离处的距离。箭头在菜单垂直方向时，偏移量为箭头至最上侧箭头安全距离处的距离。<br> 根据配置的placement的不同，箭头展示的默认位置不同：<br> 在菜单不发生避让的情况下，placement设置为Placement.Top、Placement.Bottom时，箭头显示在水平方向且默认居中；<br> placement设置为Placement.Left、Placement.Right时，箭头显示在垂直方向且默认居中；<br> placement设置为Placement.TopLeft、Placement.BottomLeft时，箭头默认显示在水平方向，且距离菜单左侧边缘距离为箭头安全距离；<br> placement设置为Placement.TopRight、Placement.BottomRight时，箭头默认显示在水平方向，且距离菜单右侧距离为箭头安全距离；<br> placement设置为Placement.LeftTop、Placement.RightTop时，箭头默认显示在垂直方向，且距离菜单上侧距离为箭头安全距离；<br> placement设置为Placement.LeftBottom、Placement.RightBottom时，箭头默认显示在垂直方向，且距离菜单下侧距离为箭头安全距离。|
|preview|Option\<() -> Unit>|否|Option.None| **命名参数。** 长按悬浮菜单或使用bindContextMenu显示菜单的预览内容样式，为用户自定义的内容。<br> **说明：** <br> - 仅支持接收@Builder修饰的自定义构建函数。<br> - 不支持responseType为ResponseType.RightClick时触发，如果responseType为ResponseType.RightClick，则不会显示预览内容。<br> - 当未设置preview参数时，enableArrow参数生效。<br> - 当preview参数设置为CustomBuilder时，enableArrow为true时也不显示箭头。|
|previewAnimationOptions|?[ContextMenuAnimationOptions](#class-contextmenuanimationoptions)|否|None|**命名参数。** 控制长按预览显示动画开始倍率和结束倍率（相对预览原图比例）。|
|onAppear|?() -> Unit|否|None| **命名参数。** 菜单弹出时的事件回调。|
|onDisappear|?() -> Unit|否|None| **命名参数。** 菜单消失时的事件回调。|
|aboutToAppear|?() -> Unit|否|None| **命名参数。** 菜单显示动效前的事件回调。|
|aboutToDisappear|?() -> Unit|否|None| **命名参数。** 菜单退出动效前的事件回调。|
|backgroundColor|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|否|None|**命名参数。** 弹窗背板颜色。初始值为Color.Transparent。|
|backgroundBlurStyle|?[BlurStyle](#enum-blurstyle)|否|Option.None| **命名参数。** 弹窗背板模糊材质。|
|transition|?[TransitionEffect](./cj-animation-transition.md#class-transitioneffect)|否|None| **命名参数。** 菜单显示和退出的过渡效果。<br> **说明：**<br> 菜单退出动效过程中，进行横竖屏切换，菜单会避让。二级菜单不继承自定义动效。弹出过程可以点击二级菜单，退出动效执行过程不允许点击二级菜单。<br> 详细描述见TransitionEffect对象说明。|
|borderRadius|?[BorderRadiuses](#class-borderradiuses)|否|None| **命名参数。** 设置菜单显示区域的圆角。|
|layoutRegionMargin|?[Margin](#class-margin)|否|None| **命名参数。** 设置菜单的布局区域的边距。|

## class DismissContentCoverAction

```cangjie
public class DismissContentCoverAction {
    public let reason: DismissReason
}
```

**功能：** 用于处理全屏模态页面关闭逻辑的核心回调类，负责在用户触发关闭操作时，通过回调机制拦截关闭行为。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### let reason

```cangjie
public let reason: DismissReason
```

**功能：** 关闭原因类型。

**类型：** [DismissReason](#enum-dismissreason)

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func dismiss()

```cangjie
public func dismiss(): Unit
```

**功能：** 显式触发模态页面关闭操作，是唯一控制关闭的入口。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## class ContextMenuAnimationOptions

```cangjie
public class ContextMenuAnimationOptions {
    public var scale: ?VArray<Float64, $2>
    public var transition: ?TransitionEffect
    public var hoverScale: ?VArray<Float64, $2>
    public init(scale!: ?VArray<Float64, $2> = None, transition!: ?TransitionEffect = None, hoverScale!: ?VArray<Float64, $2> = None)
}
```

**功能：** 控制长按预览显示动画开始倍率和结束倍率（相对预览原图比例）参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var scale

```cangjie
public var scale: ?VArray<Float64, $2>
```

**功能：** 动画开始和结束时相对预览原图缩放比例。

**类型：** ?VArray<Float64, $2>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var transition

```cangjie
public var transition: ?TransitionEffect
```

**功能：** 设置菜单显示和退出的过渡效果。

**类型：** ?[TransitionEffect](./cj-animation-transition.md#class-transitioneffect)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var hoverScale

```cangjie
public var hoverScale: ?VArray<Float64, $2>
```

**功能：** 设置预览自定义长按场景下，浮起原组件截图的缩放动画开始和结束时相对预览原图缩放比例，且有与预览图的切换的过渡动效。

**类型：** ?VArray<Float64, $2>

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?VArray\<Float64, \$2>, ?TransitionEffect, ?VArray\<Float64, \$2>)

```cangjie
public init(scale!: ?VArray<Float64, $2> = None, transition!: ?TransitionEffect = None, hoverScale!: ?VArray<Float64, $2> = None)
```

**功能：** 构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|scale|?VArray<Float64, $2>|否|None| **命名参数。** 动画开始和结束时相对预览原图缩放比例。<br> **说明：** 缩放比例需要根据实际开发场景设置，建议设置值为小于预览图宽度或布局的最大限制。|
|transition|?[TransitionEffect](./cj-animation-transition.md#class-transitioneffect)|否|None| **命名参数。** 菜单显示和退出的过渡效果。<br> **说明：** 菜单退出动效过程中，进行横竖屏切换，菜单会避让。二级菜单不继承自定义动效。弹出过程可以点击二级菜单，退出动效执行过程不允许点击二级菜单。详细描述见TransitionEffect对象说明。|
|hoverScale|?VArray<Float64, $2>|否|None| **命名参数。** 预览自定义长按场景下，浮起原组件截图的缩放动画开始和结束时相对预览原图缩放比例，且有与预览图的切换的过渡动效。<br> **说明：** 倍率设置参数小于等于0时，不生效。<br> 设置transition接口时，不生效。<br>使用此接口且同时使用scale接口时，scale接口起始值不生效。<br> 为保障最佳体验，最终预览图尺寸不建议小于原组件截图尺寸。当前预览动效宽高会受组件截图和自定义预览大小影响，请根据实际使用情况自行保障展示效果。|

## class DismissSheetAction

```cangjie
public class DismissSheetAction {
    public var reason: DismissReason
}
```

**功能：** 半模态页面关闭回调函数类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var reason

```cangjie
public var reason: DismissReason
```

**功能：** 半模态页面关闭原因。

**类型：** [DismissReason](#enum-dismissreason)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### func dismiss()

```cangjie
public func dismiss(): Unit
```

**功能：** 半模态页面关闭回调函数。开发者需要退出页面时调用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## enum LengthUnit

```cangjie
public enum LengthUnit <: Equatable<LengthUnit> {
    | Px
    | Vp
    | Fp
    | Percent
    | Lpx
    | ...
}
```

**功能：** 长度单位。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：** Equatable\<[LengthUnit](#enum-lengthunit)>

### Px

```cangjie
Px
```

**功能：** 基本像素单位。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Vp

```cangjie
Vp
```

**功能：** 屏幕密度单位。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Fp

```cangjie
Fp
```

**功能：** 字体像素单位。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Percent

```cangjie
Percent
```

**功能：** 百分比。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Lpx

```cangjie
Lpx
```

**功能：** 逻辑像素单位。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func !=(LengthUnit)

```cangjie
public operator func !=(other: LengthUnit): Bool
```

**功能：** 不等比较运算符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[LengthUnit](#enum-lengthunit)|是|-|要比较的另一个LengthUnit枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，不相等时返回true。|

### operator func ==(LengthUnit)

```cangjie
public operator func ==(other: LengthUnit): Bool
```

**功能：** 相等比较运算符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[LengthUnit](#enum-lengthunit)|是|-|要比较的另一个LengthUnit枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|比较结果，相等时返回true。|

### func getValue()

```cangjie
public func getValue(): Int32
```

**功能：** 获取LengthUnit的值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Int32|LengthUnit的值。|

### static func parse(Int32)

```cangjie
public static func parse(value: Int32): LengthUnit
```

**功能：** 解析Int32值为LengthUnit。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|Int32|是|-|要解析的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[LengthUnit](#enum-lengthunit)|解析后的LengthUnit。|

## enum ModalTransition

```cangjie
public enum ModalTransition <: Equatable<ModalTransition> {
    | Default
    | None
    | Alpha
    | ...
}
```

**功能：** 全屏模态切换动画。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ModalTransition](#enum-modaltransition)>

### Default

```cangjie
Default
```

**功能：** 全屏模态上下切换动画。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### None

```cangjie
None
```

**功能：** 全屏模态无转场动画。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Alpha

```cangjie
Alpha
```

**功能：** 全屏模态透明度渐变动画。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ModalTransition)

```cangjie
public operator func ==(other: ModalTransition): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ModalTransition](#enum-modaltransition)|是|-|要比较的另一个ModalTransition枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ModalTransition)

```cangjie
public operator func !=(other: ModalTransition): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ModalTransition](#enum-modaltransition)|是|-|要比较的另一个ModalTransition枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SheetSize

```cangjie
public enum SheetSize <: Equatable<SheetSize> {
    | Medium
    | Large
    | FitContent
    | ...
}
```

**功能：** 设置半模态页面的切换高度档位。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SheetSize](#enum-sheetsize)>

### Medium

```cangjie
Medium
```

**功能：** 指定半模态高度为屏幕高度一半。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Large

```cangjie
Large
```

**功能：** 指定半模态高度几乎为屏幕高度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### FitContent

```cangjie
FitContent
```

**功能：** 指定半模态高度为适应内容的高度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SheetSize)

```cangjie
public operator func ==(other: SheetSize): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SheetSize](#enum-sheetsize)|是|-|要比较的另一个SheetSize枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SheetSize)

```cangjie
public operator func !=(other: SheetSize): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SheetSize](#enum-sheetsize)|是|-|要比较的另一个SheetSize枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SheetType

```cangjie
public enum SheetType <: Equatable<SheetType> {
    | Bottom
    | Center
    | Popup
    | ...
}
```

**功能：** 设置半模态弹窗的样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SheetType](#enum-sheettype)>

### Bottom

```cangjie
Bottom
```

**功能：** 底部弹窗。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Center

```cangjie
Center
```

**功能：** 居中弹窗。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Popup

```cangjie
Popup
```

**功能：** 跟手弹窗。跟手弹窗面板不支持跟手滑动，下滑面板不关闭。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SheetType)

```cangjie
public operator func ==(other: SheetType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SheetType](#enum-sheettype)|是|-|要比较的另一个SheetType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SheetType)

```cangjie
public operator func !=(other: SheetType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SheetType](#enum-sheettype)|是|-|要比较的另一个SheetType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SheetMode

```cangjie
public enum SheetMode <: Equatable<SheetMode> {
    | Overlay
    | Embedded
    | ...
}
```

**功能：** 设置半模态页面的显示层级。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SheetMode](#enum-sheetmode)>

### Overlay

```cangjie
Overlay
```

**功能：** 设置半模态面板在当前UIContext内顶层显示，在所有页面之上。和弹窗类组件显示在一个层级。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Embedded

```cangjie
Embedded
```

**功能：** 设置半模态面板在当前页面内的顶层显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SheetMode)

```cangjie
public operator func ==(other: SheetMode): Bool
```

**功能：** 判断两个SheetMode枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SheetMode](#enum-sheetmode)|是|-|要比较的另一个SheetMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SheetMode)

```cangjie
public operator func !=(other: SheetMode): Bool
```

**功能：** 判断两个SheetMode枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SheetMode](#enum-sheetmode)|是|-|要比较的另一个SheetMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ScrollSizeMode

```cangjie
public enum ScrollSizeMode <: Equatable<ScrollSizeMode> {
    | FollowDetent
    | Continuous
    | ...
}
```

**功能：** 设置半模态面板滑动时，内容区域刷新时机。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ScrollSizeMode](#enum-scrollsizemode)>

### FollowDetent

```cangjie
FollowDetent
```

**功能：** 设置半模态面板跟手滑动结束后更新内容显示区域。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Continuous

```cangjie
Continuous
```

**功能：** 设置半模态面板在滑动过程中持续更新内容显示区域。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ScrollSizeMode)

```cangjie
public operator func ==(other: ScrollSizeMode): Bool
```

**功能：** 判断两个ScrollSizeMode枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScrollSizeMode](./cj-common-types.md#enum-scrollsizemode)|是|-|要比较的另一个ScrollSizeMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ScrollSizeMode)

```cangjie
public operator func !=(other: ScrollSizeMode): Bool
```

**功能：** 判断两个ScrollSizeMode枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScrollSizeMode](./cj-common-types.md#enum-scrollsizemode)|是|-|要比较的另一个ScrollSizeMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum KeySource

```cangjie
public enum KeySource <: Equatable<KeySource> {
    | Unknown
    | Keyboard
    | ...
}
```

**功能：** 按键来源。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[KeySource](#enum-keysource)>

### Unknown

```cangjie
Unknown
```

**功能：** 输入设备类型未知。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Keyboard

```cangjie
Keyboard
```

**功能：** 键盘按键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(KeySource)

```cangjie
public operator func ==(other: KeySource): Bool
```

**功能：** 判断两个KeySource枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[KeySource](#enum-keysource)|是|-|要比较的另一个KeySource枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(KeySource)

```cangjie
public operator func !=(other: KeySource): Bool
```

**功能：** 判断两个KeySource枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[KeySource](#enum-keysource)|是|-|要比较的另一个KeySource枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum KeyType

```cangjie
public enum KeyType <: Equatable<KeyType> {
    | Unknown
    | Down
    | Up
    | ...
}
```

**功能：** 按键的类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<KeyType>

### Unknown

```cangjie
Unknown
```

**功能：** 未知类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Down

```cangjie
Down
```

**功能：** 按键按下。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Up

```cangjie
Up
```

**功能：** 按键释放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(KeyType)

```cangjie
public operator func ==(other: KeyType): Bool
```

**功能：** 判断两个KeyType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[KeyType](#enum-keytype)|是|-|要比较的另一个KeyType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(KeyType)

```cangjie
public operator func !=(other: KeyType): Bool
```

**功能：** 判断两个KeyType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[KeyType](#enum-keytype)|是|-|要比较的另一个KeyType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ModifierKey

```cangjie
public enum ModifierKey <: Equatable<ModifierKey> {
    | Ctrl
    | Shift
    | Alt
    | ...
}
```

**功能：** 输入法修饰键类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ModifierKey](#enum-modifierkey)>

### Ctrl

```cangjie
Ctrl
```

**功能：** 表示键盘上Ctrl键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Shift

```cangjie
Shift
```

**功能：** 表示键盘上Shift键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Alt

```cangjie
Alt
```

**功能：** 表示键盘上Alt键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ModifierKey)

```cangjie
public operator func ==(other: ModifierKey): Bool
```

**功能：** 判断两个ModifierKey枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ModifierKey](#enum-modifierkey)|是|-|要比较的另一个ModifierKey枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ModifierKey)

```cangjie
public operator func !=(other: ModifierKey): Bool
```

**功能：** 判断两个ModifierKey枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ModifierKey](#enum-modifierkey)|是|-|要比较的另一个ModifierKey枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum FunctionKey

```cangjie
public enum FunctionKey <: Equatable<FunctionKey> {
    | Esc
    | F1
    | F2
    | F3
    | F4
    | F5
    | F6
    | F7
    | F8
    | F9
    | F10
    | F11
    | F12
    | Tab
    | ...
}
```

**功能：** 键盘功能键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[FunctionKey](#enum-functionkey)>

### Esc

```cangjie
Esc
```

**功能：** Escape键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### F1

```cangjie
F1
```

**功能：** F1键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### F2

```cangjie
F2
```

**功能：** F2键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### F3

```cangjie
F3
```

**功能：** F3键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### F4

```cangjie
F4
```

**功能：** F4键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### F5

```cangjie
F5
```

**功能：** F5键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### F6

```cangjie
F6
```

**功能：** F6键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### F7

```cangjie
F7
```

**功能：** F7键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### F8

```cangjie
F8
```

**功能：** F8键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### F9

```cangjie
F9
```

**功能：** F9键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### F10

```cangjie
F10
```

**功能：** F10键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### F11

```cangjie
F11
```

**功能：** F11键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### F12

```cangjie
F12
```

**功能：** F12键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Tab

```cangjie
Tab
```

**功能：** Tab键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(FunctionKey)

```cangjie
public operator func ==(other: FunctionKey): Bool
```

**功能：** 判断两个FunctionKey枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FunctionKey](#enum-functionkey)|是|-|要比较的另一个FunctionKey枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(FunctionKey)

```cangjie
public operator func !=(other: FunctionKey): Bool
```

**功能：** 判断两个FunctionKey枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FunctionKey](#enum-functionkey)|是|-|要比较的另一个FunctionKey枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum DataPanelType

```cangjie
public enum DataPanelType <: Equatable<DataPanelType> {
    | Circle
    | Line
    | ...
}
```

**功能：** 数据面板类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[DataPanelType](#enum-datapaneltype)>

### Circle

```cangjie
Circle
```

**功能：** 环形数据面板。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Line

```cangjie
Line
```

**功能：** 线型数据面板。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(DataPanelType)

```cangjie
public operator func ==(other: DataPanelType): Bool
```

**功能：** 判断两个DataPanelType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DataPanelType](#enum-datapaneltype)|是|-|要比较的另一个DataPanelType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(DataPanelType)

```cangjie
public operator func !=(other: DataPanelType): Bool
```

**功能：** 判断两个DataPanelType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DataPanelType](#enum-datapaneltype)|是|-|要比较的另一个DataPanelType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ItemState

```cangjie
public enum ItemState <: Equatable<ItemState> {
    | Normal
    | Disabled
    | Waiting
    | Skip
    | ...
}
```

**功能：** 项目状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ItemState](#enum-itemstate)>

### Normal

```cangjie
Normal
```

**功能：** 正常状态，右侧文本按钮正常显示，可点击进入下一个StepperItem。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Disabled

```cangjie
Disabled
```

**功能：** 不可用状态，右侧文本按钮灰度显示，不可点击进入下一个StepperItem。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Waiting

```cangjie
Waiting
```

**功能：** 等待状态，右侧文本按钮不显示，显示等待进度条，不可点击进入下一个StepperItem。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Skip

```cangjie
Skip
```

**功能：** 跳过状态，右侧文本按钮默认显示"跳过"，此时可在Stepper的onSkip回调中自定义相关逻辑。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ItemState)

```cangjie
public operator func ==(other: ItemState): Bool
```

**功能：** 判断两个ItemState枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ItemState](#enum-itemstate)|是|-|要比较的另一个ItemState枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ItemState)

```cangjie
public operator func !=(other: ItemState): Bool
```

**功能：** 判断两个ItemState枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ItemState](#enum-itemstate)|是|-|要比较的另一个ItemState枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum RefreshStatus

```cangjie
public enum RefreshStatus <: Equatable<RefreshStatus> {
    | Inactive
    | Drag
    | OverDrag
    | Refresh
    | Done
    | ...
}
```

**功能：** 下拉状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[RefreshStatus](#enum-refreshstatus)>

### Inactive

```cangjie
Inactive
```

**功能：** 下拉刷新的刷新状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Drag

```cangjie
Drag
```

**功能：** 下拉中，下拉距离小于刷新距离。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### OverDrag

```cangjie
OverDrag
```

**功能：** 下拉中，下拉距离超过刷新距离。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Refresh

```cangjie
Refresh
```

**功能：** 下拉后，弹回到刷新距离并进入刷新状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Done

```cangjie
Done
```

**功能：** 刷新结束，返回初始状态（顶部）。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(RefreshStatus)

```cangjie
public operator func ==(other: RefreshStatus): Bool
```

**功能：** 判断两个RefreshStatus枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[RefreshStatus](#enum-refreshstatus)|是|-|要比较的另一个RefreshStatus枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(RefreshStatus)

```cangjie
public operator func !=(other: RefreshStatus): Bool
```

**功能：** 判断两个RefreshStatus枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[RefreshStatus](#enum-refreshstatus)|是|-|要比较的另一个RefreshStatus枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SeekMode

```cangjie
public enum SeekMode <: Equatable<SeekMode> {
    | PreviousKeyframe
    | NextKeyframe
    | ClosestKeyframe
    | Accurate
    | ...
}
```

**功能：** 跳转模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SeekMode](#enum-seekmode)>

### PreviousKeyframe

```cangjie
PreviousKeyframe
```

**功能：** 跳转到前一个最近的关键帧。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### NextKeyframe

```cangjie
NextKeyframe
```

**功能：** 跳转到后一个最近的关键帧。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ClosestKeyframe

```cangjie
ClosestKeyframe
```

**功能：** 跳转到最近的关键帧。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Accurate

```cangjie
Accurate
```

**功能：** 精准跳转，不论是否为关键帧。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SeekMode)

```cangjie
public operator func ==(other: SeekMode): Bool
```

**功能：** 判断两个SeekMode枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SeekMode](#enum-seekmode)|是|-|要比较的另一个SeekMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SeekMode)

```cangjie
public operator func !=(other: SeekMode): Bool
```

**功能：** 判断两个SeekMode枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SeekMode](#enum-seekmode)|是|-|要比较的另一个SeekMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum PlaybackSpeed

```cangjie
public enum PlaybackSpeed <: Equatable<PlaybackSpeed> {
    | SpeedForward075X
    | SpeedForward100X
    | SpeedForward125X
    | SpeedForward175X
    | SpeedForward200X
    | ...
}
```

**功能：** 定义播放速度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[PlaybackSpeed](#enum-playbackspeed)>

### SpeedForward075X

```cangjie
SpeedForward075X
```

**功能：** 0.75倍速播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### SpeedForward100X

```cangjie
SpeedForward100X
```

**功能：** 1.00倍速播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### SpeedForward125X

```cangjie
SpeedForward125X
```

**功能：** 1.25倍速播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### SpeedForward175X

```cangjie
SpeedForward175X
```

**功能：** 1.75倍速播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### SpeedForward200X

```cangjie
SpeedForward200X
```

**功能：** 2.00倍速播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(PlaybackSpeed)

```cangjie
public operator func ==(other: PlaybackSpeed): Bool
```

**功能：** 判断两个PlaybackSpeed枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PlaybackSpeed](#enum-playbackspeed)|是|-|要比较的另一个PlaybackSpeed枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(PlaybackSpeed)

```cangjie
public operator func !=(other: PlaybackSpeed): Bool
```

**功能：** 判断两个PlaybackSpeed枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PlaybackSpeed](#enum-playbackspeed)|是|-|要比较的另一个PlaybackSpeed枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SelectStatus

```cangjie
public enum SelectStatus <: Equatable<SelectStatus> {
    | All
    | Part
    | None
    | ...
}
```

**功能：** 多选框选择状态类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SelectStatus](#enum-selectstatus)>

### All

```cangjie
All
```

**功能：** 群组多选择框全部选择。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Part

```cangjie
Part
```

**功能：** 群组多选择框部分选择。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### None

```cangjie
None
```

**功能：** 群组多选择框全部没有选择。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SelectStatus)

```cangjie
public operator func ==(other: SelectStatus): Bool
```

**功能：** 判断两个SelectStatus枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SelectStatus](#enum-selectstatus)|是|-|要比较的另一个SelectStatus枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SelectStatus)

```cangjie
public operator func !=(other: SelectStatus): Bool
```

**功能：** 判断两个SelectStatus枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SelectStatus](#enum-selectstatus)|是|-|要比较的另一个SelectStatus枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum AnimationStatus

```cangjie
public enum AnimationStatus <: Equatable<AnimationStatus> {
    | Initial
    | Running
    | Paused
    | Stopped
    | ...
}
```

**功能：** 动画播放状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[AnimationStatus](#enum-animationstatus)>

### Initial

```cangjie
Initial
```

**功能：** 动画初始状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Running

```cangjie
Running
```

**功能：** 动画正在播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Paused

```cangjie
Paused
```

**功能：** 动画已暂停。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Stopped

```cangjie
Stopped
```

**功能：** 动画已停止。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(AnimationStatus)

```cangjie
public operator func ==(other: AnimationStatus): Bool
```

**功能：** 判断两个AnimationStatus枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AnimationStatus](#enum-animationstatus)|是|-|要比较的另一个AnimationStatus枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(AnimationStatus)

```cangjie
public operator func !=(other: AnimationStatus): Bool
```

**功能：** 判断两个AnimationStatus枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AnimationStatus](#enum-animationstatus)|是|-|要比较的另一个AnimationStatus枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum FillMode

```cangjie
public enum FillMode <: Equatable<FillMode> {
    | None
    | Forwards
    | Backwards
    | Both
    | ...
}
```

**功能：** 当前播放方向下，动画开始前和结束后的状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[FillMode](#enum-fillmode)>

### None

```cangjie
None
```

**功能：** 动画未执行时不会将任何样式应用于目标，动画播放完成之后恢复初始默认状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Forwards

```cangjie
Forwards
```

**功能：** 目标将保留动画执行期间最后一个关键帧的状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Backwards

```cangjie
Backwards
```

**功能：** 动画将在应用于目标时立即应用第一个关键帧中定义的值，并在delay期间保留此值。第一个关键帧取决于playMode，playMode为Normal或Alternate时为from的状态，playMode为Reverse或AlternateReverse时为to的状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Both

```cangjie
Both
```

**功能：** 动画将遵循Forwards和Backwards的规则，从而在两个方向上扩展动画属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(FillMode)

```cangjie
public operator func ==(other: FillMode): Bool
```

**功能：** 判断两个FillMode枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FillMode](#enum-fillmode)|是|-|要比较的另一个FillMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(FillMode)

```cangjie
public operator func !=(other: FillMode): Bool
```

**功能：** 判断两个FillMode枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FillMode](#enum-fillmode)|是|-|要比较的另一个FillMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SwipeEdgeEffect

```cangjie
public enum SwipeEdgeEffect <: Equatable<SwipeEdgeEffect> {
    | Spring
    | None
    | ...
}
```

**功能：** 滑动效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SwipeEdgeEffect](#enum-swipeedgeeffect)>

### Spring

```cangjie
Spring
```

**功能：** ListItem划动距离超过划出组件大小后可以继续划动，松手后按照弹簧阻尼曲线回弹。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### None

```cangjie
None
```

**功能：** ListItem划动距离不能超过划出组件大小。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SwipeEdgeEffect)

```cangjie
public operator func ==(other: SwipeEdgeEffect): Bool
```

**功能：** 判断两个SwipeEdgeEffect枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SwipeEdgeEffect](#enum-swipeedgeeffect)|是|-|要比较的另一个SwipeEdgeEffect枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SwipeEdgeEffect)

```cangjie
public operator func !=(other: SwipeEdgeEffect): Bool
```

**功能：** 判断两个SwipeEdgeEffect枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SwipeEdgeEffect](#enum-swipeedgeeffect)|是|-|要比较的另一个SwipeEdgeEffect枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SharedTransitionEffectType

```cangjie
public enum SharedTransitionEffectType <: Equatable<SharedTransitionEffectType> {
    | Static
    | Exchange
    | ...
}
```

**功能：** 共享元素转场动效类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SharedTransitionEffectType](#enum-sharedtransitioneffecttype)>

### Static

```cangjie
Static
```

**功能：** 目标页面元素的位置保持不变，可以配置透明度动画。目前，只有为重定向到目标页面而配置的静态效果才会生效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Exchange

```cangjie
Exchange
```

**功能：** 将源页面元素移动到目标页面元素位置并适当缩放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SharedTransitionEffectType)

```cangjie
public operator func ==(other: SharedTransitionEffectType): Bool
```

**功能：** 判断两个SharedTransitionEffectType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SharedTransitionEffectType](#enum-sharedtransitioneffecttype)|是|-|要比较的另一个SharedTransitionEffectType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SharedTransitionEffectType)

```cangjie
public operator func !=(other: SharedTransitionEffectType): Bool
```

**功能：** 判断两个SharedTransitionEffectType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SharedTransitionEffectType](#enum-sharedtransitioneffecttype)|是|-|要比较的另一个SharedTransitionEffectType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ScrollState

```cangjie
public enum ScrollState <: Equatable<ScrollState> {
    | Idle
    | Scroll
    | Fling
    | ...
}
```

**功能：** 设置当前滑动状态

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ScrollState](#enum-scrollstate)>

### Idle

```cangjie
Idle
```

**功能：** 未滑动状态

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Scroll

```cangjie
Scroll
```

**功能：** 手指拖动状态

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Fling

```cangjie
Fling
```

**功能：** 拖拽结束之后的惯性滑动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ScrollState)

```cangjie
public operator func ==(other: ScrollState): Bool
```

**功能：** 判断两个ScrollState枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScrollState](#enum-scrollstate)|是|-|要比较的另一个ScrollState枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ScrollState)

```cangjie
public operator func !=(other: ScrollState): Bool
```

**功能：** 判断两个ScrollState枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScrollState](#enum-scrollstate)|是|-|要比较的另一个ScrollState枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ImageSmoothingQuality

```cangjie
public enum ImageSmoothingQuality <: Equatable<ImageSmoothingQuality> {
    | Low
    | Medium
    | High
    | ...
}
```

**功能：** 设置图像平滑度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ImageSmoothingQuality](#enum-imagesmoothingquality)>

### Low

```cangjie
Low
```

**功能：** 低画质。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Medium

```cangjie
Medium
```

**功能：** 中画质。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### High

```cangjie
High
```

**功能：** 高画质。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ImageSmoothingQuality)

```cangjie
public operator func ==(other: ImageSmoothingQuality): Bool
```

**功能：** 判断两个ImageSmoothingQuality枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageSmoothingQuality](#enum-imagesmoothingquality)|是|-|要比较的另一个ImageSmoothingQuality枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ImageSmoothingQuality)

```cangjie
public operator func !=(other: ImageSmoothingQuality): Bool
```

**功能：** 判断两个ImageSmoothingQuality枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageSmoothingQuality](#enum-imagesmoothingquality)|是|-|要比较的另一个ImageSmoothingQuality枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum GestureMask

```cangjie
public enum GestureMask <: Equatable<GestureMask> {
    | Normal
    | IgnoreInternal
    | ...
}
```

**功能：** 手势掩码。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[GestureMask](#enum-gesturemask)>

### Normal

```cangjie
Normal
```

**功能：** 不屏蔽子组件的手势，按照默认手势识别顺序进行识别。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### IgnoreInternal

```cangjie
IgnoreInternal
```

**功能：** 屏蔽子组件的手势，包括子组件上系统内置的手势，如子组件为List组件时，内置的滑动手势同样会被屏蔽。若父子组件区域存在部分重叠，则只会屏蔽父子组件重叠的部分。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(GestureMask)

```cangjie
public operator func ==(other: GestureMask): Bool
```

**功能：** 判断两个GestureMask枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[GestureMask](#enum-gesturemask)|是|-|要比较的另一个GestureMask枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(GestureMask)

```cangjie
public operator func !=(other: GestureMask): Bool
```

**功能：** 判断两个GestureMask枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[GestureMask](#enum-gesturemask)|是|-|要比较的另一个GestureMask枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SwipeDirection

```cangjie
public enum SwipeDirection <: Equatable<SwipeDirection> {
    | Horizontal
    | Vertical
    | All
    | ...
}
```

**功能：** 触发滑动手势的滑动方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SwipeDirection](#enum-swipedirection)>

### Horizontal

```cangjie
Horizontal
```

**功能：** 水平方向，手指滑动方向与x轴夹角小于45度时触发。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Vertical

```cangjie
Vertical
```

**功能：** 竖直方向，手指滑动方向与y轴夹角小于45度时触发。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### All

```cangjie
All
```

**功能：** 所有方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SwipeDirection)

```cangjie
public operator func ==(other: SwipeDirection): Bool
```

**功能：** 判断两个SwipeDirection枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SwipeDirection](#enum-swipedirection)|是|-|要比较的另一个SwipeDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SwipeDirection)

```cangjie
public operator func !=(other: SwipeDirection): Bool
```

**功能：** 判断两个SwipeDirection枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SwipeDirection](#enum-swipedirection)|是|-|要比较的另一个SwipeDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum PanDirection

```cangjie
public enum PanDirection <: Equatable<PanDirection> {
    | None
    | Left
    | Right
    | Horizontal
    | Up
    | Down
    | Vertical
    | All
    | Computed(UInt32)
    | ...
}
```

**功能：** 拖动手势方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[PanDirection](#enum-pandirection)>

### None

```cangjie
None
```

**功能：** 所有方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Left

```cangjie
Left
```

**功能：** 向左拖动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Right

```cangjie
Right
```

**功能：** 向右拖动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Horizontal

```cangjie
Horizontal
```

**功能：** 水平方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Up

```cangjie
Up
```

**功能：** 向上拖动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Down

```cangjie
Down
```

**功能：** 向下拖动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Vertical

```cangjie
Vertical
```

**功能：** 竖直方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### All

```cangjie
All
```

**功能：** 所有方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Computed(UInt32)

```cangjie
Computed(UInt32)
```

**功能：** 支持逻辑与(&)和逻辑或(|)运算。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(PanDirection)

```cangjie
public operator func ==(other: PanDirection): Bool
```

**功能：** 判断两个PanDirection枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PanDirection](#enum-pandirection)|是|-|要比较的另一个PanDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(PanDirection)

```cangjie
public operator func !=(other: PanDirection): Bool
```

**功能：** 判断两个PanDirection枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PanDirection](#enum-pandirection)|是|-|要比较的另一个PanDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

### operator func |(PanDirection)

```cangjie
public operator func |(right: PanDirection): PanDirection
```

**功能：** 对PanDirection执行逻辑或(|)运算。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|right|[PanDirection](#enum-pandirection)|是|-|要进行逻辑或运算的PanDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|[PanDirection](#enum-pandirection)|逻辑或运算的结果。|

### operator func &(PanDirection)

```cangjie
public operator func &(right: PanDirection): PanDirection
```

**功能：** 对PanDirection执行逻辑与(&)运算。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|right|[PanDirection](#enum-pandirection)|是|-|要进行逻辑与运算的PanDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|[PanDirection](#enum-pandirection)|逻辑与运算的结果。|

## enum GestureMode

```cangjie
public enum GestureMode <: Equatable<GestureMode> {
    | Sequence
    | Parallel
    | Exclusive
    | ...
}
```

**功能：** 组合手势的识别模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[GestureMode](#enum-gesturemode)>

### Sequence

```cangjie
Sequence
```

**功能：** 顺序识别，按照手势的注册顺序识别手势，直到所有手势识别成功。若有一个手势识别失败，后续手势识别均失败。顺序识别手势组仅有最后一个手势可以响应onActionEnd。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Parallel

```cangjie
Parallel
```

**功能：** 并发识别，注册的手势同时识别，直到所有手势识别结束，手势识别互相不影响。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Exclusive

```cangjie
Exclusive
```

**功能：** 互斥识别，注册的手势同时识别，若有一个手势识别成功，则结束手势识别。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(GestureMode)

```cangjie
public operator func ==(other: GestureMode): Bool
```

**功能：** 判断两个GestureMode枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[GestureMode](#enum-gesturemode)|是|-|要比较的另一个GestureMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(GestureMode)

```cangjie
public operator func !=(other: GestureMode): Bool
```

**功能：** 判断两个GestureMode枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[GestureMode](#enum-gesturemode)|是|-|要比较的另一个GestureMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum Axis

```cangjie
public enum Axis <: Equatable<Axis> {
    | Vertical
    | Horizontal
    | ...
}
```

**功能：** 轴方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[Axis](#enum-axis)>

### Vertical

```cangjie
Vertical
```

**功能：** 方向为纵向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Horizontal

```cangjie
Horizontal
```

**功能：** 方向为横向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(Axis)

```cangjie
public operator func ==(other: Axis): Bool
```

**功能：** 判断两个Axis枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Axis](#enum-axis)|是|-|要比较的另一个Axis枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(Axis)

```cangjie
public operator func !=(other: Axis): Bool
```

**功能：** 判断两个Axis枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Axis](#enum-axis)|是|-|要比较的另一个Axis枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ResponseType

```cangjie
public enum ResponseType <: Equatable<ResponseType> {
    | RightClick
    | LongPress
    | ...
}
```

**功能：** 响应类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ResponseType](#enum-responsetype)>

### RightClick

```cangjie
RightClick
```

**功能：** 通过鼠标右键触发菜单弹出。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### LongPress

```cangjie
LongPress
```

**功能：** 通过长按触发菜单弹出。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ResponseType)

```cangjie
public operator func ==(other: ResponseType): Bool
```

**功能：** 判断两个ResponseType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ResponseType](#enum-responsetype)|是|-|要比较的另一个ResponseType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ResponseType)

```cangjie
public operator func !=(other: ResponseType): Bool
```

**功能：** 判断两个ResponseType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ResponseType](#enum-responsetype)|是|-|要比较的另一个ResponseType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum CopyOptions

```cangjie
public enum CopyOptions <: Equatable<CopyOptions> {
    | None
    | InApp
    | LocalDevice
    | ...
}
```

**功能：** 输入的文本复制模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[CopyOptions](#enum-copyoptions)>

### None

```cangjie
None
```

**功能：** 不支持复制。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### InApp

```cangjie
InApp
```

**功能：** 支持应用内复制。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### LocalDevice

```cangjie
LocalDevice
```

**功能：** 支持设备内复制。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(CopyOptions)

```cangjie
public operator func ==(other: CopyOptions): Bool
```

**功能：** 判断两个CopyOptions枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CopyOptions](#enum-copyoptions)|是|-|要比较的另一个CopyOptions枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(CopyOptions)

```cangjie
public operator func !=(other: CopyOptions): Bool
```

**功能：** 判断两个CopyOptions枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CopyOptions](#enum-copyoptions)|是|-|要比较的另一个CopyOptions枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum TouchType

```cangjie
public enum TouchType <: Equatable<TouchType> {
    | Down
    | Up
    | Move
    | Cancel
    | Unknown
    | ...
}
```

**功能：** 触摸触发方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[TouchType](#enum-touchtype)>

### Down

```cangjie
Down
```

**功能：** 手指按下时触发。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Up

```cangjie
Up
```

**功能：** 手指抬起时触发。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Move

```cangjie
Move
```

**功能：** 手指按压态在屏幕上移动时触发。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Cancel

```cangjie
Cancel
```

**功能：** 触摸事件取消时触发。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Unknown

```cangjie
Unknown
```

**功能：** 未知触摸操作时触发。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(TouchType)

```cangjie
public operator func ==(other: TouchType): Bool
```

**功能：** 判断两个TouchType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TouchType](#enum-touchtype)|是|-|要比较的另一个TouchType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(TouchType)

```cangjie
public operator func !=(other: TouchType): Bool
```

**功能：** 判断两个TouchType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TouchType](#enum-touchtype)|是|-|要比较的另一个TouchType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SideBarContainerType

```cangjie
public enum SideBarContainerType <: Equatable<SideBarContainerType> {
    | Embed
    | Overlay
    | Auto
    | ...
}
```

**功能：** 容器内侧边栏样式枚举。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SideBarContainerType](#enum-sidebarcontainertype)>

### Embed

```cangjie
Embed
```

**功能：** 侧边栏嵌入到组件内，和内容区并列显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Overlay

```cangjie
Overlay
```

**功能：** 侧边栏浮在内容区上面。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Auto

```cangjie
Auto
```

**功能：** Web的深色模式为跟随系统。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SideBarContainerType)

```cangjie
public operator func ==(other: SideBarContainerType): Bool
```

**功能：** 判断两个SideBarContainerType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SideBarContainerType](#enum-sidebarcontainertype)|是|-|要比较的另一个SideBarContainerType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SideBarContainerType)

```cangjie
public operator func !=(other: SideBarContainerType): Bool
```

**功能：** 判断两个SideBarContainerType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SideBarContainerType](#enum-sidebarcontainertype)|是|-|要比较的另一个SideBarContainerType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SideBarPosition

```cangjie
public enum SideBarPosition <: Equatable<SideBarPosition> {
    | Start
    | End
    | ...
}
```

**功能：** 设置侧边栏显示位置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SideBarPosition](#enum-sidebarposition)>

### Start

```cangjie
Start
```

**功能：** 侧边栏位于容器左侧。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### End

```cangjie
End
```

**功能：** 侧边栏位于容器右侧。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SideBarPosition)

```cangjie
public operator func ==(other: SideBarPosition): Bool
```

**功能：** 判断两个SideBarPosition枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SideBarPosition](#enum-sidebarposition)|是|-|要比较的另一个SideBarPosition枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SideBarPosition)

```cangjie
public operator func !=(other: SideBarPosition): Bool
```

**功能：** 判断两个SideBarPosition枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SideBarPosition](#enum-sidebarposition)|是|-|要比较的另一个SideBarPosition枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SourceType

```cangjie
public enum SourceType <: Equatable<SourceType> {
    | Unknown
    | Mouse
    | TouchScreen
    | ...
}
```

**功能：** 事件输入设备。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SourceType](#enum-sourcetype)>

### Unknown

```cangjie
Unknown
```

**功能：** 未知设备。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Mouse

```cangjie
Mouse
```

**功能：** 鼠标输入。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### TouchScreen

```cangjie
TouchScreen
```

**功能：** 触摸屏类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SourceType)

```cangjie
public operator func ==(other: SourceType): Bool
```

**功能：** 判断两个SourceType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SourceType](#enum-sourcetype)|是|-|要比较的另一个SourceType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SourceType)

```cangjie
public operator func !=(other: SourceType): Bool
```

**功能：** 判断两个SourceType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SourceType](#enum-sourcetype)|是|-|要比较的另一个SourceType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum MouseButton

```cangjie
public enum MouseButton <: Equatable<MouseButton> {
    | None
    | Left
    | Right
    | Middle
    | Back
    | Forward
    | ...
}
```

**功能：** 鼠标按键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[MouseButton](#enum-mousebutton)>

### None

```cangjie
None
```

**功能：** 无按键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Left

```cangjie
Left
```

**功能：** 鼠标左键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Right

```cangjie
Right
```

**功能：** 鼠标右键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Middle

```cangjie
Middle
```

**功能：** 鼠标中键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Back

```cangjie
Back
```

**功能：** 鼠标后退键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Forward

```cangjie
Forward
```

**功能：** 鼠标前进键。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(MouseButton)

```cangjie
public operator func ==(other: MouseButton): Bool
```

**功能：** 判断两个MouseButton枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MouseButton](#enum-mousebutton)|是|-|要比较的另一个MouseButton枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(MouseButton)

```cangjie
public operator func !=(other: MouseButton): Bool
```

**功能：** 判断两个MouseButton枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MouseButton](#enum-mousebutton)|是|-|要比较的另一个MouseButton枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum MouseAction

```cangjie
public enum MouseAction <: Equatable<MouseAction> {
    | None
    | Press
    | Release
    | Move
    | Hover
    | ...
}
```

**功能：** 鼠标动作。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[MouseAction](#enum-mouseaction)>

### None

```cangjie
None
```

**功能：** 无操作。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Press

```cangjie
Press
```

**功能：** 鼠标按键按下。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Release

```cangjie
Release
```

**功能：** 鼠标按键松开。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Move

```cangjie
Move
```

**功能：** 鼠标移动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Hover

```cangjie
Hover
```

**功能：** 鼠标悬浮。**说明：** 该枚举值无效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(MouseAction)

```cangjie
public operator func ==(other: MouseAction): Bool
```

**功能：** 判断两个MouseAction枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MouseAction](#enum-mouseaction)|是|-|要比较的另一个MouseAction枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(MouseAction)

```cangjie
public operator func !=(other: MouseAction): Bool
```

**功能：** 判断两个MouseAction枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MouseAction](#enum-mouseaction)|是|-|要比较的另一个MouseAction枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SliderStyle

```cangjie
public enum SliderStyle <: Equatable<SliderStyle> {
    | OutSet
    | InSet
    | ...
}
```

**功能：** Slider的滑块与滑轨显示样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SliderStyle](#enum-sliderstyle)>

### OutSet

```cangjie
OutSet
```

**功能：** 滑块在滑轨内。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### InSet

```cangjie
InSet
```

**功能：** 旋钮在内样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SliderStyle)

```cangjie
public operator func ==(other: SliderStyle): Bool
```

**功能：** 判断两个SliderStyle枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SliderStyle](#enum-sliderstyle)|是|-|要比较的另一个SliderStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SliderStyle)

```cangjie
public operator func !=(other: SliderStyle): Bool
```

**功能：** 判断两个SliderStyle枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SliderStyle](#enum-sliderstyle)|是|-|要比较的另一个SliderStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ImageInterpolation

```cangjie
public enum ImageInterpolation <: Equatable<ImageInterpolation> {
    | None
    | High
    | Medium
    | Low
    | ...
}
```

**功能：** 图像插值方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ImageInterpolation](#enum-imageinterpolation)>

### None

```cangjie
None
```

**功能：** 无插值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### High

```cangjie
High
```

**功能：** 高质量插值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Medium

```cangjie
Medium
```

**功能：** 中等质量插值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Low

```cangjie
Low
```

**功能：** 低质量插值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ImageInterpolation)

```cangjie
public operator func ==(other: ImageInterpolation): Bool
```

**功能：** 判断两个ImageInterpolation枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageInterpolation](#enum-imageinterpolation)|是|-|要比较的另一个ImageInterpolation枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ImageInterpolation)

```cangjie
public operator func !=(other: ImageInterpolation): Bool
```

**功能：** 判断两个ImageInterpolation枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageInterpolation](#enum-imageinterpolation)|是|-|要比较的另一个ImageInterpolation枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum BarState

```cangjie
public enum BarState <: Equatable<BarState> {
    | Off
    | Auto
    | On
    | ...
}
```

**功能：** 滚动条的显示模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[BarState](#enum-barstate)>

### Off

```cangjie
Off
```

**功能：** 不显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Auto

```cangjie
Auto
```

**功能：** 按需显示（触摸时显示，2秒后消失）。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### On

```cangjie
On
```

**功能：** 常驻显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(BarState)

```cangjie
public operator func ==(other: BarState): Bool
```

**功能：** 判断两个BarState枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BarState](#enum-barstate)|是|-|要比较的另一个BarState枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(BarState)

```cangjie
public operator func !=(other: BarState): Bool
```

**功能：** 判断两个BarState枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BarState](#enum-barstate)|是|-|要比较的另一个BarState枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum Visibility

```cangjie
public enum Visibility <: Equatable<Visibility> {
    | Visible
    | Hidden
    | None
    | ...
}
```

**功能：** 当前组件显示或隐藏。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[Visibility](#enum-visibility)>

### Visible

```cangjie
Visible
```

**功能：** 显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Hidden

```cangjie
Hidden
```

**功能：** 隐藏，但参与布局进行占位。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### None

```cangjie
None
```

**功能：** 隐藏，但不参与布局，不进行占位。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(Visibility)

```cangjie
public operator func ==(other: Visibility): Bool
```

**功能：** 判断两个Visibility枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Visibility](#enum-visibility)|是|-|要比较的另一个Visibility枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(Visibility)

```cangjie
public operator func !=(other: Visibility): Bool
```

**功能：** 判断两个Visibility枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Visibility](#enum-visibility)|是|-|要比较的另一个Visibility枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum LineCapStyle

```cangjie
public enum LineCapStyle <: Equatable<LineCapStyle> {
    | Butt
    | Round
    | Square
    | ...
}
```

**功能：** 线条样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[LineCapStyle](#enum-linecapstyle)>

### Butt

```cangjie
Butt
```

**功能：** 线条两端为平行线，不额外扩展

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Round

```cangjie
Round
```

**功能：** 在线条两端延伸半个圆，直径等于线宽

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Square

```cangjie
Square
```

**功能：** 在线条两端延伸半个圆，直径等于线宽

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(LineCapStyle)

```cangjie
public operator func ==(other: LineCapStyle): Bool
```

**功能：** 判断两个LineCapStyle枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[LineCapStyle](#enum-linecapstyle)|是|-|要比较的另一个LineCapStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(LineCapStyle)

```cangjie
public operator func !=(other: LineCapStyle): Bool
```

**功能：** 判断两个LineCapStyle枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[LineCapStyle](#enum-linecapstyle)|是|-|要比较的另一个LineCapStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ProgressType

```cangjie
public enum ProgressType <: Equatable<ProgressType> {
    | Linear
    | Ring
    | Eclipse
    | ScaleRing
    | Capsule
    | ...
}
```

**功能：** Progress组件的样式类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ProgressType](#enum-progresstype)>

### Linear

```cangjie
Linear
```

**功能：** 线性样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Ring

```cangjie
Ring
```

**功能：** 环形无刻度样式，环形圆环逐渐显示至完全填充效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Eclipse

```cangjie
Eclipse
```

**功能：** 圆形样式，显示类似月圆月缺的进度展示效果，从月牙逐渐变化至满月。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ScaleRing

```cangjie
ScaleRing
```

**功能：** 环形有刻度样式，显示类似时钟刻度形式的进度展示效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Capsule

```cangjie
Capsule
```

**功能：** 胶囊样式，头尾两端圆弧处的进度展示效果与Eclipse相同；中段处的进度展示效果与Linear相同。高度大于宽度的时候自适应垂直显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ProgressType)

```cangjie
public operator func ==(other: ProgressType): Bool
```

**功能：** 判断两个ProgressType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ProgressType](#enum-progresstype)|是|-|要比较的另一个ProgressType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ProgressType)

```cangjie
public operator func !=(other: ProgressType): Bool
```

**功能：** 判断两个ProgressType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ProgressType](#enum-progresstype)|是|-|要比较的另一个ProgressType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ImageRenderMode

```cangjie
public enum ImageRenderMode <: Equatable<ImageRenderMode> {
    | Original
    | Template
    | ...
}
```

**功能：** 图像渲染模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ImageRenderMode](#enum-imagerendermode)>

### Original

```cangjie
Original
```

**功能：** 按照原图进行渲染，包括颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Template

```cangjie
Template
```

**功能：** 将图片渲染为模板图片，忽略图片的颜色信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ImageRenderMode)

```cangjie
public operator func ==(other: ImageRenderMode): Bool
```

**功能：** 判断两个ImageRenderMode枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageRenderMode](#enum-imagerendermode)|是|-|要比较的另一个ImageRenderMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ImageRenderMode)

```cangjie
public operator func !=(other: ImageRenderMode): Bool
```

**功能：** 判断两个ImageRenderMode枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageRenderMode](#enum-imagerendermode)|是|-|要比较的另一个ImageRenderMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum NavigationType

```cangjie
public enum NavigationType <: Equatable<NavigationType> {
    | Push
    | Replace
    | Back
    | ...
}
```

**功能：** 页面路由方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[NavigationType](#enum-navigationtype)>

### Push

```cangjie
Push
```

**功能：** 跳转到应用内的指定页面。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Replace

```cangjie
Replace
```

**功能：** 用应用内的某个页面替换当前页面，并销毁被替换的页面。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Back

```cangjie
Back
```

**功能：** 返回到指定的页面。指定的页面不存在栈中时不响应。未传入指定的页面时返回上一页。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(NavigationType)

```cangjie
public operator func ==(other: NavigationType): Bool
```

**功能：** 判断两个NavigationType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[NavigationType](#enum-navigationtype)|是|-|要比较的另一个NavigationType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(NavigationType)

```cangjie
public operator func !=(other: NavigationType): Bool
```

**功能：** 判断两个NavigationType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[NavigationType](#enum-navigationtype)|是|-|要比较的另一个NavigationType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SwiperDisplayMode

```cangjie
public enum SwiperDisplayMode <: Equatable<SwiperDisplayMode> {
    | Stretch
    | ...
}
```

**功能：** Swiper在主轴上的尺寸大小模式枚举。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SwiperDisplayMode](#enum-swiperdisplaymode)>

### Stretch

```cangjie
Stretch
```

**功能：** Swiper滑动一页的宽度为Swiper组件自身的宽度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SwiperDisplayMode)

```cangjie
public operator func ==(other: SwiperDisplayMode): Bool
```

**功能：** 判断两个SwiperDisplayMode枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SwiperDisplayMode](#enum-swiperdisplaymode)|是|-|要比较的另一个SwiperDisplayMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SwiperDisplayMode)

```cangjie
public operator func !=(other: SwiperDisplayMode): Bool
```

**功能：** 判断两个SwiperDisplayMode枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SwiperDisplayMode](#enum-swiperdisplaymode)|是|-|要比较的另一个SwiperDisplayMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum Curve

```cangjie
public enum Curve <: Equatable<Curve> {
    | Linear
    | Ease
    | EaseIn
    | EaseOut
    | EaseInOut
    | FastOutSlowIn
    | LinearOutSlowIn
    | FastOutLinearIn
    | ExtremeDeceleration
    | Sharp
    | Rhythm
    | Smooth
    | Friction
    | ...
}
```

**功能：** 动画曲线。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[Curve](#enum-curve)>

### Linear

```cangjie
Linear
```

**功能：** 表示动画从头到尾的速度都是相同的。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Ease

```cangjie
Ease
```

**功能：** 表示动画以低速开始，然后加快，在结束前变慢，CubicBezier(0.25, 0.1, 0.25, 1.0)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### EaseIn

```cangjie
EaseIn
```

**功能：** 表示动画以低速开始，CubicBezier(0.42, 0.0, 1.0, 1.0)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### EaseOut

```cangjie
EaseOut
```

**功能：** 表示动画以低速结束，CubicBezier(0.0, 0.0, 0.58, 1.0)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### EaseInOut

```cangjie
EaseInOut
```

**功能：** 表示动画以低速开始和结束，CubicBezier(0.42, 0.0, 0.58, 1.0)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### FastOutSlowIn

```cangjie
FastOutSlowIn
```

**功能：** 标准曲线，cubic-bezier(0.4, 0.0, 0.2, 1.0)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### LinearOutSlowIn

```cangjie
LinearOutSlowIn
```

**功能：** 减速曲线，cubic-bezier(0.0, 0.0, 0.2, 1.0)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### FastOutLinearIn

```cangjie
FastOutLinearIn
```

**功能：** 加速曲线，cubic-bezier(0.4, 0.0, 1.0, 1.0)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ExtremeDeceleration

```cangjie
ExtremeDeceleration
```

**功能：** 急缓曲线，cubic-bezier(0.0, 0.0, 0.0, 1.0)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Sharp

```cangjie
Sharp
```

**功能：** 锐利曲线，CubicBezier(0.4, 0.0, 0.6, 1.0)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Rhythm

```cangjie
Rhythm
```

**功能：** 节奏曲线，CubicBezier(0.7, 0.0, 0.2, 1.0)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Smooth

```cangjie
Smooth
```

**功能：** 平滑曲线，CubicBezier(0.4, 0.0, 0.2, 1.0)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Friction

```cangjie
Friction
```

**功能：** 阻尼曲线，CubicBezier(0.2, 0.0, 0.2, 1.0)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(Curve)

```cangjie
public operator func ==(other: Curve): Bool
```

**功能：** 判断两个Curve枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Curve](#enum-curve)|是|-|要比较的另一个Curve枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(Curve)

```cangjie
public operator func !=(other: Curve): Bool
```

**功能：** 判断两个Curve枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Curve](#enum-curve)|是|-|要比较的另一个Curve枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum EdgeEffect

```cangjie
public enum EdgeEffect <: Equatable<EdgeEffect> {
    | Spring
    | Fade
    | None
    | ...
}
```

**功能：** 边缘滑动效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[EdgeEffect](#enum-edgeeffect)>

### Spring

```cangjie
Spring
```

**功能：** 弹性物理动效，滑动到边缘后可以根据初始速度或通过触摸事件继续滑动一段距离，松手后回弹。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Fade

```cangjie
Fade
```

**功能：** 阴影效果，滑动到边缘后会有圆弧状的阴影。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### None

```cangjie
None
```

**功能：** 滑动到边缘后无效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(EdgeEffect)

```cangjie
public operator func ==(other: EdgeEffect): Bool
```

**功能：** 判断两个EdgeEffect枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[EdgeEffect](#enum-edgeeffect)|是|-|要比较的另一个EdgeEffect枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(EdgeEffect)

```cangjie
public operator func !=(other: EdgeEffect): Bool
```

**功能：** 判断两个EdgeEffect枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[EdgeEffect](#enum-edgeeffect)|是|-|要比较的另一个EdgeEffect枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum Edge

```cangjie
public enum Edge <: Equatable<Edge> {
    | Top
    | Start
    | Bottom
    | End
    | ...
}
```

**功能：** 滚动到容器边缘。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[Edge](#enum-edge)>

### Top

```cangjie
Top
```

**功能：** 竖直方向上边缘。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Start

```cangjie
Start
```

**功能：** 水平方向起始位置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Bottom

```cangjie
Bottom
```

**功能：** 竖直方向下边缘。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### End

```cangjie
End
```

**功能：** 水平方向末尾位置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(Edge)

```cangjie
public operator func ==(other: Edge): Bool
```

**功能：** 判断两个Edge枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Edge](#enum-edge)|是|-|要比较的另一个Edge枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(Edge)

```cangjie
public operator func !=(other: Edge): Bool
```

**功能：** 判断两个Edge枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Edge](#enum-edge)|是|-|要比较的另一个Edge枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum Placement

```cangjie
public enum Placement <: Equatable<Placement> {
    | Left
    | Right
    | Top
    | Bottom
    | TopLeft
    | TopRight
    | BottomLeft
    | BottomRight
    | LeftTop
    | LeftBottom
    | RightTop
    | RightBottom
    | ...
}
```

**功能：** 气泡提示位置设置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[Placement](#enum-placement)>

### Left

```cangjie
Left
```

**功能：** 气泡提示位于组件左侧，与组件左侧中心对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Right

```cangjie
Right
```

**功能：** 气泡提示位于组件右侧，与组件右侧中心对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Top

```cangjie
Top
```

**功能：** 气泡提示位于组件上侧，与组件上侧中心对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Bottom

```cangjie
Bottom
```

**功能：** 气泡提示位于组件下侧，与组件下侧中心对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### TopLeft

```cangjie
TopLeft
```

**功能：** 气泡提示位于组件上侧，与组件左侧边缘对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### TopRight

```cangjie
TopRight
```

**功能：** 气泡提示位于组件上侧，与组件右侧边缘对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BottomLeft

```cangjie
BottomLeft
```

**功能：** 气泡提示位于组件下侧，与组件左侧边缘对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BottomRight

```cangjie
BottomRight
```

**功能：** 气泡提示位于组件下侧，与组件右侧边缘对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### LeftTop

```cangjie
LeftTop
```

**功能：** 气泡提示位于组件左侧，与组件上侧边缘对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### LeftBottom

```cangjie
LeftBottom
```

**功能：** 气泡提示位于组件左侧，与组件下侧边缘对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### RightTop

```cangjie
RightTop
```

**功能：** 气泡提示位于组件右侧，与组件上侧边缘对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### RightBottom

```cangjie
RightBottom
```

**功能：** 气泡提示位于组件右侧，与组件下侧边缘对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(Placement)

```cangjie
public operator func ==(other: Placement): Bool
```

**功能：** 判断两个Placement枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Placement](#enum-placement)|是|-|要比较的另一个Placement枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(Placement)

```cangjie
public operator func !=(other: Placement): Bool
```

**功能：** 判断两个Placement枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Placement](#enum-placement)|是|-|要比较的另一个Placement枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum LineJoinStyle

```cangjie
public enum LineJoinStyle <: Equatable<LineJoinStyle> {
    | Miter
    | Round
    | Bevel
    | ...
}
```

**功能：** 路径段连接方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[LineJoinStyle](#enum-linejoinstyle)>

### Miter

```cangjie
Miter
```

**功能：** 使用尖角连接路径段。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Round

```cangjie
Round
```

**功能：** 使用圆角连接路径段。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Bevel

```cangjie
Bevel
```

**功能：** 使用斜角连接路径段。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(LineJoinStyle)

```cangjie
public operator func ==(other: LineJoinStyle): Bool
```

**功能：** 判断两个LineJoinStyle枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[LineJoinStyle](#enum-linejoinstyle)|是|-|要比较的另一个LineJoinStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(LineJoinStyle)

```cangjie
public operator func !=(other: LineJoinStyle): Bool
```

**功能：** 判断两个LineJoinStyle枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[LineJoinStyle](#enum-linejoinstyle)|是|-|要比较的另一个LineJoinStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum BarPosition

```cangjie
public enum BarPosition <: Equatable<BarPosition> {
    | Start
    | End
    | ...
}
```

**功能：** 设置TabBar的布局位置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[BarPosition](#enum-barposition)>

### Start

```cangjie
Start
```

**功能：** 位于首部。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### End

```cangjie
End
```

**功能：** 位于尾部。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(BarPosition)

```cangjie
public operator func ==(other: BarPosition): Bool
```

**功能：** 判断两个BarPosition枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BarPosition](#enum-barposition)|是|-|要比较的另一个BarPosition枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(BarPosition)

```cangjie
public operator func !=(other: BarPosition): Bool
```

**功能：** 判断两个BarPosition枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BarPosition](#enum-barposition)|是|-|要比较的另一个BarPosition枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum BarMode

```cangjie
public enum BarMode <: Equatable<BarMode> {
    | Fixed
    | Scrollable
    | ...
}
```

**功能：** TabBar布局模式枚举。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[BarMode](#enum-barmode)>

### Fixed

```cangjie
Fixed
```

**功能：** 所有TabBar均分屏幕宽度，TabBar不可滚动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Scrollable

```cangjie
Scrollable
```

**功能：** 所有TabBar按照自身尺寸布局，TabBar可滚动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(BarMode)

```cangjie
public operator func ==(other: BarMode): Bool
```

**功能：** 判断两个BarMode枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BarMode](#enum-barmode)|是|-|要比较的另一个BarMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(BarMode)

```cangjie
public operator func !=(other: BarMode): Bool
```

**功能：** 判断两个BarMode枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BarMode](#enum-barmode)|是|-|要比较的另一个BarMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ShadowType

```cangjie
public enum ShadowType <: Equatable<ShadowType> {
    | Color
    | Blur
    | ...
}
```

**功能：** 阴影类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ShadowType](#enum-shadowtype)>

### Color

```cangjie
Color
```

**功能：** 颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Blur

```cangjie
Blur
```

**功能：** 模糊。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ShadowType)

```cangjie
public operator func ==(other: ShadowType): Bool
```

**功能：** 判断两个ShadowType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ShadowType](#enum-shadowtype)|是|-|要比较的另一个ShadowType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ShadowType)

```cangjie
public operator func !=(other: ShadowType): Bool
```

**功能：** 判断两个ShadowType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ShadowType](#enum-shadowtype)|是|-|要比较的另一个ShadowType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum TextDecorationType

```cangjie
public enum TextDecorationType <: Equatable<TextDecorationType> {
    | None
    | Underline
    | Overline
    | LineThrough
    | ...
}
```

**功能：** 装饰线类型枚举。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[TextDecorationType](#enum-textdecorationtype)>

### None

```cangjie
None
```

**功能：** 不使用文本装饰线。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Underline

```cangjie
Underline
```

**功能：** 在文字下方加下划线。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Overline

```cangjie
Overline
```

**功能：** 文字上划线修饰。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### LineThrough

```cangjie
LineThrough
```

**功能：** 穿过文本的修饰线。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(TextDecorationType)

```cangjie
public operator func ==(other: TextDecorationType): Bool
```

**功能：** 判断两个TextDecorationType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextDecorationType](#enum-textdecorationtype)|是|-|要比较的另一个TextDecorationType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(TextDecorationType)

```cangjie
public operator func !=(other: TextDecorationType): Bool
```

**功能：** 判断两个TextDecorationType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextDecorationType](#enum-textdecorationtype)|是|-|要比较的另一个TextDecorationType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum TextAlign

```cangjie
public enum TextAlign <: Equatable<TextAlign> {
    | Start
    | Center
    | End
    | ...
}
```

**功能：** 文本对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[TextAlign](#enum-textalign)>

### Start

```cangjie
Start
```

**功能：** 水平对齐首部。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Center

```cangjie
Center
```

**功能：** 水平居中对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### End

```cangjie
End
```

**功能：** 水平对齐尾部。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(TextAlign)

```cangjie
public operator func ==(other: TextAlign): Bool
```

**功能：** 判断两个TextAlign枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextAlign](#enum-textalign)|是|-|要比较的另一个TextAlign枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(TextAlign)

```cangjie
public operator func !=(other: TextAlign): Bool
```

**功能：** 判断两个TextAlign枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextAlign](#enum-textalign)|是|-|要比较的另一个TextAlign枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum TextOverflow

```cangjie
public enum TextOverflow <: Equatable<TextOverflow> {
    | Clip
    | Ellipsis
    | None
    | ...
}
```

**功能：** 文本超长时的显示方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[TextOverflow](#enum-textoverflow)>

### Clip

```cangjie
Clip
```

**功能：** 文本超长时按最大行截断显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Ellipsis

```cangjie
Ellipsis
```

**功能：** 文本超长时显示不下的文本用省略号代替。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### None

```cangjie
None
```

**功能：** 文本超长时按最大行截断显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(TextOverflow)

```cangjie
public operator func ==(other: TextOverflow): Bool
```

**功能：** 判断两个TextOverflow枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextOverflow](#enum-textoverflow)|是|-|要比较的另一个TextOverflow枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(TextOverflow)

```cangjie
public operator func !=(other: TextOverflow): Bool
```

**功能：** 判断两个TextOverflow枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextOverflow](#enum-textoverflow)|是|-|要比较的另一个TextOverflow枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum WordBreak

```cangjie
public enum WordBreak <: Equatable<WordBreak> {
    | Normal
    | BreakAll
    | BreakWord
    | ...
}
```

**功能：** 设置文本断行规则。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[WordBreak](#enum-wordbreak)>

### Normal

```cangjie
Normal
```

**功能：** CJK(中文、日文、韩文)文本可以在任意2个字符间断行，而Non-CJK文本（如英文等）只能在空白符处断行。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BreakAll

```cangjie
BreakAll
```

**功能：** 对于Non-CJK的文本，可在任意2个字符间断行。对于CJK与NORMAL效果一致。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BreakWord

```cangjie
BreakWord
```

**功能：** 与BREAKALL相同，对于Non-CJK的文本可在任意2个字符间断行，一行文本中有断行破发点（如空白符）时，优先按破发点换行，保障单词优先完整显示。若整一行文本均无断行破发点时，则在任意2个字符间断行。对于CJK与NORMAL效果一致。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(WordBreak)

```cangjie
public operator func ==(other: WordBreak): Bool
```

**功能：** 判断两个WordBreak枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WordBreak](#enum-wordbreak)|是|-|要比较的另一个WordBreak枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(WordBreak)

```cangjie
public operator func !=(other: WordBreak): Bool
```

**功能：** 判断两个WordBreak枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WordBreak](#enum-wordbreak)|是|-|要比较的另一个WordBreak枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ImageRepeat

```cangjie
public enum ImageRepeat <: Equatable<ImageRepeat> {
    | NoRepeat
    | X
    | Y
    | XY
    | ...
}
```

**功能：** 图片重复方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ImageRepeat](#enum-imagerepeat)>

### NoRepeat

```cangjie
NoRepeat
```

**功能：** 不重复绘制图片。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### X

```cangjie
X
```

**功能：** 只在水平轴上重复绘制图片。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Y

```cangjie
Y
```

**功能：** 只在竖直轴上重复绘制图片。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### XY

```cangjie
XY
```

**功能：** 在两个轴上重复绘制图片。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ImageRepeat)

```cangjie
public operator func ==(other: ImageRepeat): Bool
```

**功能：** 判断两个ImageRepeat枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageRepeat](#enum-imagerepeat)|是|-|要比较的另一个ImageRepeat枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ImageRepeat)

```cangjie
public operator func !=(other: ImageRepeat): Bool
```

**功能：** 判断两个ImageRepeat枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageRepeat](#enum-imagerepeat)|是|-|要比较的另一个ImageRepeat枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ImageSize

```cangjie
public enum ImageSize <: Equatable<ImageSize> {
    | Contain
    | Cover
    | Auto
    | ...
}
```

**功能：** 图片尺寸显示设置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ImageSize](#enum-imagesize)>

### Contain

```cangjie
Contain
```

**功能：** 保持宽高比进行缩小或者放大，使得图片完全显示在显示边界内。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Cover

```cangjie
Cover
```

**功能：** 保持宽高比进行缩小或者放大，使得图片两边都大于或等于显示边界。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Auto

```cangjie
Auto
```

**功能：** 使用Flex容器中默认配置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ImageSize)

```cangjie
public operator func ==(other: ImageSize): Bool
```

**功能：** 判断两个ImageSize枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageSize](#enum-imagesize)|是|-|要比较的另一个ImageSize枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ImageSize)

```cangjie
public operator func !=(other: ImageSize): Bool
```

**功能：** 判断两个ImageSize枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageSize](#enum-imagesize)|是|-|要比较的另一个ImageSize枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ShadowStyle

```cangjie
public enum ShadowStyle <: Equatable<ShadowStyle> {
    | OuterDefaultXS
    | OuterDefaultSM
    | OuterDefaultMD
    | OuterDefaultLG
    | OuterFloatingSM
    | OuterFloatingMD
    | ...
}
```

**功能：** 阴影样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ShadowStyle](#enum-shadowstyle)>

### OuterDefaultXS

```cangjie
OuterDefaultXS
```

**功能：** 超小阴影。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### OuterDefaultSM

```cangjie
OuterDefaultSM
```

**功能：** 小阴影。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### OuterDefaultMD

```cangjie
OuterDefaultMD
```

**功能：** 中阴影。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### OuterDefaultLG

```cangjie
OuterDefaultLG
```

**功能：** 大阴影。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### OuterFloatingSM

```cangjie
OuterFloatingSM
```

**功能：** 浮动小阴影。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### OuterFloatingMD

```cangjie
OuterFloatingMD
```

**功能：** 浮动中阴影。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ShadowStyle)

```cangjie
public operator func ==(other: ShadowStyle): Bool
```

**功能：** 判断两个ShadowStyle枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ShadowStyle](#enum-shadowstyle)|是|-|要比较的另一个ShadowStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ShadowStyle)

```cangjie
public operator func !=(other: ShadowStyle): Bool
```

**功能：** 判断两个ShadowStyle枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ShadowStyle](#enum-shadowstyle)|是|-|要比较的另一个ShadowStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum TextCase

```cangjie
public enum TextCase <: Equatable<TextCase> {
    | Normal
    | LowerCase
    | UpperCase
    | ...
}
```

**功能：** 文本大小写格式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[TextCase](#enum-textcase)>

### Normal

```cangjie
Normal
```

**功能：** 保持文本原有大小写。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### LowerCase

```cangjie
LowerCase
```

**功能：** 文本采用全小写。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### UpperCase

```cangjie
UpperCase
```

**功能：** 文本采用全大写。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(TextCase)

```cangjie
public operator func ==(other: TextCase): Bool
```

**功能：** 判断两个TextCase枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextCase](#enum-textcase)|是|-|要比较的另一个TextCase枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(TextCase)

```cangjie
public operator func !=(other: TextCase): Bool
```

**功能：** 判断两个TextCase枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextCase](#enum-textcase)|是|-|要比较的另一个TextCase枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum BorderStyle

```cangjie
public enum BorderStyle <: Equatable<BorderStyle> {
    | Solid
    | Dashed
    | Dotted
    | ...
}
```

**功能：** 边框样式，用于描述组件边框四条边的样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[BorderStyle](#enum-borderstyle)>

### Solid

```cangjie
Solid
```

**功能：** 显示为一条实线。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Dashed

```cangjie
Dashed
```

**功能：** 显示为一系列短的方形虚线。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Dotted

```cangjie
Dotted
```

**功能：** 显示为一系列圆点，圆点半径为borderWidth的一半。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(BorderStyle)

```cangjie
public operator func ==(other: BorderStyle): Bool
```

**功能：** 判断两个BorderStyle枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BorderStyle](#enum-borderstyle)|是|-|要比较的另一个BorderStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(BorderStyle)

```cangjie
public operator func !=(other: BorderStyle): Bool
```

**功能：** 判断两个BorderStyle枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BorderStyle](#enum-borderstyle)|是|-|要比较的另一个BorderStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ImageFit

```cangjie
public enum ImageFit <: Equatable<ImageFit> {
    | Fill
    | Contain
    | Cover
    | Auto
    | None
    | ScaleDown
    | ...
}
```

**功能：** 图片的显示适配方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ImageFit](#enum-imagefit)>

### Fill

```cangjie
Fill
```

**功能：** 不保持宽高比进行缩放，图片会被拉伸以填满整个显示边界。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Contain

```cangjie
Contain
```

**功能：** 保持宽高比进行缩小或者放大，使得图片完全显示在显示边界内。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Cover

```cangjie
Cover
```

**功能：** 保持宽高比进行缩小或者放大，使得图片两边都大于或等于显示边界。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Auto

```cangjie
Auto
```

**功能：** 默认值，保持原图的比例不变。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### None

```cangjie
None
```

**功能：** 图片不进行任何缩放，保持原始尺寸显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ScaleDown

```cangjie
ScaleDown
```

**功能：** 图片会按照比例缩小，但不会放大，保持宽高比。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ImageFit)

```cangjie
public operator func ==(other: ImageFit): Bool
```

**功能：** 判断两个ImageFit枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageFit](#enum-imagefit)|是|-|要比较的另一个ImageFit枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ImageFit)

```cangjie
public operator func !=(other: ImageFit): Bool
```

**功能：** 判断两个ImageFit枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageFit](#enum-imagefit)|是|-|要比较的另一个ImageFit枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum Direction

```cangjie
public enum Direction <: Equatable<Direction> {
    | Ltr
    | Rtl
    | Auto
    | ...
}
```

**功能：** 元素布局方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[Direction](#enum-direction)>

### Ltr

```cangjie
Ltr
```

**功能：** 元素从左到右布局。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Rtl

```cangjie
Rtl
```

**功能：** 元素从右到左布局。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Auto

```cangjie
Auto
```

**功能：** 使用默认布局方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(Direction)

```cangjie
public operator func ==(other: Direction): Bool
```

**功能：** 判断两个Direction枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Direction](#enum-direction)|是|-|要比较的另一个Direction枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(Direction)

```cangjie
public operator func !=(other: Direction): Bool
```

**功能：** 判断两个Direction枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Direction](#enum-direction)|是|-|要比较的另一个Direction枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ScrollDirection

```cangjie
public enum ScrollDirection <: Equatable<ScrollDirection> {
    | Vertical
    | Horizontal
    | ...
}
```

**功能：** 滚动方向枚举。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ScrollDirection](#enum-scrolldirection)>

### Vertical

```cangjie
Vertical
```

**功能：** 仅支持竖直方向滚动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Horizontal

```cangjie
Horizontal
```

**功能：** 仅支持水平方向滚动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ScrollDirection)

```cangjie
public operator func ==(other: ScrollDirection): Bool
```

**功能：** 判断两个ScrollDirection枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScrollDirection](#enum-scrolldirection)|是|-|要比较的另一个ScrollDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ScrollDirection)

```cangjie
public operator func !=(other: ScrollDirection): Bool
```

**功能：** 判断两个ScrollDirection枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScrollDirection](#enum-scrolldirection)|是|-|要比较的另一个ScrollDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ScrollBarDirection

```cangjie
public enum ScrollBarDirection <: Equatable<ScrollBarDirection> {
    | Vertical
    | Horizontal
    | ...
}
```

**功能：** 设置滚动条的方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ScrollBarDirection](#enum-scrollbardirection)>

### Vertical

```cangjie
Vertical
```

**功能：** 设置滚动条方向为纵向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Horizontal

```cangjie
Horizontal
```

**功能：** 设置滚动条方向为横向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ScrollBarDirection)

```cangjie
public operator func ==(other: ScrollBarDirection): Bool
```

**功能：** 判断两个ScrollBarDirection枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScrollBarDirection](#enum-scrollbardirection)|是|-|要比较的另一个ScrollBarDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ScrollBarDirection)

```cangjie
public operator func !=(other: ScrollBarDirection): Bool
```

**功能：** 判断两个ScrollBarDirection枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScrollBarDirection](#enum-scrollbardirection)|是|-|要比较的另一个ScrollBarDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SliderChangeMode

```cangjie
public enum SliderChangeMode <: Equatable<SliderChangeMode> {
    | Begin
    | Moving
    | End
    | Click
    | ...
}
```

**功能：** Slider拖动或点击时触发事件的状态值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SliderChangeMode](#enum-sliderchangemode)>

### Begin

```cangjie
Begin
```

**功能：** 鼠标接触或者按下滑块。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Moving

```cangjie
Moving
```

**功能：** 正在拖动滑块过程中。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### End

```cangjie
End
```

**功能：** 手势/鼠标离开滑块。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Click

```cangjie
Click
```

**功能：** 点击滑动条使滑块位置移动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SliderChangeMode)

```cangjie
public operator func ==(other: SliderChangeMode): Bool
```

**功能：** 判断两个SliderChangeMode枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SliderChangeMode](#enum-sliderchangemode)|是|-|要比较的另一个SliderChangeMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SliderChangeMode)

```cangjie
public operator func !=(other: SliderChangeMode): Bool
```

**功能：** 判断两个SliderChangeMode枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SliderChangeMode](#enum-sliderchangemode)|是|-|要比较的另一个SliderChangeMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum IndexerAlign

```cangjie
public enum IndexerAlign <: Equatable<IndexerAlign> {
    | Left
    | Right
    | ...
}
```

**功能：** 索引器对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[IndexerAlign](#enum-indexeralign)>

### Left

```cangjie
Left
```

**功能：** 左对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Right

```cangjie
Right
```

**功能：** 右对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(IndexerAlign)

```cangjie
public operator func ==(other: IndexerAlign): Bool
```

**功能：** 判断两个IndexerAlign枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[IndexerAlign](#enum-indexeralign)|是|-|要比较的另一个IndexerAlign枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(IndexerAlign)

```cangjie
public operator func !=(other: IndexerAlign): Bool
```

**功能：** 判断两个IndexerAlign枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[IndexerAlign](#enum-indexeralign)|是|-|要比较的另一个IndexerAlign枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum InputType

```cangjie
public enum InputType <: Equatable<InputType> {
    | Normal
    | Number
    | Email
    | Password
    | PhoneNumber
    | ...
}
```

**功能：** 表示输入框的类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[InputType](#enum-inputtype)>

### Normal

```cangjie
Normal
```

**功能：** 表示基本输入模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Number

```cangjie
Number
```

**功能：** 表示纯数字输入模式，仅能输入表示数字的字符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Email

```cangjie
Email
```

**功能：** mail地址输入模式，仅能输入标准邮箱格式支持的字符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Password

```cangjie
Password
```

**功能：** 表示密码输入模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### PhoneNumber

```cangjie
PhoneNumber
```

**功能：** 表示电话号码输入模式。支持输入数字、空格、+ 、-、*、#、(、)，长度不限。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(InputType)

```cangjie
public operator func ==(other: InputType): Bool
```

**功能：** 判断两个InputType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[InputType](#enum-inputtype)|是|-|要比较的另一个InputType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(InputType)

```cangjie
public operator func !=(other: InputType): Bool
```

**功能：** 判断两个InputType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[InputType](#enum-inputtype)|是|-|要比较的另一个InputType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum EnterKeyType

```cangjie
public enum EnterKeyType <: Equatable<EnterKeyType> {
    | Go
    | Search
    | Send
    | Next
    | Done
    | Previous
    | NewLine
    | ...
}
```

**功能：** 表示键盘操作按钮的类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[EnterKeyType](#enum-enterkeytype)>

### Go

```cangjie
Go
```

**功能：** 显示为开始样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Search

```cangjie
Search
```

**功能：** 显示为搜索样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Send

```cangjie
Send
```

**功能：** c

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Next

```cangjie
Next
```

**功能：** 显示为下一步样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Done

```cangjie
Done
```

**功能：** 显示为完成样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Previous

```cangjie
Previous
```

**功能：** 显示为上一步样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### NewLine

```cangjie
NewLine
```

**功能：** 显示为换行样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(EnterKeyType)

```cangjie
public operator func ==(other: EnterKeyType): Bool
```

**功能：** 判断两个EnterKeyType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[EnterKeyType](#enum-enterkeytype)|是|-|要比较的另一个EnterKeyType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(EnterKeyType)

```cangjie
public operator func !=(other: EnterKeyType): Bool
```

**功能：** 判断两个EnterKeyType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[EnterKeyType](#enum-enterkeytype)|是|-|要比较的另一个EnterKeyType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum FlexDirection

```cangjie
public enum FlexDirection <: Equatable<FlexDirection> {
    | Row
    | Column
    | RowReverse
    | ColumnReverse
    | ...
}
```

**功能：** Flex布局容器方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[FlexDirection](#enum-flexdirection)>

### Row

```cangjie
Row
```

**功能：** 主轴与行方向一致作为布局模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Column

```cangjie
Column
```

**功能：** 主轴与列方向一致作为布局模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### RowReverse

```cangjie
RowReverse
```

**功能：** 与Row方向相反方向进行布局。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ColumnReverse

```cangjie
ColumnReverse
```

**功能：** 与Column相反方向进行布局。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(FlexDirection)

```cangjie
public operator func ==(other: FlexDirection): Bool
```

**功能：** 判断两个FlexDirection枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FlexDirection](#enum-flexdirection)|是|-|要比较的另一个FlexDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(FlexDirection)

```cangjie
public operator func !=(other: FlexDirection): Bool
```

**功能：** 判断两个FlexDirection枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FlexDirection](#enum-flexdirection)|是|-|要比较的另一个FlexDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum FlexWrap

```cangjie
public enum FlexWrap <: Equatable<FlexWrap> {
    | NoWrap
    | Wrap
    | WrapReverse
    | ...
}
```

**功能：** FlexWrap枚举描述。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[FlexWrap](#enum-flexwrap)>

### NoWrap

```cangjie
NoWrap
```

**功能：** Flex容器的元素单行/列布局，子元素尽可能约束在容器内。当子元素有最小尺寸约束等设置时，Flex容器不会对其强制弹性压缩。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Wrap

```cangjie
Wrap
```

**功能：** Flex容器的元素多行/列排布，子项允许超出容器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### WrapReverse

```cangjie
WrapReverse
```

**功能：** 与Wrap方向相反方向进行布局。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(FlexWrap)

```cangjie
public operator func ==(other: FlexWrap): Bool
```

**功能：** 判断两个FlexWrap枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FlexWrap](#enum-flexwrap)|是|-|要比较的另一个FlexWrap枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(FlexWrap)

```cangjie
public operator func !=(other: FlexWrap): Bool
```

**功能：** 判断两个FlexWrap枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FlexWrap](#enum-flexwrap)|是|-|要比较的另一个FlexWrap枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum FlexAlign

```cangjie
public enum FlexAlign <: Equatable<FlexAlign> {
    | Start
    | Center
    | End
    | SpaceBetween
    | SpaceAround
    | SpaceEvenly
    | ...
}
```

**功能：** Flex容器对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[FlexAlign](#enum-flexalign)>

### Start

```cangjie
Start
```

**功能：** 元素在主轴方向头部对齐，第一个元素与行首对齐，其他元素与前一个对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Center

```cangjie
Center
```

**功能：** 元素在主轴方向中心对齐，第一个元素与行首的距离与最后一个元素与行尾距离相同。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### End

```cangjie
End
```

**功能：** 元素在主轴方向尾部对齐，最后一个元素与行尾对齐，其他元素与后一个对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### SpaceBetween

```cangjie
SpaceBetween
```

**功能：** Flex主轴方向均匀分配弹性元素，相邻元素之间距离相同。第一个元素与行首对齐，最后一个元素与行尾对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### SpaceAround

```cangjie
SpaceAround
```

**功能：** Flex主轴方向均匀分配弹性元素，相邻元素之间距离相同。第一个元素到行首的距离和最后一个元素到行尾的距离是相邻元素之间距离的一半。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### SpaceEvenly

```cangjie
SpaceEvenly
```

**功能：** Flex主轴方向均匀分配弹性元素，相邻元素之间距离相同。第一个元素到行首的距离和最后一个元素到行尾的距离与相邻元素之间距离相同。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(FlexAlign)

```cangjie
public operator func ==(other: FlexAlign): Bool
```

**功能：** 判断两个FlexAlign枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FlexAlign](#enum-flexalign)|是|-|要比较的另一个FlexAlign枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(FlexAlign)

```cangjie
public operator func !=(other: FlexAlign): Bool
```

**功能：** 判断两个FlexAlign枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FlexAlign](#enum-flexalign)|是|-|要比较的另一个FlexAlign枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ItemAlign

```cangjie
public enum ItemAlign <: Equatable<ItemAlign> {
    | Auto
    | Start
    | Center
    | End
    | Stretch
    | Baseline
    | ...
}
```

**功能：** 元素对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ItemAlign](#enum-itemalign)>

### Auto

```cangjie
Auto
```

**功能：** 使用Flex容器中默认配置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Start

```cangjie
Start
```

**功能：** 元素在Flex容器中，交叉轴方向首部对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Center

```cangjie
Center
```

**功能：** ListItem在List中，交叉轴方向居中对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### End

```cangjie
End
```

**功能：** ListItem在List中，交叉轴方向尾部对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Stretch

```cangjie
Stretch
```

**功能：** 元素在Flex容器中，交叉轴方向拉伸填充。容器为Flex且设置Wrap为FlexWrap.Wrap或FlexWrap.WrapReverse时，元素拉伸到与当前行/列交叉轴长度最长的元素尺寸。其余情况下，无论元素尺寸是否设置，均拉伸到容器尺寸。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Baseline

```cangjie
Baseline
```

**功能：** 图片下边沿与文本BaseLine对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ItemAlign)

```cangjie
public operator func ==(other: ItemAlign): Bool
```

**功能：** 判断两个ItemAlign枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ItemAlign](#enum-itemalign)|是|-|要比较的另一个ItemAlign枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ItemAlign)

```cangjie
public operator func !=(other: ItemAlign): Bool
```

**功能：** 判断两个ItemAlign枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ItemAlign](#enum-itemalign)|是|-|要比较的另一个ItemAlign枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ToggleType

```cangjie
public enum ToggleType <: Equatable<ToggleType> {
    | Checkbox
    | Switch
    | Button
    | ...
}
```

**功能：** 开关组件类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ToggleType](#enum-toggletype)>

### Checkbox

```cangjie
Checkbox
```

**功能：** 提供单选框样式。
Checkbox默认样式为圆形。
通用属性margin的默认值为：top 14.px, right 14.px, bottom 14.px, left 14.px。
默认尺寸为：宽为20.vp, 高为20.vp。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Switch

```cangjie
Switch
```

**功能：** 提供开关样式。
通用属性margin的默认值为：top 6.px, right 14.px, bottom 6.px, left 14.px。
默认尺寸为：宽为36.vp, 高为20.vp。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Button

```cangjie
Button
```

**功能：** 提供状态按钮样式，如果子组件有文本设置，则相应的文本内容会显示在按钮内部。
初始尺寸为：高为28.vp，宽无初始值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ToggleType)

```cangjie
public operator func ==(other: ToggleType): Bool
```

**功能：** 判断两个ToggleType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ToggleType](#enum-toggletype)|是|-|要比较的另一个ToggleType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ToggleType)

```cangjie
public operator func !=(other: ToggleType): Bool
```

**功能：** 判断两个ToggleType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ToggleType](#enum-toggletype)|是|-|要比较的另一个ToggleType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum FontStyle

```cangjie
public enum FontStyle <: Equatable<FontStyle> {
    | Normal
    | Italic
    | ...
}
```

**功能：** 字体样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[FontStyle](#enum-fontstyle)>

### Normal

```cangjie
Normal
```

**功能：** 标准字体样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Italic

```cangjie
Italic
```

**功能：** 斜体字体样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(FontStyle)

```cangjie
public operator func ==(other: FontStyle): Bool
```

**功能：** 判断两个FontStyle枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FontStyle](#enum-fontstyle)|是|-|要比较的另一个FontStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(FontStyle)

```cangjie
public operator func !=(other: FontStyle): Bool
```

**功能：** 判断两个FontStyle枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FontStyle](#enum-fontstyle)|是|-|要比较的另一个FontStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum Alignment

```cangjie
public enum Alignment <: Equatable<Alignment> {
    | TopStart
    | Top
    | TopEnd
    | Start
    | Center
    | End
    | BottomStart
    | Bottom
    | BottomEnd
    | ...
}
```

**功能：** 对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[Alignment](#enum-alignment)>

### TopStart

```cangjie
TopStart
```

**功能：** 顶部起始端。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Top

```cangjie
Top
```

**功能：** 顶部横向居中。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### TopEnd

```cangjie
TopEnd
```

**功能：** 顶部尾端。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Start

```cangjie
Start
```

**功能：** 起始端。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Center

```cangjie
Center
```

**功能：** 横向和纵向居中。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### End

```cangjie
End
```

**功能：** 尾端。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BottomStart

```cangjie
BottomStart
```

**功能：** 底部起始端。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Bottom

```cangjie
Bottom
```

**功能：** 底部横向居中。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BottomEnd

```cangjie
BottomEnd
```

**功能：** 底部尾端。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(Alignment)

```cangjie
public operator func ==(other: Alignment): Bool
```

**功能：** 判断两个Alignment枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Alignment](#enum-alignment)|是|-|要比较的另一个Alignment枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(Alignment)

```cangjie
public operator func !=(other: Alignment): Bool
```

**功能：** 判断两个Alignment枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Alignment](#enum-alignment)|是|-|要比较的另一个Alignment枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum HorizontalAlign

```cangjie
public enum HorizontalAlign <: Equatable<HorizontalAlign> {
    | Start
    | Center
    | End
    | ...
}
```

**功能：** 水平方向对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[HorizontalAlign](#enum-horizontalalign)>

### Start

```cangjie
Start
```

**功能：** 按照语言方向起始端对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Center

```cangjie
Center
```

**功能：** 居中对齐。使用默认对齐模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### End

```cangjie
End
```

**功能：** 按照语言方向末端对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(HorizontalAlign)

```cangjie
public operator func ==(other: HorizontalAlign): Bool
```

**功能：** 判断两个HorizontalAlign枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[HorizontalAlign](#enum-horizontalalign)|是|-|要比较的另一个HorizontalAlign枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(HorizontalAlign)

```cangjie
public operator func !=(other: HorizontalAlign): Bool
```

**功能：** 判断两个HorizontalAlign枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[HorizontalAlign](#enum-horizontalalign)|是|-|要比较的另一个HorizontalAlign枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum VerticalAlign

```cangjie
public enum VerticalAlign <: Equatable<VerticalAlign> {
    | Top
    | Center
    | Bottom
    | ...
}
```

**功能：** 垂直方向上对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[VerticalAlign](#enum-verticalalign)>

### Top

```cangjie
Top
```

**功能：** 顶部对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Center

```cangjie
Center
```

**功能：** 居中对齐，默认对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Bottom

```cangjie
Bottom
```

**功能：** 底部对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(VerticalAlign)

```cangjie
public operator func ==(other: VerticalAlign): Bool
```

**功能：** 判断两个VerticalAlign枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[VerticalAlign](#enum-verticalalign)|是|-|要比较的另一个VerticalAlign枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(VerticalAlign)

```cangjie
public operator func !=(other: VerticalAlign): Bool
```

**功能：** 判断两个VerticalAlign枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[VerticalAlign](#enum-verticalalign)|是|-|要比较的另一个VerticalAlign枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum FontWeight

```cangjie
public enum FontWeight <: Equatable<FontWeight> {
    | Normal
    | Bold
    | Bolder
    | Lighter
    | Medium
    | Regular
    | W100
    | W200
    | W300
    | W400
    | W500
    | W600
    | W700
    | W800
    | W900
    | ...
}
```

**功能：** 设置文本的字体粗细，设置过大可能会在不同字体下有截断。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[FontWeight](#enum-fontweight)>

### Normal

```cangjie
Normal
```

**功能：** 字体粗细正常。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Bold

```cangjie
Bold
```

**功能：** 字体较粗。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Bolder

```cangjie
Bolder
```

**功能：** 字体非常粗。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Lighter

```cangjie
Lighter
```

**功能：** 字体较细。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Medium

```cangjie
Medium
```

**功能：** 字体粗细适中。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Regular

```cangjie
Regular
```

**功能：** 字体粗细稍粗。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### W100

```cangjie
W100
```

**功能：** 100（最细）。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### W200

```cangjie
W200
```

**功能：** 200。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### W300

```cangjie
W300
```

**功能：** 300。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### W400

```cangjie
W400
```

**功能：** 400（正常）。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### W500

```cangjie
W500
```

**功能：** 500。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### W600

```cangjie
W600
```

**功能：** 600。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### W700

```cangjie
W700
```

**功能：** 700。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### W800

```cangjie
W800
```

**功能：** 800。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### W900

```cangjie
W900
```

**功能：** 900（最粗）。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(FontWeight)

```cangjie
public operator func ==(other: FontWeight): Bool
```

**功能：** 判断两个FontWeight枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FontWeight](#enum-fontweight)|是|-|要比较的另一个FontWeight枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(FontWeight)

```cangjie
public operator func !=(other: FontWeight): Bool
```

**功能：** 判断两个FontWeight枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FontWeight](#enum-fontweight)|是|-|要比较的另一个FontWeight枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ListItemAlign

```cangjie
public enum ListItemAlign <: Equatable<ListItemAlign> {
    | Start
    | Center
    | End
    | ...
}
```

**功能：** ListItem在List中，交叉轴方向的对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ListItemAlign](#enum-listitemalign)>

### Start

```cangjie
Start
```

**功能：** ListItem在List中，交叉轴方向首部对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Center

```cangjie
Center
```

**功能：** ListItem在List中，交叉轴方向居中对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### End

```cangjie
End
```

**功能：** ListItem在List中，交叉轴方向尾部对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ListItemAlign)

```cangjie
public operator func ==(other: ListItemAlign): Bool
```

**功能：** 判断两个ListItemAlign枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ListItemAlign](#enum-listitemalign)|是|-|要比较的另一个ListItemAlign枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ListItemAlign)

```cangjie
public operator func !=(other: ListItemAlign): Bool
```

**功能：** 判断两个ListItemAlign枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ListItemAlign](#enum-listitemalign)|是|-|要比较的另一个ListItemAlign枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum StickyStyle

```cangjie
public enum StickyStyle <: Equatable<StickyStyle> {
    | None
    | Header
    | Footer
    | ...
}
```

**功能：** 设置ListItemGroup中header和footer是否要吸顶或吸底。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[StickyStyle](#enum-stickystyle)>

### None

```cangjie
None
```

**功能：** 设置ListItemGroup的headerh不吸顶，footer不吸底。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Header

```cangjie
Header
```

**功能：** 设置ListItemGroup的headerh吸顶。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Footer

```cangjie
Footer
```

**功能：** 设置ListItemGroup的footer吸底。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(StickyStyle)

```cangjie
public operator func ==(other: StickyStyle): Bool
```

**功能：** 判断两个StickyStyle枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[StickyStyle](#enum-stickystyle)|是|-|要比较的另一个StickyStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(StickyStyle)

```cangjie
public operator func !=(other: StickyStyle): Bool
```

**功能：** 判断两个StickyStyle枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[StickyStyle](#enum-stickystyle)|是|-|要比较的另一个StickyStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum RichEditorSpanType

```cangjie
public enum RichEditorSpanType <: Equatable<RichEditorSpanType> {
    | Text
    | Image
    | Mixed
    | ...
}
```

**功能：** 表示Span类型信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[RichEditorSpanType](#enum-richeditorspantype)>

### Text

```cangjie
Text
```

**功能：** 表示Span为文字类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Image

```cangjie
Image
```

**功能：** 表示Span为图像类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Mixed

```cangjie
Mixed
```

**功能：** 表示Span为图文混合类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(RichEditorSpanType)

```cangjie
public operator func ==(other: RichEditorSpanType): Bool
```

**功能：** 判断两个RichEditorSpanType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[RichEditorSpanType](#enum-richeditorspantype)|是|-|要比较的另一个RichEditorSpanType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(RichEditorSpanType)

```cangjie
public operator func !=(other: RichEditorSpanType): Bool
```

**功能：** 判断两个RichEditorSpanType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[RichEditorSpanType](#enum-richeditorspantype)|是|-|要比较的另一个RichEditorSpanType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ImageSpanAlignment

```cangjie
public enum ImageSpanAlignment <: Equatable<ImageSpanAlignment> {
    | Top
    | Center
    | Bottom
    | Baseline
    | ...
}
```

**功能：** 图片基于行高的对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ImageSpanAlignment](#enum-imagespanalignment)>

### Top

```cangjie
Top
```

**功能：** 图片上边沿与行上边沿对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Center

```cangjie
Center
```

**功能：** 图片中间与行中间对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Bottom

```cangjie
Bottom
```

**功能：** 图片下边沿与行下边沿对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Baseline

```cangjie
Baseline
```

**功能：** 图片下边沿与文本BaseLine对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ImageSpanAlignment)

```cangjie
public operator func ==(other: ImageSpanAlignment): Bool
```

**功能：** 判断两个ImageSpanAlignment枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageSpanAlignment](#enum-imagespanalignment)|是|-|要比较的另一个ImageSpanAlignment枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ImageSpanAlignment)

```cangjie
public operator func !=(other: ImageSpanAlignment): Bool
```

**功能：** 判断两个ImageSpanAlignment枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageSpanAlignment](#enum-imagespanalignment)|是|-|要比较的另一个ImageSpanAlignment枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum RichEditorDeleteDirection

```cangjie
public enum RichEditorDeleteDirection <: Equatable<RichEditorDeleteDirection> {
    | Backward
    | Forward
    | ...
}
```

**功能：** 表示删除操作的方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[RichEditorDeleteDirection](#enum-richeditordeletedirection)>

### Backward

```cangjie
Backward
```

**功能：** 表示向后删除。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Forward

```cangjie
Forward
```

**功能：** 表示向前删除。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(RichEditorDeleteDirection)

```cangjie
public operator func ==(other: RichEditorDeleteDirection): Bool
```

**功能：** 判断两个RichEditorDeleteDirection枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[RichEditorDeleteDirection](#enum-richeditordeletedirection)|是|-|要比较的另一个RichEditorDeleteDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(RichEditorDeleteDirection)

```cangjie
public operator func !=(other: RichEditorDeleteDirection): Bool
```

**功能：** 判断两个RichEditorDeleteDirection枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[RichEditorDeleteDirection](#enum-richeditordeletedirection)|是|-|要比较的另一个RichEditorDeleteDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum MixedMode

```cangjie
public enum MixedMode <: Equatable<MixedMode> {
    | All
    | Compatible
    | None
    | ...
}
```

**功能：** 设置混合内容安全加载模式。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**父类型：**

- Equatable\<[MixedMode](#enum-mixedmode)>

### All

```cangjie
All
```

**功能：** 宽松模式：允许加载HTTP和HTTPS混合内容。所有不安全的内容都可以被加载。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### Compatible

```cangjie
Compatible
```

**功能：** 兼容模式：混合内容兼容性模式，部分不安全的内容可能被加载。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### None

```cangjie
None
```

**功能：** 严格模式：不允许加载HTTP和HTTPS混合内容。不允许安全来源（secure origin）加载不安全来源（insecure origin）的内容。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### operator func ==(MixedMode)

```cangjie
public operator func ==(other: MixedMode): Bool
```

**功能：** 判断两个MixedMode枚举是否相等。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MixedMode](#enum-mixedmode)|是|-|要比较的另一个MixedMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(MixedMode)

```cangjie
public operator func !=(other: MixedMode): Bool
```

**功能：** 判断两个MixedMode枚举是否不相等。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MixedMode](#enum-mixedmode)|是|-|要比较的另一个MixedMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum PlayMode

```cangjie
public enum PlayMode <: Equatable<PlayMode> {
    | Normal
    | Reverse
    | Alternate
    | AlternateReverse
    | ...
}
```

**功能：** 动画播放方向设置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[PlayMode](#enum-playmode)>

### Normal

```cangjie
Normal
```

**功能：** 动画正向播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Reverse

```cangjie
Reverse
```

**功能：** 动画反向播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Alternate

```cangjie
Alternate
```

**功能：** 动画在奇数次（1, 3, 7...）正向播放，在偶数次（2, 4, 6...）反向播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### AlternateReverse

```cangjie
AlternateReverse
```

**功能：** 动画在奇数次（1, 3, 7...）反向播放，在偶数次（2, 4, 6...）正向播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(PlayMode)

```cangjie
public operator func ==(other: PlayMode): Bool
```

**功能：** 判断两个PlayMode枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PlayMode](#enum-playmode)|是|-|要比较的另一个PlayMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(PlayMode)

```cangjie
public operator func !=(other: PlayMode): Bool
```

**功能：** 判断两个PlayMode枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PlayMode](#enum-playmode)|是|-|要比较的另一个PlayMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum GradientDirection

```cangjie
public enum GradientDirection <: Equatable<GradientDirection> {
    | Left
    | Top
    | Right
    | Bottom
    | LeftTop
    | LeftBottom
    | RightTop
    | RightBottom
    | None
    | ...
}
```

**功能：** 梯度方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[GradientDirection](#enum-gradientdirection)>

### Left

```cangjie
Left
```

**功能：** 从右到左。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Top

```cangjie
Top
```

**功能：** 从下到上。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Right

```cangjie
Right
```

**功能：** 从左到右。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Bottom

```cangjie
Bottom
```

**功能：** 从上到下。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### LeftTop

```cangjie
LeftTop
```

**功能：** 左上。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### LeftBottom

```cangjie
LeftBottom
```

**功能：** 左下。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### RightTop

```cangjie
RightTop
```

**功能：** 右上。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### RightBottom

```cangjie
RightBottom
```

**功能：** 右下。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### None

```cangjie
None
```

**功能：** 无。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(GradientDirection)

```cangjie
public operator func ==(other: GradientDirection): Bool
```

**功能：** 判断两个GradientDirection枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[GradientDirection](#enum-gradientdirection)|是|-|要比较的另一个GradientDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(GradientDirection)

```cangjie
public operator func !=(other: GradientDirection): Bool
```

**功能：** 判断两个GradientDirection枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[GradientDirection](#enum-gradientdirection)|是|-|要比较的另一个GradientDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum RenderFit

```cangjie
public enum RenderFit <: Equatable<RenderFit> {
    | Center
    | Top
    | Bottom
    | Left
    | Right
    | TopLeft
    | TopRight
    | BottomLeft
    | BottomRight
    | ResizeFill
    | ResizeContain
    | ResizeContainTopLeft
    | ResizeContainBottomRight
    | ResizeCover
    | ResizeCoverTopLeft
    | ResizeCoverBottomRight
    | ...
}
```

**功能：** 组件内容填充样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[RenderFit](#enum-renderfit)>

### Center

```cangjie
Center
```

**功能：** 保持动画终态的内容大小，并且内容始终与组件保持中心对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Top

```cangjie
Top
```

**功能：** 保持动画终态的内容大小，并且内容始终与组件保持顶部中心对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Bottom

```cangjie
Bottom
```

**功能：** 保持动画终态的内容大小，并且内容始终与组件保持底部中心对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Left

```cangjie
Left
```

**功能：** 保持动画终态的内容大小，并且内容始终与组件保持左侧对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Right

```cangjie
Right
```

**功能：** 保持动画终态的内容大小，并且内容始终与组件保持右侧对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### TopLeft

```cangjie
TopLeft
```

**功能：** 保持动画终态的内容大小，并且内容始终与组件保持左上角对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### TopRight

```cangjie
TopRight
```

**功能：** 保持动画终态的内容大小，并且内容始终与组件保持右上角对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BottomLeft

```cangjie
BottomLeft
```

**功能：** 保持动画终态的内容大小，并且内容始终与组件保持左下角对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BottomRight

```cangjie
BottomRight
```

**功能：** 保持动画终态的内容大小，并且内容始终与组件保持右下角对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ResizeFill

```cangjie
ResizeFill
```

**功能：** 不考虑动画终态内容的宽高比，并且内容始终缩放到组件的大小。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ResizeContain

```cangjie
ResizeContain
```

**功能：** 保持动画终态内容的宽高比进行缩小或放大，使内容完整显示在组件内，且与组件保持中心对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ResizeContainTopLeft

```cangjie
ResizeContainTopLeft
```

**功能：** 持动画终态内容的宽高比进行缩小或放大，使内容完整显示在组件内。当组件宽方向有剩余时，内容与组件保持左侧对齐，当组件高方向有剩余时，内容与组件保持顶部对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ResizeContainBottomRight

```cangjie
ResizeContainBottomRight
```

**功能：** 保持动画终态内容的宽高比进行缩小或放大，使内容的两边都恰好大于或等于组件两边。当内容宽方向有剩余时，内容与组件保持右侧对齐，显示内容的右侧部分。当内容高方向有剩余时，内容与组件保持底部对齐，显示内容的底侧部分。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ResizeCover

```cangjie
ResizeCover
```

**功能：** 保持动画终态内容的宽高比进行缩小或放大，使内容两边都大于或等于组件两边，且与组件保持中心对齐，显示内容的中间部分。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ResizeCoverTopLeft

```cangjie
ResizeCoverTopLeft
```

**功能：** 持动画终态内容的宽高比进行缩小或放大，使内容完整显示在组件内。当组件宽方向有剩余时，内容与组件保持左侧对齐，当组件高方向有剩余时，内容与组件保持顶部对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ResizeCoverBottomRight

```cangjie
ResizeCoverBottomRight
```

**功能：** 保持动画终态内容的宽高比进行缩小或放大，使内容完整显示在组件内。当组件宽方向有剩余时，内容与组件保持右侧对齐，当组件高方向有剩余时，内容与组件保持底部对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(RenderFit)

```cangjie
public operator func ==(other: RenderFit): Bool
```

**功能：** 判断两个RenderFit枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[RenderFit](#enum-renderfit)|是|-|要比较的另一个RenderFit枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(RenderFit)

```cangjie
public operator func !=(other: RenderFit): Bool
```

**功能：** 判断两个RenderFit枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[RenderFit](#enum-renderfit)|是|-|要比较的另一个RenderFit枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum DialogAlignment

```cangjie
public enum DialogAlignment <: Equatable<DialogAlignment> {
    | Top
    | Center
    | Bottom
    | Default
    | TopStart
    | TopEnd
    | CenterStart
    | CenterEnd
    | BottomStart
    | BottomEnd
    | ...
}
```

**功能：** 弹窗在竖直方向上的对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[DialogAlignment](#enum-dialogalignment)>

### Top

```cangjie
Top
```

**功能：** 垂直顶部对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Center

```cangjie
Center
```

**功能：** 垂直居中对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Bottom

```cangjie
Bottom
```

**功能：** 底部横向居中。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Default

```cangjie
Default
```

**功能：** 默认对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### TopStart

```cangjie
TopStart
```

**功能：** 对齐左上角。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### TopEnd

```cangjie
TopEnd
```

**功能：** 对齐右上角。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### CenterStart

```cangjie
CenterStart
```

**功能：** 左侧居中对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### CenterEnd

```cangjie
CenterEnd
```

**功能：** 右侧居中对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BottomStart

```cangjie
BottomStart
```

**功能：** 底部起始端。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BottomEnd

```cangjie
BottomEnd
```

**功能：** 底部尾端。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(DialogAlignment)

```cangjie
public operator func ==(other: DialogAlignment): Bool
```

**功能：** 判断两个DialogAlignment枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DialogAlignment](#enum-dialogalignment)|是|-|要比较的另一个DialogAlignment枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(DialogAlignment)

```cangjie
public operator func !=(other: DialogAlignment): Bool
```

**功能：** 判断两个DialogAlignment枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DialogAlignment](#enum-dialogalignment)|是|-|要比较的另一个DialogAlignment枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum BarrierDirection

```cangjie
public enum BarrierDirection <: Equatable<BarrierDirection> {
    | Left
    | Right
    | Top
    | Bottom
    | ...
}
```

**功能：** 定义屏障线的方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[BarrierDirection](#enum-barrierdirection)>

### Left

```cangjie
Left
```

**功能：** 屏障在其所有referencedId的最左侧。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Right

```cangjie
Right
```

**功能：** 屏障在其所有referencedId的最右侧。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Top

```cangjie
Top
```

**功能：** 屏障在其所有referencedId的最上方。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Bottom

```cangjie
Bottom
```

**功能：** Barrier将定位在所有引用组件的底部。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(BarrierDirection)

```cangjie
public operator func ==(other: BarrierDirection): Bool
```

**功能：** 判断两个BarrierDirection枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BarrierDirection](#enum-barrierdirection)|是|-|要比较的另一个BarrierDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(BarrierDirection)

```cangjie
public operator func !=(other: BarrierDirection): Bool
```

**功能：** 判断两个BarrierDirection枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BarrierDirection](#enum-barrierdirection)|是|-|要比较的另一个BarrierDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SafeAreaType

```cangjie
public enum SafeAreaType <: Equatable<SafeAreaType> {
    | System
    | Cutout
    | Keyboard
    | ...
}
```

**功能：** 扩展安全区域的枚举类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SafeAreaType](#enum-safeareatype)>

### System

```cangjie
System
```

**功能：** 默认系统非安全区域，包括状态栏和导航栏。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Cutout

```cangjie
Cutout
```

**功能：** 设备的非安全区域，如刘海屏或打孔屏。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Keyboard

```cangjie
Keyboard
```

**功能：** 软键盘区域。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SafeAreaType)

```cangjie
public operator func ==(other: SafeAreaType): Bool
```

**功能：** 判断两个SafeAreaType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SafeAreaType](#enum-safeareatype)|是|-|要比较的另一个SafeAreaType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SafeAreaType)

```cangjie
public operator func !=(other: SafeAreaType): Bool
```

**功能：** 判断两个SafeAreaType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SafeAreaType](#enum-safeareatype)|是|-|要比较的另一个SafeAreaType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SafeAreaEdge

```cangjie
public enum SafeAreaEdge <: Equatable<SafeAreaEdge> {
    | Top
    | Bottom
    | Start
    | End
    | ...
}
```

**功能：** 扩展安全区域的方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SafeAreaEdge](#enum-safeareaedge)>

### Top

```cangjie
Top
```

**功能：** 上方区域。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Bottom

```cangjie
Bottom
```

**功能：** 下方区域。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Start

```cangjie
Start
```

**功能：** 前部区域。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### End

```cangjie
End
```

**功能：** 尾部区域。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SafeAreaEdge)

```cangjie
public operator func ==(other: SafeAreaEdge): Bool
```

**功能：** 判断两个SafeAreaEdge枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SafeAreaEdge](#enum-safeareaedge)|是|-|要比较的另一个SafeAreaEdge枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SafeAreaEdge)

```cangjie
public operator func !=(other: SafeAreaEdge): Bool
```

**功能：** 判断两个SafeAreaEdge枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SafeAreaEdge](#enum-safeareaedge)|是|-|要比较的另一个SafeAreaEdge枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ColoringStrategy

```cangjie
public enum ColoringStrategy <: Equatable<ColoringStrategy> {
    | Invert
    | ...
}
```

**功能：** 智能取色枚举类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ColoringStrategy](#enum-coloringstrategy)>

### Invert

```cangjie
Invert
```

**功能：** 设置前景色为控件背景色的反色。仅支持在foregroundColor中设置该枚举。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ColoringStrategy)

```cangjie
public operator func ==(other: ColoringStrategy): Bool
```

**功能：** 判断两个ColoringStrategy枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ColoringStrategy](#enum-coloringstrategy)|是|-|要比较的另一个ColoringStrategy枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ColoringStrategy)

```cangjie
public operator func !=(other: ColoringStrategy): Bool
```

**功能：** 判断两个ColoringStrategy枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ColoringStrategy](#enum-coloringstrategy)|是|-|要比较的另一个ColoringStrategy枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum NestedScrollMode

```cangjie
public enum NestedScrollMode <: Equatable<NestedScrollMode> {
    | SelfOnly
    | SelfFirst
    | ParentFirst
    | Parallel
    | ...
}
```

**功能：** 可滚动组件往末尾端滚动时的嵌套滚动选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[NestedScrollMode](#enum-nestedscrollmode)>

### SelfOnly

```cangjie
SelfOnly
```

**功能：** 只自身滚动，不与父组件联动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### SelfFirst

```cangjie
SelfFirst
```

**功能：** 自身先滚动，自身滚动到边缘以后父组件滚动。父组件滚动到边缘以后，如果父组件有边缘效果，则父组件触发边缘效果，否则子组件触发边缘效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ParentFirst

```cangjie
ParentFirst
```

**功能：** 父组件先滚动，父组件滚动到边缘以后自身滚动。自身滚动到边缘后，如果有边缘效果，会触发自身的边缘效果，否则触发父组件的边缘效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Parallel

```cangjie
Parallel
```

**功能：** 自身和父组件同时滚动，自身和父组件都到达边缘以后，如果自身有边缘效果，则自身触发边缘效果，否则父组件触发边缘效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(NestedScrollMode)

```cangjie
public operator func ==(other: NestedScrollMode): Bool
```

**功能：** 判断两个NestedScrollMode枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[NestedScrollMode](#enum-nestedscrollmode)|是|-|要比较的另一个NestedScrollMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(NestedScrollMode)

```cangjie
public operator func !=(other: NestedScrollMode): Bool
```

**功能：** 判断两个NestedScrollMode枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[NestedScrollMode](#enum-nestedscrollmode)|是|-|要比较的另一个NestedScrollMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ThemeColorMode

```cangjie
public enum ThemeColorMode <: Equatable<ThemeColorMode> {
    | System
    | Light
    | Dark
    | ...
}
```

**功能：** 主题颜色模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ThemeColorMode](#enum-themecolormode)>

### System

```cangjie
System
```

**功能：** 跟随系统深浅色模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Light

```cangjie
Light
```

**功能：** 固定使用浅色模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Dark

```cangjie
Dark
```

**功能：** 固定使用深色模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ThemeColorMode)

```cangjie
public operator func ==(other: ThemeColorMode): Bool
```

**功能：** 判断两个ThemeColorMode枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ThemeColorMode](#enum-themecolormode)|是|-|要比较的另一个ThemeColorMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ThemeColorMode)

```cangjie
public operator func !=(other: ThemeColorMode): Bool
```

**功能：** 判断两个ThemeColorMode枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ThemeColorMode](#enum-themecolormode)|是|-|要比较的另一个ThemeColorMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum AdaptiveColor

```cangjie
public enum AdaptiveColor <: Equatable<AdaptiveColor> {
    | Default
    | Average
    | ...
}
```

**功能：** 取色模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[AdaptiveColor](#enum-adaptivecolor)>

### Default

```cangjie
Default
```

**功能：** 不使用取色模糊。使用默认的颜色作为蒙版颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Average

```cangjie
Average
```

**功能：** 使用取色模糊。将取色区域的颜色平均值作为蒙版颜色。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(AdaptiveColor)

```cangjie
public operator func ==(other: AdaptiveColor): Bool
```

**功能：** 判断两个AdaptiveColor枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AdaptiveColor](#enum-adaptivecolor)|是|-|要比较的另一个AdaptiveColor枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(AdaptiveColor)

```cangjie
public operator func !=(other: AdaptiveColor): Bool
```

**功能：** 判断两个AdaptiveColor枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AdaptiveColor](#enum-adaptivecolor)|是|-|要比较的另一个AdaptiveColor枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ControlSize

```cangjie
public enum ControlSize <: Equatable<ControlSize> {
    | Small
    | Normal
    | ...
}
```

**功能：** 控制尺寸大小。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ControlSize](#enum-controlsize)>

### Small

```cangjie
Small
```

**功能：** 小尺寸。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Normal

```cangjie
Normal
```

**功能：** 正常尺寸。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ControlSize)

```cangjie
public operator func ==(other: ControlSize): Bool
```

**功能：** 判断两个ControlSize枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ControlSize](#enum-controlsize)|是|-|要比较的另一个ControlSize枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ControlSize)

```cangjie
public operator func !=(other: ControlSize): Bool
```

**功能：** 判断两个ControlSize枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ControlSize](#enum-controlsize)|是|-|要比较的另一个ControlSize枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum OptionWidthMode

```cangjie
public enum OptionWidthMode <: Equatable<OptionWidthMode> {
    | FitContent
    | FitTrigger
    | ...
}
```

**功能：** 下拉菜单宽度设置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[OptionWidthMode](#enum-optionwidthmode)>

### FitContent

```cangjie
FitContent
```

**功能：** 设置该值时，下拉菜单宽度按默认2栅格显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### FitTrigger

```cangjie
FitTrigger
```

**功能：** 设置下拉菜单继承下拉按钮宽度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(OptionWidthMode)

```cangjie
public operator func ==(other: OptionWidthMode): Bool
```

**功能：** 判断两个OptionWidthMode枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[OptionWidthMode](#enum-optionwidthmode)|是|-|要比较的另一个OptionWidthMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(OptionWidthMode)

```cangjie
public operator func !=(other: OptionWidthMode): Bool
```

**功能：** 判断两个OptionWidthMode枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[OptionWidthMode](#enum-optionwidthmode)|是|-|要比较的另一个OptionWidthMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ArrowPosition

```cangjie
public enum ArrowPosition <: Equatable<ArrowPosition> {
    | End
    | Start
    | ...
}
```

**功能：** 下拉菜单项的文本与箭头之间的对齐方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ArrowPosition](#enum-arrowposition)>

### End

```cangjie
End
```

**功能：** 文字在前，箭头在后。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Start

```cangjie
Start
```

**功能：** 箭头在前，文字在后。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ArrowPosition)

```cangjie
public operator func ==(other: ArrowPosition): Bool
```

**功能：** 判断两个ArrowPosition枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ArrowPosition](#enum-arrowposition)|是|-|要比较的另一个ArrowPosition枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ArrowPosition)

```cangjie
public operator func !=(other: ArrowPosition): Bool
```

**功能：** 判断两个ArrowPosition枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ArrowPosition](#enum-arrowposition)|是|-|要比较的另一个ArrowPosition枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum MenuAlignType

```cangjie
public enum MenuAlignType <: Equatable<MenuAlignType> {
    | Start
    | Center
    | End
    | ...
}
```

**功能：** 菜单对齐类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[MenuAlignType](#enum-menualigntype)>

### Start

```cangjie
Start
```

**功能：** 按照语言方向起始端对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Center

```cangjie
Center
```

**功能：** 居中对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### End

```cangjie
End
```

**功能：** 按照语言方向末端对齐。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(MenuAlignType)

```cangjie
public operator func ==(other: MenuAlignType): Bool
```

**功能：** 判断两个MenuAlignType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MenuAlignType](#enum-menualigntype)|是|-|要比较的另一个MenuAlignType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(MenuAlignType)

```cangjie
public operator func !=(other: MenuAlignType): Bool
```

**功能：** 判断两个MenuAlignType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MenuAlignType](#enum-menualigntype)|是|-|要比较的另一个MenuAlignType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum WebDarkMode

```cangjie
public enum WebDarkMode <: Equatable<WebDarkMode> {
    | Off
    | On
    | Auto
    | ...
}
```

**功能：** Web的深色模式，默认关闭。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**父类型：**

- Equatable\<[WebDarkMode](#enum-webdarkmode)>

### Off

```cangjie
Off
```

**功能：** Web的深色模式为关闭。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### On

```cangjie
On
```

**功能：** Web的深色模式为开启。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### Auto

```cangjie
Auto
```

**功能：** Web的深色模式为跟随系统。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

### operator func ==(WebDarkMode)

```cangjie
public operator func ==(other: WebDarkMode): Bool
```

**功能：** 判断两个WebDarkMode枚举是否相等。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WebDarkMode](#enum-webdarkmode)|是|-|要比较的另一个WebDarkMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(WebDarkMode)

```cangjie
public operator func !=(other: WebDarkMode): Bool
```

**功能：** 判断两个WebDarkMode枚举是否不相等。

**系统能力：** SystemCapability.Web.Webview.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WebDarkMode](#enum-webdarkmode)|是|-|要比较的另一个WebDarkMode枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum SourceTool

```cangjie
public enum SourceTool <: Equatable<SourceTool> {
    | Unknown
    | Finger
    | Pen
    | Mouse
    | Touchpad
    | Joystick
    | ...
}
```

**功能：** 事件输入源

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[SourceTool](#enum-sourcetool)>

### Unknown

```cangjie
Unknown
```

**功能：** 未知输入源。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Finger

```cangjie
Finger
```

**功能：** 手指输入。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Pen

```cangjie
Pen
```

**功能：** 手写笔输入。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Mouse

```cangjie
Mouse
```

**功能：** 鼠标输入。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Touchpad

```cangjie
Touchpad
```

**功能：** 触控板输入。触控板单指输入被视为鼠标输入操作。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Joystick

```cangjie
Joystick
```

**功能：** 手柄输入。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(SourceTool)

```cangjie
public operator func ==(other: SourceTool): Bool
```

**功能：** 判断两个SourceTool枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SourceTool](#enum-sourcetool)|是|-|要比较的另一个SourceTool枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(SourceTool)

```cangjie
public operator func !=(other: SourceTool): Bool
```

**功能：** 判断两个SourceTool枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SourceTool](#enum-sourcetool)|是|-|要比较的另一个SourceTool枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum Repetition

```cangjie
public enum Repetition <: Equatable<Repetition> {
    | Repeat
    | RepeatX
    | RepeatY
    | NoRepeat
    | Clamp
    | Mirror
    | ...
}
```

**功能：** 设置图像重复的方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[Repetition](#enum-repetition)>

### Repeat

```cangjie
Repeat
```

**功能：** 沿x轴和y轴重复绘制图像。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### RepeatX

```cangjie
RepeatX
```

**功能：** 沿x轴重复绘制图像。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### RepeatY

```cangjie
RepeatY
```

**功能：** 沿y轴重复绘制图像。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### NoRepeat

```cangjie
NoRepeat
```

**功能：** 不重复绘制图像。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Clamp

```cangjie
Clamp
```

**功能：** 在原始边界外绘制时，超出部分使用边缘的颜色绘制。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Mirror

```cangjie
Mirror
```

**功能：** 沿x轴和y轴重复翻转绘制图像。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(Repetition)

```cangjie
public operator func ==(other: Repetition): Bool
```

**功能：** 判断两个Repetition枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Repetition](#enum-repetition)|是|-|要比较的另一个Repetition枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(Repetition)

```cangjie
public operator func !=(other: Repetition): Bool
```

**功能：** 判断两个Repetition枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[Repetition](#enum-repetition)|是|-|要比较的另一个Repetition枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ScrollSource

```cangjie
public enum ScrollSource <: Equatable<ScrollSource> {
    | Drag
    | Fling
    | EdgeEffect
    | OtherUserInput
    | ScrollBar
    | ScrollBarFling
    | Scroller
    | ScrollerAnimation
    | ...
}
```

**功能：** 滑动操作的来源。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ScrollSource](#enum-scrollsource)>

### Drag

```cangjie
Drag
```

**功能：** 拖拽事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Fling

```cangjie
Fling
```

**功能：** 拖拽结束之后的惯性滑动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### EdgeEffect

```cangjie
EdgeEffect
```

**功能：** EdgeEffect.Spring的边缘滚动效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### OtherUserInput

```cangjie
OtherUserInput
```

**功能：** 除拖拽外的其他用户输入，如鼠标滚轮、键盘事件等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ScrollBar

```cangjie
ScrollBar
```

**功能：** 滚动条的拖拽事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ScrollBarFling

```cangjie
ScrollBarFling
```

**功能：** 滚动条拖拽结束后的带速度的惯性滑动。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Scroller

```cangjie
Scroller
```

**功能：** Scroller的不带动效方法。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ScrollerAnimation

```cangjie
ScrollerAnimation
```

**功能：** Scroller的带动效方法。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ScrollSource)

```cangjie
public operator func ==(other: ScrollSource): Bool
```

**功能：** 判断两个ScrollSource枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScrollSource](#enum-scrollsource)|是|-|要比较的另一个ScrollSource枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ScrollSource)

```cangjie
public operator func !=(other: ScrollSource): Bool
```

**功能：** 判断两个ScrollSource枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScrollSource](#enum-scrollsource)|是|-|要比较的另一个ScrollSource枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ContentType

```cangjie
public enum ContentType <: Equatable<ContentType> {
    | UserName
    | Password
    | NewPassword
    | FullStreetAddress
    | HouseNumber
    | DistrictAddress
    | CityAddress
    | ProvinceAddress
    | CountryAddress
    | PersonFullName
    | PersonLastName
    | PersonFirstName
    | PhoneNumber
    | PhoneCountryCode
    | FullPhoneNumber
    | EmailAddress
    | BankCardNumber
    | IdCardNumber
    | Nickname
    | DetailInfoWithoutStreet
    | FormatAddress
    | ...
}
```

**功能：** 自动填充类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ContentType](#enum-contenttype)>

### UserName

```cangjie
UserName
```

**功能：** 【用户名】在已启用情景化自动填充的情况下，支持用户名的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Password

```cangjie
Password
```

**功能：** 【密码】在已启用密码保险箱的情况下，支持密码的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### NewPassword

```cangjie
NewPassword
```

**功能：** 【新密码】在已启用密码保险箱的情况下，支持自动生成新密码。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### FullStreetAddress

```cangjie
FullStreetAddress
```

**功能：** 【详细地址】在已启用情景化自动填充的情况下，支持详细地址的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### HouseNumber

```cangjie
HouseNumber
```

**功能：** 【门牌号】在已启用情景化自动填充的情况下，支持门牌号的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### DistrictAddress

```cangjie
DistrictAddress
```

**功能：** 【区/县】在已启用情景化自动填充的情况下，支持区/县的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### CityAddress

```cangjie
CityAddress
```

**功能：** 【市】在已启用情景化自动填充的情况下，支持市的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ProvinceAddress

```cangjie
ProvinceAddress
```

**功能：** 【省】在已启用情景化自动填充的情况下，支持省的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### CountryAddress

```cangjie
CountryAddress
```

**功能：** 【国家】在已启用情景化自动填充的情况下，支持国家的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### PersonFullName

```cangjie
PersonFullName
```

**功能：** 【姓名】在已启用情景化自动填充的情况下，支持姓名的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### PersonLastName

```cangjie
PersonLastName
```

**功能：** 【姓氏】在已启用情景化自动填充的情况下，支持姓氏的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### PersonFirstName

```cangjie
PersonFirstName
```

**功能：** 【名字】在已启用情景化自动填充的情况下，支持名字的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### PhoneNumber

```cangjie
PhoneNumber
```

**功能：** 【手机号码】在已启用情景化自动填充的情况下，支持手机号码的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### PhoneCountryCode

```cangjie
PhoneCountryCode
```

**功能：** 【国家代码】在已启用情景化自动填充的情况下，支持国家代码的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### FullPhoneNumber

```cangjie
FullPhoneNumber
```

**功能：** 【包含国家代码的手机号码】在已启用情景化自动填充的情况下，支持包含国家代码的手机号码的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### EmailAddress

```cangjie
EmailAddress
```

**功能：** 【邮箱地址】在已启用情景化自动填充的情况下，支持邮箱地址的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BankCardNumber

```cangjie
BankCardNumber
```

**功能：** 【银行卡号】在已启用情景化自动填充的情况下，支持银行卡号的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### IdCardNumber

```cangjie
IdCardNumber
```

**功能：** 【身份证号】在已启用情景化自动填充的情况下，支持身份证号的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Nickname

```cangjie
Nickname
```

**功能：** 【昵称】在已启用情景化自动填充的情况下，支持昵称的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### DetailInfoWithoutStreet

```cangjie
DetailInfoWithoutStreet
```

**功能：** 【无街道地址】在已启用情景化自动填充的情况下，支持无街道地址的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### FormatAddress

```cangjie
FormatAddress
```

**功能：** 【标准地址】在已启用情景化自动填充的情况下，支持标准地址的自动保存和自动填充。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ContentType)

```cangjie
public operator func ==(other: ContentType): Bool
```

**功能：** 判断两个ContentType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ContentType](#enum-contenttype)|是|-|要比较的另一个ContentType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ContentType)

```cangjie
public operator func !=(other: ContentType): Bool
```

**功能：** 判断两个ContentType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ContentType](#enum-contenttype)|是|-|要比较的另一个ContentType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum MenuPolicy

```cangjie
public enum MenuPolicy <: Equatable<MenuPolicy> {
    | Default
    | Hide
    | Show
    | ...
}
```

**功能：** 菜单弹出的策略。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[MenuPolicy](#enum-menupolicy)>

### Default

```cangjie
Default
```

**功能：** 按照底层默认逻辑决定是否弹出菜单。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Hide

```cangjie
Hide
```

**功能：** 始终不弹出菜单。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Show

```cangjie
Show
```

**功能：** 始终弹出菜单。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(MenuPolicy)

```cangjie
public operator func ==(other: MenuPolicy): Bool
```

**功能：** 判断两个MenuPolicy枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MenuPolicy](#enum-menupolicy)|是|-|要比较的另一个MenuPolicy枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(MenuPolicy)

```cangjie
public operator func !=(other: MenuPolicy): Bool
```

**功能：** 判断两个MenuPolicy枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MenuPolicy](#enum-menupolicy)|是|-|要比较的另一个MenuPolicy枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum TextDecorationStyle

```cangjie
public enum TextDecorationStyle <: Equatable<TextDecorationStyle> {
    | Solid
    | Double
    | Dotted
    | Dashed
    | Wavy
    | ...
}
```

**功能：** 设置文本装饰线样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[TextDecorationStyle](#enum-textdecorationstyle)>

### Solid

```cangjie
Solid
```

**功能：** 单实线（默认值）。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Double

```cangjie
Double
```

**功能：** 双实线。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Dotted

```cangjie
Dotted
```

**功能：** 点线。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Dashed

```cangjie
Dashed
```

**功能：** 虚线。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Wavy

```cangjie
Wavy
```

**功能：** 波浪线。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(TextDecorationStyle)

```cangjie
public operator func ==(other: TextDecorationStyle): Bool
```

**功能：** 判断两个TextDecorationStyle枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextDecorationStyle](#enum-textdecorationstyle)|是|-|要比较的另一个TextDecorationStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(TextDecorationStyle)

```cangjie
public operator func !=(other: TextDecorationStyle): Bool
```

**功能：** 判断两个TextDecorationStyle枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextDecorationStyle](#enum-textdecorationstyle)|是|-|要比较的另一个TextDecorationStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum LineBreakStrategy

```cangjie
public enum LineBreakStrategy <: Equatable<LineBreakStrategy> {
    | Greedy
    | HighQuality
    | Balanced
    | ...
}
```

**功能：** 文本的折行规则。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[LineBreakStrategy](#enum-linebreakstrategy)>

### Greedy

```cangjie
Greedy
```

**功能：** 使每一行尽量显示多的字符，直到这一行不能显示更多字符再进行折行。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### HighQuality

```cangjie
HighQuality
```

**功能：** 在BALANCED的基础上，尽可能填满行，在最后一行的权重上比较低，可能会出现最后一行留白比较多。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Balanced

```cangjie
Balanced
```

**功能：** 尽可能保证在不拆词的情况下，使一个段落中每一行的宽度相同。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(LineBreakStrategy)

```cangjie
public operator func ==(other: LineBreakStrategy): Bool
```

**功能：** 判断两个LineBreakStrategy枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[LineBreakStrategy](#enum-linebreakstrategy)|是|-|要比较的另一个LineBreakStrategy枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(LineBreakStrategy)

```cangjie
public operator func !=(other: LineBreakStrategy): Bool
```

**功能：** 判断两个LineBreakStrategy枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[LineBreakStrategy](#enum-linebreakstrategy)|是|-|要比较的另一个LineBreakStrategy枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum TextContentStyle

```cangjie
public enum TextContentStyle <: Equatable<TextContentStyle> {
    | Default
    | Inline
    | ...
}
```

**功能：** 文本框多态样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[TextContentStyle](#enum-textcontentstyle)>

### Default

```cangjie
Default
```

**功能：** 默认风格，光标宽1.5vp，光标高度与文本选中底板高度和字体大小相关。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Inline

```cangjie
Inline
```

**功能：** 内联输入风格。文本选中底板高度与输入框高度相同。
内联输入是在有明显的编辑态/非编辑态的区分场景下使用，例如：文件列表视图中的重命名。
不支持showError属性。
内联模式下，不支持拖入文本。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(TextContentStyle)

```cangjie
public operator func ==(other: TextContentStyle): Bool
```

**功能：** 判断两个TextContentStyle枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextContentStyle](#enum-textcontentstyle)|是|-|要比较的另一个TextContentStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(TextContentStyle)

```cangjie
public operator func !=(other: TextContentStyle): Bool
```

**功能：** 判断两个TextContentStyle枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextContentStyle](#enum-textcontentstyle)|是|-|要比较的另一个TextContentStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum CheckBoxShape

```cangjie
public enum CheckBoxShape <: Equatable<CheckBoxShape> {
    | Circle
    | RoundedSquare
    | ...
}
```

**功能：** 多选框形状类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[CheckBoxShape](#enum-checkboxshape)>

### Circle

```cangjie
Circle
```

**功能：** 圆形。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### RoundedSquare

```cangjie
RoundedSquare
```

**功能：** 圆角正方形。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(CheckBoxShape)

```cangjie
public operator func ==(other: CheckBoxShape): Bool
```

**功能：** 判断两个CheckBoxShape枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CheckBoxShape](#enum-checkboxshape)|是|-|要比较的另一个CheckBoxShape枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(CheckBoxShape)

```cangjie
public operator func !=(other: CheckBoxShape): Bool
```

**功能：** 判断两个CheckBoxShape枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CheckBoxShape](#enum-checkboxshape)|是|-|要比较的另一个CheckBoxShape枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum TextHeightAdaptivePolicy

```cangjie
public enum TextHeightAdaptivePolicy <: Equatable<TextHeightAdaptivePolicy> {
    | MaxLinesFirst
    | MinFontSizeFirst
    | LayoutConstraintFirst
    | ...
}
```

**功能：** 设置文本高度自适应方式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[TextHeightAdaptivePolicy](#enum-textheightadaptivepolicy)>

### MaxLinesFirst

```cangjie
MaxLinesFirst
```

**功能：** 设置文本高度自适应方式为以MaxLines优先。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### MinFontSizeFirst

```cangjie
MinFontSizeFirst
```

**功能：** 设置文本高度自适应方式为以缩小字体优先。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### LayoutConstraintFirst

```cangjie
LayoutConstraintFirst
```

**功能：** 设置文本高度自适应方式为以布局约束（高度）优先。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(TextHeightAdaptivePolicy)

```cangjie
public operator func ==(other: TextHeightAdaptivePolicy): Bool
```

**功能：** 判断两个TextHeightAdaptivePolicy枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextHeightAdaptivePolicy](#enum-textheightadaptivepolicy)|是|-|要比较的另一个TextHeightAdaptivePolicy枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(TextHeightAdaptivePolicy)

```cangjie
public operator func !=(other: TextHeightAdaptivePolicy): Bool
```

**功能：** 判断两个TextHeightAdaptivePolicy枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextHeightAdaptivePolicy](#enum-textheightadaptivepolicy)|是|-|要比较的另一个TextHeightAdaptivePolicy枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum ArrowPointPosition

```cangjie
public enum ArrowPointPosition <: Equatable<ArrowPointPosition> {
    | Start
    | Center
    | End
    | ...
}
```

**功能：** 箭头指向位置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[ArrowPointPosition](#enum-arrowpointposition)>

### Start

```cangjie
Start
```

**功能：** 水平方向：位于父组件最左侧，垂直方向：位于父组件最上侧。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Center

```cangjie
Center
```

**功能：** 位于父组件居中位置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### End

```cangjie
End
```

**功能：** 水平方向：位于父组件最右侧，垂直方向：位于父组件最下侧。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(ArrowPointPosition)

```cangjie
public operator func ==(other: ArrowPointPosition): Bool
```

**功能：** 判断两个ArrowPointPosition枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ArrowPointPosition](#enum-arrowpointposition)|是|-|要比较的另一个ArrowPointPosition枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(ArrowPointPosition)

```cangjie
public operator func !=(other: ArrowPointPosition): Bool
```

**功能：** 判断两个ArrowPointPosition枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ArrowPointPosition](#enum-arrowpointposition)|是|-|要比较的另一个ArrowPointPosition枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum TitleHeight

```cangjie
public enum TitleHeight <: Equatable<TitleHeight> {
    | MainOnly
    | MainWithSub
    | ...
}
```

**功能：** 设置标题栏高度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[TitleHeight](#enum-titleheight)>

### MainOnly

```cangjie
MainOnly
```

**功能：** 只有主标题时标题栏的推荐高度（56vp）。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### MainWithSub

```cangjie
MainWithSub
```

**功能：** 同时有主标题和副标题时标题栏的推荐高度（82vp）。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(TitleHeight)

```cangjie
public operator func ==(other: TitleHeight): Bool
```

**功能：** 判断两个TitleHeight枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TitleHeight](#enum-titleheight)|是|-|要比较的另一个TitleHeight枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(TitleHeight)

```cangjie
public operator func !=(other: TitleHeight): Bool
```

**功能：** 判断两个TitleHeight枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TitleHeight](#enum-titleheight)|是|-|要比较的另一个TitleHeight枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum DialogButtonStyle

```cangjie
public enum DialogButtonStyle <: Equatable<DialogButtonStyle> {
    | Default
    | Highlight
    | ...
}
```

**功能：** 对话框按钮样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[DialogButtonStyle](#enum-dialogbuttonstyle)>

### Default

```cangjie
Default
```

**功能：** 白底蓝字（深色主题：白底=黑底）。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Highlight

```cangjie
Highlight
```

**功能：** 蓝底白字。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(DialogButtonStyle)

```cangjie
public operator func ==(other: DialogButtonStyle): Bool
```

**功能：** 判断两个DialogButtonStyle枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DialogButtonStyle](#enum-dialogbuttonstyle)|是|-|要比较的另一个DialogButtonStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(DialogButtonStyle)

```cangjie
public operator func !=(other: DialogButtonStyle): Bool
```

**功能：** 判断两个DialogButtonStyle枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DialogButtonStyle](#enum-dialogbuttonstyle)|是|-|要比较的另一个DialogButtonStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum LengthMetricsUnit

```cangjie
public enum LengthMetricsUnit <: Equatable<LengthMetricsUnit> {
    | Default
    | Px
    | ...
}
```

**功能：** 长度度量单位枚举。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[LengthMetricsUnit](#enum-lengthmetricsunit)>

### Default

```cangjie
Default
```

**功能：** 长度类型，用于描述以默认的vp像素单位为单位的长度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Px

```cangjie
Px
```

**功能：** 长度类型，用于描述以px像素单位为单位的长度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(LengthMetricsUnit)

```cangjie
public operator func ==(other: LengthMetricsUnit): Bool
```

**功能：** 判断两个LengthMetricsUnit枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[LengthMetricsUnit](#enum-lengthmetricsunit)|是|-|要比较的另一个LengthMetricsUnit枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(LengthMetricsUnit)

```cangjie
public operator func !=(other: LengthMetricsUnit): Bool
```

**功能：** 判断两个LengthMetricsUnit枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[LengthMetricsUnit](#enum-lengthmetricsunit)|是|-|要比较的另一个LengthMetricsUnit枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum CanvasDirection

```cangjie
public enum CanvasDirection <: Equatable<CanvasDirection> {
    | Inherit
    | Ltr
    | Rtl
    | ...
}
```

**功能：** 设置绘制文字时使用的文字方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[CanvasDirection](#enum-canvasdirection)>

### Inherit

```cangjie
Inherit
```

**功能：** 继承canvas组件通用属性已设定的文本方向。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Ltr

```cangjie
Ltr
```

**功能：** 从左往右。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Rtl

```cangjie
Rtl
```

**功能：** 从右往左。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(CanvasDirection)

```cangjie
public operator func ==(other: CanvasDirection): Bool
```

**功能：** 判断两个CanvasDirection枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CanvasDirection](#enum-canvasdirection)|是|-|要比较的另一个CanvasDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(CanvasDirection)

```cangjie
public operator func !=(other: CanvasDirection): Bool
```

**功能：** 判断两个CanvasDirection枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CanvasDirection](#enum-canvasdirection)|是|-|要比较的另一个CanvasDirection枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum CanvasFillRule

```cangjie
public enum CanvasFillRule <: Equatable<CanvasFillRule> {
    | EvenOdd
    | NonZero
    | ...
}
```

**功能：** 指定要填充对象的规则。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[CanvasFillRule](#enum-canvasfillrule)>

### EvenOdd

```cangjie
EvenOdd
```

**功能：** 奇偶规则。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### NonZero

```cangjie
NonZero
```

**功能：** 非零规则。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(CanvasFillRule)

```cangjie
public operator func ==(other: CanvasFillRule): Bool
```

**功能：** 判断两个CanvasFillRule枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CanvasFillRule](#enum-canvasfillrule)|是|-|要比较的另一个CanvasFillRule枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(CanvasFillRule)

```cangjie
public operator func !=(other: CanvasFillRule): Bool
```

**功能：** 判断两个CanvasFillRule枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CanvasFillRule](#enum-canvasfillrule)|是|-|要比较的另一个CanvasFillRule枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum FinishCallbackType

```cangjie
public enum FinishCallbackType <: Equatable<FinishCallbackType> {
    | Removed
    | Logically
    | ...
}
```

**功能：** 动画结束时的回调类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[FinishCallbackType](#enum-finishcallbacktype)>

### Removed

```cangjie
Removed
```

**功能：** 当整个动画结束并立即删除时，将触发回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Logically

```cangjie
Logically
```

**功能：** 当动画在逻辑上处于下降状态，但可能仍处于其长尾状态时，将触发回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(FinishCallbackType)

```cangjie
public operator func ==(other: FinishCallbackType): Bool
```

**功能：** 判断两个FinishCallbackType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FinishCallbackType](#enum-finishcallbacktype)|是|-|要比较的另一个FinishCallbackType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(FinishCallbackType)

```cangjie
public operator func !=(other: FinishCallbackType): Bool
```

**功能：** 判断两个FinishCallbackType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FinishCallbackType](#enum-finishcallbacktype)|是|-|要比较的另一个FinishCallbackType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum BlurStyle

```cangjie
public enum BlurStyle <: Equatable<BlurStyle> {
    | Thin
    | Regular
    | Thick
    | BackgroundThin
    | BackgroundRegular
    | BackgroundThick
    | BackgroundUltraThick
    | None
    | ComponentUltraThin
    | ComponentThin
    | ComponentRegular
    | ComponentThick
    | ComponentUltraThick
    | ...
}
```

**功能：** 前景模糊样式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[BlurStyle](#enum-blurstyle)>

### Thin

```cangjie
Thin
```

**功能：** 薄模糊效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Regular

```cangjie
Regular
```

**功能：** 普通模糊效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Thick

```cangjie
Thick
```

**功能：** 厚模糊效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BackgroundThin

```cangjie
BackgroundThin
```

**功能：** 近距景深模糊。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BackgroundRegular

```cangjie
BackgroundRegular
```

**功能：** 中距景深模糊。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BackgroundThick

```cangjie
BackgroundThick
```

**功能：** 远距景深模糊。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### BackgroundUltraThick

```cangjie
BackgroundUltraThick
```

**功能：** 超远距景深模糊。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### None

```cangjie
None
```

**功能：** 无模糊效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ComponentUltraThin

```cangjie
ComponentUltraThin
```

**功能：** 组件超薄材质模糊。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ComponentThin

```cangjie
ComponentThin
```

**功能：** 组件轻薄材质模糊。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ComponentRegular

```cangjie
ComponentRegular
```

**功能：** 组件普通材质模糊。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ComponentThick

```cangjie
ComponentThick
```

**功能：** 组件厚材质模糊。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### ComponentUltraThick

```cangjie
ComponentUltraThick
```

**功能：** 组件超厚材质模糊。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(BlurStyle)

```cangjie
public operator func ==(other: BlurStyle): Bool
```

**功能：** 判断两个BlurStyle枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BlurStyle](#enum-blurstyle)|是|-|要比较的另一个BlurStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(BlurStyle)

```cangjie
public operator func !=(other: BlurStyle): Bool
```

**功能：** 判断两个BlurStyle枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BlurStyle](#enum-blurstyle)|是|-|要比较的另一个BlurStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum DismissReason

```cangjie
public enum DismissReason <: Equatable<DismissReason> {
    | PressBack
    | TouchOutside
    | CloseButton
    | SlideDown
    | ...
}
```

**功能：** 弹窗关闭原因。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[DismissReason](#enum-dismissreason)>

### PressBack

```cangjie
PressBack
```

**功能：** 点击三键back、左滑/右滑、键盘ESC。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### TouchOutside

```cangjie
TouchOutside
```

**功能：** 点击遮障层时。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### CloseButton

```cangjie
CloseButton
```

**功能：** 点击了关闭按钮。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### SlideDown

```cangjie
SlideDown
```

**功能：** 下拉关闭。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(DismissReason)

```cangjie
public operator func ==(other: DismissReason): Bool
```

**功能：** 判断两个DismissReason枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DismissReason](#enum-dismissreason)|是|-|要比较的另一个DismissReason枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(DismissReason)

```cangjie
public operator func !=(other: DismissReason): Bool
```

**功能：** 判断两个DismissReason枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DismissReason](#enum-dismissreason)|是|-|要比较的另一个DismissReason枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum TextInputStyle

```cangjie
public enum TextInputStyle <: Equatable<TextInputStyle> {
    | Default
    | Inline
    | ...
}
```

**功能：** 表示输入风格。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[TextInputStyle](#enum-textinputstyle)>

### Default

```cangjie
Default
```

**功能：** 表示默认风格，光标宽1.5.vp，光标高度与文本选中底板高度和字体大小相关。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Inline

```cangjie
Inline
```

**功能：** 表示内联输入风格。文本选中底板高度与输入框高度相同。内联输入适用于需要明显区分编辑状态和非编辑状态的场景，如文件列表视图中的重命名。内联输入不支持`showError`属性，并且在内联模式下不支持拖入文本功能。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(TextInputStyle)

```cangjie
public operator func ==(other: TextInputStyle): Bool
```

**功能：** 判断两个TextInputStyle枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextInputStyle](#enum-textinputstyle)|是|-|要比较的另一个TextInputStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(TextInputStyle)

```cangjie
public operator func !=(other: TextInputStyle): Bool
```

**功能：** 判断两个TextInputStyle枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextInputStyle](#enum-textinputstyle)|是|-|要比较的另一个TextInputStyle枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## enum TextAreaType

```cangjie
public enum TextAreaType <: Equatable<TextAreaType> {
    | Normal
    | Number
    | PhoneNumber
    | Email
    | NumberDecimal
    | Url
    | ...
}
```

**功能：** 表示输入框类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[TextAreaType](#enum-textareatype)>

### Normal

```cangjie
Normal
```

**功能：** 表示基本输入模式。支持输入数字、字母、下划线、空格、特殊字符。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Number

```cangjie
Number
```

**功能：** 表示纯数字输入模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### PhoneNumber

```cangjie
PhoneNumber
```

**功能：** 表示电话号码输入模式。支持输入数字、空格、+ 、-、*、#、(、)，长度不限。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Email

```cangjie
Email
```

**功能：** 表示邮箱地址输入模式。支持数字，字母，下划线、小数点、!、#、$、%、&、'、*、+、-、/、=、?、^、`、{、|、}、~，以及@字符（只能存在一个@字符）。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### NumberDecimal

```cangjie
NumberDecimal
```

**功能：** 表示带小数点的数字输入模式。支持数字、小数点（只能存在一个小数点）。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Url

```cangjie
Url
```

**功能：** 表示带URL的输入模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func ==(TextAreaType)

```cangjie
public operator func ==(other: TextAreaType): Bool
```

**功能：** 判断两个TextAreaType枚举是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextAreaType](#enum-textareatype)|是|-|要比较的另一个TextAreaType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举相等则返回true，否则返回false。|

### operator func !=(TextAreaType)

```cangjie
public operator func !=(other: TextAreaType): Bool
```

**功能：** 判断两个TextAreaType枚举是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TextAreaType](#enum-textareatype)|是|-|要比较的另一个TextAreaType枚举。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举不相等则返回true，否则返回false。|

## type VoidCallback

```cangjie
public type VoidCallback = () -> Unit
```

**功能：** [VoidCallback](#type-voidcallback)是[() -> Unit](#type-voidcallback)类型的别名。

**类型：** () -> Unit

## type Callback\<T, V>

```cangjie
public type Callback<T, V> = (T) -> V
```

**功能：** Callback\<T, V>是(T) -> V类型的别名。

**类型：** (T) -> V

## type CustomBuilder

```cangjie
public type CustomBuilder = () -> Unit
```

**功能：** CustomBuilder是() -> Unit类型的别名。

**类型：** () -> Unit

## type TransitionFinishCallback

```cangjie
public type TransitionFinishCallback = (Bool) -> Unit
```

**功能：** [TransitionFinishCallback](#type-transitionfinishcallback)是(Bool) -> Unit类型的别名。

**类型：** (Bool) -> Unit

## type ItemGeneratorFunc\<T>

```cangjie
public type ItemGeneratorFunc<T> = (T, Int64) -> Unit
```

**功能：** 定义Item生成器函数。

**类型：** (T, Int64) -> Unit

## type KeyGeneratorFunc\<T>

```cangjie
public type KeyGeneratorFunc<T> = (T, Int64) -> String
```

**功能：** 定义键生成器函数。

**类型：** (T, Int64) -> String
