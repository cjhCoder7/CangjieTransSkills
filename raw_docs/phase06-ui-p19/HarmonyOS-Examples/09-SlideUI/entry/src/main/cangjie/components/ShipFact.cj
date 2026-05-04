/**
 * Created on 2025/7/29
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.app

extend Text {
    func texSty(curWidth: Int64) {
        this.width(curWidth.percent).maxLines(1).textOverflow(TextOverflow.Ellipsis).fontSize(15).fontWeight(FontWeight.W400)
    }
}

extend Row {
    func rowSty() {
        this.width(92.percent).justifyContent(FlexAlign.SpaceBetween)
    }
}

@Component
public class ShipFact {
    public func build() {
        Column(15) {
            rowItem('MMSI： 41345623', '航向： 106.0°')
            rowItem('邮轮;靠泊', '速度： 0.0节')
            rowItem('目的地： YANGSHAN,CN', 'ETA： 07-17 21:00')

            Row {
                Text('最后时间： 07-18 13:44').texSty(100)
            }.rowSty()
        }
        .height(160)
        .backgroundColor(Color.WHITE)
        .alignRules(AlignRuleOption(left: HorizontalAnchor("left", HorizontalAlign.Start), right: HorizontalAnchor("right", HorizontalAlign.End), bottom: VerticalAnchor("bottom", VerticalAlign.Top)))
        .padding(top: 20)
    }

    @Builder
    func rowItem(str1: String, str2: String) {
        Row {
            Text(str1).texSty(55)
            Text(str2).texSty(40)
        }.rowSty()
    }
}