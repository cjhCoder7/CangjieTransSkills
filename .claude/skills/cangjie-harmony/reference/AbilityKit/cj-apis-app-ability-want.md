# ohos.app.ability.want（Want）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

Want是对象间信息传递的载体，可以用于应用组件间的信息传递。

其典型应用场景之一是，当[UIAbility](./cj-apis-app-ability-ui_ability.md#class-uiability) A启动 UIAbility B、并需要传入一些数据时，可使用[Want](#class-want)作为载体。例如在[startAbility](./cj-apis-app-ability-ui_ability.md#func-startabilitywant-startoptions)接口的入参want中，可以通过abilityName指定启动的目标Ability，也可以通过parameters等字段携带其他数据。

## 导入模块

```cangjie
import kit.AbilityKit.*
```

## 权限列表

ohos.permission.DISTRIBUTED_DATASYNC

ohos.permission.PREPARE_APP_TERMINATE

ohos.permission.PRIVACY_WINDOW

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](./cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class Want

```cangjie
public class Want {
    public var deviceId: String
    public var bundleName: String
    public var abilityName: String
    public var moduleName: String
    public var flags: UInt32
    public var uri: String
    public var action: String
    public var entities: Array<String>
    public var dataType: String
    public var parameters: HashMap<String, WantValueType>
    public init(
        deviceId!: String = "",
        bundleName!: String = "",
        abilityName!: String = "",
        moduleName!: String = "",
        flags!: UInt32 = 0,
        uri!: String = "",
        action!: String = "",
        entities!: Array<String> = [],
        dataType!: String = "",
        parameters!: HashMap<String, WantValueType> = HashMap<String, WantValueType>(),
        fds!: HashMap<String, Int32> = HashMap<String, Int32>()
    )
}
```

**功能：** 用于描述应用组件启动请求的Want信息。

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### var abilityName

```cangjie
public var abilityName: String
```

**功能：** 应用的Ability组件名。在应用启动场景中表示被拉起方的Ability组件名。如果在Want中该字段同时指定了BundleName和AbilityName，则Want可以直接匹配到指定的Ability。AbilityName需要在一个应用的范围内保证唯一。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### var action

```cangjie
public var action: String
```

**功能：** 表示要执行的通用操作（如：查看、分享、应用详情）。在隐式Want中，开发者可以定义该action字段，配合uri或parameters来表示对数据执行的操作。隐式Want定义及匹配规则请参见[显式Want与隐式Want匹配规则](../../application-models/cj-explicit-implicit-want-mappings.md)。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### var bundleName

```cangjie
public var bundleName: String
```

**功能：** 应用包名。在应用启动场景中表示被拉起方的应用包名。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### var deviceId

```cangjie
public var deviceId: String
```

**功能：** 设备ID。在应用启动场景中表示被拉起方的设备ID，如果未设置该字段，则表示指定当前设备。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### var entities

```cangjie
public var entities: Array<String>
```

**功能：** 表示目标Ability额外的类别信息（如：浏览器、视频播放器）。在隐式Want中是对action字段的补充。在隐式Want中，开发者可以定义该entities字段，来过滤匹配Ability类型。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### var flags

```cangjie
public var flags: UInt32
```

**功能：** 表示处理Want的方式。值为枚举类型[Flags](./cj-apis-app-ability-want_constant.md#class-flags)，默认传数字。例如取值为0x00000001（即Flags.FLAG_AUTH_READ_URI_PERMISSION）表示临时授予接收方读取该Want对象中URI指向的数据的权限。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### var moduleName

```cangjie
public var moduleName: String
```

**功能：** 应用模块名。在应用启动场景中表示被拉起方的应用模块名。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### var parameters

```cangjie
public var parameters: HashMap<String, WantValueType>
```

**功能：** 表示WantParams描述。

以下Key均由系统赋值，开发者手动修改也不会生效，系统在数据传递时会自动修改为实际值。

- ohos.aafwk.param.callerPid：表示拉起方的pid，值为字符串类型。
- ohos.aafwk.param.callerBundleName：表示拉起方的BundleName，值为字符串类型。
- ohos.aafwk.param.callerAbilityName：表示拉起方的AbilityName，值为字符串类型。
- ohos.aafwk.param.callerNativeName：表示native调用时拉起方的进程名，值为字符串类型。
- ohos.aafwk.param.callerAppId：表示拉起应用的AppId信息，值为字符串类型。
- ohos.aafwk.param.callerAppIdentifier：表示拉起应用的AppIdentifier信息，值为字符串类型。
- ohos.aafwk.param.callerToken：表示拉起方的token，值为字符串类型。
- ohos.aafwk.param.callerUid：表示[BundleInfo](./cj-apis-bundle_manager.md#class-bundleinfo)中的uid，应用包里应用程序的uid，值为数值类型。
- ohos.param.callerAppCloneIndex：表示拉起方应用的分身索引，值为数值类型。
- component.startup.newRules：表示是否启用新的管控规则，值为布尔类型。
- moduleName：表示拉起方的moduleName，值为字符串类型。
- ohos.ability.params.abilityRecoveryRestart：表示当前Ability是否发生了故障恢复重启，值为布尔类型。

**类型：** HashMap\<String,[WantValueType](#enum-wantvaluetype)>

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### var uri

```cangjie
public var uri: String
```

**功能：** 统一资源标识符，一般在应用启动场景中配合type使用，指明待处理的数据类型。如果在Want中指定了uri，则Want将匹配指定的Uri信息，包括`scheme`、`schemeSpecificPart`、`authority`和`path`信息。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### var dataType

```cangjie
public var dataType: String
```

**功能：** 表示MIME type类型描述，打开文件的类型，主要用于文管打开文件。比如：'text/xml' 、 'image/*'等，MIME定义请参见[Media Types](https://www.iana.org/assignments/media-types/media-types.xhtml?utm_source=ld246.com)。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### init(String, String, String, String, UInt32, String, String, Array\<String>, String, HashMap\<String,WantValueType>, HashMap\<String,Int32>)

```cangjie
public init(
    deviceId!: String = "",
    bundleName!: String = "",
    abilityName!: String = "",
    moduleName!: String = "",
    flags!: UInt32 = 0,
    uri!: String = "",
    action!: String = "",
    entities!: Array<String> = [],
    dataType!: String = "",
    parameters!: HashMap<String, WantValueType> = HashMap<String, WantValueType>(),
    fds!: HashMap<String, Int32> = HashMap<String, Int32>()
)
```

**功能：** 构造函数，创建Want实例。

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|deviceId|String|否|""|**命名参数。** 设备ID。在应用启动场景中表示被拉起方的设备ID，如果未设置该字段，则表示指定当前设备。|
|bundleName|String|否|""|**命名参数。** 应用包名。在应用启动场景中表示被拉起方的应用包名。|
|abilityName|String|否|""|**命名参数。** 应用的Ability组件名。在应用启动场景中表示被拉起方的Ability组件名。如果在Want中该字段同时指定了BundleName和AbilityName，则Want可以直接匹配到指定的Ability。AbilityName需要在一个应用的范围内保证唯一。|
|moduleName|String|否|""|**命名参数。** 应用模块名。在应用启动场景中表示被拉起方的应用模块名。|
|flags|UInt32|否|0|**命名参数。** 表示处理Want的方式。值为枚举类型[Flags](./cj-apis-app-ability-want_constant.md#class-flags)，默认传数字。<br />例如取值为0x00000001（即Flags.FLAG_AUTH_READ_URI_PERMISSION）表示临时授予接收方读取该URI指向的数据的权限。|
|uri|String|否|""|**命名参数。** 统一资源标识符，一般在应用启动场景中配合type使用，指明待处理的数据类型。如果在Want中指定了uri，则Want将匹配指定的Uri信息，包括`scheme`、`schemeSpecificPart`、`authority`和`path`信息。|
|action|String|否|""|**命名参数。** 表示要执行的通用操作（如：查看、分享、应用详情）。在隐式Want中，开发者可以定义该字段，配合uri或parameters来表示对数据执行的操作。隐式Want定义及匹配规则请参见[显式Want与隐式Want匹配规则](../../application-models/cj-explicit-implicit-want-mappings.md)。|
|entities|Array\<String>|否|[]|**命名参数。** 表示目标Ability额外的类别信息（如：浏览器、视频播放器）。在隐式Want中是对action字段的补充。在隐式Want中，开发者可以定义该字段，来过滤匹配Ability类型。|
|dataType|String|否|""|**命名参数。** 表示MIME type类型描述，打开文件的类型，主要用于文管打开文件。比如：'text/xml' 、 'image/*'等，MIME定义请参见[Media Types](https://www.iana.org/assignments/media-types/media-types.xhtml?utm_source=ld246.com)。|
|parameters|HashMap\<String,[WantValueType](#enum-wantvaluetype)>|否|HashMap<String, WantValueType>()|**命名参数。** 表示WantParams描述。|
|fds|HashMap\<String,Int32>|否|HashMap<String, Int32>()|**命名参数。** 表示文件描述符，在启动场景中拉起方写入的FD，会设置到该参数中。|

**异常：**

- BusinessException：对应错误码如下表，详见[元能力子系统错误码](./cj-errorcode-ability.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 16000050 | Internal error. |

## enum WantValueType

```cangjie
public enum WantValueType {
    | Int64Value(Int64)
    | Float64Value(Float64)
    | StringValue(String)
    | BoolValue(Bool)
    | ArrayValue(Array<WantValueType>)
    | HashMapValue(HashMap<String, WantValueType>)
    | ...
}
```

**功能：** Want值类型。

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### ArrayValue(Array\<WantValueType>)

```cangjie
ArrayValue(Array<WantValueType>)
```

**功能：** 数组值。

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### BoolValue(Bool)

```cangjie
BoolValue(Bool)
```

**功能：** 布尔值。

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### Float64Value(Float64)

```cangjie
Float64Value(Float64)
```

**功能：** 64位浮点值。

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### HashMapValue(HashMap\<String, WantValueType>)

```cangjie
HashMapValue(HashMap<String, WantValueType>)
```

**功能：** 哈希映射值。

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### Int64Value(Int64)

```cangjie
Int64Value(Int64)
```

**功能：** 64位整数值。

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### StringValue(String)

```cangjie
StringValue(String)
```

**功能：** 字符串值。

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22
