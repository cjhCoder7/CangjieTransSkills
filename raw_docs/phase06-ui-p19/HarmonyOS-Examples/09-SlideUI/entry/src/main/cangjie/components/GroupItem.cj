/**
 * Created on 2025/7/31
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.ArrayList

extend Text {
    func itemTextSty(_curFontColor: Color) {
        this.textOverflow(TextOverflow.Ellipsis).fontColor(_curFontColor).fontSize(12).margin(top: 5, bottom: 5)
    }
}

@Component
public class GroupItem {
    @Prop var data: ArrayList<Array<String>>
    let colorArr: ArrayList<Color> = ArrayList<Color>([Color(0x999d9c), Color.BLACK])
    public func build() {
        Column {
            Row {
                ForEach(data, { colItems: Array<String>, _: Int64 =>
                    Column {
                        ForEach(colItems, { item: String, idx: Int64 =>
                            Text(item).itemTextSty(colorArr[idx % 2])
                        })
                    }
                    .width(50.percent)
                    .alignItems(HorizontalAlign.Start)
                    .justifyContent(FlexAlign.Start)
                })
            }
            .width(100.percent)
        }
        .width(90.percent)
    }
}