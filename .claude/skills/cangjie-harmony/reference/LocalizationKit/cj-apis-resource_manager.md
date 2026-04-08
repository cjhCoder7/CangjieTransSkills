# ohos.resource_manager（资源管理）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

resource_manager模块提供资源获取能力。根据当前的Configuration配置提供获取应用资源对象读取接口。

Configuration配置包括语言、区域、横竖屏、Mcc（移动国家码）和Mnc（移动网络码）、Device capability（设备类型）、Density（分辨率）。

## 导入模块

```cangjie
import kit.LocalizationKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class Configuration

```cangjie
public class Configuration {
    public var direction: Direction
    public var locale: String
    public var deviceType: DeviceType
    public var screenDensity: ScreenDensity
    public var colorMode: ColorMode
    public var mcc: UInt32
    public var mnc: UInt32
}
```

**功能：** 表示当前设备的状态。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### var colorMode

```cangjie
public var colorMode: ColorMode
```

**功能：** 颜色模式。

**类型：** [ColorMode](#enum-colormode)

**读写能力：** 可读写

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### var deviceType

```cangjie
public var deviceType: DeviceType
```

**功能：** 设备类型。

**类型：** [DeviceType](#enum-devicetype)

**读写能力：** 可读写

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### var direction

```cangjie
public var direction: Direction
```

**功能：** 屏幕方向。

**类型：** [Direction](#enum-direction)

**读写能力：** 可读写

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### var locale

```cangjie
public var locale: String
```

**功能：** 语言文字国家地区。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### var mcc

```cangjie
public var mcc: UInt32
```

**功能：** 移动国家码。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### var mnc

```cangjie
public var mnc: UInt32
```

**功能：** 移动网络码。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### var screenDensity

```cangjie
public var screenDensity: ScreenDensity
```

**功能：** 屏幕密度。

**类型：** [ScreenDensity](#enum-screendensity)

**读写能力：** 可读写

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

## class DeviceCapability

```cangjie
public class DeviceCapability {
    public var screenDensity: ScreenDensity
    public var deviceType: DeviceType
}
```

**功能：** 表示设备支持的能力。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### var deviceType

```cangjie
public var deviceType: DeviceType
```

**功能：** 当前设备类型。

**类型：** [DeviceType](#enum-devicetype)

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### var screenDensity

```cangjie
public var screenDensity: ScreenDensity
```

**功能：** 当前设备屏幕密度。

**类型：** [ScreenDensity](#enum-screendensity)

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

## class ResourceManager

```cangjie
public class ResourceManager {}
```

**功能：** 提供访问应用资源和系统资源的能力。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### func addResource(String)

```cangjie
public func addResource(path: String): Unit
```

**功能：** 应用运行时加载指定的资源路径，实现资源覆盖。

> **说明**
>
> rawfile和resfile目录不支持资源覆盖。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|path|String|是|-|资源路径。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001010 | Invalid overlay path. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let path = "/data/storage/el2/base/haps/entry/files/library-default-unsigned.hsp"
    resourceManager.addResource(path)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func closeRawFd(String)

```cangjie
public func closeRawFd(path: String): Unit
```

**功能：** 关闭resources/rawfile目录下rawfile文件所在HAP的文件描述符（fd）。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|path|String|是|-|rawfile文件路径。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001005 | Invalid relative path. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let rawfd = resourceManager.closeRawFd("test.txt")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getBoolean(UInt32)

```cangjie
public func getBoolean(resId: UInt32): Bool
```

**功能：** 获取指定资源ID值对应的布尔值。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resId|UInt32|是|-|资源ID值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|资源ID值对应的布尔值。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001001 | Invalid resource ID. |
  | 9001002 | No matching resource is found based on the resource ID. |
  | 9001006 | The resource is referenced cyclically. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let res = @r(app.boolean.test)
    let result = resourceManager.getBoolean(res.id)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getBooleanByName(String)

```cangjie
public func getBooleanByName(resName: String): Bool
```

**功能：** 获取指定资源名称对应的布尔值。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resName|String|是|-|资源名称。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|资源名称对应的布尔值。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001003 | Invalid resource name. |
  | 9001004 | No matching resource is found based on the resource name. |
  | 9001006 | The resource is referenced cyclically. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let result = resourceManager.getBooleanByName("test")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getColor(UInt32)

```cangjie
public func getColor(resId: UInt32): UInt32
```

**功能：** 获取指定资源ID对应的颜色值。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resId|UInt32|是|-|资源ID值。|

**返回值：**

|类型|说明|
|:----|:----|
|UInt32|返回资源ID值对应的颜色值（十进制）。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001001 | Invalid resource ID.|
  | 9001002 | No matching resource is found based on the resource ID.|
  | 9001006 | The resource is referenced cyclically.|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let res = @r(app.color.test)
    let result = resourceManager.getColor(res.id)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getColorByName(String)

```cangjie
public func getColorByName(resName: String): UInt32
```

**功能：** 获取指定资源名称对应的颜色值。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resName|String|是|-|资源名称。|

**返回值：**

|类型|说明|
|:----|:----|
|UInt32|返回资源名称对应的颜色值（十进制）。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001003 | Invalid resource name. |
  | 9001004 | No matching resource is found based on the resource name. |
  | 9001006 | The resource is referenced cyclically. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let result = resourceManager.getColorByName("test")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getConfiguration()

```cangjie
public func getConfiguration(): Configuration
```

**功能：** 获取设备的Configuration。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[Configuration](#class-configuration)|设备的Configuration。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let configuration = resourceManager.getConfiguration()
    Hilog.info(0, "test", configuration.locale, "")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getDeviceCapability()

```cangjie
public func getDeviceCapability(): DeviceCapability
```

**功能：** 获取设备的DeviceCapability。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[DeviceCapability](#class-devicecapability)|设备的DeviceCapability。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let deviceCapability = resourceManager.getDeviceCapability()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getLocales(Bool)

```cangjie
public func getLocales(includeSystem!: Bool = false): Array<String>
```

**功能：** 获取应用的语言列表。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|includeSystem|Bool|否|false| **命名参数。** 是否包含系统资源，默认值为false。 <br> - false：表示仅获取应用资源的语言列表。 <br> - true：表示获取系统资源和应用资源的语言列表。 <br>当使用系统资源管理对象获取语言列表时，includeSystem值无效，始终返回系统资源语言列表。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<String>|返回获取的语言列表，列表中的字符串由语言、脚本（可选）、地区（可选），按照顺序使用中划线“-”连接组成。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    resourceManager.getLocales()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getMediaBase64ByName(String, ?ScreenDensity)

```cangjie
public func getMediaBase64ByName(resName: String, density!: ?ScreenDensity = None): String
```

**功能：** 获取指定资源名称对应的默认或指定的屏幕密度图片资源Base64编码。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resName|String|是|-|资源ID。|
|density|?[ScreenDensity](#enum-screendensity)|否|None| **命名参数。** 资源获取需要的屏幕密度，0或缺省表示默认屏幕密度。|

**返回值：**

|类型|说明|
|:----|:----|
|String|资源名称对应的图片资源Base64编码。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001003 | Invalid resource name. |
  | 9001004 | No matching resource is found based on the resource name. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let code = resourceManager.getMediaBase64ByName("test")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getMediaByName(String, ?ScreenDensity)

```cangjie
public func getMediaByName(resName: String, density!: ?ScreenDensity = None): Array<UInt8>
```

**功能：** 获取指定资源名称对应的默认或指定的屏幕密度媒体文件内容。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resName|String|是|-|资源名称。|
|density|?[ScreenDensity](#enum-screendensity)|否|None| **命名参数。** 资源获取需要的屏幕密度，0或缺省表示默认屏幕密度。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<UInt8>|资源名称对应的媒体文件内容。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001003 | Invalid resource name. |
  | 9001004 | No matching resource is found based on the resource name. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    resourceManager.getMediaByName("test", density: ScreenMdpi)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getMediaContent(UInt32, ?ScreenDensity)

```cangjie
public func getMediaContent(resId: UInt32, density!: ?ScreenDensity = None): Array<UInt8>
```

**功能：** 获取指定资源ID对应的默认或指定的屏幕密度媒体文件内容。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resId|UInt32|是|-|资源ID值。|
|density|?[ScreenDensity](#enum-screendensity)|否|None| **命名参数。** 资源获取需要的屏幕密度，0或缺省表示默认屏幕密度。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<UInt8>|资源ID对应的媒体文件内容。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001001 | Invalid resource ID. |
  | 9001002 | No matching resource is found based on the resource ID. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let res = @r(app.media.test)
    resourceManager.getMediaContent(res.id, density: ScreenSdpi)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getMediaContentBase64(UInt32, ?ScreenDensity)

```cangjie
public func getMediaContentBase64(resId: UInt32, density!: ?ScreenDensity = None): String
```

**功能：** 获取指定资源ID对应的默认或指定的屏幕密度图片资源Base64编码。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resId|UInt32|是|-|资源ID值。|
|density|?[ScreenDensity](#enum-screendensity)|否|None| **命名参数。** 资源获取需要的屏幕密度，0或缺省表示默认屏幕密度。|

**返回值：**

|类型|说明|
|:----|:----|
|String|资源ID对应的图片资源Base64编码。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001001 | Invalid resource ID. |
  | 9001002 | No matching resource is found based on the resource ID. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let res = @r(app.media.test)
    let code = resourceManager.getMediaContentBase64(res.id)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getNumber(UInt32)

```cangjie
public func getNumber(resId: UInt32): NumberValueType
```

**功能：** 获取指定资源ID对应的Int32数值或者Float32数值。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resId|UInt32|是|-|资源ID。|

**返回值：**

|类型|说明|
|:----|:----|
|[NumberValueType](#enum-numbervaluetype)|资源ID值对应的数值。<br>Int32对应的是原数值，Float32不带单位时对应的是原数值，带"vp","fp"单位时对应的是px值，具体参考示例代码。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001001 | Invalid resource ID. |
  | 9001002 | No matching resource is found based on the resource ID. |
  | 9001006 | The resource is referenced cyclically. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import kit.PerformanceAnalysisKit.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let res = @r(app.integer.test)
    let number = resourceManager.getNumber(res.id)
    match (number) {
        case Int32Value(v) => Hilog.info(0, "test", v.toString(), "")
        case Float32Value(v) => Hilog.info(0, "test", v.toString(), "")
        case _ => throw IllegalArgumentException("The type is not supported.")
    }
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getNumberByName(String)

```cangjie
public func getNumberByName(resName: String): NumberValueType
```

**功能：** 获取指定资源名称对应的Int32数值或者Float32数值。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resName|String|是|-|资源名称。|

**返回值：**

|类型|说明|
|:----|:----|
|[NumberValueType](#enum-numbervaluetype)|资源名称对应的数值。<br>Int32对应的是原数值，Float32不带单位时对应的是原数值，带"vp","fp"单位时对应的是px值。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001003 | Invalid resource name. |
  | 9001004 | No matching resource is found based on the resource name. |
  | 9001006 | The resource is referenced cyclically. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import kit.PerformanceAnalysisKit.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let number = resourceManager.getNumberByName("test")
    match (number) {
        case Int32Value(v) => Hilog.info(0, "test", v.toString(), "")
        case Float32Value(v) => Hilog.info(0, "test", v.toString(), "")
        case _ => throw IllegalArgumentException("The type is not supported.")
    }
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getPluralStringByName(String, Int64)

```cangjie
public func getPluralStringByName(resName: String, num: Int64): String
```

**功能：** 获取指定资源名称，指定资源数量的单复数字符串。

> **说明**
>
> 中文环境下，字符串不区分单复数；其他语言环境下，字符串区分单复数，具体规则参考[语言单复数规则](https://www.unicode.org/cldr/charts/45/supplemental/language_plural_rules.html)。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resName|String|是|-|资源名称。|
|num|Int64|是|-|数量值。根据当前语言的复数规则获取该数量值对应的字符串数字，语言的复数规则参见[语言单复数规则](https://www.unicode.org/cldr/charts/45/supplemental/language_plural_rules.html)。|

**返回值：**

|类型|说明|
|:----|:----|
|String|根据指定数量获取指定资源名称表示的单复数字符串。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001003 | Invalid resource name. |
  | 9001004 | No matching resource is found based on the resource name. |
  | 9001006 | The resource is referenced cyclically. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let result = resourceManager.getPluralStringByName("test", 1)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getPluralStringValue(UInt32, Int64)

```cangjie
public func getPluralStringValue(resId: UInt32, num: Int64): String
```

**功能：** 获取指定资源ID，指定资源数量的单复数字符串。

> **说明**
>
> 中文环境下，字符串不区分单复数；其他语言环境下，字符串区分单复数，具体规则参考[语言单复数规则](https://www.unicode.org/cldr/charts/45/supplemental/language_plural_rules.html)。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resId|UInt32|是|-|资源ID值。|
|num|Int64|是|-|数量值。根据当前语言的复数规则获取该数量值对应的字符串数字，语言的复数规则参见[语言单复数规则](https://www.unicode.org/cldr/charts/45/supplemental/language_plural_rules.html)。|

**返回值：**

|类型|说明|
|:----|:----|
|String|根据指定数量获取指定ID字符串表示的单复数字符串。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001001 | Invalid resource ID. |
  | 9001002 | No matching resource is found based on the resource ID. |
  | 9001006 | The resource is referenced cyclically. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let res = @r(app.plural.test)
    let result = resourceManager.getPluralStringValue(res.id, 1)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getRawFd(String)

```cangjie
public func getRawFd(path: String): RawFileDescriptor
```

**功能：** 获取resources/rawfile目录下rawfile文件所在HAP的文件描述符（fd）。

> **说明**
>
> 文件描述符（fd）使用完毕后需调用[closeRawFd](#func-closerawfdstring)关闭fd，避免资源泄露。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|path|String|是|-|rawfile文件路径。|

**返回值：**

|类型|说明|
|:----|:----|
|[RawFileDescriptor](./cj-apis-raw_file_descriptor.md#class-rawfiledescriptor)|rawfile文件所在HAP的文件描述符（fd）。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001005 | Invalid relative path. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let rawfd = resourceManager.getRawFd("test.txt")
    Hilog.info(0, "test", "${rawfd.fd} ${rawfd.offset} ${rawfd.length}", "")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getRawFileContent(String)

```cangjie
public func getRawFileContent(path: String): Array<UInt8>
```

**功能：** 获取resources/rawfile目录下对应的rawfile文件内容。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|path|String|是|-|rawfile文件路径。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<UInt8>|返回获取的rawfile文件内容。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001005 | Invalid relative path. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    resourceManager.getRawFileContent("test.txt")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getRawFileList(String)

```cangjie
public func getRawFileList(path: String): Array<String>
```

**功能：** 获取resources/rawfile目录下文件夹及文件列表。

>**说明**
>
> 若文件夹中无文件，则抛出异常；若文件夹中有文件，则返回文件夹及文件列表。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|path|String|是|-|rawfile文件夹路径。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<String>|rawfile文件目录下的文件夹及文件列表。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001005 | Invalid relative path. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    resourceManager.getRawFileList("")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getString(UInt32, Array\<ArgsValueType>)

```cangjie
public func getString(resId: UInt32, args: Array<ArgsValueType>): String
```

**功能：** 获取指定资源ID对应的字符串，并根据args参数对字符串进行格式化。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resId|UInt32|是|-|资源ID值。|
|args|Array\<[ArgsValueType](#enum-argsvaluetype)>|是|-|格式化字符串资源参数。<br>支持参数类型：`%d`、`%f`、`%s`、`%%`、。<br>说明：`%%`转义为`%`。<br>举例：`%%d`格式化后为`%d`字符串。|

**返回值：**

|类型|说明|
|:----|:----|
|String|资源ID值对应的格式化字符串。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001001 | Invalid resource ID. |
  | 9001002 | No matching resource is found based on the resource ID. |
  | 9001006 | The resource is referenced cyclically. |
  | 9001007 | Failed to format the resource obtained based on the resource ID. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let resource = @r(app.string.test)
    let result = resourceManager.getString(resource.id)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getStringArrayByName(String)

```cangjie
public func getStringArrayByName(resName: String): Array<String>
```

**功能：** 获取指定资源名称对应的字符串数组。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resName|String|是|-|资源名称。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<String>|对应资源名称的字符串数组。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001003 | Invalid resource name. |
  | 9001004 | No matching resource is found based on the resource name. |
  | 9001006 | The resource is referenced cyclically. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    resourceManager.getStringArrayByName("test")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getStringArrayValue(UInt32)

```cangjie
public func getStringArrayValue(resId: UInt32): Array<String>
```

**功能：** 获取指定资源ID对应的字符串数组。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resId|UInt32|是|-|资源ID值。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<String>|资源ID值对应的字符串数组。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001001 | Invalid resource ID. |
  | 9001002 | No matching resource is found based on the resource ID. |
  | 9001006 | The resource is referenced cyclically. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let res = @r(app.strarray.test)
    let result = resourceManager.getStringArrayValue(res.id)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getStringByName(String, Array\<ArgsValueType>)

```cangjie
public func getStringByName(resName: String, args: Array<ArgsValueType>): String
```

**功能：** 获取指定资源名称对应的字符串，并根据args参数对字符串进行格式化。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resName|String|是|-|资源名称。|
|args|Array\<[ArgsValueType](#enum-argsvaluetype)>|是|-|格式化字符串资源参数。<br>支持参数类型：`%d`、`%f`、`%s`、`%%`。<br>说明：`%%`转义为`%`。<br>举例：`%%d`格式化后为`%d`字符串。|

**返回值：**

|类型|说明|
|:----|:----|
|String|资源名对应的格式化字符串。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001003 | Invalid resource name. |
  | 9001004 | No matching resource is found based on the resource name. |
  | 9001006 | The resource is referenced cyclically. |
  | 9001007 | Failed to format the resource obtained based on the resource ID. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let result = resourceManager.getStringByName("test", ArgsValueType.StringValue("format string"), ArgsValueType.Int32Value(10), ArgsValueType.Float32Value(98.78))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func removeResource(String)

```cangjie
public func removeResource(path: String): Unit
```

**功能：** 应用运行时移除指定的资源路径，还原被覆盖前的资源。

> **说明**
>
> rawfile和resfile目录不支持资源覆盖。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|path|String|是|-|资源路径。|

**异常：**

- BusinessException：对应错误码如下表，详见[资源管理错误码](./cj-errorcode-resource-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 9001010 | Invalid overlay path. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let resourceManager = Global.abilityContext.resourceManager
    let path = "/data/storage/el2/base/haps/entry/files/library-default-unsigned.hsp"
    resourceManager.removeResource(path)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## enum ArgsValueType

```cangjie
public enum ArgsValueType {
    | Int32Value(Int32)
    | Float32Value(Float32)
    | StringValue(String)
    | ...
}
```

**功能：** 格式化字符串资源参数枚举类型。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### Float32Value(Float32)

```cangjie
Float32Value(Float32)
```

**功能：** Float32类型的格式化字符串资源参数枚举值。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### Int32Value(Int32)

```cangjie
Int32Value(Int32)
```

**功能：** Int32类型的格式化字符串资源参数枚举值。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### StringValue(String)

```cangjie
StringValue(String)
```

**功能：** String类型的格式化字符串资源参数枚举值。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

## enum ColorMode

```cangjie
public enum ColorMode {
    | Dark
    | Light
    | ...
}
```

**功能：** 用于表示当前设备颜色模式。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### Dark

```cangjie
Dark
```

**功能：** 深色模式。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### Light

```cangjie
Light
```

**功能：** 浅色模式。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

## enum DeviceType

```cangjie
public enum DeviceType {
    | DeviceTypePhone
    | DeviceTypeTablet
    | DeviceTypeCar
    | DeviceTypePc
    | DeviceTypeTv
    | DeviceTypeWearable
    | DeviceType2In1
    | ...
}
```

**功能：** 用于表示当前设备类型。目前仓颉仅支持手机（Phone），平板（Tablet）。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### DeviceType2In1

```cangjie
DeviceType2In1
```

**功能：** 2in1设备。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### DeviceTypeCar

```cangjie
DeviceTypeCar
```

**功能：** 汽车。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### DeviceTypePc

```cangjie
DeviceTypePc
```

**功能：** 电脑。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### DeviceTypePhone

```cangjie
DeviceTypePhone
```

**功能：** 手机。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### DeviceTypeTv

```cangjie
DeviceTypeTv
```

**功能：** 电视。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### DeviceTypeTablet

```cangjie
DeviceTypeTablet
```

**功能：** 平板。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### DeviceTypeWearable

```cangjie
DeviceTypeWearable
```

**功能：** 穿戴。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

## enum Direction

```cangjie
public enum Direction {
    | DirectionVertical
    | DirectionHorizontal
    | ...
}
```

**功能：** 用于表示设备屏幕方向。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### DirectionHorizontal

```cangjie
DirectionHorizontal
```

**功能：** 横屏。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### DirectionVertical

```cangjie
DirectionVertical
```

**功能：** 竖屏。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

## enum NumberValueType

```cangjie
public enum NumberValueType {
    | Int32Value(Int32)
    | Float32Value(Float32)
    | ...
}
```

**功能：** 表示从资源中获取到的数字类型。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### Float32Value(Float32)

```cangjie
Float32Value(Float32)
```

**功能：** 存储Float32类型值的Number类型。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### Int32Value(Int32)

```cangjie
Int32Value(Int32)
```

**功能：** 存储Int32类型值的Number类型。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

## enum ScreenDensity

```cangjie
public enum ScreenDensity {
    | ScreenSdpi
    | ScreenMdpi
    | ScreenLdpi
    | ScreenXldpi
    | ScreenXxldpi
    | ScreenXxxldpi
    | ...
}
```

**功能：** 用于表示当前设备屏幕密度。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### ScreenLdpi

```cangjie
ScreenLdpi
```

**功能：** 高屏幕密度。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### ScreenMdpi

```cangjie
ScreenMdpi
```

**功能：** 中屏幕密度。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### ScreenSdpi

```cangjie
ScreenSdpi
```

**功能：** 低屏幕密度。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### ScreenXldpi

```cangjie
ScreenXldpi
```

**功能：** 特高屏幕密度。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### ScreenXxldpi

```cangjie
ScreenXxldpi
```

**功能：** 超高屏幕密度。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22

### ScreenXxxldpi

```cangjie
ScreenXxxldpi
```

**功能：** 超特高屏幕密度。

**系统能力：** SystemCapability.Global.ResourceManager

**起始版本：** 22