# ohos.app.ability.ability_stage

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

ability_stage模块提供AbilityStage相关的功能，包括AbilityStage的创建、注册等。

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

## class AbilityStage

```cangjie
public open class AbilityStage {}
```

**功能：** AbilityStage是Ability的运行时类，提供Ability的创建、销毁等生命周期回调。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

### prop context

```cangjie
public mut prop context: AbilityStageContext
```

**功能：** AbilityStage的上下文。

**类型：** [AbilityStageContext](cj-apis-app-ability-ui_ability.md#class-abilitystagecontext)

**读写能力：** 可读写

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

**示例：**

<!-- compile -->
```cangjie
import kit.AbilityKit.*

class MyAbilityStage1 <: AbilityStage {
    public override func onCreate(): Unit {
        let context = this.context
    }
}
```
### func onCreate()

```cangjie
public open func onCreate(): Unit
```

**功能：** 在加载Module的第一个Ability实例前，系统会先创建对应的AbilityStage实例，并在AbilityStage创建完成后，自动触发该回调。

开发者可以在该回调中执行Module的初始化操作（如资源预加载、线程创建等）。

**系统能力：** SystemCapability.Ability.AbilityRuntime.Core

**起始版本：** 22

**示例：**

<!-- compile -->
```cangjie
import kit.AbilityKit.*

class MyAbilityStage2 <: AbilityStage {
    public override func onCreate(): Unit {
        let context = this.context
    }
}
```
