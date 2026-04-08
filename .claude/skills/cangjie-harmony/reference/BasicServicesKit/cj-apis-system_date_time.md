# ohos.system_date_time（系统时间、时区）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

system_date_time模块主要由系统时间和系统时区功能组成。开发者可以获取系统时间及系统时区。

## 导入模块

```cangjie
import kit.BasicServicesKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class SystemDateTime

```cangjie
public class SystemDateTime {}
```

**功能：** 系统时间、时区功能类。

**系统能力：** SystemCapability.MiscServices.Time

**起始版本：** 22

### static func getTime(Bool)

```cangjie
public static func getTime(isNanoseconds!: Bool = false): Int64
```

**功能：** 获取自Unix纪元以来到当前系统时间所经过的时间。

**系统能力：** SystemCapability.MiscServices.Time

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|isNanoseconds|Bool|否|false| **命名参数。** 返回结果是否为纳秒数。<br>- true：表示返回结果为纳秒数(ns)。 <br>- false：表示返回结果为毫秒数(ms)。<br>默认值为false。|

**返回值：**

|类型|说明|
|:----|:----|
|Int64|自Unix纪元以来到当前系统时间所经过的时间。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.BasicServicesKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let time = SystemDateTime.getTime()
    Hilog.info(0, "cangjie_ohos_test", "Succeeded in getting time : ${time}")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func getTimezone()

```cangjie
public static func getTimezone(): String
```

**功能：** 获取系统时区。

**系统能力：** SystemCapability.MiscServices.Time

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|返回系统时区。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.BasicServicesKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let time = SystemDateTime.getTimezone()
    Hilog.info(0, "cangjie_ohos_test", "Succeeded to getTimezone, getTimezone is ${time} ")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func getUptime(TimeType, Bool)

```cangjie
public static func getUptime(timeType: TimeType, isNanoseconds!: Bool = false): Int64
```

**功能：** 获取自系统启动以来经过的时间。

**系统能力：** SystemCapability.MiscServices.Time

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|timeType|[TimeType](#enum-timetype)|是|-|获取时间的类型，仅能为Startup或者Active。|
|isNanoseconds|Bool|否|false| **命名参数。** 返回结果是否为纳秒数。<br/>- true：表示返回结果为纳秒数(ns)。 <br/>- false：表示返回结果为毫秒数(ms)。<br>默认值为false。|

**返回值：**

|类型|说明|
|:----|:----|
|Int64|自系统启动以来经过的时间。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.BasicServicesKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let time = SystemDateTime.getUptime(TimeType.Active)
    Hilog.info(0, "cangjie_ohos_test", "Succeeded to getUptime : ${time}")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## enum TimeType

```cangjie
public enum TimeType {
    | Startup
    | Active
    | ...
}
```

**功能：** 定义获取时间的枚举类型。

**系统能力：** SystemCapability.MiscServices.Time

**起始版本：** 22

### Active

```cangjie
Active
```

**功能：** 自系统启动以来经过的毫秒数，不包括深度睡眠时间。

**系统能力：** SystemCapability.MiscServices.Time

**起始版本：** 22

### Startup

```cangjie
Startup
```

**功能：** 自系统启动以来经过的毫秒数，包括深度睡眠时间。

**系统能力：** SystemCapability.MiscServices.Time

**起始版本：** 22
