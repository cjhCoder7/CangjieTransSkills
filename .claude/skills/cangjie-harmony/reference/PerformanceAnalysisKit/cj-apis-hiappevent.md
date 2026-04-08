# ohos.hiviewdfx.hi_app_event（应用事件打点）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

hi_app_event模块提供应用打点和事件订阅能力，包括事件存储、事件订阅、事件清理、打点配置等功能。[HiAppEvent](#class-hiappevent)将应用运行过程中触发的事件信息统一归纳到[AppEventInfo](#class-appeventinfo)中，并将事件分为系统事件和应用事件两类。

系统事件来源于系统服务，是系统预先定义的事件，这类事件信息中的事件参数对象params包含的字段已由各系统事件定义，具体字段含义在各系统事件指南的介绍中。

应用事件来源于应用，是应用开发者自己定义的事件，这类事件信息支持自定义后通过[Write](#static-func-writeappeventinfo)打点接口进行配置设定，具体字段含义可结合开发者需求展开。

## 导入模块

```cangjie
import kit.PerformanceAnalysisKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class AppEventFilter

```cangjie
public class AppEventFilter {
    public var domain: String
    public var eventTypes: Array<EventType>
    public var names: Array<String>
    public init(domain: String, eventTypes!: Array<EventType> = [], names!: Array<String> = [])
}
```

**功能：** 提供设置[Watcher](#class-watcher)的订阅过滤条件的参数选项。用于在事件观察者中设置事件过滤条件，确保只有满足过滤条件的事件才会被监听处理。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var domain

```cangjie
public var domain: String
```

**功能：** 需要订阅的事件领域。可以是系统事件领域（hiAppEvent.domain.OS）或开发者在使用[Write](#static-func-writeappeventinfo)接口时传入的自定义事件信息（[AppEventInfo](#class-appeventinfo)）中的事件领域。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var eventTypes

```cangjie
public var eventTypes: Array<EventType>
```

**功能：** 需要订阅的事件类型集合。

**类型：** Array\<[EventType](#enum-eventtype)>

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var names

```cangjie
public var names: Array<String>
```

**功能：** 需要订阅的事件名称集合。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### init(String, Array\<EventType>, Array\<String>)

```cangjie
public init(domain: String, eventTypes!: Array<EventType> = [], names!: Array<String> = [])
```

**功能：** 创建[AppEventFilter](#class-appeventfilter)实例。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|domain|String|是|-|需要订阅的事件领域。可以是系统事件领域（hiAppEvent.domain.OS）或开发者在使用[Write](#static-func-writeappeventinfo)接口时传入的自定义事件信息（[AppEventInfo](#class-appeventinfo)）中的事件领域。|
|eventTypes|Array\<[EventType](#enum-eventtype)>|否|[]|**命名参数。** 需要订阅的事件类型集合。默认不进行过滤。|
|names|Array\<String>|否|[]|**命名参数。** 需要订阅的事件名称集合。默认不进行过滤。|

## class AppEventGroup

```cangjie
public class AppEventGroup {
    public var name: String
    public var appEventInfos: Array<AppEventInfo>
}
```

**功能：** 提供订阅返回的事件组的参数定义。可用于获取事件组的详细信息，事件组常在[Watcher](#class-watcher)的onReceive回调中使用。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var appEventInfos

```cangjie
public var appEventInfos: Array<AppEventInfo>
```

**功能：** 事件对象集合。

**类型：** Array\<[AppEventInfo](#class-appeventinfo)>

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var name

```cangjie
public var name: String
```

**功能：** 事件名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

## class AppEventInfo

```cangjie
public class AppEventInfo {
    public var domain: String
    public var name: String
    public var eventType: EventType
    public var params: HashMap<String, EventValueType>
    public init(domain: String, name: String, event: EventType, params: HashMap<String, EventValueType>)
}
```

**功能：** 提供事件信息的参数选项。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var domain

```cangjie
public var domain: String
```

**功能：** 事件领域。事件领域名称支持数字、字母、下划线字符，需要以字母开头且不能以下划线结尾，长度非空且不超过32个字符。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var eventType

```cangjie
public var eventType: EventType
```

**功能：** 事件类型。

**类型：** [EventType](#enum-eventtype)

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var name

```cangjie
public var name: String
```

**功能：** 事件名称。首字符必须为字母字符或$字符，中间字符必须为数字字符、字母字符或下划线字符，结尾字符必须为数字字符或字母字符，长度非空且不超过48个字符。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var params

```cangjie
public var params: HashMap<String, EventValueType>
```

**功能：** 事件参数对象，包含每个事件参数的参数名和参数值。针对应用事件，[Write](#static-func-writeappeventinfo)打点写入的参数由开发者定义，其规格如下：

- 参数名为StringValue类型，首字符必须为字母字符或`$`字符，中间字符必须为数字字符、字母字符或下划线字符，结尾字符必须为数字字符或字母字符，长度非空且不超过32个字符。如testName、\$123_name等。

- 参数值支持StringValue、IntValue、FloatValue、BoolValue、数组类型。StringValue类型参数长度需在8*1024个字符以内，超出后会和对应的参数名一同被丢弃；IntValue、FloatValue类型参数取值需在-(2^53 - 1)~2^53 - 1范围内，超出可能会产生不确定值；数组类型参数中的元素类型只能全为StringValue、IntValue、FloatValue、BoolValue中的一种，且元素个数需在100以内，超出部分即从第101个元素开始会被丢弃。

- 参数个数需在32个以内，超出的参数会做丢弃处理。

**类型：** HashMap\<String,[EventValueType](#enum-eventvaluetype)>

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### init(String, String, EventType, HashMap\<String,EventValueType>)

```cangjie
public init(domain: String, name: String, event: EventType, params: HashMap<String, EventValueType>)
```

**功能：** 创建[AppEventInfo](#class-appeventinfo)实例。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|domain|String|是|-|事件领域。事件领域名称支持数字、字母、下划线字符，需要以字母开头且不能以下划线结尾，长度非空且不超过32个字符。|
|name|String|是|-|事件名称。首字符必须为字母字符或$字符，中间字符必须为数字字符、字母字符或下划线字符，结尾字符必须为数字字符或字母字符，长度非空且不超过48个字符。|
|event|[EventType](#enum-eventtype)|是|-|事件类型。|
|params|HashMap\<String,[EventValueType](#enum-eventvaluetype)>|是|-|事件参数对象，包含每个事件参数的参数名和参数值。|

## class AppEventPackage

```cangjie
public class AppEventPackage {
    public var packageId: Int32
    public var row: Int32
    public var size: Int32
    public var data: Array<String>
}
```

**功能：** 提供订阅返回的事件包的参数定义。可用于获取事件包的详细信息，事件包由[takeNext](#func-takenext)接口获得。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var data

```cangjie
public var data: Array<String>
```

**功能：** 事件包的事件信息。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var packageId

```cangjie
public var packageId: Int32
```

**功能：** 事件包ID，从0开始自动递增。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var row

```cangjie
public var row: Int32
```

**功能：** 事件包的事件数量。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var size

```cangjie
public var size: Int32
```

**功能：** 事件包的事件大小，单位为byte。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

## class AppEventPackageHolder

```cangjie
public class AppEventPackageHolder {
    public init(watcherName: String)
}
```

**功能：** 订阅数据持有者类，用于对订阅事件进行处理。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### init(String)

```cangjie
public init(watcherName: String)
```

**功能：** 类构造函数，用于创建订阅数据持有者实例。先通过[addWatcher](#static-func-addwatcherwatcher)添加事件观察者，再通过观察者名称关联到应用内已添加的观察者对象。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|watcherName|String|是|-|已通过[addWatcher](#static-func-addwatcherwatcher)添加的事件观察者名称。若未通过addWatcher添加，则默认无数据。|

**异常：**

- BusinessException：对应错误码如下表，详见[应用事件打点错误码](./cj-errorcode-hiappevent.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 11105001 | Parameter error. |

### func setSize(Int32)

```cangjie
public func setSize(size: Int32): Unit
```

**功能：** 设置每次取出的应用事件包的数据大小阈值。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|size|Int32|是|-|数据大小阈值，单位为byte。取值范围[0, 2^31-1]，超出范围会抛异常。|

**异常：**

- BusinessException：对应错误码如下表，详见[应用事件打点错误码](./cj-errorcode-hiappevent.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 11104001 | Invalid size value. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    // 添加数据观察者“Watcher1”，订阅监听系统事件
    HiAppEvent.addWatcher(Watcher(
        "Watcher1",
        appEventFilters: [ AppEventFilter("button")]
    ))

    let holder = AppEventPackageHolder("watcher2")
    holder.setSize(100)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func takeNext()

```cangjie
public func takeNext(): Option<AppEventPackage>
```

**功能：** 获取订阅事件。

系统根据setSize设置的数据大小阈值或setRow设置的条数来取出订阅事件数据，默认取1条订阅事件。当订阅事件数据全部被取出时返回None。

当setRow和setSize同时调用时仅setRow生效。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Option\<[AppEventPackage](#class-appeventpackage)>|取出的事件包对象，订阅事件数据被全部取出后会返回None。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    let holder = AppEventPackageHolder("watcher3")
    if (let Some(v) <- holder.takeNext()) {
        let eventPkg = v
        Hilog.info(0, "AppLogCj", "HiAppEvent packageId=${eventPkg.packageId}", "")
        Hilog.info(0, "AppLogCj", "HiAppEvent row=${eventPkg.row}", "")
        Hilog.info(0, "AppLogCj", "HiAppEvent size=${eventPkg.size}", "")
    }
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class AppEventReportConfig

```cangjie
public class AppEventReportConfig {
    public var domain: String
    public var name: String
    public var isRealTime: Bool
    public init(domain!: String = "", name!: String = "", isRealTime!: Bool = false)
}
```

**功能：** 数据处理者可以上报事件的描述配置。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var domain

```cangjie
public var domain: String
```

**功能：** 事件领域。事件领域名称支持数字、字母、下划线字符，需要以字母开头且不能以下划线结尾，长度非空且不超过32个字符。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var isRealTime

```cangjie
public var isRealTime: Bool
```

**功能：** 是否实时上报事件。配置值为true表示实时上报事件，false表示不实时上报事件。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var name

```cangjie
public var name: String
```

**功能：** 事件名称。首字符必须为字母字符或$字符，中间字符必须为数字字符、字母字符或下划线字符，结尾字符必须为数字字符或字母字符，长度非空且不超过48个字符。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### init(String, String, Bool)

```cangjie
public init(domain!: String = "", name!: String = "", isRealTime!: Bool = false)
```

**功能：** 创建[AppEventReportConfig](#class-appeventreportconfig)实例。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|domain|String|否|""|**命名参数。** 事件领域。默认为空字符串，事件领域名称支持数字、字母、下划线字符，需要以字母开头且不能以下划线结尾，长度非空且不超过32个字符。|
|name|String|否|""|**命名参数。** 事件名称。默认为空字符串，首字符必须为字母字符或$字符，中间字符必须为数字字符、字母字符或下划线字符，结尾字符必须为数字字符或字母字符，长度非空且不超过48个字符。|
|isRealTime|Bool|否|false|**命名参数。** 是否实时上报事件。默认值为false，配置值为true表示实时上报事件，false表示不实时上报事件。|

## class ConfigOption

```cangjie
public class ConfigOption {
    public var disable: Bool
    public var maxStorage: String
    public init(disable!: Bool = false, maxStorage!: String = "10M")
}
```

**功能：** 提供对应用事件打点功能的配置选项。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var disable

```cangjie
public var disable: Bool
```

**功能：** 打点功能开关。true：关闭打点功能，false：开启打点功能。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var maxStorage

```cangjie
public var maxStorage: String
```

**功能：** 打点数据存放目录的配额大小。建议配额大小不超过10M，配额过大可能会影响接口效率。

在目录大小超出配额后，下次打点会触发对目录的清理操作：按从旧到新的顺序逐个删除打点数据文件，直到目录大小不超出配额时结束。

配额值字符串规格如下：

- 配额值字符串只由数字字符和大小单位字符（单位字符支持[b\|k\|kb\|m\|mb\|g\|gb\|t\|tb]，不区分大小写）构成。

- 配额值字符串必须以数字开头，后面可以选择不传单位字符（默认使用byte作为单位），或者以单位字符结尾。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### init(Bool, String)

```cangjie
public init(disable!: Bool = false, maxStorage!: String = "10M")
```

**功能：** 创建[ConfigOption](#class-configoption)实例。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|disable|Bool|否|false|**命名参数。** 打点功能开关。|
|maxStorage|String|否|"10M"|**命名参数。** 打点数据存放目录的配额大小，默认值为“10M”。建议配额大小不超过10M，配额过大可能会影响接口效率。|

## class Domain

```cangjie
public class Domain {
    public static const OS = "OS"
}
```

**功能：** 提供领域名称常量。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### static const OS

```cangjie
public static const OS = "OS"
```

**功能：** 系统领域。

**类型：** String

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

## class Event

```cangjie
public class Event {
    public static const USER_LOGIN = "hiappevent.user_login"
    public static const USER_LOGOUT = "hiappevent.user_logout"
    public static const DISTRIBUTED_SERVICE_START = "hiappevent.distributed_service_start"
    public static const APP_CRASH = "APP_CRASH"
    public static const APP_FREEZE = "APP_FREEZE"
}
```

**功能：** 提供事件名称常量。包含系统事件名称常量和应用事件名称常量，其中应用事件名称常量是为开发者在调用[Write](#static-func-writeappeventinfo)接口进行应用事件打点时预留的可选自定义事件名称。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### static const APP_CRASH

```cangjie
public static const APP_CRASH = "APP_CRASH"
```

**功能：** 应用崩溃事件。系统事件名称常量。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### static const APP_FREEZE

```cangjie
public static const APP_FREEZE = "APP_FREEZE"
```

**功能：** 应用冻屏事件。系统事件名称常量。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### static const DISTRIBUTED_SERVICE_START

```cangjie
public static const DISTRIBUTED_SERVICE_START = "hiappevent.distributed_service_start"
```

**功能：** 分布式服务启动事件。预留的应用事件名称常量。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### static const USER_LOGIN

```cangjie
public static const USER_LOGIN = "hiappevent.user_login"
```

**功能：** 用户登录事件。预留的应用事件名称常量。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### static const USER_LOGOUT

```cangjie
public static const USER_LOGOUT = "hiappevent.user_logout"
```

**功能：** 用户登出事件。预留的应用事件名称常量。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

## class HiAppEvent

```cangjie
public class HiAppEvent {}
```

**功能：** 该类提供了应用事件打点能力。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### static func addProcessor(Processor)

```cangjie
public static func addProcessor(processor: Processor): Int64
```

**功能：** 添加数据处理者配置信息，用于配置处理者接收的事件名等信息。事件发生后处理者可以接收事件。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|processor|[Processor](#class-processor)|是|-|上报事件的数据处理者。|

**返回值：**

|类型|说明|
|:----|:----|
|Int64|所添加上报事件数据处理者的ID，标识唯一数据处理者，可用于移除数据处理者。 添加失败返回-1，添加成功返回大于0的值。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    var processor : Processor = Processor("test_processor")
    let processorId = HiAppEvent.addProcessor(processor)
    Hilog.info(0, "AppLogCj", "HiAppEvent::processorId is ${processorId}.", "")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func addWatcher(Watcher)

```cangjie
public static func addWatcher(watcher: Watcher): Option<AppEventPackageHolder>
```

**功能：** 添加事件观察者。可通过事件观察者的回调函数监听事件。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|watcher|[Watcher](#class-watcher)|是|-|事件观察者。|

**返回值：**

|类型|说明|
|:----|:----|
|Option\<[AppEventPackageHolder](#class-appeventpackage)>|订阅数据持有者，订阅失败时返回None。|

**异常：**

- BusinessException：对应错误码如下表，详见[应用事件打点错误码](./cj-errorcode-hiappevent.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 11102001 | Invalid watcher name. Possible causes: 1. Contain invalid characters; 2. Length is invalid. |
  | 11102002 | Invalid filtering event domain. Possible causes: 1. Contain invalid characters; 2. Length is invalid. |
  | 11102003 | Invalid row value. Possible caused by the row value is less than zero. |
  | 11102004 | Invalid size value. Possible caused by the size value is less than zero. |
  | 11102005 | Invalid timeout value. Possible caused by the timeout value is less than zero. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.PerformanceAnalysisKit.*

func f1() {
    // 如果观察者传入了回调的相关参数，则可以选择在自动触发的回调函数中对订阅事件进行处理
    var condition = TriggerCondition(row: 1)
    var appEventFilter = [AppEventFilter("button")]
    var watcher = Watcher(
        "watcher1",
        triggerCondition: condition,
        onTrigger: Some(
            {
                row, size, holder =>
                    Hilog.info(0, "AppLogCj", "HiAppEvent onTrigger: curRow=${row}, curSize=${size}", "")
                    while (let Some(v) <- holder.takeNext()) {
                        let eventPkg = v
                        Hilog.info(0, "AppLogCj", "HiAppEvent packageId=${eventPkg.packageId}", "")
                        Hilog.info(0, "AppLogCj", "HiAppEvent row=${eventPkg.row}", "")
                        Hilog.info(0, "AppLogCj", "HiAppEvent size=${eventPkg.size}", "")
                        for (i in 0..eventPkg
                                .data
                                .size) {
                            Hilog.info(0, "AppLogCj", "HiAppEvent info=${eventPkg.data[i]}", "")
                        }
                    }
            }
        )
    )
    HiAppEvent.addWatcher(watcher)
}

func f2() {
    // 如果观察者未传入回调的相关参数，则可以选择使用返回的holder对象手动去处理订阅事件
    let watcher = Watcher("watcher2")
    let holder = HiAppEvent.addWatcher(watcher)
    if (let Some(v1) <- holder) {
        while (let Some(v2) <- v1.takeNext()) {
            let eventPkg = v2
            Hilog.info(0, "test_hiAppEvent_addWatcher", "HiAppEvent packageId=${eventPkg.packageId}", "")
            Hilog.info(0, "test_hiAppEvent_addWatcher", "HiAppEvent row=${eventPkg.row}", "")
            Hilog.info(0, "test_hiAppEvent_addWatcher", "HiAppEvent size=${eventPkg.size}", "")
            for (i in 0..eventPkg
                    .data
                    .size) {
                Hilog.info(0, "test_hiAppEvent_addWatcher", "HiAppEvent info=${eventPkg.data[i]}", "")
            }
        }
    }
}

func f3() {
    // 观察者可以在实时回调函数onReceive中处理订阅事件
    var condition = TriggerCondition(row: 1, size: 100)
    let watcher = Watcher(
        "watcher",
        triggerCondition: condition,
        onTrigger: {
            row, size, holder => Hilog.info(0, "AppLogCj", "HiAppEvent onTrigger: curRow=${row}, curSize=${size}", "")
        },
        onReceive: {
            domain, AppEventGroups =>
                Hilog.info(0, "AppLogCj", "domain =${domain}")
                let groupSize = AppEventGroups.size
                for (i in 0..groupSize) {
                    Hilog.info(0, "AppLogCj", "name =${AppEventGroups[i].name}", "")
                    let appInfosize = AppEventGroups[i]
                        .appEventInfos
                        .size
                    for (j in 0..appInfosize) {
                        Hilog.info(0, "AppLogCj", "appEventInfo name=${AppEventGroups[i].appEventInfos[j].name}", "")
                        Hilog.info(0, "AppLogCj", "appEventInfo domain=${AppEventGroups[i].appEventInfos[j].domain}", "")
                        let paSize = AppEventGroups[i]
                            .appEventInfos[j]
                            .params
                            .size
                        for ((k, v) in AppEventGroups[i]
                                .appEventInfos[j]
                                .params) {
                            Hilog.info(0x0000, "HiAppEnvent", "key=${k}", "")
                            Hilog.info(0x0000, "HiAppEnvent", "value=${v.toString()}", "")
                        }
                    }
                }
        }
    )
    HiAppEvent.addWatcher(watcher)
}

func test() {
    f1()
    f2()
    f3()
}
```

### static func clearData()

```cangjie
public static func clearData(): Unit
```

**功能：** 应用事件打点数据清理方法，将当前应用存储在本地的打点数据进行清除。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.PerformanceAnalysisKit.*
import std.collection.ArrayList
import std.collection.HashMap
import ohos.business_exception.BusinessException

try {
    let params = HashMap<String, EventValueType>()
    params.add("cangjie", IntValue(1001))
    params.add("cangjie2", StringValue("1001"))
    var appInfo: AppEventInfo = AppEventInfo("cangjie1", "test_event", EventType.Fault, params)
    HiAppEvent.write(appInfo)
    HiAppEvent.clearData()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func configure(ConfigOption)

```cangjie
public static func configure(config: ConfigOption): Unit
```

**功能：** 应用事件打点配置方法，支持配置打点开关和目录存储配额大小。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|config|[ConfigOption](#class-configoption)|是|-|应用事件打点配置项对象。|

**异常：**

- BusinessException：对应错误码如下表，详见[应用事件打点错误码](./cj-errorcode-hiappevent.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 11103001 | Invalid max storage quota value. Possible caused by incorrectly formatted. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    var config : ConfigOption = ConfigOption(maxStorage: "100M", disable: true)
    HiAppEvent.configure(config)
    Hilog.info(0, "AppLogCj", "HiAppEvent::configure.")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func getUserId(String)

```cangjie
public static func getUserId(name: String): String
```

**功能：** 获取通过setUserId接口设置的value值。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-|用户ID的key。只能包含大小写字母、数字、下划线和 $，不能以数字开头，长度非空且不超过256个字符。|

**返回值：**

|类型|说明|
|:----|:----|
|String|用户ID的值。没有查到返回空字符串。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    HiAppEvent.setUserId("test_getUserId_name", "test_getUserId_value")
    let userIdName = HiAppEvent.getUserId("test_getUserId_name")
    Hilog.info(0, "AppLogCj", "HiAppEvent::test_getUserId is ${userIdName}.")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func getUserProperty(String)

```cangjie
public static func getUserProperty(name: String): String
```

**功能：** 获取通过setUserProperty接口设置的value值。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-|用户属性的key。只能包含大小写字母、数字、下划线和 $，不能以数字开头，长度非空且不超过256个字符。|

**返回值：**

|类型|说明|
|:----|:----|
|String|用户属性的值。没有查到返回空字符串。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    HiAppEvent.setUserProperty("test_setUserProperty_name", "test_setUserProperty_value")
    let propertyName = HiAppEvent.getUserProperty("test_getUserProperty_name")
    Hilog.info(0, "AppLogCj", "HiAppEvent::test_getUserProperty is ${propertyName}.")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func removeProcessor(Int64)

```cangjie
public static func removeProcessor(id: Int64): Unit
```

**功能：** 移除上报事件的数据处理者。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|id|Int64|是|-|上报事件数据处理者ID。值大于0。由调用[addProcessor](#static-func-addprocessorprocessor)接口返回值所得。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    var processor : Processor = Processor("test_processor")
    let processorId = HiAppEvent.addProcessor(processor)
    HiAppEvent.removeProcessor(processorId)
    Hilog.info(0, "AppLogCj", "HiAppEvent::removeProcessor test over.")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func removeWatcher(Watcher)

```cangjie
public static func removeWatcher(watcher: Watcher): Unit
```

**功能：** 移除事件观察者。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|watcher|[Watcher](#class-watcher)|是|-|事件观察者。|

**异常：**

- BusinessException：对应错误码如下表，详见[应用事件打点错误码](./cj-errorcode-hiappevent.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 11102001 | Invalid watcher name. Possible causes: 1. Contain invalid characters; 2. Length is invalid. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    // 定义一个应用事件观察者
    let watcher= Watcher("watcher1")
    // 添加一个应用事件观察者来订阅事件
    HiAppEvent.addWatcher(watcher)
    // 移除该应用事件观察者以取消订阅事件
    HiAppEvent.removeWatcher(watcher)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func setUserId(String, String)

```cangjie
public static func setUserId(name: String, value: String): Unit
```

**功能：** 设置用户ID值。用于在配置[Processor](#class-processor)数据处理者时进行关联。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-|用户ID的key。只能包含大小写字母、数字、下划线和 $，不能以数字开头，长度非空且不超过256个字符。|
|value|String|是|-|用户ID的值。长度不超过256，当值为空字符串时，则清除用户ID。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    HiAppEvent.setUserId("test_getUserId_name", "test_getUserId_value")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func setUserProperty(String, String)

```cangjie
public static func setUserProperty(name: String, value: String): Unit
```

**功能：** 设置用户属性值。用于在配置[Processor](#class-processor)数据处理者时进行关联。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-|用户属性的key。只能包含大小写字母、数字、下划线和 $，不能以数字开头，长度非空且不超过256个字符。|
|value|String|是|-|用户属性的值。长度不超过1024，当值为空字符串时，则清除用户属性。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    HiAppEvent.setUserProperty("test_setUserProperty_name", "test_setUserProperty_value")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func write(AppEventInfo)

```cangjie
public static func write(info: AppEventInfo): Unit
```

**功能：** 应用事件打点方法，将AppEventInfo类型的事件进行存储。通过此接口写入的事件对象是开发者自定义的对象，为了避免与系统事件产生冲突混淆，不建议写入系统事件（[Event](#class-event)中定义的系统事件名称常量）。此接口写入的事件可通过订阅事件观察者（[addWatcher](#static-func-addwatcherwatcher)）进行订阅。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|info|[AppEventInfo](#class-appeventinfo)|是|-|应用事件对象。其内部定义的事件名称建议避免与[Event](#class-event)中定义的系统事件名称常量产生冲突。|

**异常：**

- BusinessException：对应错误码如下表，详见[应用事件打点错误码](./cj-errorcode-hiappevent.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 11100001 | Function is disabled. Possible caused by the param disable in ConfigOption is true. |
  | 11101001 | Invalid event domain.Possible causes: 1. Contain invalid characters; 2. Length is invalid. |
  | 11101002 | Invalid event name. Possible causes: 1. Contain invalid characters; 2. Length is invalid. |
  | 11101003 | Invalid number of event parameters. Possible caused by the number of parameters is over 32. |
  | 11101004 | Invalid string length of the event parameter. |
  | 11101005 | Invalid event parameter name. Possible causes: 1. Contain invalid characters; 2. Length is invalid. |
  | 11101006 | Invalid array length of a event parameter. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException
import std.collection.HashMap

try {
    let params = HashMap<String, EventValueType>()
    params.add("cangjie", IntValue(1001))
    params.add("cangjie2", StringValue("1001"))
    var appInfo: AppEventInfo = AppEventInfo("cangjie1", "test_event", EventType.Fault, params)
    HiAppEvent.write(appInfo)
    HiAppEvent.clearData()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class Param

```cangjie
public class Param {
    public static const USER_ID = "user_id"
    public static const DISTRIBUTED_SERVICE_NAME = "ds_name"
    public static const DISTRIBUTED_SERVICE_INSTANCE_ID = "ds_instance_id"
}
```

**功能：** 提供参数名称常量。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### static const DISTRIBUTED_SERVICE_INSTANCE_ID

```cangjie
public static const DISTRIBUTED_SERVICE_INSTANCE_ID = "ds_instance_id"
```

**功能：** 分布式服务实例ID。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### static const DISTRIBUTED_SERVICE_NAME

```cangjie
public static const DISTRIBUTED_SERVICE_NAME = "ds_name"
```

**功能：** 分布式服务名称。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### static const USER_ID

```cangjie
public static const USER_ID = "user_id"
```

**功能：** 用户自定义ID。

**类型：** String

**读写能力：** 只读

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

## class Processor

```cangjie
public class Processor {
    public var name: String
    public var debugMode: Bool
    public var routeInfo: String
    public var appId: String
    public var onStartReport: Bool
    public var onBackgroundReport: Bool
    public var periodReport: Int32
    public var batchReport: Int32
    public var userIds: Array<String>
    public var userProperties: Array<String>
    public var eventConfigs: Array<AppEventReportConfig>
    public init(name: String, debugMode!: Bool = false, routeInfo!: String = "", appId!: String = "",
        onStartReport!: Bool = false, onBackgroundReport!: Bool = false, periodReport!: Int32 = 0,
        batchReport!: Int32 = 0, userIds!: Array<String> = [], userProperties!: Array<String> = [],
        eventConfigs!: Array<AppEventReportConfig> = [])
}
```

**功能：** 可以上报事件的数据处理者对象。用于事件的上报和管理，开发者可自定义数据处理配置，满足不同的数据处理需求。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var appId

```cangjie
public var appId: String
```

**功能：** 应用id。传入字符串长度不能超过8KB，超过时会被置为空字符串。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var batchReport

```cangjie
public var batchReport: Int32
```

**功能：** 事件上报阈值，当事件条数达到阈值时上报事件。传入数值必须大于0且小于1000，不在数值范围内会被置为0，不进行上报。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var debugMode

```cangjie
public var debugMode: Bool
```

**功能：** 是否开启debug模式。配置值为true表示开启debug模式，false表示不开启debug模式。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var eventConfigs

```cangjie
public var eventConfigs: Array<AppEventReportConfig>
```

**功能：** 数据处理者配置id。传入数值必须大于或等于0，小于0时会被置为0。传入的值大于0时，与数据处理者的名称name共同唯一标识数据处理者。

**类型：** Array\<[AppEventReportConfig](#class-appeventreportconfig)>

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var name

```cangjie
public var name: String
```

**功能：** 数据处理者的名称。名称只能包含大小写字母、数字、下划线和$，不能以数字开头，长度非空且不超过256个字符。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var onBackgroundReport

```cangjie
public var onBackgroundReport: Bool
```

**功能：** 当应用程序进入后台时是否上报事件。配置值为true表示上报事件，false表示不上报事件。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var onStartReport

```cangjie
public var onStartReport: Bool
```

**功能：** 数据处理者在启动时是否上报事件。配置值为true表示上报事件，false表示不上报事件。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var periodReport

```cangjie
public var periodReport: Int32
```

**功能：** 事件定时上报时间周期，单位为秒。传入数值必须大于或等于0，小于0时会被置为0，不进行定时上报。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var routeInfo

```cangjie
public var routeInfo: String
```

**功能：** 服务器位置信息。传入字符串长度不能超过8KB，超过时会被置为空字符串。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var userIds

```cangjie
public var userIds: Array<String>
```

**功能：** 数据处理者可以上报的用户ID的name数组。name对应[setUserId](#static-func-setuseridstring-string)接口的name参数。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var userProperties

```cangjie
public var userProperties: Array<String>
```

**功能：** 数据处理者可以上报的用户属性的name数组。name对应[setUserProperty](#static-func-setuserpropertystring-string)接口的name参数。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### init(String, Bool, String, String, Bool, Bool, Int32, Int32, Array\<String>, Array\<String>, Array\<AppEventReportConfig>)

```cangjie
public init(name: String, debugMode!: Bool = false, routeInfo!: String = "", appId!: String = "",
    onStartReport!: Bool = false, onBackgroundReport!: Bool = false, periodReport!: Int32 = 0,
    batchReport!: Int32 = 0, userIds!: Array<String> = [], userProperties!: Array<String> = [],
    eventConfigs!: Array<AppEventReportConfig> = [])
```

**功能：** 创建[Processor](#class-processor)实例。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-|数据处理者的名称。名称只能包含大小写字母、数字、下划线和 $，不能以数字开头，长度非空且不超过256个字符。|
|debugMode|Bool|否|false|**命名参数。** 是否开启debug模式，默认值为false。配置值为true表示开启debug模式，false表示不开启debug模式。|
|routeInfo|String|否|""|**命名参数。** 服务器位置信息，默认为空字符串。传入字符串长度不能超过8KB，超过时会被置为默认值。|
|appId|String|否|""|**命名参数。** 应用id，默认为空字符串。传入字符串长度不能超过8KB，超过时会被置为默认值。|
|onStartReport|Bool|否|false|**命名参数。** 数据处理者在启动时是否上报事件，默认值为false。配置值为true表示上报事件，false表示不上报事件。|
|onBackgroundReport|Bool|否|false|**命名参数。** 当应用程序进入后台时是否上报事件，默认值为false。配置值为true表示上报事件，false表示不上报事件。|
|periodReport|Int32|否|0|**命名参数。** 事件定时上报时间周期，单位为秒。传入数值必须大于或等于0，小于0时会被置为默认值0，不进行定时上报。|
|batchReport|Int32|否|0|**命名参数。** 事件上报阈值，当事件条数达到阈值时上报事件。传入数值必须大于0且小于1000，不在数值范围内会被置为默认值0，不进行上报。|
|userIds|Array\<String>|否|[]|**命名参数。** 数据处理者可以上报的用户ID的name数组。name对应[setUserId](#static-func-setuseridstring-string)接口的name参数。默认为空数组。|
|userProperties|Array\<String>|否|[]|**命名参数。** 数据处理者可以上报的用户属性的name数组。name对应[setUserProperty](#static-func-setuserpropertystring-string)接口的name参数。默认为空数组。|
|eventConfigs|Array\<[AppEventReportConfig](#class-appeventreportconfig)>|否|[]|**命名参数。** 数据处理者配置id。传入数值必须大于或等于0，小于0时会被置为默认值0。传入的值大于0时，与数据处理者的名称name共同唯一标识数据处理者。|

## class TriggerCondition

```cangjie
public class TriggerCondition {
    public var row: Int32
    public var size: Int32
    public var timeOut: Int32
    public init(row!: Int32 = 0, size!: Int32 = 0, timeOut!: Int32 = 0)
}
```

**功能：** 提供设置[Watcher](#class-watcher)的onTrigger回调触发条件的参数选项。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var row

```cangjie
public var row: Int32
```

**功能：** 满足触发回调的事件总数量，正整数。设置为0，不触发回调。传入负值时，会被置为0。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var size

```cangjie
public var size: Int32
```

**功能：** 满足触发回调的事件总大小，正整数，单位为byte。设置为0，不触发回调。传入负值时，会被置为0。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var timeOut

```cangjie
public var timeOut: Int32
```

**功能：** 满足触发回调的超时时长，正整数，单位为30s。设置为0，不触发回调。传入负值时，会被置为0。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### init(Int32, Int32, Int32)

```cangjie
public init(row!: Int32 = 0, size!: Int32 = 0, timeOut!: Int32 = 0)
```

**功能：** 创建[TriggerCondition](#class-triggercondition)实例。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|row|Int32|否|0|**命名参数。** 满足触发回调的事件总数量，正整数。默认值0，不触发回调。传入负值时，会被置为默认值。|
|size|Int32|否|0|**命名参数。** 满足触发回调的事件总大小，正整数，单位为byte。默认值0，不触发回调。传入负值时，会被置为默认值。|
|timeOut|Int32|否|0|**命名参数。** 满足触发回调的超时时长，正整数，单位为30s。默认值0，不触发回调。传入负值时，会被置为默认值。|

## class Watcher

```cangjie
public class Watcher {
    public var name: String
    public var triggerCondition: TriggerCondition
    public var appEventFilters: Array<AppEventFilter>
    public var onTrigger: Option <(Int32, Int32, AppEventPackageHolder) -> Unit>
    public var onReceive: Option <(String, Array<AppEventGroup>) -> Unit>
    public init(name: String, triggerCondition!: TriggerCondition = TriggerCondition(),
        appEventFilters!: Array<AppEventFilter> = [],
        onTrigger!: Option<(Int32, Int32, AppEventPackageHolder) -> Unit> = None,
        onReceive!: Option<(String, Array<AppEventGroup>) -> Unit> = None)
}
```

**功能：** 提供事件观察者的参数选项。用于配置和管理事件的观察者，实现对特定事件的监听和处理。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var appEventFilters

```cangjie
public var appEventFilters: Array<AppEventFilter>
```

**功能：** 订阅过滤条件，在需要对订阅事件进行过滤时传入。

**类型：** Array\<[AppEventFilter](#class-appeventfilter)>

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var name

```cangjie
public var name: String
```

**功能：** 观察者名称，用于唯一标识观察者。首字符必须为字母字符，中间字符必须为数字字符、字母字符或下划线字符，结尾字符必须为数字字符或字母字符，长度非空且不超过32个字符。如testName1、crash_Watcher等。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var onReceive

```cangjie
public var onReceive: Option <(String, Array<AppEventGroup>) -> Unit>
```

**功能：** 订阅实时回调函数，与回调函数onTrigger同时存在时，只触发此回调，函数入参说明如下：

domain：回调事件的领域名称；

appEventGroups：回调事件集合。

**类型：** [AppEventGroup](#class-appeventgroup)->Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var onTrigger

```cangjie
public var onTrigger: Option <(Int32, Int32, AppEventPackageHolder) -> Unit>
```

**功能：** 订阅回调函数，需要与回调触发条件triggerCondition一同传入才会生效，函数入参说明如下：

curRow：在本次回调触发时的订阅事件总数量；

curSize：在本次回调触发时的订阅事件总大小，单位为byte；

holder：订阅数据持有者对象，可以通过其对订阅事件进行处理。

**类型：** (Int32,Int32,[AppEventPackageHolder](#class-appeventpackageholder))->Unit

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### var triggerCondition

```cangjie
public var triggerCondition: TriggerCondition
```

**功能：** 订阅回调触发条件，需要与回调函数onTrigger一同传入才会生效。

**类型：** [TriggerCondition](#class-triggercondition)

**读写能力：** 可读写

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### init(String, TriggerCondition, Array\<AppEventFilter>, Option\<(Int32,Int32,AppEventPackageHolder) -> Unit>, Option\<(String,Array\<AppEventGroup>) -> Unit>)

```cangjie
public init(name: String, triggerCondition!: TriggerCondition = TriggerCondition(),
    appEventFilters!: Array<AppEventFilter> = [],
    onTrigger!: Option<(Int32, Int32, AppEventPackageHolder) -> Unit> = None,
    onReceive!: Option<(String, Array<AppEventGroup>) -> Unit> = None)
```

**功能：** 创建[Watcher](#class-watcher)实例。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-|观察者名称，用于唯一标识观察者。首字符必须为字母字符，中间字符必须为数字字符、字母字符或下划线字符，结尾字符必须为数字字符或字母字符，长度非空且不超过32个字符。如testName1、crash_Watcher等。|
|triggerCondition|[TriggerCondition](#class-triggercondition)|否|TriggerCondition()|**命名参数。** 订阅回调触发条件，需要与回调函数onTrigger一同传入才会生效。默认不触发。|
|appEventFilters|Array\<[AppEventFilter](#class-appeventfilter)>|否|[]|**命名参数。** 订阅过滤条件，在需要对订阅事件进行过滤时传入。默认不过滤事件。|
|onTrigger|Option\<(Int32,Int32,[AppEventPackageHolder](#class-appeventpackageholder))->Unit>|否|None|**命名参数。** 订阅回调函数，需要与回调触发条件triggerCondition一同传入才会生效。|
|onReceive|Option\<(String,Array\<[AppEventGroup](#class-appeventgroup)>)->Unit>|否|None|**命名参数。** 订阅实时回调函数，与回调函数onTrigger同时存在时，只触发此回调。|

## enum EventType

```cangjie
public enum EventType {
    | Fault
    | Statistic
    | Security
    | Behavior
    | ...
}
```

**功能：** 事件类型枚举。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### Behavior

```cangjie
Behavior
```

**功能：** 行为类型事件。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### Fault

```cangjie
Fault
```

**功能：** 故障类型事件。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### Security

```cangjie
Security
```

**功能：** 安全类型事件。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### Statistic

```cangjie
Statistic
```

**功能：** 统计类型事件。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

## enum EventValueType

```cangjie
public enum EventValueType <: ToString {
    | IntValue(Int32)
    | FloatValue(Float64)
    | StringValue(String)
    | BoolValue(Bool)
    | ArrString(Array<String>)
    | ArrInt32(Array<Int32>)
    | ArrBool(Array<Bool>)
    | ArrFloat64(Array<Float64>)
    | Int64Value(Int64)
    | ArrInt64(Array<Int64>)
    | ...
}
```

**功能：** 事件参数值数据。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**父类型：**

- ToString

### ArrBool(Array\<Bool>)

```cangjie
ArrBool(Array<Bool>)
```

**功能：** Bool类型数组数据。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### ArrFloat64(Array\<Float64>)

```cangjie
ArrFloat64(Array<Float64>)
```

**功能：** Float64类型数组数据。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### ArrInt32(Array\<Int32>)

```cangjie
ArrInt32(Array<Int32>)
```

**功能：** Int32类型数组数据。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### ArrInt64(Array\<Int64>)

```cangjie
ArrInt64(Array<Int64>)
```

**功能：** Int64类型数组数据。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### ArrString(Array\<String>)

```cangjie
ArrString(Array<String>)
```

**功能：** 字符串数组数据。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### BoolValue(Bool)

```cangjie
BoolValue(Bool)
```

**功能：** 布尔类型数据。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### FloatValue(Float64)

```cangjie
FloatValue(Float64)
```

**功能：** Float64类型数据。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### Int64Value(Int64)

```cangjie
Int64Value(Int64)
```

**功能：** Int64类型数据。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### IntValue(Int32)

```cangjie
IntValue(Int32)
```

**功能：** Int32类型数据。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### StringValue(String)

```cangjie
StringValue(String)
```

**功能：** 字符串类型数据。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

### func toString()

```cangjie
public func toString(): String
```

**功能：** 返回数据的字符串表示。

**系统能力：** SystemCapability.HiviewDFX.HiAppEvent

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|数据的字符串表示。|

**异常：**

- BusinessException：对应错误码如下表，详见[应用事件打点错误码](./cj-errorcode-hiappevent.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 11105001 | Parameter error. |
