# ohos.ability.ability_result

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

ability_result模块定义了Ability被拉起并退出后返回的结果码和数据。

## 导入模块

```cangjie
import kit.AbilityKit.*
```

## 权限列表

ohos.permission.DISTRIBUTED_DATASYNC

ohos.permission.PREPARE_APP_TERMINATE

ohos.permission.PRIVACY_WINDOW

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](./cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class AbilityResult

```cangjie
public class AbilityResult {
    public var resultCode: Int32
    public var want: Want
    public init(resultCode: Int32, want!: Want = Want())
}
```

**功能：** 定义UIAbility被拉起并退出后返回给调用方的结果码和数据。

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### var resultCode

```cangjie
public var resultCode: Int32
```

**功能：** 目标方的UIAbility被拉起并退出后，目标方返回给拉起方的结果码。

正常情况下，返回目标方传递的结果码。

异常情况下，返回-1。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### var want

```cangjie
public var want: Want
```

**功能：** 表示UIAbility被拉起并退出后返回的数据。

**类型：** [Want](cj-apis-app-ability-want.md#class-want)

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

### init(Int32, Want)

```cangjie
public init(resultCode: Int32, want!: Want = Want())
```

**功能：** 构造AbilityResult这个类。

**系统能力：** SystemCapability.Ability.AbilityBase

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|resultCode|Int32|是|-|表示结果码。|
|want|[Want](cj-apis-app-ability-want.md#class-want)|否|Want()|**命名参数。** 表示Want类型信息，如ability名称，包名等。|

**示例：**

<!-- compile -->
```cangjie
import kit.AbilityKit.*

let abilityResult = AbilityResult(0)
```
