/**
 * Created on 2024/9/7
 */
package ohos_app_cangjie_entry.common.component

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class PublicPageBody {
    @Prop
    var label: String

    func build() {
        Column() {
            if (this.label == "转盘列表") {
                TurnTableList()
            } else if (this.label == "创建" || this.label == "编辑") {
                FoundAndEdit(label : label)
            }
        }
    }
}
