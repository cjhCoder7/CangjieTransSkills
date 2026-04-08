# ohos.data.relational_store（关系型数据库）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

关系型数据库（Relational Database，RDB）是一种基于关系模型来管理数据的数据库。关系型数据库基于SQLite组件提供了一套完整的对本地数据库进行管理的机制，对外提供了一系列的增、删、改、查等接口，也可以直接运行用户输入的SQL语句来满足复杂的场景需要。不支持Worker线程。

仓颉侧支持的基本数据类型：Int64、Float64、String、二进制类型数据、Bool。为保证插入并读取数据成功，建议一条数据不要超过2M。超出该大小，插入成功，读取失败。

该模块提供以下关系型数据库相关的常用功能：

- [RdbPredicates](#class-rdbpredicates)： 数据库中用来代表数据实体的性质、特征或者数据实体之间关系的词项，主要用来定义数据库的操作条件。
- [RdbStore](#class-rdbstore)：提供管理关系数据库(RDB)方法的接口。
- [ResultSet](#class-resultset)：提供用户调用关系型数据库查询接口之后返回的结果集合。

## 导入模块

```cangjie
import kit.ArkData.*
```

## 权限列表

ohos.permission.DISTRIBUTED_DATASYNC

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## func deleteRdbStore(UIAbilityContext, String)

```cangjie
public func deleteRdbStore(context: UIAbilityContext, name: String): Unit
```

**功能：** 使用指定的数据库文件配置删除数据库。

建立数据库时，若在[StoreConfig](#class-storeconfig)中配置了自定义路径，则调用此接口进行删库无效，必须使用[deleteRdbStore(UIAbilityContext, StoreConfig)](#func-deleterdbstoreuiabilitycontext-storeconfig)接口进行删库。

当使用向量数据库时，在调用deleteRdbStore接口前，应当确保向量数据库已打开的[RdbStore](#class-rdbstore)和[ResultSet](#class-resultset)均已成功关闭。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|[UIAbilityContext](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)|是|-| 应用的上下文。|
|name|String|是|-|数据库名称。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | Capability not supported. |
  | 14800000 | Inner error. |
  | 14800010 | Failed to open or delete the database by an invalid database path. |
  | 14801001 | The operation is supported in the stage model only. |
  | 14801002 | Invalid data group ID. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext, StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    deleteRdbStore(Global.abilityContext, "RdbTest.db")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func deleteRdbStore(UIAbilityContext, StoreConfig)

```cangjie
public func deleteRdbStore(context: UIAbilityContext, config: StoreConfig): Unit
```

**功能：** 使用指定的数据库文件配置删除数据库。

若数据库文件处于公共沙箱目录下，则删除数据库时必须使用该接口。当存在多个进程操作同一个数据库的情况，建议向其他进程发送数据库删除通知使其感知并处理。建立数据库时，若在[StoreConfig](#class-storeconfig)中配置了自定义路径，则必须调用此接口进行删库。

当使用向量数据库时，在调用deleteRdbStore接口前，应当确保向量数据库已打开的RdbStore和ResultSet均已成功关闭。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|[UIAbilityContext](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)|是|-|应用的上下文。|
|config|[StoreConfig](#class-storeconfig)|是|-|与此RDB存储相关的数据库配置。|

**异常：**

- BusinessException：对应错误码如下表，详见[通用错误码](../cj-errorcode-universal.md)和[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | Capability not supported. |
  | 14800000 | Inner error. |
  | 14800010 | Failed to open or delete the database by an invalid database path. |
  | 14801001 | The operation is supported in the stage model only. |
  | 14801002 | Invalid data group ID. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext, StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    deleteRdbStore(Global.abilityContext, StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func getRdbStore(UIAbilityContext, StoreConfig)

```cangjie
public func getRdbStore(context: UIAbilityContext, config: StoreConfig): RdbStore
```

**功能：** 创建或打开已有的关系型数据库，开发者可以根据自己的需求配置config参数，然后通过RdbStore调用相关接口执行数据操作。

对应沙箱路径下无数据库文件时，将创建数据库文件，文件创建位置详见[StoreConfig](#class-storeconfig)。对应路径下已有数据库文件时，将打开已有数据库文件。

开发者在创建数据库时，应谨慎配置是否进行数据库加密的参数[encrypt](#var-encrypt)，数据库创建后，禁止对该参数进行修改。

| 当前开库的加密类型  | 本设备上创建该数据库时的加密类型           | 结果 |
| ------- | -------------------------------- | ---- |
| 非加密 | 加密                          | 将数据库以加密方式打开。   |
| 加密 | 非加密                          | 将数据库以非加密方式打开。   |

getRdbStore目前不支持多线程并发操作。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|[UIAbilityContext](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)|是|-|应用的上下文。|
|config|[StoreConfig](#class-storeconfig)|是|-|与此RDB存储相关的数据库配置。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbStore](#class-rdbstore)|返回RdbStore对象。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800010 | Failed to open or delete the database by an invalid database path. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14801001 | The operation is supported in the stage model only. |
  | 14801002 | Invalid data group ID. |
  | 14800017 | StoreConfig is changed. |
  | 14800020 | The secret key is corrupted or lost. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext, StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class Asset

```cangjie
public class Asset {
    public var name: String
    public var uri: String
    public var path: String
    public var createTime: String
    public var modifyTime: String
    public var size: String
    public var status: AssetStatus

    public init(name: String, uri: String, path: String, createTime: String, modifyTime: String, size: String,
        status!: AssetStatus = AssetStatus.AssetNormal)
}
```

**功能：** 记录资产附件（文件、图片、视频等类型文件）的相关信息。资产类型的相关接口暂不支持Datashare。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var createTime

```cangjie
public var createTime: String
```

**功能：** 资产被创建出来的时间。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var modifyTime

```cangjie
public var modifyTime: String
```

**功能：** 资产最后一次被修改的时间。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var name

```cangjie
public var name: String
```

**功能：** 资产的名称。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var path

```cangjie
public var path: String
```

**功能：** 资产在应用沙箱里的路径。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var size

```cangjie
public var size: String
```

**功能：** 资产占用空间的大小。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var status

```cangjie
public var status: AssetStatus
```

**功能：** 资产的状态。

**类型：** [AssetStatus](#enum-assetstatus)

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var uri

```cangjie
public var uri: String
```

**功能：** 资产的uri，在系统里的绝对路径。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### init(String, String, String, String, String, String, AssetStatus)

```cangjie
public init(name: String, uri: String, path: String, createTime: String, modifyTime: String, size: String,
    status!: AssetStatus = AssetStatus.AssetNormal)
```

**功能：** 构建Asset。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-|资产的名称。|
|uri|String|是|-|资产的uri，在系统里的绝对路径。|
|path|String|是|-|资产在应用沙箱里的路径。|
|createTime|String|是|-|资产被创建出来的时间。|
|modifyTime|String|是|-|资产最后一次被修改的时间。|
|size|String|是|-|资产占用空间的大小。|
|status|[AssetStatus](#enum-assetstatus)|否|AssetStatus.AssetNormal|**命名参数。** 资产的状态，默认值为AssetStatus.AssetNormal。|

## class CryptoParam

```cangjie
public class CryptoParam {
    public var encryptionKey: Array<UInt8>
    public var iterationCount: Int32
    public var encryptionAlgo: EncryptionAlgo
    public var hmacAlgo: HmacAlgo
    public var kdfAlgo:?KdfAlgo
    public var cryptoPageSize: UInt32

    public init(encryptionKey: Array<UInt8>, iterationCount!: Int32 = 10000,
        encryptionAlgo!: EncryptionAlgo = EncryptionAlgo.Aes256Gcm,
        hmacAlgo!: HmacAlgo = HmacAlgo.Sha256, kdfAlgo!: ?KdfAlgo = None,
        cryptoPageSize!: UInt32 = 1024)
}
```

**功能：** 数据库加密参数配置。此配置只有在StoreConfig的encrypt选项设置为true或密钥非空时有效。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var cryptoPageSize

```cangjie
public var cryptoPageSize: UInt32
```

**功能：** 整数类型，指定数据库加解密使用的页大小。

用户指定的页大小应为1024到65536范围内的整数，并且为2<sup>n</sup>。若指定值非整数，则向下取整。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var encryptionAlgo

```cangjie
public var encryptionAlgo: EncryptionAlgo
```

**功能：** 指定数据库加解密使用的加密算法。

**类型：** [EncryptionAlgo](#enum-encryptionalgo)

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var encryptionKey

```cangjie
public var encryptionKey: Array<UInt8>
```

**功能：** 指定数据库加/解密使用的密钥。

如传入密钥为空，则由数据库负责生成并保存密钥，并使用生成的密钥打开数据库文件。

使用完后用户需要将密钥内容全部置为零。

**类型：** Array\<UInt8>

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var hmacAlgo

```cangjie
public var hmacAlgo: HmacAlgo
```

**功能：** 指定数据库加解密使用的HMAC算法。

**类型：** [HmacAlgo](#enum-hmacalgo)

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var iterationCount

```cangjie
public var iterationCount: Int32
```

**功能：** 整数类型，指定数据库PBKDF2算法的迭代次数。

迭代次数应当为大于零的整数。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var kdfAlgo

```cangjie
public var kdfAlgo:?KdfAlgo
```

**功能：** 指定数据库加解密使用的PBKDF2算法。

**类型：** ?[KdfAlgo](#enum-kdfalgo)

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### init(Array\<UInt8>, Int32, EncryptionAlgo, HmacAlgo, ?KdfAlgo, UInt32)

```cangjie
public init(encryptionKey: Array<UInt8>, iterationCount!: Int32 = 10000,
    encryptionAlgo!: EncryptionAlgo = EncryptionAlgo.Aes256Gcm,
    hmacAlgo!: HmacAlgo = HmacAlgo.Sha256, kdfAlgo!: ?KdfAlgo = None,
    cryptoPageSize!: UInt32 = 1024)
```

**功能：** CryptoParam类的构造函数。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|encryptionKey|Array\<UInt8>|是|-|指定数据库加/解密使用的密钥。|
|iterationCount|Int32|否|10000|**命名参数。** 整数类型，指定数据库PBKDF2算法的迭代次数，默认值为10000。|
|encryptionAlgo|[EncryptionAlgo](#enum-encryptionalgo)|否|EncryptionAlgo.Aes256Gcm|**命名参数。** 指定数据库加解密使用的加密算法。如不指定，默认值为EncryptionAlgo.Aes256Gcm。|
|hmacAlgo|[HmacAlgo](#enum-hmacalgo)|否|HmacAlgo.Sha256|**命名参数。** 指定数据库加解密使用的HMAC算法。如不指定，默认值为HmacAlgo.Sha256。|
|kdfAlgo|?[KdfAlgo](#enum-kdfalgo)|否|None|**命名参数。** 指定数据库加解密使用的PBKDF2算法。如不指定，默认使用和HMAC算法相等的算法。|
|cryptoPageSize|UInt32|否|1024|**命名参数。** 整数类型，指定数据库加解密使用的页大小，单位为字节。如不指定，默认值为1024字节。|

## class RdbPredicates

```cangjie
public class RdbPredicates {
    public init(name: String)
}
```

**功能：** 表示关系型数据库（RDB）的谓词。该类确定RDB中条件表达式的值是true还是false。谓词间支持多语句拼接，拼接时默认使用and()连接。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### init(String)

```cangjie
public init(name: String)
```

**功能：** 构造函数。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-|数据库表名。|

### func inValues(String, Array\<RelationalStoreValueType>)

```cangjie
public func inValues(field: String, value: Array<RelationalStoreValueType>): RdbPredicates
```

**功能：** 配置谓词条件，表示字段`field`的值必须在给定的`value`集合内。

> **说明：**
>
> `value`集合不能为空。如果传入空集，此条件将失效，导致操作针对所有数据（如全量查询、更新或删除）。请在调用前判断`value`是否为空集，避免误操作。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|value|Array\<[RelationalStoreValueType](#enum-relationalstorevaluetype)>|是|-|以RelationalStoreValueType数组形式指定的要匹配的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 数据表的"NAME"列中在["Lisa", "Rose"]中的值
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.inValues("NAME", [RelationalStoreValueType.StringValue("Lisa"), RelationalStoreValueType.StringValue("Rose")])
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func and()

```cangjie
public func and(): RdbPredicates
```

**功能：** 向谓词添加和条件。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回带有和条件的Rdb谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 匹配数据表的"NAME"列中的值为"Lisa"且"SALARY"列中的值为"200.5"的字段
    let predicates = RdbPredicates("EMPLOYEE")
    predicates
        .equalTo("NAME", RelationalStoreValueType.StringValue("Lisa"))
        .and()
        .equalTo("SALARY", RelationalStoreValueType.Double(200.5))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func beginWrap()

```cangjie
public func beginWrap(): RdbPredicates
```

**功能：** 向谓词添加左括号。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回带有左括号的Rdb谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = RdbPredicates("EMPLOYEE")
    predicates
        .equalTo("NAME", RelationalStoreValueType.StringValue("Lisa"))
        .beginWrap()
        .equalTo("AGE", RelationalStoreValueType.Integer(18))
        .or()
        .equalTo("SALARY", RelationalStoreValueType.Double(200.5))
        .endWrap()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func beginsWith(String, String)

```cangjie
public func beginsWith(field: String, value: String): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中以value开头的字段。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|value|String|是|-|指示要与谓词匹配的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 匹配数据表的"NAME"列中以"Li"开头的字段，如"Lisa"
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.beginsWith("NAME", "Li")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func between(String, RelationalStoreValueType, RelationalStoreValueType)

```cangjie
public func between(field: String, low: RelationalStoreValueType, high: RelationalStoreValueType): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中值在给定范围内的字段（包含范围边界）。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|low|[RelationalStoreValueType](#enum-relationalstorevaluetype)|是|-|指示与谓词匹配的最小值。|
|high|[RelationalStoreValueType](#enum-relationalstorevaluetype)|是|-|指示与谓词匹配的最大值。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 匹配数据表的"AGE"列中大于等于10且小于等于50的值
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.between("AGE", RelationalStoreValueType.Integer(10), RelationalStoreValueType.Integer(50))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func contains(String, String)

```cangjie
public func contains(field: String, value: String): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中包含value的字段。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|value|String|是|-|指示要与谓词匹配的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 匹配数据表的"NAME"列中包含"os"的字段，如"Rose"
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.contains("NAME", "os")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func distinct()

```cangjie
public func distinct(): RdbPredicates
```

**功能：** 配置谓词以过滤重复记录并仅保留其中一个。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回可用于过滤重复记录的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = RdbPredicates("EMPLOYEE")
    predicates
        .equalTo("NAME", RelationalStoreValueType.StringValue("Rose"))
        .distinct()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func endWrap()

```cangjie
public func endWrap(): RdbPredicates
```

**功能：** 向谓词添加右括号。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回带有右括号的Rdb谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = RdbPredicates("EMPLOYEE")
    predicates
        .equalTo("NAME", RelationalStoreValueType.StringValue("Lisa"))
        .beginWrap()
        .equalTo("AGE", RelationalStoreValueType.Integer(18))
        .or()
        .equalTo("SALARY", RelationalStoreValueType.Double(200.5))
        .endWrap()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func endsWith(String, String)

```cangjie
public func endsWith(field: String, value: String): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中以value结尾的字段。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|value|String|是|-|指示要与谓词匹配的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 匹配数据表的"NAME"列中以"se"结尾的字段，如"Rose"
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.endsWith("NAME", "se")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func equalTo(String, RelationalStoreValueType)

```cangjie
public func equalTo(field: String, value: RelationalStoreValueType): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中值为value的字段。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|value|[RelationalStoreValueType](#enum-relationalstorevaluetype)|是|-|指示要与谓词匹配的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 匹配数据表的"NAME"列中的值为"Lisa"的字段
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.equalTo("NAME", RelationalStoreValueType.StringValue("Lisa"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func glob(String, String)

```cangjie
public func glob(field: String, value: String): RdbPredicates
```

**功能：** 配置谓词匹配数据字段为value的指定字段。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|value|String|是|-|指示要与谓词匹配的值。<br>支持通配符，*表示0个、1个或多个数字或字符，?表示1个数字或字符。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 匹配数据表的"NAME"列中类型为string且值为"?h*g"的字段
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.glob("NAME", "?h*g")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func greaterThan(String, RelationalStoreValueType)

```cangjie
public func greaterThan(field: String, value: RelationalStoreValueType): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中值大于value的字段。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|value|[RelationalStoreValueType](#enum-relationalstorevaluetype)|是|-|指示要与谓词匹配的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 匹配数据表的"AGE"列中大于18的值
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.greaterThan("AGE", RelationalStoreValueType.Integer(18))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func greaterThanOrEqualTo(String, RelationalStoreValueType)

```cangjie
public func greaterThanOrEqualTo(field: String, value: RelationalStoreValueType): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中的值大于或者等于value的字段。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|value|[RelationalStoreValueType](#enum-relationalstorevaluetype)|是|-|指示要与谓词匹配的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 匹配数据表的"AGE"列中大于18的值
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.greaterThanOrEqualTo("AGE", RelationalStoreValueType.Integer(18))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func groupBy(Array\<String>)

```cangjie
public func groupBy(fields: Array<String>): RdbPredicates
```

**功能：** 配置谓词按指定列分组查询结果。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|fields|Array\<String>|是|-|指定分组依赖的列名。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回分组查询列的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.groupBy(["AGE", "NAME"])
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func inAllDevices()

```cangjie
public func inAllDevices(): RdbPredicates
```

**功能：** 同步分布式数据库时连接到组网内所有的远程设备。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.inAllDevices()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func isNotNull(String)

```cangjie
public func isNotNull(field: String): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中值不为null的字段。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.isNotNull("NAME")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func isNull(String)

```cangjie
public func isNull(field: String): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中的值为null的字段。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.isNull("NAME")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func lessThan(String, RelationalStoreValueType)

```cangjie
public func lessThan(field: String, value: RelationalStoreValueType): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中的值小于value的字段。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|value|[RelationalStoreValueType](#enum-relationalstorevaluetype)|是|-|指示要与谓词匹配的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 匹配数据表的"AGE"列中小于20的值
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.lessThan("AGE", RelationalStoreValueType.Integer(20))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func lessThanOrEqualTo(String, RelationalStoreValueType)

```cangjie
public func lessThanOrEqualTo(field: String, value: RelationalStoreValueType): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中的值小于或者等于value的字段。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|value|[RelationalStoreValueType](#enum-relationalstorevaluetype)|是|-|指示要与谓词匹配的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 匹配数据表的"AGE"列中小于等于20的值
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.lessThanOrEqualTo("AGE", RelationalStoreValueType.Integer(20))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func like(String, String)

```cangjie
public func like(field: String, value: String): RdbPredicates
```

**功能：** 配置模糊查询条件，指定`field`列的模糊匹配条件。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|value|String|是|-|指定模糊匹配条件，通常配合通配符使用，`%`表示任意长度任意字符，`_`表示单个字符。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 数据表的"NAME"列中的值类似于"os"的字段，如"Rose"
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.like("NAME", "%os%")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func limitAs(Int32)

```cangjie
public func limitAs(value: Int32): RdbPredicates
```

**功能：** 设置谓词的最大数据记录数量。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|Int32|是|-|最大数据记录数，取值应为正整数，传入值小于等于0时，不会限制记录数量。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回可用于设置最大数据记录数的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = RdbPredicates("EMPLOYEE")
    predicates
        .equalTo("NAME", RelationalStoreValueType.StringValue("Rose"))
        .limitAs(3)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func notBetween(String, RelationalStoreValueType, RelationalStoreValueType)

```cangjie
public func notBetween(field: String, low: RelationalStoreValueType, high: RelationalStoreValueType): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中值超出给定范围的字段（不包含范围边界）。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|low|[RelationalStoreValueType](#enum-relationalstorevaluetype)|是|-|指示与谓词匹配的最小值。|
|high|[RelationalStoreValueType](#enum-relationalstorevaluetype)|是|-|指示要与谓词匹配的最大值。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 数据表的"AGE"列中小于10或大于50的值
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.notBetween("AGE", RelationalStoreValueType.Integer(10), RelationalStoreValueType.Integer(50))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func notEqualTo(String, RelationalStoreValueType)

```cangjie
public func notEqualTo(field: String, value: RelationalStoreValueType): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中值不为value的字段。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|value|[RelationalStoreValueType](#enum-relationalstorevaluetype)|是|-|指示要与谓词匹配的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 数据表的"NAME"列中的值不为"Lisa"的字段
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.notEqualTo("NAME", RelationalStoreValueType.StringValue("Lisa"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func notInValues(String, Array\<RelationalStoreValueType>)

```cangjie
public func notInValues(field: String, value: Array<RelationalStoreValueType>): RdbPredicates
```

**功能：** 将谓词配置为匹配数据字段为RelationalStoreValueType且值超出给定范围的指定字段。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|
|value|Array\<[RelationalStoreValueType](#enum-relationalstorevaluetype)>|是|-|以RelationalStoreValueType数组形式指定的要匹配的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 数据表的"NAME"列中不在["Lisa", "Rose"]中的值
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.notInValues("NAME", [RelationalStoreValueType.StringValue("Lisa"), RelationalStoreValueType.StringValue("Rose")])
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func offsetAs(Int32)

```cangjie
public func offsetAs(rowOffset: Int32): RdbPredicates
```

**功能：** 设置谓词查询结果返回的起始位置。需要同步调用limitAs接口指定查询数量，否则将无查询结果。如需查询指定偏移位置后的所有行，limitAs接口入参需小于等于0。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|rowOffset|Int32|是|-|指定查询结果的起始位置，默认初始位置为结果集的最前端。当rowOffset为负数时，起始位置为结果集的最前端。当rowOffset超出结果集最后位置时，查询结果为空。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回具有指定返回结果起始位置的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = RdbPredicates("EMPLOYEE")
    predicates
        .equalTo("NAME", RelationalStoreValueType.StringValue("Rose"))
        .offsetAs(3)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func or()

```cangjie
public func or(): RdbPredicates
```

**功能：** 将或条件添加到谓词中。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回带有或条件的Rdb谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 数据表的"NAME"列中的值为"Lisa"或"Rose"的字段
    let predicates = RdbPredicates("EMPLOYEE")
    predicates
        .equalTo("NAME", RelationalStoreValueType.StringValue("Lisa"))
        .or()
        .equalTo("NAME", RelationalStoreValueType.StringValue("Rose"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func orderByAsc(String)

```cangjie
public func orderByAsc(field: String): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中值按升序排序的列。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.orderByAsc("NAME")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func orderByDesc(String)

```cangjie
public func orderByDesc(field: String): RdbPredicates
```

**功能：** 配置谓词以匹配数据表的field列中值按降序排序的列。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。|

**返回值：**

|类型|说明|
|:----|:----|
|[RdbPredicates](#class-rdbpredicates)|返回与指定字段匹配的谓词。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.orderByDesc("AGE")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class RdbStore

```cangjie
public class RdbStore {}
```

**功能：** 提供管理关系数据库（RDB）方法的接口。

在使用以下API前，请先通过[getRdbStore](#func-getrdbstoreuiabilitycontext-storeconfig)方法获取RdbStore实例，并使用该实例调用对应接口方法。

在此基础上，建议优先使用[execute](#func-executesqlstring-arrayrelationalstorevaluetype)方法完成数据库表结构和初始数据的初始化，以确保相关接口调用的前置条件已满足。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### func backup(String)

```cangjie
public func backup(destName: String): Unit
```

**功能：** 以指定名称备份数据库。

该接口支持[向量数据库](#class-storeconfig)使用。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|destName|String|是|-|指定数据库的备份文件名。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800015 | The database does not respond. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext, StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    rdbStore.backup("dbBackup.db")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func batchInsert(String, Array\<ValuesBucket>)

```cangjie
public func batchInsert(table: String, values: Array<ValuesBucket>): Int64
```

**功能：** 向目标表中插入一组数据。

该接口支持[向量数据库](#class-storeconfig)使用。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|table|String|是|-|指定的目标表名。|
|values|Array\<[ValuesBucket](#type-valuesbucket)>|是|-|表示要插入到表中的一组数据。|

**返回值：**

|类型|说明|
|:----|:----|
|Int64|如果操作成功，返回插入的数据个数，否则返回-1。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800015 | The database does not respond. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |
  | 14800047 | The WAL file size exceeds the default limit. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import std.collection.{HashMap, Map}
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext, StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    var values1 = HashMap<String, RelationalStoreValueType>()
    values1.add("ID", RelationalStoreValueType.Integer(1))
    values1.add("NAME", RelationalStoreValueType.StringValue("Lisa"))
    values1.add("AGE", RelationalStoreValueType.Integer(18))
    values1.add("SALARY", RelationalStoreValueType.Double(100.5))
    var values2 = HashMap<String, RelationalStoreValueType>()
    values2.add("ID", RelationalStoreValueType.Integer(2))
    values2.add("NAME", RelationalStoreValueType.StringValue("Jack"))
    values2.add("AGE", RelationalStoreValueType.Integer(19))
    values2.add("SALARY", RelationalStoreValueType.Double(101.5))
    var values3 = HashMap<String, RelationalStoreValueType>()
    values3.add("ID", RelationalStoreValueType.Integer(3))
    values3.add("NAME", RelationalStoreValueType.StringValue("Tom"))
    values3.add("AGE", RelationalStoreValueType.Integer(20))
    values3.add("SALARY", RelationalStoreValueType.Double(102.5))
    let valueBuckets: Array<Map<String, RelationalStoreValueType>>= [values1, values2, values3]
    let count = rdbStore.batchInsert("EMPLOYEE", valueBuckets)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func beginTransaction()

```cangjie
public func beginTransaction(): Unit
```

**功能：** 在开始执行SQL语句之前，开始事务。
此接口不允许嵌套事务，且不支持在多进程或多线程中使用。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800015 | The database does not respond. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |
  | 14800047 | The WAL file size exceeds the default limit. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import std.collection.HashMap
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext, StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    var values = HashMap<String, RelationalStoreValueType>()
    rdbStore.beginTransaction()
    values.add("ID", RelationalStoreValueType.Integer(2))
    values.add("NAME", RelationalStoreValueType.StringValue("Sun"))
    rdbStore.insert("THING", values)
    rdbStore.commit()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func commit()

```cangjie
public func commit(): Unit
```

**功能：** 提交已执行的SQL语句，跟[beginTransaction](#func-begintransaction)配合使用。
此接口不允许嵌套事务，且不支持在多进程或多线程中使用。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800015 | The database does not respond. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import std.collection.HashMap
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext, StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    rdbStore.executeSql("CREATE TABLE THING(ID int NOT NULL, NAME varchar(255) NOT NULL, PRIMARY KEY (Id))")
    rdbStore.beginTransaction()
    var values = HashMap<String, RelationalStoreValueType>()
    values.add("ID", RelationalStoreValueType.Integer(2))
    values.add("NAME", RelationalStoreValueType.StringValue("Sun"))
    rdbStore.insert("THING", values)
    rdbStore.commit()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func delete(RdbPredicates)

```cangjie
public func delete(predicates: RdbPredicates): Int64
```

**功能：** 根据RdbPredicates的指定实例对象从数据库中删除数据。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|predicates|[RdbPredicates](#class-rdbpredicates)|是|-|RdbPredicates的实例对象指定的删除条件。|

**返回值：**

|类型|说明|
|:----|:----|
|Int64|返回受影响的行数量。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800015 | The database does not respond. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |
  | 14800047 | The WAL file size exceeds the default limit. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import std.collection.HashMap
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext, StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.equalTo("NAME", RelationalStoreValueType.StringValue("Lisa"))
    let count = rdbStore.delete(predicates)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func emit(String)

```cangjie
public func emit(event: String): Unit
```

**功能：** 通知通过[on](#func-onstring-bool-callback0argument)注册的进程间或者进程内监听事件。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|String|是|-|通知订阅事件的名称，可自定义事件名称，不能与系统已有事件dataChange，autoSyncProgress，statistics名称重复。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | Capability not supported. |
  | 14800000 | Inner error. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800050 | Failed to obtain the subscription service. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import kit.PerformanceAnalysisKit.*
import ohos.callback_invoke.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallback <: Callback0Argument {
    public init() {}
    public open func invoke(err: ?BusinessException): Unit {
        Hilog.info(0, "test", "Call invoke.", "")
    }
}

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext, StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let testCallback = TestCallback()
    rdbStore.on("PRINT", false, testCallback)
    rdbStore.emit("PRINT")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func executeSql(String, Array\<RelationalStoreValueType>)

```cangjie
public func executeSql(sql: String, bindArgs!: Array<RelationalStoreValueType> = []): Unit
```

**功能：**  执行指定的SQL语句，语句中的各种表达式和操作符之间的关系操作符号不超过1000个。

此接口不支持执行查询、附加数据库和事务操作，可以使用[querySql](#func-querysqlstring-arrayrelationalstorevaluetype)、[query](#func-queryrdbpredicates-arraystring)、[beginTransaction](#func-begintransaction)、[commit](#func-commit)等接口代替。

不支持分号分隔的多条语句。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|sql|String|是|-|指定要执行的SQL语句。|
|bindArgs|Array\<[RelationalStoreValueType](#enum-relationalstorevaluetype)>|否|[]|**命名参数。** SQL语句中参数的值。该值与sql参数语句中的占位符相对应。当sql参数语句完整时，该参数不填。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | Capability not supported the sql(attach,begin,commit,rollback etc.). |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800015 | The database does not respond. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |
  | 14800047 | The WAL file size exceeds the default limit. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext, StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    rdbStore.executeSql("DELETE FROM EMPLOYEE WHERE ID = ?", bindArgs: [RelationalStoreValueType.Integer(3)])
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func insert(String, ValuesBucket, ConflictResolution)

```cangjie
public func insert(table: String, values: ValuesBucket,
    conflict!: ConflictResolution = ConflictResolution.OnConflictNone): Int64
```

**功能：** 向目标表中插入一行数据。由于共享内存的大小限制为2MB，因此单条数据的大小也必须严格小于2MB。如果单条数据超过此限制，在后续通过RdbStore的[query](#func-queryrdbpredicates-arraystring)或[querySql](#func-querysqlstring-arrayrelationalstorevaluetype)接口获取ResultSet后，调用[getString](#func-getstringint32)等get方法时将无法成功获取数据，并可能导致操作失败或抛出异常。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|table|String|是|-|指定的目标表名。|
|values|[ValuesBucket](#type-valuesbucket)|是|-|表示要插入到表中的数据行。|
|conflict|[ConflictResolution](#enum-conflictresolution)|否|ConflictResolution.OnConflictNone|**命名参数。** 指定冲突解决方式。|

**返回值：**

|类型|说明|
|:----|:----|
|Int64|如果操作成功，返回行ID；否则返回-1。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800015 | The database does not respond. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |
  | 14800047 | The WAL file size exceeds the default limit. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import std.collection.HashMap
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    rdbStore.executeSql(
        "CREATE TABLE EMPLOYEE(ID int NOT NULL, NAME varchar(255) NOT NULL, AGE int, SALARY float NOT NULL, CODES Bit NOT NULL, PRIMARY KEY (Id))"
    )
    var values = HashMap<String, RelationalStoreValueType>()
    values.add("ID", RelationalStoreValueType.Integer(1))
    values.add("NAME", RelationalStoreValueType.StringValue("Lisa"))
    values.add("AGE", RelationalStoreValueType.Integer(18))
    values.add("SALARY", RelationalStoreValueType.Double(100.5))
    values.add("CODES", RelationalStoreValueType.Boolean(true))
    let id = rdbStore.insert("EMPLOYEE", values, conflict: OnConflictReplace)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func off(String, Bool, ?Callback0Argument)

```cangjie
public func off(event: String, interProcess: Bool, observer!: ?Callback0Argument = None): Unit
```

**功能：** 取消数据变更的事件监听。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|String|是|-|取消订阅事件名称。事件名称与on接口调用时订阅事件的名称一致。|
|interProcess|Bool|是|-|指定是进程间还是本进程取消订阅。<br/> true：进程间。<br/> false：本进程。|
|observer|?[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|否|None|**命名参数。** 该参数存在，则取消指定Callback监听回调，否则取消该event事件的所有监听回调。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | Capability not supported. |
  | 14800000 | Inner error. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800050 | Failed to obtain the subscription service. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import kit.PerformanceAnalysisKit.*
import ohos.callback_invoke.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallback1 <: Callback0Argument {
    public init() {}
    public func invoke(err: ?BusinessException): Unit {
        Hilog.info(0, "test", "Call invoke.", "")
    }
}

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext, StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let testCallback = TestCallback1()
    rdbStore.on("PRINT", false, testCallback)
    rdbStore.off("PRINT", false, observer: testCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func on(String, Bool, Callback0Argument)

```cangjie
public func on(event: String, interProcess: Bool, observer: Callback0Argument): Unit
```

**功能：** 注册数据库的进程内或者进程间事件监听。当调用[emit](#func-emitstring)接口时，将调用回调。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|String|是|-|订阅事件名称，与emit接口触发事件时的名称一致。|
|interProcess|Bool|是|-|指定是进程间还是本进程订阅。<br/> true：进程间。<br/> false：本进程。|
|observer|[Callback0Argument](../arkinterop/cj-api-callback_invoke.md#class-callback0argument)|是|-|回调函数对象。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | Capability not supported. |
  | 14800000 | Inner error. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800050 | Failed to obtain the subscription service. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import kit.PerformanceAnalysisKit.*
import ohos.callback_invoke.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

// 此处代码可添加在依赖项定义中
class TestCallback2 <: Callback0Argument {
    public init() {}
    public func invoke(err: ?BusinessException): Unit {
        Hilog.info(0, "test", "Call invoke.", "")
    }
}

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let testCallback = TestCallback2()
    rdbStore.on("PRINT", false, testCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func query(RdbPredicates, Array\<String>)

```cangjie
public func query(predicates: RdbPredicates, columns!: Array<String> = []): ResultSet
```

**功能：** 根据指定条件查询数据库中的数据。由于共享内存的大小限制为2MB，因此单条数据的大小也必须严格小于2MB。如果单条数据超过此限制，在后续通过RdbStore的[query](#func-queryrdbpredicates-arraystring)或[querySql](#func-querysqlstring-arrayrelationalstorevaluetype)接口获取ResultSet后，调用[getString](#func-getstringint32)等get方法时将无法成功获取数据，并可能导致操作失败或抛出异常。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|predicates|[RdbPredicates](#class-rdbpredicates)|是|-|RdbPredicates的实例对象指定的查询条件。|
|columns|Array\<String>|否|[]|**命名参数。** 表示要查询的列。如果值为空，则查询应用于所有列。|

**返回值：**

|类型|说明|
|:----|:----|
|[ResultSet](#class-resultset)|返回ResultSet对象。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800015 | The database does not respond. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.equalTo("NAME", RelationalStoreValueType.StringValue("Rose"))
    let columns = ["ID", "NAME", "AGE", "SALARY", "CODES"]
    let resultSet = rdbStore.query(predicates, columns: columns)
    resultSet.goToNextRow()
    let id = resultSet.getLong(resultSet.getColumnIndex("ID"))
    let name = resultSet.getString(resultSet.getColumnIndex("NAME"))
    let age = resultSet.getLong(resultSet.getColumnIndex("AGE"))
    let salary = resultSet.getDouble(resultSet.getColumnIndex("SALARY"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func querySql(String, Array\<RelationalStoreValueType>)

```cangjie
public func querySql(sql: String, bindArgs!: Array<RelationalStoreValueType> = []): ResultSet
```

**功能：** 根据指定SQL语句查询数据库中的数据，SQL语句中的各种表达式和操作符之间的关系操作符号不超过1000个。由于共享内存的大小限制为2MB，因此单条数据的大小也必须严格小于2MB。如果单条数据超过此限制，在后续通过RdbStore的[query](#func-queryrdbpredicates-arraystring)或[querySql](#func-querysqlstring-arrayrelationalstorevaluetype)接口获取ResultSet后，调用[getString](#func-getstringint32)等get方法时将无法成功获取数据，并可能导致操作失败或抛出异常。

该接口支持[向量数据库](#class-storeconfig)使用。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|sql|String|是|-|指定要执行的SQL语句。|
|bindArgs|Array\<[RelationalStoreValueType](#enum-relationalstorevaluetype)>|否|[]|**命名参数。** SQL语句中参数的值。该值与sql参数语句中的占位符相对应。当sql参数语句完整时，该参数不填。|

**返回值：**

|类型|说明|
|:----|:----|
|[ResultSet](#class-resultset)|返回ResultSet对象。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800015 | The database does not respond. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    resultSet.goToNextRow()
    let id = resultSet.getLong(resultSet.getColumnIndex("ID"))
    let name = resultSet.getString(resultSet.getColumnIndex("NAME"))
    let age = resultSet.getLong(resultSet.getColumnIndex("AGE"))
    let salary = resultSet.getDouble(resultSet.getColumnIndex("SALARY"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func restore(String)

```cangjie
public func restore(srcName: String): Unit
```

**功能：** 从指定的数据库备份文件恢复数据库。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|srcName|String|是|-|指定数据库的备份文件名。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800015 | The database does not respond. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    rdbStore.restore("dbBackup.db")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func rollBack()

```cangjie
public func rollBack(): Unit
```

**功能：** 回滚已经执行的SQL语句。
此接口不允许嵌套事务，且不支持在多进程或多线程中使用。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800015 | The database does not respond. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import std.collection.HashMap
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let predicates = RdbPredicates("THING")
    var values = HashMap<String, RelationalStoreValueType>()
    try {
        rdbStore.beginTransaction()
        values.add("ID", RelationalStoreValueType.Integer(3))
        values.add("NAME", RelationalStoreValueType.StringValue("Tom"))
        rdbStore.insert("THING", values)
        values.add("ID", RelationalStoreValueType.Integer(4))
        values.add("NAME", RelationalStoreValueType.StringValue("Wind"))
        rdbStore.insert("THING", values)
        rdbStore.commit()
    } catch (e: Exception) {
        rdbStore.rollBack()
    }
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func update(ValuesBucket, RdbPredicates, ConflictResolution)

```cangjie
public func update(values: ValuesBucket, predicates: RdbPredicates,
    conflict!: ConflictResolution = ConflictResolution.OnConflictNone): Int64
```

**功能：** 根据RdbPredicates的指定实例对象更新数据库中的数据。由于共享内存的大小限制为2MB，因此单条数据的大小也必须严格小于2MB。如果单条数据超过此限制，在后续通过RdbStore的[query](#func-queryrdbpredicates-arraystring)或[querySql](#func-querysqlstring-arrayrelationalstorevaluetype)接口获取ResultSet后，调用[getString](#func-getstringint32)等get方法时将无法成功获取数据，并可能导致操作失败或抛出异常。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|values|[ValuesBucket](#type-valuesbucket)|是|-|values指示数据库中要更新的数据行。键值对与数据库表的列名相关联。|
|predicates|[RdbPredicates](#class-rdbpredicates)|是|-|RdbPredicates的实例对象指定的更新条件。|
|conflict|[ConflictResolution](#enum-conflictresolution)|否|ConflictResolution.OnConflictNone|**命名参数。** 指定冲突解决方式。|

**返回值：**

|类型|说明|
|:----|:----|
|Int64|返回受影响的行数。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800015 | The database does not respond. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |
  | 14800047 | The WAL file size exceeds the default limit. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import std.collection.HashMap
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let predicates = RdbPredicates("EMPLOYEE")
    predicates.equalTo("NAME", RelationalStoreValueType.StringValue("TOM"))
    var values = HashMap<String, RelationalStoreValueType>()
    values.add("NAME", RelationalStoreValueType.StringValue("TOM"))
    values.add("AGE", RelationalStoreValueType.Integer(88))
    values.add("SALARY", RelationalStoreValueType.Double(9999.513))
    let count = rdbStore.update(values, predicates, conflict: OnConflictReplace)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class ResultSet

```cangjie
public class ResultSet {}
```

**功能：** 提供通过查询数据库生成的数据库结果集的访问方法。结果集是指用户调用关系型数据库查询接口之后返回的结果集合，提供了多种灵活的数据访问方式，以便用户获取各项数据。

ResultSet实例不会实时刷新。使用结果集后，如果数据库中的数据发生变化（如增删改操作），需要重新查询才能获取到最新的数据。

下列API示例中，都需先使用[query](#func-queryrdbpredicates-arraystring)、[querySql](#func-querysqlstring-arrayrelationalstorevaluetype)等query类方法中任一方法获取到ResultSet实例，再通过此实例调用对应方法。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### prop columnCount

```cangjie
public prop columnCount: Int32
```

**功能：** 获取结果集中列的数量。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### prop columnNames

```cangjie
public prop columnNames: Array<String>
```

**功能：** 获取结果集中所有列的名称。

**类型：** Array\<String>

**读写能力：** 只读

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### prop isAtFirstRow

```cangjie
public prop isAtFirstRow: Bool
```

**功能：** 检查结果集指针是否位于第一行（行索引为0），true表示位于第一行，false表示不位于第一行。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### prop isAtLastRow

```cangjie
public prop isAtLastRow: Bool
```

**功能：** 检查结果集指针是否位于最后一行，true表示位于最后一行，false表示不位于最后一行。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### prop isClosed

```cangjie
public prop isClosed: Bool
```

**功能：** 检查当前结果集是否关闭，true表示结果集已关闭，false表示结果集未关闭。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### prop isEnded

```cangjie
public prop isEnded: Bool
```

**功能：** 检查结果集指针是否位于最后一行之后，true表示位于最后一行之后，false表示不位于最后一行之后。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### prop isStarted

```cangjie
public prop isStarted: Bool
```

**功能：** 检查指针是否移动过，true表示指针已移动过，false表示指针未移动过。

**类型：** Bool

**读写能力：** 只读

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### prop rowCount

```cangjie
public prop rowCount: Int32
```

**功能：** 获取结果集中行的数量。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### prop rowIndex

```cangjie
public prop rowIndex: Int32
```

**功能：** 获取结果集当前行的索引位置，默认值为-1。索引位置下标从0开始。

**类型：** Int32

**读写能力：** 只读

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### func close()

```cangjie
public func close(): Unit
```

**功能：** 关闭结果集，若不关闭可能会引起fd泄露和内存泄露。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    resultSet.close()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getAsset(Int32)

```cangjie
public func getAsset(columnIndex: Int32): Asset
```

**功能：** 以[Asset](#class-asset)形式获取当前行中指定列的值，如果当前列的数据类型为Asset类型，会以Asset类型返回指定值，其他类型则返回14800000。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|columnIndex|Int32|是|-|指定的列索引，从0开始。|

**返回值：**

|类型|说明|
|:----|:----|
|[Asset](#class-asset)|以Asset形式返回指定列的值。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |
  | 14800013 | Resultset is empty or column index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let doc = resultSet.getAsset(resultSet.getColumnIndex("DOC"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getAssets(Int32)

```cangjie
public func getAssets(columnIndex: Int32): Assets
```

**功能：** 以[Assets](#type-assets)形式获取当前行中指定列的值，如果当前列的数据类型为Assets类型，会以Assets类型返回指定值，其他类型则返回14800000。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|columnIndex|Int32|是|-|指定的列索引，从0开始。|

**返回值：**

|类型|说明|
|:----|:----|
|Assets|以Array\<[Asset](#class-asset)>形式返回指定列的值。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |
  | 14800013 | Resultset is empty or column index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let docs = resultSet.getAssets(resultSet.getColumnIndex("DOCS"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getBlob(Int32)

```cangjie
public func getBlob(columnIndex: Int32): Array<UInt8>
```

**功能：** 以字节数组的形式获取当前行中指定列的值，如果当前列的数据类型为INTEGER、DOUBLE、TEXT、BLOB类型，会转成字节数组类型返回指定值，如果该列内容为空时，会返回空字节数组，其他类型则返回14800000。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|columnIndex|Int32|是|-|指定的列索引，从0开始。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<UInt8>|以字节数组的形式返回指定列的值。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |
  | 14800013 | Resultset is empty or column index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
         StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let codes = resultSet.getBlob(resultSet.getColumnIndex("CODES"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getColumnIndex(String)

```cangjie
public func getColumnIndex(columnName: String): Int32
```

**功能：** 根据指定的列名获取列索引。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|columnName|String|是|-|表示结果集中指定列的名称。|

**返回值：**

|类型|说明|
|:----|:----|
|Int32|返回指定列的索引。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800013 | Resultset is empty or column index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800019 | The SQL must be a query statement. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let id = resultSet.getLong(resultSet.getColumnIndex("ID"))
    let name = resultSet.getString(resultSet.getColumnIndex("NAME"))
    let age = resultSet.getLong(resultSet.getColumnIndex("AGE"))
    let salary = resultSet.getDouble(resultSet.getColumnIndex("SALARY"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getColumnName(Int32)

```cangjie
public func getColumnName(columnIndex: Int32): String
```

**功能：** 根据指定的列索引获取列名。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|columnIndex|Int32|是|-|表示结果集中指定列的索引。|

**返回值：**

|类型|说明|
|:----|:----|
|String|返回指定列的名称。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800013 | Resultset is empty or column index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800019 | The SQL must be a query statement. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let id = resultSet.getColumnName(0)
    let name = resultSet.getColumnName(1)
    let age = resultSet.getColumnName(2)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getDouble(Int32)

```cangjie
public func getDouble(columnIndex: Int32): Float64
```

**功能：** 以Float64形式获取当前行中指定列的值，如果当前列的数据类型为INTEGER、DOUBLE、TEXT、BLOB类型，会转成Float64类型返回指定值，如果该列内容为空时，会返回0.0，其他类型则返回14800000。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|columnIndex|Int32|是|-|指定的列索引，从0开始。|

**返回值：**

|类型|说明|
|:----|:----|
|Float64|以Float64形式返回指定列的值。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |
  | 14800013 | Resultset is empty or column index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let salary = resultSet.getDouble(resultSet.getColumnIndex("SALARY"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getLong(Int32)

```cangjie
public func getLong(columnIndex: Int32): Int64
```

**功能：** 以Int64形式获取当前行中指定列的值，如果当前列的数据类型为INTEGER、DOUBLE、TEXT、BLOB类型，会转成Int64类型返回指定值，如果该列内容为空时，会返回0，其他类型则返回14800000。如果当前列的数据类型为INTEGER，值大于 2^53 - 1 或小于 -(2^53 - 1) 且不希望丢失精度，建议使用[getString](#func-getstringint32)接口获取。如果当前列的数据类型为DOUBLE且不希望丢失精度，建议使用[getDouble](#func-getdoubleint32)接口获取。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|columnIndex|Int32|是|-|指定的列索引，从0开始。|

**返回值：**

|类型|说明|
|:----|:----|
|Int64|以Int64形式返回指定列的值。<br>该接口支持的数据范围是：-(2^53 - 1)~2^53 - 1，若超出该范围，，建议对于DOUBLE类型的值使用[getDouble](#func-getdoubleint32)，对于INTEGER类型的值使用[getString](#func-getstringint32)。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |
  | 14800013 | Resultset is empty or column index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let age = resultSet.getLong(resultSet.getColumnIndex("AGE"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getRow()

```cangjie
public func getRow(): ValuesBucket
```

**功能：** 获取当前行。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[ValuesBucket](#type-valuesbucket)|返回指定行的值。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |
  | 14800013 | Resultset is empty or column index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let value = resultSet.getRow()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func getString(Int32)

```cangjie
public func getString(columnIndex: Int32): String
```

**功能：** 以字符串形式获取当前行中指定列的值，如果当前列中的值为INTEGER、DOUBLE、TEXT、BLOB类型，会以字符串形式返回指定值，如果是当前列中的值为INTEGER，并且为空，则会返回空字符串""，其他类型则返回14800000。如果当前列中的值为DOUBLE类型，可能存在精度的丢失，建议使用[getDouble](#func-getdoubleint32)接口获取。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|columnIndex|Int32|是|-|指定的列索引，从0开始。|

**返回值：**

|类型|说明|
|:----|:----|
|String|以字符串形式返回指定列的值。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |
  | 14800013 | Resultset is empty or column index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let name = resultSet.getString(resultSet.getColumnIndex("NAME"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func goTo(Int32)

```cangjie
public func goTo(offset: Int32): Bool
```

**功能：** 指定相对当前结果集指针位置的偏移量，以移动结果集的指针位置。

> **注意：** 
> 
> 此接口在失败时不会返回`false`，而是抛出异常。请确保调用时针对错误码提示进行适当的处理。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|offset|Int32|是|-|表示相对当前结果集指针位置的偏移量，正值表示向后移动，负值表示向前移动。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果成功移动结果集，则为true。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800019 | The SQL must be a query statement. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let result = resultSet.goTo(1)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func goToFirstRow()

```cangjie
public func goToFirstRow(): Bool
```

**功能：** 转到结果集的第一行。

> **注意：** 
> 
> 此接口在失败时不会返回`false`，而是抛出异常。请确保调用时针对错误码提示进行适当的处理。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果成功移动结果集，则为true。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800019 | The SQL must be a query statement. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let result = resultSet.goToFirstRow()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func goToLastRow()

```cangjie
public func goToLastRow(): Bool
```

**功能：** 转到结果集的最后一行。

> **注意：** 
> 
> 此接口在失败时不会返回`false`，而是抛出异常。请确保调用时针对错误码提示进行适当的处理。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果成功移动结果集，则为true。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800019 | The SQL must be a query statement. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let result = resultSet.goToLastRow()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func goToNextRow()

```cangjie
public func goToNextRow(): Bool
```

**功能：** 转到结果集的下一行。

> **注意：** 
> 
> 此接口在失败时不会返回`false`，而是抛出异常。请确保调用时针对错误码提示进行适当的处理。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果成功移动结果集，则为true。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800019 | The SQL must be a query statement. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let result = resultSet.goToNextRow()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func goToPreviousRow()

```cangjie
public func goToPreviousRow(): Bool
```

**功能：** 转到结果集的上一行。

> **注意：** 
> 
> 此接口在失败时不会返回`false`，而是抛出异常。请确保调用时针对错误码提示进行适当的处理。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果成功移动结果集，则为true。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800019 | The SQL must be a query statement. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let result = resultSet.goToPreviousRow()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func goToRow(Int32)

```cangjie
public func goToRow(position: Int32): Bool
```

**功能：** 转到结果集的指定行。

> **注意：** 
> 
> 此接口在失败时不会返回`false`，而是抛出异常。请确保调用时针对错误码提示进行适当的处理。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|position|Int32|是|-|表示要移动到的指定位置。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果成功移动结果集，则为true。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800019 | The SQL must be a query statement. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let result = resultSet.goToRow(5)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func isColumnNull(Int32)

```cangjie
public func isColumnNull(columnIndex: Int32): Bool
```

**功能：** 检查当前行中指定列的值是否为null。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|columnIndex|Int32|是|-|指定的列索引，从0开始。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果当前行中指定列的值为null，则返回true，否则返回false。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Inner error. |
  | 14800011 | Failed to open the database because it is corrupted. |
  | 14800012 | ResultSet is empty or pointer index is out of bounds. |
  | 14800013 | Resultset is empty or column index is out of bounds. |
  | 14800014 | The RdbStore or ResultSet is already closed. |
  | 14800021 | SQLite: Generic error. Possible causes: Insert failed or the updated data does not exist. |
  | 14800022 | SQLite: Callback routine requested an abort. |
  | 14800023 | SQLite: Access permission denied. |
  | 14800024 | SQLite: The database file is locked. |
  | 14800025 | SQLite: A table in the database is locked. |
  | 14800026 | SQLite: The database is out of memory. |
  | 14800027 | SQLite: Attempt to write a readonly database. |
  | 14800028 | SQLite: Some kind of disk I/O error occurred. |
  | 14800029 | SQLite: The database is full. |
  | 14800030 | SQLite: Unable to open the database file. |
  | 14800031 | SQLite: TEXT or BLOB exceeds size limit. |
  | 14800032 | SQLite: Abort due to constraint violation. |
  | 14800033 | SQLite: Data type mismatch. |
  | 14800034 | SQLite: Library used incorrectly. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    var rdbStore: RdbStore = getRdbStore(Global.abilityContext,
        StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db")) // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let resultSet = rdbStore.querySql("SELECT * FROM EMPLOYEE WHERE NAME = 'Peter'")
    let isColumnNull = resultSet.isColumnNull(resultSet.getColumnIndex("CODES"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class StoreConfig

```cangjie
public class StoreConfig {
    public var name: String
    public var securityLevel: RelationalStoreSecurityLevel
    public var encrypt: Bool
    public var dataGroupId: String
    public var customDir: String
    public var rootDir: String
    public var autoCleanDirtyData: Bool
    public var allowRebuild: Bool
    public var vector: Bool
    public var isReadOnly: Bool
    public var pluginLibs: Array<String>
    public var cryptoParam: CryptoParam
    public var tokenizer: Tokenizer
    public var persist: Bool
    public var enableSemanticIndex: Bool

    public init(securityLevel: RelationalStoreSecurityLevel, name!: String = "",
        encrypt!: Bool = false, dataGroupId!: String = "",
        customDir!: String = "", rootDir!: String = "",
        autoCleanDirtyData!: Bool = true, allowRebuild!: Bool = false,
        isReadOnly!: Bool = false, pluginLibs!: Array<String> = Array<String>(),
        cryptoParam!: CryptoParam = CryptoParam([]), vector!: Bool = false,
        tokenizer!: Tokenizer = Tokenizer.NoneTokenizer, persist!: Bool = true,
        enableSemanticIndex!: Bool = false)
}
```

**功能：** 管理关系数据库配置。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var allowRebuild

```cangjie
public var allowRebuild: Bool
```

**功能：** 指定数据库是否支持异常时自动删除，并重建一个空库空表，true表示自动删除，false表示不自动删除。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var autoCleanDirtyData

```cangjie
public var autoCleanDirtyData: Bool
```

**功能：** 指定是否自动清理云端删除后同步到本地的数据，true表示自动清理，false表示手动清理。

对于端云协同的数据库，当云端删除的数据同步到设备端时，可通过该参数设置设备端是否自动清理。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### var cryptoParam

```cangjie
public var cryptoParam: CryptoParam
```

**功能：** 指定用户自定义的加密参数。

**类型：** [CryptoParam](#class-cryptoparam)

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var customDir

```cangjie
public var customDir: String
```

**功能：** 数据库自定义路径。

使用约束：数据库路径大小限制为128字节，如果超过该大小会开库失败，返回错误。

数据库将在如下的目录结构中被创建：context.databaseDir + "/rdb/" + customDir，其中context.databaseDir是应用沙箱对应的路径，"/rdb/"表示创建的是关系型数据库，customDir表示自定义的路径。当此参数不填时，默认在本应用沙箱目录下创建RdbStore实例。如果同时配置了rootDir参数，将打开或删除如下路径数据库：rootDir + "/" + customDir + "/" + name。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var dataGroupId

```cangjie
public var dataGroupId: String
```

**功能：** 应用组ID，<!--RP1-->暂不支持指定dataGroupId在对应的沙箱路径下创建RdbStore实例。<!--RP1End-->

dataGroupId共享沙箱的方式不支持多进程访问加密数据库。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var enableSemanticIndex

```cangjie
public var enableSemanticIndex: Bool
```

**功能：** 指定数据库是否启用语义索引处理功能。true表示启用语义索引处理功能，false表示不启用。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var encrypt

```cangjie
public var encrypt: Bool
```

**功能：**  指定数据库是否加密。

true：加密。

false：非加密。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var isReadOnly

```cangjie
public var isReadOnly: Bool
```

**功能：** 指定数据库是否只读，默认为数据库可读写。

true：只允许从数据库读取数据，不允许对数据库进行写操作，否则会返回错误码801。

false：允许对数据库进行读写操作。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var name

```cangjie
public var name: String
```

**功能：** 数据库文件名，也是数据库唯一标识符。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var persist

```cangjie
public var persist: Bool
```

**功能：** 指定数据库是否需要持久化。true表示持久化，false表示不持久化，即内存数据库。

内存数据库不支持加密、backup、restore、跨进程访问及分布式能力，securityLevel属性会被忽略。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var pluginLibs

```cangjie
public var pluginLibs: Array<String>
```

**功能：** 表示包含有fts（Full-Text Search，即全文搜索引擎）等能力的动态库名的数组。

使用约束：

1. 动态库名的数量限制最多为16个，如果超过该数量会开库失败，返回错误。

2. 动态库名需为本应用沙箱路径下或系统路径下的动态库，如果动态库无法加载会开库失败，返回错误。

3. 动态库名需为完整路径，用于被sqlite加载。

    样例：[context.bundleCodeDir+ "/libs/arm64/" + libtokenizer.so]，其中context.bundleCodeDir是应用沙箱对应的路径，"/libs/arm64/"表示子目录，libtokenizer.so表示动态库的文件名。当此参数不填时，默认不加载动态库。

4. 动态库需要包含其全部依赖，避免依赖项丢失导致无法运行。

例如：在ndk工程中，使用默认编译参数构建libtokenizer.so，此动态库依赖c++标准库。在加载此动态库时，由于namespace与编译时不一致，链接到了错误的libc++_shared.so，导致__emutls_get_address符号找不到。要解决此问题，需在编译时静态链接c++标准库，具体请参见NDK工程构建概述。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var rootDir

```cangjie
public var rootDir: String
```

**功能：** 指定数据库根路径。

将从如下目录打开或删除数据库：rootDir + "/" + customDir。通过设置此参数打开的数据库为只读模式，不允许对数据库进行写操作，否则返回错误码801。配置此参数打开或删除数据库时，应确保对应路径下数据库文件存在，并且有读取权限，否则返回错误码14800010。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var securityLevel

```cangjie
public var securityLevel: RelationalStoreSecurityLevel
```

**功能：** 设置数据库安全级别。

**类型：** [RelationalStoreSecurityLevel](#enum-relationalstoresecuritylevel)

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var tokenizer

```cangjie
public var tokenizer: Tokenizer
```

**功能：** 指定用户在fts场景下使用哪种分词器。

当此参数不填时，则在fts下不支持中文以及多国语言分词，但仍可支持英文分词。

**类型：** [Tokenizer](#enum-tokenizer)

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### var vector

```cangjie
public var vector: Bool
```

**功能：** 指定数据库是否是向量数据库，true表示向量数据库，false表示关系型数据库。

向量数据库适用于存储和处理高维向量数据，关系型数据库适用于存储和处理结构化数据。

当使用向量数据库时，在调用deleteRdbStore接口前，应当确保向量数据库已打开的RdbStore和ResultSet均已成功关闭。

**类型：** Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### init(RelationalStoreSecurityLevel, String, Bool, String, String, String, Bool, Bool, Bool, Array\<String>, CryptoParam, Bool, Tokenizer, Bool, Bool)

```cangjie
public init(securityLevel: RelationalStoreSecurityLevel, name!: String = "",
    encrypt!: Bool = false, dataGroupId!: String = "",
    customDir!: String = "", rootDir!: String = "",
    autoCleanDirtyData!: Bool = true, allowRebuild!: Bool = false,
    isReadOnly!: Bool = false, pluginLibs!: Array<String> = Array<String>(),
    cryptoParam!: CryptoParam = CryptoParam([]), vector!: Bool = false,
    tokenizer!: Tokenizer = Tokenizer.NoneTokenizer, persist!: Bool = true,
    enableSemanticIndex!: Bool = false)
```

**功能：** StoreConfig类的构造函数。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|securityLevel|[RelationalStoreSecurityLevel](#enum-relationalstoresecuritylevel)|是|-|设置数据库安全级别。|
|name|String|否|""|数据库文件名，也是数据库唯一标识符。|
|encrypt|Bool|否|false|指定数据库是否加密，默认不加密。|
|dataGroupId|String|否|""|应用组ID，<!--RP1-->暂不支持指定dataGroupId在对应的沙箱路径下创建RdbStore实例。<!--RP1End-->|
|customDir|String|否|""|数据库自定义路径。|
|rootDir|String|否|""|指定数据库根路径。|
|autoCleanDirtyData|Bool|否|true|指定是否自动清理云端删除后同步到本地的数据，true表示自动清理，false表示手动清理，默认自动清理。|
|allowRebuild|Bool|否|false|指定数据库是否支持异常时自动删除，并重建一个空库空表，默认不删除。|
|isReadOnly|Bool|否|false|指定数据库是否只读，默认为数据库可读写。|
|pluginLibs|Array\<String>|否|Array\<String>()|表示包含有fts（Full-Text Search，即全文搜索引擎）等能力的动态库名的数组。|
|cryptoParam|[CryptoParam](#class-cryptoparam)|否|CryptoParam([])|指定用户自定义的加密参数。|
|vector|Bool|否|false|指定数据库是否是向量数据库，true表示向量数据库，false表示关系型数据库，默认为false。|
|tokenizer|[Tokenizer](#enum-tokenizer)|否|Tokenizer.NoneTokenizer|指定用户在fts场景下使用哪种分词器。|
|persist|Bool|否|true|指定数据库是否需要持久化。true表示持久化，false表示不持久化，即内存数据库。默认为true。|
|enableSemanticIndex|Bool|否|false|指定数据库是否启用语义索引处理功能。true表示启用语义索引处理功能，false表示不启用。默认为false。|

## enum AssetStatus

```cangjie
public enum AssetStatus {
    | AssetNormal
    | AssetInsert
    | AssetUpdate
    | AssetDelete
    | AssetAbnormal
    | AssetDownloading
    | ...
}
```

**功能：** 描述资产附件的状态枚举。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### AssetAbnormal

```cangjie
AssetAbnormal
```

**功能：** 表示资产状态异常。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### AssetDelete

```cangjie
AssetDelete
```

**功能：** 表示资产需要在云端删除。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### AssetDownloading

```cangjie
AssetDownloading
```

**功能：** 表示资产正在下载到本地设备。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### AssetInsert

```cangjie
AssetInsert
```

**功能：** 表示资产需要插入到云端。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### AssetNormal

```cangjie
AssetNormal
```

**功能：** 表示资产状态正常。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### AssetUpdate

```cangjie
AssetUpdate
```

**功能：** 表示资产需要更新到云端。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

## enum ChangeType

```cangjie
public enum ChangeType {
    | DataChange
    | AssetChange
    | ...
}
```

**功能：** 描述数据变更类型。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### AssetChange

```cangjie
AssetChange
```

**功能：** 表示是资产附件发生了变更。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### DataChange

```cangjie
DataChange
```

**功能：** 表示是数据发生变更。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

## enum ConflictResolution

```cangjie
public enum ConflictResolution {
    | OnConflictNone
    | OnConflictRollback
    | OnConflictAbort
    | OnConflictFail
    | OnConflictIgnore
    | OnConflictReplace
    | ...
}
```

**功能：** 插入和修改接口的冲突解决方式。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### OnConflictAbort

```cangjie
OnConflictAbort
```

**功能：** 表示当冲突发生时，中止当前SQL语句，并撤销当前 SQL 语句所做的任何更改，但是由同一事务中先前的 SQL 语句引起的更改被保留并且事务保持活动状态。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### OnConflictFail

```cangjie
OnConflictFail
```

**功能：** 表示当冲突发生时，中止当前 SQL 语句。但它不会撤销失败的 SQL 语句的先前更改，也不会结束事务。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### OnConflictIgnore

```cangjie
OnConflictIgnore
```

**功能：** 表示当冲突发生时，跳过包含违反约束的行并继续处理 SQL 语句的后续行。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### OnConflictNone

```cangjie
OnConflictNone
```

**功能：** 表示当冲突发生时，不做任何处理。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### OnConflictReplace

```cangjie
OnConflictReplace
```

**功能：** 表示当冲突发生时，在插入或更新当前行之前删除导致约束违例的预先存在的行，并且命令会继续正常执行。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### OnConflictRollback

```cangjie
OnConflictRollback
```

**功能：** 表示当冲突发生时，中止SQL语句并回滚当前事务。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

## enum DistributedType

```cangjie
public enum DistributedType {
    | DistributedDevice
    | DistributedCloud
    | ...
}
```

**功能：** 表示在不同设备之间分布式的数据库表。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### DistributedCloud

```cangjie
DistributedCloud
```

**功能：** 表示在设备和云端之间分布式的数据库表。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### DistributedDevice

```cangjie
DistributedDevice
```

**功能：** 表示在不同设备之间分布式的数据库表。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

## enum EncryptionAlgo

```cangjie
public enum EncryptionAlgo {
    | Aes256Gcm
    | Aes256Cbc
    | ...
}
```

**功能：** 数据库的加密算法枚举。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### Aes256Cbc

```cangjie
Aes256Cbc
```

**功能：** 数据库使用AES_256_CBC加密。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### Aes256Gcm

```cangjie
Aes256Gcm
```

**功能：** 数据库使用AES_256_GCM加密。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

## enum Field

```cangjie
public enum Field {
    | CursorField
    | OriginField
    | DeletedFlagField
    | OwnerField
    | PrivilegeField
    | SharingResourceField
    | ...
}
```

**功能：** 用于谓词查询条件的特殊字段。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### CursorField

```cangjie
CursorField
```

**功能：** 用于cursor查找的字段名。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### DeletedFlagField

```cangjie
DeletedFlagField
```

**功能：** 用于cursor查找的结果集返回时填充的字段，表示云端删除的数据同步到本地后数据是否清理。

返回的结果集中，该字段对应的value为false表示数据未清理，true表示数据已清理。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### OriginField

```cangjie
OriginField
```

**功能：** 用于cursor查找时指定数据来源的字段名。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### OwnerField

```cangjie
OwnerField
```

**功能：** 用于共享表中查找owner时返回的结果集中填充的字段，表示当前共享记录的共享发起者。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### PrivilegeField

```cangjie
PrivilegeField
```

**功能：** 用于共享表中查找共享数据权限时，返回的结果集中填充的字段，表示当前共享记录的允许的操作权限。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### SharingResourceField

```cangjie
SharingResourceField
```

**功能：** 用于数据共享查找共享数据的共享资源时，返回的结果集中填充的字段，表示共享数据的共享资源标识。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

## enum HmacAlgo

```cangjie
public enum HmacAlgo {
    | Sha1
    | Sha256
    | Sha512
    | ...
}
```

**功能：** 数据库的HMAC算法枚举。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### Sha1

```cangjie
Sha1
```

**功能：** HMAC_SHA1算法。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### Sha256

```cangjie
Sha256
```

**功能：** HMAC_SHA256算法。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### Sha512

```cangjie
Sha512
```

**功能：** HMAC_SHA512算法。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

## enum KdfAlgo

```cangjie
public enum KdfAlgo {
    | KdfSha1
    | KdfSha256
    | KdfSha512
    | ...
}
```

**功能：** 数据库的PBKDF2算法枚举。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### KdfSha1

```cangjie
KdfSha1
```

**功能：** PBKDF2_HMAC_SHA1算法。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### KdfSha256

```cangjie
KdfSha256
```

**功能：** PBKDF2_HMAC_SHA256算法。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### KdfSha512

```cangjie
KdfSha512
```

**功能：** PBKDF2_HMAC_SHA512算法。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

## enum Origin

```cangjie
public enum Origin {
    | Local
    | Cloud
    | Remote
    | ...
}
```

**功能：** 表示数据来源。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### Cloud

```cangjie
Cloud
```

**功能：** 表示云端同步的数据。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### Local

```cangjie
Local
```

**功能：** 表示本地数据。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### Remote

```cangjie
Remote
```

**功能：** 表示端端同步的数据。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

## enum Progress

```cangjie
public enum Progress {
    | SyncBegin
    | SyncInProgress
    | SyncFinish
    | ...
}
```

**功能：** 描述端云同步过程的枚举。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### SyncBegin

```cangjie
SyncBegin
```

**功能：** 表示端云同步过程开始。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### SyncFinish

```cangjie
SyncFinish
```

**功能：** 表示端云同步过程已完成。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### SyncInProgress

```cangjie
SyncInProgress
```

**功能：** 表示正在端云同步过程中。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

## enum RelationalStoreSecurityLevel

```cangjie
public enum RelationalStoreSecurityLevel {
    | S1
    | S2
    | S3
    | S4
    | ...
}
```

**功能：** 数据库的安全级别枚举。数据库的安全等级仅支持由低向高设置，不支持由高向低设置。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### S1

```cangjie
S1
```

**功能：** 表示数据库的安全级别为低级别，当数据泄露时会产生较低影响。例如，包含壁纸等系统数据的数据库。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### S2

```cangjie
S2
```

**功能：** 表示数据库的安全级别为中级别，当数据泄露时会产生较大影响。例如，包含录音、视频等用户生成数据或通话记录等信息的数据库。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### S3

```cangjie
S3
```

**功能：** 表示数据库的安全级别为高级别，当数据泄露时会产生重大影响。例如，包含用户运动、健康、位置等信息的数据库。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### S4

```cangjie
S4
```

**功能：** 表示数据库的安全级别为关键级别，当数据泄露时会产生严重影响。例如，包含认证凭据、财务数据等信息的数据库。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

## enum SubscribeType

```cangjie
public enum SubscribeType {
    | SubscribeTypeRemote
    | SubscribeTypeCloud
    | SubscribeTypeCloudDetails
    | ...
}
```

**功能：** 描述订阅类型。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### SubscribeTypeCloud

```cangjie
SubscribeTypeCloud
```

**功能：** 订阅云端数据更改。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### SubscribeTypeCloudDetails

```cangjie
SubscribeTypeCloudDetails
```

**功能：** 订阅云端数据更改详情。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### SubscribeTypeRemote

```cangjie
SubscribeTypeRemote
```

**功能：** 订阅远程数据更改。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

## enum SyncMode

```cangjie
public enum SyncMode {
    | SyncModePush
    | SyncModePull
    | SyncModeTimeFirst
    | SyncModeNativeFirst
    | SyncModeCloudFirst
    | ...
}
```

**功能：** 指数据库同步模式。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### SyncModeCloudFirst

```cangjie
SyncModeCloudFirst
```

**功能：** 表示数据从云端同步到本地设备。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### SyncModeNativeFirst

```cangjie
SyncModeNativeFirst
```

**功能：** 表示数据从本地设备同步到云端。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

### SyncModePull

```cangjie
SyncModePull
```

**功能：** 表示数据从远程设备拉至本地设备。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### SyncModePush

```cangjie
SyncModePush
```

**功能：** 表示数据从本地设备推送到远程设备。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### SyncModeTimeFirst

```cangjie
SyncModeTimeFirst
```

**功能：** 表示数据从修改时间较近的一端同步到修改时间较远的一端。

**系统能力：** SystemCapability.DistributedDataManager.CloudSync.Client

**起始版本：** 22

## enum Tokenizer

```cangjie
public enum Tokenizer {
    | NoneTokenizer
    | IcuTokenizer
    | CustomTokenizer
    | ...
}
```

**功能：** 描述fts（全文搜索）场景下使用的分词器枚举。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### CustomTokenizer

```cangjie
CustomTokenizer
```

**功能：** 表示使用自研分词器，可支持中文（简体、繁体）、英文、阿拉伯数字。CUSTOM_TOKENIZER相比ICU_TOKENIZER在分词准确率、常驻内存占用上更有优势。自研分词器支持默认分词模式和短词分词模式（short_words）两种，使用参数cut_mode可指定模式，不指定模式时使用默认模式。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### IcuTokenizer

```cangjie
IcuTokenizer
```

**功能：** 表示使用icu分词器，支持中文以及多国语言。指定icu分词器时，可指定使用哪种语言，例如zh_CN表示中文，tr_TR表示土耳其语等。详细支持的语言种类，请查阅[ICU分词器](https://gitcode.com/openharmony/third_party_icu/blob/master/icu4c/source/data/lang/zh.txt)。详细的语言缩写，请查阅该目录（[ICU支持的语言缩写](https://gitcode.com/openharmony/third_party_icu/tree/master/icu4c/source/data/locales)）下的文件名。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### NoneTokenizer

```cangjie
NoneTokenizer
```

**功能：** 不使用分词器。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

## enum RelationalStoreValueType

```cangjie
public enum RelationalStoreValueType {
    | Null
    | Integer(Int64)
    | Double(Float64)
    | StringValue(String)
    | Boolean(Bool)
    | Uint8Array(Array<UInt8>)
    | AssetEnum(Asset)
    | AssetsEnum(Array<Asset>)
    | ...
}
```

**功能：** 用于表示允许的数据字段类型，接口参数具体类型根据其功能而定。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### AssetEnum(Asset)

```cangjie
AssetEnum(Asset)
```

**功能：** 表示值类型为附件[Asset](#type-assets)。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### AssetsEnum(Array\<Asset>)

```cangjie
AssetsEnum(Array<Asset>)
```

**功能：** 表示值类型为附件数组Array\<[Asset](#class-asset)>。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### Boolean(Bool)

```cangjie
Boolean(Bool)
```

**功能：** 表示值类型为布尔值。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### Double(Float64)

```cangjie
Double(Float64)
```

**功能：** 表示值类型为浮点型数字。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### Integer(Int64)

```cangjie
Integer(Int64)
```

**功能：** 表示值类型为整型数字。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### Null

```cangjie
Null
```

**功能：** 表示值类型为空。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### StringValue(String)

```cangjie
StringValue(String)
```

**功能：** 表示值类型为字符。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

### Uint8Array(Array\<UInt8>)

```cangjie
Uint8Array(Array<UInt8>)
```

**功能：** 表示值类型为UInt8类型的数组。

**系统能力：** SystemCapability.DistributedDataManager.RelationalStore.Core

**起始版本：** 22

## type Assets

```cangjie
public type Assets = Array<Asset>
```

**功能：** [Assets](#type-assets)是[Array\<Asset>](#class-asset)类型的别名。

## type ValuesBucket

```cangjie
public type ValuesBucket = Map<String, RelationalStoreValueType>
```

**功能：** [ValuesBucket](#type-valuesbucket)是<!--RP2-->[Map\<String,RelationalStoreValueType>](https://gitcode.com/Cangjie/cangjie_docs/blob/main/docs/dev-guide/source_zh_cn/generic/generic_class.md)<!--RP2End-->类型的别名。
