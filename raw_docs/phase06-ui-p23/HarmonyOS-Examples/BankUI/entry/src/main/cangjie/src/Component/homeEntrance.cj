/**
 * Created on 2024/8/30
 */
package ohos_app_cangjie_entry.Component

import ohos_app_cangjie_entry.Model.*
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class HomeEntrance {
    func build() {
        Column() {
            Grid {
                ForEach(
                    EntranceList,
                    itemGeneratorFunc: {
                        item: iconItem, index: Int64 => GridItem {
                            Column(){
                                Image(item.getImage()).width(30).height(30).margin(bottom: 4)
                                Text(item.getTitle()).fontSize(10).textAlign(TextAlign.Center).fontWeight(FontWeight.W400)
                            }
                        }
                    }
                )
            }.columnsTemplate('1fr 1fr 1fr 1fr 1fr').rowsTemplate('1fr 1fr')
            .width(100.percent).height(120).padding(left: 12, right: 12).backgroundColor(0xFFFFFF).borderRadius(16)
        }
        .padding(left: 16, right: 16)
    }
}
