# 传统曲线

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

传统曲线基于数学公式，创造形状符合开发者预期的动画曲线。以三阶贝塞尔曲线为代表，通过调整曲线控制点，可以改变曲线形状，从而带来缓入、缓出等动画效果。对于同一条传统曲线，由于不具备物理含义，其形状不会因为用户行为发生任何改变，缺少物理动画的自然感和生动感。建议优先采用物理曲线创建动画，将传统曲线作为辅助用于极少数必要场景中。

ArkUI提供了贝塞尔曲线、阶梯曲线等传统曲线接口，开发者请参见[插值计算](../reference/arkui-cj/cj-apis-curves.md)进行查阅。

传统曲线的示例和效果如下：

 <!--run-->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

class MyCurve {
    let title: String
    let curve: Curve
    let color: ResourceColor

    public init(title: String, curve: Curve, color: ResourceColor) {
        this.title = title
        this.curve = curve
        this.color = color
    }
}

let myCurves: Array<MyCurve> = [
    MyCurve(' FastOutSlowIn', Curve.FastOutSlowIn, 0xD94838),
    MyCurve(' Ease', Curve.Ease, 0xD94838),
    MyCurve(' EaseIn', Curve.EaseIn, 0xDB6B42),
    MyCurve(' Linear', Curve.Linear, 0x317AF7),
    MyCurve(' EaseOut', Curve.EaseOut, 0x5BA854),
    MyCurve(' EaseInOut', Curve.EaseInOut, 0x317AF7)
]

@Entry
@Component
class EntryView {
    @State var dRotate: Float32 = 0.0

    func build() {
        Column() {
            Grid() {
                ForEach(myCurves,itemGeneratorFunc: {
                        item: MyCurve, _: Int64 =>
                        GridItem() {
                            Column() {
                                Row()
                                    .width(30)
                                    .height(30)
                                    .borderRadius(15)
                                    .backgroundColor(item.color)
                                Text(item.title)
                                    .fontSize(15)
                                    .fontColor(0x909399)
                            }.width(100.percent)
                        }
                    })
            }
            .columnsTemplate('1fr 1fr 1fr')
            .rowsTemplate('1fr 1fr 1fr 1fr 1fr')
            .padding(10)
            .width(100.percent)
            .height(300)
            .margin(top: 50)

            Stack() {
                Row()
                    .width(290)
                    .height(290)
                    .border(width: 15, color: 0xE6E8EB, radius: 145)

                ForEach(myCurves, itemGeneratorFunc: { item: MyCurve, idx: Int64 =>
                        Column() {
                            Row()
                                .width(30)
                                .height(30)
                                .borderRadius(15)
                                .backgroundColor(item.color)
                        }
                        .width(20)
                        .height(300)
                        .rotate(angle: this.dRotate)
                        .animation(AnimateParam(duration: 2000, curve: item.curve, delay: 100, iterations: -1))
                    }
                )
            }
            .width(100.percent)
            .height(200)
            .onClick({evt => this.dRotate = 360.0})
        }
        .width(100.percent)
    }
}
```

![curves](./figures/curves.gif)
