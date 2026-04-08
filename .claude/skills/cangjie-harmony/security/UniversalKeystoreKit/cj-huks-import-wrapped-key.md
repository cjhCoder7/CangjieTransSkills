# 加密导入密钥

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

以加密导入ECDH密钥对为例，涉及业务侧加密密钥的[密钥生成](./cj-huks-key-generation-overview.md)、[协商](./cj-huks-key-agreement-overview.md)等操作不在本示例中体现。

具体的场景介绍及支持的算法规格，请参见[密钥导入支持的算法](./cj-huks-key-import-overview.md#支持的算法)。

## 开发步骤

1. 设备A（导入设备）将待导入密钥转换成[HUKS密钥材料格式](./cj-huks-concepts.md#密钥材料格式)To_Import_Key（仅针对非对称密钥，若待导入密钥是对称密钥则可省略此步骤）。

2. 设备B（被导入设备）生成一个加密导入用途的、用于协商的非对称密钥对Wrapping_Key（公钥Wrapping_Pk，私钥Wrapping_Sk），其密钥用途设置为unwrap，导出Wrapping_Key的公钥材料Wrapping_Pk并保存。

3. 设备A使用和设备B同样的算法，生成一个加密导入用途的、用于协商的非对称密钥对Caller_Key（公钥Caller_Pk，私钥Caller_Sk），导出Caller_Key的公钥材料Caller_Pk并保存。

4. 设备A生成一个对称密钥Caller_Kek，该密钥后续将用于加密To_Import_Key。

5. 设备A基于Caller_Key的私钥Caller_Sk和设备B Wrapping_Key的公钥Wrapping_Pk，协商出Shared_Key。

6. 设备A使用Caller_Kek加密To_Import_Key，生成To_Import_Key_Enc。

7. 设备A使用Shared_Key加密Caller_Kek，生成Caller_Kek_Enc。

8. 设备A封装Caller_Pk、Caller_Kek_Enc、To_Import_Key_Enc等加密导入的密钥材料并发送给设备B，加密导入密钥材料格式见[加密导入密钥材料格式](./cj-huks-key-import-overview.md#加密导入密钥材料格式)。

9. 设备B导入封装的加密密钥材料。

10. 设备A、B删除用于加密导入的密钥。

## 示例

<!-- compile -->

```cangjie
import kit.PerformanceAnalysisKit.Hilog
import kit.UniversalKeystoreKit.*
import std.collection.*

let IV = "TEST_IV" // 此处为样例代码，实际使用需采用随机值
let AAD = "TEST_ADD" // 此处为样例代码，实际使用需采用随机值
let NONCE = "TEST_NONCE" // 此处为样例代码，实际使用需采用随机值
let TAG_SIZE = 16
let FIELD_LENGTH = 4
let importedAes192PlainKey = "The aes192 key to import"
let callerAes256Kek = "This is kek to encrypt aes192 key"
let callerKeyAlias = "test_caller_key_ecdh_aes192"
let callerKekAliasAes256 = "test_caller_kek_ecdh_aes256"
let callerAgreeKeyAliasAes256 = "test_caller_agree_key_ecdh_aes256"
let importedKeyAliasAes192 = "test_import_key_ecdh_aes192"
var huksPubKey: ?Array<UInt8> = None
var callerSelfPublicKey: ?Array<UInt8> = None
var outSharedKey: ?Array<UInt8> = []
var outPlainKeyEncData: ?Array<UInt8> = None
var outKekEncData: ?Array<UInt8> = None
var outKekEncTag: ?Array<UInt8> = None
var outAgreeKeyEncTag: ?Array<UInt8> = None
var mask = [0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000]

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

func subUint8ArrayOf(arrayBuf: Array<UInt8>, start: Int64, end: Int64) {
    let realEnd = min(end, arrayBuf.size)
    let list = ArrayList<UInt8>()
    for (i in start..realEnd) {
        list.add(arrayBuf[i])
    }
    return list.toArray()
}

func stringToUint8Array(str: String) {
    return str.toArray()
}

func assignLength(length: Int64, arrayBuf: Array<UInt8>, startIndex: Int64) {
    var index = startIndex
    for (i in 0..4) {
        arrayBuf[index] = UInt8((length & mask[i]) >> (i * 8))
        index++
    }
    return 4
}

func assignData(data: Array<UInt8>, arrayBuf: Array<UInt8>, startIndex: Int64) {
    var index = startIndex
    for (i in 0..data.size) {
        arrayBuf[index] = data[i]
        index++
    }
    return data.size
}

let genWrappingKeyParams: HuksOptions = HuksOptions(
    properties: [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_ECC)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_UNWRAP)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_CURVE25519_KEY_SIZE_256)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PADDING,
            HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_NONE)
        )
    ],
    inData: Bytes()
)
let genCallerEcdhParams: HuksOptions = HuksOptions(
    properties: [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_ECC)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_AGREE)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_CURVE25519_KEY_SIZE_256)
        )
    ],
    inData: Bytes()
)
let importParamsCallerKek: HuksOptions = HuksOptions(
    properties: [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PADDING,
            HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_NONE)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_BLOCK_MODE,
            HuksParamValue.Uint32Value(HuksCipherMode.HUKS_MODE_GCM)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_NONE)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_IV,
            HuksParamValue.BytesValue(IV.toArray())
        )
    ],
    inData: stringToUint8Array(callerAes256Kek)
)
var importParamsAgreeKey: HuksOptions = HuksOptions(
    properties: [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PADDING,
            HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_NONE)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_BLOCK_MODE,
            HuksParamValue.Uint32Value(HuksCipherMode.HUKS_MODE_GCM)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_NONE)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_IV,
            HuksParamValue.BytesValue(IV.toArray())
        )
    ],
    inData: Bytes()
)
let callerAgreeParams: HuksOptions = HuksOptions(
    properties: [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_ECDH)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_AGREE)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_CURVE25519_KEY_SIZE_256)
        )
    ],
    inData: Bytes()
)
var encryptKeyCommonParams: HuksOptions = HuksOptions(
    properties: [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PADDING,
            HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_NONE)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_BLOCK_MODE,
            HuksParamValue.Uint32Value(HuksCipherMode.HUKS_MODE_GCM)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_NONCE,
            HuksParamValue.BytesValue(NONCE.toArray())
        ),
        HuksParam(
            HuksTag.HUKS_TAG_ASSOCIATED_DATA,
            HuksParamValue.BytesValue(AAD.toArray())
        )
    ],
    inData: Bytes()
)
var importWrappedAes192Params: HuksOptions = HuksOptions(
    properties: [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(1 | 2)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_192)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PADDING,
            HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_NONE)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_BLOCK_MODE,
            HuksParamValue.Uint32Value(HuksCipherMode.HUKS_MODE_CBC)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_NONE)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_UNWRAP_ALGORITHM_SUITE,
            HuksParamValue.Uint32Value(HuksUnwrapSuite.HUKS_UNWRAP_SUITE_ECDH_AES_256_GCM_NO_PADDING)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_IV,
            HuksParamValue.BytesValue(IV.toArray())
        )
    ],
    inData: Bytes()
)

func publicGenerateItemFunc(keyAlias: String, huksOptions: HuksOptions) {
    loggerInfo("enter generateKeyItem")
    try {
        generateKeyItem(keyAlias, huksOptions)
    } catch (e: Exception) {
        loggerInfo("generateKeyItem invalid, ${e}")
    }
}

func publicImportKeyItemFunc(keyAlias: String, HuksOptions: HuksOptions) {
    loggerInfo("enter importKeyItem")
    try {
        importKeyItem(keyAlias, HuksOptions)
    } catch (e: Exception) {
        loggerInfo("importKeyItem input arg invalid, ${e}")
    }
}

func publicDeleteKeyItemFunc(KeyAlias: String, HuksOptions: HuksOptions) {
    loggerInfo("enter deleteKeyItem")
    try {
        deleteKeyItem(KeyAlias, HuksOptions)
    } catch (e: Exception) {
        loggerInfo("deleteKeyItem input arg invalid, ${e}")
    }
}

func importWrappedKeyItem(keyAlias: String, wrappingKeyAlias: String, huksOptions: HuksOptions): Unit {
    try {
        importWrappedKeyItem(keyAlias, wrappingKeyAlias, huksOptions)
    } catch (e: Exception) {
        loggerInfo("importWrappedKeyItem invalid, ${e}")
    }
}

func publicImportWrappedKeyFunc(keyAlias: String, wrappingKeyAlias: String, huksOptions: HuksOptions) {
    loggerInfo("enter importWrappedKeyItem")
    for (i in 0..huksOptions
            .inData
            .size) {
    }
    try {
        importWrappedKeyItem(keyAlias, wrappingKeyAlias, huksOptions)
    } catch (e: Exception) {
        loggerInfo("importWrappedKeyItem input arg invalid, ${e}")
    }
}

func publicImportWrappedKey(keyAlias: String, wrappingKeyAlias: String, huksOptions: HuksOptions) {
    loggerInfo("enter importWrappedKeyItem")
    try {
        importWrappedKeyItem(keyAlias, wrappingKeyAlias, huksOptions)
    } catch (e: Exception) {
        loggerInfo("importWrappedKeyItem input arg invalid, ${e}")
    }
}

func publicInitFunc(srcKeyAlias: String, HuksOptions: HuksOptions): HuksHandleId {
    var handle: ?HuksHandleId = None
    loggerInfo("enter doInit")
    try {
        handle = initSession(srcKeyAlias, HuksOptions).handle
    } catch (e: Exception) {
        loggerInfo("doInit input arg invalid, ${e}")
    }
    return handle.getOrThrow()
}

func publicUpdateSessionfunc(handle: HuksHandleId, huksOptions: HuksOptions): Array<UInt8> {
    let maxUpdateSize = 64
    let inData = huksOptions
        .inData
    let lastInDataPosition = inData.size - 1
    var inDataSegSize = maxUpdateSize
    var inDataSegPosition = 0
    var isFinished = false
    var outData: ?Array<UInt8> = None

    var newHuksOptions = huksOptions
    while (inDataSegPosition <= lastInDataPosition) {
        if (inDataSegPosition + maxUpdateSize > lastInDataPosition) {
            isFinished = true
            inDataSegSize = lastInDataPosition - inDataSegPosition + 1
            loggerInfo("enter doUpdate")
            break
        }
        newHuksOptions.inData = inData.slice(inDataSegPosition, inDataSegSize)
        loggerInfo("enter doUpdate")
        try {
            outData = updateSession(handle, huksOptions)
        } catch (e: Exception) {
            loggerInfo("doUpdate input arg invalid, ${e}")
        }
        if ((!isFinished) && (inDataSegPosition + maxUpdateSize > lastInDataPosition)) {
            loggerInfo("update size invalid isFinished = ${isFinished}")
            loggerInfo("inDataSegPosition = ${inDataSegPosition}")
            loggerInfo("lastInDataPosition = ${lastInDataPosition}")
            return Array<UInt8>()
        }
        inDataSegPosition += maxUpdateSize
    }
    return outData.getOrThrow()
}

func publicFinishSession(handle: HuksHandleId, huksOptions: HuksOptions, inData: Array<UInt8>) {
    var outData: ?Array<UInt8> = None
    loggerInfo("enter doFinish")
    try {
        outData = finishSession(handle, huksOptions)
    } catch (e: Exception) {
        loggerInfo("doFinish input arg invalid, ${e}")
    }
    return outData.getOrThrow()
}

func cipherfunc(keyAlias: String, huksOptions: HuksOptions) {
    let handle = publicInitFunc(keyAlias, huksOptions)
    let tmpData = publicUpdateSessionfunc(handle, huksOptions)
    let outData = publicFinishSession(handle, huksOptions, tmpData)
    return outData
}

func agreefunc(keyAlias: String, huksOptions: HuksOptions, huksPublicKey: Array<UInt8>) {
    let handle = publicInitFunc(keyAlias, huksOptions)
    var newhuksOptions = huksOptions
    newhuksOptions.inData = huksPublicKey
    loggerInfo("enter doUpdate")
    try {
        updateSession(handle, newhuksOptions)
    } catch (e: Exception) {
        loggerInfo("doUpdate input arg invalid, ${e}")
    }
    loggerInfo("enter doInit")
    var outSharedKey: ?Array<UInt8> = []
    try {
        outSharedKey = finishSession(handle, newhuksOptions)
    } catch (e: Exception) {
        loggerInfo("doInit input arg invalid, ${e}")
    }
    return outSharedKey
}

func ImportKekAndAgreeSharedSecret(callerKekAlias: String, importKekParams: HuksOptions, callerKeyAlias: String,
    huksPublicKey: Array<UInt8>, agreeParams: HuksOptions) {
    publicImportKeyItemFunc(callerKekAlias, importKekParams)
    outSharedKey = agreefunc(callerKeyAlias, agreeParams, huksPublicKey)
    importParamsAgreeKey.inData = outSharedKey.getOrThrow()
    publicImportKeyItemFunc(callerAgreeKeyAliasAes256, importParamsAgreeKey)
}

func generateAndExportPublicKey(keyAlias: String, HuksOptions: HuksOptions, caller: Bool) {
    publicGenerateItemFunc(keyAlias, HuksOptions)
    try {
        exportKeyItem(keyAlias, HuksOptions)
    } catch (e: Exception) {
        loggerInfo("generate pubKey failed, ${e}")
    }
}

func EncryptImportedPlainKeyAndKek(keyAlias: String) {
    encryptKeyCommonParams.inData = stringToUint8Array(keyAlias)
    let plainKeyEncData = cipherfunc(callerKekAliasAes256, encryptKeyCommonParams)
    outKekEncTag = subUint8ArrayOf(plainKeyEncData, plainKeyEncData.size - TAG_SIZE, plainKeyEncData.size)
    outPlainKeyEncData = subUint8ArrayOf(plainKeyEncData, 0, plainKeyEncData.size - TAG_SIZE)
    encryptKeyCommonParams.inData = stringToUint8Array(callerAes256Kek)
    let kekEncData = cipherfunc(callerAgreeKeyAliasAes256, encryptKeyCommonParams)
    outAgreeKeyEncTag = subUint8ArrayOf(kekEncData, kekEncData.size - TAG_SIZE, kekEncData.size)
    outKekEncData = subUint8ArrayOf(kekEncData, 0, kekEncData.size - TAG_SIZE)
}

func BuildWrappedDataAndImportWrappedKey(plainKey: String) {
    let plainKeySizeBuff = Array<UInt8>(4, repeat: 0)
    assignLength(plainKey.size, plainKeySizeBuff, 0)
    let wrappedData = Array<UInt8>(
        FIELD_LENGTH + huksPubKey
            .getOrThrow()
            .size + FIELD_LENGTH + AAD.size + FIELD_LENGTH + NONCE.size + FIELD_LENGTH + TAG_SIZE + FIELD_LENGTH + outKekEncData
            .getOrThrow()
            .size + FIELD_LENGTH + AAD.size + FIELD_LENGTH + NONCE.size + FIELD_LENGTH + TAG_SIZE + FIELD_LENGTH + plainKeySizeBuff
            .size + FIELD_LENGTH + outPlainKeyEncData
            .getOrThrow()
            .size, repeat: 0)
    var index = 0
    let AADUint8Array = stringToUint8Array(AAD)
    let NonceArray = stringToUint8Array(NONCE)
    index += assignLength(callerSelfPublicKey
        .getOrThrow()
        .size, wrappedData, index) // 4
    index += assignData(callerSelfPublicKey.getOrThrow(), wrappedData, index) // 91
    index += assignLength(AADUint8Array.size, wrappedData, index) // 4
    index += assignData(AADUint8Array, wrappedData, index) // 16
    index += assignLength(NonceArray.size, wrappedData, index) // 4
    index += assignData(NonceArray, wrappedData, index) // 12
    index += assignLength(outAgreeKeyEncTag
        .getOrThrow()
        .size, wrappedData, index) // 4
    index += assignData(outAgreeKeyEncTag.getOrThrow(), wrappedData, index) // 16
    index += assignLength(outKekEncData
        .getOrThrow()
        .size, wrappedData, index) // 4
    index += assignData(outKekEncData.getOrThrow(), wrappedData, index) // 32
    index += assignLength(AADUint8Array.size, wrappedData, index) // 4
    index += assignData(AADUint8Array, wrappedData, index) // 16
    index += assignLength(NonceArray.size, wrappedData, index) // 4
    index += assignData(NonceArray, wrappedData, index) // 12
    index += assignLength(outKekEncTag
        .getOrThrow()
        .size, wrappedData, index) // 4
    index += assignData(outKekEncTag.getOrThrow(), wrappedData, index) // 16
    index += assignLength(plainKeySizeBuff.size, wrappedData, index) // 4
    index += assignData(plainKeySizeBuff, wrappedData, index) // 4
    index += assignLength(outPlainKeyEncData
        .getOrThrow()
        .size, wrappedData, index) // 4
    index += assignData(outPlainKeyEncData.getOrThrow(), wrappedData, index) // 24
    return wrappedData
}

/* 模拟加密导入密钥场景，设备A为远端设备（导入设备），设备B为本端设备（被导入设备） */
func ImportWrappedKey() {
    /**
     * 1.设备A将待导入密钥转换成HUKS密钥材料格式To_Import_Key（仅针对非对称密钥，若待导入密钥是对称密钥则可省略此步骤），
     *   本示例使用importedAes192PlainKey（对称密钥）作为模拟
     */

    /* 2.设备B生成一个加密导入用途的、用于协商的非对称密钥对Wrapping_Key（公钥Wrapping_Pk，私钥Wrapping_Sk），其密钥用途设置为unwrap，导出Wrapping_Key公钥Wrapping_Pk存放在变量huksPubKey中 */
    let srcKeyAliasWrap = 'HUKS_Basic_Capability_Import_0200'
    generateAndExportPublicKey(srcKeyAliasWrap, genWrappingKeyParams, false)

    /* 3.设备A使用和设备B同样的算法，生成一个加密导入用途的、用于协商的非对称密钥对Caller_Key（公钥Caller_Pk，私钥Caller_Sk），导出Caller_Key公钥Caller_Pk存放在变量callerSelfPublicKey中 */
    generateAndExportPublicKey(callerKeyAlias, genCallerEcdhParams, true)

    /**
     * 4.设备A生成一个对称密钥Caller_Kek，该密钥后续将用于加密To_Import_Key
     * 5.设备A基于Caller_Key的私钥Caller_Sk和Wrapping_Key的公钥Wrapping_Pk，协商出Shared_Key
     */
    ImportKekAndAgreeSharedSecret(callerKekAliasAes256, importParamsCallerKek, callerKeyAlias, huksPubKey.getOrThrow(),
        callerAgreeParams)

    /**
     * 6.设备A使用Caller_Kek加密To_Import_Key，生成To_Import_Key_Enc
     * 7.设备A使用Shared_Key加密Caller_Kek，生成Caller_Kek_Enc
     */
    EncryptImportedPlainKeyAndKek(importedAes192PlainKey)

    /* 8.设备A封装Caller_Pk、To_Import_Key_Enc、Caller_Kek_Enc等加密导入的材料并发送给设备B。本示例作为变量存放在callerSelfPublicKey，outPlainKeyEncData，outKekEncData */
    let wrappedData = BuildWrappedDataAndImportWrappedKey(importedAes192PlainKey)
    importWrappedAes192Params.inData = wrappedData

    /* 9.设备B导入封装的加密密钥材料 */
    publicImportWrappedKeyFunc(importedKeyAliasAes192, srcKeyAliasWrap, importWrappedAes192Params)

    /* 10.设备A、B删除用于加密导入的密钥 */
    publicDeleteKeyItemFunc(srcKeyAliasWrap, genWrappingKeyParams)
    publicDeleteKeyItemFunc(callerKeyAlias, genCallerEcdhParams)
    publicDeleteKeyItemFunc(importedKeyAliasAes192, importWrappedAes192Params)
    publicDeleteKeyItemFunc(callerKekAliasAes256, callerAgreeParams)
}

```
