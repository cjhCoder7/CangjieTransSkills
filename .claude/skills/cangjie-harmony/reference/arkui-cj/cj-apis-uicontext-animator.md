# AnimatorResult

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

提供组件动画Animator的结果，包括启动动画、重置动画参数和以相反的顺序播放动画等。

> **说明：**
>
> 以下API需先使用[UIContext](./cj-apis-uicontext-uicontext.md#class-uicontext)中的[createAnimator()](./cj-apis-uicontext-uicontext.md#func-createanimatoranimatoroptions)方法创建AnimatorResult对象，再通过该对象调用对应方法。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## class AnimatorResult

```cangjie
public class AnimatorResult {
}
```

**功能：** 定义Animator结果类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### prop onFrame

```cangjie
public mut prop onFrame: (Float64) -> Unit
```

**功能：** 接收到帧时回调。

**类型：** (Float64) -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码ID|错误信息|
  |:----|:---|
  |100001|Internal error. Possible causes: The specified page is not found or the object property list is not obtained.|

### prop onFinish

```cangjie
public mut prop onFinish: () -> Unit
```

**功能：** 动画完成时回调。

**类型：** () -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码ID|错误信息|
  |:----|:---|
  |100001|Internal error. Possible causes: The specified page is not found or the object property list is not obtained.|

### prop onCancel

```cangjie
public mut prop onCancel: () -> Unit
```

**功能：** 动画被取消时回调。

**类型：** () -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码ID|错误信息|
  |:----|:---|
  |100001|Internal error. Possible causes: The specified page is not found or the object property list is not obtained.|

### prop onRepeat

```cangjie
public mut prop onRepeat: () -> Unit
```

**功能：** 动画重复时回调。

**类型：** () -> Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码ID|错误信息|
  |:----|:---|
  |100001|Internal error. Possible causes: The specified page is not found or the object property list is not obtained.|

### func reset(AnimatorOptions)

```cangjie
public func reset(options: AnimatorOptions): Unit
```

**功能：** 重置当前animator动画参数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|options|[AnimatorOptions](#class-animatoroptions)|是|-|动画选项。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码ID|错误信息|
  |:----|:---|
  |100001|Internal error. Possible causes: The specified page is not found or the object property list is not obtained.|

### func play()

```cangjie
public func play(): Unit
```

**功能：** 启动动画。动画会保留上一次的播放状态，比如播放状态设置reverse后，再次播放会保留reverse的播放状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码ID|错误信息|
  |:----|:---|
  |100001|Internal error. Possible causes: The specified page is not found or the object property list is not obtained.|

### func finish()

```cangjie
public func finish(): Unit
```

**功能：** 结束动画，会触发[onFinish](#prop-onfinish)回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码ID|错误信息|
  |:----|:---|
  |100001|Internal error. Possible causes: The specified page is not found or the object property list is not obtained.|

### func pause()

```cangjie
public func pause(): Unit
```

**功能：** 暂停动画。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码ID|错误信息|
  |:----|:---|
  |100001|Internal error. Possible causes: The specified page is not found or the object property list is not obtained.|

### func cancel()

```cangjie
public func cancel(): Unit
```

**功能：** 取消动画，会触发[onCancel](#prop-oncancel)回调。此接口和[finish](#func-finish)接口功能上没有区别，仅触发的回调不同，建议使用[finish](#func-finish)接口结束动画。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码ID|错误信息|
  |:----|:---|
  |100001|Internal error. Possible causes: The specified page is not found or the object property list is not obtained.|

### func reverse()

```cangjie
public func reverse(): Unit
```

**功能：** 以相反的顺序播放动画。使用interpolating-spring曲线时此接口无效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码ID|错误信息|
  |:----|:---|
  |100001|Internal error. Possible causes: The specified page is not found or the object property list is not obtained.|

### func setExpectedFrameRateRange(ExpectedFrameRateRange)

```cangjie
public func setExpectedFrameRateRange(rateRange: ExpectedFrameRateRange): Unit
```

**功能：** 设置期望的帧率范围。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|rateRange|[ExpectedFrameRateRange](./cj-common-types.md#class-expectedframeraterange)|是|-|帧率范围。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  |错误码ID|错误信息|
  |:----|:---|
  |100001|Internal error. Possible causes: The specified page is not found or the object property list is not obtained.|

## class AnimatorOptions

```cangjie
public class AnimatorOptions {
    public var duration: Int32
    public var easing: String
    public var delay: Int32
    public var fill: AnimatorFill
    public var direction: AnimatorDirection
    public var iterations: Int32
    public var begin: Float64
    public var end: Float64
    public init(
        duration!: Int32,
        easing!: String,
        delay!: Int32,
        fill!: AnimatorFill,
        direction!: AnimatorDirection,
        iterations!: Int32,
        begin!: Float64,
        end!: Float64
    )
}
```

**功能：** 定义动画选项。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var duration

```cangjie
public var duration: Int32
```

**功能：** 动画播放的时长，单位毫秒。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var easing

```cangjie
public var easing: String
```

**功能：** 动画插值曲线。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var delay

```cangjie
public var delay: Int32
```

**功能：** 动画延时播放时长，单位毫秒。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var fill

```cangjie
public var fill: AnimatorFill
```

**功能：** 动画执行后是否恢复到初始状态，动画执行后，动画结束时的状态（在最后一个关键帧中定义）将保留。

**类型：** [AnimatorFill](#enum-animatorfill)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var direction

```cangjie
public var direction: AnimatorDirection
```

**功能：** 动画播放模式。

**类型：** [AnimatorDirection](#enum-animatordirection)

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var iterations

```cangjie
public var iterations: Int32
```

**功能：** 动画播放次数。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var begin

```cangjie
public var begin: Float64
```

**功能：** 动画插值起点。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### var end

```cangjie
public var end: Float64
```

**功能：** 动画插值终点。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(Int32, String, Int32, AnimatorFill, AnimatorDirection, Int32, Float64, Float64)

```cangjie
public init(
    duration!: Int32,
    easing!: String,
    delay!: Int32,
    fill!: AnimatorFill,
    direction!: AnimatorDirection,
    iterations!: Int32,
    begin!: Float64,
    end!: Float64
)
```

**功能：** 创建AnimatorOptions对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|duration|Int32|是|-|**命名参数。** 动画播放的时长，单位毫秒。取值范围：[0, +∞)。|
|easing|String|是|-|**命名参数。** 动画插值曲线。|
|delay|Int32|是|-|**命名参数。** 动画延时播放时长，单位毫秒，设置为0时，表示不延时。设置为负数时动画提前播放，如果提前播放的时长大于动画总时长，动画直接过渡到终点。|
|fill|[AnimatorFill](#enum-animatorfill)|是|-|**命名参数。** 动画执行后是否恢复到初始状态，动画执行后，动画结束时的状态（在最后一个关键帧中定义）将保留。|
|direction|[AnimatorDirection](#enum-animatordirection)|是|-|**命名参数。** 动画播放模式。|
|iterations|Int32|是|-|**命名参数。** 动画播放次数。设置为0时不播放，设置为-1时无限次播放，设置大于0时为播放次数。|
|begin|Float64|是|-|**命名参数。** 动画插值起点。|
|end|Float64|是|-|**命名参数。** 动画插值终点。|

## enum AnimatorFill

```cangjie
public enum AnimatorFill <: Equatable<AnimatorFill> {
    | None
    | Forwards
    | Backwards
    | Both
    | ...
}
```

**功能：** 动画执行后的状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[AnimatorFill](#enum-animatorfill)>

### None

```cangjie
None
```

**功能：** 在动画执行之前和之后都不会应用任何样式到目标上。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Forwards

```cangjie
Forwards
```

**功能：** 在动画结束后，目标将保留动画结束时的状态（在最后一个关键帧中定义）。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Backwards

```cangjie
Backwards
```

**功能：** 动画将在[AnimatorOptions](#class-animatoroptions)中的delay期间应用第一个关键帧中定义的值。当[AnimatorOptions](#class-animatoroptions)中的direction为Normal或Alternate时应用from关键帧中的值，当[AnimatorOptions](#class-animatoroptions)中的direction为Reverse或AlternateReverse时应用to关键帧中的值。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Both

```cangjie
Both
```

**功能：** 动画将遵循Forwards和Backwards的规则，从而在两个方向上扩展动画属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func !=(AnimatorFill)

```cangjie
public operator func !=(other: AnimatorFill): Bool
```

**功能：** 比较两个枚举值是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AnimatorFill](#enum-animatorfill)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值不相等则返回true，否则返回false。|

### operator func ==(AnimatorFill)

```cangjie
public operator func ==(other: AnimatorFill): Bool
```

**功能：** 比较两个枚举值是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AnimatorFill](#enum-animatorfill)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值相等则返回true，否则返回false。|

## enum AnimatorDirection

```cangjie
public enum AnimatorDirection <: Equatable<AnimatorDirection> {
    | Normal
    | Reverse
    | Alternate
    | AlternateReverse
    | ...
}
```

**功能：** 动画播放模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**父类型：**

- Equatable\<[AnimatorDirection](#enum-animatordirection)>

### Normal

```cangjie
Normal
```

**功能：** 动画正向循环播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Reverse

```cangjie
Reverse
```

**功能：** 动画反向循环播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### Alternate

```cangjie
Alternate
```

**功能：** 动画交替循环播放，奇数次正向播放，偶数次反向播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### AlternateReverse

```cangjie
AlternateReverse
```

**功能：** 动画反向交替循环播放，奇数次反向播放，偶数次正向播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### operator func !=(AnimatorDirection)

```cangjie
public operator func !=(other: AnimatorDirection): Bool
```

**功能：** 比较两个枚举值是否不相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AnimatorDirection](#enum-animatordirection)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值不相等则返回true，否则返回false。|

### operator func ==(AnimatorDirection)

```cangjie
public operator func ==(other: AnimatorDirection): Bool
```

**功能：** 比较两个枚举值是否相等。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AnimatorDirection](#enum-animatordirection)|是|-|待比较的另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果两个枚举值相等则返回true，否则返回false。|