# 管理应用窗口

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 基本概念

- 窗口沉浸式能力：指对状态栏、导航栏等系统窗口进行控制，减少状态栏导航栏等系统界面的突兀感，从而使用户获得最佳体验的能力。
  沉浸式能力只在应用主窗口作为全屏窗口时生效。通常情况下，应用子窗口（弹窗、悬浮窗口等辅助窗口）和处于自由窗口下的应用主窗口无法使用沉浸式能力。

- 悬浮窗：全局悬浮窗口是一种特殊的应用窗口，具备在应用主窗口和对应Ability退至后台后仍然可以在前台显示的能力。
  悬浮窗口可以用于应用退至后台后，使用小窗继续播放视频，或者为特定的应用创建悬浮球等快速入口。应用在创建悬浮窗口前，需要申请对应的权限。

## 场景介绍

在`Stage`模型下，管理应用窗口的典型场景有：

- 设置应用主窗口属性及目标页面

- 设置应用子窗口属性及目标页面

- 体验窗口沉浸式能力

- 设置悬浮窗

- 监听窗口不可交互与可交互事件

以下分别介绍具体开发方式。

## 接口说明

上述场景涉及的常用接口如下表所示。更多API说明请参见[API参考](../reference/arkui-cj/cj-apis-window.md)。

| 实例名         | 接口名                                                       | 描述                                                         |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| WindowStage    | func getMainWindow(): Window | 获取`WindowStage`实例下的主窗口。<br/>此接口仅可在`Stage`模型下使用。 |
| WindowStage    | loadContent(path: String): Unit | 为当前`WindowStage`的主窗口加载具体页面。<br>其中path为要加载到窗口中的页面内容的路径。<br/>此接口仅可在`Stage`模型下使用。 |
| WindowStage    | createSubWindow(name: String): Window | 创建子窗口。<br/>此接口仅可在`Stage`模型下使用。             |
| window静态方法 | createWindow(config: Configuration): Window | 创建子窗口或者系统窗口。<br/>-`config`：创建窗口时的参数。             |
| Window         | setWindowBrightness(brightness: Float32): Unit | 设置屏幕亮度值。                                             |
| Window         | setWindowTouchable(isTouchable: Bool): Unit | 设置窗口是否为可触状态。true表示可触；false表示不可触。 |
| Window         | moveWindowTo(x: Int32, y: Int32): Unit | 移动当前窗口位置。                                           |
| Window         | resize(width: UInt32, height: UInt32): Unit | 改变当前窗口大小。                                           |
| Window         | setWindowLayoutFullScreen(isLayoutFullScreen: Bool): Unit | 设置主窗口或子窗口的布局是否为沉浸式布局。true表示沉浸式布局；false表示非沉浸式布局。|
| Window         | setWindowSystemBarEnabled(names: Array\<SystemBarType>): Unit | 设置主窗口状态栏、三键导航栏的可见模式，状态栏通过status控制、三键导航栏通过navigation控制。<br>例如，该参数设置为[SystemBarType.Status,&nbsp;SystemBarType.Navigation]，则全部显示；设置为[]，则不显示。|
| Window         | setWindowSystemBarProperties(systemBarProperties: SystemBarProperties): Unit | 设置窗口内导航栏、状态栏属性。<br/>`systemBarProperties`：导航栏、状态栏的属性集合。 |
| Window         | func showWindow(): Unit             | 显示当前窗口。                                               |
| Window         | func destroyWindow(): Unit     | 销毁当前窗口。                                               |

## 设置应用主窗口

在`Stage`模型下，应用主窗口由[UIAbility](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiability)创建并维护生命周期。在[UIAbility](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#class-uiability)的[onWindowStageCreate](../reference/AbilityKit/cj-apis-app-ability-ui_ability.md#func-onwindowstagecreatewindowstage)回调中，通过`WindowStage`获取应用主窗口，即可对其进行属性设置等操作。还可以在应用配置文件中设置应用主窗口的属性，如最大窗口宽度maxWindowWidth等，详见[module.json5配置文件中的abilities标签](../cj-start/basic-knowledge/cj-module-configuration-file.md#abilities标签)。

### 开发步骤

1. 获取应用主窗口。

   通过[getMainWindow](../reference/arkui-cj/cj-apis-window.md#func-getmainwindow)接口获取应用主窗口。

2. 设置主窗口属性。

   可设置主窗口的背景色、亮度值、是否可触等多个属性，开发者可根据需要选择对应的接口。本示例以设置“是否可触”属性为例。

3. 为主窗口加载对应的目标页面。

   通过[loadContent](../reference/arkui-cj/cj-apis-window.md#func-loadcontentstring)接口加载主窗口的目标页面。

```cangjie
package ohos_app_cangjie_entry

internal import kit.AbilityKit.*
internal import kit.ArkUI.*

class MainAbility <: UIAbility {
    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        // 1.获取应用主窗口。
        let mainWindow: Window = windowStage.getMainWindow()
        // 2.设置主窗口属性。以设置"是否可触"属性为例。
        mainWindow.setWindowTouchable(false)
        // 3.为主窗口加载对应的目标页面。
        windowStage.loadContent("EntryView")
    }
}
```

## 设置应用子窗口

开发者可以按需创建应用子窗口，如弹窗等，并对其进行属性设置等操作。

> **说明：**
> 以下几种场景不建议使用子窗口，建议优先考虑使用控件[overlay](../reference/arkui-cj/cj-universal-attribute-overlay.md)能力实现。
>
> - 移动设备（手机）场景下子窗不能超出处于悬浮窗、分屏状态的主窗口范围，与控件一致。
> - 分屏窗口与自由窗口模式下，主窗口位置大小发生改变时控件实时跟随变化能力优于子窗。
> - 部分设备平台下根据实际的系统配置限制，子窗只有系统默认的动效和圆角阴影，应用无法设置，自由度低。

### 开发步骤

1. 创建应用子窗口。

   通过`createSubWindow`接口创建应用子窗口。

2. 设置子窗口属性。

   子窗口创建成功后，可以改变其大小、位置等，还可以根据应用需要设置窗口背景色、亮度等属性。

   在调用`showWindow`之前，建议设置子窗口的大小和位置。

   如果没有设置子窗口的大小，调用`showWindow`后:
    + 自由窗口状态下，默认子窗口大小为当前物理屏幕的大小。
    + 非自由窗口状态下，默认子窗口大小为主窗口大小。

3. 加载显示子窗口的具体内容。

   通过`showWindow`接口加载显示子窗口的具体内容。

4. 销毁子窗口。

   当不再需要某些子窗口时，可根据具体实现逻辑，使用`destroyWindow`接口销毁子窗口。

直接在onWindowStageCreate里面创建子窗口的整体示例代码如下：

```cangjie
package ohos_app_cangjie_entry

internal import kit.ArkUI.*
internal import kit.AbilityKit.*

var windowStage: ?WindowStage = None
var subWindow: ?Window = None

class MainAbility <: UIAbility {
    public init() {
        super()
        registerSelf()
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        // 开发者可以在适当的时机，如主窗口上按钮点击事件等，创建子窗口。并不一定需要在onWindowStageCreate调用，这里仅作展示
        // 1.创建应用子窗口。
        subWindow = windowStage.createSubWindow("mySubWindow")
        // 2.子窗口创建成功后，设置子窗口的位置、大小及相关属性等。
        subWindow.getOrThrow().moveWindowTo(300, 300)
        subWindow.getOrThrow().resize(500, 500)
        // 3.显示子窗口。
        subWindow.getOrThrow().showWindow()
    }

    public override func onWindowStageDestroy(): Unit {
        // 开发者可以在适当的时机，如子窗口上点击关闭按钮等，销毁子窗口。并不一定需要在onWindowStageDestroy调用，这里仅作展示
        // 4.销毁子窗口。当不再需要子窗口时，可根据具体实现逻辑，使用destroy对其进行销毁。
        if (!subWindow.isSome()) {
            return
        }
        subWindow.getOrThrow().destroyWindow()
    }
}
```

另外，也可以在某个page页面通过点击按钮创建子窗口，整体示例代码如下：

```cangjie
// main_ability.cj
package ohos_app_cangjie_entry

internal import kit.ArkUI.*
internal import kit.AbilityKit.*
internal import ohos.arkui.state_management.AppStorage

class MainAbility <: UIAbility {
    public init() {
        super()
        registerSelf()
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        AppStorage.setOrCreate("windowStage", windowStage)
        windowStage.loadContent("EntryView")
    }
}
```

```cangjie
// index.cj
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_management.AppStorage
import ohos.arkui.state_macro_manage.*

var windowStage: ?WindowStage = None
var subWindow: ?Window = None

@Entry
@Component
class EntryView{
    @State
    var message: String = "Hello World"

    func build() {
        Row() {
            Column() {
                Text(this.message)
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
                Button() {
                    Text("CreateSubWindow")
                        .fontSize(30)
                        .fontWeight(FontWeight.Normal)
                }
                    .margin(top: 20.px)
                    .backgroundColor(0x0D9FFB)
                    .width(220)
                    .height(68)
                    .onClick {
                        evt =>
                            windowStage = AppStorage.get('windowStage')
                            // 1.创建应用子窗口。
                            subWindow = windowStage.getOrThrow().createSubWindow("mySubWindow")
                            // 2.子窗口创建成功后，设置子窗口的位置、大小及相关属性等。
                            subWindow.getOrThrow().moveWindowTo(300, 300)
                            subWindow.getOrThrow().resize(500, 500)
                            // 3.显示子窗口。
                            subWindow.getOrThrow().showWindow()
                    }
                Button() {
                    Text("destroySubWindow")
                        .fontSize(30)
                        .fontWeight(FontWeight.Normal)
                }
                    .margin(top: 20.px)
                    .backgroundColor(0x0D9FFB)
                    .width(220)
                    .height(68)
                    .onClick({
                        evt =>
                            // 4.销毁子窗口。当不再需要子窗口时，可根据具体实现逻辑，使用destroy对其进行销毁。
                            if (!subWindow.isSome()) {
                                return
                            }
                            subWindow.getOrThrow().destroyWindow()
                    })
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

## 体验窗口沉浸式能力

在看视频、玩游戏等场景下，用户往往希望隐藏状态栏、导航栏等不必要的系统窗口，从而获得更佳的沉浸式体验。此时可以借助窗口沉浸式能力（窗口沉浸式能力都是针对应用主窗口而言的），达到预期效果。从API version 10开始，沉浸式窗口默认配置为全屏大小并由组件模块控制布局，状态栏、导航栏背景颜色为透明，文字颜色为黑色；应用窗口调用`setWindowLayoutFullScreen`接口，设置为true表示由组件模块控制忽略状态栏、导航栏的沉浸式全屏布局，设置为false表示由组件模块控制避让状态栏、导航栏的非沉浸式全屏布局。

> **说明：**
>
> 当前沉浸式界面开发仅支持窗口级别的配置，暂不支持Page级别的配置。若有Page级别切换的需要，可以在页面生命周期开始，例如onPageShow中设置沉浸模式，然后在页面退出，例如onPageHide中恢复默认设置来实现。

### 开发步骤

1. 获取应用主窗口。

   通过`getMainWindow`接口获取应用主窗口。

2. 实现沉浸式效果。有以下两种方式：

   - 方式一：应用主窗口为全屏窗口时，调用`setWindowSystemBarEnabled`接口，设置导航栏、状态栏不显示，从而达到沉浸式效果。

   - 方式二：调用`setWindowLayoutFullScreen`接口，设置应用主窗口为全屏布局；然后调用`setWindowSystemBarProperties`接口，设置导航栏、状态栏的透明度、背景/文字颜色以及高亮图标等属性，使之保持与主窗口显示协调一致，从而达到沉浸式效果。

3. 加载显示沉浸式窗口的具体内容。

   通过`loadContent`接口加载沉浸式窗口的具体内容。

```cangjie
package ohos_app_cangjie_entry

internal import kit.AbilityKit.*
internal import kit.ArkUI.*

class MainAbility <: UIAbility {
    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        // 1.获取应用主窗口。
        let mainWindow: Window = windowStage.getMainWindow()
        // 2.实现沉浸式效果。方式一：设置导航栏、状态栏不显示。
        mainWindow.setWindowSystemBarEnabled([])
        // 2.实现沉浸式效果。方式二：设置窗口为全屏布局，配合设置导航栏、状态栏的透明度、背景/文字颜色及高亮图标等属性，与主窗口显示保持协调一致。
        mainWindow.setWindowLayoutFullScreen(true)
        let sysBarProps: SystemBarProperties = SystemBarProperties(
                                                statusBarColor: "#ff00ff", 
                                                navigationBarColor: "#00ff00", 
                                                statusBarContentColor: "#ffffff",
                                                navigationBarContentColor: "#ffffff")
        mainWindow.setWindowSystemBarProperties(sysBarProps)
        // 3.为沉浸式窗口加载对应的目标页面。
        windowStage.loadContent("EntryView")
    }
}
```

## 设置悬浮窗

悬浮窗可以在已有的任务基础上，创建一个始终在前台显示的窗口。即使创建悬浮窗的任务退至后台，悬浮窗仍然可以在前台显示。通常悬浮窗位于所有应用窗口之上，开发者可以创建悬浮窗，并对悬浮窗进行属性设置等操作。

### 开发步骤

**前提条件：** 创建`WindowType.TypeFloat`即悬浮窗类型的窗口，需要申请`ohos.permission.SYSTEM_FLOAT_WINDOW`权限，配置方式请参见[选择申请权限的方式](../security/AccessToken/cj-determine-application-mode.md)。

1. 创建悬浮窗。

   通过`createWindow`接口创建悬浮窗类型的窗口。

2. 对悬浮窗进行属性设置等操作。

   悬浮窗窗口创建成功后，可以改变其大小、位置等，还可以根据应用需要设置悬浮窗背景色、亮度等属性。

3. 加载显示悬浮窗的具体内容。

   通过`showWindow`接口加载显示悬浮窗的具体内容。

4. 销毁悬浮窗。

   当不再需要悬浮窗时，可根据具体实现逻辑，使用`destroyWindow`接口销毁悬浮窗。

```cangjie
package ohos_app_cangjie_entry

internal import kit.AbilityKit.*
internal import kit.ArkUI.*

class MainAbility <: UIAbility {
    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        // 1.创建悬浮窗。
        let config: Configuration = Configuration(
            name: "floatWindow", windowType: WindowType.TypeFloat, ctx: this.context
        )
        let windowClass: Window = createWindow(config)
        // 2.悬浮窗窗口创建成功后，设置悬浮窗的位置、大小及相关属性等。
        windowClass.moveWindowTo(300, 300)
        windowClass.resize(500, 500)
        // 3.显示悬浮窗。
        windowClass.showWindow()
        // 4.销毁悬浮窗。当不再需要悬浮窗时，可根据具体实现逻辑，使用destroy对其进行销毁。
        windowClass.destroyWindow()
    }
}
```