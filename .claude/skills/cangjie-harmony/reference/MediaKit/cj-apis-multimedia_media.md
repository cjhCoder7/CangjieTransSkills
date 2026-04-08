# ohos.multimedia.media（媒体服务）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

media模块为开发者提供一套简单且易于理解的接口，使得开发者能够方便接入系统并使用系统的媒体资源。

媒体子系统包含了音视频相关媒体业务，目前主要提供获取视频缩略图（[AVImageGenerator](#class-avimagegenerator)）的功能。

## 导入模块

```cangjie
import kit.MediaKit.*
```

## 权限列表

ohos.permission.MICROPHONE

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。
- 获取当前应用沙箱所在路径可通过UIAbilityContext.[filesDir](../AbilityKit/cj-apis-app-ability-ui_ability.md#prop-filesdir)获取。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## func createAVImageGenerator()

```cangjie
public func createAVImageGenerator(): AVImageGenerator
```

**功能：** 创建AVImageGenerator实例。

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[AVImageGenerator](#class-avimagegenerator)|返回AVImageGenerator实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Media错误码](./cj-errorcode-multimedia-media.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 5400101 | No memory. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.MediaKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    let generator = createAVImageGenerator()
} catch (e: BusinessException) {
    Hilog.error(0, "AppLogCj", e.message)
}
```

## class AVFileDescriptor

```cangjie
public class AVFileDescriptor {
    public var fd: Int32
    public var offset: Int64
    public var length: Int64
    public init(
        fd: Int32,
        offset!: Int64 = 0,
        length!: Int64 = -1
    )
}
```

**功能：** 音视频文件资源描述，一种特殊资源的播放方式，使用场景：应用中的音频资源被连续存储在同一个文件中，需要根据偏移量和长度进行播放。

**系统能力：** SystemCapability.Multimedia.Media.Core

**起始版本：** 22

### var fd

```cangjie
public var fd: Int32
```

**功能：** 资源句柄，通过[getRawFd](../LocalizationKit/cj-apis-resource_manager.md#func-getrawfdstring)获取，也可以通过[open](../CoreFileKit/cj-apis-file_fs.md#static-func-openstring-int64)获取。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Media.Core

**起始版本：** 22

### var length

```cangjie
public var length: Int64
```

**功能：** 资源长度，需要基于预置资源的信息输入，非法值会造成音视频资源解析错误。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Media.Core

**起始版本：** 22

### var offset

```cangjie
public var offset: Int64
```

**功能：** 资源偏移量，需要基于预置资源的信息输入，非法值会造成音视频资源解析错误。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Media.Core

**起始版本：** 22

### init(Int32, Int64, Int64)

```cangjie
public init(
    fd: Int32,
    offset!: Int64 = 0,
    length!: Int64 = -1
)
```

**功能：** 构造音视频文件资源描述类型。

**系统能力：** SystemCapability.Multimedia.Media.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|fd|Int32|是|-|资源句柄，通过[getRawFd](../LocalizationKit/cj-apis-resource_manager.md#func-getrawfdstring)获取，也可以通过[open](../CoreFileKit/cj-apis-file_fs.md#static-func-openstring-int64)获取。|
|offset|Int64|否|0| **命名参数。** 资源偏移量，默认值为0，需要基于预置资源的信息输入，非法值会造成音视频资源解析错误。|
|length|Int64|否|-1| **命名参数。** 资源长度，默认值为-1，需要基于预置资源的信息输入，非法值会造成音视频资源解析错误。|

## class AVImageGenerator

```cangjie
public class AVImageGenerator {}
```

**功能：** 视频缩略图获取类，用于从视频资源中获取缩略图。在调用AVImageGenerator的方法前，需要先通过[createAVImageGenerator()](#func-createavimagegenerator)构建一个AVImageGenerator实例。

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

### prop fdSrc

```cangjie
public mut prop fdSrc: AVFileDescriptor
```

**功能：** 媒体文件描述，通过该属性设置数据源。

使用示例：

假设一个连续存储的媒体文件，地址偏移：0，字节长度：100。其文件描述为AVFileDescriptor { fd = 资源句柄; offset = 0; length = 100; }。

> **说明：**
>
> 将资源句柄（fd）传递给AVImageGenerator实例之后，不允许通过该资源句柄做其他读写操作，包括但不限于将同一个资源句柄传递给多个AVPlayer/AVImageGenerator/AVTranscoder。同一时间通过同一个资源句柄读写文件时存在竞争关系，将导致视频缩略图数据获取异常。

**类型：** [AVFileDescriptor](#class-avfiledescriptor)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Media.AVMetadataExtractor

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Media错误码](./cj-errorcode-multimedia-media.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 5400101 | No memory. |
  | 5400102 | Operation not allowed. |

### func fetchFrameByTime(Int64, AVImageQueryOptions, PixelMapParams)

```cangjie
public func fetchFrameByTime(timeUs: Int64, options: AVImageQueryOptions, param: PixelMapParams): PixelMap
```

**功能：** 获取视频缩略图。

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|timeUs|Int64|是|-|需要获取的缩略图在视频中的时间点，单位为微秒（μs）。|
|options|[AVImageQueryOptions](#enum-avimagequeryoptions)|是|-| 需要获取的缩略图时间点与视频帧的对应关系。|
|param|[PixelMapParams](#class-pixelmapparams)|是|-|需要获取的缩略图的格式参数。|

**返回值：**

|类型|说明|
|:----|:----|
|[PixelMap](../ImageKit/cj-apis-image.md#class-pixelmap)|视频缩略图。|

**异常：**

- BusinessException：对应错误码如下表，详见[Media错误码](./cj-errorcode-multimedia-media.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 5400101 | No memory. |
  | 5400102 | Operation not allowed. |
  | 5400106 | Unsupported format. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.MediaKit.*
import kit.LocalizationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let timeUs = 0
    let queryOption = AVImageQueryOptions.AvImageQueryNextSync
    let param = PixelMapParams(width: 300, height: 300)
    let generator = createAVImageGenerator()
    let abilityContext = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let rawFd = abilityContext.resourceManager.getRawFd("trailer.mp4")    // 请替换您的资源路径，获取文件路径参考本文使用说明
    generator.fdSrc = AVFileDescriptor(rawFd.fd, offset: rawFd.offset, length: rawFd.length)
    let pic = generator.fetchFrameByTime(timeUs, queryOption, param)
    generator.release()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func release()

```cangjie
public func release(): Unit
```

**功能：** 释放资源。

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Media错误码](./cj-errorcode-multimedia-media.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 5400101 | No memory. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.MediaKit.*
import kit.LocalizationKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    let timeUs = 0
    let queryOption = AVImageQueryOptions.AvImageQueryNextSync
    let param = PixelMapParams(width: 300, height: 300)
    let generator = createAVImageGenerator()
    let abilityContext = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let rawFd = abilityContext.resourceManager.getRawFd("trailer.mp4")
    generator.fdSrc = AVFileDescriptor(rawFd.fd, offset:rawFd.offset, length:rawFd.length)
    let pic = generator.fetchFrameByTime(timeUs, queryOption, param)
    generator.release()
} catch (e: BusinessException) {
    Hilog.error(0, "AppLogCj", e.message)
}
```

## class PixelMapParams

```cangjie
public class PixelMapParams {
    public var width: Int32
    public var height: Int32
    public init(width!: Int32 = -1, height!: Int32 = -1)
}
```

**功能：** 获取视频缩略图时，输出缩略图的格式参数。

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

### var height

```cangjie
public var height: Int32
```

**功能：** 输出的缩略图高度。应保证大于0且不大于原始视频高度。否则返回的缩略图不会进行缩放。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

### var width

```cangjie
public var width: Int32
```

**功能：** 输出的缩略图宽度。应保证大于0且不大于原始视频宽度。否则返回的缩略图不会进行缩放。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

### init(Int32, Int32)

```cangjie
public init(width!: Int32 = -1, height!: Int32 = -1)
```

**功能：** 构造缩略图的格式参数。

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|width|Int32|否|-1| **命名参数。** 输出的缩略图宽度。应保证大于0且不大于原始视频宽度。否则返回的缩略图不会进行缩放。|
|height|Int32|否|-1| **命名参数。** 输出的缩略图高度。应保证大于0且不大于原始视频高度。否则返回的缩略图不会进行缩放。|

## enum AVImageQueryOptions

```cangjie
public enum AVImageQueryOptions <: Equatable<AVImageQueryOptions> & ToString {
    | AvImageQueryNextSync
    | AvImageQueryPreviousSync
    | AvImageQueryClosestSync
    | AvImageQueryClosest
    | ...
}
```

**功能：** 需要获取的缩略图时间点与视频帧的对应关系。

在获取视频缩略图时，传入的时间点与实际取得的视频帧所在时间点不一定相等，需要指定传入的时间点与实际取得的视频帧的时间关系。

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

**父类型：**

- Equatable\<AVImageQueryOptions>
- ToString

### AvImageQueryClosest

```cangjie
AvImageQueryClosest
```

**功能：** 表示选取离传入时间点最近的帧，该帧不一定是关键帧。

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

### AvImageQueryClosestSync

```cangjie
AvImageQueryClosestSync
```

**功能：** 表示选取离传入时间点最近的关键帧。

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

### AvImageQueryNextSync

```cangjie
AvImageQueryNextSync
```

**功能：** 表示选取传入时间点或之后的关键帧。

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

### AvImageQueryPreviousSync

```cangjie
AvImageQueryPreviousSync
```

**功能：** 表示选取传入时间点或之前的关键帧。

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

### func !=(AVImageQueryOptions)

```cangjie
public operator func !=(other: AVImageQueryOptions): Bool
```

**功能：** 比较两个AVImageQueryOptions是否不等。

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AVImageQueryOptions](#enum-avimagequeryoptions)|是|-|另一AVImageQueryOptions实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个AVImageQueryOptions不等返回true，否则返回false。|

### func ==(AVImageQueryOptions)

```cangjie
public operator func ==(other: AVImageQueryOptions): Bool
```

**功能：** 比较两个AVImageQueryOptions是否相等。

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AVImageQueryOptions](#enum-avimagequeryoptions)|是|-|另一AVImageQueryOptions实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个AVImageQueryOptions相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 返回AVImageQueryOptions的字符串表示。

**系统能力：** SystemCapability.Multimedia.Media.AVImageGenerator

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|AVImageQueryOptions的字符串表示。|