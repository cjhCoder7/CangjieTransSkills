# Web组件嵌套滚动

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

Web组件嵌套滚动的典型应用场景为，在一个页面中，有多个独立的区域需要进行滚动，当用户滚动Web区域内容时，可带动其他滚动区域进行滚动，以达到上下滑动页面的用户体验。

内嵌在可滚动容器（[Scroll](../reference/arkui-cj/cj-scroll-swipe-scroll.md)、[List](../reference/arkui-cj/cj-scroll-swipe-list.md)中的Web组件，接收到滑动手势事件，需要对接ArkUI框架的[NestedScrollMode](../reference/arkui-cj/cj-common-types.md#enum-nestedscrollmode)枚举类型，使得Web组件可以嵌套ArkUI可滚动容器，进行嵌套滚动。开发者可以在Web组件创建时，使用[nestedScroll](../reference/arkui-cj/cj-web-web.md#func-nestedscrollnestedscrollmode-nestedscrollmode)属性接口指定默认的嵌套滚动模式，也允许在过程中动态改变嵌套滚动的模式。

nestedScroll有两个入参，分别为scrollForward和scrollBackward，均为[NestedScrollMode](../reference/arkui-cj/cj-common-types.md#enum-nestedscrollmode)枚举类型。

当Web组件被多个可滚动容器组件嵌套时，未被Web组件消费的与父组件方向一致的偏移量、速度值将被传递给距Web组件最近且方向一致的父组件，使得父组件可以继续滚动。一次手势滑动只能沿X轴或Y轴一个方向嵌套滚动，当手势斜向滑动时，滚动方向为偏移量或速度在X轴、Y轴绝对值较大的方向；当偏移量或速度绝对值在X轴、Y轴绝对值相同时，滚动方向为距Web组件最近的可滚动组件的方向。

> **说明：**
>
> - 支持嵌套滚动的容器：[Grid](../reference/arkui-cj/cj-scroll-swipe-grid.md)、[List](../reference/arkui-cj/cj-scroll-swipe-list.md)、[Scroll](../reference/arkui-cj/cj-scroll-swipe-scroll.md)、[Swiper](../reference/arkui-cj/cj-scroll-swipe-swiper.md)、[Tabs](../reference/arkui-cj/cj-navigation-switching-tabs.md)、[Refresh](../reference/arkui-cj/cj-scroll-swipe-refresh.md)、[bindSheet](../reference/arkui-cj/cj-animation-transition.md)。
> - 支持嵌套滚动的输入事件：使用手势、鼠标、触控板。

<!-- compile -->

```cangjie
// index.cj
import ohos.arkui.state_macro_manage.*
import ohos.web.webview.WebviewController
import kit.ArkUI.*

@Entry
@Component
class EntryView {
    var scrollerForScroll: Scroller = Scroller()
    let controller = WebviewController()
    let controller2 = WebviewController()
    // NestedScrollMode设置成SelfOnly时，Web网页滚动到页面边缘后，不与父组件联动，父组件仍无法滚动。
    @State
    var nestedScrollMode0: NestedScrollMode = NestedScrollMode.SelfOnly
    // NestedScrollMode设置成SelfFirst时，Web网页滚动到页面边缘后，父组件继续滚动。
    @State
    var nestedScrollMode1: NestedScrollMode = NestedScrollMode.SelfFirst
    // NestedScrollMode设置为ParentFirst时，父组件先滚动，滚动至边缘后通知Web继续滚动。
    @State
    var nestedScrollMode2: NestedScrollMode = NestedScrollMode.ParentFirst
    // NestedScrollMode设置为Parallel时，父组件与Web同时滚动。
    @State
    var nestedScrollMode3: NestedScrollMode = NestedScrollMode.Parallel
    @State
    var nestedScrollModeF: NestedScrollMode = NestedScrollMode.SelfFirst
    @State
    var nestedScrollModeB: NestedScrollMode = NestedScrollMode.SelfFirst
    // scroll竖向的滚动
    @State
    var scrollDirection: ScrollDirection = ScrollDirection.Vertical

    func build() {
        Flex() {
            Scroll(this.scrollerForScroll) {
                Column(space: 5) {
                    Row() {
                        Text('切换前滚动模式').fontSize(5)
                        Button("SelfOnly").onClick ({ evt =>
                            this.nestedScrollModeF = this.nestedScrollMode0
                        }).fontSize(5)
                        Button("SelfFirst").onClick ({ evt =>
                            this.nestedScrollModeF = this.nestedScrollMode1
                        }).fontSize(5)
                        Button("ParentFirst").onClick ({ evt =>
                            this.nestedScrollModeF = this.nestedScrollMode2
                        }).fontSize(5)
                        Button("Parallel").onClick ({ evt =>
                            this.nestedScrollModeF = this.nestedScrollMode3
                        }).fontSize(5)
                    }
                    Row() {
                        Text('切换后滚动模式').fontSize(5)
                        Button("SelfOnly").onClick ({ evt =>
                            this.nestedScrollModeB = this.nestedScrollMode0
                        }).fontSize(5)
                        Button("SelfFirst").onClick ({ evt =>
                            this.nestedScrollModeB = this.nestedScrollMode1
                        }).fontSize(5)
                        Button("ParentFirst").onClick ({ evt =>
                            this.nestedScrollModeB = this.nestedScrollMode2
                        }).fontSize(5)
                        Button("Parallel").onClick ({ evt =>
                            this.nestedScrollModeB = this.nestedScrollMode3
                        }).fontSize(5)
                    }
                    Text('当前内嵌前滚动模式 scrollForward ---nestedScrollModeF').fontSize(10)
                    Text('当前内嵌后滚动模式  scrollBackward ---nestedScrollModeB').fontSize(10)
                    Text("Scroll Area")
                        .width(100.percent)
                        .height(10.percent)
                        .backgroundColor(0X330000FF)
                        .fontSize(16)
                        .textAlign(TextAlign.Center)
                    Text("Scroll Area")
                        .width(100.percent)
                        .height(10.percent)
                        .backgroundColor(0X330000FF)
                        .fontSize(16)
                        .textAlign(TextAlign.Center)
                    Text("Scroll Area")
                        .width(100.percent)
                        .height(10.percent)
                        .backgroundColor(0X330000FF)
                        .fontSize(16)
                        .textAlign(TextAlign.Center)
                    // src改为有效地址或者资源文件
                    Web(src: "www.example.com", controller: this.controller)
                        .nestedScroll(
                            scrollForward: this.nestedScrollModeF,
                            scrollBackward: this.nestedScrollModeB
                        )
                        .height(40.percent)
                        .width(100.percent)

                    Text("Scroll Area")
                        .width(100.percent)
                        .height(20.percent)
                        .backgroundColor(0X330000FF)
                        .fontSize(16)
                        .textAlign(TextAlign.Center)
                    Text("Scroll Area")
                        .width(100.percent)
                        .height(20.percent)
                        .backgroundColor(0X330000FF)
                        .fontSize(16)
                        .textAlign(TextAlign.Center)
                    // src改为有效地址或者资源文件
                    Web(src: "www.example.com", controller: this.controller2)
                        .nestedScroll(
                            scrollForward: this.nestedScrollModeF,
                            scrollBackward: this.nestedScrollModeB
                        )
                        .height(40.percent)
                        .width(90.percent)
                    Text("Scroll Area")
                        .width(100.percent)
                        .height(20.percent)
                        .backgroundColor(0X330000FF)
                        .fontSize(16)
                        .textAlign(TextAlign.Center)
                }.width(95.percent).border( width: 5 )
            }.width(100.percent).height(120.percent).border(width: 5).scrollable(this.scrollDirection)
        }.width(100.percent).height(100.percent).backgroundColor(0xDCDCDC).padding(20)
    }
}
```

![web-nested-scrolling](figures/web-nested-scrolling.gif)
