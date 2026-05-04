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
public class SearchInput {
    @State
    var searchInput: String = '';
    @Link
    var searchArrList: ObservedArrayList<String>
    let controller = SearchController()

    func build() {
        Flex(FlexParams(direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center)) {
            Image(@r(app.media.ic_public_arrow_left)).width(16).height(16).margin(left: 10).onClick(
                {
                event => Router.back()
            })
            Search(value: this.searchInput, placeholder: "Type to search", controller: controller).width(75.percent).
                height(5.percent).backgroundColor(Color.WHITE).placeholderColor(0x787F87).onChange(
                {
                value => this.searchInput = value
            }).margin(left: 12, right: 12, bottom: 8, top: 8)
            Text("搜索").fontSize(16).fontColor(0x007DFF).margin(right: 8).onClick(
                {
                    event =>
                    if (this.searchInput != '' && this.searchInput.trimAscii().size > 0) {
                        this.searchArrList.prepend(this.searchInput.trimAscii())
                    }
                    this.searchInput = ''
                }
            )
        }.width(100.percent)
    }
}
