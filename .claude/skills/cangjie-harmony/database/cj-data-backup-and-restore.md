# 数据库备份与恢复

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 场景介绍

当应用在处理一项重要的操作时不能被打断，例如：写入多个表关联的事务。此时，每个表的写入都是单独的，但是表与表之间的事务关联性不能被分割。

如果操作的过程中出现问题，开发者可以使用恢复功能，将数据库恢复到之前的状态，重新对数据库进行操作。

在数据库被篡改、删除、或者设备断电场景下，数据库可能会因为数据丢失、数据损坏、脏数据等而不可用，可以通过数据库的备份恢复能力将数据库恢复至可用状态。

键值型数据库和关系型数据库均支持对数据库的备份和恢复。另外，键值型数据库还支持删除数据库备份，以释放本地存储空间。

## 键值型数据库备份、恢复与删除

键值型数据库，通过backup接口实现数据库备份，通过restore接口实现数据库恢复，通过deletebackup接口删除数据库备份。具体接口及功能，请参见[分布式键值数据库](../reference/ArkData/cj-apis-distributed_kv_store.md)。

1. 创建数据库。

    a. 获取context。

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
                case LaunchReason.StartAbility => Hilog.info(0, "cangjie", "StartAbility")
                case _ => ()
            }
        } 
        // ...
    }
    ```

    b. 创建kvStore。

    为实现创建kvStore功能，需要导入如下包：

    <!-- compile -->

    ```cangjie
    // xxx.cj
    import kit.ArkData.*
    import kit.PerformanceAnalysisKit.Hilog
    import ohos.business_exception.BusinessException
    ```

    实现创建kvStore功能的核心代码是：

    <!-- compile -->

    ```cangjie
    var kvManager: Option<KVManager> = Option<KVManager>.None
    var kvStore: Option<SingleKVStore> = Option<SingleKVStore>.None

    try {
        // 1. 创建kvManager
        let kvManagerConfig = KVManagerConfig(globalAbilityContext.getOrThrow(), "com.example.datamanagertest")
        kvManager = DistributedKVStore.createKVManager(kvManagerConfig)
        // 2. 配置数据库参数
        let options = KVOptions(
            KVSecurityLevel.S3,
            createIfMissing: true,
            encrypt: true,
            backup: false,
            autoSync: false,
        )
        // 3. 创建kvStore
        kvStore = kvManager.getOrThrow().getKVStore("storeId", options)
    } catch (e: BusinessException) {
        Hilog.error(0, "ErrorCode: ${e.code}", e.message)
    }
   ```

2. 使用put()方法插入数据。

    实现插入数据功能的核心代码是：

    <!-- compile -->

    ```cangjie
    const KEY_TEST_STRING_ELEMENT: String = "key_test_string"
    const VALUE_TEST_STRING_ELEMENT: String = "value_test_string"

    try {
        kvStore.getOrThrow().put(KEY_TEST_STRING_ELEMENT, KVValueType.StringValue(VALUE_TEST_STRING_ELEMENT))
    } catch (e: BusinessException) {
        Hilog.error(0, "ErrorCode: ${e.code}", e.message)
    }
    ```

3. 使用backup()方法备份数据。

    <!-- compile -->

    ```cangjie
    try {
        kvStore.getOrThrow().backup("BK001")
    } catch (e: BusinessException) {
        Hilog.error(0, "ErrorCode: ${e.code}", e.message)
    }
    ```

4. 使用delete()方法删除数据（模拟意外删除、篡改场景）。

    <!-- compile -->

    ```cangjie
    try {
        kvStore.getOrThrow().delete(KEY_TEST_STRING_ELEMENT)
    } catch (e: BusinessException) {
        Hilog.error(0, "ErrorCode: ${e.code}", e.message)
    }
    ```

5. 使用restore()方法恢复数据。

    <!-- compile -->

    ```cangjie
    try {
        kvStore.getOrThrow().restore("BK001")
    } catch (e: BusinessException) {
        Hilog.error(0, "ErrorCode: ${e.code}", e.message)
    }
    ```

## 关系型数据库备份

数据库操作或者存储过程中，有可能会因为各种原因发生非预期的数据库异常的情况，可以根据需要使用关系型数据库的备份能力，以便在数据库异常时，可靠高效地恢复数据保证业务数据正常使用。

关系型数据库支持两种手动备份和自动备份（仅系统应用可用）两种方式。

### 手动备份

手动备份：通过调用[backup](../reference/ArkData/cj-apis-relational_store.md#func-backupstring)接口实现数据库手动备份。示例如下：

为实现手动备份功能，需要导入如下包：

<!-- compile -->

```cangjie
import kit.ArkData.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.BusinessException
```

实现手动备份功能的核心代码是：

<!-- compile -->

```cangjie
var rdbStore_: Option<RdbStore> = Option<RdbStore>.None
let storeConfig_ = StoreConfig(
    RelationalStoreSecurityLevel.S3,// 数据库安全级别
    name: "RdbTest.db", // 数据库文件名
    encrypt: false, // 可选参数，指定数据库是否加密，默认不加密
)

try {
    let store = getRdbStore(globalAbilityContext.getOrThrow(), storeConfig_)
    store.executeSql("CREATE TABLE EMPLOYEE(ID int NOT NULL, NAME varchar(255) NOT NULL, AGE int, SALARY float NOT NULL, CODES Bit NOT NULL, PRIMARY KEY (Id))")
    /**
     * "Backup.db"为备份数据库文件名，默认在RdbStore同路径下备份。
     * 也可指定绝对路径："/data/storage/el2/database/Backup.db"，文件路径需要存在，不会自动创建目录。
     */
    store.backup("Backup.db")
    rdbStore_ = store
} catch (e: BusinessException) {
    Hilog.error(0, "ErrorCode: ${e.code}", e.message)
}
```

## 关系型数据库数据恢复

针对数据库出现异常的情况，在数据库重建成功后，需要用提前备份好的数据进行数据恢复。

### 恢复手动备份数据

关系型数据库通过调用backup接口可以实现[手动备份数据库](#手动备份)，通过restore接口可以实现手动恢复数据库。

具体恢复过程和关键示例代码片段如下，完整示例代码请结合关系型数据库的备份、重建等上下文进行实现。

1. 抛出数据库异常错误码。

    实现抛出数据库异常错误码功能的核心代码是：

    <!-- compile -->

    ```cangjie
    try {
        let predicates = RdbPredicates("EMPLOYEE")
        let columns = ["ID", "NAME", "AGE", "SALARY", "CODES"]
        let resultSet = rdbStore_.getOrThrow().query(predicates, columns: columns)
        /*
         * 业务的增删改逻辑
         * ...
         */
        // 抛出异常
        if (resultSet.rowCount == -1) {
            resultSet.isColumnNull(0)
        }
        // resultSet.goToFirstRow(), resultSet.count等其它接口也会抛异常
        while (resultSet.goToNextRow()) {
            Hilog.info(0, "info", "${resultSet.getRow().size}")
        }
        resultSet.close()
    } catch (e: BusinessException) {
        if (e.code == 14800011) {
            // 执行下文的步骤，即关闭结果集之后进行数据的恢复
        }
        Hilog.error(0, "ErrorCode: ${e.code}", e.message)
    }
    ```

2. 关闭所有打开着的结果集。

    实现关闭结果集功能的核心代码是：

    <!-- compile -->

    ```cangjie
    try {
        // 所有打开着的结果集
        var resultSets: Array<ResultSet> = Array<ResultSet>()
        // 结果集添加到resultSets中
        // ...
        // 使用resultSet.close()方法关闭所有打开着的结果集
        for (i in (0..resultSets.size)) {
            resultSets[i].close()
        }
    } catch (e: BusinessException) {
        if (e.code != 14800014) {
            Hilog.error(0, "ErrorCode: ${e.code}", e.message)
        }
    }
    ```

3. 调用restore接口恢复数据。

    为实现恢复数据功能，需要导入如下包：

    <!-- compile -->

    ```cangjie
    import kit.CoreFileKit.FileIo
    ```

    实现恢复数据功能的核心代码是：

    <!-- compile -->

    ```cangjie
    try {
        /**
         * "Backup.db"为备份数据库文件名，默认在当前 store 所在路径下查找备份文件 Backup.db。
         * 如在备份时指定了绝对路径："/data/storage/el2/database/Backup.db", 需要传入绝对路径。
         */
        let backup = '/data/storage/el2/database/Backup.db' + '/entry/rdb/Backup.db'
        if (!FileIo.access(backup)) {
            Hilog.info(0, "info", "no backup file")
        }
        // 调用restore接口恢复数据
        rdbStore_.getOrThrow().restore("Backup.db")
        Hilog.info(0, "info","Succeeded in backup data.")
    } catch (e: BusinessException) {
        Hilog.error(0, "ErrorCode: ${e.code}", e.message)
    }
    ```
