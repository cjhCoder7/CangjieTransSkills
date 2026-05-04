package ohos_app_cangjie_entry

internal import ohos.base.LengthProp
internal import ohos.component.Alignment
internal import ohos.component.Slider
internal import ohos.component.SliderChangeMode
internal import ohos.component.SliderStyle
internal import ohos.component.Axis
internal import ohos.component.RenderingContextSettings
internal import ohos.component.CanvasRenderingContext2D
internal import ohos.component.Canvas
internal import ohos.component.Row
internal import ohos.component.Stack
internal import ohos.component.Button
internal import ohos.component.CustomView
internal import ohos.component.CJEntry
internal import ohos.component.loadNativeView
internal import ohos.state_manage.SubscriberManager
internal import ohos.state_manage.ObservedProperty
internal import ohos.state_manage.LocalStorage
internal import ohos.hilog.Hilog
import ohos.state_macro_manage.Entry
import ohos.state_macro_manage.Component
import ohos.state_macro_manage.State
import ohos.state_macro_manage.r
import ohos_app_cangjie_entry.card.*

@Entry
@Component
class EntryView {
    @State
    var angle: Float64 = 10.0 //牌旋转角度间隔
    @State
    var basePoint: Float64 = 60.0 //牌旋中心基点y坐标

    var settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    var context: CanvasRenderingContext2D = CanvasRenderingContext2D(this.settings)
    let cards = deck() //牌

    func build() {
        Stack(Alignment.Bottom) {
            //画布初始化，并绘制牌扇
            Canvas(this.context).width(600).height(1000).onReady(
                {
                => for (i in 0..13) {
                    drawCard(this.context, 600.0, 1200.0, Float64(-45.0 + angle * Float64(i)), basePoint, cards[i][0],
                        cards[i][1])
                }
            })
            //组件布局
            Row {

                //旋转角度间隔调节
                Slider(
                    value: 0.0,
                    min: 5.0,
                    max: 25.0,
                    step: 1.0,
                    style: SliderStyle.OutSet,
                    direction: Axis.Horizontal,
                    reverse: false
                ).blockColor(REDSUIT).trackColor(BLACKSUIT).selectedColor(BORDER).showSteps(false).showTips(false).
                    trackThickness(5).onChange(
                    {
                        val: Float64, mode: SliderChangeMode =>
                        context.clearRect(0, 0, 600, 1000)
                        this.angle = val
                        for (i in 0..13) {
                            drawCard(this.context, 600.0, 1000.0, Float64(-45.0 + Float64(i) * angle), basePoint,
                                cards[i][0], cards[i][1])
                        }
                    }
                ).width(30.percent)

                //重新洗牌
                Button("发牌").onClick {
                    shuffle(cards)
                    context.clearRect(0, 0, 600, 1000)
                    for (i in 0..13) {
                        drawCard(this.context, 600.0, 1000.0, Float64(-45.0 + Float64(i) * angle), basePoint,
                            cards[i][0], cards[i][1])
                    }
                }.fontSize(20).width(30.percent)
                //旋转基点调节
                Slider(
                    value: 0.0,
                    min: 60.0,
                    max: 100.0,
                    step: 1.0,
                    style: SliderStyle.OutSet,
                    direction: Axis.Horizontal,
                    reverse: false
                ).blockColor(REDSUIT).trackColor(BLACKSUIT).selectedColor(BORDER).showSteps(false).showTips(false).
                    trackThickness(5).onChange(
                    {
                        val: Float64, mode: SliderChangeMode =>
                        context.clearRect(0, 0, 600, 1000)
                        this.basePoint = val
                        for (i in 0..13) {
                            drawCard(this.context, 600.0, 1000.0, Float64(-45.0 + Float64(i) * angle), basePoint,
                                cards[i][0], cards[i][1])
                        }
                    }
                ).width(30.percent)
            }.height(55.percent) //行容器高度
        }.height(100.percent)
    }
}
