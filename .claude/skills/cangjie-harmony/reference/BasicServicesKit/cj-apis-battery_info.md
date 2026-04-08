# ohos.battery_info（电量信息）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

battery_info模块主要提供电池状态和充放电状态的查询接口。

## 导入模块

```cangjie
import kit.BasicServicesKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class BatteryInfo

```cangjie
public class BatteryInfo {}
```

**功能：** 描述电池信息的类。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### static prop batteryCapacityLevel

```cangjie
public static prop batteryCapacityLevel: BatteryCapacityLevel
```

**功能：** 表示当前设备电池电量的等级。

**类型：** [BatteryCapacityLevel](#enum-batterycapacitylevel)

**读写能力：** 只读

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### static prop batterySoc

```cangjie
public static prop batterySoc: Int32
```

**功能：** 表示当前设备剩余电池电量百分比。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### static prop batteryTemperature

```cangjie
public static prop batteryTemperature: Int32
```

**功能：** 表示当前设备电池的温度，单位0.1摄氏度。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### static prop chargingStatus

```cangjie
public static prop chargingStatus: BatteryChargeState
```

**功能：** 表示当前设备电池的充电状态。

**类型：** [BatteryChargeState](#enum-batterychargestate)

**读写能力：** 只读

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### static prop healthStatus

```cangjie
public static prop healthStatus: BatteryHealthState
```

**功能：** 表示当前设备电池的健康状态。

**类型：** [BatteryHealthState](#enum-batteryhealthstate)

**读写能力：** 只读

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### static prop isBatteryPresent

```cangjie
public static prop isBatteryPresent: Bool
```

**功能：** 表示当前设备是否支持电池或者电池是否在位。true表示支持电池或电池在位，false表示不支持电池或电池不在位，默认为false。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### static prop nowCurrent

```cangjie
public static prop nowCurrent: Int32
```

**功能：** 表示当前设备电池的电流，单位毫安。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### static prop pluggedType

```cangjie
public static prop pluggedType: BatteryPluggedType
```

**功能：** 表示当前设备连接的充电器类型。

**类型：** [BatteryPluggedType](#enum-batterypluggedtype)

**读写能力：** 只读

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### static prop technology

```cangjie
public static prop technology: String
```

**功能：** 表示当前设备电池的技术型号。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### static prop voltage

```cangjie
public static prop voltage: Int32
```

**功能：** 表示当前设备电池的电压，单位微伏。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

## enum BatteryCapacityLevel

```cangjie
public enum BatteryCapacityLevel <: Equatable<BatteryCapacityLevel> & ToString {
    | LevelFull
    | LevelHigh
    | LevelNormal
    | LevelLow
    | LevelWarning
    | LevelCritical
    | LevelShutdown
    | ...
}
```

**功能：** 表示电池电量等级的枚举。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<BatteryCapacityLevel>
- ToString

### LevelCritical

```cangjie
LevelCritical
```

**功能：** 表示电池电量等级为极低电量。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### LevelFull

```cangjie
LevelFull
```

**功能：** 表示电池电量等级为满电量。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### LevelHigh

```cangjie
LevelHigh
```

**功能：** 表示电池电量等级为高电量。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### LevelLow

```cangjie
LevelLow
```

**功能：** 表示电池电量等级为低电量。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### LevelNormal

```cangjie
LevelNormal
```

**功能：** 表示电池电量等级为正常电量。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### LevelShutdown

```cangjie
LevelShutdown
```

**功能：** 表示电池电量等级为关机电量。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### LevelWarning

```cangjie
LevelWarning
```

**功能：** 表示电池电量等级为告警电量。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### func !=(BatteryCapacityLevel)

```cangjie
public operator func !=(other: BatteryCapacityLevel): Bool
```

**功能：** 对电池电量等级进行判不等。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BatteryCapacityLevel](#enum-batterycapacitylevel)|是|-|电池电量等级。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool| 如果电池电量等级不同返回true，否则返回false。|

### func ==(BatteryCapacityLevel)

```cangjie
public operator func ==(other: BatteryCapacityLevel): Bool
```

**功能：** 对电池电量等级进行判等。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BatteryCapacityLevel](#enum-batterycapacitylevel)|是|-|电池电量等级。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool| 如果电池电量等级相同返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 返回电池电量等级的字符串表示。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String| 电池电量等级值对应的字符串。 |

## enum BatteryChargeState

```cangjie
public enum BatteryChargeState <: Equatable<BatteryChargeState> & ToString {
    | UnknownChargeState
    | Enabled
    | Disabled
    | Full
    | ...
}
```

**功能：** 表示电池充电状态的枚举。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<BatteryChargeState>
- ToString

### Disabled

```cangjie
Disabled
```

**功能：** 表示电池充电状态为停止状态。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### Enabled

```cangjie
Enabled
```

**功能：** 表示电池充电状态为使能状态。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### Full

```cangjie
Full
```

**功能：** 表示电池充电状态为已充满状态。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### UnknownChargeState

```cangjie
UnknownChargeState
```

**功能：** 表示电池充电状态未知。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### func !=(BatteryChargeState)

```cangjie
public operator func !=(other: BatteryChargeState): Bool
```

**功能：** 对电池充电状态进行判不等。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BatteryChargeState](#enum-batterychargestate)|是|-|电池充电状态。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool| 如果电池充电状态不同返回true，否则返回false。|

### func ==(BatteryChargeState)

```cangjie
public operator func ==(other: BatteryChargeState): Bool
```

**功能：**  对电池充电状态进行判等。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BatteryChargeState](#enum-batterychargestate)|是|-|电池充电状态。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool| 如果电池充电状态相同返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 返回电池充电状态的字符串表示。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String| 电池充电状态值对应的字符串。 |

## enum BatteryHealthState

```cangjie
public enum BatteryHealthState <: Equatable<BatteryHealthState> & ToString {
    | UnknownHealthState
    | Good
    | Overheat
    | Overvoltage
    | Cold
    | Dead
    | ...
}
```

**功能：** 表示电池健康状态的枚举。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<BatteryHealthState>
- ToString

### Cold

```cangjie
Cold
```

**功能：**  表示电池健康状态为低温。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### Dead

```cangjie
Dead
```

**功能：** 表示电池健康状态为僵死状态。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### Good

```cangjie
Good
```

**功能：** 表示电池健康状态为正常。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### Overheat

```cangjie
Overheat
```

**功能：** 表示电池健康状态为过热。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### Overvoltage

```cangjie
Overvoltage
```

**功能：** 表示电池健康状态为过压。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### UnknownHealthState

```cangjie
UnknownHealthState
```

**功能：** 表示电池健康状态未知。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### func !=(BatteryHealthState)

```cangjie
public operator func !=(other: BatteryHealthState): Bool
```

**功能：** 对电池健康状态进行判不等。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BatteryHealthState](#enum-batteryhealthstate)|是|-|电池健康状态。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool| 如果电池健康状态不同返回true，否则返回false。|

### func ==(BatteryHealthState)

```cangjie
public operator func ==(other: BatteryHealthState): Bool
```

**功能：** 对电池健康状态进行判等。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BatteryHealthState](#enum-batteryhealthstate)|是|-|电池健康状态。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool| 如果电池健康状态相同返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 返回电池健康状态的字符串表示。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String| 电池健康状态值对应的字符串。 |

## enum BatteryPluggedType

```cangjie
public enum BatteryPluggedType <: Equatable<BatteryPluggedType> & ToString {
    | UnknownType
    | Ac
    | Usb
    | Wireless
    | ...
}
```

**功能：** 表示连接的充电器类型的枚举。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**父类型：**

- Equatable\<BatteryPluggedType>
- ToString

### Ac

```cangjie
Ac
```

**功能：** 表示连接的充电器类型为交流充电器。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### UnknownType

```cangjie
UnknownType
```

**功能：** 表示未获取到连接充电器类型。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### Usb

```cangjie
Usb
```

**功能：** 表示连接的充电器类型为USB。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### Wireless

```cangjie
Wireless
```

**功能：** 表示连接的充电器类型为无线充电器。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

### func !=(BatteryPluggedType)

```cangjie
public operator func !=(other: BatteryPluggedType): Bool
```

**功能：** 对充电器类型进行判不等。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BatteryPluggedType](#enum-batterypluggedtype)|是|-|充电器类型。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool| 如果充电器类型不同返回true，否则返回false。|

### func ==(BatteryPluggedType)

```cangjie
public operator func ==(other: BatteryPluggedType): Bool
```

**功能：** 对充电器类型进行判等。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[BatteryPluggedType](#enum-batterypluggedtype)|是|-|充电器类型。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool| 如果充电器类型相同返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 返回充电器类型信息的字符串表示。

**系统能力：** SystemCapability.PowerManager.BatteryManager.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String| 充电器类型值对应的字符串。 |
