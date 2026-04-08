# ForEach：循环渲染

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

ForEach接口基于数组类型数据来进行循环渲染，需要与容器组件配合使用，且接口返回的组件应当是允许包含在ForEach父容器组件中的子组件。例如，ListItem组件要求ForEach的父容器组件必须为[List组件](../../reference/arkui-cj/cj-scroll-swipe-list.md)。

## 键值生成规则

在ForEach循环渲染过程中，系统会为每个数组元素生成一个唯一且持久的键值，用于标识对应的组件。当这个键值变化时，仓颉将视为该数组元素已被替换或修改，并会基于新的键值创建一个新的组件。

ForEach提供了一个名为keyGenerator的参数，这是一个函数，开发者可以通过它自定义键值的生成规则。如果开发者没有定义keyGenerator函数，则ArkUI框架会使用默认的键值生成函数。

ArkUI框架对于ForEach的键值生成有一套特定的判断规则，这主要与itemGenerator函数的第二个参数index以及keyGenerator函数的第二个参数index有关。

> **说明：**
>
> ArkUI框架会对重复的键值发出警告。在UI更新的场景下，如果出现重复的键值，框架可能无法正常工作，具体请参见[渲染结果非预期](#渲染结果非预期)。

## 组件创建规则

在确定键值生成规则后，ForEach的第二个参数itemGenerator函数会根据键值生成规则为数据源的每个数组项创建组件。组件的创建包括两种情况：[ForEach首次渲染](#首次渲染)和[ForEach非首次渲染](#非首次渲染)。

## 首次渲染

在ForEach首次渲染时，会根据前述键值生成规则为数据源的每个数组项生成唯一键值，并创建相应的组件。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Component
class ChildItem {
    @Prop var item: String
    func build() {
        Text(this.item)
        .fontSize(50)
    }
}

@Entry
@Component
class EntryView {
    @State var simpleList: Array<String> = ['one', 'two','three']
    func build() {
        Row() {
            Column() {
                ForEach(this.simpleList,itemGeneratorFunc: {item: String,idx:Int64 =>
            ChildItem(item: item)}, keyGeneratorFunc: {item: String, idx: Int64 => return item})
            }
            .justifyContent(FlexAlign.Center)
            .width(100.percent)
            .height(100.percent)
        }
        .height(100.percent)
        .backgroundColor(Color.White)
    }
}
```

运行效果如下图所示。

图1 ForEach数据源不存在相同值案例首次渲染运行效果图

![onetwothree](figures/onetwothree.png)

在上述代码中，键值生成规则是keyGenerator函数的返回值item。在ForEach渲染循环时，为数据源数组项依次生成键值one、two和three，并创建对应的ChildItem组件渲染到界面上。

当不同数组项按照键值生成规则生成的键值相同时，框架的行为是未定义的。例如，在以下代码中，ForEach渲染相同的数据项two时，只创建了一个ChildItem组件，而没有创建多个具有相同键值的组件。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Component
class ChildItem {
    @Prop var item: String
    func build() {
        Text(this.item)
        .fontSize(50)
    }
}

@Entry
@Component
class EntryView {
    @State var simpleList: Array<String> = ['one', 'two','two','three']
    func build() {
        Row() {
            Column() {
                ForEach(this.simpleList,itemGeneratorFunc: {item: String,idx:Int64 =>
                    ChildItem(item: item)}, keyGeneratorFunc: {item: String, idx: Int64 => return item})
            }
            .justifyContent(FlexAlign.Center)
            .width(100.percent)
            .height(100.percent)
        }
        .height(100.percent)
        .backgroundColor(Color.White)
    }
}
```

图2 ForEach数据源存在相同值案例首次渲染运行效果图

![onetwothree2](figures/onetwothree2.png)

在该示例中，最终键值生成规则为item。当ForEach遍历数据源simpleList，遍历到索引为1的two时，按照最终键值生成规则生成键值为two的组件并进行标记。当遍历到索引为2的two时，按照最终键值生成规则当前项的键值也为two，此时不再创建新的组件。

## 非首次渲染

在ForEach组件进行非首次渲染时，它会检查新生成的键值是否在上次渲染中已经存在。如果键值不存在，则会创建一个新的组件；如果键值存在，则不会创建新的组件，而是直接渲染该键值所对应的组件。例如，在以下的代码示例中，通过点击事件修改了数组的第三项值为"new three"，这将触发ForEach组件进行非首次渲染。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Component
class ChildItem {
    @Prop var item: String
    func build() {
        Text(this.item)
        .fontSize(50)
    }
}

@Entry
@Component
class EntryView {
    @State var simpleList: ObservedArrayList<String> = ObservedArrayList<String>(['one', 'two','three'])
    func build() {
        Row() {
            Column() {
                Text("点击修改第3个数组项的值")
                .fontSize(24)
                .fontColor(Color.Red)
                .onClick({evt=>
                this.simpleList[2] = 'new three'
                })
                ForEach(this.simpleList,itemGeneratorFunc: {item: String,idx:Int64 =>
                ChildItem(item: item)}, keyGeneratorFunc: {item: String, idx: Int64 => return item})
            }
            .justifyContent(FlexAlign.Center)
            .width(100.percent)
            .height(100.percent)
        }
        .height(100.percent)
        .backgroundColor(Color.White)
    }
}
```

运行效果如下图所示。

图3 ForEach非首次渲染案例运行效果图

![changenumthree.gif](figures/changenumthree.gif)

从本例可以看出[@State](../state_management/cj-macro-state.md)能够监听到简单数据类型数组数据源 simpleList 数组项的变化。

1. 当 simpleList 数组项发生变化时，会触发 ForEach 进行重新渲染。
2. ForEach 遍历新的数据源 ['one', 'two', 'new three']，并生成对应的键值one、two和new three。
3. 其中，键值one和two在上次渲染中已经存在，所以 ForEach 复用了对应的组件并进行了渲染。对于第三个数组项 "new three"，由于其通过键值生成规则 item 生成的键值new three在上次渲染中不存在，因此 ForEach 为该数组项创建了一个新的组件。

## 使用场景

ForEach组件在开发过程中的主要应用场景包括：[数据源不变](#数据源不变)、[数据源数组项发生变化](#数据源数组项发生变化)（如插入、删除操作）。

## 数据源不变

在数据源保持不变的场景中，数据源可以直接采用基本数据类型。例如，在页面加载状态时，可以使用骨架屏列表进行渲染展示。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Builder
func textArea(width: Int64, height:Int64) {
    Row()
    .width(width)
    .height(height)
    .backgroundColor(Color.White)
}

@Component
class ArticleSkeletonView {
    func build() {
        Row() {
            Column() {
                textArea(80, 80)
            }
            .margin(right: 20 )
            Column() {
                textArea(60, 20)
                textArea(50, 20)
            }
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.SpaceAround)
            .height(100)
        }
        .padding(20)
        .borderRadius(12)
        .backgroundColor(Color.Gray)
        .height(120)
        .width(100.percent)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin(top: 20)
    }
}

@Entry
@Component
class EntryView {
    @State var simpleList: Array<Int64> = [1, 2, 3, 4, 5]
    func build() {
        Column() {
            ForEach(this.simpleList, itemGenerator: {item: Int64,idx:Int64 =>ArticleSkeletonView()}
            )
        }
        .padding(20)
        .width(100.percent)
        .height(100.percent)
    }
}
```

运行效果如下图所示。

图4 骨架屏运行效果图

![skscreem.png](figures/skscreem.png)

## 数据源数组项发生变化

在数据源数组项发生变化的场景下，例如进行数组插入、删除操作或者数组项索引位置发生交换时，数据源应为对象数组类型，并使用对象的唯一ID作为最终键值。例如，当在页面上通过手势上滑加载下一页数据时，会在数据源数组尾部新增新获取的数据项，从而使得数据源数组长度增大。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import kit.LocalizationKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.resource.__GenerateResource__

class Article {
    var id: String
    var title: String
    var brief: String
    init(id: String, title: String, brief: String) {
        this.id = id
        this.title = title
        this.brief = brief
    }
}

@Builder
func textArea(width: Int64, height:Int64) {
    Row()
    .width(width)
    .height(height)
    .backgroundColor(Color.White)
}

@Component
class ArticleCard {
    @Prop var article: Article
    func build() {
        Row(){
        // 此处'app.media.icon'仅作示例，请开发者自行替换，否则imageSource创建失败会导致后续无法正常执行。
        Image(@r(app.media.startIcon))
        .width(80)
        .height(80)
        .margin(right:20)
        Column() {
            Text(this.article.title)
            .fontSize(20)
            .margin(bottom:8)
            Text(this.article.brief)
            .fontSize(16)
            .fontColor(Color.Gray)
            .margin(bottom: 8)
        }
        .alignItems(HorizontalAlign.Start)
        .width(80.percent)
        .height(100.percent)
        }
        .padding(20)
        .borderRadius(12)
        .backgroundColor(Color.White)
        .height(120)
        .width(100.percent)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin(top: 20)
    }
}

@Entry
@Component
class EntryView {
    @State var isListReachEnd: Bool = false
    @State var articleList: ObservedArrayList<Article> = ObservedArrayList<Article>([
        Article('001', '第1篇文章', '文章简介内容'),
        Article('002', '第2篇文章', '文章简介内容'),
        Article('003', '第3篇文章', '文章简介内容'),
        Article('004', '第4篇文章', '文章简介内容'),
        Article('005', '第5篇文章', '文章简介内容'),
        Article('006', '第6篇文章', '文章简介内容')
    ])
    func loadMoreArticles() {
        this.articleList.append(Article('007', '加载的新文章', '文章简介内容'))
            Hilog.info(0,"here","here")
    }
    func build() {
        Column(space: 5) {
            List() {
                ForEach(this.articleList, itemGeneratorFunc: {item: Article,idx:Int64  =>
                    ListItem() {
                        ArticleCard(article: item)
                    }
                    }, keyGeneratorFunc: {item: Article, idx: Int64 => return item.id})
            }
            .onReachEnd( {=>
                this.isListReachEnd = true
            })
        .padding(20)
        .scrollBar(BarState.Off)
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(Color.Gray)
    }
}
```

初始运行效果（左图）和手势上滑加载后效果（右图）如下图所示。

图5 数据源数组项变化案例运行效果图

![datachange.png](figures/datachange.png) ![datachange2.png](figures/datachange2.png)

在本示例中，ArticleCard组件作为ArticleListView组件的子组件，通过@Prop装饰器接收一个Article对象，用于渲染文章卡片。

1. 当列表滚动到底部时，如果手势滑动距离超过指定的80，将触发loadMoreArticles()函数。此函数会在articleList数据源的尾部添加一个新的数据项，从而增加数据源的长度。
2. 数据源被@State装饰器修饰，ArkUI框架能够感知到数据源长度的变化，并触发ForEach进行重新渲染。

## 使用建议

- 为满足键值的唯一性，对于对象数据类型，建议使用对象数据中的唯一id作为键值。
- 尽量避免在最终的键值生成规则中包含数据项索引index，以防止出现[渲染结果非预期](#渲染结果非预期)和[渲染性能降低](#渲染性能降低)。如果业务确实需要使用index，例如列表需要通过index进行条件渲染，开发者需要接受ForEach在改变数据源后重新创建组件所带来的性能损耗。
- 基本数据类型的数据项没有唯一ID属性。如果使用基本数据类型本身作为键值，必须确保数组项无重复。因此，对于数据源会发生变化的场景，建议将基本数据类型数组转化为具备唯一ID属性的对象数据类型数组，再使用唯一ID属性作为键值。
- 对于以上限制规则，index参数存在的意义为：index是开发者保证键值唯一性的最终手段；对数据项进行修改时，由于itemGenerator中的item参数是不可修改的，所以须用index索引值对数据源进行修改，进而触发UI重新渲染。
- ForEach在下列容器组件 [List](../../reference/arkui-cj/cj-scroll-swipe-list.md)、[Grid](../../reference/arkui-cj/cj-scroll-swipe-grid.md)、[Swiper](../../reference/arkui-cj/cj-scroll-swipe-swiper.md)内使用的时候，不要与LazyForEach 混用。 以List为例，同时包含ForEach、LazyForEach的情形是不推荐的。
- 数组项是对象数据类型的情况下，不建议用内容相同的数组项替换旧的数组项。

## 不推荐案例

开发者在使用ForEach的过程中，若对于键值生成规则的理解不够充分，可能会出现错误的使用方式。错误使用一方面会导致功能层面问题，例如[渲染结果非预期](#渲染结果非预期)，另一方面会导致性能层面问题，例如[渲染性能降低](#渲染性能降低)。

### 渲染结果非预期

在本示例中，通过设置ForEach的第三个参数keyGenerator函数，自定义键值生成规则为数据源的索引index的字符串类型值。当点击父组件EntryView中“在第1项后插入新项”文本组件后，界面会出现非预期的结果。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import kit.LocalizationKit.*
import kit.PerformanceAnalysisKit.Hilog

@Component
class ChildItem {
    @Prop var item: String
    func build() {
        Text(this.item)
        .fontSize(30)
    }
}

@Entry
@Component
class EntryView {
    @State var simpleList: ObservedArrayList<String> =ObservedArrayList(['one', 'two', 'three'])
    func build() {
        Column() {
            Button() {
                Text('在第1项后插入新项').fontSize(20)
            }.width(240).height(45).backgroundColor(0x0A59F7)
            .onClick({ evt =>
                this.simpleList.insert(1,'new item')
            })
            ForEach(this.simpleList, itemGeneratorFunc: {item: String ,idx:Int64 =>ChildItem(item: item)
            },keyGeneratorFunc: {item: String, index: Int64 => index.toString()}
            )
        }
    .justifyContent(FlexAlign.Center)
    .width(100.percent)
    .height(100.percent)
    .backgroundColor(Color.White)
    }
}
```

上述代码的初始渲染效果和点击“在第1项后插入新项”文本组件后的渲染效果如下图所示。

图6 渲染结果非预期运行效果图

![renderunexpect.gif](figures/renderunexpect.gif)

ForEach在首次渲染时，创建的键值依次为"0"、"1"、"2"。

插入新项后，数据源simpleList变为['one', 'new item', 'two', 'three']，框架监听到@State装饰的数据源长度变化触发ForEach重新渲染。

ForEach依次遍历新数据源，遍历数据项"one"时生成键值"0"，存在相同键值，因此不创建新组件。继续遍历数据项"new item"时生成键值"1"，存在相同键值，因此不创建新组件。继续遍历数据项"two"生成键值"2"，存在相同键值，因此不创建新组件。最后遍历数据项"three"时生成键值"3"，不存在相同键值，创建内容为"three"的新组件并渲染。

从以上可以看出，当最终键值生成规则包含index时，期望的界面渲染结果为['one', 'new item', 'two', 'three']，而实际的渲染结果为['one', 'two', 'three', 'three']，渲染结果不符合开发者预期。因此，开发者在使用ForEach时应尽量避免最终键值生成规则中包含index。

### 渲染性能降低

在本示例中，ForEach的第三个参数keyGenerator函数处于缺省状态。当点击“在第1项后插入新项”文本组件后，ForEach将需要为第2个数组项以及其后的所有项重新创建组件。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import kit.LocalizationKit.*
import kit.PerformanceAnalysisKit.Hilog

@Component
class ChildItem {
    @Prop var item: String
    protected override func aboutToAppear() {
    Hilog.info(0,"0","[aboutToAppear]: item is ${this.item}")
    }
    func build() {
        Text(this.item)
        .fontSize(30)
    }
}

@Entry
@Component
class EntryView {
    @State var simpleList: ObservedArrayList<String> =ObservedArrayList(['one', 'two', 'three'])
    func build() {
        Column() {
            Button() {
            Text('在第1项后插入新项').fontSize(30)
            }.width(240).height(45).backgroundColor(0x0A59F7)
            .onClick({
                evt =>this.simpleList.insert(1,'new item')
            })
            ForEach(this.simpleList, itemGenerator: {item: String ,idx:Int64 =>
            ChildItem(item: item)}
            )
        }
    .justifyContent(FlexAlign.Center)
    .width(100.percent)
    .height(100.percent)
    .backgroundColor(Color.White)
    }
}
```

以上代码的初始渲染效果和点击"在第1项后插入新项"文本组件后的渲染效果如下图所示。

图7 渲染性能降低案例运行效果图

![renderlowq.gif](figures/renderlowq.gif)

点击“在第1项后插入新项”文本组件后，DevEco Studio的日志打印结果如下所示。

图8 渲染性能降低案例日志打印图

![log.png](figures/log.png)

插入新项后，ForEach为new item、 two、 three三个数组项创建了对应的组件ChildItem，并执行了组件的aboutToAppear()生命周期函数。这是因为：

1. 在ForEach首次渲染时，创建的键值依次为0__one、1__two、2__three。
2. 插入新项后，数据源simpleList变为['one', 'new item', 'two', 'three']，ArkUI框架监听到@State装饰的数据源长度变化触发ForEach重新渲染。
3. ForEach依次遍历新数据源，遍历数据项one时生成键值0__one，键值已存在，因此不创建新组件。继续遍历数据项new item时生成键值1__new item，不存在相同键值，创建内容为new item的新组件并渲染。继续遍历数据项two生成键值2__two，不存在相同键值，创建内容为two的新组件并渲染。最后遍历数据项three时生成键值3__three，不存在相同键值，创建内容为three的新组件并渲染。

尽管此示例中界面渲染的结果符合预期，但每次插入一条新数组项时，ForEach都会为从该数组项起后面的所有数组项全部重新创建组件。当数据源数据量较大或组件结构复杂时，由于组件无法得到复用，将导致性能体验不佳。因此，除非必要，否则不推荐将第三个参数keyGenerator函数处于缺省状态，以及在键值生成规则中包含数据项索引index。

正确渲染并保证效率的ForEach写法是：

```cangjie
ForEach(this.simpleList, itemGenerator: {item: String ,idx:Int64 =>ChildItem(item: item)}, keyGenerator: {item: String, index: Int64 => item})
```

提供了第三个参数keyGenerator，在这个例子中，对数据源的不同数据项生成不同的key，并且对同一个数据项每次生成相同的key。
