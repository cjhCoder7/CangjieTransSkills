# 安全随机数生成

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

随机数主要用于临时会话密钥生成和非对称加密算法的密钥生成等场景。在加解密场景中，安全随机数生成器需要具备随机性、不可预测性和不可重复性。当前系统生成的随机数满足密码学安全伪随机性的要求。

开发者可以调用接口，完成以下功能：

- 生成指定长度的安全随机数，并将其用于生成对应的密钥。
- 指定随机种子，生成一系列的随机序列。

在开发前，开发者应该先对加解密基础知识有一定了解，并熟知以下随机数相关的基本概念：

- **内部状态**

  代表随机数生成器内存中的数值，当内部状态相同时，随机数生成器会生成固定的随机数序列。

- **随机种子**

  一个用来对伪随机数的内部状态进行初始化的数据，随机数生成器通过种子来生成一系列的随机序列。

  当前OpenSSL实现方式，随机数生成器内部状态是不断变化的，即使设置相同的种子，生成的随机数序列也不会相同。

## 支持的算法与规格

随机数生成算法使用OpenSSL的RAND_priv_bytes接口生成安全随机数。

| 算法 | 长度（Byte） |
| -------- | -------- |
| CTR_DRBG | [1, Int32.MAX] |

## 开发步骤

1. 调用[createRandom](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-createrandom)，生成随机数实例。

2. (可选)设置DataBlob数据，调用[setSeed](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-setseeddatablob)，为随机数生成池设置种子。

3. 设置指定字节长度，调用[generateRandom](../../reference/CryptoArchitectureKit/cj-apis-crypto.md#func-generaterandomint32)，生成安全随机数。

   指定字节长度范围为1~Int32.MAX。

## 示例

同步方法示例如下：

<!-- compile -->

```cangjie
import kit.CryptoArchitectureKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException

func doRand() {
    let rand = createRandom()
    let len: Int32 = 24 // Generate a 24-byte random number.
    try {
        let randData = rand.generateRandom(len)
        Hilog.info(0,"","rand result: ${randData.data}")
    } catch (e: BusinessException) {
        Hilog.error(0,"","do rand failed, ${e.code}, ${e.message}")
    }
}
```
