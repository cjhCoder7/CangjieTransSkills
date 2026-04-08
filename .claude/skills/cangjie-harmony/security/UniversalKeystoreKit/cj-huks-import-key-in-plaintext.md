# 明文导入密钥

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

分别以导入AES256与RSA2048密钥为例，具体的场景介绍及支持的算法规格，请参见[密钥导入的支持的算法](./cj-huks-key-import-overview.md#支持的算法)。

## 开发步骤

1. 指定密钥别名keyAlias。

    密钥别名的最大长度为128字节。

2. 封装密钥属性集和密钥材料。

    - 密钥属性集同样与密钥生成中指定的密钥属性一致，须包含[HuksKeyAlg](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#class-hukskeyalg)、[HuksKeySize](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#class-hukskeysize)、[HuksKeyPurpose](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#class-hukskeypurpose)属性。
    - 密钥材料须符合[HUKS密钥材料格式](./cj-huks-concepts.md#密钥材料格式)，并以Array\<UInt8>形式赋值给[HuksOptions](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#class-huksoptions)的inData字段。

3. 调用[importKeyItem](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-importkeyitemstring-huksoptions)，传入密钥别名和密钥属性集，即可导入密钥。

    HuksParam和HuksOptions的含义参考：[HuksParam](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#class-huksparam) 和 [HuksOptions](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#class-huksoptions)

### 导入AES256密钥

<!-- compile -->

```cangjie
/* 以下以导入AES256密钥的Callback操作使用为例 */
/* 以下以生成DH密钥为例 */
import kit.PerformanceAnalysisKit.Hilog
import kit.UniversalKeystoreKit.*

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

/* 密钥材料 */
let plainTextSize32: Array<UInt8> = [0xfb, 0x8b, 0x9f, 0x12, 0xa0, 0x83, 0x19, 0xbe, 0x6a, 0x6f, 0x63, 0x2a, 0x7c, 0x86,
    0xba, 0xca, 0x64, 0x0b, 0x88, 0x96, 0xe2, 0xfa, 0x77, 0xbc, 0x71, 0xe3, 0x0f, 0x0f, 0x9e, 0x3c, 0xe5, 0xf9]

/* 1.确定密钥别名 */
let keyAlias = 'AES256Alias_sample'

/* 2.封装密钥属性集和密钥材料 */
let properties: Array<HuksParam> = [
    HuksParam(
        HuksTag.HUKS_TAG_ALGORITHM,
        HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES)
    ),
    HuksParam(
        HuksTag.HUKS_TAG_KEY_SIZE,
        HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256)
    ),
    HuksParam(
        HuksTag.HUKS_TAG_PURPOSE,
        HuksParamValue.Uint32Value(1 | 2)
    )
]
let options: HuksOptions = HuksOptions(
    properties: properties,
    inData: plainTextSize32
)

/* 3.明文导入密钥 */
func importKeyFunc(): Unit {
    try {
        importKeyItem(keyAlias, options)
    } catch (e: Exception) {
        loggerInfo("callback: importKeyItem input arg invalid ${e}")
    }
}

```

### 导入X25519密钥公钥

<!-- compile -->

```cangjie
/* 以下以生成DH密钥为例 */
import kit.PerformanceAnalysisKit.Hilog
import kit.UniversalKeystoreKit.*

// X25519的公钥数据。X25519 密钥对中的私钥和公钥都是 32 字节（256 位），关于算法原理请自行参考相关密钥学资料。
let x25519KeyPubMaterial: Array<UInt8> = [0x30, 0x2A, 0x30, 0x05, 0x06, 0x03, 0x2B, 0x65, 0x6E, 0x03, 0x21, 0x00, 0xD2,
    0x36, 0x9E, 0xCF, 0xF0, 0x61, 0x5B, 0x73, 0xCE, 0x4F, 0xF0, 0x40, 0x2B, 0x89, 0x18, 0x3E, 0x06, 0x33, 0x60, 0xC6]

/* 1. 确定密钥别名 */
let keyAlias = 'X25519_Pub_import_sample'

/* 2. 封装密钥属性集和密钥材料 */
let properties: Array<HuksParam> = [
    HuksParam(
        HuksTag.HUKS_TAG_ALGORITHM,
        HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_X25519)
    ),
    HuksParam(
        HuksTag.HUKS_TAG_KEY_SIZE,
        HuksParamValue.Uint32Value(HuksKeySize.HUKS_CURVE25519_KEY_SIZE_256)
    ),
    HuksParam(
        // 此 tag表示密钥导入后的用途，导入后将不可更改。
        HuksTag.HUKS_TAG_PURPOSE,
        HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_VERIFY)
    ),
    HuksParam(
        // 此 tag表示需导入的密钥类型。
        HuksTag.HUKS_TAG_IMPORT_KEY_TYPE,
        // 此 value表示导入密钥的公钥，若改为HUKS_KEY_TYPE_KEY_PAIR时表示导入密钥对。
        HuksParamValue.Uint32Value(HuksImportKeyType.HUKS_KEY_TYPE_PUBLIC_KEY)
    )
]
let options: HuksOptions = HuksOptions(
    properties: properties,
    inData: x25519KeyPubMaterial
)

/* 3. 明文导入密钥 */
func importKeyFunc(): Unit {
    try {
        importKeyItem(keyAlias, options)
    } catch (e: Exception) {
        Hilog.error(1, "info", "callback: importKeyItem input arg invalid ${e}")
    }
}
```

## 调测验证

调用[hasKeyItem](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-haskeyitemstring-huksoptions)验证密钥是否存在，如密钥存在即表示密钥导入成功。

<!-- compile -->

```cangjie
import kit.UniversalKeystoreKit.*

let keyAlias = 'AES256Alias_sample'
let isKeyExist = false
let keyProperties: Array<HuksParam> = [
    HuksParam(
        HuksTag.HUKS_TAG_ALGORITHM,
        HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES)
    )
]
let huksOptions: HuksOptions = HuksOptions(
    properties: keyProperties, // 非空填充。
    inData: Array<UInt8>() // 非空填充。
)

@Entry
@Component
class EntryView {
    @State
    var message: String = "Hello World"

    func build() {
        Row {
            Column {
                Text(this.message)
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
                    .onClick ({
                        evt => try {
                            hasKeyItem(keyAlias, huksOptions)
                        } catch (e: Exception) {
                            throw e
                        }
                    })
            }.width(100.percent)
        }.height(100.percent)
    }
}
```
