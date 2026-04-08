# 视频播放（Video）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

Video组件用于播放视频文件并控制其播放状态，常用于为短视频和应用内部视频的列表页面。当视频完整出现时会自动播放，用户点击视频区域则会暂停播放，同时显示播放进度条，通过拖动播放进度条指定视频播放到具体位置。具体用法请参见[Video](../reference/arkui-cj/cj-image-video-video.md)。

## 创建视频组件

Video通过调用接口来创建，接口调用形式请参见[创建Video组件](../reference/arkui-cj/cj-image-video-video.md#创建组件)。

## 加载视频资源

Video组件支持加载本地视频和网络视频。

### 加载本地视频

- 普通本地视频

加载本地视频时，首先在本地rawfile目录指定对应的文件，如下图所示。

![Video](figures/Video.png)

再使用资源访问符@rawfile()引用视频资源。

<!-- code_check_manual -->

```cangjie
@Component
class VideoPlayer {
    private var controller: VideoController = VideoController()
    private var previewUris: AppResource = @r(app.media.preview)
    private var innerResource: AppResource = @rawfile("videoTest.mp4")

    func build() {
        Column() {
            Video(src: this.innerResource, previewUri: this.previewUris, controller: this.controller)
        }
    }
}
```

### 加载沙箱路径视频

支持file://路径前缀的字符串，用于读取应用沙箱路径内的资源，需要保证应用沙箱目录路径下的文件存在并且有可读权限。

<!-- code_check_manual -->

```cangjie
@Component
class VideoPlayer {
    private var controller: VideoController = VideoController()
    private var videoSrc: String = "file:///data/storage/el2/base/haps/entry/files/show.mp4"

    func build() {
        Column() {
            Video(src: this.videoSrc, controller: this.controller)
        }
    }
}
```

### 加载网络视频

加载网络视频时，需要申请权限ohos.permission.INTERNET，具体申请方式请参考[声明权限](../security/AccessToken/cj-declare-permissions.md)。此时，Video的src属性为网络视频的链接。

<!-- code_check_manual -->

```cangjie
@Component
class VideoPlayer {
    private var controller: VideoController = VideoController()
    private var previewUris: AppResource = @r(app.media.preview)
    private var videoSrc: String = "https://www.example.com/example.mp4" // 使用时请替换为实际视频加载网址

    func build() {
        Column() {
            Video(src: this.videoSrc, previewUri: this.previewUris, controller: this.controller)
        }
    }
}
```

## 添加属性

Video组件[属性](../reference/arkui-cj/cj-image-video-video.md#组件属性)主要用于设置视频的播放形式。例如设置视频播放是否静音、播放是否显示控制条等。

<!-- code_check_manual -->

```cangjie
@Component
class VideoPlayer {
    private var controller: VideoController = VideoController()

    func build() {
        Column() {
            Video(controller: this.controller)
                .muted(false) // 设置是否静音
                .controls(false) // 设置是否显示默认控制条
                .autoPlay(false) // 设置是否自动播放
                .loop(false) // 设置是否循环播放
                .objectFit(ImageFit.Contain) // 设置视频适配模式
        }
    }
}
```

## 事件调用

Video组件回调事件主要为播放开始、暂停结束、播放失败、播放停止、视频准备和操作进度条等事件，除此之外，Video组件也支持通用事件的调用，如点击、触摸等事件的调用。详情请参见[事件说明](../reference/arkui-cj/cj-image-video-video.md#组件事件)。

<!-- code_check_manual -->

```cangjie
@Component
class VideoPlayer {
    private var controller: VideoController = VideoController()
    private var previewUris: AppResource = @r(app.media.preview)
    private var innerResource: AppResource = @rawfile("videoTest.mp4")

    func build() {
        Column() {
            Video(src: this.innerResource, previewUri: this.previewUris, controller: this.controller)
                .onUpdate({ value => // 更新事件回调
                    Hilog.info(0, "cangjie", "video update.")
                })
                .onPrepared({ value => // 准备事件回调
                    Hilog.info(0, "cangjie", "video prepared.")
                })
                .onError({ => // 失败事件回调
                    Hilog.info(0, "cangjie", "video error.")
                })
        }
    }
}
```

## Video控制器使用

Video控制器主要用于控制视频的状态，包括播放、暂停、停止以及设置进度等，详情请参见[VideoController使用说明](../reference/arkui-cj/cj-image-video-video.md#class-videocontroller)。

- 默认控制器

  默认的控制器支持视频的开始、暂停、进度调整、全屏显示四项基本功能。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry

  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*
  import ohos.resource.*

  @Entry
  @Component
  class EntryView {
      @State var videoSrc: AppResource = @r(app.media.startIcon) // 需要传入正确的视频数据源
      @State var previewUri: AppResource = @r(app.media.startIcon)
      @State var curRate: PlaybackSpeed = PlaybackSpeed.SpeedForward100X

      func build() {
          Row() {
              Column() {
                  Video(src: this.videoSrc, previewUri: this.previewUri, currentProgressRate: this.curRate)
              }
              .width(100.percent)
          }
          .height(100.percent)
      }
  }
  ```

- 自定义控制器

  使用自定义的控制器，先将默认控制器关闭掉，之后可以使用[button](./cj-common-components-button.md)以及[slider](../reference/arkui-cj/cj-button-picker-slider.md)等组件进行自定义的控制与显示，适合在自定义较强的场景下使用。

     <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry

  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*
  import ohos.resource.*

  @Entry
  @Component
  class EntryView {
      @State var videoSrc: AppResource = @r(app.media.startIcon) // 需要传入正确的视频数据源
      @State var previewUri: AppResource = @r(app.media.startIcon)
      @State var curRate: PlaybackSpeed = PlaybackSpeed.SpeedForward100X
      @State var isAutoPlay: Bool = false
      @State var showControls: Bool = true
      @State var sliderStartTime: String = ""
      @State var currentTime: Int32 = 0
      @State var durationTime: Int32 = 0
      var controller: VideoController = VideoController()
      func build() {
          Row() {
              Column() {
                  Video(src: this.videoSrc, previewUri: this.previewUri, currentProgressRate: this.curRate,
                      controller: this.controller)
                      .controls(false)
                      .autoPlay(true)
                      .onPrepared({
                              value => this.durationTime = value.duration.getOrThrow()
                          })
                      .onUpdate({
                              value => this.currentTime = value.time.getOrThrow()
                          })
                  Row() {
                      Text("${this.currentTime}s")
                      Slider(value: Float64(this.currentTime),  min: 0.0, max: Float64(this.durationTime))
                          .onChange({ value: Float64, mode: SliderChangeMode =>
                                  this.controller.setCurrentTime(Int32(value), SeekMode.Accurate)
                              })
                          .width(85.percent)
                      Text("${this.durationTime}s")
                  }
                  .opacity(0.8)
                  .width(100.percent)
              }.width(100.percent)
          }.height(100.percent)
      }
  }
  ```

## 其他说明

Video组件已经封装好了视频播放的基础能力，开发者无需进行视频实例的创建，视频信息的设置获取，只需要设置数据源以及基础信息即可播放视频，相对扩展能力较弱。
