# ohos.wifi_manager（WLAN）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

wifi_manager模块主要提供WLAN基础功能、P2P（peer-to-peer）功能和WLAN消息通知的相应服务，让应用可以通过WLAN和其他设备互联互通。

## 导入模块

```cangjie
import kit.ConnectivityKit.*
```

## 权限列表

ohos.permission.GET_WIFI_INFO

ohos.permission.SET_WIFI_INFO

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md)。

## func getScanInfoList()

```cangjie
public func getScanInfoList(): Array<WifiScanInfo>
```

**功能：** 获取扫描结果。

**需要权限：** ohos.permission.GET_WIFI_INFO

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[WifiScanInfo](#class-wifiscaninfo)>|返回扫描到的热点列表。如果应用申请了ohos.permission.GET_WIFI_PEERS_MAC权限（仅系统应用可申请），则返回结果中的bssid为真实设备地址，否则为随机设备地址。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[WIFI错误码](./cj-errorcode-wifi-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2501000 | Operation failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let scanInfoList = getScanInfoList()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func isWifiActive()

```cangjie
public func isWifiActive(): Bool
```

**功能：** 查询WLAN是否已使能。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|true:已使能，false:未使能。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[WIFI错误码](./cj-errorcode-wifi-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | Capability not supported. |
  | 2501000 | Operation failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let isWifiActive = isWifiActive()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func off(WifiCallbackType, ?CallbackObject)

```cangjie
public func off(eventType: WifiCallbackType, callback!: ?CallbackObject = None): Unit
```

**功能：** 取消注册WLAN状态改变事件。

**需要权限：** ohos.permission.GET_WIFI_INFO

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[WifiCallbackType](#enum-wificallbacktype)|是|-|回调事件。|
|callback|?[CallbackObject](../arkinterop/cj-api-callback_invoke.md#class-callbackobject)|否|None| **命名参数。** 状态改变回调函数。如果callback没有传入参数，将取消注册该事件关联的所有回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[WIFI错误码](./cj-errorcode-wifi-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2801000 | Operation failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException
import ohos.callback_invoke.*
import kit.PerformanceAnalysisKit.Hilog

class WifiCallback <: Callback1Argument<Int32> {
    public func invoke(err: ?BusinessException, arg: Int32) {
        Hilog.info(0, "test", "invoke success", "")
    }
}

try {
    let callback = WifiCallback()
    // Register event
    on(WifiScanStateChange, callback)
    // Unregister event
    off(WifiScanStateChange, callback: callback)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func on(WifiCallbackType, Callback1Argument\<Int32>)

```cangjie
public func on(eventType: WifiCallbackType, callback: Callback1Argument<Int32>): Unit
```

**功能：** 注册WLAN状态改变事件。

**需要权限：** ohos.permission.GET_WIFI_INFO

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[WifiCallbackType](#enum-wificallbacktype)|是|-|回调事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<Int32>|是|-|状态改变回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[WIFI错误码](./cj-errorcode-wifi-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2801000 | Operation failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException
import ohos.callback_invoke.*
import kit.PerformanceAnalysisKit.Hilog

class WifiCallback1 <: Callback1Argument<Int32> {
    public func invoke(err: ?BusinessException, arg: Int32) {
        Hilog.info(0, "test", "invoke success", "")
    }
}

try {
    let callback = WifiCallback1()
    // Register event
    on(WifiScanStateChange, callback)
    // Unregister event
    off(WifiScanStateChange, callback: callback)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func p2pCancelConnect()

```cangjie
public func p2pCancelConnect(): Unit
```

**功能：** 在P2P连接过程中，取消P2P连接。

**需要权限：** ohos.permission.GET_WIFI_INFO

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[WIFI错误码](./cj-errorcode-wifi-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2801000 | Operation failed. |
  | 2801001 | Wi-Fi STA disabled. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    p2pCancelConnect()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func p2pConnect(WifiP2pConfig)

```cangjie
public func p2pConnect(config: WifiP2pConfig): Unit
```

**功能：** 执行P2P连接。

**需要权限：** ohos.permission.GET_WIFI_INFO

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|config|[WifiP2pConfig](#class-wifip2pconfig)|是|-|连接配置信息。如果DeviceAddressType未指定值，则DeviceAddressType默认为随机设备地址类型。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[WIFI错误码](./cj-errorcode-wifi-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2801000 | Operation failed. |
  | 2801001 | Wi-Fi STA disabled. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let config = WifiP2pConfig("xx:xx:xx:xx", -2, "", "", GroupOwnerBand.GoBandAuto)
    p2pConnect(config)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func startDiscoverDevices()

```cangjie
public func startDiscoverDevices(): Unit
```

**功能：** 开始发现设备。

**需要权限：** ohos.permission.GET_WIFI_INFO

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[WIFI错误码](./cj-errorcode-wifi-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2801000 | Operation failed. |
  | 2801001 | Wi-Fi STA disabled. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    startDiscoverDevices()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func stopDiscoverDevices()

```cangjie
public func stopDiscoverDevices(): Unit
```

**功能：** 停止发现设备。

**需要权限：** ohos.permission.GET_WIFI_INFO

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[WIFI错误码](./cj-errorcode-wifi-manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2801000 | Operation failed. |
  | 2801001 | Wi-Fi STA disabled. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    stopDiscoverDevices()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class WifiInfoElement

```cangjie
public class WifiInfoElement {
    public var eid: UInt32
    public var content: Array<UInt8>
}
```

**功能：** WLAN热点信息。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var content

```cangjie
public var content: Array<UInt8>
```

**功能：** 元素内容。

**类型：** Array\<UInt8>

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var eid

```cangjie
public var eid: UInt32
```

**功能：** 元素ID。

**类型：** UInt32

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

## class WifiP2pConfig

```cangjie
public class WifiP2pConfig {
    public var deviceAddress: String
    public var netId: Int32
    public var passphrase: String
    public var groupName: String
    public var goBand: GroupOwnerBand
    public var deviceAddressType: DeviceAddressType
    public init(
        deviceAddress: String,
        netId: Int32,
        passphrase: String,
        groupName: String,
        goBand: GroupOwnerBand,
        deviceAddressType!: DeviceAddressType = RandomDeviceAddress
    )
}
```

**功能：** 表示P2P配置信息。

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

### var deviceAddress

```cangjie
public var deviceAddress: String
```

**功能：** 设备地址。

**类型：** String

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

### var deviceAddressType

```cangjie
public var deviceAddressType: DeviceAddressType
```

**功能：** 设备地址类型。

**类型：** [DeviceAddressType](#enum-deviceaddresstype)

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

### var goBand

```cangjie
public var goBand: GroupOwnerBand
```

**功能：** 群组带宽。

**类型：** [GroupOwnerBand](#enum-groupownerband)

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

### var groupName

```cangjie
public var groupName: String
```

**功能：** 群组名称。

**类型：** String

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

### var netId

```cangjie
public var netId: Int32
```

**功能：** 网络ID。创建群组时-1表示创建临时组，-2表示创建永久组。

**类型：** Int32

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

### var passphrase

```cangjie
public var passphrase: String
```

**功能：** 群组密钥。

**类型：** String

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

### init(String, Int32, String, String, GroupOwnerBand, DeviceAddressType)

```cangjie
public init(
    deviceAddress: String,
    netId: Int32,
    passphrase: String,
    groupName: String,
    goBand: GroupOwnerBand,
    deviceAddressType!: DeviceAddressType = RandomDeviceAddress
)
```

**功能：** 构造WifiP2PConfig实例。

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|deviceAddress|String|是|-|设备地址。|
|netId|Int32|是|-|网络ID。创建群组时-1表示创建临时组，-2表示创建永久组。|
|passphrase|String|是|-|群组密钥。|
|groupName|String|是|-|群组名称。|
|goBand|[GroupOwnerBand](#enum-groupownerband)|是|-|群组带宽。|
|deviceAddressType|[DeviceAddressType](#enum-deviceaddresstype)|否|RandomDeviceAddress| **命名参数。** 设备地址类型。|

## class WifiScanInfo

```cangjie
public class WifiScanInfo {
    public var ssid: String
    public var bssid: String
    public var bssidType: DeviceAddressType
    public var capabilities: String
    public var securityType: WifiSecurityType
    public var rssi: Int32
    public var band: Int32
    public var frequency: Int32
    public var channelWidth: Int32
    public var centerFrequency0: Int32
    public var centerFrequency1: Int32
    public var infoElems: Array<WifiInfoElement>
    public var timestamp: Int64
    public var supportedWifiCategory: WifiCategory
    public var isHiLinkNetwork: Bool
}
```

**功能：** WLAN热点信息。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var band

```cangjie
public var band: Int32
```

**功能：**  WLAN接入点的频段，1:2.4GHZ；2:5GHZ。

**类型：** Int32

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var bssid

```cangjie
public var bssid: String
```

**功能：** 热点的BSSID，例如：00:11:22:33:44:55。

**类型：** String

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var bssidType

```cangjie
public var bssidType: DeviceAddressType
```

**功能：** 热点的BSSID类型。

**类型：** [DeviceAddressType](#enum-deviceaddresstype)

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var capabilities

```cangjie
public var capabilities: String
```

**功能：** 热点能力。

**类型：** String

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var centerFrequency0

```cangjie
public var centerFrequency0: Int32
```

**功能：** 热点的中心频率。

**类型：** Int32

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var centerFrequency1

```cangjie
public var centerFrequency1: Int32
```

**功能：** 热点的中心频率。如果热点使用两个不重叠的WLAN信道，则返回两个中心频率，分别用centerFrequency0和centerFrequency1表示。

**类型：** Int32

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var channelWidth

```cangjie
public var channelWidth: Int32
```

**功能：** WLAN接入点的带宽。

**类型：** Int32

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var frequency

```cangjie
public var frequency: Int32
```

**功能：** WLAN接入点的频率。

**类型：** Int32

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var infoElems

```cangjie
public var infoElems: Array<WifiInfoElement>
```

**功能：** 信息元素。

**类型：** Array\<[WifiInfoElement](#class-wifiinfoelement)>

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var isHiLinkNetwork

```cangjie
public var isHiLinkNetwork: Bool
```

**功能：** 热点是否支持hiLink，true:支持，&nbsp;false:不支持。

**类型：** Bool

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var rssi

```cangjie
public var rssi: Int32
```

**功能：** 热点的信号强度(dBm)。

**类型：** Int32

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var securityType

```cangjie
public var securityType: WifiSecurityType
```

**功能：** WLAN加密类型。

**类型：** [WifiSecurityType](#enum-wifisecuritytype)

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var ssid

```cangjie
public var ssid: String
```

**功能：** 热点的SSID，最大长度为32字节，编码格式为UTF-8。

**类型：** String

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var supportedWifiCategory

```cangjie
public var supportedWifiCategory: WifiCategory
```

**功能：** 热点支持的最高wifi级别。

**类型：** [WifiCategory](#enum-wificategory)

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### var timestamp

```cangjie
public var timestamp: Int64
```

**功能：** 时间戳。

**类型：** Int64

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

## enum DeviceAddressType

```cangjie
public enum DeviceAddressType <: Equatable<DeviceAddressType> & ToString {
    | RandomDeviceAddress
    | RealDeviceAddress
    | ...
}
```

**功能：** wifi 设备地址（mac/bssid）类型。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

**父类型：**

- Equatable\<DeviceAddressType>
- ToString

### RandomDeviceAddress

```cangjie
RandomDeviceAddress
```

**功能：** 随机设备地址。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

### RealDeviceAddress

```cangjie
RealDeviceAddress
```

**功能：** 真实设备地址。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

### func !=(DeviceAddressType)

```cangjie
public operator func !=(other: DeviceAddressType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DeviceAddressType](#enum-deviceaddresstype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(DeviceAddressType)

```cangjie
public operator func ==(other: DeviceAddressType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[DeviceAddressType](#enum-deviceaddresstype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum GroupOwnerBand

```cangjie
public enum GroupOwnerBand <: Equatable<GroupOwnerBand> & ToString {
    | GoBandAuto
    | GoBand2GHz
    | GoBand5GHz
    | ...
}
```

**功能：** 表示群组带宽。

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

**父类型：**

- Equatable\<GroupOwnerBand>
- ToString

### GoBand2GHz

```cangjie
GoBand2GHz
```

**功能：** 2.4GHZ。

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

### GoBand5GHz

```cangjie
GoBand5GHz
```

**功能：** 5GHZ。

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

### GoBandAuto

```cangjie
GoBandAuto
```

**功能：** 自动模式。

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

### func !=(GroupOwnerBand)

```cangjie
public operator func !=(other: GroupOwnerBand): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[GroupOwnerBand](#enum-groupownerband)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(GroupOwnerBand)

```cangjie
public operator func ==(other: GroupOwnerBand): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[GroupOwnerBand](#enum-groupownerband)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Communication.WiFi.P2P

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum WifiCallbackType

```cangjie
public enum WifiCallbackType <: Equatable<WifiCallbackType> & Hashable & ToString {
    | WifiScanStateChange
    | ...
}
```

**功能：** WLAN回调触发事件类型。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

**父类型：**

- Equatable\<WifiCallbackType>
- Hashable
- ToString

### WifiScanStateChange

```cangjie
WifiScanStateChange
```

**功能：** 注册WLAN状态改变事件类型。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### func !=(WifiCallbackType)

```cangjie
public operator func !=(other: WifiCallbackType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WifiCallbackType](#enum-wificallbacktype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(WifiCallbackType)

```cangjie
public operator func ==(other: WifiCallbackType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WifiCallbackType](#enum-wificallbacktype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func hashCode()

```cangjie
public func hashCode(): Int64
```

**功能：** 获取输入数据的哈希值。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Int64|数据的哈希值。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum WifiCategory

```cangjie
public enum WifiCategory <: Equatable<WifiCategory> & ToString {
    | Default
    | Wifi6
    | Wifi6Plus
    | ...
}
```

**功能：** 表示热点支持的最高wifi类别。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

**父类型：**

- Equatable\<WifiCategory>
- ToString

### Default

```cangjie
Default
```

**功能：** Default。Wifi6以下的wifi类别。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### Wifi6

```cangjie
Wifi6
```

**功能：** Wifi6。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### Wifi6Plus

```cangjie
Wifi6Plus
```

**功能：** Wifi6+。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

### func !=(WifiCategory)

```cangjie
public operator func !=(other: WifiCategory): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WifiCategory](#enum-wificategory)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(WifiCategory)

```cangjie
public operator func ==(other: WifiCategory): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WifiCategory](#enum-wificategory)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Communication.WiFi.STA

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum WifiSecurityType

```cangjie
public enum WifiSecurityType <: Equatable<WifiSecurityType> & ToString {
    | WifiSecTypeInvalid
    | WifiSecTypeOpen
    | WifiSecTypeWep
    | WifiSecTypePsk
    | WifiSecTypeSae
    | WifiSecTypeEap
    | WifiSecTypeEapSuiteB
    | WifiSecTypeOwe
    | WifiSecTypeWapiCert
    | WifiSecTypeWapiPsk
    | ...
}
```

**功能：** 表示加密类型。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

**父类型：**

- Equatable\<WifiSecurityType>
- ToString

### WifiSecTypeEap

```cangjie
WifiSecTypeEap
```

**功能：** EAP加密类型。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

### WifiSecTypeEapSuiteB

```cangjie
WifiSecTypeEapSuiteB
```

**功能：** Suite-B 192位加密类型。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

### WifiSecTypeInvalid

```cangjie
WifiSecTypeInvalid
```

**功能：** 无效加密类型。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

### WifiSecTypeOpen

```cangjie
WifiSecTypeOpen
```

**功能：** 开放加密类型。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

### WifiSecTypeOwe

```cangjie
WifiSecTypeOwe
```

**功能：** 机会性无线加密类型。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

### WifiSecTypePsk

```cangjie
WifiSecTypePsk
```

**功能：** Pre-shared key (PSK)加密类型。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

### WifiSecTypeSae

```cangjie
WifiSecTypeSae
```

**功能：** Simultaneous Authentication of Equals (SAE)加密类型。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

### WifiSecTypeWapiCert

```cangjie
WifiSecTypeWapiCert
```

**功能：** WAPI-Cert加密类型。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

### WifiSecTypeWapiPsk

```cangjie
WifiSecTypeWapiPsk
```

**功能：** WAPI-PSK加密类型。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

### WifiSecTypeWep

```cangjie
WifiSecTypeWep
```

**功能：** Wired Equivalent Privacy (WEP)加密类型。候选网络配置不支持该加密类型。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

### func !=(WifiSecurityType)

```cangjie
public operator func !=(other: WifiSecurityType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WifiSecurityType](#enum-wifisecuritytype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(WifiSecurityType)

```cangjie
public operator func ==(other: WifiSecurityType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[WifiSecurityType](#enum-wifisecuritytype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Communication.WiFi.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|
