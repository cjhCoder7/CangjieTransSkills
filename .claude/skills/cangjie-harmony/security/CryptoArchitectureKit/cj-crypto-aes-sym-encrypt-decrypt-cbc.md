# 使用AES对称密钥（CBC模式）加解密

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

对应的算法规格请参见[对称密钥加解密算法规格：AES](./cj-crypto-sym-encrypt-decrypt-spec.md#aes)。

## 加密

1. 调用[createSymKeyGenerator](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createsymkeygeneratorstring) 和 [generateSymKey](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-generatesymkey)，生成密钥算法为AES、密钥长度为128位的对称密钥（SymKey）。

   如何生成AES对称密钥，开发者可参考下文示例，并结合[对称密钥生成和转换规格：AES](./cj-crypto-sym-key-generation-conversion-spec.md#aes)和[随机生成对称密钥](./cj-crypto-generate-sym-key-randomly.md)理解，参考文档与当前示例可能存在入参差异，请在阅读时注意区分。

2. 调用[createCipher](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createcipherstring)，指定字符串参数'AES128|CBC|PKCS7'，创建对称密钥类型为AES128、分组模式为CBC、填充模式为PKCS7的Cipher实例，用于完成加密操作。

3. 调用[initialize](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-initializecryptomode-key-paramsspec)，设置模式为加密（CryptoMode.EncryptMode），指定加密密钥（SymKey）和CBC模式对应的加密参数（IvParamsSpec），初始化加密Cipher实例。

4. 加密内容较短时，可以不调用update，直接调用[doFinal](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-dofinaldatablob)，获取加密后的数据。

## 解密

1. 调用[createCipher](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createcipherstring)，指定字符串参数'AES128|CBC|PKCS7'，创建对称密钥类型为AES128、分组模式为CBC、填充模式为PKCS7的Cipher实例，用于完成解密操作。

2. 调用[initialize](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-initializecryptomode-key-paramsspec)，设置模式为解密（CryptoMode.DecryptMode），指定解密密钥（SymKey）和CBC模式对应的解密参数（IvParamsSpec），初始化解密Cipher实例。

3. 解密内容较短时，可以不调用update，直接调用[doFinal](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-dofinaldatablob)，获取解密后的数据。

## 示例

同步方法示例如下：

<!-- compile -->

```cangjie
import kit.CryptoArchitectureKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

func generateRandom(len: Int32) {
    let rand = createRandom()
    let generateRandSync = rand.generateRandom(len)
    return generateRandSync
}

func genIvParamsSpec() {
    let ivBlob = generateRandom(16)
    let ivParamsSpec: IvParamsSpec = IvParamsSpec("IvParamsSpec", ivBlob)
    return ivParamsSpec
}

let iv = genIvParamsSpec()
// 加密消息。
func encryptMessage(symKey: SymKey, plainText: DataBlob) {
    let cipher = createCipher('AES128|CBC|PKCS7')
    cipher.initialize(CryptoMode.EncryptMode, symKey, iv)
    let cipherData = cipher.doFinal(plainText)
    return cipherData
}

// 解密消息。
func decryptMessage(symKey: SymKey, cipherText: DataBlob) {
    let decoder = createCipher('AES128|CBC|PKCS7')
    decoder.initialize(CryptoMode.DecryptMode, symKey, iv)
    let decryptData = decoder.doFinal(cipherText)
    return decryptData
}

func genSymKeyByData(symKeyData: Array<UInt8>) {
    let symKeyBlob: DataBlob = DataBlob(symKeyData)
    let aesGenerator = createSymKeyGenerator('AES128')
    let symKey = aesGenerator.convertKey(symKeyBlob)
    Hilog.info(0,"",'convertKey success')
    return symKey
}

func test() {
    try {
        let keyData: Array<UInt8> = [83, 217, 231, 76, 28, 113, 23, 219, 250, 71, 209, 210, 205, 97, 32, 159]
        let symKey = genSymKeyByData(keyData)
        let message = "This is a test"
        let plainText: DataBlob = DataBlob(message.toArray())
        let encryptText = encryptMessage(symKey, plainText)
        let decryptText = decryptMessage(symKey, encryptText)
        if (plainText.data.toString() == decryptText.data.toString()) {
            Hilog.info(0,"",'decrypt ok')
            Hilog.info(0,"",'decrypt plainText: ' + String.fromUtf8(decryptText.data))
        } else {
            Hilog.error(0,"",'decrypt failed')
        }
    } catch (e: BusinessException) {
        Hilog.error(0,"","AES CBC ${e}, error code: ${e.code}")
    }
}
```
