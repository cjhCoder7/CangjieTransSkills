# 签名/验签

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

当前指导共提供四种示例，供开发者参考完成签名、验签开发：

- [SM2/SM3](#sm2sm3)、[RSA/SHA256/PSS](#rsasha256pss)、[RSA/SHA256/PKCS1\_V1\_5](#rsasha256pkcs1_v1_5)

具体的场景介绍及支持的算法规格，请参见[签名/验签支持的算法](./cj-huks-signing-signature-verification-overview.md#支持的算法)。

## 开发步骤

### 生成密钥

1. 指定密钥别名。

2. 初始化密钥属性集。

3. 调用[generateKeyItem](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-generatekeyitemstring-huksoptions)生成密钥，具体请参见[密钥生成](./cj-huks-key-generation-overview.md)。

除此之外，开发者也可以参考[密钥导入](./cj-huks-key-import-overview.md)，导入已有的密钥。

### 签名

1. 获取密钥别名。

2. 指定待签名的明文数据。

3. 获取属性参数HuksOptions，包括两个字段properties和inData。inData传入明文数据，properties传入[算法参数配置](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#class-huksparam)。

4. 调用[initSession](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-initsessionstring-huksoptions)初始化密钥会话，并获取会话的句柄handle。

5. 调用[finishSession](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-finishsessionhukshandleid-huksoptions-bytes)结束密钥会话，获取签名signature。

### 验签

1. 获取密钥别名。

2. 获取待验证的签名signature。

3. 获取属性参数HuksOptions，包括两个字段properties和inData。inData传入签名signature，properties传入[算法参数配置](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#class-huksparam)。

4. 调用[initSession](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-initsessionstring-huksoptions)初始化密钥会话，并获取会话的句柄handle。

5. 调用[updateSession](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-updatesessionhukshandleid-huksoptions-bytes)更新密钥会话。

6. 调用[finishSession](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-finishsessionhukshandleid-huksoptions-bytes)结束密钥会话，验证签名。

### 删除密钥

当密钥废弃不用时，需要调用[deleteKeyItem](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-deletekeyitemstring-huksoptions)删除密钥，具体请参见[密钥删除](./cj-huks-delete-key.md)。

## 开发案例

### ECC256/SHA256

<!-- compile -->

```cangjie
/*
 * 密钥算法为ECC256、摘要算法为SHA256
 */
import kit.UniversalKeystoreKit.*

let keyAlias = 'test_eccKeyAlias'
var handle: ?HuksHandleId = None
let plaintext = '123456'
var signature: ?Array<UInt8> = None

func StringToUint8Array(str: String) {
    return str.toArray()
}

func Uint8ArrayToString(fileData: Array<UInt8>) {
    return String.fromUtf8(fileData)
}

func GetEccGenerateProperties() {
    let properties: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_ECC)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(4 | 8)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256)
        )
    ]
    return properties
}

func GetEccSignProperties() {
    let properties: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_ECC)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_SIGN)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256)
        )
    ]
    return properties
}

func GetEccVerifyProperties() {
    let properties: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_ECC)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_VERIFY)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256)
        )
    ]
    return properties
}

func GenerateEccKey(keyAlias: String) {
    let genProperties = GetEccGenerateProperties()
    let options: HuksOptions = HuksOptions(properties: genProperties, inData: Bytes())
    generateKeyItem(keyAlias, options)
}

func Sign(keyAlias: String, plaintext: String) {
    let signProperties = GetEccSignProperties()
    let options: HuksOptions = HuksOptions(
        properties: signProperties,
        inData: StringToUint8Array(plaintext)
    )
    handle = initSession(keyAlias, options).handle
    signature = finishSession(handle.getOrThrow(), options)
}

func Verify(keyAlias: String, plaintext: String, signature: Array<UInt8>) {
    let verifyProperties = GetEccVerifyProperties()
    var options: HuksOptions = HuksOptions(
        properties: verifyProperties,
        inData: StringToUint8Array(plaintext)
    )
    handle = initSession(keyAlias, options).handle
    updateSession(handle.getOrThrow(), options)
    options.inData = signature
    finishSession(handle.getOrThrow(), options)
}

func DeleteEccKey(keyAlias: String) {
    let emptyOptions: HuksOptions = HuksOptions()
    deleteKeyItem(keyAlias, emptyOptions)
}

func testSignVerify() {
    GenerateEccKey(keyAlias)
    Sign(keyAlias, plaintext)
    Verify(keyAlias, plaintext, signature.getOrThrow())
    DeleteEccKey(keyAlias)
}
```

### SM2/SM3

<!-- compile -->

```cangjie
/*
 * 密钥算法为SM2、摘要算法为SM3
 */
import kit.UniversalKeystoreKit.*

let keyAlias = 'test_sm2KeyAlias'
var handle: ?HuksHandleId = None
let plaintext = '123456'
var signature: ?Array<UInt8> = None

func StringToUint8Array(str: String) {
    return str.toArray()
}

func Uint8ArrayToString(fileData: Array<UInt8>) {
    return String.fromUtf8(fileData)
}

func GetSm2GenerateProperties() {
    let properties: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_SM2)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(4 | 8)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SM3)
        )
    ]
    return properties
}

func GetSm2SignProperties() {
    let properties: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_SM2)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_SIGN)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SM3)
        )
    ]
    return properties
}

func GetSm2VerifyProperties() {
    let properties: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_SM2)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_VERIFY)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SM3)
        )
    ]
    return properties
}

func GenerateSm2Key(keyAlias: String) {
    let genProperties = GetSm2GenerateProperties()
    let options: HuksOptions = HuksOptions(properties: genProperties, inData: Bytes())
    generateKeyItem(keyAlias, options)
}

func Sign(keyAlias: String, plaintext: String) {
    let signProperties = GetSm2SignProperties()
    let options: HuksOptions = HuksOptions(
        properties: signProperties,
        inData: StringToUint8Array(plaintext)
    )
    handle = initSession(keyAlias, options).handle
    signature = finishSession(handle.getOrThrow(), options)
}

func Verify(keyAlias: String, plaintext: String, signature: Array<UInt8>) {
    let verifyProperties = GetSm2VerifyProperties()
    var options: HuksOptions = HuksOptions(
        properties: verifyProperties,
        inData: StringToUint8Array(plaintext)
    )
    handle = initSession(keyAlias, options).handle
    updateSession(handle.getOrThrow(), options)
    options.inData = signature
    finishSession(handle.getOrThrow(), options)
}

func DeleteSm2Key(keyAlias: String) {
    let emptyOptions: HuksOptions = HuksOptions()
    deleteKeyItem(keyAlias, emptyOptions)
}

func testSignVerify() {
    GenerateSm2Key(keyAlias)
    Sign(keyAlias, plaintext)
    Verify(keyAlias, plaintext, signature.getOrThrow())
    DeleteSm2Key(keyAlias)
}
```

### RSA/SHA256/PSS

<!-- compile -->

```cangjie
/*
 * 密钥算法为RSA，摘要算法为SHA256，填充模式为PSS
 */
import kit.UniversalKeystoreKit.*

let keyAlias = 'test_rsaKeyAlias'
var handle: ?HuksHandleId = None
let plaintext = '123456'
var signature: ?Array<UInt8> = None

func StringToUint8Array(str: String) {
    return str.toArray()
}

func Uint8ArrayToString(fileData: Array<UInt8>) {
    return String.fromUtf8(fileData)
}

func GetRsaGenerateProperties() {
    let properties: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_RSA)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_RSA_KEY_SIZE_2048)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(4 | 8)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PADDING,
            HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_PSS)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256)
        )
    ]
    return properties
}

func GetRsaSignProperties() {
    let properties: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_RSA)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PADDING,
            HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_PSS)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_SIGN)
        )
    ]
    return properties
}

func GetRsaVerifyProperties() {
    let properties: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_RSA)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PADDING,
            HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_PSS)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_VERIFY)
        )
    ]
    return properties
}

func GenerateRsaKey(keyAlias: String) {
    let genProperties = GetRsaGenerateProperties()
    let options: HuksOptions = HuksOptions(properties: genProperties, inData: Bytes())
    generateKeyItem(keyAlias, options)
}

func Sign(keyAlias: String, plaintext: String) {
    let signProperties = GetRsaSignProperties()
    let options: HuksOptions = HuksOptions(
        properties: signProperties,
        inData: StringToUint8Array(plaintext)
    )
    handle = initSession(keyAlias, options).handle

    if (let Some(handle) <- handle) {
        signature = finishSession(handle, options)
    }
}

func Verify(keyAlias: String, plaintext: String, signature: Array<UInt8>) {
    let verifyProperties = GetRsaVerifyProperties()
    var options: HuksOptions = HuksOptions(
        properties: verifyProperties,
        inData: StringToUint8Array(plaintext)
    )
    handle = initSession(keyAlias, options).handle

    if (let Some(handle) <- handle) {
        updateSession(handle, options)

        options.inData = signature
        finishSession(handle, options)
    }
}

func DeleteRsaKey(keyAlias: String) {
    let emptyOptions: HuksOptions = HuksOptions()
    deleteKeyItem(keyAlias, emptyOptions)
}

func testSignVerify() {
    GenerateRsaKey(keyAlias)
    Sign(keyAlias, plaintext)
    Verify(keyAlias, plaintext, signature.getOrThrow())
    DeleteRsaKey(keyAlias)
}
```

### RSA/SHA256/PKCS1_V1_5

<!-- compile -->

```cangjie
/*
 * 密钥算法为RSA，摘要算法为SHA256，填充模式为PKCS1_V1_5
 */
import kit.UniversalKeystoreKit.*

let keyAlias = 'test_rsaKeyAlias'
var handle: ?HuksHandleId = None
let plaintext = '123456'
var signature: ?Array<UInt8> = None

func StringToUint8Array(str: String) {
    return str.toArray()
}

func Uint8ArrayToString(fileData: Array<UInt8>) {
    return String.fromUtf8(fileData)
}

func GetRsaGenerateProperties() {
    let properties: Array<HuksParam> = [
        HuksParam(HuksTag.HUKS_TAG_ALGORITHM, HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_RSA)),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_RSA_KEY_SIZE_2048)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(4 | 8)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PADDING,
            HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_PKCS1_V1_5)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256)
        )
    ]
    return properties
}

func GetRsaSignProperties() {
    let properties: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_RSA)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_RSA_KEY_SIZE_2048)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_SIGN)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PADDING,
            HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_PKCS1_V1_5)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256)
        )
    ]
    return properties
}

func GetRsaVerifyProperties() {
    let properties: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_RSA)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_RSA_KEY_SIZE_2048)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_VERIFY)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PADDING,
            HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_PKCS1_V1_5)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA256)
        )
    ]
    return properties
}

func GenerateRsaKey(keyAlias: String) {
    let genProperties = GetRsaGenerateProperties()
    let options: HuksOptions = HuksOptions(properties: genProperties, inData: Bytes())
    generateKeyItem(keyAlias, options)
}

func Sign(keyAlias: String, plaintext: String) {
    let signProperties = GetRsaSignProperties()
    let options: HuksOptions = HuksOptions(
        properties: signProperties,
        inData: StringToUint8Array(plaintext)
    )
    handle = initSession(keyAlias, options).handle
    signature = finishSession(handle.getOrThrow(), options)
}

func Verify(keyAlias: String, plaintext: String, signature: Array<UInt8>) {
    let verifyProperties = GetRsaVerifyProperties()
    var options: HuksOptions = HuksOptions(
        properties: verifyProperties,
        inData: StringToUint8Array(plaintext)
    )
    handle = initSession(keyAlias, options).handle
    updateSession(handle.getOrThrow(), options)
    options.inData = signature
    finishSession(handle.getOrThrow(), options)
}

func DeleteRsaKey(keyAlias: String) {
    let emptyOptions: HuksOptions = HuksOptions()
    deleteKeyItem(keyAlias, emptyOptions)
}

func testSignVerify() {
    GenerateRsaKey(keyAlias)
    Sign(keyAlias, plaintext)
    Verify(keyAlias, plaintext, signature.getOrThrow())
    DeleteRsaKey(keyAlias)
}
```
