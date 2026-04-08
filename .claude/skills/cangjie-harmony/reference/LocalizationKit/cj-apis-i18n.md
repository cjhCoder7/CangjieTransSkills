# ohos.i18n（国际化-I18n）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

i18n模块提供系统相关的或者增强的[国际化](../../internationalization/cj-i18n-l10n.md)能力，包括区域管理、电话号码处理、日历等，相关接口为ECMA 402标准中未定义的补充接口。

## 导入模块

```cangjie
import kit.LocalizationKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## func getCalendar(String, ?CalendarType)

```cangjie
public func getCalendar(locale: String, calendarType!: ?CalendarType = None): Calendar
```

**功能：** 获取指定区域和历法的日历对象。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|locale|String|是|-|表示区域信息的字符串，由语言、脚本、国家地区组成，例如zh-Hans-CN。|
|calendarType|?CalendarType|否|None|**命名参数。** 表示历法，取值包括：buddhist,&nbsp;chinese,&nbsp;coptic,&nbsp;ethiopic,&nbsp;hebrew,&nbsp;gregory,&nbsp;indian,&nbsp;islamic_civil,&nbsp;islamic_tbla,&nbsp;islamic_umalqura,&nbsp;japanese,&nbsp;persian。<br>默认值：区域默认的历法。|

**返回值：**

|类型|说明|
|:----|:----|
|Calendar|日历对象。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.i18n.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let calendar = getCalendar("en-US", calendarType: CalendarType.Buddhist)// 获得一个基于 en-US 区域设置的佛教日历对象
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class Calendar

```cangjie
public class Calendar {}
```

**功能：** 提供历法相关的能力，包括历法名称获取和日期计算等。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

### func add(String, Int32)

```cangjie
public func add(field: String, amount: Int32): Unit
```

**功能：** 对日历对象中的表示时间日期的日历属性值进行加减操作。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|指定的日历属性，目前支持的属性值有&nbsp;year,&nbsp;month,&nbsp;week_of_year,&nbsp;week_of_month,&nbsp;date,&nbsp;day_of_year,&nbsp;day_of_week,&nbsp;day_of_week_in_month,&nbsp;hour,&nbsp;hour_of_day,&nbsp;minute,&nbsp;second,&nbsp;millisecond。<br>各取值代表的含义请参考[get](#func-getstring)。|
|amount|Int32|是|-|进行加减操作的具体数值。|

**异常：**

- BusinessException：对应错误码如下表，详见[i18n错误码](./cj-errorcode-i18n.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 890001 | Invalid parameter. Possible causes: Parameter verification failed. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.getCalendar
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let calendar = getCalendar("zh-Hans")
    calendar.set(2021,11,11) // set time to 2021.12.11
    calendar.add("year", 3)
    let res = calendar.get("year") // res = 2024
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func get(String)

```cangjie
public func get(field: String): Int32
```

**功能：** 获取日历对象中日历属性的值。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|指定的日历属性，目前支持的属性值请参考下表。|

| 属性名称   | 说明                                       |
| ----- | ---------------------------------------- |
| era | 纪元，例如公历中的公元前或者公元后。 |
| year | 年。 |
| month | 月。说明：月份从0开始计数，例如0表示一月。 |
| date | 日。 |
| hour | 挂钟小时数。 |
| hour_of_day | 一天中的第几小时。 |
| minute | 分。 |
| second | 秒。 |
| millisecond | 毫秒。 |
| week_of_year | 一年中的第几周，按照星期计算周，注意：第一周的归属算法各地有区别。 |
| year_woy | 一年中的第几周，按照数值计算周，例如一年中前1~7日属于第一周。 |
| week_of_month | 一个月中的第几周，按照星期计算周。 |
| day_of_week_in_month | 一月中的第几周，按照数值计算周，例如1-7日属于第一周。 |
| day_of_year | 一年中的第几天。 |
| day_of_week | 一周中的第几天(星期)。 |
| milliseconds_in_day | 一天中的第几毫秒。 |
| zone_offset | 以毫秒计时的时区固定偏移量（不含夏令时）。 |
| dst_offset | 以毫秒计时的夏令时偏移量。 |
| dow_local | 本地星期。 |
| extended_year | 扩展的年份数值，支持负数。 |
| julian_day | 儒略日,与当前时区相关。 |
| is_leap_month | 是否为闰月。 |

**返回值：**

|类型|说明|
|:----|:----|
|Int32|日历属性的值，如当前Calendar对象的内部日期的年份为1990，get('year')返回1990。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.getCalendar
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let calendar = getCalendar("en-US")
    calendar.set(2024, 1, 1, hour: 12, minute: 30, second: 30)
    let year = calendar.get("year") // 2024
    let month = calendar.get("month") // 1
    let date = calendar.get("date") // 1
    let hour = calendar.get("hour_of_day") // 12
    let minute = calendar.get("minute") // 30
    let second = calendar.get("second") // 30
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getDisplayName(String)

```cangjie
public func getDisplayName(locale: String): String
```

**功能：** 获取日历对象名称在指定语言下的翻译。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|locale|String|是|-|表示区域ID的字符串，由语言、脚本、国家地区组成。|

**返回值：**

|类型|说明|
|:----|:----|
|String|日历对象名称在指定语言下的翻译。如buddhist在en-US上显示的名称为“Buddhist&nbsp;Calendar”。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.getCalendar
import ohos.i18n.CalendarType
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let calendar = getCalendar("en-US", calendarType: CalendarType.Buddhist)
    let res = calendar.getDisplayName("zh") // res = "佛历"
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getFirstDayOfWeek()

```cangjie
public func getFirstDayOfWeek(): Int32
```

**功能：** 获取系统设置的周起始日。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Int32|周起始日。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.getCalendar
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let calendar = getCalendar("en-US")
    let res = calendar.getFirstDayOfWeek() // res = 1
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getMinimalDaysInFirstWeek()

```cangjie
public func getMinimalDaysInFirstWeek(): Int32
```

**功能：** 获取日历对象一年中第一周的最小天数。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Int32|一年中第一周的最小天数。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.getCalendar
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let calendar = getCalendar("zh-Hans")
    let res = calendar.getMinimalDaysInFirstWeek() // res = 1
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getTimeInMillis()

```cangjie
public func getTimeInMillis(): Float64
```

**功能：** 获取当前日历对象的时间戳。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Float64|Unix时间戳，表示从1970.1.1&nbsp;00:00:00&nbsp;GMT逝去的毫秒数。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.getCalendar
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let calendar = getCalendar("en-US")
    calendar.setTime(5000.0)
    let millis = calendar.getTimeInMillis() // millis = 5000
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getTimeZone()

```cangjie
public func getTimeZone(): String
```

**功能：** 创建对应时区城市的时区对象。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|时区城市ID，要求是系统支持的时区城市ID。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.getCalendar
import ohos.i18n.CalendarType
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let calendar = getCalendar("zh-Hans", calendarType: CalendarType.Chinese)
    calendar.setTimeZone("Asia/Shanghai")
    let timeZone = calendar.getTimeZone() // timeZone = "Asia/Shanghai"
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func set(Int32, Int32, Int32, ?Int32, ?Int32, ?Int32)

```cangjie
public func set(year: Int32, month: Int32, date: Int32, hour!: ?Int32 = None, minute!: ?Int32 = None, second!: ?Int32 = None): Unit
```

**功能：** 设置日历对象的年、月、日、时、分、秒。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|year|Int32|是|-|设置的年。|
|month|Int32|是|-|设置的月。说明：月份从0开始计数，如0表示一月。|
|date|Int32|是|-|设置的日。|
|hour|?Int32|否|None|**命名参数。** 设置的小时。默认值：系统当前时间。|
|minute|?Int32|否|None|**命名参数。** 设置的分钟。默认值：系统当前时间。|
|second|?Int32|否|None|**命名参数。** 设置的秒。默认值：系统当前时间。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.getCalendar
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let calendar = getCalendar("zh-Hans")
    calendar.set(2021,11,11)  // set time to 2021.12.11
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setFirstDayOfWeek(Int32)

```cangjie
public func setFirstDayOfWeek(value: Int32): Unit
```

**功能：** 设置日历对象的周起始日。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|Int32|是|-|一周的起始日，1代表周日，7代表周六。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.getCalendar
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let calendar = getCalendar("zh-Hans")
    calendar.setFirstDayOfWeek(3)
    let firstDayOfWeek = calendar.getFirstDayOfWeek() // firstDayOfWeek = 3
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setMinimalDaysInFirstWeek(Int32)

```cangjie
public func setMinimalDaysInFirstWeek(value: Int32): Unit
```

**功能：** 设置日历对象一年中第一周的最小天数。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|Int32|是|-|一年中第一周的最小天数。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.getCalendar
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let calendar = getCalendar("zh-Hans")
    calendar.setMinimalDaysInFirstWeek(3)
    let minimalDaysInFirstWeek = calendar.getMinimalDaysInFirstWeek() // minimalDaysInFirstWeek = 3
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setTime(Float64)

```cangjie
public func setTime(time: Float64): Unit
```

**功能：** 基于传入的时间戳，设置日历对象内部的时间、日期。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|time|Float64|是|-|Unix时间戳，表示从1970.1.1&nbsp;00:00:00&nbsp;GMT逝去的毫秒数。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.getCalendar
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let calendar = getCalendar("en-US")
    calendar.setTime(10540800000.0)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func setTimeZone(String)

```cangjie
public func setTimeZone(timeZone: String): Unit
```

**功能：** 设置日历对象的时区。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|timeZone|String|是|-|合法的时区ID，如“Asia/Shanghai”。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.LocalizationKit.getCalendar
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let calendar = getCalendar("en-US")
    calendar.setTimeZone("Asia/Shanghai")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class System

```cangjie
public class System {}
```

**功能：** I18n系统对象。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

### static func getAppPreferredLanguage()

```cangjie
public static func getAppPreferredLanguage(): String
```

**功能：** 获取应用偏好语言。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|应用偏好语言。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.i18n.*
import kit.LocalizationKit.getCalendar
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let appPreferredLanguage = System.getAppPreferredLanguage() // 获取应用偏好语言
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## enum CalendarType

```cangjie
public enum CalendarType {
    | Buddhist
    | Chinese
    | Coptic
    | Ethiopic
    | Hebrew
    | Gregory
    | Indian
    | IslamicCivil
    | IslamicTbla
    | IslamicUmalqura
    | Japanese
    | Persian
    | ...
}
```

**功能：** 日历类型枚举，用于指定不同的日历系统。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

### Buddhist

```cangjie
Buddhist
```

**功能：** 佛历。

**系统能力：**  SystemCapability.Global.I18n

**起始版本：** 22

### Chinese

```cangjie
Chinese
```

**功能：** 农历。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

### Coptic

```cangjie
Coptic
```

**功能：** 科普特历。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

### Ethiopic

```cangjie
Ethiopic
```

**功能：** 埃塞俄比亚历。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

### Hebrew

```cangjie
Hebrew
```

**功能：** 希伯来历。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

### Gregory

```cangjie
Gregory
```

**功能：** 公历。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

### Indian

```cangjie
Indian
```

**功能：** 印度历。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

### IslamicCivil

```cangjie
IslamicCivil
```

**功能：** 伊斯兰希吉来历。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

### IslamicTbla

```cangjie
IslamicTbla
```

**功能：** 伊斯兰天文历。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

### IslamicUmalqura

```cangjie
IslamicUmalqura
```

**功能：** 伊斯兰历（乌姆库拉）。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

### Japanese

```cangjie
Japanese
```

**功能：** 日本历。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22

### Persian

```cangjie
Persian
```

**功能：** 波斯历。

**系统能力：** SystemCapability.Global.I18n

**起始版本：** 22
