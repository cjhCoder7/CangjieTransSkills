/**
 * Created on 2024/9/5
 */
package ohos_app_cangjie_entry.Component

import cj_res_entry.app
import ohos_app_cangjie_entry.Model.*
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.*
import std.collection.ArrayList

@Component
public class SearchDelete {
    @State
    var searchInput: String = '';
    @Link
    var searchArrList: ObservedArrayList<String>

    func build() {
        Flex(FlexParams(direction: FlexDirection.Row, alignItems: ItemAlign.Center)) {
            if (this.searchArrList.size > 0) {
                Text("最近搜索").fontSize(16).fontWeight(FontWeight.W500).height(3.percent).margin(left: 12)
                Blank()
                Image(@r(app.media.ic_delete)).height(3.percent).width(7.percent).margin(right: 15).onClick(
                    {
                    event => this.searchArrList.clear()
                })
            } else {
                Column() {
                    Image(@r(app.media.ic_no_search)).height(15.percent).width(33.percent).margin(top: 170, bottom: 8)
                    Text("没有搜索内容").fontSize(16)
                }.width(100.percent).justifyContent(FlexAlign.Center)
            }
        }
    }
}
