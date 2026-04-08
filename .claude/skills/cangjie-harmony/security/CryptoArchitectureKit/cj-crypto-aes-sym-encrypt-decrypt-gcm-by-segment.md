# 使用AES对称密钥（GCM模式）分段加解密

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

对应的算法规格请参见[对称密钥加解密算法规格：AES](./cj-crypto-sym-encrypt-decrypt-spec.md#aes)。

## 加密

1. 调用[createSymKeyGenerator](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createsymkeygeneratorstring)，生成密钥算法为AES、密钥长度为128位的对称密钥（SymKey）。

   如何生成AES对称密钥，开发者可参考下文示例，并结合[对称密钥生成和转换规格：AES](./cj-crypto-sym-key-generation-conversion-spec.md#aes)和[随机生成对称密钥](./cj-crypto-generate-sym-key-randomly.md)理解，参考文档与当前示例可能存在入参差异，请在阅读时注意区分。

2. 调用[createCipher](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createcipherstring)，指定字符串参数'AES128|GCM|PKCS7'，创建对称密钥类型为AES128、分组模式为GCM、填充模式为PKCS7的Cipher实例，用于完成加密操作。

3. 调用[initialize](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-initializecryptomode-key-paramsspec)，设置模式为加密（CryptoMode.EncryptMode），指定加密密钥（SymKey）和GCM模式对应的加密参数（GcmParamsSpec），初始化加密Cipher实例。

4. 将一次传入数据量设置为20字节，多次调用[update](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-updatedatablob)，更新数据（明文）。

   当前单次update长度没有限制，开发者可以根据数据量判断如何调用update。

      1）比如ECB和CBC模式，始终以分组作为基本单位来加密，并输出本次update产生的加密分组结果。即当本次update操作凑满一个分组就输出密文，没有凑满则此次update输出空Datablob，将未加密的数据与下次输入的数据拼接凑分组再输出。等到最后doFinal的时候，将未加密的数据，根据指定的填充模式进行填充，再输出剩余加密结果。解密过程中的update同理。

      2）对于流加密模式（比如CTR和OFB模式），通常密文长度和明文长度相等。

5. 调用[doFinal](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-dofinaldatablob)，获取加密后的数据。

   由于已使用update传入数据，此处data传入None。

6. 读取[GcmParamsSpec](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#class-gcmparamsspec).authTag作为解密的认证信息。

   在GCM模式下，算法库当前只支持16字节的authTag，作为解密时初始化的认证信息。示例中authTag恰好为16字节。

## 解密

1. 调用[createCipher](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createcipherstring)，指定字符串参数'AES128|GCM|PKCS7'，创建对称密钥类型为AES128、分组模式为GCM、填充模式为PKCS7的Cipher实例，用于完成解密操作。

2. 调用[initialize](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-initializecryptomode-key-paramsspec)，设置模式为解密（CryptoMode.DecryptMode），指定解密密钥（SymKey）和GCM模式对应的解密参数（GcmParamsSpec），初始化解密Cipher实例。

3. 将一次传入数据量设置为20字节，多次调用[update](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-updatedatablob)，更新数据（密文）。

4. 调用[doFinal](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-dofinaldatablob)，获取解密后的数据。

## 示例

同步方法示例如下：

<!-- compile -->

```cangjie
import kit.CryptoArchitectureKit.*
import std.collection.ArrayList
import kit.PerformanceAnalysisKit.Hilog

func generateRandom(len: Int32) {
    let rand = createRandom()
    let generateRandSync = rand.generateRandom(len)
    return generateRandSync
}

func genGcmParamsSpec() {
    let ivBlob = generateRandom(12)
    let aadBlob: DataBlob = DataBlob([1, 2, 3, 4, 5, 6, 7, 8]) // 8 bytes
    let arr: Array<UInt8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] // 16 bytes
    let tagBlob: DataBlob = DataBlob() // The GCM authTag is obtained by doFinal() in encryption and passed in params of init() in decryption.
    let gcmParamsSpec: GcmParamsSpec = GcmParamsSpec("GcmParamsSpec", ivBlob, aadBlob, tagBlob)
    return gcmParamsSpec
}

var gcmParams = genGcmParamsSpec()
// 加密消息。
func encryptMessage(symKey: SymKey, plainText: DataBlob) {
    let cipher = createCipher('AES128|GCM|PKCS7')
    cipher.initialize(CryptoMode.EncryptMode, symKey, gcmParams)
    let updateLength = 20 // 假设以20字节为单位进行分段update，实际并无要求。
    let cipherText = ArrayList<UInt8>()
    let size = plainText.data.size
    for (i in 0..size : updateLength) {
        let len = if (i + updateLength > size) {
            size
        } else {
            i + updateLength
        }
        let updateMessage = plainText.data[i..len]
        let updateMessageBlob: DataBlob = DataBlob(updateMessage)
        // 分段update。
        let updateOutput = cipher.update(updateMessageBlob)
        // 把update的结果拼接起来，得到密文（有些情况下还需拼接doFinal的结果，这取决于分组模式和填充模式，本例中GCM模式的doFinal结果只包含authTag而不含密文，所以不需要拼接）。
        cipherText.add(all: updateOutput.data)
    }
    gcmParams.authTag = cipher.doFinal(Option<DataBlob>.None)
    let cipherBlob: DataBlob = DataBlob(cipherText.toArray())
    return cipherBlob
}

// 解密消息。
func decryptMessage(symKey: SymKey, cipherText: DataBlob) {
    let decoder = createCipher('AES128|GCM|PKCS7')
    decoder.initialize(CryptoMode.DecryptMode, symKey, gcmParams)
    let updateLength = 20 // 假设以20字节为单位进行分段update，实际并无要求。
    let decryptText = ArrayList<UInt8>()
    let size = cipherText.data.size
    for (i in 0..size : updateLength) {
        let len = if (i + updateLength > size) {
            size
        } else {
            i + updateLength
        }
        let updateMessage = cipherText.data[i..len]
        let updateMessageBlob: DataBlob = DataBlob(updateMessage)
        // 分段update。
        let updateOutput = decoder.update(updateMessageBlob)
        // 把update的结果拼接起来，得到明文。
        decryptText.add(all: updateOutput.data)
    }
    decoder.doFinal(Option<DataBlob>.None)
    let decryptBlob: DataBlob = DataBlob(decryptText.toArray())
    return decryptBlob
}

func genSymKeyByData(symKeyData: Array<UInt8>) {
    let symKeyBlob: DataBlob = DataBlob(symKeyData)
    let aesGenerator = createSymKeyGenerator('AES128')
    let symKey = aesGenerator.convertKey(symKeyBlob)
    Hilog.info(0,"",'convertKey success')
    return symKey
}

func test() {
    let keyData: Array<UInt8> = [83, 217, 231, 76, 28, 113, 23, 219, 250, 71, 209, 210, 205, 97, 32, 159]
    let symKey = genSymKeyByData(keyData)
    let message = "aaaaa.....bbbbb.....ccccc.....ddddd.....eee" // 假设信息总共43字节，根据UTF-8解码后，也是43字节。
    let plainText: DataBlob = DataBlob(message.toArray())
    let encryptText = encryptMessage(symKey, plainText)
    let decryptText = decryptMessage(symKey, encryptText)
    if (plainText.data.toString() == decryptText.data.toString()) {
        Hilog.info(0,"",'decrypt ok')
        Hilog.info(0,"",'decrypt plainText: ' + String.fromUtf8(decryptText.data))
    } else {
        Hilog.error(0,"",'decrypt failed')
    }
}
```
