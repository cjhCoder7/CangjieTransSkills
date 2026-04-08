# ImageData

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

ImageData对象可以存储canvas渲染的像素数据。

> **说明：**
>
> 创建ImageData时，宽高不超过16384px，最大面积不超过16000px*16000px，超过最大面积则无法正常绘制。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## class ImageData

```cangjie
public class ImageData {
    public init(width: ?Float64, height: ?Float64, data!: ?Array<UInt8>, unit!: ?LengthMetricsUnit = None)
    public init(width: ?Float64, height: ?Float64, unit!: ?LengthMetricsUnit = None)
}
```

**功能：** ImageData对象可以存储canvas渲染的像素数据。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### prop width

```cangjie
public prop width: Int32
```

**功能：** 矩形区域宽度，默认单位为vp。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### prop height

```cangjie
public prop height: Int32
```

**功能：** 矩形区域高度，默认单位为vp。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### prop data

```cangjie
public prop data: Array<UInt8>
```

**功能：** 一维数组，保存了相应的颜色数据，数据值范围为0到255。

**类型：** Array\<UInt8>

**读写能力：** 只读

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### init(?Float64, ?Float64, ?Array\<UInt8>, ?LengthMetricsUnit)

```cangjie
public init(width: ?Float64, height: ?Float64, data!: ?Array<UInt8>,
    unit!: ?LengthMetricsUnit = None)
```

**功能：** 构造一个ImageData类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|width|?Float64|是|-|矩形区域宽度，默认单位为vp。|
|height|?Float64|是|-|矩形区域高度，默认单位为vp。|
|data|?Array\<UInt8>|是|-|**命名参数。** 一维数组，保存了相应的颜色数据，数据值范围为0到255。|
|unit|?[LengthMetricsUnit](./cj-common-types.md#enum-lengthmetricsunit)|否|None|**命名参数。** 用来配置ImageData对象的单位模式，配置后无法动态更改，配置方法同[CanvasRenderingContext2D](./cj-canvas-drawing-canvasrenderingcontext2d.md#class-canvasrenderingcontext2d)。|

> **说明：**
>
> - width和height不能小于0.0，否则会有非预期的结果。
> - data的长度必须等于4.0 * width * height，否则会有非预期的结果。

### init(?Float64, ?Float64, ?LengthMetricsUnit)

```cangjie
public init(width: ?Float64, height: ?Float64, unit!: ?LengthMetricsUnit = None)
```

**功能：** 构造一个ImageData类型的对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|width|?Float64|是|-|矩形区域宽度，默认单位为vp。|
|height|?Float64|是|-|矩形区域高度，默认单位为vp。|
|unit|?[LengthMetricsUnit](./cj-common-types.md#enum-lengthmetricsunit)|否|None|**命名参数。** 用来配置ImageData对象的单位模式，配置后无法动态更改，配置方法同[CanvasRenderingContext2D](./cj-canvas-drawing-canvasrenderingcontext2d.md#class-canvasrenderingcontext2d)。|

> **说明：**
>
> width和height不能小于0.0，否则会有非预期的结果。
