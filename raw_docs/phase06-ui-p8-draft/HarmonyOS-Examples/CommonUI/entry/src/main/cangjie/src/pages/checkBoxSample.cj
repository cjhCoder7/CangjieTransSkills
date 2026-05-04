/**
 * Created on 2024/5/14
 */
package ohos_app_cangjie_entry.pages

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Entry
@Component
class CheckBoxView {
    func build() {
        Row() {
            Checkbox(name: "checkbox1", group: "checkboxGroup")
            .size(height: 100.vp, width: 100.vp)
            .select(true)
            .selectedColor(Color(0xed6f21))
            .onChange({ value: Bool =>
                BaseLog.info("Checkbox1 change is" + value.toString())
            })
            Checkbox(name: "checkbox2", group: "checkboxGroup")
            .size(height: 100.vp, width: 100.vp)
            .select(false)
            .selectedColor(Color(0x39a2db))
            .onChange({ value: Bool =>
                BaseLog.info("Checkbox2 change is" + value.toString())
            })
        }
    }
}