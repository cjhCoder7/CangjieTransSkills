package ohos_app_cangjie_entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

import ohos_app_cangjie_entry.views.*
import ohos_app_cangjie_entry.constants.StyleConstants

let storage = LocalStorage()

@Entry[storage]
@Component
class EntryView {
    @StorageProp['topRectHeight']
    let topRectHeight: Length = 0.vp

    @StorageProp['bottomRectHeight']
    let bottomRectHeight: Length = 0.vp

    func build() {
        Column {
            Title()

            Content()
        }
        .width(StyleConstants.FULL_WIDTH)
        .height(StyleConstants.FULL_HEIGHT)
        .padding(top: topRectHeight, bottom: bottomRectHeight)
    }
}
