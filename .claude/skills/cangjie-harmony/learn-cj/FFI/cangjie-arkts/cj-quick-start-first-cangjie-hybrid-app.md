# 构建第一个仓颉与ArkTS混合应用

> **说明：**
>
> 为确保运行效果，本文以**DevEco Studio 5.0.2 Release** 和 **DevEco Studio-Cangjie Plugin 5.0.7.100 Beta1** 版本为例，点击[此处](https://developer.huawei.com/consumer/cn/download/)获取最新版本的下载链接。

本文档适用于对仓颉语言、ArkTS语言、UI框架等有基本概念的OpenHarmony应用开发者。通过构建一个简单的具有页面跳转/返回功能的仓颉与ArkTS混合开发的应用（如下图所示），快速了解工程目录的主要文件，熟悉混合应用的开发流程。

![hybridExampleRunning](../../figures/hybridExampleRunning.png)

## 创建仓颉与ArkTS混合工程

1. 若首次打开**DevEco Studio**，请单击**Create Project**创建工程。如果已经打开了一个工程，请在菜单栏选择**File** > **New** > **Create Project**来创建一个新工程。
2. 选择**Application**应用开发，选择模板 **[Cangjie] Hybrid Ability**，单击**Next**进行下一步配置。

   > **注意：**
   >
   > 若开发者需要进行纯仓颉工程开发，请选择 **[Cangjie] Empty Ability**模块。

   ![buildChooseCangjieHybridTemplate](../../figures/buildChooseCangjieHybridTemplate.png)

3. 进入配置工程界面，参数保持默认设置即可。

   > **注意：**
   >
   > 仓颉混合页面支持的最低Compatible SDK版本为5.0.1(13)。

   ![buildConfigCangjieHybridTyplate](../../figures/buildConfigCangjieHybridTemplate.png)

4. 单击**Finish**，DevEco Studio会自动生成示例代码和相关资源，等待工程创建完成。

## 仓颉与ArkTS混合工程目录结构

仓颉与ArkTS混合工程目录结构如下所示。

```text
Project_name
├── .hvigor
├── .idea
├── AppScope
│    ├── resources
│    └── app.json5
├── entry
│    ├── build
│    ├── har
│    │    └── CJHyAPIRegister-v1.0.1.har
│    ├── libs
│    ├── oh_modules
│    ├── src
│    │    ├── main
│    │    │    ├── cangjie
│    │    │    │    ├── types
│    │    │    │    │    └── libohos_app_cangjie_entry
│    │    │    │    │          ├── Index.d.ts
│    │    │    │    │          └── oh-package.json5
│    │    │    │    └── index.cj
│    │    │    ├── ets
│    │    │    │    ├── entryability
│    │    │    │    ├── entrybackupability
│    │    │    │    └── pages
│    │    │    ├── resources
│    │    │    └── module.json5
│    │    ├── mock
│    │    ├── ohosTest
│    │    └── test
│    ├── build-profile.json5
│    ├── cjpm.toml
│    ├── hvigorfile.ts
│    ├── obfuscation-rules.txt
│    ├── oh-package.json5
│    └── oh-package-lock.json5
├── hvigor
│    ├── hvigor-config.json5
├── oh_modules
├── build-profile.json5
├── code-linter.json5
├── hvigorfile.ts
├── local.properties
├── oh-package.json5
└── oh-package-lock.json5
```

其中关键文件信息如下：

- **AppScope > app.json5**：应用的全局配置信息。
- **entry**：OpenHarmony工程模块，编译构建生成一个HAP包。
    - **src > har**：用于存放仓颉与ArkTS互操作依赖的HAR模块。
    - **src > main > cangjie**：用于存放仓颉源码。
    - **src > main > cangjie > types**: 仓颉与ArkTS互操作的依赖库。
    - **src > main > ets**：用于存放ArkTS源码。
    - **src > main > ets > entryability**：应用/服务的入口。
    - **src > main > ets > entrybackupability**：应用提供扩展的备份恢复能力。
    - **src > main > ets > pages**：应用/服务包含的页面。
    - **src > main > resources**：用于存放应用/服务所用到的资源文件，如图形、多媒体、字符串、布局文件等。
    - **src > main > module.json5**：模块配置文件。主要包含 HAP 的配置信息、应用/服务在具体设备上的配置信息以及应用/服务的全局配置信息。
    - **build-profile.json5**：当前的模块信息 、编译信息配置项，包括buildOption、targets配置等。
    - **cjpm.toml**：仓颉的包管理配置文件，包括编译选项、依赖管理等。
    - **hvigorfile.ts**：模块级编译构建任务脚本。
    - **oh-package.json5**：用来描述包名、版本、入口文件（类型声明文件）和依赖项等信息。
- **hvigor**：用于存放当前工程使用的 hvigor。
    - **hvigor-config.json5**：指定工程全局使用的 hvigor 以及 hvigor 参数配置。
- **oh_modules**：用于存放三方库依赖信息，包含应用/服务所依赖的第三方库文件。
- **build-profile.json5**：应用级配置信息，包括签名、产品配置等。
- **hvigorfile.ts**：应用级编译构建任务脚本。
- **oh-package.json5**：主要用来描述全局配置，如：依赖覆盖（overrides）、依赖关系重写（overrideDependencyMap）和参数化配置（parameterFile）等。

## 构建第一个页面（纯ArkTS页面）

1. 使用文本组件

   工程同步完成后，在**Project**创建，打开**entry > src > main > ets > pages**，打开**Index.ets**文件，进行页面的编写。

   针对本文中使用文本/按钮来实现页面跳转/返回的应用场景，页面均使用Row和Column组件来组建布局。对于更多复杂元素对齐的场景，可选择使用RelativeContainer组件进行布局。

   **Index.ets**文件的示例如下：

   ```typescript
   @Entry
   @Component
   struct Index {
     @State message: string = 'Hello World';

     build() {
       RelativeContainer() {
         Text(this.message)
           .fontSize(40)
           .fontWeight(FontWeight.Bold)
           .alignRules({
             center: { anchor: '__container__', align: VerticalAlign.Center },
             middle: { anchor: '__container__', align: HorizontalAlign.Center }
           })
       }
       .height('100%')
       .width('100%')
     }
   }
   ```

2. 添加按钮

   在默认页面基础上，添加一个Button组件，作为按钮响应用户单击，从而实现跳转到另一个页面。添加完成后“Index.ets”文件的示例如下：

   ```typescript
   // Index.ets
   @Entry
   @Component
   struct Index {
     @State message: string = 'Hello World'

     build() {
       Row() {
         Column() {
           Text(this.message)
             .fontSize(50)
             .fontWeight(FontWeight.Bold)
           // 添加按钮，以响应用户单击
           Button() {
             Text('Next')
               .fontSize(30)
               .fontWeight(FontWeight.Bold)
           }
           .type(ButtonType.Capsule)
           .margin({
             top: 20
           })
           .backgroundColor('#0D9FFB')
           .width('40%')
           .height('5%')
         }
         .width('100%')
       }
       .height('100%')
     }
   }
   ```

## 构建第二个页面（ArkTS与仓颉混合页面）

> **说明：**
>
> 在仓颉与ArkTS混合开发场景中，仓颉页面不是一个真正意义上具有完整生命周期的页面，只能以组件的形式嵌入到ArkTS页面中，因此需要在ArkTS侧提供一个@Entry的页面作为容器，来加载仓颉页面组件。
>
> 仓颉与ArkTS混合UI的详细内容请参见 [混合开发](../../../arkui-cj/cj-appendix-hybrid.md)。

1. 创建仓颉页面。

    - 在**Project**窗口，打开**entry > src > main**，右键单击**cangjie**文件夹，选择**New -> Cangjie HybridComponent File**，**Component name**命名为**Second**，**Language** 中选中**Cangjie**选项，**Type** 中选中**With ArkTS Wrapper**选项,如下图所示：

       ![inputPageName](../../figures/inputPageName.png)

    - 单击**OK**，可以看到文件目录结构如下：

       ```text
        entry
        ├── .preview
        ├── build
        ├── libs
        ├── oh_modules
        └── src
             └── main
                  ├── cangjie
                  │    ├── types
                  │    ├── index.cj
                  │    └── second.cj
                  ├── ets
                  │    ├── entryability
                  │    ├── entrybackupability
                  │    └── pages
                  │         ├── Index.ets
                  │         └── second.ets
                  ├── resources
                  └── module.json5
       ```

       可以看到，在**src > main > cangjie**目录中会创建一个**second.cj**的仓颉源码文件，并且在**src > main > ets > pages**文件夹下自动生成**second.ets**的ArkTS侧仓颉页面容器。

    - 参考第一个ArkTS页面的样式，在仓颉页面中添加Text组件、Button组件等，并设置其样式。**second.cj**文件的示例如下：

       <!-- compile -->

       ```cangjie
       // second.cj
       package ohos_app_cangjie_entry

       import ohos.base.*
       import ohos.arkui.component.*
       import ohos.arkui.state_macro_manage.*
       import ohos.arkui.state_management.*

       @HybridComponentEntry
       @Component
       class Second {
           @State var msg: String = "Hello Cangjie"

           public func build() {
               Row() {
                   Column() {
                       Text(this.msg)
                           .fontSize(50)
                           .fontWeight(FontWeight.Bold)

                       Button() {
                           Text("Back")
                               .fontSize(30)
                               .fontWeight(FontWeight.Bold)
                       }
                       .shape(ButtonType.Capsule)
                       .margin(top: 20)
                       .backgroundColor(Color(0x0D9FFB))
                       .width(40.percent)
                       .height(5.percent)
                   }
                   .width(100.percent)
               }
               .height(100.percent)
           }
       }
       ```

2. 创建ArkTS侧仓颉页面的容器。

    - 在 ArkTS 页面中嵌入仓颉页面。**src > main > ets > pages > second.ets**文件的示例如下：

       ```typescript
       // second.ets
       // 在 ArkTS 页面中嵌入仓颉页面
       import { CJHybridComponent } from '@cangjie/cjhybridcomponent';

       @Entry
       @Component
       struct Second {
         build() {
           Row() {
             // 通过 CJHybridComponent 接口嵌入仓颉页面
             CJHybridComponent({
               library: "ohos_app_cangjie_entry", // 仓颉页面所在的 package 名字
               component: "Second"                // 仓颉页面对应的 class 名字
             })
           }
           .height('100%')
           .width('100%')
         }
       }
       ```

    > **说明：**
    >
    > 开发者需要自行开发ArkTS代码作为容器来嵌入仓颉页面。

3. 配置第二个页面的路由。

- 在**Project**窗口，打开**entry > src > main > resources > base > profile**，在main_pages.json文件中的"src"下已经自动生成第二个页面的路由"pages/second"。示例如下：

   ```json
   {
     "src": [
       "pages/Index",
       "pages/second"
     ]
   }
   ```

## 实现页面间的跳转

页面间的导航可以通过页面路由router来实现。页面路由router根据页面url找到目标页面，从而实现跳转。使用页面路由请导入router模块。

1. 第一个Arkts页面跳转到第二个ArkTS与仓颉混合页面。

   在第一个Arkts页面中，跳转按钮绑定onClick事件，单击按钮时跳转到第二页。**Index.ets**文件的示例如下：

   ```typescript
   // Index.ets
   // 导入页面路由模块
   import { router } from '@kit.ArkUI';
   import { BusinessError } from '@kit.BasicServicesKit';

   @Entry
   @Component
   struct Index {
     @State message: string = 'Hello World'

     build() {
       Row() {
         Column() {
           Text(this.message)
             .fontSize(50)
             .fontWeight(FontWeight.Bold)
           // 添加按钮，以响应用户单击
           Button() {
             Text('Next')
               .fontSize(30)
               .fontWeight(FontWeight.Bold)
           }
           .type(ButtonType.Capsule)
           .margin({
             top: 20
           })
           .backgroundColor('#0D9FFB')
           .width('40%')
           .height('5%')
           // 跳转按钮绑定onClick事件，单击时跳转到第二页
           .onClick(() => {
             console.info(`Succeeded in clicking the 'Next' button.`)
             // 跳转到第二页
             router.pushUrl({ url: 'pages/second' }).then(() => {
               console.info('Succeeded in jumping to the second page.')
             }).catch((err: BusinessError) => {
               console.error(`Failed to jump to the second page. Code is ${err.code}, message is $   {err.message}`)
             })
           })
         }
         .width('100%')
       }
       .height('100%')
     }
   }
   ```

2. 第二个页面返回到第一个页面。

   在第二个ArkTS与仓颉混合的页面中，需要在仓颉Button组件上绑定onClick事件，单击按钮时返回到第一个ArkTS页面。但是，由于**仓颉与ArkTS的页面路由router并不互通**，在混合页面中如果希望在仓颉侧路由到一个ArkTS页面，需要将**ArkTS侧的路由跳转函数**通过互操作能力注册给仓颉进行调用。

   > **说明：**
   >
   > 仓颉与ArkTS语言互操作支持以下两种开发范式：
   >
   > 使用仓颉-ArkTS声明式互操作宏：可以自动生成互操作胶水层代码，**使用起来更简单，推荐使用**。下方示例即使用此方式。
   >
   > 使用仓颉-ArkTS互操作库：提供更底层的动态类型接口。

- 仓颉提供注册和注销ArkTS函数的相关接口。在**Project**窗口，单击**entry > src > main > cangjie**，打开**index.cj**文件，编写仓颉与ArkTS互操作相关的代码，编写完成后示例如下：

   <!-- compile -->

   ```cangjie
   // index.cj
   package ohos_app_cangjie_entry

   import ohos.base.*
   import ohos.ark_interop.*
   import ohos.ark_interop_macro.*
   import ohos.hilog.Hilog
   import std.collection.*

   // 定义一个全局 HashMap，用于保存ArkTS注册的函数
   // 作为简单演示，此处默认所有ArkTS的回调函数均为无参、无返回值
   public let globalJSFunction = HashMap<String, ()->Unit>()

   @Interop[ArkTS]
   public func registerJSFunc(name: String, fn: ()->Unit): Unit {
       // 如果已经注册过，则打印错误信息，并直接返回
       if (globalJSFunction.contains(name)) {
           Hilog.error(1, "info", "registerJSFunc failed(err: func ${name} already exists)")
           return
       }
       // 保存到 HashMap 中
       globalJSFunction.add(name, fn)
   }

   @Interop[ArkTS]
   public func unregisterJSFunc(name: String): Unit {
       globalJSFunction.remove(name)
   }
   ```

- 自动生成仓颉与ArkTS互操作接口文件（.d.ts文件）。打开上述**index.cj**文件，在文件编辑界面中右键单击选择**Generate... > Cangjie-ArkTS Interop API**，则会在**entry > src > main > cangjie > types > libohos_app_cangjie_entry**目录下的**Index.d.ts**文件中自动生成仓颉暴露给ArkTS的.d.ts接口声明，目录结构如下所示：

    ```text
    entry
    ├── .preview
    ├── build
    ├── har
    ├── libs
    ├── oh_modules
    └── src
         └── main
              ├── cangjie
              │    ├── ark_interop_api
              │    ├── types
              │    │    └── libohos_app_cangjie_entry
              │    │         │── Index.d.ts
              │    │         └── oh-package.json5
              │    ├── index.cj
              │    └── second.cj
              ├── ets
              │    ├── entryability
              │    ├── entrybackupability
              │    └── pages
              │         ├── Index.ets
              │         └── second.ets
              ├── resources
              └── module.json5
    ```

   接口声明如下所示：

   ```typescript
   // Index.d.ts
   export declare function registerJSFunc(name: string, fn: () => void): void
   export declare function unregisterJSFunc(name: string): void
   ```

   > **说明：**
   >
   > 创建Cangjie Hybrid Ability混合工程之后，在模块下**entry > oh-package.json5**文件中会自动将**libohos_app_cangjie_entry**库添加到**dependencies**字段中作为依赖。
   >
   > **entry > oh-package.json5**文件如下所示：
   >
   > ```json
   > "dependencies": {
   >    "libohos_app_cangjie_entry.so": "file:src/main/cangjie/types/libohos_app_cangjie_entry",
   >    "@cangjie/cjhybridcomponent": "1.0.0",
   >    "libark_interop_api.so": "file:src/main/cangjie/ark_interop_api"
   > }
   >    ```

- 仓颉暴露给ArkTS的.d.ts接口声明生成后，可以直接在ArkTS文件中引入.d.ts文件中接口的依赖。将ArkTS页面路由的函数注册到仓颉侧。**second.ets**文件的示例如下：

   ```typescript
   // second.ets
   import { CJHybridComponent } from '@cangjie/cjhybridcomponent';

   // 导入ArkTS页面路由模块
   import { router } from '@kit.ArkUI';
   import { BusinessError } from '@kit.BasicServicesKit';

   // 导入 libohos_app_cangjie_entry.so 中的 registerJSFunc 和 unregisterJSFunc 接口
   import cjlib from 'libohos_app_cangjie_entry.so'

   @Entry
   @Component
   struct Second {
     aboutToAppear(): void {
       // 在页面出现之前，注册回调函数给仓颉侧
       cjlib.registerJSFunc('SecondPageRouterBack', () => {
         try {
           // 返回第一页
           router.back()
           console.info('Succeeded in returning to the first page.')
         } catch (err) {
           let code = (err as BusinessError).code;
           let message = (err as BusinessError).message;
           console.error(`Failed to return to the first page. Code is ${code}, message is $   {message}`)
         }
       })
     }

     aboutToDisappear(): void {
       // 在页面销毁之前，注销对应的回调函数
       cjlib.unregisterJSFunc('SecondPageRouterBack')
     }

     build() {
       Row() {
         // 通过 CJHybridComponent 嵌入仓颉页面组件
         CJHybridComponent({
           library: "ohos_app_cangjie_entry", // 仓颉页面组件所在的 package 名字
           component: "Second"      // 仓颉页面组件对应的 class 名字
         })
       }
       .height('100%')
       .width('100%')
     }
   }
   ```

- 在仓颉页面组件中，给仓颉Button按钮绑定onClick事件，单击按钮时，调用ArkTS注册过来的回调函数，返回第一页。**second.cj**文件的示例如下：

   <!-- compile -->

   ```cangjie
   // second.cj
   package ohos_app_cangjie_entry

   import ohos.base.*
   import ohos.arkui.component.*
   import ohos.arkui.state_macro_manage.*
   import ohos.arkui.state_management.*
   import ohos.hilog.Hilog

   @HybridComponentEntry
   @Component
   class Second {
       @State var msg: String = "Hello Cangjie"

       public func build() {
           Row() {
               Column() {
                   Text(this.msg)
                       .fontSize(50)
                       .fontWeight(FontWeight.Bold)

                   Button() {
                       Text("Back")
                           .fontSize(30)
                           .fontWeight(FontWeight.Bold)
                   }
                   .shape(ButtonType.Capsule)
                   .margin(top: 20)
                   .backgroundColor(Color(0x0D9FFB))
                   .width(40.percent)
                   .height(5.percent)
                   // 返回按钮绑定onClick事件，单击按钮时返回到第一页
                   .onClick ({ _ =>
                       Hilog.info(1, "info", "Succeeded in clicking the 'Back' button.")
                       let optFn = globalJSFunction.get("SecondPageRouterBack")
                       if (let Some(fn) <- optFn) {
                           fn() //调用 ArkTS 回调函数
                       } else {
                           Hilog.error(1, "info", "Failed to return to the first page. callback not exists")
                       }
                   })
               }
               .width(100.percent)
           }
           .height(100.percent)
       }
   }
   ```

## 使用真机或模拟器运行应用

### 使用本地真机

1. 将搭载OpenHarmony系统的真机与电脑连接。
2. 真机连接成功后，单击**File > Project Structure > Project > Signing Configs**界面勾选**Support OpenHarmony**和**Automatically generate signature**，单击界面提示的**Sign In**，使用用户账号登录。等待自动签名完成后，单击**OK**即可。如下图所示：

    ![buildSign](../../figures/buildSign.png)

3. 在编辑窗口右上角的工具栏，单击![runButton](../../figures/runButton.png)按钮运行。效果如下图所示：

    ![hybridExampleRunning](../../figures/hybridExampleRunning.png)

### 使用模拟器

仓颉语言编写的OpenHarmony应用/服务，支持在DevEco Studio提供的模拟器（Emulator）上运行。

1. 创建一个类型为Phone的模拟器设备，并在DevEco Studio右上角的设备列表中，选中该设备。

2. 仓颉工程默认编译架构为**arm64-v8a**，因此在使用**x86模拟器**时（当前开发环境为**Windows/x86_64**或**MacOS/x86_64**时），仓颉工程及三方库需要编译出x86_64版本的so，请在仓颉模块的**build-profile.json5**配置文件中，为**cangjieOptions/abiFilters**的值增加**x86_64**，具体编译配置如下：

    ```json
    "buildOption": { // 配置项目在构建过程中使用的相关配置
      "cangjieOptions": { // 仓颉相关配置
        "path": "./cjpm.toml", // cjpm配置文件路径，提供仓颉构建配置
        "abiFilters": ["arm64-v8a", "x86_64"] // 自定义仓颉编译架构，默认编译架构为arm64-v8a
      }
    }
    ```

3. 在编辑窗口右上角的工具栏，单击![runButton](../../figures/runButton.png)按钮运行。效果同使用真机运行。

恭喜您已经构建完成第一个仓颉与ArkTS混合应用。
