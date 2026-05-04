package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.components.home.Home
import ohos_app_cangjie_entry.components.me.Me
import ohos_app_cangjie_entry.components.message.Message
import std.collection.ArrayList
import ohos_app_cangjie_entry.models.{TabBar, Temp}
import cj_res_entry.app
import ohos_app_cangjie_entry.constants.*


@Entry
@Component
class MyView {
    @StorageLink["bottomRectHeight"] var bottomRectHeight: Length = Length(0, unitType : LengthType.px)
    @StorageLink["topRectHeight"] var topRectHeight: Length = Length(0, unitType : LengthType.px)

    func build() {
    	Column() {
            Home()
    	}
        // TODO 这里手动设置避让安全区，如果后面tabs 默认躲避 安全区，可以再修改
        .padding(top: px2vp(this.topRectHeight) ?? this.topRectHeight,
            bottom: px2vp(this.bottomRectHeight) ?? this.bottomRectHeight)
        // TODO 如果后面tabs 默认躲避 安全区，可以设置tabs的背景色即可
        .backgroundColor(@r(app.color.background_secondary))
        // TODO 后面tabs 默认支持安全区避让特性，可以删除
        .expandSafeArea(types: [SafeAreaType.SYSTEM], edges: [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
        .height(100.percent)
        .width(100.percent)
    }
}