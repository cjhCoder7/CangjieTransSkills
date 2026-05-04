package ohos_app_cangjie_entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.app
import ohos.resource_manager.ResourceManager
import ohos.ability.getStageContext
import ohos_app_cangjie_entry.components.*
import ohos_app_cangjie_entry.dataModel.*

import std.time.*
import std.collection.*

extend Column {
    func tabColStyle(offset: Length) {
        let topPadding = px2vp(offset)
        let topVp = { topPadding: ?Length =>
            match(topPadding) {
                case Some(length) => return length
                case None => return 0.vp
            }
        }(topPadding)
        this.padding(top: topVp)
        this.height(100.percent)
    }
}

@Entry
@Component
class EntryView {
    let currentTime = DateTime.now()
    let dayOfWeek = currentTime.dayOfWeek
    let weekDay = dayOfWeek.value()

    var currentIndex: Int32 = 2
    var controller: TabsController = TabsController()

    var bottomRectHeight: Length = 0.px
    var topRectHeight: Length = 0.px

    let stageContext = getStageContext(MainAbility.abilityContext.getOrThrow())
    let resMgr = ResourceManager.getResourceManager(stageContext)

    // 星期几的资源
    let classficationNamesRes = @r(app.strarray.classificationNames)
    @State var classificationNames: Array<String> = resMgr.getStringArrayValue(Int32(classficationNamesRes.id))
    @State var weekdaysScroller: Scroller = Scroller()

    // 节数的资源
    let classIndexRes = @r(app.strarray.classIndex)
    @State var classIndex: Array<String> = resMgr.getStringArrayValue(Int32(classIndexRes.id))
    let classTimeRes = @r(app.strarray.classTime)
    @State var classTime: Array<String> = resMgr.getStringArrayValue(Int32(classTimeRes.id))

    @State var classScroller: Scroller = Scroller()
    @State var timeScroller: Scroller = Scroller()
    @State var verticalScroller: Scroller = Scroller()
    @State var horizontalScroller: Scroller = Scroller()

    func build() {
        Column {
            Tabs(BarPosition.End, this.controller, this.currentIndex) {
                TabContent {
                    Column().tabColStyle(topRectHeight)
                }
                .tabBar(icon: "/resources/base/media/main_page.svg", text: "主页")

                TabContent {
                    Column().tabColStyle(topRectHeight)
                }
                .tabBar(icon: "/resources/base/media/message.svg", text: "消息")

                TabContent {
                    Column {
                        BackRow()
                        // 节行以下
                        Column {
                            // 节行
                            SectionRow(weekdaysScroller: weekdaysScroller, classificationNames: classificationNames, horizontalScroller: horizontalScroller)

                            // 第几节，时间，课程
                            Row {
                                // 第几节 + 上课时间
                                SectionTime(classIndex: classIndex, classScroller: classScroller, verticalScroller: verticalScroller, timeScroller: timeScroller, classTime: classTime)
                                // 课表
                                Course(horizontalScroller: horizontalScroller, verticalScroller: verticalScroller, classScroller: classScroller, timeScroller: timeScroller, weekdaysScroller: weekdaysScroller)
                            }
                            .position(x: 0, y: 42)
                            .width(100.percent)
                            .height(94.percent)
                            .backgroundColor(Color.WHITE)
                        }
                        .height(88.percent)
                        .width(100.percent)
                        // todo onAppear
                        .onAppear({ =>
                            if(this.weekDay > 1) {
                                this.weekdaysScroller.scrollTo(xOffset: (this.weekDay - 1) * 120, yOffset: 0)
                                this.horizontalScroller.scrollTo(xOffset: (this.weekDay - 1) * 120, yOffset: 0)
                            }
                        })
                    }
                    .tabColStyle(topRectHeight)
                }
                .tabBar(icon: "/resources/base/media/course_table_unclicked.svg", text:"课表")
            }
            .onChange({index: Int32 => this.currentIndex = index
                    nativeLog(currentIndex.toString())
                })
            .barWidth(100.percent)
            .barHeight(80)
            .barMode(BarMode.Fixed)
            .width(100.percent)
            .backgroundColor(Color(0xFFF1F3F5))
        }
        .width(100.percent)
        .height(100.percent)
    }
}
