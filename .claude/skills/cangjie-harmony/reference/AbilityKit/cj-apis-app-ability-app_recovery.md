# ohos.app.ability.app_recovery（应用故障恢复）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

app_recovery模块提供了应用在故障状态下的恢复能力。

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

## func restartApp()

```cangjie
public func restartApp(): Unit
```

**功能：** 重启当前进程，并拉起应用启动时第一个Ability，如果该Ability存在已经保存的状态，这些状态数据会在Ability的OnCreate生命周期回调的want参数中作为wantParam属性传入。

按以下规则启动：

- 如果当前应用前台的Ability支持恢复，则重新拉起该Ability。

- 如果存在多个支持恢复的Ability处于前台，则只拉起最后一个。

- 如果没有Ability处于前台，则不拉起。

- 可以配合[ErrorManager](./cj-apis-app-ability-error_manager.md)相关接口使用。两次重启的间隔应大于一分钟，一分钟之内重复调用此接口只会退出应用不会重启应用。自动重启的行为与主动重启一致。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

**示例：**

<!-- compile -->

```cangjie
// index.cj

import kit.AbilityKit.*
import ohos.business_exception.BusinessException
import kit.PerformanceAnalysisKit.Hilog

try {
    restartApp()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```
