# ohos.ability_access_ctrl（程序访问控制管理）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

程序访问控制管理模块提供程序的权限管理能力，包括鉴权、授权和取消授权等。

## 导入模块

```cangjie
import kit.AbilityKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class AbilityAccessCtrl

```cangjie
public class AbilityAccessCtrl {}
```

**功能：** 此类用于创建[AtManager](#class-atmanager)，AtManager为管理访问控制模块的实例。

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22

### static func createAtManager()

```cangjie
public static func createAtManager(): AtManager
```

**功能：** 创建程序管理访问控制模块的实例对象。

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|[AtManager](#class-atmanager)|管理访问控制模块的实例。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.AbilityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let atManager: AtManager = AbilityAccessCtrl.createAtManager()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## class AtManager

```cangjie
public class AtManager {}
```

**功能：** 管理访问控制模块的实例。

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22

### func checkAccessToken(UInt32, Permissions)

```cangjie
public func checkAccessToken(tokenID: UInt32, permissionName: Permissions): GrantStatus
```

**功能：** 校验应用是否授予权限。

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|tokenID|UInt32|是|-|要校验的目标应用的身份标识。可通过应用的[ApplicationInfo](cj-apis-bundle_manager.md#class-applicationinfo)的accessTokenId字段获得。|
|permissionName|[Permissions](#type-permissions)|是|-|需要校验的权限名称，合法的权限名取值可在[应用权限列表](../../security/AccessToken/cj-app-permissions.md)中查询。|

**返回值：**

|类型|说明|
|:----|:----|
|[GrantStatus](#enum-grantstatus)|返回授权状态结果。|

**异常：**

- BusinessException：对应错误码如下表，详见[访问控制错误码](./cj-errorcode-access-token.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 12100001 | Invalid parameter. The tokenID is 0, or the permissionName exceeds 256 characters. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.AbilityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let atManager = AbilityAccessCtrl.createAtManager()
    let tokenID : UInt32 = 1 // tokenID系统应用可以通过bundleManager.getApplicationInfo获取，普通应用可以通过bundleManager.getBundleInfoForSelf获取
    let status = atManager.checkAccessToken(tokenID, "ohos.permission.READ_CONTACTS")
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### func requestPermissionsFromUser(UIAbilityContext, Array\<Permissions>, AsyncCallback\<PermissionRequestResult>)

```cangjie
public func requestPermissionsFromUser(context: UIAbilityContext, permissionList: Array<Permissions>,
    requestCallback: AsyncCallback<PermissionRequestResult>): Unit
```

**功能：** 用于拉起弹框请求用户授权。

如果用户拒绝授权，将无法再次拉起弹框，需要用户在系统应用“设置”的界面中，手动授予权限。

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|context|[UIAbilityContext](cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)|是|-|请求权限的UIAbility的Context。|
|permissionList|Array\<[Permissions](#type-permissions)>|是|-|权限名列表，合法的权限名取值可在[应用权限列表](../../security/AccessToken/cj-app-permissions.md)中查询。|
|requestCallback|AsyncCallback\<[PermissionRequestResult](cj-apis-sercurity-permission_request_result.md#class-permissionrequestresult)>|是|-|回调函数，返回接口调用是否成功的结果。|

**异常：**

- BusinessException：对应错误码如下表，详见[访问控制错误码](./cj-errorcode-access-token.md)。

  | 错误码ID | 错误信息 |
  | :---- | :--- |
  | 12100001 | Invalid parameter. The context is invalid when it does not belong to the application itself. |

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.AbilityKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.*
import ohos.business_exception.BusinessException

try {
    // 此处代码可添加在依赖项定义中
    var resultCallback = {
        errorCode: Option<BusinessException>, data: Option<PermissionRequestResult> => match (errorCode) {
            case Some(e) => Hilog.error(0, "AppLogCj", "permissionResultCallBack request error: errcode is ${e.code}")
            case _ =>
                match (data) {
                    case Some(value) =>
                        for (i in (0..value.permissions.size)) {
                            Hilog.info(0, "AppLogCj", "CallBack: ${value.permissions[i]} - ${value.authResults[i]}")
                        }
                    case _ => Hilog.error(0, "AppLogCj", "permissionResultCallBack request error: data is null")
                }
        }
    }

    let ctx = Global.abilityContext // 此处需手动配置模板，获取Context上下文。上下文获取方式请参见使用说明。
    let atManager = AbilityAccessCtrl.createAtManager()
    let permissionList = ["ohos.permission.READ_CONTACTS", "ohos.permission.CAMERA"]
    atManager.requestPermissionsFromUser(ctx, permissionList, resultCallback)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

## enum GrantStatus

```cangjie
public enum GrantStatus <: Equatable<GrantStatus> & ToString {
    | PermissionDenied
    | PermissionGranted
    | ...
}
```

**功能：** 表示授权状态的枚举。

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22

**父类型：**

- Equatable\<GrantStatus>
- ToString

### PermissionDenied

```cangjie
PermissionDenied
```

**功能：** 表示未授权。

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22

### PermissionGranted

```cangjie
PermissionGranted
```

**功能：** 表示已授权。

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22

### func !=(GrantStatus)

```cangjie
public operator func !=(other: GrantStatus): Bool
```

**功能：** 对授权状态进行判不等。

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[GrantStatus](#enum-grantstatus)|是|-|授权状态。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果授权状态不同，返回true，否则返回false。|

### func ==(GrantStatus)

```cangjie
public operator func ==(other: GrantStatus): Bool
```

**功能：** 对授权状态进行判等。

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[GrantStatus](#enum-grantstatus)|是|-|授权状态。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|如果授权状态相同，返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 返回授权状态的字符串表示。

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|授权状态的字符串表示。|

## type Permissions

```cangjie
public type Permissions = String
```

**功能：** 表示权限名称，是String类型的别名。
