# 向用户申请授权

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

当应用需要访问用户的隐私信息或使用系统能力时，例如获取位置信息、访问日历、使用相机拍摄照片或录制视频等，应该向用户请求授权，这部分权限是user_grant权限。

当应用申请user_grant权限时，需要完成以下步骤：

1. 在配置文件中，声明应用需要请求的权限。

2. 将应用中需要申请权限的目标对象与对应目标权限进行关联，让用户明确地知道，哪些操作需要用户向应用授予指定的权限。

    以上两步请参见章节[声明权限](./cj-declare-permissions.md)完成。

3. 运行应用时，在用户触发访问操作目标对象时应该调用接口，精准触发动态授权弹框。该接口的内部会检查当前用户是否已经授权应用所需的权限，如果当前用户尚未授予应用所需的权限，该接口会拉起动态授权弹框，向用户请求授权。

4. 检查用户的授权结果，确认用户已授权才可以进行下一步操作。

本章节会介绍如何完成步骤3和4。

## 约束与限制

- user_grant权限授权要基于用户可知可控的原则，需要应用在运行时主动调用系统动态申请权限的接口，系统弹框由用户授权，用户结合应用运行场景的上下文，识别出应用申请相应敏感权限的合理性，从而做出正确的选择。
- 系统不鼓励频繁弹窗打扰用户，如果用户拒绝授权，将无法再次拉起弹窗，需要应用引导用户在系统应用“设置”的界面中手动授予权限。
- 系统权限弹窗不可被遮挡。

  系统权限弹窗不可被其他组件/控件遮挡，弹窗信息需要完整展示，以便用户识别并完成授权动作。

  如果系统权限弹窗与其他组件/控件同时同位置展示，系统权限弹窗将默认覆盖其他组件/控件。

- 每次执行需要目标权限的操作时，应用都必须检查自己是否已经具有该权限。

  如需检查用户是否已向您的应用授予特定权限，可以使用[checkAccessToken()](../../reference/AbilityKit/cj-apis-ability_access_ctrl.md#func-checkaccesstokenuint32-permissions)函数，此方法会返回[PermissionGranted](../../reference/AbilityKit/cj-apis-ability_access_ctrl.md#enum-grantstatus)或[PermissionDenied](../../reference/AbilityKit/cj-apis-ability_access_ctrl.md#enum-grantstatus)。具体示例可参考下文。

- 每次访问受目标权限保护的接口之前，都需要使用[requestPermissionsFromUser()](../../reference/AbilityKit/cj-apis-ability_access_ctrl.md#func-requestpermissionsfromuseruiabilitycontext-arraypermissions-asynccallbackpermissionrequestresult)接口请求相应的权限。

  用户可能在动态授予权限后通过系统设置来取消应用的权限，因此不能将之前授予的授权状态持久化。

- 应用在onWindowStageCreate()回调中申请授权时，需要等待异步接口loadContent()/setUIContent()执行结束后或在loadContent()/setUIContent()回调中调用[requestPermissionsFromUser()](../../reference/AbilityKit/cj-apis-ability_access_ctrl.md#func-requestpermissionsfromuseruiabilitycontext-arraypermissions-asynccallbackpermissionrequestresult)，否则在Content加载完成前，requestPermissionsFromUser会调用失败。
  <!--RP1--><!--RP1End-->

## 开发步骤

以申请使用位置权限为例进行说明。

效果展示：

<!--RP4-->
![zh-cn_image_location](figures/zh-cn_image_location.png)
<!--RP4End-->

1. 申请ohos.permission.LOCATION、ohos.permission.APPROXIMATELY_LOCATION权限，配置方式请参见[声明权限](./cj-declare-permissions.md)。

2. 校验当前是否已经授权。

    在进行权限申请之前，需要先检查当前应用程序是否已经被授予权限。可以通过调用[checkAccessToken()](../../reference/AbilityKit/cj-apis-ability_access_ctrl.md#func-checkaccesstokenuint32-permissions)方法来校验当前是否已经授权。如果已经授权，则可以直接访问目标操作，否则需要进行下一步操作，即向用户申请授权。

    <!-- compile -->

    ```cangjie
    import kit.AbilityKit.{Permissions, AbilityAccessCtrl, GrantStatus, BundleManager, BundleFlag}
    import kit.PerformanceAnalysisKit.Hilog
    import ohos.bundle.bundle_manager.BundleInfo

    func checkPermissionGrant(permission: Permissions): GrantStatus {
        try {
            // 获取应用程序的accessTokenID
            let tokenID = BundleManager.getBundleInfoForSelf(BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).appInfo.accessTokenId
            let atManager = AbilityAccessCtrl.createAtManager()
            // 校验应用是否被授予权限
            return atManager.checkAccessToken(tokenID, permission)
        } catch(e: Exception) {
            Hilog.error(0,"","checkAccessToken Exception: ${e}")
            throw e
        }
    }

    func checkPermissions(): Unit {
        let grantStatus1: Bool = (checkPermissionGrant("ohos.permission.LOCATION") == GrantStatus.PermissionGranted)
        let grantStatus2: Bool = (checkPermissionGrant("ohos.permission.APPROXIMATELY_LOCATION") == GrantStatus.PermissionDenied)
        // 精确定位权限（ohos.permission.LOCATION）只能跟模糊定位权限（ohos.permission.APPROXIMATELY_LOCATION）一起申请，或者已经有模糊定位权限才能申请精确定位权限
        if (grantStatus2 && !grantStatus1) {
            // 模糊定位权限已申请，精确定位权限未申请
            Hilog.info(0,"","Only APPROXIMATELY_LOCATION is granted")
        } else if (!grantStatus1 && !grantStatus2) {
            // 模糊定位权限和精确定位权限均未申请，需要申请模糊定位权限与精确定位权限，或单独申请模糊定位权限
            Hilog.info(0,"","LOCATION and APPROXIMATELY_LOCATION not granted")
        } else {
            // 已经授权，可以继续访问目标操作
            Hilog.info(0,"","LOCATION and APPROXIMATELY_LOCATION are granted")
        }
    }
    ```

3. 动态向用户申请授权。

    动态向用户申请权限是指在应用程序运行时向用户请求授权的过程。可以通过调用[requestPermissionsFromUser()](../../reference/AbilityKit/cj-apis-ability_access_ctrl.md#func-requestpermissionsfromuseruiabilitycontext-arraypermissions-asynccallbackpermissionrequestresult)方法来实现。该方法接收一个权限列表参数，例如位置、日历、相机、麦克风等。用户可以选择授予权限或者拒绝授权。

    可以在Ability的onWindowStageCreate()回调中调用[requestPermissionsFromUser()](../../reference/AbilityKit/cj-apis-ability_access_ctrl.md#func-requestpermissionsfromuseruiabilitycontext-arraypermissions-asynccallbackpermissionrequestresult)方法来动态申请权限，也可以根据业务需要在UI中向用户申请授权。

    应用在onWindowStageCreate()回调中申请授权时，需要等待异步接口loadContent()/setUIContent()执行结束后或在loadContent()/setUIContent()回调中调用[requestPermissionsFromUser()](../../reference/AbilityKit/cj-apis-ability_access_ctrl.md#func-requestpermissionsfromuseruiabilitycontext-arraypermissions-asynccallbackpermissionrequestresult)，否则在Content加载完成前，requestPermissionsFromUser会调用失败。

    <!--RP1--><!--RP1End-->

    <!--RP2-->

    - 在UIAbility中向用户申请授权。

        <!-- compile -->

        ```cangjie
        // main_ability.cj
        import kit.AbilityKit.*
        import kit.PerformanceAnalysisKit.Hilog
        import ohos.business_exception.*
        import ohos.window.WindowStage

        class MainAbility <: UIAbility {
            // ...
            public override func onWindowStageCreate(windowStage: WindowStage): Unit {
                Hilog.info(0,"","MainAbility onWindowStageCreate.")
                windowStage.loadContent("EntryView")
                // 设置回调
                var resultCallback = {
                    errorCode: Option<BusinessException>, data: Option<PermissionRequestResult> => match (errorCode) {
                        case Some(e) => Hilog.error(0,"","requestPermissionsFromUser failed, errcode: ${e.code}")
                        case _ =>
                            match (data) {
                                case Some(value) =>
                                    for (i in (0..value.permissions.size)) {
                                        if (value.authResults[i] == 0) {
                                            // 用户已授权
                                            Hilog.info(0,"","permission: ${value.permissions[i]} is granted.")
                                        } else {
                                            // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
                                            Hilog.info(0,"","permission: ${value.permissions[i]} is denied by user.")
                                        }
                                    }
                                case _ => Hilog.error(0,"","requestPermissionsFromUser error: data is null")
                            }
                    }
                }
                let permissionList = ["ohos.permission.LOCATION", "ohos.permission.APPROXIMATELY_LOCATION"]
                let atManager = AbilityAccessCtrl.createAtManager()
                // 申请权限，requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
                atManager.requestPermissionsFromUser(this.context, permissionList, resultCallback)
            }
        }
        ```

    - 在UI中向用户申请授权。

        1. 获取context

            <!-- compile -->

            ```cangjie
            // main_ability.cj
            import kit.AbilityKit.*
            import ohos.window.WindowStage
            import kit.PerformanceAnalysisKit.Hilog

            var globalAbilityContext: Option<UIAbilityContext> = Option<UIAbilityContext>.None

            class MainAbility <: UIAbility {
                public init() {
                    super()
                    registerSelf()
                }

                public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
                    Hilog.info(0,"","MainAbility OnCreated.${want.abilityName}")
                    // 获取context
                    globalAbilityContext = Option<UIAbilityContext>.Some(this.context)
                    match (launchParam.launchReason) {
                        case LaunchReason.StartAbility => Hilog.info(0,"","START_ABILITY")
                        case _ => ()
                    }
                }

                public override func onWindowStageCreate(windowStage: WindowStage): Unit {
                    Hilog.info(0,"","MainAbility onWindowStageCreate.")
                    windowStage.loadContent("EntryView")
                }
            }
            ```

        2. 申请权限

            <!-- compile -->

            ```cangjie
            // index.cj
            import kit.AbilityKit.*
            import ohos.business_exception.*
            import kit.PerformanceAnalysisKit.Hilog
            import ohos.arkui.component.button.Button
            import ohos.arkui.state_macro_manage.Entry
            import ohos.arkui.state_macro_manage.Component
            

            @Entry
            @Component
            class EntryView {
                // 申请权限
                func requestPermissons(): Unit {
                    var resultCallback = {
                        errorCode: Option<BusinessException>, data: Option<PermissionRequestResult> => match (errorCode) {
                            case Some(e) => Hilog.info(0,"","permissionResultCallBack request error: errcode: ${e.code}")
                            case _ =>
                                match (data) {
                                    case Some(value) =>
                                        for (i in (0..value.permissions.size)) {
                                            if (value.authResults[i] == 0) {
                                                // 用户已授权
                                                Hilog.info(0,"","permission: ${value.permissions[i]} is granted.")
                                            } else {
                                                // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
                                                Hilog.info(0,"","permission: ${value.permissions[i]} is denied by user.")
                                            }
                                        }
                                    case _ => Hilog.info(0,"","permissionResultCallBack request error: data is null")
                                }
                        }
                    }
                    let atManager = AbilityAccessCtrl.createAtManager()
                    let stageContext = globalAbilityContext.getOrThrow()
                    let permissionList = ["ohos.permission.LOCATION", "ohos.permission.APPROXIMATELY_LOCATION"]
                    atManager.requestPermissionsFromUser(stageContext, permissionList, resultCallback)
                }

                func build() {
                    Row {
                        Column {
                            Button("requestPermissons").onClick ({
                                evt => Hilog.info(0,"","Hello Cangjie")
                                // 点击按钮进行权限申请
                                requestPermissons()
                            }).fontSize(30).height(50)

                        }.width(100.percent)
                    }.height(100.percent)
                }
            }
            ```

    <!--RP2End-->

4. 处理授权结果。

    调用[requestPermissionsFromUser()](../../reference/AbilityKit/cj-apis-ability_access_ctrl.md#func-requestpermissionsfromuseruiabilitycontext-arraypermissions-asynccallbackpermissionrequestresult)方法后，应用程序将等待用户授权的结果。如果用户授权，则可以继续访问目标操作。如果用户拒绝授权，则需要提示用户必须授权才能访问当前页面的功能，并引导用户到系统应用“设置”中打开相应的权限。
    <!--RP3-->

    路径：设置 > 隐私 > 权限管理 > 应用 > 目标应用<!--RP3End-->
