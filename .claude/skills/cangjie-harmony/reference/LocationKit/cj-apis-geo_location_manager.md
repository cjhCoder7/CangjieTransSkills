# ohos.geo_location_manager（位置服务）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

geo_location_manager模块提供GNSS定位、网络定位（蜂窝基站、WLAN、蓝牙定位技术）等基本功能。

使用位置服务时请打开设备“位置”开关。如果“位置”开关关闭并且代码未设置捕获异常，可能导致应用异常。

> **说明：**
>
> 本模块能力仅支持WGS-84坐标系。

## 导入模块

```cangjie
import kit.LocationKit.*
```

## 申请权限

请参考[申请位置权限开发指导](../../location/cj-location-permission-guidelines.md#开发步骤)

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class CurrentLocationRequest

```cangjie
public class CurrentLocationRequest {
    public var priority: LocationRequestPriority
    public var scenario: LocationRequestScenario
    public var maxAccuracy: Float32
    public var timeoutMs: Int32
    public init(priority!: LocationRequestPriority = LocationRequestPriority.FirstFix,
        scenario!: LocationRequestScenario = LocationRequestScenario.Unset, maxAccuracy!: Float32 = 0.0,
        timeoutMs!: Int32 = 5000)
}
```

**功能：** 当前位置信息请求参数。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var maxAccuracy

```cangjie
public var maxAccuracy: Float32
```

**功能：** 应用向系统请求位置信息时要求的精度值，单位为米。该参数仅在精确位置功能场景（即同时授权了ohos.permission.APPROXIMATELY_LOCATION和ohos.permission.LOCATION 权限）下有效，模糊位置功能生效场景（即仅授权了ohos.permission.APPROXIMATELY_LOCATION 权限）下该字段无意义。

该参数生效的情况下，系统会对比GNSS或网络定位服务上报的位置信息与应用的位置信息申请。当位置信息[Location](#class-location)中的精度值（accuracy）小于等于应用要求的精度值（maxAccuracy）时，位置信息会返回给应用；否则系统将丢弃本次收到的位置信息。

当scenario为NAVIGATION/TRAJECTORY_TRACKING/CAR_HAILING或者priority为ACCURACY时建议设置maxAccuracy为大于10的值。

当scenario为DAILY_LIFE_SERVICE/NO_POWER或者priority为LOW_POWER/FIRST_FIX时建议设置maxAccuracy为大于100的值。

**类型：** Float32

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var priority

```cangjie
public var priority: LocationRequestPriority
```

**功能：** 表示优先级信息。当scenario取值为Unset时，priority参数生效，否则priority参数不生效；当scenario和priority均取值为Unset时，无法发起定位请求。取值范围见[LocationRequestPriority](#enum-locationrequestpriority)的定义。

**类型：** [LocationRequestPriority](#enum-locationrequestpriority)

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var scenario

```cangjie
public var scenario: LocationRequestScenario
```

**功能：** 表示场景信息。当scenario取值为Unset时，priority参数生效，否则priority参数不生效；当scenario和priority均取值为Unset时，无法发起定位请求。取值范围见[LocationRequestScenario](#enum-locationrequestscenario)的定义。

**类型：** [LocationRequestScenario](#enum-locationrequestscenario)

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var timeoutMs

```cangjie
public var timeoutMs: Int32
```

**功能：** 表示超时时间，单位是毫秒，最小为1000毫秒。取值范围为大于等于1000。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### init(LocationRequestPriority, LocationRequestScenario, Float32, Int32)

```cangjie
public init(priority!: LocationRequestPriority = LocationRequestPriority.FirstFix,
    scenario!: LocationRequestScenario = LocationRequestScenario.Unset, maxAccuracy!: Float32 = 0.0,
    timeoutMs!: Int32 = 5000)
```

**功能：** 构造CurrentLocationRequest对象。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|priority|[LocationRequestPriority](#enum-locationrequestpriority)|否|LocationRequestPriority.FirstFix|**命名参数。** 表示优先级信息。当scenario取值为Unset时，priority参数生效，否则priority参数不生效；当scenario和priority均取值为Unset时，无法发起定位请求。取值范围见[LocationRequestPriority](#enum-locationrequestpriority)的定义。默认值为LocationRequestPriority.FirstFix。|
|scenario|[LocationRequestScenario](#enum-locationrequestscenario)|否|LocationRequestScenario.Unset|**命名参数。** 表示场景信息。当scenario取值为Unset时，priority参数生效，否则priority参数不生效；当scenario和priority均取值为Unset时，无法发起定位请求。取值范围见[LocationRequestScenario](#enum-locationrequestscenario)的定义。默认值为LocationRequestScenario.Unset。|
|maxAccuracy|Float32|否|0.0|**命名参数。** 应用向系统请求位置信息时要求的精度值，单位为米。默认值为0，表示不限制位置信息的精度，取值范围为大于等于0。|
|timeoutMs|Int32|否|5000|**命名参数。** 表示超时时间，单位是毫秒，最小为1000毫秒。取值范围为大于等于1000。|

## class GeoLocationManager

```cangjie
public class GeoLocationManager {}
```

**功能：** 用于提供位置服务的类。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### static func getCurrentLocation()

```cangjie
public static func getCurrentLocation(): Location
```

**功能：** 获取当前位置。

**需要权限：** ohos.APPROXIMATELY_LOCATION

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[Location](#class-location)|返回当前位置信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[位置服务子系统错误码](./cj-errorcode-geo_location_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission verification failed. The application does not have the permission required to call the API. |
  | 801 | Capability not supported. Failed to call ${geoLocationManager.getCurrentLocation} due to limited device capabilities. |
  | 3301000 | The location service is unavailable. |
  | 3301100 | The location switch is off. |
  | 3301200 | Failed to obtain the geographical location. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let location = GeoLocationManager.getCurrentLocation()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func getCurrentLocation(CurrentLocationRequest)

```cangjie
public static func getCurrentLocation(request: CurrentLocationRequest): Location
```

**功能：** 获取当前位置。

**需要权限：** ohos.APPROXIMATELY_LOCATION

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|request|[CurrentLocationRequest](#class-currentlocationrequest)|是|-|设置位置请求参数。|

**返回值：**

|类型|说明|
|:----|:----|
|[Location](#class-location)|返回当前位置信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[位置服务子系统错误码](./cj-errorcode-geo_location_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission verification failed. The application does not have the permission required to call the API. |
  | 801 | Capability not supported. Failed to call ${geoLocationManager.getCurrentLocation} due to limited device capabilities. |
  | 3301000 | The location service is unavailable. |
  | 3301100 | The location switch is off. |
  | 3301200 | Failed to obtain the geographical location. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let location = GeoLocationManager.getCurrentLocation(CurrentLocationRequest())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func getCurrentLocation(SingleLocationRequest)

```cangjie
public static func getCurrentLocation(request: SingleLocationRequest): Location
```

**功能：** 获取当前位置。

**需要权限：** ohos.APPROXIMATELY_LOCATION

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|request|[SingleLocationRequest](#class-singlelocationrequest)|是|-|设置位置请求参数。|

**返回值：**

|类型|说明|
|:----|:----|
|[Location](#class-location)|返回当前位置信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[位置服务子系统错误码](./cj-errorcode-geo_location_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission verification failed. The application does not have the permission required to call the API. |
  | 801 | Capability not supported. Failed to call ${geoLocationManager.getCurrentLocation} due to limited device capabilities. |
  | 3301000 | The location service is unavailable. |
  | 3301100 | The location switch is off. |
  | 3301200 | Failed to obtain the geographical location. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let location = GeoLocationManager.getCurrentLocation(SingleLocationRequest(LocatingPriority.PriorityLocatingSpeed, 1000))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func isLocationEnabled()

```cangjie
public static func isLocationEnabled(): Bool
```

**功能：** 判断位置服务是否已经开启。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|true：位置信息开关已开启。<br/>false：位置信息开关已关闭。|

**异常：**

- BusinessException：对应错误码如下表，详见[位置服务子系统错误码](./cj-errorcode-geo_location_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | Capability not supported. Failed to call ${geoLocationManager.isLocationEnabled} due to limited device capabilities. |
  | 3301000 | The location service is unavailable. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocationKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let res = GeoLocationManager.isLocationEnabled()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class Location

```cangjie
public class Location {
    public var latitude: Float64
    public var longitude: Float64
    public var altitude: Float64
    public var accuracy: Float64
    public var speed: Float64
    public var timestamp: Int64
    public var direction: Float64
    public var timeSinceBoot: Int64
    public var additions: ?Array<String>
    public var additionsMap: ?Map<String, String>
    public var additionSize: ?Int64
    public var altitudeAccuracy: ?Float64
    public var speedAccuracy: ?Float64
    public var directionAccuracy: ?Float64
    public var uncertaintyOfTimeSinceBoot: ?Int64
    public var sourceType: ?LocationSourceType
}
```

**功能：** 位置信息。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var accuracy

```cangjie
public var accuracy: Float64
```

**功能：** 表示精度信息，单位米。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var additionSize

```cangjie
public var additionSize: ?Int64
```

**功能：** 附加信息数量。取值范围为大于等于0。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var additions

```cangjie
public var additions: ?Array<String>
```

**功能：** 附加信息。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var additionsMap

```cangjie
public var additionsMap: ?Map<String, String>
```

**功能：** 附加信息。具体内容和顺序与additions一致。

**类型：** ?Map\<String, String>

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var altitude

```cangjie
public var altitude: Float64
```

**功能：** 表示高度信息，单位米。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var altitudeAccuracy

```cangjie
public var altitudeAccuracy: ?Float64
```

**功能：** 表示高度信息的精度，单位米。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var direction

```cangjie
public var direction: Float64
```

**功能：** 表示航向信息。单位是“度”，取值范围为0到360。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var directionAccuracy

```cangjie
public var directionAccuracy: ?Float64
```

**功能：** 表示航向信息的精度。单位是“度”，取值范围为0到360。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var latitude

```cangjie
public var latitude: Float64
```

**功能：** 表示纬度信息，正值表示北纬，负值表示南纬。取值范围为-90到90。仅支持WGS84坐标系。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var longitude

```cangjie
public var longitude: Float64
```

**功能：** 表示经度信息，正值表示东经，负值表示西经。取值范围为-180到180。仅支持WGS84坐标系。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var sourceType

```cangjie
public var sourceType: ?LocationSourceType
```

**功能：** 表示定位结果的来源。

**类型：** [LocationSourceType](#enum-locationsourcetype)

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var speed

```cangjie
public var speed: Float64
```

**功能：** 表示速度信息，单位米每秒。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var speedAccuracy

```cangjie
public var speedAccuracy: ?Float64
```

**功能：** 表示速度信息的精度，单位米每秒。

**类型：** ?Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var timeSinceBoot

```cangjie
public var timeSinceBoot: Int64
```

**功能：** 表示获取位置成功的时间戳，值表示从本次开机到获取位置成功所经过的时间，单位为纳秒。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var timestamp

```cangjie
public var timestamp: Int64
```

**功能：** 表示位置时间戳，UTC格式。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var uncertaintyOfTimeSinceBoot

```cangjie
public var uncertaintyOfTimeSinceBoot: ?Int64
```

**功能：** 表示位置时间戳的不确定度。

**类型：** Int64

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

## class SingleLocationRequest

```cangjie
public class SingleLocationRequest {
    public var locatingPriority: LocatingPriority
    public var locatingTimeoutMs: Int32
    public init(locatingPriority: LocatingPriority, locatingTimeoutMs: Int32)
}
```

**功能：** 单次定位的请求参数。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var locatingPriority

```cangjie
public var locatingPriority: LocatingPriority
```

**功能：** 表示优先级信息。取值范围见[LocatingPriority](#enum-locatingpriority)的定义。

**类型：** [LocatingPriority](#enum-locatingpriority)

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### var locatingTimeoutMs

```cangjie
public var locatingTimeoutMs: Int32
```

**功能：** 表示超时时间，单位是毫秒，最小为1000毫秒。取值范围为大于等于1000。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### init(LocatingPriority, Int32)

```cangjie
public init(locatingPriority: LocatingPriority, locatingTimeoutMs: Int32)
```

**功能：** 构造SingleLocationRequest对象。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|locatingPriority|[LocatingPriority](#enum-locatingpriority)|是|-|表示优先级信息。取值范围见[LocatingPriority](#enum-locatingpriority)的定义。|
|locatingTimeoutMs|Int32|是|-|表示超时时间，单位是毫秒，最小为1000毫秒。取值范围为大于等于1000。|

## enum LocatingPriority

```cangjie
public enum LocatingPriority {
    | PriorityAccuracy
    | PriorityLocatingSpeed
    | ...
}
```

**功能：** 单次位置请求中的优先级类型。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### PriorityAccuracy

```cangjie
PriorityAccuracy
```

**功能：** 表示精度优先。

定位精度优先策略会同时使用GNSS定位和网络定位技术，并把一段时间内精度较好的结果返回给应用；这个时间段长度为[SingleLocationRequest](#class-singlelocationrequest).locatingTimeoutMs与“30秒”中的较小者。

对设备的硬件资源消耗较大，功耗较大。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### PriorityLocatingSpeed

```cangjie
PriorityLocatingSpeed
```

**功能：** 表示快速获取位置优先，如果应用希望快速拿到一个位置，可以将优先级设置为该类型。

快速定位优先策略会同时使用GNSS定位和网络定位技术，以便在室内和户外场景下均可以快速获取到位置结果，我们会把最先拿到的定位结果返回给应用。对设备的硬件资源消耗较大，功耗也较大。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

## enum LocationRequestPriority

```cangjie
public enum LocationRequestPriority {
    | Unset
    | Accuracy
    | LowPower
    | FirstFix
    | ...
}
```

**功能：** 位置请求中位置信息优先级类型。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### Accuracy

```cangjie
Accuracy
```

**功能：** 表示精度优先。

定位精度优先策略主要以GNSS定位技术为主。我们会在GNSS提供稳定位置结果之前使用网络定位技术提供服务。在持续定位过程中，如果超过30秒无法获取GNSS定位结果则使用网络定位技术。对设备的硬件资源消耗较大，功耗较大。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### FirstFix

```cangjie
FirstFix
```

**功能：** 表示快速获取位置优先，如果应用希望快速拿到一个位置，可以将优先级设置为该字段。

快速定位优先策略会同时使用GNSS定位和网络定位技术，以便在室内和户外场景下均可以快速获取到位置结果；当各种定位技术都有提供位置结果时，系统会选择其中精度较好的结果返回给应用。因为对各种定位技术同时使用，对设备的硬件资源消耗较大，功耗也较大。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### LowPower

```cangjie
LowPower
```

**功能：** 表示低功耗优先。

低功耗定位优先策略仅使用网络定位技术，在室内和户外场景均可提供定位服务，因为其依赖周边基站、可见WLAN、蓝牙设备的分布情况，定位结果的精度波动范围较大，推荐在对定位结果精度要求不高的场景下使用该策略，可以有效节省设备功耗。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### Unset

```cangjie
Unset
```

**功能：** 表示未设置优先级，表示[LocationRequestPriority](#enum-locationrequestpriority)无效。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

## enum LocationRequestScenario

```cangjie
public enum LocationRequestScenario {
    | Unset
    | Navigation
    | TrajectoryTracking
    | CarHailing
    | DailyLifeService
    | NoPower
    | ...
}
```

**功能：** 位置请求中定位场景类型。

> **说明：**
>
> 当使用NAVIGATION/TRAJECTORY_TRACKING/CAR_HAILING场景进行单次定位或持续定位时，会在GNSS提供稳定位置结果之前使用网络定位技术提供服务；在持续定位时，如果超过30秒无法获取GNSS定位结果则会使用网络定位技术获取位置。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### CarHailing

```cangjie
CarHailing
```

**功能：** 表示打车场景。

适用于用户出行打车时定位当前位置的场景，如网约车类应用。

主要使用GNSS定位技术提供定位服务，功耗较高。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### DailyLifeService

```cangjie
DailyLifeService
```

**功能：** 表示日常服务使用场景。

适用于不需要定位用户精确位置的使用场景，如新闻资讯、网购、点餐类应用。

该场景仅使用网络定位技术提供定位服务，功耗较低。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### Navigation

```cangjie
Navigation
```

**功能：** 表示导航场景。

适用于在户外获取设备实时位置的场景，如车载、步行导航。

主要使用GNSS定位技术提供定位服务，功耗较高。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### NoPower

```cangjie
NoPower
```

**功能：** 表示无功耗场景，这种场景下不会主动触发定位，会在其他应用定位时，才给当前应用返回位置。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### TrajectoryTracking

```cangjie
TrajectoryTracking
```

**功能：** 表示运动轨迹记录场景。

适用于记录用户位置轨迹的场景，如运动类应用记录轨迹功能。

主要使用GNSS定位技术提供定位服务，功耗较高。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### Unset

```cangjie
Unset
```

**功能：** 表示未设置场景信息。

表示[LocationRequestScenario](#enum-locationrequestscenario)字段无效。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

## enum LocationSourceType

```cangjie
public enum LocationSourceType {
    | Gnss
    | Network
    | Indoor
    | Rtk
    | ...
}
```

**功能：** 定位结果的来源。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### Gnss

```cangjie
Gnss
```

**功能：** 表示定位结果来自于GNSS定位技术。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### Indoor

```cangjie
Indoor
```

**功能：** 表示定位结果来自于室内高精度定位技术。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### Network

```cangjie
Network
```

**功能：** 表示定位结果来自于网络定位技术。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22

### Rtk

```cangjie
Rtk
```

**功能：** 表示定位结果来自于室外高精度定位技术。

**系统能力：** SystemCapability.Location.Location.Core

**起始版本：** 22
