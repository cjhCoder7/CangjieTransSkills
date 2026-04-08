# 密钥协商

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

以协商密钥类型为X25519，并密钥仅在HUKS内使用为例，完成密钥协商。具体的场景介绍及支持的算法规格，请参见[密钥生成支持的算法](./cj-huks-key-generation-overview.md#支持的算法)。

## 开发步骤

### 生成密钥

设备A、设备B各自生成一个非对称密钥，具体请参见[密钥生成](./cj-huks-key-generation-overview.md)或[密钥导入](./cj-huks-key-import-overview.md)。

密钥生成时，可指定参数HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG（可选），用于标识基于该密钥协商出的密钥是否由HUKS管理。

- 当TAG设置为HUKS_STORAGE_ONLY_USED_IN_HUKS时，表示基于该密钥协商出的密钥，由HUKS管理，可保证协商密钥全生命周期不出安全环境。

- 当TAG设置为HUKS_STORAGE_KEY_EXPORT_ALLOWED时，表示基于该密钥协商出的密钥，返回给调用方管理，由业务自行保证密钥安全。

- 若业务未设置TAG的具体值，表示基于该密钥协商出的密钥，可由HUKS管理，也可返回给调用方管理，业务可在后续协商时再选择使用何种方式保护密钥。

### 导出密钥

设备A、B导出非对称密钥对的公钥材料，具体请参见[密钥导出](./cj-huks-export-key.md)。

### 密钥协商

设备A、B分别基于本端私钥和对端设备的公钥，协商出共享密钥。

密钥协商时，可指定参数HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG（可选），用于标识协商得到的密钥是否由HUKS管理。

| 生成 | 协商 | 规格 |
| :-------- | :-------- | :-------- |
| HUKS_STORAGE_ONLY_USED_IN_HUKS | HUKS_STORAGE_ONLY_USED_IN_HUKS | 密钥由HUKS管理 |
| HUKS_STORAGE_KEY_EXPORT_ALLOWED | HUKS_STORAGE_KEY_EXPORT_ALLOWED | 密钥返回给调用方管理 |
| 未指定TAG具体值 | HUKS_STORAGE_ONLY_USED_IN_HUKS | 密钥由HUKS管理 |
| 未指定TAG具体值 | HUKS_STORAGE_KEY_EXPORT_ALLOWED | 密钥返回给调用方管理 |
| 未指定TAG具体值 | 未指定TAG具体值 | 密钥返回给调用方管理 |

协商时指定的TAG值，不可与生成时指定的TAG值冲突。表格中仅列举有效的指定方式。

### 删除密钥

当密钥废弃不用时，设备A、B均需要删除密钥，具体请参见[密钥删除](./cj-huks-delete-key.md)。

## 示例

下面分别以X25519与DH密钥为例，进行协商。

- X25519非对称密钥协商用例

    <!-- compile -->

    ```cangjie
    /*
     * 以下以X25519密钥的操作使用为例
     */
    import kit.PerformanceAnalysisKit.Hilog
    import kit.UniversalKeystoreKit.*

    func loggerInfo(str: String) {
        Hilog.info(0, "CangjieTest", str)
    }

    /*
     * 确定密钥别名和封装密钥属性参数集
     */
    let srcKeyAliasFirst = "AgreeX25519KeyFirstAlias"
    let srcKeyAliasSecond = "AgreeX25519KeySecondAlias"
    let agreeX25519InData = 'AgreeX25519TestIndata'
    var finishOutData: ?Array<UInt8> = None
    var handle: ?HuksHandleId = None
    var exportKey: ?Array<UInt8> = None
    var exportKeyFirst: ?Array<UInt8> = None
    var exportKeySecond: ?Array<UInt8> = None
    /* 集成生成密钥参数集 */
    let properties: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_X25519),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_AGREE),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_CURVE25519_KEY_SIZE_256),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_NONE),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PADDING,
            HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_NONE),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_BLOCK_MODE,
            HuksParamValue.Uint32Value(HuksCipherMode.HUKS_MODE_CBC),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
            HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
        )
    ]
    var huksOptions: HuksOptions = HuksOptions(
        properties: properties,
        inData: Bytes()
    )
    /* 集成第一个协商参数集 */
    let finishProperties1: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
            HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_IS_KEY_ALIAS,
            HuksParamValue.BooleanValue(true)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(1 | 2),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_NONE),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PADDING,
            HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_NONE),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_BLOCK_MODE,
            HuksParamValue.Uint32Value(HuksCipherMode.HUKS_MODE_ECB),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_ALIAS,
            HuksParamValue.BytesValue((srcKeyAliasFirst + 'final').toArray())
        )
    ]
    let finishOptionsFirst: HuksOptions = HuksOptions(
        properties: finishProperties1,
        inData: StringToUint8Array(agreeX25519InData)
    )
    /* 集成第二个协商参数集 */
    let finishProperties2: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
            HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_IS_KEY_ALIAS,
            HuksParamValue.BooleanValue(true)
        ),
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(1 | 2),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_DIGEST,
            HuksParamValue.Uint32Value(HuksKeyDigest.HUKS_DIGEST_NONE),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PADDING,
            HuksParamValue.Uint32Value(HuksKeyPadding.HUKS_PADDING_NONE),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_BLOCK_MODE,
            HuksParamValue.Uint32Value(HuksCipherMode.HUKS_MODE_ECB),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_ALIAS,
            HuksParamValue.BytesValue((srcKeyAliasSecond + 'final').toArray())
        )
    ]
    let finishOptionsSecond: HuksOptions = HuksOptions(
        properties: finishProperties2,
        inData: StringToUint8Array(agreeX25519InData)
    )

    func StringToUint8Array(str: String) {
        return str.toArray()
    }

    class throwObject {
        var isThrow: Bool = false

        init(isThrow: Bool) {
            this.isThrow = isThrow
        }
    }

    /* 生成密钥 */
    func generateKeyItem(keyAlias: String, huksOptions: HuksOptions, throwObject: throwObject) {
        try {
            generateKeyItem(keyAlias, huksOptions)
        } catch (e: Exception) {
            throwObject.isThrow = true
            throw e
        }
    }

    /* 调用generateKeyItem生成密钥 */
    func publicGenKeyFunc(keyAlias: String, huksOptions: HuksOptions) {
        loggerInfo("enter generateKeyItem")
        let throwObject: throwObject = throwObject(false)
        try {
            generateKeyItem(keyAlias, huksOptions, throwObject)
        } catch (e: Exception) {
            loggerInfo("generateKeyItem input arg invalid, ${e}")
        }
    }

    /*初始化密钥会话接口，并获取一个句柄（必选）和挑战值（可选）*/
    func initSession(keyAlias: String, huksOptions: HuksOptions, throwObject: throwObject) {
        return try {
            initSession(keyAlias, huksOptions).handle
        } catch (e: Exception) {
            throwObject.isThrow = true
            throw e
        }
    }

    /*调用initSession获取handle*/
    func publicInitFunc(keyAlias: String, huksOptions: HuksOptions) {
        loggerInfo("enter doInit")
        let throwObject: throwObject = throwObject(false)
        try {
            handle = initSession(keyAlias, huksOptions, throwObject)
        } catch (e: Exception) {
            loggerInfo("doInit input arg invalid, ${e}")
        }
    }

    /* 分段添加密钥操作的数据并进行相应的密钥操作，输出处理数据 */
    func updateSession(handle: HuksHandleId, huksOptions: HuksOptions, throwObject: throwObject) {
        return try {
            updateSession(handle, huksOptions)
        } catch (e: Exception) {
            throwObject.isThrow = true
            throw e
        }
    }

    /* 调用updateSession进行协商操作 */
    func publicUpdateFunc(handle: HuksHandleId, huksOptions: HuksOptions) {
        loggerInfo("enter doUpdate")
        let throwObject: throwObject = throwObject(false)
        try {
            updateSession(handle, huksOptions, throwObject)
        } catch (e: Exception) {
            loggerInfo("doUpdate input arg invalid, ${e}")
        }
    }

    /* 结束密钥会话并进行相应的密钥操作，输出处理数据 */
    func finishSession(handle: HuksHandleId, huksOptions: HuksOptions, throwObject: throwObject) {
        return try {
            finishSession(handle, huksOptions)
        } catch (e: Exception) {
            throwObject.isThrow = true
            throw e
        }
    }

    /* 调用finishSession结束操作 */
    func publicFinishFunc(handle: HuksHandleId, huksOptions: HuksOptions) {
        loggerInfo("enter doFinish")
        let throwObject: throwObject = throwObject(false)
        try {
            finishOutData = finishSession(handle, huksOptions, throwObject)
        } catch (e: Exception) {
            loggerInfo("doFinish input arg invalid, ${e}")
        }
    }

    /* 导出密钥 */
    func exportKeyItem(keyAlias: String, huksOptions: HuksOptions, throwObject: throwObject) {
        return try {
            exportKeyItem(keyAlias, huksOptions)
        } catch (e: Exception) {
            throwObject.isThrow = true
            throw e
        }
    }

    /* 调用exportKeyItem导出公钥操作 */
    func publicExportKeyFunc(keyAlias: String, huksOptions: HuksOptions) {
        loggerInfo("enter export")
        let throwObject: throwObject = throwObject(false)
        try {
            exportKey = exportKeyItem(keyAlias, huksOptions, throwObject)
        } catch (e: Exception) {
            loggerInfo("exportKeyItem input arg invalid, ${e}")
        }
    }

    ```

- DH密钥协商用例

    <!-- compile -->

    ```cangjie
    /*
     * 以下以 DH密钥的操作使用为例
     */
    import kit.PerformanceAnalysisKit.Hilog
    import kit.UniversalKeystoreKit.*
    import std.math.numeric.BigInt

    func loggerInfo(str: String) {
        Hilog.info(0, "CangjieTest", str)
    }

    func StringToUint8Array(str: String) {
        return str.toArray()
    }

    func Uint8ArrayToBigInt(arr: Array<UInt8>): BigInt {
        var i = 0
        let byteMax: BigInt = BigInt('100')
        var result: BigInt = BigInt('0')
        while (i < arr.size) {
            result = result * byteMax
            result = result + BigInt(arr[i])
            i += 1
        }
        return result
    }

    let dhAgree: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_DH),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_AGREE),
        )
    ]
    let dh2048Agree: Array<HuksParam> = [
        HuksParam(
            HuksTag.HUKS_TAG_ALGORITHM,
            HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_DH),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_PURPOSE,
            HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_AGREE),
        ),
        HuksParam(
            HuksTag.HUKS_TAG_KEY_SIZE,
            HuksParamValue.Uint32Value(HuksKeySize.HUKS_DH_KEY_SIZE_2048),
        )
    ]
    let dhGenOptions: HuksOptions = HuksOptions(
        properties: dh2048Agree,
        inData: Bytes()
    )
    let emptyOptions: HuksOptions = HuksOptions(properties: [], inData: Bytes())

    func HuksDhAgreeExportKey(
        keyAlias: String,
        peerPubKey: ?Array<UInt8>
    ): ?Array<UInt8> {
        let initHandle = initSession(keyAlias, dhGenOptions)
        let dhAgreeUpdateBobPubKey: HuksOptions = HuksOptions(
            properties: [
                HuksParam(
                    HuksTag.HUKS_TAG_ALGORITHM,
                    HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_DH),
                ),
                HuksParam(
                    HuksTag.HUKS_TAG_PURPOSE,
                    HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_AGREE),
                ),
                HuksParam(
                    HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
                    HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_KEY_EXPORT_ALLOWED),
                )
            ],
            inData: peerPubKey.getOrThrow()
        )
        updateSession(initHandle.handle, dhAgreeUpdateBobPubKey)
        return finishSession(initHandle.handle, emptyOptions)
    }

    func HuksDhAgreeExportTest(aliasA: String, aliasB: String, pubKeyA: ?Array<UInt8>, pubKeyB: ?Array<UInt8>) {
        let agreedKeyFromAlice = HuksDhAgreeExportKey(aliasA, pubKeyB).getOrThrow()
        loggerInfo("ok! agreedKeyFromAlice export is 0x${Uint8ArrayToBigInt(agreedKeyFromAlice).toString(radix: 16)}")

        let agreedKeyFromBob = HuksDhAgreeExportKey(aliasB, pubKeyA).getOrThrow()
        loggerInfo("ok! agreedKeyFromBob export is 0x${Uint8ArrayToBigInt(agreedKeyFromBob).toString(radix: 16)}")
    }

    func HuksDhAgreeInHuks(keyAlias: String, peerPubKey: ?Array<UInt8>, aliasAgreedKey: String): ?Array<UInt8> {
        let onlyUsedInHuks: Array<HuksParam> = [
            HuksParam(
                HuksTag.HUKS_TAG_KEY_STORAGE_FLAG,
                HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
            ),
            HuksParam(
                HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
                HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
            )
        ]
        let dhAgreeInit: HuksOptions = HuksOptions(
            properties: [
                HuksParam(
                    HuksTag.HUKS_TAG_KEY_STORAGE_FLAG,
                    HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
                ),
                HuksParam(
                    HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
                    HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
                ),
                HuksParam(
                    HuksTag.HUKS_TAG_KEY_SIZE, 
                    HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256)
                ),
                HuksParam(
                    HuksTag.HUKS_TAG_KEY_STORAGE_FLAG,
                    HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
                ),
                HuksParam(
                    HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
                    HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
                )
            ],
            inData: Bytes()
        )
        let dhAgreeFinishParams: Array<HuksParam> = [
            HuksParam(
                HuksTag.HUKS_TAG_KEY_STORAGE_FLAG,
                HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
            ),
            HuksParam(
                HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
                HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
            ),
            HuksParam(HuksTag.HUKS_TAG_IS_KEY_ALIAS, HuksParamValue.BooleanValue(true)),
            HuksParam(HuksTag.HUKS_TAG_ALGORITHM, HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_AES)),
            HuksParam(
                HuksTag.HUKS_TAG_KEY_SIZE, 
                HuksParamValue.Uint32Value(HuksKeySize.HUKS_AES_KEY_SIZE_256)
            ),
            HuksParam(
                HuksTag.HUKS_TAG_PURPOSE,
                HuksParamValue.Uint32Value(1 | 2)
            )
        ]

        let handle = initSession(keyAlias, dhAgreeInit)
        let dhAgreeUpdatePubKey: HuksOptions = HuksOptions(
            properties: [
                HuksParam(
                    HuksTag.HUKS_TAG_ALGORITHM,
                    HuksParamValue.Uint32Value(HuksKeyAlg.HUKS_ALG_DH),
                ),
                HuksParam(
                    HuksTag.HUKS_TAG_PURPOSE,
                    HuksParamValue.Uint32Value(HuksKeyPurpose.HUKS_KEY_PURPOSE_AGREE),
                ),
                HuksParam(
                    HuksTag.HUKS_TAG_KEY_STORAGE_FLAG,
                    HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
                ),
                HuksParam(
                    HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
                    HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
                )
            ],
            inData: peerPubKey.getOrThrow()
        )
        updateSession(handle.handle, dhAgreeUpdatePubKey)
        let dhAgreeAliceFinnish: HuksOptions = HuksOptions(
            properties: [
                HuksParam(
                    HuksTag.HUKS_TAG_KEY_STORAGE_FLAG,
                    HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
                ),
                HuksParam(
                    HuksTag.HUKS_TAG_DERIVED_AGREED_KEY_STORAGE_FLAG,
                    HuksParamValue.Uint32Value(HuksKeyStorageType.HUKS_STORAGE_ONLY_USED_IN_HUKS),
                ),
                HuksParam(HuksTag.HUKS_TAG_IS_KEY_ALIAS, HuksParamValue.BooleanValue(true)),
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
                ),
                HuksParam(HuksTag.HUKS_TAG_KEY_ALIAS, HuksParamValue.BytesValue(aliasAgreedKey.toArray()))
            ],
            inData: Bytes()
        )
        return finishSession(handle.handle, dhAgreeAliceFinnish)
    }

    func HuksDhAgreeInHuksTest(aliasA: String, aliasB: String, pubKeyA: ?Array<UInt8>, pubKeyB: ?Array<UInt8>,
        aliasAgreedKeyFromA: String, aliasAgreedKeyFromB: String) {
        let finishAliceResult = HuksDhAgreeInHuks(aliasA, pubKeyB, aliasAgreedKeyFromA).getOrThrow()
        loggerInfo("ok! finishAliceResult in huks is 0x${Uint8ArrayToBigInt(finishAliceResult).toString(radix: 16)}")
        let aliceAgreedExist = hasKeyItem(aliasAgreedKeyFromA, emptyOptions)
        loggerInfo("ok! aliceAgreedExist in huks is ${aliceAgreedExist}")

        let finishBobResult = HuksDhAgreeInHuks(aliasB, pubKeyA, aliasAgreedKeyFromB).getOrThrow()
        loggerInfo("ok! finishBobResult in huks is 0x${Uint8ArrayToBigInt(finishBobResult).toString(radix: 16)}")
        let bobAgreedExist = hasKeyItem(aliasAgreedKeyFromB, emptyOptions)
        loggerInfo("ok! bobAgreedExist in huks is ${bobAgreedExist}")

        deleteKeyItem(aliasAgreedKeyFromA, emptyOptions)
        deleteKeyItem(aliasAgreedKeyFromB, emptyOptions)
    }

    func huksDhAgreeTest() {
        let aliasAlice = 'alice'
        let aliasBob = 'bob'

        /* 调用generateKeyItem生成别名为alice与bob的两个密钥 */
        generateKeyItem(aliasAlice, dhGenOptions)
        generateKeyItem(aliasBob, dhGenOptions)

        /* 导出非对称密钥alice与bob的的公钥 */
        let pubKeyAlice = exportKeyItem(aliasAlice, emptyOptions)
        let pubKeyBob = exportKeyItem(aliasBob, emptyOptions)

        /* 开始协商，协商生成的密钥返回给业务管理 */
        HuksDhAgreeExportTest(aliasAlice, aliasBob, pubKeyAlice, pubKeyBob)

        /* 开始协商，协商生成的密钥由HUKS管理 */
        HuksDhAgreeInHuksTest(aliasAlice, aliasBob, pubKeyAlice, pubKeyBob, 'agreedKeyFromAlice', 'agreedKeyFromBob')

        deleteKeyItem(aliasAlice, emptyOptions)
        deleteKeyItem(aliasBob, emptyOptions)
    }
    ```
