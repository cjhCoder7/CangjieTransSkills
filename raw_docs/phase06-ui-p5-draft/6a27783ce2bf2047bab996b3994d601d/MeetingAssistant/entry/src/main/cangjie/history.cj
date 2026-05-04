package ohos_app_cangjie_entry

import ohos.component.Text
import ohos.component.Button
import ohos.component.Column
import ohos.component.CustomView
import ohos.state_manage.LocalStorage
import ohos.state_manage.ObservedProperty
import ohos.state_manage.SubscriberManager
import ohos.state_manage.ViewStackProcessor
import ohos.state_macro_manage.State
import ohos.state_macro_manage.Component
import ohos.state_macro_manage.HybridComponentEntry
import ohos.hybrid_base.CJPageEntry
import ohos.hybrid_base.HybridComponentBase
import cj_res_entry.app

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.r
import ohos.state_macro_manage.State
import ohos.state_macro_manage.*
import cj_res_entry.*
import std.collection.ArrayList

class MeetingRecord {
    var id: Int64
    var title: String
    var typeR: String // "video" or "audio"
    var date: String
    var time: String
    var duration: String
    var hasNotes: Bool

    init(id: Int64, title: String, typeR: String, date: String, time: String, duration: String, hasNotes: Bool) {
        this.id = id
        this.title = title
        this.typeR = typeR
        this.date = date
        this.time = time
        this.duration = duration
        this.hasNotes = hasNotes
    }
}

@HybridComponentEntry
@Component
class History {
    @State
    var activeFilter: String = "全部"

    @State
    var searchText: String = ""

    let filters = ["全部", "视频会议", "录音文件", "有纪要"]

    let meetings = ArrayList<MeetingRecord>([
        MeetingRecord(1, "Q4产品规划会议", "video", "今天", "14:30", "45分钟", true),
        MeetingRecord(2, "技术架构评审", "video", "昨天", "10:00", "1小时20分", true),
        MeetingRecord(3, "客户需求讨论", "audio", "11月27日", "15:00", "30分钟", false),
        MeetingRecord(4, "团队周会", "video", "11月25日", "09:30", "50分钟", true),
        MeetingRecord(5, "项目复盘会议", "audio", "11月22日", "14:00", "40分钟", true)
    ])

    func build() {
        Stack(Alignment.Bottom) {
            Scroll() {
                Column() {
                    // 标题栏
                    Row() {
                        Column() {
                            Text("历史记录")
                                .fontSize(24)
                                .fontWeight(FontWeight.Bold)
                                .fontColor(0x000000)
                            Text("共 23 条会议记录")
                                .fontSize(14)
                                .fontColor(0x999999)
                                .margin(top: 4)
                        }
                        .alignItems(HorizontalAlign.Start)

                        Blank()

                        // Calendar Button
                        Row() {
                            Image(@r(app.media.ic_calendar))
                                .width(20)
                                .height(20)
                        }
                        .width(40)
                        .height(40)
                        .borderRadius(20)
                        .backgroundColor(0xF5F5F5)
                        .justifyContent(FlexAlign.Center)
                    }
                    .width(100.percent)
                    .padding(left: 20, right: 20, top: 16)

                    // 搜索栏
                    Row() {
                        Row() {
                            Image(@r(app.media.ic_search))
                                .width(20)
                                .height(20)

                            TextInput(text: searchText, placeholder: "搜索会议...")
                                .fontSize(14)
                                .fontColor(0x000000)
                                .backgroundColor(0xFAFAFA)
                                .layoutWeight(1)
                                .margin(left: 12)
                                .onChange { val => this.searchText = val }
                        }
                        .layoutWeight(1)
                        .height(48)
                        .padding(left: 16, right: 16)
                        .backgroundColor(0xFAFAFA)
                        .borderRadius(12)

                        // Filter Button
                        Row() {
                            Image(@r(app.media.ic_filter))
                                .width(20)
                                .height(20)
                        }
                        .width(48)
                        .height(48)
                        .borderRadius(12)
                        .backgroundColor(0xF5F5F5)
                        .margin(left: 12)
                        .justifyContent(FlexAlign.Center)
                    }
                    .width(100.percent)
                    .padding(left: 20, right: 20, top: 24)

                    // 快捷筛选
                    Scroll() {
                        Row() {
                            ForEach(filters, { filter: String, index: Int64 =>
                                Text(filter)
                                    .fontSize(14)
                                    .fontWeight(FontWeight.Medium)
                                    .fontColor(if (activeFilter == filter) { 0xFFFFFF } else { 0x000000 })
                                    .backgroundColor(if (activeFilter == filter) { 0x000000 } else { 0xF5F5F5 })
                                    .borderRadius(20)
                                    .padding(left: 16, right: 16, top: 8, bottom: 8)
                                    .margin(right: 8)
                                    .onClick { _ =>
                                        this.activeFilter = filter
                                    }
                            })
                        }
                        .padding(left: 20, right: 12)
                    }
                    .scrollable(ScrollDirection.Horizontal)
                    .scrollBar(BarState.Off)
                    .width(100.percent)
                    .margin(top: 16)

                    // 会议列表
                    Column() {
                        ForEach(meetings, { meeting: MeetingRecord, index: Int64 =>
                            Row() {
                                // Icon Box
                                Row() {
                                    Image(if (meeting.typeR == "video") { @r(app.media.ic_video) } else { @r(app.media.ic_mic) })
                                        .width(24)
                                        .height(24)
                                }
                                .width(48)
                                .height(48)
                                .borderRadius(12)
                                .backgroundColor(0xEEEEEE)
                                .justifyContent(FlexAlign.Center)
                                .margin(right: 12)

                                // Content
                                Column() {
                                    Text(meeting.title)
                                        .fontSize(16)
                                        .fontWeight(FontWeight.Medium)
                                        .fontColor(0x000000)
                                        .maxLines(1)
                                        .textOverflow(TextOverflow.Ellipsis)
                                        .margin(bottom: 4)

                                    Row() {
                                        Text(meeting.date)
                                            .fontSize(12)
                                            .fontColor(0x999999)
                                        Text(" · ")
                                            .fontSize(12)
                                            .fontColor(0xDDDDDD)
                                        Text(meeting.time)
                                            .fontSize(12)
                                            .fontColor(0x999999)
                                        Text(" · ")
                                            .fontSize(12)
                                            .fontColor(0xDDDDDD)

                                        Image(@r(app.media.ic_clock))
                                            .width(12)
                                            .height(12)
                                            .margin(right: 4)

                                        Text(meeting.duration)
                                            .fontSize(12)
                                            .fontColor(0x999999)
                                    }
                                }
                                .layoutWeight(1)
                                .alignItems(HorizontalAlign.Start)

                                // Generated Tag
                                if (meeting.hasNotes) {
                                    Text("已生成")
                                        .fontSize(12)
                                        .fontColor(0x4CAF50)
                                        .backgroundColor(0xE8F5E9)
                                        .padding(top: 4, bottom: 4, left: 8, right: 8)
                                        .borderRadius(4)
                                }

                                // Arrow
                                Image(@r(app.media.ic_chevron_right))
                                    .width(16)
                                    .height(16)
                                    .margin(left: 8)
                            }
                            .width(100.percent)
                            .padding(top: 12, bottom: 12)
                            .backgroundColor(0xFFFFFF)
                            .margin(bottom: 8)
                        })
                    }
                    .padding(left: 20, right: 20, top: 16)
                }
            }
            .width(100.percent)
            .height(100.percent)
            .align(Alignment.Top)
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(0xFFFFFF)
    }
}
