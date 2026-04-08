# 关系型数据库跨设备数据同步

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 场景介绍

当应用程序本地存储的关系型数据存在跨设备同步的需求时，可以将需要同步的表数据迁移到新的支持跨设备的表中，也可以在刚完成表创建时设置其支持跨设备。

## 基本概念

关系型数据库跨设备数据同步，支持应用在多设备间同步存储的关系型数据。

- 应用在数据库中新创建表后，可以设置其为分布式表。在查询远程设备数据库时，根据本地表名可以获取指定远程设备的分布式表名。
- 设备之间同步数据，数据同步有两种方式，将数据从本地设备推送到远程设备或将数据从远程设备拉至本地设备。

## 运作机制

底层通信组件完成设备发现和认证，会通知上层应用程序设备上线。收到设备上线的消息后，数据管理服务可以在两个设备之间建立加密的数据传输通道，利用该通道在两个设备之间进行数据同步。

### 数据跨设备同步机制

![relationalStore_sync](figures/relational-store-sync.png)   <!-- ToBeReviewd -->

业务将数据写入关系型数据库后，向数据管理服务发起同步请求。

数据管理服务从应用沙箱内读取待同步数据，根据对端设备的deviceId将数据发送到其他设备的数据管理服务。再由数据管理服务将数据写入同应用的数据库内。

### 数据变化通知机制

增、删、改数据库时，订阅者会收到数据变化的通知。主要分为本地数据变化通知和分布式数据变化通知。

- **本地数据变化通知：** 本地设备的应用内订阅数据变化通知，数据库增删改数据时，会收到通知。
- **分布式数据变化通知：** 同一应用订阅组网内其他设备数据变化的通知，其他设备增删改数据时，本设备会收到通知。

## 约束限制

- 每个应用程序最多支持同时打开16个关系型分布式数据库。
- 单个数据库最多支持注册8个订阅数据变化的回调。
- 不支持将含有复合键的表设置为分布式表。

## 接口说明

以下是关系型设备协同分布式数据库跨设备数据同步功能的相关接口，更多接口及使用方式请参见[关系型数据库](../reference/ArkData/cj-apis-relational_store.md)。

| 接口名称 | 描述 |
| -------- | -------- |
| on(event: String, interProcess: Bool, observer: Callback0Argument): Unit | 订阅分布式数据变化。 |
| off(event: String, interProcess: Bool, observer!: ?Callback0Argument = None): Unit | 取消订阅分布式数据变化。 |

## 开发步骤

> **说明：**
>
> 数据只允许向数据安全标签不高于对端设备安全等级的设备同步数据，具体规则请参见[跨设备同步访问控制机制](cj-access-control-by-device-and-data-level.md#跨设备同步访问控制机制)。

1. 导入模块。

    <!-- compile -->

    ```cangjie
    import kit.ArkData.*
    import kit.AbilityKit.{UIAbility, Want, LaunchParam, LaunchReason}
    import kit.ArkUI.WindowStage
    import kit.PerformanceAnalysisKit.Hilog
    import ohos.business_exception.BusinessException
    ```

2. 请求权限。

   (1) 需要申请ohos.permission.DISTRIBUTED_DATASYNC权限，配置方式请参见[声明权限](../security/AccessToken/cj-declare-permissions.md)。

   (2) 同时需要在应用首次启动时弹窗向用户申请授权，使用方式请参见[向用户申请授权](../security/AccessToken/cj-request-user-authorization.md)。

3. 创建关系型数据库。

    <!-- compile -->

    ```cangjie
    // main_ability.cj
    var rdbStore: Option<RdbStore> = Option<RdbStore>.None

    class MainAbility <: UIAbility {
        public init() {
            super()
            registerSelf()
        }

        public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
            match (launchParam.launchReason) {
                case LaunchReason.StartAbility => Hilog.info(0, "cangjie", "START_ABILITY")
                case _ => ()
            }
        }

        public override func onWindowStageCreate(windowStage: WindowStage): Unit {
            Hilog.info(0, "cangjie", "MainAbility onWindowStageCreate.")
            windowStage.loadContent("EntryView")

            let storeConfig = StoreConfig(
                RelationalStoreSecurityLevel.S3, // 数据库安全级别
                name: "RdbTest.db", // 数据库文件名
                
            )

            try {
                let store = getRdbStore(this.context, storeConfig)
                store.executeSql("CREATE TABLE EMPLOYEE(ID int NOT NULL, NAME varchar(255) NOT NULL, AGE int, SALARY float NOT NULL, CODES Bit NOT NULL, PRIMARY KEY (Id))")
                rdbStore = store
                // 后续可进行数据的相关操作
            } catch (e: BusinessException) {
                Hilog.error(0, "ErrorCode: ${e.code}", e.message)
            }
            // ...
        }
    }
    ```
