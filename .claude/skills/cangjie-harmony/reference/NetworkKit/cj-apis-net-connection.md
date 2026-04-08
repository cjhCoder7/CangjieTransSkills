# ohos.net.connection（网络连接管理）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

connection模块提供管理网络一些基础能力，包括获取默认激活的数据网络、获取所有激活数据网络列表、开启关闭飞行模式、获取网络能力信息等功能。

本节错误码的详细介绍请参见[网络连接管理错误码](./cj-errorcode-net-connection.md)。

## 导入模块

```cangjie
import kit.NetworkKit.*
```

## 权限列表

ohos.permission.GET_NETWORK_INFO

ohos.permission.INTERNET

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## func createNetConnection(?NetSpecifier, UInt32)

```cangjie
public func createNetConnection(netSpecifier!: ?NetSpecifier = None, timeout!: UInt32 = 0): NetConnection
```

**功能：** 创建一个NetConnection对象，[netSpecifier](#class-netspecifier)指定关注的网络的各项特征；timeout是超时时间(单位是毫秒)；netSpecifier是timeout的必要条件，两者都没有则表示关注默认网络。

**注意：** createNetConnection注册回调函数的数量不能超过2000（个），否则无法继续注册网络监听。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|netSpecifier|?[NetSpecifier](#class-netspecifier)|否|None|**命名参数。** 指定待关注网络的特征，缺省表示关注默认网络。|
|timeout|UInt32|否|0|**命名参数。** 获取netSpecifier指定网络时的超时时间，传入值需为UInt32范围内的整数，仅netSpecifier存在时生效，默认值为0。|

**返回值：**

|类型|说明|
|:----|:----|
|[NetConnection](#class-netconnection)|所关注的网络的句柄。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 关注默认网络, 不需要传参
    let netConnection = createNetConnection()

    // 关注蜂窝网络，需要传入相关网络特征，timeout参数未传入说明未使用超时时间，此时timeout为0
    let netspecifier = NetSpecifier(NetCapabilities([NetBearType.BearerCellular]))
    let netConnectionCellular = createNetConnection(netSpecifier: netspecifier)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func getAddressesByName(String)

```cangjie
public func getAddressesByName(host: String): Array<NetAddress>
```

**功能：** 使用对应网络解析主机名以获取所有IP地址。

**需要权限：** ohos.permission.INTERNET

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|host|String|是|-|需要解析的主机名。例如："www.example.com"。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[NetAddress](#class-netaddress)>|返回所有IP地址。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2100001 | Invalid parameter value. |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let addresses = getAddressesByName("localhost")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func getAllNets()

```cangjie
public func getAllNets(): Array<NetHandle>
```

**功能：** 获取所有处于连接状态的网络列表。

**需要权限：** ohos.permission.GET_NETWORK_INFO

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[NetHandle](#class-nethandle)>|返回处于激活状态的数据网络列表。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let netHandles = getAllNets()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func getAppNet()

```cangjie
public func getAppNet(): NetHandle
```

**功能：** 获取App绑定的网络信息。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[NetHandle](#class-nethandle)|返回App绑定的网络信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let netHandle = getAppNet()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func getConnectionProperties(NetHandle)

```cangjie
public func getConnectionProperties(netHandle: NetHandle): ConnectionProperties
```

**功能：** 获取netHandle对应的网络的连接信息。

**需要权限：** ohos.permission.GET_NETWORK_INFO

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|netHandle|[NetHandle](#class-nethandle)|是|-|数据网络的句柄。|

**返回值：**

|类型|说明|
|:----|:----|
|[ConnectionProperties](#class-connectionproperties)|返回网络的连接信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2100001 | Invalid parameter value. |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.*

try {
    let netHandle = getDefaultNet()
    let connectionProperties = getConnectionProperties(netHandle)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "getConnectionProperties failed: ${e.code} ${e.message}")
}
```

## func getDefaultHttpProxy()

```cangjie
public func getDefaultHttpProxy(): HttpProxy
```

**功能：** 获取网络默认的代理配置信息。如果设置了全局代理，则会返回全局代理配置信息。如果进程使用[setAppNet](#func-setappnetnethandle)绑定到指定[NetHandle](#class-nethandle)对应的网络，则返回[NetHandle](#class-nethandle)对应网络的代理配置信息。在其它情况下，将返回默认网络的代理配置信息。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[HttpProxy](#class-httpproxy)|返回网络默认的代理配置信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.*

try {
    let proxy = getDefaultHttpProxy()
    Hilog.info(0, "test", "proxy: ${proxy.host} ${proxy.port}")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "getDefaultHttpProxy failed: ${e.code} ${e.message}")
}
```

## func getDefaultNet()

```cangjie
public func getDefaultNet(): NetHandle
```

**功能：** 获取默认激活的数据网络。可以使用[getNetCapabilities](#func-getnetcapabilitiesnethandle)去获取网络的类型、拥有的能力等信息。

**需要权限：** ohos.permission.GET_NETWORK_INFO

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[NetHandle](#class-nethandle)|返回默认激活的数据网络。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let netHandle = getDefaultNet()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func getNetCapabilities(NetHandle)

```cangjie
public func getNetCapabilities(netHandle: NetHandle): NetCapabilities
```

**功能：** 获取netHandle对应的网络的能力信息。

**需要权限：** ohos.permission.GET_NETWORK_INFO

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|netHandle|[NetHandle](#class-nethandle)|是|-|数据网络的句柄。|

**返回值：**

|类型|说明|
|:----|:----|
|[NetCapabilities](#class-netcapabilities)|返回网络的能力信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2100001 | Invalid parameter value. |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.*

try {
    let netHandle = getDefaultNet()
    let netCapabilities = getNetCapabilities(netHandle)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "getNetCapabilities failed: ${e.code} ${e.message}")
}
```

## func hasDefaultNet()

```cangjie
public func hasDefaultNet(): Bool
```

**功能：** 检查默认数据网络是否被激活，返回接口，如果被激活则返回true。

**需要权限：** ohos.permission.GET_NETWORK_INFO

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|默认数据网络被激活返回true。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let hasDefault = hasDefaultNet()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func isDefaultNetMetered()

```cangjie
public func isDefaultNetMetered(): Bool
```

**功能：** 检查当前网络上的数据流量使用是否被计费（例如：WiFi网络不会被计费，蜂窝网络会被计费）

**需要权限：** ohos.permission.GET_NETWORK_INFO

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|表示当前网络上的数据流量是否被计费。true表示会被计费，false表示不会被计费。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let isMetered = isDefaultNetMetered()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func reportNetConnected(NetHandle)

```cangjie
public func reportNetConnected(netHandle: NetHandle): Unit
```

**功能：** 向网络管理报告网络处于可用状态。

**需要权限：** ohos.permission.GET_NETWORK_INFO & ohos.permission.INTERNET

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|netHandle|[NetHandle](#class-nethandle)|是|-|数据网络的句柄，参考[NetHandle](#class-nethandle)。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2100001 | Invalid parameter value. |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let handle = getDefaultNet()
    reportNetConnected(handle)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func reportNetDisconnected(NetHandle)

```cangjie
public func reportNetDisconnected(netHandle: NetHandle): Unit
```

**功能：** 向网络管理上报网络处于不可用状态。

**需要权限：** ohos.permission.GET_NETWORK_INFO & ohos.permission.INTERNET

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|netHandle|[NetHandle](#class-nethandle)|是|-|数据网络的句柄，参考[NetHandle](#class-nethandle)。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2100001 | Invalid parameter value. |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let handle = getDefaultNet()
    reportNetDisconnected(handle)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func setAppNet(NetHandle)

```cangjie
public func setAppNet(netHandle: NetHandle): Unit
```

**功能：** 将App绑定到特定的网络，绑定后App只能通过netHandle对应的网络访问网络。

**需要权限：** ohos.permission.INTERNET

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|netHandle|[NetHandle](#class-nethandle)|是|-|数据网络的句柄。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2100001 | Invalid parameter value. |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.*

try {
    let netHandle = getDefaultNet()
    setAppNet(netHandle)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "setAppNet failed: ${e.code} ${e.message}")
}
```

## class ConnectionProperties

```cangjie
public class ConnectionProperties {
    public var interfaceName: String
    public var domains: String
    public var linkAddresses: Array<LinkAddress>
    public var dnses: Array<NetAddress>
    public var routes: Array<RouteInfo>
    public var mtu: UInt32
}
```

**功能：** 网络连接信息类。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var dnses

```cangjie
public var dnses: Array<NetAddress>
```

**功能：** 网络地址，参考[NetAddress](#class-netaddress)。

**类型：** Array\<[NetAddress](#class-netaddress)>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var domains

```cangjie
public var domains: String
```

**功能：** 域名。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var interfaceName

```cangjie
public var interfaceName: String
```

**功能：** 网卡名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var linkAddresses

```cangjie
public var linkAddresses: Array<LinkAddress>
```

**功能：** 链路信息。

**类型：** Array\<[LinkAddress](#class-linkaddress)>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var mtu

```cangjie
public var mtu: UInt32
```

**功能：** 最大传输单元。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var routes

```cangjie
public var routes: Array<RouteInfo>
```

**功能：** 路由信息。

**类型：** Array\<[RouteInfo](#class-routeinfo)>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

## class HttpProxy

```cangjie
public class HttpProxy {
    public var host: String
    public var port: UInt32
    public var exclusionList: Array<String>
    public var username: String
    public var password: String
    public init(host: String,  port: UInt32, exclusionList: Array<String>,
        username!: String = "", password!: String = "")
}
```

**功能：** 网络代理配置信息。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var exclusionList

```cangjie
public var exclusionList: Array<String>
```

**功能：** 不使用代理的主机名列表，主机名支持域名、IP地址以及通配符形式，详细匹配规则如下：

1、域名匹配规则：

（1）完全匹配：代理服务器主机名只要与列表中的任意一个主机名完全相同，就可以匹配。

（2）包含匹配：代理服务器主机名只要包含列表中的任意一个主机名，就可以匹配。

例如，如果在主机名列表中设置了 “ample.com”，则  “ample.com”、“www.ample.com”、“ample.com:80”都会被匹配，而 “www.example.com”、“ample.com.org”则不会被匹配。

2、IP地址匹配规则：代理服务器主机名只要与列表中的任意一个IP地址完全相同，就可以匹配。

3、域名跟IP地址可以同时添加到列表中进行匹配。

4、单个“\*”是唯一有效的通配符，当列表中只有通配符时，将与所有代理服务器主机名匹配，表示禁用代理。通配符只能单独添加，不可以与其他域名、IP地址一起添加到列表中，否则通配符将不生效。

5、匹配规则不区分主机名大小写。

6、匹配主机名时，不考虑http和https等协议前缀。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var host

```cangjie
public var host: String
```

**功能：** 代理服务器主机名。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var password

```cangjie
public var password: String
```

**功能：** 使用代理的用户密码。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var port

```cangjie
public var port: UInt32
```

**功能：** 主机端口。取值范围[0,65535]。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var username

```cangjie
public var username: String
```

**功能：** 使用代理的用户名。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### init(String, UInt32, Array\<String>, String, String)

```cangjie
public init(host: String,  port: UInt32, exclusionList: Array<String>,
    username!: String = "", password!: String = "")
```

**功能：** 构造HttpProxy实例。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|host|String|是|-|代理服务器主机名。|
|port|UInt32|是|-|主机端口。取值范围[0,65535]。|
|exclusionList|Array\<String>|是|-|不使用代理的主机名列表。|
|username|String|否|""|**命名参数。** 使用代理的用户名。|
|password|String|否|""|**命名参数。** 使用代理的用户密码。|

## class LinkAddress

```cangjie
public class LinkAddress {
    public var address: NetAddress
    public var prefixLength: Int32
}
```

**功能：** 网络链路信息。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var address

```cangjie
public var address: NetAddress
```

**功能：** 链路地址。

**类型：** [NetAddress](#class-netaddress)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var prefixLength

```cangjie
public var prefixLength: Int32
```

**功能：** 链路地址前缀的长度。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

## class NetAddress

```cangjie
public class NetAddress {
    public var address: String
    public var family: UInt32
    public var port: UInt32
    public init(address: String, family!: UInt32 = 1, port!: UInt32 = 0)
}
```

**功能：** 网络地址。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var address

```cangjie
public var address: String
```

**功能：** 地址。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var family

```cangjie
public var family: UInt32
```

**功能：** IPv4 = 1，IPv6 = 2。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var port

```cangjie
public var port: UInt32
```

**功能：** 端口，取值范围\[0, 65535]。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### init(String, UInt32, UInt32)

```cangjie
public init(address: String, family!: UInt32 = 1, port!: UInt32 = 0)
```

**功能：** 构造NetAddress实例。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|address|String|是|-|地址。|
|family|UInt32|否|1|**命名参数。** IPv4 = 1，IPv6 = 2，默认IPv4。|
|port|UInt32|否|0|**命名参数。** 端口，取值范围\[0, 65535]，默认值为0。|

## class NetBlockStatusInfo

```cangjie
public class NetBlockStatusInfo {
    public var netHandle: NetHandle
    public var blocked: Bool
}
```

**功能：** 获取网络状态信息。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var blocked

```cangjie
public var blocked: Bool
```

**功能：** 标识当前网络是否是堵塞状态。true：标识当前网络是堵塞状态；false：标识当前网络不是堵塞状态。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var netHandle

```cangjie
public var netHandle: NetHandle
```

**功能：** 数据网络句柄(netHandle)。

**类型：** [NetHandle](#class-nethandle)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

## class NetCapabilities

```cangjie
public class NetCapabilities {
    public var bearerTypes: Array<NetBearType>
    public var linkUpBandwidthKbps: UInt32
    public var linkDownBandwidthKbps: UInt32
    public var networkCap: Array<NetCap>
    public init(bearerTypes: Array<NetBearType>, linkUpBandwidthKbps!: UInt32 = 0, linkDownBandwidthKbps!: UInt32 = 0,
        networkCap!: Array<NetCap> = Array<NetCap>())
}
```

**功能：** 网络的能力集。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var bearerTypes

```cangjie
public var bearerTypes: Array<NetBearType>
```

**功能：** 网络类型。数组里面只包含了一种网络类型。

**类型：** Array\<[NetBearType](#enum-netbeartype)>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var linkDownBandwidthKbps

```cangjie
public var linkDownBandwidthKbps: UInt32
```

**功能：** 下行（网络到设备）带宽，单位(kb/s)。0表示无法评估当前网络带宽。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var linkUpBandwidthKbps

```cangjie
public var linkUpBandwidthKbps: UInt32
```

**功能：** 上行（设备到网络）带宽，单位(kb/s)。0表示无法评估当前网络带宽。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var networkCap

```cangjie
public var networkCap: Array<NetCap>
```

**功能：** 网络具体能力。

**类型：** Array\<[NetCap](#enum-netcap)>

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### init(Array\<NetBearType>, UInt32, UInt32, Array\<NetCap>)

```cangjie
public init(bearerTypes: Array<NetBearType>, linkUpBandwidthKbps!: UInt32 = 0, linkDownBandwidthKbps!: UInt32 = 0,
    networkCap!: Array<NetCap> = Array<NetCap>())
```

**功能：** 网络的能力集。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|bearerTypes|Array\<[NetBearType](#enum-netbeartype)>|是|-|网络类型。数组里面只包含了一种网络类型。|
|linkUpBandwidthKbps|UInt32|否|0|**命名参数。** 上行（设备到网络）带宽，单位(kb/s)。0表示无法评估当前网络带宽。|
|linkDownBandwidthKbps|UInt32|否|0|**命名参数。** 下行（网络到设备）带宽，单位(kb/s)。0表示无法评估当前网络带宽。|
|networkCap|Array\<[NetCap](#enum-netcap)>|否|Array\<NetCap>()|**命名参数。** 网络具体能力。|

## class NetCapabilityInfo

```cangjie
public class NetCapabilityInfo {
    public var netHandle: NetHandle
    public var netCap: NetCapabilities
}
```

**功能：** 提供承载数据网络能力的实例。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var netCap

```cangjie
public var netCap: NetCapabilities
```

**功能：** 存储数据网络的传输能力和承载类型。

**类型：** [NetCapabilities](#class-netcapabilities)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var netHandle

```cangjie
public var netHandle: NetHandle
```

**功能：** 数据网络句柄。

**类型：** [NetHandle](#class-nethandle)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

## class NetConnection

```cangjie
public class NetConnection {}
```

**功能：** 网络连接的句柄。

> **说明：**
>
>（1）设备从无网络状态转变为有网络状态时，将触发netAvailable事件、netCapabilitiesChange事件和netConnectionPropertiesChange事件；
>
>（2）接收到netAvailable事件后，若设备从有网络状态转变为无网络状态，将触发netLost事件；
>
>（3）若未接收到netAvailable事件，则将直接接收到netUnavailable事件；
>
>（4）设备从WiFi网络切换至蜂窝网络时，将先触发netLost事件（WiFi丢失），随后触发netAvailable事件（蜂窝可用）。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### func on(NetConnectionEvent, Callback1Argument\<NetHandle>)

```cangjie
public func on(event: NetConnectionEvent, callback: Callback1Argument<NetHandle>): Unit
```

**功能：** 订阅网络可用事件。此接口需在调用register接口之前调用。若无需接收网络状态变化的回调通知，应使用unregister取消订阅默认的网络状态变化通知。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|[NetConnectionEvent](#enum-netconnectionevent)|是|-|网络连接事件类型，仅支持NetAvailable和NetLost事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[NetHandle](#class-nethandle)>|是|-|回调函数，返回数据网络句柄。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100001 | Invalid parameter value. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException
import ohos.callback_invoke.*

// 定义NetAvailableCb类
class NetAvailableCb <: Callback1Argument<NetHandle> {
    let callback_: (NetHandle)->Unit
    public init(callback: (NetHandle)->Unit) {callback_ = callback}
    public func invoke(err: ?BusinessException, val: NetHandle): Unit {
        callback_(val)
    }
}

try {
    let netConn = createNetConnection()
    netConn.register()

    let netAvailableCallBack = NetAvailableCb({handle => Hilog.info(0, "net_connection test", "onNetAvailable handle is ${handle.netId}")})
    netConn.on(NetConnectionEvent.NetAvailable, netAvailableCallBack)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(NetConnectionEvent, Callback1Argument\<NetBlockStatusInfo>)

```cangjie
public func on(event: NetConnectionEvent, callback: Callback1Argument<NetBlockStatusInfo>): Unit
```

**功能：** 订阅网络阻塞状态事件。此接口需要在调用register接口之前调用。若无需接收网络状态变化的回调通知，应使用unregister取消订阅默认的网络状态变化通知。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|[NetConnectionEvent](#enum-netconnectionevent)|是|-|网络连接事件类型，仅支持NetBlockStatusChange事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[NetBlockStatusInfo](#class-netblockstatusinfo)>|是|-|回调函数，获取网络阻塞状态信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100001 | Invalid parameter value. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException
import ohos.callback_invoke.*

// 定义NetBlockStatusChangeCb类
class NetBlockStatusChangeCb <: Callback1Argument<NetBlockStatusInfo> {
    let callback_: (NetBlockStatusInfo)->Unit
    public init(callback: (NetBlockStatusInfo)->Unit) {callback_ = callback}
    public func invoke(err: ?BusinessException, val: NetBlockStatusInfo): Unit {
        callback_(val)
    }
}

try {
    let netConn = createNetConnection()
    netConn.register()

    let netBlockStatusChangeCallBack = NetBlockStatusChangeCb(
        {
            info => Hilog.info(0, "net_connection test",
                "onNetBlockStatusChange handle is ${info.netHandle.netId}, block is ${info.blocked}")
        })
    netConn.on(NetConnectionEvent.NetBlockStatusChange, netBlockStatusChangeCallBack)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(NetConnectionEvent, Callback1Argument\<NetCapabilityInfo>)

```cangjie
public func on(event: NetConnectionEvent, callback: Callback1Argument<NetCapabilityInfo>): Unit
```

**功能：** 订阅网络能力变化事件。此接口要在register接口调用前调用，不需要网络状态变化回调通知时，使用unregister取消订阅默认网络状态变化的通知。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|[NetConnectionEvent](#enum-netconnectionevent)|是|-|网络连接事件类型，仅支持NetCapabilitiesChange事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[NetCapabilityInfo](#class-netcapabilityinfo)>|是|-|回调函数，返回数据网络句柄（netHandle）和网络的能力信息（netCap）。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100001 | Invalid parameter value. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException
import ohos.callback_invoke.*

// 定义NetCapabilitiesChangeCb类
class NetCapabilitiesChangeCb <: Callback1Argument<NetCapabilityInfo> {
    let callback_: (NetCapabilityInfo)->Unit
    public init(callback: (NetCapabilityInfo)->Unit) {callback_ = callback}
    public func invoke(err: ?BusinessException, val: NetCapabilityInfo): Unit {
        callback_(val)
    }
}

try {
    let netConn = createNetConnection()
    netConn.register()

    let netCapabilitiesChangeCallBack = NetCapabilitiesChangeCb(
        {
            info => Hilog.info(0, "net_connection test",
                "onNetCapabilitiesChange handle is ${info.netHandle.netId}, props is ")
        })
    netConn.on(NetConnectionEvent.NetCapabilitiesChange, netCapabilitiesChangeCallBack)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(NetConnectionEvent, Callback1Argument\<NetConnectionPropertyInfo>)

```cangjie
public func on(event: NetConnectionEvent, callback: Callback1Argument<NetConnectionPropertyInfo>): Unit
```

**功能：** 订阅网络连接信息变化事件。此接口要在register接口调用前调用，不需要网络状态变化回调通知时，使用unregister取消订阅默认网络状态变化的通知。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|[NetConnectionEvent](#enum-netconnectionevent)|是|-|网络连接事件类型，仅支持NetConnectionPropertiesChange事件。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<[NetConnectionPropertyInfo](#class-netconnectionpropertyinfo)>|是|-|回调函数，获取网络连接属性信息。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100001 | Invalid parameter value. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException
import ohos.callback_invoke.*

// 定义NetConnectionPropertiesChangeCb类
class NetConnectionPropertiesChangeCb <: Callback1Argument<NetConnectionPropertyInfo> {
    let callback_: (NetConnectionPropertyInfo)->Unit
    public init(callback: (NetConnectionPropertyInfo)->Unit) {callback_ = callback}
    public func invoke(err: ?BusinessException, val: NetConnectionPropertyInfo): Unit {
        callback_(val)
    }
}

try {
    let netConn = createNetConnection()
    netConn.register()

    let netConnectionPropertiesChangeCallBack = NetConnectionPropertiesChangeCb(
        {
            info => Hilog.info(0, "net_connection test",
                "onNetConnectionPropertiesChange handle is ${info.netHandle.netId}, props is ")
        })
    netConn.on(NetConnectionEvent.NetConnectionPropertiesChange, netConnectionPropertiesChangeCallBack)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(NetConnectionEvent, Callback0Argument)

```cangjie
public func on(event: NetConnectionEvent, callback: Callback0Argument): Unit
```

**功能：** 订阅网络不可用事件。此接口要在register接口调用前调用，不需要网络状态变化回调通知时，使用unregister取消订阅默认网络状态变化的通知。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|[NetConnectionEvent](#enum-netconnectionevent)|是|-|网络连接事件类型，仅支持NetUnavailable事件。|
|callback|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数，无返回结果。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100001 | Invalid parameter value. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException
import ohos.callback_invoke.*

// 定义NetUnavailableCb类
class NetUnavailableCb <: Callback0Argument {
    let callback_: ()->Unit
    public init(callback: ()->Unit) {callback_ = callback}
    public func invoke(err: ?BusinessException): Unit {
        callback_()
    }
}

try {
    let netConn = createNetConnection()
    netConn.register()

    let netUnAvailableCallBack = NetUnavailableCb({=> Hilog.info(0, "net_connection test", "onNetUnavailable")})
    netConn.on(NetConnectionEvent.NetUnavailable, netUnAvailableCallBack)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func register()

```cangjie
public func register(): Unit
```

**功能：** 订阅指定网络状态变化的通知。如需监听特定事件，确保调用on监听事件后再调用register进行注册。

**需要权限：** ohos.permission.GET_NETWORK_INFO

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |
  | 2101008 | The callback already exists. |
  | 2101022 | The number of requests exceeded the maximum allowed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let netCon: NetConnection = createNetConnection()
    netCon.register()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func unregister()

```cangjie
public func unregister(): Unit
```

**功能：** 取消订阅默认网络状态变化的通知。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |
  | 2101007 | The callback does not exist. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let netCon: NetConnection = createNetConnection()
    netCon.register()
    netCon.unregister()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class NetConnectionPropertyInfo

```cangjie
public class NetConnectionPropertyInfo {
    public var netHandle: NetHandle
    public var connectionProperties: ConnectionProperties
}
```

**功能：** 网络连接信息。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var connectionProperties

```cangjie
public var connectionProperties: ConnectionProperties
```

**功能：** 网络连接属性。

**类型：** [ConnectionProperties](#class-connectionproperties)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var netHandle

```cangjie
public var netHandle: NetHandle
```

**功能：** 数据网络句柄(netHandle)。

**类型：** [NetHandle](#class-nethandle)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

## class NetHandle

```cangjie
public class NetHandle {
    public var netId: Int32
}
```

**功能：** 数据网络的句柄。

在调用NetHandle的方法之前，需要先获取NetHandle对象。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var netId

```cangjie
public var netId: Int32
```

**功能：** 网络ID，取值为0代表没有默认网络，其余取值必须大于等于100。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### func getAddressByName(String)

```cangjie
public func getAddressByName(host: String): NetAddress
```

**功能：** 使用当前NetHandle对应的网络解析主机名获取到的第一个IP地址。

**需要权限：** ohos.permission.INTERNET

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|host|String|是|-|需要解析的主机名。例如："www.example.com"。|

**返回值：**

|类型|说明|
|:----|:----|
|[NetAddress](#class-netaddress)|返回第一个IP地址。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2100001 | Invalid parameter value. |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let handle = getDefaultNet()

    let address = handle.getAddressByName("localhost")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getAddressesByName(String)

```cangjie
public func getAddressesByName(host: String): Array<NetAddress>
```

**功能：** 使用当前NetHandle对应的网络解析主机名获取到的所有IP地址。

**需要权限：** ohos.permission.INTERNET

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|host|String|是|-|需要解析的主机名。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[NetAddress](#class-netaddress)>|需要解析的主机名。例如："www.example.com"。|

**异常：**

- BusinessException：对应错误码如下表，详见[网络连接管理错误码](./cj-errorcode-net-connection.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | Permission denied. |
  | 2100001 | Invalid parameter value. |
  | 2100002 | Failed to connect to the service. |
  | 2100003 | System internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.NetworkKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let handle = getDefaultNet()

    let addresses = handle.getAddressesByName("localhost")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class NetSpecifier

```cangjie
public class NetSpecifier {
    public var netCapabilities: NetCapabilities
    public var bearerPrivateIdentifier: String
    public init(netCapabilities: NetCapabilities, bearerPrivateIdentifier!: String = "")
}
```

**功能：** 提供承载数据网络能力的实例。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var bearerPrivateIdentifier

```cangjie
public var bearerPrivateIdentifier: String
```

**功能：** 网络标识符，蜂窝网络的标识符是"slot0"（对应SIM卡1）、"slot1"（对应SIM卡2）。可以通过传递注册的WLAN热点信息表示应用希望激活的指定的WLAN网络。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var netCapabilities

```cangjie
public var netCapabilities: NetCapabilities
```

**功能：** 存储数据网络的传输能力和承载类型。

**类型：** [NetCapabilities](#class-netcapabilities)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### init(NetCapabilities, String)

```cangjie
public init(netCapabilities: NetCapabilities, bearerPrivateIdentifier!: String = "")
```

**功能：** 提供承载数据网络能力的实例。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|netCapabilities|[NetCapabilities](#class-netcapabilities)|是|-|存储数据网络的传输能力和承载类型。|
|bearerPrivateIdentifier|String|否|""|**命名参数。** 网络标识符，蜂窝网络的标识符是"slot0"（对应SIM卡1）、"slot1"（对应SIM卡2）。可以通过传递注册的WLAN热点信息表示应用希望激活的指定的WLAN网络。|

## class RouteInfo

```cangjie
public class RouteInfo {
    public var interfaceName: String
    public var destination: LinkAddress
    public var gateway: NetAddress
    public var hasGateway: Bool
    public var isDefaultRoute: Bool
}
```

**功能：** 网络路由信息。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var destination

```cangjie
public var destination: LinkAddress
```

**功能：** 目的地址。

**类型：** [LinkAddress](#class-linkaddress)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var gateway

```cangjie
public var gateway: NetAddress
```

**功能：** 网关地址。

**类型：** [NetAddress](#class-netaddress)

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var hasGateway

```cangjie
public var hasGateway: Bool
```

**功能：** 是否有网关。true：有网关；false：无网关。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var interfaceName

```cangjie
public var interfaceName: String
```

**功能：** 网卡名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### var isDefaultRoute

```cangjie
public var isDefaultRoute: Bool
```

**功能：** 是否为默认路由。true：默认路由；false：非默认路由。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

## enum NetBearType

```cangjie
public enum NetBearType {
    | BearerCellular
    | BearerWifi
    | BearerEthernet
    | ...
}
```

**功能：** 网络类型。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### BearerCellular

```cangjie
BearerCellular
```

**功能：** 蜂窝网络。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### BearerEthernet

```cangjie
BearerEthernet
```

**功能：** 以太网网络。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### BearerWifi

```cangjie
BearerWifi
```

**功能：** Wi-Fi网络。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

## enum NetCap

```cangjie
public enum NetCap {
    | NetCapabilityMms
    | NetCapabilityNotMetered
    | NetCapabilityInternet
    | NetCapabilityNotVpn
    | NetCapabilityValidated
    | ...
}
```

**功能：** 网络具体能力。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### NetCapabilityInternet

```cangjie
NetCapabilityInternet
```

**功能：** 表示该网络应具有访问Internet的能力，此能力由网络提供者设置，但该网络访问Internet的连通性并未被网络管理成功验证。网络连通性可以通过NetCapabilityValidated判断。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### NetCapabilityMms

```cangjie
NetCapabilityMms
```

**功能：** 表示网络可以访问运营商的MMSC（Multimedia&nbsp;Message&nbsp;Service，多媒体短信服务）发送和接收彩信。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### NetCapabilityNotMetered

```cangjie
NetCapabilityNotMetered
```

**功能：** 表示网络流量未被计费。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### NetCapabilityNotVpn

```cangjie
NetCapabilityNotVpn
```

**功能：** 表示网络不使用VPN（Virtual&nbsp;Private&nbsp;Network，虚拟专用网络）。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### NetCapabilityValidated

```cangjie
NetCapabilityValidated
```

**功能：** 表示网络管理通过该网络与华为云地址成功建立连接，此能力由网络管理模块设置。

注意： 网络管理可能会与华为云地址建立连接失败，导致网络能力不具备此标记位，但不完全代表该网络无法访问互联网。另外，对于新完成连接的网络，由于网络正在进行连通性验证，此值可能无法反映真实的验证结果。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

## enum NetConnectionEvent

```cangjie
public enum NetConnectionEvent <: Equatable<NetConnectionEvent> {
    | NetAvailable
    | NetBlockStatusChange
    | NetCapabilitiesChange
    | NetConnectionPropertiesChange
    | NetLost
    | NetUnavailable
    | ...
}
```

**功能：** 网络连接事件类型。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<NetConnectionEvent>

### NetAvailable

```cangjie
NetAvailable
```

**功能：** 网络可用事件。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### NetBlockStatusChange

```cangjie
NetBlockStatusChange
```

**功能：** 网络阻塞状态变化事件。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### NetCapabilitiesChange

```cangjie
NetCapabilitiesChange
```

**功能：** 网络能力变化事件。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### NetConnectionPropertiesChange

```cangjie
NetConnectionPropertiesChange
```

**功能：** 网络连接信息变化事件。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### NetLost

```cangjie
NetLost
```

**功能：** 网络丢失事件。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### NetUnavailable

```cangjie
NetUnavailable
```

**功能：** 网络不可用事件。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

### func !=(NetConnectionEvent)

```cangjie
public operator func !=(other: NetConnectionEvent): Bool
```

**功能：** 判断两个事件是否不相等。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[NetConnectionEvent](#enum-netconnectionevent)|是|-|另一个事件枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|当两个事件不相等时返回true，否则返回false。|

### func ==(NetConnectionEvent)

```cangjie
public operator func ==(other: NetConnectionEvent): Bool
```

**功能：** 判断两个事件是否相等。

**系统能力：** SystemCapability.Communication.NetManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[NetConnectionEvent](#enum-netconnectionevent)|是|-|另一个事件枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|当两个事件相等时返回true，否则返回false。|
