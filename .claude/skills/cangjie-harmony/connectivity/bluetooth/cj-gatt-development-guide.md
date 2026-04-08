# 连接和传输数据

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 简介

本指南主要提供了基于通用属性协议（Generic Attribute Profile，GATT）实现BLE设备间连接和传输数据的开发指导。当两个设备间进行GATT通信交互时，依据设备功能的不同，可区分为GATT客户端和GATT服务端，本指南将分别介绍客户端与服务端的实现方法。

GATT是低功耗蓝牙（BLE）的核心协议，定义了基于服务（Service）、特征值（Characteristic）和描述符（Descriptor）进行蓝牙通信和传输数据的机制。相关术语介绍请参考[Connectivity Kit术语](../cj-terminology.md)。

## 实现原理

客户端获取到服务端的设备地址后，即可向服务端发起连接。服务端设备地址可以通过BLE扫描流程获取。待两端连接成功后，即可向服务端发起服务查询、读写特征值和接收通知等操作，从而实现向服务端发送数据或者接收服务端数据的功能。

服务端需要发送BLE广播才能被客户端发现。服务端需要支持客户端需要连接的服务，等待客户端的连接请求即可。待两端连接成功后，即可接收客户端的读写特征值和发送通知等操作，从而实现接收客户端数据或者向客户端发送数据的功能。

客户端的BLE扫描和服务端的BLE广播流程，请参考[查找设备](cj-ble-development-guide.md)。

## 开发步骤

### 申请蓝牙权限

需要申请权限ohos.permission.ACCESS_BLUETOOTH。如何配置和申请权限，请参考[声明权限](../../security/AccessToken/cj-declare-permissions.md)和[向用户申请授权](../../security/AccessToken/cj-request-user-authorization.md)。

### 导入所需API模块

**1. 创建客户端实例**

客户端通过查找设备流程搜索到目标设备后，即可构造客户端实例，后续所有操作都基于该客户端实例。

- 导入模块。

<!-- compile -->

```cangjie
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
```

- 构造客户端实例。

```cangjie
// 此处是伪代码
let device = 'XX:XX:XX:XX:XX:XX'

try {
    let device: GattClientDevice = createGattClientDevice(device)  // 请替换为您的设备地址
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

**2. 订阅连接状态变化事件**

通过订阅连接状态变化事件，可以获取实时的GATT连接状态。整个连接过程会涉及多种状态的跃迁，其中[StateConnected](../../reference/ConnectivityKit/cj-apis-bluetooth-constant.md#stateconnected)表示已连接，[StateDisconnected](../../reference/ConnectivityKit/cj-apis-bluetooth-constant.md#statedisconnected)表示已断连。

- 导入模块。

<!-- compile -->

```cangjie
import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
```

- 订阅连接状态变化事件。

```cangjie
// 此处是伪代码
let device = 'XX:XX:XX:XX:XX:XX'

class BLEConnectionStateChangeCallback <: Callback1Argument<BleConnectionChangeState> {
    public func invoke(err: ?BusinessException, stateInfo: BleConnectionChangeState): Unit {
        let connectState = stateInfo.state
    }
}

let bleConnectionStateChangeCallback = BLEConnectionStateChangeCallback()
try {
    let gattClient = createGattClientDevice(device)
    gattClient.on(BluetoothBleGattClientDeviceCallbackType.BleConnectionStateChange, bleConnectionStateChangeCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

**3. 发起连接**

通过创建的客户端实例，直接发起连接即可。通过连接状态变化事件判断是否已连接成功。

- 导入模块。

<!-- compile -->

```cangjie
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
```

- 发起连接。

```cangjie
// 此处是伪代码
let device = 'XX:XX:XX:XX:XX:XX'

try {
    let gattClient = createGattClientDevice(device)
    gattClient.connect()
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

**4. 服务发现**

服务发现是获取服务端支持的所有服务能力集合的过程。客户端需要根据服务发现结果，判断服务端是否存在应用需要的服务能力。

- 后续的读写特征值、读写描述符等操作都需要在服务发现操作完成后进行，否则会失败。
- 后续的读写等操作中指定的特征值或描述符必须包含在服务能力集合中，否则会失败。

- 导入模块。

<!-- compile -->

```cangjie
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
```

- 服务发现。

```cangjie
// 此处是伪代码
let device = 'XX:XX:XX:XX:XX:XX'

try {
    let gattClient = createGattClientDevice(device)
    // 此处是伪代码，需要连接上后，才可以调用
    let services = gattClient.getServices{err: ?BusinessException, c: ?Array<GattService> =>
        Hilog.info(0, "Bluetooth", "getServices successfully")
    }
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

**5. 传输数据**

传输数据通过操作服务端的特征值或者描述符实现。

**5.1 读取或写入特征值**

读取特征值操作，可以获取服务端特征值的数据内容。

写入特征值操作，可以更新服务端特征值的数据内容。

相关API请参考[readCharacteristicValue](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-readcharacteristicvalueblecharacteristic-asynccallbackblecharacteristic)和[writeCharacteristicValue](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-writecharacteristicvalueblecharacteristic-gattwritetype-asynccallbackunit)。

- 导入模块。

<!-- compile -->

```cangjie
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.*
```

- 读取或写入特征值。

```cangjie
// 此处是伪代码
let device = 'XX:XX:XX:XX:XX:XX'
let bufferDesc: Array<Byte> = [11, 0]
let descriptor = BleDescriptor(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    "00002902-0000-1000-8000-00805F9B34FB",
    bufferDesc
)
let descriptors: Array<BleDescriptor> = [descriptor]
let bufferCCC: Array<Byte> = [1, 0]
let characteristic: BleCharacteristic = BleCharacteristic(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    bufferCCC,
    descriptors
)

var gattClient: ?GattClientDevice = None
try {
    gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}

// 读取特征值
try {
    gattClient?.readCharacteristicValue(characteristic) {
        error: ?BusinessException, outData: ?BleCharacteristic =>
    }
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}

// 写入特征值
try {
    gattClient?.writeCharacteristicValue(characteristic, GattWriteType.Write) {
        error: ?BusinessException, c: ?Unit => if (let Some(e) <- error) {
            Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
        }
        Hilog.info(0, "Bluetooth", "writeCharacteristicValue success")
    }
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

**5.2 读取或写入描述符**

读取描述符操作，可以获取服务端描述符的数据内容。

写入描述符操作，可以更新服务端描述符的数据内容。

相关API请参考[readDescriptorValue](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-readdescriptorvaluebledescriptor-asynccallbackbledescriptor)和[writeDescriptorValue](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-writedescriptorvaluebledescriptor-asynccallbackunit)。

- 导入模块。

<!-- compile -->

```cangjie
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.*
```

- 读取或写入描述符。

```cangjie
// 此处是伪代码
let device = 'XX:XX:XX:XX:XX:XX'
let bufferDesc: Array<Byte> = [11, 0]
let descriptor = BleDescriptor(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    "00002903-0000-1000-8000-00805F9B34FB",
    bufferDesc
)

var gattClient: ?GattClientDevice = None
try {
    gattClient = createGattClientDevice("XX:XX:XX:XX:XX:XX")
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}

// 读取描述符
try {
    gattClient?.readDescriptorValue(descriptor) {
        error: ?BusinessException, outDescriptor: ?BleDescriptor =>
    }
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}

// 写入描述符
try {
    gattClient?.writeDescriptorValue(descriptor) {
        error: ?BusinessException, c: ?Unit => if (let Some(e) <- error) {
            Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
        }
    }
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

**5.3 接收服务端特征值变化通知或指示**

当服务端特征值的数据内容发生变化时，客户端可以通过接收服务端的特征值变化通知或者指示来实现更新数据。该服务端特征值需包含蓝牙标准协议定义的Client Characteristic Configuration描述符UUID（00002902-0000-1000-8000-00805f9b34fb），才能支持通知或者指示能力。

客户端收到服务端通知时，不需要回复确认；客户端收到服务端指示时，需要回复确认，蓝牙子系统会实现该操作，应用无需关注。

- 先订阅服务端特征值变化事件，详情请见[on(BleCharacteristicChange)](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-onbluetoothblegattclientdevicecallbacktype-callback1argumentblecharacteristic)。
- 再使能服务端特征值变化通知或者指示能力，应用根据实际场景选择一种方式即可。相关API请参考[setCharacteristicChangeNotification](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-setcharacteristicchangenotificationblecharacteristic-bool-asynccallbackunit)和[setCharacteristicChangeIndication](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-setcharacteristicchangeindicationblecharacteristic-bool-asynccallbackunit)。

- 导入模块。

<!-- compile -->

```cangjie
import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
```

- 接收服务端特征值变化通知或指示。

```cangjie
// 此处是伪代码
let device = 'XX:XX:XX:XX:XX:XX'

// 定义服务端特征值变化事件
class BLECharacteristicChangeCallback <: Callback1Argument<BleCharacteristic> {
    public func invoke(err: ?BusinessException, characteristic: BleCharacteristic): Unit {
        Hilog.info(0, "Bluetooth", "characteristic has change")
    }
}

let arrayBuffer: Array<Byte> = [11, 0]
let descriptor = BleDescriptor(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    "00002902-0000-1000-8000-00805F9B34FB",
    arrayBuffer
)
let descriptors: Array<BleDescriptor> = [descriptor]
let arrayBufferC: Array<Byte> = [0, 0]
let characteristic: BleCharacteristic = BleCharacteristic(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    arrayBufferC,
    descriptors
)

var gattClient: ?GattClientDevice = None
try {
    gattClient = createGattClientDevice(device)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}

// 发起订阅
let bleCharacteristicChangeCallback = BLECharacteristicChangeCallback()
try {
    gattClient?.on(BluetoothBleGattClientDeviceCallbackType.BleCharacteristicChange, bleCharacteristicChangeCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}

// 通知和指示，2选1即可
// 设置特征值变化通知能力
try {
  // enable入参: true表示启用，false表示禁用
    gattClient?.setCharacteristicChangeNotification(characteristic, true) {
        error: ?BusinessException, c: ?Unit => if (let Some(e) <- error) {
            Hilog.info(0, "Bluetooth", "setCharacteristicChangeNotification callback failed")
        } else {
            Hilog.info(0, "Bluetooth", "setCharacteristicChangeNotification callback successful")
        }
    }
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}

// 设置特征值变化指示能力
try {
  // enable入参: true表示启用，false表示禁用
    gattClient?.setCharacteristicChangeIndication(characteristic, true)  {
        error: ?BusinessException, c: ?Unit => if (let Some(e) <- error) {
            Hilog.info(0, "Bluetooth", "setCharacteristicChangeIndication callback failed")
        } else {
            Hilog.info(0, "Bluetooth", "setCharacteristicChangeIndication callback successful")
        }
    }
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

### 服务端

**1. 创建服务端实例**

构造服务端实例，后续所有操作都基于该服务端实例。

- 导入模块。

<!-- compile -->

```cangjie
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException
```

- 创建服务端实例。

```cangjie
try {
    let gattServer: GattServer = createGattServer()
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

**2. 添加服务**

添加应用需要的服务，将在蓝牙子系统中注册指定的UUID服务。客户端会发起服务查询，判断服务端是否支持特定的服务。

- 导入模块。

<!-- compile -->

```cangjie
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException
```

- 添加服务。

```cangjie
// 创建descriptors
let arrayBuffer: Array<Byte> = [11, 0]
let descriptor = BleDescriptor(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    "00002902-0000-1000-8000-00805F9B34FB",
    arrayBuffer
)
let descriptors: Array<BleDescriptor> = [descriptor]

// 创建characteristics
let arrayBufferC: Array<Byte> = [1, 0]
let characteristic: BleCharacteristic = BleCharacteristic(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    arrayBufferC,
    descriptors
)
let characteristics: Array<BleCharacteristic> = [characteristic]

// 创建gattService
let gattService: GattService = GattService(
    "00001810-0000-1000-8000-00805F9B34FB",
    true,
    characteristics,
    includeServices: []
)

try {
    let gattServer = createGattServer()
    gattServer.addService(gattService)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}", "")
}
```

**3. 订阅连接状态变化事件**

通过订阅连接状态变化事件，可以获取实时的GATT连接状态以及客户端的设备地址。整个连接过程涉及多种状态的跃迁，其中[StateConnected](../../reference/ConnectivityKit/cj-apis-bluetooth-constant.md#stateconnected)表示已连接，[StateDisconnected](../../reference/ConnectivityKit/cj-apis-bluetooth-constant.md#statedisconnected)表示已断连。

- 导入模块。

<!-- compile -->

```cangjie
import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
```

- 订阅连接状态变化事件。

```cangjie
class StateChangeCallback <: Callback1Argument<BleConnectionChangeState> {
    public func invoke(err: ?BusinessException, state: BleConnectionChangeState): Unit {
        Hilog.info(0, "Bluetooth", "bluetooth connect state changed")
    }
}

let stateChangeCallback = StateChangeCallback()
try {
    let gattServer = createGattServer()
    gattServer.on(BluetoothBleGattServerCallbackType.ConnectionStateChange, stateChangeCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

**4. 传输数据**

传输数据可以通过客户端读写特征值数据内容、读写描述符数据内容、主动发送特征值数据内容变化通知或指示实现。

**4.1 订阅特征值读取或写入事件**

通过订阅特征值读取或写入事件，获取客户端的操作请求，相关API请参考[on(CharacteristicRead)](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-onbluetoothblegattservercallbacktype-callback1argumentcharacteristicreadrequest)和[on('characteristicWrite')](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-onbluetoothblegattservercallbacktype-callback1argumentcharacteristicwriterequest)。

- 收到读取特征值请求时，需要调用[sendResponse](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-sendresponseserverresponse)进行回复对应特征值的数据内容。
- 收到写入特征值请求时，可保存客户端写入的特征值数据内容。根据写入请求[CharacteristicWriteRequest](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#class-characteristicwriterequest)的needRsp判断是否需要调用[sendResponse](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-sendresponseserverresponse)进行回复。

- 导入模块。

<!-- compile -->

```cangjie
import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
```

- 订阅特征值读取或写入事件。

```cangjie
let gattServer = createGattServer()
let arrayBufferCCC: Array<Byte> = [1, 0]

// 定义特征值读取回调函数
class CharacteristicReadCallback <: Callback1Argument<CharacteristicReadRequest> {
    public func invoke(err: ?BusinessException, charReq: CharacteristicReadRequest): Unit {
        let deviceId: String = charReq.deviceId
        let transId: Int32 = charReq.transId
        let offset: Int32 = charReq.offset
        let serverResponse: ServerResponse = ServerResponse(
            deviceId,
            transId,
            0,
            offset,
            arrayBufferCCC // 传入服务端对应特征值的数据内容，此处是伪代码
        )

        try {
            gattServer.sendResponse(serverResponse)
        } catch (e: BusinessException) {
            Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
        }
    }
}

// 定义特征值写入回调函数
class CharacteristicWriteCallback <: Callback1Argument<CharacteristicWriteRequest> {
    public func invoke(err: ?BusinessException, charReq: CharacteristicWriteRequest): Unit {
        let deviceId: String = charReq.deviceId
        let transId: Int32 = charReq.transId
        let offset: Int32 = charReq.offset
        if (!charReq.needRsp) { // 判断是否需要回复客户端
            return
        }
        let value: Array<UInt8> = charReq.value
        arrayBufferCCC[0] = value[0]
        let serverResponse: ServerResponse = ServerResponse(
            deviceId,
            transId,
            0,
            offset,
            arrayBufferCCC
        )

        try {
            gattServer.sendResponse(serverResponse)
        } catch (e: BusinessException) {
            Hilog.info(0, "Bluetooth", "gattServer send response fail because ${e}")
        }
    }
}

// 订阅特征值读取事件
let characteristicReadCallback = CharacteristicReadCallback()
try {
    gattServer.on(BluetoothBleGattServerCallbackType.CharacteristicRead, characteristicReadCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}

// 订阅特征值写入事件
let characteristicWriteCallback = CharacteristicWriteCallback()
try {
    gattServer.on(BluetoothBleGattServerCallbackType.CharacteristicWrite, characteristicWriteCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

**4.2 订阅描述符读取或写入事件**

通过订阅描述符读取或写入事件，获取客户端的操作请求，相关API请参考[on(DescriptorRead)](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-onbluetoothblegattservercallbacktype-callback1argumentdescriptorreadrequest)和[on(DescriptorWrite)](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-onbluetoothblegattservercallbacktype-callback1argumentdescriptorwriterequest)。

- 收到读取描述符请求时，需要调用[sendResponse](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-sendresponseserverresponse)进行回复对应描述符的数据内容。
- 收到写入描述符请求时，可保存客户端写入的描述符数据内容。根据写入请求[DescriptorWriteRequest](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#class-descriptorwriterequest)的needRsp判断是否需要调用[sendResponse](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-sendresponseserverresponse)进行回复。

- 导入模块。

<!-- compile -->

```cangjie
import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
```

- 订阅描述符读取或写入事件。

```cangjie
let gattServer = createGattServer()
let arrayBufferCCC: Array<Byte> = [1, 0]

// 定义描述符读取回调函数
class DescriptorReadCallback <: Callback1Argument<DescriptorReadRequest> {
    public func invoke(err: ?BusinessException, desReq: DescriptorReadRequest): Unit {
        let deviceId: String = desReq.deviceId
        let transId: Int32 = desReq.transId
        let offset: Int32 = desReq.offset
        let serverResponse: ServerResponse = ServerResponse(
            deviceId,
            transId,
            0,
            offset,
            arrayBufferCCC
        )
        try {
            gattServer.sendResponse(serverResponse)
        } catch (e: BusinessException) {
            Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
        }
    }
}

// 定义描述符写入回调函数
class DescriptorWriteCallback <: Callback1Argument<DescriptorWriteRequest> {
    public func invoke(err: ?BusinessException, desReq: DescriptorWriteRequest): Unit {
        let deviceId: String = desReq.deviceId
        let transId: Int32 = desReq.transId
        let offset: Int32 = desReq.offset
        if (!desReq.needRsp) { // 判断是否需要回复客户端
            return
        }
        let value: Array<UInt8> = desReq.value
        arrayBufferCCC[0] = value[0]
        let serverResponse: ServerResponse = ServerResponse(
            deviceId,
            transId,
            0,
            offset,
            arrayBufferCCC
        )
        try {
            gattServer.sendResponse(serverResponse)
        } catch (e: BusinessException) {
            Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
        }
    }
}

// 订阅描述符读取事件
let descriptorReadCallback = DescriptorReadCallback()
try {
    gattServer.on(BluetoothBleGattServerCallbackType.DescriptorRead, descriptorReadCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}

// 订阅描述符写入事件
let descriptorWriteCallback = DescriptorWriteCallback()
try {
    gattServer.on(BluetoothBleGattServerCallbackType.DescriptorWrite, descriptorWriteCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

**4.3 发送特征值变化通知或指示**

当服务端的特征值数据内容发生变化时，可以通过通知或者指示主动知会到客户端，相关API请参考[notifyCharacteristicChanged](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-notifycharacteristicchangedstring-notifycharacteristic)。

发送通知时，不需要客户端回复确认；发送指示时，需要客户端回复确认。应用根据[NotifyCharacteristic](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#class-notifycharacteristic)的confirm参数决定发送哪种类型。

- 该特征值需包含蓝牙标准协议定义的Client Characteristic Configuration描述符UUID（00002902-0000-1000-8000-00805f9b34fb），才支持通知或者指示能力。
- 使用通知或者指示能力需要使能。客户端可以通过[setCharacteristicChangeNotification](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-setcharacteristicchangenotificationblecharacteristic-bool-asynccallbackunit)或[setCharacteristicChangeIndication](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md#func-setcharacteristicchangeindicationblecharacteristic-bool-asynccallbackunit)。使能该能力，应用根据实际场景选择一种方式即可。

- 导入模块。

<!-- compile -->

```cangjie
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
```

- 发送特征值变化通知或指示。

```cangjie
let device = 'XX:XX:XX:XX:XX:XX'; // 该设备地址表示客户端地址，可以通过连接状态变化事件中获取
let arrayBufferC: Array<Byte> = [0, 0]
let notifyCharacteristic = NotifyCharacteristic(
    "00001810-0000-1000-8000-00805F9B34FB",
    "00001820-0000-1000-8000-00805F9B34FB",
    arrayBufferC,
    true // 决定发送通知还是指示
)
try {
  let gattServer = createGattServer()
  // 发送变更通知或指示
  gattServer.notifyCharacteristicChanged("XX:XX:XX:XX:XX:XX", notifyCharacteristic) 
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

**5. 关闭服务端实例**

当应用不再需要创建的服务端实例时，需要主动关闭，并释放相关资源。例如：删除已添加的服务，取消已订阅事件。

- 导入模块。

<!-- compile -->

```cangjie
import ohos.business_exception.*
import kit.ConnectivityKit.*
import kit.PerformanceAnalysisKit.Hilog
```

- 关闭服务端实例。

```cangjie
try {
    let gattServer = createGattServer()
    gattServer.removeService("00001810-0000-1000-8000-00805F9B34FB") // 删除此前注册的服务
    gattServer.close() // 应用不再使用此gattServer，则需要close
} catch (e: BusinessException) {
    Hilog.info(0, "Bluetooth", "errCode: ${e.code}, errMessage: ${e.message}")
}
```

## 完整示例

### 客户端

```cangjie
import kit.ConnectivityKit.*
import ohos.business_exception.BusinessException
import ohos.callback_invoke.Callback1Argument
import kit.PerformanceAnalysisKit.Hilog

const TAG: String = 'GattClientManager'

class GattClientManager {
    var device: ?String = None<String>
    var gattClient: ?GattClientDevice = None<GattClientDevice>
    var connectState: ProfileConnectionState = ProfileConnectionState.StateDisconnected
    let myServiceUuid: String = '00001810-0000-1000-8000-00805F9B34FB'
    let myCharacteristicUuid: String = '00001820-0000-1000-8000-00805F9B34FB'
    // 标准协议描述符Client Characteristic Configuration，用于特征值变化通知或指示
    let myFirstDescriptorUuid: String = '00002902-0000-1000-8000-00805F9B34FB'
    // 自定义描述符
    let mySecondDescriptorUuid: String = '00002903-0000-1000-8000-00805F9B34FB'
    var found: Bool = false

    var myService: ?GattService = None<GattService>
    var myCharacteristic: ?BleCharacteristic = None<BleCharacteristic>
    var myFirstDescriptor: ?BleDescriptor = None<BleDescriptor>
    var mySecondDescriptor: ?BleDescriptor = None<BleDescriptor>

    var foundService: Bool = false
    var foundChar: Bool = false
    var foundFirstDes: Bool = false
    var foundSecondDes: Bool = false

    // 构造BLEDescriptor
    private func initDescriptor(des: String, value: Array<Byte>): BleDescriptor {
        let descriptor: BleDescriptor = BleDescriptor(
            this.myServiceUuid,
            this.myCharacteristicUuid,
            des,
            value
        )
        return descriptor
    }

    // 构造BLECharacteristic
    private func initCharacteristic(isWrite: Bool): BleCharacteristic {
        let charBuffer: Array<UInt8> = if (isWrite) {
            [21, 22]
        } else {
            [0, 0]
        }
        let characteristic: BleCharacteristic = BleCharacteristic(
            this.myServiceUuid,
            this.myCharacteristicUuid,
            charBuffer,
            []
        )
        return characteristic
    }

    private func logCharacteristic(char: BleCharacteristic) {
        var message = 'logCharacteristic uuid:' + char.characteristicUUID + ', value: '
        let value = char.characteristicValue
        message += 'logCharacteristic value: '
        for (i in 0..value.size) {
            message += value[i].toString() + ' '
        }
        Hilog.info(1, TAG, message)
    }

    private func logDescriptor(des: BleDescriptor) {
        var message = 'logDescriptor uuid:' + des.descriptorUUID + ', value: '
        let value = des.descriptorValue
        message += 'logDescriptor value: '
        for (i in 0..value.size) {
            message += value[i].toString() + ' '
        }
        Hilog.info(1, TAG, message)
    }

    private func checkService(services: Array<GattService>) {
        for (i in 0..services.size) {
            if (services[i].serviceUUID != this.myServiceUuid) {
                continue
            }
            this.myService = services[i]
            this.foundService = true
            for (j in 0..services[i].characteristics.size) {
                if (services[i].characteristics[j].characteristicUUID != this.myCharacteristicUuid) {
                    continue
                }
                this.logCharacteristic(services[i].characteristics[j])
                this.myCharacteristic = services[i].characteristics[j]
                this.foundChar = true
                for (k in 0..services[i].characteristics[j].descriptors.size) {
                    if (services[i].characteristics[j].descriptors[k].descriptorUUID == this.myFirstDescriptorUuid) {
                        this.myFirstDescriptor= services[i].characteristics[j].descriptors[k]
                        this.foundFirstDes = true
                        continue
                    }
                    if (services[i].characteristics[j].descriptors[k].descriptorUUID == this.mySecondDescriptorUuid) {
                        this.mySecondDescriptor = services[i].characteristics[j].descriptors[k]
                        this.foundSecondDes = true
                        continue
                    }
                }
            }
        }
        Hilog.error(1, TAG, 'foundService: ${this.foundService}, foundChar: ${this.foundChar}, foundFirDes: ${this.foundFirstDes}, foundSecDes: ${this.foundSecondDes}')
    }

    // 2. client端主动连接时调用
    public func startConnect(peerDevice: String) { // 对端设备一般通过ble scan获取到
        // 1. 定义连接状态变化回调函数
        let onGattClientStateChange = BLEConnectionStateChangeCallback(){
            err, stateInfo =>
            Hilog.info(0, TAG, "onGattServerStateChange: device=" + stateInfo.deviceId + ", state=" + stateInfo.state.toString())
            if (stateInfo.deviceId == this.device.getOrThrow()) {
                this.connectState = stateInfo.state
            }
        }
        if (this.connectState != ProfileConnectionState.StateDisconnected) {
            Hilog.error(1, TAG, 'startConnect failed')
            return
        }
        Hilog.info(1, TAG, 'startConnect ' + peerDevice)
        this.device = peerDevice
        // 2.1 使用device构造gattClient，后续的交互都需要使用该实例
        this.gattClient = createGattClientDevice(peerDevice)
        try {
            // 2.2 订阅连接状态
            this.gattClient?.on(BluetoothBleGattClientDeviceCallbackType.BleConnectionStateChange, onGattClientStateChange)

            // 2.3 发起连接
            this.gattClient?.connect() // 2.3 发起连接
        } catch (e: BusinessException) {
            Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
        }
    }

    // 3. client端连接成功后，需要进行服务发现
    public func discoverServices() {
        if (this.gattClient.isNone()) {
            Hilog.info(1, TAG, 'no gattClient')
            return
        }
        Hilog.info(1, TAG, 'discoverServices')
        try {
            let result = this.gattClient?.getServices(){
                error: ?BusinessException, result: ?Array<GattService> =>
                if (let Some(e) <- error) {
                    throw e
                }
                this.checkService(result.getOrThrow()) // 要确保server端的服务内容有业务所需要的服务
            }
            if (let Some(v) <- this.myService) {
                Hilog.error(1, TAG, 'Service: ${v.serviceUUID}')
            }
            if (let Some(v) <- this.myCharacteristic) {
                this.logCharacteristic(v)
            }
            if (let Some(v) <- this.myFirstDescriptor) {
                this.logDescriptor(v)
            }
            if (let Some(v) <- this.mySecondDescriptor) {
                this.logDescriptor(v)
            }
        } catch (e: BusinessException) {
            Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
        }
    }

    // 4. 在确保拿到了server端的服务结果后，读取server端特定服务的特征值时调用
    public func readCharacteristicValue() {
        if (this.gattClient.isNone() || this.connectState != ProfileConnectionState.StateConnected) {
            Hilog.error(1, TAG, 'gattClient does not exist or state not connected')
            return
        }
        if (!this.found) { // 要确保server端有对应的characteristic
            Hilog.error(1, TAG, 'server characteristic does not exist')
            return
        }

        let characteristic = this.initCharacteristic(false)
        Hilog.info(1, TAG, 'readCharacteristicValue')
        try {
            this.gattClient?.readCharacteristicValue(characteristic) {
                    e, outData => 
                    this.myCharacteristic = outData
                    this.logCharacteristic(outData.getOrThrow())
                }
        } catch (e: BusinessException) {
            Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
        }
    }

    // 5. 在确保拿到了server端的服务结果后，写入server端特定服务的特征值时调用
    public func writeCharacteristicValue() {
        if (this.gattClient.isNone() || this.connectState != ProfileConnectionState.StateConnected) {
            Hilog.error(1, TAG, 'gattClient does not exist or state not connected')
            return
        }
        if (!this.found) { // 要确保server端有对应的characteristic
            Hilog.error(1, TAG, 'server characteristic does not exist')
            return
        }

        let characteristic = this.initCharacteristic(true)
        Hilog.info(1, TAG, 'writeCharacteristicValue')
        try {
            this.gattClient?.writeCharacteristicValue(characteristic, GattWriteType.Write) {
                    err, unit =>
                    if (let Some(e) <- err) {
                        Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
                        return
                    }
                    Hilog.info(1, TAG, 'writeCharacteristicValue success')
                }
        } catch (e: BusinessException) {
            Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
        }
    }

    // 6. 在确保拿到了server端的服务结果后，读取server端特定服务的描述符时调用
    public func readDescriptorValue() {
        if (this.gattClient.isNone() || this.connectState != ProfileConnectionState.StateConnected) {
            Hilog.error(1, TAG, 'gattClient does not exist or state not connected')
            return
        }
        if (!this.found) { // 要确保server端有对应的descriptor
            Hilog.error(1, TAG, 'server descriptor does not exist')
            return
        }

        let descBuffer = Array<Byte>()
        let descriptor = this.initDescriptor(this.mySecondDescriptorUuid, descBuffer)
        Hilog.info(1, TAG, 'readDescriptorValue')
        try {
            this.gattClient?.readDescriptorValue(descriptor) {
                e, outData => this.logDescriptor(outData.getOrThrow())
            }
        } catch (e: BusinessException) {
            Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
        }
    }

    // 7. 在确保拿到了server端的服务结果后，写入server端特定服务的描述符时调用
    public func writeDescriptorValue() {
        if (this.gattClient.isNone() || this.connectState != ProfileConnectionState.StateConnected) {
            Hilog.error(1, TAG, 'gattClient does not exist or state not connected')
            return
        }
        if (!this.found) { // 要确保server端有对应的descriptor
            Hilog.error(1, TAG, 'server descriptor does not exist')
            return
        }

        let descBuffer: Array<UInt8> = [41, 42]
        let descriptor = this.initDescriptor(this.mySecondDescriptorUuid, descBuffer)
        Hilog.info(1, TAG, 'writeDescriptorValue')
        try {
            this.gattClient?.writeDescriptorValue(descriptor) {
                    err, unit =>
                    if (let Some(e) <- err) {
                        Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
                        return
                    }
                    Hilog.info(1, TAG, 'writeDescriptorValue success')
                }
        } catch (e: BusinessException) {
            Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
        }
    }

    // 9. 使能或禁用接收服务端端特征值内容变更通知的能力时调用，一般通知或者指示，二选一
    public func Notify(enable: Bool) {
        // 8. 定义特征值变化回调函数
        let onCharacteristicChange = BLECharacteristicChangeCallback(){
            err, char =>
            Hilog.error(1, TAG, 'onCharacteristicChange: uuid: ' + char.characteristicUUID + ', value: ${char.characteristicValue}')
            this.myCharacteristic = char
            this.logCharacteristic(char)
        }
        if (this.gattClient.isNone() || this.connectState != ProfileConnectionState.StateConnected) {
            Hilog.error(1, TAG, 'gattClient does not exist or state not connected')
            return
        }

        if (this.foundFirstDes) { // 要确保server端有对应的client configuration descriptor
            Hilog.error(1, TAG, 'server client configuration descriptor does not exist')
            return;
        }

        Hilog.error(1, TAG, 'Notify ${this.device} enable: ${enable}')
        try {
            // 订阅特征值变化
            this.gattClient?.on(BleCharacteristicChange, onCharacteristicChange)
            // 设置特征值变化通知能力，enable: true表示启用，false表示禁用
            this.gattClient?.setCharacteristicChangeNotification(this.myCharacteristic.getOrThrow(), enable) {
                error: ?BusinessException, c: ?Unit => 
                if (let Some(e) <- error) {
                    Hilog.error(1, TAG, 'setCharacteristicChangeNotification callback failed')
                } else {
                    Hilog.error(1, TAG, 'setCharacteristicChangeNotification callback successful')
                }
            }
        } catch (e: BusinessException) {
            Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
        }
    }

    // 10. 使能或禁用接收服务端端特征值内容变更指示的能力时调用，一般通知或者指示，二选一
    public func Indicate(enable: Bool) {
        let onCharacteristicChange = BLECharacteristicChangeCallback(){
            err, char =>
            Hilog.error(1, TAG, 'onCharacteristicChange: uuid: ' + char.characteristicUUID + ', value: ${char.characteristicValue}')
            this.myCharacteristic = char
            this.logCharacteristic(char)
        }
        if (this.gattClient.isNone() || this.connectState != ProfileConnectionState.StateConnected) {
            Hilog.error(1, TAG, 'gattClient does not exist or state not connected')
            return
        }

        if (this.foundFirstDes) { // 要确保server端有对应的client configuration descriptor
            Hilog.error(1, TAG, 'server client configuration descriptor does not exist')
            return;
        }

        Hilog.error(1, TAG, 'Indicate ${this.device} enable: ${enable}')
        try {
            // 订阅特征值变化
            this.gattClient?.on(BleCharacteristicChange, onCharacteristicChange)
            // 设置特征值变化指示能力，enable: true表示启用，false表示禁用
            this.gattClient?.setCharacteristicChangeIndication(this.myCharacteristic.getOrThrow(), enable) {
                error: ?BusinessException, c: ?Unit => 
                if (let Some(e) <- error) {
                    Hilog.error(1, TAG, 'setCharacteristicChangeIndication callback failed')
                } else {
                    Hilog.error(1, TAG, 'setCharacteristicChangeIndication callback successful')
                }
            }
        } catch (e: BusinessException) {
            Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
        }
    }

    // 11.client端主动断开时调用
    public func stopConnect() {
        if (this.gattClient.isNone() || this.connectState != ProfileConnectionState.StateConnected) {
            Hilog.error(1, TAG, 'gattClient does not exist or state not connected')
            return
        }

        Hilog.info(1, TAG, 'stopConnect ' + this.device.getOrThrow())
        try {
            this.gattClient?.disconnect() // 11.1 断开连接
            this.gattClient?.off(BluetoothBleGattClientDeviceCallbackType.BleConnectionStateChange) // 11.2 取消订阅连接状态
            this.gattClient?.close() // 8.2 如果不再使用此gattClient，则需要close
        } catch (e: BusinessException) {
            Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
        }
    }
}

class BLEConnectionStateChangeCallback <: Callback1Argument<BleConnectionChangeState> {
    let callback: (?BusinessException, BleConnectionChangeState) -> Unit
    public init(callback: (?BusinessException, BleConnectionChangeState) -> Unit){
        this.callback = callback
    }
    public func invoke(err: ?BusinessException, stateInfo: BleConnectionChangeState): Unit {
        callback(err, stateInfo)
    }
}

class BLECharacteristicChangeCallback <: Callback1Argument<BleCharacteristic> {
    let callback: (?BusinessException, BleCharacteristic) -> Unit
    public init(callback: (?BusinessException, BleCharacteristic) -> Unit){
        this.callback = callback
    }
    public func invoke(err: ?BusinessException, char: BleCharacteristic): Unit {
        callback(err, char)
    }
}

let gattClientManager = GattClientManager()
```

### 服务端

```cangjie
import kit.ConnectivityKit.*
import ohos.business_exception.BusinessException
import ohos.callback_invoke.Callback1Argument
import kit.PerformanceAnalysisKit.Hilog
import std.collection.ArrayList

const TAG: String = 'GattServerManager'

class GattServerManager {
    var device: String = ""
    public var gattServer: ?GattServer = None
    var connectState: ProfileConnectionState = ProfileConnectionState.StateDisconnected
    let myServiceUuid: String = '00001810-0000-1000-8000-00805F9B34FB'
    let myCharacteristicUuid: String = '00001820-0000-1000-8000-00805F9B34FB'
    // 标准协议描述符Client Characteristic Configuration，用于特征值变化通知或指示
    let myFirstDescriptorUuid: String = '00002902-0000-1000-8000-00805F9B34FB'
    // 自定义描述符
    let mySecondDescriptorUuid: String = '00002903-0000-1000-8000-00805F9B34FB'

    var charBuffer: Array<UInt8> = Array<UInt8>(2, repeat: 0)
    var firDescBuffer: Array<UInt8> = Array<UInt8>(2, repeat: 0)
    var secDescBuffer: Array<UInt8> = Array<UInt8>(2, repeat: 0)

    // 构造BLEDescriptor
    private func initDescriptor(des: String, value: Array<Byte>): BleDescriptor {
        let descriptor: BleDescriptor = BleDescriptor(
            this.myServiceUuid,
            this.myCharacteristicUuid,
            des,
            value
        )
        return descriptor
    }

    // 构造BLECharacteristic
    private func initCharacteristic(): BleCharacteristic {
        secDescBuffer = [31, 32]
        let descriptors: Array<BleDescriptor> = [initDescriptor(this.myFirstDescriptorUuid, firDescBuffer),
            initDescriptor(this.mySecondDescriptorUuid, secDescBuffer)] // 默认Client Characteristic Configuration描述符没有使能特征值变化通知或者指示能力
        charBuffer = [1, 2]
        let characteristic: BleCharacteristic = BleCharacteristic(
            this.myServiceUuid,
            this.myCharacteristicUuid,
            charBuffer,
            descriptors
        )
        return characteristic
    }

    // 1. 定义连接状态变化回调函数
    let onGattServerStateChange = BLEConnectionStateChangeCallback(){
        err, stateInfo =>
        Hilog.info(0, TAG, "onGattServerStateChange: device=" + stateInfo.deviceId + ", state=" + stateInfo.state.toString())
    }

    // 2. 定义读取特征值请求回调函数
    var onCharacteristicRead: ?ReadRequestCb = None 

    // 检查client configuration descriptor的通知能力是否使能
    private func checkDescriptorNotification(buffer: Array<UInt8>): Bool {
        let notifyValue: Array<UInt8> = [1, 0] // 使能client configuration descriptor notification的值
        return notifyValue == buffer
    }

    // 检查client configuration descriptor的指示能力是否使能
    private func checkDescriptorIndication(buffer: Array<UInt8>): Bool {
        let notifyValue: Array<UInt8> = [2, 0] // 使能client configuration descriptor indication的值
        return notifyValue == buffer
    }

    // 3. 定义写入特征值请求回调函数
    var onCharacteristicWrite: ?WriteRequestCb = None

    // 4. 定义读取描述符请求回调函数
    var onDescriptorRead: ?DescriptorReadRequestCb = None

    // 5. 定义写入描述符请求回调函数
    var onDescriptorWrite: ?DescriptorWriteRequestCb = None

    // 6. server端注册服务时调用
    public func registerServer() {
        onCharacteristicRead = ReadRequestCb() {
            err, charReq =>
            let deviceId: String = charReq.deviceId
            let transId: Int32 = charReq.transId
            let offset: Int32 = charReq.offset
            Hilog.info(1, TAG, 'receive characteristicRead: uuid: ${charReq.characteristicUUID}, value: ${this.charBuffer}')
            let serverResponse: ServerResponse = ServerResponse(
                deviceId,
                transId,
                0, // 0表示成功
                offset,
                this.charBuffer
            )

            try {
                this.gattServer?.sendResponse(serverResponse)
            } catch (e: BusinessException) {
                Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
            }
        }
        onCharacteristicWrite = WriteRequestCb() {
            err, charReq =>
            let deviceId: String = charReq.deviceId
            let transId: Int32 = charReq.transId
            let offset: Int32 = charReq.offset
            this.charBuffer = charReq.value
            Hilog.info(1, TAG, 'receive characteristicWrite: uuid: ${charReq.characteristicUUID}, value: ${this.charBuffer}')
            if (!charReq.needRsp) {
                return
            }
            let rspBuffer: Array<UInt8> = [0]
            let serverResponse: ServerResponse = ServerResponse(
                deviceId,
                transId,
                0, // 0表示成功
                offset,
                rspBuffer
            )

            try {
                this.gattServer?.sendResponse(serverResponse)
                this.sendCharacterChange() // 此处特征值变化了，模拟主动发送变化通知或者指示
            } catch (e: BusinessException) {
                Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
            }
        }
        let characteristics: ArrayList<BleCharacteristic> = ArrayList<BleCharacteristic>()
        let characteristic = this.initCharacteristic()
        characteristics.add(characteristic)
        let gattService: GattService = GattService(
            this.myServiceUuid,
            true,
            characteristics.toArray()
        )
        onDescriptorRead = DescriptorReadRequestCb(){
            err, desReq =>
            let deviceId: String = desReq.deviceId
            let transId: Int32 = desReq.transId
            let offset: Int32 = desReq.offset
            let tmpBuffer = if (desReq.descriptorUUID == this.myFirstDescriptorUuid) {
                this.firDescBuffer
            } else {
                this.secDescBuffer
            }
            Hilog.info(1, TAG, 'receive descriptorRead: ${desReq.descriptorUUID}, tmpValue: ${tmpBuffer}')
            let serverResponse: ServerResponse = ServerResponse(
                deviceId,
                transId,
                0, // 0表示成功
                offset,
                tmpBuffer
            )

            try {
                this.gattServer?.sendResponse(serverResponse)
            } catch (e: BusinessException) {
                Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
            }
        }
        onDescriptorWrite = DescriptorWriteRequestCb(){
            err, desReq =>
            let deviceId: String = desReq.deviceId
            let transId: Int32 = desReq.transId
            let offset: Int32 = desReq.offset
            Hilog.info(1, TAG, 'receive descriptorWrite: uuid: ${desReq.descriptorUUID}, needRsp: ${desReq.needRsp}, value: ${desReq.value}')
            if (desReq.descriptorUUID == this.myFirstDescriptorUuid) {
                this.firDescBuffer = desReq.value
            } else {
                this.secDescBuffer = desReq.value
            }
            if (!desReq.needRsp) {
                return
            }
            let rspBuffer: Array<UInt8> = [0]
            let serverResponse: ServerResponse = ServerResponse(
                deviceId,
                transId,
                0, // 0表示成功
                offset,
                rspBuffer
            )

            try {
                this.gattServer?.sendResponse(serverResponse)
            } catch (e: BusinessException) {
                Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
            }
        }
        Hilog.info(1, TAG, 'registerServer ' + this.myServiceUuid)
        try {
            this.gattServer = createGattServer() // 6.1 构造gattServer，后续的交互都需要使用该实例
            this.gattServer?.addService(gattService) // 6.2 注册服务
            this.gattServer?.on(BluetoothBleGattServerCallbackType.ConnectionStateChange, this.onGattServerStateChange) // 6.3 订阅连接状态
            this.gattServer?.on(CharacteristicRead, this.onCharacteristicRead.getOrThrow()) // 6.4 订阅特征值读事件
            this.gattServer?.on(CharacteristicWrite, this.onCharacteristicWrite.getOrThrow()) // 6.5 订阅特征值读事件
            this.gattServer?.on(DescriptorRead, this.onDescriptorRead.getOrThrow()) // 6.6 订阅特征值读事件
            this.gattServer?.on(DescriptorWrite, this.onDescriptorWrite.getOrThrow()) // 6.7 订阅特征值读事件
        } catch (e: BusinessException) {
            Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
        }
    }

  // 7. 特征值内容发生变化时调用
  public func sendCharacterChange() {
    Hilog.info(1, TAG, 'sendCharacterChange: uuid: ${this.myCharacteristicUuid}, value: ${charBuffer}')
    if (this.checkDescriptorNotification(this.firDescBuffer)) {
        let notifyCharacter = NotifyCharacteristic(
            this.myServiceUuid,
            this.myCharacteristicUuid,
            this.charBuffer,
            false
        )
        Hilog.info(1, TAG, 'sendCharacterChange notification')
        this.gattServer?.notifyCharacteristicChanged(this.device, notifyCharacter)
    } else if (this.checkDescriptorIndication(this.firDescBuffer)) {
        let notifyCharacter = NotifyCharacteristic(
            "00001810-0000-1000-8000-00805F9B34FB",
            "00001820-0000-1000-8000-00805F9B34FB",
            this.charBuffer,
            true
        )
        Hilog.info(1, TAG, 'sendCharacterChange indication')
        this.gattServer?.notifyCharacteristicChanged(this.device, notifyCharacter)
    } else {
        Hilog.info(1, TAG, 'notification/indication is disabled')
    }
  }

    // 8. server端删除服务，不再使用时调用
    public func unRegisterServer() {
        if (this.gattServer.isNone()) {
            Hilog.error(1, TAG, 'no gattServer')
            return
        }

        Hilog.info(1, TAG, 'unRegisterServer ' + this.myServiceUuid)
        try {
            this.gattServer?.removeService(this.myServiceUuid) // 8.1 删除服务
            this.gattServer?.off(BluetoothBleGattServerCallbackType.ConnectionStateChange) // 8.2 取消订阅连接状态
            this.gattServer?.off(CharacteristicRead, callback: this.onCharacteristicRead.getOrThrow()) // 8.3 取消订阅特征值读事件
            this.gattServer?.off(CharacteristicWrite, callback: this.onCharacteristicWrite.getOrThrow()) // 8.4 取消订阅特征值读事件
            this.gattServer?.off(DescriptorRead, callback: this.onDescriptorRead.getOrThrow()) // 8.5 取消订阅特征值读事件
            this.gattServer?.off(DescriptorWrite, callback: this.onDescriptorWrite.getOrThrow()) // 8.6 取消订阅特征值读事件
            this.gattServer?.close() // 8.7 如果应用不再使用此gattServer，则需要close
        } catch (e: BusinessException) {
            Hilog.error(1, TAG, 'errCode: ${e.code}, errMessage: ${e.message}')
        }
    }
}

class BLEConnectionStateChangeCallback <: Callback1Argument<BleConnectionChangeState> {
    let callback: (?BusinessException, BleConnectionChangeState) -> Unit
    public init(callback: (?BusinessException, BleConnectionChangeState) -> Unit){
        this.callback = callback
    }
    public func invoke(err: ?BusinessException, stateInfo: BleConnectionChangeState): Unit {
        callback(err, stateInfo)
    }
}

class ReadRequestCb <: Callback1Argument<CharacteristicReadRequest> {
    let callback: (?BusinessException, CharacteristicReadRequest) -> Unit
    public init(callback: (?BusinessException, CharacteristicReadRequest) -> Unit){
        this.callback = callback
    }
    public func invoke(err: ?BusinessException, charReq: CharacteristicReadRequest): Unit {
        callback(err, charReq)
    }
}

class WriteRequestCb <: Callback1Argument<CharacteristicWriteRequest> {
    let callback: (?BusinessException, CharacteristicWriteRequest) -> Unit
    public init(callback: (?BusinessException, CharacteristicWriteRequest) -> Unit){
        this.callback = callback
    }
    public func invoke(err: ?BusinessException, charReq: CharacteristicWriteRequest): Unit {
        callback(err, charReq)
    }
}

class DescriptorReadRequestCb <: Callback1Argument<DescriptorReadRequest> {
    let callback: (?BusinessException, DescriptorReadRequest) -> Unit
    public init(callback: (?BusinessException, DescriptorReadRequest) -> Unit){
        this.callback = callback
    }
    public func invoke(err: ?BusinessException, desReq: DescriptorReadRequest): Unit {
        callback(err, desReq)
    }
}

class DescriptorWriteRequestCb <: Callback1Argument<DescriptorWriteRequest> {
    let callback: (?BusinessException, DescriptorWriteRequest) -> Unit
    public init(callback: (?BusinessException, DescriptorWriteRequest) -> Unit){
        this.callback = callback
    }
    public func invoke(err: ?BusinessException, desReq: DescriptorWriteRequest): Unit {
        callback(err, desReq)
    }
}

let gattServerManager = GattServerManager()
```
