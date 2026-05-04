package ohos_app_cangjie_entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.image.Image as MultiImage
import ohos.image.Component as ImageComponent
import ohos.image.InitializationOptions
import ohos.image.PixelMapFormat
import ohos.image.PixelMap
import ohos.image.createPixelMap
import ohos.image.Size as UniqueImageSize
import ohos.resource_manager.*
import cj_res_entry.app
import ohos_app_cangjie_entry.common.*
import ohos_app_cangjie_entry.view.*
import std.sync.*
import std.time.Duration
import ohos_app_cangjie_entry.view.PanelComponent


@Entry
@Component
class EntryView {

    @State var speed:Float32 = Constants.SPEED
    @State var angle: Float32 = Constants.ANGLE
    @State var imageSize:Float32 = Constants.IMAGE_SIZE_INITIAL
    private var timer : Option<Timer> = None


    func build() {
        Column() {
            Image(@rawfile("windmill.png"))
            .objectFit(ImageFit.Contain)
            .width(Constants.IMAGE_SIZE)
            .height(Constants.IMAGE_SIZE)
            .rotate(
                x: RotatePosition.X,
                y: RotatePosition.Y,
                z: RotatePosition.Z,
                angle: this.angle,
                )
            .scale(x:this.imageSize, y:this.imageSize)
            Row().height(Constants.WEIGHT_BLANK_IMAGE)

            PanelComponent(mode:SliderMode.SPEED, title:@r(app.string.speed_text), outSetValue:this.angle, min:SliderSpeed.MIN, max:SliderSpeed.MAX, step: SliderSpeed.STEP,
            callback:({value,mode =>
                this.timer?.cancel()
                this.timer = Timer.repeat(Duration.millisecond*50, Duration.millisecond*50, { =>
                spawn(Main){this.angle += Float32(value) } })}))

            PanelComponent(mode: SliderMode.SCALE, title:@r(app.string.scale_text), outSetValue:this.imageSize, min:Constants.MIN, max:Constants.MAX, step: Constants.STEP,
                callback:({value, mode =>
                    this.imageSize = Float32(value)}))
        }
        .justifyContent(FlexAlign.End)
        .height(Constants.PERCENTAGE_100)
        .backgroundColor(@r(app.color.background_color))
    }

}
