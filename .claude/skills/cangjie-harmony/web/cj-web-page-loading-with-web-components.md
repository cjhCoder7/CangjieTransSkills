# 使用Web组件加载页面

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

页面加载是Web组件的基本功能。根据页面加载数据来源可以分为三种常用场景，包括加载网络页面、加载本地页面、加载HTML格式的富文本数据。

页面加载过程中，若涉及网络资源获取，请在module.json5中配置网络访问权限，添加方法请参见[在配置文件中声明权限](../security/AccessToken/cj-declare-permissions.md)。

```json
"requestPermissions":[
  {
    "name" : "ohos.permission.INTERNET"
  }
]
```

## 加载网络页面

开发者可以在Web组件创建时，指定默认加载的网络页面。[Web组件](../reference/arkui-cj/cj-web-web.md)的第一个参数变量src不能通过状态变量（例如：@State）动态更改地址。

在下面的示例中，在Web组件加载完“www.example.com”页面后，开发者可通过loadUrl接口将此Web组件显示页面变更为“www.example1.com”。

<!-- compile -->

```cangjie
// index.cj
import ohos.arkui.state_macro_manage.*
import ohos.web.webview.WebviewController
import kit.ArkUI.{Web, Button}
import ohos.business_exception.*
import kit.PerformanceAnalysisKit.Hilog

func loggerError(str: String) {
    Hilog.error(0, "CangjieTest", str)
}

@Entry
@Component
class EntryView {
    let webController = WebviewController()

    func build() {
        Column {
            Button("loadUrl").onClick ({ evt =>
                try {
                    // 点击按钮时，通过loadUrl，跳转到www.example1.com
                    webController.loadUrl('www.example1.com')
                } catch (e: BusinessException) {
                    loggerError("loadUrl ErrorCode: ${e.code},  Message: ${e.message}")
                }
            })
            // 组件创建时，加载www.example.com
            Web(src: 'www.example.com', controller: webController)
        }
    }
}
```

## 加载本地页面

在下面的示例中展示加载本地页面文件的方法：

将本地页面文件放在应用的rawfile目录下，开发者可以在Web组件创建的时候指定默认加载的本地页面。

加载本地html文件时引用本地css样式文件可以通过下面方法实现。

```html
<link rel="stylesheet" href="resource://rawfile/xxx.css">
<link rel="stylesheet" href="file:///data/storage/el2/base/haps/entry/cache/xxx.css">// 加载沙箱路径下的本地css文件。
```

- 将资源文件放置在应用的resources/rawfile目录下：

    **图1** 资源文件路径

    ![resource-path](figures/web-resource-path.png) <!--ToBeReviewed-->

- 应用侧代码：

    <!-- compile -->

    ```cangjie
    // index.cj
    import ohos.arkui.state_macro_manage.*
    import kit.LocalizationKit.*
    import ohos.web.webview.WebviewController
    import ohos.business_exception.*
    import kit.ArkUI.{Web, Button}
    import ohos.resource.__GenerateResource__
    import kit.PerformanceAnalysisKit.Hilog

    func loggerError(str: String) {
        Hilog.error(0, "CangjieTest", str)
    }

    @Entry
    @Component
    class EntryView {
        let webController = WebviewController()

        func build() {
            Column {
                Button("loadUrl").onClick ({ evt =>
                    try {
                        // 点击按钮时，通过loadUrl，跳转到local1.html
                        webController.loadUrl(@rawfile("local1.html"))
                    } catch (e: BusinessException) {
                        loggerError("loadUrl ErrorCode: ${e.code},  Message: ${e.message}")
                    }
                })
                // 组件创建时，通过$rawfile加载本地文件local.html
                Web(src: @rawfile("local.html"), controller: webController)
            }
        }
    }
    ```

- local.html页面代码：

    ```html
    <!-- resources/rawfile/local.html -->
    <!DOCTYPE html>
    <html>
        <body>
        <p>Hello World</p>
        </body>
    </html>
    ```

- local1.html页面代码：

    ```html
    <!-- resources/rawfile/local1.html -->
    <!DOCTYPE html>
    <html>
        <body>
        <p>This is local1 page</p>
        </body>
    </html>
    ```

加载沙箱路径下的本地页面文件示例如下：

1. 通过构造的单例对象GlobalContext获取沙箱路径，需要开启应用中文件系统的访问[fileAccess](../reference/arkui-cj/cj-web-web.md#func-fileaccessbool)权限。

    <!-- compile -->

    ```cangjie
    // global_context.cj
    import std.collection.HashMap

    public class GlobalContext {
        private GlobalContext(){}
        private static var instance: GlobalContext = GlobalContext()
        private let _objects = HashMap<String, String>()

        static func getInstance(): GlobalContext {
          return GlobalContext.instance
        }

        func getValue(key: String): String {
            return match (this._objects.get(key)) {
                case Some(v) => v
                case _ => ""
            }
        }

        func setValue(key: String, value: String): Unit {
          this._objects.add(key, value)
        }
    }
    ```

    <!-- compile -->

    ```cangjie
    // index.cj
    import ohos.arkui.state_macro_manage.*
    import ohos.web.webview.WebviewController
    import kit.ArkUI.Web

    @Entry
    @Component
    class EntryView {
        let webController = WebviewController()
        let url = 'file://' + GlobalContext.getInstance().getValue("filesDir") + '/index.html'

        func build() {
            Column {
                Web(src: url, controller: webController)
                    .fileAccess(true)
            }
        }
    }
    ```

    加载的html文件。

    ```html
    <!-- resources/rawfile/index.html -->
    <!DOCTYPE html>
    <html>
        <body>
            <p>Hello World</p>
        </body>
    </html>
    ```

2. 修改main_ability.cj。

   以filesDir为例，获取沙箱路径。

    <!-- compile -->

   ```cangjie
    // main_ability.cj
    import kit.PerformanceAnalysisKit.Hilog

    func loggerInfo(str: String) {
        Hilog.info(0, "CangjieTest", str)
    }

    class MainAbility <: UIAbility {
        public init() {
            super()
            registerSelf()
        }

        public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
            loggerInfo("MainAbility OnCreated.${want.abilityName}")
            // 通过在GlobalContext对象上绑定filesDir，可以实现Ability组件与UI之间的数据同步。
            GlobalContext.getInstance().setValue("filesDir", this.context.filesDir)
            match (launchParam.launchReason) {
                case LaunchReason.StartAbility => loggerInfo("StartAbility")
                case _ => ()
            }
        }

        public override func onWindowStageCreate(windowStage: WindowStage): Unit {
            loggerInfo("MainAbility onWindowStageCreate.")
            windowStage.loadContent("EntryView")
        }
        // ...
    }
   ```

## 加载HTML格式的文本数据

Web组件可以通过data url方式直接加载HTML字符串。

<!-- compile -->

```cangjie
// index.cj
import ohos.arkui.state_macro_manage.*
import ohos.web.webview.WebviewController
import kit.ArkUI.Web

@Entry
@Component
class EntryView {
    let webController = WebviewController()
    let htmlStr: String = "data:text/html, <html><body bgcolor=\"white\">Source:<pre>source</pre></body></html>"

    func build() {
        Column {
            // 组件创建时，加载www.example.com
            Web(src: htmlStr, controller: webController)
        }
    }
}
```
