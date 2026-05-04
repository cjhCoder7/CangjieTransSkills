/**
 * Created on 2024/9/19
 */
package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.*
import ohos.prompt_action.*
import ohos_app_cangjie_entry.core.Puzzle
import std.convert.*
import std.math.*
import ohos.hilog.*
import ohos_app_cangjie_entry.widget.*

extend Button {
    func butStyle() {
        this.fontSize(25).margin(top: 40).height(50).width(70.percent).backgroundColor(0x00A09E5F)
    }
}

extend Int64 {
    public func printScore(): String {
        if (this > 0) {this.toString()} else {""}
    }
}

extend Grid {
    func girdStyle() {
        this.columnsGap(10).rowsGap(10).columnsTemplate("1fr 1fr 1fr 1fr").rowsTemplate("1fr 1fr 1fr 1fr").width(90.percent).backgroundColor(0xFAEEE0).height(340)
    }
}

extend Column {
    func colStyle() {
        this.justifyContent(FlexAlign.Center).height(100.percent).backgroundColor(0xFAEEE0).width(100.percent).margin(top: 5)
    }
}

extend Text {
    func textStyle() {
        this.fontSize(32).width(100.percent).border(width: 5.px, radius: 20.px).height(100.percent).textAlign(TextAlign.Center)
    }
}


@Entry
@Component
class MyView {
    @State
    var numbers: ObservedArray<Int64> = ObservedArray([512, 0, 2, 2, 4, 8, 32, 16, 128, 4, 4, 2048, 1024, 8, 8, 64])

    //判断上一次移动是否改变了布局，如果没有改变，说明滑动无效（不会新生成一个格子）
    var statusChange = true

    @State
    var gameBeign: Bool = false

    @State
    var score: Int64 = 0

    @StorageLink["maxScore"]
    var maxScore: Int64 = 0

    //触摸方向
    var direct: String = ""

    //按压时的坐标位置
    var down: (Float64, Float64) = (0.0, 0.0)
    var up: (Float64, Float64) = (0.0, 0.0)

    //核心运行逻辑
    let puzzle: Puzzle = Puzzle()

    let colorMap = HashMap<Int64, (UInt32, UInt32)>(
        [(0, (0xFFFFFF, 0x776E65)), (2, (0xEEE4DA, 0x776E65)), (4, (0xEDE0C8, 0x776E65)), (8, (0xF2B179, 0xFFFFFF)),
        (16, (0xF59563, 0xFFFFFF)), (32, (0xF67C5F, 0xFFFFFF)), (64, (0xF65E3B, 0xFFFFFF)), (128, (0xEDCF72, 0xFFFFFF)),
        (256, (0xEDCC61, 0xFFFFFF)), (512, (0xEDC850, 0xFFFFFF)), (1024, (0xEDC53F, 0xFFFFFF)),
        (2048, (0xEDC22E, 0xFFFFFF)), (4096, (0x3C3A32, 0xFFFFFF)), (8192, (0x009E60, 0xFFFFFF))])

    //将puzzle中的数据同步到numbers，使用ObservedArray机制绑定UI更新（在最新版HM5.0.0中有bug，见CangjieMoBileUsersForm/issues/137）
    func sync(): Unit {
        var board: Array<Int64> = puzzle.board

        // 判断用户移动是否有效
        var change = false
        for (i in 0..board.size) {
            if (board[i] != numbers[i]){
                change = true
                break
            }
        }
        if (!change){
            statusChange = false
        }else{
            statusChange = true
        }

        score = puzzle.score
        //Hilog.info(0, "score", "score: ${score}")

        if (score > maxScore) {
            maxScore = score
        }
        for (i in 0..board.size) {
            numbers[i] = board[i]
        }
    }

    //游戏状态改变时动画切换效果
    func changeGame(): Unit {
        animateTo(AnimateParam(duration: 1000), {=> this.gameBeign = !this.gameBeign})
    }

    //获取游戏屏幕滑动的方向
    func currentDirect(): String {
        let x = up[0] - down[0]
        let y = up[1] - down[1]
        if (abs(x) > abs(y)) {
            if (x > 0.0) {
                "right"
            } else {
                "left"
            }
        } else {
            if (y > 0.0) {
                "down"
            } else {
                "up"
            }
        }
    }

    //移动动画
    func moveAnimate(animateCallBack: () -> Unit, onFinish: () -> Unit): Unit {
        animateTo(
            AnimateParam(
                duration: 200,
                curve: Curve.FastOutLinearIn,
                delay: 0,
                iterations: 1, // 设置-1表示动画无限循环
                playMode: PlayMode.Normal,
                onFinish: onFinish,
                expectedFrameRateRange: ExpectedFrameRateRange(
                    min: 10,
                    max: 60,
                    expected: 30,
                )
            ),
            animateCallBack
        )
    }

    func build() {
        Stack(Alignment.Top) {
            Column() {
                Grid {
                    ForEach(
                        this.numbers,
                        itemGeneratorFunc: {
                            num: Int64, idx: Int64 => GridItem {
                                Text(this.numbers[idx].printScore())
                                .backgroundColor(colorMap[numbers[idx]][0])
                                .fontColor(colorMap[numbers[idx]][1])
                                .textStyle()
                            }
                        }
                    )
                }
                .girdStyle()
                .onTouch(
                    {
                        event =>
                        if (!gameBeign) {
                            return
                        }
                        //监听按下，松开事件
                        if ("Down" == event.eventType.toString()) {
                            down = (event.touches[0].x, event.touches[0].y)
                        }
                        if ("Up" == event.eventType.toString()) {
                            up = (event.touches[0].x, event.touches[0].y)

                            //计算按下松开移动位置，判断移动的方向
                            puzzle.move(currentDirect())

                            //添加过渡动画
                            moveAnimate({ => sync()},{=>
                                // 有效移动后，随机生成一个新的格子
                                if (statusChange){
                                        puzzle.pickOne()
                                        sync()
                                }
                            })

                            //检查游戏是否结束
                            if (puzzle.check()) {
                                PromptAction.showToast(message: "游戏结束，您的当前得分为:${score}")
                            }
                        }
                    }
                )
                //游戏开始后，隐藏按钮
                if (!gameBeign) {
                    Button("新游戏").butStyle().onClick {
                        =>
                        PromptAction.showToast(message: "游戏开始")
                        puzzle.reset()
                        sync()
                        changeGame()
                    }

                    if (score > 0) {
                        Button("继续游戏").butStyle().onClick {
                            =>
                            PromptAction.showToast(message: "游戏恢复")
                            changeGame()
                        }
                    }
                    Button("关于我们").butStyle().onClick {
                        => PromptAction.showToast(message: "关于我们")
                    }
                }
            }.colStyle()

            //使用Stack层叠组件，分数放在最后是因为要在上层显示
            if (gameBeign) {
                Row() {
                    Row() {
                        Score(title: "主菜单", score: 2048)
                    }.onClick {_ => changeGame()}
                    Score(title: "分数", score: score)
                    Score(title: "最高分", score: maxScore)
                }.margin(top: 20.percent).justifyContent(FlexAlign.End).width(100.percent)
            }
        }
    }
}
