# ohos.app.ability.ability_constant

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

ability_constant模块提供Ability相关的枚举，包括应用启动原因LaunchReason、上次退出原因LastExitReason、迁移结果OnContinueResult等。

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

## class LaunchParam

```cangjie
public class LaunchParam {
    public var launchReason: LaunchReason
    public var lastExitReason: LastExitReason
}
```

**功能：** 启动参数，主要包括Ability启动原因以及上次退出原因。Ability启动时由系统自动传入，开发者无需修改。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### var lastExitReason

```cangjie
public var lastExitReason: LastExitReason
```

**功能：** 枚举类型，表示Ability上次退出原因。

**类型：** [LastExitReason](#enum-lastexitreason)

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### var launchReason

```cangjie
public var launchReason: LaunchReason
```

**功能：** 枚举类型，表示Ability启动原因（如故障恢复拉起、意图调用拉起、原子化服务分享拉起等），详见[LaunchReason](#enum-launchreason)。

**类型：** [LaunchReason](#enum-launchreason)

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

## enum LastExitReason

```cangjie
public enum LastExitReason {
    | Unknown
    | Normal
    | CppCrash
    | AppFreeze
    | ...
}
```

**功能：** Ability上次退出原因，该类型为枚举，可配合UIAbility的[onCreate(want, launchParam)](./cj-apis-app-ability-ui_ability.md#func-oncreatewant-launchparam)方法根据launchParam.lastExitReason的不同类型执行相应操作。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### AppFreeze

```cangjie
AppFreeze
```

**功能：** 应用冻屏导致的应用程序退出。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### CppCrash

```cangjie
CppCrash
```

**功能：** 进程崩溃导致的应用程序退出。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### Normal

```cangjie
Normal
```

**功能：** 用户主动关闭，应用程序正常退出。

> **说明：**
>
> 当开发者直接调用内核kill命令等非Ability Kit提供的能力强制退出应用进程时，也会返回Normal。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### Unknown

```cangjie
Unknown
```

**功能：** 未知原因。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

## enum LaunchReason

```cangjie
public enum LaunchReason {
    | Unknown
    | StartAbility
    | Call
    | Continuation
    | AppRecovery
    | ...
}
```

**功能：** Ability启动原因，该类型为枚举，可配合UIAbility的[onCreate(want, launchParam)](./cj-apis-app-ability-ui_ability.md#func-oncreatewant-launchparam)方法根据launchParam.launchReason的不同类型执行相应操作。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### AppRecovery

```cangjie
AppRecovery
```

**功能：** 设置应用恢复后，应用故障时自动恢复启动Ability。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### Call

```cangjie
Call
```

**功能：** 调用启动。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### Continuation

```cangjie
Continuation
```

**功能：** 跨端迁移启动Ability。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### StartAbility

```cangjie
StartAbility
```

**功能：** 通过[startAbility](./cj-apis-app-ability-ui_ability.md#func-startabilitywant-startoptions)接口启动Ability。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### Unknown

```cangjie
Unknown
```

**功能：** 未知原因。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

## enum MemoryLevel

```cangjie
public enum MemoryLevel <: Equatable<MemoryLevel> & ToString {
    | MemoryLevelModerate
    | MemoryLevelLow
    | MemoryLevelCritical
    | ...
}
```

**功能：** 整机可用内存级别，该类型为枚举。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

**父类型：**

- [Equatable\<MemoryLevel>](#enum-memorylevel)
- ToString

### MemoryLevelCritical

```cangjie
MemoryLevelCritical
```

**功能：** 整机可用内存极低。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### MemoryLevelLow

```cangjie
MemoryLevelLow
```

**功能：** 整机可用内存低。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### MemoryLevelModerate

```cangjie
MemoryLevelModerate
```

**功能：** 整机可用内存适中。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### func !=(MemoryLevel)

```cangjie
public operator func !=(other: MemoryLevel): Bool
```

**功能：** 判断两个枚举值是否不相等。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MemoryLevel](#enum-memorylevel)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值不相等返回true，否则返回false。|

### func ==(MemoryLevel)

```cangjie
public operator func ==(other: MemoryLevel): Bool
```

**功能：** 判断两个枚举值是否相等。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|other|[MemoryLevel](#enum-memorylevel)|是|-|另一个枚举值。|

**返回值：**

|类型|说明|
|:----|:----|
|Bool|两个枚举值相等返回true，否则返回false。|

### func toString()

```cangjie
public func toString(): String
```

**功能：** 获取当前枚举的字符串表示。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

**返回值：**

|类型|说明|
|:----|:----|
|String|当前枚举的字符串表示。|

## enum OnContinueResult

```cangjie
public enum OnContinueResult {
    | Agree
    | Reject
    | Mismatch
    | ...
}
```

**功能：** Ability迁移结果，该类型为枚举。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### Agree

```cangjie
Agree
```

**功能：** 表示同意。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### Mismatch

```cangjie
Mismatch
```

**功能：** 表示版本不匹配。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### Reject

```cangjie
Reject
```

**功能：** 表示拒绝。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

## enum WindowMode

```cangjie
public enum WindowMode {
    | WindowModeFullscreen
    | WindowModeSplitPrimary
    | WindowModeSplitSecondary
    | ...
}
```

**功能：** 启动UIAbility时窗口的创建模式，类型为枚举。可配合[startAbility](./cj-apis-app-ability-ui_ability.md#func-startabilitywant-startoptions)方法使用。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### WindowModeFullscreen

```cangjie
WindowModeFullscreen
```

**功能：** 全屏模式。仅在Tablet设备上生效。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### WindowModeSplitPrimary

```cangjie
WindowModeSplitPrimary
```

**功能：** 支持应用内拉起Ability时设置为分屏，左侧分屏。仅在折叠屏和Tablet设备上生效。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### WindowModeSplitSecondary

```cangjie
WindowModeSplitSecondary
```

**功能：** 支持应用内拉起Ability时设置为分屏，右侧分屏。仅在折叠屏和Tablet设备上生效。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22
