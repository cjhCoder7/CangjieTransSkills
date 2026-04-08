# ohos.bluetooth.ble（蓝牙ble模块）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

本模块提供了基于低功耗蓝牙（Bluetooth Low Energy，BLE）技术的蓝牙能力，支持发起BLE扫描、发送BLE广播报文、以及基于通用属性协议（Generic Attribute Profile，GATT）的连接和传输数据。

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
- 请将示例代码中的XX:XX:XX:XX:XX:XX或其他地址替换为您的真实地址

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## func createGattClientDevice(String)

```cangjie
public func createGattClientDevice(deviceId: String): GattClientDevice
```

**功能：** 创建[GattClientDevice](#class-gattclientdevice)实例，表示GATT连接中的client端。

- 通过该实例可以操作client端行为，如调用[connect](#func-connect)向对端设备发起连接，调用[getServices](#func-getrssivalueasynccallbackint32)获取对端设备支持的所有服务能力。
- 创建该实例所需要的设备地址表示server端设备。可以通过[startBleScanning](#func-startblescanningarrayscanfilter-scanoptions)接口获取server端设备地址，且需保证server端设备的BLE广播是可连接的。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|deviceId|String|是|-|对端设备地址，&nbsp;例如："XX:XX:XX:XX:XX:XX"。|

**返回值：**

|类型|说明|
|:----|:----|
|[GattClientDevice](#class-gattclientdevice)|client端类，使用client端方法之前需要创建该类的实例进行操作。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | Capability not supported. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

try {
    let device: GattClientDevice = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

## func createGattServer()

```cangjie
public func createGattServer(): GattServer
```

**功能：** 创建[GattServer](#class-gattserver)实例，表示GATT连接中的server端。

- 通过该实例可以操作server端的行为，如添加服务[addService](#func-addservicegattservice)、通知特征值变化[notifyCharacteristicChanged](#func-notifycharacteristicchangedstring-notifycharacteristic)等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[GattServer](#class-gattserver)|返回一个Gatt服务的实例。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException

try {
    let gattServer: GattServer = createGattServer()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func off(BluetoothBleCallbackType, ?CallbackObject)

```cangjie
public func off(eventType: BluetoothBleCallbackType, callback!: ?CallbackObject = None): Unit
```

**功能：** 取消订阅BLE设备事件。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[BluetoothBleCallbackType](#enum-bluetoothblecallbacktype)|是|-|回调事件。|
|callback|?[CallbackObject](../arkinterop/cj-api-callback_invoke.md#class-callbackobject)|否|None|**命名参数。**  表示取消订阅BLE事件。不填该参数则取消订阅该type对应的所有回调。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class BLEDeviceFindCallback <: Callback1Argument<Array<ScanResult>> {
    public func invoke(err: ?BusinessException, devices: Array<ScanResult>): Unit {
        for (device in devices) {
            Hilog.info(0, "Bluetooth", "device has find, deviceID is ${device.deviceId}, name is ${device.deviceName}")
        }
    }
}

let bleDeviceFindCallback = BLEDeviceFindCallback()
try {
    on(BluetoothBleCallbackType.BleDeviceFind, bleDeviceFindCallback)
    off(BluetoothBleCallbackType.BleDeviceFind, callback: bleDeviceFindCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

## func on(BluetoothBleCallbackType, Callback1Argument\<AdvertisingStateChangeInfo>)

```cangjie
public func on(eventType: BluetoothBleCallbackType, callback: Callback1Argument<AdvertisingStateChangeInfo>): Unit
```

**功能：** 订阅BLE广播状态。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[BluetoothBleCallbackType](#enum-bluetoothblecallbacktype)|是|-|事件回调类型，支持的事件为AdvertisingStateChange，表示广播状态事件。<br>当调用[startAdvertising](#func-startadvertisingadvertisingparams)、[stopAdvertising](#func-stopadvertisinguint32)，广播状态改变时，均会触发该事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[AdvertisingStateChangeInfo](#class-advertisingstatechangeinfo)>|是|-|指定订阅的回调函数，会携带广播状态信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class AdvertisingStateChange <: Callback1Argument<AdvertisingStateChangeInfo> {
    public func invoke(err: ?BusinessException, info: AdvertisingStateChangeInfo): Unit {
        Hilog.info(0, "Bluetooth", "the advertising state is ${info.state}")
    }
}

let advertisingStateChange = AdvertisingStateChange()
try {
    on(BluetoothBleCallbackType.AdvertisingStateChange, advertisingStateChange)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

## func on(BluetoothBleCallbackType, Callback1Argument\<Array\<ScanResult>>)

```cangjie
public func on(eventType: BluetoothBleCallbackType, callback: Callback1Argument<Array<ScanResult>>): Unit
```

**功能：** 订阅BLE设备扫描结果上报事件。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[BluetoothBleCallbackType](#enum-bluetoothblecallbacktype)|是|-|事件回调类型，支持的事件为BleDeviceFind，表示BLE设备扫描结果上报事件。<br>当调用[startAdvertising](#func-startadvertisingadvertisingparams) 后，开始BLE扫描，若扫描到BLE设备，触发该事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<Array\<[ScanResult](#class-scanresult)>>|是|-|指定订阅的回调函数，会携带扫描结果的集合。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class BLEDeviceFindCallback1 <: Callback1Argument<Array<ScanResult>> {
    public func invoke(err: ?BusinessException, devices: Array<ScanResult>): Unit {
        for (device in devices) {
            Hilog.info(0, "Bluetooth", "device has find, deviceID is ${device.deviceId}, name is ${device.deviceName}")
        }
    }
}

let bleDeviceFindCallback = BLEDeviceFindCallback1()
try {
    on(BluetoothBleCallbackType.BleDeviceFind, bleDeviceFindCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

## func startAdvertising(AdvertiseSetting, AdvertiseData, ?AdvertiseData)

```cangjie
public func startAdvertising(setting: AdvertiseSetting, advData: AdvertiseData, advResponse!: ?AdvertiseData = None): Unit
```

**功能：** 开始发送BLE广播报文。

- 当应用不再需要发送BLE广播报文时，需主动调用[stopAdvertising](#func-stopadvertisinguint32)停止发送。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|setting|[AdvertiseSetting](#class-advertisesetting)|是|-|BLE广播的相关参数。|
|advData|[AdvertiseData](#class-advertisedata)|是|-|BLE广播包内容。|
|advResponse|?[AdvertiseData](#class-advertisedata)|否|None|**命名参数。** BLE扫描回复广播报文。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900010 | The number of advertising resources reaches the upper limit. |
  | 2900099 | Operation failed. |
  | 2902054 | The length of the advertising data exceeds the upper limit. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

let advertisingSettings = AdvertiseSetting()
let manufactureDataUnit = ManufactureData(
    4567u16,
    [1, 2, 3, 4]
)
let serviceDataUnit = ServiceData(
    "00001888-0000-1000-8000-00805f9b34fb",
    [5, 6, 7, 8]
)
let advertisingData = AdvertiseData(
    ["00001888-0000-1000-8000-00805f9b34fb"],
    [manufactureDataUnit],
    [serviceDataUnit],
    includeDeviceName: true
)
let advertisingResponse = AdvertiseData(
    ["00001888-0000-1000-8000-00805f9b34fb"],
    [manufactureDataUnit],
    [serviceDataUnit]
)
try {
    startAdvertising(advertisingSettings, advertisingData, advResponse: advertisingResponse)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

## func startAdvertising(AdvertisingParams)

```cangjie
public func startAdvertising(advertisingParams: AdvertisingParams): UInt32
```

**功能：** 首次启动发送BLE广播报文。

- 启动成功后，蓝牙子系统会分配相关资源，并返回该广播的标识。

- 若携带了发送广播持续时间，则一定时间后，广播会停止发送，但分配的广播资源还存在。

- 应用可多次调用，支持发起多路广播，每一路广播通过不同的ID标识管理。

- 当应用不再需要该广播时，需调用[stopAdvertising](#func-stopadvertisinguint32)完全停止该广播，不要[stopAdvertising](#func-stopadvertising)混用。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|advertisingParams|[AdvertisingParams](#class-advertisingparams)|是|-|启动BLE广播的相关参数。|

**返回值：**

|类型|说明|
|:----|:----|
|UInt32|广播ID标识。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900010 | The number of advertising resources reaches the upper limit. |
  | 2900099 | Operation failed. |
  | 2902054 | The length of the advertising data exceeds the upper limit. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

let advertisingSettings = AdvertiseSetting()
let manufactureDataUnit = ManufactureData(
    4567u16,
    [1, 2, 3, 4]
)
let serviceDataUnit = ServiceData(
    "00001888-0000-1000-8000-00805f9b34fb",
    [5, 6, 7, 8]
)
let advertisingData = AdvertiseData(
    ["00001888-0000-1000-8000-00805f9b34fb"],
    [manufactureDataUnit],
    [serviceDataUnit],
    includeDeviceName: true
)
let advertisingResponse = AdvertiseData(
    ["00001888-0000-1000-8000-00805f9b34fb"],
    [manufactureDataUnit],
    [serviceDataUnit]
)
let advertisingParams = AdvertisingParams(
    advertisingSettings,
    advertisingData,
    advertisingResponse: advertisingResponse,
    duration: 300
)
try {
    let advHandle = startAdvertising(advertisingParams)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

## func startBleScanning(Array\<ScanFilter>, ?ScanOptions)

```cangjie
public func startBleScanning(filters: Array<ScanFilter>, options!: ?ScanOptions = None): Unit
```

**功能：** 发起BLE扫描流程。

- 扫描结果会通过[on(BleDeviceFind)](#func-onbluetoothblecallbacktype-callback1argumentarrayscanresult)的回调函数获取到。只能扫描BLE设备，调用[stopBleScanning](#func-stopblescanning)可以停止该方法开启的扫描流程。

- 该接口只支持单路扫描，即应用同时只能调用一次，下一次调用前，需要先调用[stopBleScanning](#func-stopblescanning)停止上一次的扫描流程。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|filters|Array\<[ScanFilter](#class-scanfilter)>|是|-|表示扫描结果过滤策略集合，符合过滤条件的设备发现会保留。<br>-若该参数设置为[]，将扫描所有可发现的周边BLE设备，但是不建议使用此方式，可能扫描到非预期设备，并增加功耗。|
|options|?[ScanOptions](#class-scanoptions)|否|None|**命名参数。** 表示扫描的参数配置，可选参数。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class BLEDeviceFindCallback2 <: Callback1Argument<Array<ScanResult>> {
    public func invoke(err: ?BusinessException, devices: Array<ScanResult>): Unit {
        for (device in devices) {
            Hilog.info(0, "Bluetooth", "device has find, deviceID is ${device.deviceId}, name is ${device.deviceName}")
        }
    }
}

let bleDeviceFindCallback = BLEDeviceFindCallback2()
try {
    on(BluetoothBleCallbackType.BleDeviceFind, bleDeviceFindCallback)
    var scanFilter = ScanFilter()
    scanFilter.serviceUUID = "00001888-0000-1000-8000-00805f9b34fb"  // 请替换为您的 serviceUUid
    let scanOptions = ScanOptions(interval: 0, dutyMode: ScanDuty.ScanModeLowPower, matchMode: MatchMode.MatchModeAggressive, phyType: PhyType.PhyLe1M)
    startBleScanning([scanFilter], options: scanOptions)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

## func stopAdvertising()

```cangjie
public func stopAdvertising(): Unit
```

**功能：** 停止发送BLE广播报文。

- 停止的BLE广播是由[startAdvertising](#func-startadvertisingadvertisesetting-advertisedata-advertisedata)触发的。
- 不可以和[startAdvertising](#func-startadvertisingadvertisingparams)搭配使用。
- 当应用不再需要发送BLE广播报文时，需主动调用该方法停止发送。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900099 | Operation failed. |
  | 2902055 | Invalid advertising id. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    stopAdvertising()
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

## func stopAdvertising(UInt32)

```cangjie
public func stopAdvertising(advertisingId: UInt32): Unit
```

**功能：** 完全停止发送BLE广播。

- 与[startAdvertising](#func-startadvertisingadvertisingparams)搭配使用，会释放已经申请的广播资源。
- [startAdvertising](#func-startadvertisingadvertisingparams)首次启动广播时分配的广播标识也将失效。
- 不可以和[startAdvertising](#func-startadvertisingadvertisesetting-advertisedata-advertisedata)接口搭配使用。
- 通过[on(AdvertisingStateChange)](#func-onbluetoothblecallbacktype-callback1argumentadvertisingstatechangeinfo)回调获取完全停止广播结果。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|advertisingId|UInt32|是|-|需要停止的广播ID标识。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900099 | Operation failed. |
  | 2902055 | Invalid advertising id. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

let advertisingSettings = AdvertiseSetting()
let manufactureDataUnit = ManufactureData(
    4567u16,
    [1, 2, 3, 4]
)
let serviceDataUnit = ServiceData(
    "00001888-0000-1000-8000-00805f9b34fb",
    [5, 6, 7, 8]
)
let advertisingData = AdvertiseData(
    ["00001888-0000-1000-8000-00805f9b34fb"],
    [manufactureDataUnit],
    [serviceDataUnit],
    includeDeviceName: true
)
let advertisingResponse = AdvertiseData(
    ["00001888-0000-1000-8000-00805f9b34fb"],
    [manufactureDataUnit],
    [serviceDataUnit]
)
let advertisingParams = AdvertisingParams(
    advertisingSettings,
    advertisingData,
    advertisingResponse: advertisingResponse,
    duration: 300
)
var advHandle: UInt32 = 0xFF
try {
    advHandle = startAdvertising(advertisingParams)
    stopAdvertising(advHandle)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

## func stopBleScanning()

```cangjie
public func stopBleScanning(): Unit
```

**功能：** 停止BLE扫描流程。

- 停止的BLE扫描由[startBleScanning](#func-startblescanningarrayscanfilter-scanoptions)触发。

- 当应用不再需要扫描BLE设备时，需主动调用该方法停止扫描。

- 调用此接口后将不再收到扫描结果上报，重新开启BLE扫描即可再次扫到BLE设备。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

try {
    stopBleScanning()
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

## class AdvertiseData

```cangjie
public class AdvertiseData {
    public var serviceUUIDs: Array<String>
    public var manufactureData: Array<ManufactureData>
    public var serviceData: Array<ServiceData>
    public var includeDeviceName: Bool
    public init(
        serviceUUIDs: Array<String>,
        manufactureData: Array<ManufactureData>,
        serviceData: Array<ServiceData>,
        includeDeviceName!: Bool = false,
        includeTxPower!: Bool = false
    )
}
```

**功能：** 描述BLE广播报文数据内容，也可以用作回复扫描请求的广播报文数据内容。当前只支持传统广播，因此报文最大长度为31个字节。若超出最大长度（31个字节）限制，会导致启动广播失败。若携带了所有参数，尤其是携带了蓝牙设备名称，需要注意广播报文长度。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var includeDeviceName

```cangjie
public var includeDeviceName: Bool
```

**功能：** 是否携带蓝牙设备名称。true表示携带，false表示不携带。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var manufactureData

```cangjie
public var manufactureData: Array<ManufactureData>
```

**功能：** 要携带的制造商数据内容。

**类型：** Array\<[ManufactureData](#class-manufacturedata)>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceData

```cangjie
public var serviceData: Array<ServiceData>
```

**功能：** 要携带的服务数据内容。

**类型：** Array\<[ServiceData](#class-servicedata)>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceUUIDs

```cangjie
public var serviceUUIDs: Array<String>
```

**功能：** 要携带的服务UUID。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### init(Array\<String>, Array\<ManufactureData>, Array\<ServiceData>, Bool, Bool)

```cangjie
public init(
    serviceUUIDs: Array<String>,
    manufactureData: Array<ManufactureData>,
    serviceData: Array<ServiceData>,
    includeDeviceName!: Bool = false,
    includeTxPower!: Bool = false
)
```

**功能：** AdvertiseData 构造器。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|serviceUUIDs|Array\<String>|是|-|要携带的服务UUID。|
|manufactureData|Array\<[ManufactureData](#class-manufacturedata)>|是|-|要携带的制造商数据内容。|
|serviceData|Array\<[ServiceData](#class-servicedata)>|是|-|要携带的服务数据内容。|
|includeDeviceName|Bool|否|false| **命名参数。** 是否携带蓝牙设备名称。true表示携带，false表示不携带，默认值为false。|
|includeTxPower|Bool|否|false| **命名参数。** 是否携带广播发送功率。<br>true表示携带广播发送功率，false表示不携带广播发送功率，默认值为false。<br>携带该值后，广播报文长度将多占用3个字节。|

## class AdvertiseSetting

```cangjie
public class AdvertiseSetting {
    public var interval: UInt16
    public var txPower: Int8
    public var connectable: Bool
    public init(interval!: UInt16 = BLE_ADV_DEFAULT_INTERVAL, txPower!: Int8 = BLE_ADV_TX_POWER_MEDIUM_VALUE, connectable!: Bool = true)
}
```

**功能：** 描述BLE广播的发送参数。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var connectable

```cangjie
public var connectable: Bool
```

**功能：** 是否是可连接广播。true表示发送可连接广播，false表示发送不可连接广播。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var interval

```cangjie
public var interval: UInt16
```

**功能：** 广播发送间隔。

取值范围：[32, 16777215]，单位：slot（时间槽），一个slot代表0.625毫秒。

其中传统广播的最大值是16384。

**类型：** UInt16

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var txPower

```cangjie
public var txPower: Int8
```

**功能：** 广播发送功率。取值范围：[-127, 1]，单位：dBm。

考虑到发送广播的性能和功耗，建议高档取值为1，中档取为-7，低档取值为-15。

**类型：** Int8

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### init(UInt16, Int8, Bool)

```cangjie
public init(interval!: UInt16 = BLE_ADV_DEFAULT_INTERVAL, txPower!: Int8 = BLE_ADV_TX_POWER_MEDIUM_VALUE, connectable!: Bool = true)
```

**功能：** 构造蓝牙低功耗设备发送广播的参数结构。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|interval|UInt16|否|BLE_ADV_DEFAULT_INTERVAL|**命名参数。** 广播发送间隔。取值范围：[32, 16777215]，单位：slot（时间槽），一个slot代表0.625毫秒，默认值为1600。|
|txPower|Int8|否|BLE_ADV_TX_POWER_MEDIUM_VALUE|**命名参数。** 广播发送功率。取值范围：[-127, 1]，单位：dBm，默认值为-7。|
|connectable|Bool|否|true|**命名参数。** 是否是可连接广播。true表示发送可连接广播，false表示发送不可连接广播，默认值为true。|

## class AdvertisingParams

```cangjie
public class AdvertisingParams {
    public var advertisingSettings: AdvertiseSetting
    public var advertisingData: AdvertiseData
    public var advertisingResponse: AdvertiseData
    public var duration: UInt16
    public init(
        advertisingSettings: AdvertiseSetting,
        advertisingData: AdvertiseData,
        advertisingResponse!: AdvertiseData = AdvertiseData([], [], []),
        duration!: UInt16 = 0
    )
}
```

**功能：** 首次启动BLE广播时设置的参数。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var advertisingData

```cangjie
public var advertisingData: AdvertiseData
```

**功能：** 需要发送的广播报文数据内容。

**类型：** [AdvertiseData](#class-advertisedata)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var advertisingResponse

```cangjie
public var advertisingResponse: AdvertiseData
```

**功能：** 回复扫描请求的广播报文数据内容。

**类型：** [AdvertiseData](#class-advertisedata)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var advertisingSettings

```cangjie
public var advertisingSettings: AdvertiseSetting
```

**功能：** 广播的发送参数。

**类型：** [AdvertiseSetting](#class-advertisesetting)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var duration

```cangjie
public var duration: UInt16
```

**功能：** 发送广播的持续时间。取值范围：[1, 65535]，单位：10ms。

**类型：** UInt16

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### init(AdvertiseSetting, AdvertiseData, AdvertiseData, UInt16)

```cangjie
public init(
    advertisingSettings: AdvertiseSetting,
    advertisingData: AdvertiseData,
    advertisingResponse!: AdvertiseData = AdvertiseData([], [], []),
    duration!: UInt16 = 0
)
```

**功能：** AdvertisingParams 构造器。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|advertisingSettings|[AdvertiseSetting](#class-advertisesetting)|是|-|广播的发送参数。|
|advertisingData|[AdvertiseData](#class-advertisedata)|是|-|需要发送的广播报文数据内容。|
|advertisingResponse|[AdvertiseData](#class-advertisedata)|否|AdvertiseData([],[],[])| **命名参数。** 回复扫描请求的广播报文数据内容。|
|duration|UInt16|否|0| **命名参数。** 发送广播的持续时间。取值范围：[1, 65535]，单位：10ms。|

## class AdvertisingStateChangeInfo

```cangjie
public class AdvertisingStateChangeInfo {
    public var advertisingId: Int32
    public var state: AdvertisingState
}
```

**功能：** 描述BLE广播启动、停止的状态信息。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var advertisingId

```cangjie
public var advertisingId: Int32
```

**功能：** 首次启动广播时会分配该值，后续用于标识当前操作的广播。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var state

```cangjie
public var state: AdvertisingState
```

**功能：** 操作广播后，收到的BLE广播状态。

**类型：** [AdvertisingState](#enum-advertisingstate)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

## class BleCharacteristic

```cangjie
public class BleCharacteristic {
    public var serviceUUID: String
    public var characteristicUUID: String
    public var characteristicValue: Array<Byte>
    public var descriptors: Array<BleDescriptor>
    public var properties: GattProperties
    public init(
        serviceUUID: String,
        characteristicUUID: String,
        characteristicValue: Array<Byte>,
        descriptors: Array<BleDescriptor>,
        properties!: GattProperties = GattProperties(),
        permissions!: GattPermissions = GattPermissions(),
        characteristicValueHandle!: UInt32 = 0
    )
}
```

**功能：** GATT特征值结构定义，是服务[GattService](#class-gattservice)的核心数据单元。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var characteristicUUID

```cangjie
public var characteristicUUID: String
```

**功能：** 特征值UUID。例如：00002a11-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var characteristicValue

```cangjie
public var characteristicValue: Array<Byte>
```

**功能：** 特征值的数据内容。

**类型：** Array\<Byte>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var descriptors

```cangjie
public var descriptors: Array<BleDescriptor>
```

**功能：** 特征值包含的描述符列表。

**类型：** Array\<[BleDescriptor](#class-bledescriptor)>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var properties

```cangjie
public var properties: GattProperties
```

**功能：** 特征值支持的属性。

**类型：** [GattProperties](#class-gattproperties)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceUUID

```cangjie
public var serviceUUID: String
```

**功能：** 特征值所属的服务UUID。例如：00001888-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### init(String, String, Array\<Byte>, Array\<BleDescriptor>, GattProperties, GattPermissions, UInt32)

```cangjie
public init(
    serviceUUID: String,
    characteristicUUID: String,
    characteristicValue: Array<Byte>,
    descriptors: Array<BleDescriptor>,
    properties!: GattProperties = GattProperties(),
    permissions!: GattPermissions = GattPermissions(),
    characteristicValueHandle!: UInt32 = 0
)
```

**功能：** BleCharacteristic 构造器。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|serviceUUID|String|是|-|特征值所属的服务UUID。例如：00001888-0000-1000-8000-00805f9b34fb。|
|characteristicUUID|String|是|-|特征值UUID。例如：00002a11-0000-1000-8000-00805f9b34fb。|
|characteristicValue|Array\<Byte>|是|-|特征值的数据内容。|
|descriptors|Array\<[BleDescriptor](#class-bledescriptor)>|是|-|特征值包含的描述符列表。|
|properties|[GattProperties](#class-gattproperties)|否|GattProperties()|**命名参数。** 特征值支持的属性。|
|permissions|[GattPermissions](#class-gattpermissions)|否|GattPermissions()|**命名参数。** 特征值读写操作需要的权限。预留字段，本版本暂不支持。|
|characteristicValueHandle|UInt32|否|0|**命名参数。** 特征值的唯一标识句柄。当server端BLE蓝牙设备提供了多个相同UUID特征值时，可以通过此句柄区分不同的特征值。预留字段，本版本暂不支持。|

## class BleConnectionChangeState

```cangjie
public class BleConnectionChangeState {
    public var deviceId: String
    public var state: ProfileConnectionState
}
```

**功能：** 描述GATT profile协议连接状态。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var deviceId

```cangjie
public var deviceId: String
```

**功能：** 对端蓝牙设备地址。例如："XX:XX:XX:XX:XX:XX"。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var state

```cangjie
public var state: ProfileConnectionState
```

**功能：** GATT profile连接状态。

**类型：** [ProfileConnectionState](cj-apis-bluetooth-constant.md#enum-profileconnectionstate)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

## class BleDescriptor

```cangjie
public class BleDescriptor {
    public var serviceUUID: String
    public var characteristicUUID: String
    public var descriptorUUID: String
    public var descriptorValue: Array<Byte>
    public init(
        serviceUUID: String,
        characteristicUUID: String,
        descriptorUUID: String,
        descriptorValue: Array<Byte>,
        descriptorHandle!: UInt32 = 0,
        permissions!: GattPermissions = GattPermissions()
    )
}
```

**功能：** GATT描述符结构定义，是特征值[BleCharacteristic](#class-blecharacteristic)的数据单元，用于描述特征值的附加信息和属性。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var characteristicUUID

```cangjie
public var characteristicUUID: String
```

**功能：** 描述符所属的特征值UUID。例如：00002a11-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var descriptorUUID

```cangjie
public var descriptorUUID: String
```

**功能：** 描述符UUID。例如：00002902-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var descriptorValue

```cangjie
public var descriptorValue: Array<Byte>
```

**功能：** 描述符的数据内容。

**类型：** Array\<Byte>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceUUID

```cangjie
public var serviceUUID: String
```

**功能：** 特征值所属的服务UUID。例如：00001888-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### init(String, String, String, Array\<Byte>, UInt32, GattPermissions)

```cangjie
public init(
    serviceUUID: String,
    characteristicUUID: String,
    descriptorUUID: String,
    descriptorValue: Array<Byte>,
    descriptorHandle!: UInt32 = 0,
    permissions!: GattPermissions = GattPermissions()
)
```

**功能：** BleDescriptor 构造器。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|serviceUUID|String|是|-|特征值所属的服务UUID。例如：00001888-0000-1000-8000-00805f9b34fb。|
|characteristicUUID|String|是|-|描述符所属的特征值UUID。例如：00002a11-0000-1000-8000-00805f9b34fb。|
|descriptorUUID|String|是|-|描述符UUID。例如：00002902-0000-1000-8000-00805f9b34fb。|
|descriptorValue|Array\<Byte>|是|-|描述符的数据内容。|
|descriptorHandle|UInt32|否|0|**命名参数。**  描述符的唯一标识句柄。当server端BLE蓝牙设备提供了多个相同UUID描述符时，可以通过此句柄区分不同的描述符。预留字段，本版本暂不支持。|
|permissions|[GattPermissions](#class-gattpermissions)|否|GattPermissions()|**命名参数。**  描述符读写操作需要的权限。预留字段，本版本暂不支持。|

## class CharacteristicReadRequest

```cangjie
public class CharacteristicReadRequest {
    public var deviceId: String
    public var transId: Int32
    public var offset: Int32
    public var characteristicUUID: String
    public var serviceUUID: String
}
```

**功能：** 描述server端订阅client端读特征值请求事件后，接收到的事件参数结构。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var characteristicUUID

```cangjie
public var characteristicUUID: String
```

**功能：** client端需要读取的特征值UUID。例如：00002a11-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var deviceId

```cangjie
public var deviceId: String
```

**功能：** client端蓝牙设备地址。例如："XX:XX:XX:XX:XX:XX"。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var offset

```cangjie
public var offset: Int32
```

**功能：** client端读数据的偏移值。例如：k表示从第k个字节开始读。<br>server端回复响应时需填写相同的offset。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceUUID

```cangjie
public var serviceUUID: String
```

**功能：** 特征值所属的服务UUID。例如：00001888-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var transId

```cangjie
public var transId: Int32
```

**功能：** client端读请求的标识符，server端回复时需填写相同的transId。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

## class CharacteristicWriteRequest

```cangjie
public class CharacteristicWriteRequest {
    public var deviceId: String
    public var transId: Int32
    public var offset: Int32
    public var isPrepared: Bool
    public var needRsp: Bool
    public var value: Array<Byte>
    public var characteristicUUID: String
    public var serviceUUID: String
}
```

**功能：** 描述server端订阅client端写特征值请求事件后，接收到的事件参数结构。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var characteristicUUID

```cangjie
public var characteristicUUID: String
```

**功能：** client端需要写入的特征值UUID。例如：00002a11-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var deviceId

```cangjie
public var deviceId: String
```

**功能：** client端蓝牙设备地址。例如："XX:XX:XX:XX:XX:XX"。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var isPrepared

```cangjie
public var isPrepared: Bool
```

**功能：** 收到client端写请求后，是否立即回复。

true表示稍后回复，false表示立即回复。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var needRsp

```cangjie
public var needRsp: Bool
```

**功能：** 是否需要回复client端。

true表示需要回复，false表示不需要回复。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var offset

```cangjie
public var offset: Int32
```

**功能：** client端写数据的偏移值。例如：k表示从第k个字节开始写。

server端回复时需填写相同的offset。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceUUID

```cangjie
public var serviceUUID: String
```

**功能：** 特征值所属的服务UUID。例如：00001888-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var transId

```cangjie
public var transId: Int32
```

**功能：** client端写请求的标识符，server端回复时需填写相同的transId。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var value

```cangjie
public var value: Array<Byte>
```

**功能：** client端需要给特征值写入的数据。

**类型：** Array\<Byte>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

## class DescriptorReadRequest

```cangjie
public class DescriptorReadRequest {
    public var deviceId: String
    public var transId: Int32
    public var offset: Int32
    public var descriptorUUID: String
    public var characteristicUUID: String
    public var serviceUUID: String
}
```

**功能：** 描述server端订阅client端读描述符请求事件后，接收到的事件参数结构。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var characteristicUUID

```cangjie
public var characteristicUUID: String
```

**功能：** 描述符所属的特征值UUID。例如：00002a11-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var descriptorUUID

```cangjie
public var descriptorUUID: String
```

**功能：** client端需要读取的描述符UUID。例如：00002902-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var deviceId

```cangjie
public var deviceId: String
```

**功能：** client端蓝牙设备地址。例如："XX:XX:XX:XX:XX:XX"。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var offset

```cangjie
public var offset: Int32
```

**功能：** client端读数据的偏移值。例如：k表示从第k个字节开始读。

server端回复响应时需填写相同的offset。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceUUID

```cangjie
public var serviceUUID: String
```

**功能：** 特征值所属的服务UUID。例如：00001888-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var transId

```cangjie
public var transId: Int32
```

**功能：** client端读请求的标识符，server端回复时需填写相同的transId。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

## class DescriptorWriteRequest

```cangjie
public class DescriptorWriteRequest {
    public var deviceId: String
    public var transId: Int32
    public var offset: Int32
    public var isPrepared: Bool
    public var needRsp: Bool
    public var value: Array<Byte>
    public var descriptorUUID: String
    public var characteristicUUID: String
    public var serviceUUID: String
}
```

**功能：** 描述server端订阅client端写描述符请求事件后，接收到的事件参数结构。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var characteristicUUID

```cangjie
public var characteristicUUID: String
```

**功能：** 描述符所属的特征值UUID。例如：00002a11-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var descriptorUUID

```cangjie
public var descriptorUUID: String
```

**功能：** client端需要写入的描述符UUID。例如：00002902-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var deviceId

```cangjie
public var deviceId: String
```

**功能：** client端蓝牙设备地址。例如："XX:XX:XX:XX:XX:XX"。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var isPrepared

```cangjie
public var isPrepared: Bool
```

**功能：** 收到client端写请求后，是否立即回复。

true表示稍后回复，false表示立即回复。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var needRsp

```cangjie
public var needRsp: Bool
```

**功能：** 是否需要回复client端。

true表示需要回复，false表示不需要回复。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var offset

```cangjie
public var offset: Int32
```

**功能：** client端写数据的偏移值。例如：k表示从第k个字节开始写。

server端回复时需填写相同的offset。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceUUID

```cangjie
public var serviceUUID: String
```

**功能：** 特征值所属的服务UUID。例如：00001888-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var transId

```cangjie
public var transId: Int32
```

**功能：** client端写请求的标识符，server端回复时需填写相同的transId。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var value

```cangjie
public var value: Array<Byte>
```

**功能：** client端需要给描述符写入的数据。

**类型：** Array\<Byte>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

## class GattClientDevice

```cangjie
public class GattClientDevice {}
```

**功能：** GATT客户端类，提供了和服务端进行连接和数据传输等操作方法。

- 使用该类的方法前，需通过[createGattClientDevice](#func-creategattclientdevicestring)方法构造该类的实例。

- 通过创建不同的该类实例，可以管理多路GATT连接。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func close()

```cangjie
public func close(): Unit
```

**功能：** 销毁client端实例。销毁后，通过[GattClientDevice](#class-gattclientdevice)创建的实例将不可用。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    gattClient.close()
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func connect()

```cangjie
public func connect(): Unit
```

**功能：** client端主动发起和server蓝牙设备的GATT协议连接。

- 远端设备地址已通过[createGattClientDevice](#func-creategattclientdevicestring)方法中的deviceId参数指定。
- client可通过订阅[on(BleConnectionStateChange)](#func-onbluetoothblegattclientdevicecallbacktype-callback1argumentbleconnectionchangestate)事件来感知连接是否成功。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    gattClient.connect()
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func disconnect()

```cangjie
public func disconnect(): Unit
```

**功能：** client断开与远端蓝牙低功耗设备的连接。

- client可通过订阅[on(BleConnectionStateChange)](#func-onbluetoothblegattclientdevicecallbacktype-callback1argumentbleconnectionchangestate)事件来感知连接是否成功。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    gattClient.disconnect()
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func getDeviceName()

```cangjie
public func getDeviceName(): String
```

**功能：** client获取远端蓝牙低功耗设备的名称。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|携带server端设备名称。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    let server = gattClient.getDeviceName()
    Hilog.info(0, "Bluetooth", "device name " + server)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func getRssiValue(AsyncCallback\<Int32>)

```cangjie
public func getRssiValue(callback: AsyncCallback<Int32>): Unit
```

**功能：** client端获取GATT连接链路信号强度 (Received Signal Strength Indication, RSSI)。

- 需先调用[connect](#func-connect)方法，等GATT profile连接成功后才能使用。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|[AsyncCallback](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)\<Int32>|是|-|返回链路的信号强度，单位：dBm。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900011 | The operation is busy. The last operation is not completed. |
  | 2900099 | Operation failed. |
  | 2901003 | The connection is not established. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    gattClient.getRssiValue {
        error: ?BusinessException, rssi: ?Int32 =>
        if (let Some(e) <- error) {
            throw e
        }
        Hilog.info(0, "Bluetooth", "the rssi value is " + rssi.getOrThrow().toString())
    }
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func getServices(AsyncCallback\<Array\<GattService>>)

```cangjie
public func getServices(callback: AsyncCallback<Array<GattService>>): Unit
```

**功能：** client端获取蓝牙低功耗设备的所有服务，即服务发现。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|[AsyncCallback](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)\<Array\<[GattService](#class-gattservice)>>|是|-|返回获取到的server端服务列表。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    let services = gattClient.getServices{err: ?BusinessException, c: ?Array<GattService> =>
            let ss = c.getOrThrow()
            for (service in ss) {
                Hilog.info(0, "Bluetooth", "find serviceUUID : ${service.serviceUUID}")
            }
        }
    Hilog.info(0, "Bluetooth", "getServices success")
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func off(BluetoothBleGattClientDeviceCallbackType, ?CallbackObject)

```cangjie
public func off(eventType: BluetoothBleGattClientDeviceCallbackType, callback!: ?CallbackObject = None): Unit
```

**功能：** 取消订阅 client 端蓝牙低功耗设备事件。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[BluetoothBleGattClientDeviceCallbackType](#enum-bluetoothblegattclientdevicecallbacktype)|是|-|特征值变化事件。|
|callback|?[CallbackObject](../arkinterop/cj-api-callback_invoke.md#class-callbackobject)|否|None|**命名参数。**  取消订阅 client 端蓝牙低功耗设备事件。不填该参数则取消订阅该type对应的所有回调。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

class BLEConnectionStateChangeCallback <: Callback1Argument<BleConnectionChangeState> {
    public func invoke(err: ?BusinessException, stateInfo: BleConnectionChangeState): Unit {
        Hilog.info(0, "Bluetooth", "onGattServerStateChange: device=" + stateInfo.deviceId + ", state=" + stateInfo.state.toString())
    }
}

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    var connectState = ProfileConnectionState.StateDisconnected
    let bleConnectionStateChangeCallback = BLEConnectionStateChangeCallback()
    gattClient.on(BluetoothBleGattClientDeviceCallbackType.BleConnectionStateChange, bleConnectionStateChangeCallback)
    gattClient.off(BluetoothBleGattClientDeviceCallbackType.BleConnectionStateChange, callback: bleConnectionStateChangeCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func on(BluetoothBleGattClientDeviceCallbackType, Callback1Argument\<BleCharacteristic>)

```cangjie
public func on(eventType: BluetoothBleGattClientDeviceCallbackType, callback: Callback1Argument<BleCharacteristic>): Unit
```

**功能：** client端订阅server端特征值变化事件。

- 需调用[setCharacteristicChangeNotification](#func-setcharacteristicchangenotificationblecharacteristic-bool-asynccallbackunit)或者[setCharacteristicChangeIndication](#func-setcharacteristicchangeindicationblecharacteristic-bool-asynccallbackunit)，且启用通知或者指示能力后，才能接收到server端的特征值内容变更通知或者指示。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[BluetoothBleGattClientDeviceCallbackType](#enum-bluetoothblegattclientdevicecallbacktype)|是|-|事件回调类型，支持的事件为BleCharacteristicChange，表示server端特征值变化事件。<br>当client端收到server端特征值内容变更的通知或者指示时，触发该事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[BleCharacteristic](#class-blecharacteristic)>|是|-|指定订阅的回调函数，会携带server端变化后的特征值内容。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class BLECharacteristicChangeCallback <: Callback1Argument<BleCharacteristic> {
    public func invoke(err: ?BusinessException, characteristic: BleCharacteristic): Unit {
        Hilog.info(0, "Bluetooth", "characteristic ${characteristic.serviceUUID} has change")
    }
}

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    let bleCharacteristicChangeCallback = BLECharacteristicChangeCallback()
    gattClient.on(BluetoothBleGattClientDeviceCallbackType.BleCharacteristicChange, bleCharacteristicChangeCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func on(BluetoothBleGattClientDeviceCallbackType, Callback1Argument\<BleConnectionChangeState>)

```cangjie
public func on(
    eventType: BluetoothBleGattClientDeviceCallbackType,
    callback: Callback1Argument<BleConnectionChangeState>
): Unit
```

**功能：** client端订阅GATT profile协议的连接状态变化事件。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[BluetoothBleGattClientDeviceCallbackType](#enum-bluetoothblegattclientdevicecallbacktype)|是|-|事件回调类型，支持的事件为BleConnectionStateChange，表示连接状态变化事件。<br>client和server端之间的连接状态发生变化时，触发该事件。<br>当client端调用[connect](#func-connect)或[disconnect](#func-disconnect)时，可能引起连接状态生变化。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[BleConnectionChangeState](#class-bleconnectionchangestate)>|是|-|指定订阅的回调函数，会携带连接状态信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class BLEConnectionStateChangeCallback1 <: Callback1Argument<BleConnectionChangeState> {
    public func invoke(err: ?BusinessException, stateInfo: BleConnectionChangeState): Unit {
        Hilog.info(0, "Bluetooth", "onGattServerStateChange: device=" + stateInfo.deviceId + ", state=" + stateInfo.state.toString())
    }
}

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    let bleConnectionStateChangeCallback = BLEConnectionStateChangeCallback1()
    gattClient.on(BluetoothBleGattClientDeviceCallbackType.BleConnectionStateChange, bleConnectionStateChangeCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func on(BluetoothBleGattClientDeviceCallbackType, Callback1Argument\<Int32>)

```cangjie
public func on(eventType: BluetoothBleGattClientDeviceCallbackType, callback: Callback1Argument<Int32>): Unit
```

**功能：** client端订阅MTU（最大传输单元）大小变更事件。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[BluetoothBleGattClientDeviceCallbackType](#enum-bluetoothblegattclientdevicecallbacktype)|是|-|事件回调类型，支持的事件为ClientBleMtuChange，表示MTU大小变更事件。<br>当调用[setBleMtuSize](#func-setblemtusizeint32)方法，client端发起MTU大小协商后，会触发该事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<Int32>|是|-|指定订阅的回调函数，会携带协商后的MTU大小。单位：Byte。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class BLEMtuChangeCallback <: Callback1Argument<Int32> {
    public func invoke(err: ?BusinessException, mtu: Int32): Unit {
        Hilog.info(0, "Bluetooth", "mtu change to ${mtu}")
    }
}

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    let bleMtuChangeCallback = BLEMtuChangeCallback()
    gattClient.on(BluetoothBleGattClientDeviceCallbackType.ClientBleMtuChange, bleMtuChangeCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func readCharacteristicValue(BleCharacteristic, AsyncCallback\<BleCharacteristic>)

```cangjie
public func readCharacteristicValue(
    characteristic: BleCharacteristic,
    callback: AsyncCallback<BleCharacteristic>
): Unit
```

**功能：** client端从指定的server端特征值读取数据。

- 需要先调用[getServices](#func-getservicesasynccallbackarraygattservice)，获取到server端所有支持的能力，且包含指定的入参特征值UUID；否则会读取失败。

- 回调结果返回后，才能调用下一次读取或者写入操作，如[readCharacteristicValue](#func-readcharacteristicvalueblecharacteristic-asynccallbackblecharacteristic)、[readDescriptorValue](#func-readdescriptorvaluebledescriptor-asynccallbackbledescriptor)、[writeCharacteristicValue](#func-writecharacteristicvalueblecharacteristic-gattwritetype-asynccallbackunit)、[writeDescriptorValue](#func-writedescriptorvaluebledescriptor-asynccallbackunit)、[setCharacteristicChangeNotification](#func-setcharacteristicchangenotificationblecharacteristic-bool-asynccallbackunit)和[setCharacteristicChangeIndication](#func-setcharacteristicchangeindicationblecharacteristic-bool-asynccallbackunit)。

- 读取特征值过程中，需确保[BleCharacteristic](#class-blecharacteristic)入参特征值的serviceUUID、characteristicUUID准确。characteristicValue表示的数据内容长度可由用户任意指定，不会影响实际读取到的特征值数据内容。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|characteristic|[BleCharacteristic](#class-blecharacteristic)|是|-|需要读取的特征值。|
|callback|[AsyncCallback](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)\<[BleCharacteristic](#class-blecharacteristic)>|是|-|回调函数。当读取成功，获取到的特征值对象，包含读取到的数据内容。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900011 | The operation is busy. The last operation is not completed. |
  | 2900099 | Operation failed. |
  | 2901000 | Read forbidden. |
  | 2901003 | The connection is not established. |
  | 2901004 | The connection is congested. |
  | 2901005 | The connection is not encrypted. |
  | 2901006 | The connection is not authenticated. |
  | 2901007 | The connection is not authorized. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

// 创建descriptors
let descBuffer: Array<Byte> = [31, 32]
let descriptor = BleDescriptor(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    "00002902-0000-1000-8000-00805F9B34FB",
    Array<Byte>(2, repeat: 0)
)
// 创建characteristics
let descriptors: Array<BleDescriptor> = [descriptor]
let charBuffer: Array<Byte> = [21, 22]
let properties = GattProperties()

let characteristic: BleCharacteristic = BleCharacteristic(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    charBuffer,
    descriptors,
    properties: properties
)

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    gattClient.readCharacteristicValue(characteristic) {
        error: ?BusinessException, outData: ?BleCharacteristic =>
        if (let Some(e) <- error) {
            throw e
        }
        if (let Some(c) <- outData) {
            Hilog.info(0, "Bluetooth", "read characteristic value uuid is ${c.characteristicUUID}", "")
            let message = StringBuilder("logCharacteristic value: ")
            for (i in 0..c.characteristicValue.size) {
                message.append(c.characteristicValue[i])
            }
            Hilog.info(0, "Bluetooth", message.toString())
        }
    }
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func readDescriptorValue(BleDescriptor, AsyncCallback\<BleDescriptor>)

```cangjie
public func readDescriptorValue(descriptor: BleDescriptor, callback: AsyncCallback<BleDescriptor>): Unit
```

**功能：** client端从指定的server端描述符读取数据。

- 需要先调用[getServices](#func-getservicesasynccallbackarraygattservice)，获取到server端所有支持的能力，且包含指定的入参特征值UUID；否则会读取失败。

- 回调结果返回后，才能调用下一次读取或者写入操作，如[readCharacteristicValue](#func-readcharacteristicvalueblecharacteristic-asynccallbackblecharacteristic)、[readDescriptorValue](#func-readdescriptorvaluebledescriptor-asynccallbackbledescriptor)、[writeCharacteristicValue](#func-writecharacteristicvalueblecharacteristic-gattwritetype-asynccallbackunit)、[writeDescriptorValue](#func-writedescriptorvaluebledescriptor-asynccallbackunit)、[setCharacteristicChangeNotification](#func-setcharacteristicchangenotificationblecharacteristic-bool-asynccallbackunit)和[setCharacteristicChangeIndication](#func-setcharacteristicchangeindicationblecharacteristic-bool-asynccallbackunit)。

- 读取描述符过程中，需确保[BleDescriptor](#class-bledescriptor)入参描述符的serviceUUID、characteristicUUID、descriptorUuid准确。descriptorValue表示的数据内容长度可由用户任意指定，不会影响实际读取到的描述符数据内容。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|descriptor|[BleDescriptor](#class-bledescriptor)|是|-|需要读取的描述符。|
|callback|[AsyncCallback](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)\<[BleDescriptor](#class-bledescriptor)>|是|-|回调函数。当读取成功，data为获取到的描述符对象，包含读取到的数据内容。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900011 | The operation is busy. The last operation is not complete. |
  | 2900099 | Operation failed. |
  | 2901000 | Read forbidden. |
  | 2901003 | The connection is not established. |
  | 2901004 | The connection is congested. |
  | 2901005 | The connection is not encrypted. |
  | 2901006 | The connection is not authenticated. |
  | 2901007 | The connection is not authorized. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

let descBuffer: Array<Byte> = [31, 32]
let descriptor = BleDescriptor(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    "00002903-0000-1000-8000-00805F9B34FB",
    Array<Byte>(2, repeat: 0)
)

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    gattClient.readDescriptorValue(descriptor) {
        error: ?BusinessException, outDescriptor: ?BleDescriptor =>
        if (let Some(e) <- error) {
            throw e
        }
        if (let Some(d) <- outDescriptor) {
            Hilog.info(0, "Bluetooth", "read descriptor value uuid is ${d.descriptorUUID}")
            let message = StringBuilder("logDescriptor value: ")
            for (i in 0..d.descriptorValue.size) {
                message.append(d.descriptorValue[i])
            }
            Hilog.info(0, "Bluetooth", message.toString())
        }
    }
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func setBleMtuSize(Int32)

```cangjie
public func setBleMtuSize(mtu: Int32): Unit
```

**功能：** client端同server端协商[MTU](../../connectivity/cj-terminology.md#mtu)（最大传输单元）大小。

- 需先调用[connect](#func-connect)方法，等GATT profile连接成功后才能使用。

- 通过[on(ClientBleMtuChange)](#func-onbluetoothblegattservercallbacktype-callback1argumentint32)，订阅MTU协商结果。

- 如果未协商，MTU大小默认为23字节。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|mtu|Int32|是|-|需要协商的mtu大小，取值范围：[23, 517]，单位：Byte。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    gattClient.setBleMtuSize(100)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func setCharacteristicChangeIndication(BleCharacteristic, Bool, AsyncCallback\<Unit>)

```cangjie
public func setCharacteristicChangeIndication(characteristic: BleCharacteristic, enable: Bool, callback: AsyncCallback<Unit>): Unit
```

**功能：** client端启用或者禁用接收server端特征值内容变更指示的能力。

- 需要先调用[getServices](#func-getservicesasynccallbackarraygattservice)，获取到server端所有支持的能力，且需包含指定的入参特征值UUID。

- server端对应的特征值需包含标准协议定义的Client Characteristic Configuration描述符UUID（00002902-0000-1000-8000-00805f9b34fb），server端才能支持发送变更指示。

- 若启用该能力，系统蓝牙服务会自动往server端写Client Characteristic Configuration描述符，启用server端的指示能力。

- 若禁用该能力，系统蓝牙服务会自动往server端写Client Characteristic Configuration描述符，禁用server端的指示能力。

- 通过[on(BleCharacteristicChange)](#func-onbluetoothblegattclientdevicecallbacktype-callback1argumentblecharacteristic)接收server端特征值内容变更指示。

- 若client端收到server端特征值内容变更指示后，系统蓝牙服务会主动回复确认，应用无需关注。

- 回调结果返回后，才能调用下一次读取或者写入操作，如[readCharacteristicValue](#func-readcharacteristicvalueblecharacteristic-asynccallbackblecharacteristic)、[readDescriptorValue](#func-readdescriptorvaluebledescriptor-asynccallbackbledescriptor)、[writeCharacteristicValue](#func-writecharacteristicvalueblecharacteristic-gattwritetype-asynccallbackunit)、[writeDescriptorValue](#func-writedescriptorvaluebledescriptor-asynccallbackunit)、[setCharacteristicChangeNotification](#func-setcharacteristicchangenotificationblecharacteristic-bool-asynccallbackunit)和[setCharacteristicChangeIndication](#func-setcharacteristicchangeindicationblecharacteristic-bool-asynccallbackunit)。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|characteristic|[BleCharacteristic](#class-blecharacteristic)|是|-|需要管理的server端特征值。|
|enable|Bool|是|-|蓝牙设备特征的写入类型。|
|callback|[AsyncCallback](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)\<Unit>|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900011 | The operation is busy. The last operation is not completed. |
  | 2900099 | Operation failed. |
  | 2901003 | The connection is not established. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

// 创建descriptors
let descBuffer: Array<Byte> = [31, 32]
let descriptor = BleDescriptor(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    "00002902-0000-1000-8000-00805F9B34FB",
    Array<Byte>(2, repeat: 0)
)
// 创建characteristics
let descriptors: Array<BleDescriptor> = [descriptor]
let charBuffer: Array<Byte> = [21, 22]
let properties = GattProperties()

let characteristic: BleCharacteristic = BleCharacteristic(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    charBuffer,
    descriptors,
    properties: properties
)

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    gattClient.setCharacteristicChangeIndication(characteristic, false)  {
        error: ?BusinessException, c: ?Unit => if (let Some(e) <- error) {
            throw e
        }
    }
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func setCharacteristicChangeNotification(BleCharacteristic, Bool, AsyncCallback\<Unit>)

```cangjie
public func setCharacteristicChangeNotification(characteristic: BleCharacteristic, enable: Bool, callback: AsyncCallback<Unit>): Unit
```

**功能：** client端启用或者禁用接收server端特征值内容变更通知的能力。

- 需要先调用[getServices](#func-getservicesasynccallbackarraygattservice)，获取到server端所有支持的能力，且需包含指定的入参特征值UUID。

- server端对应的特征值需包含标准协议定义的Client Characteristic Configuration描述符UUID（00002902-0000-1000-8000-00805f9b34fb），server端才能支持发送变更通知。

- 若启用该能力，系统蓝牙服务会自动往server端写Client Characteristic Configuration描述符，启用server端的通知能力。

- 若禁用该能力，系统蓝牙服务会自动往server端写Client Characteristic Configuration描述符，禁用server端的通知能力。

- 通过[on(BleCharacteristicChange)](#func-onbluetoothblegattclientdevicecallbacktype-callback1argumentblecharacteristic)接收server端特征值内容变更指示。

- 若client端收到server端特征值内容变更通知后，无需回复确认。

- 回调结果返回后，才能调用下一次读取或者写入操作，如[readCharacteristicValue](#func-readcharacteristicvalueblecharacteristic-asynccallbackblecharacteristic)、[readDescriptorValue](#func-readdescriptorvaluebledescriptor-asynccallbackbledescriptor)、[writeCharacteristicValue](#func-writecharacteristicvalueblecharacteristic-gattwritetype-asynccallbackunit)、[writeDescriptorValue](#func-writedescriptorvaluebledescriptor-asynccallbackunit)、[setCharacteristicChangeNotification](#func-setcharacteristicchangenotificationblecharacteristic-bool-asynccallbackunit)和[setCharacteristicChangeIndication](#func-setcharacteristicchangeindicationblecharacteristic-bool-asynccallbackunit)。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|characteristic|[BleCharacteristic](#class-blecharacteristic)|是|-|需要管理的server端特征值。|
|enable|Bool|是|-|是否启用接收server端特征值通知的能力。<br>true表示启用，false表示禁用。|
|callback|[AsyncCallback](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)\<Unit>|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900011 | The operation is busy. The last operation is not completed. |
  | 2900099 | Operation failed. |
  | 2901003 | The connection is not established. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
// 创建descriptors
let descBuffer: Array<Byte> = [31, 32]
let descriptor = BleDescriptor(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    "00002902-0000-1000-8000-00805F9B34FB",
    Array<Byte>(2, repeat: 0)
)
// 创建characteristics
let descriptors: Array<BleDescriptor> = [descriptor]
let charBuffer: Array<Byte> = [21, 22]
let properties = GattProperties()

let characteristic: BleCharacteristic = BleCharacteristic(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    charBuffer,
    descriptors,
    properties: properties
)

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    gattClient.setCharacteristicChangeNotification(characteristic, false) {
        error: ?BusinessException, c: ?Unit => if (let Some(e) <- error) {
            throw e
        }
    }
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func writeCharacteristicValue(BleCharacteristic, GattWriteType, AsyncCallback\<Unit>)

```cangjie
public func writeCharacteristicValue(characteristic: BleCharacteristic, writeType: GattWriteType,
    callback: AsyncCallback<Unit>): Unit
```

**功能：** client端向指定的server端特征值写入数据。

- 需要先调用[getServices](#func-getservicesasynccallbackarraygattservice)，获取到server端所有支持的能力，且包含指定的入参特征值UUID；否则会写入失败。

- 回调结果返回后，才能调用下一次读取或者写入操作，如[readCharacteristicValue](#func-readcharacteristicvalueblecharacteristic-asynccallbackblecharacteristic)、[readDescriptorValue](#func-readdescriptorvaluebledescriptor-asynccallbackbledescriptor)、[writeCharacteristicValue](#func-writecharacteristicvalueblecharacteristic-gattwritetype-asynccallbackunit)、[writeDescriptorValue](#func-writedescriptorvaluebledescriptor-asynccallbackunit)、[setCharacteristicChangeNotification](#func-setcharacteristicchangenotificationblecharacteristic-bool-asynccallbackunit)和[setCharacteristicChangeIndication](#func-setcharacteristicchangeindicationblecharacteristic-bool-asynccallbackunit)。

- 应用单次可写入的特征值数据长度默认限制为（MTU-3）字节，MTU大小可由[setBleMtuSize](#func-setblemtusizeint32)接口指定。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|characteristic|[BleCharacteristic](#class-blecharacteristic)|是|-|需要写入的特征值，包含写入的数据内容。|
|writeType|[GattWriteType](#enum-gattwritetype)|是|-|写入特征值的方式。|
|callback|[AsyncCallback](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)\<Unit>|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900011 | The operation is busy. The last operation is not completed. |
  | 2900099 | Operation failed. |
  | 2901001 | Write forbidden. |
  | 2901003 | The connection is not established. |
  | 2901004 | The connection is congested. |
  | 2901005 | The connection is not encrypted. |
  | 2901006 | The connection is not authenticated. |
  | 2901007 | The connection is not authorized. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

// 创建descriptors
let descBuffer: Array<Byte> = [31, 32]
let descriptor = BleDescriptor(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    "00002902-0000-1000-8000-00805F9B34FB",
    Array<Byte>(2, repeat: 0)
)

// 创建characteristics
let descriptors: Array<BleDescriptor> = [descriptor]
let charBuffer: Array<Byte> = [21, 22]
let properties = GattProperties()

let characteristic: BleCharacteristic = BleCharacteristic(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    charBuffer,
    descriptors,
    properties: properties
)

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    gattClient.writeCharacteristicValue(characteristic, GattWriteType.Write) {
        error: ?BusinessException, c: ?Unit => if (let Some(e) <- error) {
            throw e
        }
    }
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func writeDescriptorValue(BleDescriptor, AsyncCallback\<Unit>)

```cangjie
public func writeDescriptorValue(descriptor: BleDescriptor, callback: AsyncCallback<Unit>): Unit
```

**功能：** client端向指定的server端描述符写入数据。

- 需要先调用[getServices](#func-getservicesasynccallbackarraygattservice)，获取到server端所有支持的能力，且包含指定的入参描述符UUID；否则会写入失败。

- 回调结果返回后，才能调用下一次读取或者写入操作，如[readCharacteristicValue](#func-readcharacteristicvalueblecharacteristic-asynccallbackblecharacteristic)、[readDescriptorValue](#func-readdescriptorvaluebledescriptor-asynccallbackbledescriptor)、[writeCharacteristicValue](#func-writecharacteristicvalueblecharacteristic-gattwritetype-asynccallbackunit)、[writeDescriptorValue](#func-writedescriptorvaluebledescriptor-asynccallbackunit)、[setCharacteristicChangeNotification](#func-setcharacteristicchangenotificationblecharacteristic-bool-asynccallbackunit)和[setCharacteristicChangeIndication](#func-setcharacteristicchangeindicationblecharacteristic-bool-asynccallbackunit)。

- 应用单次可写入的描述符数据长度默认限制为（MTU-3）字节，MTU大小可由[setBleMtuSize](#func-setblemtusizeint32)接口指定。

- Client Characteristic Configuration描述符（UUID：00002902-0000-1000-8000-00805f9b34fb）和 Server Characteristic Configuration描述符（UUID：00002903-0000-1000-8000-00805f9b34fb）较为特殊，蓝牙标准协议规定内容长度为2字节，写入内容长度应设置为2字节。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|descriptor|[BleDescriptor](#class-bledescriptor)|是|-|需要写入的描述符，包含写入的数据内容。|
|callback|[AsyncCallback](../arkinterop/cj-api-business_exception.md#type-asynccallbackt)\<Unit>|是|-|回调函数。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900011 | The operation is busy. The last operation is not complete. |
  | 2900099 | Operation failed. |
  | 2901001 | Write forbidden. |
  | 2901003 | The connection is not established. |
  | 2901004 | The connection is congested. |
  | 2901005 | The connection is not encrypted. |
  | 2901006 | The connection is not authenticated. |
  | 2901007 | The connection is not authorized. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

let descBuffer: Array<Byte> = [31, 32]
let descriptor = BleDescriptor(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    "00002903-0000-1000-8000-00805F9B34FB",
    Array<Byte>(2, repeat: 0)
)
let descriptors: BleDescriptor = descriptor
let charBuffer: Array<Byte> = [1, 2]
let properties = GattProperties()

try {
    let gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")  // 请替换为您的设备地址
    gattClient.writeDescriptorValue(descriptors) {
        error: ?BusinessException, c: ?Unit => if (let Some(e) <- error) {
            throw e
        }
    }
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

## class GattPermissions

```cangjie
public class GattPermissions {
    public var read: Bool
    public var readEncrypted: Bool
    public var readEncryptedMitm: Bool
    public var write: Bool
    public var writeEncrypted: Bool
    public var writeEncryptedMitm: Bool
    public var writeSigned: Bool
    public var writeSignedMitm: Bool
    public init (
        read!: Bool = true,
        readEncrypted!: Bool = false,
        readEncryptedMitm!: Bool = false,
        write!: Bool = true,
        writeEncrypted!: Bool = false,
        writeEncryptedMitm!: Bool = false,
        writeSigned!: Bool = false,
        writeSignedMitm!: Bool = false
    )
}
```

**功能：** 描述读写GATT特征值或描述符需具备的权限。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var read

```cangjie
public var read: Bool
```

**功能：** 是否允许读取该特征值或描述符内容。

true表示允许，false表示不允许。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var readEncrypted

```cangjie
public var readEncrypted: Bool
```

**功能：** 读取该特征值或描述符内容是否需要加密。

true表示需要加密后，方可读取内容，false表示不需要普通方式加密。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var readEncryptedMitm

```cangjie
public var readEncryptedMitm: Bool
```

**功能：** 读取该特征值或描述符内容是否需要防中间人攻击的加密。

防中间人攻击表示操作需要经过认证，防止数据被第三方篡改。true表示需要防中间人攻击的加密后才能读取内容，false表示不需要防中间人攻击的加密。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var write

```cangjie
public var write: Bool
```

**功能：** 是否允许写入该特征值或描述符内容。

true表示允许，false表示不允许。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var writeEncrypted

```cangjie
public var writeEncrypted: Bool
```

**功能：** 写入该特征值或描述符内容是否需要加密。

true表示需要加密后，方可写入内容，false表示不需要普通方式加密。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var writeEncryptedMitm

```cangjie
public var writeEncryptedMitm: Bool
```

**功能：** 写入该特征值或描述符内容是否需要防中间人攻击的加密。

true表示需要防中间人攻击的加密后才能写入内容，false表示不需要防中间人攻击的加密。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var writeSigned

```cangjie
public var writeSigned: Bool
```

**功能：** 写入该特征值或描述符内容是否需要经过签名处理。

true表示内容需要签名处理后方可写入，false表示不需要签名处理。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var writeSignedMitm

```cangjie
public var writeSignedMitm: Bool
```

**功能：** 写入该特征值或描述符内容是否需要经过防中间人攻击方式的签名处理。

true表示需要防中间人攻击方式的签名处理后方可写入，false表示不需要以防中间人攻击方式签名处理。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### init(Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool)

```cangjie
public init (
    read!: Bool = true,
    readEncrypted!: Bool = false,
    readEncryptedMitm!: Bool = false,
    write!: Bool = true,
    writeEncrypted!: Bool = false,
    writeEncryptedMitm!: Bool = false,
    writeSigned!: Bool = false,
    writeSignedMitm!: Bool = false
)
```

**功能：** GattPermissions 构造器

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|read|Bool|否|true|**命名参数。** 是否允许读取该特征值或描述符内容。|
|readEncrypted|Bool|否|false|**命名参数。** 读取该特征值或描述符内容是否需要加密。|
|readEncryptedMitm|Bool|否|false|**命名参数。** 读取该特征值或描述符内容是否需要防中间人攻击的加密。|
|write|Bool|否|true|**命名参数。** 是否允许写入该特征值或描述符内容。|
|writeEncrypted|Bool|否|false|**命名参数。** 写入该特征值或描述符内容是否需要加密。|
|writeEncryptedMitm|Bool|否|false|**命名参数。** 写入该特征值或描述符内容是否需要防中间人攻击的加密。|
|writeSigned|Bool|否|false|**命名参数。** 写入该特征值或描述符内容是否需要经过签名处理。|
|writeSignedMitm|Bool|否|false|**命名参数。** 写入该特征值或描述符内容是否需要经过防中间人攻击方式的签名处理。|

### func !=(GattPermissions)

```cangjie
public operator func !=(other: GattPermissions): Bool
```

**功能：** 对 GattPermissions 进行判不等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[GattPermissions](#class-gattpermissions)|是|-|描述符读写操作需要的权限。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果描述符读写操作需要的权限不同，返回true，否则返回false。|

### func ==(GattPermissions)

```cangjie
public operator func ==(other: GattPermissions): Bool
```

**功能：** 对 GattPermissions 进行判等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[GattPermissions](#class-gattpermissions)|是|-|描述符读写操作需要的权限。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果描述符读写操作需要的权限相同，返回true，否则返回false。|

## class GattProperties

```cangjie
public class GattProperties {
    public var write: Bool
    public var writeNoResponse: Bool
    public var read: Bool
    public var notify: Bool
    public var indicate: Bool
    public init(
        write!: Bool = true,
        writeNoResponse!: Bool = true,
        read!: Bool = true,
        notify!: Bool = false,
        indicate!: Bool = false,
        broadcast!: Bool = false,
        authenticatedSignedWrite!: Bool = false,
        extendedProperties!: Bool = false
    )
}
```

**功能：** 描述GATT特征值支持的属性。决定了特征值内容和描述符如何被使用和访问。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var indicate

```cangjie
public var indicate: Bool
```

**功能：** 该特征值是否支持向对端设备指示特征值内容。

true表示支持，对端设备需要回复确认，false表示不支持。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var notify

```cangjie
public var notify: Bool
```

**功能：** 该特征值是否支持主动向对端设备通知特征值内容。

true表示支持，且对端设备不需要回复确认，false表示不支持。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var read

```cangjie
public var read: Bool
```

**功能：** 该特征值是否支持读取操作。

true表示支持，false表示不支持。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var write

```cangjie
public var write: Bool
```

**功能：** 该特征值是否支持写入操作。

true表示支持，且被写入时需要回复对端设备，false表示不支持。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var writeNoResponse

```cangjie
public var writeNoResponse: Bool
```

**功能：** 该特征值是否支持写入操作。

true表示支持，且被写入时无需回复对端设备，false表示不支持。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### init(Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool)

```cangjie
public init(
    write!: Bool = true,
    writeNoResponse!: Bool = true,
    read!: Bool = true,
    notify!: Bool = false,
    indicate!: Bool = false,
    broadcast!: Bool = false,
    authenticatedSignedWrite!: Bool = false,
    extendedProperties!: Bool = false
)
```

**功能：** GattProperties构造器。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|write|Bool|否|true|**命名参数。** 该特征值是否支持写入操作。|
|writeNoResponse|Bool|否|true|**命名参数。** 该特征值是否支持写入操作。|
|read|Bool|否|true|**命名参数。** 该特征值是否支持读取操作。|
|notify|Bool|否|false|**命名参数。** 该特征值是否支持主动向对端设备通知特征值内容。|
|indicate|Bool|否|false|**命名参数。** 该特征值是否支持向对端设备指示特征值内容。|
|broadcast|Bool|否|false|**命名参数。** 该特征值是否支持作为广播内容由server端发送。<br>true表示支持，server端可将特征值内容以[ServiceData](#class-servicedata)类型在广播报文中携带，false表示不支持。默认值为false。预留字段，本版本暂不支持。|
|authenticatedSignedWrite|Bool|否|false|**命名参数。** 该特征值是否支持签名写入操作，通过对写入内容进行签名校验替代加密流程。<br>true表示支持，且该特征值权限[GattPermissions](#class-gattpermissions)中的writeSigned或writeSignedMitm需设置为true，否则该属性不生效，false表示不支持。默认值为false。预留字段，本版本暂不支持。|
|extendedProperties|Bool|否|false|**命名参数。** 该特征值是否存在扩展属性。<br>true表示存在扩展属性，false表示不存在。默认值为false。预留字段，本版本暂不支持。|

## class GattServer

```cangjie
public class GattServer {}
```

**功能：** GATT通信中的服务端类。

- 通过[createGattServer](#func-creategattserver)方法可以构造server实例。

- 通过该实例可以操作server端的行为，如添加服务[addService](#func-addservicegattservice)、通知特征值变化[notifyCharacteristicChanged](#func-notifycharacteristicchangedstring-notifycharacteristic)等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func addService(GattService)

```cangjie
public func addService(service: GattService): Unit
```

**功能：** server端添加服务。该操作会在蓝牙子系统中注册该服务，表示server端支持的能力。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|service|[GattService](#class-gattservice)|是|-|server端的service数据。表示支持的特定功能。<br>例如：00001800-0000-1000-8000-00805f9b34fb表示通用访问服务；00001801-0000-1000-8000-00805f9b34fb表示通用属性服务等。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

// 创建descriptors
let descBuffer: Array<Byte> = [31, 32]
let descriptors0 = BleDescriptor(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    "00002902-0000-1000-8000-00805F9B34FB",
    Array<Byte>(2, repeat: 0)
)
let descriptors1 = BleDescriptor(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    "00002903-0000-1000-8000-00805F9B34FB",
    descBuffer
)

// 创建characteristics
let descriptors: Array<BleDescriptor> = [descriptors0, descriptors1]
let charBuffer: Array<Byte> = [21, 22]
let properties = GattProperties()

let characteristic: BleCharacteristic = BleCharacteristic(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    charBuffer,
    descriptors,
    properties: properties
)

let characteristics: Array<BleCharacteristic> = [characteristic]
let gattService: GattService = GattService(
    "00001810-0000-1000-8000-00805F9B34FB",
    true,
    characteristics,
    includeServices: Array<GattService>()
)

try {
    //构造gattServer
    let gattServer = createGattServer()
    gattServer.addService(gattService)
} catch (e: BusinessException) {
    Hilog.error(0, "AppLogCj", "add Service error because ${e}")
}
```

### func close()

```cangjie
public func close(): Unit
```

**功能：** 销毁server端实例。销毁后，通过[createGattServer](#func-creategattserver)创建的实例将不可用。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

try {
    let gattServer = createGattServer()
    gattServer.close()
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func notifyCharacteristicChanged(String, NotifyCharacteristic)

```cangjie
public func notifyCharacteristicChanged(deviceId: String, notifyCharacteristic: NotifyCharacteristic): Unit
```

**功能：** server端发送特征值变化通知或者指示给对端设备。

- 建议该特征值的Client Characteristic Configuration描述符notification（通知）或indication（指示）能力已被使能。

- 蓝牙标准协议规定Client Characteristic Configuration描述符的数据内容长度为2字节，bit0和bit1分别表示notification（通知）和indication（指示）能力是否使能，例如bit0 = 1表示notification enabled。

- 该特征值数据内容变化时调用。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|deviceId|String|是|-|接收通知的client设备地址。例如：“XX:XX:XX:XX:XX:XX”。|
|notifyCharacteristic|[NotifyCharacteristic](#class-notifycharacteristic)|是|-|通知给client的特征值数据对象。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

try {
    let gattServer = createGattServer()
    let charBuffer: Array<Byte> = [21, 22]
    let notifyCharacteristic = NotifyCharacteristic(
        "00001810-0000-1000-8000-00805F9B34FB",
        "00001820-0000-1000-8000-00805F9B34FB",
        charBuffer,
        false
    )
    gattServer.notifyCharacteristicChanged("XX:XX:XX:XX:XX:XX", notifyCharacteristic)  // 请替换为您的 deviceId
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func off(BluetoothBleGattServerCallbackType, ?CallbackObject)

```cangjie
public func off(eventType: BluetoothBleGattServerCallbackType, callback!: ?CallbackObject = None): Unit
```

**功能：** server端取消订阅事件。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[BluetoothBleGattServerCallbackType](#enum-bluetoothblegattservercallbacktype)|是|-|回调事件。|
|callback|?[CallbackObject](../arkinterop/cj-api-callback_invoke.md#class-callbackobject)|否|None|**命名参数。**  表示取消订阅BLE事件。不填该参数则取消订阅该type对应的所有回调。|

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

// 此处代码可添加在依赖项定义中
class StateChangeCallback <: Callback1Argument<BleConnectionChangeState> {
    public func invoke(err: ?BusinessException, state: BleConnectionChangeState): Unit {
        Hilog.info(0, "Bluetooth", "onGattServerStateChange: device=" + state.deviceId + ", state=" + state.state.toString())
    }
}

try {
    let gattServer = createGattServer()
    let stateChangeCallback = StateChangeCallback()
    gattServer.on(BluetoothBleGattServerCallbackType.ConnectionStateChange, stateChangeCallback)
    gattServer.off(BluetoothBleGattServerCallbackType.ConnectionStateChange, callback: stateChangeCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func on(BluetoothBleGattServerCallbackType, Callback1Argument\<CharacteristicReadRequest>)

```cangjie
public func on(eventType: BluetoothBleGattServerCallbackType, callback: Callback1Argument<CharacteristicReadRequest>): Unit
```

**功能：** server端订阅client的特征值读请求事件，server端收到该事件后需要调用[sendResponse](#func-sendresponseserverresponse)接口回复client。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[BluetoothBleGattServerCallbackType](#enum-bluetoothblegattservercallbacktype)|是|-|事件回调类型，支持的事件为CharacteristicRead，表示特征值读请求事件。<br>当收到client端设备的读取特征值请求时，触发该事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[CharacteristicReadRequest](#class-characteristicreadrequest)>|是|-|指定订阅的回调函数，会携带client端发送的读请求数据。|

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

// 此处代码可添加在依赖项定义中
class CharacteristicReadCallback <: Callback1Argument<CharacteristicReadRequest> {
    let gattReadServer: GattServer
    init(gattReadServer: GattServer) {
    	this.gattReadServer = gattReadServer
    }
    public func invoke(err: ?BusinessException, charReq: CharacteristicReadRequest): Unit {
        let deviceId: String = charReq.deviceId
        let transId: Int32 = charReq.transId
        let offset: Int32 = charReq.offset
        Hilog.info(0, "Bluetooth", "receive characteristicRead")
        let rspBuffer: Array<Byte> = [21, 22]
        let serverResponse: ServerResponse = ServerResponse(
            deviceId,
            transId,
            0,
            offset,
            rspBuffer
        )
        try {
            gattReadServer.sendResponse(serverResponse)
        } catch (e: BusinessException) {
            Hilog.info(0, "Bluetooth", "gattServer send response fail because ${e}")
        }
    }
}

try {
    let gattReadServer = createGattServer()
    let characteristicReadCallback = CharacteristicReadCallback(gattReadServer)
    gattReadServer.on(BluetoothBleGattServerCallbackType.CharacteristicRead, characteristicReadCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func on(BluetoothBleGattServerCallbackType, Callback1Argument\<CharacteristicWriteRequest>)

```cangjie
public func on(eventType: BluetoothBleGattServerCallbackType, callback: Callback1Argument<CharacteristicWriteRequest>): Unit
```

**功能：** server端订阅client的特征值写请求事件，server端收到该事件后需要根据[CharacteristicWriteRequest](#class-characteristicwriterequest)中的needRsp决定是否调用[sendResponse](#func-sendresponseserverresponse)接口回复client。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[BluetoothBleGattServerCallbackType](#enum-bluetoothblegattservercallbacktype)|是|-|事件回调类型，支持的事件为CharacteristicWrite，表示特征值写请求事件。<br>当收到client端设备的写特征值请求时，触发该事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[CharacteristicWriteRequest](#class-characteristicwriterequest)>|是|-|指定订阅的回调函数，会携带client端发送的写请求数据。|

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

// 此处代码可添加在依赖项定义中
class CharacteristicWriteCallback <: Callback1Argument<CharacteristicWriteRequest> {
    let gattWriteServer: GattServer
    init(gattWriteServer: GattServer) {
    	this.gattWriteServer = gattWriteServer
    }
    public func invoke(err: ?BusinessException, charReq: CharacteristicWriteRequest): Unit {
        let deviceId: String = charReq.deviceId
        let transId: Int32 = charReq.transId
        let offset: Int32 = charReq.offset
        Hilog.info(0, "Bluetooth", "receive characteristicWrite")

        Hilog.info(0, "Bluetooth", "receive characteristicWrite: needRsp=" + charReq
            .needRsp
            .toString())
        if (!charReq.needRsp) {
            return
        }
        let rspBuffer = Array<Byte>()
        let serverResponse: ServerResponse = ServerResponse(
            deviceId,
            transId,
            0,
            offset,
            rspBuffer
        )
        try {
            gattWriteServer.sendResponse(serverResponse)
        } catch (e: BusinessException) {
            Hilog.info(0, "Bluetooth", "gattServer send response fail because ${e}")
        }
    }
}

try {
    let gattWriteServer = createGattServer()
    let characteristicWriteCallback = CharacteristicWriteCallback(gattWriteServer)
    gattWriteServer.on(BluetoothBleGattServerCallbackType.CharacteristicWrite, characteristicWriteCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func on(BluetoothBleGattServerCallbackType, Callback1Argument\<DescriptorReadRequest>)

```cangjie
public func on(eventType: BluetoothBleGattServerCallbackType, callback: Callback1Argument<DescriptorReadRequest>): Unit
```

**功能：** server端订阅client的描述符读请求事件，server端收到该事件后需要调用[sendResponse](#func-sendresponseserverresponse)接口回复client。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[BluetoothBleGattServerCallbackType](#enum-bluetoothblegattservercallbacktype)|是|-|事件回调类型，支持的事件为DescriptorRead，表示描述符读请求事件。<br>当收到client端设备的读取描述符请求时，触发该事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[DescriptorReadRequest](#class-descriptorreadrequest)>|是|-|指定订阅的回调函数，会携带client端发送的读请求数据。|

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

// 此处代码可添加在依赖项定义中
class DescriptorReadCallback <: Callback1Argument<DescriptorReadRequest> {
    let gattServer: GattServer
    init(gattServer: GattServer) {
    	this.gattServer = gattServer
    }
    public func invoke(err: ?BusinessException, desReq: DescriptorReadRequest): Unit {
        let deviceId: String = desReq.deviceId
        let transId: Int32 = desReq.transId
        let offset: Int32 = desReq.offset
        Hilog.info(0, "Bluetooth", "receive descriptorRead")
        let rspBuffer: Array<Byte> = [31, 32]
        let serverResponse: ServerResponse = ServerResponse(
            deviceId,
            transId,
            0,
            offset,
            rspBuffer
        )
        try {
            gattServer.sendResponse(serverResponse)
        } catch (e: BusinessException) {
            Hilog.info(0, "Bluetooth", "gattServer send response fail because ${e}")
        }
    }
}

try {
    let gattServer = createGattServer()
    let descriptorReadCallback = DescriptorReadCallback(gattServer)
    gattServer.on(BluetoothBleGattServerCallbackType.DescriptorRead, descriptorReadCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func on(BluetoothBleGattServerCallbackType, Callback1Argument\<DescriptorWriteRequest>)

```cangjie
public func on(eventType: BluetoothBleGattServerCallbackType, callback: Callback1Argument<DescriptorWriteRequest>): Unit
```

**功能：** server端订阅client的描述符写请求事件，server端收到该事件后需要根据[DescriptorWriteRequest](#descriptorwrite)里的needRsp决定是否调用[sendResponse](#func-sendresponseserverresponse)接口回复client。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[BluetoothBleGattServerCallbackType](#enum-bluetoothblegattservercallbacktype)|是|-| 事件回调类型，支持的事件为DescriptorWrite，表示描述符写请求事件。<br>当收到client端设备的写描述符请求时，触发该事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[DescriptorWriteRequest](#class-descriptorwriterequest)>|是|-|指定订阅的回调函数，会携带client端发送的写请求数据。|

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

// 此处代码可添加在依赖项定义中
class DescriptorWriteCallback <: Callback1Argument<DescriptorWriteRequest> {
    let gattServer: GattServer
    init(gattServer: GattServer) {
    	this.gattServer = gattServer
    }
    public func invoke(err: ?BusinessException, desReq: DescriptorWriteRequest): Unit {
        let deviceId: String = desReq.deviceId
        let transId: Int32 = desReq.transId
        let offset: Int32 = desReq.offset
        Hilog.info(0, "Bluetooth", "receive descriptorWrite")
        Hilog.info(0, "Bluetooth", "receive descriptorWrite: needRsp=" + desReq.needRsp.toString())
        if (!desReq.needRsp) {
            return
        }
        let rspBuffer = Array<Byte>()
        let serverResponse: ServerResponse = ServerResponse(
            deviceId,
            transId,
            0,
            offset,
            rspBuffer
        )
        try {
            gattServer.sendResponse(serverResponse)
        } catch (e: BusinessException) {
            Hilog.info(0, "Bluetooth", "gattServer send response fail because ${e}")
        }
    }
}

try {
    let gattServer = createGattServer()
    let descriptorWriteCallback = DescriptorWriteCallback(gattServer)
    gattServer.on(BluetoothBleGattServerCallbackType.DescriptorWrite, descriptorWriteCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func on(BluetoothBleGattServerCallbackType, Callback1Argument\<BleConnectionChangeState>)

```cangjie
public func on(eventType: BluetoothBleGattServerCallbackType, callback: Callback1Argument<BleConnectionChangeState>): Unit
```

**功能：** server端订阅GATT profile协议的连接状态变化事件。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[BluetoothBleGattServerCallbackType](#enum-bluetoothblegattservercallbacktype)|是|-|事件回调类型，支持的事件为ConnectionStateChange，表示GATT profile连接状态发生变化的事件。<br>当client和server端之间的连接状态发生变化时，触发该事件。<br>例如：收到连接请求或者断连请求时，可能引起连接状态生变化。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[BleConnectionChangeState](#class-bleconnectionchangestate)>|是|-|指定订阅的回调函数，会携带连接状态。|

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

// 此处代码可添加在依赖项定义中
class StateChangeCallback1 <: Callback1Argument<BleConnectionChangeState> {
    public func invoke(err: ?BusinessException, state: BleConnectionChangeState): Unit {
        Hilog.info(0, "Bluetooth", "onGattServerStateChange: device=" + state.deviceId + ", state=" + state.state.toString())
    }
}

try {
    let gattServer = createGattServer()
    let stateChangeCallback = StateChangeCallback1()
    gattServer.on(BluetoothBleGattServerCallbackType.ConnectionStateChange, stateChangeCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func on(BluetoothBleGattServerCallbackType, Callback1Argument\<Int32>)

```cangjie
public func on(eventType: BluetoothBleGattServerCallbackType, callback: Callback1Argument<Int32>): Unit
```

**功能：** server端订阅MTU（最大传输单元）大小变更事件。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|eventType|[BluetoothBleGattServerCallbackType](#enum-bluetoothblegattservercallbacktype)|是|-|事件回调类型，支持的事件为ServerBleMtuChange，表示MTU状态变化事件。<br>当收到了client端发起了MTU协商请求时，触发该事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<Int32>|是|-|指定订阅的回调函数，会携带协商后的MTU大小。单位：Byte。|

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

// 此处代码可添加在依赖项定义中
class BLEMtuChangeCallback1 <: Callback1Argument<Int32> {
    public func invoke(err: ?BusinessException, mtu: Int32): Unit {
        Hilog.info(0, "Bluetooth", "mtu change to ${mtu}")
    }
}

try {
    let gattServer = createGattServer()
    let bleMtuChangeCallback = BLEMtuChangeCallback1()
    gattServer.on(BluetoothBleGattServerCallbackType.ServerBleMtuChange, bleMtuChangeCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func removeService(String)

```cangjie
public func removeService(serviceUUID: String): Unit
```

**功能：** 删除server端已添加的服务。

- 该服务曾通过[addService](#func-addservicegattservice)添加。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|serviceUUID|String|是|-|即将删除的服务的UUID。例如：00001810-0000-1000-8000-00805F9B34FB。|

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
    let gattServer = createGattServer()
    gattServer.removeService("00001810-0000-1000-8000-00805F9B34FB")
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### func sendResponse(ServerResponse)

```cangjie
public func sendResponse(serverResponse: ServerResponse): Unit
```

**功能：** server端收到client的请求操作后，需要调用此接口回复client，否则可能导致链路异常，超时后断连。

client请求是指通过下述接口订阅回调收到的请求消息：

- [on(CharacteristicRead)](#func-onbluetoothblegattservercallbacktype-callback1argumentcharacteristicreadrequest)
- [on(CharacteristicWrite)](#func-onbluetoothblegattservercallbacktype-callback1argumentcharacteristicwriterequest)，需根据[CharacteristicWriteRequest](#class-characteristicwriterequest)中的needRsp决定是否需要回复。
- [on(DescriptorRead)](#func-onbluetoothblegattservercallbacktype-callback1argumentdescriptorreadrequest)
- [on(DescriptorWrite)](#func-onbluetoothblegattservercallbacktype-callback1argumentdescriptorwriterequest)，需根据[DescriptorWriteRequest](#class-descriptorwriterequest)中的needRsp决定是否需要回复。

**需要权限：** ohos.permission.ACCESS_BLUETOOTH

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|serverResponse|ServerResponse|是|-|server端回复client的响应数据。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[蓝牙服务子系统错误码](./cj-errorcode-bluetooth_manager.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 801 | Capability not supported. |
  | 2900001 | Service stopped. |
  | 2900003 | Bluetooth disabled. |
  | 2900099 | Operation failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog

try {
    let rspBuffer = Array<Byte>()
    let serverResponse: ServerResponse = ServerResponse(
        "XX:XX:XX:XX:XX:XX", 0, 0, 0,
        rspBuffer
    )
    let gattServer = createGattServer()
    gattServer.sendResponse(serverResponse)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

## class GattService

```cangjie
public class GattService {
    public var serviceUUID: String
    public var isPrimary: Bool
    public var characteristics: Array<BleCharacteristic>
    public var includeServices: Array<GattService>
    public init(
        serviceUUID: String,
        isPrimary: Bool,
        characteristics: Array<BleCharacteristic>,
        includeServices!: Array<GattService> = []
    )
}
```

**功能：** GATT服务结构定义，可包含多个特征值[BleCharacteristic](#class-blecharacteristic)和依赖的其他服务。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var characteristics

```cangjie
public var characteristics: Array<BleCharacteristic>
```

**功能：** 当前服务包含的特征值列表。

**类型：** Array\<[BleCharacteristic](#class-blecharacteristic)>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var includeServices

```cangjie
public var includeServices: Array<GattService>
```

**功能：** 当前服务依赖的其它服务。

**类型：** Array\<[GattService](#class-gattservice)>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var isPrimary

```cangjie
public var isPrimary: Bool
```

**功能：** 是否是主服务。true表示是主服务，false表示是次要服务。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceUUID

```cangjie
public var serviceUUID: String
```

**功能：** 服务UUID，标识一个GATT服务。例如：00001888-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### init(String, Bool, Array\<BleCharacteristic>, Array\<GattService>)

```cangjie
public init(
    serviceUUID: String,
    isPrimary: Bool,
    characteristics: Array<BleCharacteristic>,
    includeServices!: Array<GattService> = []
)
```

**功能：** GattService 构造器。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|serviceUUID|String|是|-|服务UUID，标识一个GATT服务。例如：00001888-0000-1000-8000-00805f9b34fb。|
|isPrimary|Bool|是|-|是否是主服务。true表示是主服务，false表示是次要服务。|
|characteristics|Array\<[BleCharacteristic](#class-blecharacteristic)>|是|-|当前服务包含的特征值列表。|
|includeServices|Array\<[GattService](#class-gattservice)>|否|[]|**命名参数。** 当前服务依赖的其它服务。|

## class ManufactureData

```cangjie
public class ManufactureData {
    public var manufactureId: UInt16
    public var manufactureValue: Array<Byte>
    public init(
        manufactureId: UInt16,
        manufactureValue: Array<Byte>
    )
}
```

**功能：** 描述BLE广播报文中制造商数据内容。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var manufactureId

```cangjie
public var manufactureId: UInt16
```

**功能：** 制造商的标识，由蓝牙技术联盟分配。

**类型：** UInt16

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var manufactureValue

```cangjie
public var manufactureValue: Array<Byte>
```

**功能：** 制造商特定的数据。

**类型：** Array\<Byte>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### init(UInt16, Array\<Byte>)

```cangjie
public init(
    manufactureId: UInt16,
    manufactureValue: Array<Byte>
)
```

**功能：** ManufactureData 构造器。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|manufactureId|UInt16|是|-|制造商的标识，由蓝牙技术联盟分配。|
|manufactureValue|Array\<Byte>|是|-|制造商特定的数据。|

## class NotifyCharacteristic

```cangjie
public class NotifyCharacteristic {
    public var serviceUUID: String
    public var characteristicUUID: String
    public var characteristicValue: Array<Byte>
    public var confirm: Bool
    public init(
        serviceUUID: String,
        characteristicUUID: String,
        characteristicValue: Array<Byte>,
        confirm: Bool
    )
}
```

**功能：** 描述server端特征值发生变化时，server端发送特征值通知的参数结构。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var characteristicUUID

```cangjie
public var characteristicUUID: String
```

**功能：** 内容发生变化的特征值UUID。例如：00002a11-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var characteristicValue

```cangjie
public var characteristicValue: Array<Byte>
```

**功能：** 特征值对应的数据内容。

**类型：** Array\<Byte>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var confirm

```cangjie
public var confirm: Bool
```

**功能：** true表示发送的是指示，需要client端回复确认。false表示发送的是通知，不需要client端回复确认。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceUUID

```cangjie
public var serviceUUID: String
```

**功能：** 特征值所属的服务UUID。例如：00001888-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### init(String, String, Array\<Byte>, Bool)

```cangjie
public init(
    serviceUUID: String,
    characteristicUUID: String,
    characteristicValue: Array<Byte>,
    confirm: Bool
)
```

**功能：** NotifyCharacteristic 构造器。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|serviceUUID|String|是|-|特征值所属的服务UUID。例如：00001888-0000-1000-8000-00805f9b34fb。|
|characteristicUUID|String|是|-|内容发生变化的特征值UUID。例如：00002a11-0000-1000-8000-00805f9b34fb。|
|characteristicValue|Array\<Byte>|是|-|特征值对应的数据内容。|
|confirm|Bool|是|-|true表示发送的是指示，需要client端回复确认。false表示发送的是通知，不需要client端回复确认。|

## class ScanFilter

```cangjie
public class ScanFilter {
    public var deviceId: String
    public var name: String
    public var serviceUUID: String
    public var serviceUUIDMask: String
    public var serviceSolicitationUUID: String
    public var serviceSolicitationUUIDMask: String
    public var serviceData: Array<Byte>
    public var serviceDataMask: Array<Byte>
    public var manufactureId: UInt16
    public var manufactureData: Array<Byte>
    public var manufactureDataMask: Array<Byte>
    public init(
        deviceId!: String = "",
        name!: String = "",
        serviceUUID!: String = "",
        serviceUUIDMask!: String = "",
        serviceSolicitationUUID!: String = "",
        serviceSolicitationUUIDMask!: String = "",
        serviceData!: Array<Byte> = [],
        serviceDataMask!: Array<Byte> = [],
        manufactureId!: UInt16 = 0,
        manufactureData!: Array<Byte> = [],
        manufactureDataMask!: Array<Byte> = []
    )
}
```

**功能：** 扫描BLE广播的过滤条件，只有符合该条件的广播报文才会上报。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var deviceId

```cangjie
public var deviceId: String
```

**功能：** 过滤该BLE设备地址的广播报文。例如："XX:XX:XX:XX:XX:XX"。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var manufactureData

```cangjie
public var manufactureData: Array<Byte>
```

**功能：** 过滤包含该制造商标识符的广播报文。例如：0x0006。

**类型：** Array\<Byte>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var manufactureDataMask

```cangjie
public var manufactureDataMask: Array<Byte>
```

**功能：** 搭配manufactureId过滤器使用，过滤包含该制造商数据的广播报文。例如：[0x1F,0x2F,0x3F]。

**类型：** Array\<Byte>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var manufactureId

```cangjie
public var manufactureId: UInt16
```

**功能：** 表示过滤包含该制造商ID的设备，例如：0x0006。

**类型：** UInt16

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var name

```cangjie
public var name: String
```

**功能：** 过滤该BLE设备名称的广播报文。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceData

```cangjie
public var serviceData: Array<Byte>
```

**功能：** 过滤包含该服务数据的广播报文。例如：[0x90,0x00,0xF1,0xF2]。

**类型：** Array\<Byte>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceDataMask

```cangjie
public var serviceDataMask: Array<Byte>
```

**功能：** 搭配serviceData过滤器使用，可设置过滤部分服务数据。例如：[0xFF,0xFF,0xFF,0xFF]。

**类型：** Array\<Byte>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceSolicitationUUID

```cangjie
public var serviceSolicitationUUID: String
```

**功能：** 过滤包含该服务请求UUID的广播报文。例如：00001888-0000-1000-8000-00805F9B34FB。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceSolicitationUUIDMask

```cangjie
public var serviceSolicitationUUIDMask: String
```

**功能：** 搭配serviceSolicitationUUID过滤器使用，可设置过滤部分服务请求UUID。例如：FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceUUID

```cangjie
public var serviceUUID: String
```

**功能：** 过滤包含该服务UUID的广播报文。例如：00001888-0000-1000-8000-00805f9b34fb。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceUUIDMask

```cangjie
public var serviceUUIDMask: String
```

**功能：** 搭配serviceUUID过滤器使用，可设置过滤部分服务UUID。例如：FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### init(String, String, String, String, String, String, Array\<Byte>, Array\<Byte>, UInt16, Array\<Byte>, Array\<Byte>)

```cangjie
public init(
    deviceId!: String = "",
    name!: String = "",
    serviceUUID!: String = "",
    serviceUUIDMask!: String = "",
    serviceSolicitationUUID!: String = "",
    serviceSolicitationUUIDMask!: String = "",
    serviceData!: Array<Byte> = [],
    serviceDataMask!: Array<Byte> = [],
    manufactureId!: UInt16 = 0,
    manufactureData!: Array<Byte> = [],
    manufactureDataMask!: Array<Byte> = []
)
```

**功能：** 创建扫描过滤参数结构体ScanFilter。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|deviceId|String|否|""|**命名参数。** 过滤该BLE设备地址的广播报文。例如："XX:XX:XX:XX:XX:XX"。预留字段，本版本暂不支持。|
|name|String|否|""|**命名参数。** 过滤该BLE设备名称的广播报文。预留字段，本版本暂不支持。|
|serviceUUID|String|否|""|**命名参数。** 过滤包含该服务UUID的广播报文。例如：00001888-0000-1000-8000-00805f9b34fb。预留字段，本版本暂不支持。|
|serviceUUIDMask|String|否|""|**命名参数。** 搭配serviceUUID过滤器使用，可设置过滤部分服务UUID。例如：FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF。预留字段，本版本暂不支持。|
|serviceSolicitationUUID|String|否|""|**命名参数。** 过滤包含该服务请求UUID的广播报文。例如：00001888-0000-1000-8000-00805F9B34FB。预留字段，本版本暂不支持。|
|serviceSolicitationUUIDMask|String|否|""|**命名参数。** 搭配serviceSolicitationUuid过滤器使用，可设置过滤部分服务请求UUID。例如：FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF。预留字段，本版本暂不支持。|
|serviceData|Array\<Byte>|否|[]|**命名参数。** 过滤包含该服务数据的广播报文。例如：[0x90,0x00,0xF1,0xF2]。预留字段，本版本暂不支持。|
|serviceDataMask|Array\<Byte>|否|[]|**命名参数。** 搭配serviceData过滤器使用，可设置过滤部分服务数据。例如：[0xFF,0xFF,0xFF,0xFF]。预留字段，本版本暂不支持。|
|manufactureId|UInt16|否|0|**命名参数。** 过滤包含该制造商标识符的广播报文。例如：0x0006。预留字段，本版本暂不支持。|
|manufactureData|Array\<Byte>|否|[]|**命名参数。** 搭配manufactureId过滤器使用，过滤包含该制造商数据的广播报文。例如：[0x1F,0x2F,0x3F]。预留字段，本版本暂不支持。|
|manufactureDataMask|Array\<Byte>|否|[]|**命名参数。** 搭配manufactureData过滤器使用，可设置过滤部分制造商数据。例如：[0xFF,0xFF,0xFF]。预留字段，本版本暂不支持。|

## class ScanOptions

```cangjie
public class ScanOptions {
    public var interval: Int32
    public var dutyMode: ScanDuty
    public var matchMode: MatchMode
    public var phyType: PhyType
    public init(
        interval!: Int32 = 0,
        dutyMode!: ScanDuty = ScanModeLowPower,
        matchMode!: MatchMode = MatchModeAggressive,
        phyType!: PhyType = PhyLe1M,
        reportMode!: ScanReportMode = Normal
    )
}
```

**功能：** BLE扫描的配置参数。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var dutyMode

```cangjie
public var dutyMode: ScanDuty
```

**功能：** 扫描模式。

**类型：** [ScanDuty](#enum-scanduty)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var interval

```cangjie
public var interval: Int32
```

**功能：** 扫描结果上报的延迟时间，单位：ms。搭配[ScanReportMode](#enum-scanreportmode)使用。

- 在常规或围栏扫描上报模式下，该值不生效，扫描到符合过滤条件的广播报文后立即上报。

- 在批量扫描上报模式下，该值生效，扫描到符合过滤条件的广播报文后，会存入缓存队列，延迟上报。若不设置该值或设置在[0, 5000)范围内，蓝牙子系统会默认设置延迟时间为5000ms。延迟时间内，若符合过滤条件的广播报文数量超过硬件缓存能力，蓝牙子系统会提前上报扫描结果。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var matchMode

```cangjie
public var matchMode: MatchMode
```

**功能：** 硬件的过滤匹配模式。

**类型：** [MatchMode](#enum-matchmode)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var phyType

```cangjie
public var phyType: PhyType
```

**功能：** 扫描中使用的物理通道类型。

**类型：** [PhyType](#enum-phytype)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### init(Int32, ScanDuty, MatchMode, PhyType, ScanReportMode)

```cangjie
public init(
    interval!: Int32 = 0,
    dutyMode!: ScanDuty = ScanModeLowPower,
    matchMode!: MatchMode = MatchModeAggressive,
    phyType!: PhyType = PhyLe1M,
    reportMode!: ScanReportMode = Normal
)
```

**功能：** 创建扫描的配置参数结构体ScanOptions。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|interval|Int32|否|0|**命名参数。** 扫描结果上报的延迟时间，单位：ms，默认值为0。搭配[ScanReportMode](#enum-scanreportmode)使用。|
|dutyMode|[ScanDuty](#enum-scanduty)|否|ScanModeLowPower|**命名参数。** 扫描模式，默认值为ScanModeLowPower。|
|matchMode|[MatchMode](#enum-matchmode)|否|MatchModeAggressive|**命名参数。** 硬件的过滤匹配模式，默认值为MatchModeAggressive。|
|phyType|[PhyType](#enum-phytype)|否|PhyLe1M|**命名参数。** 扫描中使用的物理通道类型，默认值为PhyLe1M。|
|reportMode|[ScanReportMode](#enum-scanreportmode)|否|Normal|**命名参数。** 扫描结果数据上报模式，默认值为Normal。|

## class ScanResult

```cangjie
public class ScanResult {
    public var deviceId: String
    public var rssi: Int32
    public var data: Array<Byte>
    public var deviceName: String
    public var connectable: Bool
}
```

**功能：** 扫描到符合过滤条件的广播报文后，上报的扫描数据。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var connectable

```cangjie
public var connectable: Bool
```

**功能：** 扫描到的设备是否可连接。true表示可连接，false表示不可连接。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var data

```cangjie
public var data: Array<Byte>
```

**功能：** 扫描到的设备发送的广播报文内容。

**类型：** Array\<Byte>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var deviceId

```cangjie
public var deviceId: String
```

**功能：** 扫描到的蓝牙设备地址。例如："XX:XX:XX:XX:XX:XX"。

基于信息安全考虑，此处获取的设备地址为虚拟MAC地址。

- 若和该设备地址配对成功后，该地址不会变更。

- 若该设备重启蓝牙开关，重新获取到的虚拟地址会立即变更。

- 若取消配对，蓝牙子系统会根据该地址的实际使用情况，决策后续变更时机；若其他应用正在使用该地址，则不会立刻变更。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var deviceName

```cangjie
public var deviceName: String
```

**功能：** 扫描到的设备名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var rssi

```cangjie
public var rssi: Int32
```

**功能：** 扫描到的设备信号强度，单位：dBm。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

## class ServerResponse

```cangjie
public class ServerResponse {
    public var deviceId: String
    public var transId: Int32
    public var status: Int32
    public var offset: Int32
    public var value: Array<Byte>
    public init(
        deviceId: String,
        transId: Int32,
        status: Int32,
        offset: Int32,
        value: Array<Byte>
    )
}
```

**功能：** 描述server端回复client端读或者写请求的响应参数结构。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var deviceId

```cangjie
public var deviceId: String
```

**功能：** client端蓝牙设备地址。例如："XX:XX:XX:XX:XX:XX"。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var offset

```cangjie
public var offset: Int32
```

**功能：** client端读或者写请求的数据偏移值，与订阅client端读或者写请求事件携带的offset保持一致。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var status

```cangjie
public var status: Int32
```

**功能：** 响应的状态，设置为0即可，表示正常。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var transId

```cangjie
public var transId: Int32
```

**功能：** 收到client端请求的标识符，与订阅client端读或者写请求事件携带的transId保持一致。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var value

```cangjie
public var value: Array<Byte>
```

**功能：** 回复的数据。

**类型：** Array\<Byte>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### init(String, Int32, Int32, Int32, Array\<Byte>)

```cangjie
public init(
    deviceId: String,
    transId: Int32,
    status: Int32,
    offset: Int32,
    value: Array<Byte>
)
```

**功能：** 描述server端回复client端读/写请求的响应参数类。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|deviceId|String|是|-|client端蓝牙设备地址。例如："XX:XX:XX:XX:XX:XX"。|
|transId|Int32|是|-|收到client端请求的标识符，与订阅client端读或者写请求事件携带的transId保持一致。|
|status|Int32|是|-|响应的状态，设置为0即可，表示正常。|
|offset|Int32|是|-|client端读或者写请求的数据偏移值，与订阅client端读或者写请求事件携带的offset保持一致。|
|value|Array\<Byte>|是|-|回复的数据。|

## class ServiceData

```cangjie
public class ServiceData {
    public var serviceUUID: String
    public var serviceValue: Array<Byte>
    public init(
        serviceUUID: String,
        serviceValue: Array<Byte>
    )
}
```

**功能：** 描述BLE广播报文中的服务数据内容。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceUUID

```cangjie
public var serviceUUID: String
```

**功能：** 服务UUID。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### var serviceValue

```cangjie
public var serviceValue: Array<Byte>
```

**功能：** 服务数据。

**类型：** Array\<Byte>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### init(String, Array\<Byte>)

```cangjie
public init(
    serviceUUID: String,
    serviceValue: Array<Byte>
)
```

**功能：** 描述广播包中服务数据内容。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|serviceUUID|String|是|-|服务UUID。|
|serviceValue|Array\<Byte>|是|-|服务数据。|

## enum AdvertisingState

```cangjie
public enum AdvertisingState <: Equatable<AdvertisingState> & ToString {
    | Started
    | Enabled
    | Disabled
    | Stopped
    | ...
}
```

**功能：** 枚举，不同操作对应的BLE广播状态。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<AdvertisingState>
- ToString

### Disabled

```cangjie
Disabled
```

**功能：** 广播停止成功。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### Enabled

```cangjie
Enabled
```

**功能：** 广播启动成功。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### Started

```cangjie
Started
```

**功能：** 调用[startAdvertising](#func-startadvertisingadvertisingparams)方法后，广播首次启动成功，且会分配相关资源。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### Stopped

```cangjie
Stopped
```

**功能：** 调用[stopAdvertising](#func-stopadvertisinguint32)方法后，广播停止成功，且会释放首次启动广播时分配的相关资源。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(AdvertisingState)

```cangjie
public operator func !=(other: AdvertisingState): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AdvertisingState](#enum-advertisingstate)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(AdvertisingState)

```cangjie
public operator func ==(other: AdvertisingState): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[AdvertisingState](#enum-advertisingstate)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum BluetoothBleCallbackType

```cangjie
public enum BluetoothBleCallbackType <: Equatable<BluetoothBleCallbackType> & Hashable & ToString {
    | AdvertisingStateChange
    | BleDeviceFind
    | ...
}
```

**功能：** 广播扫描订阅事件类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<BluetoothBleCallbackType>
- Hashable
- ToString

### AdvertisingStateChange

```cangjie
AdvertisingStateChange
```

**功能：** 表示广播状态事件类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### BleDeviceFind

```cangjie
BleDeviceFind
```

**功能：** 表示BLE设备发现事件类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(BluetoothBleCallbackType)

```cangjie
public operator func !=(other: BluetoothBleCallbackType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BluetoothBleCallbackType](#enum-bluetoothblecallbacktype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(BluetoothBleCallbackType)

```cangjie
public operator func ==(other: BluetoothBleCallbackType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BluetoothBleCallbackType](#enum-bluetoothblecallbacktype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func hashCode()

```cangjie
public func hashCode(): Int64
```

**功能：** 获取枚举值的哈希值。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Int64|枚举值的哈希值。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举值的字符串表达。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举值的字符串表达。|

## enum BluetoothBleGattClientDeviceCallbackType

```cangjie
public enum BluetoothBleGattClientDeviceCallbackType <: Equatable<BluetoothBleGattClientDeviceCallbackType> & Hashable & ToString {
    | BleCharacteristicChange
    | BleConnectionStateChange
    | ClientBleMtuChange
    | ...
}
```

**功能：** 客户端 on/off 事件的类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<BluetoothBleGattClientDeviceCallbackType>
- Hashable
- ToString

### BleCharacteristicChange

```cangjie
BleCharacteristicChange
```

**功能：** 表示特征值变化事件类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### BleConnectionStateChange

```cangjie
BleConnectionStateChange
```

**功能：** 表示连接状态变化事件类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### ClientBleMtuChange

```cangjie
ClientBleMtuChange
```

**功能：** 表示MTU状态变化事件类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(BluetoothBleGattClientDeviceCallbackType)

```cangjie
public operator func !=(other: BluetoothBleGattClientDeviceCallbackType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BluetoothBleGattClientDeviceCallbackType](#enum-bluetoothblegattclientdevicecallbacktype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(BluetoothBleGattClientDeviceCallbackType)

```cangjie
public operator func ==(other: BluetoothBleGattClientDeviceCallbackType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BluetoothBleGattClientDeviceCallbackType](#enum-bluetoothblegattclientdevicecallbacktype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func hashCode()

```cangjie
public func hashCode(): Int64
```

**功能：** 获取输入数据的哈希值。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

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

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum BluetoothBleGattServerCallbackType

```cangjie
public enum BluetoothBleGattServerCallbackType <: Equatable<BluetoothBleGattServerCallbackType> & Hashable & ToString {
    | CharacteristicRead
    | CharacteristicWrite
    | DescriptorRead
    | DescriptorWrite
    | ConnectionStateChange
    | ServerBleMtuChange
    | ...
}
```

**功能：** 服务端 on/off 事件的类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<BluetoothBleGattServerCallbackType>
- Hashable
- ToString

### CharacteristicRead

```cangjie
CharacteristicRead
```

**功能：** 表示特征值读请求事件类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### CharacteristicWrite

```cangjie
CharacteristicWrite
```

**功能：** 表示特征值写请求事件类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### ConnectionStateChange

```cangjie
ConnectionStateChange
```

**功能：** 表示BLE连接状态变化事件类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### DescriptorRead

```cangjie
DescriptorRead
```

**功能：** 表示描述符读请求事件类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### DescriptorWrite

```cangjie
DescriptorWrite
```

**功能：** 表示描述符写请求事件类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### ServerBleMtuChange

```cangjie
ServerBleMtuChange
```

**功能：** 表示MTU状态变化事件类型。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(BluetoothBleGattServerCallbackType)

```cangjie
public operator func !=(other: BluetoothBleGattServerCallbackType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BluetoothBleGattServerCallbackType](#enum-bluetoothblegattservercallbacktype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(BluetoothBleGattServerCallbackType)

```cangjie
public operator func ==(other: BluetoothBleGattServerCallbackType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BluetoothBleGattServerCallbackType](#enum-bluetoothblegattservercallbacktype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func hashCode()

```cangjie
public func hashCode(): Int64
```

**功能：** 获取输入数据的哈希值。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

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

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum GattWriteType

```cangjie
public enum GattWriteType <: Equatable<GattWriteType> & ToString {
    | Write
    | WriteNoResponse
    | ...
}
```

**功能：** 枚举，写入特征值的方式（不同的取值，对端蓝牙设备的表现不一样）。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<GattWriteType>
- ToString

### Write

```cangjie
Write
```

**功能：** 写入特征值后，对端蓝牙设备需要回复确认。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### WriteNoResponse

```cangjie
WriteNoResponse
```

**功能：** 写入特征值后，对端蓝牙设备不需要回复。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(GattWriteType)

```cangjie
public operator func !=(other: GattWriteType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[GattWriteType](#enum-gattwritetype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(GattWriteType)

```cangjie
public operator func ==(other: GattWriteType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[GattWriteType](#enum-gattwritetype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum MatchMode

```cangjie
public enum MatchMode <: Equatable<MatchMode> & ToString {
    | MatchModeAggressive
    | MatchModeSticky
    | ...
}
```

**功能：** 枚举，硬件过滤匹配模式。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<MatchMode>
- ToString

### MatchModeAggressive

```cangjie
MatchModeAggressive
```

**功能：** 当广播报文信号强度较低或者短时间内广播报文的发送次数较少时，可以更快地上报。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### MatchModeSticky

```cangjie
MatchModeSticky
```

**功能：** 广播报文信号强度较高或者短时间内广播报文的发送次数较多时，才会上报。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(MatchMode)

```cangjie
public operator func !=(other: MatchMode): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MatchMode](#enum-matchmode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(MatchMode)

```cangjie
public operator func ==(other: MatchMode): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MatchMode](#enum-matchmode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum PhyType

```cangjie
public enum PhyType <: Equatable<PhyType> & ToString {
    | PhyLe1M
    | PhyLeAllSupported
    | ...
}
```

**功能：** 枚举，指定扫描过程中接收BLE广播报文的物理通道。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<PhyType>
- ToString

### PhyLe1M

```cangjie
PhyLe1M
```

**功能：** 使用1M PHY类型扫描。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### PhyLeAllSupported

```cangjie
PhyLeAllSupported
```

**功能：** 使用所有支持的PHY类型扫描。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(PhyType)

```cangjie
public operator func !=(other: PhyType): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PhyType](#enum-phytype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(PhyType)

```cangjie
public operator func ==(other: PhyType): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[PhyType](#enum-phytype)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum ScanDuty

```cangjie
public enum ScanDuty <: Equatable<ScanDuty> & ToString {
    | ScanModeLowPower
    | ScanModeBalanced
    | ScanModeLowLatency
    | ...
}
```

**功能：** 枚举，扫描模式，表示不同的扫描性能和功耗情况。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<ScanDuty>
- ToString

### ScanModeBalanced

```cangjie
ScanModeBalanced
```

**功能：** 均衡模式，平衡扫描性能和功耗。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### ScanModeLowLatency

```cangjie
ScanModeLowLatency
```

**功能：** 低延迟模式，扫描性能较高，但功耗也较高。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### ScanModeLowPower

```cangjie
ScanModeLowPower
```

**功能：** 低功耗模式，扫描性能较低，功耗也较低。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(ScanDuty)

```cangjie
public operator func !=(other: ScanDuty): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScanDuty](#enum-scanduty)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(ScanDuty)

```cangjie
public operator func ==(other: ScanDuty): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScanDuty](#enum-scanduty)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|

## enum ScanReportMode

```cangjie
public enum ScanReportMode <: Equatable<ScanReportMode> & ToString {
    | Normal
    | Batch
    | FenceSensitivityLow
    | FenceSensitivityHigh
    | ...
}
```

**功能：** 枚举，扫描结果上报模式。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<ScanReportMode>
- ToString

### Batch

```cangjie
Batch
```

**功能：** 批量扫描上报模式。

- 该模式可通过降低蓝牙芯片上报扫描结果频率，使系统更长时间地保持在休眠状态，从而降低整机功耗。

- 该模式下，扫描到符合过滤条件的BLE广播报文后不会立刻上报，需要缓存一段时间（[ScanOptions](#class-scanoptions)中的interval字段）后上报。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### FenceSensitivityHigh

```cangjie
FenceSensitivityHigh
```

**功能：** 高灵敏度围栏上报模式。

- 围栏模式表示只在广播进入或离开围栏时上报。

- 扫描到的广播信号强度低且广播数量少时，可进入高灵敏度围栏。

- 首次扫描到广播即进入围栏，触发一次上报。

- 一段时间内扫描不到广播即离开围栏，触发一次上报。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### FenceSensitivityLow

```cangjie
FenceSensitivityLow
```

**功能：** 低灵敏度围栏上报模式。

- 围栏模式表示只在广播进入或离开围栏时上报。

- 扫描到的广播信号强度高且广播数量多时，可进入低灵敏度围栏。

- 首次扫描到广播即进入围栏，触发一次上报。

- 一段时间内扫描不到广播即离开围栏，触发一次上报。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### Normal

```cangjie
Normal
```

**功能：** 常规扫描上报模式，扫描到符合过滤条件的BLE广播报文后就会立刻上报。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(ScanReportMode)

```cangjie
public operator func !=(other: ScanReportMode): Bool
```

**功能：** 对扫描上报模式进行判不等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScanReportMode](#enum-scanreportmode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果扫描结果数据上报模式不同，返回true，否则返回false。|

### func ==(ScanReportMode)

```cangjie
public operator func ==(other: ScanReportMode): Bool
```

**功能：** 对扫描上报模式进行判等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ScanReportMode](#enum-scanreportmode)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果扫描结果数据上报模式相同，返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取扫描结果数据上报模式的字符串表示。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|扫描结果数据上报模式的字符串表示。|
