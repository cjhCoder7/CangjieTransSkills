package ohos_app_cangjie_entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.constants.*
import ohos_app_cangjie_entry.components.*

let storage = LocalStorage()

@Entry[storage]
@Component
class EntryView {
    @StorageProp['topRectHeight']
    let topRectHeight: Length = 0.vp

    func build() {
        Column {
            Title()
            Blank()
            SeatMap()
            Blank()
            Card()
        }
        .padding(top: topRectHeight, bottom: 10.vp)
        .width(StyleConstants.FULL_WIDTH)
        .height(StyleConstants.FULL_HEIGHT)
        .backgroundColor(StyleConstants.BACKGROUND_COLOR)
    }
}
