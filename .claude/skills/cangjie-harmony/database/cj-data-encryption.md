# 数据库加密

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 场景介绍

为了增强数据库的安全性，数据库提供了一个安全适用的数据库加密能力，从而对数据库存储的内容实施有效保护。通过数据库加密等安全方法实现了数据库数据存储的保密性和完整性要求，使得数据库以密文方式存储并在密态方式下工作，确保了数据安全。

加密后的数据库只能通过接口进行访问，无法通过其它方式打开数据库文件。数据库的加密属性在创建数据库时确认，无法变更。

键值型数据库和关系型数据库均支持数据库加密操作。

## 键值型数据库加密

键值型数据库，通过options中encrypt参数来设置是否加密，默认为false，表示不加密。encrypt参数为true时表示加密。

具体接口及功能，请参见[分布式键值数据库](../reference/ArkData/cj-apis-distributed_kv_store.md)。

1. 获取context。

    <!-- compile -->

    ```cangjie
    // main_ability.cj
    import kit.PerformanceAnalysisKit.Hilog
    import kit.AbilityKit.{UIAbility, Want, LaunchParam, LaunchReason, UIAbilityContext}

    var globalAbilityContext: Option<UIAbilityContext> = Option<UIAbilityContext>.None

    class MainAbility <: UIAbility {
        public init() {
            super()
            registerSelf()
        }

        public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
            // 获取context
            globalAbilityContext = this.context

            match (launchParam.launchReason) {
                case LaunchReason.StartAbility => Hilog.info(0, "cangjie", "START_ABILITY")
                case _ => ()
            }
        } 
        // ...
    }
    ```

2. 键值型数据库加密设置。

    为实现加密功能，需要导入如下包：

    <!-- compile -->

    ```cangjie
    // xxx.cj
    import kit.ArkData.*
    import ohos.business_exception.BusinessException
    import kit.PerformanceAnalysisKit.Hilog
    ```

    实现加密功能的核心代码是：

    <!-- compile -->

    ```cangjie
    try {
        let context = globalAbilityContext.getOrThrow()
        let kvManagerConfig = KVManagerConfig(globalAbilityContext.getOrThrow(), "com.example.datamanagertest")
        // 创建KVManager实例
        let kvManager = DistributedKVStore.createKVManager(kvManagerConfig)
        Hilog.info(0, "cangjie", "Succeeded in creating KVManager.")

        let options = KVOptions(
            KVSecurityLevel.S3, // 设置安全等级为S3
            createIfMissing: true,
            encrypt: true,
            backup: false,
            autoSync: false,
        )
        let kvStore = kvManager.getKVStore("storeId", options)
        Hilog.info(0, "cangjie", "getSingleKVStore success")
    } catch (e: BusinessException) {
        Hilog.error(0, "ErrorCode: ${e.code}", e.message)
    }
    // 进行其它数据库相关的操作
    // ...
    ```

## 关系型数据库加密

关系型数据库，通过StoreConfig中encrypt属性来设置是否加密，默认为false，表示不加密。encrypt参数为true时表示加密。

具体接口及功能，请参见[关系型数据库](../reference/ArkData/cj-apis-relational_store.md)。

1. 获取context。

    <!-- compile -->

    ```cangjie
    // main_ability.cj
    import kit.PerformanceAnalysisKit.Hilog
    import kit.AbilityKit.{UIAbility, Want, LaunchParam, LaunchReason, UIAbilityContext}

    var globalAbilityContext: Option<UIAbilityContext> = Option<UIAbilityContext>.None

    class MainAbility <: UIAbility {
        public init() {
            super()
            registerSelf()
        }

        public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
            // 获取context
            globalAbilityContext = this.context

            match (launchParam.launchReason) {
                case LaunchReason.StartAbility => Hilog.info(0, "cangjie", "START_ABILITY")
                case _ => ()
            }
        } 
        // ...
    }
    ```

2. 关系型数据库加密设置。

    为实现加密功能，需要导入如下包：

    <!-- compile -->

    ```cangjie
    import kit.ArkData.*
    import kit.PerformanceAnalysisKit.Hilog
    import ohos.business_exception.BusinessException
    ```

    实现加密功能的核心代码是：

    <!-- compile -->

    ```cangjie
    try {
        // globalAbilityContext 在Ability onCreate时获取
        let context = globalAbilityContext.getOrThrow()
        let storeConfig = StoreConfig(
            RelationalStoreSecurityLevel.S3, // 数据库安全级别
            name: "RdbTest.db", // 数据库文件名
            encrypt: true, // 设置数据库加密
        )
        let rdbStore = getRdbStore(context, storeConfig)
        Hilog.info(0, "cangjie", "getRdbStore success")
    } catch (e: BusinessException) {
        Hilog.error(0, "ErrorCode: ${e.code}", e.message)
    }
    // 进行其它数据库相关的操作
    // ...
    ```
