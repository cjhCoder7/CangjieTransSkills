# 密钥派生

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

以HKDF256密钥为例，完成密钥派生。具体的场景介绍及支持的算法规格，请参见[密钥生成支持的算法](./cj-huks-key-generation-overview.md#支持的算法)。

## 开发步骤

### 生成密钥

1. 指定密钥别名。

2. 初始化密钥属性集，可指定参数HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG（可选），用于标识基于该密钥派生出的密钥是否由HUKS管理。

    - 当TAG设置为HUKS_STORAGE_ONLY_USED_IN_HUKS时，表示基于该密钥派生出的密钥，由HUKS管理，可保证派生密钥全生命周期不出安全环境。

    - 当TAG设置为HUKS_STORAGE_KEY_EXPORT_ALLOWED时，表示基于该密钥派生出的密钥，返回给调用方管理，由业务自行保证密钥安全。

    - 若业务未设置TAG的具体值，表示基于该密钥派生出的密钥，即可由HUKS管理，也可返回给调用方管理，业务可在后续派生时再选择使用何种方式保护密钥。

3. 调用[generateKeyItem](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-generatekeyitemstring-huksoptions)生成密钥，具体请参见[密钥生成](./cj-huks-key-generation-overview.md)。

除此之外，开发者也可以参考[密钥导入](./cj-huks-key-import-overview.md)，导入已有的密钥。

### 密钥派生

1. 获取密钥别名，指定对应的属性参数HuksOptions。

    可指定参数HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG（可选），用于标识派生得到的密钥是否由HUKS管理。

    | 生成 | 派生 | 规格 |
    | :-------- | :-------- | :-------- |
    | HUKS_STORAGE_ONLY_USED_IN_HUKS | HUKS_STORAGE_ONLY_USED_IN_HUKS | 密钥由HUKS管理 |
    | HUKS_STORAGE_KEY_EXPORT_ALLOWED | HUKS_STORAGE_KEY_EXPORT_ALLOWED | 密钥返回给调用方管理 |
    | 未指定TAG具体值 | HUKS_STORAGE_ONLY_USED_IN_HUKS | 密钥由HUKS管理 |
    | 未指定TAG具体值 | HUKS_STORAGE_KEY_EXPORT_ALLOWED | 密钥返回给调用方管理 |
    | 未指定TAG具体值 | 未指定TAG具体值 | 密钥返回给调用方管理 |

    派生时指定的TAG值，不可与生成时指定的TAG值冲突。表格中仅列举有效的指定方式。

2. 调用[initSession](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-initsessionstring-huksoptions)初始化密钥会话，并获取会话的句柄handle。

3. 调用[updateSession](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-updatesessionhukshandleid-huksoptions-bytes)更新密钥会话。

4. 调用[finishSession](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-finishsessionhukshandleid-huksoptions-bytes)结束密钥会话，完成派生。

### 删除密钥

当密钥废弃不用时，需要调用[deleteKeyItem](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-deletekeyitemstring-huksoptions)删除密钥，具体请参见[密钥删除](./cj-huks-delete-key.md)。

## 开发案例

### HKDF

<!-- compile -->

```cangjie
/*
 * 以下以HKDF密钥的操作使用为例
 */
import kit.PerformanceAnalysisKit.Hilog
import kit.UniversalKeystoreKit.*

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

/*
 * 确定密钥别名和封装密钥属性参数集
 */
let srcKeyAlias = "hkdf_Key"
let deriveHkdfInData = "deriveHkdfTestIndata"
var handle: ?HuksHandleId = None
var finishOutData: ?Array<UInt8> = None
let HuksKeyDeriveKeySize: UInt32 = 32
/* 集成生成密钥参数集 */
let properties: Array<HuksParam> = [
    HuksParam(
        HuksTag.HUKS_TAG_ALGORITHM,
        HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_PURPOSE,
        HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_DERIVE),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_DIGEST,
        HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_KEY_SIZE,
        HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_128),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
        HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
    )
]
let huksOptions: HuksOptions = HuksOptions(
    properties: properties,
    inData: Bytes()
)
/* 集成init时密钥参数集 */
let initProperties: Array<HuksParam> = [
    HuksParam(
        HuksTag.HUKS_TAG_ALGORITHM,
        HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_HKDF),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_PURPOSE,
        HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_DERIVE),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_DIGEST,
        HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_DERIVE_KEY_SIZE,
        HuksParamValue.Uint32Value(HuksKeyDeriveKeySize),
    )
]
var initOptions: HuksOptions = HuksOptions(
    properties: initProperties,
    inData: Bytes()
)
/* 集成finish时密钥参数集 */
let finishProperties: Array<HuksParam> = [
    HuksParam(
        HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
        HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_IS_KEY_ALIAS,
        HuksParamValue.BooleanValue(true),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_ALGORITHM,
        HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_KEY_SIZE,
        HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_PURPOSE,
        HuksParamValue.Uint32Value(1 | 2),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_DIGEST,
        HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_NONE),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_KEY_ALIAS,
        HuksParamValue.BytesValue(srcKeyAlias.toArray()),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_PADDING,
        HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_NONE),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_BLOCK_MODE,
        HuksParamValue.Uint32Value(HuksCipherMode.HUKS_MODE_ECB),
    )
]
let finishOptions: HuksOptions = HuksOptions(
    properties: finishProperties,
    inData: Bytes()
)

func StringToUint8Array(str: String) {
    return str.toArray()
}

class throwObject {
    var isThrow: Bool = false

    init(isThrow: Bool) {
        this.isThrow = isThrow
    }
}

func generateKeyItem(keyAlias: String, huksOptions: HuksOptions, throwObject: throwObject) {
    try {
        generateKeyItem(keyAlias, huksOptions)
    } catch (e: Exception) {
        throwObject.isThrow = true
        throw e
    }
}

func publicGenKeyFunc(keyAlias: String, huksOptions: HuksOptions) {
    loggerInfo("enter generateKeyItem")
    let throwObject: throwObject = throwObject(false)
    try {
        generateKeyItem(keyAlias, huksOptions, throwObject)
    } catch (e: Exception) {
        loggerInfo("generateKeyItem input arg invalid, ${e}")
    }
}

func initSession(keyAlias: String, huksOptions: HuksOptions, throwObject: throwObject) {
    return try {
        initSession(keyAlias, huksOptions)
    } catch (e: Exception) {
        throwObject.isThrow = true
        throw e
    }
}

func publicInitFunc(keyAlias: String, huksOptions: HuksOptions) {
    loggerInfo("enter doInit")
    let throwObject: throwObject = throwObject(false)
    try {
        handle = initSession(keyAlias, huksOptions, throwObject).handle
    } catch (e: Exception) {
        loggerInfo("doInit input arg invalid, ${e}")
    }
}

func updateSession(handle: HuksHandleId, huksOptions: HuksOptions, throwObject: throwObject) {
    return try {
        updateSession(handle, huksOptions)
    } catch (e: Exception) {
        throwObject.isThrow = true
        throw e
    }
}

func publicUpdateFunc(handle: HuksHandleId, huksOptions: HuksOptions) {
    loggerInfo("enter doUpdate")
    let throwObject: throwObject = throwObject(false)
    try {
        updateSession(handle, huksOptions, throwObject)
    } catch (e: Exception) {
        loggerInfo("doUpdate input arg invalid, ${e}")
    }
}

func finishSession(handle: HuksHandleId, huksOptions: HuksOptions, throwObject: throwObject) {
    return try {
        finishSession(handle, huksOptions)
    } catch (e: Exception) {
        throwObject.isThrow = true
        throw e
    }
}

func publicFinishFunc(handle: HuksHandleId, huksOptions: HuksOptions) {
    loggerInfo("enter doFinish")
    let throwObject: throwObject = throwObject(false)
    try {
        finishSession(handle, huksOptions, throwObject)
    } catch (e: Exception) {
        loggerInfo("doFinish input arg invalid, ${e}")
    }
}

func deleteKeyItem(keyAlias: String, huksOptions: HuksOptions, throwObject: throwObject) {
    try {
        deleteKeyItem(keyAlias, huksOptions)
    } catch (e: Exception) {
        throwObject.isThrow = true
        throw e
    }
}

func publicDeleteKeyFunc(keyAlias: String, huksOptions: HuksOptions) {
    loggerInfo("enter deleteKeyItem")
    let throwObject: throwObject = throwObject(false)
    try {
        deleteKeyItem(keyAlias, huksOptions, throwObject)
    } catch (e: Exception) {
        loggerInfo("deleteKeyItem input arg invalid, ${e}")
    }
}

func testDerive() {
    /* 生成密钥 */
    publicGenKeyFunc(srcKeyAlias, huksOptions)
    /* 进行派生操作 */
    publicInitFunc(srcKeyAlias, initOptions)
    initOptions.inData = StringToUint8Array(deriveHkdfInData)
    publicUpdateFunc(handle.getOrThrow(), initOptions)
    publicFinishFunc(handle.getOrThrow(), finishOptions)
    publicDeleteKeyFunc(srcKeyAlias, huksOptions)
}
```

### PBKDF2

<!-- compile -->

```cangjie
/*
 * 以下以PBKDF2密钥的操作使用为例
 */
import kit.PerformanceAnalysisKit.Hilog
import kit.UniversalKeystoreKit.*

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

/*
 * 确定密钥别名和封装密钥属性参数集
 */
let srcKeyAlias = "pbkdf2_Key"
let salt = "mySalt"
let iterationCount: UInt32 = 10000
let derivedKeySize: UInt32 = 32
var handle: ?HuksHandleId = None
var finishOutData: ?Array<UInt8> = None

/* 集成生成密钥参数集 */
let properties: Array<HuksParam> = [
    HuksParam(
        HuksTag.HUKS_TAG_ALGORITHM,
        HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_PURPOSE,
        HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_DERIVE),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_DIGEST,
        HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_KEY_SIZE,
        HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_128),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
        HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
    )
]
let huksOptions: HuksOptions = HuksOptions(
    properties: properties,
    inData: Bytes()
)

/* 集成init时密钥参数集 */
let initProperties: Array<HuksParam> = [
    HuksParam(
        HuksTag.HUKS_TAG_ALGORITHM,
        HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_PBKDF2),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_PURPOSE,
        HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_DERIVE),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_DIGEST,
        HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_DERIVE_KEY_SIZE,
        HuksParamValue.Uint32Value(derivedKeySize),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_ITERATION,
        HuksParamValue.Uint32Value(iterationCount),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_SALT,
        HuksParamValue.BytesValue(salt.toArray()),
    )
]
let initOptions: HuksOptions = HuksOptions(
    properties: initProperties,
    inData: Bytes()
)

/* 集成finish时密钥参数集 */
let finishProperties: Array<HuksParam> = [
    HuksParam(
        HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
        HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_IS_KEY_ALIAS,
        HuksParamValue.BooleanValue(true),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_ALGORITHM,
        HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_KEY_SIZE,
        HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_PURPOSE,
        HuksParamValue.Uint32Value(1 | 2),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_DIGEST,
        HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_NONE),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_KEY_ALIAS,
        HuksParamValue.BytesValue(srcKeyAlias.toArray()),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_PADDING,
        HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_NONE),
    ),
    HuksParam(
        HuksTag.HUKS_TAG_BLOCK_MODE,
        HuksParamValue.Uint32Value(HuksCipherMode.HUKS_MODE_ECB),
    )
]
let finishOptions: HuksOptions = HuksOptions(
    properties: finishProperties,
    inData: Bytes()
)

func StringToUint8Array(str: String) {
    return str.toArray()
}

class throwObject {
    var isThrow: Bool = false

    init(isThrow: Bool) {
        this.isThrow = isThrow
    }
}

func generateKeyItem(keyAlias: String, huksOptions: HuksOptions, throwObject: throwObject) {
    try {
        generateKeyItem(keyAlias, huksOptions)
    } catch (e: Exception) {
        throwObject.isThrow = true
        throw e
    }
}

func publicGenKeyFunc(keyAlias: String, huksOptions: HuksOptions) {
    loggerInfo("enter generateKeyItem")
    let throwObject: throwObject = throwObject(false)
    try {
        generateKeyItem(keyAlias, huksOptions, throwObject)
    } catch (e: Exception) {
        loggerInfo("generateKeyItem input arg invalid, ${e}")
    }
}

func initSession(keyAlias: String, huksOptions: HuksOptions, throwObject: throwObject) {
    return try {
        initSession(keyAlias, huksOptions).handle
    } catch (e: Exception) {
        throwObject.isThrow = true
        loggerInfo("?????????????????")
        throw e
    }
}

func publicInitFunc(keyAlias: String, huksOptions: HuksOptions) {
    loggerInfo("enter doInit")
    let throwObject: throwObject = throwObject(false)
    try {
        handle = initSession(keyAlias, huksOptions, throwObject)
    } catch (e: Exception) {
        loggerInfo("doInit input arg invalid, ${e}")
    }
}

func updateSession(handle: HuksHandleId, huksOptions: HuksOptions, throwObject: throwObject) {
    return try {
        updateSession(handle, huksOptions)
    } catch (e: Exception) {
        throwObject.isThrow = true
        throw e
    }
}

func publicUpdateFunc(handle: HuksHandleId, huksOptions: HuksOptions) {
    loggerInfo("enter doUpdate")
    let throwObject: throwObject = throwObject(false)
    try {
        updateSession(handle, huksOptions, throwObject)
    } catch (e: Exception) {
        loggerInfo("doUpdate input arg invalid, ${e}")
    }
}

func finishSession(handle: HuksHandleId, huksOptions: HuksOptions, throwObject: throwObject) {
    return try {
        finishSession(handle, huksOptions)
    } catch (e: Exception) {
        throwObject.isThrow = true
        throw e
    }
}

func publicFinishFunc(handle: HuksHandleId, huksOptions: HuksOptions) {
    loggerInfo("enter doFinish")
    let throwObject: throwObject = throwObject(false)
    try {
        finishOutData = finishSession(handle, huksOptions, throwObject)
    } catch (e: Exception) {
        loggerInfo("doFinish input arg invalid, ${e}")
    }
}

func deleteKeyItem(keyAlias: String, huksOptions: HuksOptions, throwObject: throwObject) {
    try {
        deleteKeyItem(keyAlias, huksOptions)
    } catch (e: Exception) {
        throwObject.isThrow = true
        throw e
    }
}

func publicDeleteKeyFunc(keyAlias: String, huksOptions: HuksOptions) {
    loggerInfo("enter deleteKeyItem")
    let throwObject: throwObject = throwObject(false)
    try {
        deleteKeyItem(keyAlias, huksOptions, throwObject)
    } catch (e: Exception) {
        loggerInfo("deleteKeyItem input arg invalid, ${e}")
    }
}

func testDerive() {
    /* 生成密钥 */
    publicGenKeyFunc(srcKeyAlias, huksOptions)
    /* 进行派生操作 */
    publicInitFunc(srcKeyAlias, initOptions)
    publicUpdateFunc(handle.getOrThrow(), initOptions)
    publicFinishFunc(handle.getOrThrow(), finishOptions)
    publicDeleteKeyFunc(srcKeyAlias, huksOptions)
}

```
