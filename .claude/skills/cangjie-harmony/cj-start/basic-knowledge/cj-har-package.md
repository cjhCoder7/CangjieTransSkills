# HAR

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

HAR（Harmony Archive）是静态共享包，可以包含代码、C++库、资源和配置文件。通过 HAR 可在多个模块或工程间共享仓颉组件与资源。

## 使用场景

- 支持应用内共享，也可以作为二方库（SDK）、三方库（SDK）发布后供其他应用使用。

- 作为二方库（SDK），发布到[OHPM私仓](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-ohpm-repo)，供公司内部其他应用使用。

- 作为三方库（SDK），发布到[OHPM中心仓](https://ohpm.openharmony.cn/)，供其他应用使用。

## 约束限制

- HAR不支持在设备上单独安装或运行，只能作为应用模块的依赖项被引用。

- HAR不支持在配置文件中声明pages页面，但是可以包含pages页面，并通过Navigation跳转的方式进行跳转。

- HAR不支持引用AppScope目录中的资源。在编译构建时，AppScope中的内容不会打包到HAR中，因此会导致HAR资源引用失败。

- 多包（HAP）引用相同的HAR时，会造成多包间代码和资源的重复拷贝，从而导致应用包变大。

- HAR可以依赖其他HAR，但不支持循环依赖，也不支持依赖传递。

- HAP引用HAR时，在编译构建过程中系统会自动合并两者的权限配置。因此开发者无需在HAP和HAR中重复申请相同权限。

- 当集成使用仓颉二进制HAR时，须使用与该HAR编译所用SDK相同的版本进行编译。

- 当模块中有自定义宏并且需要给其他模块使用时，本模块和其他模块不支持编译成二进制HAR，需要编译成源码格式的仓颉HAR<!-- add link -->。

- 二进制HAR默认打包仓颉so和cjo产物，并且放在HAR包中libs/arm64-v8a/cjbins/package或libs/x86_64/cjbins/package包目录下；如果需要仓颉so产物平铺在libs/arm64-v8a或libs/x86_64目录下，例如在纯ArkTS HAP依赖二进制格式的仓颉HAR场景下，可以在仓颉HAR模块中设置flattenLibs配置项值为true。

> **说明：**
>
> 循环依赖：例如有三个HAR，HAR-A、HAR-B和HAR-C，循环依赖指HAR-A依赖HAR-B，HAR-B依赖HAR-C，HAR-C依赖HAR-A。
>
> 依赖传递：例如有三个HAR，HAR-A、HAR-B和HAR-C，依赖关系是HAR-A依赖HAR-B，HAR-B依赖HAR-C。不支持传递依赖指HAR-A可以使用HAR-B的方法和组件，但是HAR-A不能直接使用HAR-C的方法和组件。

## 创建

开发者可以通过DevEco Studio创建一个HAR模块。

## 开发

介绍如何导出HAR的仓颉组件、接口、资源，供其他应用或当前应用的其他模块引用。

HAR需要导出的接口等，可以使用`public`修饰。

> **说明：**
>
> HAR在和宿主应用一起编译时，会把HAR的代码直接编译到宿主应用中，HAR包是一个编译中间态产物，不是最终的运行实体。运行时，HAR运行的身份信息是其宿主应用，系统会以宿主应用的版本做行为区分。如果需要在HAR中区分宿主应用的版本做不同的行为区分，可以调用[getBundleInfoForSelf](../../reference/AbilityKit/cj-apis-bundle_manager.md#static-func-getbundleinfoforselfint32)接口，获取宿主应用的targetVersion，然后根据不同的targetVersion，做不同的逻辑处理。

### 导出仓颉组件

通过`public`导出仓颉组件，示例如下：

<!-- compile -->

```cangjie
// library/src/main/cangjie/mainPage.cj
package ohos_app_cangjie_library

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.resource.__GenerateResource__

@Component
public class MainPage {
    @State
    var message: String = "Hello"

    public func build() {
        Column() {
            Row() {
                Text(this.message).fontSize(32).fontWeight(FontWeight.Bold)
            }.margin(32).height(56).width(624)
            Flex(justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center, alignContent: FlexAlign.Center, direction: FlexDirection.Row, wrap: FlexWrap.NoWrap) {
                    Column() {
                        Image(@r(app.media.pic_empty)).width(33.percent)
                        Text(@r(app.string.empty)).fontSize(14).fontColor(@r(app.color.text_color))
                    }
            }.width(100.percent).height(90.percent)
        }.width(100.percent).height(100.percent).backgroundColor(@r(app.color.page_background))
    }
}
```

### 导出类和方法

通过`public`导出类和方法，支持导出多个类和方法，示例如下所示：

<!-- compile -->

```cangjie
// library/src/main/cangjie/classFunc.cj
package ohos_app_cangjie_library

public class Log {
    public static func info(msg: String) {
        msg
    }
}

public func harFunc() {
  return 'har func'
}

public func harFunc2() {
  return 'har func2'
}
```

### 导出资源

在编译构建HAP时，DevEco Studio会从HAP模块及依赖的模块中收集资源文件，如果不同模块下的资源文件出现重名冲突时，DevEco Studio会按照以下优先级进行覆盖（优先级由高到低）：

- AppScope（仅Stage模型支持）。

- HAP包自身模块。

- 依赖的HAR模块，如果依赖的多个HAR之间有资源冲突，会按照工程oh-package.json5中dependencies下的依赖顺序进行覆盖，依赖顺序在前的优先级较高。例如下方示例中dayjs和lottie中包含同名文件时，会优先使用dayjs中的资源。

> **说明：**
>
> 如果在AppScope、HAP模块或HAR模块的国际化目录中配置了资源，在相同的国际化限定词下，合并的优先级也遵循上述规则。同时，国际化限定词中配置的优先级高于在base中的配置。例如，在AppScope的base中配置了资源字段，在HAR模块的en_US中配置了同样的资源字段，则在en_US的使用场景中，会更优先使用HAR模块中配置的资源字段。

```json5
// oh-package.json5
{
    "dependencies": {
        "dayjs": "^1.10.4",
        "lottie": "^2.0.0"
    }
}
```

## 使用

介绍如何配置HAR依赖，并引用HAR的仓颉组件、接口、资源。

引用HAR前，需要先配置对HAR的依赖，详见[引用HAR文件和资源](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-har-import)。

### 引用HAR的仓颉组件

HAR的依赖配置成功后，可以引用HAR的仓颉组件。通过`import`引入HAR导出的仓颉组件，示例如下所示：

<!-- compile -->

```cangjie
// entry/src/main/cangjie/index.cj
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos_app_cangjie_library.MainPage

@Entry
@Component
class EntryView {
    func build() {
        Row {
           // 引用HAR的仓颉组件
           MainPage()
        }.height(100.percent)
    }
}
```

### 引用HAR的类和方法

通过`import`引用HAR导出的类和方法，示例如下所示：

<!-- compile -->

```cangjie
// entry/src/main/cangjie/index2.cj
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos_app_cangjie_library.Log
import ohos_app_cangjie_library.harFunc

@Entry
@Component
class EntryView2 {
    @State
    var message: String = "Hello World"

    func build() {
        Row {
            Column {
                Text(this.message)
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
                    .onClick ({
                        evt =>
                        // 引用HAR的类和方法
                        Log.info("har msg")
                        this.message = "func return: ${harFunc()}"
                    })
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

### 引用HAR的资源

通过`@r`引用HAR中的资源，例如在HAR模块的`src/main/resources`里添加字符串资源（在string.json中定义，name：hello_har）和图片资源（icon_har.png），然后在Entry模块中引用该字符串和图片资源的示例如下所示：

<!-- compile -->

```cangjie
// entry/src/main/cangjie/index3.cj
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.resource.__GenerateResource__

@Entry
@Component
class EntryView3 {
    @State
    var message: String = "Hello World"

    func build() {
        Row {
            Column {
                // 引用HAR的字符串资源
                Text(@r(app.string.hello_har))
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
                    .onClick ({
                        evt => this.message = "Hello Cangjie"
                    })
                List() {
                    ListItem() {
                        // 引用HAR的图片资源
                        Image(@r(app.media.icon_har)).id('iconHar').borderRadius(48.px)
                    }.margin(5.percent).width(312.px)
                }.alignListItem(ListItemAlign.Center)
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

## 编译

HAR可以作为二方库和三方库提供给其他应用使用。

## 发布

详见[发布HAR](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-har-publish)。
