/**
 * Created on 2024/8/31
 */
package ohos_app_cangjie_entry.page.home

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import cj_res_entry.app
import ohos.hilog.Hilog
import std.collection.*
import std.math.*
import std.random.*
import std.sync.*
import std.time.{Duration, DurationExtension}
import ohos.concurrency.launch

import ohos_app_cangjie_entry.model.CircleModel
import ohos_app_cangjie_entry.util.CircleUtil

@Component
public class turntable {
    var settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    var context: CanvasRenderingContext2D = CanvasRenderingContext2D(this.settings)

    //获取的屏幕宽高
    var screenWidth: UInt32 = 0
    var screenHeight: UInt32 = 0

    //控制小圆改变颜色
    @State
    var res: Bool = false
    //画图的旋转角度
    @State
    var rotateAngle: Float32 = 0.0
    //控制转盘转动
    @State
    var enabledFlag: Bool = true

    //中奖信息
    @Link
    var resultOfLuckyDraw: String

    //实例化一个画圆工具
    @State
    var circleUtil: CircleUtil = CircleUtil(this.context)

    //大圆
    var bigCircle: CircleModel = CircleModel(0.0, 0.0, 175.0, 0.0, 360.0)
    //中间的圆
    var middleCircle: CircleModel = CircleModel(175.0, 175.0, 150.0, 0.0, 360.0)

    protected override func aboutToAppear() {
        //获取屏幕宽高
        //this.screenWidth = AppStorage.get<(UInt32, UInt32)>("widthAndHeight").getOrThrow()[0]
        //this.screenHeight = AppStorage.get<(UInt32, UInt32)>("widthAndHeight").getOrThrow()[1]

        let time = Timer.repeat(200 * Duration.millisecond, 500 * Duration.millisecond,
            {
            => spawn (Main) {
                this.res = !this.res
                this.circleUtil.canvaSmallCircle(this.res)
            }
        })
    }

    protected override func aboutToDisappear(){

    }

    //控制转盘的旋转
    private func controllerTurntabelRotate() {
        //实例化一个随机Random对象
        let random: Random = Random()
        //使用random.nextFloat32()函数生成一个随机数
        let randomAngle = round(360.0 * random.nextFloat32())
        animateTo(
            AnimateParam(
                duration: 4000,
                curve: Curve.Ease,
                delay: 0,
                iterations: 1,
                playMode: PlayMode.Normal,
                onFinish: {
                    =>
                    this.resultOfLuckyDraw = this.circleUtil.getText(randomAngle)
                    this.rotateAngle = 270.0 - randomAngle
                    this.enabledFlag = !this.enabledFlag
                }
            ),
            {
                => this.rotateAngle = 360.0 * 6.0 + 270.0 - randomAngle
            }
        )
    }

    func build() {
        Stack() {
            Canvas(this.context).width(350).height(350).onReady({
                => this.circleUtil.canvaAll(this.res)
            }).rotate(x: 0.0, y: 0.0, z: 1.0, angle: this.rotateAngle, centerX: 50.percent, centerY: 50.percent)

            Image(@r(app.media.ic_begin_center)).width(100).height(100).enabled(this.enabledFlag).onClick(
                {
                    e =>
                    this.enabledFlag = !this.enabledFlag
                    this.controllerTurntabelRotate()
                }
            )
        }.width(95.percent).alignment(Alignment.Center)
        .margin(bottom:40)
    }
}
