package ohos_app_cangjie_SlowFeet

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.*
import ohos_app_cangjie_SlowFeet.Pages.*

@Entry
@Component
class MyView {
    func build() {
        Tabs(BarPosition.End) {
            TabContent {
                Tabs(BarPosition.Start) {
                    TabContent {}.tabBar(icon: "/resources/base/media/public_drawer.svg", text: "").enabled(false)
                    TabContent {
                        Column {
                            Row {
                                TextInput(placeholder: "搜索").width(70.percent).margin(2.5.percent).height(80.percent)
                                Button("搜索").width(15.percent).margin(2.5.percent).height(80.percent)
                            }.height(8.percent)
                            List {
                                // TIP: 电商应该统一规定图片高度，所以用不到 WaterFlow
                                ListItem {
                                    this.GoodsInfo(@r(app.media.goods1), "枫丹 99 新二手摩托", "9w+", "9.99K",
                                        video: true)
                                }.width(97.percent).margin(1.5.percent)
                                ListItem {this.GoodsInfo(@r(app.media.goods1), "枫丹 99 新二手摩托", "9w+", "9.99K")}.
                                    width(97.percent).margin(1.5.percent)
                                ListItem {this.GoodsInfo(@r(app.media.goods1), "枫丹 99 新二手摩托", "9w+", "9.99K")}.
                                    width(97.percent).margin(1.5.percent)
                                ListItem {this.GoodsInfo(@r(app.media.goods1), "枫丹 99 新二手摩托", "9w+", "9.99K")}.
                                    width(97.percent).margin(1.5.percent)
                                ListItem {this.GoodsInfo(@r(app.media.goods1), "枫丹 99 新二手摩托", "9w+", "9.99K")}.
                                    width(97.percent).margin(1.5.percent)
                                ListItem {this.GoodsInfo(@r(app.media.goods1), "枫丹 99 新二手摩托", "9w+", "9.99K")}.
                                    width(97.percent).margin(1.5.percent)
                                ListItem {this.GoodsInfo(@r(app.media.goods1), "枫丹 99 新二手摩托", "9w+", "9.99K")}.
                                    width(97.percent).margin(1.5.percent)
                                ListItem {this.GoodsInfo(@r(app.media.goods1), "枫丹 99 新二手摩托", "9w+", "9.99K")}.
                                    width(97.percent).margin(1.5.percent)
                                ListItem {this.GoodsInfo(@r(app.media.goods1), "枫丹 99 新二手摩托", "9w+", "9.99K")}.
                                    width(97.percent).margin(1.5.percent)
                                ListItem {this.GoodsInfo(@r(app.media.goods1), "枫丹 99 新二手摩托", "9w+", "9.99K")}.
                                    width(97.percent).margin(1.5.percent)
                            }.lanes(2).width(98.percent).height(92.percent).scrollBar(BarState.Off)
                        }
                    }.tabBar("商城").backgroundColor(0xF0F0F0)
                    TabContent {
                        Column {
                            Row {
                                Text("———— 你还没有关注谁哦 ————").fontColor(0x7F7F7F)
                            }
                        }
                    }.tabBar("关注").backgroundColor(0xF0F0F0)
                    TabContent {
                        // TODO: 等有 WaterFlow 了再改
                        List {
                            ListItem {this.VideoInfo(@r(app.media.cover), @r(app.media.user_portrait), "孙善雅", "-999")}.
                                width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.cover2), @r(app.media.user_portrait), "秋秋醒了_", "11")
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.cover3), @r(app.media.genshin), "我爱玩原神34", "100w+")
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.live_cover), @r(app.media.user_portrait), "黑神话", "9k+",
                                    living: true)
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {this.VideoInfo(@r(app.media.cover), @r(app.media.user_portrait), "孙善雅", "-999")}.
                                width(97.percent).margin(1.5.percent)
                            ListItem {this.VideoInfo(@r(app.media.cover), @r(app.media.user_portrait), "孙善雅", "-999")}.
                                width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.cover2), @r(app.media.user_portrait), "秋秋醒了_", "11")
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {this.VideoInfo(@r(app.media.cover), @r(app.media.user_portrait), "孙善雅", "-999")}.
                                width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.cover2), @r(app.media.user_portrait), "秋秋醒了_", "11")
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.cover2), @r(app.media.user_portrait), "秋秋醒了_", "11")
                            }.width(97.percent).margin(1.5.percent)
                        }.lanes(2).width(98.percent).height(100.percent).scrollBar(BarState.Off)
                    }.tabBar("发现").backgroundColor(0xF0F0F0)
                    TabContent {
                        List {
                            ListItem {this.VideoInfo(@r(app.media.cover), @r(app.media.user_portrait), "孙善雅", "-999")}.
                                width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.cover2), @r(app.media.user_portrait), "秋秋醒了_", "11")
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.cover3), @r(app.media.genshin), "我爱玩原神34", "100w+")
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.live_cover), @r(app.media.user_portrait), "黑神话", "9k+",
                                    living: true)
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {this.VideoInfo(@r(app.media.cover), @r(app.media.user_portrait), "孙善雅", "-999")}.
                                width(97.percent).margin(1.5.percent)
                            ListItem {this.VideoInfo(@r(app.media.cover), @r(app.media.user_portrait), "孙善雅", "-999")}.
                                width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.cover2), @r(app.media.user_portrait), "秋秋醒了_", "11")
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {this.VideoInfo(@r(app.media.cover), @r(app.media.user_portrait), "孙善雅", "-999")}.
                                width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.cover2), @r(app.media.user_portrait), "秋秋醒了_", "11")
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.cover2), @r(app.media.user_portrait), "秋秋醒了_", "11")
                            }.width(97.percent).margin(1.5.percent)
                        }.lanes(2).width(98.percent).height(100.percent).scrollBar(BarState.Off)
                    }.tabBar("同城").backgroundColor(0xF0F0F0)
                    TabContent {
                        List {
                            ListItem {
                                this.VideoInfo(@r(app.media.live_cover), @r(app.media.user_portrait), "黑神话", "9k+",
                                    living: true)
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.live_cover), @r(app.media.user_portrait), "黑神话", "9k+",
                                    living: true)
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.live_cover), @r(app.media.user_portrait), "黑神话", "9k+",
                                    living: true)
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.live_cover), @r(app.media.user_portrait), "黑神话", "9k+",
                                    living: true)
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.live_cover), @r(app.media.user_portrait), "黑神话", "9k+",
                                    living: true)
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.live_cover), @r(app.media.user_portrait), "黑神话", "9k+",
                                    living: true)
                            }.width(97.percent).margin(1.5.percent)
                            ListItem {
                                this.VideoInfo(@r(app.media.live_cover), @r(app.media.user_portrait), "黑神话", "9k+",
                                    living: true)
                            }.width(97.percent).margin(1.5.percent)
                        }.lanes(2).width(98.percent).height(100.percent).scrollBar(BarState.Off)
                    }.tabBar("直播").backgroundColor(0xF0F0F0)
                    TabContent {}.tabBar(icon: "/resources/base/media/public_search.svg", text: "").enabled(false)
                }.scrollable(false).index(3)
            }.tabBar("首页")
            TabContent {
                // TODO: 变个色
                VideoView( recommended: true )
            }.tabBar("精选")
            TabContent {
                Row {
                    Column {
                        Text("请先登录").decoration(decorationType: TextDecorationType.LineThrough, color: 0x000000).
                            fontSize(30)
                        Button("登录").enabled(false)
                    }
                }
            }.tabBar(icon: "/resources/base/media/public_add_norm.svg", text: "")
            TabContent {
                ColumnSplit {
                    Row {
                        Text("消息").fontSize(22).fontWeight(FontWeight.Bold)
                    }.width(100.percent).height(8.percent).justifyContent(FlexAlign.Center)
                    List {
                        ListItem {this.ChatInfo(@r(app.media.genshin), "我爱玩原神34", "谢谢关注~来了就是一家人", "8-24"
                            )}
                        ListItem {
                            this.ChatInfo(@r(app.media.fontaine), "枫丹二手车批发",
                                "感谢关注，二手车请联系微信：mournink", "8-24")
                        }
                        ListItem {this.ChatInfo(@r(app.media.furrina), "娜姐《收徒》", "感谢你这么好看还关注我😜", "8-24"
                            )}
                        ListItem {this.ChatInfo(@r(app.media.user_portrait), "TA", "该用户存在违规行为，消息不可见",
                                "23-9")}
                        ListItem {this.ChatInfo(@r(app.media.user_portrait), "TA", "该用户存在违规行为，消息不可见",
                                "23-8")}
                        ListItem {this.ChatInfo(@r(app.media.user_portrait), "TA", "该用户存在违规行为，消息不可见",
                                "23-8")}
                        ListItem {this.ChatInfo(@r(app.media.user_portrait), "TA", "该用户存在违规行为，消息不可见",
                                "23-6")}
                        ListItem {this.ChatInfo(@r(app.media.user_portrait), "TA", "该用户存在违规行为，消息不可见",
                                "23-4")}
                        ListItem {this.ChatInfo(@r(app.media.user_portrait), "TA", "该用户存在违规行为，消息不可见",
                                "22-7")}
                        ListItem {this.ChatInfo(@r(app.media.user_portrait), "TA", "该用户存在违规行为，消息不可见",
                                "22-2")}
                        ListItem {this.ChatInfo(@r(app.media.user_portrait), "TA", "该用户存在违规行为，消息不可见",
                                "22-1")}
                        ListItem {this.ChatInfo(@r(app.media.user_portrait), "TA", "该用户存在违规行为，消息不可见",
                                "21-3")}
                        ListItem {this.ChatInfo(@r(app.media.user_portrait), "TA", "该用户存在违规行为，消息不可见",
                                "21-3")}
                        ListItem {this.ChatInfo(@r(app.media.user_portrait), "TA", "该用户存在违规行为，消息不可见",
                                "21-2")}
                        ListItem {
                            this.ChatInfo(@r(app.media.user_portrait), "TA", "该用户存在违规行为，消息不可见", "20-11")
                        }
                        ListItem {this.ChatInfo(@r(app.media.user_portrait), "TA", "该用户存在违规行为，消息不可见",
                                "20-9")}
                        ListItem {
                            this.ChatInfo(@r(app.media.user_portrait), "TA", "该用户存在违规行为，消息不可见", "19-12")
                        }
                    }.width(100.percent).height(92.percent).scrollBar(BarState.Off)
                }.width(100.percent)
            }.tabBar("消息").groupDefaultFocus(true)
            TabContent {
                UserInfo()
            }.tabBar("我")
        }.scrollable(false)
    }

    @Builder
    func GoodsInfo(pic: CJResource, name: String, sold: String, price: String, video!: Bool = false) {
        Stack {
            Column {
                Image(pic).width(100.percent).borderRadius(topLeft: 2.fp, topRight: 2.fp, bottomLeft: 0.fp,
                    bottomRight: 0.fp)
                Column {
                    Text(name).maxLines(1).textOverflow(TextOverflow.Ellipsis).width(90.percent).margin(5.fp)
                    Text("已售 ${sold} 件").maxLines(1).textOverflow(TextOverflow.Ellipsis).width(90.percent).fontWeight(
                        FontWeight.Lighter).fontSize(11)
                    Text("惊爆价 ￥${price}").fontColor(0xF44444).fontWeight(FontWeight.Bold).fontSize(14).width(
                        90.percent).margin(5.fp)
                } // .height(70.fp)
            }.borderRadius(2.fp).backgroundColor(0xFFFFFF)
            if (video) {
                Row {
                    Image(@r(app.media.replay)).height(20.fp).margin(5.fp)
                    Text("讲解回放").fontColor(0xFFFFFF).fontSize(10).margin(5.fp)
                }.height(30.fp).backgroundColor(Color(0, 0, 0, alpha: 0.5)).position(x: 10.fp, y: 10.fp).borderRadius(
                    10.fp)
            }
        }
    }

    @Builder
    func ChatInfo(head: CJResource, title: String, message: String, time: String, notify!: Bool = false) {
        Row {
            Column {
                Image(head).width(70.percent).height(70.percent).borderRadius(114514)
            }.width(22.percent).height(100.percent).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).
                align(Alignment.Center)
            Column {
                Text(title).fontWeight(FontWeight.Bold).fontSize(16)
                Text(message).foregroundColor(0x888888).textOverflow(TextOverflow.Ellipsis).width(90.percent).maxLines(
                    1)
            }.width(64.percent).height(100.percent).alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Center)
            Column {
                Text(time).foregroundColor(0xCCCCCC)
                // TODO: 这个红点还有点毛病，再看看
                if (notify) {
                    Text("").foregroundColor(Color.RED)
                } else {
                    Text("").foregroundColor(Color.RED)
                }
            }.width(14.percent).height(100.percent).alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Center)
        }.height(13.percent).onClick({
            event => Router.push(url: "ChatView")
        })
    }

    @Builder
    func VideoInfo(pic: CJResource, head: CJResource, name: String, like: String, living!: Bool = false) {
        Stack {
            Column {
                Image(pic).width(100.percent).borderRadius(topLeft: 2.fp, topRight: 2.fp, bottomLeft: 0.fp,
                    bottomRight: 0.fp)
                Row {
                    Row {
                        Image(head).width(25.fp).margin(5.fp).borderRadius(114514)
                        Text(name).fontSize(12).fontColor(0x000000)
                    }.width(50.percent).justifyContent(FlexAlign.Start)
                    Row {
                        if (living) {
                            Image(@r(app.media.eye)).width(15.fp)
                        } else {
                            Image(@r(app.media.heart)).width(15.fp)
                        }
                        Text(like).fontSize(12).margin(5.fp)
                    }.width(50.percent).justifyContent(FlexAlign.End)
                }.height(35.fp)
            }.borderRadius(2.fp).backgroundColor(0xFFFFFF)
            if (living) {
                Row {
                    Image(@r(app.media.dot_radiowaves_left_and_right)).height(20.fp).margin(5.fp)
                    Text("直播中").fontColor(0xFFFFFF).fontSize(10).margin(5.fp)
                }.height(30.fp).backgroundColor(Color(0, 0, 0, alpha: 0.5)).position(x: 10.fp, y: 10.fp).borderRadius(
                    10.fp)
            }
        }.onClick({_ => if(!living) {Router.push(url: "VideoView")} else {/* TODO: 直播页 */}})
    }
}
