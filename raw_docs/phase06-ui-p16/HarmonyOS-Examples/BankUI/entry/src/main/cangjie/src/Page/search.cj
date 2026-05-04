/**
 * Created on 2024/9/5
 */
package ohos_app_cangjie_entry.Page

import cj_res_entry.app
import ohos_app_cangjie_entry.Component.*
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.ArrayList

@Entry
@Component
public class Search {
    @State
    var searchArrList: ObservedArrayList<String> = ObservedArrayList<String>('基金', '仓颉', 'cangjie', 'HarmonyOS',
        'Bank')
    @State
    var searchInput: String = ''

    func build() {
        Column() {
            SearchInput(searchArrList: this.searchArrList)
            SearchDelete(searchArrList: this.searchArrList)
            SearchLayout(searchArrList: this.searchArrList)
        }.backgroundColor(0xF1F3F5).width(100.percent).height(100.percent).alignItems(HorizontalAlign.Center)
    }
}
