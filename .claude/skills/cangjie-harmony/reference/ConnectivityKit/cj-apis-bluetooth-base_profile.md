# ohos.bluetooth.base_profile（蓝牙baseProfile模块）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

baseProfile模块提供了基础的Profile类型和相关方法。

## 导入模块

```cangjie
import kit.ConnectivityKit.*
```

## 权限列表

ohos.permission.ACCESS_BLUETOOTH

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## interface BaseProfile

```cangjie
public interface BaseProfile {
    func getConnectedDevices(): Array<String>
    func getConnectionState(deviceId: String): ProfileConnectionState
    func on(eventType: ProfileCallbackType, callback: Callback1Argument<StateChangeParam>): Unit
    func off(eventType: ProfileCallbackType, callback: CallbackObject): Unit
    func off(eventType: ProfileCallbackType): Unit
}
```

**功能：** Profile 基础类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func getConnectedDevices()

```cangjie
func getConnectedDevices(): Array<String>
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

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

try {
    let a2dpSrc = createA2dpSrcProfile()
    let retArray = a2dpSrc.getConnectedDevices()
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

### func getConnectionState(String)

```cangjie
func getConnectionState(deviceId: String): ProfileConnectionState
```

**功能：** 获取设备Profile的连接状态。

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
|[ProfileConnectionState](cj-apis-bluetooth-constant.md#enum-profileconnectionstate)|返回Profile的连接状态。|

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

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

try {
    let a2dpSrc = createA2dpSrcProfile()
    let retArray = a2dpSrc.getConnectionState("XX:XX:XX:XX:XX:XX")
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

### func off(ProfileCallbackType, CallbackObject)

```cangjie
func off(eventType: ProfileCallbackType, callback: CallbackObject): Unit
```

**功能：** 取消所有订阅连接状态变化事件。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[ProfileCallbackType](#enum-profilecallbacktype)|是|-|回调事件类型。|
|callback|[CallbackObject](../arkinterop/cj-api-callback_invoke.md#class-callbackobject)|是|-|回调事件。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

// 此处定义所需要的依赖项等
class StateChangeCallback <: Callback1Argument<StateChangeParam> {
    public func invoke(err: ?BusinessException, arg: StateChangeParam): Unit {
        let connectionState = arg.state.toString()
        Hilog.info(0, "Bluetooth", "profile connection state has change to ${connectionState}")
    }
}

let changeCallBack = StateChangeCallback()
let a2dp = createA2dpSrcProfile()
try {
    a2dp.on(ProfileCallbackType.ConnectionStateChange, changeCallBack)
    a2dp.off(ProfileCallbackType.ConnectionStateChange)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

### func off(ProfileCallbackType)

```cangjie
func off(eventType: ProfileCallbackType): Unit
```

**功能：** 取消所有订阅连接状态变化事件。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[ProfileCallbackType](#enum-profilecallbacktype)|是|-|回调事件类型。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

// 此处定义所需要的依赖项等
class StateChangeCallback1 <: Callback1Argument<StateChangeParam> {
    public func invoke(err: ?BusinessException, arg: StateChangeParam): Unit {
        let connectionState = arg.state.toString()
        Hilog.info(0, "Bluetooth", "profile connection state has change to ${connectionState}")
    }
}

let changeCallBack = StateChangeCallback1()
let a2dp = createA2dpSrcProfile()
try {
    a2dp.on(ProfileCallbackType.ConnectionStateChange, changeCallBack)
    a2dp.off(ProfileCallbackType.ConnectionStateChange)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

### func on(ProfileCallbackType, Callback1Argument\<StateChangeParam>)

```cangjie
func on(eventType: ProfileCallbackType, callback: Callback1Argument<StateChangeParam>): Unit
```

**功能：** 订阅连接状态变化事件。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[ProfileCallbackType](#enum-profilecallbacktype)|是|-|传入`ConnectionStateChange`，表示连接状态变化事件类型。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[StateChangeParam](#class-statechangeparam)>|是|-|表示回调函数的入参。|

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

import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

// 此处定义所需要的依赖项等
class StateChangeCallback2 <: Callback1Argument<StateChangeParam> {
    public func invoke(err: ?BusinessException, arg: StateChangeParam): Unit {
        let connectionState = arg.state.toString()
        Hilog.info(0, "Bluetooth", "profile connection state has change to ${connectionState}")
    }
}

let changeCallBack = StateChangeCallback2()
let a2dp = createA2dpSrcProfile()
try {
    a2dp.on(ProfileCallbackType.ConnectionStateChange, changeCallBack)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

## class StateChangeParam

```cangjie
public class StateChangeParam {
    public var deviceId: String
    public var state: ProfileConnectionState
    public var cause: DisconnectCause
}
```

**功能：** 描述profile状态改变参数。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var cause

```cangjie
public var cause: DisconnectCause
```

**功能：** 表示连接失败的原因。

**类型：** [DisconnectCause](#enum-disconnectcause)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var deviceId

```cangjie
public var deviceId: String
```

**功能：** 表示蓝牙设备地址。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var state

```cangjie
public var state: ProfileConnectionState
```

**功能：** 表示蓝牙设备的profile连接状态。

**类型：** [ProfileConnectionState](cj-apis-bluetooth-constant.md#enum-profileconnectionstate)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

## enum DisconnectCause

```cangjie
public enum DisconnectCause <: Equatable<DisconnectCause> & ToString {
    | UserDisconnect
    | ConnectShouldFromKeyboard
    | ConnectShouldFromMouse
    | ConnectShouldFromCar
    | TooManyConnectedDevices
    | ConnectInternalFail
    | ...
}
```

**功能：** 连接失败原因。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<DisconnectCause>
- ToString

### ConnectInternalFail

```cangjie
ConnectInternalFail
```

**功能：** 内部错误。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### ConnectShouldFromCar

```cangjie
ConnectShouldFromCar
```

**功能：** 应该从车机侧发起连接。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### ConnectShouldFromKeyboard

```cangjie
ConnectShouldFromKeyboard
```

**功能：** 应该从键盘侧发起连接。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### ConnectShouldFromMouse

```cangjie
ConnectShouldFromMouse
```

**功能：** 应该从鼠标侧发起连接。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### TooManyConnectedDevices

```cangjie
TooManyConnectedDevices
```

**功能：** 当前连接数超过上限。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### UserDisconnect

```cangjie
UserDisconnect
```

**功能：** 用户主动断开连接。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(DisconnectCause)

```cangjie
public operator func !=(other: DisconnectCause): Bool
```

**功能：** 对连接失败原因进行判不等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DisconnectCause](#enum-disconnectcause)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果连接失败原因不同，返回true，否则返回false。|

### func ==(DisconnectCause)

```cangjie
public operator func ==(other: DisconnectCause): Bool
```

**功能：** 对连接失败原因进行判等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DisconnectCause](#enum-disconnectcause)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果连接失败原因相同，返回true，否则返回false。|

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

## enum ProfileCallbackType

```cangjie
public enum ProfileCallbackType <: Equatable<ProfileCallbackType> & Hashable & ToString {
    | ConnectionStateChange
    | ...
}
```

**功能：** bluetooth baseprofile 回调事件。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<ProfileCallbackType>
- Hashable
- ToString

### ConnectionStateChange

```cangjie
ConnectionStateChange
```

**功能：** 表示连接状态变化事件类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(ProfileCallbackType)

```cangjie
public operator func !=(other: ProfileCallbackType): Bool
```

**功能：** 对回调事件类型进行判不等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ProfileCallbackType](#enum-profilecallbacktype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果回调事件类型不同，返回true，否则返回false。|

### func ==(ProfileCallbackType)

```cangjie
public operator func ==(other: ProfileCallbackType): Bool
```

**功能：** 对回调事件类型进行判等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ProfileCallbackType](#enum-profilecallbacktype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果回调事件类型相同，返回true，否则返回false。|

### func hashCode()

```cangjie
public func hashCode(): Int64
```

**功能：** 获取回调事件类型的哈希值。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Int64|回调事件类型的哈希值。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取回调事件类型的字符串表示。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|回调事件类型的字符串表示。|