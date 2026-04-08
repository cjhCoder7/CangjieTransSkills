# ohos.security.huks（通用密钥库系统）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

huks模块向应用提供密钥库能力，包括密钥管理及密钥的密码学操作等功能。

HUKS所管理的密钥可以由应用导入或者由应用调用HUKS接口生成。

## 导入模块

```cangjie
import kit.UniversalKeystoreKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## func abortSession(HuksHandleId, HuksOptions)

```cangjie
public func abortSession(handle: HuksHandleId, options: HuksOptions): Unit
```

**功能：** abortSession操作密钥接口。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|handle|[HuksHandleId](#class-hukshandleid)|是|-|abortSession操作的handle。|
|options|[HuksOptions](#class-huksoptions)|是|-|abortSession操作的参数集合。|

**异常：**

- BusinessException：对应错误码如下表，详见[HUKS错误码](./cj-errorcode-huks.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | api is not supported. |
  | 12000004 | operating file failed. |
  | 12000005 | IPC communication failed. |
  | 12000006 | error occurred in crypto engine. |
  | 12000012 | Device environment or input parameter abnormal. |
  | 12000014 | memory is insufficient. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.UniversalKeystoreKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let keyAlias = "KEY_ALIAS" // 密钥别名，在生成密钥时指定，在加密、解密和删除密钥时使用
    let options = HuksOptions(properties:
        [
            HuksParam(HuksTag.HUKS_TAG_ALGORITHM, Uint32Value(HuksKeyAlg.HUKS_ALG_AES)),
            HuksParam(HuksTag.HUKS_TAG_KEY_SIZE, Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_128)),
            HuksParam(
                HuksTag.HUKS_TAG_PURPOSE,
                Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT)
            )
        ]
    )

    generateKeyItem(keyAlias, options)

    // encrypt and abort
    let handle = initSession(keyAlias, options).handle

    abortSession(handle, options)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func anonAttestKeyItem(String, HuksOptions)

```cangjie
public func anonAttestKeyItem(keyAlias: String, options: HuksOptions): Array<String>
```

**功能：** 获取匿名化密钥证书。

该操作需要联网进行，且耗时较长。返回12000012错误码时，可能是由于网络异常导致。此时如果没有联网，需要提示用户网络没有连接，如果已经联网，可能是由于网络抖动导致失败，建议重试。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|keyAlias|String|是|-|密钥别名，存放待获取证书密钥的别名。|
|options|[HuksOptions](#class-huksoptions)|是|-|用于获取证书时指定所需参数与数据。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<String>|获取到的证书链。|

**异常：**

- BusinessException：对应错误码如下表，详见[HUKS错误码](./cj-errorcode-huks.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | check permission failed. |
  | 801 | api is not supported. |
  | 12000001 | algorithm mode is not supported. |
  | 12000004 | operating file failed. |
  | 12000005 | IPC communication failed. |
  | 12000006 | error occurred in crypto engine. |
  | 12000011 | queried entity does not exist. |
  | 12000012 | Device environment or input parameter abnormal. |
  | 12000014 | memory is insufficient. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.UniversalKeystoreKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let keyAlias = "KEY_ALIAS" // 密钥别名，在生成密钥时指定，在加密、解密和删除密钥时使用
    // generate key
    generateKeyItem(
        keyAlias,
        HuksOptions(properties:
            [
                HuksParam(HuksTag.HUKS_TAG_ALGORITHM, Uint32Value(HuksKeyAlg.HUKS_ALG_RSA)),
                HuksParam(HuksTag.HUKS_TAG_KEY_SIZE, Uint32Value(HuksKeySize.HUKS_RSA_KEY_SIZE_2048)),
                HuksParam(HuksTag.HUKS_TAG_PURPOSE, Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_VERIFY)),
                HuksParam(HuksTag.HUKS_TAG_DIGEST, Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256)),
                HuksParam(HuksTag.HUKS_TAG_PADDING, Uint32Value(HuksKeyPadding.HUKS_PADDING_PSS)),
                HuksParam(HuksTag.HUKS_TAG_BLOCK_MODE, Uint32Value(HuksCipherMode.HUKS_MODE_ECB))
            ]
        )
    )

    let challenge = "hi_challenge_data"
    let chains = anonAttestKeyItem(
        keyAlias,
        HuksOptions(properties:
            [
                HuksParam(HuksTag.HUKS_TAG_ATTESTATION_CHALLENGE, HuksParamValue.BytesValue(challenge.toArray())),
                HuksParam(HuksTag.HUKS_TAG_KEY_ALIAS, HuksParamValue.BytesValue(keyAlias.toArray()))
            ]
        )
    )
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func deleteKeyItem(String, HuksOptions)

```cangjie
public func deleteKeyItem(keyAlias: String, options: HuksOptions): Unit
```

**功能：** 删除密钥。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|keyAlias|String|是|-|密钥别名，应为生成key时传入的别名。|
|options|[HuksOptions](#class-huksoptions)|是|-|用于删除时指定密钥的属性Tag，比如删除的密钥范围（全量/单个），当删除单个时，Tag字段可传空。|

**异常：**

- BusinessException：对应错误码如下表，详见[HUKS错误码](./cj-errorcode-huks.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | api is not supported. |
  | 12000004 | operating file failed. |
  | 12000005 | IPC communication failed. |
  | 12000011 | queried entity does not exist. |
  | 12000012 | Device environment or input parameter abnormal. |
  | 12000014 | memory is insufficient. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.UniversalKeystoreKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 此处代码可添加在依赖项定义中
    func generateSimpleKey(keyAlias: String) {
        let options = HuksOptions(properties:
            [
                HuksParam(HuksTag.HUKS_TAG_ALGORITHM, Uint32Value(HuksKeyAlg.HUKS_ALG_AES)),
                HuksParam(HuksTag.HUKS_TAG_KEY_SIZE, Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_128)),
                HuksParam(
                    HuksTag.HUKS_TAG_PURPOSE,
                    Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT)
                )
            ]
        )
        generateKeyItem(keyAlias, options)
    }

    func test_delete_key() {
        let keyAlias = "KEY_ALIAS" // 密钥别名，在生成密钥时指定，在加密、解密和删除密钥时使用
        generateSimpleKey(keyAlias)
        // delete
        deleteKeyItem(keyAlias, HuksOptions())
    }

    test_delete_key()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func exportKeyItem(String, HuksOptions)

```cangjie
public func exportKeyItem(keyAlias: String, _: HuksOptions): Bytes
```

**功能：** 导出密钥。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|keyAlias|String|是|-|密钥别名，应与所用密钥生成时使用的别名相同。|
|_|[HuksOptions](#class-huksoptions)|是|-|空对象（此处传空即可）。|

**返回值：**

|类型|说明|
|:----|:----|
|Bytes|<返回从密钥中导出的公钥。|

**异常：**

- BusinessException：对应错误码如下表，详见[HUKS错误码](./cj-errorcode-huks.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | api is not supported. |
  | 12000001 | algorithm mode is not supported. |
  | 12000004 | operating file failed. |
  | 12000005 | IPC communication failed. |
  | 12000006 | error occurred in crypto engine. |
  | 12000011 | queried entity does not exist. |
  | 12000012 | Device environment or input parameter abnormal. |
  | 12000014 | memory is insufficient. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.UniversalKeystoreKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let keyAlias = "KEY_ALIAS" // 密钥别名，在生成密钥时指定，在加密、解密和删除密钥时使用
    /* 1. Generate Key */
    generateKeyItem(
        keyAlias,
        HuksOptions(properties:
            [
                HuksParam(HuksTag.HUKS_TAG_ALGORITHM, Uint32Value(HuksKeyAlg.HUKS_ALG_ECC)),
                HuksParam(HuksTag.HUKS_TAG_KEY_SIZE, Uint32Value(HuksKeySize.HUKS_ECC_KEY_SIZE_256)),
                HuksParam(
                    HuksTag.HUKS_TAG_PURPOSE,
                    Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_VERIFY | HuksKeyPurpose.HUKS_KEY_PURPOSE_SIGN
                )),
                HuksParam(HuksTag.HUKS_TAG_DIGEST, Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256))
            ]
        )
    )
    /* 2. Export Key */
    let data = exportKeyItem(keyAlias, HuksOptions())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func finishSession(HuksHandleId, HuksOptions, Bytes)

```cangjie
public func finishSession(handle: HuksHandleId, options: HuksOptions, token!: Bytes = Bytes<UInt8>()): Option<Bytes>
```

**功能：** finishSession操作密钥接口。[security_huks.initSession](#func-initsessionstring-huksoptions)、[security_huks.updateSession](#func-updatesessionhukshandleid-huksoptions-bytes)、[security_huks.finishSession](#func-finishsessionhukshandleid-huksoptions-bytes)为三段式接口，需要一起使用。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|handle|[HuksHandleId](#class-hukshandleid)|是|-|finishSession操作的handle。|
|options|[HuksOptions](#class-huksoptions)|是|-|finishSession操作的参数集合。|
|token|Bytes|否|Bytes()|**命名参数。** 密钥二次认证密钥访问控制的用户鉴权证明(AuthToken)，不填表示不进行二次认证密钥访问控制。|

**返回值：**

|类型|说明|
|:----|:----|
|Option\<Bytes>|表示USER IAM服务的AuthToken的值。|

**异常：**

- BusinessException：对应错误码如下表，详见[HUKS错误码](./cj-errorcode-huks.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | api is not supported. |
  | 12000001 | algorithm mode is not supported. |
  | 12000002 | algorithm param is missing. |
  | 12000003 | algorithm param is invalid. |
  | 12000004 | operating file failed. |
  | 12000005 | IPC communication failed. |
  | 12000006 | error occurred in crypto engine. |
  | 12000007 | this credential is already invalidated permanently .|
  | 12000008 | verify auth token failed. |
  | 12000009 | auth token is already timeout. |
  | 12000011 | queried entity does not exist. |
  | 12000012 | Device environment or input parameter abnormal. |
  | 12000014 | memory is insufficient. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.UniversalKeystoreKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let keyAlias = "KEY_ALIAS" // 密钥别名，在生成密钥时指定，在加密、解密和删除密钥时使用
    let options = HuksOptions(properties:
        [
            HuksParam(HuksTag.HUKS_TAG_ALGORITHM, Uint32Value(HuksKeyAlg.HUKS_ALG_AES)),
            HuksParam(HuksTag.HUKS_TAG_KEY_SIZE, Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_128)),
            HuksParam(
                HuksTag.HUKS_TAG_PURPOSE,
                Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT)
            ),
            HuksParam(HuksTag.HUKS_TAG_PADDING, Uint32Value(HuksKeyPadding.HUKS_PADDING_PKCS7)),
            HuksParam(HuksTag.HUKS_TAG_BLOCK_MODE, Uint32Value(HuksCipherMode.HUKS_MODE_CBC))
        ]
    )
    generateKeyItem(keyAlias, options)
    // encrypt
    let handle = initSession(keyAlias, options).handle
    let cipherData = finishSession(handle, options)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func generateKeyItem(String, HuksOptions)

```cangjie
public func generateKeyItem(keyAlias: String, options: HuksOptions): Unit
```

**功能：** 生成密钥。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|keyAlias|String|是|-|密钥别名。密钥别名的最大长度为128字节，建议不包含个人信息等敏感词汇。|
|options|[HuksOptions](#class-huksoptions)|是|-|用于存放生成key所需TAG。其中密钥使用的算法、密钥用途、密钥长度为必选参数。|

**异常：**

- BusinessException：对应错误码如下表，详见[HUKS错误码](./cj-errorcode-huks.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | api is not supported. |
  | 12000001 | algorithm mode is not supported. |
  | 12000002 | algorithm param is missing. |
  | 12000003 | algorithm param is invalid. |
  | 12000004 | operating file failed. |
  | 12000005 | IPC communication failed. |
  | 12000006 | error occurred in crypto engine. |
  | 12000012 | Device environment or input parameter abnormal. |
  | 12000013 | queried credential does not exist. |
  | 12000014 | memory is insufficient. |
  | 12000015 | Failed to obtain the security information via UserIAM. |
  | 12000017 | The key with same alias is already exist. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.UniversalKeystoreKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let keyAlias = "KEY_ALIAS" // 密钥别名，在生成密钥时指定，在加密、解密和删除密钥时使用
    let options = HuksOptions(properties:
        [
            HuksParam(HuksTag.HUKS_TAG_ALGORITHM, Uint32Value(HuksKeyAlg.HUKS_ALG_AES)),
            HuksParam(HuksTag.HUKS_TAG_KEY_SIZE, Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_128)),
            HuksParam(
                HuksTag.HUKS_TAG_PURPOSE,
                Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT)
            )
        ]
    )
    generateKeyItem(keyAlias, options)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func getKeyItemProperties(String, HuksOptions)

```cangjie
public func getKeyItemProperties(keyAlias: String, _: HuksOptions): Array<HuksParam>
```

**功能：** 获取密钥属性。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|keyAlias|String|是|-|密钥别名，应与所用密钥生成时使用的别名相同。|
|_|[HuksOptions](#class-huksoptions)|是|-|空对象（此处传空即可）。|

**返回值：**

|类型|说明|
|:----|:----|
|Array\<[HuksParam](#class-huksparam)>|返回密钥属性。|

**异常：**

- BusinessException：对应错误码如下表，详见[HUKS错误码](./cj-errorcode-huks.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | api is not supported. |
  | 12000001 | algorithm mode is not supported. |
  | 12000004 | operating file failed. |
  | 12000005 | IPC communication failed. |
  | 12000006 | error occurred in crypto engine. |
  | 12000011 | queried entity does not exist. |
  | 12000012 | Device environment or input parameter abnormal. |
  | 12000014 | memory is insufficient. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.UniversalKeystoreKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let keyAlias = "KEY_ALIAS" // 密钥别名，在生成密钥时指定，在加密、解密和删除密钥时使用
    let properties = getKeyItemProperties(keyAlias, HuksOptions())
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func importKeyItem(String, HuksOptions)

```cangjie
public func importKeyItem(keyAlias: String, options: HuksOptions): Unit
```

**功能：** 导入明文密钥。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|keyAlias|String|是|-|密钥别名（密钥别名的最大长度为128字节，建议不包含个人信息等敏感词汇）。|
|options|[HuksOptions](#class-huksoptions)|是|-|用于导入时所需TAG和需要导入的密钥。其中密钥使用的算法、密钥用途、密钥长度为必选参数。|

**异常：**

- BusinessException：对应错误码如下表，详见[HUKS错误码](./cj-errorcode-huks.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | api is not supported. |
  | 12000001 | algorithm mode is not supported. |
  | 12000002 | algorithm param is missing. |
  | 12000003 | algorithm param is invalid. |
  | 12000004 | operating file failed. |
  | 12000005 | IPC communication failed. |
  | 12000006 | error occurred in crypto engine. |
  | 12000011 | queried entity does not exist. |
  | 12000012 | Device environment or input parameter abnormal. |
  | 12000013 | queried credential does not exist. |
  | 12000014 | memory is insufficient. |
  | 12000015 | Failed to obtain the security information via UserIAM. |
  | 12000017 | The key with same alias is already exist. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.UniversalKeystoreKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let keyAlias = "KEY_ALIAS" // 密钥别名，在生成密钥时指定，在加密、解密和删除密钥时使用
    let key = Array<UInt8>(Int64(HuksKeySize.HUKS_AES_KEY_SIZE_256 / 8), {i => UInt8(i & 0xFF)})
    importKeyItem(
        keyAlias,
        HuksOptions(properties:
            [
                HuksParam(HuksTag.HUKS_TAG_ALGORITHM, Uint32Value(HuksKeyAlg.HUKS_ALG_AES)),
                HuksParam(HuksTag.HUKS_TAG_KEY_SIZE, Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256)),
                HuksParam(
                    HuksTag.HUKS_TAG_PURPOSE,
                    Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT)
                )
            ],
            inData: key
        )
    )
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func importWrappedKeyItem(String, String, HuksOptions)

```cangjie
public func importWrappedKeyItem(keyAlias: String, wrappingKeyAlias: String, options: HuksOptions): Unit
```

**功能：** 导入加密密钥。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|keyAlias|String|是|-|密钥别名，存放待导入密钥的别名。|
|wrappingKeyAlias|String|是|-|密钥别名，对应密钥用于解密加密的密钥数据。|
|options|[HuksOptions](#class-huksoptions)|是|-|用于导入时所需TAG和需要导入的加密的密钥数据。其中密钥使用的算法、密钥用途、密钥长度为必选参数。|

**异常：**

- BusinessException：对应错误码如下表，详见[HUKS错误码](./cj-errorcode-huks.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 201 | check permission failed. |
  | 801 | api is not supported. |
  | 12000001 | algorithm mode is not supported. |
  | 12000002 | algorithm param is missing. |
  | 12000003 | algorithm param is invalid. |
  | 12000004 | operating file failed. |
  | 12000005 | IPC communication failed. |
  | 12000006 | error occurred in crypto engine. |
  | 12000011 | queried entity does not exist. |
  | 12000012 | Device environment or input parameter abnormal. |
  | 12000013 | queried credential does not exist. |
  | 12000014 | memory is insufficient. |
  | 12000015 | Failed to obtain the security information via UserIAM. |
  | 12000017 | The key with same alias is already exist. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.UniversalKeystoreKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

let keyAlias = "KEY_ALIAS" // 密钥别名，在生成密钥时指定，在加密、解密和删除密钥时使用
let wrappingKeyAlias = "test_import_wrapped_wrong_wrapping_key"

try {
    importWrappedKeyItem(
        keyAlias,
        wrappingKeyAlias,
        HuksOptions(
            properties:  [
                HuksParam(HuksTag.HUKS_TAG_ALGORITHM, HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES)),
                HuksParam(HuksTag.HUKS_TAG_KEY_SIZE, HuksParamValue.Uint32Value( HuksKeySize.HUKS_AES_KEY_SIZE_256)),
                HuksParam(
                    HuksTag.HUKS_TAG_PURPOSE,
                    HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT)
                )
            ],
            inData: Bytes()
        )
    )} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func initSession(String, HuksOptions)

```cangjie
public func initSession(keyAlias: String, options: HuksOptions): HuksSessionHandle
```

**功能：** initSession操作密钥接口。[security_huks.initSession](#func-initsessionstring-huksoptions)、[security_huks.updateSession](#func-updatesessionhukshandleid-huksoptions-bytes)、[security_huks.finishSession](#func-finishsessionhukshandleid-huksoptions-bytes)为三段式接口，需要一起使用。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|keyAlias|String|是|-|initSession操作密钥的别名。|
|options|[HuksOptions](#class-huksoptions)|是|-|initSession操作的参数集合。|

**返回值：**

|类型|说明|
|:----|:----|
|[HuksSessionHandle](#class-hukssessionhandle)|返回密钥huks Handle。|

**异常：**

- BusinessException：对应错误码如下表，详见[HUKS错误码](./cj-errorcode-huks.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | api is not supported. |
  | 12000001 | algorithm mode is not supported. |
  | 12000002 | algorithm param is missing. |
  | 12000003 | algorithm param is invalid. |
  | 12000004 | operating file failed. |
  | 12000005 | IPC communication failed. |
  | 12000006 | error occurred in crypto engine. |
  | 12000010 | the number of sessions has reached limit. |
  | 12000011 | queried entity does not exist. |
  | 12000012 | Device environment or input parameter abnormal. |
  | 12000014 | memory is insufficient. |
  | 12000018 | the input parameter is invalid. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.UniversalKeystoreKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let keyAlias = "KEY_ALIAS" // 密钥别名，在生成密钥时指定，在加密、解密和删除密钥时使用
    let options = HuksOptions(properties:
        [
            HuksParam(HuksTag.HUKS_TAG_ALGORITHM, Uint32Value(HuksKeyAlg.HUKS_ALG_AES)),
            HuksParam(HuksTag.HUKS_TAG_KEY_SIZE, Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_128)),
            HuksParam(
                HuksTag.HUKS_TAG_PURPOSE,
                Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT)
            ),
            HuksParam(HuksTag.HUKS_TAG_PADDING, Uint32Value(HuksKeyPadding.HUKS_PADDING_PKCS7)),
            HuksParam(HuksTag.HUKS_TAG_BLOCK_MODE, Uint32Value(HuksCipherMode.HUKS_MODE_CBC))
        ]
    )
    generateKeyItem(keyAlias, options)
    // encrypt
    let handle = initSession(keyAlias, options).handle
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func hasKeyItem(String, HuksOptions)

```cangjie
public func hasKeyItem(keyAlias: String, options: HuksOptions): Bool
```

**功能：** 判断密钥是否存在。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|keyAlias|String|是|-|待查找的密钥的别名。|
|options|[HuksOptions](#class-huksoptions)|是|-|用于查询时指定密钥的属性Tag，比如查询的密钥范围（全量/单个），当查询单个时，Tag字段可传空。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|表示密钥是否存在。|

**异常：**

- BusinessException：对应错误码如下表，详见[HUKS错误码](./cj-errorcode-huks.md)和[通用错误码](../cj-errorcode-universal.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | api is not supported. |
  | 12000004 | operating file failed. |
  | 12000005 | IPC communication failed. |
  | 12000006 | error occurred in crypto engine. |
  | 12000011 | queried entity does not exist. |
  | 12000012 | Device environment or input parameter abnormal. |
  | 12000014 | memory is insufficient. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.UniversalKeystoreKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    // 此处代码可添加在依赖项定义中
    func generateSimpleKey(keyAlias: String) {
        let options = HuksOptions(properties:
            [
                HuksParam(HuksTag.HUKS_TAG_ALGORITHM, Uint32Value(HuksKeyAlg.HUKS_ALG_AES)),
                HuksParam(HuksTag.HUKS_TAG_KEY_SIZE, Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_128)),
                HuksParam(
                    HuksTag.HUKS_TAG_PURPOSE,
                    Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT)
                )
            ]
        )
        generateKeyItem(keyAlias, options)
    }

    let keyAlias = "KEY_ALIAS" // 密钥别名，在生成密钥时指定，在加密、解密和删除密钥时使用
    var result = hasKeyItem(keyAlias, HuksOptions()) // false
    generateSimpleKey(keyAlias)
    result = hasKeyItem(keyAlias, HuksOptions()) // true
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## func updateSession(HuksHandleId, HuksOptions, Bytes)

```cangjie
public func updateSession(handle: HuksHandleId, options: HuksOptions, token!: Bytes = Bytes<UInt8>()): Option<Bytes>
```

**功能：** updateSession操作密钥接口。[security_huks.initSession](#func-initsessionstring-huksoptions)、[security_huks.updateSession](#func-updatesessionhukshandleid-huksoptions-bytes)、[security_huks.finishSession](#func-finishsessionhukshandleid-huksoptions-bytes)为三段式接口，需要一起使用。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|handle|[HuksHandleId](#class-hukshandleid)|是|-|updateSession操作的handle。|
|options|[HuksOptions](#class-huksoptions)|是|-|updateSession操作的参数集合。|
|token|Bytes|否|Bytes()|**命名参数。** 密钥二次认证密钥访问控制的用户鉴权证明(AuthToken)，不填表示不进行二次认证密钥访问控制。|

**返回值：**

|类型|说明|
|:----|:----|
|Option\<Bytes>|输出密钥更新结果。|

**异常：**

- BusinessException：对应错误码如下表，详见[HUKS错误码](./cj-errorcode-huks.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 801 | api is not supported. |
  | 12000001 | algorithm mode is not supported. |
  | 12000002 | algorithm param is missing. |
  | 12000003 | algorithm param is invalid. |
  | 12000004 | operating file failed. |
  | 12000005 | IPC communication failed. |
  | 12000006 | error occurred in crypto engine. |
  | 12000007 | this credential is already invalidated permanently .|
  | 12000008 | verify auth token failed. |
  | 12000009 | auth token is already timeout. |
  | 12000011 | queried entity does not exist. |
  | 12000012 | Device environment or input parameter abnormal. |
  | 12000014 | memory is insufficient. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.UniversalKeystoreKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

let keyAlias = "KEY_ALIAS" // 密钥别名，在生成密钥时指定，在加密、解密和删除密钥时使用
try {
    let plainText = 'PLAIN_TEXT'  // 待加密的明文
    let iv = 'TEST_IV' // 此处为样例代码，实际使用需采用随机值
    let options = HuksOptions(
        properties:  [
            HuksParam(HuksTag.HUKS_TAG_ALGORITHM, HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES)),
            HuksParam(HuksTag.HUKS_TAG_KEY_SIZE, HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_128)),
            HuksParam(
                HuksTag.HUKS_TAG_PURPOSE,
                HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT)
            )
        ],
        inData: Bytes()
    )
    let encOptions = HuksOptions(
        properties: [
            HuksParam(HuksTag.HUKS_TAG_ALGORITHM, HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES)),
            HuksParam(HuksTag.HUKS_TAG_KEY_SIZE, HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_128)),
            HuksParam(HuksTag.HUKS_TAG_PURPOSE, HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT)),
            HuksParam(HuksTag.HUKS_TAG_PADDING, HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_PKCS7)),
            HuksParam(HuksTag.HUKS_TAG_BLOCK_MODE, HuksParamValue.Uint32Value(HuksCipherMode.HUKS_MODE_CBC)),
            HuksParam(HuksTag.HUKS_TAG_IV, HuksParamValue.BytesValue(iv.toArray()))
        ],
        inData: plainText.toArray()
    )

    generateKeyItem(keyAlias, options)

    let handle = initSession(keyAlias, encOptions).handle
    let bytes: Array<UInt8> = []
    updateSession(handle, HuksOptions(), token: bytes) 
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class HuksAuthAccessType

```cangjie
public class HuksAuthAccessType {
    public static const HUKS_AUTH_ACCESS_INVALID_CLEAR_PASSWORD: UInt32 = 1 << 0
    public static const HUKS_AUTH_ACCESS_INVALID_NEW_BIO_ENROLL: UInt32 = 1 << 1
}
```

**功能：** 表示安全访问控制类型。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_AUTH_ACCESS_INVALID_CLEAR_PASSWORD

```cangjie
public static const HUKS_AUTH_ACCESS_INVALID_CLEAR_PASSWORD: UInt32 = 1 << 0
```

**功能：** 表示安全访问控制类型为清除密码后密钥无效。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_AUTH_ACCESS_INVALID_NEW_BIO_ENROLL

```cangjie
public static const HUKS_AUTH_ACCESS_INVALID_NEW_BIO_ENROLL: UInt32 = 1 << 1
```

**功能：** 表示安全访问控制类型为新录入生物特征后密钥无效。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

## class HuksAuthStorageLevel

```cangjie
public class HuksAuthStorageLevel {
    public static const HUKS_AUTH_STORAGE_LEVEL_DE: UInt32 = 0
    public static const HUKS_AUTH_STORAGE_LEVEL_CE: UInt32 = 1
    public static const HUKS_AUTH_STORAGE_LEVEL_ECE: UInt32 = 2
}
```

**功能：** 表示生成或导入密钥时，指定该密钥的存储安全等级。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_AUTH_STORAGE_LEVEL_CE

```cangjie
public static const HUKS_AUTH_STORAGE_LEVEL_CE: UInt32 = 1
```

**功能：** 表示密钥仅在首次解锁后可访问。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_AUTH_STORAGE_LEVEL_DE

```cangjie
public static const HUKS_AUTH_STORAGE_LEVEL_DE: UInt32 = 0
```

**功能：** 表示密钥仅在开机后可访问。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_AUTH_STORAGE_LEVEL_ECE

```cangjie
public static const HUKS_AUTH_STORAGE_LEVEL_ECE: UInt32 = 2
```

**功能：** 表示密钥仅在解锁状态时可访问。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksChallengePosition

```cangjie
public class HuksChallengePosition {
    public static const HUKS_CHALLENGE_POS_0: UInt32 = 0
    public static const HUKS_CHALLENGE_POS_1: UInt32 = 1
    public static const HUKS_CHALLENGE_POS_2: UInt32 = 2
    public static const HUKS_CHALLENGE_POS_3: UInt32 = 3
}
```

**功能：** 表示challenge类型为用户自定义类型时，生成的challenge有效长度仅为8字节连续的数据，且仅支持4种位置。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_CHALLENGE_POS_0

```cangjie
public static const HUKS_CHALLENGE_POS_0: UInt32 = 0
```

**功能：** 表示0~7字节为当前密钥的有效challenge。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_CHALLENGE_POS_1

```cangjie
public static const HUKS_CHALLENGE_POS_1: UInt32 = 1
```

**功能：** 表示8~15字节为当前密钥的有效challenge。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_CHALLENGE_POS_2

```cangjie
public static const HUKS_CHALLENGE_POS_2: UInt32 = 2
```

**功能：** 表示16~23字节为当前密钥的有效challenge。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_CHALLENGE_POS_3

```cangjie
public static const HUKS_CHALLENGE_POS_3: UInt32 = 3
```

**功能：** 表示24~31字节为当前密钥的有效challenge。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

## class HuksChallengeType

```cangjie
public class HuksChallengeType {
    public static const HUKS_CHALLENGE_TYPE_NORMAL: UInt32 = 0
    public static const HUKS_CHALLENGE_TYPE_CUSTOM: UInt32 = 1
    public static const HUKS_CHALLENGE_TYPE_NONE: UInt32 = 2
}
```

**功能：** 表示密钥使用时生成challenge的类型。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_CHALLENGE_TYPE_CUSTOM

```cangjie
public static const HUKS_CHALLENGE_TYPE_CUSTOM: UInt32 = 1
```

**功能：** 表示challenge为用户自定义类型。支持使用多个密钥仅一次认证。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_CHALLENGE_TYPE_NONE

```cangjie
public static const HUKS_CHALLENGE_TYPE_NONE: UInt32 = 2
```

**功能：** 表示免challenge类型。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_CHALLENGE_TYPE_NORMAL

```cangjie
public static const HUKS_CHALLENGE_TYPE_NORMAL: UInt32 = 0
```

**功能：** 表示challenge为普通类型，默认32字节。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

## class HuksCipherMode

```cangjie
public class HuksCipherMode {
    public static const HUKS_MODE_ECB: UInt32 = 1
    public static const HUKS_MODE_CBC: UInt32 = 2
    public static const HUKS_MODE_CTR: UInt32 = 3
    public static const HUKS_MODE_OFB: UInt32 = 4
    public static const HUKS_MODE_CCM: UInt32 = 31
    public static const HUKS_MODE_GCM: UInt32 = 32
}
```

**功能：** 表示加密模式。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_MODE_CBC

```cangjie
public static const HUKS_MODE_CBC: UInt32 = 2
```

**功能：** 表示使用CBC加密模式。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_MODE_CCM

```cangjie
public static const HUKS_MODE_CCM: UInt32 = 31
```

**功能：** 表示使用CCM加密模式。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_MODE_CTR

```cangjie
public static const HUKS_MODE_CTR: UInt32 = 3
```

**功能：** 表示使用CTR加密模式。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_MODE_ECB

```cangjie
public static const HUKS_MODE_ECB: UInt32 = 1
```

**功能：** 表示使用ECB加密模式。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_MODE_GCM

```cangjie
public static const HUKS_MODE_GCM: UInt32 = 32
```

**功能：** 表示使用GCM加密模式。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_MODE_OFB

```cangjie
public static const HUKS_MODE_OFB: UInt32 = 4
```

**功能：** 表示使用OFB加密模式。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksHandleId

```cangjie
public class HuksHandleId {}
```

**功能：** 加密handle的id。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

## class HuksImportKeyType

```cangjie
public class HuksImportKeyType {
    public static const HUKS_KEY_TYPE_PUBLIC_KEY: UInt32 = 0
    public static const HUKS_KEY_TYPE_PRIVATE_KEY: UInt32 = 1
    public static const HUKS_KEY_TYPE_KEY_PAIR: UInt32 = 2
}
```

**功能：** 表示导入密钥的密钥类型，默认为导入公钥，导入对称密钥时不需要该字段。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_TYPE_KEY_PAIR

```cangjie
public static const HUKS_KEY_TYPE_KEY_PAIR: UInt32 = 2
```

**功能：** 表示导入的密钥类型为公私钥对。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_TYPE_PRIVATE_KEY

```cangjie
public static const HUKS_KEY_TYPE_PRIVATE_KEY: UInt32 = 1
```

**功能：** 表示导入的密钥类型为私钥。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_TYPE_PUBLIC_KEY

```cangjie
public static const HUKS_KEY_TYPE_PUBLIC_KEY: UInt32 = 0
```

**功能：** 表示导入的密钥类型为公钥。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksKeyAlg

```cangjie
public class HuksKeyAlg {
    public static const HUKS_ALG_RSA: UInt32 = 1
    public static const HUKS_ALG_ECC: UInt32 = 2
    public static const HUKS_ALG_DSA: UInt32 = 3
    public static const HUKS_ALG_AES: UInt32 = 20
    public static const HUKS_ALG_HMAC: UInt32 = 50
    public static const HUKS_ALG_HKDF: UInt32 = 51
    public static const HUKS_ALG_PBKDF2: UInt32 = 52
    public static const HUKS_ALG_ECDH: UInt32 = 100
    public static const HUKS_ALG_X25519: UInt32 = 101
    public static const HUKS_ALG_ED25519: UInt32 = 102
    public static const HUKS_ALG_DH: UInt32 = 103
    public static const HUKS_ALG_SM2: UInt32 = 150
    public static const HUKS_ALG_SM3: UInt32 = 151
    public static const HUKS_ALG_SM4: UInt32 = 152
}
```

**功能：** 表示密钥使用的算法。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ALG_AES

```cangjie
public static const HUKS_ALG_AES: UInt32 = 20
```

**功能：** 表示使用AES算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ALG_DH

```cangjie
public static const HUKS_ALG_DH: UInt32 = 103
```

**功能：** 表示使用DH算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ALG_DSA

```cangjie
public static const HUKS_ALG_DSA: UInt32 = 3
```

**功能：** 表示使用DSA算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ALG_ECC

```cangjie
public static const HUKS_ALG_ECC: UInt32 = 2
```

**功能：** 表示使用ECC算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ALG_ECDH

```cangjie
public static const HUKS_ALG_ECDH: UInt32 = 100
```

**功能：** 表示使用ECDH算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ALG_ED25519

```cangjie
public static const HUKS_ALG_ED25519: UInt32 = 102
```

**功能：** 表示使用ED25519算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ALG_HKDF

```cangjie
public static const HUKS_ALG_HKDF: UInt32 = 51
```

**功能：** 表示使用HKDF算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ALG_HMAC

```cangjie
public static const HUKS_ALG_HMAC: UInt32 = 50
```

**功能：** 表示使用HMAC算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ALG_PBKDF2

```cangjie
public static const HUKS_ALG_PBKDF2: UInt32 = 52
```

**功能：** 表示使用PBKDF2算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ALG_RSA

```cangjie
public static const HUKS_ALG_RSA: UInt32 = 1
```

**功能：** 表示使用RSA算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ALG_SM2

```cangjie
public static const HUKS_ALG_SM2: UInt32 = 150
```

**功能：** 表示使用SM2算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ALG_SM3

```cangjie
public static const HUKS_ALG_SM3: UInt32 = 151
```

**功能：** 表示使用SM3算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ALG_SM4

```cangjie
public static const HUKS_ALG_SM4: UInt32 = 152
```

**功能：** 表示使用SM4算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ALG_X25519

```cangjie
public static const HUKS_ALG_X25519: UInt32 = 101
```

**功能：** 表示使用X25519算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksKeyDigest

```cangjie
public class HuksKeyDigest {
    public static const HUKS_DIGEST_NONE: UInt32 = 0
    public static const HUKS_DIGEST_MD5: UInt32 = 1
    public static const HUKS_DIGEST_SM3: UInt32 = 2
    public static const HUKS_DIGEST_SHA1: UInt32 = 10
    public static const HUKS_DIGEST_SHA224: UInt32 = 11
    public static const HUKS_DIGEST_SHA256: UInt32 = 12
    public static const HUKS_DIGEST_SHA384: UInt32 = 13
    public static const HUKS_DIGEST_SHA512: UInt32 = 14
}
```

**功能：** 表示摘要算法。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_DIGEST_MD5

```cangjie
public static const HUKS_DIGEST_MD5: UInt32 = 1
```

**功能：** 表示MD5摘要算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_DIGEST_NONE

```cangjie
public static const HUKS_DIGEST_NONE: UInt32 = 0
```

**功能：** 表示无摘要算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_DIGEST_SHA1

```cangjie
public static const HUKS_DIGEST_SHA1: UInt32 = 10
```

**功能：** 表示SHA1摘要算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_DIGEST_SHA224

```cangjie
public static const HUKS_DIGEST_SHA224: UInt32 = 11
```

**功能：** 表示SHA224摘要算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_DIGEST_SHA256

```cangjie
public static const HUKS_DIGEST_SHA256: UInt32 = 12
```

**功能：** 表示SHA256摘要算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_DIGEST_SHA384

```cangjie
public static const HUKS_DIGEST_SHA384: UInt32 = 13
```

**功能：** 表示SHA384摘要算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_DIGEST_SHA512

```cangjie
public static const HUKS_DIGEST_SHA512: UInt32 = 14
```

**功能：** 表示SHA512摘要算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_DIGEST_SM3

```cangjie
public static const HUKS_DIGEST_SM3: UInt32 = 2
```

**功能：** 表示SM3摘要算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksKeyFlag

```cangjie
public class HuksKeyFlag {
    public static const HUKS_KEY_FLAG_IMPORT_KEY: UInt32 = 1
    public static const HUKS_KEY_FLAG_GENERATE_KEY: UInt32 = 2
    public static const HUKS_KEY_FLAG_AGREE_KEY: UInt32 = 3
    public static const HUKS_KEY_FLAG_DERIVE_KEY: UInt32 = 4
}
```

**功能：** 表示密钥的产生方式。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_FLAG_AGREE_KEY

```cangjie
public static const HUKS_KEY_FLAG_AGREE_KEY: UInt32 = 3
```

**功能：** 表示通过生成密钥协商接口生成的密钥。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_FLAG_DERIVE_KEY

```cangjie
public static const HUKS_KEY_FLAG_DERIVE_KEY: UInt32 = 4
```

**功能：** 表示通过生成密钥派生接口生成的密钥。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_FLAG_GENERATE_KEY

```cangjie
public static const HUKS_KEY_FLAG_GENERATE_KEY: UInt32 = 2
```

**功能：** 表示通过生成密钥接口生成的密钥。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_FLAG_IMPORT_KEY

```cangjie
public static const HUKS_KEY_FLAG_IMPORT_KEY: UInt32 = 1
```

**功能：** 表示通过导入公钥接口导入的密钥。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksKeyGenerationType

```cangjie
public class HuksKeyGenerationType {
    public static const HUKS_KEY_GENERATE_TYPE_DEFAULT: UInt32 = 0
    public static const HUKS_KEY_GENERATE_TYPE_DERIVE: UInt32 = 1
    public static const HUKS_KEY_GENERATE_TYPE_AGREE: UInt32 = 2
}
```

**功能：** 表示生成密钥的类型。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_GENERATE_TYPE_AGREE

```cangjie
public static const HUKS_KEY_GENERATE_TYPE_AGREE: UInt32 = 2
```

**功能：** 协商生成的密钥。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_GENERATE_TYPE_DEFAULT

```cangjie
public static const HUKS_KEY_GENERATE_TYPE_DEFAULT: UInt32 = 0
```

**功能：** 默认生成的密钥。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_GENERATE_TYPE_DERIVE

```cangjie
public static const HUKS_KEY_GENERATE_TYPE_DERIVE: UInt32 = 1
```

**功能：** 派生生成的密钥。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksKeyPadding

```cangjie
public class HuksKeyPadding {
    public static const HUKS_PADDING_NONE: UInt32 = 0
    public static const HUKS_PADDING_OAEP: UInt32 = 1
    public static const HUKS_PADDING_PSS: UInt32 = 2
    public static const HUKS_PADDING_PKCS1_V1_5: UInt32 = 3
    public static const HUKS_PADDING_PKCS5: UInt32 = 4
    public static const HUKS_PADDING_PKCS7: UInt32 = 5
}
```

**功能：** 表示补齐算法。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_PADDING_NONE

```cangjie
public static const HUKS_PADDING_NONE: UInt32 = 0
```

**功能：** 表示不使用补齐算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_PADDING_OAEP

```cangjie
public static const HUKS_PADDING_OAEP: UInt32 = 1
```

**功能：** 表示使用OAEP填充算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_PADDING_PKCS1_V1_5

```cangjie
public static const HUKS_PADDING_PKCS1_V1_5: UInt32 = 3
```

**功能：** 表示使用PKCS1_V1_5填充算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_PADDING_PKCS5

```cangjie
public static const HUKS_PADDING_PKCS5: UInt32 = 4
```

**功能：** 表示使用PKCS5填充算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_PADDING_PKCS7

```cangjie
public static const HUKS_PADDING_PKCS7: UInt32 = 5
```

**功能：** 表示使用PKCS7补齐算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_PADDING_PSS

```cangjie
public static const HUKS_PADDING_PSS: UInt32 = 2
```

**功能：** 表示使用PSS补齐算法。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksKeyPurpose

```cangjie
public class HuksKeyPurpose {
    public static const HUKS_KEY_PURPOSE_ENCRYPT: UInt32 = 1
    public static const HUKS_KEY_PURPOSE_DECRYPT: UInt32 = 2
    public static const HUKS_KEY_PURPOSE_SIGN: UInt32 = 4
    public static const HUKS_KEY_PURPOSE_VERIFY: UInt32 = 8
    public static const HUKS_KEY_PURPOSE_DERIVE: UInt32 = 16
    public static const HUKS_KEY_PURPOSE_WRAP: UInt32 = 32
    public static const HUKS_KEY_PURPOSE_UNWRAP: UInt32 = 64
    public static const HUKS_KEY_PURPOSE_MAC: UInt32 = 128
    public static const HUKS_KEY_PURPOSE_AGREE: UInt32 = 256
}
```

**功能：** 表示密钥用途。

一个密钥仅能用于单类用途，不能既用于加解密又用于签名验签。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_PURPOSE_AGREE

```cangjie
public static const HUKS_KEY_PURPOSE_AGREE: UInt32 = 256
```

**功能：** 表示密钥用于进行密钥协商。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_PURPOSE_DECRYPT

```cangjie
public static const HUKS_KEY_PURPOSE_DECRYPT: UInt32 = 2
```

**功能：** 表示密钥用于对密文进行解密操作。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_PURPOSE_DERIVE

```cangjie
public static const HUKS_KEY_PURPOSE_DERIVE: UInt32 = 16
```

**功能：** 表示密钥用于派生密钥。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_PURPOSE_ENCRYPT

```cangjie
public static const HUKS_KEY_PURPOSE_ENCRYPT: UInt32 = 1
```

**功能：** 表示密钥用于对明文进行加密操作。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_PURPOSE_MAC

```cangjie
public static const HUKS_KEY_PURPOSE_MAC: UInt32 = 128
```

**功能：** 表示密钥用于生成mac消息验证码。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_PURPOSE_SIGN

```cangjie
public static const HUKS_KEY_PURPOSE_SIGN: UInt32 = 4
```

**功能：** 表示密钥用于对数据进行签名。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_PURPOSE_UNWRAP

```cangjie
public static const HUKS_KEY_PURPOSE_UNWRAP: UInt32 = 64
```

**功能：** 表示密钥加密导入。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_PURPOSE_VERIFY

```cangjie
public static const HUKS_KEY_PURPOSE_VERIFY: UInt32 = 8
```

**功能：** 表示密钥用于验证签名后的数据。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_KEY_PURPOSE_WRAP

```cangjie
public static const HUKS_KEY_PURPOSE_WRAP: UInt32 = 32
```

**功能：** 表示密钥用于加密导出。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksKeySize

```cangjie
public class HuksKeySize {
    public static const HUKS_RSA_KEY_SIZE_512: UInt32 = 512
    public static const HUKS_RSA_KEY_SIZE_768: UInt32 = 768
    public static const HUKS_RSA_KEY_SIZE_1024: UInt32 = 1024
    public static const HUKS_RSA_KEY_SIZE_2048: UInt32 = 2048
    public static const HUKS_RSA_KEY_SIZE_3072: UInt32 = 3072
    public static const HUKS_RSA_KEY_SIZE_4096: UInt32 = 4096
    public static const HUKS_ECC_KEY_SIZE_224: UInt32 = 224
    public static const HUKS_ECC_KEY_SIZE_256: UInt32 = 256
    public static const HUKS_ECC_KEY_SIZE_384: UInt32 = 384
    public static const HUKS_ECC_KEY_SIZE_521: UInt32 = 521
    public static const HUKS_AES_KEY_SIZE_128: UInt32 = 128
    public static const HUKS_AES_KEY_SIZE_192: UInt32 = 192
    public static const HUKS_AES_KEY_SIZE_256: UInt32 = 256
    public static const HUKS_CURVE25519_KEY_SIZE_256: UInt32 = 256
    public static const HUKS_DH_KEY_SIZE_2048: UInt32 = 2048
    public static const HUKS_DH_KEY_SIZE_3072: UInt32 = 3072
    public static const HUKS_DH_KEY_SIZE_4096: UInt32 = 4096
    public static const HUKS_SM2_KEY_SIZE_256: UInt32 = 256
    public static const HUKS_SM4_KEY_SIZE_128: UInt32 = 128
}
```

**功能：** 表示密钥长度。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_AES_KEY_SIZE_128

```cangjie
public static const HUKS_AES_KEY_SIZE_128: UInt32 = 128
```

**功能：** 表示使用AES算法的密钥长度为128bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_AES_KEY_SIZE_192

```cangjie
public static const HUKS_AES_KEY_SIZE_192: UInt32 = 192
```

**功能：** 表示使用AES算法的密钥长度为192bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_AES_KEY_SIZE_256

```cangjie
public static const HUKS_AES_KEY_SIZE_256: UInt32 = 256
```

**功能：** 表示使用AES算法的密钥长度为256bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_CURVE25519_KEY_SIZE_256

```cangjie
public static const HUKS_CURVE25519_KEY_SIZE_256: UInt32 = 256
```

**功能：** 表示使用CURVE25519算法的密钥长度为256bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_DH_KEY_SIZE_2048

```cangjie
public static const HUKS_DH_KEY_SIZE_2048: UInt32 = 2048
```

**功能：** 表示使用DH算法的密钥长度为2048bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_DH_KEY_SIZE_3072

```cangjie
public static const HUKS_DH_KEY_SIZE_3072: UInt32 = 3072
```

**功能：** 表示使用DH算法的密钥长度为3072bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_DH_KEY_SIZE_4096

```cangjie
public static const HUKS_DH_KEY_SIZE_4096: UInt32 = 4096
```

**功能：** 表示使用DH算法的密钥长度为4096bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ECC_KEY_SIZE_224

```cangjie
public static const HUKS_ECC_KEY_SIZE_224: UInt32 = 224
```

**功能：** 表示使用ECC算法的密钥长度为224bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ECC_KEY_SIZE_256

```cangjie
public static const HUKS_ECC_KEY_SIZE_256: UInt32 = 256
```

**功能：** 表示使用ECC算法的密钥长度为256bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ECC_KEY_SIZE_384

```cangjie
public static const HUKS_ECC_KEY_SIZE_384: UInt32 = 384
```

**功能：** 表示使用ECC算法的密钥长度为384bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_ECC_KEY_SIZE_521

```cangjie
public static const HUKS_ECC_KEY_SIZE_521: UInt32 = 521
```

**功能：** 表示使用ECC算法的密钥长度为521bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_RSA_KEY_SIZE_1024

```cangjie
public static const HUKS_RSA_KEY_SIZE_1024: UInt32 = 1024
```

**功能：** 表示使用RSA算法的密钥长度为1024bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_RSA_KEY_SIZE_2048

```cangjie
public static const HUKS_RSA_KEY_SIZE_2048: UInt32 = 2048
```

**功能：** 表示使用RSA算法的密钥长度为2048bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_RSA_KEY_SIZE_3072

```cangjie
public static const HUKS_RSA_KEY_SIZE_3072: UInt32 = 3072
```

**功能：** 表示使用RSA算法的密钥长度为3072bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_RSA_KEY_SIZE_4096

```cangjie
public static const HUKS_RSA_KEY_SIZE_4096: UInt32 = 4096
```

**功能：** 表示使用RSA算法的密钥长度为4096bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_RSA_KEY_SIZE_512

```cangjie
public static const HUKS_RSA_KEY_SIZE_512: UInt32 = 512
```

**功能：** 表示使用RSA算法的密钥长度为512bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_RSA_KEY_SIZE_768

```cangjie
public static const HUKS_RSA_KEY_SIZE_768: UInt32 = 768
```

**功能：** 表示使用RSA算法的密钥长度为768bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_SM2_KEY_SIZE_256

```cangjie
public static const HUKS_SM2_KEY_SIZE_256: UInt32 = 256
```

**功能：** 表示SM2算法的密钥长度为256bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_SM4_KEY_SIZE_128

```cangjie
public static const HUKS_SM4_KEY_SIZE_128: UInt32 = 128
```

**功能：** 表示SM4算法的密钥长度为128bit。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksKeyStorageType

```cangjie
public class HuksKeyStorageType {
    public static const HUKS_STORAGE_ONLY_USED_IN_HUKS: UInt32 = 2
    public static const HUKS_STORAGE_KEY_EXPORT_ALLOWED: UInt32 = 3
}
```

**功能：** 表示密钥存储方式。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_STORAGE_KEY_EXPORT_ALLOWED

```cangjie
public static const HUKS_STORAGE_KEY_EXPORT_ALLOWED: UInt32 = 3
```

**功能：** 表示主密钥派生的密钥直接导出给业务方，HUKS不对其进行托管服务。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_STORAGE_ONLY_USED_IN_HUKS

```cangjie
public static const HUKS_STORAGE_ONLY_USED_IN_HUKS: UInt32 = 2
```

**功能：** 表示主密钥派生的密钥存储于huks中，由HUKS进行托管。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksOptions

```cangjie
public class HuksOptions {
    public var properties: Array<HuksParam>
    public var inData: Bytes

    public init(properties!: Array<HuksParam> = Array<HuksParam>(), inData!: Bytes =  Bytes<UInt8>())
}
```

**功能：** 调用接口使用的options。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### var inData

```cangjie
public var inData: Bytes
```

**功能：** 输入数据。

**类型：** Bytes

**读写能力：** 可读写

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### var properties

```cangjie
public var properties: Array<HuksParam>
```

**功能：** 属性，用于存HuksParam的数组。

**类型：** Array\<[HuksParam](#class-huksparam)>

**读写能力：** 可读写

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### init(Array\<HuksParam>, Bytes)

```cangjie
public init(properties!: Array<HuksParam> = Array<HuksParam>(), inData!: Bytes = Bytes())
```

**功能：** 构造调用接口使用的options实例。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|properties|Array\<[HuksParam](#class-huksparam)>|否|Array\<HuksParam>()|**命名参数。** 属性，用于存HuksParam的数组。默认为空。|
|inData|Bytes|否|Bytes()|**命名参数。** 输入数据。默认为空。|

## class HuksParam

```cangjie
public class HuksParam {
    public var tag: UInt32
    public var value: HuksParamValue

    public init(tag: UInt32, value: HuksParamValue)
}
```

**功能：** 调用接口使用的options中的properties数组中的param。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### var tag

```cangjie
public var tag: UInt32
```

**功能：** 标签。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### var value

```cangjie
public var value: HuksParamValue
```

**功能：** 标签对应值。

**类型：** UInt32

**读写能力：** 可读写

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### init(UInt32, HuksParamValue)

```cangjie
public init(tag: UInt32, value: HuksParamValue)
```

**功能：** 构造[HuksOptions](#class-huksoptions)中properties数组中的元素实例。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|tag|UInt32|是|-|标签。|
|value|[HuksParamValue](#enum-huksparamvalue)|是|-|标签对应值。|

## class HuksRsaPssSaltLenType

```cangjie
public class HuksRsaPssSaltLenType {
    public static const HUKS_RSA_PSS_SALT_LEN_DIGEST: UInt32 = 0
    public static const HUKS_RSA_PSS_SALT_LEN_MAX: UInt32 = 1
}
```

**功能：** 表示Rsa在签名验签、padding为pss时需指定的salt_len类型。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_RSA_PSS_SALT_LEN_DIGEST

```cangjie
public static const HUKS_RSA_PSS_SALT_LEN_DIGEST: UInt32 = 0
```

**功能：** 表示以摘要长度设置salt_len。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_RSA_PSS_SALT_LEN_MAX

```cangjie
public static const HUKS_RSA_PSS_SALT_LEN_MAX: UInt32 = 1
```

**功能：** 表示以最大长度设置salt_len。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksSecureSignType

```cangjie
public class HuksSecureSignType {
    public static const HUKS_SECURE_SIGN_WITH_AUTH_INFO: UInt32 = 1
}
```

**功能：** 表示生成或导入密钥时，指定该密钥的签名类型。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_SECURE_SIGN_WITH_AUTH_INFO

```cangjie
public static const HUKS_SECURE_SIGN_WITH_AUTH_INFO: UInt32 = 1
```

**功能：** 表示签名类型为携带认证信息。生成或导入密钥时指定该字段，则在使用密钥进行签名时，对待签名的数据添加认证信息后进行签名。

> **注意：**
>
> 携带的认证信息包含身份信息，开发者需在其隐私声明中对此身份信息的使用目的、存留策略和销毁方式进行说明。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

## class HuksSessionHandle

```cangjie
public class HuksSessionHandle {
    public var handle: HuksHandleId
    public var challenge: Bytes
}
```

**功能：** huks Handle结构体。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### var challenge

```cangjie
public var challenge: Bytes
```

**功能：** 表示[initSession](#func-initsessionstring-huksoptions)操作之后获取到的challenge信息。

**类型：** Bytes

**读写能力：** 可读写

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### var handle

```cangjie
public var handle: HuksHandleId
```

**功能：** 表示handle值。

**类型：** [HuksHandleId](#class-hukshandleid)

**读写能力：** 可读写

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksTag

```cangjie
public class HuksTag {
    public static const HUKS_TAG_ALGORITHM: UInt32 =  HuksTagType.HUKS_TAG_TYPE_UINT | 1
    public static const HUKS_TAG_PURPOSE: UInt32 =  HuksTagType.HUKS_TAG_TYPE_UINT | 2
    public static const HUKS_TAG_KEY_SIZE: UInt32 =  HuksTagType.HUKS_TAG_TYPE_UINT | 3
    public static const HUKS_TAG_DIGEST: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 4
    public static const HUKS_TAG_PADDING: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 5
    public static const HUKS_TAG_BLOCK_MODE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 6
    public static const HUKS_TAG_KEY_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 7
    public static const HUKS_TAG_ASSOCIATED_DATA: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 8
    public static const HUKS_TAG_NONCE: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 9
    public static const HUKS_TAG_IV: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 10
    public static const HUKS_TAG_INFO: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 11
    public static const HUKS_TAG_SALT: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 12
    public static const HUKS_TAG_ITERATION: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 14
    public static const HUKS_TAG_KEY_GENERATION_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 15
    public static const HUKS_TAG_ALG_FOR_AGREEMENT: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 19
    public static const HUKS_TAG_AGREE_PUBLIC_KEY_IS_KEY_ALIAS: UInt32 = HuksTagType.HUKS_TAG_TYPE_BOOL | 20
    public static const HUKS_TAG_PRIVATE_KEY_ALIAS_FOR_AGREEMENT: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 21
    public static const HUKS_TAG_PUBLIC_KEY_FOR_AGREEMENT: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 22
    public static const HUKS_TAG_KEY_ALIAS: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 23
    public static const HUKS_TAG_DERIVE_KEY_SIZE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 24
    public static const HUKS_TAG_IMPORT_KEY_TYPE: UInt32 =  HuksTagType.HUKS_TAG_TYPE_UINT | 25
    public static const HUKS_TAG_UNWRAP_ALGORITHM_SUITE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 26
    public static const HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 29
    public static const HUKS_TAG_RSA_PSS_SALT_LEN_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 30
    public static const HUKS_TAG_USER_ID: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 302
    public static const HUKS_TAG_NO_AUTH_REQUIRED: UInt32 = HuksTagType.HUKS_TAG_TYPE_BOOL | 303
    public static const HUKS_TAG_USER_AUTH_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 304
    public static const HUKS_TAG_AUTH_TIMEOUT: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 305
    public static const HUKS_TAG_AUTH_TOKEN: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 306
    public static const HUKS_TAG_KEY_AUTH_ACCESS_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 307
    public static const HUKS_TAG_KEY_SECURE_SIGN_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 308
    public static const HUKS_TAG_CHALLENGE_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 309
    public static const HUKS_TAG_CHALLENGE_POS: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 310
    public static const HUKS_TAG_KEY_AUTH_PURPOSE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 311
    public static const HUKS_TAG_AUTH_STORAGE_LEVEL: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 316
    public static const HUKS_TAG_ATTESTATION_CHALLENGE: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 501
    public static const HUKS_TAG_IS_KEY_ALIAS: UInt32 = HuksTagType.HUKS_TAG_TYPE_BOOL | 1001
    public static const HUKS_TAG_KEY_STORAGE_FLAG: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 1002
    public static const HUKS_TAG_IS_ALLOWED_WRAP: UInt32 = HuksTagType.HUKS_TAG_TYPE_BOOL | 1003
    public static const HUKS_TAG_KEY_WRAP_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 1004
    public static const HUKS_TAG_KEY_AUTH_ID: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 1005
    public static const HUKS_TAG_KEY_FLAG: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 1007
    public static const HUKS_TAG_KEY: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 10006
    public static const HUKS_TAG_AE_TAG: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 10009
}
```

**功能：** 表示调用参数的Tag。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_AE_TAG

```cangjie
public static const HUKS_TAG_AE_TAG: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 10009
```

**功能：** 用于传入GCM模式中的AEAD数据的字段。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_ALG_FOR_AGREEMENT

```cangjie
public static const HUKS_TAG_ALG_FOR_AGREEMENT: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 19
```

**功能：** 表示密钥协商时的算法类型。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_PRIVATE_KEY_ALIAS_FOR_AGREEMENT

```cangjie
public static const HUKS_TAG_PRIVATE_KEY_ALIAS_FOR_AGREEMENT: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 21
```

**功能：** 表示密钥协商时的私钥别名。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_PUBLIC_KEY_FOR_AGREEMENT

```cangjie
public static const HUKS_TAG_PUBLIC_KEY_FOR_AGREEMENT: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 22
```

**功能：** 表示密钥协商时的公钥。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_AGREE_PUBLIC_KEY_IS_KEY_ALIAS

```cangjie
public static const HUKS_TAG_AGREE_PUBLIC_KEY_IS_KEY_ALIAS: UInt32 = HuksTagType.HUKS_TAG_TYPE_BOOL | 20
```

**功能：** 表示密钥协商时的公钥别名。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_ALGORITHM

```cangjie
public static const HUKS_TAG_ALGORITHM: UInt32 =  HuksTagType.HUKS_TAG_TYPE_UINT | 1
```

**功能：** 表示算法的Tag。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_ASSOCIATED_DATA

```cangjie
public static const HUKS_TAG_ASSOCIATED_DATA: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 8
```

**功能：** 表示附加身份验证数据的Tag。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_ATTESTATION_CHALLENGE

```cangjie
public static const HUKS_TAG_ATTESTATION_CHALLENGE: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 501
```

**功能：** 表示attestation时的挑战值。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_TAG_AUTH_TIMEOUT

```cangjie
public static const HUKS_TAG_AUTH_TIMEOUT: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 305
```

**功能：** 表示auth token单次有效期。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_TAG_AUTH_TOKEN

```cangjie
public static const HUKS_TAG_AUTH_TOKEN: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 306
```

**功能：** 用于传入authToken的字段。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_TAG_BLOCK_MODE

```cangjie
public static const HUKS_TAG_BLOCK_MODE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 6
```

**功能：** 表示加密模式的Tag。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_CHALLENGE_POS

```cangjie
public static const HUKS_TAG_CHALLENGE_POS: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 310
```

**功能：** 表示challenge类型为用户自定义类型时，huks产生的challenge有效长度仅为8字节连续的数据。从[HuksChallengePosition](#class-hukschallengeposition)中选择。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_TAG_CHALLENGE_TYPE

```cangjie
public static const HUKS_TAG_CHALLENGE_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 309
```

**功能：** 表示密钥使用时生成的challenge类型。从[HuksChallengeType](#class-hukschallengetype)中选择。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_TAG_DERIVE_KEY_SIZE

```cangjie
public static const HUKS_TAG_DERIVE_KEY_SIZE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 24
```

**功能：** 表示派生密钥的大小。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG

```cangjie
public static const HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 29
```

**功能：** 表示派生密钥/协商密钥的存储类型。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_DIGEST

```cangjie
public static const HUKS_TAG_DIGEST: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 4
```

**功能：** 表示摘要算法的Tag。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_IMPORT_KEY_TYPE

```cangjie
public static const HUKS_TAG_IMPORT_KEY_TYPE: UInt32 =  HuksTagType.HUKS_TAG_TYPE_UINT | 25
```

**功能：** 表示导入的密钥类型。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_INFO

```cangjie
public static const HUKS_TAG_INFO: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 11
```

**功能：** 表示密钥派生时的info。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_IS_ALLOWED_WRAP

```cangjie
public static const HUKS_TAG_IS_ALLOWED_WRAP: UInt32 = HuksTagType.HUKS_TAG_TYPE_BOOL | 1003
```

**功能：** 预留。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_IS_KEY_ALIAS

```cangjie
public static const HUKS_TAG_IS_KEY_ALIAS: UInt32 = HuksTagType.HUKS_TAG_TYPE_BOOL | 1001
```

**功能：** 表示是否使用生成key时传入的别名的Tag。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_ITERATION

```cangjie
public static const HUKS_TAG_ITERATION: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 14
```

**功能：** 表示密钥派生时的迭代次数。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_IV

```cangjie
public static const HUKS_TAG_IV: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 10
```

**功能：** 表示密钥初始化的向量。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_KEY

```cangjie
public static const HUKS_TAG_KEY: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 10006
```

**功能：** 预留。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_KEY_ALIAS

```cangjie
public static const HUKS_TAG_KEY_ALIAS: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 23
```

**功能：** 表示密钥别名。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_KEY_AUTH_ACCESS_TYPE

```cangjie
public static const HUKS_TAG_KEY_AUTH_ACCESS_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 307
```

**功能：** 表示安全访问控制类型。从[HuksAuthAccessType](#class-huksauthaccesstype)中选择，需要和用户认证类型同时设置。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_TAG_KEY_AUTH_ID

```cangjie
public static const HUKS_TAG_KEY_AUTH_ID: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 1005
```

**功能：** 预留。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_TAG_KEY_AUTH_PURPOSE

```cangjie
public static const HUKS_TAG_KEY_AUTH_PURPOSE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 311
```

**功能：** 表示密钥认证用途的tag。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_TAG_KEY_FLAG

```cangjie
public static const HUKS_TAG_KEY_FLAG: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 1007
```

**功能：** 表示密钥标志的Tag。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_KEY_GENERATION_TYPE

```cangjie
public static const HUKS_TAG_KEY_GENERATION_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 15
```

**功能：** 表示生成密钥类型的Tag。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_KEY_SECURE_SIGN_TYPE

```cangjie
public static const HUKS_TAG_KEY_SECURE_SIGN_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 308
```

**功能：** 表示生成或导入密钥时，指定该密钥的签名类型。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_TAG_KEY_SIZE

```cangjie
public static const HUKS_TAG_KEY_SIZE: UInt32 =  HuksTagType.HUKS_TAG_TYPE_UINT | 3
```

**功能：** 表示密钥长度的Tag。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_KEY_STORAGE_FLAG

```cangjie
public static const HUKS_TAG_KEY_STORAGE_FLAG: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 1002
```

**功能：** 表示密钥存储方式的Tag。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_KEY_TYPE

```cangjie
public static const HUKS_TAG_KEY_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 7
```

**功能：** 表示密钥类型的Tag。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_KEY_WRAP_TYPE

```cangjie
public static const HUKS_TAG_KEY_WRAP_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 1004
```

**功能：** 预留。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_NO_AUTH_REQUIRED

```cangjie
public static const HUKS_TAG_NO_AUTH_REQUIRED: UInt32 = HuksTagType.HUKS_TAG_TYPE_BOOL | 303
```

**功能：** 预留。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_NONCE

```cangjie
public static const HUKS_TAG_NONCE: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 9
```

**功能：** 表示密钥加解密的NONCE字段。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_PADDING

```cangjie
public static const HUKS_TAG_PADDING: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 5
```

**功能：** 表示填充模式的Tag。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_PURPOSE

```cangjie
public static const HUKS_TAG_PURPOSE: UInt32 =  HuksTagType.HUKS_TAG_TYPE_UINT | 2
```

**功能：** 表示密钥用途的Tag。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_RSA_PSS_SALT_LEN_TYPE

```cangjie
public static const HUKS_TAG_RSA_PSS_SALT_LEN_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 30
```

**功能：** 表示rsa_pss_salt_length的类型。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_SALT

```cangjie
public static const HUKS_TAG_SALT: UInt32 = HuksTagType.HUKS_TAG_TYPE_BYTES | 12
```

**功能：** 表示密钥派生时的盐值。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_UNWRAP_ALGORITHM_SUITE

```cangjie
public static const HUKS_TAG_UNWRAP_ALGORITHM_SUITE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 26
```

**功能：** 表示导入加密密钥的套件。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_USER_AUTH_TYPE

```cangjie
public static const HUKS_TAG_USER_AUTH_TYPE: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 304
```

**功能：** 表示用户认证类型。从[HuksUserAuthType](#class-huksuserauthtype)中选择，需要与安全访问控制类型同时设置。支持同时指定两种用户认证类型，如：安全访问控制类型指定为HUKS_SECURE_ACCESS_INVALID_NEW_BIO_ENROLL时，密钥访问认证类型可以指定以下三种： HUKS_USER_AUTH_TYPE_FACE、HUKS_USER_AUTH_TYPE_FINGERPRINT、HUKS_USER_AUTH_TYPE_FACE | HUKS_USER_AUTH_TYPE_FINGERPRINT。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_TAG_USER_ID

```cangjie
public static const HUKS_TAG_USER_ID: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 302
```

**功能：** 表示当前密钥属于哪个userID。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_AUTH_STORAGE_LEVEL

```cangjie
public static const HUKS_TAG_AUTH_STORAGE_LEVEL: UInt32 = HuksTagType.HUKS_TAG_TYPE_UINT | 316
```

**功能：** 表示密钥存储安全等级的tag。从[HuksAuthStorageLevel](#class-huksauthstoragelevel)中选择。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

## class HuksTagType

```cangjie
public class HuksTagType {
    public static const HUKS_TAG_TYPE_INVALID: UInt32 = 0 << 28
    public static const HUKS_TAG_TYPE_INT: UInt32 = 1 << 28
    public static const HUKS_TAG_TYPE_UINT: UInt32 = 2 << 28
    public static const HUKS_TAG_TYPE_ULONG: UInt32 = 3 << 28
    public static const HUKS_TAG_TYPE_BOOL: UInt32 = 4 << 28
    public static const HUKS_TAG_TYPE_BYTES: UInt32 = 5 << 28
}
```

**功能：** 表示Tag的数据类型。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_TYPE_BOOL

```cangjie
public static const HUKS_TAG_TYPE_BOOL: UInt32 = 4 << 28
```

**功能：** 表示该Tag的数据类型为Bool。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_TYPE_BYTES

```cangjie
public static const HUKS_TAG_TYPE_BYTES: UInt32 = 5 << 28
```

**功能：** 表示该Tag的数据类型为Bytes。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_TYPE_INT

```cangjie
public static const HUKS_TAG_TYPE_INT: UInt32 = 1 << 28
```

**功能：** 表示该Tag的数据类型为Int32。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_TYPE_INVALID

```cangjie
public static const HUKS_TAG_TYPE_INVALID: UInt32 = 0 << 28
```

**功能：** 表示非法的Tag类型。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_TYPE_UINT

```cangjie
public static const HUKS_TAG_TYPE_UINT: UInt32 = 2 << 28
```

**功能：** 表示该Tag的数据类型为UInt32。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_TAG_TYPE_ULONG

```cangjie
public static const HUKS_TAG_TYPE_ULONG: UInt32 = 3 << 28
```

**功能：** 表示该Tag的数据类型为Int64。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksUnwrapSuite

```cangjie
public class HuksUnwrapSuite {
    public static const HUKS_UNWRAP_SUITE_X25519_AES_256_GCM_NO_PADDING: UInt32 = 1
    public static const HUKS_UNWRAP_SUITE_ECDH_AES_256_GCM_NO_PADDING: UInt32 = 2
}
```

**功能：** 表示导入加密密钥的算法套件。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_UNWRAP_SUITE_ECDH_AES_256_GCM_NO_PADDING

```cangjie
public static const HUKS_UNWRAP_SUITE_ECDH_AES_256_GCM_NO_PADDING: UInt32 = 2
```

**功能：** 导入加密密钥时，ECDH密钥协商后使用AES-256 GCM加密。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### static const HUKS_UNWRAP_SUITE_X25519_AES_256_GCM_NO_PADDING

```cangjie
public static const HUKS_UNWRAP_SUITE_X25519_AES_256_GCM_NO_PADDING: UInt32 = 1
```

**功能：** 导入加密密钥时，X25519密钥协商后使用AES-256 GCM加密。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## class HuksUserAuthType

```cangjie
public class HuksUserAuthType {
    public static const HUKS_USER_AUTH_TYPE_FINGERPRINT: UInt32 = 1 << 0
    public static const HUKS_USER_AUTH_TYPE_FACE: UInt32 = 1 << 1
    public static const HUKS_USER_AUTH_TYPE_PIN: UInt32 = 1 << 2
}
```

**功能：** 表示用户认证类型。

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_USER_AUTH_TYPE_FACE

```cangjie
public static const HUKS_USER_AUTH_TYPE_FACE: UInt32 = 1 << 1
```

**功能：** 表示用户认证类型为人脸。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_USER_AUTH_TYPE_FINGERPRINT

```cangjie
public static const HUKS_USER_AUTH_TYPE_FINGERPRINT: UInt32 = 1 << 0
```

**功能：** 表示用户认证类型为指纹。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

### static const HUKS_USER_AUTH_TYPE_PIN

```cangjie
public static const HUKS_USER_AUTH_TYPE_PIN: UInt32 = 1 << 2
```

**功能：** 表示用户认证类型为PIN码。

**类型：** UInt32

**系统能力：** SystemCapability.Security.Huks.Extension

**起始版本：** 22

## enum HuksParamValue

```cangjie
public enum HuksParamValue {
    | BooleanValue(Bool)
    | Int32Value(Int32)
    | Uint32Value(UInt32)
    | Uint64Value(UInt64)
    | BytesValue(Bytes)
    | ...
}
```

**功能：** 用于表示HuksParam中value的值，支持Bool、Int32、UInt32、UInt64、Bytes格式。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### BooleanValue(Bool)

```cangjie
BooleanValue(Bool)
```

**功能：** 该字段用于传入Bool类型的value值。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### BytesValue(Bytes)

```cangjie
BytesValue(Bytes)
```

**功能：** 该字段用于传入Bytes类型的value值。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### Int32Value(Int32)

```cangjie
Int32Value(Int32)
```

**功能：** 该字段用于传入Int32类型的value值。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### Uint32Value(UInt32)

```cangjie
Uint32Value(UInt32)
```

**功能：** 该字段用于传入UInt32类型的value值。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

### Uint64Value(UInt64)

```cangjie
Uint64Value(UInt64)
```

**功能：** 该字段用于传入UInt64类型的value值。

**系统能力：** SystemCapability.Security.Huks.Core

**起始版本：** 22

## type Bytes

```cangjie
public type Bytes = Array<UInt8>
```

**功能：** [Bytes](#type-bytes)用于表示密钥输入输出值，支持Array\<UInt8>格式。