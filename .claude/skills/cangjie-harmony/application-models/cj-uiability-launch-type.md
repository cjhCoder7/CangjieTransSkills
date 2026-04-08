# UIAbility组件启动模式

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

[UIAbility](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiability)的启动模式是指UIAbility实例在启动时的不同呈现状态。针对不同的业务场景，系统提供了两种启动模式：

- [singleton启动模式](#singleton启动模式)
- [multiton启动模式](#multiton启动模式)

> **说明：**
>
> `standard`是`multiton`的曾用名，效果与多实例模式一致。

## singleton启动模式

singleton启动模式为单实例模式，也是默认情况下的启动模式。

每次调用[startAbility()](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#func-startabilitywant-startoptions)方法时，如果应用进程中该类型的[UIAbility](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiability)实例已经存在，则复用系统中的UIAbility实例。系统中只存在唯一一个该UIAbility实例，即在最近任务列表中只存在一个该类型的UIAbility实例。

**图1** 单实例模式演示效果

<img src="./figures/uiability-launch-type1.gif" style="zoom:90%">

> **说明：**
>
> 应用的UIAbility实例已创建，该UIAbility配置为单实例模式，再次调用[startAbility()](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#func-startabilitywant-startoptions)方法启动该UIAbility实例。由于启动的还是原来的Ability实例，并未重新创建一个新的UIAbility实例，此时只会进入该UIAbility的[onNewWant()](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#func-onnewwantwant-launchparam)回调，不会进入其[onCreate()](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#func-oncreatewant-launchparam)和[onWindowStageCreate()](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#func-onwindowstagecreatewindowstage)生命周期回调。如果已经创建的实例仍在启动过程中，调用startAbility接口启动该实例，将收到错误码16000082。

如果需要使用singleton启动模式，在[module.json5配置文件](../cj-start/basic-knowledge/cj-module-configuration-file.md)中的`launchType`字段配置为`singleton`即可。

```json
{
  "module": {
    // ...
    "abilities": [
      {
        "launchType": "singleton",
        // ...
      }
    ]
  }
}
```

## multiton启动模式

multiton启动模式为多实例模式，每次调用[startAbility()](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#func-startabilitywant-startoptions)方法时，都会在应用进程中创建一个新的该类型[UIAbility](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiability)实例。即在最近任务列表中可以看到有多个该类型的UIAbility实例。这种情况下可以将UIAbility配置为multiton（多实例模式）。

**图2** 多实例模式演示效果

<img src="./figures/uiability-launch-type2.gif" style="zoom:90%">

multiton启动模式的开发使用，在[module.json5配置文件](../cj-start/basic-knowledge/cj-module-configuration-file.md)中的`launchType`字段配置为`multiton`即可。

```json
{
  "module": {
    // ...
    "abilities": [
      {
        "launchType": "multiton",
        // ...
      }
    ]
  }
}
```
