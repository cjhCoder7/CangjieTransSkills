package ohos_app_cangjie_entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

import ohos_app_cangjie_entry.components.*
import std.collection.ArrayList
import std.math.abs
import cj_res_entry.app
import ohos_app_cangjie_entry.datas.*
import ohos.ability.*

func getContext(): AbilityContext {
    match(globalAbilityContext) {
        case Some(context) => context
        case _ => throw Exception("can not get globalAbilityContext.")
    }
}

@Entry
@Component
class EntryView {
    @State var isShow: Bool = false
    @State var isShowDown: Bool = true
    var xStart: Float64 = 0.0
    var xEnd: Float64 = 0.0
    @State var msgTxt: String = 'AIS信息'
    @State var miniTxt: String = '微档案'
    @State var weatherTxt: String = '气象信息'
    @State var msgData: ArrayList<Array<String>> = MsgData().data
    @State var miniData: ArrayList<Array<String>> = MiniData().data
    @State var weatherData: ArrayList<Array<String>> = WeatherData().data
    @State var abilityContext: AbilityContext = getContext()

    public var listScroller: Scroller = Scroller()

    func build() {
        Stack(Alignment.TopStart) {
            RelativeContainer {
                if (!this.isShow) {
                    MyTop(isShow: isShow, isShowDown: isShowDown, abilityContext: abilityContext)
                }

                if (this.isShow) {
                    Column {}
                    .id('_padding')
                    .width(100.percent)
                    .height(100.percent)
                    .backgroundColor(Color(0, 0, 0, alpha: 0.4))
                    .alignRules(AlignRuleOption(right: HorizontalAnchor('__container__', HorizontalAlign.End)))
                    .onClick{
                        evt =>
                            this.isShow = false
                            this.isShowDown = true
                    }

                    StatusHead(isShow: isShow)

                    List(space: 11, scroller: this.listScroller) {
                        ShipImg(isShow: isShow, isShowDown: isShowDown)
                        ShipDirection()
                        MsgItem(msgTxt: msgTxt, data: msgData)
                        MsgItem(msgTxt: miniTxt, data: miniData)
                        MsgItem(msgTxt: weatherTxt, data: weatherData)
                    }
                    .alignListItem(ListItemAlign.Start)
                    .id('scrollPart')
                    .alignRules(AlignRuleOption(top: VerticalAnchor('statusHead', VerticalAlign.Bottom), left: HorizontalAnchor('__container__', HorizontalAlign.Start)))
                    .width(290)
                    .height(100.percent)
                    .padding(bottom: 60)
                    .edgeEffect(EdgeEffect.None)
                    .scrollBar(BarState.Off)
                    .backgroundColor(Color.WHITE)
                    .onTouch({ event =>
                        match (event.eventType) {
                        	case TouchType.Down => this.xStart = event.touches[0].x
                            case TouchType.Up =>
                                this.xEnd = event.touches[0].x
                                var moveWidth = abs(xStart - xEnd)
                                if (moveWidth >= 90.0 && xEnd < xStart) {
                                    this.isShow = false
                                } else {
                                    this.isShow = true
                                }
                            case _ => ()
                        }
                    })
                    .align(Alignment.Start)
                }
            }
            .backgroundImage(src: @r(app.media.background_map))
            .transition(TransitionEffect.opacity(0.99))
        }
        .transition(TransitionEffect.opacity(0.99))
    }
}
