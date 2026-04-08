# ohos.data.preferences（用户首选项）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

用户首选项为应用提供Key-Value键值型的数据处理能力，支持应用持久化轻量级数据，并对其修改和查询。

数据存储形式为键值对，键的类型为字符串型，值的存储数据类型包括数字型、字符型、布尔型以及这3种类型的数组类型。

## 导入模块

```cangjie
import kit.ArkData.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。
- 正确的[dataGroupId](#var-datagroupid)需要向应用市场获取。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## const MAX_KEY_LENGTH

```cangjie
public const MAX_KEY_LENGTH: UInt32 = 1024
```

**功能：** Key的最大长度，限制为1024个字节。

**类型：** UInt32

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

## const MAX_VALUE_LENGTH

```cangjie
public const MAX_VALUE_LENGTH: UInt32 = 16 * 1024 * 1024
```

**功能：** Value的最大长度，限制为16MB。

**类型：** UInt32

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

## class PreferencesOptions

```cangjie
public class PreferencesOptions {
    public var name: String
    public var dataGroupId: String
    public var storageType: StorageType
    public init(name: String, dataGroupId!: String = String.empty,
        storageType!: StorageType = StorageType.Xml)
}
```

**功能：** Preferences实例配置选项。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### var dataGroupId

```cangjie
public var dataGroupId: String
```

**功能：** 应用组ID，<!--RP1-->暂不支持指定dataGroupId在对应共享沙箱路径下创建Preferences实例。<!--RP1End-->

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### var name

```cangjie
public var name: String
```

**功能：** Preferences实例的名称。名称长度需大于零且小于等于255字节，名称中不能包含'/'且不能以'/'结尾。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### var storageType

```cangjie
public var storageType: StorageType
```

**功能：** 存储模式。表示当前Preferences实例需要使用的存储模式。当选择某种存储模式创建Preferences后，不支持中途切换存储模式。

**类型：** [StorageType](#enum-storagetype)

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### init(String, String, StorageType)

```cangjie
public init(name: String, dataGroupId!: String = String.empty,
    storageType!: StorageType = StorageType.Xml)
```

**功能：** 用于创建PreferencesOptions实例的构造函数。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-|Preferences实例的名称。名称长度需大于零且小于等于255字节，名称中不能包含'/'且不能以'/'结尾。|
|dataGroupId|String|否|String.empty|**命名参数。** 应用组ID，为可选参数。|
|storageType|[StorageType](#enum-storagetype)|否|StorageType.Xml|**命名参数。** 存储模式。表示当前Preferences实例需要使用的存储模式。当选择某种存储模式创建Preferences后，不支持中途切换存储模式。|

## class Preferences

```cangjie
public class Preferences {}
```

**功能：** 首选项实例，提供获取和修改存储数据的接口。

下列接口都需先使用[getPreferences](#static-func-getpreferencesuiabilitycontext-preferencesoptions)获取到Preferences实例，再通过此实例调用对应接口。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### static func deletePreferences(UIAbilityContext, String)

```cangjie
public static func deletePreferences(context: UIAbilityContext, name: String): Unit
```

**功能：** 从缓存中删除指定的Preferences实例，若Preferences实例有对应的持久化文件，则同时删除其持久化文件。

调用该接口后，不建议再使用旧的Preferences实例进行数据操作，否则会导致数据一致性问题。

不支持该接口与其他preference接口并发调用。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|[UIAbilityContext](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)|是|-|应用上下文。|
|name|String|是|-|Preferences实例的名称。|

**异常：**

- BusinessException：对应错误码如下表，详见[用户首选项错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 15500000 | Inner error. |
  | 15500010 | Failed to delete the user preferences persistence file. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 获取 Preferences 实例
    let preferences = Preferences.getPreferences(Global.abilityContext, "myStore")  // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    // 删除 Preferences 实例
    Preferences.deletePreferences(Global.abilityContext, "myStore")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func deletePreferences(UIAbilityContext, PreferencesOptions)

```cangjie
public static func deletePreferences(context: UIAbilityContext, options: PreferencesOptions): Unit
```

**功能：** 从缓存中删除指定的Preferences实例，若Preferences实例有对应的持久化文件，则同时删除其持久化文件。

调用该接口后，不建议再使用旧的Preferences实例进行数据操作，否则会导致数据一致性问题。

不支持该接口与其他preference接口并发调用。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|[UIAbilityContext](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)|是|-|应用上下文。|
|options|[PreferencesOptions](#class-preferencesoptions)|是|-|与Preferences实例相关的配置选项。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[用户首选项错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | Capability not supported. |
  | 15500000 | Inner error. |
  | 15500010 | Failed to delete the user preferences persistence file. |
  | 15501001 | The operations is supported in stage mode only. |
  | 15501002 | Invalid dataGroupId. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 获取 Preferences 实例
    let preferences = Preferences.getPreferences(Global.abilityContext, "myStore")  // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    // 删除 Preferences 实例
    Preferences.deletePreferences(Global.abilityContext, "myStore")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func getPreferences(UIAbilityContext, String)

```cangjie
public static func getPreferences(context: UIAbilityContext, name: String): Preferences
```

**功能：** 获取Preferences实例。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|[UIAbilityContext](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)|是|-|应用上下文。|
|name|String|是|-|Preferences实例的名称。|

**返回值：**

|类型|说明|
|:----|:----|
|[Preferences](#class-preferences)|返回Preferences实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[用户首选项错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 15500000 | Inner error. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let preferences = Preferences.getPreferences(Global.abilityContext, "mystore") // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    // 删除 Preferences 实例的缓存
    Preferences.removePreferencesFromCache(Global.abilityContext, PreferencesOptions("mystore", dataGroupId:"myGroupID"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func getPreferences(UIAbilityContext, PreferencesOptions)

```cangjie
public static func getPreferences(context: UIAbilityContext, options: PreferencesOptions): Preferences
```

**功能：** 获取Preferences实例。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|[UIAbilityContext](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)|是|-|应用上下文。|
|options|[PreferencesOptions](#class-preferencesoptions)|是|-|与Preferences实例相关的配置选项。|

**返回值：**

|类型|说明|
|:----|:----|
|[Preferences](#class-preferences)|返回Preferences实例。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[用户首选项错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | Capability not supported. |
  | 15500000 | Inner error. |
  | 15501001 | The operations is supported in stage mode only. |
  | 15501002 | Invalid dataGroupId. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let preferences = Preferences.getPreferences(Global.abilityContext, PreferencesOptions("mystore", dataGroupId:"myGroupID")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    // 删除 Preferences 实例的缓存
    Preferences.removePreferencesFromCache(Global.abilityContext, PreferencesOptions("mystore", dataGroupId:"myGroupID"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func removePreferencesFromCache(UIAbilityContext, String)

```cangjie
public static func removePreferencesFromCache(context: UIAbilityContext, name: String): Unit
```

**功能：** 从缓存中移除指定的Preferences实例。

应用首次调用[getPreferences](#static-func-getpreferencesuiabilitycontext-string)接口获取某个Preferences实例后，该实例会被缓存起来。后续再次调用getPreferences时，不会再从持久化文件中读取，而是直接从缓存中获取Preferences实例。

调用此接口移除缓存中的实例之后，再次调用getPreferences将会重新读取持久化文件，生成新的Preferences实例。

调用该接口后，不建议再使用旧的Preferences实例进行数据操作，否则会出现数据一致性问题。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|[UIAbilityContext](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)|是|-|应用上下文。|
|name|String|是|-|Preferences实例的名称。|

**异常：**

- BusinessException：对应错误码如下表，详见[用户首选项错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 15500000 | Inner error. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let preferences = Preferences.getPreferences(Global.abilityContext, PreferencesOptions("mystore", dataGroupId:"myGroupID")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    // 删除 Preferences 实例的缓存
    Preferences.removePreferencesFromCache(Global.abilityContext, PreferencesOptions("mystore", dataGroupId:"myGroupID"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func removePreferencesFromCache(UIAbilityContext, PreferencesOptions)

```cangjie
public static func removePreferencesFromCache(context: UIAbilityContext, options: PreferencesOptions): Unit
```

**功能：** 从缓存中移除指定的Preferences实例。

应用首次调用[getPreferences](#static-func-getpreferencesuiabilitycontext-preferencesoptions)接口获取某个Preferences实例后，该实例会被缓存起来，后续再次[getPreferences](#static-func-getpreferencesuiabilitycontext-preferencesoptions)时不会再次从持久化文件中读取，直接从缓存中获取Preferences实例。调用此接口移出缓存中的实例之后，再次getPreferences将会重新读取持久化文件，生成新的Preferences实例。

调用该接口后，不建议再使用旧的Preferences实例进行数据操作，否则会出现数据一致性问题。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|[UIAbilityContext](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)|是|-|应用上下文。|
|options|[PreferencesOptions](#class-preferencesoptions)|是|-|与Preferences实例相关的配置选项。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[事件错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | Capability not supported. |
  | 15500000 | Inner error. |
  | 15501001 | The operations is supported in stage mode only. |
  | 15501002 | Invalid dataGroupId. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let preferences = Preferences.getPreferences(Global.abilityContext, PreferencesOptions("mystore", dataGroupId:"myGroupID")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    // 删除 Preferences 实例的缓存
    Preferences.removePreferencesFromCache(Global.abilityContext, PreferencesOptions("mystore", dataGroupId:"myGroupID"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func clear()

```cangjie
public func clear(): Unit
```

**功能：** 清除缓存的Preferences实例中的所有数据，可通过[flush](#func-flush)将Preferences实例持久化。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[用户首选项错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 15500000 | Inner error. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let preferences = Preferences.getPreferences(Global.abilityContext, PreferencesOptions("mystore", dataGroupId:"myGroupID")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    preferences.put("myKey", PreferencesValueType.StringData("myValue"))
    preferences.clear()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func delete(String)

```cangjie
public func delete(key: String): Unit
```

**功能：** 从缓存的Preferences实例中删除名为给定Key的存储键值对，可通过[flush](#func-flush)将Preferences实例持久化。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|key|String|是|-|要删除的存储Key名称，不能为空，最大长度限制为[MAX_KEY_LENGTH](#const-max_key_length)。|

**异常：**

- BusinessException：对应错误码如下表，详见[用户首选项错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 15500000 | Inner error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 获取 Preferences 实例
    let preferences = Preferences.getPreferences(Global.abilityContext, "myStore") // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    preferences.delete("startup")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func flush()

```cangjie
public func flush(): Unit
```

**功能：** 将缓存的Preferences实例中的数据存储到用户首选项的持久化文件中。

> **说明：**
>
> - 当数据未修改或修改后的数据与缓存数据一致时，不会刷新持久化文件。
>
> - 只在XML存储模式下使用。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[用户首选项错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 15500000 | Inner error. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let preferences = Preferences.getPreferences(Global.abilityContext, PreferencesOptions("mystore", dataGroupId:"myGroupID")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    preferences.put("myKey", PreferencesValueType.StringData("myValue"))
    preferences.flush()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func get(String, PreferencesValueType)

```cangjie
public func get(key: String, defValue: PreferencesValueType): PreferencesValueType
```

**功能：** 从缓存的Preferences实例中获取键对应的值，如果值为null或者非默认值类型，返回默认数据defValue。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|key|String|是|-|要获取的存储Key名称，不能为空，最大长度限制为[MAX_KEY_LENGTH](#const-max_key_length)。|
|defValue|[PreferencesValueType](#enum-preferencesvaluetype)|是|-|默认返回值。支持Int64、Float64、String、Bool、 Array\<Bool>、Array\<Float64>、Array\<String>。|

**返回值：**

|类型|说明|
|:----|:----|
|[PreferencesValueType](#enum-preferencesvaluetype)|返回键对应的值。|

**异常：**

- BusinessException：对应错误码如下表，详见[用户首选项错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 15500000 | Inner error. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException

try {
    let preferences = Preferences.getPreferences(Global.abilityContext, PreferencesOptions("mystore", dataGroupId:"myGroupID")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    var value = preferences.get("key", PreferencesValueType.Integer(0))
    match (value) {
        case PreferencesValueType.Integer(n) => Hilog.info(0, "AppLogCj", "获取到的值为${n}")
        case _ => Hilog.info(0, "AppLogCj", "获取到的值并不是 Int")
    }
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getAll()

```cangjie
public func getAll(): HashMap<String, PreferencesValueType>
```

**功能：** 获取缓存的Preferences实例中的所有键值数据。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|HashMap\<String,[PreferencesValueType](#enum-preferencesvaluetype)>|HashMap对象，返回所有包含的键值数据。|

**异常：**

- BusinessException：对应错误码如下表，详见[用户首选项错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 15500000 | Inner error. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException

try {
    let preferences = Preferences.getPreferences(Global.abilityContext, PreferencesOptions("mystore", dataGroupId:"myGroupID")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    var values = preferences.getAll()
    for ((k, v) in values) {
        match (v) {
            case Integer(n) => Hilog.info(0, "AppLogCj", "获得到的键值对key: ${k} value: ${n}")
            case Double(n) => Hilog.info(0, "AppLogCj", "获得到的键值对key: ${k} value: ${n}")
            case StringData(n) => Hilog.info(0, "AppLogCj", "获得到的键值对key: ${k} value: ${n}")
            case _ => Hilog.info(0, "AppLogCj", "其他值")
        }
    }
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func has(String)

```cangjie
public func has(key: String): Bool
```

**功能：** 检查缓存的Preferences实例中是否包含名为给定Key的存储键值对。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|key|String|是|-|要检查的存储key名称，不能为空，最大长度限制为[MAX_KEY_LENGTH](#const-max_key_length)。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|Bool值。返回Preferences实例是否包含给定key的存储键值对，true表示存在，false表示不存在。|

**异常：**

- BusinessException：对应错误码如下表，详见[用户首选项错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 15500000 | Inner error. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let preferences = Preferences.getPreferences(Global.abilityContext, PreferencesOptions("mystore", dataGroupId:"myGroupID")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let hasKey = preferences.has("startup")
    if (hasKey) {
        Hilog.info(0, "AppLogCj", "The key 'startup' is contained.")
    } else {
        Hilog.info(0, "AppLogCj", "The key 'startup' dose not contain.")
    }
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(PreferencesEvent, ?Callback1Argument\<String>)

```cangjie
public func off(event: PreferencesEvent, callback!: ?Callback1Argument<String> = None): Unit
```

**功能：** 取消订阅数据变更/取消订阅进程间数据变更。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|[PreferencesEvent](#enum-preferencesevent)|是|-|事件类型，表示取消订阅数据变更，或表示取消订阅进程间数据变更。|
|callback|?[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<String>|否|None|**命名参数。** 需要取消的回调函数，不填写则全部取消。<br> String: 发生变化的Key的类型。|

**异常：**

- BusinessException：对应错误码如下表，详见[用户首选项错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 15500000 | Inner error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException

// 此处代码可添加在依赖项定义中
// 回调函数
class Callback <: Callback1Argument<String> {
    public func invoke(err: ?BusinessException, arg: String): Unit {
        Hilog.info(0, "AppLogCj", "=========callback========= ${arg.toString()}======================")
    }
}

try {
    var str = "container"
    var a = Preferences.getPreferences(Global.abilityContext, str) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    var c = Callback()
    a.on(PreferencesEvent.PreferencesChange, c)
    a.off(PreferencesEvent.PreferencesChange)
    a.put("kkk1", PreferencesValueType.StringData("vvv1"))
    a.flush()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(PreferencesEvent, Callback1Argument\<String>)

```cangjie
public func on(event: PreferencesEvent, callback: Callback1Argument<String>): Unit
```

**功能：** 订阅数据变更。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|[PreferencesEvent](#enum-preferencesevent)|是|-|事件类型。<br> PreferencesChange 时，表示订阅数据变更，订阅的Key的值发生变更后，在执行flush方法后，触发callback回调。<br> PreferencesMultiProcessChange 时，表示订阅进程间数据变更，多个进程持有同一个首选项文件时，订阅的Key的值在任意一个进程发生变更后，执行flush方法后，触发callback回调。|
|callback|[Callback1Argument](../arkinterop/cj-api-callback_invoke.md#class-callback1argumenta)\<String>|是|-|回调函数。<br>String: 发生变化的Key的类型。|

**异常：**

- BusinessException：对应错误码如下表，详见[用户首选项错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 15500000 | Inner error. |
  | 15500019 | Failed to obtain the subscription service. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.callback_invoke.*
import ohos.business_exception.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException

// 回调函数
class Callback1 <: Callback1Argument<String> {
    public func invoke(err: ?BusinessException, arg: String): Unit {
        Hilog.info(0, "AppLogCj", "=========callback========= ${arg.toString()}======================")
    }
}

try {
    var str = "container"
    var a = Preferences.getPreferences(Global.abilityContext, str) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    var c = Callback1()
    a.on(PreferencesEvent.PreferencesChange, c)
    a.put("kkk1", PreferencesValueType.StringData("vvv1"))
    a.flush()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func put(String, PreferencesValueType)

```cangjie
public func put(key: String, value: PreferencesValueType): Unit
```

**功能：** 将数据写入缓存的Preferences实例中，可通过[flush](#func-flush)将Preferences实例持久化。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|key|String|是|-|要修改的存储的Key，不能为空，最大长度限制为[MAX_KEY_LENGTH](#const-max_key_length)。|
|value|[PreferencesValueType](#enum-preferencesvaluetype)|是|-|存储的新值。支持Int64、Float64、String、Bool、 Array\<Bool>、Array\<Float64>、Array\<String>。|

**异常：**

- BusinessException：对应错误码如下表，详见[用户首选项错误码](./cj-errorcode-preferences.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 15500000 | Inner error. |

**示例：**

<!-- compile only -->
<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var preferences = Preferences.getPreferences(Global.abilityContext, PreferencesOptions("mystore", dataGroupId:"myGroupID")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    preferences.put("Monday", PreferencesValueType.StringData("今天天气真好"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## enum PreferencesEvent

```cangjie
public enum PreferencesEvent {
    | PreferencesChange
    | PreferencesMultiProcessChange
    | ...
}
```

**功能：** Preferences的事件类型枚举。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### PreferencesChange

```cangjie
PreferencesChange
```

**功能：** 表示数据变更。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### PreferencesMultiProcessChange

```cangjie
PreferencesMultiProcessChange
```

**功能：** 表示多进程间的数据变更。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

## enum StorageType

```cangjie
public enum StorageType {
    | Xml
    | Gskv
    | ...
}
```

**功能：** Preferences的存储模式枚举。

> **说明：**
>
> - 在选择存储模式前，建议调用isStorageTypeSupported检查当前平台是否支持对应存储模式。
>
> - 当选择某一模式通过getPreferences接口获取实例后，不允许中途切换模式。
>
> - 首选项不支持不同模式间数据的迁移，若需将数据从一种模式切换至另一种模式，需通过读写首选项的形式进行数据迁移。
>
> - 若需要变更首选项的存储路径，不能通过移动或覆盖文件的方式进行，需通过读写首选项的形式进行数据迁移。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### Gskv

```cangjie
Gskv
```

**功能：** 表示GSKV存储模式。

**特点：** 数据以GSKV数据库模式进行存储。对数据的操作实时落盘，无需调用flush接口对数据进行落盘。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### Xml

```cangjie
Xml
```

**功能：** 表示XML存储模式，这是Preferences的默认存储模式。

**特点：** 数据XML格式进行存储。对数据的操作发生在内存中，需要调用flush接口进行落盘。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

## enum PreferencesValueType

```cangjie
public enum PreferencesValueType {
    | Integer(Int64)
    | Double(Float64)
    | StringData(String)
    | BoolData(Bool)
    | BoolArray(Array<Bool>)
    | DoubleArray(Array<Float64>)
    | StringArray(Array<String>)
    | ...
}
```

**功能：** 表示支持的值类型。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### BoolArray(Array\<Bool>)

```cangjie
BoolArray(Array<Bool>)
```

**功能：** 表示值类型为布尔类型的数组。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### BoolData(Bool)

```cangjie
BoolData(Bool)
```

**功能：** 表示值类型为布尔值。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### Double(Float64)

```cangjie
Double(Float64)
```

**功能：** 表示值类型为双精度浮点数类型。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### DoubleArray(Array\<Float64>)

```cangjie
DoubleArray(Array<Float64>)
```

**功能：** 表示值类型为双精度浮点数类型的数组。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### Integer(Int64)

```cangjie
Integer(Int64)
```

**功能：** 表示值类型为64位有符号整型类型。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### StringArray(Array\<String>)

```cangjie
StringArray(Array<String>)
```

**功能：** 表示值类型为字符串类型的数组。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22

### StringData(String)

```cangjie
StringData(String)
```

**功能：** 表示值类型为字符串。

**系统能力：** SystemCapability.DistributedDataManager.Preferences.Core

**起始版本：** 22
