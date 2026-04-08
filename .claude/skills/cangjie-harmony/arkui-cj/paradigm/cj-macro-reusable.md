# @Reusable宏：组件复用

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

@Reusable宏装饰任意自定义组件时，表示该自定义组件可以复用。

## 概述

@Reusable适用自定义组件，与[@Component](./cj-create-custom-components.md#component)结合使用，标记为@Reusable的自定义组件从组件树上被移除时，组件和其对应的页面对象都会被放入复用缓存中，后续创建新自定义组件节点时，会复用缓存区中的节点，节约组件重新创建的时间。

## 限制条件

- 暂时不支持混合工程。

- @Reusable仅用于自定义组件。

    <!-- run -->

    ```cangjie
    package ohos_app_cangjie_entry
    import kit.ArkUI.*
    import ohos.arkui.state_management.*
    import ohos.arkui.state_macro_manage.*

    // @Builder加上@Reusable编译报错，不适用于builder
    // @Reusable
    @Builder
    func MyBuilder() {
        Crash()
    }

    @Component
    public class Crash {
        public func build() {
            Column() {
                Text("Crash")
                    .fontSize(12)
                    .lineHeight(8)
                    .fontColor(Color.Blue)
            }
            .width(100.percent)
            .height(100.percent)
            .justifyContent(FlexAlign.Center)
        }
    }

    @Entry
    @Component
    public class EntryView {
        public func build(): Unit {
            Column() {
                MyBuilder()
            }
        }
    }
    ```

- @Reusable宏不支持嵌套使用，存在增加内存和不方便维护的问题。

    > **说明：**
    >
    > - 不支持嵌套使用，只是标记，会多增加一个缓存池，各自的复用缓存池存在相同树状结构，复用效率低，引发复用内存增加；
    > - 嵌套使用形成各自独立的复用缓存池之后，生命周期的传递存在问题，资源和变量管理无法共享，并不方便维护，容易引发问题；
    > - 示例中PlayButton形成的复用缓存池，并不能在PlayButton02的复用缓存池使用，但PlayButton02自己形成复用缓存相互可以使用；
    > - 在PlayButton隐藏时已经触发PlayButton02的aboutToRecycle，但是在PlayButton02单独显示时却无法执行aboutToReuse，组件复用的生命周期方法存在无法成对调用问题；
    > - 综上，不建议嵌套使用。

    <!-- run -->

    ```cangjie
    package ohos_app_cangjie_entry

    import kit.ArkUI.*
    import ohos.arkui.state_macro_manage.*
    import kit.PerformanceAnalysisKit.Hilog

    @Entry
    @Component
    public class EntryView {
        @State
        var isPlaying: Bool = false
        @State
        var isPlaying01: Bool = true
        @State
        var isPlaying02: Bool = false

        public func build() {
            Column() {
                if (this.isPlaying02) {
                    // 初始态是显示的按钮
                    Text("Default shown childbutton").fontSize(14)
                    PlayButton02(isPlaying02: isPlaying02)
                }
                Text("==================").fontSize(14)

                if (this.isPlaying01) {
                    // 初始态是隐藏的按钮
                    Text("Default hidden childbutton").fontSize(14)
                    PlayButton02(isPlaying02: isPlaying01)
                }
                Text("==================").fontSize(14)

                // 父子嵌套
                if (this.isPlaying) {
                    Text("parent child 嵌套").fontSize(14)
                    PlayButton(buttonPlaying: isPlaying)
                }
                Text("==================").fontSize(14)

                // 父子嵌套控制
                Text("Parent=child==is ${if(isPlaying) {""} else {"not"}} playing").fontSize(14)
                Button("Parent=child===controll=${isPlaying}").margin(14).onClick({
                    e => isPlaying = !isPlaying
                })
                Text("==================").fontSize(14)

                // 默认隐藏按钮控制
                Text("Hiddenchild==is ${if(isPlaying01) {""} else {"not"}} playing").fontSize(14)
                Button("Button===hiddenchild==control==${isPlaying01}").margin(14).onClick({
                   e => isPlaying01 = !isPlaying01
                })
                Text("==================").fontSize(14)

                // 默认显示按钮控制
                Text("shownchid==is ${if(isPlaying02) {""} else {"not"}} playing").fontSize(14)
                Button("Button===shownchid==control==${isPlaying02}").margin(14).onClick({
                    e => isPlaying02 = !isPlaying02
                })
            }
        }
    }

    // 复用1
    @Reusable
    @Component
    class PlayButton {
        @Link var buttonPlaying: Bool

        func build() {
            Column() {
                // 复用
                PlayButton02(isPlaying02: buttonPlaying)
                Button(if(buttonPlaying) {"parent_pause"} else {"parent_play"}).margin(12).onClick({
                    e => buttonPlaying = !buttonPlaying
                })
            }
        }
    }

    // 复用2 不建议嵌套使用
    @Reusable
    @Component
    class PlayButton02 {
        @Link var isPlaying02: Bool
        protected override func aboutToRecycle(): Unit {
            Hilog.info(0, "cangjie", "=====aboutToRecycle====PlayButton02====")
        }
        protected override func aboutToReuse(param: ReuseParams) {
            Hilog.info(0, "cangjie", "=====aboutToReuse====PlayButton02====")
        }
        func build() {
            Column() {
                Button("===commonbutton====").margin(12)
            }
        }
    }
    ```

## 使用场景

- 列表滚动：当应用需要展示大量数据的列表，并且用户进行滚动操作时，频繁创建和销毁列表项的视图可能导致卡顿和性能问题。在这种情况下，使用列表组件的组件复用机制可以重用已经创建的列表项视图，提高滚动的流畅度。

- 动态布局更新：如果应用中的界面需要频繁地进行布局更新，例如根据用户的操作或数据变化动态改变视图结构和样式，重复创建和销毁视图可能导致频繁的布局计算，影响帧率。在这种情况下，使用组件复用可以避免不必要的视图创建和布局计算，提高性能。

- 频繁创建和销毁数据项的视图场景下。使用组件复用可以重用已创建的视图，只更新数据的内容，减少视图的创建和销毁，能有效提高性能。

## 使用场景举例

### 动态布局更新

- 示例代码将Child自定义组件标记为复用组件，通过Button点击更新Child，触发Child复用;

- @Reusable：自定义组件被@Reusable宏修饰，即表示其具备组件复用的能力;

- aboutToReuse：当一个可复用的自定义组件从复用缓存中重新加入到节点树时，触发aboutToReuse生命周期回调，并将组件的构造参数传递给aboutToReuse。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.PerformanceAnalysisKit.Hilog

public class Message {
    public var value: String
    public init(val: String) {
        value = val
    }
}

@Entry
@Component
public class EntryView {
    @State var switch: Bool = true
    public func build() {
        Column() {
            Button("Hello")
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .onClick({evt =>
                switch = !switch
            })
            if (switch) {
                Child(message: Message("Child"))
            }
        }.height(100.percent).width(100.percent)
    }
}

@Reusable
@Component
class Child {
    @State
    var message: Message = Message("about to reuse")
    protected override func aboutToReuse(params: ReuseParams) {
        if (let Some(value) <- params.get<Message>("message")) {
            message = value as Message ?? Message("None")
            Hilog.info(0, "cangjie", "Recycle ===Child===")
        }
    }
    func build() {
        Column() {
            Text(this.message.value)
        }.borderWidth(1).height(100)
    }
}
```

### 列表滚动配合LazyForEach使用

- 示例代码将CardView自定义组件标记为复用组件，List上下滑动，触发CardView复用;

- @Reusable：自定义组件被@Reusable装饰器修饰，即表示其具备组件复用的能力;

- 变量item的被@State修饰，才能更新，非@State修饰变量存在无法更新问题。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_management.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import kit.PerformanceAnalysisKit.Hilog

class MyDataSource <: IDataSource<Int64> {
    public MyDataSource(let data_: ArrayList<Int64>) {}
    public var listenerOp: Option<DataChangeListener> = None
    public func totalCount(): Int64 {
        return data_.size
    }
    public func getData(index: Int64): Int64 {
        return data_[index]
    }

    public func pushData(val: Int64): Unit {
        data_.add(val)
    }

    public func registerDataChangeListener(listener: DataChangeListener): Unit {
        listenerOp = listener
    }

    public func unregisterDataChangeListener(listener: DataChangeListener): Unit {
        listenerOp = None
    }
}

@Entry
@Component
public class EntryView {
    let data: MyDataSource = MyDataSource(ArrayList<Int64>([]))
    protected override func aboutToAppear() {
        for (i in 0..1000) {
            data.pushData(i)
        }
    }

    public func build(): Unit {
        Column() {
            List() {
                LazyForEach(
                    data,
                    itemGeneratorFunc: {
                        item: Int64, idx: Int64 => ListItem() {
                            CardView(item: "${item}")
                        }
                    }
                )
            }
        }
    }
}

// 复用组件
@Reusable
@Component
class CardView {
    @State
    var item: String = ""
    protected override func aboutToReuse(params: ReuseParams) {
        if (let Some(value) <- params.get<String>("item")) {
            item = value
            Hilog.info(0, "cangjie", "Recycle ===Child===")
        }
    }
    func build() {
        Column() {
            Text(item)
        }.borderWidth(1).height(100)
    }
}
```

### if使用场景

示例代码将OneMoment自定义组件标记为复用组件，List上下滑动，触发OneMoment复用;

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_management.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import kit.PerformanceAnalysisKit.Hilog
import kit.LocalizationKit.*
import ohos.resource.__GenerateResource__

class MyDataSource <: IDataSource<FriendMoment> {
    public MyDataSource(let data_: ArrayList<FriendMoment>) {}
    public var listenerOp: Option<DataChangeListener> = None
    public func totalCount(): Int64 {
        return data_.size
    }
    public func getData(index: Int64): FriendMoment {
        return data_[index]
    }

    public func pushData(val: FriendMoment): Unit {
        data_.add(val)
    }

    public func registerDataChangeListener(listener: DataChangeListener): Unit {
        listenerOp = listener
    }

    public func unregisterDataChangeListener(listener: DataChangeListener): Unit {
        listenerOp = None
    }
}

public class FriendMoment {
    public var text: String = ""
    public var title: String = ""
    public var image: ?AppResource = None
    public init(text: String, title: String, image: ?AppResource) {
        this.text = text
        this.title = title
        this.image = image
    }

}

@Reusable
@Component
public class OneMoment {
    @State var moment: FriendMoment = FriendMoment("", "", @r(app.media.startIcon))
    protected override func aboutToReuse(params: ReuseParams) {
        if (let Some(value) <- params.get<FriendMoment>("moment")) {
            let pVal = value
            this.moment = pVal
            Hilog.info(0, "cangjie", "====aboutToReuse====OnMoment==复用了==== ${pVal.text}")
        }
    }
    public func build() {
        Column() {
            Text(moment.text)
            if (moment.image.isSome()) {
                Flex(wrap: FlexWrap.Wrap) {
                    Image((moment.image) ?? @r(app.media.background)).height(50).width(50)
                    Image((moment.image) ?? @r(app.media.background)).height(50).width(50)
                    Image((moment.image) ?? @r(app.media.background)).height(50).width(50)
                    Image((moment.image) ?? @r(app.media.background)).height(50).width(50)
                }
            }
        }
    }
}

@Entry
@Component
public class EntryView {
    let data: MyDataSource = MyDataSource(ArrayList<FriendMoment>([]))
    protected override func aboutToAppear() {
        for (i in 0..20) {
            let title = "${i+1}test+if"
            data.pushData(FriendMoment("${i}", title, @r(app.media.startIcon)))
        }
        for (i in 0..50) {
            let title = "${i+1}test+if"
            data.pushData(FriendMoment("${i}", title, Option<AppResource>.None))
        }
    }

    public func build(): Unit {
        Column() {
            List() {
                LazyForEach(
                    data,
                    itemGeneratorFunc: {
                        item: FriendMoment, idx: Int64 => ListItem() {
                            OneMoment(moment: item)
                        }
                    }
                )
            }
        }
    }
}
```
