/**
 * Created on 2024/9/5
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.display.*
import ohos.state_macro_manage.*

public func getHistoryItemColor(index: Int64): Color {
    if(index == AppStorage.get<Int64>("historyIndex").getOrThrow()) {
        return themes[AppStorage.get<Int64>("themeIndex").getOrThrow()].foregroundColor
    }
    return Color(0x333333)
}

@Component
public class History {
    @StorageLink["history"] var history: ObservedArrayList<String> = ObservedArrayList<String>([])
    @StorageLink["historyIndex"] var historyIndex: Int64 = 0
    @StorageLink["themeIndex"] var themeIndex: Int64 = 0

    func build() {
        List(space: 0, initialIndex: 0) {
            ForEach(
                history,
                itemGeneratorFunc: {
                    item: String, index: Int64 => ListItem() {
                        Text(formatExpression(item))
                        .fontColor(getHistoryItemColor(index))
                        .fontSize(20)
                    }
                    .backgroundColor(0xFAFAFA)
                    .borderRadius(10)
                    .padding(top: 10.vp, left: 10.vp, right: 10.vp, bottom: 0.vp)
                }
            )
        }
        .width(100.percent)
    }
}

