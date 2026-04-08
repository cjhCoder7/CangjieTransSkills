# Web页面显示内容滚动

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

ArkWeb中的Webview.WebviewController提供scrollTo和scrollBy接口。

当Web显示的内容大小远远大于组件大小时，用户可以通过scrollTo和scrollBy对Web页面中显示的内容进行滚动来显示没有显示的部分，且可以生成动画滚动效果。目前动画效果不支持手势打断，可以通过再次执行一个时间约为0的动画进行强制打断。

> **说明：**
>
> 支持滚动的条件： Web页面的长度或宽度大于显示区域的长度或宽度。

<!-- compile -->

```cangjie
// index.cj
import ohos.arkui.state_macro_manage.*
import kit.ArkWeb.WebviewController
import kit.ArkUI.{Web, Button}
import ohos.business_exception.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.resource.__GenerateResource__

@Entry
@Component
class EntryView {
    let webController = WebviewController()

    func build() {
        Column {
            Button("scrollTo").onClick ({ evt =>
                try {
                    webController.scrollTo(50.0, 50.0, duration: 500)
                    Hilog.info(1, "info", "scrollTo success")
                } catch (e: BusinessException) {
                    Hilog.error(1, "info", "scrollTo ErrorCode: ${e.code},  Message: ${e.message}")
                }
            }).margin(10)
            Button("scrollBy").onClick ({ evt =>
                try {
                    webController.scrollBy(50.0, 50.0, duration: 500)
                    Hilog.info(1, "info", "scrollBy success")
                } catch (e: BusinessException) {
                    Hilog.error(1, "info", "scrollBy ErrorCode: ${e.code},  Message: ${e.message}")
                }
            }).margin(10)
            Button("scrollStop").onClick ({ evt =>
                try {
                    webController.scrollBy(0.0, 0.0, duration: 1)
                    Hilog.info(1, "info", "scrollStop success")
                } catch (e: BusinessException) {
                    Hilog.error(1, "info", "scrollStop ErrorCode: ${e.code},  Message: ${e.message}")
                }
            }).margin(10)
            Web(src: @rawfile("index.html"), controller: webController)
        }
    }
}
```

```html
<!-- resources/rawfile/index.html -->
<html>
<head>
    <title>Demo</title>
    <style>
        body {
            width:2000px;
            height:2000px;
            padding-right:170px;
            padding-left:170px;
            border:25px solid blueviolet
            back
        }
        .scroll-text {
        font-size: 75px;
        }
    </style>
</head>
<body>
<div class="scroll-text">Scroll Text</div>
</body>
</html>
```

![web-content-scrolling](figures/web-content-scrolling.gif)
<!--Del-->
## 示例代码

[Web页面显示内容滚动](https://gitcode.com/openharmony/applications_app_samples_cangjie/tree/master/code/BasicFeature/Web/PageScroll)
<!--DelEnd-->
