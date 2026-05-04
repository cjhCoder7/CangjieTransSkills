package ohos_app_cangjie_entry

import ohos_app_cangjie_entry.entity.*
import ohos_app_cangjie_entry.service.DynamicParam

import std.collection.*
import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.unicode.*

@Entry
@Component
class EntryView {
    @State
    var items: ArrayList<ButtonEntity> = ArrayList()
    @State
    var dynamicParam: DynamicParam = DynamicParam()

    let animateTextSize = AnimateParam(
        duration: 100,
        curve: Curve.Linear
    )

    public func aboutToAppear(): Unit {
        preparePortrait()
    }

    private func preparePortrait() {
        //(     )       ←       ÷
        //7     8       9       ×
        //4     5       6       -
        //1     2       3       +
        //0     .       AC      =
        items = ArrayList(
            Keyboards.LeftBracket, Keyboards.RightBracket,
            Keyboards.Pop, Keyboards.Divide, Keyboards.Seven,
            Keyboards.Eight, Keyboards.Nine, Keyboards.Multiply,
            Keyboards.Four, Keyboards.Five, Keyboards.Six,
            Keyboards.Reduce, Keyboards.One, Keyboards.Two,
            Keyboards.Three, Keyboards.Plus, Keyboards.Zero,
            Keyboards.Dot, Keyboards.Clear, Keyboards.Eval
        )
    }

    func build() {
        RelativeContainer {
            Column {
                Text(dynamicParam.expressionText)
                    .fontWeight(FontWeight.Bold)
                    .animationStart(animateTextSize)
                    .fontSize(dynamicParam.expressionTextSize)
                    .animationEnd()
                Text(dynamicParam.resultText)
                    .fontWeight(FontWeight.Bold)
                    .animationStart(animateTextSize)
                    .fontSize(dynamicParam.resultTextSize)
                    .animationEnd()
            }
            .id('LAY_RESULT')
            .width(100.percent)
            .padding(16)
            .alignItems(HorizontalAlign.End)
            .alignRules(AlignRuleOption(bottom: VerticalAnchor('LAY_KEYBOARD', VerticalAlign.Top)))

            Grid {
                ForEach(items, itemGeneratorFunc: { entity: ButtonEntity, index: Int =>
                    GridItem {
                        Button(entity.text)
                            .shape(ShapeType.Normal).stateEffect(true).borderRadius(8)
                            .width(100.percent).height(100.percent)
                            .onClick({e => entity.onPress(dynamicParam)})
                            .fontWeight(FontWeight.Medium).fontColor(entity.textColor).fontSize(24)
                            .backgroundColor(entity.bgColor)
                        }
                    }
                )
            }
            .id('LAY_KEYBOARD')
            .rowsTemplate('1fr 1fr 1fr 1fr 1fr')
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .columnsGap(8).rowsGap(8)
            .padding(16)
            .width(100.percent)
            .height(50.percent)
            .alignRules(AlignRuleOption(bottom: VerticalAnchor('__container__', VerticalAlign.Bottom)))
        }.height(100.percent).width(100.percent)
    }
}
