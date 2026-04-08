# ohos.multimedia.image（图片处理）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

image模块提供图片处理效果，包括通过属性创建PixelMap、读取图像像素数据、读取区域内的图片数据等。

## 导入模块

```cangjie
import kit.ImageKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。
- 运行示例代码时，请先通过 [createImageSource](#func-createimagesourcestring-sourceoptions) 构建正确的图片源，支持从raw数组、Uri、文件描述符等构建图片源。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## func createImagePacker()

```cangjie
public func createImagePacker(): ImagePacker
```

**功能：** 创建ImagePacker实例。

> **说明：**
>
> 由于图片占用内存较大，所以当ImagePacker实例使用完成后，应主动调用[release](#func-release-1)方法及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[ImagePacker](#class-imagepacker)|返回ImagePacker实例。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let imagePacker : ImagePacker = createImagePacker()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func createImageReceiver(Size, ImageFormat, Int32)

```cangjie
public func createImageReceiver(size: Size, format: ImageFormat, capacity: Int32): ImageReceiver
```

**功能：** 通过图片大小、图片格式、容量创建ImageReceiver实例。

> **说明：**
>
> - ImageReceiver做为图片的接收方、消费者，它的参数属性实际上不会对接收到的图片产生影响。图片属性的配置应在发送方、生产者进行，如相机预览流[createPreviewOutput](../CameraKit/cj-apis-multimedia-camera.md#func-createpreviewoutputprofile-string)。
>
> - 由于图片占用内存较大，所以当ImageReceiver实例使用完成后，应主动调用[release](#func-release-2)方法及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|size|[Size](#class-size)|是|-|图像的默认大小。该参数不会影响接收到的图片大小，实际返回大小由生产者决定，如相机。|
|format|[ImageFormat](#enum-imageformat)|是|-|图像格式，取值为[ImageFormat](#enum-imageformat)常量（目前仅支持 ImageFormat:Jpeg，实际返回格式由生产者决定，如相机）。|
|capacity|Int32|是|-|同时访问的最大图像数。该参数仅作为期望值，实际capacity由设备硬件决定。|

**返回值：**

|类型|说明|
|:----|:----|
|[ImageReceiver](#class-imagereceiver)|如果操作成功，则返回ImageReceiver实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |
  | 62980115 | Parameter error.Possible causes: 1.Mandatory parameters are left unspecified; 2.Incorrect parameter types. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let size = Size(8, 8192)
    let receiver:ImageReceiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func createImageSource(String)

```cangjie
public func createImageSource(uri: String): ImageSource
```

**功能：** 通过传入的uri创建ImageSource实例。

> **说明：**
>
> 由于图片占用内存较大，所以当ImageSource实例使用完成后，应主动调用[release](#func-release-3)方法及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|uri|String|是|-|图片路径，当前仅支持应用沙箱路径。</br>当前支持格式有：.jpg .png .gif .bmp .webp .dng .heic（不同硬件设备支持情况不同） [.svg](#svg标签说明) .ico。 |

**返回值：**

|类型|说明|
|:----|:----|
|[ImageSource](#class-imagesource)|返回ImageSource类实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let path: String = "../test.jpg"
    let imageSourceApi: ImageSource = createImageSource(path)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func createImageSource(String, SourceOptions)

```cangjie
public func createImageSource(uri: String, options: SourceOptions): ImageSource
```

**功能：** 通过传入的uri创建ImageSource实例。

> **说明：**
>
> 由于图片占用内存较大，所以当ImageSource实例使用完成后，应主动调用[release](#func-release-3)方法及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|uri|String|是|-|图片路径，当前仅支持应用沙箱路径。</br>当前支持格式有：.jpg .png .gif .bmp .webp .dng .heic（不同硬件设备支持情况不同） [.svg](#svg标签说明) .ico。|
|options|[SourceOptions](#class-sourceoptions)|是|-|图片属性，包括图片像素密度、像素格式和图片尺寸。|

**返回值：**

|类型|说明|
|:----|:----|
|[ImageSource](#class-imagesource)|返回ImageSource类实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSource: ImageSource = createImageSource("test.png", sourceOptions)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func createImageSource(Int32)

```cangjie
public func createImageSource(fd: Int32): ImageSource
```

**功能：** 通过传入文件描述符来创建ImageSource实例。

> **说明：**
>
> 由于图片占用内存较大，所以当ImageSource实例使用完成后，应主动调用[release](#func-release-3)方法及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|fd|Int32|是|-|文件描述符fd。|

**返回值：**

|类型|说明|
|:----|:----|
|[ImageSource](#class-imagesource)|返回ImageSource类实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let imageSourceApi : ImageSource = createImageSource(0)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func createImageSource(Int32, SourceOptions)

```cangjie
public func createImageSource(fd: Int32, options: SourceOptions): ImageSource
```

**功能：** 通过传入文件描述符来创建ImageSource实例。

> **说明：**
>
> 由于图片占用内存较大，所以当ImageSource实例使用完成后，应主动调用[release](#func-release-3)方法及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|fd|Int32|是|-|文件描述符fd。|
|options|[SourceOptions](#class-sourceoptions)|是|-|图片属性，包括图片像素密度、像素格式和图片尺寸。|

**返回值：**

|类型|说明|
|:----|:----|
|[ImageSource](#class-imagesource)|返回ImageSource类实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSource: ImageSource = createImageSource(0, sourceOptions)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func createImageSource(Array\<UInt8>)

```cangjie
public func createImageSource(buf: Array<UInt8>): ImageSource
```

**功能：** 通过缓冲区创建ImageSource实例。buf数据应该是未解码的数据，不要传入类似于RBGA，YUV的像素buffer数据，如果想通过像素buffer数据创建pixelMap，可以调用[createPixelMap](#func-createpixelmaparrayuint8-initializationoptions)这一类接口。

> **说明：**
>
> 由于图片占用内存较大，所以当ImageSource实例使用完成后，应主动调用[release](#func-release-3)方法及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|buf|Array\<UInt8>|是|-|图像缓冲区数组。|

**返回值：**

|类型|说明|
|:----|:----|
|[ImageSource](#class-imagesource)|返回ImageSource类实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let buf: Array<UInt8> = Array<UInt8>(96, repeat: 0) //96为需要创建的像素buffer大小，取值为：height * width *4
    let imageSourceApi: ImageSource = createImageSource(buf)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func createImageSource(Array\<UInt8>, SourceOptions)

```cangjie
public func createImageSource(buf: Array<UInt8>, options: SourceOptions): ImageSource
```

**功能：** 通过缓冲区创建ImageSource实例。buf数据应该是未解码的数据，不要传入类似于RBGA，YUV的像素buffer数据，如果想通过像素buffer数据创建pixelMap，可以调用[createPixelMap](#func-createpixelmaparrayuint8-initializationoptions)这一类接口。

> **说明：**
>
> 由于图片占用内存较大，所以当ImageSource实例使用完成后，应主动调用[release](#func-release-3)方法及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|buf|Array\<UInt8>|是|-|图像缓冲区数组。|
|options|[SourceOptions](#class-sourceoptions)|是|-|图片属性，包括图片像素密度、像素格式和图片尺寸。|

**返回值：**

|类型|说明|
|:----|:----|
|[ImageSource](#class-imagesource)|返回ImageSource类实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func createImageSource(RawFileDescriptor, SourceOptions)

```cangjie
public func createImageSource(rawfile: RawFileDescriptor, options!: SourceOptions = SourceOptions(0)): ImageSource
```

**功能：** 通过图像资源文件的RawFileDescriptor创建ImageSource实例。

> **说明：**
>
> 由于图片占用内存较大，所以当ImageSource实例使用完成后，应主动调用[release](#func-release-3)方法及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|rawfile|[RawFileDescriptor](../LocalizationKit/cj-apis-raw_file_descriptor.md#class-rawfiledescriptor)|是|-|图像资源文件的RawFileDescriptor。|
|options|[SourceOptions](#class-sourceoptions)|否|SourceOptions(0)| **命名参数。** 图片属性，包括图片像素密度、像素格式和图片尺寸。|

**返回值：**

|类型|说明|
|:----|:----|
|[ImageSource](#class-imagesource)|返回ImageSource类实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException
import ohos.resource_manager.ResourceManager

let resourceManager = Global.abilityContext.resourceManager // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
try {
    let rawfd = resourceManager.getRawFd("test.png")
    createImageSource(rawfd)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "error code: ${e.code}, message: ${e.message}.", "")
}
```

## func createPixelMap(Array\<UInt8>, InitializationOptions)

```cangjie
public func createPixelMap(colors: Array<UInt8>, options: InitializationOptions): PixelMap
```

**功能：** 通过属性创建PixelMap，默认采用Bgra8888格式处理数据。

> **说明：**
>
> 由于图片占用内存较大，所以当PixelMap对象使用完成后，应主动调用[release](#func-release-4)方法及时释放内存。释放时应确保后续不再使用该对象。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|colors|Array\<UInt8>|是|-|图像像素数据的缓冲区，用于初始化PixelMap的像素。初始化前，缓冲区中的像素格式需要由[InitializationOptions](#class-initializationoptions).srcPixelFormat指定。<br>**说明：** 图像像素数据的缓冲区长度：length = width * height * 单位像素字节数。|
|options|[InitializationOptions](#class-initializationoptions)|是|-|创建像素的属性，包括透明度，尺寸，缩略值，像素格式和是否可编辑。|

**返回值：**

|类型|说明|
|:----|:----|
|[PixelMap](#class-pixelmap)|返回PixelMap。<br>当创建的pixelMap大小超过原图大小时，返回原图pixelMap大小。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |
  | 62980115 | Parameter error. Possible causes: 1.Mandatory parameters are left unspecified. 2.Incorrect parameter types. 3.Parameter verification failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkUI.Row
import kit.ArkUI.Column
import kit.ArkUI.loadNativeView
import kit.ArkUI.CustomView
import kit.ArkUI.CJEntry
import kit.ArkUI.Image
import kit.ArkUI.LengthProp
import kit.ArkUI.SubscriberManager
import kit.ArkUI.LocalStorage
import ohos.arkui.state_macro_manage.*
import kit.ImageKit.{InitializationOptions, createPixelMap, Size, PixelMap}
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

func getPixelMap(): PixelMap {
    try {
        // 96 为需要创建的像素 buffer 大小，取值为：height * width * 4
        let color: Array<UInt8> = Array<UInt8>(96, repeat: 0)
        let opts: InitializationOptions = InitializationOptions(Size(4, 6))
        // 通过属性创建的PixelMap实例，后续可以调用该实例的方法读取或写入图像数据
        let pixelMap = createPixelMap(color, opts)
        return pixelMap
    } catch (e: BusinessException) {
        Hilog.info(0, "test", "${e.message}")
        throw e
    }
}

@Entry
@Component
class EntryView {

    func build() {
        Row {
            Column {
                Image(getPixelMap())
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

## class Component

```cangjie
public class Component {
    public let componentType: ComponentType
    public let rowStride: Int32
    public let pixelStride: Int32
    public let byteBuffer: Array<UInt8>
}
```

**功能：** 描述图像颜色分量。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### let byteBuffer

```cangjie
public let byteBuffer: Array<UInt8>
```

**功能：** 组件缓冲区。

**类型：** Array\<UInt8>

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### let componentType

```cangjie
public let componentType: ComponentType
```

**功能：** 组件类型。

**类型：** [ComponentType](#enum-componenttype)

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### let pixelStride

```cangjie
public let pixelStride: Int32
```

**功能：** 像素间距。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### let rowStride

```cangjie
public let rowStride: Int32
```

**功能：** 行距。读取相机预览流数据时，需要按stride进行读取，使用详情请参考[相机预览花屏解决方案](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-deal-stride-solution)。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

## class DecodingOptions

```cangjie
public class DecodingOptions {
    public var index: UInt32
    public var sampleSize: UInt32
    public var rotate: UInt32
    public var editable: Bool
    public var desiredSize: Size
    public var desiredRegion: Region
    public var desiredPixelFormat: PixelMapFormat
    public var fitDensity: Int32
    public var desiredColorSpace: ?ColorSpaceManager
    public var desiredDynamicRange: DecodingDynamicRange
    public init(sampleSize!: UInt32 = 1, rotate!: UInt32 = 0, editable!: Bool = false,
        desiredSize!: Size = Size(0, 0), desiredRegion!: Region = Region(Size(0, 0), 0, 0),
        desiredPixelFormat!: PixelMapFormat = Unknown, index!: UInt32 = 0, fitDensity!: Int32 = 0,
        desiredColorSpace!: ?ColorSpaceManager = None, desiredDynamicRange!: DecodingDynamicRange = Sdr)
}
```

**功能：** 图像解码设置选项。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### var desiredColorSpace

```cangjie
public var desiredColorSpace:?ColorSpaceManager
```

**功能：** 目标色彩空间。

**类型：** ?[ColorSpaceManager](../ArkGraphics2D/cj-apis-color_manager.md#class-colorspacemanager)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### var desiredDynamicRange

```cangjie
public var desiredDynamicRange: DecodingDynamicRange
```

**功能：** 目标动态范围。

如果平台不支持Hdr，设置无效，默认解码为Sdr内容。

**类型：** [DecodingDynamicRange](#enum-decodingdynamicrange)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### var desiredPixelFormat

```cangjie
public var desiredPixelFormat: PixelMapFormat
```

**功能：** 解码的像素格式。仅支持设置：Rgba8888、Bgra8888和Rgb565。有透明通道图片格式不支持设置Rgb565，如PNG、GIF、ICO和WEBP。

**类型：** [PixelMapFormat](#enum-pixelmapformat)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### var desiredRegion

```cangjie
public var desiredRegion: Region
```

**功能：** 解码图像中由Region指定的矩形区域，当原始图像很大而只需要解码图像的一部分时，可以设置该参数，有助于提升性能。

**类型：** [Region](#class-region)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### var desiredSize

```cangjie
public var desiredSize: Size
```

**功能：** 期望输出大小，必须为正整数，若与原尺寸比例不一致，则会进行拉伸/缩放到指定尺寸。

**类型：** [Size](#class-size)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### var editable

```cangjie
public var editable: Bool
```

**功能：** true表示可编辑，false表示不可编辑。当取值为false时，图片不可二次编辑，如writePixels操作将失败。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### var fitDensity

```cangjie
public var fitDensity: Int32
```

**功能：** 图像像素密度，单位为ppi。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### var index

```cangjie
public var index: UInt32
```

**功能：** 解码图片序号。设置值为0，表示第一张图片。当取值为N时，表示第N+1张图片。单帧图片场景中index取值只能为0，动图等多帧图片场景中index的取值范围为：0~（帧数-1）。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### var rotate

```cangjie
public var rotate: UInt32
```

**功能：** 旋转角度。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### var sampleSize

```cangjie
public var sampleSize: UInt32
```

**功能：** 缩略图采样大小。当前只能取1。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### init(UInt32, UInt32, Bool, Size, Region, PixelMapFormat, UInt32, Int32, ?ColorSpaceManager, DecodingDynamicRange)

```cangjie
public init(sampleSize!: UInt32 = 1, rotate!: UInt32 = 0, editable!: Bool = false,
    desiredSize!: Size = Size(0, 0), desiredRegion!: Region = Region(Size(0, 0), 0, 0),
    desiredPixelFormat!: PixelMapFormat = Unknown, index!: UInt32 = 0, fitDensity!: Int32 = 0,
    desiredColorSpace!: ?ColorSpaceManager = None, desiredDynamicRange!: DecodingDynamicRange = Sdr)
```

**功能：** 创建DecodingOptions对象。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|sampleSize|UInt32|否|1|**命名参数。** 缩略图采样大小，默认值为1。当前只能取1。|
|rotate|UInt32|否|0|**命名参数。** 旋转角度。默认值为0。|
|editable|Bool|否|false|**命名参数。** true表示可编辑，false表示不可编辑。默认值为false。当取值为false时，图片不可二次编辑，如writePixels操作将失败。|
|desiredSize|[Size](#class-size)|否|Size(0, 0)|**命名参数。** 期望输出大小，必须为正整数，若与原尺寸比例不一致，则会进行拉伸/缩放到指定尺寸，默认为原始尺寸。|
|desiredRegion|[Region](#class-region)|否|Region(Size(0, 0), 0, 0)|**命名参数。** 解码图像中由Region指定的矩形区域，当原始图像很大而只需要解码图像的一部分时，可以设置该参数，有助于提升性能，默认为原始大小。|
|desiredPixelFormat|[PixelMapFormat](#enum-pixelmapformat)|否|Unknown|**命名参数。** 解码的像素格式。默认值为Unknown。仅支持设置：Rgba8888、Bgra8888和Rgb565。有透明通道图片格式不支持设置Rgb565，如PNG、GIF、ICO和WEBP。|
|index|UInt32|否|0|**命名参数。** 解码图片序号。默认值为0，表示第一张图片。当取值为N时，表示第N+1张图片。单帧图片场景中index取值只能为0，动图等多帧图片场景中index的取值范围为：0~（帧数-1）。|
|fitDensity|Int32|否|0|**命名参数。** 图像像素密度，单位为ppi。默认值为0。|
|desiredColorSpace|?[ColorSpaceManager](../ArkGraphics2D/cj-apis-color_manager.md#class-colorspacemanager)|否|None|**命名参数。** 目标色彩空间。色域默认值为Unknown。|
|desiredDynamicRange|[DecodingDynamicRange](#enum-decodingdynamicrange)|否|Sdr|**命名参数。** 目标动态范围，默认值为Sdr。<br>如果平台不支持Hdr，设置无效，默认解码为Sdr内容。 |

## class Image

```cangjie
public class Image {}
```

**功能：** Image类，用于获取图像内容。

> **说明：**
>
> - 调用[readNextImage](#func-readnextimage)和[readLatestImage](#func-readlatestimage)接口时会返回Image实例。
>
> - Image的属性仅支持在创建时初始化，后续无法再修改，且它的属性不对图像内容产生实际影响，请以图片生产者写入的属性为准，即以向[ImageReceiver](#class-imagereceiver)发送图片数据的发送方实际写入的内容为准。
>
> - 由于图片占用内存较大，所以当Image实例使用完成后，应主动调用[release](#func-release)方法及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### prop clipRect

```cangjie
public prop clipRect: Region
```

**功能：** 要裁剪的图像区域。

**类型：** [Region](#class-region)

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

### prop format

```cangjie
public prop format: Int32
```

**功能：** 图像格式，参考[PixelMapFormat](#enum-pixelmapformat)。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

### prop size

```cangjie
public prop size: Size
```

**功能：** 图像大小。如果image对象所存储的是相机预览流数据，即YUV图像数据，那么获取到的size中的宽高分别对应YUV图像的宽高； 如果image对象所存储的是相机拍照流数据，即JPEG图像，由于已经是编码后的文件，size中的宽等于JPEG文件大小，高等于1。image对象所存储的数据是预览流还是拍照流，取决于应用将receiver中的surfaceId传给相机的previewOutput还是captureOutput。

**类型：** [Size](#class-size)

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

### func getComponent(ComponentType)

```cangjie
public func getComponent(componentType: ComponentType): Component
```

**功能：** 根据图像的组件类型从图像中获取组件缓存。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|componentType|[ComponentType](#enum-componenttype)|是|-|图像的组件类型。（目前仅支持 ComponentType:Jpeg，实际返回格式由生产者决定，如相机）。|

**返回值：**

|类型|说明|
|:----|:----|
|[Component](#class-component)|返回组件缓冲区。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let size = Size(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let img = receiver.readNextImage()
    let component : Component = img.getComponent(ComponentType.Jpeg)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func release()

```cangjie
public func release(): Unit
```

**功能：** 释放当前图像。

> **说明：**
>
> - 在接收另一个图像前必须先释放对应资源。
>
> - 由于图片占用内存较大，所以当Image实例使用完成后，应主动调用该方法，及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let size = Size(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let img = receiver.readNextImage()
    img.release()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class ImageInfo

```cangjie
public class ImageInfo {
    public var size: Size
    public var density: Int32
    public var stride: Int32
    public var pixelFormat: PixelMapFormat
    public var alphaType: AlphaType
    public var mimeType: String
    public var isHdr: Bool
}
```

**功能：** 表示图片信息。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var alphaType

```cangjie
public var alphaType: AlphaType
```

**功能：** 透明度。

**类型：** [AlphaType](#enum-alphatype)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var density

```cangjie
public var density: Int32
```

**功能：** 像素密度，单位为ppi。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var isHdr

```cangjie
public var isHdr: Bool
```

**功能：** true表示图片为高动态范围（HDR），false表示图片非高动态范围（SDR）。对于[ImageSource](#class-imagesource)，代表源图片是否为HDR；对于[PixelMap](#class-pixelmap)，代表解码后的pixelmap是否为HDR。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var mimeType

```cangjie
public var mimeType: String
```

**功能：** 图片真实格式（MIME type）。

图片解码和图片编码支持格式的范围不同，请避免直接将解码得到的图片真实格式作为图片编码时[PackingOption](#class-packingoption)的format。

可以使用[ImageSource](#class-imagesource)的supportedFormats属性和[ImagePacker](#class-imagepacker)的supportedFormats属性查看解码和编码支持的格式范围。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var pixelFormat

```cangjie
public var pixelFormat: PixelMapFormat
```

**功能：** 像素格式。

**类型：** [PixelMapFormat](#enum-pixelmapformat)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var size

```cangjie
public var size: Size
```

**功能：** 图片大小。

**类型：** [Size](#class-size)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var stride

```cangjie
public var stride: Int32
```

**功能：** 跨距，内存中每行像素所占的空间。stride >= region.size.width*4。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

## class ImagePacker

```cangjie
public class ImagePacker {}
```

**功能：** ImagePacker类，用于图片压缩和编码。

> **说明：**
>
> - 在调用ImagePacker的方法前，需要先通过[createImagePacker](#func-createimagepacker)构建一个ImagePacker实例。
>
> - 编码期间，请避免修改或释放作为输入的ImageSource/PixelMap对象，以免出现crash或其他未定义行为。
>
> - 由于图片占用内存较大，所以当ImagePacker实例使用完成后，应主动调用[release](#func-release-1)方法及时释放内存。释放时应确保后续不再使用该实例。
>
> - 当前支持的格式有：jpeg、webp、png、heif、gif（不同硬件设备支持情况不同，可通过ImagePacker的supportedFormats属性查看）。

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

### prop supportedFormats

```cangjie
public prop supportedFormats: Array<String>
```

**功能：** 图片编码支持的格式，包括：jpeg、webp、png、heic、gif（不同硬件设备支持情况不同）。

**类型：** Array\<String>

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980098 | Failed to malloc memory. |
  | 62980104 | Failed to initialize the internal object. |

### func packToData(ImageSource, PackingOption)

```cangjie
public func packToData(source: ImageSource, options: PackingOption): Array<UInt8>
```

**功能：** 图片压缩或重新编码。

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|source|[ImageSource](#class-imagesource)|是|-|编码的ImageSource。|
|options|[PackingOption](#class-packingoption)|是|-|设置编码参数。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<UInt8>|返回压缩或编码后的数据。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980096 | The operation failed. Possible cause: 1.Image upload exception. 2. Decoding process exception. 3. Insufficient memory. |
  | 62980101 | The image data is abnormal. |
  | 62980104 | Failed to initialize the internal object. |
  | 62980106 | The image data is too large. This status code is thrown when an error occurs during the process of checking size. |
  | 62980113 | Unknown image format. The image data provided is not in a recognized or supported format, or it may be occorrupted. |
  | 62980115 | If the parameter is invalid. |
  | 62980119 | Failed to encode the image. |
  | 62980120 | Add pixelmap out of range. |
  | 62980172 | Failed to encode icc. |
  | 62980252 | Failed to create surface. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSource: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    var imagePacker = createImagePacker()
    let supportedFormats = imagePacker.supportedFormats
    let packingOption = PackingOption("image/jpeg", 98)
    let packRes = imagePacker.packToData(imageSource, packingOption)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func packToData(PixelMap, PackingOption)

```cangjie
public func packToData(source: PixelMap, options: PackingOption): Array<UInt8>
```

**功能：** 图片压缩或重新编码。

> **注意：**
> 接口如果返回62980115错误码，表明参数异常，可能是PixelMap对象被提前释放了。需要调用方排查，在该方法调用结束后再释放PixelMap对象。

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|source|[PixelMap](#class-pixelmap)|是|-|编码的PixelMap源。|
|options|[PackingOption](#class-packingoption)|是|-|设置编码参数。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<UInt8>|返回压缩或编码后的数据。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980096 | The operation failed. Possible cause: 1.Image upload exception.2. Decoding process exception. 3. Insufficient memory. |
  | 62980101 | The image data is abnormal. |
  | 62980104 | Failed to initialize the internal object. |
  | 62980106 | The image data is too large. This status code is thrown when an error occurs during the process of checking size. |
  | 62980113 | Unknown image format.The image data provided is not in a recognized or supported format, or it may be occorrupted. |
  | 62980115 | If the parameter is invalid. |
  | 62980119 | Failed to encode the image. |
  | 62980120 | Add pixelmap out of range. |
  | 62980172 | Failed to encode icc. |
  | 62980252 | Failed to create surface. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var colors: Array<UInt8> = [80, 2, 4, 8, 40, 2, 4, 8]
    var pm = createPixelMap(colors,
        InitializationOptions(Size(2, 1), scaleMode: ScaleMode.CenterCrop))
    var imagePacker = createImagePacker()
    let supportedFormats = imagePacker.supportedFormats
    let packingOption = PackingOption("image/jpeg", 98)
    let packRes = imagePacker.packToData(pm, packingOption)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func packToFile(ImageSource, Int32, PackingOption)

```cangjie
public func packToFile(source: ImageSource, fd: Int32, options: PackingOption): Unit
```

**功能：** 指定编码参数，将ImageSource直接编码进文件。

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|source|[ImageSource](#class-imagesource)|是|-|编码的ImageSource。|
|fd|Int32|是|-|文件描述符。|
|options|[PackingOption](#class-packingoption)|是|-|设置编码参数。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980096 | The operation failed. Possible cause: 1.Image upload exception. 2. Decoding process exception. 3. Insufficient memory. |
  | 62980101 | The image data is abnormal. |
  | 62980104 | Failed to initialize the internal object. |
  | 62980106 | The image data is too large. This status code is thrown when an error occurs during the process of checking size. |
  | 62980113 | Unknown image format. The image data provided is not in a recognized or supported format, or it may be occorrupted. |
  | 62980115 | Invalid input parameter. |
  | 62980119 | Failed to encode the image. |
  | 62980120 | Add pixelmap out of range. |
  | 62980172 | Failed to encode icc. |
  | 62980252 | Failed to create surface. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import kit.CoreFileKit.{FileIo, OpenMode}
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSource: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    var fd: Int32 = 0
    let filePath = "data/storage/el1/base/xxx.txt"
    let file = FileIo.open(filePath,mode: (OpenMode.CREATE | OpenMode.READ_WRITE))
    let packingOption = PackingOption("image/jpeg", 98)
    let imagePacker = createImagePacker()
    imagePacker.packToFile(imageSource, fd, packingOption)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func packToFile(PixelMap, Int32, PackingOption)

```cangjie
public func packToFile(source: PixelMap, fd: Int32, options: PackingOption): Unit
```

**功能：** 指定编码参数，将PixelMap直接编码进文件。

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|source|[PixelMap](#class-pixelmap)|是|-|编码的PixelMap资源。|
|fd|Int32|是|-|文件描述符。|
|options|[PackingOption](#class-packingoption)|是|-|设置编码参数。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980096 | The operation failed. Possible cause: 1.Image upload exception.2. Decoding process exception. 3. Insufficient memory. |
  | 62980101 | The image data is abnormal. |
  | 62980104 | Failed to initialize the internal object. |
  | 62980106 | The image data is too large. This status code is thrown when an error occurs during the process of checking size. |
  | 62980113 | Unknown image format.The image data provided is not in a recognized or supported format, or it may be occorrupted. |
  | 62980115 | Invalid input parameter. |
  | 62980119 | Failed to encode the image. |
  | 62980120 | Add pixelmap out of range. |
  | 62980172 | Failed to encode icc. |
  | 62980252 | Failed to create surface. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import kit.CoreFileKit.{FileIo, OpenMode}
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let color: Array<UInt8> = Array<UInt8>(96, repeat: 0) //96为需要创建的像素buffer大小，取值为：height * width *4
    let opts: InitializationOptions = InitializationOptions(
        Size(4, 6),
        editable: true,
        pixelFormat: PixelMapFormat.Rgba8888)
    let pixelMap = createPixelMap(color, opts)
    var fd: Int32 = 0
    let filePath = "data/storage/el1/base/xxx.txt"
    let file = FileIo.open(filePath,mode: (OpenMode.CREATE | OpenMode.READ_WRITE))
    let packingOption = PackingOption("image/jpeg", 98)
    let imagePacker = createImagePacker()
    imagePacker.packToFile(pixelMap, fd, packingOption)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func release()

```cangjie
public func release(): Unit
```

**功能：** 释放图片打包实例。

> **说明：**
>
> 由于图片占用内存较大，所以当ImagePacker实例使用完成后，应主动调用该方法，及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let imagePacker = createImagePacker()
    imagePacker.release()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class ImagePropertyOptions

```cangjie
public class ImagePropertyOptions {
    public var index: UInt32
    public var defaultValue: String
    public init(index!: UInt32 = 0, defaultValue!: String = "")
}
```

**功能：** 表示查询图片属性的索引。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### var defaultValue

```cangjie
public var defaultValue: String
```

**功能：** 默认属性值。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### var index

```cangjie
public var index: UInt32
```

**功能：** 图片序号。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### init(UInt32, String)

```cangjie
public init(index!: UInt32 = 0, defaultValue!: String = "")
```

**功能：** 创建ImagePropertyOptions对象。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|index|UInt32|否|0| **命名参数。** 图片序号。默认值为0。|
|defaultValue|String|否|""| **命名参数。** 默认属性值。默认值为空。|

## class ImageReceiver

```cangjie
public class ImageReceiver {}
```

**功能：** 图像接收类，用于获取组件surface id，接收最新的图片和读取下一张图片，以及释放ImageReceiver实例。

> **说明：**
>
> - ImageReceiver作为图片的接收方、消费者，它的参数属性实际上不会对接收到的图片产生影响。图片属性的配置应在发送方、生产者进行，如相机预览流[createPreviewOutput](../CameraKit/cj-apis-multimedia-camera.md#func-createpreviewoutputprofile-string)。
>
> - 在调用以下方法前需要先通过[createImageReceiver](#func-createimagereceiversize-imageformat-int32)创建ImageReceiver实例。
>
> - 由于图片占用内存较大，所以当ImageReceiver实例使用完成后，应主动调用[release](#func-release-2)方法及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

### prop capacity

```cangjie
public prop capacity: Int32
```

**功能：** 同时访问的图像数。该参数仅作为期望值，实际capacity由设备硬件决定。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

### prop format

```cangjie
public prop format: ImageFormat
```

**功能：** 图像格式，取值为[ImageFormat](#enum-imageformat)常量（目前仅支持 ImageFormat:Jpeg，实际返回格式由生产者决定，如相机）。

**类型：** [ImageFormat](#enum-imageformat)

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

### prop size

```cangjie
public prop size: Size
```

**功能：** 图片大小。该参数不会影响接收到的图片大小，实际返回大小由生产者决定，如相机。

**类型：** [Size](#class-size)

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

### func getReceivingSurfaceId()

```cangjie
public func getReceivingSurfaceId(): String
```

**功能：** 用于获取一个surface id供Camera或其他组件使用。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|返回surface id。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let size = Size(8, 8192)
    var receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let id: String = receiver.getReceivingSurfaceId()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func release()

```cangjie
public func release(): Unit
```

**功能：** 释放ImageReceiver实例。

> **说明：**
>
> 由于图片占用内存较大，所以当ImageReceiver实例使用完成后，应主动调用该方法，及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let size = Size(8, 8192)
    var receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    receiver.release()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func readLatestImage()

```cangjie
public func readLatestImage(): Image
```

**功能：** 从ImageReceiver读取最新的图片。

> **注意：** 
> 
> - 此接口需要在[on](#func-onreceivetype-callback0argument)回调触发后调用，才能正常的接收到数据。且此接口返回的[Image](#class-image)对象使用完毕后需要调用[release](#func-release-1)方法释放，释放后才可以继续接收新的数据。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[Image](#class-image)|返回最新图片。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    let size = Size(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let image = receiver.readLatestImage()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func readNextImage()

```cangjie
public func readNextImage(): Image
```

**功能：** 从ImageReceiver读取下一张图片。

> **注意：** 
> 
> - 此接口需要在[on](#func-onreceivetype-callback0argument)回调触发后调用，才能正常的接收到数据。且此接口返回的[Image](#class-image)对象使用完毕后需要调用[release](#func-release-1)方法释放，释放后才可以继续接收新的数据。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[Image](#class-image)|返回下一张图片。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    let size = Size(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let image = receiver.readNextImage()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(ReceiveType, Callback0Argument)

```cangjie
public func on(eventType: ReceiveType, callback: Callback0Argument): Unit
```

**功能：** 接收图片时注册回调。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[ReceiveType](#enum-receivetype)|是|-|注册事件的类型，固定为ImageArrival，接收图片时触发。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException
import ohos.callback_invoke.*

class Callback <: Callback0Argument {
    public func invoke(res: ?BusinessException): Unit {
        Hilog.info(0, "test", "invoke success")
    }
}

try {
    let size = Size(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let callback = Callback()
    receiver.on(ImageArrival, callback)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(ReceiveType)

```cangjie
public func off(eventType: ReceiveType): Unit
```

**功能：** 释放buffer时移除注册回调。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[ReceiveType](#enum-receivetype)|是|-|注册事件的类型，固定为ImageArrival，释放buffer时触发。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException
import ohos.callback_invoke.*

class Callback1 <: Callback0Argument {
    public func invoke(res: ?BusinessException): Unit {
        Hilog.info(0, "test", "invoke success")
    }
}

try {
    let size = Size(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let callback = Callback1()
    receiver.on(ImageArrival, callback)
    receiver.off(ImageArrival)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class ImageSource

```cangjie
public class ImageSource {}
```

**功能：** ImageSource类，用于获取图片相关信息。

> **说明：**
>
> - 在调用ImageSource的方法前，需要先通过[createImageSource](#func-createimagesourcearrayuint8)构建一个ImageSource实例。
>
> - ImageSource的所有方法均不支持并发调用。
>
> - 由于图片占用内存较大，所以当ImageSource实例使用完成后，应主动调用[release](#func-release-3)方法及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

### prop supportedFormats

```cangjie
public prop supportedFormats: Array<String>
```

**功能：** 支持的图片格式，包括：png，jpeg，bmp，gif，webp，dng，heic（不同硬件设备支持情况不同）。

**类型：** Array\<String>

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980102 | Failed to malloc memory. |
  | 62980104 | Failed to initialize the internal object. |

### func createPixelMap(DecodingOptions)

```cangjie
public func createPixelMap(options!: DecodingOptions = DecodingOptions()): PixelMap
```

**功能：** 通过图片解码参数创建PixelMap对象。

> **说明：**
>
> 由于图片占用内存较大，所以当PixelMap对象使用完成后，应主动调用[release](#func-release-4)方法，及时释放内存。释放时应确保后续不再使用该对象。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|options|[DecodingOptions](#class-decodingoptions)|否|DecodingOptions()|**命名参数。** 解码参数。|

**返回值：**

|类型|说明|
|:----|:----|
|[PixelMap](#class-pixelmap)|返回PixelMap。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let option = DecodingOptions(
        sampleSize: 1,
        rotate: 10,
        editable: true,
        desiredSize: Size(3, 4),
        desiredRegion: Region(Size(3, 4), 0, 0),
        desiredPixelFormat: PixelMapFormat.Rgba8888,
        index: 0,
        fitDensity: 20
    )
    let pixelMap = imageSourceApi.createPixelMap(options: option)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func createPixelMapList(DecodingOptions)

```cangjie
public func createPixelMapList(options!: DecodingOptions = DecodingOptions()): Array<PixelMap>
```

**功能：** 通过图片解码参数创建PixelMap数组。

> **说明：**
>
> - 针对动图如Gif、Webp，此接口返回每帧图片数据；针对静态图，此接口返回唯一的一帧图片数据。
>
> - 由于图片占用内存较大，所以当PixelMap对象使用完成后，应主动调用[release](#func-release-4)方法，及时释放内存。释放时应确保后续不再使用该对象。

> **注意：**
>
> - 此接口会一次性解码全部帧，当帧数过多或单帧图像过大时，会占用较大内存，造成系统内存紧张，此种情况推荐使用Image组件显示动图，Image组件采用逐帧解码，占用内存比此接口少。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|options|[DecodingOptions](#class-decodingoptions)|否|DecodingOptions()|**命名参数。** 解码参数。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[PixelMap](#class-pixelmap)>|返回PixeMap数组。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980096 | The operation failed. Possible cause: 1.Image upload exception. 2. Decoding process exception. 3. Insufficient memory. |
  | 62980099 | The shared memory data is abnormal. |
  | 62980101 | The image data is abnormal. |
  | 62980102 | Failed to malloc memory. |
  | 62980103 | The image data is not supported. |
  | 62980104 | Failed to initialize the internal object. |
  | 62980106 | The image data is too large. This status code is thrown when an error occurs during the process of checking size. |
  | 62980109 | Failed to crop the image. |
  | 62980111 | The image source data is incomplete. |
  | 62980115 | Invalid image parameter. |
  | 62980116 | Failed to decode the image. |
  | 62980118 | Failed to create the image plugin. |
  | 62980137 | Invalid media operation. |
  | 62980173 | The DMA memory does not exist. |
  | 62980174 | The DMA memory data is abnormal. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let option = DecodingOptions(
        sampleSize: 1,
        rotate: 10,
        editable: true,
        desiredSize: Size(3, 4),
        desiredRegion: Region(Size(3, 4), 0, 0),
        desiredPixelFormat: PixelMapFormat.Rgba8888,
        index: 0,
        fitDensity: 20
    )
    let pixelMap = imageSourceApi.createPixelMapList(options: option)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getDelayTimeList()

```cangjie
public func getDelayTimeList(): Array<Int32>
```

**功能：** 获取图像延迟时间数组。此接口仅用于gif图片和webp图片。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<Int32>|返回延迟时间数组。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980096 | The operation failed. Possible cause: 1.Image upload exception. 2. Decoding process exception. 3. Insufficient memory. |
  | 62980102 | Failed to malloc memory. |
  | 62980104 | Failed to initialize the internal object. |
  | 62980110 | The image source data is incorrect. |
  | 62980111 | The image source data is incomplete. |
  | 62980115 | Invalid image parameter. |
  | 62980116 | Failed to decode the image. |
  | 62980118 | Failed to create the image plugin. |
  | 62980122 | Failed to decode the image header. |
  | 62980149 | Invalid MIME type for the image source. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let list = imageSourceApi.getDelayTimeList()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getFrameCount()

```cangjie
public func getFrameCount(): UInt32
```

**功能：** 获取图像帧数。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|UInt32|返回图像帧数。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980096 | The operation failed. Possible cause: 1.Image upload exception. 2. Decoding process exception. 3. Insufficient memory. |
  | 62980104 | Failed to initialize the internal object. |
  | 62980111 | The image source data is incomplete. |
  | 62980112 | The image format does not match. |
  | 62980113 | Unknown image format. The image data provided is not in a recognized or supported format, or it may be occorrupted. |
  | 62980115 | Invalid image parameter. |
  | 62980116 | Failed to decode the image. |
  | 62980118 | Failed to create the image plugin. |
  | 62980122 | Failed to decode the image header. |
  | 62980137 | Invalid media operation. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let count = imageSourceApi.getFrameCount()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getImageInfo(UInt32)

```cangjie
public func getImageInfo(index!: UInt32 = 0): ImageInfo
```

**功能：** 获取指定序号的图片信息。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|index|UInt32|否|0|**命名参数。** 创建ImageSource时的序号。默认值为0，表示第一张图片。当取值为N时，表示第N+1张图片。单帧图片场景中index取值只能为0，动图等多帧图片场景中index的取值范围为：0~（帧数-1）。|

**返回值：**

|类型|说明|
|:----|:----|
|[ImageInfo](#class-imageinfo)|返回获取到的图片信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    imageSourceApi.getImageInfo(index : 0)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getImageProperty(PropertyKey, ImagePropertyOptions)

```cangjie
public func getImageProperty(key: PropertyKey, options!: ImagePropertyOptions = ImagePropertyOptions()): String
```

**功能：** 获取图片中给定索引处图像的指定属性键的值。

该接口仅支持JPEG、PNG、HEIF和WEBP（不同硬件设备支持情况不同）文件，且需要包含Exif信息。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|key|[PropertyKey](#enum-propertykey)|是|-|图片属性名。|
|options|[ImagePropertyOptions](#class-imagepropertyoptions)|否|ImagePropertyOptions()|**命名参数。** 图片属性，包括图片序号与默认属性值。|

**返回值：**

|类型|说明|
|:----|:----|
|String|返回图片属性值，如获取失败则返回属性默认值。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980096 | The operation failed. Possible cause: 1.Image upload exception. 2. Decoding process exception. 3. Insufficient memory. |
  | 62980103 | The image data is not supported. |
  | 62980104 | Failed to initialize the internal object. |
  | 62980110 | The image source data is incorrect. |
  | 62980111 | The image source data is incomplete. |
  | 62980112 | The image format does not match. |
  | 62980113 | Unknown image format. The image data provided is not in a recognized or supported format, or it may be occorrupted. |
  | 62980115 | Invalid image parameter. |
  | 62980118 | Failed to create the image plugin. |
  | 62980122 | Failed to decode the image header. |
  | 62980123 | The image does not support EXIF decoding. |
  | 62980135 | The EXIF value is invalid. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let value = imageSourceApi.getImageProperty(PropertyKey.ImageLength)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func modifyImageProperty(PropertyKey, String)

```cangjie
public func modifyImageProperty(key: PropertyKey, value: String): Unit
```

**功能：** 通过指定的键修改图片属性的值。

该接口仅支持JPEG、PNG、HEIF和WEBP（不同硬件设备支持情况不同）文件，且需要包含Exif信息。

> **说明：**
>
> 调用modifyImageProperty修改属性会改变属性字节长度，使用buffer创建的ImageSource调用modifyImageProperty会导致buffer内容覆盖，目前buffer创建的ImageSource不支持调用此接口，请改用fd或path创建的ImageSource。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|key|[PropertyKey](#enum-propertykey)|是|-|图片属性名。|
|value|String|是|-|属性值。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |
  | 62980110 | The image source data is incorrect. |
  | 62980115 | Parameter error.Possible causes: 1.Mandatory parameters are left unspecified; 2.Incorrect parameter types. |
  | 62980123 | The image does not support EXIF decoding. |
  | 62980133 | The EXIF data is out of range. |
  | 62980135 | The EXIF value is invalid. |
  | 62980146 | The EXIF data failed to be written to the file. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    imageSourceApi.modifyImageProperty(PropertyKey.ImageLength, "200")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func release()

```cangjie
public func release(): Unit
```

**功能：** 释放ImageSource实例。

> **说明：**
>
> 由于图片占用内存较大，所以当ImageSource实例使用完成后，应主动调用该方法，及时释放内存。释放时应确保后续不再使用该实例。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    imageSourceApi.release()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func updateData(Array\<UInt8>, Bool, UInt32, UInt32)

```cangjie
public func updateData(buf: Array<UInt8>, isFinished: Bool, offset: UInt32, length: UInt32): Unit
```

**功能：** 更新增量数据。

**系统能力：** SystemCapability.Multimedia.Image.ImageSource

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|buf|Array\<UInt8>|是|-|存放增量数据的buffer。|
|isFinished|Bool|是|-|true表示数据更新完成，当前buffer内存放最后一段数据；false表示数据还未更新完成，需要继续更新。|
|offset|UInt32|是|-|即当前buffer中的数据首地址，相对于整个图片文件首地址的偏移量。单位：字节。|
|length|UInt32|是|-|当前buffer的长度。单位：字节。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let testPng = Array<UInt8>(16500, repeat: 0)
    let bufferSize = 5000
    var offset = 0
    var isFinished = false
    while (offset < testPng.size) {
        var oneStep = testPng.slice(offset, min(bufferSize, testPng.size - offset))
        if (oneStep.size < bufferSize) {
            isFinished = true
        }
        imageSourceApi.updateData(oneStep, isFinished, 0, UInt32(oneStep.size))
        offset = offset + oneStep.size
    }
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class InitializationOptions

```cangjie
public class InitializationOptions {
    public var alphaType: AlphaType
    public var editable: Bool
    public var srcPixelFormat: PixelMapFormat
    public var pixelFormat: PixelMapFormat
    public var scaleMode: ScaleMode
    public var size: Size
    public init(size: Size, alphaType!: AlphaType = AlphaType.Premul, editable!: Bool = false, srcPixelFormat!: PixelMapFormat = PixelMapFormat.Bgra8888,
        pixelFormat!: PixelMapFormat = PixelMapFormat.Rgba8888, scaleMode!: ScaleMode = ScaleMode.FitTargetSize)
}
```

**功能：** PixelMap的初始化选项。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var alphaType

```cangjie
public var alphaType: AlphaType
```

**功能：** 透明度。

**类型：** [AlphaType](#enum-alphatype)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var editable

```cangjie
public var editable: Bool
```

**功能：** true表示可编辑，false表示不可编辑。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var pixelFormat

```cangjie
public var pixelFormat: PixelMapFormat
```

**功能：** 像素格式。

**类型：** [PixelMapFormat](#enum-pixelmapformat)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var scaleMode

```cangjie
public var scaleMode: ScaleMode
```

**功能：** 缩略值。

**类型：** [ScaleMode](#enum-scalemode)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var size

```cangjie
public var size: Size
```

**功能：** 创建图片大小。

**类型：** [Size](#class-size)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var srcPixelFormat

```cangjie
public var srcPixelFormat: PixelMapFormat
```

**功能：** 传入的buffer数据的像素格式。

**类型：** [PixelMapFormat](#enum-pixelmapformat)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### init(Size, AlphaType, Bool, PixelMapFormat, PixelMapFormat, ScaleMode)

```cangjie
public init(size: Size, alphaType!: AlphaType = AlphaType.Premul, editable!: Bool = false, srcPixelFormat!: PixelMapFormat = PixelMapFormat.Bgra8888,
    pixelFormat!: PixelMapFormat = PixelMapFormat.Rgba8888, scaleMode!: ScaleMode = ScaleMode.FitTargetSize)
```

**功能：** 创建InitializationOptions对象。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|size|[Size](#class-size)|是|-|**命名参数。** 创建图片大小。|
|alphaType|[AlphaType](#enum-alphatype)|否|AlphaType.Premul|**命名参数。** 透明度。默认值为AlphaType.Premul。|
|editable|Bool|否|false|**命名参数。** true表示可编辑，false表示不可编辑。默认值为false。|
|srcPixelFormat|[PixelMapFormat](#enum-pixelmapformat)|否|PixelMapFormat.Bgra8888|**命名参数。** 传入的buffer数据的像素格式。默认值为PixelMapFormat.Bgra8888。|
|pixelFormat|[PixelMapFormat](#enum-pixelmapformat)|否|PixelMapFormat.Rgba8888|**命名参数。**  生成的pixelMap的像素格式。默认值为PixelMapFormat.Rgba8888。|
|scaleMode|[ScaleMode](#enum-scalemode)|否|ScaleMode.FitTargetSize|**命名参数。** 缩略值。默认值为ScaleMode.FitTargetSize。|

## class PackingOption

```cangjie
public class PackingOption {
    public var format: String
    public var quality: UInt8
    public var bufferSize: UInt64
    public var desiredDynamicRange: PackingDynamicRange
    public var needsPackProperties: Bool
    public init(format: String, quality: UInt8, bufferSize!: UInt64 = 0,
        desiredDynamicRange!: PackingDynamicRange = Sdr, needsPackProperties!: Bool = false)
}
```

**功能：** 表示图片打包选项。

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

### var bufferSize

```cangjie
public var bufferSize: UInt64
```

**功能：** 接收编码数据的缓冲区大小，单位为Byte。如果不设置大小，默认为25M。如果编码图片超过25M，需要指定大小。bufferSize需大于编码后图片大小。使用[packToFile](#func-packtofileimagesource-int32-packingoption)不受此参数限制。

**类型：** UInt64

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

### var desiredDynamicRange

```cangjie
public var desiredDynamicRange: PackingDynamicRange
```

**功能：** 目标动态范围。

**类型：** [PackingDynamicRange](#enum-packingdynamicrange)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

### var format

```cangjie
public var format: String
```

**功能：** 目标格式。

当前只支持"image/jpeg"、"image/webp"、"image/png"和"image/heic(或者image/heif)"、"image/sdr_astc_4x4"、"image/sdr_sut_superfast_4x4"（不同硬件设备支持情况不同）、"image/hdr_astc_4x4"。

> **说明：**
>
> 因为jpeg不支持透明通道，若使用带透明通道的数据编码jpeg格式，透明色将变为黑色。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

### var needsPackProperties

```cangjie
public var needsPackProperties: Bool
```

**功能：** 是否需要编码图片属性信息，例如EXIF。true表示需要，false表示不需要。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

### var quality

```cangjie
public var quality: UInt8
```

**功能：** 编码中设定输出图片质量的参数，该参数仅对JPEG图片和HEIF图片生效。取值范围：[0, 100]。0质量最低，100质量最高，质量越高生成图片所占空间越大。WebP、PNG等图片均为无损编码。

1. sdr_astc_4x4编码中，可以设定输出图片质量的参数，可选参数：92、85。

2. sut编码中，设定输出图片质量可选参数：92。

3. hdr_astc_4x4编码中，可以设定输出图片质量的参数，可选参数：85。

**类型：** UInt8

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

### init(String, UInt8, UInt64, PackingDynamicRange, Bool)

```cangjie
public init(format: String, quality: UInt8, bufferSize!: UInt64 = 0,
    desiredDynamicRange!: PackingDynamicRange = Sdr, needsPackProperties!: Bool = false)
```

**功能：** 创建PackingOption对象。

**系统能力：** SystemCapability.Multimedia.Image.ImagePacker

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|format|String|是|-|目标格式。|
|quality|UInt8|是|-|1. 编码中设定输出图片质量的参数，该参数仅对JPEG图片和HEIF图片生效。取值范围：[0, 100]。0质量最低，100质量最高，质量越高生成图片所占空间越大。WebP、PNG等图片均为无损编码。<br> 2.sdr_astc_4x4编码中，可以设定输出图片质量的参数，可选参数：92、85。<br>3. sut编码中，设定输出图片质量可选参数：92。<br>4. hdr_astc_4x4编码中，可以设定输出图片质量的参数，可选参数：85。|
|bufferSize|UInt64|否|0|**命名参数。** 接收编码数据的缓冲区大小，单位为Byte。如果不设置大小，默认为25M。如果编码图片超过25M，需要指定大小。bufferSize需大于编码后图片大小。使用[packToFile](#func-packtofileimagesource-int32-packingoption)不受此参数限制。|
|desiredDynamicRange|[PackingDynamicRange](#enum-packingdynamicrange)|否|Sdr|**命名参数。** 目标动态范围。默认值为Sdr。|
|needsPackProperties|Bool|否|false|**命名参数。** 是否需要编码图片属性信息，例如EXIF。true表示需要，false表示不需要。默认值为false。|

## class PixelMap

```cangjie
public class PixelMap {}
```

**功能：** 图像像素类，用于读取或写入图像数据以及获取图像信息。在调用PixelMap的方法前，需要先通过[createPixelMap](#func-createpixelmaparrayuint8-initializationoptions)创建一个PixelMap实例。目前pixelmap序列化大小最大128MB，超过会送显失败。大小计算方式为(宽\*高\*每像素占用字节数)。

在调用PixelMap的方法前，需要先通过[createPixelMap](#func-createpixelmaparrayuint8-initializationoptions)构建一个PixelMap对象。

图片使用的内存往往较大，在PixelMap对象使用完成后，应主动调用[release](#func-release-4)方法及时释放内存。释放时应确保后续不再使用该对象。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### prop isEditable

```cangjie
public prop isEditable: Bool
```

**功能：**  图像像素是否可被编辑。true表示可被编辑，false表示不可被编辑。为false时，图像的渲染和传输性能更好。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

### prop isStrideAlignment

```cangjie
public prop isStrideAlignment: Bool
```

**功能：** 图像的行数据是否已进行内存对齐。true表示已进行内存对齐，每行数据的末尾可能有空白字节填充以满足对齐要求；false表示未进行内存对齐，每行数据紧密排列，末尾无空白字节填充。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

### func applyColorSpace(ColorSpaceManager)

```cangjie
public func applyColorSpace(targetColorSpace: ColorSpaceManager): Unit
```

**功能：** 根据输入的目标色彩空间对图像像素颜色进行色彩空间转换。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|targetColorSpace|[ColorSpaceManager](../ArkGraphics2D/cj-apis-color_manager.md#class-colorspacemanager)|是|-|目标色彩空间，支持Srgb、DciP3、DisplayP3、AdobeRgb1998。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |
  | 62980108 | Failed to convert the color space. |
  | 62980115 | Invalid image parameter. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import kit.ArkGraphics2D.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let colorSpaceManager = create(Srgb)
    pixelMap.applyColorSpace(colorSpaceManager)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func createAlphaPixelMap()

```cangjie
public func createAlphaPixelMap(): PixelMap
```

**功能：** 根据Alpha通道的信息，来生成一个仅包含Alpha通道信息的pixelmap，可用于阴影效果，yuv格式不支持此接口。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[PixelMap](#class-pixelmap)|返回pixelmap实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let alphaPixelmap = pixelMap.createAlphaPixelMap()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func crop(Region)

```cangjie
public func crop(region: Region): Unit
```

**功能：** 根据输入的尺寸对图片进行裁剪。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|region|[Region](#class-region)|是|-|裁剪的尺寸。取值范围不能超过图片的宽高。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let region: Region = Region(Size(100, 100), 0, 0)
    pixelMap.crop(region)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func flip(Bool, Bool)

```cangjie
public func flip(horizontal: Bool, vertical: Bool): Unit
```

**功能：** 根据输入的条件对图片进行翻转。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|horizontal|Bool|是|-|true表示进行水平翻转，false表示不进行水平翻转。|
|vertical|Bool|是|-|true表示进行垂直翻转，false表示不进行垂直翻转。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let horizontal: Bool = true
    let vertical: Bool = false
    pixelMap.flip(horizontal, vertical)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getBytesNumberPerRow()

```cangjie
public func getBytesNumberPerRow(): UInt32
```

**功能：** 获取图像像素每行字节数。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|UInt32|图像像素的行字节数。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let rowCount : UInt32 = pixelMap.getBytesNumberPerRow()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getColorSpace()

```cangjie
public func getColorSpace(): ColorSpaceManager
```

**功能：** 获取图像广色域信息。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[ColorSpaceManager](../ArkGraphics2D/cj-apis-color_manager.md#class-colorspacemanager)|图像广色域信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980101 | If the image data abnormal. |
  | 62980103 | If the image data unsupport. |
  | 62980104 | Failed to initialize the internal object. |
  | 62980115 | If the image parameter invalid. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import kit.ArkGraphics2D.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let colorSpaceManager = pixelMap.getColorSpace()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getDensity()

```cangjie
public func getDensity(): Int32
```

**功能：** 获取当前图像像素的密度。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Int32|图像像素的密度，单位为ppi。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let getDensity : Int32 = pixelMap.getDensity()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getImageInfo()

```cangjie
public func getImageInfo(): ImageInfo
```

**功能：** 获取图像像素信息。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[ImageInfo](#class-imageinfo)|返回图像像素信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    pixelMap.getImageInfo()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getPixelBytesNumber()

```cangjie
public func getPixelBytesNumber(): UInt32
```

**功能：** 获取图像像素的总字节数。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|UInt32|图像像素的总字节数。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let pixelBytesNumber : UInt32 = pixelMap.getPixelBytesNumber()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func opacity(Float32)

```cangjie
public func opacity(rate: Float32): Unit
```

**功能：** 通过设置透明比率来让PixelMap达到对应的透明效果，yuv图片不支持设置透明度。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|rate|Float32|是|-|透明比率的值，取值范围是(0.0,1.0]。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let rate: Float32 = 0.5
    pixelMap.opacity(rate)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func readPixels(PositionArea)

```cangjie
public func readPixels(area: PositionArea): Unit
```

**功能：** 按照PixelMap的像素格式，读取PixelMap的图像像素数据，并写入缓冲区中。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|area|[PositionArea](#class-positionarea)|是|-|缓冲区，函数执行结束后获取的图像像素数据写入到该内存区域内。缓冲区大小由[getPixelBytesNumber](#func-getpixelbytesnumber)接口获取。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let area: PositionArea = PositionArea(
        Array<UInt8>(8, repeat: 0),
        0,
        8,
        Region(Size(1, 2), 0, 0)
    )
    pixelMap.readPixels(area)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func readPixelsToBuffer(Array\<UInt8>)

```cangjie
public func readPixelsToBuffer(dst: Array<UInt8>): Unit
```

**功能：** 按照PixelMap的像素格式，读取PixelMap的图像像素数据，并写入缓冲区中。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|dst|Array\<UInt8>|是|-|缓冲区，函数执行结束后获取的图像像素数据写入到该内存区域内。缓冲区大小由[getPixelBytesNumber](#func-getpixelbytesnumber)接口获取。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let readBuffer: Array<UInt8> = Array<UInt8>(96, repeat: 0) //96为需要创建的像素buffer大小，取值为：height * width *4
    pixelMap.readPixelsToBuffer(readBuffer)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func release()

```cangjie
public func release(): Unit
```

**功能：** 释放PixelMap对象（释放后，任何访问该对象内部数据的方法调用都会失败）。

图片使用的内存往往较大，在PixelMap对象使用完成后，应主动调用该方法及时释放内存。

释放时应确保后续不再使用该对象。

> **注意：**
>
> 释放指的是Cangjie对象释放与之关联的native对象的管理权。仅当所有管理该native对象的ArkTS对象都被释放时，native对象占用的内存才会被回收。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    pixelMap.release()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func rotate(Float32)

```cangjie
public func rotate(angle: Float32): Unit
```

**功能：** 根据输入的角度对图片进行旋转。

> **说明：**
>
> 1. 图片旋转的角度取值范围：0-360。超出取值范围时，根据圆周360度自动矫正。例如，-100度与260度效果相同。
> 2. 如果图片旋转的角度不是90的整数倍，旋转后图片的尺寸会发生改变。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|angle|Float32|是|-|图片旋转的角度。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let angle: Float32 = 90.0
    pixelMap.rotate(angle)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func scale(Float32, Float32)

```cangjie
public func scale(x: Float32, y: Float32): Unit
```

**功能：** 根据输入的宽高的缩放倍数对图片进行缩放。

> **说明：**
>
> 1. 建议宽高的缩放倍数取非负数，否则会产生翻转效果。
> 2. 宽高的缩放倍数 = 缩放后的图片宽高 / 缩放前的图片宽高。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|Float32|是|-|宽度的缩放倍数。|
|y|Float32|是|-|高度的缩放倍数。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    pixelMap.scale(1.0, 1.0)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setColorSpace(ColorSpaceManager)

```cangjie
public func setColorSpace(colorSpace: ColorSpaceManager): Unit
```

**功能：** 设置图像广色域信息。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|colorSpace|[ColorSpaceManager](../ArkGraphics2D/cj-apis-color_manager.md#class-colorspacemanager)|是|-|图像广色域信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |
  | 62980111 | The image source data is incomplete. |
  | 62980115 | If the image parameter invalid. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import kit.ArkGraphics2D.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let colorSpaceManager = create(Srgb)
    pixelMap.setColorSpace(colorSpaceManager)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func translate(Float32, Float32)

```cangjie
public func translate(x: Float32, y: Float32): Unit
```

**功能：** 根据输入的坐标对图片进行位置变换。

translate后的图片尺寸改变为：width+X ，height+Y，建议translate后的图片尺寸宽高不要超过屏幕的宽高。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|Float32|是|-|区域横坐标。单位：像素。|
|y|Float32|是|-|区域纵坐标。单位：像素。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let translateX: Float32 = 50.0
    let translateY: Float32 = 10.0
    pixelMap.translate(translateX, translateY)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func writeBufferToPixels(Array\<UInt8>)

```cangjie
public func writeBufferToPixels(src: Array<UInt8>): Unit
```

**功能：** 按照PixelMap的像素格式，读取缓冲区中的图像像素数据，并写入PixelMap。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|src|Array\<UInt8>|是|-|缓冲区，函数执行时会将该缓冲区中的图像像素数据写入到PixelMap。缓冲区大小由[getPixelBytesNumber](#func-getpixelbytesnumber)接口获取。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let color: Array<UInt8> = Array<UInt8>(96, {i => UInt8(i)}) //96为需要创建的像素buffer大小，取值为：height * width *4
    pixelMap.writeBufferToPixels(color)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func writePixels(PositionArea)

```cangjie
public func writePixels(area: PositionArea): Unit
```

**功能：** 固定按照BGRA_8888格式，读取[PositionArea](#class-positionarea).pixels缓冲区中的图像像素数据，并写入PixelMap指定区域内，该区域由[PositionArea](#class-positionarea).region指定。

可用公式计算PositionArea需要申请的内存大小。

YUV的区域计算公式：读取区域（region.size{width * height}）* 1.5 （1倍的Y分量+0.25倍U分量+0.25倍V分量）

RGBA的区域计算公式：读取区域（region.size{width * height}）* 4 （1倍的R分量+1倍G分量+1倍B分量+1倍A分量）

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|area|[PositionArea](#class-positionarea)|是|-|区域，根据区域写入。|

**异常：**

- BusinessException：对应错误码如下表，详见[Image错误码](./cj-errorcode-image.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 62980104 | Failed to initialize the internal object. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ImageKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let data: Array<UInt8> = Array<UInt8>(112, repeat: 0)
    let sourceOptions: SourceOptions = SourceOptions(120)
    let imageSourceApi: ImageSource = createImageSource(data, sourceOptions)  // 请替换为正确的图片源，参考本文使用说明。
    let pixelMap = imageSourceApi.createPixelMap()
    let area: PositionArea = PositionArea(
        Array<UInt8>(8, {i => UInt8(i)}),
        0,
        8,
        Region(Size(1, 2), 0, 0)
    )
    pixelMap.writePixels(area)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class PositionArea

```cangjie
public class PositionArea {
    public var pixels: Array<UInt8>
    public var offset: UInt32
    public var stride: UInt32
    public var region: Region
    public init(pixels: Array<UInt8>, offset: UInt32, stride: UInt32, region: Region)
}
```

**功能：** 表示图片指定区域内的数据。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var offset

```cangjie
public var offset: UInt32
```

**功能：** 偏移量。单位：字节。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var pixels

```cangjie
public var pixels: Array<UInt8>
```

**功能：** 像素。仅支持BGRA_8888格式的图像像素数据。

**类型：** Array\<UInt8>

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var region

```cangjie
public var region: Region
```

**功能：** 区域，按照区域读写。写入的区域宽度加X坐标不能大于原图的宽度，写入的区域高度加Y坐标不能大于原图的高度。

**类型：** [Region](#class-region)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var stride

```cangjie
public var stride: UInt32
```

**功能：** 跨距，内存中每行像素所占的空间。stride >= region.size.width*4。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### init(Array\<UInt8>, UInt32, UInt32, Region)

```cangjie
public init(pixels: Array<UInt8>, offset: UInt32, stride: UInt32, region: Region)
```

**功能：** 创建PositionArea对象。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|pixels|Array\<UInt8>|是|-|像素。仅支持BGRA_8888格式的图像像素数据。|
|offset|UInt32|是|-|偏移量。单位：字节。|
|stride|UInt32|是|-|跨距，内存中每行像素所占的空间。stride >= region.size.width*4。|
|region|[Region](#class-region)|是|-|区域，按照区域读写。写入的区域宽度加X坐标不能大于原图的宽度，写入的区域高度加Y坐标不能大于原图的高度。|

## class Region

```cangjie
public class Region {
    public var size: Size
    public var x: Int32
    public var y: Int32
    public init(size: Size, x: Int32, y: Int32)
}
```

**功能：** 表示区域信息。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var size

```cangjie
public var size: Size
```

**功能：** 区域大小。

**类型：** [Size](#class-size)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var x

```cangjie
public var x: Int32
```

**功能：** 区域左上角横坐标。单位：像素。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var y

```cangjie
public var y: Int32
```

**功能：** 区域左上角纵坐标。单位：像素。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### init(Size, Int32, Int32)

```cangjie
public init(size: Size, x: Int32, y: Int32)
```

**功能：** 创建Region对象。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|size|[Size](#class-size)|是|-|区域大小。|
|x|Int32|是|-|区域左上角横坐标。单位：像素。|
|y|Int32|是|-|区域左上角纵坐标。单位：像素。|

## class Size

```cangjie
public class Size {
    public var height: Int32
    public var width: Int32
    public init(height: Int32, width: Int32)
}
```

**功能：** 表示图片尺寸。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var height

```cangjie
public var height: Int32
```

**功能：** 输出图片的高，单位：像素。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var width

```cangjie
public var width: Int32
```

**功能：** 输出图片的宽，单位：像素。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### init(Int32, Int32)

```cangjie
public init(height: Int32, width: Int32)
```

**功能：** 创建Size对象。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|height|Int32|是|-|输出图片的高，单位：像素。|
|width|Int32|是|-|输出图片的宽，单位：像素。|

## class SourceOptions

```cangjie
public class SourceOptions {
    public var sourceDensity: Int32
    public var sourcePixelFormat: PixelMapFormat
    public var sourceSize: Size
    public init(sourceDensity: Int32, sourcePixelFormat!: PixelMapFormat = PixelMapFormat.Unknown, sourceSize!: Size = Size(0, 0))
}
```

**功能：** ImageSource的初始化选项。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var sourceDensity

```cangjie
public var sourceDensity: Int32
```

**功能：** 图片资源像素密度，单位为ppi。

在解码参数[DecodingOptions](#class-decodingoptions)未设置desiredSize的前提下，当前参数SourceOptions.sourceDensity与DecodingOptions.fitDensity非零时将对解码输出的pixelmap进行缩放。

缩放后宽计算公式如下(高同理)：(width * fitDensity + (sourceDensity >> 1)) / sourceDensity。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var sourcePixelFormat

```cangjie
public var sourcePixelFormat: PixelMapFormat
```

**功能：** 图片像素格式。

**类型：** [PixelMapFormat](#enum-pixelmapformat)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### var sourceSize

```cangjie
public var sourceSize: Size
```

**功能：** 图像像素大小。

**类型：** [Size](#class-size)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### init(Int32, PixelMapFormat, Size)

```cangjie
public init(sourceDensity: Int32, sourcePixelFormat!: PixelMapFormat = PixelMapFormat.Unknown, sourceSize!: Size = Size(0, 0))
```

**功能：** 创建SourceOptions对象。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|sourceDensity|Int32|是|-|图片资源像素密度，单位为ppi。|
|sourcePixelFormat|[PixelMapFormat](#enum-pixelmapformat)|否|PixelMapFormat.Unknown|**命名参数。** 图片像素格式，默认值为PixelMapFormat.Unknown。|
|sourceSize|[Size](#class-size)|否|Size(0, 0)|**命名参数。** 图像像素大小，默认值为空。|

## enum AlphaType

```cangjie
public enum AlphaType <: Equatable<AlphaType> & ToString {
    | Unknown
    | Opaque
    | Premul
    | UnPremul
    | ...
}
```

**功能：** 枚举，图像的透明度类型。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**父类型：**

- Equatable\<AlphaType>
- ToString

### Opaque

```cangjie
Opaque
```

**功能：** 没有alpha或图片不透明。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Premul

```cangjie
Premul
```

**功能：** RGB预乘alpha。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### UnPremul

```cangjie
UnPremul
```

**功能：** RGB非预乘alpha。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Unknown

```cangjie
Unknown
```

**功能：** 未知透明度。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### func !=(AlphaType)

```cangjie
public operator func !=(other: AlphaType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AlphaType](#enum-alphatype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(AlphaType)

```cangjie
public operator func ==(other: AlphaType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AlphaType](#enum-alphatype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum ComponentType

```cangjie
public enum ComponentType <: Equatable<ComponentType> & ToString {
    | YuvY
    | YuvU
    | YuvV
    | Jpeg
    | ...
}
```

**功能：** 枚举，图像的组件类型。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

**父类型：**

- Equatable\<ComponentType>
- ToString

### Jpeg

```cangjie
Jpeg
```

**功能：** JPEG 类型。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

### YuvU

```cangjie
YuvU
```

**功能：** 色度信息。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

### YuvV

```cangjie
YuvV
```

**功能：** 色度信息。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

### YuvY

```cangjie
YuvY
```

**功能：** 亮度信息。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

### func !=(ComponentType)

```cangjie
public operator func !=(other: ComponentType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ComponentType](#enum-componenttype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(ComponentType)

```cangjie
public operator func ==(other: ComponentType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ComponentType](#enum-componenttype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum DecodingDynamicRange

```cangjie
public enum DecodingDynamicRange <: Equatable<DecodingDynamicRange> & ToString {
    | Auto
    | Sdr
    | Hdr
    | ...
}
```

**功能：** 描述解码时期望的图像动态范围。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**父类型：**

- Equatable\<DecodingDynamicRange>
- ToString

### Auto

```cangjie
Auto
```

**功能：** 自适应，根据图片信息处理。即如果图片本身为HDR图片，则会按照HDR内容解码；反之按照SDR内容解码。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Hdr

```cangjie
Hdr
```

**功能：** 按照高动态范围处理图片。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Sdr

```cangjie
Sdr
```

**功能：** 按照标准动态范围处理图片。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### func !=(DecodingDynamicRange)

```cangjie
public operator func !=(other: DecodingDynamicRange): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DecodingDynamicRange](#enum-decodingdynamicrange)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(DecodingDynamicRange)

```cangjie
public operator func ==(other: DecodingDynamicRange): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DecodingDynamicRange](#enum-decodingdynamicrange)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum ImageFormat

```cangjie
public enum ImageFormat <: Equatable<ImageFormat> & ToString {
    | Ycbcr422Sp
    | Jpeg
    | ...
}
```

**功能：** 枚举，图片格式。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**父类型：**

- Equatable\<ImageFormat>
- ToString

### Jpeg

```cangjie
Jpeg
```

**功能：** JPEG编码格式。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Ycbcr422Sp

```cangjie
Ycbcr422Sp
```

**功能：** YCBCR422半平面格式。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### func !=(ImageFormat)

```cangjie
public operator func !=(other: ImageFormat): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageFormat](#enum-imageformat)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(ImageFormat)

```cangjie
public operator func ==(other: ImageFormat): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageFormat](#enum-imageformat)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum PackingDynamicRange

```cangjie
public enum PackingDynamicRange <: Equatable<PackingDynamicRange> & ToString {
    | Auto
    | Sdr
    | ...
}
```

**功能：** 描述编码时期望的图像动态范围。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**父类型：**

- Equatable\<PackingDynamicRange>
- ToString

### Auto

```cangjie
Auto
```

**功能：** 自适应，根据[pixelmap](#class-pixelmap)内容处理。即如果pixelmap本身为HDR，则会按照HDR内容进行编码；反之按照SDR内容编码。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Sdr

```cangjie
Sdr
```

**功能：** 按照标准动态范围处理图片。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### func !=(PackingDynamicRange)

```cangjie
public operator func !=(other: PackingDynamicRange): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PackingDynamicRange](#enum-packingdynamicrange)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(PackingDynamicRange)

```cangjie
public operator func ==(other: PackingDynamicRange): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PackingDynamicRange](#enum-packingdynamicrange)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum PixelMapFormat

```cangjie
public enum PixelMapFormat <: Equatable<PixelMapFormat> & ToString {
    | Unknown
    | Rgb565
    | Rgba8888
    | Bgra8888
    | Rgb888
    | Alpha8
    | RgbaF16
    | Nv21
    | Nv12
    | Rgba1010102
    | YcbcrP010
    | YcrcbP010
    | ...
}
```

**功能：** 枚举，图片像素格式。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**父类型：**

- Equatable\<PixelMapFormat>
- ToString

### Alpha8

```cangjie
Alpha8
```

**功能：** 颜色信息仅包含透明度（Alpha），每个像素占8位。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Bgra8888

```cangjie
Bgra8888
```

**功能：** 颜色信息由B（Blue），G（Green），R（Red）与透明度（Alpha）四部分组成，每个部分占8位，总共占32位。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Nv12

```cangjie
Nv12
```

**功能：** YUV像素排列，U分量在V分量之前。颜色信息由亮度分量Y和交错排列的色度分量U和V组成，其中Y分量占8位，UV分量因4：2：0采样平均占4位，总共平均占12位。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Nv21

```cangjie
Nv21
```

**功能：** YVU像素排列，V分量在U分量之前。颜色信息由亮度分量Y和交错排列的色度分量V和U组成，其中Y分量占8位，UV分量因4：2：0采样平均占4位，总共平均占12位。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Rgb565

```cangjie
Rgb565
```

**功能：** 颜色信息由R（Red），G（Green），B（Blue）三部分组成，R占5位，G占6位，B占5位，总共占16位。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Rgb888

```cangjie
Rgb888
```

**功能：** 颜色信息由R（Red），G（Green），B（Blue）三部分组成，每个部分占8位，总共占24位。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Rgba1010102

```cangjie
Rgba1010102
```

**功能：** 颜色信息由R（Red），G（Green），B（Blue）与透明度（Alpha）四部分组成，其中R、G、B分别占10位，透明度占2位，总共占32位。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Rgba8888

```cangjie
Rgba8888
```

**功能：** 颜色信息由R（Red），G（Green），B（Blue）与透明度（Alpha）四部分组成，每个部分占8位，总共占32位。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### RgbaF16

```cangjie
RgbaF16
```

**功能：** 颜色信息由R（Red），G（Green），B（Blue）与透明度（Alpha）四部分组成，每个部分占16位，总共占64位。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Unknown

```cangjie
Unknown
```

**功能：** 未知格式。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### YcbcrP010

```cangjie
YcbcrP010
```

**功能：** 颜色信息由亮度分量Y和色度分量Cb与Cr组成，每个分量有效10位，实际存储时，Y平面每个像素占16位数据（10位有效），UV平面交错排列，每4个像素占32位数据（每色度分量10位有效），平均有效占15位。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### YcrcbP010

```cangjie
YcrcbP010
```

**功能：** 颜色信息由亮度分量Y和色度分量Cr与Cb组成，每个分量有效10位，实际存储时，Y平面每个像素占16位数据（10位有效），UV平面交错排列，每4个像素占32位数据（每色度分量10位有效），平均有效占15位。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### func !=(PixelMapFormat)

```cangjie
public operator func !=(other: PixelMapFormat): Bool
```

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**功能：** 判断两个枚举值是否不相等。

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PixelMapFormat](#enum-pixelmapformat)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(PixelMapFormat)

```cangjie
public operator func ==(other: PixelMapFormat): Bool
```

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**功能：** 判断两个枚举值是否相等。

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PixelMapFormat](#enum-pixelmapformat)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**功能：** 获取枚举的值。

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum PropertyKey

```cangjie
public enum PropertyKey <: ToString {
    | BitsPerSample
    | Orientation
    | ImageLength
    | ImageWidth
    | GpsLatitude
    | GpsLongitude
    | GpsLatitudeRef
    | GpsLongitudeRef
    | DateTimeOriginal
    | ExposureTime
    | SceneType
    | IsoSpeedRatings
    | FNumber
    | DateTime
    | GpsTimestamp
    | GpsDateStamp
    | ImageDescription
    | Make
    | Model
    | PhotoMode
    | SensitivityType
    | StandardOutputSensitivity
    | RecommendedExposureIndex
    | IsoSpeed
    | ApertureValue
    | ExposureBiasValue
    | MeteringMode
    | LightSource
    | Flash
    | FocalLength
    | UserComment
    | PixelXDimension
    | PixelYDimension
    | WhiteBalance
    | FocalLengthIn35mmFilm
    | CaptureMode
    | PhysicalAperture
    | RollAngle
    | PitchAngle
    | SceneFoodConf
    | SceneStageConf
    | SceneBlueSkyConf
    | SceneGreenPlantConf
    | SceneBeachConf
    | SceneSnowConf
    | SceneSunsetConf
    | SceneFlowersConf
    | SceneNightConf
    | SceneTextConf
    | FaceCount
    | FocusMode
    | ...
}
```

**功能：** 枚举，Exif（Exchangeable image file format）图像信息。

- 格式示例中的key为：PropertyKey.XXX（XXX为枚举的名称，如：.PropertyKey.ImageWidth）。

- 格式示例仅用于说明修改传值和读取结果的格式。具体接口使用方法请参考：[modifyImageProperty](#func-modifyimagepropertypropertykey-string)（修改单个Exif字段）、[getImageProperty](#func-getimagepropertypropertykey-imagepropertyoptions)（读取单个Exif字段）。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**父类型：**

- ToString

### ApertureValue

```cangjie
ApertureValue
```

**功能：** 光圈值。格式如4/1。

修改传参格式说明：非负有理数字符串。

修改示例：`imageSource.modifyImageProperty(key,'5.6');`

读取结果示例："5.60 EV (f/7.0)"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### BitsPerSample

```cangjie
BitsPerSample
```

**功能：** 像素各分量的位数，如RGB，3分量，格式是8,8,8。

修改传参格式说明：三个非负整数字符串，空格或者英文逗号隔开。

修改示例：`imageSource.modifyImageProperty(key,'8 8 8');`或`imageSource.modifyImageProperty(key,'8,8,8');`

读取结果示例："8,8,8"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### CaptureMode

```cangjie
CaptureMode
```

**功能：** 捕获模式。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### DateTime

```cangjie
DateTime
```

**功能：** 日期时间。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### DateTimeOriginal

```cangjie
DateTimeOriginal
```

**功能：** 日期时间。

修改传参格式说明：有两种格式，YYYY:MM:DD或者YYYY:MM:DD HH:MM:SS

修改示例：`imageSource.modifyImageProperty(key,'2024:07:07 13:45:59');`<br />或`imageSource.modifyImageProperty(key,'2024:07:07');`

读取结果示例："2024:07:07 13:45:59"或"2024:07:07"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### ExposureBiasValue

```cangjie
ExposureBiasValue
```

**功能：** 曝光偏差值。

修改传参格式说明：非负有理数字符串。

修改示例：`imageSource.modifyImageProperty(key,'1');`

读取结果示例：1.00 EV

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### ExposureTime

```cangjie
ExposureTime
```

**功能：** 曝光时间，例如1/33 sec。

修改传参格式说明：非负有理数字符串。

修改示例：`imageSource.modifyImageProperty(key,'1');`或`imageSource.modifyImageProperty(key,'1/2');`

读取结果示例："1/33 sec."

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### FNumber

```cangjie
FNumber
```

**功能：** 光圈值，例如f/1.8。

修改传参格式说明：非负有理数字符串。

修改示例：`imageSource.modifyImageProperty(key,'1');`或`imageSource.modifyImageProperty(key,'1/2');`

读取结果示例："f/1.0"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### FaceCount

```cangjie
FaceCount
```

**功能：** 人脸数量。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Flash

```cangjie
Flash
```

**功能：** 闪光灯，记录闪光灯状态。

修改传参格式说明：修改时传入相应的数字或者字符串。

修改示例：`imageSource.modifyImageProperty(key,'0x00');`或`imageSource.modifyImageProperty(key,'Flash did not fire');`

读取结果示例："Flash did not fire"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### FocalLength

```cangjie
FocalLength
```

**功能：** 焦距。

修改传参格式说明：非负有理数字符串。

修改示例：`imageSource.modifyImageProperty(key,'50');`或`imageSource.modifyImageProperty(key,'50/1');`

读取结果示例："50.0 mm"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### FocalLengthIn35mmFilm

```cangjie
FocalLengthIn35mmFilm
```

**功能：** 焦距35毫米胶片。

修改传参格式说明：非负整数字符串。

修改示例：`imageSource.modifyImageProperty(key,'50');`

读取结果示例：*"50"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### FocusMode

```cangjie
FocusMode
```

**功能：** 对焦模式。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### GpsDateStamp

```cangjie
GpsDateStamp
```

**功能：** GPS日期戳。

修改传参格式说明：格式为“YY:MM:DD”。

修改示例：`imageSource.modifyImageProperty(key,'2020:07:07');`

读取结果示例："2020:07:07"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### GpsLatitude

```cangjie
GpsLatitude
```

**功能：** 图片纬度。修改时应按"度，分，秒"格式传入，如"39, 54, 7.542"

修改传参格式说明：三个非负有理数字符串，逗号隔开。

修改示例：`imageSource.modifyImageProperty(key,'39,54,7.542');`

读取结果示例："39,54,7.542"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### GpsLatitudeRef

```cangjie
GpsLatitudeRef
```

**功能：** 用于标识图像拍摄地点的纬度方向（北半球或南半球）。

78："North"。

83："South"。

修改传参格式说明： 修改时传入相应的数字或者字符串。

修改示例：`imageSource.modifyImageProperty(key,'78');`或`imageSource.modifyImageProperty(key,'North');`

读取结果示例："N"或"78"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### GpsLongitude

```cangjie
GpsLongitude
```

**功能：** 图片经度。修改时应按"度，分，秒"格式传入，如"116，19，42.16"

修改传参格式说明：三个非负有理数字符串，逗号隔开。

修改示例：`imageSource.modifyImageProperty(key,'116,19,42.16');`

读取结果示例："116,19,42.16"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### GpsLongitudeRef

```cangjie
GpsLongitudeRef
```

**功能：** 经度引用，例如W或E， 用于标识图像拍摄地点的经度方向（东半球或西半球）。

69："East"。

87："West"。

修改传参格式说明：修改时传入相应的数字或者字符串。

修改示例：`imageSource.modifyImageProperty(key,'69');`或`imageSource.modifyImageProperty(key,'East');`

读取结果示例："69"或"E"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### GpsTimestamp

```cangjie
GpsTimestamp
```

**功能：** GPS时间戳。

修改传参格式说明：格式为"HH:mm:ss.ddd"。

修改示例：`imageSource.modifyImageProperty(key,'12:30:30.123');`

读取结果示例："12:30:30.123"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### IsoSpeed

```cangjie
IsoSpeed
```

**功能：** ISO速度等级。

修改传参格式说明：非负整数字符串。

修改示例：`imageSource.modifyImageProperty(key,'3200');`

读取结果示例："3200"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### IsoSpeedRatings

```cangjie
IsoSpeedRatings
```

**功能：** ISO感光度，例如400。

修改传参格式说明：非负整数字符串。

修改示例：`imageSource.modifyImageProperty(key,'3200');`

读取结果示例："3200"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### ImageDescription

```cangjie
ImageDescription
```

**功能：** 图像信息描述。

修改传参格式说明：字符串。

修改示例：`imageSource.modifyImageProperty(key,'Image description info');`

读取结果示例："Image description info"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### ImageLength

```cangjie
ImageLength
```

**功能：** 图片长度。

修改传参格式说明：非负整数字符串。

修改示例：`imageSource.modifyImageProperty(key,'3072');`

读取结果示例："3072"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### ImageWidth

```cangjie
ImageWidth
```

**功能：** 图片宽度。

修改传参格式说明：非负整数字符串。

修改示例：`imageSource.modifyImageProperty(key,'4096');`

读取结果示例："4096"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### LightSource

```cangjie
LightSource
```

**功能：** 光源。例如Fluorescent。

修改传参格式说明：修改时传入相应的数字或者字符串。

修改示例：`imageSource.modifyImageProperty(key,'1');`或`imageSource.modifyImageProperty(key,'Daylight');`

读取结果示例："Daylight"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Make

```cangjie
Make
```

**功能：** 生产商。

修改传参格式说明：字符串。

修改示例：`imageSource.modifyImageProperty(key,'Make');`

读取结果示例："Make"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### MeteringMode

```cangjie
MeteringMode
```

**功能：** 测光模式。

修改传参格式说明：修改时传入相应的数字或者字符串。

修改示例：`imageSource.modifyImageProperty(key,'1');`或`imageSource.modifyImageProperty(key,'Average');`

读取结果示例："Average"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Model

```cangjie
Model
```

**功能：** 设备型号。

修改传参格式说明：字符串。

修改示例：`imageSource.modifyImageProperty(key,'Model');`

读取结果示例："Model"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### Orientation

```cangjie
Orientation
```

**功能：** 图片方向。

1："Top-left"，图像未旋转。

2："Top-right"，镜像水平翻转。

3："Bottom-right"，图像旋转180°。

4："Bottom-left"，镜像垂直翻转。

5："Left-top"，镜像水平翻转再顺时针旋转270°。

6："Right-top"，顺时针旋转90°。

7："Right-bottom"，镜像水平翻转再顺时针旋转90°。

8："Left-bottom"，顺时针旋转270°。

如果读到未定义值会返回"Unknown Value 0"。获取该属性时会以字符串的形式返回。修改该属性时既可以以数字形式指定，也可以以字符串形式指定。

修改传参格式说明：修改时传入相应的数字或者字符串。

修改示例：`imageSource.modifyImageProperty(key,'1');`或`imageSource.modifyImageProperty(key,'Top-left');`

读取结果示例："Top-left"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### PhotoMode

```cangjie
PhotoMode
```

**功能：** 拍照模式。

修改传参格式说明：非负整数字符串。

修改示例：`imageSource.modifyImageProperty(key,'1');`

读取结果示例："1"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### PhysicalAperture

```cangjie
PhysicalAperture
```

**功能：** 物理孔径，光圈大小。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### PitchAngle

```cangjie
PitchAngle
```

**功能：** 俯仰角度。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### PixelXDimension

```cangjie
PixelXDimension
```

**功能：** 像素X尺寸。

修改传参格式说明：非负整数字符串。

修改示例：`imageSource.modifyImageProperty(key,'4096');`

读取结果示例："4096"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### PixelYDimension

```cangjie
PixelYDimension
```

**功能：** 像素Y尺寸。

修改传参格式说明：非负整数字符串。

修改示例：`imageSource.modifyImageProperty(key,'3072');`

读取结果示例："3072"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### RecommendedExposureIndex

```cangjie
RecommendedExposureIndex
```

**功能：** 推荐曝光指数。

修改传参格式说明：非负整数字符串。

修改示例：`imageSource.modifyImageProperty(key,'3200');`

读取结果示例："3200"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### RollAngle

```cangjie
RollAngle
```

**功能：** 滚动角度。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### SceneBeachConf

```cangjie
SceneBeachConf
```

**功能：** 拍照场景：沙滩。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### SceneBlueSkyConf

```cangjie
SceneBlueSkyConf
```

**功能：** 拍照场景：蓝天。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### SceneFlowersConf

```cangjie
SceneFlowersConf
```

**功能：** 拍照场景：花。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### SceneFoodConf

```cangjie
SceneFoodConf
```

**功能：** 拍照场景：食物。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### SceneGreenPlantConf

```cangjie
SceneGreenPlantConf
```

**功能：** 拍照场景：绿植。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### SceneNightConf

```cangjie
SceneNightConf
```

**功能：** 拍照场景：夜晚。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### SceneSnowConf

```cangjie
SceneSnowConf
```

**功能：** 拍照场景：下雪。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### SceneStageConf

```cangjie
SceneStageConf
```

**功能：** 拍照场景：舞台。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### SceneSunsetConf

```cangjie
SceneSunsetConf
```

**功能：** 拍照场景：日落。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### SceneTextConf

```cangjie
SceneTextConf
```

**功能：** 拍照场景：文本。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### SceneType

```cangjie
SceneType
```

**功能：** 拍摄场景模式，例如人像、风光、运动、夜景等。

1："Directly photographed"，图像传感器直接拍摄。

修改传参格式说明：修改时传入相应的数字或者字符串。

修改示例：`imageSource.modifyImageProperty(key,'1');`或`imageSource.modifyImageProperty(key,'Directly photographed');`

读取结果示例："Directly photographed"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### SensitivityType

```cangjie
SensitivityType
```

**功能：** 灵敏度类型。

修改传参格式说明：修改时传入相应的数字或者字符串。

修改示例：`imageSource.modifyImageProperty(key,'1');`或`imageSource.modifyImageProperty(key,'Standard output sensitivity (SOS)');`

读取结果示例："Standard output sensitivity (SOS)"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### StandardOutputSensitivity

```cangjie
StandardOutputSensitivity
```

**功能：** 标准输出灵敏度。

修改传参格式说明：非负整数字符串。

修改示例：`imageSource.modifyImageProperty(key,'400');`

读取结果示例："400"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### UserComment

```cangjie
UserComment
```

**功能：** 用户注释。

修改传参格式说明：字符串。

修改示例：`imageSource.modifyImageProperty(key,'User Comment');`

读取结果示例："User Comment"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### WhiteBalance

```cangjie
WhiteBalance
```

**功能：** 白平衡。

0："Auto white balance"，自动白平衡。

1："Manual white balance"，手动白平衡。

修改传参格式说明：修改时传入相应的数字或者字符串。

修改示例：`imageSource.modifyImageProperty(key,'0');`或`imageSource.modifyImageProperty(key,'Auto white balance');`

读取结果示例："Auto white balance"

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### func !=(PropertyKey)

```cangjie
public operator func !=(other: PropertyKey): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PropertyKey](#enum-propertykey)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(PropertyKey)

```cangjie
public operator func ==(other: PropertyKey): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PropertyKey](#enum-propertykey)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum ReceiveType

```cangjie
public enum ReceiveType {
    | ImageArrival
    | ...
}
```

**功能：** 接收图片时注册回调类型。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

### ImageArrival

```cangjie
ImageArrival
```

**功能：** 接收图片时事件类型。

**系统能力：** SystemCapability.Multimedia.Image.ImageReceiver

**起始版本：** 22

## enum ScaleMode

```cangjie
public enum ScaleMode <: Equatable<ScaleMode> & ToString {
    | FitTargetSize
    | CenterCrop
    | ...
}
```

**功能：** 图像的缩放模式。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**父类型：**

- Equatable\<ScaleMode>
- ToString

### CenterCrop

```cangjie
CenterCrop
```

**功能：** 缩放图像以填充目标图像区域并居中裁剪区域外的效果。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### FitTargetSize

```cangjie
FitTargetSize
```

**功能：** 图像适合目标尺寸的效果。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

### func !=(ScaleMode)

```cangjie
public operator func !=(other: ScaleMode): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScaleMode](#enum-scalemode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(ScaleMode)

```cangjie
public operator func ==(other: ScaleMode): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScaleMode](#enum-scalemode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Multimedia.Image.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## 补充说明

### SVG标签说明

支持SVG标签，使用版本为(SVG) 1.1，当前支持的标签列表有：

- a
- circle
- clipPath
- defs
- ellipse
- feBlend
- feColorMatrix
- feComposite
- feDiffuseLighting
- feDisplacementMap
- feDistantLight
- feFlood
- feGaussianBlur
- feImage
- feMorphology
- feOffset
- fePointLight
- feSpecularLighting
- feSpotLight
- feTurbulence
- filter
- g
- image
- line
- linearGradient
- mask
- path
- pattern
- polygon
- polyline
- radialGradient
- rect
- stop
- svg
- text
- textPath
- tspan
- use
