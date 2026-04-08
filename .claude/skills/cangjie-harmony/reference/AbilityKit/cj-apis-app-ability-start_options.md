# ohos.app.ability.start_options

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

start_options模块提供StartOptions，可以作为启动UIAbility接口（例如[startAbility()](./cj-apis-app-ability-ui_ability.md#func-startabilitywant-startoptions)）的入参，用于指定目标UIAbility启动时的选项，包括窗口模式、目标UIAbility启动时所在的屏幕等。

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

## class StartOptions

```cangjie
public open class StartOptions {
    public var windowMode:?WindowMode
    public var displayId: Int32
    public init(
        windowMode!: ?WindowMode = None,
        displayId!: Int32 = 0
    )
}
```

**功能：** StartOptions用于指定启动目标UIAbility时的选项。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### var displayId

```cangjie
public var displayId: Int32
```

**功能：** 屏幕ID，取值为大于等于-1的整数。

- 取值为-1，表示当前屏幕。

- 取值为0，表示主屏幕。

- 取值为正整数，表示指定ID的屏幕。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### var windowMode

```cangjie
public var windowMode:?WindowMode
```

**功能：** 启动UIAbility时的窗口模式。

**类型：** ?[WindowMode](cj-apis-app-ability-ability_constant.md#enum-windowmode)

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### init(?WindowMode, Int32)

```cangjie
public init(
    windowMode!: ?WindowMode = None,
    displayId!: Int32 = 0
)
```

**功能：** 构造函数，创建StartOptions实例。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|windowMode|?[WindowMode](cj-apis-app-ability-ability_constant.md#enum-windowmode)|否|None|**命名参数。** 启动UIAbility时的窗口模式。|
|displayId|Int32|否|0|**命名参数。** 屏幕ID，取值为大于等于-1的整数。|

**示例：**

<!-- compile -->
```cangjie
import kit.AbilityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    let startOptions = StartOptions(windowMode: WindowMode.WindowModeFullscreen, displayId: 0)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```
