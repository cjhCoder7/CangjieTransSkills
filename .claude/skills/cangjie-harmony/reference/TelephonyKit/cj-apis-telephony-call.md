# ohos.telephony.call（拨打电话）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

call模块提供呼叫管理功能，包括拨打电话、跳转到拨号界面、获取通话状态、格式化电话号码等。

## 导入模块

```cangjie
import kit.TelephonyKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class Call

```cangjie
public class Call {}
```

**功能：** 拨打电话类，提供呼叫管理功能，包括拨打电话、跳转到拨号界面、获取通话状态、格式化电话号码等接口。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

### static func formatPhoneNumber(String, NumberFormatOptions)

```cangjie
public static func formatPhoneNumber(
    phoneNumber: String,
    options!: NumberFormatOptions = NumberFormatOptions()
): String
```

**功能：** 格式化电话号码，可设置格式化参数。

电话号码格式化后为标准数字字符串，例如：“138 xxxx xxxx”、“0755 xxxx xxxx”。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|phoneNumber|String|是|-|电话号码。|
|options|[NumberFormatOptions](#class-numberformatoptions)|否|NumberFormatOptions()| **命名参数。** 格式化参数，如国家码。|

**返回值：**

|类型|说明|
|:----|:----|
|String|返回格式化电话号码的结果。|

**异常：**

- BusinessException：对应错误码如下表，详见[电话子系统错误码](./cj-errorcode-telephony.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 8300001 | Invalid parameter value. |
  | 8300002 | Operation failed. Cannot connect to service. |
  | 8300003 | System internal error. |
  | 8300999 | Unknown error code. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.TelephonyKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let result = Call.formatPhoneNumber("138xxxxxxxx", options: NumberFormatOptions(countryCode: "CN"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func formatPhoneNumberToE164(String, String)

```cangjie
public static func formatPhoneNumberToE164(phoneNumber: String, countryCode: String): String
```

**功能：** 将电话号码格式化为E.164表示形式。

待格式化的电话号码需要与传入的国家码相匹配，如中国电话号码需要传入国家码CN，否则格式化后的电话号码为""。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|phoneNumber|String|是|-|电话号码。|
|countryCode|String|是|-|国家码，支持所有国家码，如：中国（CN）。|

**返回值：**

|类型|说明|
|:----|:----|
|String|返回将电话号码格式化为E.164表示形式的结果。|

**异常：**

- BusinessException：对应错误码如下表，详见[电话子系统错误码](./cj-errorcode-telephony.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 8300001 | Invalid parameter value. |
  | 8300002 | Operation failed. Cannot connect to service. |
  | 8300003 | System internal error. |
  | 8300999 | Unknown error code. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.TelephonyKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let result = Call.formatPhoneNumberToE164("138xxxxxxxx", "CN")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func getCallState()

```cangjie
public static func getCallState(): CallState
```

**功能：** 获取当前通话状态。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[CallState](#enum-callstate)|返回获取到的通话状态。|

**异常：**

- BusinessException：对应错误码如下表，详见[电话子系统错误码](./cj-errorcode-telephony.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 8300001 | Parameter error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.TelephonyKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let result: CallState = Call.getCallState()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func hasCall()

```cangjie
public static func hasCall(): Bool
```

**功能：** 判断是否存在通话。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回判断是否存在通话。返回true表示当前存在通话，false表示当前不存在通话。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.TelephonyKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let result: Bool = Call.hasCall()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func hasVoiceCapability()

```cangjie
public static func hasVoiceCapability(): Bool
```

**功能：** 检查当前设备是否具备语音通话能力。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回true表示设备具备语音通话能力，返回false表示设备不具备语音通话能力。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.TelephonyKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let result: Bool = Call.hasVoiceCapability()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func isEmergencyPhoneNumber(String, EmergencyNumberOptions)

```cangjie
public static func isEmergencyPhoneNumber(phoneNumber: String, options!: EmergencyNumberOptions = EmergencyNumberOptions(slotId: 0)): Bool
```

**功能：** 根据电话号码参数，判断是否是紧急电话号码。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|phoneNumber|String|是|-|电话号码。|
|options|[EmergencyNumberOptions](#class-emergencynumberoptions)|否|EmergencyNumberOptions(slotId: 0)|**命名参数。** 电话号码参数。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|返回判断是否是紧急电话号码的结果。返回true表示是紧急电话号码，返回false表示不是紧急电话号码。|

**异常：**

- BusinessException：对应错误码如下表，详见[电话子系统错误码](./cj-errorcode-telephony.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 8300001 | Invalid parameter value. |
  | 8300002 | Operation failed. Cannot connect to service. |
  | 8300003 | System internal error. |
  | 8300999 | Unknown error code. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.TelephonyKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let result = Call.isEmergencyPhoneNumber("138xxxxxxxx", options: EmergencyNumberOptions(slotId: 1))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func makeCall(String)

```cangjie
public static func makeCall(phoneNumber: String): Unit
```

**功能：** 跳转到拨号界面，并显示待拨出的号码。后台调用需要申请ohos.permission.START_ABILITIES_FROM_BACKGROUND权限。

> **说明：**
>
> 该接口为预埋接口，当前功能受限，推荐使用双参接口[makeCall](#static-func-makecalluiabilitycontext-string)。

**系统能力：** SystemCapability.Applications.Contacts

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|phoneNumber|String|是|-|电话号码。|

**异常：**

- BusinessException：对应错误码如下表，详见[电话子系统错误码](./cj-errorcode-telephony.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 8300001 | Invalid parameter value. |
  | 8300002 | Operation failed. Cannot connect to service. |
  | 8300003 | System internal error. |
  | 8300999 | Unknown error code. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.TelephonyKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    Call.makeCall("138xxxxxxxx")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func makeCall(UIAbilityContext, String)

```cangjie
public static func makeCall(context: UIAbilityContext, phoneNumber: String): Unit
```

**功能：** 跳转到拨号界面，并显示待拨出的号码。后台调用需要申请ohos.permission.START_ABILITIES_FROM_BACKGROUND权限。

**系统能力：** SystemCapability.Applications.Contacts

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|[UIAbilityContext](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)|是|-|应用上下文Context。|
|phoneNumber|String|是|-|电话号码。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 8300001 | Invalid parameter value. |
  | 8300002 | Operation failed. Cannot connect to service. |
  | 8300003 | System internal error. |
  | 8300999 | Unknown error code. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.TelephonyKit.*
import ohos.app.ability.ui_ability.UIAbilityContext
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    Call.makeCall(Global.abilityContext, "138xxxxxxxx")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class EmergencyNumberOptions

```cangjie
public class EmergencyNumberOptions {
    public var slotId: Int32
    public init(slotId!: Int32 = 0)
}
```

**功能：** 判断是否是紧急电话号码的可选参数。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

### var slotId

```cangjie
public var slotId: Int32
```

**功能：** 卡槽ID：

- 卡槽1：`0`。

- 卡槽2：`1`。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

### init(Int32)

```cangjie
public init(slotId!: Int32 = 0)
```

**功能：** EmergencyNumberOptions构造器。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|slotId|Int32|否|0|**命名参数。** 卡槽ID。|

## class NumberFormatOptions

```cangjie
public class NumberFormatOptions {
    public var countryCode: String
    public init(countryCode!: String = "CN")
}
```

**功能：** 格式化号码的可选参数。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

### var countryCode

```cangjie
public var countryCode: String
```

**功能：** 国家码，支持所有国家的国家码，如：CN（中国）。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

### init(String)

```cangjie
public init(countryCode!: String = "CN")
```

**功能：** 用于创建NumberFormatOptions实例的构造函数。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|countryCode|String|否|"CN"|**命名参数。** 国家码，支持所有国家的国家码，如：CN（中国）。默认为："CN"。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.TelephonyKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let op = NumberFormatOptions(countryCode: "CN")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## enum CallState

```cangjie
public enum CallState <: Equatable<CallState> & ToString {
    | CallStateUnknown
    | CallStateIdle
    | CallStateRinging
    | CallStateOffhook
    | CallStateAnswered
    | ...
}
```

**功能：** 通话状态码。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

**父类型：**

- Equatable\<CallState>
- ToString

### CallStateAnswered

```cangjie
CallStateAnswered
```

**功能：** 表示来电已经接听。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

### CallStateIdle

```cangjie
CallStateIdle
```

**功能：** 表示没有正在进行的呼叫。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

### CallStateOffhook

```cangjie
CallStateOffhook
```

**功能：** 表示至少有一个呼叫处于拨号、通话中或呼叫保持状态，并且没有新的来电振铃或等待。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

### CallStateRinging

```cangjie
CallStateRinging
```

**功能：** 表示来电正在振铃或等待。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

### CallStateUnknown

```cangjie
CallStateUnknown
```

**功能：** 无效状态，当获取呼叫状态失败时返回。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

### func !=(CallState)

```cangjie
public operator func !=(other: CallState): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CallState](#enum-callstate)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(CallState)

```cangjie
public operator func ==(other: CallState): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[CallState](#enum-callstate)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取枚举的值。

**系统能力：** SystemCapability.Telephony.CallManager

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|枚举的说明。|
