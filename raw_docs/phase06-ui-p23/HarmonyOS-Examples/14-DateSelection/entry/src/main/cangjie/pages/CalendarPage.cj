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
import std.collection.ArrayList
import ohos_app_cangjie_entry.model.*
import std.time.*
import ohos.hilog.*
import std.unittest.testmacro.Test
import encoding.json.JsonObject
import encoding.json.JsonValue
import encoding.json.JsonString
import encoding.json.JsonInt

//日期选择界面
@Entry
@Component
class CalendarPage {
    let today = DateTime.now()

    @State var currentYear: Int64 = 0
    @State var currentDay: MyDay = MyDay(today.addDays(-1))
    @State var currentMonth: MyMonth = MyMonth(today.addMonths(-1))
    @State var nextMonth: MyMonth = MyMonth(today.addMonths(-1))
    @State var contentData: ArrayList<MyMonth> = ArrayList<MyMonth>()
    @State var DateLsit1: ArrayList<Int64> = ArrayList<Int64>()
    @State var DateLsit2: ArrayList<Int64> = ArrayList<Int64>()
    @State var startCheckDate: Int64 = -1
    @State var endCheckDate: Int64 = -1
    @State var startCheckMonth: Int64 = -1
    @State var endCheckMonth: Int64 = -1
    @State var startCheckWeekDay: Int64 = -1
    @State var endCheckWeekDay: Int64 = -1

    @State var returnParams: JsonObject = JsonObject()

    private let week: Array<String> = ["日","一","二","三","四","五","六"]

    public func aboutToAppear() {
        this.initData()
    }

    func build() {
        Column (12){
            this.weekBuilder()
            this.dataBuilder()
            this.buttonBuilder()
        }
        .padding(top: 12, bottom: 12)
        .width(100.percent)
        .height(85.percent)
        .borderRadius(16)
        .backgroundColor(Color.WHITE)
        .alignItems(HorizontalAlign.Center)
    }

    //获取时间
    func initData() {
        this.currentYear = today.year
        this.currentDay = MyDay(today)
        this.currentMonth = MyMonth(today)
        this.nextMonth = MyMonth(today.addMonths(1))

        this.contentData.append(this.currentMonth)
        this.contentData.append(this.nextMonth)
    }

    //加载日历标题
    @Builder
  func itemHead(month: MyMonth) {
        Text("${month.getYear()}年 ${month.getMonth()}月")
        .fontSize(16)
        .fontWeight(W400)
        .width(100.percent)
        .height(20)
        .margin(left: 20)
  }

    //创建星期
    @Builder
    func weekBuilder() {
        List {
            ForEach(this.week, itemGeneratorFunc: { weekInformation: String, _: Int64 =>
                        ListItem {
                            Text(weekInformation)
                            .textAlign(TextAlign.Center)
                            .width(100.percent)
                            .height(100.percent)
                            .fontColor(@r(app.color.week_font_color))
                        }
                        .width(14.3.percent)
                    })
        }
        .backgroundColor(@r(app.color.background))
        .width(100.percent)
        .height(30)
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
    }

    //日历日期
    @Builder
    func dataBuilder() {
        List {
            ForEach(this.contentData, itemGeneratorFunc: { monthItem: MyMonth, _: Int64 =>
                        ListItemGroup(ListItemGroupParams(header:{=>bind(this.itemHead,this)(monthItem)})) {
                            ListItem {
                                Stack {
                                    Grid {
                                        ForEach(monthItem.getDateList(), itemGeneratorFunc: { day: Int64,_: Int64 =>
                                                GridItem {
                                                    Stack {
                                                        Text(day.toString())
                                                        .zIndex(999)
                                                        .fontSize(16)
                                                        .fontWeight(W400)
                                                        .fontColor(
                                                            if (day == this.startCheckDate && monthItem.getMonth() == this.startCheckMonth || day == this.endCheckDate && monthItem.getMonth() == this.endCheckMonth) {
                                                                Color.WHITE.toUInt32()
                                                            } else {
                                                                Color.BLACK.toUInt32()
                                                            })
                                                        .width(100.percent)
                                                        .height(100.percent)
                                                        .textAlign(TextAlign.Center)
                                                        .borderRadius(10)
                                                        .onClick{ e =>
                                                                    if(day >= this.currentDay.getDate() && monthItem.getMonth() == this.currentMonth.getMonth() || monthItem.getMonth() == this.nextMonth.getMonth() && day >= monthItem.getStartDay().getDate()) {
                                                                    if(this.startCheckMonth == -1) {
                                                                        this.startCheckMonth = monthItem.getMonth()
                                                                        this.startCheckDate = day
                                                                    } else if(this.endCheckMonth == -1) {
                                                                        if(monthItem.getMonth() > this.startCheckMonth || monthItem.getMonth() == this.startCheckMonth && day > this.startCheckDate) {
                                                                            this.endCheckMonth = monthItem.getMonth()
                                                                            this.endCheckDate = day
                                                                        } else {
                                                                            this.startCheckMonth = monthItem.getMonth()
                                                                            this.startCheckDate = day
                                                                        }
                                                                    } else {
                                                                        this.startCheckMonth = monthItem.getMonth()
                                                                        this.startCheckDate = day
                                                                        this.endCheckMonth = -1
                                                                        this.endCheckDate = -1
                                                                    }
                                                                    }
                                                                }
                                                            if (day == this.startCheckDate && monthItem.getMonth() == this.startCheckMonth) {
                                                                Column {
                                                                    Text("")
                                                                    Text(@r(app.string.check_in))
                                                                    .fontSize(12)
                                                                    .fontWeight(W400)
                                                                    .fontColor(Color.WHITE)
                                                                    .margin(top: 40)
                                                                }
                                                                .borderRadius(5)
                                                                .backgroundColor(@r(app.color.selected_background_color))
                                                                .width(90.percent)
                                                                .height(95.percent)
                                                            } else if(day == this.endCheckDate && monthItem.getMonth() == this.endCheckMonth) {
                                                                Column {
                                                                    Text("")
                                                                    Text(@r(app.string.check_out))
                                                                    .fontSize(12)
                                                                    .fontWeight(W400)
                                                                    .fontColor(Color.WHITE)
                                                                    .margin(top: 40)
                                                                }
                                                                .borderRadius(5)
                                                                .backgroundColor(@r(app.color.selected_background_color))
                                                                .width(90.percent)
                                                                .height(95.percent)
                                                                } else if(this.endCheckMonth != -1 && (day + monthItem.getMonth() * 100) > (this.startCheckDate + this.startCheckMonth * 100) && (day + monthItem.getMonth() * 100) < (this.endCheckDate + this.endCheckMonth * 100)) {
                                                                    Text("")
                                                                    .backgroundColor(@r(app.color.middle_background_color))
                                                                    .width(100.percent)
                                                                    .height(95.percent)
                                                                }
                                                                }
                                                            }.opacity(
                                                            if (day == 0) {
                                                                0
                                                            } else {
                                                                1
                                                            })

                                            })
                                }
                                .backgroundColor(Color.WHITE)
                                .columnsTemplate("1fr 1fr 1fr 1fr 1fr 1fr 1fr")
                                // 当前月显示的数组元素个数大于35则显示6行，否则显示5行
                                .rowsTemplate(
                                    if (monthItem.getDateList().size > 35) {
                                        "1fr 1fr 1fr 1fr 1fr 1fr"
                                        }else {
              	                                "1fr 1fr 1fr 1fr 1fr"
                                                })
                                .height(if (monthItem.getDateList().size > 35) {
                                            360
                                        } else {
              	                            300
                                            })
                            }
                        }
                    }
            })
        }.height(90.percent)
        .width(100.percent)
        .edgeEffect(EdgeEffect.None)
        .scrollBar(BarState.Off)
        .sticky(StickyStyle.Header)
    }

    //创建按钮
    @Builder
    func buttonBuilder() {
        Column {
            Row {
                Text(@r(app.string.check_in))
                .fontWeight(W400)
                .fontSize(14)
                .fontColor(@r(app.color.week_font_color))
                .margin(left: 16)

                Text(@r(app.string.check_out))
                .fontWeight(W400)
                .fontSize(14)
                .fontColor(@r(app.color.week_font_color))
                .margin(left: 200)

                }
                .width(100.percent)

            Row {
                Text(
                    if(this.startCheckDate == -1) {
                        ""
                    } else {
                        "${this.startCheckMonth}月 ${this.startCheckDate}日"
                    }
                )
                .fontWeight(W500)
                .fontSize(16)
                .width(100)
                .margin(left: 14)

                Text('-')
                .fontSize(16)
                .fontWeight(W500)
                .margin(left: 70)

                Text(
                    if(this.endCheckDate == -1) {
                        ""
                    } else {
                        "${this.endCheckMonth}月 ${this.endCheckDate}日"
                    }
                )
                .fontWeight(W500)
                .fontSize(16)
                .width(100)
                .margin(left: 50)
            }
            .width(100.percent)
            .height(50)

            Button(@r(app.string.confirm))
            .backgroundColor(@r(app.color.selected_background_color))
            .onClick{ evt =>
                    if(this.startCheckDate>= 0 && this.endCheckDate >= 0) {
                        returnParams.put("startCheckDate",JsonInt(this.startCheckDate))
                        returnParams.put("endCheckDate",JsonInt(this.endCheckDate))
                        returnParams.put("startCheckMonth",JsonInt(this.startCheckMonth))
                        returnParams.put("endCheckMonth",JsonInt(this.endCheckMonth))
                    }
                    Router.back(url: "MainPage",params: returnParams)
            }
            .margin(top: 10)
            .width(90.percent)
        }
        .height(100.percent)
    }
}