# UIAbility组件基本用法

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

[UIAbility](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiability)组件的基本用法包括：指定UIAbility的启动页面以及获取uiability的上下文信息[UIAbilityContext](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)。

## 指定UIAbility的启动页面

应用中的[UIAbility](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiability)在启动过程中，需要指定启动页面，否则应用启动后会因为没有默认加载页面而导致白屏。可以在UIAbility的[onWindowStageCreate()](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#func-onwindowstagecreatewindowstage)生命周期回调中，通过[WindowStage](../reference/arkui-cj/cj-apis-window.md#class-windowstage)对象的[loadContent()](../reference/arkui-cj/cj-apis-window.md#class-windowstage)方法设置启动页面。

<!-- compile -->

```cangjie
import kit.AbilityKit.UIAbility
import kit.ArkUI.WindowStage

class MainAbility <: UIAbility {
    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        // Main window is created, set main page for this ability
        windowStage.loadContent("EntryView")
    }
    // ...
}
```

> **说明：**
>
> 在DevEco Studio中创建的UIAbility中，该UIAbility实例默认会加载Index页面，根据需要将Index页面类名替换为需要的页面类名即可。

## 获取UIAbility的上下文信息

[UIAbility](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiability)类拥有自身的上下文信息，该信息为[UIAbilityContext](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)类的实例，[UIAbilityContext](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)类拥有abilityInfo、currentHapModuleInfo等属性。通过AbilityContext可以获取Ability的相关配置信息，如包代码路径、Bundle名称、Ability名称和应用程序需要的环境状态等属性信息，以及可以获取操作Ability实例的方法（如[startAbility()](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#func-startabilitywant-startoptions)、[terminateSelf()](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#func-terminateself)等）。

- 在UIAbility中可以通过`this.context`获取UIAbility实例的上下文信息。

  <!-- compile -->

  ```cangjie
  import kit.AbilityKit.{UIAbility, UIAbilityContext, Want, LaunchParam}
  import kit.ArkUI.WindowStage

  var globalContext : ?UIAbilityContext = None

  class MainAbility <: UIAbility {
      public override func onWindowStageCreate(windowStage: WindowStage): Unit {
          // 获取Ability实例的上下文
          globalContext = this.context
          windowStage.loadContent("EntryView")
    }
  }
  ```

- 在页面中获取UIAbility实例的上下文信息，包括导入依赖资源context模块和在组件中定义一个context变量两个部分。

  <!-- compile -->

  ```cangjie
  import kit.AbilityKit.{UIAbilityContext, Want}

  func getContext(): UIAbilityContext {
      return globalContext.getOrThrow()
  }

  @Entry
  @Component
  class EntryView {
      @State
      var context: UIAbilityContext = getContext()

      func startAbilityTest(): Unit {
          let want = Want(
              // Want参数信息
          )
          context.startAbility(want)
      }

      // 页面展示
      func build() {
          // ...
      }
  }
  ```

  也可以在导入依赖资源context模块后，再使用[UIAbilityContext](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiabilitycontext)前进行变量定义。

  <!-- compile -->

  ```cangjie
  import kit.AbilityKit.{UIAbilityContext, Want}

  func getContext(): UIAbilityContext {
      return globalContext.getOrThrow()
  }

  @Entry
  @Component
  class EntryView {
      func startAbilityTest(): Unit {
          let context = getContext()
          let want = Want(
              // Want参数信息
          )
          context.startAbility(want)
      }

      // 页面展示
      func build() {
          // ...
      }
  }
  ```

- 当业务完成后，开发者如果想要终止当前[UIAbility](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiability)实例，可以通过调用[terminateSelf()](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#func-terminateself)方法实现。

  <!-- compile -->

  ```cangjie
  import kit.PerformanceAnalysisKit.Hilog
  import kit.AbilityKit.{UIAbilityContext, Want}

  func getContext(): UIAbilityContext {
      return globalContext.getOrThrow()
  }

  @Entry
  @Component
  class EntryView {
      func build() {
          Row {
              Column {
                  Text("")
                      .fontSize(50)
                      .fontWeight(FontWeight.Bold)
                      .onClick ({
                          evt =>
                          let context = getContext()
                          try {
                              // 执行正常业务
                              context.terminateSelf()
                          } catch (e: Exception) {
                              // 处理业务逻辑错误
                              Hilog.error(0, "terminateSelf failed", " message is ${e.toString()}")
                          }
                      })
              }.width(100.percent)
          }.height(100.percent)
      }
  }
  ```
