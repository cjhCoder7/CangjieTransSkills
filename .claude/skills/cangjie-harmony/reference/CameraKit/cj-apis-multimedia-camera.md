# ohos.multimedia.camera（相机管理）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

camera模块为开发者提供一套简单且易于理解的相机服务接口，开发者通过调用接口可以开发相机应用。应用通过访问和操作相机硬件，实现基础操作，如预览、拍照和录像；还可以通过接口组合完成更多操作，如控制闪光灯和曝光时间、对焦或调焦等。

## 导入模块

```cangjie
import kit.CameraKit.*
```

## 权限列表

ohos.permission.CAMERA

ohos.permission.MICROPHONE

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## func getCameraManager(UIAbilityContext)

```cangjie
public func getCameraManager(context: UIAbilityContext): CameraManager
```

**功能：** 获取相机管理器实例。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|[UIAbilityContext](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)|是|-|应用上下文。|

**返回值：**

|类型|说明|
|:----|:----|
|[CameraManager](#class-cameramanager)|相机管理器。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## interface AutoExposure

```cangjie
public interface AutoExposure <: AutoExposureQuery {
    func getExposureMode(): ExposureMode
    func setExposureMode(aeMode: ExposureMode): Unit
    func getMeteringPoint(): Point
    func setMeteringPoint(point: Point): Unit
    func setExposureBias(exposureBias: Float64): Unit
    func getExposureValue(): Float64
}
```

**功能：** 自动曝光类，对设备自动曝光（AE）操作。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- [AutoExposureQuery](#interface-autoexposurequery)

### func getExposureMode()

```cangjie
func getExposureMode(): ExposureMode
```

**功能：** 获取当前曝光模式。

> **说明：**
>
> 若未通过[setExposureMode](#func-setexposuremodeexposuremode)接口进行设置，直接调用该接口查询当前曝光模式，会返回无效值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[ExposureMode](#enum-exposuremode)|获取当前曝光模式。接口调用失败会抛出相应错误码。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    let photoSession = session as PhotoSession
    Hilog.info(0, "AppLogCj", photoSession.getOrThrow().getExposureMode().toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getExposureValue()

```cangjie
func getExposureValue(): Float64
```

**功能：** 查询当前曝光值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Float64|获取曝光值。曝光补偿存在步长，如步长为0.5。则设置1.2时，获取到实际生效曝光补偿为1.0。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    let photoSession = session as PhotoSession
    Hilog.info(0, "AppLogCj", photoSession.getOrThrow().getExposureValue().toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getMeteringPoint()

```cangjie
func getMeteringPoint(): Point
```

**功能：** 查询曝光区域中心点。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[Point](#class-point)|获取当前曝光点。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    let photoSession = session as PhotoSession
    let point = photoSession.getOrThrow().getMeteringPoint()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setExposureBias(Float64)

```cangjie
func setExposureBias(exposureBias: Float64): Unit
```

**功能：** 设置曝光补偿，曝光补偿值（EV）。

进行设置之前，建议先通过方法[getExposureBiasRange](#func-getexposurebiasrange)查询支持的范围。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|exposureBias|Float64|是|-|曝光补偿，[getExposureBiasRange](#func-getexposurebiasrange)查询支持的范围，如果设置超过支持范围的值，自动匹配到就近临界点。曝光补偿存在步长，如步长为0.5。则设置1.2时，获取到实际生效曝光补偿为1.0。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400102 | Operation not allowed. |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let exposureBias = 1.2
    photoSession.setExposureBias(exposureBias)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setExposureMode(ExposureMode)

```cangjie
func setExposureMode(aeMode: ExposureMode): Unit
```

**功能：** 设置曝光模式。进行设置之前，需要先检查设备是否支持指定的曝光模式，可使用方法[isExposureModeSupported](#func-isexposuremodesupportedexposuremode)。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|aeMode|[ExposureMode](#enum-exposuremode)|是|-|曝光模式。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400102 | Operation not allowed. |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let aeMode = ExposureMode.ExposureModeAuto
    photoSession.setExposureMode(aeMode)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setMeteringPoint(Point)

```cangjie
func setMeteringPoint(point: Point): Unit
```

**功能：** 设置曝光区域中心点，曝光点应在0-1坐标系内，该坐标系左上角为{0，0}，右下角为{1，1}。

此坐标系是以设备充电口在右侧时的横向设备方向为基准的，例如应用的预览界面布局以设备充电口在下侧时的竖向方向为基准，布局宽高为{w，h}，且触碰点为{x，y}，则转换后的坐标点为{y/h，1-x/w}。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|point|[Point](#class-point)|是|-|曝光点，x、y设置范围应在[0，1]之内，超过范围，如果小于0设置0，大于1设置1。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.CameraKit.Point as ImagePoint
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let point = ImagePoint(1.0, 1.0)
    photoSession.setMeteringPoint(point)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## interface AutoExposureQuery

```cangjie
public interface AutoExposureQuery {
    func isExposureModeSupported(aeMode: ExposureMode): Bool
    func getExposureBiasRange(): Array<Float64>
}
```

**功能：** 针对设备的自动曝光特性提供了一系列查询功能。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func getExposureBiasRange()

```cangjie
func getExposureBiasRange(): Array<Float64>
```

**功能：** 查询曝光补偿范围。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<Float64>|获取补偿范围的数组。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let range = photoSession.getExposureBiasRange()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func isExposureModeSupported(ExposureMode)

```cangjie
func isExposureModeSupported(aeMode: ExposureMode): Bool
```

**功能：** 检测是否支持曝光模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|aeMode|[ExposureMode](#enum-exposuremode)|是|-|曝光模式。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|是否支持曝光模式。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config, only throw in session usage. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let aeMode = ExposureMode.ExposureModeAuto
    Hilog.info(0, "AppLogCj", photoSession.isExposureModeSupported(aeMode).toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## interface CameraOutput

```cangjie
public interface CameraOutput {
    func release(): Unit
}
```

**功能：** 会话中[Session](#interface-session)使用的输出信息，output的基类。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func release()

```cangjie
func release(): Unit
```

**功能：** 释放输出资源。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let previewOutput = cameraManager.createPreviewOutput(ability.previewProfiles[0], surfaceId)
    previewOutput.release()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## interface ColorManagement

```cangjie
public interface ColorManagement <: ColorManagementQuery {
    func setColorSpace(colorSpace: ColorSpace): Unit
    func getActiveColorSpace(): ColorSpace
}
```

**功能：** 色彩管理类，用于设置色彩空间参数。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- [ColorManagementQuery](#interface-colormanagementquery)

### func getActiveColorSpace()

```cangjie
func getActiveColorSpace(): ColorSpace
```

**功能：** 获取当前设置的色彩空间。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[ColorSpace](../ArkGraphics2D/cj-apis-color_manager.md#enum-colorspace)|当前设置的色彩空间。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let colorSpace = photoSession.getActiveColorSpace()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setColorSpace(ColorSpace)

```cangjie
func setColorSpace(colorSpace: ColorSpace): Unit
```

**功能：** 设置色彩空间。

使用该接口前，必须先通过[getSupportedColorSpaces](#func-getsupportedcolorspaces)获取当前设备所支持的ColorSpaces。该接口建议在[addOutput](#func-addoutputcameraoutput)之后、[commitConfig](#func-commitconfig)之前调用，如果在[commitConfig](#func-commitconfig)之后调用该接口，会导致相机会话配置耗时增加。

**P3广色域与HDR高动态范围成像**

应用可以下发不同的色彩空间(ColorSpace)参数来支持P3广色域以及HDR的功能。
当应用不主动设置色彩空间时，拍照模式默认为SDR拍摄效果。
在拍照模式下若需要获取HDR高显效果的图片可通过设置色彩空间P3色域实现。
应用针对不同模式使能HDR效果、设置的色彩空间以及设置相机输出流[Profile](#class-profile)中的[CameraFormat](#enum-cameraformat)一一对应关系可参考下表。例如，在录像模式下若需要选择HDR拍摄，相机预览输出流和录像输出流[Profile](#class-profile)中的[CameraFormat](#enum-cameraformat)可选择CameraFormatYcrcbP010，色彩空间ColorSpace可选择设置Bt2020HlgLimit。

在录像模式下，使能SDR或HDR_VIVID拍摄效果时，CameraFormat与ColorSpace必须按照下列表格中的对应关系配置，若不满足表格中CameraFormat与ColorSpace配置，会导致预览异常等问题。

**录像模式：**

| SDR/HDR拍摄         | CameraFormat             | ColorSpace       |
|--------------------|--------------------------|------------------|
| SDR                | CameraFormatYuv420Sp | Bt709Limit      |
| HDR_VIVID          | CameraFormatYcrcbP010<br>CameraFormatYcbcrP010 | Bt2020HlgLimit |

**拍照模式：**

| SDR/HDR拍摄        | ColorSpace |
|--------------------|------------|
| SDR(Default)       | Srgb      |
| HDR                | DisplayP3 |

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|colorSpace|[ColorSpace](../ArkGraphics2D/cj-apis-color_manager.md#enum-colorspace)|是|-|色彩空间，通过[getSupportedColorSpaces](#func-getsupportedcolorspaces)接口获取。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400102 | The colorSpace does not match the format. |
  | 7400103 | Session not config. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let colorSpaces = photoSession.getSupportedColorSpaces()
    if (colorSpaces.size > 0) {
        let colorSpace = colorSpaces[0]
        photoSession.setColorSpace(colorSpace)
    }
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## interface ColorManagementQuery

```cangjie
public interface ColorManagementQuery {
    func getSupportedColorSpaces(): Array<ColorSpace>
}
```

**功能：** 色彩管理类，用于查询色彩空间参数。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func getSupportedColorSpaces()

```cangjie
func getSupportedColorSpaces(): Array<ColorSpace>
```

**功能：** 获取支持的色彩空间列表。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[ColorSpace](../ArkGraphics2D/cj-apis-color_manager.md#enum-colorspace)>|支持的色彩空间列表。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config, only throw in session usage. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let colorSpaces = photoSession.getSupportedColorSpaces()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## interface Flash

```cangjie
public interface Flash <: FlashQuery {
    func setFlashMode(flashMode: FlashMode): Unit
    func getFlashMode(): FlashMode
}
```

**功能：** 闪光灯类，对设备闪光灯操作。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- [FlashQuery](#interface-flashquery)

### func getFlashMode()

```cangjie
func getFlashMode(): FlashMode
```

**功能：** 获取当前设备的闪光灯模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[FlashMode](#enum-flashmode)|当前设备的闪光灯模式。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let flashMode = photoSession.getFlashMode()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setFlashMode(FlashMode)

```cangjie
func setFlashMode(flashMode: FlashMode): Unit
```

**功能：** 设置闪光灯模式。

进行设置之前，需要先检查：

1. 设备是否支持闪光灯，可使用方法[hasFlash](#func-hasflash)判断。
2. 设备是否支持指定的闪光灯模式，可使用方法[isFlashModeSupported](#func-isflashmodesupportedflashmode)判断。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|flashMode|[FlashMode](#enum-flashmode)|是|-|指定闪光灯模式。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let flashMode = FlashMode.FlashModeAlwaysOpen
    photoSession.setFlashMode(flashMode)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## interface FlashQuery

```cangjie
public interface FlashQuery {
    func hasFlash(): Bool
    func isFlashModeSupported(flashMode: FlashMode): Bool
}
```

**功能：** 提供了查询设备的闪光灯状态和模式的能力。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func hasFlash()

```cangjie
func hasFlash(): Bool
```

**功能：** 检测是否有闪光灯，返回是否支持闪光灯。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|设备是否支持闪光灯。true表示支持，false表示不支持。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    Hilog.info(0, "AppLogCj", photoSession.hasFlash().toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func isFlashModeSupported(FlashMode)

```cangjie
func isFlashModeSupported(flashMode: FlashMode): Bool
```

**功能：** 检测闪光灯模式是否支持。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|flashMode|[FlashMode](#enum-flashmode)|是|-|指定闪光灯模式。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回true表示支持该闪光灯模式，false表示不支持。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let result = photoSession.isFlashModeSupported(FlashMode.FlashModeAlwaysOpen)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## interface Focus

```cangjie
public interface Focus <: FocusQuery {
    func setFocusMode(afMode: FocusMode): Unit
    func getFocusMode(): FocusMode
    func setFocusPoint(point: Point): Unit
    func getFocusPoint(): Point
    func getFocalLength(): Float64
}
```

**功能：** 对焦类，对设备对焦操作。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- [FocusQuery](#interface-focusquery)

### func getFocalLength()

```cangjie
func getFocalLength(): Float64
```

**功能：** 查询当前的焦距值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Float64|用于获取当前焦距，单位mm。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    Hilog.info(0, "AppLogCj", photoSession.getFocalLength().toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getFocusMode()

```cangjie
func getFocusMode(): FocusMode
```

**功能：** 获取当前的对焦模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[FocusMode](#enum-focusmode)|获取当前设备的焦距模式。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    Hilog.info(0, "AppLogCj", photoSession.getFocusMode().toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getFocusPoint()

```cangjie
func getFocusPoint(): Point
```

**功能：** 查询当前的焦点。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[Point](#class-point)|用于获取当前的焦点。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let point = photoSession.getFocusPoint()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setFocusMode(FocusMode)

```cangjie
func setFocusMode(afMode: FocusMode): Unit
```

**功能：** 设置对焦模式。

进行设置之前，需要先检查设备是否支持指定的焦距模式，可使用方法[isFocusModeSupported](#func-isfocusmodesupportedfocusmode)。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|afMode|[FocusMode](#enum-focusmode)|是|-|指定的焦距模式。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let afMode = FocusMode.FocusModeManual
    photoSession.setFocusMode(afMode)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setFocusPoint(Point)

```cangjie
func setFocusPoint(point: Point): Unit
```

**功能：** 设置焦点，焦点应在0-1坐标系内，该坐标系左上角为{0，0}，右下角为{1，1}。

此坐标系是以设备充电口在右侧时的横向设备方向为基准的，例如应用的预览界面布局以设备充电口在下侧时的竖向方向为基准，布局宽高为{w，h}，且触碰点为{x，y}，则转换后的坐标点为{y/h，1-x/w}。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|point|[Point](#class-point)|是|-|焦点。x、y设置范围应在[0，1]之内，超过范围，如果小于0设置0，大于1设置1。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.CameraKit.Point as ImagePoint
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    photoSession.setFocusPoint(ImagePoint(0.5, 0.5))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## interface FocusQuery

```cangjie
public interface FocusQuery {
    func isFocusModeSupported(afMode: FocusMode): Bool
}
```

**功能：** 提供了查询是否支持当前对焦模式的方法。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func isFocusModeSupported(FocusMode)

```cangjie
func isFocusModeSupported(afMode: FocusMode): Bool
```

**功能：** 检测对焦模式是否支持。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|afMode|[FocusMode](#enum-focusmode)|是|-|指定的焦距模式。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|检测对焦模式是否支持。true表示支持，false表示不支持。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let afMode = FocusMode.FocusModeManual
    Hilog.info(0, "AppLogCj", photoSession.isFocusModeSupported(afMode).toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## interface Session

```cangjie
public interface Session {
    func beginConfig(): Unit
    func commitConfig(): Unit
    func canAddInput(cameraInput: CameraInput): Bool
    func addInput(cameraInput: CameraInput): Unit
    func removeInput(cameraInput: CameraInput): Unit
    func canAddOutput(cameraOutput: CameraOutput): Bool
    func addOutput(cameraOutput: CameraOutput): Unit
    func removeOutput(cameraOutput: CameraOutput): Unit
    func start(): Unit
    func stop(): Unit
    func release(): Unit
}
```

**功能：** 会话类型，保存一次相机运行所需要的所有资源[CameraInput](#class-camerainput)、[CameraOutput](#interface-cameraoutput)，并向相机设备申请完成相机功能（录像，拍照）。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func addInput(CameraInput)

```cangjie
func addInput(cameraInput: CameraInput): Unit
```

**功能：** 把[CameraInput](#class-camerainput)加入到会话。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|cameraInput|[CameraInput](#class-camerainput)|是|-|需要添加的CameraInput实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400102 | Operation not allowed. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    let cameraDevice = cameraManager.getSupportedCameras()[0]
    let cameraInput = cameraManager.createCameraInput(cameraDevice)
    session.addInput(cameraInput)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func addOutput(CameraOutput)

```cangjie
func addOutput(cameraOutput: CameraOutput): Unit
```

**功能：** 把[CameraOutput](#interface-cameraoutput)加入到会话。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|cameraOutput|[CameraOutput](#interface-cameraoutput)|是|-|需要添加的CameraOutput实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400102 | Operation not allowed. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    let cameraDevice = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(cameraDevice)[0]
    let ability = cameraManager.getSupportedOutputCapability(cameraDevice, mode)
    let cameraOutput = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    session.addOutput(cameraOutput)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func beginConfig()

```cangjie
func beginConfig(): Unit
```

**功能：** 开始配置会话。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400105 | Session config locked. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    session.beginConfig()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func canAddInput(CameraInput)

```cangjie
func canAddInput(cameraInput: CameraInput): Bool
```

**功能：** 判断当前cameraInput是否可以添加到session中。当前函数需要在[beginConfig](#func-beginconfig)和[commitConfig](#func-commitconfig)之间生效。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|cameraInput|[CameraInput](#class-camerainput)|是|-|需要添加的CameraInput实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回true表示支持添加当前cameraInput，返回false表示不支持添加。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    let cameraDevice = cameraManager.getSupportedCameras()[0]
    let cameraInput = cameraManager.createCameraInput(cameraDevice)
    Hilog.info(0, "AppLogCj", session.canAddInput(cameraInput).toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func canAddOutput(CameraOutput)

```cangjie
func canAddOutput(cameraOutput: CameraOutput): Bool
```

**功能：** 判断当前cameraOutput是否可以添加到session中。当前函数需要在[addInput](#func-addinputcamerainput)和[commitConfig](#func-commitconfig)之间生效。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|cameraOutput|[CameraOutput](#interface-cameraoutput)|是|-|需要添加的CameraOutput实例。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|是否可以添加当前cameraOutput到session中。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    let cameraDevice = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(cameraDevice)[0]
    let ability = cameraManager.getSupportedOutputCapability(cameraDevice, mode)
    let cameraOutput = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    Hilog.info(0, "AppLogCj", session.canAddOutput(cameraOutput).toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func commitConfig()

```cangjie
func commitConfig(): Unit
```

**功能：** 提交配置信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400102 | Operation not allowed. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    session.commitConfig()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func release()

```cangjie
func release(): Unit
```

**功能：** 释放会话资源。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    session.release()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func removeInput(CameraInput)

```cangjie
func removeInput(cameraInput: CameraInput): Unit
```

**功能：** 移除[CameraInput](#class-camerainput)。当前函数需要在[beginConfig](#func-beginconfig)和[commitConfig](#func-commitconfig)之间生效。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|cameraInput|[CameraInput](#class-camerainput)|是|-|需要移除的CameraInput实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400102 | Operation not allowed. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    let cameraDevice = cameraManager.getSupportedCameras()[0]
    let cameraInput = cameraManager.createCameraInput(cameraDevice)
    session.removeInput(cameraInput)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func removeOutput(CameraOutput)

```cangjie
func removeOutput(cameraOutput: CameraOutput): Unit
```

**功能：** 从会话中移除[CameraOutput](#interface-cameraoutput)。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|cameraOutput|[CameraOutput](#interface-cameraoutput)|是|-|需要移除的CameraOutput实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400102 | Operation not allowed. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    let cameraDevice = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(cameraDevice)[0]
    let ability = cameraManager.getSupportedOutputCapability(cameraDevice, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let previewOutput = cameraManager.createPreviewOutput(ability.previewProfiles[0], surfaceId)
    session.removeOutput(previewOutput)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func start()

```cangjie
func start(): Unit
```

**功能：** 开始会话工作。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400102 | Operation not allowed. |
  | 7400103 | Session not config. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    session.start()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func stop()

```cangjie
func stop(): Unit
```

**功能：** 停止会话工作。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    session.stop()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## interface Stabilization

```cangjie
public interface Stabilization <: StabilizationQuery {
    func getActiveVideoStabilizationMode(): VideoStabilizationMode
    func setVideoStabilizationMode(mode: VideoStabilizationMode): Unit
}
```

**功能：** 提供设备在录像模式下设置视频防抖的操作。

> **说明：**
>
> - 对视频进行防抖设置的前提是会话中有录像流（[VideoOutput](#class-videooutput)）。
>
> - 设置防抖操作时，[VideoStabilizationMode.HIGH](#high)需要在[Profile](#class-profile)的分辨率为1920*1080的场景下生效。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- [StabilizationQuery](#interface-stabilizationquery)

### func getActiveVideoStabilizationMode()

```cangjie
func getActiveVideoStabilizationMode(): VideoStabilizationMode
```

**功能：** 查询当前正在使用的视频防抖模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[VideoStabilizationMode](#enum-videostabilizationmode)|视频防抖是否正在使用。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalVideo)
    var videoSessionOption = session as VideoSession
    let videoSession = videoSessionOption.getOrThrow()
    Hilog.info(0, "AppLogCj", videoSession.getActiveVideoStabilizationMode().toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setVideoStabilizationMode(VideoStabilizationMode)

```cangjie
func setVideoStabilizationMode(mode: VideoStabilizationMode): Unit
```

**功能：** 设置视频防抖模式。需要先检查设备是否支持对应的防抖模式，可以通过[isVideoStabilizationModeSupported](#func-isvideostabilizationmodesupportedvideostabilizationmode)方法判断所设置的模式是否支持。建议在[commitConfig](#func-commitconfig)与[start](#func-start)之间设置视频防抖。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|mode|[VideoStabilizationMode](#enum-videostabilizationmode)|是|-|需要设置的视频防抖模式。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalVideo)
    var videoSessionOption = session as VideoSession
    let videoSession = videoSessionOption.getOrThrow()
    let vsMode = VideoStabilizationMode.Off
    videoSession.setVideoStabilizationMode(vsMode)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## interface StabilizationQuery

```cangjie
public interface StabilizationQuery {
    func isVideoStabilizationModeSupported(vsMode: VideoStabilizationMode): Bool
}
```

**功能：** 提供了查询设备在录像模式下是否支持对应的视频防抖模式的能力。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func isVideoStabilizationModeSupported(VideoStabilizationMode)

```cangjie
func isVideoStabilizationModeSupported(vsMode: VideoStabilizationMode): Bool
```

**功能：** 查询是否支持指定的视频防抖模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|vsMode|[VideoStabilizationMode](#enum-videostabilizationmode)|是|-|视频防抖模式。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回视频防抖模式是否支持。true表示支持，false表示不支持。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config, only throw in session usage. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalVideo)
    var videoSessionOption = session as VideoSession
    let videoSession = videoSessionOption.getOrThrow()
    let vsMode = VideoStabilizationMode.Off
    let result = videoSession.isVideoStabilizationModeSupported(vsMode)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## interface Zoom

```cangjie
public interface Zoom <: ZoomQuery {
    func setZoomRatio(zoomRatio: Float64): Unit
    func getZoomRatio(): Float64
    func setSmoothZoom(targetRatio: Float64, mode: SmoothZoomMode): Unit
    func setSmoothZoom(targetRatio: Float64): Unit
}
```

**功能：** 变焦类，对设备变焦操作。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- [ZoomQuery](#interface-zoomquery)

### func getZoomRatio()

```cangjie
func getZoomRatio(): Float64
```

**功能：** 获取当前的变焦比。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Float64|获取当前的变焦比结果。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    Hilog.info(0, "AppLogCj", photoSession.getZoomRatio().toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setSmoothZoom(Float64, SmoothZoomMode)

```cangjie
func setSmoothZoom(targetRatio: Float64, mode: SmoothZoomMode): Unit
```

**功能：** 触发平滑变焦。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|targetRatio|Float64|是|-|目标值。通过[getZoomRatioRange](#func-getzoomratiorange)获取支持的变焦范围，如果设置超过支持范围的值，则只保留精度范围内数值。|
|mode|[SmoothZoomMode](#enum-smoothzoommode)|是|-|平滑变焦模式。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let targetRatio: Float64 = 0.3
    photoSession.setSmoothZoom(targetRatio, SmoothZoomMode.Normal)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setSmoothZoom(Float64)

```cangjie
func setSmoothZoom(targetRatio: Float64): Unit
```

**功能：** 触发平滑变焦。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|targetRatio|Float64|是|-|目标值。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let targetRatio: Float64 = 0.3
    photoSession.setSmoothZoom(targetRatio)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setZoomRatio(Float64)

```cangjie
func setZoomRatio(zoomRatio: Float64): Unit
```

**功能：** 设置变焦比，变焦精度最高为小数点后两位，如果设置超过支持的精度范围，则只保留精度范围内数值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|zoomRatio|Float64|是|-|可变焦距比，通过[getZoomRatioRange](#func-getzoomratiorange)获取支持的变焦范围，如果设置超过支持范围的值，则只保留精度范围内数值。<br>设置可变焦距比到底层生效需要一定时间，获取正确设置的可变焦距比需要等待1~2帧的时间。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let zoomRatio: Float64 = 0.5
    photoSession.setZoomRatio(zoomRatio)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## interface ZoomQuery

```cangjie
public interface ZoomQuery {
    func getZoomRatioRange(): Array<Float64>
}
```

**功能：** 提供了与设备的缩放相关的查询功能，包括获取支持的缩放比例范围。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func getZoomRatioRange()

```cangjie
func getZoomRatioRange(): Array<Float64>
```

**功能：** 获取支持的变焦范围。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<Float64>|用于获取可变焦距比范围，返回的数组包括其最小值和最大值。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config, only throw in session usage. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let session = cameraManager.createSession(SceneMode.NormalPhoto)
    var photoSessionOption = session as PhotoSession
    let photoSession = photoSessionOption.getOrThrow()
    let zoomRatio: Float64 = 0.5
    Hilog.info(0, "AppLogCj", photoSession.getZoomRatioRange().toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class CameraDevice

```cangjie
public class CameraDevice {
    public let cameraId: String
    public let cameraPosition: CameraPosition
    public let cameraType: CameraType
    public let connectionType: ConnectionType
    public let cameraOrientation: UInt32
}
```

**功能：** 相机设备信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let cameraId

```cangjie
public let cameraId: String
```

**功能：** 相机ID。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let cameraOrientation

```cangjie
public let cameraOrientation: UInt32
```

**功能：** 相机安装角度，不会随着屏幕旋转而改变，取值范围为0°-360°，单位：度。

**类型：** UInt32

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let cameraPosition

```cangjie
public let cameraPosition: CameraPosition
```

**功能：** 相机位置。

**类型：** [CameraPosition](#enum-cameraposition)

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let cameraType

```cangjie
public let cameraType: CameraType
```

**功能：** 相机类型。

**类型：** [CameraType](#enum-cameratype)

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let connectionType

```cangjie
public let connectionType: ConnectionType
```

**功能：** 相机连接类型。

**类型：** [ConnectionType](#enum-connectiontype)

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class CameraInput

```cangjie
public class CameraInput {}
```

**功能：** 相机设备输入对象。

会话中[Session](#interface-session)使用的相机信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func close()

```cangjie
public func close(): Unit
```

**功能：** 关闭相机。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevice = cameraManager.getSupportedCameras()[0]
    let cameraInput = cameraManager.createCameraInput(cameraDevice)
    cameraInput.close()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, CameraDevice, Callback0Argument)

```cangjie
public func off(eventType: CameraEvents, camera: CameraDevice, callback: Callback0Argument): Unit
```

**功能：** 注销监听CameraInput的错误事件。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，固定为CameraError，CameraInput对象创建成功可监听。相机设备出错情况下可触发该事件并返回结果，比如设备不可用或者冲突等返回对应错误信息。|
|camera|[CameraDevice](#class-cameradevice)|是|-|CameraDevice对象。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevice = cameraManager.getSupportedCameras()[0]
    let cameraInput = cameraManager.createCameraInput(cameraDevice)
    cameraInput.off(CameraEvents.CameraError, cameraDevice)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, CameraDevice)

```cangjie
public func off(eventType: CameraEvents, camera: CameraDevice): Unit
```

**功能：** 注销监听CameraInput的错误事件。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，固定为CameraError，CameraInput对象创建成功可监听。相机设备出错情况下可触发该事件并返回结果，比如设备不可用或者冲突等返回对应错误信息。|
|camera|[CameraDevice](#class-cameradevice)|是|-|CameraDevice对象。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevice = cameraManager.getSupportedCameras()[0]
    let cameraInput = cameraManager.createCameraInput(cameraDevice)
    cameraInput.off(CameraEvents.CameraError, cameraDevice)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, CameraDevice, Callback0Argument)

```cangjie
public func on(eventType: CameraEvents, camera: CameraDevice, callback: Callback0Argument): Unit
```

**功能：** 监听CameraInput的错误事件，通过注册回调函数获取结果。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为CameraError，CameraInput对象创建成功可监听。相机设备出错情况下可触发该事件并返回结果，比如设备不可用或者冲突等返回对应错误信息。|
|camera|[CameraDevice](#class-cameradevice)|是|-|CameraDevice对象。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数，用于获取结果。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.callback_invoke.Callback0Argument
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallbackError <: Callback0Argument {
    public init() {}
    public func invoke(res: ?BusinessException): Unit {
        Hilog.info(0, "Camera", "Call invoke error. code: ${res?.code}, msg: ${res?.message}")
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevice = cameraManager.getSupportedCameras()[0]
    let cameraInput = cameraManager.createCameraInput(cameraDevice)
    let testCallbackError = TestCallbackError()
    cameraInput.on(CameraEvents.CameraError, cameraDevice, testCallbackError)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func open()

```cangjie
public func open(): Unit
```

**功能：** 打开相机。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400107 | Can not use camera cause of conflict. |
  | 7400108 | Camera disabled cause of security reason. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevice = cameraManager.getSupportedCameras()[0]
    let cameraInput = cameraManager.createCameraInput(cameraDevice)
    cameraInput.open()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func open(Bool)

```cangjie
public func open(isSecureEnabled: Bool): UInt64
```

**功能：** 打开相机。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|isSecureEnabled|Bool|是|-|设置true为使能以安全的方式打开相机，设置false则反之。|

**返回值：**

|类型|说明|
|:----|:----|
|UInt64|打开相机的句柄。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400107 | Can not use camera cause of conflict. |
  | 7400108 | Camera disabled cause of security reason. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevice = cameraManager.getSupportedCameras()[0]
    let cameraInput = cameraManager.createCameraInput(cameraDevice)
    let isSecureEnabled = false
    let handle = cameraInput.open(isSecureEnabled)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class CameraManager

```cangjie
public class CameraManager {}
```

**功能：** 相机管理器类，使用前需要通过[getCameraManager](#func-getcameramanageruiabilitycontext)获取相机管理实例。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func createCameraInput(CameraDevice)

```cangjie
public func createCameraInput(camera: CameraDevice): CameraInput
```

**功能：** 使用CameraDevice对象创建CameraInput实例。

该接口使用前首先通过[getSupportedCameras](#func-getsupportedcameras)接口查询当前设备支持的相机设备信息列表，开发者需要根据具体使用场景选择符合需求的相机设备，然后使用该接口创建CameraInput实例。

**需要权限：** ohos.permission.CAMERA

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|camera|[CameraDevice](#class-cameradevice)|是|-|CameraDevice对象，通过[getSupportedCameras](#func-getsupportedcameras)接口获取。|

**返回值：**

|类型|说明|
|:----|:----|
|[CameraInput](#class-camerainput)|CameraInput实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400102 | Operation not allowed. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevices = cameraManager.getSupportedCameras()
    let cameraDevice0 = cameraDevices[0]
    let position = cameraDevice0.cameraPosition
    let cameraType = cameraDevice0.cameraType
    let cameraInput = cameraManager.createCameraInput(position , cameraType)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func createCameraInput(CameraPosition, CameraType)

```cangjie
public func createCameraInput(position: CameraPosition, cameraType: CameraType): CameraInput
```

**功能：** 根据相机位置和类型创建CameraInput实例。

该接口使用前需要开发者根据应用具体使用场景自行指定相机位置和类型，例如打开前置相机进入自拍功能。

**需要权限：** ohos.permission.CAMERA

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|position|[CameraPosition](#enum-cameraposition)|是|-|相机位置，通过[getSupportedCameras](#func-getsupportedcameras)接口获取设备，然后获取设备位置信息。|
|cameraType|[CameraType](#enum-cameratype)|是|-|相机类型，通过[getSupportedCameras](#func-getsupportedcameras)接口获取设备，然后获取设备类型信息。|

**返回值：**

|类型|说明|
|:----|:----|
|[CameraInput](#class-camerainput)|CameraInput实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400102 | Operation not allowed. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevices = cameraManager.getSupportedCameras()
    let cameraDevice0 = cameraDevices[0]
    let position = cameraDevice0.cameraPosition
    let cameraType = cameraDevice0.cameraType
    let cameraInput = cameraManager.createCameraInput(position , cameraType)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func createPhotoOutput(?Profile)

```cangjie
public func createPhotoOutput(profile!: ?Profile = None): PhotoOutput
```

**功能：** 创建拍照输出对象。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|profile|?[Profile](#class-profile)|否|None|支持的拍照配置信息，通过[getSupportedOutputCapability](#func-getsupportedcameras)接口获取。如果使用[preconfig](#func-preconfigpreconfigtype-preconfigratio)进行预配置，传入profile参数会覆盖preconfig的预配置参数。|

**返回值：**

|类型|说明|
|:----|:----|
|[PhotoOutput](#class-photooutput)|PhotoOutput实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevices = cameraManager.getSupportedCameras()
    let camera = cameraDevices[0]
    let mode = cameraManager.getSupportedSceneModes(camera)[0]
    let cameraOutputCapability = cameraManager.getSupportedOutputCapability(camera, mode)
    let profile = cameraOutputCapability.photoProfiles[0]
    let photoOutput  = cameraManager.createPhotoOutput(profile:profile)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func createPreviewOutput(Profile, String)

```cangjie
public func createPreviewOutput(profile: Profile, surfaceId: String): PreviewOutput
```

**功能：** 创建预览输出对象。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|profile|[Profile](#class-profile)|是|-|支持的预览配置信息，通过[getSupportedOutputCapability](#func-getsupportedoutputcapabilitycameradevice-scenemode)接口获取。|
|surfaceId|String|是|-|从[ImageReceiver](../ImageKit/cj-apis-image.md#class-imagereceiver)组件获取的surfaceId。|

**返回值：**

|类型|说明|
|:----|:----|
|[PreviewOutput](#class-previewoutput)|PreviewOutput实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevices = cameraManager.getSupportedCameras()
    let camera = cameraDevices[0]
    let mode = cameraManager.getSupportedSceneModes(camera)[0]
    let cameraOutputCapability = cameraManager.getSupportedOutputCapability(camera, mode)
    let profile = cameraOutputCapability.previewProfiles[0]
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let previewOutput = cameraManager.createPreviewOutput(profile, surfaceId)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func createPreviewOutput(String)

```cangjie
public func createPreviewOutput(surfaceId: String): PreviewOutput
```

**功能：** 创建无配置信息的预览输出对象。该接口需配合[preconfig](#func-preconfigpreconfigtype-preconfigratio)一起使用。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|surfaceId|String|是|-|从[ImageReceiver](../ImageKit/cj-apis-image.md#class-imagereceiver)组件获取的surfaceId。|

**返回值：**

|类型|说明|
|:----|:----|
|[PreviewOutput](#class-previewoutput)|PreviewOutput实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let previewOutput = cameraManager.createPreviewOutput(surfaceId)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func createSession(SceneMode)

```cangjie
public func createSession(mode: SceneMode): Session
```

**功能：** 创建指定SceneMode的Session实例。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|mode|[SceneMode](#enum-scenemode)|是|-|相机支持的模式。|

**返回值：**

|类型|说明|
|:----|:----|
|[Session](#interface-session)|Session实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevices = cameraManager.getSupportedCameras()
    let camera = cameraDevices[0]
    let mode = cameraManager.getSupportedSceneModes(camera)[0]
    let session = cameraManager.createSession(mode)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func createVideoOutput(VideoProfile, String)

```cangjie
public func createVideoOutput(profile: VideoProfile, surfaceId: String): VideoOutput
```

**功能：** 创建录像输出对象。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|profile|[VideoProfile](#class-videoprofile)|是|-|支持的录像配置信息，通过[getSupportedOutputCapability](#func-getsupportedoutputcapabilitycameradevice-scenemode)接口获取。|
|surfaceId|String|是|-|从AVRecorder获取的surfaceId。|

**返回值：**

|类型|说明|
|:----|:----|
|[VideoOutput](#class-videooutput)|VideoOutput实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevices = cameraManager.getSupportedCameras()
    let camera = cameraDevices[0]
    let mode = cameraManager.getSupportedSceneModes(camera)[0]
    let cameraOutputCapability = cameraManager.getSupportedOutputCapability(camera, mode)
    let profile = cameraOutputCapability.videoProfiles[0]
    // 假设从AVRecorder获取surfaceId
    let surfaceId: String = "surfaceId_from_avrecorder"
    let videoOutput = cameraManager.createVideoOutput(profile, surfaceId)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func createVideoOutput(String)

```cangjie
public func createVideoOutput(surfaceId: String): VideoOutput
```

**功能：** 创建无配置信息的录像输出对象。该接口需配合[preconfig](#func-preconfigpreconfigtype-preconfigratio)功能一起使用。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|surfaceId|String|是|-|从AVRecorder获取的surfaceId。|

**返回值：**

|类型|说明|
|:----|:----|
|[VideoOutput](#class-videooutput)|VideoOutput实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let videoOutput = cameraManager.createVideoOutput(surfaceId)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getSupportedCameras()

```cangjie
public func getSupportedCameras(): Array<CameraDevice>
```

**功能：** 获取支持指定的相机设备对象。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[CameraDevice](#class-cameradevice)>|相机设备列表。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevices = cameraManager.getSupportedCameras()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getSupportedOutputCapability(CameraDevice, SceneMode)

```cangjie
public func getSupportedOutputCapability(camera: CameraDevice, mode: SceneMode): CameraOutputCapability
```

**功能：** 查询相机设备在模式下支持的输出能力。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|camera|[CameraDevice](#class-cameradevice)|是|-|相机设备，通过[getSupportedCameras](#func-getsupportedcameras)接口获取。|
|mode|[SceneMode](#enum-scenemode)|是|-|相机模式，通过[getSupportedSceneModes](#func-getsupportedscenemodescameradevice)接口获取。|

**返回值：**

|类型|说明|
|:----|:----|
|[CameraOutputCapability](#class-cameraoutputcapability)|相机输出能力。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevices = cameraManager.getSupportedCameras()
    let camera = cameraDevices[0]
    let mode = cameraManager.getSupportedSceneModes(camera)[0]
    let cameraOutputCapability = cameraManager.getSupportedOutputCapability(camera, mode)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getSupportedSceneModes(CameraDevice)

```cangjie
public func getSupportedSceneModes(camera: CameraDevice): Array<SceneMode>
```

**功能：** 获取指定的相机设备对象支持的模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|camera|[CameraDevice](#class-cameradevice)|是|-|相机设备，通过[getSupportedCameras](#func-getsupportedcameras)接口获取。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[SceneMode](#enum-scenemode)>|相机支持的模式列表。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let cameraDevices = cameraManager.getSupportedCameras()
    let camera = cameraDevices[0]
    let mode = cameraManager.getSupportedSceneModes(camera)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getTorchMode()

```cangjie
public func getTorchMode(): TorchMode
```

**功能：** 获取当前设备手电筒模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[TorchMode](#enum-torchmode)|返回设备当前手电筒模式。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let torchMode = cameraManager.getTorchMode()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func isCameraMuted()

```cangjie
public func isCameraMuted(): Bool
```

**功能：** 查询当前相机是否禁用。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回true表示相机被禁用，返回false表示相机未被禁用。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    Hilog.info(0, "AppLogCj", cameraManager.isCameraMuted().toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func isTorchModeSupported(TorchMode)

```cangjie
public func isTorchModeSupported(mode: TorchMode): Bool
```

**功能：** 检测是否支持设置的手电筒模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|mode|[TorchMode](#enum-torchmode)|是|-|手电筒模式。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回true表示设备支持设置的手电筒模式。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let torchMode = cameraManager.getTorchMode()
    Hilog.info(0, "AppLogCj", cameraManager.isTorchModeSupported(torchMode).toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func isTorchSupported()

```cangjie
public func isTorchSupported(): Bool
```

**功能：** 检测设备是否支持手电筒。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回true表示设备支持手电筒，返回false表示设备不支持手电。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    Hilog.info(0, "AppLogCj", cameraManager.isTorchSupported().toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback1Argument\<CameraStatusInfo>)

```cangjie
public func off(eventType: CameraEvents, callback: Callback1Argument<CameraStatusInfo>): Unit
```

**功能：** 相机设备状态注销回调，通过注销回调函数取消获取相机的状态变化。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为CameraStatus。CameraManager对象获取成功后可监听。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[CameraStatusInfo](#class-camerastatusinfo)>|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    cameraManager.off(CameraEvents.TorchStatusChange)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback1Argument\<FoldStatusInfo>)

```cangjie
public func off(eventType: CameraEvents, callback: Callback1Argument<FoldStatusInfo>): Unit
```

**功能：** 关闭折叠设备折叠状态变化的监听。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为FoldStatusChange。表示折叠设备折叠状态发生变化。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[FoldStatusInfo](#class-foldstatusinfo)>|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    cameraManager.off(CameraEvents.TorchStatusChange)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback1Argument\<TorchStatusInfo>)

```cangjie
public func off(eventType: CameraEvents, callback: Callback1Argument<TorchStatusInfo>): Unit
```

**功能：** 手电筒状态变化注销回调，通过注销回调函数取消获取手电筒状态变化。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为TorchStatusChange。CameraManager对象获取成功后可监听。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[TorchStatusInfo](#class-torchstatusinfo)>|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    cameraManager.off(CameraEvents.TorchStatusChange)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents)

```cangjie
public func off(eventType: CameraEvents): Unit
```

**功能：** 取消对应监听事件的所有回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件。必须为可被on函数监听的事件。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    cameraManager.off(CameraEvents.TorchStatusChange)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback1Argument\<CameraStatusInfo>)

```cangjie
public func on(eventType: CameraEvents, callback: Callback1Argument<CameraStatusInfo>): Unit
```

**功能：** 相机设备状态回调，通过注册回调函数获取相机的状态变化。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为CameraStatus。CameraManager对象获取成功后可监听。目前只支持对设备打开或者关闭会触发该事件并返回对应信息。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[CameraStatusInfo](#class-camerastatusinfo)>|是|-|回调函数，用于获取镜头状态变化信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import ohos.callback_invoke.Callback1Argument
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallbackTorchStatusChange <: Callback1Argument<TorchStatusInfo> {
    public init() {}
    public func invoke(err: ?BusinessException, res: TorchStatusInfo): Unit {
        Hilog.info(0, "Camera", "Call invoke TorchStatusChange. isTorchAvailable: ${res.isTorchAvailable}, isTorchActive: ${res.isTorchActive}, torchLevel:${res.torchLevel}")
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let testCallbackTorchStatusChange = TestCallbackTorchStatusChange()
    cameraManager.on(CameraEvents.TorchStatusChange, testCallbackTorchStatusChange)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback1Argument\<FoldStatusInfo>)

```cangjie
public func on(eventType: CameraEvents, callback: Callback1Argument<FoldStatusInfo>): Unit
```

**功能：** 注册折叠设备折叠状态变化的监听。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为FoldStatusChange。表示折叠设备折叠状态发生变化。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[FoldStatusInfo](#class-foldstatusinfo)>|是|-|回调函数。返回折叠设备折叠信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import ohos.callback_invoke.Callback1Argument
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallbackTorchStatusChange1 <: Callback1Argument<TorchStatusInfo> {
    public init() {}
    public func invoke(err: ?BusinessException, res: TorchStatusInfo): Unit {
        Hilog.info(0, "Camera", "Call invoke TorchStatusChange. isTorchAvailable: ${res.isTorchAvailable}, isTorchActive: ${res.isTorchActive}, torchLevel:${res.torchLevel}")
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let testCallbackTorchStatusChange = TestCallbackTorchStatusChange1()
    cameraManager.on(CameraEvents.TorchStatusChange, testCallbackTorchStatusChange)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback1Argument\<TorchStatusInfo>)

```cangjie
public func on(eventType: CameraEvents, callback: Callback1Argument<TorchStatusInfo>): Unit
```

**功能：** 手电筒状态变化回调，通过注册回调函数获取手电筒状态变化。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为TorchStatusChange。cameraManager对象获取成功后可监听。目前只支持手电筒打开，手电筒关闭，手电筒不可用，手电筒恢复可用会触发该事件并返回对应信息。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[TorchStatusInfo](#class-torchstatusinfo)>|是|-|回调函数，用于获取手电筒状态变化信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import ohos.callback_invoke.Callback1Argument
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallbackTorchStatusChange2 <: Callback1Argument<TorchStatusInfo> {
    public init() {}
    public func invoke(err: ?BusinessException, res: TorchStatusInfo): Unit {
        Hilog.info(0, "Camera", "Call invoke TorchStatusChange. isTorchAvailable: ${res.isTorchAvailable}, isTorchActive: ${res.isTorchActive}, torchLevel:${res.torchLevel}")
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let testCallbackTorchStatusChange = TestCallbackTorchStatusChange2()
    cameraManager.on(CameraEvents.TorchStatusChange, testCallbackTorchStatusChange)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setTorchMode(TorchMode)

```cangjie
public func setTorchMode(mode: TorchMode): Unit
```

**功能：** 设置设备手电筒模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|mode|[TorchMode](#enum-torchmode)|是|-|手电筒模式。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400102 | Operation not allowed. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    cameraManager.setTorchMode(TorchMode.On)
    cameraManager.setTorchMode(TorchMode.Off)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class CameraOutputCapability

```cangjie
public class CameraOutputCapability {
    public let previewProfiles: Array<Profile>
    public let photoProfiles: Array<Profile>
    public let videoProfiles: Array<VideoProfile>
    public let supportedMetadataObjectTypes: Array<MetadataObjectType>
}
```

**功能：** 相机输出能力项。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let photoProfiles

```cangjie
public let photoProfiles: Array<Profile>
```

**功能：** 支持的拍照配置信息集合。

**类型：** Array\<[Profile](#class-profile)>

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let previewProfiles

```cangjie
public let previewProfiles: Array<Profile>
```

**功能：** 支持的预览配置信息集合。

**类型：** Array\<[Profile](#class-profile)>

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let supportedMetadataObjectTypes

```cangjie
public let supportedMetadataObjectTypes: Array<MetadataObjectType>
```

**功能：** 支持的metadata流类型信息集合。

**类型：** Array\<[MetadataObjectType](#enum-metadataobjecttype)>

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let videoProfiles

```cangjie
public let videoProfiles: Array<VideoProfile>
```

**功能：** 支持的录像配置信息集合。

**类型：** Array\<[VideoProfile](#class-videoprofile)>

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class CameraStatusInfo

```cangjie
public class CameraStatusInfo {
    public var camera: CameraDevice
    public var status: CameraStatus
}
```

**功能：** 相机管理器回调返回的接口实例，该实例表示相机状态信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var camera

```cangjie
public var camera: CameraDevice
```

**功能：** 相机信息。

**类型：** [CameraDevice](#class-cameradevice)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var status

```cangjie
public var status: CameraStatus
```

**功能：** 相机状态。

**类型：** [CameraStatus](#enum-camerastatus)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class CaptureEndInfo

```cangjie
public class CaptureEndInfo {
    public var captureId: Int32
    public var frameCount: Int32
}
```

**功能：** 拍照停止信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var captureId

```cangjie
public var captureId: Int32
```

**功能：** 拍照的ID。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var frameCount

```cangjie
public var frameCount: Int32
```

**功能：** 帧数。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class CaptureStartInfo

```cangjie
public class CaptureStartInfo {
    public var captureId: Int32
    public var time: Int64
}
```

**功能：** 拍照开始信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var captureId

```cangjie
public var captureId: Int32
```

**功能：** 拍照的ID。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var time

```cangjie
public var time: Int64
```

**功能：** 预估的单次拍照底层出sensor采集帧时间，如果上报-1，代表没有预估时间。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class FoldStatusInfo

```cangjie
public class FoldStatusInfo {
    public let supportedCameras: Array<CameraDevice>
    public let foldStatus: FoldStatus
}
```

**功能：** 相机管理器回调返回的接口实例，表示折叠机折叠状态信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let foldStatus

```cangjie
public let foldStatus: FoldStatus
```

**功能：** 折叠屏折叠状态。

**类型：** [FoldStatus](#enum-foldstatus)

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let supportedCameras

```cangjie
public let supportedCameras: Array<CameraDevice>
```

**功能：** 当前折叠状态所支持的相机信息列表。

**类型：** Array\<[CameraDevice](#class-cameradevice)>

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class FrameRateRange

```cangjie
public class FrameRateRange {
    public let min: Int32
    public let max: Int32
}
```

**功能：** 帧率范围。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let max

```cangjie
public let max: Int32
```

**功能：** 最大帧率，单位：fps。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let min

```cangjie
public let min: Int32
```

**功能：** 最小帧率，单位：fps。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class FrameShutterEndInfo

```cangjie
public class FrameShutterEndInfo {
    public var captureId: Int32
}
```

**功能：** 拍照曝光结束信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var captureId

```cangjie
public var captureId: Int32
```

**功能：** 拍照的ID。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class FrameShutterInfo

```cangjie
public class FrameShutterInfo {
    public var captureId: Int32
    public var timestamp: Int64
}
```

**功能：** 拍照帧输出信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var captureId

```cangjie
public var captureId: Int32
```

**功能：** 拍照的ID。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var timestamp

```cangjie
public var timestamp: Int64
```

**功能：** 快门时间戳，单位毫秒。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class Location

```cangjie
public class Location {
    public var latitude: Float64
    public var longitude: Float64
    public var altitude: Float64
    public init(latitude: Float64, longitude: Float64, altitude: Float64)
}
```

**功能：** 图片地理位置信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var altitude

```cangjie
public var altitude: Float64
```

**功能：** 海拔(米)。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var latitude

```cangjie
public var latitude: Float64
```

**功能：** 纬度（度）。取值范围：[-90, 90]。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var longitude

```cangjie
public var longitude: Float64
```

**功能：** 经度（度）。取值范围：[-180, 180]。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### init(Float64, Float64, Float64)

```cangjie
public init(latitude: Float64, longitude: Float64, altitude: Float64)
```

**功能：** 创建Location对象。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|latitude|Float64|是|-|纬度（度）。取值范围：[-90, 90]。|
|longitude|Float64|是|-|经度（度）。取值范围：[-180, 180]。|
|altitude|Float64|是|-|海拔(米)。|

## class PhotoCaptureSetting

```cangjie
public class PhotoCaptureSetting {
    public var quality: QualityLevel
    public var rotation: ImageRotation
    public var location:?Location
    public var mirror: Bool
    public init(
        quality!: QualityLevel = QualityLevel.QualityLevelLow,
        rotation!: ImageRotation = ImageRotation.Rotation0,
        location!: ?Location = None,
        mirror!: Bool = false
    )
}
```

**功能：** 拍摄照片的设置。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var location

```cangjie
public var location:?Location
```

**功能：** 图片地理位置信息。

**类型：** ?[Location](#class-location)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var mirror

```cangjie
public var mirror: Bool
```

**功能：** 镜像使能开关。使用之前需要使用[isMirrorSupported](#func-ismirrorsupported)进行判断是否支持。true表示使能，false表示不使能。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var quality

```cangjie
public var quality: QualityLevel
```

**功能：** 图片质量。

**类型：** [QualityLevel](#enum-qualitylevel)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var rotation

```cangjie
public var rotation: ImageRotation
```

**功能：** 图片旋转角度。

**类型：** [ImageRotation](#enum-imagerotation)

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### init(QualityLevel, ImageRotation, ?Location, Bool)

```cangjie
public init(
    quality!: QualityLevel = QualityLevel.QualityLevelLow,
    rotation!: ImageRotation = ImageRotation.Rotation0,
    location!: ?Location = None,
    mirror!: Bool = false
)
```

**功能：** 创建PhotoCaptureSetting对象。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|quality|[QualityLevel](#enum-qualitylevel)|否|QualityLevel.QualityLevelLow|**命名参数。** 图片质量(默认低)。|
|rotation|[ImageRotation](#enum-imagerotation)|否|ImageRotation.Rotation0|**命名参数。** 图片旋转角度（默认0度，顺时针旋转）。|
|location|?[Location](#class-location)|否|None|**命名参数。** 图片地理位置信息(默认以设备硬件信息为准)。|
|mirror|Bool|否|false|**命名参数。** 镜像使能开关（默认关）。使用之前需要使用[isMirrorSupported](#func-ismirrorsupported)进行判断是否支持。true表示使能，false表示不使能。|

## class PhotoOutput

```cangjie
public class PhotoOutput <: CameraOutput {}
```

**功能：** 拍照会话中使用的输出信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- [CameraOutput](#interface-cameraoutput)

### func capture()

```cangjie
public func capture(): Unit
```

**功能：** 以默认设置触发一次拍照。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400104 | Session not running. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    output.capture()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func capture(PhotoCaptureSetting)

```cangjie
public func capture(setting: PhotoCaptureSetting): Unit
```

**功能：** 以指定参数触发一次拍照。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|setting|[PhotoCaptureSetting](#class-photocapturesetting)|是|-|拍照设置。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400104 | Session not running. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    output.capture(PhotoCaptureSetting())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func enableMirror(Bool)

```cangjie
public func enableMirror(enabled: Bool): Unit
```

**功能：** 是否启用动态照片镜像拍照。

调用该接口前，需要通过[isMovingPhotoSupported](#func-ismovingphotosupported)查询是否支持动态照片拍摄功能以及通过[isMirrorSupported](#func-ismirrorsupported)查询是否支持镜像拍照功能。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|enabled|Bool|是|-|true为开启镜像拍照，false为关闭镜像拍照。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400103 | Session not config. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    let enabled = true
    output.enableMirror(enabled)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func enableMovingPhoto(Bool)

```cangjie
public func enableMovingPhoto(enabled: Bool): Unit
```

**功能：** 使能动态照片拍照。

**需要权限：** ohos.permission.MICROPHONE

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|enabled|Bool|是|-|使能动态照片拍照。true为开启动态照片，false为关闭动态照片。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | permission denied. |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    let enabled = true
    output.enableMovingPhoto(enabled)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getActiveProfile()

```cangjie
public func getActiveProfile(): Profile
```

**功能：** 获取当前生效的配置信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[Profile](#class-profile)|当前生效的配置信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    let profile = output.getActiveProfile()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getPhotoRotation(Int32)

```cangjie
public func getPhotoRotation(deviceDegree: Int32): ImageRotation
```

**功能：** 获取拍照旋转角度。

- 设备自然方向：设备默认使用方向，手机为竖屏（充电口向下）。
- 相机镜头角度：值等于相机图像顺时针旋转到设备自然方向的角度，手机后置相机传感器是横屏安装的，所以需要顺时针旋转90度到设备自然方向。
- 屏幕显示方向：需要屏幕显示的图片左上角为第一个像素点为坐标原点。锁屏时与自然方向一致。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|deviceDegree|Int32|是|-|设备旋转角度，单位度，取值范围：[0, 360]。<br>若入参超过该范围，则取入参除以360的余数。|

**返回值：**

|类型|说明|
|:----|:----|
|[ImageRotation](#enum-imagerotation)|拍照旋转角度。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    let deviceDegree: Int32 = 0
    let imageRotation = output.getPhotoRotation(deviceDegree)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getSupportedMovingPhotoVideoCodecTypes()

```cangjie
public func getSupportedMovingPhotoVideoCodecTypes(): Array<VideoCodecType>
```

**功能：** 查询支持的动态照片短视频编码类型。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[VideoCodecType](#enum-videocodectype)>|支持的动态照片短视频编码类型列表。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    let videoCodecTypes = output.getSupportedMovingPhotoVideoCodecTypes()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func isMirrorSupported()

```cangjie
public func isMirrorSupported(): Bool
```

**功能：** 查询是否支持镜像拍照。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回是否支持镜像拍照，true表示支持，false表示不支持。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    Hilog.info(0, "AppLogCj", output.isMirrorSupported().toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func isMovingPhotoSupported()

```cangjie
public func isMovingPhotoSupported(): Bool
```

**功能：** 查询是否支持动态照片拍摄。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回是否支持动态照片拍照。true表示支持，false表示不支持。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    Hilog.info(0, "AppLogCj", output.isMovingPhotoSupported().toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback1Argument\<CaptureStartInfo>)

```cangjie
public func off(eventType: CameraEvents, callback: Callback1Argument<CaptureStartInfo>): Unit
```

**功能：** 注销监听拍照。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为CaptureStartWithInfo，photoOutput创建成功后可监听。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[CaptureStartInfo](#class-capturestartinfo)>|是|-|回调函数，用于处理[CaptureStartInfo](#class-capturestartinfo)。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    output.off(CameraEvents.CaptureStartWithInfo)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback1Argument\<FrameShutterInfo>)

```cangjie
public func off(eventType: CameraEvents, callback: Callback1Argument<FrameShutterInfo>): Unit
```

**功能：** 注销监听拍照帧输出捕获。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为FrameShutter，photoOutput创建成功后可监听。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[FrameShutterInfo](#class-frameshutterinfo)>|是|-|回调函数，用于处理[FrameShutterInfo](#class-frameshutterinfo)。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    output.off(CameraEvents.CaptureStartWithInfo)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback1Argument\<CaptureEndInfo>)

```cangjie
public func off(eventType: CameraEvents, callback: Callback1Argument<CaptureEndInfo>): Unit
```

**功能：** 注销监听拍照结束。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为CaptureEnd，photoOutput创建成功后可监听。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[CaptureEndInfo](#class-captureendinfo)>|是|-|回调函数，用于处理[CaptureEndInfo](#class-captureendinfo)。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    output.off(CameraEvents.CaptureStartWithInfo)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback1Argument\<FrameShutterEndInfo>)

```cangjie
public func off(eventType: CameraEvents, callback: Callback1Argument<FrameShutterEndInfo>): Unit
```

**功能：** 注销监听拍照帧输出捕获。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为FrameShutterEnd，photoOutput创建成功后可监听。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[FrameShutterEndInfo](#class-frameshutterendinfo)>|是|-|回调函数，用于处理[FrameShutterEndInfo](#class-frameshutterendinfo)。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    output.off(CameraEvents.CaptureStartWithInfo)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback0Argument)

```cangjie
public func off(eventType: CameraEvents, callback: Callback0Argument): Unit
```

**功能：** 注销监听可拍下一张或注销监听错误。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为[CaptureReady, CameraError]其中之一，photoOutput创建成功后可监听。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    output.off(CameraEvents.CaptureStartWithInfo)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback1Argument\<Float64>)

```cangjie
public func off(eventType: CameraEvents, callback: Callback1Argument<Float64>): Unit
```

**功能：** 注销监听预估的拍照时间。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为EstimatedCaptureDuration，photoOutput创建成功后可监听。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<Float64>|是|-|回调函数，用于获取预估的拍照时间（毫秒）。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    output.off(CameraEvents.CaptureStartWithInfo)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents)

```cangjie
public func off(eventType: CameraEvents): Unit
```

**功能：** 取消对应监听事件的所有回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件。必须为可被on函数监听的事件。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    output.off(CameraEvents.CaptureStartWithInfo)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback1Argument\<CaptureStartInfo>)

```cangjie
public func on(eventType: CameraEvents, callback: Callback1Argument<CaptureStartInfo>): Unit
```

**功能：** 监听拍照开始，通过注册回调函数获取CaptureStartInfo。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为CaptureStartWithInfo，photoOutput创建成功后可监听。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[CaptureStartInfo](#class-capturestartinfo)>|是|-|回调函数，用于处理[CaptureStartInfo](#class-capturestartinfo)。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.callback_invoke.Callback0Argument
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallbackError3 <: Callback0Argument {
    public init() {}
    public func invoke(res: ?BusinessException): Unit {
        Hilog.info(0, "Camera", "Call invoke error. code: ${res?.code}, msg: ${res?.message}")
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    let testCallbackError = TestCallbackError3()
    output.on(CameraEvents.CameraError, testCallbackError)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback1Argument\<FrameShutterInfo>)

```cangjie
public func on(eventType: CameraEvents, callback: Callback1Argument<FrameShutterInfo>): Unit
```

**功能：** 监听拍照帧输出捕获，通过注册回调函数获取结果。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为FrameShutter，photoOutput创建成功后可监听。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[FrameShutterInfo](#class-frameshutterinfo)>|是|-|回调函数，用于处理[FrameShutterInfo](#class-frameshutterinfo)。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.callback_invoke.Callback0Argument
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallbackError4 <: Callback0Argument {
    public init() {}
    public func invoke(res: ?BusinessException): Unit {
        Hilog.info(0, "Camera", "Call invoke error. code: ${res?.code}, msg: ${res?.message}")
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    let testCallbackError = TestCallbackError4()
    output.on(CameraEvents.CameraError, testCallbackError)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback1Argument\<CaptureEndInfo>)

```cangjie
public func on(eventType: CameraEvents, callback: Callback1Argument<CaptureEndInfo>): Unit
```

**功能：** 监听拍照结束，通过注册回调函数获取结果。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为CaptureEnd。photoOutput创建成功后可监听。拍照完全结束可触发该事件发生并返回相应信息。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[CaptureEndInfo](#class-captureendinfo)>|是|-|回调函数，用于处理[CaptureEndInfo](#class-captureendinfo)。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.callback_invoke.Callback0Argument
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallbackError5 <: Callback0Argument {
    public init() {}
    public func invoke(res: ?BusinessException): Unit {
        Hilog.info(0, "Camera", "Call invoke error. code: ${res?.code}, msg: ${res?.message}")
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    let testCallbackError = TestCallbackError5()
    output.on(CameraEvents.CameraError, testCallbackError)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback1Argument\<FrameShutterEndInfo>)

```cangjie
public func on(eventType: CameraEvents, callback: Callback1Argument<FrameShutterEndInfo>): Unit
```

**功能：** 监听拍照曝光结束捕获，通过注册回调函数获取结果。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为FrameShutterEnd，photoOutput创建成功后可监听。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[FrameShutterEndInfo](#class-frameshutterendinfo)>|是|-|回调函数，用于处理[FrameShutterEndInfo](#class-frameshutterendinfo)。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.callback_invoke.Callback0Argument
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallbackError6 <: Callback0Argument {
    public init() {}
    public func invoke(res: ?BusinessException): Unit {
        Hilog.info(0, "Camera", "Call invoke error. code: ${res?.code}, msg: ${res?.message}")
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    let testCallbackError = TestCallbackError6()
    output.on(CameraEvents.CameraError, testCallbackError)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback0Argument)

```cangjie
public func on(eventType: CameraEvents, callback: Callback0Argument): Unit
```

**功能：** 监听可拍下一张或拍照错误，通过注册回调函数获取结果。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为[CaptureReady, CameraError]其中之一，photoOutput创建成功后可监听。当下一张可拍时或拍照接口调用时出现错误可触发该事件发生并返回相应信息。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.callback_invoke.Callback0Argument
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallbackError7 <: Callback0Argument {
    public init() {}
    public func invoke(res: ?BusinessException): Unit {
        Hilog.info(0, "Camera", "Call invoke error. code: ${res?.code}, msg: ${res?.message}")
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    let testCallbackError = TestCallbackError7()
    output.on(CameraEvents.CameraError, testCallbackError)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback1Argument\<Float64>)

```cangjie
public func on(eventType: CameraEvents, callback: Callback1Argument<Float64>): Unit
```

**功能：** 监听预估的拍照时间，通过注册回调函数获取结果。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为EstimatedCaptureDuration，photoOutput创建成功后可监听。拍照完全结束可触发该事件发生并返回相应信息。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<Float64>|是|-|回调函数，用于获取预估的单次拍照底层出sensor采集帧时间，单位：毫秒。如果上报-1，代表没有预估时间。 |

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.callback_invoke.Callback0Argument
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallbackError8 <: Callback0Argument {
    public init() {}
    public func invoke(res: ?BusinessException): Unit {
        Hilog.info(0, "Camera", "Call invoke error. code: ${res?.code}, msg: ${res?.message}")
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    let testCallbackError = TestCallbackError8()
    output.on(CameraEvents.CameraError, testCallbackError)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func release()

```cangjie
public func release(): Unit
```

**功能：** 释放输出资源。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    output.release()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setMovingPhotoVideoCodecType(VideoCodecType)

```cangjie
public func setMovingPhotoVideoCodecType(codecType: VideoCodecType): Unit
```

**功能：** 设置动态照片短视频编码类型。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|codecType|[VideoCodecType](#enum-videocodectype)|是|-|获取动态照片短视频编码类型。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let output = cameraManager.createPhotoOutput(profile:ability.photoProfiles[0])
    output.setMovingPhotoVideoCodecType(VideoCodecType.Avc)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class PhotoSession

```cangjie
public class PhotoSession <: Session & Flash & AutoExposure & Focus & Zoom & ColorManagement {}
```

**功能：** 普通拍照模式会话类，提供了对闪光灯、曝光、白平衡、对焦、变焦、色彩空间及微距的操作。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- [Session](#interface-session)
- [Flash](#interface-flash)
- [AutoExposure](#interface-autoexposure)
- [Focus](#interface-focus)
- [Zoom](#interface-zoom)
- [ColorManagement](#interface-colormanagement)

### func canPreconfig(PreconfigType, PreconfigRatio)

```cangjie
public func canPreconfig(preconfigType: PreconfigType, preconfigRatio!: PreconfigRatio = PreconfigRatio_4_3): Bool
```

**功能：** 查询当前Session是否支持指定的预配置类型。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|preconfigType|[PreconfigType](#enum-preconfigtype)|是|-|指定配置预期分辨率。|
|preconfigRatio|[PreconfigRatio](#enum-preconfigratio)|否|PreconfigRatio_4_3|**命名参数。** 可选画幅比例，默认为4:3。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|true: 支持指定预配值类型。false: 不支持指定预配值类型。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let photoSession = cameraManager.createSession(SceneMode.NormalPhoto) as PhotoSession
    let session = photoSession.getOrThrow()
    Hilog.info(0, "AppLogCj", session.canPreconfig(Preconfig1080p, preconfigRatio: PreconfigRatio_16_9).toString())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback0Argument)

```cangjie
public func off(eventType: CameraEvents, callback: Callback0Argument): Unit
```

**功能：** 注销监听普通拍照会话的错误事件，通过注册回调函数获取结果。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为CameraError，session创建成功之后可监听该接口。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数，用于处理[BusinessException](../arkinterop/cj-api-business_exception.md#class-businessexception)。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let photoSession = cameraManager.createSession(SceneMode.NormalPhoto) as PhotoSession
    let session = photoSession.getOrThrow()
    session.off(CameraEvents.FocusStateChange)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback1Argument\<FocusState>)

```cangjie
public func off(eventType: CameraEvents, callback: Callback1Argument<FocusState>): Unit
```

**功能：** 注销监听相机聚焦的状态变化。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为FocusStateChange，session创建成功可监听。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[FocusState](#enum-focusstate)>|是|-|回调函数，用于处理[FocusState](#enum-focusstate)。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let photoSession = cameraManager.createSession(SceneMode.NormalPhoto) as PhotoSession
    let session = photoSession.getOrThrow()
    session.off(CameraEvents.FocusStateChange)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback1Argument\<SmoothZoomInfo>)

```cangjie
public func off(eventType: CameraEvents, callback: Callback1Argument<SmoothZoomInfo>): Unit
```

**功能：** 注销监听相机平滑变焦的状态变化。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为SmoothZoomInfoAvailable，session创建成功可监听。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[SmoothZoomInfo](#class-smoothzoominfo)>|是|-|回调函数，用于处理[SmoothZoomInfo](#class-smoothzoominfo)。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let photoSession = cameraManager.createSession(SceneMode.NormalPhoto) as PhotoSession
    let session = photoSession.getOrThrow()
    session.off(CameraEvents.FocusStateChange)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents)

```cangjie
public func off(eventType: CameraEvents): Unit
```

**功能：** 注销监听普通拍照会话的错误事件/相机聚焦的状态变化/相机平滑变焦的状态变化。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件。必须为可被on函数监听的事件。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let photoSession = cameraManager.createSession(SceneMode.NormalPhoto) as PhotoSession
    let session = photoSession.getOrThrow()
    session.off(CameraEvents.FocusStateChange)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback0Argument)

```cangjie
public func on(eventType: CameraEvents, callback: Callback0Argument): Unit
```

**功能：** 监听普通拍照会话的错误事件，通过注册回调函数获取结果。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为CameraError，session创建成功之后可监听该接口。session调用相关接口出现错误时会触发该事件，比如调用[beginConfig](#func-beginconfig)，[commitConfig](#func-commitconfig)，[addInput](#func-addinputcamerainput)等接口发生错误时返回错误信息。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数，用于处理[BusinessException](../arkinterop/cj-api-business_exception.md#class-businessexception)。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.callback_invoke.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class SmoothZoomInfoAvailableCallback4 <: Callback1Argument<SmoothZoomInfo> {
    public static var invoked = false

    public func invoke(err: ?BusinessException, info: SmoothZoomInfo) {
        Hilog.info(0, "AppLogCj", "[multimedia_camera | SmoothZoomInfoAvailable Callback]: info: ${info.duration}")
        invoked = true
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let photoSession = cameraManager.createSession(SceneMode.NormalPhoto) as PhotoSession
    let session = photoSession.getOrThrow()
    let callback = SmoothZoomInfoAvailableCallback4()
    session.on(CameraEvents.SmoothZoomInfoAvailable, callback)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback1Argument\<FocusState>)

```cangjie
public func on(eventType: CameraEvents, callback: Callback1Argument<FocusState>): Unit
```

**功能：** 监听相机聚焦的状态变化，通过注册回调函数获取结果。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为FocusStateChange，session创建成功可监听。仅当自动对焦模式时，且相机对焦状态发生改变时可触发该事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[FocusState](#enum-focusstate)>|是|-|回调函数，用于获取当前对焦状态。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.callback_invoke.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class FocusStateChangeCallback <: Callback1Argument<FocusState> {
    public static var invoked = false

    public func invoke(err: ?BusinessException, state: FocusState) {
        Hilog.info(0, "AppLogCj", "[multimedia_camera | FocusStateChange Callback]: state: ${state.toString()}")
        invoked = true
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let photoSession = cameraManager.createSession(SceneMode.NormalPhoto) as PhotoSession
    let session = photoSession.getOrThrow()
    let callback = FocusStateChangeCallback()
    session.on(CameraEvents.FocusStateChange, callback)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback1Argument\<SmoothZoomInfo>)

```cangjie
public func on(eventType: CameraEvents, callback: Callback1Argument<SmoothZoomInfo>): Unit
```

**功能：** 监听相机平滑变焦的状态变化，通过注册回调函数获取结果。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为SmoothZoomInfoAvailable，session创建成功可监听。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[SmoothZoomInfo](#class-smoothzoominfo)>|是|-|回调函数，用于获取当前平滑变焦状态。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.callback_invoke.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class SmoothZoomInfoAvailableCallback2 <: Callback1Argument<SmoothZoomInfo> {
    public static var invoked = false

    public func invoke(err: ?BusinessException, info: SmoothZoomInfo) {
        Hilog.info(0, "AppLogCj", "[multimedia_camera | SmoothZoomInfoAvailable Callback]: info: ${info.duration}")
        invoked = true
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let photoSession = cameraManager.createSession(SceneMode.NormalPhoto) as PhotoSession
    let session = photoSession.getOrThrow()
    let callback = SmoothZoomInfoAvailableCallback2()
    session.on(CameraEvents.SmoothZoomInfoAvailable, callback)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func preconfig(PreconfigType, PreconfigRatio)

```cangjie
public func preconfig(
    preconfigType: PreconfigType,
    preconfigRatio!: PreconfigRatio = PreconfigRatio.PreconfigRatio_4_3
): Unit
```

**功能：** 对当前Session进行预配置。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|preconfigType|[PreconfigType](#enum-preconfigtype)|是|-|指定配置预期分辨率。|
|preconfigRatio|[PreconfigRatio](#enum-preconfigratio)|否|PreconfigRatio.PreconfigRatio_4_3|**命名参数。** 可选画幅比例，默认为4:3。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let photoSession = cameraManager.createSession(SceneMode.NormalPhoto) as PhotoSession
    let session = photoSession.getOrThrow()
    session.preconfig(Preconfig1080p, preconfigRatio: PreconfigRatio_16_9)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class Point

```cangjie
public class Point {
    public var x: Float64
    public var y: Float64
    public init(x: Float64, y: Float64)
}
```

**功能：** 点坐标用于对焦和曝光配置。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var x

```cangjie
public var x: Float64
```

**功能：** 点的x坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var y

```cangjie
public var y: Float64
```

**功能：** 点的y坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### init(Float64, Float64)

```cangjie
public init(x: Float64, y: Float64)
```

**功能：** 创建Point对象。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|x|Float64|是|-|点的x坐标。|
|y|Float64|是|-|点的y坐标。|

## class PreviewOutput

```cangjie
public class PreviewOutput <: CameraOutput {}
```

**功能：** 预览输出类。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- [CameraOutput](#interface-cameraoutput)

### func getActiveFrameRate()

```cangjie
public func getActiveFrameRate(): FrameRateRange
```

**功能：** 获取已设置的帧率范围。

使用[setFrameRate](#func-setframerateint32-int32)接口对预览流设置过帧率后可查询。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[FrameRateRange](#class-frameraterange)|帧率范围。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createPreviewOutput(ability.previewProfiles[0], surfaceId)
    let range = output.getActiveFrameRate()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getActiveProfile()

```cangjie
public func getActiveProfile(): Profile
```

**功能：** 获取当前生效的配置信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[Profile](#class-profile)|当前生效的配置信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createPreviewOutput(ability.previewProfiles[0], surfaceId)
    let profile = output.getActiveProfile()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getPreviewRotation(Int32)

```cangjie
public func getPreviewRotation(displayRotation: Int32): ImageRotation
```

**功能：** 获取预览旋转角度。

- 设备自然方向：设备默认使用方向，手机为竖屏（充电口向下）。
- 相机镜头角度：值等于相机图像顺时针旋转到设备自然方向的角度，手机后置相机传感器是横屏安装的，所以需要顺时针旋转90度到设备自然方向。
- 屏幕显示方向：需要屏幕显示的图片左上角为第一个像素点为坐标原点。锁屏时与自然方向一致。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|displayRotation|Int32|是|-|显示设备的屏幕旋转角度，通过[getDefaultDisplaySync](../arkui-cj/cj-apis-display.md#func-getdefaultdisplaysync)获得。|

**返回值：**

|类型|说明|
|:----|:----|
|[ImageRotation](#enum-imagerotation)|获取预览旋转角度。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createPreviewOutput(ability.previewProfiles[0], surfaceId)
    let imageRotation = output.getPreviewRotation(0)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getSupportedFrameRates()

```cangjie
public func getSupportedFrameRates(): Array<FrameRateRange>
```

**功能：** 查询支持的帧率范围。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[FrameRateRange](#class-frameraterange)>|支持的帧率范围列表。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createPreviewOutput(ability.previewProfiles[0], surfaceId)
    let frameRateRanges = output.getSupportedFrameRates()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback0Argument)

```cangjie
public func off(eventType: CameraEvents, callback: Callback0Argument): Unit
```

**功能：** 注销监听特定事件。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为[FrameStart, FrameEnd, CameraError]其中之一。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createPreviewOutput(ability.previewProfiles[0], surfaceId)
    output.off(CameraEvents.CameraError)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents)

```cangjie
public func off(eventType: CameraEvents): Unit
```

**功能：** 取消对应监听事件的所有回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件。必须为可被on函数监听的事件。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createPreviewOutput(ability.previewProfiles[0], surfaceId)
    output.off(CameraEvents.CameraError)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback0Argument)

```cangjie
public func on(eventType: CameraEvents, callback: Callback0Argument): Unit
```

**功能：** 监听预览帧启动，通过注册回调函数获取结果。

> **说明：**
>
> 不支持在on监听的回调方法里调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为[FrameStart, FrameEnd, CameraError]其中之一。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.callback_invoke.Callback0Argument
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallbackError1 <: Callback0Argument {
    public init() {}
    public func invoke(res: ?BusinessException): Unit {
        Hilog.info(0, "Camera", "Call invoke error. code: ${res?.code}, msg: ${res?.message}")
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createPreviewOutput(ability.previewProfiles[0], surfaceId)
    let testCallbackError = TestCallbackError1()
    output.on(CameraEvents.CameraError, testCallbackError)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func release()

```cangjie
public func release(): Unit
```

**功能：** 释放输出资源。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createPreviewOutput(ability.previewProfiles[0], surfaceId)
    output.release()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setFrameRate(Int32, Int32)

```cangjie
public func setFrameRate(minFps: Int32, maxFps: Int32): Unit
```

**功能：** 设置预览流帧率范围，设置的范围必须在支持的帧率范围内。
进行设置前，可通过[getSupportedFrameRates](#func-getsupportedframerates)查询支持的帧率范围。

> **说明：**
>
> 仅在[PhotoSession](#class-photosession)或[VideoSession](#class-videosession)模式下支持。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|minFps|Int32|是|-|最小帧率（单位：fps），当传入的最大值小于最小值时，传参异常，接口不生效。|
|maxFps|Int32|是|-|最大帧率（单位：fps），当传入的最小值大于最大值时，传参异常，接口不生效。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400110 | Unresolved conflicts with current configurations. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createPreviewOutput(ability.previewProfiles[0], surfaceId)
    output.setFrameRate(30, 60)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setPreviewRotation(ImageRotation, Bool)

```cangjie
public func setPreviewRotation(previewRotation: ImageRotation, isDisplayLocked!: Bool = false): Unit
```

**功能：** 设置预览旋转角度。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|previewRotation|[ImageRotation](#enum-imagerotation)|是|-|预览旋转角度。|
|isDisplayLocked|Bool|否|false|**命名参数。** Surface在屏幕旋转时是否锁定方向，未设置时默认取值为false，即不锁定方向。true表示锁定方向，false表示不锁定方向。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[0]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createPreviewOutput(ability.previewProfiles[0], surfaceId)
    output.setPreviewRotation(ImageRotation.Rotation90)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class Profile

```cangjie
public open class Profile {
    public let format: CameraFormat
    public let size: Size
}
```

**功能：** 相机配置信息项。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let format

```cangjie
public let format: CameraFormat
```

**功能：** 输出格式。

**类型：** [CameraFormat](#enum-cameraformat)

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let size

```cangjie
public let size: Size
```

**功能：** 分辨率。

设置的是相机的分辨率宽度和高度，而非实际输出图像的宽度和高度。

**类型：** [Size](#class-size)

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class Rect

```cangjie
public class Rect {
    public var topLeftX: Float64
    public var topLeftY: Float64
    public var width: Float64
    public var height: Float64
}
```

**功能：** 矩形定义，返回的检测点坐标系以设备充电口在右侧时的横向设备方向为基准。该坐标系左上角为（0，0），右下角为（1，1），其中（topLeftX，topLeftY）表示矩形区域的左上角坐标，width和height分别表示矩形区域的宽和高。因此在实际使用中根据业务诉求需要裁剪或者选择人脸区域时，必须将矩形区域的x坐标和y坐标分别乘以实际相机输出流的宽和高，即可得到裁剪后的人脸矩形区域。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var height

```cangjie
public var height: Float64
```

**功能：** 矩形高，相对值，范围[0.0, 1.0]。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var topLeftX

```cangjie
public var topLeftX: Float64
```

**功能：** 矩形区域左上角x坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var topLeftY

```cangjie
public var topLeftY: Float64
```

**功能：** 矩形区域左上角y坐标。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var width

```cangjie
public var width: Float64
```

**功能：** 矩形宽，相对值，范围[0.0, 1.0]。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class Size

```cangjie
public class Size {
    public var width: UInt32
    public var height: UInt32
}
```

**功能：** 尺寸参数。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var height

```cangjie
public var height: UInt32
```

**功能：** 图像尺寸高(像素)。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var width

```cangjie
public var width: UInt32
```

**功能：** 图像尺寸宽(像素)。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class SmoothZoomInfo

```cangjie
public class SmoothZoomInfo {
    public var duration: Int32
}
```

**功能：** 平滑变焦参数信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### var duration

```cangjie
public var duration: Int32
```

**功能：** 平滑变焦总时长，单位ms。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class TorchStatusInfo

```cangjie
public class TorchStatusInfo {
    public let isTorchAvailable: Bool
    public let isTorchActive: Bool
    public let torchLevel: Float64
}
```

**功能：** 手电筒回调返回的接口实例，表示手电筒状态信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let isTorchActive

```cangjie
public let isTorchActive: Bool
```

**功能：** 手电筒是否被激活。true表示手电筒被激活，false表示手电筒未被激活。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let isTorchAvailable

```cangjie
public let isTorchAvailable: Bool
```

**功能：** 手电筒是否可用。true表示手电筒可用，false表示手电筒不可用。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### let torchLevel

```cangjie
public let torchLevel: Float64
```

**功能：** 手电筒亮度等级。取值范围为[0.0,1.0]，越靠近1，亮度越大。

**类型：** Float64

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class VideoOutput

```cangjie
public class VideoOutput  <:  CameraOutput {}
```

**功能：** 录像会话中使用的输出信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- [CameraOutput](#interface-cameraoutput)

### func getActiveFrameRate()

```cangjie
public func getActiveFrameRate(): FrameRateRange
```

**功能：** 获取已设置的帧率范围。

使用[setFrameRate](#func-setframerateint32-int32)对录像流设置过帧率后可查询。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[FrameRateRange](#class-frameraterange)|帧率范围。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[1]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createVideoOutput(ability.videoProfiles[0], surfaceId)
    let frameRateRange = output.getActiveFrameRate()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getActiveProfile()

```cangjie
public func getActiveProfile(): VideoProfile
```

**功能：** 获取当前生效的配置信息。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[VideoProfile](#class-videoprofile)|当前生效的配置信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[1]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createVideoOutput(ability.videoProfiles[0], surfaceId)
    let videoProfile = output.getActiveProfile()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getSupportedFrameRates()

```cangjie
public func getSupportedFrameRates(): Array<FrameRateRange>
```

**功能：** 查询支持的帧率范围。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[FrameRateRange](#class-frameraterange)>|支持的帧率范围列表。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[1]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createVideoOutput(ability.videoProfiles[0], surfaceId)
    let frameRateRanges = output.getSupportedFrameRates()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getVideoRotation(Int32)

```cangjie
public func getVideoRotation(deviceDegree: Int32): ImageRotation
```

**功能：** 获取录像旋转角度。

- 设备自然方向：设备默认使用方向，手机为竖屏（充电口向下）。
- 相机镜头角度：值等于相机图像顺时针旋转到设备自然方向的角度，手机后置相机传感器是横屏安装的，所以需要顺时针旋转90度到设备自然方向。
- 屏幕显示方向：需要屏幕显示的图片左上角为第一个像素点为坐标原点。锁屏时与自然方向一致。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|deviceDegree|Int32|是|-|设备旋转角度。|

**返回值：**

|类型|说明|
|:----|:----|
|[ImageRotation](#enum-imagerotation)|设备旋转角度，单位度，取值范围0-360。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[1]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createVideoOutput(ability.videoProfiles[0], surfaceId)
    let imageRotation = output.getVideoRotation(0)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback0Argument)

```cangjie
public func off(eventType: CameraEvents, callback: Callback0Argument): Unit
```

**功能：** 注销监听特定事件的特定回调函数。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为[FrameStart, FrameEnd, CameraError]其中之一，videoOutput创建成功后可监听。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数，要取消的callback。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[1]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createVideoOutput(ability.videoProfiles[0], surfaceId)
    output.off(CameraEvents.CameraError)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents)

```cangjie
public func off(eventType: CameraEvents): Unit
```

**功能：** 取消对应监听事件的所有回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为[FrameStart, FrameEnd, CameraError]其中之一。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[1]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createVideoOutput(ability.videoProfiles[0], surfaceId)
    output.off(CameraEvents.CameraError)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback0Argument)

```cangjie
public func on(eventType: CameraEvents, callback: Callback0Argument): Unit
```

**功能：** 监听录像的特定事件。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为[FrameStart, FrameEnd, CameraError]其中之一，videoOutput创建成功后可监听。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数，正常时无信息捕获，出错时捕获错误信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.callback_invoke.Callback0Argument
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallbackError2 <: Callback0Argument {
    public init() {}
    public func invoke(res: ?BusinessException): Unit {
        Hilog.info(0, "Camera", "Call invoke error. code: ${res?.code}, msg: ${res?.message}")
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[1]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createVideoOutput(ability.videoProfiles[0], surfaceId)
    let testCallbackError = TestCallbackError2()
    output.on(CameraEvents.CameraError, testCallbackError)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func release()

```cangjie
public func release(): Unit
```

**功能：** 释放输出资源。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[1]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createVideoOutput(ability.videoProfiles[0], surfaceId)
    output.release()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setFrameRate(Int32, Int32)

```cangjie
public func setFrameRate(minFps: Int32, maxFps: Int32): Unit
```

**功能：** 设置录像流帧率范围，设置的范围必须在支持的帧率范围内。

进行设置前，可通过[getSupportedFrameRates](#func-getsupportedframerates)查询支持的帧率范围。

> **说明：**
>
> - 仅在[PhotoSession](#class-photosession)或[VideoSession](#class-videosession)模式下支持。
>
> - 接口调用前，先调用[getActiveFrameRate](#func-getactiveframerate)接口查询当前VideoSession的帧率，若下发的帧率与当前帧率相等，则下发的帧率不会生效。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|minFps|Int32|是|-|最小帧率，单位：fps。当传入的最大值小于最小值时，传参异常，接口不生效。|
|maxFps|Int32|是|-|最大帧率，单位：fps。当传入的最小值大于最大值时，传参异常，接口不生效。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400101 | Parameter missing or parameter type incorrect. |
  | 7400110 | Unresolved conflicts with current configurations. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[1]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createVideoOutput(ability.videoProfiles[0], surfaceId)
    output.setFrameRate(30, 60)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func start()

```cangjie
public func start(): Unit
```

**功能：** 启动录制。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400103 | Session not config. |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[1]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createVideoOutput(ability.videoProfiles[0], surfaceId)
    output.start()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func stop()

```cangjie
public func stop(): Unit
```

**功能：** 结束录制。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import kit.ImageKit.createImageReceiver
import kit.ImageKit.Size as ImageSize
import kit.ImageKit.ImageFormat
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let device = cameraManager.getSupportedCameras()[0]
    let mode = cameraManager.getSupportedSceneModes(device)[1]
    let ability = cameraManager.getSupportedOutputCapability(device, mode)
    let size = ImageSize(8, 8192)
    let receiver = createImageReceiver(size, ImageFormat.Jpeg, 8)
    let surfaceId: String = receiver.getReceivingSurfaceId()
    let output = cameraManager.createVideoOutput(ability.videoProfiles[0], surfaceId)
    output.stop()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class VideoProfile

```cangjie
public class VideoProfile <: Profile {
    public let frameRateRange: FrameRateRange
}
```

**功能：** 视频配置信息项。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- [Profile](#class-profile)

### let frameRateRange

```cangjie
public let frameRateRange: FrameRateRange
```

**功能：** 帧率范围，单位：fps(frames per second)。

**类型：** [FrameRateRange](#class-frameraterange)

**读写能力：** 只读

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

## class VideoSession

```cangjie
public class VideoSession <: Session & Flash & AutoExposure & Focus & Zoom & Stabilization & ColorManagement {}
```

**功能：** 普通录像模式会话类，提供了对闪光灯、曝光、白平衡、对焦、变焦、视频防抖、色彩空间、微距及控制器的操作。

> **说明：**
>
> 默认的视频录制模式，适用于一般场景。支持720P、1080p等多种分辨率的录制，可选择不同帧率（如30fps、60fps）。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- [Session](#interface-session)
- [Flash](#interface-flash)
- [AutoExposure](#interface-autoexposure)
- [Focus](#interface-focus)
- [Zoom](#interface-zoom)
- [Stabilization](#interface-stabilization)
- [ColorManagement](#interface-colormanagement)

### func canPreconfig(PreconfigType, PreconfigRatio)

```cangjie
public func canPreconfig(preconfigType: PreconfigType, preconfigRatio!: PreconfigRatio = PreconfigRatio_16_9): Bool
```

**功能：** 查询当前Session是否支持指定的预配置类型。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|preconfigType|[PreconfigType](#enum-preconfigtype)|是|-|指定配置预期分辨率。|
|preconfigRatio|[PreconfigRatio](#enum-preconfigratio)|否|PreconfigRatio_16_9|**命名参数。** 可选画幅比例，默认为16:9。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|true: 支持指定预配置类型。<br/>false: 不支持指定预配置类型。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let videoSession = cameraManager.createSession(SceneMode.NormalVideo) as VideoSession
    let session = videoSession.getOrThrow()
    let result = session.canPreconfig(Preconfig1080p, preconfigRatio: PreconfigRatio_16_9)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback0Argument)

```cangjie
public func off(eventType: CameraEvents, callback: Callback0Argument): Unit
```

**功能：** 注销监听普通录像会话的错误事件。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为CameraError，session创建成功之后可监听该接口。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数，取消对应callback。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let videoSession = cameraManager.createSession(SceneMode.NormalVideo) as VideoSession
    let session = videoSession.getOrThrow()
    session.off(CameraEvents.SmoothZoomInfoAvailable)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback1Argument\<FocusState>)

```cangjie
public func off(eventType: CameraEvents, callback: Callback1Argument<FocusState>): Unit
```

**功能：** 注销监听相机聚焦的状态变化。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为FocusStateChange，session创建成功之后可监听该接口。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[FocusState](#enum-focusstate)>|是|-|回调函数，取消对应callback。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let videoSession = cameraManager.createSession(SceneMode.NormalVideo) as VideoSession
    let session = videoSession.getOrThrow()
    session.off(CameraEvents.SmoothZoomInfoAvailable)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents, Callback1Argument\<SmoothZoomInfo>)

```cangjie
public func off(eventType: CameraEvents, callback: Callback1Argument<SmoothZoomInfo>): Unit
```

**功能：** 注销监听相机平滑变焦的状态变化。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为SmoothZoomInfoAvailable，session创建成功之后可监听该接口。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[SmoothZoomInfo](#class-smoothzoominfo)>|是|-|回调函数，取消对应callback。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let videoSession = cameraManager.createSession(SceneMode.NormalVideo) as VideoSession
    let session = videoSession.getOrThrow()
    session.off(CameraEvents.SmoothZoomInfoAvailable)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(CameraEvents)

```cangjie
public func off(eventType: CameraEvents): Unit
```

**功能：** 注销监听普通录像会话的错误事件。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let videoSession = cameraManager.createSession(SceneMode.NormalVideo) as VideoSession
    let session = videoSession.getOrThrow()
    session.off(CameraEvents.SmoothZoomInfoAvailable)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback0Argument)

```cangjie
public func on(eventType: CameraEvents, callback: Callback0Argument): Unit
```

**功能：** 监听普通录像会话的错误事件，通过注册回调函数获取结果。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为CameraError，session创建成功之后可监听该接口。session调用相关接口出现错误时会触发该事件，比如调用[beginConfig](#func-beginconfig)，[commitConfig](#func-commitconfig)，[addInput](#func-addinputcamerainput)等接口发生错误时返回错误信息。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数，用于获取错误信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.callback_invoke.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class SmoothZoomInfoAvailableCallback3 <: Callback1Argument<SmoothZoomInfo> {
    public static var invoked = false

    public func invoke(err: ?BusinessException, info: SmoothZoomInfo) {
        Hilog.info(0, "AppLogCj", "[multimedia_camera | SmoothZoomInfoAvailable Callback]: info: ${info.duration}")
        invoked = true
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let videoSession = cameraManager.createSession(SceneMode.NormalVideo) as VideoSession
    let session = videoSession.getOrThrow()
    let callback = SmoothZoomInfoAvailableCallback3()
    session.on(CameraEvents.SmoothZoomInfoAvailable, callback)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback1Argument\<FocusState>)

```cangjie
public func on(eventType: CameraEvents, callback: Callback1Argument<FocusState>): Unit
```

**功能：** 监听相机聚焦的状态变化，通过注册回调函数获取结果。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为FocusStateChange，session创建成功之后可监听该接口。仅当自动对焦模式时，且相机对焦状态发生改变时可触发该事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[FocusState](#enum-focusstate)>|是|-|回调函数，用于获取当前对焦状态。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.callback_invoke.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class FocusStateChangeCallback1 <: Callback1Argument<FocusState> {
    public static var invoked = false

    public func invoke(err: ?BusinessException, state: FocusState) {
        Hilog.info(0, "AppLogCj", "[multimedia_camera | FocusStateChange Callback]: state: ${state.toString()}")
        invoked = true
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let videoSession = cameraManager.createSession(SceneMode.NormalVideo) as VideoSession
    let session = videoSession.getOrThrow()
    let callback = FocusStateChangeCallback1()
    session.on(CameraEvents.FocusStateChange, callback)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(CameraEvents, Callback1Argument\<SmoothZoomInfo>)

```cangjie
public func on(eventType: CameraEvents, callback: Callback1Argument<SmoothZoomInfo>): Unit
```

**功能：** 监听相机平滑变焦的状态变化，通过注册回调函数获取结果。

> **说明：**
>
> 当前注册监听接口，不支持在on监听的回调方法里，调用off注销回调。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[CameraEvents](#enum-cameraevents)|是|-|监听事件，必须为SmoothZoomInfoAvailable，session创建成功之后可监听该接口。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[SmoothZoomInfo](#class-smoothzoominfo)>|是|-|回调函数，用于获取当前平滑变焦状态。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.callback_invoke.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class SmoothZoomInfoAvailableCallback6 <: Callback1Argument<SmoothZoomInfo> {
    public static var invoked = false

    public func invoke(err: ?BusinessException, info: SmoothZoomInfo) {
        Hilog.info(0, "AppLogCj", "[multimedia_camera | SmoothZoomInfoAvailable Callback]: info: ${info.duration}")

        invoked = true
    }
}

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let videoSession = cameraManager.createSession(SceneMode.NormalVideo) as VideoSession
    let session = videoSession.getOrThrow()
    let callback = SmoothZoomInfoAvailableCallback6()
    session.on(CameraEvents.SmoothZoomInfoAvailable, callback)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func preconfig(PreconfigType, PreconfigRatio)

```cangjie
public func preconfig(
    preconfigType: PreconfigType,
    preconfigRatio!: PreconfigRatio = PreconfigRatio.PreconfigRatio_16_9
): Unit
```

**功能：** 对当前Session进行预配置。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|preconfigType|[PreconfigType](#enum-preconfigtype)|是|-|指定配置预期分辨率。|
|preconfigRatio|[PreconfigRatio](#enum-preconfigratio)|否|PreconfigRatio.PreconfigRatio_16_9|**命名参数。** 可选画幅比例，默认为16:9。|

**异常：**

- BusinessException：对应错误码如下表，详见[Camera错误码](./cj-errorcode-multimedia-camera.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 7400201 | Camera service fatal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.CameraKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let cameraManager = getCameraManager(ctx)
    let videoSession = cameraManager.createSession(SceneMode.NormalVideo) as VideoSession
    let session = videoSession.getOrThrow()
    session.preconfig(Preconfig1080p, preconfigRatio: PreconfigRatio_16_9)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## enum CameraEvents

```cangjie
public enum CameraEvents {
    | CameraError
    | CameraStatus
    | FoldStatusChange
    | TorchStatusChange
    | FrameStart
    | FrameEnd
    | CaptureStartWithInfo
    | FrameShutter
    | CaptureEnd
    | FrameShutterEnd
    | CaptureReady
    | EstimatedCaptureDuration
    | MetadataObjectsAvailable
    | FocusStateChange
    | SmoothZoomInfoAvailable
    | ...
}
```

**功能：** 监听事件名。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<CameraEvents>

### CameraError

```cangjie
CameraError
```

**功能：** 错误事件。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraStatus

```cangjie
CameraStatus
```

**功能：** 相机的状态变化。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CaptureEnd

```cangjie
CaptureEnd
```

**功能：** 拍照结束。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CaptureReady

```cangjie
CaptureReady
```

**功能：** 可拍下一张。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CaptureStartWithInfo

```cangjie
CaptureStartWithInfo
```

**功能：** 拍照开始。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### EstimatedCaptureDuration

```cangjie
EstimatedCaptureDuration
```

**功能：** 预估的拍照时间。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### FocusStateChange

```cangjie
FocusStateChange
```

**功能：** 相机聚焦的状态变化。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### FoldStatusChange

```cangjie
FoldStatusChange
```

**功能：** 折叠设备折叠状态发生变化。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### FrameEnd

```cangjie
FrameEnd
```

**功能：** 预览帧结束。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### FrameShutter

```cangjie
FrameShutter
```

**功能：** 拍照帧输出捕获。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### FrameShutterEnd

```cangjie
FrameShutterEnd
```

**功能：** 拍照曝光结束。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### FrameStart

```cangjie
FrameStart
```

**功能：** 预览帧启动。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### MetadataObjectsAvailable

```cangjie
MetadataObjectsAvailable
```

**功能：** 检测到metadata对象。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### SmoothZoomInfoAvailable

```cangjie
SmoothZoomInfoAvailable
```

**功能：** 相机平滑变焦的状态变化。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### TorchStatusChange

```cangjie
TorchStatusChange
```

**功能：** 手电筒状态变化。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(CameraEvents)

```cangjie
public operator func !=(other: CameraEvents): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CameraEvents](#enum-cameraevents)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|true表示不相等，false表示相等。|

### func ==(CameraEvents)

```cangjie
public operator func ==(other: CameraEvents): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CameraEvents](#enum-cameraevents)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|true表示相等，false表示不相等。|

## enum CameraFormat

```cangjie
public enum CameraFormat {
    | CameraFormatRgba8888
    | CameraFormatYuv420Sp
    | CameraFormatJpeg
    | CameraFormatYcbcrP010
    | CameraFormatYcrcbP010
    | CameraFormatHeic
    | ...
}
```

**功能：** 枚举，输出格式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraFormatHeic

```cangjie
CameraFormatHeic
```

**功能：** HEIF格式的图片。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraFormatJpeg

```cangjie
CameraFormatJpeg
```

**功能：** JPEG格式的图片。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraFormatRgba8888

```cangjie
CameraFormatRgba8888
```

**功能：** RGBA_8888格式的图片。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraFormatYcbcrP010

```cangjie
CameraFormatYcbcrP010
```

**功能：** YCBCR_P010格式的图片。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraFormatYcrcbP010

```cangjie
CameraFormatYcrcbP010
```

**功能：** YCRCB_P010格式的图片。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraFormatYuv420Sp

```cangjie
CameraFormatYuv420Sp
```

**功能：** YUV_420_SP格式的图片。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(CameraFormat)

```cangjie
public operator func !=(other: CameraFormat): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CameraFormat](#enum-cameraformat)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(CameraFormat)

```cangjie
public operator func ==(other: CameraFormat): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CameraFormat](#enum-cameraformat)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum CameraPosition

```cangjie
public enum CameraPosition {
    | CameraPositionUnspecified
    | CameraPositionBack
    | CameraPositionFront
    | ...
}
```

**功能：** 枚举，相机位置。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<CameraPosition>
- ToString

### CameraPositionBack

```cangjie
CameraPositionBack
```

**功能：** 后置相机。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraPositionFront

```cangjie
CameraPositionFront
```

**功能：** 前置相机。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraPositionUnspecified

```cangjie
CameraPositionUnspecified
```

**功能：** 相对于设备屏幕没有固定的朝向的相机

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(CameraPosition)

```cangjie
public operator func !=(other: CameraPosition): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CameraPosition](#enum-cameraposition)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(CameraPosition)

```cangjie
public operator func ==(other: CameraPosition): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CameraPosition](#enum-cameraposition)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum CameraStatus

```cangjie
public enum CameraStatus {
    | CameraStatusAppear
    | CameraStatusDisappear
    | CameraStatusAvailable
    | CameraStatusUnavailable
    | ...
}
```

**功能：** 枚举，相机状态。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<CameraStatus>
- ToString

### CameraStatusAppear

```cangjie
CameraStatusAppear
```

**功能：** 新的相机出现。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraStatusAvailable

```cangjie
CameraStatusAvailable
```

**功能：** 相机可用。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraStatusDisappear

```cangjie
CameraStatusDisappear
```

**功能：** 相机被移除。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraStatusUnavailable

```cangjie
CameraStatusUnavailable
```

**功能：** 相机不可用。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(CameraStatus)

```cangjie
public operator func !=(other: CameraStatus): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CameraStatus](#enum-camerastatus)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(CameraStatus)

```cangjie
public operator func ==(other: CameraStatus): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CameraStatus](#enum-camerastatus)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum CameraType

```cangjie
public enum CameraType {
    | CameraTypeDefault
    | CameraTypeWideAngle
    | CameraTypeUltraWide
    | CameraTypeTelephoto
    | CameraTypeTrueDepth
    | ...
}
```

**功能：** 枚举，相机类型。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<CameraType>
- ToString

### CameraTypeDefault

```cangjie
CameraTypeDefault
```

**功能：** 默认相机类型。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraTypeTelephoto

```cangjie
CameraTypeTelephoto
```

**功能：** 长焦相机。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraTypeTrueDepth

```cangjie
CameraTypeTrueDepth
```

**功能：** 带景深信息的相机。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraTypeUltraWide

```cangjie
CameraTypeUltraWide
```

**功能：** 超广角相机。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraTypeWideAngle

```cangjie
CameraTypeWideAngle
```

**功能：** 广角相机。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(CameraType)

```cangjie
public operator func !=(other: CameraType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CameraType](#enum-cameratype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(CameraType)

```cangjie
public operator func ==(other: CameraType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CameraType](#enum-cameratype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum ConnectionType

```cangjie
public enum ConnectionType {
    | CameraConnectionBuiltIn
    | CameraConnectionUsbPlugin
    | CameraConnectionRemote
    | ...
}
```

**功能：** 枚举，相机连接类型。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<ConnectionType>
- ToString

### CameraConnectionBuiltIn

```cangjie
CameraConnectionBuiltIn
```

**功能：** 内置相机。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraConnectionRemote

```cangjie
CameraConnectionRemote
```

**功能：** 远程连接的相机。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### CameraConnectionUsbPlugin

```cangjie
CameraConnectionUsbPlugin
```

**功能：** USB连接的相机。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(ConnectionType)

```cangjie
public operator func !=(other: ConnectionType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ConnectionType](#enum-connectiontype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(ConnectionType)

```cangjie
public operator func ==(other: ConnectionType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ConnectionType](#enum-connectiontype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum ExposureMode

```cangjie
public enum ExposureMode {
    | ExposureModeLocked
    | ExposureModeAuto
    | ExposureModeContinuousAuto
    | ...
}
```

**功能：** 枚举，曝光模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<ExposureMode>
- ToString

### ExposureModeAuto

```cangjie
ExposureModeAuto
```

**功能：** 自动曝光模式。支持曝光区域中心点设置，可以使用[AutoExposure.setMeteringPoint](#func-setmeteringpointpoint)设置曝光区域中心点。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### ExposureModeContinuousAuto

```cangjie
ExposureModeContinuousAuto
```

**功能：** 连续自动曝光。不支持曝光区域中心点设置。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### ExposureModeLocked

```cangjie
ExposureModeLocked
```

**功能：** 锁定曝光模式。不支持曝光区域中心点设置。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(ExposureMode)

```cangjie
public operator func !=(other: ExposureMode): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ExposureMode](#enum-exposuremode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(ExposureMode)

```cangjie
public operator func ==(other: ExposureMode): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ExposureMode](#enum-exposuremode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum FlashMode

```cangjie
public enum FlashMode {
    | FlashModeClose
    | FlashModeOpen
    | FlashModeAuto
    | FlashModeAlwaysOpen
    | ...
}
```

**功能：** 枚举，闪光灯模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<FlashMode>
- ToString

### FlashModeAlwaysOpen

```cangjie
FlashModeAlwaysOpen
```

**功能：** 闪光灯常亮。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### FlashModeAuto

```cangjie
FlashModeAuto
```

**功能：** 自动闪光灯。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### FlashModeClose

```cangjie
FlashModeClose
```

**功能：** 闪光灯关闭。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### FlashModeOpen

```cangjie
FlashModeOpen
```

**功能：** 闪光灯打开。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(FlashMode)

```cangjie
public operator func !=(other: FlashMode): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FlashMode](#enum-flashmode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(FlashMode)

```cangjie
public operator func ==(other: FlashMode): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FlashMode](#enum-flashmode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum FocusMode

```cangjie
public enum FocusMode {
    | FocusModeManual
    | FocusModeContinuousAuto
    | FocusModeAuto
    | FocusModeLocked
    | ...
}
```

**功能：** 枚举，焦距模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<FocusMode>
- ToString

### FocusModeAuto

```cangjie
FocusModeAuto
```

**功能：** 自动对焦。支持对焦点设置，可以使用[setFocusPoint](#func-setfocuspointpoint)设置对焦点，根据对焦点执行一次自动对焦。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### FocusModeContinuousAuto

```cangjie
FocusModeContinuousAuto
```

**功能：** 连续自动对焦。不支持对焦点设置。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### FocusModeLocked

```cangjie
FocusModeLocked
```

**功能：** 对焦锁定。不支持对焦点设置。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### FocusModeManual

```cangjie
FocusModeManual
```

**功能：** 手动对焦。通过手动修改相机焦距来改变对焦位置，不支持对焦点设置。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(FocusMode)

```cangjie
public operator func !=(other: FocusMode): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FocusMode](#enum-focusmode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(FocusMode)

```cangjie
public operator func ==(other: FocusMode): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FocusMode](#enum-focusmode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum FocusState

```cangjie
public enum FocusState {
    | FocusStateScan
    | FocusStateFocused
    | FocusStateUnfocused
    | ...
}
```

**功能：** 枚举，焦距状态。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<FocusState>
- ToString

### FocusStateFocused

```cangjie
FocusStateFocused
```

**功能：** 对焦成功。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### FocusStateScan

```cangjie
FocusStateScan
```

**功能：** 触发对焦。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### FocusStateUnfocused

```cangjie
FocusStateUnfocused
```

**功能：** 未完成对焦。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(FocusState)

```cangjie
public operator func !=(other: FocusState): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FocusState](#enum-focusstate)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(FocusState)

```cangjie
public operator func ==(other: FocusState): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FocusState](#enum-focusstate)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum FoldStatus

```cangjie
public enum FoldStatus {
    | NonFoldable
    | Expanded
    | Folded
    | ...
}
```

**功能：** 枚举，折叠机折叠状态。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<FoldStatus>
- ToString

### Expanded

```cangjie
Expanded
```

**功能：** 表示当前设备折叠状态为完全展开。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### Folded

```cangjie
Folded
```

**功能：** 表示当前设备折叠状态为折叠。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### NonFoldable

```cangjie
NonFoldable
```

**功能：** 表示当前设备不可折叠。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(FoldStatus)

```cangjie
public operator func !=(other: FoldStatus): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FoldStatus](#enum-foldstatus)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(FoldStatus)

```cangjie
public operator func ==(other: FoldStatus): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[FoldStatus](#enum-foldstatus)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum ImageRotation

```cangjie
public enum ImageRotation {
    | Rotation0
    | Rotation90
    | Rotation180
    | Rotation270
    | ...
}
```

**功能：** 枚举，图片旋转角度。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<ImageRotation>
- ToString

### Rotation0

```cangjie
Rotation0
```

**功能：** 图片旋转0度。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### Rotation180

```cangjie
Rotation180
```

**功能：** 图片旋转180度。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### Rotation270

```cangjie
Rotation270
```

**功能：** 图片旋转270度。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### Rotation90

```cangjie
Rotation90
```

**功能：** 图片旋转90度。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(ImageRotation)

```cangjie
public operator func !=(other: ImageRotation): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageRotation](#enum-imagerotation)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(ImageRotation)

```cangjie
public operator func ==(other: ImageRotation): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ImageRotation](#enum-imagerotation)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum MetadataObjectType

```cangjie
public enum MetadataObjectType {
    | FaceDetection
    | ...
}
```

**功能：** 枚举，metadata流。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<MetadataObjectType>
- ToString

### FaceDetection

```cangjie
FaceDetection
```

**功能：** metadata对象类型，用于人脸检测。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(MetadataObjectType)

```cangjie
public operator func !=(other: MetadataObjectType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MetadataObjectType](#enum-metadataobjecttype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(MetadataObjectType)

```cangjie
public operator func ==(other: MetadataObjectType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MetadataObjectType](#enum-metadataobjecttype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum PreconfigRatio

```cangjie
public enum PreconfigRatio {
    | PreconfigRatio_1_1
    | PreconfigRatio_4_3
    | PreconfigRatio_16_9
    | ...
}
```

**功能：** 枚举，提供预配置的分辨率比例。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<PreconfigRatio>
- ToString

### PreconfigRatio_16_9

```cangjie
PreconfigRatio_16_9
```

**功能：** 16:9画幅。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### PreconfigRatio_1_1

```cangjie
PreconfigRatio_1_1
```

**功能：** 1:1画幅。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### PreconfigRatio_4_3

```cangjie
PreconfigRatio_4_3
```

**功能：** 4:3画幅。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(PreconfigRatio)

```cangjie
public operator func !=(other: PreconfigRatio): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PreconfigRatio](#enum-preconfigratio)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(PreconfigRatio)

```cangjie
public operator func ==(other: PreconfigRatio): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PreconfigRatio](#enum-preconfigratio)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum PreconfigType

```cangjie
public enum PreconfigType {
    | Preconfig720p
    | Preconfig1080p
    | Preconfig4k
    | PreconfigHighQuality
    | ...
}
```

**功能：** 枚举，提供预配置的类型。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<PreconfigType>
- ToString

### Preconfig1080p

```cangjie
Preconfig1080p
```

**功能：** 1080P预配置。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### Preconfig4k

```cangjie
Preconfig4k
```

**功能：** 4K预配置。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### Preconfig720p

```cangjie
Preconfig720p
```

**功能：** 720P预配置。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### PreconfigHighQuality

```cangjie
PreconfigHighQuality
```

**功能：** 高质量预配置。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(PreconfigType)

```cangjie
public operator func !=(other: PreconfigType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PreconfigType](#enum-preconfigtype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(PreconfigType)

```cangjie
public operator func ==(other: PreconfigType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PreconfigType](#enum-preconfigtype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum QualityLevel

```cangjie
public enum QualityLevel {
    | QualityLevelHigh
    | QualityLevelMedium
    | QualityLevelLow
    | ...
}
```

**功能：** 枚举，图片质量。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<QualityLevel>
- ToString

### QualityLevelHigh

```cangjie
QualityLevelHigh
```

**功能：** 图片质量高。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### QualityLevelLow

```cangjie
QualityLevelLow
```

**功能：** 图片质量差。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### QualityLevelMedium

```cangjie
QualityLevelMedium
```

**功能：** 图片质量中等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(QualityLevel)

```cangjie
public operator func !=(other: QualityLevel): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[QualityLevel](#enum-qualitylevel)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(QualityLevel)

```cangjie
public operator func ==(other: QualityLevel): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[QualityLevel](#enum-qualitylevel)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum SceneMode

```cangjie
public enum SceneMode {
    | NormalPhoto
    | NormalVideo
    | SecurePhoto
    | ...
}
```

**功能：** 枚举，相机模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<SceneMode>
- ToString

### NormalPhoto

```cangjie
NormalPhoto
```

**功能：** 普通拍照模式。详情见[PhotoSession](#class-photosession)。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### NormalVideo

```cangjie
NormalVideo
```

**功能：** 普通录像模式。详情见[VideoSession](#class-videosession)。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### SecurePhoto

```cangjie
SecurePhoto
```

**功能：** 安全相机模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(SceneMode)

```cangjie
public operator func !=(other: SceneMode): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SceneMode](#enum-scenemode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(SceneMode)

```cangjie
public operator func ==(other: SceneMode): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SceneMode](#enum-scenemode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum SmoothZoomMode

```cangjie
public enum SmoothZoomMode {
    | Normal
    | ...
}
```

**功能：** 平滑变焦模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<SmoothZoomMode>
- ToString

### Normal

```cangjie
Normal
```

**功能：** 贝塞尔曲线模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(SmoothZoomMode)

```cangjie
public operator func !=(other: SmoothZoomMode): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SmoothZoomMode](#enum-smoothzoommode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(SmoothZoomMode)

```cangjie
public operator func ==(other: SmoothZoomMode): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[SmoothZoomMode](#enum-smoothzoommode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22


**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum TorchMode

```cangjie
public enum TorchMode {
    | Off
    | On
    | Auto
    | ...
}
```

**功能：** 枚举，手电筒模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<TorchMode>
- ToString

### Auto

```cangjie
Auto
```

**功能：** 自动模式，系统根据环境自动调节手电筒亮度。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### Off

```cangjie
Off
```

**功能：** 常关模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### On

```cangjie
On
```

**功能：** 常开模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(TorchMode)

```cangjie
public operator func !=(other: TorchMode): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TorchMode](#enum-torchmode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(TorchMode)

```cangjie
public operator func ==(other: TorchMode): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[TorchMode](#enum-torchmode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum VideoCodecType

```cangjie
public enum VideoCodecType {
    | Avc
    | Hevc
    | ...
}
```

**功能：** 枚举，视频编码类型。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<VideoCodecType>
- ToString

### Avc

```cangjie
Avc
```

**功能：** 视频编码类型AVC。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### Hevc

```cangjie
Hevc
```

**功能：** 视频编码类型HEVC。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(VideoCodecType)

```cangjie
public operator func !=(other: VideoCodecType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[VideoCodecType](#enum-videocodectype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(VideoCodecType)

```cangjie
public operator func ==(other: VideoCodecType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[VideoCodecType](#enum-videocodectype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|

## enum VideoStabilizationMode

```cangjie
public enum VideoStabilizationMode {
    | Off
    | Low
    | Middle
    | High
    | Auto
    | ...
}
```

**功能：** 枚举，视频防抖模式。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**父类型：**

- Equatable\<VideoStabilizationMode>
- ToString

### Auto

```cangjie
Auto
```

**功能：** 自动进行选择防抖算法。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### High

```cangjie
High
```

**功能：** 使用防抖效果最好的防抖算法，防抖效果优于Middle类型。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### Low

```cangjie
Low
```

**功能：** 使用基础防抖算法。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### Middle

```cangjie
Middle
```

**功能：** 使用防抖效果一般的防抖算法，防抖效果优于Low类型。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### Off

```cangjie
Off
```

**功能：** 关闭视频防抖功能。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

### func !=(VideoStabilizationMode)

```cangjie
public operator func !=(other: VideoStabilizationMode): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[VideoStabilizationMode](#enum-videostabilizationmode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(VideoStabilizationMode)

```cangjie
public operator func ==(other: VideoStabilizationMode): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[VideoStabilizationMode](#enum-videostabilizationmode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的字符串值。

**系统能力：** SystemCapability.Multimedia.Camera.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的字符串值。|
