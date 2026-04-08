# 请求动画绘制帧率

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

在应用开发中，[属性动画](../reference/arkui-cj/cj-animation-animation.md)和[显式动画](../reference/arkui-cj/cj-apis-uicontext-uicontext.md)能够使用可选参数[ExpectedFrameRateRange](../reference/arkui-cj/cj-common-types.md#class-expectedframeraterange)，为不同的动画配置不同的期望绘制帧率。

## 请求属性动画的绘制帧率

定义文本组件的属性动画，请求绘制帧率为60，范例如下：

<!-- compile -->

```cangjie
import kit.ArkUI.*

let animateOpt1 = AnimateParam(
    duration: 1200,
    iterations: 10,
    expectedFrameRateRange: ExpectedFrameRateRange( // 设置属性动画的帧率范围
        min: 0, // 设置帧率范围
        max: 120, // 设置帧率范围
        expected: 60 // 设置动画的期望帧率为60hz
    )
)

@Entry
@Component
class EntryView {
    @State
    var message: String = "Hello World"
    func build() {
        Row {
            Column {
                Text(this.message)
                    .animationStart(animateOpt1)
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
                    .onClick ({ evt => this.message = "Hello Cangjie"
                    })
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

## 请求显式动画的绘制帧率

定义按钮组件的显式动画，请求绘制帧率为30，范例如下：

<!-- compile -->

```cangjie
import kit.ArkUI.*

@Entry
@Component
class EntryView {
    @State
    var rotateAngle: Float32 = 0.0
    @State
    var message: String = "Hello World"
    func build() {
        Row {
            Column {
                Text(this.message)
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
                    .onClick ({
                        evt => getUIContext().animateTo(
                            AnimateParam(
                                duration: 1200,
                                iterations: 10,
                                expectedFrameRateRange: ExpectedFrameRateRange( // 设置属性动画的帧率范围
                                    min: 0, // 设置帧率范围
                                    max: 120, // 设置帧率范围
                                    expected: 30 // 设置动画的期望帧率为30hz
                                )
                            ),
                            {=> this.rotateAngle = 90.0}
                        )
                    })
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

## 完整示例

<!-- compile -->

```cangjie
import kit.ArkUI.*

let animateOpt1 = AnimateParam(
    duration: 1200,
    iterations: 10,
    expectedFrameRateRange: ExpectedFrameRateRange( // 设置属性动画的帧率范围
        min: 0, // 设置帧率范围
        max: 120, // 设置帧率范围
        expected: 60 // 设置动画的期望帧率为60hz
    )
)

@Entry
@Component
class EntryView {
    @State
    var isAnimation: Bool = false
    @State
    var translateX1: Int64 = -100
    @State
    var translateX2: Int64 = -100
    @State
    var translateX3: Int64 = -100
    func build() {
        Column {
            Row {
                Text('30')
                    .fontWeight(FontWeight.Bold)
                    .fontSize(16)
                    .fontColor(Color.White)
                    .textAlign(TextAlign.Center)
                    .borderRadius(10)
                    .backgroundColor(0xF56C6C)
                    .width(80)
                    .height(80)
                    .translate(x: translateX1)
            }.height(20.percent)
            Row() {
                Text('40')
                    .fontWeight(FontWeight.Bold)
                    .fontSize(16)
                    .fontColor(Color.White)
                    .textAlign(TextAlign.Center)
                    .borderRadius(10)
                    .backgroundColor(0x2E8B57)
                    .width(80)
                    .height(80)
                    .translate(x: translateX2)
            }.height(20.percent)
            Row() {
                Text('60')
                    .fontWeight(FontWeight.Bold)
                    .fontSize(16)
                    .fontColor(Color.White)
                    .textAlign(TextAlign.Center)
                    .borderRadius(10)
                    .backgroundColor(0x008B8B)
                    .width(80)
                    .height(80)
                    .translate(x: translateX3)
                    .animationStart(animateOpt1)
            }.height(20.percent)
            Row() {
                Button('Start')
                    .id('PropertyAnimationStart')
                    .fontSize(14)
                    .fontWeight(FontWeight.W500)
                    .margin(bottom: 10, left: 5)
                    .fontColor(Color.White)
                    .onClick(
                        {
                            evt =>
                            this.isAnimation = !this.isAnimation
                            if (this.isAnimation) {
                                let translateX3 = 100
                            } else {
                                let translateX3 = -100
                            }
                            getUIContext().animateTo(
                                AnimateParam(
                                    duration: 1200,
                                    iterations: 10,
                                    playMode: PlayMode.AlternateReverse,
                                    expectedFrameRateRange: ExpectedFrameRateRange( // 设置属性动画的帧率范围
                                        min: 0, // 设置帧率范围
                                        max: 120, // 设置帧率范围
                                        expected: 40 // 设置动画的期望帧率为30hz
                                    )
                                ),
                                {
                                    => if (this.isAnimation) {
                                        let translateX3 = 100
                                    } else {
                                        let translateX3 = -100
                                    }
                                }
                            )
                        }
                    )
                    .width(40.percent)
                    .height(40)
                    .shadow(radius: 10.0, color: Color(0x909399), offsetX: 1.0, offsetY: 1.0)
            }
                .width(100.percent)
                .justifyContent(FlexAlign.Center)
                .shadow(radius: 10.0, color: Color(0x909399), offsetX: 1.0, offsetY: 1.0)
                .alignItems(VerticalAlign.Bottom)
                .layoutWeight(1)
        }
            .width(100.percent)
            .justifyContent(FlexAlign.Center)
            .shadow(radius: 10.0, color: Color(0x909399), offsetX: 1.0, offsetY: 1.0)
            .layoutWeight(1)
    }
}
```
