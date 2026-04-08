# Environment：设备环境查询

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

开发者如果需要应用程序运行的设备的环境参数，以此来作出不同的场景判断，比如多语言，深浅色模式等，需要用到Environment设备环境查询。

Environment是ArkUI框架在应用程序启动时创建的单例对象。它为[AppStorage](./cj-appstorage.md)提供了一系列描述应用程序运行状态的属性。Environment的所有属性都是不可变的（即应用不可写入），所有的属性都是简单类型。

Environment提供了读取系统某些环境变量的能力，具体见[Environment内置参数](#environment内置参数)，并将其值写入AppStorage里，所以开发者需要通过AppStorage才能获取环境变量的值。

在阅读本文档前，建议提前阅读：[AppStorage](./cj-appstorage.md)。

## Environment内置参数

|键|数据类型|描述|
|:---|:---|:---|
|accessibilityEnabled|Bool|获取无障碍屏幕读取是否启用。|
|colorMode|[ColorMode](../../reference/arkui-cj/cj-state-rendering-appstatemanagement.md#enum-colormode)|色彩模型类型：选项为ColorMode.Light: 浅色，ColorMode.Dark: 深色。|
|fontScale|Float64|字体大小比例。开发者需要配置configuration，设置fontSizeScale为"followSystem"，具体配置步骤可参考[configuration](../../cj-start/basic-knowledge/cj-app-configuration-file.md#configuration标签)使fontScale跟随系统变化。<br>初始值跟随系统默认参数。|
|fontWeightScale|Float64|字体粗细程度。在不同的系统或者机型中，fontWeightScale的取值范围可能会有所不同。<br>初始值跟随系统默认参数。|
|layoutDirection|[LayoutDirection](../../reference/arkui-cj/cj-state-rendering-appstatemanagement.md#enum-layoutdirection)|布局方向类型：包括LayoutDirection.Ltr: 从左到右，LayoutDirection.Rtl: 从右到左。|
|languageCode|String|当前系统语言值，取值必须为小写字母（例如：zh）。<br>初始值跟随系统默认参数。|

## 使用场景

### 从UI中访问Environment参数

- 使用Environment.[envProp](../../reference/arkui-cj/cj-state-rendering-appstatemanagement.md#static-func-envproptstring-t)将设备运行的环境变量存入AppStorage中。

    ```cangjie
    // 将设备的语言code存入AppStorage，默认值为en
    Environment.envProp<String>("languageCode", "en")
    ```

- 在自定义组件中通过@StorageProp获取languageCode的值。

    ```cangjie
    @StorageProp["languageCode"] let languageCode: String = "en"
    ```

设备环境到Component的更新链：Environment --> AppStorage --> Component。

> **说明：**
>
> @StorageProp关联的环境参数可以在本地更改，但不能同步回AppStorage中，因为应用对环境变量参数是不可写的，只能在Environment中查询。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    let SysLanguageCode = Environment.envProp<String>("languageCode", "en")
    @StorageProp["languageCode"]
    let languageCode: String = "en"
    func build() {
        Row() {
            Column() {
                // 输出当前设备的languageCode
                Text(this.languageCode)
            }
        }
    }
}
```

### 应用逻辑使用Environment

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class EntryView {
    // 使用Environment.EnvProp将设备运行languageCode存入AppStorage中；
    let SysLanguageCode = Environment.envProp<String>("languageCode", "en")
    // 从AppStorage获取单向绑定的languageCode的变量
    let lang: ObservedProperty<String> = AppStorage.property<String>('languageCode').getOrThrow()
    func build() {
        Row() {
            Column() {
                Button("lang")
                .onClick({
                    evt =>
                        if (lang.get()=='zh') {
                            Hilog.info(0, "Chinese", "你好")
                        } else {
                            Hilog.info(0, "En", "Hello")
                        }

                })
            }
        }
    }
}
```
