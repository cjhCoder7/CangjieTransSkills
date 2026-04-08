# 出现/消失转场

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

[transition](../reference/arkui-cj/cj-animation-transition.md#func-transitiontransitioneffect)是基础的组件转场接口，用于实现一个组件出现或者消失时的动画效果。可以通过[TransitionEffect对象](../reference/arkui-cj/cj-animation-transition.md#class-transitioneffect)的组合使用，定义出各式效果。

**表1** 转场效果接口

| 转场效果 | 说明 | 动画 |
|:-------- |:-------- |:-------- |
| IDENTITY | 禁用转场效果。 | 无。 |
| OPACITY | 默认的转场效果，透明度转场。 | 出现时透明度从0到1，消失时透明度从1到0。 |
| SLIDE | 滑动转场效果。 | 出现时从窗口左侧滑入，消失时从窗口右侧滑出。 |
| translate | 通过设置组件平移创建转场效果。 | 出现时为translate接口设置的值到默认值0，消失时为默认值0到translate接口设置的值。 |
| rotate | 通过设置组件旋转创建转场效果。 | 出现时为rotate接口设置的值到默认值0，消失时为默认值0到rotate接口设置的值。 |
| opacity | 通过设置透明度参数创建转场效果。 | 出现时为opacity设置的值到默认透明度1，消失时为默认透明度1到opacity设置的值。 |
| move | 通过[TransitionEdge](../reference/arkui-cj/cj-animation-transition.md#enum-transitionedge)创建从窗口哪条边缘出来的效果。 | 出现时从TransitionEdge方向滑入，消失时滑出到TransitionEdge方向。 |
| asymmetric | 通过此方法组合非对称的出现消失转场效果。<br/>- appear:出现转场的效果。<br/>- disappear：消失转场的效果。 | 出现时采用appear设置的[TransitionEffect](../reference/arkui-cj/cj-animation-transition.md#class-transitioneffect)出现效果，消失时采用disappear设置的[TransitionEffect](../reference/arkui-cj/cj-animation-transition.md#class-transitioneffect)消失效果。 |
| combine | 组合其他[TransitionEffect](../reference/arkui-cj/cj-animation-transition.md#class-transitioneffect)。 | 组合其他TransitionEffect，一起生效。 |
| animation | 定义转场效果的动画参数：<br/>-&nbsp;如果不定义会跟随[animateTo](../reference/arkui-cj/cj-apis-uicontext-uicontext.md#func-animatetoanimateparam-voidcallback)的动画参数。<br/>-&nbsp;不支持通过控件的[animation](../reference/arkui-cj/cj-animation-animation.md)接口配置动画参数。<br/>-&nbsp;[TransitionEffect](../reference/arkui-cj/cj-animation-transition.md#class-transitioneffect)中animation的onFinish不生效。 | 调用顺序是从上往下，上面TransitionEffect的animation也会作用到下面TransitionEffect。 |

## 示例

1. 创建TransitionEffect。

    ```cangjie
    // 出现时会是所有转场效果的出现效果叠加，消失时会是所有消失转场效果的叠加
    // 用于说明各个effect跟随的动画参数
    private var effect: TransitionEffect =
    TransitionEffect.OPACITY // 创建了透明度转场效果，这里没有调用animation接口，会跟随animateTo的动画参数
    // 通过combine方法，添加缩放转场效果，并指定了curve曲线
    .combine(TransitionEffect.scale(ScaleOptions(x: 0.0, y: 0.0)).animation(AnimateParam(curve: Curve.Smooth)))
    // 添加旋转转场效果，这里的动画参数会跟随上面的TransitionEffect，也就是Curve.Smooth
    .combine(TransitionEffect.rotate(RotateOptions(
                    90.0,
                    x: 0.0,
                    y: 0.0,
                    z: 1.0,
                    centerX: 50.percent,
                    centerY: 50.percent,
                    centerZ: 0.vp,
                    perspective: 0.0
                    )))
    // 添加平移转场效果，动画参数会跟随其之上带animation的TransitionEffect,也就是Curve.Smooth
    .combine(TransitionEffect.translate(TranslateOptions(y: 150)).animation(AnimateParam(curve: Curve.Smooth)))
    // 添加move转场效果，并指定了curve曲线
    .combine(TransitionEffect.move(TransitionEdge.End).animation(AnimateParam(curve: Curve.Linear)))
    // 添加非对称的转场效果，由于这里没有设置animation，会跟随上面的TransitionEffect的animation效果，也就是Curve.Linear
    .combine(TransitionEffect.asymmetric(TransitionEffect.scale(ScaleOptions(x: 0.0,y: 0.0)),
            TransitionEffect.rotate(RotateOptions(
                    90.0,
                    x: 0.0,
                    y: 0.0,
                    z: 1.0,
                    centerX: 50.percent,
                    centerY: 50.percent,
                    centerZ: 0.vp,
                    perspective: 0.0
                    ))))
    ```

2. 将转场效果通过[transition](../reference/arkui-cj/cj-animation-transition.md#func-transitiontransitioneffect)接口设置到组件。

    ```cangjie
    Text("test")
    .transition(this.effect)
    ```

3. 新增或者删除组件触发转场。

    ```cangjie
    @State var isPresent: Bool = false
    //...
    if (this.isPresent) {
        Text("test")
        .transition(this.effect)
    }
    //...

    // 控制新增或者删除组件
    // 方式一：将控制变量放到animateTo闭包内，未通过animation接口定义动画参数的TransitionEffect将跟随animateTo的动画参数
    getUIContext().animateTo(AnimateParam(curve: Curve.Smooth), { =>
            this.isPresent = false})

    // 方式二：直接控制删除或者新增组件，动画参数由TransitionEffect的animation接口配置
    this.isPresent = false
    ```

完整的示例代码和效果如下，示例中采用直接删除或新增组件的方式触发转场，也可以替换为在animateTo闭包内改变控制变量触发转场。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var isPresent: Bool = false
    private var effect: TransitionEffect =
    TransitionEffect.OPACITY.animation(AnimateParam(curve: Curve.ExtremeDeceleration))
    .combine(TransitionEffect.rotate(RotateOptions(
        90.0,
        x: 0.0,
        y: 0.0,
        z: 1.0,
        centerX: 50.percent,
        centerY: 50.percent,
        centerZ: 0.vp,
        perspective: 0.0
        )))

    func build() {
        Stack {
            if (this.isPresent) {
                Column {
                    Text("ArkUI")
                    .fontWeight(FontWeight.Bold)
                    .fontSize(20.vp)
                    .fontColor(Color.White)
                }
                .justifyContent(FlexAlign.Center)
                .width(150.vp)
                .height(150.vp)
                .borderRadius(10.vp)
                .backgroundColor(0xf56c6c)
                .transition(this.effect)
            }

            Column {}
            .width(155.vp)
            .height(155.vp)
            .border(width: 5.vp, color: Color.Black, radius: 10)

            Button("Click")
            .margin(top: 320.vp)
            .onClick({evt =>
                    this.isPresent = !this.isPresent
                })
        }
        .width(100.percent)
        .height(60.percent)
    }
}
```

![transition1](./figures/transition.gif)

对多个组件添加转场效果时，可以通过在[animation](../reference/arkui-cj/cj-animation-animation.md)动画参数中配置不同的delay值，实现组件渐次出现消失的效果：

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.ui_context.*
import ohos.arkui.state_macro_manage.*

const ITEM_COUNTS: Int64 = 9
const ITEM_COLOR: Int64 = 0xED6F21
const INTERVAL: Int32 = 30
const DURATION: Int32 = 300

@Entry
@Component
class EntryView {
    @State
    var isGridShow: Bool = false
    private var dataArray: Array<Int64> = Array<Int64>(ITEM_COUNTS, {i => i + 1})

    func build() {
        Stack {
            if (this.isGridShow) {
                Grid {
                    ForEach(
                        this.dataArray,
                        itemGeneratorFunc: {
                            item: Int64, index: Int64 => GridItem {
                                Stack {
                                    Text((item).toString())
                                }
                                    .size(width: 50.vp, height: 50.vp)
                                    .backgroundColor(ITEM_COLOR)
                                    .transition(
                                        TransitionEffect
                                            .OPACITY
                                            .combine(TransitionEffect.scale(ScaleOptions(x: 0.0, y: 0.0)))
                                            .animation(
                                                AnimateParam(duration: DURATION, curve: Curve.Friction,
                                                    delay: INTERVAL * Int32(index))))
                                    .borderRadius(10.vp)
                            }.transition(TransitionEffect.opacity(0.99))
                        },
                        keyGeneratorFunc: {item: Int64, index: Int64 => item.toString()}
                    )
                }
                    .columnsTemplate('1fr 1fr 1fr')
                    .rowsGap(15.vp)
                    .columnsGap(15.vp)
                    .size(width: 180.vp, height: 180.vp)
                    .transition(TransitionEffect.opacity(0.99))
            }
        }
            .size(width: 100.percent, height: 100.percent)
            .onClick(
                {
                    evt => getUIContext().animateTo(
                        AnimateParam(duration: DURATION,
                        delay: INTERVAL * (Int32(ITEM_COUNTS) - 1), curve: Curve.Friction),
                        {
                            => this.isGridShow = !this.isGridShow
                        }
                    )
                })
    }
}
```

![transition2](./figures/transition2.gif)