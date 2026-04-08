# 使用AVImageGenerator提取视频指定时间图像

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

使用AVImageGenerator可以实现从原始媒体资源中获取视频指定时间的缩略图。本开发指导将以获取一个视频资源的缩略图为例，向开发者讲解 AVImageGenerator 的相关功能。

获取视频资源的缩略图的全流程包含：创建AVImageGenerator对象，设置资源，获取缩略图，销毁资源。

## 开发步骤及注意事项

详细的API说明请参见[AVImageGenerator API参考](../../reference/MediaKit/cj-apis-multimedia_media.md#class-avimagegenerator)。

1. 使用createAVImageGenerator()创建实例。

2. 设置资源：需要设置属性fdSrc（表示文件描述符）。

   > **说明：**
   >
   > 开发者需根据实际情况，确认资源有效性并设置fdSrc：
   >
   > - 可以使用ResourceManager.getRawFd打开HAP资源文件描述符，使用方法请参见[ResourceManager API参考](../../reference/LocalizationKit/cj-apis-resource_manager.md#func-getrawfdstring)。
   >
   > - 也可以使用应用沙箱路径访问对应资源（必须确认资源文件可用），请参见[获取应用文件路径](../../file-management/cj-app-sandbox-directory.md#应用文件目录与应用文件路径)。应用沙箱的介绍及如何向应用沙箱推送文件，请参见[文件管理](../../file-management/cj-app-sandbox-directory.md)。
   >
   > - 不同AVImageGenerator，如果需要操作同一资源，需要多次打开文件描述符，不要共用同一文件描述符。

3. 获取指定时间图像：调用fetchFrameByTime()，可以获取到一个PixelMap对象，该对象可用于图片显示。

4. 释放资源：调用release()销毁实例，释放资源。

## 完整示例

参考以下示例，设置文件描述符，获取一个视频指定时间的缩略图。

<!-- compile -->

```cangjie
// index.cj
import kit.ArkUI.Button
import kit.ArkUI.Image
import kit.MediaKit.*
import kit.ImageKit.PixelMap
import kit.AbilityKit.*
import kit.PerformanceAnalysisKit.Hilog

var ctx = Option<UIAbilityContext>.None

@Entry
@Component
class EntryView {
    @State
    var message: String = 'Hello World'

    // pixelMap对象声明，用于图片显示
    @State
    var pixelMap: ?PixelMap = Option<PixelMap>.None

    func build() {
        Row() {
            Column() {
                Text(this.message).fontSize(50).fontWeight(FontWeight.Bold)
                Button() {
                    Text('TestButton')
                        .fontSize(30)
                        .fontWeight(FontWeight.Bold)
                }
                .margin(top: 20.px)
                .backgroundColor(0x0D9FFB)
                .width(60.percent)
                .height(5.percent)
                .onClick ({
                    evt =>
                    // 设置fdSrc, 获取视频的缩略图
                    testFetchFrameByTime()
                })
                Image(this.pixelMap).width(300).height(300)
                .margin(top: 20.px)
            }
            .width(100.percent)
            }
            .height(100.percent)
    }

    // 使用资源管理接口获取打包在HAP内的视频文件，通过设置fdSrc属性，
    // 获取视频指定时间的缩略图，并通过Image控件显示在屏幕上。
    func testFetchFrameByTime() {
        // 创建AVImageGenerator对象
        let avImageGenerator = createAVImageGenerator()
        // 设置fdSrc
        avImageGenerator.fdSrc = AVFileDescriptor(ctx.getOrThrow().resourceManager.getRawFd('demo.mp4').fd)

        // 初始化入参
        let timeUs = 0
        let queryOption = AVImageQueryOptions.AvImageQueryNextSync
        let param = PixelMapParams(
            width : 300,
            height : 300
        )

        // 获取缩略图
        pixelMap = avImageGenerator.fetchFrameByTime(timeUs, queryOption, param)

        // 释放资源
        avImageGenerator.release()
        Hilog.info(1, "info", "release success.")
    }
}
```

<!-- compile -->

```cangjie
// main_ability.cj
import kit.AbilityKit.*
import kit.PerformanceAnalysisKit.Hilog
import kit.ArkUI.WindowStage

class MainAbility <: UIAbility {
    public init() {
        super()
        registerSelf()
    }

    public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
        Hilog.info(1, "info", "MainAbility OnCreated.${want.abilityName}")
        match (launchParam.launchReason) {
            case LaunchReason.START_ABILITY => Hilog.info(1, "info", "START_ABILITY")
            case _ => ()
        }
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        Hilog.info(1, "info", "MainAbility onWindowStageCreate.")
        windowStage.loadContent("EntryView")
        // declared in index.cj
        ctx = this.context
    }
}
```
