/**
 * Created on 2025/7/18
 */
package ohos_app_cangjie_entry.pages

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.app
import ohos.router.Router
import encoding.json.JsonObject
import ohos.hilog.Hilog
import encoding.json.JsonString
import encoding.json.JsonValue

//主界面
@Entry
@Component
class MainPage {

    //底部导航栏参数
    var controller: TabsController = TabsController()
    @State var currentIndex: Int32 = 0

    //预定日期参数
    @State
    var startDate: String = ""
    @State
    var endDate: String = ""

    //日历页面返回参数
    @State var params: JsonObject = JsonObject()

    //tabs入口
    func build() {
        Column {
                this.tabBuilder()

        }.padding(top: 0, bottom: 0)
        .backgroundColor(@r(app.color.background))
    }

    //更新预定信息
    protected override func onPageShow() {
        this.params = Router.getParamsObject()
        if (params.get("startCheckDate").isSome() && params.get("endCheckDate").isSome()) {
            this.startDate = tostring(params.get("startCheckMonth"))+ "月" + tostring(params.get("startCheckDate")) + "日"
            this.endDate = tostring(params.get("endCheckMonth"))+ "月" + tostring(params.get("endCheckDate")) + "日"
        }
    }

    //jsonobject转换为字符串
    func tostring (item: ?JsonValue): String{
        return match (item) {
            case Some(s) => "${s}"
            case None => ""
        }
    }

    //创建标题
     @Builder
     func titleBuilder() {
        Column {
            Text(@r(app.string.room_detail))
            .fontWeight(FontWeight.W500)
            .fontSize(18)
            .margin(top: 5)
            .width(100.percent) // 添加宽度约束
            .textAlign(TextAlign.Center) // 明确对齐方式

            Image(@r(app.media.room))
            .width(350)
            .height(155)
            .margin(top: 20)
        }
    }

    // 创建房间详情界面
     @Builder
    func roomDetail() {
        Column {
            Text(@r(app.string.room_description))
            .fontSize(18)
            .fontWeight(W700)
            .margin(top: 16, left: 7)

            Text(@r(app.string.location))
            .fontSize(12)
            .fontWeight(W400)
            .opacity(0.4)
            .margin(top: 14, left: 7)

            Text(@r(app.string.price))
            .fontSize(24)
            .fontWeight(W700)
            .fontColor(@r(app.color.price_font_color))
            .margin(top: 14, left: 7)
        }
        .margin(top: 12)
        .alignItems(HorizontalAlign.Start)
        .width(350)
        .height(122)
        .borderRadius(16)
        .backgroundColor(Color.WHITE)

    }

    //房间预定界面
    @Builder
    private func roomReservation() {
        Column {
            Row {
                Image(@r(app.media.house))
                .width(18)
                .height(18)

                Text(@r(app.string.room_description1))
                .fontWeight(W400)
                .fontSize(14)
                .margin(left: 6)
                }
                .margin(top: 14, left: 7)

            Row {
                Text(@r(app.string.room_name))
                .fontWeight(W500)
                .fontSize(16)

                Text(@r(app.string.price))
                .fontWeight(W700)
                .fontSize(20)
                .margin(left: 200)
                }
                .margin(top: 14, left: 7)

              Column {
                Row {
                    Text(@r(app.string.check_in_data))
                    .fontWeight(W400)
                    .fontSize(12)
                    .opacity(0.5)
                    .margin(left: 7)

                    Text(@r(app.string.check_out_data))
                    .fontWeight(W400)
                    .fontSize(12)
                    .opacity(0.5)
                    .margin(left: 220)
                }
                .margin(top: 10)
                .width(100.percent)

                Row {
                    Text(this.startDate)
                    .fontWeight(W500)
                    .fontSize(16)
                    .margin(left: 8)
                    .width(100)
                    Text(this.endDate)
                    .fontWeight(W500)
                    .fontSize(16)
                    .margin(left: 130)
                    .width(100)
                }
                .margin(top: 10)
                .width(100.percent)
            }
        }
        .margin(top: 12)
        .alignItems(HorizontalAlign.Start)
        .width(350)
        .height(150)
        .borderRadius(16)
        .backgroundColor(Color.WHITE)
        .onClick { e => Router.push(url: "CalendarPage")
        }
    }

    //创建Tabs
    @Builder
    private func tabBuilder() {
       Column {
            Tabs(BarPosition.End, this.controller) {
                TabContent {
                        Column {
                            //将组件放进房间界面
                            this.titleBuilder()
                            this.roomDetail()
                            this.roomReservation()
                        }
                        .width(100.percent)
                        .height(100.percent)
                }
                .tabBar(icon:"/resources/base/media/house_tab.svg", text: @r(app.string.room))
                .id("tab0")

                TabContent {
                        Column {
                            Text(@r(app.string.facility))
                            .textAlign(TextAlign.Center)
                            .fontSize(50)
                            .fontColor(0x182431)
                            .opacity(0.4)
                            .height(100.percent)
                        }
                        .width(100.percent)
                        .height(100.percent)
                }
                .tabBar(icon: "/resources/base/media/facility.svg", text: @r(app.string.facility))
                .id("tab1")

                TabContent {
                        Column {
                            Text(@r(app.string.mine))
                            .textAlign(TextAlign.Center)
                            .fontSize(50)
                            .fontColor(0x182431)
                            .opacity(0.4)
                            .height(100.percent)
                        }
                        .width(100.percent)
                        .height(100.percent)
                }
                .tabBar(icon: "/resources/base/media/mine.svg", text: @r(app.string.mine))
                .id("tab2")
            }
            .vertical(false)
            .scrollable(true)
            .barMode(BarMode.Fixed)
            .barWidth(100.percent)
            .barHeight(70)
            .animationDuration(400)
            .width(100.percent)
            .backgroundColor(0xF5F5F5)
            .onChange({index: Int32  => this.currentIndex = index})
            .padding(bottom: 0)
        }
        .width(100.percent)
        .height(100.percent)
        .margin(top: 5)
    }
}