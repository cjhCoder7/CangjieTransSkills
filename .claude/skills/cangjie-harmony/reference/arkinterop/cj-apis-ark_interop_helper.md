# ohos.ark_interop_helper（ArkTS互操作公共辅助功能函数）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

提供数据类型转换和互操作相关的公共辅助功能函数，包括JSValue到napi_value的转换、HashMap与JSValue之间的格式转换等工具函数。

## 导入模块

```cangjie
import ohos.ark_interop_helper.*
```

> **说明：**
>
> 当前暂不支持Kit化的导入方式，预计在下个版本支持。

## func arktsValuetoNapiValue(napi_env, JSValue)

```cangjie
public func arktsValuetoNapiValue(env: napi_env, ark_value: JSValue): napi_value
```

**功能：** 将 JSValue 类型转化为 napi_value 类型。

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|env|[napi_env](cj-apis-ark_interop.md#type-napi_env)|是|-|环境上下文。|
|ark_value|[JSValue](cj-apis-ark_interop.md#class-jsvalue)|是|-|需要转换的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[napi_value](cj-apis-ark_interop.md#type-napi_value)|转化的 napi_value 值。|

## func isStageMode(napi_env, napi_value)

```cangjie
public func isStageMode(env: napi_env, context: napi_value): Bool
```

**功能：** 判断是否处于应用模式。

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|env|[napi_env](cj-apis-ark_interop.md#type-napi_env)|是|-|环境信息。|
|context|[napi_value](cj-apis-ark_interop.md#type-napi_value)|是|-|上下文信息。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|是否处于应用模式。|

## func mapFromJSValue\<T>(JSContext, JSValue, (JSContext,JSValue) -> T)

```cangjie
public func mapFromJSValue<T>(
    context: JSContext,
    value: JSValue,
    convert: (JSContext, JSValue) -> T
): ?HashMap<String, T>
```

**功能：** 把 JSValue 格式的数据转换成 HashMap 。

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|[JSContext](cj-apis-ark_interop.md#class-jscontext)|是|-|互操作上下文。|
|value|[JSValue](cj-apis-ark_interop.md#class-jsvalue)|是|-|需要转换的 JSValue 数据。|
|convert|([JSContext](cj-apis-ark_interop.md#class-jscontext), [JSValue](cj-apis-ark_interop.md#class-jsvalue))->T|是|-|把 JSValue 当作一个 HashMap 后，获取这个 HashMap 的 key 对应的 value 转换成 T。|

**返回值：**

|类型|说明|
|:----|:----|
|?HashMap\<String, T>|转换后的 HashMap 数据。|

## func mapToJSValue\<T>(JSContext, ?HashMap\<String,T>, (JSContext,T) -> JSValue)

```cangjie
public func mapToJSValue<T>(
    context: JSContext,
    parameter: ?HashMap<String, T>,
    convert: (JSContext, T) -> JSValue
): JSValue
```

**功能：** 把 HashMap 格式的数据转换成 JSValue 。

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|[JSContext](cj-apis-ark_interop.md#class-jscontext)|是|-|互操作上下文。|
|parameter|?HashMap\<String, T>|是|-|需要转换的 HashMap 数据。|
|convert|([JSContext](cj-apis-ark_interop.md#class-jscontext), T)->[JSValue](cj-apis-ark_interop.md#class-jsvalue)|是|-|把 HashMap 的 T 转换成 JSValue。|

**返回值：**

|类型|说明|
|:----|:----|
|[JSValue](cj-apis-ark_interop.md#class-jsvalue)|转换后的 JSValue 数据。|
