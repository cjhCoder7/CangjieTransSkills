/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package ohos_app_cangjie_entry

import ohos.state_macro_manage.*
import ohos.prompt_action.*

@Entry
@Component
public class SimpleSample {
    @State
    var editFlag: Bool = false
    @State
    var data: PhotoViewModel = PhotoViewModel()
    @State
    var toastNum: Int64 = 1
    @State
    var showRect: String = "RectF"
    var dialogController: CustomDialogController = CustomDialogController(
        CustomDialogControllerOptions(builder: CustomDialogExample2(confirm: onAccept), alignment: DialogAlignment.Top,
            offset: Offset(100.vp, 10.vp), cancel: {
                => AppLog.info("click the callback in the blank area")
            }, autoCancel: true))

    func onAccept(index: Int64): Unit {
        if (index == 0) {
            data.setZoomable(false)
        } else if (index == 1) {
            data.setZoomable(true)
        } else if (index == 2) {
            data.setImageFit(ImageFit.Contain)
        } else if (index == 5) {
            data.setImageFit(ImageFit.Fill)
        } else if (index == 6) {
            data.setImageFit(ImageFit.None)
        } else if (index == 7) {
            data.setImageFit(ImageFit.Cover)
        } else if (index == 8) {
            data.setImageFit(ImageFit.ScaleDown)
        } else if (index == 9) {
            data.setScale(Random().nextFloat64() + 1.0, true)
        } else if (index == 10) {
            data.setScale(Random().nextFloat64() + 1.0, true)
        }
    }

    func build() {
        Column() {
            Row(5) {
                Image(@r(app.media.back))
                    .width(45)
                    .height(45)
                    .margin(left: 5)
                    .onClick({
                        event => Router.back()
                    })
                Text("Simple Sample")
                    .width(75.percent)
                    .fontColor(0xffffff)
                    .fontSize(20)
                    .margin(top: 4)
                Image(@r(app.media.more))
                    .width(45)
                    .height(45)
                    .margin(right: 5)
                    .onClick({
                        event => dialogController.`open`()
                    })
            }
                .width(100.percent)
                .height(80)
                .backgroundColor(0x3d3d3d)

            PhotoView(model: getData())

            Text("${showRect}")
                .width(100.percent)
                .height(20)
                .fontSize(13)
                .textAlign(TextAlign.Center)
                .fontColor(Color.WHITE)
                .backgroundColor(Color.BLACK)
        }
            .height(100.percent)
            .width(100.percent)
            .padding(0)
            .margin(0)
            .border(width: 0)
            .backgroundColor(0x3d3d3d)
    }

    public func onPageShow(): Unit {
        sleep(Duration.second / 120)
        showRect = data
            .getRectF()
            .toString()
    }

    public func getData(): PhotoViewModel {
        data.initMatrix()
        data
            .setImageResource(@r(app.media.wallpaper))
            .setScale(1.0, false)
            .setImageFit(ImageFit.Contain)
            .setMaximumScale(3.0)
            .setOnPhotoTapListener(MyOnPhotoTapListener())
            .setOnMatrixChangeListener(MyOnMatrixChangedListener())
            .gestureConversion(PanDirection.All, SwipeDirection.None, Option<Bool>.None)
    }
}

class MyOnPhotoTapListener <: OnPhotoTapListener {
    public override func onPhotoTap(x: Float64, y: Float64): Unit {
        let xRes: Float64 = x * 100.0
        let yRes: Float64 = y * 100.0
        PromptAction.showToast(message: "Photo Tap! X: ${xRes}% Y: ${yRes}", duration: 2000)
    }
}

class MyOnMatrixChangedListener <: OnMatrixChangedListener {
    public override func onMatrixChanged(rect: ?RectF): String {
        if (let Some(v) <- rect) {
            return v.toString()
        }
        return "RectF"
    }
}

@CustomDialog
class CustomDialogExample2 {
    var controller: Option<CustomDialogController> = Option.None
    var confirm: (Int64) -> Unit

    func build() {
        Column() {
            Text("Disable Zoom")
                .width(100.percent)
                .padding(left: 20)
                .fontSize(14)
                .fontColor(0xffffff)
                .margin(top: 10)
                .onClick(
                    {
                        event =>
                        controller?.close()
                        confirm(0)
                    }
                )
            Text("Enable Zoom")
                .width(100.percent)
                .padding(left: 20)
                .fontSize(14)
                .fontColor(0xffffff)
                .margin(top: 10)
                .onClick(
                    {
                        event =>
                        controller?.close()
                        confirm(1)
                    }
                )
            Text("Change to FIT_CENTER")
                .width(100.percent)
                .padding(left: 20)
                .fontSize(14)
                .fontColor(0xffffff)
                .margin(top: 10)
                .onClick(
                    {
                        event =>
                        controller?.close()
                        confirm(2)
                    }
                )
            Text("Change to FIT_XY")
                .width(100.percent)
                .padding(left: 20)
                .fontSize(14)
                .fontColor(0xffffff)
                .margin(top: 10)
                .onClick(
                    {
                        event =>
                        controller?.close()
                        confirm(5)
                    }
                )
            Text("Change to CENTER")
                .width(100.percent)
                .padding(left: 20)
                .fontSize(14)
                .fontColor(0xffffff)
                .margin(top: 10)
                .onClick(
                    {
                        event =>
                        controller?.close()
                        confirm(6)
                    }
                )
            Text("Change to Center_crop")
                .width(100.percent)
                .padding(left: 20)
                .fontSize(14)
                .fontColor(0xffffff)
                .margin(top: 10)
                .onClick(
                    {
                        event =>
                        controller?.close()
                        confirm(7)
                    }
                )
            Text("Change to CENTER_Inside")
                .width(100.percent)
                .padding(left: 20)
                .fontSize(14)
                .fontColor(0xffffff)
                .margin(top: 10)
                .onClick(
                    {
                        event =>
                        controller?.close()
                        confirm(8)
                    }
                )
            Text("Animate scale to random value")
                .width(100.percent)
                .padding(left: 20)
                .fontSize(14)
                .fontColor(0xffffff)
                .margin(top: 10)
                .onClick(
                    {
                        event =>
                        controller?.close()
                        confirm(9)
                    }
                )
            Text("set scale to random value")
                .width(100.percent)
                .padding(left: 20)
                .fontSize(14)
                .fontColor(0xffffff)
                .margin(top: 10)
                .onClick(
                    {
                        event =>
                        controller?.close()
                        confirm(10)
                    }
                )
            Text("Restore Display Matrix")
                .width(100.percent)
                .padding(left: 20)
                .fontSize(14)
                .fontColor(0xffffff)
                .margin(top: 10)
                .onClick(
                    {
                        event =>
                        controller?.close()
                        confirm(11)
                    }
                )
            Text("Capture Display Matrix")
                .width(100.percent)
                .padding(left: 20)
                .fontSize(14)
                .fontColor(0xffffff)
                .margin(top: 10)
                .onClick(
                    {
                        event =>
                        controller?.close()
                        confirm(12)
                    }
                )
        }.backgroundColor(0x3d3d3d)
    }
}
