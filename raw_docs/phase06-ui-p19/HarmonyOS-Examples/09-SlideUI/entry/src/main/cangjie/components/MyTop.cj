/**
 * Created on 2025/7/29
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.app
import ohos.ability.AbilityContext


@Component
public class MyTop {
    @Builder
    public func SheetTransitionBuilder() {
        Column {
            Column {
                ShipFact()
            }
            .onClick {
                evt =>
                this.isShow = true
            }
            BottomTab()
        }
    }

    @Prop var abilityContext: AbilityContext
    @Prop var isShowDown: Bool
    @Link var isShow: Bool

    public func build() {
        Row {
            Row {
                Image(@r(app.media.ic_public_arrow_left))
                .width(34)
                .height(34)
                .onClick{
                    evt =>
                    abilityContext.terminateSelf()
                }
            }
            .width(40)
            .height(40)
            .justifyContent(FlexAlign.Center)

            Text("信息")
            .fontColor(Color.BLACK)
            .fontWeight(FontWeight.Bold)
            .fontSize(20)
            .margin(left: 6)
            .onClick {
                evt =>
                    this.isShowDown = true
            }
            .bindSheet(this.isShowDown, SheetTransitionBuilder, options: SheetOptions(onDisappear: {=> this.isShowDown = false},title: { => Text('SHIP_NAME').fontSize(20).fontWeight(FontWeight.W500)}, backgroundColor: Color(255, 255, 255, alpha: 0.0), height: SheetSize.FIT_CONTENT, preferType: SheetType.BOTTOM))
        }
        .width(100.percent)
        .height(62)
        .margin(top: 38)
        .alignRules(AlignRuleOption(left: HorizontalAnchor("left", HorizontalAlign.Start), right: HorizontalAnchor("right", HorizontalAlign.End), top: VerticalAnchor("top", VerticalAlign.Top)))
        .padding(left: 16)
    }
}