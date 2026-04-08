# 密钥删除

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

为保证数据安全性，当不需要使用该密钥时，应该删除密钥。

## 开发步骤

以删除HKDF256密钥为例。

1. 确定密钥别名keyAlias，密钥别名最大长度为128字节。

2. 初始化密钥属性集。用于删除时指定[密钥的属性TAG](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#class-hukstag)，当删除单个时，TAG字段可传空。

3. 调用接口[deleteKeyItem](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-deletekeyitemstring-huksoptions)，删除密钥。

## 示例

<!-- compile -->

```cangjie
/*
 * 以下以HKDF256密钥的操作使用为例
 */
import kit.UniversalKeystoreKit.*

/* 1.确定密钥别名 */
let keyAlias = "test_Key"

/* 2.构造空对象 */
let huksOptions: HuksOptions = HuksOptions()

class throwObject {
    var isThrow: Bool = false

    init(isThrow: Bool) {
        this.isThrow = isThrow
    }
}

func deleteKeyItem(keyAlias: String, huksOptions: HuksOptions, throwObject: throwObject) {
    try {
        deleteKeyItem(keyAlias, huksOptions)
    } catch (e: Exception) {
        throwObject.isThrow = true
        throw e
    }
}

/* 3.删除密钥*/
func publicDeleteKeyFunc(keyAlias: String, huksOptions: HuksOptions) {
    Hilog.info(1, "info", "enter deleteKeyItem")
    let throwObject: throwObject = throwObject(false)
    try {
        deleteKeyItem(keyAlias, huksOptions, throwObject)
    } catch (e: Exception) {
        Hilog.error(1, "info", "deleteKeyItem input arg invalid, ${e}")
    }
}

func testDerive() {
    publicDeleteKeyFunc(keyAlias, huksOptions)
}
```
