# ohos.security.permission_request_result（PermissionRequestResult）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

权限请求结果对象。在调用[requestPermissionsFromUser](cj-apis-ability_access_ctrl.md#func-requestpermissionsfromuseruiabilitycontext-arraypermissions-asynccallbackpermissionrequestresult)申请权限时返回此对象，表明此次权限申请的结果。

## 导入模块

```cangjie
import kit.AbilityKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class PermissionRequestResult

```cangjie
public class PermissionRequestResult {
    public var permissions: Array<String>
    public var authResults: Array<Int32>
    public var dialogShownResults = Array<Bool>()
}
```

**功能：** 构建权限请求结果对象。

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22

### var authResults

```cangjie
public var authResults: Array<Int32>
```

**功能：** 响应请求权限的结果：

- -1：未授权。如果dialogShownResults返回为true，表示用户首次申请；如果dialogShownResults返回为false，表示权限已设置，无需弹窗，需要用户在"设置"中修改。

- 0：已授权。

- 2：未授权，表示请求无效。可能原因有：①未在设置文件中声明目标权限；②权限名非法；③部分权限存在特殊申请条件，在申请对应权限时未满足其指定的条件。

**类型：** Array\<Int32>

**读写能力：** 可读写

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22

### var dialogShownResults

```cangjie
public var dialogShownResults = Array<Bool>()
```

**功能：** 此权限申请是否有弹窗：

true：有弹窗。

false：无弹窗。

**类型：** Array\<Bool>

**读写能力：** 可读写

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22

### var permissions

```cangjie
public var permissions: Array<String>
```

**功能：** 用户传入的权限。

**类型：** Array\<String>

**读写能力：** 可读写

**系统能力：** SystemCapability.Security.AccessToken

**起始版本：** 22
