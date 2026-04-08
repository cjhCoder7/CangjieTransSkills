# 查找设备

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 简介

本指南主要提供了BLE扫描和BLE广播相关操作的开发指导。可以实现发现周边BLE设备和其他设备发现本机设备的场景。

## 开发步骤

### 申请蓝牙权限

需要申请权限ohos.permission.ACCESS_BLUETOOTH。如何配置和申请权限，请参考[声明权限](../../security/AccessToken/cj-declare-permissions.md)和[向用户申请授权](../../security/AccessToken/cj-request-user-authorization.md)。

## 场景介绍

主要场景有：

- 开启、关闭广播
- 开启、关闭扫描

## 接口说明

完整的仓颉 API 说明以及实例代码请参见：[BLE 接口](../../reference/ConnectivityKit/cj-apis-bluetooth-ble.md)。

具体接口说明如下表。

| 接口名 | 功能描述 |
| ---------------------------------- | -----------------------------------------------|
| startBleScanning() | 发起BLE扫描流程。 |
| stopBleScanning() | 停止BLE扫描流程。 |
| startAdvertising() | 开始发送BLE广播。 |
| stopAdvertising() | 停止发送BLE广播。 |
| on(eventType: BluetoothBleCallbackType) | 订阅BLE广播状态。 |
| off(eventType: BluetoothBleCallbackType) | 取消订阅BLE广播状态。 |
| on(eventType: BluetoothBleCallbackType) | 订阅BLE设备发现上报事件。 |
| off(eventType: BluetoothBleCallbackType) | 取消订阅BLE设备发现上报事件。  |

## 主要场景开发步骤

### 开启、关闭广播

1. import需要的ble模块。
2. 开启设备的蓝牙。
3. 需要SystemCapability.Communication.Bluetooth.Core系统能力。
4. 开启广播，对端设备扫描该广播。
5. 关闭广播。
6. 示例代码：

    <!-- compile -->

    ```cangjie
    import kit.ConnectivityKit.*
    import ohos.callback_invoke.*
    import ohos.business_exception.*
    import kit.PerformanceAnalysisKit.Hilog

    let TAG: String = 'BleAdvertisingManager'

    class BleAdvertisingManager {
        private var advHandle: UInt32 = 0xFF // default invalid value

        // 1 订阅广播状态
        public func onAdvertisingStateChange() {
            try {
                on(BluetoothBleCallbackType.AdvertisingStateChange, StateChangeInfoCb())
            } catch (e: BusinessException) {
                Hilog.error(0x0000, 'Tag', 'errCode: ${e.code}, errMessage: ' + e.message)
            }
        }

        // 2 首次启动广播
        public func startAdvertising() {
            // 2.1 设置广播发送的参数
            let setting: AdvertiseSetting = AdvertiseSetting(interval:160, txPower:0, connectable:true)
            // 2.2 构造广播数据
            let manufactureValueBuffer: Array<UInt8> = [1, 2, 3, 4]
            let serviceValueBuffer: Array<UInt8> = [5, 6, 7, 8]
            let manufactureDataUnit: ManufactureData = ManufactureData(4567, manufactureValueBuffer)
            let serviceDataUnit: ServiceData = ServiceData("00001888-0000-1000-8000-00805f9b34fb", serviceValueBuffer)
            let advData: AdvertiseData = AdvertiseData(["00001888-0000-1000-8000-00805f9b34fb"], [manufactureDataUnit],
                [serviceDataUnit], includeDeviceName: false // 表示是否携带设备名，可选参数。注意带上设备名时广播包长度不能超出31个字节。
                )
            let advResponse: AdvertiseData = AdvertiseData(["00001888-0000-1000-8000-00805f9b34fb"], [manufactureDataUnit],
                [serviceDataUnit])
            // 2.3 构造广播启动完整参数AdvertisingParams
            let advertisingParams: AdvertisingParams = AdvertisingParams(
                setting,
                advData,
                advertisingResponse: advResponse,
                duration: 0 // 可选参数，若大于0，则广播发送一段时间后，则会临时停止，可重新启动发送
            )

            // 2.4 首次启动广播，且获取所启动广播的标识ID
            try {
                this.onAdvertisingStateChange()
                this.advHandle = startAdvertising(advertisingParams)
            } catch (e: BusinessException) {
                Hilog.error(0x0000, 'Tag', 'errCode: ${e.code}, errMessage: ' + e.message)
            }
        }

        // 3 完全关闭广播，释放广播资源
        public func stopAdvertising() {
            try {
                stopAdvertising(this.advHandle)
                off(BluetoothBleCallbackType.AdvertisingStateChange)
            } catch (e: BusinessException) {
                Hilog.error(0x0000, 'Tag', 'errCode: ${e.code}, errMessage: ' + e.message)
            }
        }
    }

    class StateChangeInfoCb <: Callback1Argument<AdvertisingStateChangeInfo> {
        public func invoke(err: ?BusinessException, info: AdvertisingStateChangeInfo): Unit {
            Hilog.info(0xFF00, 'Tag', "advertisingId: ${info.advertisingId}, AdvertisingState: ${info.state}")
        }
    }

    let bleAdvertisingManager = BleAdvertisingManager()
    ```

7. 错误码请参见[蓝牙服务子系统错误码](../../reference/ConnectivityKit/cj-errorcode-bluetooth_manager.md)。

### 开启、关闭扫描

1. import需要的ble模块。
2. 开启设备的蓝牙。
3. 需要SystemCapability.Communication.Bluetooth.Core系统能力。
4. 对端设备开启广播。
5. 本端设备开启扫描，获取扫描结果。
6. 关闭扫描。
7. 示例代码:

    <!-- compile -->

    ```cangjie
    import kit.ConnectivityKit.*
    import ohos.callback_invoke.*
    import ohos.business_exception.*
    import std.collection.{HashMap, ArrayList}
    import std.math.numeric.BigInt
    import kit.PerformanceAnalysisKit.Hilog

    const BLE_ADV_TYPE_FLAG = 0x01
    const BLE_ADV_TYPE_16_BIT_SERVICE_UUIDS_INCOMPLETE = 0x02
    const BLE_ADV_TYPE_16_BIT_SERVICE_UUIDS_COMPLETE = 0x03
    const BLE_ADV_TYPE_32_BIT_SERVICE_UUIDS_INCOMPLETE = 0x04
    const BLE_ADV_TYPE_32_BIT_SERVICE_UUIDS_COMPLETE = 0x05
    const BLE_ADV_TYPE_128_BIT_SERVICE_UUIDS_INCOMPLETE = 0x06
    const BLE_ADV_TYPE_128_BIT_SERVICE_UUIDS_COMPLETE = 0x07
    const BLE_ADV_TYPE_LOCAL_NAME_SHORT = 0x08
    const BLE_ADV_TYPE_LOCAL_NAME_COMPLETE = 0x09
    const BLE_ADV_TYPE_TX_POWER_LEVEL = 0x0A
    const BLE_ADV_TYPE_16_BIT_SERVICE_SOLICITATION_UUIDS = 0x14
    const BLE_ADV_TYPE_128_BIT_SERVICE_SOLICITATION_UUIDS = 0x15
    const BLE_ADV_TYPE_32_BIT_SERVICE_SOLICITATION_UUIDS = 0x1F
    const BLE_ADV_TYPE_16_BIT_SERVICE_DATA = 0x16
    const BLE_ADV_TYPE_32_BIT_SERVICE_DATA = 0x20
    const BLE_ADV_TYPE_128_BIT_SERVICE_DATA = 0x21
    const BLE_ADV_TYPE_MANUFACTURER_SPECIFIC_DATA = 0xFF
    const BLUETOOTH_UUID_16_BIT_LENGTH: UInt8 = 2
    const BLUETOOTH_UUID_32_BIT_LENGTH: UInt8 = 4
    const BLUETOOTH_UUID_128_BIT_LENGTH: UInt8 = 16
    const BLUETOOTH_MANUFACTURE_ID_LENGTH: UInt8 = 2

    class BleScanManager {
        // 1 订阅扫描结果
        public func onScanResult() {
            on(BluetoothBleCallbackType.BleDeviceFind, ScanResultCb())
        }

        // 2 开启扫描
        public func startScan() {
            // 2.1 构造扫描过滤器，需要能够匹配预期的广播包内容
            let manufactureId: UInt16 = 4567
            let manufactureData: Array<UInt8> = [1, 2, 3, 4]
            let manufactureDataMask: Array<UInt8> = [0xFF, 0xFF, 0xFF, 0xFF]
            var scanFilter: ScanFilter = ScanFilter() // 根据业务实际情况定义过滤器
            scanFilter.manufactureId = manufactureId
            scanFilter.manufactureData = manufactureData
            scanFilter.manufactureDataMask = manufactureDataMask

            // 2.2 构造扫描参数
            let scanOptions: ScanOptions = ScanOptions(
                interval: 0,
                dutyMode: ScanDuty.ScanModeLowPower,
                matchMode: MatchMode.MatchModeAggressive,
                phyType: PhyType.PhyLe1M
            )
            try {
                this.onScanResult() // 订阅扫描结果
                startBleScanning([scanFilter], options: scanOptions)
                Hilog.info(0xFF00, 'Tag', 'startBleScan success')
            } catch (e: BusinessException) {
                Hilog.error(0x0000, 'Tag', 'errCode: ${e.code}, errMessage: ' + e.message)
            }
        }

        // 3 关闭扫描
        public func stopScan() {
            try {
                off(BluetoothBleCallbackType.BleDeviceFind) // 取消订阅扫描结果
                stopBleScanning()
                Hilog.info(0xFF00, 'Tag', 'stopBleScan success')
            } catch (e: BusinessException) {
                Hilog.error(0x0000, 'Tag', 'errCode: ${e.code}, errMessage: ' + e.message)
            }
        }
    }

    private func parseScanResult(data: Array<UInt8>) {
        if (data.size == 0) {
            Hilog.warn(0xFF00, 'Tag', 'nothing, adv data length is 0')
            return
        }
        Hilog.info(0xFF00, 'Tag', 'data: ' + String.fromUtf8(data))

        var advFlags: UInt8 = 0
        var txPowerLevel: UInt8 = 0
        var localName: String = ""
        var serviceUuids: ArrayList<String> = ArrayList<String>()
        var serviceSolicitationUuids: ArrayList<String> = ArrayList<String>()
        var serviceDatas: HashMap<String, Array<UInt8>> = HashMap()
        var manufactureSpecificDatas: HashMap<UInt16, Array<UInt8>> = HashMap()

        var curPos = 0
        while (curPos < data.size) {
            let length = data[curPos]
            curPos++
            if (length == 0) {
                break
            }
            let dataLength = length - 1
            let dataType = data[curPos]
            curPos++
            match (dataType) {
                case BLE_ADV_TYPE_FLAG => advFlags = data[curPos]
                case BLE_ADV_TYPE_LOCAL_NAME_SHORT => localName = data[curPos..curPos + Int64(dataLength)].toString()
                case BLE_ADV_TYPE_LOCAL_NAME_COMPLETE => localName = data[curPos..curPos + Int64(dataLength)].toString()
                case BLE_ADV_TYPE_TX_POWER_LEVEL => txPowerLevel = data[curPos]
                case BLE_ADV_TYPE_16_BIT_SERVICE_UUIDS_INCOMPLETE => parseServiceUuid(BLUETOOTH_UUID_16_BIT_LENGTH, curPos,
                    dataLength, data, serviceUuids)
                case BLE_ADV_TYPE_16_BIT_SERVICE_UUIDS_COMPLETE => parseServiceUuid(BLUETOOTH_UUID_16_BIT_LENGTH, curPos,
                    dataLength, data, serviceUuids)
                case BLE_ADV_TYPE_32_BIT_SERVICE_UUIDS_INCOMPLETE => parseServiceUuid(BLUETOOTH_UUID_32_BIT_LENGTH, curPos,
                    dataLength, data, serviceUuids)
                case BLE_ADV_TYPE_32_BIT_SERVICE_UUIDS_COMPLETE => parseServiceUuid(BLUETOOTH_UUID_32_BIT_LENGTH, curPos,
                    dataLength, data, serviceUuids)
                case BLE_ADV_TYPE_128_BIT_SERVICE_UUIDS_INCOMPLETE => parseServiceUuid(BLUETOOTH_UUID_128_BIT_LENGTH, curPos,
                    dataLength, data, serviceUuids)
                case BLE_ADV_TYPE_128_BIT_SERVICE_UUIDS_COMPLETE => parseServiceUuid(BLUETOOTH_UUID_128_BIT_LENGTH, curPos,
                    dataLength, data, serviceUuids)
                case BLE_ADV_TYPE_16_BIT_SERVICE_SOLICITATION_UUIDS => parseServiceSolicitationUuid(
                    BLUETOOTH_UUID_16_BIT_LENGTH, curPos, dataLength, data, serviceSolicitationUuids)
                case BLE_ADV_TYPE_32_BIT_SERVICE_SOLICITATION_UUIDS => parseServiceSolicitationUuid(
                    BLUETOOTH_UUID_32_BIT_LENGTH, curPos, dataLength, data, serviceSolicitationUuids)
                case BLE_ADV_TYPE_128_BIT_SERVICE_SOLICITATION_UUIDS => parseServiceSolicitationUuid(
                    BLUETOOTH_UUID_128_BIT_LENGTH, curPos, dataLength, data, serviceSolicitationUuids)
                case BLE_ADV_TYPE_16_BIT_SERVICE_DATA => parseServiceData(BLUETOOTH_UUID_16_BIT_LENGTH, curPos, dataLength,
                    data, serviceDatas)
                case BLE_ADV_TYPE_32_BIT_SERVICE_DATA => parseServiceData(BLUETOOTH_UUID_32_BIT_LENGTH, curPos, dataLength,
                    data, serviceDatas)
                case BLE_ADV_TYPE_128_BIT_SERVICE_DATA => parseServiceData(BLUETOOTH_UUID_128_BIT_LENGTH, curPos, dataLength,
                    data, serviceDatas)
                case BLE_ADV_TYPE_MANUFACTURER_SPECIFIC_DATA => parseManufactureData(curPos, dataLength, data,
                    manufactureSpecificDatas)
                case _ => ()
            }
            curPos += Int64(dataLength)
        }
    }

    private func parseServiceUuid(uuidLength: UInt8, curPos: Int64, dataLength: UInt8, data: Array<UInt8>,
        serviceUuids: ArrayList<String>) {
        var dataLength_ = dataLength
        var curPos_ = curPos
        while (dataLength > 0) {
            let tmpData: Array<UInt8> = data.slice(curPos, Int64(uuidLength))
            serviceUuids.add(getUuidFromArray(Int64(uuidLength), tmpData))
            dataLength_ -= uuidLength
            curPos_ += Int64(uuidLength)
        }
    }

    private func parseServiceSolicitationUuid(uuidLength: UInt8, curPos: Int64, dataLength: UInt8, data: Array<UInt8>,
        serviceSolicitationUuids: ArrayList<String>) {
        var dataLength_ = dataLength
        var curPos_ = curPos
        while (dataLength > 0) {
            let tmpData: Array<UInt8> = data.slice(curPos, Int64(uuidLength))
            serviceSolicitationUuids.add(getUuidFromArray(Int64(uuidLength), tmpData))
            dataLength_ -= uuidLength
            curPos_ += Int64(uuidLength)
        }
    }

    private func getUuidFromArray(uuidLength: Int64, uuidData: Array<UInt8>): String {
        var uuid = ""
        var temp: String = ""
        for (i in uuidLength - 1..-1 : -1) {
            temp = temp + BigInt
                .parse(uuidData[i].toString())
                .toString(radix: 16)
                .padStart(2, padding: "0")
        }
        match (uuidLength) {
            case BLUETOOTH_UUID_16_BIT_LENGTH => uuid = "0000${temp}-0000-1000-8000-00805F9B34FB"
            case BLUETOOTH_UUID_32_BIT_LENGTH => uuid = "${temp}-0000-1000-8000-00805F9B34FB"
            case BLUETOOTH_UUID_128_BIT_LENGTH => uuid = "${temp[0..8]}-${temp[8..12]}-${temp[12..16]}-${temp[16..20]}-${temp[20..32]}"
            case _ => ()
        }
        return uuid
    }

    private func parseServiceData(uuidLength: UInt8, curPos: Int64, dataLength: UInt8, data: Array<UInt8>,
        serviceDatas: HashMap<String, Array<UInt8>>) {
        let tmpUuid: Array<UInt8> = data.slice(curPos, Int64(uuidLength))
        let tmpValue: Array<UInt8> = data.slice(curPos + Int64(uuidLength), Int64(dataLength - uuidLength))
        serviceDatas[tmpUuid.toString()] = tmpValue
    }

    private func parseManufactureData(curPos: Int64, dataLength: UInt8, data: Array<UInt8>,
        manufactureSpecificDatas: HashMap<UInt16, Array<UInt8>>) {
        let manufactureId: UInt16 = UInt16(data[curPos + 1]) << 8 + UInt16(data[curPos])
        let tmpValue: Array<UInt8> = data.slice(curPos + Int64(BLUETOOTH_MANUFACTURE_ID_LENGTH),
            Int64(dataLength - BLUETOOTH_MANUFACTURE_ID_LENGTH))
        manufactureSpecificDatas[manufactureId] = tmpValue
    }

    class ScanResultCb <: Callback1Argument<Array<ScanResult>> {
        public func invoke(err: ?BusinessException, data: Array<ScanResult>): Unit {
            if (data.size > 0) {
                Hilog.info(0xFF00, 'Tag', 'BLE scan result = ' + data[0].deviceId)
                parseScanResult(data[0].data)
            }
        }
    }

    let bleScanManager = BleScanManager()
    ```

8. 错误码请参见[蓝牙服务子系统错误码](../../reference/ConnectivityKit/cj-errorcode-bluetooth_manager.md)。
<!--Del-->
## 示例代码

[开启、关闭广播](https://gitcode.com/openharmony/applications_app_samples_cangjie/tree/master/code/BasicFeature/Connectivity/Broadcast)
<!--DelEnd-->
