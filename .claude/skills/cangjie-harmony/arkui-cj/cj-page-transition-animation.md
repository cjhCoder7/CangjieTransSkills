# 页面转场动画（不推荐）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

为了实现更好的转场效果，推荐使用[模态转场](./cj-modal-transition.md)。

两个页面间发生跳转，一个页面消失，另一个页面出现，这时可以配置各自页面的页面转场参数实现自定义的页面转场效果。[页面转场](../reference/arkui-cj/cj-animation-pagetransition.md)效果写在pageTransition函数中，通过[PageTransitionEnter](../reference/arkui-cj/cj-animation-pagetransition.md#class-pagetransitionenter)和[PageTransitionExit](../reference/arkui-cj/cj-animation-pagetransition.md#class-pagetransitionexit)指定页面进入和退出的动画效果。

pageTransition的函数为：

```cangjie
protected func pageTransition(): Unit {
    PageTransitionEnter()
    PageTransitionExit()
}
```

PageTransitionEnter的接口为：

```cangjie
PageTransitionEnter(routeType: RouteType.None, duration: 1000)
```

PageTransitionExit的接口为：

```cangjie
PageTransitionExit(routeType: RouteType.None, duration: 1000)
```

上述接口定义了PageTransitionEnter和PageTransitionExit组件，可通过slide、translate、scale、opacity属性定义不同的页面转场效果。对于PageTransitionEnter而言，这些效果表示入场时起点值，对于PageTransitionExit而言，这些效果表示退场的终点值，这一点与组件转场transition配置方法类似。此外，PageTransitionEnter提供了onEnter接口进行自定义页面入场动画的回调，PageTransitionExit提供了onExit接口进行自定义页面退场动画的回调。

上述接口中的参数routeType，表示路由生效的类型，这一点开发者容易混淆其含义。页面转场的两个页面，必定有一个页面退出，一个页面进入。如果通过router.pushUrl操作从页面A跳转到页面B，则页面A退出，做页面退场动画，页面B进入，做页面入场动画。如果通过router.back操作从页面B返回到页面A，则页面B退出，做页面退场动画，页面A进入，做页面入场动画。即页面的PageTransitionEnter既可能是由于新增页面（push，入栈）引起的新页面的入场动画，也可能是由于页面返回（back，或pop，出栈）引起的页面栈中老页面的入场动画。为了能区分这两种形式的入场动画，提供了routeType参数，这样开发者能完全定义所有类型的页面转场效果。

## routeType配置为RouteType.None

routeType为RouteType.None表示对页面栈的push、pop操作均生效，routeType的默认值为RouteType.None。

```cangjie
// page A
protected func pageTransition(): Unit {
    // 定义页面进入时的效果，从左侧滑入，时长为1200ms，无论页面栈发生push还是pop操作均可生效
    PageTransitionEnter(routeType: RouteType.None, duration: 1200)
        .slide(SlideEffect.Left)
    // 定义页面退出时的效果，向左侧滑出，时长为1000ms，无论页面栈发生push还是pop操作均可生效
    PageTransitionExit(routeType: RouteType.None, duration: 1000)
        .slide(SlideEffect.Left)
}
```

```cangjie
// page B
protected func pageTransition(): Unit {
    // 定义页面进入时的效果，从右侧滑入，时长为1000ms，无论页面栈发生push还是pop操作均可生效
    PageTransitionEnter(routeType: RouteType.None, duration: 1000)
        .slide(SlideEffect.Right)
    // 定义页面退出时的效果，向右侧滑出，时长为1200ms，无论页面栈发生push还是pop操作均可生效
    PageTransitionExit(routeType: RouteType.None, duration: 1200)
        .slide(SlideEffect.Right)
}
```

假设页面跳转配置为多实例模式，即页面栈中允许存在重复的页面。可能出现的4种场景对应的页面转场效果如下表。

|路由操作|页面A转场效果|页面B转场效果|
|:---|:---|:---|
|router.pushUrl，从页面A跳转到新增的页面B|页面退出，PageTransitionExit生效，向左侧滑出屏幕|页面进入，PageTransitionEnter生效，从右侧滑入屏幕|
|router.back，从页面B返回到页面A|页面进入，PageTransitionEnter生效，从左侧滑入屏幕|页面退出，PageTransitionExit生效，向右侧滑出屏幕|
|router.pushUrl，从页面B跳转到新增的页面A|页面进入，PageTransitionEnter生效，从左侧滑入屏幕|页面退出，PageTransitionExit生效，向右侧滑出屏幕|
|router.back，从页面A返回到页面B|页面退出，PageTransitionExit生效，向左侧滑出屏幕|页面进入，PageTransitionEnter生效，从右侧滑入屏幕|

如果希望pushUrl进入的页面总是从右侧滑入，back时退出的页面总是从右侧滑出，则上表中的第3、4种情况不满足要求，那么需要完整的定义4个页面转场效果。

## routeType配置为RouteType.Push或RouteType.Pop

routeType为RouteType.Push表示仅对页面栈的push操作生效，routeType为RouteType.Pop表示仅对页面栈的pop操作生效。

<!-- code_check_manual -->

```cangjie
// page A
protected func pageTransition(): Unit {
    // 定义页面进入时的效果，从右侧滑入，时长为1200ms，页面栈发生push操作时该效果才生效
    PageTransitionEnter(routeType: RouteType.Push, duration: 1200)
        .slide(SlideEffect.Right)
    // 定义页面进入时的效果，从左侧滑入，时长为1200ms，页面栈发生pop操作时该效果才生效
    PageTransitionEnter(routeType: RouteType.Pop, duration: 1200)
        .slide(SlideEffect.Left)
    // 定义页面退出时的效果，向左侧滑出，时长为1000ms，页面栈发生push操作时该效果才生效
    PageTransitionExit(routeType: RouteType.Push, duration: 1000)
        .slide(SlideEffect.Left)
    // 定义页面退出时的效果，向右侧滑出，时长为1000ms，页面栈发生pop操作时该效果才生效
    PageTransitionExit(routeType: RouteType.Pop, duration: 1000)
        .slide(SlideEffect.Right)
}
```

```cangjie
// page B
protected func pageTransition(): Unit {
    // 定义页面进入时的效果，从右侧滑入，时长为1000ms，页面栈发生push操作时该效果才生效
    PageTransitionEnter(routeType: RouteType.Push, duration: 1000)
        .slide(SlideEffect.Right)
    // 定义页面进入时的效果，从左侧滑入，时长为1000ms，页面栈发生pop操作时该效果才生效
    PageTransitionEnter(routeType: RouteType.Pop, duration: 1000)
        .slide(SlideEffect.Left)
    // 定义页面退出时的效果，向左侧滑出，时长为1200ms，页面栈发生push操作时该效果才生效
    PageTransitionExit(routeType: RouteType.Push, duration: 1200)
        .slide(SlideEffect.Left)
    // 定义页面退出时的效果，向右侧滑出，时长为1200ms，页面栈发生pop操作时该效果才生效
    PageTransitionExit(routeType: RouteType.Pop, duration: 1200)
        .slide(SlideEffect.Right)
}
```

以上代码则完整的定义了所有可能的页面转场样式。假设页面跳转配置为多实例模式，即页面栈中允许存在重复的页面。可能出现的4种场景对应的页面转场效果如下表。

|路由操作|页面A转场效果|页面B转场效果|
|:---|:---|:---|
|router.pushUrl，从页面A跳转到新增的页面B|页面退出，PageTransitionExit且routeType为RouteType.Push的转场样式生效，向左侧滑出屏幕|页面进入，PageTransitionEnter且routeType为RouteType.Push的转场样式生效，从右侧滑入屏幕|
|router.back，从页面B返回到页面A|页面进入，PageTransitionEnter且routeType为RouteType.Pop的转场样式生效，从左侧滑入屏幕|页面退出，PageTransitionExit且routeType为RouteType.Pop的转场样式生效，向右侧滑出屏幕|
|router.pushUrl，从页面B跳转到新增的页面A|页面进入，PageTransitionEnter且routeType为RouteType.Push的转场样式生效，从右侧滑入屏幕|页面退出，PageTransitionExit且routeType为RouteType.Push的转场样式生效，向左侧滑出屏幕|
|router.back，从页面A返回到页面B|页面退出，PageTransitionExit且routeType为RouteType.Pop的转场样式生效，向右侧滑出屏幕|页面进入，PageTransitionEnter且routeType为RouteType.Pop的转场样式生效，从左侧滑入屏幕|

> **说明：**
>
> - 由于每个页面的页面转场样式都可由开发者独立配置，而页面转场涉及到两个页面，开发者应考虑两个页面的页面转场效果的衔接，如时长尽量保持一致。
> - 如果没有定义匹配的页面转场样式，则该页面使用系统默认的页面转场样式。

## 禁用某页面的页面转场

通过设置页面转场的时长为0，可使该页面无页面转场动画。

```cangjie
protected func pageTransition(): Unit {
    PageTransitionEnter(routeType: RouteType.None, duration: 0)
    PageTransitionExit(routeType: RouteType.None, duration: 0)
}
```

## 场景示例

下面介绍利用[router.pushUrl](../reference/arkui-cj/cj-apis-uicontext-router.md#func-pushurlstringstring)跳转能力定义所有的4种页面转场样式的页面转场动画示例。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.resource.*

@Entry
@Component
class EntryView {
    func build() {
        Column() {
            Image(@r(app.media.image1))
                .width(90.percent).height(80.percent)
                .objectFit(ImageFit.Fill)
                .syncLoad(true) // 同步加载图片，使页面出现时图片已经加载完成
                .margin(30)

             Row(space: 10){
                Button("pushUrl")
                  .onClick ({ evt =>
                    // 路由到下一个页面，push操作
                    getUIContext().getRouter().pushUrl(url: "Page1")
                  })
                Button("back")
                    .onClick ({ evt =>
                    // 返回到上一页面，相当于pop操作
                    getUIContext().getRouter().back()
                  })
            }.justifyContent(FlexAlign.Center)
        }
        .width(100.percent).height(100.percent)
        .alignItems(HorizontalAlign.Center)
    }

    protected func pageTransition(): Unit {
        // 定义页面进入时的效果，从右侧滑入，时长为1000ms，页面栈发生push操作时该效果才生效
        PageTransitionEnter(routeType: RouteType.Push, duration: 1000)
            .slide(SlideEffect.Right)
        // 定义页面进入时的效果，从左侧滑入，时长为1000ms，页面栈发生pop操作时该效果才生效
        PageTransitionEnter(routeType: RouteType.Pop, duration: 1000)
            .slide(SlideEffect.Left)
        // 定义页面退出时的效果，向左侧滑出，时长为1000ms，页面栈发生push操作时该效果才生效
        PageTransitionExit(routeType: RouteType.Push, duration: 1000)
            .slide(SlideEffect.Left)
        // 定义页面退出时的效果，向右侧滑出，时长为1000ms，页面栈发生pop操作时该效果才生效
        PageTransitionExit(routeType: RouteType.Pop, duration: 1000)
            .slide(SlideEffect.Right)
    }
}
```

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.resource.*

@Entry
@Component
class Page1 {
    func build() {
        Column() {
            Image(@r(app.media.image2))
                .width(90.percent).height(80.percent)
                .objectFit(ImageFit.Fill)
                .syncLoad(true) // 同步加载图片，使页面出现时图片已经加载完成
                .margin(30)

             Row(space: 10){
                Button("pushUrl")
                  .onClick ({ evt =>
                    // 路由到下一个页面，push操作
                    getUIContext().getRouter().pushUrl(url: "EntryView")
                  })
                Button("back")
                    .onClick( { evt =>
                    // 返回到上一页面，相当于pop操作
                    getUIContext().getRouter().back()
                  })
            }.justifyContent(FlexAlign.Center)
        }
        .width(100.percent).height(100.percent)
        .alignItems(HorizontalAlign.Center)
    }

    protected func pageTransition(): Unit {
        // 定义页面进入时的效果，从右侧滑入，时长为1000ms，页面栈发生push操作时该效果才生效
        PageTransitionEnter(routeType: RouteType.Push, duration: 1000)
            .slide(SlideEffect.Right)
        // 定义页面进入时的效果，从左侧滑入，时长为1000ms，页面栈发生pop操作时该效果才生效
        PageTransitionEnter(routeType: RouteType.Pop, duration: 1000)
            .slide(SlideEffect.Left)
        // 定义页面退出时的效果，向左侧滑出，时长为1000ms，页面栈发生push操作时该效果才生效
        PageTransitionExit(routeType: RouteType.Push, duration: 1000)
            .slide(SlideEffect.Left)
        // 定义页面退出时的效果，向右侧滑出，时长为1000ms，页面栈发生pop操作时该效果才生效
        PageTransitionExit(routeType: RouteType.Pop, duration: 1000)
            .slide(SlideEffect.Right)
    }
}
```

![transiton-animation](figures/transition-animation1.gif)

下面介绍使用了routeType为None的页面转场动画示例。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.resource.*

@Entry
@Component
class EntryView {
    func build() {
        Column() {
            Image(@r(app.media.image1))
                .width(90.percent).height(80.percent)
                .objectFit(ImageFit.Fill)
                .syncLoad(true) // 同步加载图片，使页面出现时图片已经加载完成
                .margin(30)

             Row(space: 10){
                Button("pushUrl")
                  .onClick ({ evt =>
                    // 路由到下一个页面，push操作
                    getUIContext().getRouter().pushUrl(url: "Page1")
                  })
                Button("back")
                    .onClick({ evt =>
                    // 返回到上一页面，相当于pop操作
                    getUIContext().getRouter().back()
                  })
            }.justifyContent(FlexAlign.Center)
        }
        .width(100.percent).height(100.percent)
        .alignItems(HorizontalAlign.Center)
    }

    protected func pageTransition(): Unit {
        // 定义页面进入时的效果，从左侧滑入，时长为1000ms，无论页面栈发生push还是pop操作均可生效
        PageTransitionEnter(duration: 1000)
            .slide(SlideEffect.Left)
        // 定义页面退出时的效果，相对于正常页面位置x方向平移100vp，y方向平移100vp，透明度变为0，时长为1200ms，无论页面栈发生push还是pop操作均可生效
        PageTransitionExit(duration: 1200)
            .translate(x: 100.0, y: 100.0)
            .opacity(0.0)
    }
}
```

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.resource.*

@Entry
@Component
class Page1 {
    func build() {
        Column() {
            Image(@r(app.media.image2))
                .width(90.percent).height(80.percent)
                .objectFit(ImageFit.Fill)
                .syncLoad(true) // 同步加载图片，使页面出现时图片已经加载完成
                .margin(30)

             Row(space: 10){
                Button("pushUrl")
                  .onClick ({ evt =>
                    // 路由到下一个页面，push操作
                    getUIContext().getRouter().pushUrl(url: "EntryView")
                  })
                Button("back")
                    .onClick ({ evt =>
                    // 返回到上一页面，相当于pop操作
                    getUIContext().getRouter().back()
                  })
            }.justifyContent(FlexAlign.Center)
        }
        .width(100.percent).height(100.percent)
        .alignItems(HorizontalAlign.Center)
    }

    protected func pageTransition(): Unit {
        // 定义页面进入时的效果，从左侧滑入，时长为1200ms，无论页面栈发生push还是pop操作均可生效
        PageTransitionEnter(duration: 1200)
            .slide(SlideEffect.Left)
        // 定义页面退出时的效果，相对于正常页面位置x方向平移100vp，y方向平移100vp，透明度变为0，时长为1000ms，无论页面栈发生push还是pop操作均可生效
        PageTransitionExit(duration: 1000)
            .translate(x: 100.0, y: 100.0)
            .opacity(0.0)
    }
}
```

![transiton-animation](figures/transition-animation2.gif)
