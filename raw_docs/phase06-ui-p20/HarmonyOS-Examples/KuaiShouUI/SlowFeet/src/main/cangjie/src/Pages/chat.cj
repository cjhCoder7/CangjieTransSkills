package ohos_app_cangjie_SlowFeet.Pages

import ohos_app_cangjie_SlowFeet.Model.*
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.*

@Entry
@Component
class ChatView {
    @State
    var chats: ObservedArrayList<ChatModel> = ObservedArrayList<ChatModel>([ChatModel("感谢关注，二手车批发请联系微信：mournink。")]);
    @State
    var text: String = "";
    func build() {
        Column {
            Row {
                Row {
                    Button("<").onClick({ _ => Router.back() }).backgroundColor(0xffffff).foregroundColor(0x000000).margin(10.fp).width(40.fp).height(40.fp).borderRadius(114514)
                    Image("/resources/base/media/fontaine.png").width(40.fp).height(40.fp).borderRadius(114514).margin(10.fp)
                    Text("枫丹二手车批发").margin(5.fp)
                }.height(100.percent).width(80.percent)
                Row {
                    Button("=").backgroundColor(0xffffff).backgroundColor(0xffffff).foregroundColor(0x000000).margin(10.fp).width(40.fp).height(40.fp).borderRadius(114514)
                }.height(100.percent).width(20.percent).justifyContent(FlexAlign.End)
            }.height(10.percent).width(100.percent).expandSafeArea(types: [SafeAreaType.KEYBOARD], edges: [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
            List {
                ForEach(this.chats, { item: ChatModel, _: Int64 => ListItem{ chatBuilder(item) }.width(100.percent) })
            }.height(80.percent).width(100.percent).expandSafeArea(types: [SafeAreaType.KEYBOARD], edges: [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
            Row {
                TextInput(placeholder: "输入消息", text: this.text).margin(5.fp).width(80.percent).onChange({ content => this.text = content })
                Button("↑").width(10.percent).margin(5.fp).fontWeight(FontWeight.Bolder).enabled(this.text != "").onClick(send)
            }.height(10.percent)
        }.height(100.percent).expandSafeArea(types: [SafeAreaType.SYSTEM], edges: [SafeAreaEdge.BOTTOM])
    }
    func send() {
        if(this.text == "") { () }
        this.chats.append(ChatModel(this.text, from: false))
        this.text = ""
        ()
    }
    @Builder
    func chatBuilder(chat: ChatModel) {
        if (chat.from) {
            Row {
                Row {
                    Row{
                        Text(chat.message).fontColor(0xFFFFFF).padding(10.fp)
                    }.backgroundColor(0xCBCBCB).borderRadius(topLeft: 20.fp, topRight: 20.fp, bottomLeft: 0.fp, bottomRight: 20.fp)
                }.width(80.percent).margin(10.fp).justifyContent(FlexAlign.Start)
            }.justifyContent(FlexAlign.Start).width(100.percent)
        } else {
            Row {
                Row {
                    Row{
                        Text(chat.message).fontColor(0xFFFFFF).padding(10.fp)
                    }.backgroundColor(0x0A59F7).borderRadius(topLeft: 20.fp, topRight: 20.fp, bottomLeft: 20.fp, bottomRight: 0.fp)
                }.width(80.percent).margin(10.fp).justifyContent(FlexAlign.End)
            }.justifyContent(FlexAlign.End).width(100.percent)
        }
    }
}
