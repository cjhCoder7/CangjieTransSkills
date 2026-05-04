package ohos_app_cangjie_entry

internal import ohos.base.LengthProp
internal import ohos.component.Column
internal import ohos.component.Row
internal import ohos.component.Button
internal import ohos.component.Text
internal import ohos.component.CustomView
internal import ohos.component.CJEntry
internal import ohos.component.loadNativeView
internal import ohos.state_manage.SubscriberManager
internal import ohos.state_manage.ObservedProperty
internal import ohos.state_manage.LocalStorage
import ohos.state_macro_manage.Entry
import ohos.state_macro_manage.Component
import ohos.state_macro_manage.State
import ohos.state_macro_manage.r

@Entry
@Component
class EntryView {
    @State
    var power: Option<Int64> = 68
    @State
    var isCharging: Bool = true

    func build() {
        Column {
            ElectricQuantity(power: power, isCharging: isCharging)

            Slider(
                value: Float64(power ?? 0),
                min: 0.0,
                max: 100.0,
                step: 1.0,
                style: SliderStyle.OutSet
            ).onChange {
                value, mode => power = Int64(value)
            }.margin(top: 30)

            Row(10) {
                Text("充电中：")
                Toggle(ToggleType.SwitchType, isOn: isCharging).onChange {
                    isOn => isCharging = isOn
                }
            }
        }.padding(top: 100)
    }
}
