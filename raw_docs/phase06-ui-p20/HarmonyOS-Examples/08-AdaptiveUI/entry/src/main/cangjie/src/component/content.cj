/**
 * Created on 2025/7/17
 */
package ohos_app_cangjie_entry.component

internal import ohos_app_cangjie_entry.common.*
import ohos.state_macro_manage.*

// 歌单内容，包含封面和音乐列表
@Component
public class Content {
    @State var deviceType: String = AppStorage.get<String>("deviceType").getOrThrow()
    func build() {
        GridRow { // 默认分为 12 栅格
            GridCol {
                PlayListCover(deviceType: deviceType)
            }.span(GridColColumnOption(sm: 12, md: 6, lg: 4))
            GridCol {
                PlayerList(deviceType: deviceType)
            }.span(GridColColumnOption(sm: 12, md: 6, lg: 8))
        }
        .width(100.percent)
        .height(83.percent)
        .onBreakpointChange {
            bp: String => this.deviceType = bp
        }
    }
}

func adjust<T>(deviceType: String, xs!: T, sm!: T, md!: T, lg!: T, other!: T): T {
    match (deviceType) {
        case "xs" => xs
        case "sm" => sm
        case "md" => md
        case "lg" => lg
        case _ => other
    }
}

@Component
class PlayListCover {
    @Link var deviceType: String
    private let toolBarInfo: Array<(CJResource, String)> = [
        (@r(app.media.heart), "999+"),
        (@r(app.media.ellipsis_message), "评论"),
        (@r(app.media.star), "收藏"),
        (@r(app.media.trash), "删除")
    ]

    func sizeChange(ty: String): Length {
        adjust(ty, xs: 100.vp, sm: 100.vp, md: 200.vp, lg: 200.vp, other: 200.vp)
    }

    func build() {
        Column {
            GridRow { // 默认分为 12 栅格，每个 GridCol 自适应调整
                // 封面图片
                GridCol {
                    Image(@r(app.media.music_background)).size(
                        width: sizeChange(deviceType),
                        height: sizeChange(deviceType)
                    )
                }.span(GridColColumnOption(sm: 4, md: 12, lg: 12))
                // 封面标题
                GridCol {
                    Column(6) {
                        Text("清明雨揽月的歌单")
                            .fontSize(22.fp)
                            .fontWeight(FontWeight.Medium)
                        Text("创建者很懒，什么都没有留下哦～")
                            .fontSize(14.fp)
                    }
                    .width(100.percent)
                    .height(sizeChange(deviceType))
                    .alignItems(adjust(deviceType, xs: HorizontalAlign.Start, sm: HorizontalAlign.Start,
                            md: HorizontalAlign.Center, lg: HorizontalAlign.Center, other: HorizontalAlign.Center))
                    .justifyContent(FlexAlign.Center)
                }.span(GridColColumnOption(sm: 8, md: 12, lg: 12))
                // 控制栏
                GridCol {
                    Row {
                        ForEach(toolBarInfo, { item: (CJResource, String), _: Int64 =>
                             Column(5) {
                                Image(item[0])
                                    .size(width: 24, height: 24)
                                    .fillColor(Color.BLACK)
                                Text(item[1]).fontSize(14.fp)
                            }.layoutWeight(1)
                        })
                    }.offset(x: 0, y: 5)
                }.span(GridColColumnOption(sm: 12, md: 12, lg: 12))
            }
            .width(100.percent)
        }
        .height(adjust(deviceType, xs: 30.percent, sm: 30.percent, md: 100.percent, lg: 100.percent, other: 100.percent))
        .justifyContent(FlexAlign.Center)
    }
}

// 音乐列表
@Component
class PlayerList {
    @Link var deviceType: String

    @Builder
    func listItem(item: (String, String)) {
        Row {
            Column(5) {
                Text(item[0]).fontWeight(FontWeight.Normal).fontSize(16.fp)
                Row(5) {
                    Text('vip')
                        .fontSize(12.fp).fontColor(Color.RED).padding(1)
                        .borderColor(Color.RED).borderRadius(5).borderWidth(1)
                    Text(item[1])
                        .fontSize(12.fp).fontColor(@r(app.color.font_secondary))
                }
            }.alignItems(HorizontalAlign.Start)
            Button {
                Image(@r(app.media.identify_song)).size(width: 22, height: 22)
            }
            .shape(ShapeType.Normal)
            .borderRadius(10)
            .padding(5)
            .backgroundColor(Color.WHITE)
        }
        .width(100.percent)
        .padding(10)
        .justifyContent(FlexAlign.SpaceBetween)
    }

    func build() {
        List {
            ForEach(MUSIC_LIST, { item: (String, String), _: Int64 =>
                ListItem { listItem(item) }
            })
        }
        .divider(strokeWidth: 0.5.vp, color: Color.GRAY)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .borderRadius(10.vp)
        .height(adjust(deviceType, xs: 70.percent, sm: 70.percent, md: 100.percent, lg: 100.percent, other: 100.percent))
        .backgroundColor(@r(app.color.bg_primary))
    }
}
