/**
 * Created on 2024/9/10
 */
package addressexchange.view

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.prompt_action.*

import cj_res_addressexchange.*

@Entry
@Component
public class AddressExchangeView {
    // 旋转角度
    @State var rotateAngle: Float32 = 0.0
    // 偏移量
    @State var translateX: Float64 = 0.0
    // 是否已交换
    @State var swap: Bool = false
    // 整体内容区宽度
    private let rowWidth: Float64 = 300.0
    // 单次偏移距离
    private let distance: Float64 = this.rowWidth * 0.6
    // 内容相隔距离
    private let columnSpace: Int64 = 16
    // 初始化偏移距离
    private let zeroTranslate: Float64 = 0.0
    // 单次旋转180°
    private let rotateAddAngle: Float32 = 180.0
    // toast弹窗时长
    private let toastDuration: Int32 = 2000

    func build() {
        // 地址交换
        Column(this.columnSpace) {
            Row() {
                Text("北京")
                .translate(x: this.translateX)
                .width(40.percent)
                .textAlign(if (this.swap) {TextAlign.End} else {TextAlign.Start})
                .onClick({ event =>
                    PromptAction.showToast(
                        message: "仅演示，可自行实现业务功能",
                        duration: this.toastDuration
                    )
                })

                Stack() {
                    Image(@r(app.media.address_exchange_airplane))
                        .size(height: 16, width: 16)
                    Image(@r(app.media.address_exchange_recycle))
                        .size(height: 28, width: 28)
                        //.animation    //FIXME: 仓颉缺少 .animation 属性，当前使用 .animationStart 及 .animationEnd 代替
                        .animationStart(AnimateParam(curve: Curve.EaseOut, playMode: PlayMode.Normal))
                        .rotate(z: 1.0, angle: this.rotateAngle)    //FIXME: 对于图片的旋转，需要设定Z轴为 1.0
                        .animationEnd()
                }
                .width(20.percent)
                .onClick({ event =>
                    this.swap = !this.swap
                    // TODO: 知识点：动画效果，修改偏移量，修改旋转角度，实现效果
                    // FIXME: 仓颉缺少 curves.springMotion() 方法构造弹性动画曲线对象，发站/到站切换后，文字缺少轻微回弹的效果
                    animateTo(AnimateParam(duration: 500, curve: Curve.EaseOut)) {
                        if (this.swap) {
                            this.translateX = this.distance
                        } else {
                            this.translateX = this.zeroTranslate
                        }
                        this.rotateAngle += this.rotateAddAngle
                    }
                })

                Text("上海")
                .translate(x: -this.translateX)
                .width(40.percent)
                .textAlign(if (this.swap) {TextAlign.Start} else {TextAlign.End})
                .onClick({ event =>
                    PromptAction.showToast(
                        message: "仅演示，可自行实现业务功能",
                        duration: this.toastDuration
                    )
                })

            }
            .width(this.rowWidth)
            .height(60)

            Row(this.columnSpace) {
                Text("2月8日")
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .height(30)

                Text("周四")
                .height(30)
            }
            .width(this.rowWidth)
            .onClick({ event =>
                PromptAction.showToast(
                    message: "仅演示，可自行实现业务功能",
                    duration: this.toastDuration
                )
            })

            Button("查询车票")
            .fontColor(Color.WHITE)
            .height(40)
            .width(this.rowWidth)
            .onClick({event =>
                PromptAction.showToast(
                    message: "仅演示，可自行实现业务功能",
                    duration: this.toastDuration
                )
            })
        }
        .backgroundColor(0xF1F3F5)
        .borderRadius(12)
        .width(94.percent)
        .height(178)
        .margin(12)
    }
}