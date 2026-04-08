# 使用AES对称密钥（CCM模式）加解密

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

对应的算法规格请参见[对称密钥加解密算法规格：AES](./cj-crypto-sym-encrypt-decrypt-spec.md#aes)。

## 加密

1. 调用[createSymKeyGenerator](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createsymkeygeneratorstring)、[generateSymKey](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-generatesymkey)，生成密钥算法为AES且密钥长度为128位的对称密钥（SymKey）。

   如何生成AES对称密钥，开发者可参考下文示例，并结合[对称密钥生成和转换规格：AES](./cj-crypto-sym-key-generation-conversion-spec.md#aes)和[随机生成对称密钥](./cj-crypto-generate-sym-key-randomly.md)理解，参考文档与当前示例可能存在入参差异，请在阅读时注意区分。

2. 调用[createCipher](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createcipherstring)，指定字符串参数'AES128|CCM'，创建对称密钥类型为AES128、分组模式为CCM的Cipher实例，用于完成加密操作。

3. 调用[initialize](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-initializecryptomode-key-paramsspec)，设置模式为加密（CryptoMode.EncryptMode），指定加密密钥（SymKey）和CCM模式对应的加密参数（CcmParamsSpec），初始化加密Cipher实例。

4. 调用[update](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-updatedatablob)，更新数据（明文）。

   当前单次update长度没有限制，开发者可以根据数据量判断如何调用update。

   > **说明：**
   > CCM模式不支持分段加解密。

5. 调用[doFinal](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-dofinaldatablob)，获取加密后的数据。
   由于已使用update传入数据，此处data传入None。

6. 读取[CcmParamsSpec.authTag](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#class-ccmparamsspec)作为解密的认证信息。

    在CCM模式下，算法库当前只支持12字节的authTag，作为解密时初始化的认证信息。示例中authTag恰好为12字节。

## 解密

1. 调用[createCipher](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createcipherstring)，指定字符串参数'AES128|CCM'，创建对称密钥类型为AES128且分组模式为CCM的Cipher实例，用于完成解密操作。

2. 调用[initialize](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-initializecryptomode-key-paramsspec)，设置模式为解密（CryptoMode.DecryptMode），指定解密密钥（SymKey）和CCM模式对应的解密参数（CcmParamsSpec），初始化解密Cipher实例。

3. 调用[doFinal](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-dofinaldatablob)，获取解密后的数据。

## 示例

同步方法示例如下：

<!-- compile -->

```cangjie
import kit.CryptoArchitectureKit.*
import kit.PerformanceAnalysisKit.Hilog

func genCcmParamsSpec() {
    let rand: Random = createRandom()
    let ivBlob: DataBlob = rand.generateRandom(7)
    let aadBlob: DataBlob = rand.generateRandom(8)
    let dataTag: Array<UInt8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] // 12 bytes
    let tagBlob: DataBlob = DataBlob(dataTag)
    // CCM的authTag在加密时从doFinal结果中获取，在解密时填入init函数的params参数中。
    let ccmParamsSpec: CcmParamsSpec = CcmParamsSpec("CcmParamsSpec", ivBlob, aadBlob, tagBlob)
    return ccmParamsSpec
}

var ccmParams = genCcmParamsSpec()
// 加密消息。
func encryptMessage(symKey: SymKey, plainText: DataBlob) {
    let cipher = createCipher('AES128|CCM')
    cipher.initialize(CryptoMode.EncryptMode, symKey, ccmParams)
    let encryptUpdate = cipher.update(plainText);
    // ccm模式加密doFinal时传入空，获得tag数据，并更新至ccmParams对象中。
    ccmParams.authTag = cipher.doFinal(Option<DataBlob>.None);
    return encryptUpdate
}

// 解密消息。
func decryptMessage(symKey: SymKey, cipherText: DataBlob) {
    let decoder = createCipher('AES128|CCM')
    decoder.initialize(CryptoMode.DecryptMode, symKey, ccmParams)
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
```
