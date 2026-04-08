# HMAC

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

HMAC是密钥相关的哈希运算消息认证码（Hash-based Message Authentication Code）。具体的场景介绍及支持的算法规格，请参见[HMAC介绍与算法规格](./cj-huks-hmac-overview.md)。

## 开发步骤

### 生成密钥

1. 指定密钥别名。

2. 初始化密钥属性集。

3. 调用[generateKeyItem](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-generatekeyitemstring-huksoptions)生成密钥，HMAC支持的规格请参见[密钥生成](./cj-huks-key-generation-overview.md#支持的算法)。

除此之外，开发者也可以参考[密钥导入](./cj-huks-key-import-overview.md#支持的算法)的规格介绍，导入已有的密钥。

### 执行HMAC

1. 获取密钥别名。

2. 获取待运算的数据。

3. 调用[initSession](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-initsessionstring-huksoptions)初始化密钥会话，并获取会话的句柄handle。

4. 调用[finishSession](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-finishsessionhukshandleid-huksoptions-bytes)结束密钥会话，获取HMAC结果。

## 示例

<!-- compile -->

```cangjie
/*
 * 以下以HMAC密钥的操作使用为例
 */
import kit.UniversalKeystoreKit.*

let HmacKeyAlias = 'test_HMAC' // 密钥别名，用户自行指定，用于生成密钥
var handle: ?HuksHandleId = None
let plainText = '123456' // 待运算的数据
var hashData: ?Array<UInt8> = None // HMAC运算后的数据

func StringToUint8Array(str: String) {
    return str.toArray()
}

func Uint8ArrayToString(fileData: Array<UInt8>) {
    return String.fromUtf8(fileData)
}

func GetHMACProperties() {
    let properties: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_HMAC)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_MAC)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_SHA384)
        )
    ]
    return properties
}

/*
 * 模拟密钥生成场景
 */
func GenerateHMACKey() {
    // 获取生成密钥算法参数配置
    let genProperties = GetHMACProperties()
    let options: HuksOptions = HuksOptions(properties: genProperties, inData: Bytes())
    // 调用generateKeyItem生成密钥，HmacKeyAlias是密钥别名，在生成密钥时进行指定的
    generateKeyItem(HmacKeyAlias, options)
}

/*
 * 模拟HMAC计算场景
 */
func HMACData() {
    // 获取HMAC算法参数配置
    let hmacProperties = GetHMACProperties()
    let options: HuksOptions = HuksOptions(
        properties: hmacProperties,
        inData: StringToUint8Array(plainText)
    )
    // 调用initSession获取handle，HmacKeyAlias是密钥别名，在生成密钥时进行指定的
    handle = initSession(HmacKeyAlias, options).handle
    // 调用finishSession获取HMAC的结果
    hashData = finishSession(handle.getOrThrow(), options)
}
```
