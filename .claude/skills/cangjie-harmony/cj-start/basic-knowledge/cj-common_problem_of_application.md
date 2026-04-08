# 应用程序包常见问题

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 如何获取签名信息中的指纹信息

1. 通过调用接口获取。

    可以调用[bundleManager.getBundleInfoForSelf](../../reference/AbilityKit/cj-apis-bundle_manager.md#static-func-getbundleinfoforselfint32)获取自身的BundleInfo应用包信息，应用包信息中包含signatureInfo签名信息，签名信息中包含fingerprint指纹信息。

    <!-- compile -->

    ```cangjie
    import ohos.base.*
    import kit.AbilityKit.*
    import ohos.business_exception.BusinessException
    import ohos.hilog.Hilog

    let bundleFlags =  BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO
    try {
        let res = BundleManager.getBundleInfoForSelf(bundleFlags)
        let fingerprint = res.signatureInfo.fingerprint
        Hilog.info(1, "1", "info", "getBundleInfoForSelf successfully, fingerprint: ${fingerprint}")
    } catch (e: BusinessException)  {
        Hilog.error(1, "info", "Failed to getBundleInfoForSelf. Code is ${e.code}, message is ${e.message}")
    }
    ```

2. 通过[bm工具](../../tools/cj-bm-tool.md)获取fingerprint指纹信息。

    ```shell
    hdc shell
    # 需将com.example.myapplication替换为实际应用的包名
    bm dump -n com.example.myapplication | grep fingerprint
    ```

    ![alt text](figures/get_fingerprint.png)

3. 通过.cer证书文件获取，可以参考[APP备案FAQ](https://developer.huawei.com/consumer/cn/doc/app/50130)中OpenHarmony应用/元服务如何获取公钥和签名信息。

4. 通过keytool工具获取，详情参考[生成签名证书指纹](https://developer.huawei.com/consumer/cn/doc/AppGallery-connect-Guides/appgallerykit-preparation-game-0000001055356911#section147011294331)。

## 什么是appIdentifier

appIdentifier是<!--RP1-->[Profile签名文件](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/security/app-provision-structure.md)<!--RP1End-->中的一个字段，为应用的唯一标识，在应用签名时生成，其中：

1. 通过DevEco Studio工具[自动签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section18815157237)生成，此时的appIdentifier字段是随机生成的，在不同的设备上签名、或者重新签名均会导致appIdentifier字段不一致。

2. <!--RP2-->手动配置签名，详情请参见[应用包签名工具指导](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/security/hapsigntool-guidelines.md)，此时appIdentifier字段取值为[HarmonyAppProvision配置文件](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/security/app-provision-structure.md)中app-identifier字段。<!--RP2End-->

因此，在跨设备调试、跨应用交互调试、或者多用户共同开发且需要共享密钥等要求appIdentifier不变的场景下，推荐使用手动签名，具体场景请参考[使用场景说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section54361623194519)。

## 如何获取应用信息中appIdentifier

- 可以调用[bundleManager.getBundleInfoForSelf](../../reference/AbilityKit/cj-apis-bundle_manager.md#static-func-getbundleinfoforselfint32)获取自身的BundleInfo应用包信息，应用包信息中包含signatureInfo签名信息，签名信息中包含appIdentifier信息。

    <!-- compile -->

    ```cangjie
    import kit.AbilityKit.*
    import ohos.business_exception.BusinessException
    import ohos.hilog.Hilog

    let bundleFlags =  BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO
    try {
        let res = BundleManager.getBundleInfoForSelf(bundleFlags)
        let appIdentifier = res.signatureInfo.appIdentifier
        Hilog.info(1, "1", "info", "getBundleInfoForSelf successfully, appIdentifier: ${appIdentifier}")
    } catch (e: BusinessException)  {
        Hilog.error(1, "info", "Failed to getBundleInfoForSelf. Code is ${e.code}, message is ${e.message}")
    }
    ```

- 通过[bm工具](../../tools/cj-bm-tool.md)获取。

    ```shell
    hdc shell
    # 需将com.example.myapplication替换为实际应用的包名
    bm dump -n com.example.myapplication | grep appIdentifier
    ```

    ![alt text](figures/get_appIdentifier.png)

## 什么是appId

appId是应用的唯一标识，由包名、下划线和证书公钥的Base64编码组成。由于appId和签名信息相关，如果签名证书的公钥更换，appId也会跟随变化，所以应用的唯一标识推荐使用[appIdentifier](#什么是appidentifier)。

## 如何获取应用信息中的appId

- 可以调用[bundleManager.getBundleInfoForSelf](../../reference/AbilityKit/cj-apis-bundle_manager.md#static-func-getbundleinfoforselfint32)获取自身的BundleInfo应用包信息，应用包信息中包含signatureInfo签名信息，签名信息中包含appIdentifier信息。

    <!-- compile -->

    ```cangjie
    import kit.AbilityKit.*
    import ohos.business_exception.BusinessException
    import ohos.hilog.Hilog

    let bundleFlags =  BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO
    try {
        let res = BundleManager.getBundleInfoForSelf(bundleFlags)
        let appId = res.signatureInfo.appId
        Hilog.info(1, "1", "info", "getBundleInfoForSelf successfully, appId: ${appId}")
    } catch (e: BusinessException)  {
        Hilog.error(1, "info", "Failed to getBundleInfoForSelf. Code is ${e.code}, message is ${e.message}")
    }
    ```


- 通过[bm工具](../../tools/cj-bm-tool.md)获取。

    ```shell
    hdc shell
    # 需将com.example.myapplication替换为实际应用的包名
    bm dump -n com.example.myapplication |grep '"appId":'
    ```
    ![alt text](figures/get_appId.png)
