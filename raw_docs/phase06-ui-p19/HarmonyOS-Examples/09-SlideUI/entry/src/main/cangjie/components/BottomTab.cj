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
    func colTxtSty() {
        this.fontSize(10).width(20).height(16).fontWeight(FontWeight.W400).fontColor(Color(0x666666))
    }
}

extend Button {
    func buttonSty(curBackgroudColor: Color) {
        this.backgroundColor(curBackgroudColor).fontSize(15).width(93).height(40)
    }
}

@Component
public class BottomTab {
    public func build() {
         Row(10) {
            columnItem(@r(app.media.shoucang), '关注')
            columnItem(@r(app.media.ic_tixing), '提醒')
            columnItem(@r(app.media.ic_hangxian), '航次')

            Button('历史航班')
            .fontColor(Color.BLACK)
            .borderColor(Color.GRAY)
            .buttonSty(Color(0, 0, 0, alpha: 0.05))

            Button('船舶航向')
            .buttonSty(Color(0x317aff))
        }
        .backgroundColor(Color.WHITE)
        .justifyContent(FlexAlign.Center)
        .id('bottomTab')
        .alignRules(AlignRuleOption(bottom: VerticalAnchor('bottom', VerticalAlign.Bottom)))
        .width(100.percent)
        .height(80)
        .padding(left: 6, right: 16, bottom: 30)
    }

    @Builder
    func columnItem(curImage: CJResource, curString: String) {
        Column {
            Image(curImage)
            .width(20)
            .height(20)
            Text(curString).colTxtSty()
        }
        .width(10.percent)
        .margin(right: 5)
    }
}