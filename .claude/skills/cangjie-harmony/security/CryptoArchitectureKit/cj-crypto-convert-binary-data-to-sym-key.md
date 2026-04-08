# 指定二进制数据转换对称密钥

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

以3DES和HMAC为例，根据指定的对称密钥二进制数据，生成密钥（SymKey），即将外部或存储的二进制数据生成密钥，该对象可用于后续的加解密等操作。

## 指定二进制数据生成3DES密钥

对应的算法规格请参见[对称密钥生成规格：3DES](./cj-crypto-sym-key-generation-conversion-spec.md#3des)。

1. 获取3DES二进制密钥数据，封装成[DataBlob](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#class-datablob)对象。

2. 调用[createSymKeyGenerator](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createsymkeygeneratorstring)，指定字符串参数'3DES192'，创建密钥算法为3DES、密钥长度为192位的对称密钥生成器（SymKeyGenerator）。

3. 调用[convertKey](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-convertkeydatablob)，根据指定的对称密钥二进制数据，生成对称密钥（SymKey）。

4. 调用[getEncoded](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-getencoded)，获取密钥的二进制数据。

以生成3DES密钥为例：

<!-- compile -->

```cangjie
import kit.CryptoArchitectureKit.*
import kit.PerformanceAnalysisKit.Hilog

func genKeyMaterialBlob(): DataBlob {
    let arr: Array<UInt8> = [0xba, 0x3d, 0xc2, 0x71, 0x21, 0x1e, 0x30, 0x56, 0xad, 0x47, 0xfc, 0x5a, 0x46, 0x39, 0xee,
        0x7c, 0xba, 0x3b, 0xc2, 0x71, 0xab, 0xa0, 0x30, 0x72] // 密钥长度为192位，即24字节。
    return DataBlob(arr)
}

func testConvertSymKey() {
    // 创建SymKeyGenerator实例。
    let symKeyGenerator = createSymKeyGenerator('3DES192')
    // 根据指定的数据生成对称密钥。
    let keyMaterialBlob = genKeyMaterialBlob()
    let key = symKeyGenerator.convertKey(keyMaterialBlob)
    let encodedKey = key.getEncoded() // 获取对称密钥的二进制数据，并以字节数组形式输出。长度为24字节。
    Hilog.info(0,"",'key getEncoded hex ${encodedKey.data}')
}
```

## 指定二进制数据生成HMAC密钥

对应的算法规格请参见[对称密钥生成和转换规格：HMAC](./cj-crypto-sym-key-generation-conversion-spec.md#hmac)。

1. 获取HMAC二进制密钥，封装成DataBlob对象。

2. 调用[createSymKeyGenerator](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createsymkeygeneratorstring)，指定字符串参数'HMAC'，创建密钥算法为HMAC、密钥长度为[1, 32768]位的对称密钥生成器（SymKeyGenerator）。

3. 调用[convertKey](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-convertkeydatablob)，根据指定的对称密钥二进制数据，生成对称密钥（SymKey）。

4. 调用[getEncoded](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-getencoded)，获取密钥的二进制数据。

以生成HMAC密钥为例：

<!-- compile -->

```cangjie
import kit.CryptoArchitectureKit.*
import kit.PerformanceAnalysisKit.Hilog

func testConvertKey() {
    // 对称密钥长度为64字节，512比特。
    let keyMessage = '12345678abcdefgh12345678abcdefgh12345678abcdefgh12345678abcdefgh'
    let keyBlob: DataBlob = DataBlob(keyMessage.toArray())
    let symKeyGenerator = createSymKeyGenerator('HMAC')
    let key = symKeyGenerator.convertKey(keyBlob)
    let encodedKey = key.getEncoded()
    Hilog.info(0,"",'key encoded data：${encodedKey.data}')
}
```
