# 共享元素转场（一镜到底）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

共享元素转场是一种界面切换时对相同或者相似的两个元素做的一种位置和大小匹配的过渡动画效果，也称一镜到底动效。

如下例所示，在点击图片后，该图片消失，同时在另一个位置出现新的图片，二者之间内容相同，可以对它们添加一镜到底动效。左图为不添加一镜到底动效的效果，右图为添加一镜到底动效的效果，一镜到底的效果能够让二者的出现消失产生联动，使得内容切换过程显得灵动自然而不生硬。

|![sharedelementtransiton1](./figures/sharedelementtransition1.gif)|![sharedelementtransiton2](./figures/sharedelementtransition2.gif)|
| ---- | ---- |

一镜到底的动效有多种实现方式，在实际开发过程中，应根据具体场景选择合适的方法进行实现。

以下是不同实现方式的对比：

| 一镜到底实现方式 | 特点 | 适用场景 |
| :----- | :----- | :----- |
| 不新建容器直接变化原容器 | 不发生路由跳转，需要在一个组件中实现展开及关闭两种状态的布局，展开后组件层级不变。| 适用于转场开销小的简单场景，如点开页面无需加载大量数据及组件。 |
| 使用geometryTransition共享元素转场 | 利用系统能力，转场前后两个组件调用geometryTransition接口绑定同一id，同时将转场逻辑置于animateTo动画闭包内，这样系统侧会自动为二者添加一镜到底的过渡效果。 | 系统将调整绑定的两个组件的宽高及位置至相同值，并切换二者的透明度，以实现一镜到底过渡效果。因此，为了实现流畅的动画效果，需要确保对绑定geometryTransition的节点添加宽高动画不会有跳变。此方式适用于创建新节点开销小的场景。 |

## 不新建组件并直接变化原组件

该方法不新建容器，通过在已有容器上增删组件触发[transition](../reference/arkui-cj/cj-animation-transition.md#func-transitiontransitioneffect)，搭配组件[属性动画](./cj-attribute-animation-apis.md)实现一镜到底效果。

对于同一个容器展开，容器内兄弟组件消失或者出现的场景，可通过对同一个容器展开前后进行宽高位置变化并配置属性动画，对兄弟组件配置出现消失转场动画实现一镜到底效果。基本步骤为：

1. 构建需要展开的页面，并通过状态变量构建好普通状态和展开状态的界面。

2. 将需要展开的页面展开，通过状态变量控制兄弟组件消失或出现，并通过绑定出现消失转场实现兄弟组件转场效果。

以点击卡片后显示卡片内容详情场景为例：

 <!--run-->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.ui_context.*
import ohos.arkui.state_macro_manage.*
import ohos.resource_manager.*
import ohos.resource.__GenerateResource__

let storage: LocalStorage = LocalStorage()

class PostData{
    public var avatar: AppResource = @r(app.media.foreground)
    public var name: String = ""
    public var message: String = ""
    public var images: Array<AppResource> = []

    public init(avatar: AppResource,name:String,message: String,images: Array<AppResource>) {
        this.avatar = avatar
        this.name = name
        this.message = message
        this.images = images
    }
}

@Entry
@Component
class EntryView {
    @State var isExpand: Bool = false
    @State @Watch[onItemClicked] var selectedIndex: Int64 = -1

    // The photos in the array all use AppResource resources, which need to be defined by developers as needed.
    private var allPostData: Array<PostData> = [
        PostData(@r(app.media.startIcon),"Alice","天气晴朗",[@r(app.media.startIcon), @r(app.media.startIcon)] ),
        PostData(@r(app.media.startIcon),"Bob","你好世界",[@r(app.media.startIcon)]),
        PostData(@r(app.media.startIcon),"Carl","万物生长",[@r(app.media.startIcon), @r(app.media.startIcon),@r(app.media.startIcon)])
        ]

    private func onItemClicked():Unit {
        if(this.selectedIndex<0){
            return
        }
        spawn(UIThread) {
            getUIContext().animateTo(
                AnimateParam(duration: 350,curve: Curve.Friction),
                {
                    => this.isExpand = !this.isExpand
                }
            )
        }
    }

    func build() {
        Column(){
            ForEach(this.allPostData,itemGeneratorFunc:{postData: PostData,index: Int64
                    =>
                    // 当点击了某个post后，会使其余的post消失下树
                    if(!this.isExpand || this.selectedIndex==index){
                        Column(){
                           Post(data:postData,selecteIndex: this.selectedIndex,index: index)
                        }
                        .width(100.percent)
                        // 对出现消失的post添加透明度转场和位移转场效果
                        .transition(TransitionEffect.OPACITY
                                    .combine(TransitionEffect.translate(TranslateOptions(x:250.0,y:250.0,z:250.0)))
                                    .animation(AnimateParam(duration: 350,curve: Curve.Friction)))
                    }
                }
             )
        }
        .size(width: 100.percent, height: 100.percent)
        .backgroundColor(Color.Gray)
    }
}

@Component
class Post{
    @Link var selecteIndex:Int64

    @Prop var data:PostData
    @Prop var index:Int64

    @State var itemHeight: Int64 = 250
    @State var isExpand: Bool = false
    @State var expandImageSize: Int64 = 100
    @State var avatarSize: Int64 = 50

    public func build(){
        Column(){
            Row(){
                Image(this.data.avatar)
                    .size(width: this.avatarSize,height: this.avatarSize)
                    .borderRadius(this.avatarSize/2)
                    .clip(true)
                Text(this.data.name)
            }.justifyContent(FlexAlign.Start)

            Text(this.data.message)

            Row(){
                ForEach(this.data.images,itemGeneratorFunc:{imageResource: AppResource,index: Int64
                        =>
                        Image(imageResource).size(width: this.expandImageSize,height: this.expandImageSize)
                        }
                    )
            }
            if(this.isExpand){
                Column(){
                    Text("评论区")
                    // 对评论区文本添加出现消失转场效果
                    .transition(TransitionEffect.OPACITY.animation(AnimateParam(duration: 350,curve: Curve.Friction)))
                    .padding(top: 10)
                }.transition(TransitionEffect.asymmetric(TransitionEffect.opacity(0.99).animation(AnimateParam(duration: 350,curve: Curve.Friction)),TransitionEffect.OPACITY.animation(AnimateParam(duration:0))))
                .size(width: 100.percent, height: 20.percent)
            }
        }
        .backgroundColor(Color.White)
        .size(width: 100.percent, height: this.itemHeight)
        .alignItems(HorizontalAlign.Start)
        .padding(left:10,top:10)
        .onClick({
            evt =>
                this.selecteIndex = -1
                this.selecteIndex = this.index
                getUIContext().animateTo(AnimateParam(duration:350,curve:Curve.Friction),{
                    =>
                    // 对展开的post做宽高动画，并对头像尺寸和图片尺寸加动画
                    this.isExpand = !this.isExpand
                    if(this.isExpand){
                        this.itemHeight = 780
                        this.avatarSize = 75
                    }else{
                        this.itemHeight = 250
                        this.avatarSize = 50
                    }

                    if(this.isExpand && this.data.images.size > 0){
                        this.expandImageSize = (360 - (this.data.images.size + 1)*15)/this.data.images.size
                    }else{
                        this.expandImageSize = 100
                    }
                })
        })
    }
}
```

![shared-element-transition](figures/shared-element-transition.gif)

## 使用geometryTransition共享元素转场

[geometryTransition](../reference/arkui-cj/cj-animation-geometrytransition.md)用于组件内隐式共享元素转场，在视图状态切换过程中提供丝滑的上下文继承过渡体验。

geometryTransition的使用方式为对需要添加一镜到底动效的两个组件使用geometryTransition接口绑定同一id，这样在其中一个组件消失同时另一个组件创建出现的时候，系统会对二者添加一镜到底动效。

geometryTransition绑定两个对象的实现方式使得geometryTransition区别于其他方法，最适合用于两个不同对象之间完成一镜到底。

### geometryTransition的简单使用

对于同一个页面中的两个元素的一镜到底效果，geometryTransition接口的简单使用示例如下：

 <!-- run-->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.ui_context.*
import ohos.arkui.state_macro_manage.*
import kit.LocalizationKit.*

@Entry
@Component
class EntryView {
    @State var isShow: Bool = false
    func build() {
        Stack(alignContent: Alignment.Center) {
            if (this.isShow) {
                Image(@r(app.media.startIcon))
                    .autoResize(false)
                    .clip(true)
                    .width(200)
                    .height(200)
                    .borderRadius(100)
                    .geometryTransition("picture")
                    .transition(TransitionEffect.OPACITY)
                    .id("item1")
            } else {
                Column() {
                    Column() {
                        Image(@r(app.media.startIcon))
                            .width(100.percent).height(100.percent)
                    }.width(100.percent).height(100.percent)
                }
                .width(100)
                .height(100)
                // geometryTransition会同步圆角，但仅限于geometryTransition绑定处，此处绑定的是容器
                // 则对容器本身有圆角同步而不会操作容器内部子组件的borderRadius
                .borderRadius(20)
                .clip(true)
                .position(x:40,y:40)
                .geometryTransition("picture")
                // transition保证节点离场不被立即析构，设置通用转场效果
                .transition(TransitionEffect.OPACITY)
                .id("item2")
            }
        }
        .onClick({
            event => getUIContext().animateTo(AnimateParam(duration:1000,curve:Curve.Linear), ({=>this.isShow = !this.isShow}))
        })
        .size(width:100.percent,height:100.percent)
    }
}
```

![shared-element-transition1](./figures/shared-element-transition1.gif)

### geometryTransition结合模态转场使用

更多的场景中，需要对一个页面的元素与另一个页面的元素添加一镜到底动效。可以通过geometryTransition搭配模态转场接口实现。以点击头像弹出个人信息页的demo为例：

 <!--run-->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.ui_context.*
import ohos.arkui.state_macro_manage.*
import ohos.resource_manager.AppResource
import ohos.resource.__GenerateResource__
import kit.PerformanceAnalysisKit.Hilog

let storage: LocalStorage = LocalStorage()

class PostData{
    public var avatar: AppResource = @r(app.media.foreground)
    public var name: String = ""
    public var message: String = ""
    public var images: Array<AppResource> = []

    public init(avatar: AppResource,name:String,message: String,images: Array<AppResource>) {
        this.avatar = avatar
        this.name = name
        this.message = message
        this.images = images
    }
}

@Entry
@Component
class EntryView {
    @State var isPersonalPageShow: Bool = false;
    @State var selectedIndex: Int = 0
    @State var alphaValue: Float64 = 1.0

    private var allPostData: Array<PostData> = [
        PostData(@r(app.media.startIcon),"Alice","天气晴朗",[@r(app.media.startIcon), @r(app.media.startIcon)] ),
        PostData(@r(app.media.startIcon),"Bob","你好世界",[@r(app.media.startIcon)]),
        PostData(@r(app.media.startIcon),"Carl","万物生长",[@r(app.media.startIcon),@r(app.media.startIcon),@r(app.media.startIcon)])
        ]

    public func onAppear() {
        Hilog.info(0, "cangjie", "BindContentCover onAppear.")
    }
    public func onDisappear() {
        Hilog.info(0, "cangjie", "BindContentCover onDisappear.")
    }

    private func onAvatarClicked(index: Int):Unit {
        this.selectedIndex = index
        getUIContext().animateTo(
            AnimateParam(duration: 350,curve: Curve.Friction),
            {
                =>
                this.isPersonalPageShow = !this.isPersonalPageShow
                this.alphaValue = 0.0
            }
        )
    }

    private func onPersonalPageBack(index: Int):Unit{
        getUIContext().animateTo(AnimateParam(duration: 350,curve: Curve.Friction),{
            =>
            this.isPersonalPageShow = !this.isPersonalPageShow;
            this.alphaValue = 1.0;
        })
    }

    @Builder
    public func PersonalPageBuilder(){
        Column(){
            Image(this.allPostData[this.selectedIndex].avatar)
            .size(width:200,height:200)
            .borderRadius(100)
            // 头像配置共享元素效果，与点击的头像的id匹配
            .geometryTransition(this.selectedIndex.toString())
            .clip(true)
            .transition(TransitionEffect.opacity(0.99))

            Text(this.allPostData[this.selectedIndex].name)
            // 对文本添加出现转场效果
            .transition(TransitionEffect.asymmetric(
                TransitionEffect.OPACITY.combine(TransitionEffect.translate(TranslateOptions(x:100,y:100,z:100))),
                TransitionEffect.OPACITY.animation(AnimateParam(duration: 0))))

            Text("你好，我是${this.allPostData[this.selectedIndex].name}")
            .transition(TransitionEffect.asymmetric(
                TransitionEffect.OPACITY.combine(TransitionEffect.translate(TranslateOptions(x:100,y:100,z:100))),
                TransitionEffect.OPACITY.animation(AnimateParam(duration: 0))))
        }
        .padding(20)
        .size(width:360,height:780)
        .backgroundColor(Color.White)
        .onClick({
            evt =>
            this.onPersonalPageBack(this.selectedIndex)
        })
        .transition(TransitionEffect.asymmetric(
            TransitionEffect.opacity(0.99),TransitionEffect.OPACITY
        ))
    }

    func build() {
        Column(){
            ForEach(this.allPostData,itemGeneratorFunc:{postData: PostData,index: Int
                =>
                Column(){
                    Post(data:postData,index: index,postOnAvatarClicked: this.onAvatarClicked)
                    }.width(100.percent)
                }
             )
        }
        .size(width: 100.percent, height: 100.percent)
        .backgroundColor(Color.Gray)
        .bindContentCover(this.isPersonalPageShow, this.PersonalPageBuilder,
            options: ContentCoverOptions(
            modalTransition: ModalTransition.None,
            onAppear: onAppear,
            onDisappear: onDisappear)
            )
        .opacity(this.alphaValue)
    }
}

@Component
class Post{
    @Prop var data: PostData
    @Prop var index: Int

    @State var expandImageSize: Int = 100
    @State var avatarSize: Int = 50

    let postOnAvatarClicked: (Int) -> Unit

    public func build(){
         Column(){
            Row(){
                Image(this.data.avatar)
                .size(width: this.avatarSize,height: this.avatarSize)
                .borderRadius(this.avatarSize/2)
                .clip(true)
                .onClick({
                        evt =>
                        this.postOnAvatarClicked(this.index)
                })
                // 对头像绑定共享元素转场的id
                .geometryTransition(this.index.toString(), follow: true)
                .transition(TransitionEffect.OPACITY.animation(AnimateParam(duration: 350,curve: Curve.Friction)))

                Text(this.data.name)
            }
            .justifyContent(FlexAlign.Center)

            Text(this.data.message)

            Row(){
                ForEach(this.data.images, itemGeneratorFunc: {imageResource: AppResource,index: Int
                    =>
                    Image(imageResource)
                    .size(width:100,height:100)
                    })
            }
         }
        .backgroundColor(Color.White)
        .size(width:100.percent,height:250)
        .alignItems(HorizontalAlign.Start)
        .padding(left:10,top:10)
    }
}
```

效果为点击主页的头像后，弹出模态页面显示个人信息，并且两个页面之间的头像做一镜到底动效：

![shared-element-transiton2](./figures/shared-element-transition2.gif)
