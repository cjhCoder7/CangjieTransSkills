package ohos_app_cangjie_entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.webview.*
import std.collection.*
import std.convert.*
import std.math.*

@Entry
@Component
class SnakeGame {
    @State
    var score_max: Int64 = 0
    @State
    var score_now: Int64 = 0
    @State
    var game_sta: String = "Playing"
    // webview controller
    let webController = WebviewController()
    var isloaded: Bool = false

    // UI Entry
    func build() {
        Column {
            // head area
            Blank(min: 20.vp)
            Text("贪吃蛇小游戏\t${game_sta}").fontColor(Color(225, 225, 225)).fontSize(64.px)
            Text("当前分数:\t${score_now} 分").fontColor(Color(225, 225, 225)).fontSize(64.px)
            Text("历史最高:\t${score_max} 分").fontColor(Color(225, 225, 225)).fontSize(64.px)

            // webview
            Blank(min: 15.vp)
            WebPlayground()
            Blank(min: 15.vp)
            // control button
            Row {
                // refresh button
                ControlBtn(
                    "重新 开始",
                    "CjApi.getscore()",
                    {
                        item =>
                        score_max = max(score_max, Int64.parse(item))
                        score_now = 0
                        game_sta = "Playing"
                        webController.refresh()
                    },
                    {ecode =>}
                )
                Blank(min: 100.vp)
                // pause or continue
                ControlBtn(
                    "暂停 恢复",
                    "CjApi.startorpause()",
                    {item =>},
                    {ecode =>}
                )
            }
            Blank(min: 30.vp)
            DirectionBtn("ArrowUp")
            Blank(min: 10.vp)
            Row {
                DirectionBtn("ArrowLeft")
                Blank(min: 100.vp)
                DirectionBtn("ArrowRight")
            }
            Blank(min: 10.vp)
            DirectionBtn("ArrowDown")
            Blank(min: 30.vp)
        }
            .width(100.percent)
            .height(100.percent)
            .backgroundColor(Color(200, 0, 0))
            .backgroundImage(src: @rawfile("game.png"), repeat: ImageRepeat.NoRepeat)
            .border(width: 30.px, color: Color(0, 0, 0), radius: 10.px, style: BorderStyle.Solid)
    }

    // direction button constructor
    @Builder
    private func DirectionBtn(drt: String) {
        Button("")
            .onClick {
                evt => webController.runJavaScript(
                    "CjApi.changeDirection('${drt}')",
                    JsCallback({item =>}, {ecode =>})
                )
            }
            .shape(ShapeType.CircleType)
            .height(200.px)
            .backgroundColor(Color(0, 0, 0))
    }

    // control button constructor
    @Builder
    private func ControlBtn(msg: String, jsscript: String, suc_cb: (String) -> Unit, err_cb: (Int32) -> Unit) {
        Button(msg)
            .onClick {
                evt => webController.runJavaScript(jsscript, JsCallback(suc_cb, err_cb))
            }
            .height(200.px)
            .backgroundColor(Color(0, 0, 0))
    }

    // webview constructor
    @Builder
    private func WebPlayground() {
        Web(src: @rawfile("index.html"), controller: webController)
            .width(80.percent)
            .height(40.percent)
            .onPageBegin {
                evt => if (!isloaded) {
                    webController.registerJavaScriptProxy(
                        [
                            {
                                s: String =>
                                game_sta = "Game Over!"
                                return ""
                            },
                            {
                                s: String =>
                                score_now = Int64.parse(s)
                                return ""
                            }
                        ],
                        "CjObj",
                        ["gameover", "getscore"]
                    )
                    isloaded = true
                    webController.refresh()
                }
            }
    }

    // JavaScript-callback constructor
    private func JsCallback(suc_cb: (String) -> Unit, err_cb: (Int32) -> Unit): AsyncCallback<String> {
        return {
            errorCode: ?AsyncError, data: ?String => match (errorCode) {
                case Some(e) => err_cb(e.code)
                case _ => match (data) {
                    case Some(value) => suc_cb(value)
                    case _ => suc_cb("undefined")
                }
            }
        }
    }
}
