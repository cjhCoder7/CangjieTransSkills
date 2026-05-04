package ohos_app_cangjie_SlowFeet.Pages

import ohos_app_cangjie_SlowFeet.Model.*
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.*
import std.convert.*
import std.collection.*

@Entry
@Component
public class VideoView {
    var controller: VideoController = VideoController()
    @State
    var playing: Bool = false
    @State
    var duration: Float64 = 0.0
    @State
    var currentTime: Float64 = 0.0
    @State
    var comment: Bool = false
    @State
    var recommended: Bool = false

    var data: Array<VideoModel> = [
        VideoModel("我爱玩原神34", "2077 年 7 月 7 日", "黑熊精转世实录", "/resources/base/media/video.mp4", 12.0,
            "我爱玩原神34 创作的原声", this.controller, true),
        VideoModel("我爱玩原神34", "2077 年 7 月 7 日", "黑熊精转世实录", "/resources/base/media/video.mp4", 12.0,
            "我爱玩原神34 创作的原声", this.controller, true),
        VideoModel("我爱玩原神34", "2077 年 7 月 7 日", "黑熊精转世实录", "/resources/base/media/video.mp4", 12.0,
            "我爱玩原神34 创作的原声", this.controller, true),
        VideoModel("我爱玩原神34", "2077 年 7 月 7 日", "黑熊精转世实录", "/resources/base/media/video.mp4", 12.0,
            "我爱玩原神34 创作的原声", this.controller, true)
    ]

    func build() {
        Column {
            Stack {
                Swiper() {
                    ForEach(
                        data,
                        itemGeneratorFunc: {
                            item: VideoModel, index: Int64 => Stack {
                                Stack() {
                                    Stack() {
                                        Video(src: item.video, controller: item.controller).width(100.percent).height(
                                            100.percent).objectFit(ImageFit.Contain).loop(true).autoPlay(true).controls(
                                            false).onPrepared(
                                            {
                                                time =>
                                                this.duration = Float64.parse(time.toString() + ".0")
                                                item.controller.start()
                                            }
                                        ).onStart(
                                            {
                                                =>
                                                item.play = true
                                                this.playing = true
                                            }
                                        ).onPause(
                                            {
                                                =>
                                                item.play = false
                                                this.playing = false
                                            }
                                        ).onClick(
                                            {
                                            _ => if (item.play) {
                                                item.controller.pause();
                                            } else {
                                                item.controller.start();
                                            }
                                        }).onVisibleAreaChange(
                                            [0.0, 1.0],
                                            {
                                                isVisible, currentRatio => if (isVisible && currentRatio >= 1.0) {
                                                    item.controller.start();
                                                }
                                            }
                                        ).onUpdate({time => this.currentTime = Float64.parse(time.toString() + ".0")})
                                        SideBars(comment: comment)
                                    }.width(100.percent).height(100.percent).padding(0.fp).alignment(Alignment.BottomEnd)
                                    infobar(item.author, item.description, item.date)
                                    Row() {
                                        Row() {
                                            Image("/resources/base/media/music.svg").height(14.fp).width(14.fp)
                                            Text(item.audio).fontSize(12).maxLines(1).width(item.audio.size * 12).fontColor(
                                                Color.WHITE).height(20.fp).textOverflow(TextOverflow.Ellipsis).layoutWeight(
                                                1).margin(left: 3.fp)
                                        }.width(66.percent)
                                        Row() {
                                            Text("19.9 亿人用过").fontSize(11).fontColor(Color.WHITE).margin(right: 3.fp)
                                            Image("/resources/base/media/chevron_right.svg").width(12.fp)
                                        }.layoutWeight(1).justifyContent(FlexAlign.End)
                                    }.width(100.percent).height(40.fp).backgroundColor(Color(0, 0, 0, alpha: 0.3)).padding(
                                        left: 12.fp, right: 12.fp)
                                    // TODO: 还有亿点 BUG
    //                                Slider(value: this.currentTime, min: 0.0, max: this.duration, step: 1.0, style: SliderStyle.OutSet).onChange({
    //                                    time, _ =>
    //                                    this.controller.setCurrentTime(Int32.parse(time.toString().split('.')[0]), SeekMode.Accurate)
    //                                }).width(100.percent).trackThickness(1.fp).trackColor(Color(240, 240, 240, alpha: 0.85)).selectedColor(0xFFFFFF).margin(bottom: 30.fp)
                                }.width(100.percent).height(100.percent).padding(0).alignment(Alignment.BottomStart)
                                if (!this.playing) {
                                    Image("/resources/base/media/play.svg").height(80.fp).width(80.fp).onClick(
                                        {
                                            _ =>
                                            item.controller.start();
                                            item.play = true
                                            this.playing = true
                                        }
                                    ).opacity(0.5)
                                }
                                if (this.comment) {
                                    Stack() {
                                        Column().width(100.percent).height(100.percent).backgroundColor(Color(0xC0, 0xC0, 0xC0, alpha: 0.6)).onClick({_ => this.comment = false})
                                        Column {
                                            Row {
                                                Text("0 条评论")
                                            }.height(10.percent)
                                            Divider()
                                            List {
                                                ListItem {
                                                }
                                            }.height(75.percent)
                                            Row {
                                                TextInput(placeholder: "说点什么吧 ...").width(70.percent).margin(2.5.percent)
                                                Button("发送").width(20.percent).margin(2.5.percent)
                                            }.height(15.percent)
                                        }.backgroundColor(0xFFFFFF).borderRadius(topLeft: 10.fp, topRight: 10.fp).width(100.percent).height(60.percent).margin(top: 40.percent)
                                    }.width(100.percent).height(100.percent).alignment(Alignment.BottomStart)
                                }
                            }.width(100.percent).height(100.percent).padding(0).alignment(Alignment.Center)
                        }
                    )
                }.width(100.percent).height(100.percent).autoPlay(false).indicator(false).loop(true).vertical(true).
                    cachedCount(0).itemSpace(0).curve(Curve.Ease)
                if(!this.recommended) { Image("/resources/base/media/chevron_left.svg").width(20.fp).height(20.fp).position(x: 20.fp, y: 20.fp).onClick({_ => Router.back()}) }
            }.width(100.percent).height(100.percent)
        }.width(100.percent).height(100.percent).expandSafeArea(edges:[SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]).backgroundColor(0x000000)
    }

    @Builder
    func infobar(name: String, description: String, time: String) {
        Column() {
            Row {
                Text("@" + name).fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.WHITE)
                Text(time).fontSize(10).fontColor(Color.WHITE).margin(left: 10.fp)
            }.margin(bottom: 8.fp)
            Text(description).fontSize(14).fontColor(Color.WHITE).width(80.percent).maxLines(2).textOverflow(
                TextOverflow.Ellipsis)
        }.padding(left: 10.fp).alignItems(HorizontalAlign.Start).width(80.percent).margin(bottom: 50.fp)
    }
}

@Component
class SideBars {
    @Link var comment: Bool
    @State
    var likeCount: Int = 399
    @State
    var commentCount: Int = 0
    @State
    var favoriteCount: Int = 299
    @State
    var shareCount: Int = 149
    @State
    var isLike: Bool = false
    @State
    var isFavorite: Bool = false

    func build() {
        Column() {
            // TODO: 关注
            Column {
                Image("/resources/base/media/genshin.png").width(45.fp).height(45.fp).borderRadius(114514).borderColor(
                    Color.WHITE).borderWidth(1.fp)
            }.width(45.percent).height(45.fp).margin(bottom: 25.fp)
            Column() {
                if (!this.isLike) {
                    Image("/resources/base/media/like.svg").height(30.fp).width(30.fp).onClick(
                        {
                            _ =>
                            this.isLike = true
                            this.likeCount++
                        }
                    ).margin(bottom: 5.fp)
                } else {
                    Image("/resources/base/media/liked.svg").height(30.fp).width(30.fp).onClick(
                        {
                            _ =>
                            this.isLike = false
                            this.likeCount--
                        }
                    ).margin(bottom: 5.fp)
                }
                Text(this.likeCount.toString()).fontSize(10.fp).fontColor(Color.WHITE)
            }.width(60.percent).height(60.fp).opacity(0.9)

            Column() {
                Image("/resources/base/media/discuss.svg").height(30.fp).width(30.fp).margin(bottom: 5.fp).onClick({_ => this.comment = true})
                Text(this.commentCount.toString()).fontSize(10.fp).fontColor(Color.WHITE)
            }.width(60.percent).height(60.fp).opacity(0.9)

            Column() {
                if (!this.isFavorite) {
                    Image("/resources/base/media/star.svg").height(30.fp).width(30.fp).onClick(
                        {
                            _ =>
                            this.isFavorite = true
                            this.favoriteCount++
                        }
                    ).margin(bottom: 5.fp)
                } else {
                    Image("/resources/base/media/stared.svg").height(30.fp).width(30.fp).onClick(
                        {
                            _ =>
                            this.isFavorite = false
                            this.favoriteCount--
                        }
                    ).margin(bottom: 5.fp)
                }
                Text(this.favoriteCount.toString()).fontSize(10.fp).fontColor(Color.WHITE)
            }.width(60.percent).height(60.fp).opacity(0.9)

            Column() {
                Image("/resources/base/media/share.svg").height(30.fp).width(30.fp)
                Text("分享").fontSize(10.fp).fontColor(Color.WHITE)
            }.width(60.percent).height(50.fp).opacity(0.9)
        }.margin(bottom: 36.fp).height(70.percent).width(60.fp).justifyContent(FlexAlign.End).align(Alignment.Bottom).expandSafeArea()
    }
}

// TODO: [B#1] 创建后会致使程序崩溃
class Videos <: IDataSource<VideoModel> {
    public Videos(var data_: ArrayList<VideoModel>) {}
    public var listenerOp: Option<DataChangeListener> = None
    public func getData(index: Int): VideoModel {
        data_[index]
    }
    public func onRegisterDataChangeListener(listener: DataChangeListener): Unit {
        listenerOp = listener
    }
    public func onUnregisterDataChangeListener(listener: DataChangeListener): Unit {
        listenerOp = None
    }
    public func totalCount(): Int {
        data_.size
    }
}
