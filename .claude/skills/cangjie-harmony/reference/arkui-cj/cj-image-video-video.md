# Video

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

用于播放视频文件并控制其播放状态的组件。

> **说明：**
>
> Video组件只提供简单的视频播放功能，无法支撑复杂的视频播控场景。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 权限列表

使用网络视频时，需要申请权限ohos.permission.INTERNET。

## 子组件

不支持子组件。

## 创建组件

### init(?ResourceStr, ?PlaybackSpeed, ?ResourceStr, ?VideoController)

```cangjie
public init(
    src!: ?ResourceStr = None,
    currentProgressRate!: ?PlaybackSpeed = Option.None,
    previewUri!: ?ResourceStr = None,
    controller!: ?VideoController = None
)
```

**功能：** 根据视频的数据源，播放倍速，预览图片和视频控制器创建一个 video 组件。

**需要权限：** 使用网络视频时，需要申请权限ohos.permission.INTERNET。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|src|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None| **命名参数。** 视频的数据源，支持本地视频和网络视频。|
|currentProgressRate|?[PlaybackSpeed](./cj-common-types.md#enum-playbackspeed)|否|Option.None| **命名参数。** 视频播放倍速。<br>初始值：SpeedForward100X。|
|previewUri|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|否|None| **命名参数。** 视频未播放时的预览图片路径。|
|controller|?[VideoController](#class-videocontroller)|否|None| **命名参数。** 设置视频控制器，可以控制视频的播放状态。<br>初始值：VideoController()|

## 通用属性/通用事件

通用属性：全部支持。

通用事件：全部支持。

## 组件属性

### func autoPlay(?Bool)

```cangjie
public func autoPlay(value: ?Bool): This
```

**功能：** 设置视频是否自动播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|视频是否自动播放。<br>初始值：false。|

### func controls(?Bool)

```cangjie
public func controls(value: ?Bool): This
```

**功能：** 设置控制视频播放的控制栏是否显示。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|是否显示控制栏。<br>初始值：true。|

### func loop(?Bool)

```cangjie
public func loop(value: ?Bool): This
```

**功能：** 设置是否单个视频循环播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|视频是否循环播放。<br>初始值：false。|

### func muted(?Bool)

```cangjie
public func muted(value: ?Bool): This
```

**功能：** 设置视频是否静音。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|视频是否静音。<br>初始值：false。|

### func objectFit(?ImageFit)

```cangjie
public func objectFit(value: ?ImageFit): This
```

**功能：** 设置视频填充模式。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ImageFit](./cj-common-types.md#enum-imagefit)|是|-|视频填充模式。<br>初始值：ImageFit.Cover。|

## 组件事件

### func onError(?VoidCallback)

```cangjie
public func onError(event: ?VoidCallback): This
```

**功能：** 播放失败时触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?[VoidCallback](./cj-common-types.md#type-voidcallback)|是|-|回调函数，播放失败时触发。<br>初始值：{ => }|

### func onFinish(?VoidCallback)

```cangjie
public func onFinish(event: ?VoidCallback): This
```

**功能：** 播放结束时触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?[VoidCallback](./cj-common-types.md#type-voidcallback)|是|-|回调函数，播放结束时触发。<br>初始值：{ => }|

### func onPause(?VoidCallback)

```cangjie
public func onPause(event: ?VoidCallback): This
```

**功能：** 暂停播放时触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?[VoidCallback](./cj-common-types.md#type-voidcallback)|是|-|回调函数，暂停播放时触发。<br>初始值：{ => }|

### func onPrepared(?Callback\<PreparedInfo, Unit>)

```cangjie
public func onPrepared(callback: ?Callback<PreparedInfo, Unit>): This
```

**功能：** 视频准备完成时触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[Callback](./cj-common-types.md#type-callbackt-v)\<[PreparedInfo](#class-preparedinfo), Unit>|是|-|回调函数，视频准备完成时触发。<br>初始值：{ _ => }|

### func onSeeked(?Callback\<PlaybackInfo, Unit>)

```cangjie
public func onSeeked(callback: ?Callback<PlaybackInfo, Unit>): This
```

**功能：** 操作进度条完成后触发该事件，上报播放时间信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[Callback](./cj-common-types.md#type-callbackt-v)\<[PlaybackInfo](#class-playbackinfo), Unit>|是|-|回调函数，操作进度条完成后触发。<br>初始值：{ _ => }|

### func onSeeking(?Callback\<PlaybackInfo, Unit>)

```cangjie
public func onSeeking(callback: ?Callback<PlaybackInfo, Unit>): This
```

**功能：** 操作进度条过程时触发该事件，上报时间信息。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[Callback](./cj-common-types.md#type-callbackt-v)\<[PlaybackInfo](#class-playbackinfo), Unit>|是|-|回调函数，操作进度条过程时触发。<br>初始值：{ _ => }|

### func onStart(?VoidCallback)

```cangjie
public func onStart(event: ?VoidCallback): This
```

**功能：** 播放时触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?[VoidCallback](./cj-common-types.md#type-voidcallback)|是|-|回调函数，播放时触发。<br>初始值：{ => }|

### func onUpdate(?Callback\<PlaybackInfo, Unit>)

```cangjie
public func onUpdate(callback: ?Callback<PlaybackInfo, Unit>): This
```

**功能：** 播放进度变化时触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[Callback](./cj-common-types.md#type-callbackt-v)\<[PlaybackInfo](#class-playbackinfo), Unit>|是|-|回调函数，播放进度变化时触发。<br>初始值：{ _ => }|

### func onFullscreenChange(?Callback\<FullscreenInfo, Unit>)

```cangjie
public func onFullscreenChange(callback: ?Callback<FullscreenInfo, Unit>): This
```

**功能：** 视频进入和退出全屏时触发该回调。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[Callback](./cj-common-types.md#type-callbackt-v)\<[FullscreenInfo](#class-fullscreeninfo), Unit>|是|-|视频进入和退出全屏时的回调函数。<br>初始值：{ _ => }|

## 基础类型定义

### class FullscreenInfo

```cangjie
public class FullscreenInfo {
    public var fullscreen: ?Bool
}
```

**功能：** 用于描述当前视频是否进入全屏播放状态。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var fullscreen

```cangjie
public var fullscreen: ?Bool
```

**功能：** 当前视频是否进入全屏播放状态。

**类型：** ?Bool

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### class PlaybackInfo

```cangjie
public class PlaybackInfo {
    public var time: ?Int32
}
```

**功能：** 用于描述当前视频播放的进度。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var time

```cangjie
public var time: ?Int32
```

**功能：** 当前视频播放的进度。单位：秒。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### class PreparedInfo

```cangjie
public class PreparedInfo {
    public var duration: ?Int32
}
```

**功能：** 用于描述当前视频的时长。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var duration

```cangjie
public var duration: ?Int32
```

**功能：** 当前视频的时长。单位：秒。

**类型：** ?Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### class VideoController

```cangjie
public class VideoController {
    public init()
}
```

**功能：** 视频控制器。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init()

```cangjie
public init()
```

**功能：** VideoController的构造函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### func exitFullscreen()

```cangjie
public func exitFullscreen(): Unit
```

**功能：** 退出全屏播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### func pause()

```cangjie
public func pause(): Unit
```

**功能：** 暂停播放，显示当前帧，再次播放时从当前位置继续播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### func requestFullscreen(?Bool)

```cangjie
public func requestFullscreen(value: ?Bool): Unit
```

**功能：** 请求全屏播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|是否全屏播放。<br>初始值：false。|

#### func setCurrentTime(Int32, ?SeekMode)

```cangjie
public func setCurrentTime(value: Int32, seekMode: ?SeekMode): Unit
```

**功能：** 指定视频播放的进度位置。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|Int32|是|-|播放时间。|
|seekMode|?[SeekMode](./cj-common-types.md#enum-seekmode)|是|-|跳转模式。|

#### func start()

```cangjie
public func start(): Unit
```

**功能：** 开始播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### func stop()

```cangjie
public func stop(): Unit
```

**功能：** 停止播放，显示当前帧，再次播放时从头开始播放。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## 示例代码

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.i18n.*
import ohos.resource.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    var videoSrc: AppResource = @rawfile("video.mp4")
    var previewUri: AppResource = @r(app.media.preview)
    var controller: VideoController = VideoController()
    @State var curRate: PlaybackSpeed = PlaybackSpeed.SpeedForward100X
    @State var isAutoPlay: Bool = false
    @State var showControls: Bool = true

    func build() {
        Column() {
            Video(
                src: this.videoSrc,
                previewUri: this.previewUri,
                currentProgressRate: this.curRate,
                controller: this.controller
            )
                .width(100.percent)
                .height(600)
                .autoPlay(this.isAutoPlay)
                .controls(this.showControls)

            Row() {
                Button("start")
                    .onClick({ evt
                        => this.controller.start() // 开始播放
                    })
                    .margin(5)
                    .width(100)
                    .id("start")
                Button("pause")
                    .onClick({ evt
                        => this.controller.pause() // 暂停播放
                    })
                    .margin(5)
                    .width(100)
                    .id("pause")
                Button("stop")
                    .onClick({ evt
                        => this.controller.stop() // 暂停播放
                           this.controller.exitFullscreen()
                        }
                    )
                    .margin(5)
                    .width(100)
                    .id("stop")
            }
            Row() {
                Button("Fullscreen")
                    .onClick({ evt
                        => this.controller.requestFullscreen(true)
                    })
                    .margin(5)
                    .width(100)
                    .id("Fullscreen")
                Button("at 10s")
                    .onClick({ evt
                        => this.controller.setCurrentTime(10, SeekMode.ClosestKeyframe)
                    })
                    .margin(5)
                    .width(100)
                    .id("at 10s")
                Button("exitFull")
                    .onClick({ evt
                        => this.controller.exitFullscreen()
                    })
                    .margin(5)
                    .width(100)
                    .id("exitFull")
            }
            Row() {
                Button("rate 0.75")
                    .onClick({ evt
                        => this.curRate = PlaybackSpeed.SpeedForward075X
                    })
                    .margin(5)
                    .width(100)
                    .id("rate 0.75")
                Button("rate 1")
                    .onClick({ evt
                        => this.curRate = PlaybackSpeed.SpeedForward100X
                    })
                    .margin(5)
                    .width(100)
                    .id("rate 1")
                Button("rate 2")
                    .onClick({ evt
                        => this.curRate = PlaybackSpeed.SpeedForward200X
                    })
                    .margin(5)
                    .width(100)
                    .id("rate 2")
            }
        }
    }
}
```

![video](figures/imageVideo.gif)