# 错误管理开发指导

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 场景介绍

当应用的代码存在规范问题或错误时，会在运行中产生异常和错误，如应用未捕获异常、应用生命周期超时等。在错误产生后，应用会异常退出。错误日志通常会保存在用户本地存储上，不方便开发者定位问题。所以，应用开发者可以使用错误管理的接口，在应用退出前，及时将相关错误及日志上报到开发者的服务平台来定位问题。

使用errormanager接口监听异常和错误后，应用不会退出，如果只是为了获取错误日志，建议使用[hiappevent](./cj-hiappevent-watcher-crash-events.md)。

## 接口说明

应用错误管理接口由[errorManager](../reference/AbilityKit/cj-apis-app-ability-error_manager.md#class-errormanager)模块提供，开发者可以通过import引入，详情请参见[开发示例](#开发示例)。

**错误管理接口功能介绍：**

| 接口名称 | 说明 |
| ---------- | -------------------- |
| on(eventType: ErrorManagerEvent, observer: ErrorObserver): Int32 | 注册错误观测器。注册后程序如果出现crash，会触发未捕获异常机制。|
| off(eventType: ErrorManagerEvent, observerId: Int32): Unit | 注销错误观测器。|

<!-- waiting -->
**错误监听(ErrorObserver)接口功能介绍：**

| 接口名称 | 说明 |
| --------------- | ----------------- |
| onUnhandledException: (String) -> Unit | 该回调函数调用场景：在程序运行中抛出异常且该异常未被任务‘try-catch’语句成功捕获。errMsg的内容固定为Uncaught exception was found.。 |
| onException: Option \<(ErrorObject) -> Unit> | 该回调函数调用场景：在程序运行中抛出异常且该异常未被任务‘try-catch’语句成功捕获。errObject中包含了该未被捕获的异常的异常名称、异常信息与栈追踪。|

## 开发示例

<!-- compile -->

```cangjie
import kit.AbilityKit.*
import kit.PerformanceAnalysisKit.*
import kit.ArkUI.WindowStage

func loggerInfo(str: String) {
    Hilog.info(0, "CangjieTest", str)
}

func loggerError(str: String) {
    Hilog.error(0, "CangjieTest", str)
}

let registerId: Int32 = -1
let callback: ErrorObserver = ErrorObserver(
    {
        errMsg: String => loggerInfo(errMsg)
    },
    onException: Some(
        {
            errorObj =>
            loggerInfo('onException, name: ${errorObj.name}')
            loggerInfo('onException, message: ${errorObj.message}')
            if (let Some(v) <- errorObj.stack) {
                loggerInfo('onException, stack: ${v}')
            }
        }
    )
)

var abilityWant: Want = Want()

public class EntryAbility <: UIAbility {
    public func onCreate(want: Want, launchParam: LaunchParam) {
        loggerInfo("[Demo] EntryAbility onCreate")
        let registerId = ErrorManager.on(ErrorManagerEvent.Error, callback)
        abilityWant = want
    }

    public override func onDestroy() {
        loggerInfo("[Demo] EntryAbility onDestroy")
        ErrorManager.off(ErrorManagerEvent.Error, registerId)
    }

    public func onWindowStageCreate(windowStage: WindowStage) {
        // Main window is created, set main page for this ability
        loggerInfo("[Demo] EntryAbility onWindowStageCreate")

        windowStage.loadContent("pages/index")
    }

    public func onWindowStageDestroy() {
        // Main window is destroyed, release UI related resources
        loggerInfo("[Demo] EntryAbility onWindowStageDestroy")
    }

    public override func onForeground() {
        // Ability has brought to foreground
        loggerInfo("[Demo] EntryAbility onForeground")
    }

    public override func onBackground() {
        // Ability has back to background
        loggerInfo("[Demo] EntryAbility onBackground")
    }
}
```
