package searchcomponent

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.prompt_action.*

@Component
public class SearchComponent {
    @State var geometryId: String = ""  //组件内隐式共享元素专场id
    var isFoldable: Bool = AppStorage.get<Bool>("isFoldable") ?? false

    protected override func aboutToAppear(): Unit {
    }

    func build() {
        //顶部搜索框
        Column() {
            Search(placeholder: "搜索")
            .backgroundColor(0xE7E9E8)
            .focusOnTouch(false)
            .focusable(false)
            //.enableKeyboardOnFocus(false)   // FIXME: 仓颉缺少该接口
            .width(if (this.isFoldable) {100.percent} else {353})
            .height(43)
            .onClick({ event =>
                PromptAction.showToast(message: "功能暂未开放")
            })
            .geometryTransition(geometryId, followWithoutTransition: true)
            //.transition() // TODO
            .backgroundColor(0xE7E9E8)
            .borderRadius(24)
        }
        .width(100.percent)
        //.bindContentCover(isShow: Bool, builder: () -> Unit, contentCoverOptions: ContentCoverOptions)    //TODO
        .alignItems(HorizontalAlign.Center)
        .padding(
            left: if (this.isFoldable) {16} else {0},
            right:  if (this.isFoldable) {16} else {0},
        )
    }
}