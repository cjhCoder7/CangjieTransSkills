# 设置深色模式

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

Web组件支持对前端页面进行深色模式配置。

- 通过[darkMode()](../reference/arkui-cj/cj-web-web.md#func-darkmodewebdarkmode)接口可以配置不同的深色模式，默认关闭。当深色模式开启时，Web将启用媒体查询prefers-color-scheme中网页所定义的深色样式，若网页未定义深色样式，则保持原状。如需开启强制深色模式，建议配合[forceDarkAccess()](../reference/arkui-cj/cj-web-web.md#func-forcedarkaccessbool)使用。[WebDarkMode.Off](../reference/arkui-cj/cj-common-types.md#enum-webdarkmode)模式表示关闭深色模式。[WebDarkMode.On](../reference/arkui-cj/cj-common-types.md#enum-webdarkmode)表示开启深色模式，并且深色模式跟随前端页面。[WebDarkMode.Auto](../reference/arkui-cj/cj-common-types.md#enum-webdarkmode)表示开启深色模式，并跟随系统。

    在下面的示例中，通过[darkMode()](../reference/arkui-cj/cj-web-web.md#func-darkmodewebdarkmode)接口将页面深色模式配置为跟随系统。

    <!-- compile -->

    ```cangjie
    // index.cj
    import ohos.web.webview.WebviewController
    import kit.ArkUI.{Web, WebDarkMode}
    import ohos.arkui.state_macro_manage.rawfile

    @Entry
    @Component
    class EntryView {
        let webController = WebviewController()

        func build() {
            Column {
                Web(src: @rawfile("index.html"), controller: webController)
                    .darkMode(WebDarkMode.Auto)
            }
        }
    }
    ```

- 通过[forceDarkAccess()](../reference/arkui-cj/cj-web-web.md#func-forcedarkaccessbool)接口可将前端页面强制配置为深色模式。强制深色模式无法保证所有颜色转换符合预期，且深色模式不跟随前端页面与系统。配置该模式时，需要将深色模式设置为`WebDarkMode.On`。

    在下面的示例中，通过[forceDarkAccess()](../reference/arkui-cj/cj-web-web.md#func-forcedarkaccessbool)接口将页面强制配置为深色模式。

    <!-- compile -->

    ```cangjie
    // index.cj
    import ohos.web.webview.WebviewController
    import kit.ArkUI.{Web, WebDarkMode}
    import ohos.arkui.state_macro_manage.rawfile

    @Entry
    @Component
    class EntryView {
        let webController = WebviewController()

        func build() {
            Column {
                Web(src: @rawfile("index.html"), controller: webController)
                    .darkMode(WebDarkMode.On)
                    .forceDarkAccess(true)
            }
        }
    }
    ```

- index.html页面代码：

    ```html
    <!-- resources/rawfile/index.html -->
    <!DOCTYPE html>
    <html>
    <head>
        <meta name="viewport" content="width=device-width,
                                        initial-scale=1.0,
                                        maximum-scale=1.0,
                                        user-scalable=no">
        <style type="text/css">
            @media (prefers-color-scheme: dark) {
                .contentCss{ background:  #000000; color: white; }
                .hrefCss{ color: #317AF7; }
            }
        </style>
    </head>
    <body class="contentCss">
    <div style="text-align:center">
        <p>Dark mode debug page</p>
    </div>
    </body>
    </html>
    ```
