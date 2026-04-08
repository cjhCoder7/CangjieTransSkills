# ohos.hilog（HiLog日志打印）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

hilog模块使应用/服务可以按照指定级别、标识和格式字符串输出日志内容，帮助开发者了解应用/服务的运行状态，更好地调试程序。

## 导入模块

```cangjie
import kit.PerformanceAnalysisKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class Hilog

```cangjie
public class Hilog {}
```

**功能：** 日志系统对象，使应用/服务可以按照指定级别、标识和格式字符串输出日志内容。提供DEBUG、INFO、WARNING、ERROR、FATAL不同级别的日志打印方法。

**系统能力：** SystemCapability.HiviewDFX.HiLog

**起始版本：** 22

### static func debug(UInt32, String, String, Array\<String>)

```cangjie
public static func debug(domain: UInt32, tag: String, format: String, args: Array<String>): Unit
```

**功能：** 打印DEBUG级别的日志。

DEBUG级别的日志在正式发布版本中默认不被打印，只有在调试版本或打开调试开关的情况下才会打印。

**系统能力：** SystemCapability.HiviewDFX.HiLog

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|domain|UInt32|是|-|日志对应的领域标识，范围是0x0~0xFFFF，超出范围则日志无法打印。<br/>建议开发者在应用内根据需要自定义划分。|
|tag|String|是|-|指定日志标识，可以为任意字符串，建议用于标识调用所在的类或者业务行为。tag最多为31字节，超出后会截断，不建议使用中文字符，可能出现乱码或者对齐问题。|
|format|String|是|-|格式字符串，用于日志的格式化输出。格式字符串中可以设置多个参数，参数需要包含参数类型、隐私标识。<br>隐私标识分为{public}和{private}，缺省为{private}。标识{public}的内容明文输出，标识{private}的内容以\<private>过滤回显。|
|args|Array\<String>|是|-|与格式字符串format对应的可变长度参数列表。参数数目、参数类型必须与格式字符串中的标识一一对应。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    Hilog.debug(0, "testTag", "Debug: Hello world!")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func error(UInt32, String, String, Array\<String>)

```cangjie
public static func error(domain: UInt32, tag: String, format: String, args: Array<String>): Unit
```

**功能：** 打印ERROR级别的日志。

**系统能力：** SystemCapability.HiviewDFX.HiLog

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|domain|UInt32|是|-|日志对应的领域标识，范围是0x0~0xFFFF，超出范围则日志无法打印。<br/>建议开发者在应用内根据需要自定义划分。|
|tag|String|是|-|指定日志标识，可以为任意字符串，建议用于标识调用所在的类或者业务行为。 tag最多为31字节，超出后会截断，不建议使用中文字符，可能出现乱码或者对齐问题。|
|format|String|是|-|格式字符串，用于日志的格式化输出。格式字符串中可以设置多个参数，参数需要包含参数类型、隐私标识。<br/>隐私标识分为{public}和{private}，缺省为{private}。标识{public}的内容明文输出，标识{private}的内容以\<private>过滤回显。|
|args|Array\<String>|是|-|与格式字符串format对应的可变长度参数列表。参数数目、参数类型必须与格式字符串中的标识一一对应。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    Hilog.error(0, "testTag", "Error: Hello world!")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func fatal(UInt32, String, String, Array\<String>)

```cangjie
public static func fatal(domain: UInt32, tag: String, format: String, args: Array<String>): Unit
```

**功能：** 打印FATAL级别的日志。

**系统能力：** SystemCapability.HiviewDFX.HiLog

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|domain|UInt32|是|-|日志对应的领域标识，范围是0x0~0xFFFF，超出范围则日志无法打印。<br/>建议开发者在应用内根据需要自定义划分。|
|tag|String|是|-|指定日志标识，可以为任意字符串，建议用于标识调用所在的类或者业务行为。tag最多为31字节，超出后会截断，不建议使用中文字符，可能出现乱码或者对齐问题。|
|format|String|是|-|格式字符串，用于日志的格式化输出。格式字符串中可以设置多个参数，参数需要包含参数类型、隐私标识。<br/>隐私标识分为{public}和{private}，缺省为{private}。标识{public}的内容明文输出，标识{private}的内容以\<private>过滤回显。|
|args|Array\<String>|是|-|与格式字符串format对应的可变长度参数列表。参数数目、参数类型必须与格式字符串中的标识一一对应。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    Hilog.fatal(0, "testTag", "Fatal: Hello world!")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func info(UInt32, String, String, Array\<String>)

```cangjie
public static func info(domain: UInt32, tag: String, format: String, args: Array<String>): Unit
```

**功能：** 打印INFO级别的日志。

**系统能力：** SystemCapability.HiviewDFX.HiLog

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|domain|UInt32|是|-|日志对应的领域标识，范围是0x0~0xFFFF，超出范围则日志无法打印。<br/>建议开发者在应用内根据需要自定义划分。|
|tag|String|是|-|指定日志标识，可以为任意字符串，建议用于标识调用所在的类或者业务行为。tag最多为31字节，超出后会截断，不建议使用中文字符，可能出现乱码或者对齐问题。|
|format|String|是|-|格式字符串，用于日志的格式化输出。格式字符串中可以设置多个参数，参数需要包含参数类型、隐私标识。<br/>隐私标识分为{public}和{private}，缺省为{private}。标识{public}的内容明文输出，标识{private}的内容以\<private>过滤回显。|
|args|Array\<String>|是|-|与格式字符串format对应的可变长度参数列表。参数数目、参数类型必须与格式字符串中的标识一一对应。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    Hilog.info(0, "testTag", "Info: Hello world!")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func isLoggable(UInt32, String, LogLevel)

```cangjie
public static func isLoggable(domain: UInt32, tag: String, level: LogLevel): Bool
```

**功能：** 在打印日志前调用该接口，用于检查指定领域标识、日志标识和级别的日志是否可以打印。

**系统能力：** SystemCapability.HiviewDFX.HiLog

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|domain|UInt32|是|-|日志对应的领域标识，范围是0x0~0xFFFF，超出范围则日志无法打印。<br/>建议开发者在应用内根据需要自定义划分。|
|tag|String|是|-|指定日志标识，可以为任意字符串，建议用于标识调用所在的类或者业务行为。tag最多为31字节，超出后会截断，不建议使用中文字符，可能出现乱码或者对齐问题。|
|level|[LogLevel](#enum-loglevel)|是|-|日志级别。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果返回true，则该领域标识、日志标识和级别的日志可以打印，否则不能打印。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    let result = Hilog.isLoggable(0, "testTag", LogLevel.Debug)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func warn(UInt32, String, String, Array\<String>)

```cangjie
public static func warn(domain: UInt32, tag: String, format: String, args: Array<String>): Unit
```

**功能：** 打印WARN级别的日志。

**系统能力：** SystemCapability.HiviewDFX.HiLog

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|domain|UInt32|是|-|日志对应的领域标识，范围是0x0~0xFFFF，超出范围则日志无法打印。<br/>建议开发者在应用内根据需要自定义划分。|
|tag|String|是|-|指定日志标识，可以为任意字符串，建议用于标识调用所在的类或者业务行为。tag最多为31字节，超出后会截断，不建议使用中文字符，可能出现乱码或者对齐问题。|
|format|String|是|-|格式字符串，用于日志的格式化输出。格式字符串中可以设置多个参数，参数需要包含参数类型、隐私标识。<br/>隐私标识分为{public}和{private}，缺省为{private}。标识{public}的内容明文输出，标识{private}的内容以\<private>过滤回显。|
|args|Array\<String>|是|-|与格式字符串format对应的可变长度参数列表。参数数目、参数类型必须与格式字符串中的标识一一对应。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    Hilog.warn(0, "testTag", "Warn: Hello world!")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## enum LogLevel

```cangjie
public enum LogLevel {
    | Debug
    | Info
    | Warning
    | Error
    | Fatal
    | ...
}
```

**功能：** 日志级别。

**系统能力：** SystemCapability.HiviewDFX.HiLog

**起始版本：** 22

### Debug

```cangjie
Debug
```

**功能：** 详细的流程记录，通过该级别的日志可以更详细地分析业务流程和定位分析问题。

**系统能力：** SystemCapability.HiviewDFX.HiLog

**起始版本：** 22

### Error

```cangjie
Error
```

**功能：** 应用发生了错误，该错误会影响功能的正常运行或用户的正常使用，可以恢复但恢复代价较高，如重置数据等。

**系统能力：** SystemCapability.HiviewDFX.HiLog

**起始版本：** 22

### Fatal

```cangjie
Fatal
```

**功能：** 重大致命异常，表明应用即将崩溃，故障无法恢复。

**系统能力：** SystemCapability.HiviewDFX.HiLog

**起始版本：** 22

### Info

```cangjie
Info
```

**功能：** 用于记录业务关键流程节点，可以还原业务的主要运行过程；

用于记录可预料的非正常情况信息，如无网络信号、登录失败等。

这些日志都应该由该业务内处于支配地位的模块来记录，避免在多个被调用的模块或低级函数中重复记录。

**系统能力：** SystemCapability.HiviewDFX.HiLog

**起始版本：** 22

### Warning

```cangjie
Warning
```

**功能：** 用于记录较为严重的非预期情况，但是对用户影响不大，应用可以自动恢复或通过简单的操作就可以恢复的问题。

**系统能力：** SystemCapability.HiviewDFX.HiLog

**起始版本：** 22
