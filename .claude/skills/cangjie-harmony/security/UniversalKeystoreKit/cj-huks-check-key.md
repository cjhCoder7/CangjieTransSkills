# 查询密钥是否存在

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

HUKS提供了接口供应用查询指定密钥是否存在。

## 开发步骤

1. 指定密钥别名keyAlias，密钥别名最大长度为128字节。

2. 初始化密钥属性集。用于查询时指定[密钥的属性TAG](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#class-huksoptions)，当查询单个密钥时，TAG字段可为空。

3. 调用接口[hasKeyItem](../../reference/UniversalKeystoreKit/cj-apis-security_huks.md#func-haskeyitemstring-huksoptions)，查询密钥是否存在。

## 示例

为实现查询密钥是否存在功能，需要导入如下包：

```cangjie
import kit.UniversalKeystoreKit.*
```

实现查询密钥是否存在功能的核心代码是：

```cangjie
/* 1. 确定密钥别名 */
let keyAlias = "test_is_key_item_exist"

/* 2. 判断密钥是否存在，变量a应为false */
var a = hasKeyItem(keyAlias, HuksOptions())

let options = HuksOptions(
    properties: [
        HuksParam(HuksTag.HUKS_TAG_ALGORITHM, HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_DH)),
        HuksParam(HuksTag.HUKS_TAG_PURPOSE, HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_AGREE)),
        HuksParam(HuksTag.HUKS_TAG_KEY_SIZE,  HuksParamValue.Uint32Value(HuksKeySize.HUKS_DH_KEY_SIZE_2048))
    ],
    inData: Bytes()
)

/* 3. 生成密钥 */
generateKeyItem(keyAlias, options)
/* 4. 判断密钥是否存在，此时变量a应为true */
a = hasKeyItem(keyAlias, HuksOptions())
```
