# Image

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

Image为图片组件，常用于在应用中显示图片。支持png、jpg、jpeg、bmp、svg、webp、gif和heif类型的图片格式。

> 说明：
>
> - 使用快捷组合键对Image组件复制时，Image组件必须处于[获焦状态](./cj-universal-attribute-focus.md#func-focusontouchbool)。Image组件默认不获焦，需将[focusable](cj-apis-window.md#var-focusable)属性设置为true，即可使用TAB键将焦点切换到组件上，再将[focusOnTouch](./cj-universal-attribute-focus.md#func-focusontouchbool)属性设置为true，即可实现点击获焦。
> - 图片格式支持SVG图源，SVG标签文档请参考[SVG标签说明](../ImageKit/cj-apis-image.md#svg标签说明)。
> - 动图的播放依赖于Image节点的可见性变化，其默认行为是不播放的。当节点可见时，通过回调启动动画，当节点不可见时，停止动画。可见性状态的判断是通过[onVisibleAreaChange](./cj-universal-event-visibleareachange.md#func-onvisibleareachangearrayfloat64-bool-float64---unit)事件触发的，当可见阈值ratios大于0时，表明Image处于可见状态。

## 导入模块

```cangjie
import kit.ArkUI.*
```

## 权限列表

使用网络图片时，需要在 module.json5 对应的"requestPermissions"中添加网络使用权限ohos.permission.INTERNET。

```json
"requestPermissions": [
    { "name": "ohos.permission.INTERNET"}
]
```

## 子组件

无

## 创建组件

### init(?ResourceStr)

```cangjie
public init(src: ?ResourceStr)
```

**功能：** 通过图片数据源获取图片，用于后续渲染展示。

> **说明：**
>
> - Image组件加载图片失败或图片尺寸为0时，图片组件大小自动为0，不跟随父组件的布局约束。
> - Image组件默认按照居中裁剪，例如组件宽高设置相同，原图长宽不等，此时按照中间区域进行裁剪。
> - Image加载成功且组件不设置宽高时，其显示大小自适应父组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|src|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|图片的数据源。<br>初始值：""|

### init(?PixelMap)

```cangjie
public init(src: ?PixelMap)
```

**功能：** 通过图片数据源获取图片，用于后续渲染展示。

  > **说明：**
  >
  > - Image组件加载图片失败或图片尺寸为0时，图片组件大小自动为0，不跟随父组件的布局约束。
  > - Image组件默认按照居中裁剪，例如组件宽高设置相同，原图长宽不等，此时按照中间区域进行裁剪。
  > - Image加载成功且组件不设置宽高时，其显示大小自适应父组件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|src|?[PixelMap](../ImageKit/cj-apis-image.md#class-pixelmap)|是|-|图片的数据源。<br/>PixelMap格式为像素图，常用于图片编辑的场景。|

## 通用属性/通用事件

通用属性：全部支持。

> **说明：**
>
> Image组件不支持设置通用属性[foregroundColor](./cj-universal-attribute-foregroundcolor.md#func-foregroundcolorresourcecolor)，可以通过Image组件的[fillColor](#func-fillcolorresourcecolor)属性设置填充颜色。

通用事件：全部支持。

## 组件属性

### func alt(?ResourceStr)

```cangjie
public func alt(src: ?ResourceStr): This
```

**功能：** 设置图片加载时显示的占位图。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|src|?[ResourceStr](./cj-common-types.md#interface-resourcestr)|是|-|加载时显示的占位图，支持本地图片（png、jpg、bmp、svg、gif和heif类型），不支持网络图片。<br>初始值：""。|

### func autoResize(?Bool)

```cangjie
public func autoResize(value: ?Bool): This
```

**功能：** 设置图片解码过程中是否对图源自动缩放。

> **说明：**
>
> 该操作会根据显示区域的尺寸决定用于绘制的图源尺寸，有利于减少内存占用。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|图片解码过程中是否对图源自动缩放。设置为true时，组件会根据显示区域的尺寸决定用于绘制的图源尺寸，有利于减少内存占用。如原图大小为1920x1080，而显示区域大小为200x200，则图片会降采样解码到200x200的尺寸，大幅度节省图片占用的内存。<br>初始值：false|

### func fillColor(?ResourceColor)

```cangjie
public func fillColor(value: ?ResourceColor): This
```

**功能：** 设置替换svg图片的填充颜色。仅对svg图源生效。

> **说明：**
>
> 如需对png图片进行修改颜色，可以使用[colorFilter](#class-colorfilter)。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ResourceColor](./cj-common-types.md#interface-resourcecolor)|是|-|设置填充颜色。|

### func fitOriginalSize(?Bool)

```cangjie
public func fitOriginalSize(value: ?Bool): This
```

**功能：** 设置图片的显示尺寸是否跟随图源尺寸。图片组件尺寸未设置时，其显示尺寸是否跟随图源尺寸。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|是否跟随图源尺寸。<br>初始值：false。|

### func interpolation(?ImageInterpolation)

```cangjie
public func interpolation(value: ?ImageInterpolation): This
```

**功能：** 设置图片的插值效果，即缓解图片在缩放时的锯齿问题。

> **说明：**
>
> - 减轻低清晰度图片在放大显示的时候出现的锯齿问题，仅针对图片放大插值。
> - svg类型图源不支持该属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ImageInterpolation](./cj-common-types.md#enum-imageinterpolation)|是|-|图片的插值效果。<br>初始值：ImageInterpolation.Low。|

### func matchTextDirection(?Bool)

```cangjie
public func matchTextDirection(value: ?Bool): This
```

**功能：** 设置图片是否跟随系统语言方向，在RTL语言环境下显示镜像翻转显示效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|是否跟随系统语言方向。<br>初始值：false。|

### func objectFit(?ImageFit)

```cangjie
public func objectFit(value: ?ImageFit): This
```

**功能：** 设置图片的填充效果。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ImageFit](./cj-common-types.md#enum-imagefit)|是|-|图片的填充效果。<br>初始值：ImageFit.Cover。|

### func objectRepeat(?ImageRepeat)

```cangjie
public func objectRepeat(value: ?ImageRepeat): This
```

**功能：** 设置图片的重复样式。

> **说明：**
>
> - 从中心点向两边重复，剩余空间不足放下一张图片时会截断。
> - svg类型图源不支持该属性。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ImageRepeat](./cj-common-types.md#enum-imagerepeat)|是|-|图片的重复样式。<br>初始值：ImageRepeat.NoRepeat。|

### func renderMode(?ImageRenderMode)

```cangjie
public func renderMode(value: ?ImageRenderMode): This
```

**功能：** 设置图片的渲染模式。

> **说明：**
>
> - svg类型图源不支持该属性。
> - 设置 [ColorFilter](#class-colorfilter) 时，该属性设置不生效。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?[ImageRenderMode](./cj-common-types.md#enum-imagerendermode)|是|-|设置图片的渲染模式。SVG类型图源不支持该属性。<br>初始值：ImageRenderMode.Original。|

### func sourceSize(?Length, ?Length)

```cangjie
public func sourceSize(width: ?Length, height: ?Length): This
```

**功能：** 将原始图片解码成 PixelMap 指定尺寸的图片。PixelMap资源不支持该函数。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|width|?[Length](./cj-common-types.md#interface-length)|是|-|图片解码后的宽度。<br>初始值：0.0.px。|
|height|?[Length](./cj-common-types.md#interface-length)|是|-|图片解码后的高度。<br>初始值：0.0.px。|

### func syncLoad(?Bool)

```cangjie
public func syncLoad(value: ?Bool): This
```

**功能：** 设置是否同步加载图片。

> **说明：**
>
> 建议加载尺寸较小的本地图片时将syncLoad设为true，因为耗时较短，在主线程上执行即可。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Bool|是|-|是否同步加载图片，默认是异步加载。同步加载时阻塞UI线程，不会显示占位图。<br>初始值：false。|

## 组件事件

### func onComplete(?ImageCompleteCallback)

```cangjie
public func onComplete(callback: ?ImageCompleteCallback): This
```

**功能：** 图片成功加载时触发该事件，返回成功加载的图片尺寸。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[ImageCompleteCallback](#type-imagecompletecallback)|是|-|回调函数，图片成功加载时触发。<br>初始值：{ _ => }。|

### func onError(?ImageErrorCallback)

```cangjie
public func onError(callback: ?ImageErrorCallback): This
```

**功能：** 图片加载出现异常时触发该事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|callback|?[ImageErrorCallback](#type-imageerrorcallback)|是|-|回调函数，图片加载出现异常时触发。<br>初始值：{ _ => }。|

### func onFinish(?() -> Unit)

```cangjie
public func onFinish(event: ?() -> Unit): This
```

**功能：** 当加载的源文件为带动效的svg图片时，当svg动效播放完成时会触发该事件，如果动效为无限循环动效，则不会触发这个事件。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|event|?() -> Unit|是|-|回调函数，svg动效播放完成时触发。<br>初始值：{ => }。|

## 基础类型定义

### class ColorFilter

```cangjie
public class ColorFilter {
    public init(value: ?Array<Float32>)
}
```

**功能：** 颜色滤镜矩阵。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### init(?Array\<Float32>)

```cangjie
public init(value: ?Array<Float32>)
```

**功能：** 构建一个颜色滤镜矩阵。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|value|?Array\<Float32>|是|-|4x5的滤镜矩阵。<br>初始值：[]|

### class ImageError

```cangjie
public class ImageError {
    public var componentWidth: Float64
    public var componentHeight: Float64
    public var message: String
}
```

**功能：** 图片加载异常时触发回调的返回对象。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var componentHeight

```cangjie
public var componentHeight: Float64
```

**功能：** 组件的高度，单位为px。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var componentWidth

```cangjie
public var componentWidth: Float64
```

**功能：** 组件的宽度，单位为px。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var message

```cangjie
public var message: String
```

**功能：** 错误信息。

**类型：** String

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

### class ImageLoadResult

```cangjie
public class ImageLoadResult {
    public var width: Float64
    public var height: Float64
    public var componentWidth: Float64
    public var componentHeight: Float64
    public var loadingStatus: Int32
    public var contentWidth: Float64
    public var contentHeight: Float64
    public var contentOffsetX: Float64
    public var contentOffsetY: Float64
}
```

**功能：** 图片加载成功类型。

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var componentHeight

```cangjie
public var componentHeight: Float64
```

**功能：** 组件的高度，单位为px。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var componentWidth

```cangjie
public var componentWidth: Float64
```

**功能：** 组件的宽度，单位为px。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var contentHeight

```cangjie
public var contentHeight: Float64
```

**功能：** 图片实际绘制的高度，单位为px。

> **说明：**
>
> 仅在loadingStatus返回1时有效。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var contentOffsetX

```cangjie
public var contentOffsetX: Float64
```

**功能：** 实际绘制内容相对于组件自身的x轴偏移，单位为px。

> **说明：**
>
> 仅在loadingStatus返回1时有效。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var contentOffsetY

```cangjie
public var contentOffsetY: Float64
```

**功能：** 实际绘制内容相对于组件自身的y轴偏移，单位为px。

> **说明：**
>
> 仅在loadingStatus返回1时有效。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var contentWidth

```cangjie
public var contentWidth: Float64
```

**功能：** 图片实际绘制的宽度，单位为px。

> **说明：**
>
> 仅在loadingStatus返回1时有效。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var height

```cangjie
public var height: Float64
```

**功能：** 图片的高度，单位为px。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var loadingStatus

```cangjie
public var loadingStatus: Int32
```

**功能：** 图片加载成功的状态。

**类型：** Int32

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

#### var width

```cangjie
public var width: Float64
```

**功能：** 图片的宽度，单位为px。

**类型：** Float64

**读写能力：** 可读写

**系统能力：** SystemCapability.ArkUI.ArkUI.Full

**起始版本：** 22

## type ImageCompleteCallback

```cangjie
public type ImageCompleteCallback = (ImageLoadResult) -> Unit
```

**功能：** 图片加载完成回调函数类型。

**类型：** ([ImageLoadResult](#class-imageloadresult)) -> Unit

## type ImageErrorCallback

```cangjie
public type ImageErrorCallback = (ImageError) -> Unit
```

**功能：** 图片加载错误回调函数类型。

**类型：** ([ImageError](#class-imageerror)) -> Unit

## 示例代码

### 示例1（加载基本类型图片）

加载png、gif、svg和jpg等基本类型的图片。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.i18n.*
import ohos.resource.*

@Entry
@Component
class EntryView {
    func build() {
        Flex(direction: FlexDirection.Column, alignItems: ItemAlign.Start) {
                Row() {
                    // 加载png格式图片
                    Image(@r(app.media.startIcon))
                    .width(110)
                    .height(110)
                    .margin(15)
                    .overlay(value: "png", align: Alignment.Bottom, offset: OverlayOffset(x: 0.0, y: 20.0))
                    // 加载gif格式图片
                    Image(@r(app.media.list))
                    .width(110).height(110).margin(15)
                    .overlay(value: "gif", align: Alignment.Bottom, offset: OverlayOffset(x: 0.0, y: 20.0))
                }
                Row() {
                    // 加载svg格式图片
                    Image(@r(app.media.svg))
                    .width(110)
                    .height(110)
                    .margin(15)
                    .overlay(value: "svg", align: Alignment.Bottom, offset: OverlayOffset(x: 0.0, y: 20.0))
                    // 加载jpg格式图片
                    Image(@r(app.media.startIcon_jpg))
                    .width(110)
                    .height(110)
                    .margin(15)
                    .overlay(value: "jpg", align: Alignment.Bottom, offset: OverlayOffset(x: 0.0, y: 20.0))
                }
            }
            .height(320)
            .width(360)
            .padding(right: 10, top: 10)
    }
}
```

![image1](figures/image1.gif)

### 示例2（为图片添加事件）

为图片添加onClick和onFinish事件。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.i18n.*
import ohos.resource.*

@Entry
@Component
class EntryView {
    let imageOne: AppResource= @r(app.media.startIcon)
    let imageTwo = @r(app.media.background)
    let imageThree = @r(app.media.svg_move)
    @State var src: AppResource = this.imageOne
    @State var src2: AppResource = this.imageThree

    func build() {
        Column(){
            // 为图片添加点击事件，点击完成后加载特定图片
            Image(this.src)
            .width(100)
            .height(100)
            .onClick({
                    evt =>
                    this.src =this.imageTwo
            })
            // 当加载图片为SVG格式时
            Image(this.src2)
            .width(100)
            .height(100)
            .onFinish({
                    // SVG动效播放完成时加载另一张图片
                    =>
                    this.src2 =this.imageOne
            })
        }
    }
}
```

![image2](figures/image2.gif)

### 示例3（为图像设置填充效果）

该示例通过objectFit为图像设置填充效果。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.i18n.*
import ohos.resource.*

@Entry
@Component
class EntryView {
    func build() {
        Flex(direction: FlexDirection.Column, alignItems: ItemAlign.Start) {
            Row() {
                // 加载png格式图片
                Image(@r(app.media.flower))
                .width(110)
                .height(110)
                .margin(15)
                .overlay(value: "Contain", align: Alignment.Bottom, offset: OverlayOffset(x: 0.0, y: 20.0))
                .border(width: 2, color: 0xFEC0CD)
                .objectFit(ImageFit.Contain)
                // 加载gif格式图片
                Image(@r(app.media.bybridhar_gif1))
                .width(110)
                .height(110)
                .margin(15)
                .overlay(value: "Cover", align: Alignment.Bottom, offset: OverlayOffset(x: 0.0, y: 20.0))
                .border(width: 2, color: 0xFEC0CD)
                .objectFit(ImageFit.Cover)
            }
            Row() {
                // 加载svg格式图片
                Image(@r(app.media.svg))
                .width(110)
                .height(110)
                .margin(15)
                .overlay(value: "Fill", align: Alignment.Bottom, offset: OverlayOffset(x: 0.0, y: 20.0))
                .border(width: 2, color: 0xFEC0CD)
                .objectFit(ImageFit.Fill)
                // 加载jpg格式图片
                Image(@r(app.media.startIcon))
                .width(110)
                .height(110)
                .margin(15)
                .overlay(value: "ScaleDown", align: Alignment.Bottom, offset: OverlayOffset(x: 0.0, y: 20.0))
                .border(width: 2, color: 0xFEC0CD)
                .objectFit(ImageFit.ScaleDown)
            }
            Row() {
                // 加载png格式图片
                Image(@r(app.media.media1))
                .width(110)
                .height(110)
                .margin(15)
                .overlay(value: "Auto", align: Alignment.Bottom, offset: OverlayOffset(x: 0.0, y: 20.0))
                .border(width: 2, color: 0xFEC0CD)
                .objectFit(ImageFit.Auto)
                // 加载gif格式图片
                Image(@r(app.media.bybridhar_gif1))
                .width(110)
                .height(110)
                .margin(15)
                .overlay(value: "None", align: Alignment.Bottom, offset: OverlayOffset(x: 0.0, y: 20.0))
                .border(width: 2, color: 0xFEC0CD)
                .objectFit(ImageFit.None)
            }
        }
        .height(480)
        .width(360)
        .padding(right: 10, top: 10)
    }
}
```

![image4](figures/image10.gif)

### 示例4（切换显示不同类型图片）

该示例展示了png类型与svg类型作为数据源的显示图片效果。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.i18n.*
import ohos.resource.*

@Entry
@Component
class EntryView {
    let imageOne: AppResource= @r(app.media.startIcon)
    let imageTwo = @r(app.media.svg_move)
    @State var imageSrcIndex : Int64 = 0
    @State var imageSrcList : Array<AppResource> = [this.imageOne,this.imageTwo]

    func build() {
        Column(){
            Image(this.imageSrcList[this.imageSrcIndex])
                .width(100)
                .height(100)
                .margin(left: 100, top: 100)
            Button("点击切换Image的src")
                .margin(left: 100, top: 20)
                .padding(20)
                .onClick({
                    evt =>
                    this.imageSrcIndex = (this.imageSrcIndex + 1) % 2
            })
        }
    }
}
```

![image5](figures/image5.gif)

### 示例5（通过sourceSize设置图片解码尺寸）

该示例通过[sourceSize](#func-sourcesizelength-length)接口自定义图片的解码尺寸。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.i18n.*
import ohos.resource.*
import ohos.arkui.component.ImageFit

@Entry
@Component
class EntryView {
    @State var borderRadiusValue : Int64 = 10

    func build() {
        Column(){
            Image(@r(app.media.image))
                .sourceSize(500,500)
                .width(300)
                .height(300)
            Image(@r(app.media.image))
                .sourceSize(10,10)
                .width(300)
                .height(300)
                .borderWidth(1)
        }
        .height(100.percent)
        .width(100.percent)
    }
}
```

![image6](figures/image6_api.png)

### 示例6（通过renderMode设置图片的渲染模式）

该示例通过通过[renderMode](#func-rendermodeimagerendermode)接口设置图片渲染模式为黑白模式。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.i18n.*
import ohos.resource.*
import ohos.arkui.component.ImageFit

@Entry
@Component
class EntryView {
    @State var borderRadiusValue : Int64 = 10

    func build() {
        Column(){
            Image(@r(app.media.image))
                .renderMode(ImageRenderMode.Template)
                .width(300)
                .height(300)
        }
        .height(100.percent)
        .width(100.percent)
    }
}
```

![image7](figures/image7_api.png)

### 示例7（通过objectRepeat设置图片的重复样式）

该示例通过通过[objectRepeat](#func-objectrepeatimagerepeat)接口在竖直轴上重复绘制图片。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.i18n.*
import ohos.resource.*
import ohos.arkui.component.ImageFit

@Entry
@Component
class EntryView {
    @State var borderRadiusValue : Int64 = 10
    func build() {
        Column(){
            Image(@r(app.media.image))
                .objectRepeat(ImageRepeat.Y)
                .width(120)
                .height(300)
                .objectFit(ImageFit.Contain)
                .borderWidth(1)
        }
        .height(100.percent)
        .width(100.percent)
    }
}
```

![image8](figures/image8.png)

### 示例8（设置SVG图片的填充颜色）

该示例通过通过[fillColor](#func-fillcolorresourcecolor)接口在竖直轴上重复绘制图片。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.i18n.*
import ohos.resource.*

@Entry
@Component
class EntryView {
    @State var borderRadiusValue : Int64 = 10
    func build() {
        Column(){
            Text("不设置fillColor")
            Image(@r(app.media.svg))
                .width(100)
                .height(100)
                .objectFit(ImageFit.Contain)
                .borderWidth(1)
            Text("fillColor传入Color.Gray")
            Image(@r(app.media.svg))
                .width(100)
                .height(100)
                .objectFit(ImageFit.Contain)
                .borderWidth(1)
                .fillColor(Color.Gray)
            Text("fillColor传入Color.Blue")
            Image(@r(app.media.svg))
                .width(100)
                .height(100)
                .objectFit(ImageFit.Contain)
                .borderWidth(1)
                .fillColor(Color.Blue)
            Text("fillColor传入Color.Red")
            Image(@r(app.media.svg))
                .width(100)
                .height(100)
                .objectFit(ImageFit.Contain)
                .borderWidth(1)
                .fillColor(Color.Red)
        }
        .height(100.percent)
        .width(100.percent)
    }
}
```

![image9](figures/image9.png)
