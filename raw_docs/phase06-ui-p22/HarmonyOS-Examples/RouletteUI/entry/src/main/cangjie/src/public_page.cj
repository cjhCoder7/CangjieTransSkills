/**
 * Created on 2024/8/31
 */
package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.Router
import ohos_app_cangjie_entry.common.component.{PublicPageTop,PublicPageBody}

@Entry
@Component
class PublicPage {

    @State var label:String = Router.getParams().getOrThrow()

    protected override func aboutToAppear() {
        AppStorage.setOrCreate<ObservedArrayList<String>>("textList", ObservedArrayList<String>(["鸿蒙","鸿蒙","鸿蒙"]))
        AppStorage.setOrCreate<String>("text", "今天学习什么！！")
    }

    func build() {
        Column() {
            PublicPageTop(label:this.label)
            PublicPageBody(label:this.label)
        }.padding(left:15,right:15)
    }
}
