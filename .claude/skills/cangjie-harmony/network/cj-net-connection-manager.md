# 网络连接管理

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 简介

网络连接管理提供管理网络一些基础能力，包括 WiFi、蜂窝、以太网等多网络连接优先级管理、网络质量评估、订阅默认或指定网络连接状态变化、查询网络连接信息、DNS解析等功能。

## 基本概念

- 网络生产者：数据网络的提供方。比如WiFi、蜂窝、Ethernet等。
- 网络消费者：数据网络的使用方。比如应用或系统服务。
- 网络探测：检测网络有效性，避免将网络从可用网络切换到不可用网络。内容包括绑定网络探测、DNS探测、HTTP探测及HTTPS探测。
- 网络优选：处理多网络共存时选择最优网络。在网络状态、网络信息及评分发生变化时被触发。

## 约束

开发语言：Cangjie

## 场景介绍

网络连接管理的典型场景如下所示。

- 接收指定网络的状态变化通知。
- 获取所有注册的网络。
- 根据数据网络查询网络的连接信息。
- 使用对应网络解析域名，获取所有IP。

具体开发方式介绍如下。

## 接口说明

完整的Cangjie API说明以及实例代码请参见[网络连接管理](../reference/NetworkKit/cj-apis-net-connection.md)。

| 接口名 | 描述 |
| ------------------------- | --------------------------- |
| getDefaultNet(): NetHandle | 获取一个含有默认网络的netId的NetHandle对象。 |
| getAppNet(): NetHandle  | 获取一个App绑定的包含了网络netId的NetHandle对象。 |
| setAppNet(netHandle: NetHandle): Unit | 绑定App到指定网络，绑定后的App只能通过指定网络访问外网。 |
| getDefaultNet(): NetHandle | 使用同步方法获取默认激活的数据网络。可以使用getNetCapabilities去获取网络的类型、拥有的能力等信息 |
| hasDefaultNet(): Bool | 检查默认数据网络是否被激活。  |
| getAllNets(): Array\<NetHandle> | 获取所处于连接状态的网络的NetHandle对象列表。 |
| getConnectionProperties(netHandle: NetHandle): ConnectionProperties  | 查询netHandle对应的网络的连接信息。  |
| getNetCapabilities(netHandle: NetHandle): NetCapabilities | 获取netHandle对应的网络的能力信息。 |
| isDefaultNetMetered(): Bool | 检查默认数据网络是否被激活。 |
| reportNetConnected(netHandle: NetHandle): Unit | 向网络管理报告网络处于可用状态，调用此接口说明应用程序认为网络的可用性(ohos.net.connection.NetCap.NET_CAPABILITY_VAILDATED)与网络管理不一致。 |
| reportNetDisconnected(netHandle: NetHandle): Unit | 向网络管理报告网络处于不可用状态，调用此接口说明应用程序认为网络的可用性(ohos.net.connection.NetCap.NET_CAPABILITY_VAILDATED)与网络管理不一致。 |
| getAddressesByName(host: String): Array\<NetAddress> | 使用对应网络解析域名，获取所有IP。 |
| createNetConnection(netSpecifier!: ?NetSpecifier = None, timeout!: UInt32 = 0): NetConnection | 返回一个NetConnection对象，netSpecifier指定关注的网络的各项特征。timeout是超时时间(单位：毫秒)，netSpecifier是timeout的必要条件，两者都没有则表示关注默认网络。 |
| getAddressByName(host: String): NetAddress  | 使用对应网络解析域名，获取一个IP，调用callback。 |
| on(event: NetConnectionEvent, callback: Callback1Argument\<NetHandle>): Unit | 订阅网络可用事件或网络丢失事件。 |
| on(event: NetConnectionEvent, callback: Callback1Argument\<NetCapabilityInfo>): Unit | 订阅网络能力变化事件。 |
| on(event: NetConnectionEvent, callback: Callback1Argument\<NetConnectionPropertyInfo>): Unit  | 订阅网络连接信息变化事件。 |
| on(event: NetConnectionEvent, callback: Callback1Argument\<NetBlockStatusInfo>): Unit         | 订阅网络阻塞状态事件，使用callback方式作为异步方法。 |
| on(event: NetConnectionEvent, callback: Callback0Argument): Unit  | 订阅网络不可用事件。 |
| register(): Unit | 订阅指定网络状态变化的通知。 |
| unregister(): Unit | 取消订阅默认网络状态变化的通知。 |

## 接收指定网络的状态变化通知

1. 声明接口调用所需要的权限：ohos.permission.GET_NETWORK_INFO。此权限级别为normal，在申请权限前，请确保符合[权限使用的基本原则](../security/AccessToken/cj-app-permission-mgmt-overview.md#权限使用的基本原则)。然后参考[访问控制-声明权限](../security/AccessToken/cj-declare-permissions.md)声明对应权限。

2. 从@kit.NetworkKit中导入connection。

3. 调用[createNetConnection](../reference/NetworkKit/cj-apis-net-connection.md#func-createnetconnectionnetspecifier-uint32)方法，指定网络能力、网络类型和超时时间（可选，如不传入代表默认网络；创建不同于默认网络时可通过指定这些参数完成），创建一个NetConnection对象。

4. 调用该对象的[register()](../reference/NetworkKit/cj-apis-net-connection.md#func-register)方法，订阅指定网络状态变化的通知。

5. 当网络可用时，会收到netAvailable事件的回调；当网络不可用时，会收到netUnavailable事件的回调。

6. 当不使用该网络时，可以调用该对象的[unregister()](../reference/NetworkKit/cj-apis-net-connection.md#func-unregister)方法，取消订阅。

<!-- compile -->

```cangjie
// 引入包名。
import kit.PerformanceAnalysisKit.Hilog
import kit.NetworkKit.*
import ohos.callback_invoke.*
import ohos.business_exception.*

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

func loggerError(str: String) {
    Hilog.error(0, "CangjieTest", str)
}

class NetAvailableCb <: Callback1Argument<NetHandle> {
    let callback_: (NetHandle)->Unit
    public init(callback: (NetHandle)->Unit) {callback_ = callback}
    public open func invoke(err: ?BusinessException, val: NetHandle): Unit {
        callback_(val)
    }
}

class NetUnavailableCb <: Callback0Argument {
    let callback_: ()->Unit
    public init(callback: ()->Unit) {callback_ = callback}
    public open func invoke(err: ?BusinessException): Unit {
        callback_()
    }
}

func test() {
    let netSpecifier = NetSpecifier(NetCapabilities([NetBearType.BearerCellular], networkCap: [NetCap.NetCapabilityInternet]))

    // 指定超时时间为10s(默认值为0)。
    let timeout = UInt32(10 * 1000)

    // 创建NetConnection对象。
    let conn = createNetConnection(netSpecifier: netSpecifier, timeout: timeout)

    // 订阅指定网络状态变化的通知。
    conn.register()

    // 订阅事件，如果当前指定网络可用，通过on_netAvailable通知用户。
    let netAvailableCallBack = NetAvailableCb({ netHandle =>
        loggerInfo("net is available, netId is ${netHandle.netId}")
    })
    conn.on(NetConnectionEvent.NetAvailable, netAvailableCallBack)

    // 订阅事件，如果当前指定网络不可用，通过on_netUnavailable通知用户。
    let netUnAvailableCallBack = NetUnavailableCb({=> loggerInfo("net is unavailable")})
    conn.on(NetConnectionEvent.NetUnavailable, netUnAvailableCallBack)

    // 当不使用该网络时，可以调用该对象的unregister()方法，取消订阅。
    conn.unregister()
}
```

## 监控默认网络变化并主动重建网络连接

根据当前网络状态及网络质量情况，默认网络可能会发生变化，如下所示。

1. 在WiFi弱信号的情况下，默认网络可能会切换到蜂窝网络。
2. 在蜂窝网络状态差的情况下，默认网络可能会切换到WiFi。
3. 关闭WiFi后，默认网络可能会切换到蜂窝网络。
4. 关闭蜂窝网络后，默认网络可能会切换到WiFi。
5. 在WiFi弱信号的情况下，默认网络可能会切换到其他WiFi(存在跨网情况)。
6. 在蜂窝网络状态差的情况下，默认网络可能会切换到其他蜂窝(存在跨网情况)。

本节旨在介绍监控默认网络的变化后，应用报文能够快速迁移到新默认网络上，具体做法如下。

### 监控默认网络变化

<!-- compile -->

```cangjie
import kit.PerformanceAnalysisKit.Hilog
import kit.NetworkKit.*
import ohos.callback_invoke.*
import ohos.business_exception.*

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

class NetAvailableCb <: Callback1Argument<NetHandle> {
    let callback_: (NetHandle)->Unit
    public init(callback: (NetHandle)->Unit) {callback_ = callback}
    public open func invoke(err: ?BusinessException, val: NetHandle): Unit {
        callback_(val)
    }
}

func test() {
    let netConnection = createNetConnection()
    let netAvailableCallBack = NetAvailableCb({ netHandle =>
        loggerInfo("net is available, netId is ${netHandle.netId}")
    })
    netConnection.on(NetConnectionEvent.NetAvailable, netAvailableCallBack)
}
```

## 获取所有注册的网络

1. 声明接口调用所需要的权限：ohos.permission.GET_NETWORK_INFO。此权限级别为normal，在申请权限前，请确保符合[权限使用的基本原则](../security/AccessToken/cj-app-permission-mgmt-overview.md#权限使用的基本原则)。然后参考[访问控制-声明权限](../security/AccessToken/cj-declare-permissions.md)声明对应权限。

2. 从kit.NetworkKit中导入connection。

3. 调用[getAllNets](../reference/NetworkKit/cj-apis-net-connection.md#func-getallnets)方法，获取所有处于连接状态的网络列表。

<!-- compile -->

```cangjie
// 引入包名。
import kit.NetworkKit.*

// 获取所有处于连接状态的网络列表。
let nets = getAllNets()
```

## 根据数据网络查询网络的能力信息及连接信息

1. 声明接口调用所需要的权限：ohos.permission.GET_NETWORK_INFO。此权限级别为normal，在申请权限前，请确保符合[权限使用的基本原则](../security/AccessToken/cj-app-permission-mgmt-overview.md#权限使用的基本原则)。然后参考[访问控制-声明权限](../security/AccessToken/cj-declare-permissions.md)声明对应权限。

2. 从kit.NetworkKit中导入connection。

3. 通过调用[getDefaultNet](../reference/NetworkKit/cj-apis-net-connection.md#func-getdefaultnet)方法，获取默认的数据网络(NetHandle)；或者通过调用[getAllNets](../reference/NetworkKit/cj-apis-net-connection.md#func-getallnets)方法，获取所有处于连接状态的网络列表(Array\<NetHandle>)。

4. 调用[getNetCapabilities](../reference/NetworkKit/cj-apis-net-connection.md#func-getnetcapabilitiesnethandle)方法，获取NetHandle对应网络的能力信息。能力信息包含了网络类型(蜂窝网络、Wi-Fi网络、以太网网络等)、网络具体能力等网络信息。

5. 调用[getConnectionProperties](../reference/NetworkKit/cj-apis-net-connection.md#func-getconnectionpropertiesnethandle)方法，获取NetHandle对应网络的连接信息。

<!-- compile -->

```cangjie
import kit.PerformanceAnalysisKit.Hilog
import kit.NetworkKit.*

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

func loggerError(str: String) {
    Hilog.error(0, "CangjieTest", str)
}

extend NetCap {
    public operator func ==(that: NetCap): Bool {
        match ((this, that)) {
            case (NetCapabilityMms, NetCapabilityMms) => true
            case (NetCapabilityNotMetered, NetCapabilityNotMetered) => true
            case (NetCapabilityInternet, NetCapabilityInternet) => true
            case (NetCapabilityNotVpn, NetCapabilityNotVpn) => true
            case (NetCapabilityValidated, NetCapabilityValidated) => true
            case _ => false
        }
    }
}

extend NetBearType {
    public operator func ==(that: NetBearType): Bool {
        match ((this, that)) {
            case (BearerCellular, BearerCellular) => true
            case (BearerWifi, BearerWifi) => true
            case (BearerEthernet, BearerEthernet) => true
            case _ => false
        }
    }
}

func test() {
    // 调用getDefaultNet方法，获取默认的数据网络(NetHandle)。
    let netHandle = getDefaultNet()
    if (netHandle.netId == 0) {
        // 当前无默认网络时，获取的netHandler的netid为0,属于异常情况，需要额外处理。
        return
    }

    let caps = getNetCapabilities(netHandle)
    // 获取网络类型(bearerTypes)。
    for (item in caps.bearerTypes) {
        if (item == BearerCellular) {
            // 蜂窝网络。
            loggerInfo("BearerCellular")
        } else if (item == BearerWifi) {
            // Wi-Fi网络。
            loggerInfo("BearerWifi")
        } else if (item == BearerEthernet) {
            // 以太网网络。
            loggerInfo("BearerEthernet")
        }
    }

    // 获取网络具体能力(networkCap)。
    for (item in caps.networkCap) {
        if (item == NetCapabilityMms) {
            // 表示网络可以访问运营商的MMSC(Multimedia Message Service，多媒体短信服务)发送和接收彩信。
            loggerInfo("NetCapabilityMms")
        } else if (item == NetCapabilityNotMetered) {
            // 表示网络流量未被计费。
            loggerInfo("NetCapabilityNotMetered")
        } else if (item == NetCapabilityInternet) {
            // 表示该网络应具有访问Internet的能力，该能力由网络提供者设置。
            loggerInfo("NetCapabilityInternet")
        } else if (item == NetCapabilityNotVpn) {
            // 表示网络不使用VPN(Virtual Private Network，虚拟专用网络)。
            loggerInfo("NetCapabilityNotVpn")
        } else if (item == NetCapabilityValidated) {
            // 表示该网络访问Internet的能力被网络管理成功验证，该能力由网络管理模块设置。
            loggerInfo("NetCapabilityValidated")
        }
    }

    // 获取netHandle对应网络的连接信息。连接信息包含了链路信息、路由信息等。
    let props = getConnectionProperties(netHandle)

    // 调用getAllNets,获取所有处于连接状态的网络列表(Array<NetHandle>)。
    let allNets = getAllNets()

    for (item in allNets) {
        let curCap = getNetCapabilities(item)
        let curProp = getConnectionProperties(item)
    }
}
```

## 使用对应网络解析域名，获取所有IP

1. 声明接口调用所需要的权限：ohos.permission.INTERNET。此权限级别为normal，在申请权限前，请确保符合[权限使用的基本原则](../security/AccessToken/cj-app-permission-mgmt-overview.md#权限使用的基本原则)。然后参考[访问控制-声明权限](../security/AccessToken/cj-declare-permissions.md)声明对应权限。

2. 从kit.NetworkKit中导入connection。

3. 调用[getAddressesByName](../reference/NetworkKit/cj-apis-net-connection.md#func-getaddressesbynamestring)方法，使用默认网络解析主机名以获取所有IP地址。

<!-- compile -->

```cangjie
// 引入包名。
import kit.PerformanceAnalysisKit.Hilog
import kit.NetworkKit.*

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

// 使用默认网络解析主机名以获取所有IP地址。
func test() {
    let addrs: Array<NetAddress> = getAddressesByName("xxxx")
    loggerInfo("Succeeded to get data")
}
```
