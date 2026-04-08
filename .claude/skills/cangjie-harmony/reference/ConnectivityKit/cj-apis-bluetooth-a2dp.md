# ohos.bluetooth.a2dp（蓝牙a2dp模块）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

a2dp模块提供了访问蓝牙音频接口的方法。

## 导入模块

```cangjie
import kit.ConnectivityKit.*
```

## 权限列表

ohos.permission.ACCESS_BLUETOOTH

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](./../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## func createA2dpSrcProfile()

```cangjie
public func createA2dpSrcProfile(): A2dpSourceProfile
```

**功能：** 创建蓝牙媒体[A2DP Source](#class-a2dpsourceprofile)实例。通过该实例可使用本端作为A2DP Source设备的方法，如：获取和其他设备间的蓝牙媒体音频播放状态。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[A2dpSourceProfile](#class-a2dpsourceprofile)|返回该profile的实例。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.*

try {
    let a2dpProfile = createA2dpSrcProfile()
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

## class A2dpSourceProfile

```cangjie
public class A2dpSourceProfile <: BaseProfile {}
```

**功能：** 使用A2dpSourceProfile方法之前需要创建该类的实例进行操作，通过[createA2dpSrcProfile()](#func-createa2dpsrcprofile)方法构造此实例。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- [BaseProfile](cj-apis-bluetooth-base_profile.md#interface-baseprofile)

### func getConnectedDevices()

```cangjie
public func getConnectedDevices(): Array<String>
```

**功能：** 获取已连接设备列表。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<String>|返回当前已连接设备的地址。基于信息安全考虑，此处获取的设备地址为随机MAC地址。配对成功后，该地址不会变更；已配对设备取消配对后重新扫描或蓝牙服务下电时，该随机地址会变更。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900004 | Profile not supported. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.*

try {
    let a2dpSrc = createA2dpSrcProfile()
    let retArray = a2dpSrc.getConnectedDevices()
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

### func getConnectionState(String)

```cangjie
public func getConnectionState(deviceId: String): ProfileConnectionState
```

**功能：** 获取设备profile的连接状态。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|deviceId|String|是|-|远端设备地址。|

**返回值：**

|类型|说明|
|:----|:----|
|[ProfileConnectionState](cj-apis-bluetooth-constant.md#enum-profileconnectionstate)|返回profile的连接状态。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900004 | Profile not supported. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.*

try {
    let a2dpSrc = createA2dpSrcProfile()
    let retArray = a2dpSrc.getConnectionState("XX:XX:XX:XX:XX:XX")
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

### func getPlayingState(String)

```cangjie
public func getPlayingState(deviceId: String): PlayingState
```

**功能：** 获取设备的播放状态。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|deviceId|String|是|-|远端设备地址。|

**返回值：**

|类型|说明|
|:----|:----|
|[PlayingState](#enum-playingstate)|远端设备的播放状态。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900004 | Profile not supported. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.*

try {
    let a2dpSrc = createA2dpSrcProfile()
    let state = a2dpSrc.getPlayingState("XX:XX:XX:XX:XX:XX")
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

### func off(ProfileCallbackType, CallbackObject)

```cangjie
public func off(eventType: ProfileCallbackType, callback: CallbackObject): Unit
```

**功能：** 取消所有订阅连接状态变化事件。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[ProfileCallbackType](cj-apis-bluetooth-base_profile.md#enum-profilecallbacktype)|是|-|回调事件类型。|
|callback|[CallbackObject](../arkinterop/cj-api-callback_invoke.md#class-callbackobject)|是|-|回调事件。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.callback_invoke.*
import ohos.business_exception.*

// 此处定义所需要的依赖项等
class StateChangeCallback <: Callback1Argument<StateChangeParam> {
    public func invoke(err: ?BusinessException, arg: StateChangeParam): Unit {
        let connectionState = arg.state.toString()
        Hilog.info(0, "Bluetooth", "profile connection state has change to ${connectionState}")
    }
}

let a2dp = createA2dpSrcProfile()
let changeCallBack = StateChangeCallback()
try {
    a2dp.on(ProfileCallbackType.ConnectionStateChange, changeCallBack)
    a2dp.off(ProfileCallbackType.ConnectionStateChange)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

### func off(ProfileCallbackType)

```cangjie
public func off(eventType: ProfileCallbackType): Unit
```

**功能：** 取消所有订阅连接状态变化事件。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[ProfileCallbackType](cj-apis-bluetooth-base_profile.md#enum-profilecallbacktype)|是|-|回调事件类型。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.callback_invoke.*
import ohos.business_exception.*

// 此处定义所需要的依赖项等
class StateChangeCallback1 <: Callback1Argument<StateChangeParam> {
    public func invoke(err: ?BusinessException, arg: StateChangeParam): Unit {
        let connectionState = arg.state.toString()
        Hilog.info(0, "Bluetooth", "profile connection state has change to ${connectionState}")
    }
}

let a2dp = createA2dpSrcProfile()
let changeCallBack = StateChangeCallback1()
try {
    a2dp.on(ProfileCallbackType.ConnectionStateChange, changeCallBack)
    a2dp.off(ProfileCallbackType.ConnectionStateChange)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

### func on(ProfileCallbackType, Callback1Argument\<StateChangeParam>)

```cangjie
public func on(eventType: ProfileCallbackType, callback: Callback1Argument<StateChangeParam>): Unit
```

**功能：** 订阅连接状态变化事件。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[ProfileCallbackType](cj-apis-bluetooth-base_profile.md#enum-profilecallbacktype)|是|-|传入[ConnectionStateChange](./cj-apis-bluetooth-base_profile.md#connectionstatechange)，表示连接状态变化事件类型。|
|callback|Callback1Argument\<[StateChangeParam](cj-apis-bluetooth-base_profile.md#class-statechangeparam)>|是|-|表示回调函数的入参。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.callback_invoke.*
import ohos.business_exception.*

// 此处定义所需要的依赖项等
class StateChangeCallback2 <: Callback1Argument<StateChangeParam> {
    public func invoke(err: ?BusinessException, arg: StateChangeParam): Unit {
        let connectionState = arg.state.toString()
        Hilog.info(0, "Bluetooth", "profile connection state has change to ${connectionState}")
    }
}

let a2dp = createA2dpSrcProfile()
let changeCallBack = StateChangeCallback2()
try {
    a2dp.on(ProfileCallbackType.ConnectionStateChange, changeCallBack)
    a2dp.off(ProfileCallbackType.ConnectionStateChange)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

## class CodecInfo

```cangjie
public class CodecInfo {
    public var codecType: CodecType
    public var codecBitsPerSample: CodecBitsPerSample
    public var codecChannelMode: CodecChannelMode
    public var codecSampleRate: CodecSampleRate
}
```

**功能：** 编码器信息。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var codecBitsPerSample

```cangjie
public var codecBitsPerSample: CodecBitsPerSample
```

**功能：** 表示每个采样点的位数，初始值为CodecBitsPerSampleNone。

**类型：** [CodecBitsPerSample](#enum-codecbitspersample)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var codecChannelMode

```cangjie
public var codecChannelMode: CodecChannelMode
```

**功能：** 表示编码器的声道模式，初始值为CodecChannelModeNone。

**类型：** [CodecChannelMode](#enum-codecchannelmode)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var codecSampleRate

```cangjie
public var codecSampleRate: CodecSampleRate
```

**功能：** 表示编码器的采样率，初始值为CodecSampleRateNone。

**类型：** [CodecSampleRate](#enum-codecsamplerate)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var codecType

```cangjie
public var codecType: CodecType
```

**功能：** 表示编码器类型，初始值为CodecTypeSbc。

**类型：** [CodecType](#enum-codectype)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

## enum CodecBitsPerSample

```cangjie
public enum CodecBitsPerSample <: Equatable<CodecBitsPerSample> & ToString {
    | CodecBitsPerSampleNone
    | CodecBitsPerSample16
    | CodecBitsPerSample24
    | CodecBitsPerSample32
    | ...
}
```

**功能：** 蓝牙编码器每个采样点的位数。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<CodecBitsPerSample>
- ToString

### CodecBitsPerSample16

```cangjie
CodecBitsPerSample16
```

**功能：** 16位采样点的位数。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CodecBitsPerSample24

```cangjie
CodecBitsPerSample24
```

**功能：** 24位采样点的位数。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CodecBitsPerSample32

```cangjie
CodecBitsPerSample32
```

**功能：** 32位采样点的位数。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CodecBitsPerSampleNone

```cangjie
CodecBitsPerSampleNone
```

**功能：** 未知采样点的位数。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(CodecBitsPerSample)

```cangjie
public operator func !=(other: CodecBitsPerSample): Bool
```

**功能：** 对蓝牙编码器每个采样点的位数进行判不等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CodecBitsPerSample](#enum-codecbitspersample)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果蓝牙编码器每个采样点的位数不同，返回true，否则返回false。|

### func ==(CodecBitsPerSample)

```cangjie
public operator func ==(other: CodecBitsPerSample): Bool
```

**功能：** 对蓝牙编码器每个采样点的位数进行判等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CodecBitsPerSample](#enum-codecbitspersample)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果蓝牙编码器每个采样点的位数相同，返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 返回枚举值的字符串表示。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举值的字符串表示。|

## enum CodecChannelMode

```cangjie
public enum CodecChannelMode <: Equatable<CodecChannelMode> & ToString {
    | CodecChannelModeNone
    | CodecChannelModeMono
    | CodecChannelModeStereo
    | ...
}
```

**功能：** 蓝牙编码器的声道模式。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<CodecChannelMode>
- ToString

### CodecChannelModeMono

```cangjie
CodecChannelModeMono
```

**功能：** 单声道。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CodecChannelModeNone

```cangjie
CodecChannelModeNone
```

**功能：** 未知声道。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CodecChannelModeStereo

```cangjie
CodecChannelModeStereo
```

**功能：** 双声道。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(CodecChannelMode)

```cangjie
public operator func !=(other: CodecChannelMode): Bool
```

**功能：** 对蓝牙编码器的声道模式判不等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CodecChannelMode](#enum-codecchannelmode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果蓝牙编码器的声道模式不同，返回true，否则返回false。|

### func ==(CodecChannelMode)

```cangjie
public operator func ==(other: CodecChannelMode): Bool
```

**功能：** 对蓝牙编码器的声道模式判等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CodecChannelMode](#enum-codecchannelmode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果蓝牙编码器的声道模式相同，返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 返回枚举值的字符串表示。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举值的字符串表示。|

## enum CodecSampleRate

```cangjie
public enum CodecSampleRate <: Equatable<CodecSampleRate> & ToString {
    | CodecSampleRateNone
    | CodecSampleRate44100
    | CodecSampleRate48000
    | CodecSampleRate88200
    | CodecSampleRate96000
    | CodecSampleRate176400
    | CodecSampleRate192000
    | ...
}
```

**功能：** 蓝牙编码器的采样率。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<CodecSampleRate>
- ToString

### CodecSampleRate176400

```cangjie
CodecSampleRate176400
```

**功能：** 176.4k位采样率

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CodecSampleRate192000

```cangjie
CodecSampleRate192000
```

**功能：** 192k位采样率。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CodecSampleRate44100

```cangjie
CodecSampleRate44100
```

**功能：** 44.1k采样率。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CodecSampleRate48000

```cangjie
CodecSampleRate48000
```

**功能：** 48k采样率。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CodecSampleRate88200

```cangjie
CodecSampleRate88200
```

**功能：** 88.2k采样率。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CodecSampleRate96000

```cangjie
CodecSampleRate96000
```

**功能：** 96k位采样率。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CodecSampleRateNone

```cangjie
CodecSampleRateNone
```

**功能：** 未知采样率。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(CodecSampleRate)

```cangjie
public operator func !=(other: CodecSampleRate): Bool
```

**功能：** 对蓝牙编码器的采样率进行判不等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CodecSampleRate](#enum-codecsamplerate)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果蓝牙编码器的采样率不同，返回true，否则返回false。|

### func ==(CodecSampleRate)

```cangjie
public operator func ==(other: CodecSampleRate): Bool
```

**功能：** 对蓝牙编码器的采样率进行判等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CodecSampleRate](#enum-codecsamplerate)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果蓝牙编码器的采样率相同，返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 返回枚举值的字符串表示。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举值的字符串表示。|

## enum CodecType

```cangjie
public enum CodecType <: Equatable<CodecType> & ToString {
    | CodecTypeInvalid
    | CodecTypeSbc
    | CodecTypeAac
    | CodecTypeL2hc
    | ...
}
```

**功能：** 蓝牙编码器类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<CodecType>
- ToString

### CodecTypeAac

```cangjie
CodecTypeAac
```

**功能：** AAC。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CodecTypeInvalid

```cangjie
CodecTypeInvalid
```

**功能：** 未知编码类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CodecTypeL2hc

```cangjie
CodecTypeL2hc
```

**功能：** L2HC。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CodecTypeSbc

```cangjie
CodecTypeSbc
```

**功能：** SBC。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(CodecType)

```cangjie
public operator func !=(other: CodecType): Bool
```

**功能：** 对蓝牙编码器类型进行判不等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CodecType](#enum-codectype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果蓝牙编码器类型不同，返回true，否则返回false。|

### func ==(CodecType)

```cangjie
public operator func ==(other: CodecType): Bool
```

**功能：** 对蓝牙编码器类型进行判等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CodecType](#enum-codectype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果蓝牙编码器类型相同，返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 返回枚举值的字符串表示。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举值的字符串表示。|

## enum PlayingState

```cangjie
public enum PlayingState <: Equatable<PlayingState> & ToString {
    | StateNotPlaying
    | StatePlaying
    | ...
}
```

**功能：** 蓝牙A2DP播放状态。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<PlayingState>
- ToString

### StateNotPlaying

```cangjie
StateNotPlaying
```

**功能：** 表示未播放。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### StatePlaying

```cangjie
StatePlaying
```

**功能：** 表示正在播放。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(PlayingState)

```cangjie
public operator func !=(other: PlayingState): Bool
```

**功能：** 对蓝牙A2DP播放状态进行判不等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PlayingState](#enum-playingstate)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果蓝牙A2DP播放状态不同，返回true，否则返回false。|

### func ==(PlayingState)

```cangjie
public operator func ==(other: PlayingState): Bool
```

**功能：** 对蓝牙A2DP播放状态进行判等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PlayingState](#enum-playingstate)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果蓝牙A2DP播放状态相同，返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 返回枚举值的字符串表示。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举值的字符串表示。|
