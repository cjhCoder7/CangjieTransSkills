# ohos.data.data_share_predicates（数据共享谓词）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

谓词（data_share_predicates）是开发者通过DataShare查询数据库中的数据时所使用的筛选条件，通常被应用在更新数据、删除数据和查询数据中。

谓词的接口函数与数据库的筛选条件具有明确的对应关系，开发者在使用前需了解数据库相关知识。

## 导入模块

```cangjie
import kit.ArkData.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class DataSharePredicates

```cangjie
public class DataSharePredicates {
    public init()
}
```

**功能：** 提供用于不同实现不同查询方法的数据共享谓词。

> **说明：**
>
> 该类不是多线程安全的，如果应用中存在多线程同时操作该类派生出的实例，注意加锁保护。

**系统能力：** SystemCapability.DistributedDataManager.DataShare.Core

**起始版本：** 22

### init()

```cangjie
public init()
```

**功能：** DataSharePredicates的初始化构造函数。

**系统能力：** SystemCapability.DistributedDataManager.DataShare.Core

**起始版本：** 22

### func inValues(String, Array\<VBValueType>)

```cangjie
public func inValues(field: String, value: Array<VBValueType>): DataSharePredicates
```

**功能：** 该接口用于配置谓词以匹配值在指定范围内的字段。目前仅关系型数据库及键值型数据库支持该谓词。

**系统能力：** SystemCapability.DistributedDataManager.DataShare.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。</br>当field为空字符串""时，调用接口配置的谓词无效。|
|value|Array\<[VBValueType](cj-apis-values_bucket.md#enum-vbvaluetype)>|是|-|以VBValueType数组形式指定的要匹配的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[DataSharePredicates](#class-datasharepredicates)|返回与指定字段匹配的谓词。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = DataSharePredicates()
    predicates.inValues("AGE", [VBValueType.Integer(18), VBValueType.Integer(20)])
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func and()

```cangjie
public func and(): DataSharePredicates
```

**功能：** 该接口用于将和条件添加到谓词中。目前仅关系型数据库及键值型数据库支持该谓词。

**系统能力：** SystemCapability.DistributedDataManager.DataShare.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[DataSharePredicates](#class-datasharepredicates)|返回与指定字段匹配的谓词。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = DataSharePredicates()
    predicates.equalTo("NAME", VBValueType.StringValue("lisi"))
            .and()
            .equalTo("SALARY", VBValueType.Double(200.5))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func equalTo(String, VBValueType)

```cangjie
public func equalTo(field: String, value: VBValueType): DataSharePredicates
```

**功能：** 该接口用于配置谓词以匹配值等于指定值的字段。目前仅关系型数据库及键值型数据库支持该谓词。

**系统能力：** SystemCapability.DistributedDataManager.DataShare.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。</br>当field为空字符串""时，调用接口配置的谓词无效。|
|value|[VBValueType](./cj-apis-values_bucket.md#enum-vbvaluetype)|是|-|指示要与谓词匹配的值。|

**返回值：**

|类型|说明|
|:----|:----|
|[DataSharePredicates](#class-datasharepredicates)|返回与指定字段匹配的谓词。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = DataSharePredicates()
    predicates.equalTo("NAME", VBValueType.StringValue("Rose"))
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func limit(Int32, Int32)

```cangjie
public func limit(total: Int32, offset: Int32): DataSharePredicates
```

**功能：** 该接口用于配置谓词以指定结果数和起始位置。目前仅关系型数据库及键值型数据库支持该谓词。

**系统能力：** SystemCapability.DistributedDataManager.DataShare.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|total|Int32|是|-|最大数据记录数。</br>当使用关系型数据库时，取值范围参考[关系型数据库limitAs接口](./cj-apis-relational_store.md#func-limitasint32)中的value参数说明。|
|offset|Int32|是|-|指定查询结果的起始位置。</br>当使用关系型数据库时，取值范围参考[关系型数据库offsetAs接口](./cj-apis-relational_store.md#func-offsetasint32)中的rowOffset参数说明。|

**返回值：**

|类型|说明|
|:----|:----|
|[DataSharePredicates](#class-datasharepredicates)|返回与指定字段匹配的谓词。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = DataSharePredicates()
    predicates.equalTo("NAME", VBValueType.StringValue("Rose")).limit(10, 3)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func orderByAsc(String)

```cangjie
public func orderByAsc(field: String): DataSharePredicates
```

**功能：** 该接口用于配置谓词以匹配其值按升序排序的列。目前仅关系型数据库及键值型数据库支持该谓词。

**系统能力：** SystemCapability.DistributedDataManager.DataShare.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。 </br>当field为空字符串""时，调用接口配置的谓词无效。|

**返回值：**

|类型|说明|
|:----|:----|
|[DataSharePredicates](#class-datasharepredicates)|返回与指定字段匹配的谓词。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = DataSharePredicates()
    predicates.orderByAsc("AGE")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func orderByDesc(String)

```cangjie
public func orderByDesc(field: String): DataSharePredicates
```

**功能：** 该接口用于配置谓词以匹配其值按降序排序的列。目前仅关系型数据库及键值型数据库支持该谓词。

**系统能力：** SystemCapability.DistributedDataManager.DataShare.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|field|String|是|-|数据库表中的列名。</br>当field为空字符串""时，调用接口配置的谓词无效。|

**返回值：**

|类型|说明|
|:----|:----|
|[DataSharePredicates](#class-datasharepredicates)|返回与指定字段匹配的谓词。|

**异常：**

- BusinessException：对应错误码如下表，详见[关系型数据库错误码](./cj-errorcode-data-rdb.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 14800000 | Internal error. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.ArkData.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let predicates = DataSharePredicates()
    predicates.orderByDesc("AGE")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```
