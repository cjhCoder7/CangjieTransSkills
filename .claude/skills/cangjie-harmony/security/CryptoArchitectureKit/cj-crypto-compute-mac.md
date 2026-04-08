# 消息认证码计算

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

MAC（Message Authentication Code，消息认证码）可以对消息进行完整性校验，通过使用双方共享的密钥，识别出信息伪装篡改等行为。

HMAC（Hash-based Message Authentication Code）是一种基于哈希的消息认证码算法。

HMAC通过指定摘要算法，以通信双方共享密钥与消息作为输入，生成消息认证码用于检验传递报文的完整性。HMAC在消息摘要算法的基础上增加了密钥的输入，确保了信息的正确性。生成的消息认证码为固定长度。

## 支持的算法与规格

当创建HMAC消息认证码时，需要使用表中“支持种类”一列中的算法，指定HMAC消息认证码算法规格。

| 摘要算法 | 支持种类 | API版本 |
| -------- | -------- | -------- |
| HASH | SHA1 | 12+ |
| HASH | SHA224 | 12+ |
| HASH | SHA256 | 12+ |
| HASH | SHA384 | 12+ |
| HASH | SHA512 | 12+ |
| HASH | SM3 | 12+ |
| HASH | MD5 | 12+ |

## 开发步骤

在调用update接口传入数据时，可以[一次性传入所有数据](#hmac一次性传入)，也可以把数据人工分段，然后[分段update](#分段hmac)。对于同一段数据而言，是否分段，计算结果没有差异。对于数据量较大的数据，开发者可以根据实际需求选择是否分段传入。

下面分别提供两种方式的示例代码。

### HMAC（一次性传入）

1. 调用[createMac](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createmacstring)，指定摘要算法SHA256，生成消息认证码实例（Mac）。

2. 调用[createSymKeyGenerator](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createsymkeygeneratorstring)、[convertKey](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-convertkeydatablob)，生成密钥算法为HMAC的对称密钥（SymKey）。
   生成对称密钥的详细开发指导，请参见[指定二进制数据生成对称密钥](./cj-crypto-convert-binary-data-to-sym-key.md)。

3. 调用[initialize](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-initializesymkey)，指定共享对称密钥（SymKey），初始化Mac对象。

4. 调用[update](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-updatedatablob-1)，传入自定义消息，进行消息认证码计算。单次update长度没有限制。

5. 调用[doFinal](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-dofinal)，获取Mac计算结果。

6. 调用[getMacLength](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-getmaclength)，获取Mac消息认证码的长度，单位为字节。

### 以一次性传入数据，获取消息认证码计算结果为例

<!-- compile -->

```cangjie
import kit.CryptoArchitectureKit.*
import kit.PerformanceAnalysisKit.Hilog

func genSymKeyByData(symKeyData: Array<UInt8>) {
    let symKeyBlob: DataBlob = DataBlob(symKeyData)
    let aesGenerator = createSymKeyGenerator('HMAC')
    let symKey = aesGenerator.convertKey(symKeyBlob)
    Hilog.info(0,"",'convertKey success')
    return symKey
}

func doHmacBySync() {
    // 把字符串按utf-8解码为Uint8Array，使用固定的128位的密钥，即16字节
    let keyData = Array<UInt8>(16, repeat:0)
    let key = genSymKeyByData(keyData)
    let macAlgName = 'SHA256' // 摘要算法名
    let message = 'hmacTestMessgae' // 待进行HMAC的数据
    let mac = createMac(macAlgName)
    mac.initialize(key)
    // 数据量较少时，可以只做一次update，将数据全部传入，接口未对入参长度做限制
    mac.update(DataBlob(keyData))
    let macResult = mac.doFinal()
    Hilog.info(0,"",'[Sync]HMAC result: ${macResult.data}')
    let macLen = mac.getMacLength()
    Hilog.info(0,"",'HMAC len: ${macLen}')
}
```

### 分段HMAC

1. 调用[createMac](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createmacstring)，指定摘要算法SHA256，生成消息认证码实例（Mac）。

2. 调用[createSymKeyGenerator](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createsymkeygeneratorstring)，生成密钥算法为HMAC的对称密钥（SymKey）。
   生成对称密钥的详细开发指导，请参见[指定二进制数据生成对称密钥](./cj-crypto-convert-binary-data-to-sym-key.md)。

3. 调用[init](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-initializesymkey)，指定共享对称密钥（SymKey），初始化Mac对象。

4. 传入自定义消息，将一次传入数据量设置为20字节，多次调用[update](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-updatedatablob-1)，进行消息认证码计算。

5. 调用[doFinal](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-dofinal)，获取Mac计算结果。

6. 调用[getMacLength](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-getmaclength)，获取Mac消息认证码的长度，单位为字节。

### 以分段传入数据，获取消息认证码计算结果为例

<!-- compile -->

```cangjie
import kit.CryptoArchitectureKit.*
import kit.PerformanceAnalysisKit.Hilog

func genSymKeyByData(symKeyData: Array<UInt8>) {
    let symKeyBlob: DataBlob = DataBlob(symKeyData)
    let aesGenerator = createSymKeyGenerator('HMAC')
    let symKey = aesGenerator.convertKey(symKeyBlob)
    Hilog.info(0,"",'convertKey success')
    return symKey
}

func doHmacBySync() {
    // 把字符串按utf-8解码为Uint8Array，使用固定的128位的密钥，即16字节
    let keyData = Array<UInt8>(16, repeat:0)
    let key = genSymKeyByData(keyData)
    let macAlgName = 'SHA256' // 摘要算法名
    let message = 'aaaaa.....bbbbb.....ccccc.....ddddd.....eee'.toArray() // 待进行HMAC的数据
    let mac = createMac(macAlgName)
    mac.initialize(key)
    let updateLength = 20; // 假设以20字节为单位进行分段update，实际并无要求
    let size = message.size
    // 数据量较少时，可以只做一次update，将数据全部传入，接口未对入参长度做限制
    for (i in 0..size : updateLength) {
        let len = if (i + updateLength > size) {
            size
        } else {
            i + updateLength
        }
        let updateMessage = message[i..len]
        let updateMessageBlob: DataBlob = DataBlob(updateMessage)
        mac.update(updateMessageBlob)
    }
    let macResult = mac.doFinal()
    Hilog.info(0,"",'[Sync]HMAC result: ${macResult.data}')
    let macLen = mac.getMacLength()
    Hilog.info(0,"",'HMAC len: ${macLen}')
}
```
