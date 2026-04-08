# 消息摘要计算MD5

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

对应的算法规格请参见[消息摘要计算算法规格](./cj-crypto-generate-message-digest-overview.md#支持的算法与规格)。

## 开发步骤

在调用update接口传入数据时，可以[一次性传入所有数据](#摘要算法一次性传入)，也可以将数据手动分段，然后[分段update](#分段摘要算法)。对于同一段数据而言，计算结果没有差异。对于数据量较大的数据，开发者可以根据实际需求选择是否分段传入。

下面分别提供两种方式的示例代码。

### 摘要算法（一次性传入）

1. 调用[createMd](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createmdstring)，指定摘要算法MD5，生成摘要实例（Md）。

2. 调用[update](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-updatedatablob-2)，传入自定义消息，进行摘要更新计算。单次update长度没有限制。

3. 调用[digest](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-digest)，获取摘要计算结果。

4. 调用[getMdLength](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-getmdlength)，获取摘要计算长度，单位为字节。

### 以单次传入数据，获取摘要计算结果为例

<!-- compile -->

```cangjie
import kit.CryptoArchitectureKit.*
import kit.PerformanceAnalysisKit.Hilog

func doMd() {
    let mdAlgName = 'MD5' // 摘要算法名。
    let message = 'mdTestMessage' // 待摘要的数据。
    let md = createMd(mdAlgName)
    // 数据量较少时，可以只做一次update，将数据全部传入，接口未对入参长度做限制。
    md.update(DataBlob(message.toArray()))
    let mdResult = md.digest()
    Hilog.info(0,"",'[Sync]:Md result: ${mdResult.data}')
    let mdLen = md.getMdLength()
    Hilog.info(0,"","md len: ${mdLen}")
}
```

### 分段摘要算法

1. 调用[createMd](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createmdstring)，指定摘要算法MD5，生成摘要实例（Md）。

2. 传入自定义消息，将一次传入数据量设置为20字节，多次调用[update](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-updatedatablob-2)，进行摘要更新计算。

3. 调用[digest](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-digest)，获取摘要计算结果。

4. 调用[getMdLength](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-getmdlength)，获取摘要计算长度，单位为字节。

### 以分段传入数据，获取摘要计算结果为例

<!-- compile -->

```cangjie
import kit.CryptoArchitectureKit.*
import kit.PerformanceAnalysisKit.Hilog

func doLoopMd() {
    let mdAlgName = "MD5" // 摘要算法名。
    let md = createMd(mdAlgName)
    // 假设信息总共43字节，根据utf-8解码后，也是43字节。
    let messageText = "aaaaa.....bbbbb.....ccccc.....ddddd.....eee"
    let messageData = messageText.toArray()
    let updateLength = 20 // 假设以20字节为单位进行分段update，实际并无此要求。
    let size = messageData.size
    for (i in 0..size : updateLength) {
        let len = if (i + updateLength > size) {
            size
        } else {
            i + updateLength
        }
        let updateMessage = messageData[i..len]
        let updateMessageBlob: DataBlob = DataBlob(updateMessage)
        md.update(updateMessageBlob)
    }
    let mdOutput = md.digest()
    Hilog.info(0,"",'[Sync]:Md result: ${mdOutput.data}')
    let mdLen = md.getMdLength()
    Hilog.info(0,"","md len: ${mdLen}")
}
```
