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
public class SearchLayout {
    @State
    var searchInput: String = '';
    @Link
    var searchArrList: ObservedArrayList<String>

    func build() {
        Flex(
            FlexParams(direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center,
            wrap: FlexWrap.Wrap)) {
            if (this.searchArrList.size > 0) {
                ForEach(
                    this.searchArrList,
                    itemGeneratorFunc: {
                        item: String, index: Int64 => Text(item).fontSize(12).textAlign(TextAlign.Center).fontWeight(
                            FontWeight.W400).borderRadius(20).backgroundColor(0xE5E8EA).margin(right: 8, top: 8).padding(
                            top: 8, bottom: 8, left: 16, right: 16)
                    }
                )
            }
        }.margin(left: 12, right: 12)
    }
}
