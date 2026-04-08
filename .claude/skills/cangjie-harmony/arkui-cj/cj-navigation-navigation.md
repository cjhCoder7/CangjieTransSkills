# 组件导航（Navigation）（推荐）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

组件导航（Navigation）主要用于实现页面间以及组件内部的页面跳转，支持在不同组件间传递跳转参数，提供灵活的跳转栈操作，从而更便捷地实现对不同页面的访问和复用。本文将从组件导航（Navigation）的路由操作、子页面管理以及跳转动效等几个方面进行详细介绍。

[Navigation](../reference/arkui-cj/cj-navigation-switching-navigation.md)是路由导航的根视图容器，一般作为页面（@Entry）的根容器。Navigation组件适用于模块内的路由切换，通过组件级路由能力实现更加自然流畅的转场体验，并提供多种标题栏样式来呈现更好的标题和内容联动效果。一次开发，多端部署场景下，Navigation组件能够自动适配窗口显示大小，在窗口较大的场景下自动切换分栏展示效果。

Navigation组件主要包含​导航页和子页。导航页由标题栏（包含菜单栏）、内容区和工具栏组成。导航页不存在页面栈中。导航页与子页，以及子页之间，可以通过路由操作进行切换。

推荐使用[NavPathStack](../reference/arkui-cj/cj-navigation-switching-navigation.md#class-navpathstack)实现页面路由。

## 路由操作

Navigation路由相关的操作都是基于页面栈[NavPathStack](../reference/arkui-cj/cj-navigation-switching-navigation.md#class-navpathstack)提供的方法进行，每个Navigation都需要创建并传入一个NavPathStack对象，用于管理页面。主要涉及页面跳转、页面返回等功能。

> **说明：**
>
> 不建议开发者通过监听生命周期的方式管理自己的页面栈。

```cangjie
@Entry
@Component
class EntryView {
    // 创建一个页面栈对象并传入Navigation
    var pageStack: NavPathStack = NavPathStack()
    func build(){
        Navigation(this.pageStack) {
        }
    }
}
```

### 页面跳转

NavPathStack通过Push相关的接口去实现页面跳转的功能，主要通过页面的name去跳转，并可以携带param。

```cangjie
this.pageStack.pushPath(NavPathInfo(name: 'PageOne', param: 'PageOne Param'))
```

### 页面返回

NavPathStack通过Pop相关接口去实现页面返回功能。

```cangjie
// 返回到上一页
this.pageStack.pop()
```

## 子页面

[NavDestination](../reference/arkui-cj/cj-navigation-switching-navdestination.md)是Navigation子页面的根容器，用于承载子页面的一些特殊属性以及生命周期等。

## 页面转场

Navigation默认提供了页面切换的转场动画，通过页面栈操作时，会触发不同的转场效果，Navigation也提供了关闭系统转场、自定义转场以及共享元素转场的能力。

### 共享元素转场

NavDestination之间切换时可以通过[geometryTransition](../reference/arkui-cj/cj-animation-geometrytransition.md#func-geometrytransitionstring-bool)实现共享元素转场。配置了共享元素转场的页面同时需要关闭系统默认的转场动画。

1. 为需要实现共享元素转场的组件添加geometryTransition属性，id参数必须在两个NavDestination之间保持一致。

    ```cangjie
    // 起始页配置共享元素id
    // ...
    @Component
    class PageOne {
        func build() {
            NavDestination() {
                Column() {
                    // ...
                    Image(@r(app.media.startIcon))
                        .geometryTransition('sharedId')
                        .width(200)
                        .height(200)
                }
            }
        }
    }

    // 目的页配置共享元素id
    // ...  
    @Component
    class PageTwo {
        func build() {
            NavDestination() {
                Column() {
                    // ...
                    Image(@r(app.media.startIcon))
                        .geometryTransition('sharedId')
                        .width(200)
                        .height(200)
                }
            }
        }
    }
    ```

2. 将页面路由的操作，放到animateTo动画闭包中，配置对应的动画参数。

    ```cangjie
    @Component
    class PageOne {
        func build() {
            NavDestination() {
                Column() {
                    Button('跳转目的页')
                    .width(80.percent)
                    .height(40)
                    .margin(20)
                    .onClick({ => animateTo(AnimateParam(duration: 1200),
                        { => this.pageStack.pushPath(NavPathInfo(name: "PageTwo", param: "information"))})
                    })
                }
            }
        }
    }
    ```
