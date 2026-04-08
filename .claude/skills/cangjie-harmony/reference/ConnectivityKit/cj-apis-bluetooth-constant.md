# ohos.bluetooth.constant（蓝牙constant模块）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

constant模块提供了蓝牙中常量的定义。

## 导入模块

```cangjie
import kit.ConnectivityKit.*
```

## enum ProfileConnectionState

```cangjie
public enum ProfileConnectionState <: Equatable<ProfileConnectionState> & ToString {
    | StateDisconnected
    | StateConnecting
    | StateConnected
    | StateDisconnecting
    | ...
}
```

**功能：** 蓝牙设备的 profile 连接状态。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**父类型：**

- Equatable\<ProfileConnectionState>
- ToString

### StateConnected

```cangjie
StateConnected
```

**功能：** 表示profile已连接。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### StateConnecting

```cangjie
StateConnecting
```

**功能：** 表示profile正在连接。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### StateDisconnected

```cangjie
StateDisconnected
```

**功能：** 表示profile已断连。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### StateDisconnecting

```cangjie
StateDisconnecting
```

**功能：** 表示profile正在断开连接。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

### func !=(ProfileConnectionState)

```cangjie
public operator func !=(other: ProfileConnectionState): Bool
```

**功能：** 对蓝牙设备的 profile 连接状态判不等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ProfileConnectionState](#enum-profileconnectionstate)|是|-|蓝牙设备的 profile 连接状态。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果蓝牙设备的 profile 连接状态不同返回 true，否则返回 false。|

### func ==(ProfileConnectionState)

```cangjie
public operator func ==(other: ProfileConnectionState): Bool
```

**功能：** 对蓝牙设备的 profile 连接状态进行判等。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[ProfileConnectionState](#enum-profileconnectionstate)|是|-|蓝牙设备的 profile 连接状态。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果蓝牙设备的 profile 连接状态相同返回 true，否则返回 false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 返回蓝牙设备的 profile 连接状态的字符串表示。

**系统能力：** SystemCapability.Communication.Bluetooth.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|蓝牙设备的 profile 连接状态的字符串表示。|
