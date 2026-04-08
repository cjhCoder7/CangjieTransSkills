# @Prop宏：父子单向同步

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

\@Prop装饰的变量可以和父组件建立单向的同步关系。\@Prop装饰的变量是可变的，但是变化不会同步回其父组件。

在阅读\@Prop文档前，建议开发者首先了解[\@State](./cj-macro-state.md)的基本用法。

## 概述

\@Prop装饰的变量和父组件建立单向的同步关系：

- \@Prop变量允许在本地修改，但修改后的变化不会同步回父组件。
- 当数据源更改时，\@Prop装饰的变量都会更新，并且会覆盖本地所有更改。因此，数值的同步是父组件到子组件（所属组件），子组件数值的变化不会同步到父组件。

## 限制条件

- \@Prop修饰当前组件所拥有的状态，仅可在子组件中定义，不能在[\@Entry](../paradigm/cj-create-custom-components.md#自定义组件的基本结构)装饰的自定义组件中使用。
- \@Prop装饰的变量是可变的，只能用var来声明，且必须指明类型。
- \@Prop禁止本地初始化，必须从父组件初始化。
- \@Prop装饰的变量需要和数据源类型一致，且数据源必须是宏装饰的状态变量（如\@State）。

## 宏使用规则说明

|\@Prop|说明|
|:---|:---|
|非属性宏|无。|
|同步类型|单向同步：对父组件状态变量值的修改，将同步给子组件\@Prop装饰的变量，子组件\@Prop变量的修改不会同步到父组件的状态变量上。嵌套类型的场景请参见[观察变化](#观察变化)。|
|允许装饰的变量类型|支持基础数据类型，对于String，Int64，Float64和Bool类型的变量，可以缺省类型。其他类型的变量不可缺省类型，必须被指定。<br/>支持enum、struct和Option类型，struct类型内部无法修改。<br/>支持class类型，如果要感知内部的变化，在定义的时候需要被[\@Observed](./cj-macro-observed-and-publish.md)修饰，对类内属性和嵌套属性使用[\@Publish](./cj-macro-observed-and-publish.md)装饰后，才能观察到其变化。嵌套类的情况同理。由于class是引用类型，使用\@Observed修饰时在子组件中对class内部变量的修改会影响父组件。<br/>支持数组类型，如果要感知内部的变化，需要使用[ObservedArrayList\<T>](../../reference/arkui-cj/cj-state-rendering-componentstatemanagement.md#class-observedarraylistt)。数组项为自定义类型时，使用[\@Observed](./cj-macro-observed-and-publish.md)和[\@Publish](./cj-macro-observed-and-publish.md)装饰时能观察到数组项中属性赋值。其他数组类型和Collection类型，如Array、Varray、ArrayList、HashMap和HashSet，支持赋值新的数组，但是无法监听内部元素的变化。<br/>支持[Color](../../reference/arkui-cj/cj-common-types.md#class-color)类型。<br/>\@Prop和[数据源](./cj-state-management-overview.md#基本概念)类型需要相同，有以下三种情况：<br/>-&nbsp;\@Prop装饰的变量和\@State以及其他宏同步时双方的类型必须相同，示例请参见[父组件@State到子组件@Prop简单数据类型同步](#父组件state到子组件prop简单数据类型同步)。<br/>-&nbsp;\@Prop装饰的变量和\@State以及其他宏装饰的数组的项同步时 ，\@Prop的类型需要和\@State装饰的数组的数组项相同，比如\@Prop&nbsp;:&nbsp;T和\@State&nbsp;:&nbsp;Array&lt;T&gt;，示例请参见[父组件@State数组中的项到子组件@Prop简单数据类型同步](#父组件state数组项到子组件prop简单数据类型同步)。<br/>-&nbsp;当父组件状态变量为struct或者class时，\@Prop装饰的变量和父组件状态变量的属性类型相同，示例请参见[从父组件中的@State类对象属性到@Prop简单类型的同步](#从父组件中的state类对象属性到prop简单类型的同步)。<br/>支持类型的场景请参见[观察变化](#观察变化)。|
|嵌套传递层数|在组件复用场景，建议\@Prop深度嵌套数据不要超过5层，嵌套太多会导致深拷贝占用的空间过大以及GarbageCollection(垃圾回收)，引起性能问题。|
|被装饰变量的初始值|\@Prop装饰的变量必须使用其父组件提供的变量进行初始化，不允许在子组件中初始化。|

## 变量的传递/访问规则说明

|传递/访问|说明|
|:---|:---|
|从父组件初始化|在创建组件的新实例时，必须初始化所有\@Prop变量，不支持在组件内部进行初始化。支持父组件中的常规变量（常规变量对\@Prop赋值，只是数值的初始化，常规变量的变化不会触发UI刷新。只有状态变量才能触发UI刷新）、[\@State](./cj-macro-state.md)、[\@Link](./cj-macro-link.md)、\@Prop、[\@Provide](./cj-macro-provide-and-consume.md)、[\@Consume](./cj-macro-provide-and-consume.md)、[Publish](./cj-macro-observed-and-publish.md)、[\@StorageLink](./cj-appstorage.md#storagelink)、[\@StorageProp](./cj-appstorage.md#storageprop)、[\@LocalStorageLink](./cj-localstorage.md#localstoragelink)和[\@LocalStorageProp](./cj-localstorage.md#localstorageprop)去初始化子组件中的\@Prop变量。|
|用于初始化子组件|\@Prop支持去初始化子组件中的常规变量、\@State、\@Link、\@Prop、\@Provide。|
|是否支持组件外访问|\@Prop装饰的变量是私有的，只能在组件内访问。不可被访问修饰符修饰。|

## 观察变化和行为表现

### 观察变化

\@Prop装饰的数据可以观察到以下变化。

- 当装饰的数据类型为基础数据类型时，可以观察到数值的变化。

    ```cangjie
    // 简单类型
    @Prop var count: Int
    // 赋值的变化可以被感知
    this.count = 1
    ```

- 当装饰的数据类型为struct时，内部无法修改。

    声明Person。

    ```cangjie
    struct Person {
        var id: Int64
        var name: String
        public init(id: Int64, name: String) {
            this.id = id
            this.name = name
        }
    }
    ```

    \@Prop装饰的是struct Person。

    ```cangjie
    // struct类型
    @Prop var person: Person
    ```

    对\@Prop装饰变量的整体赋值可行。

    ```cangjie
    // struct类型赋值
    this.person = Person(2, "muller")
    ```

    对\@Prop装饰变量的赋值，编译器显示无法修改。

    ```cangjie
    // struct属性的赋值
    this.person.id = 3
    ```

- 当装饰的数据类型为class时，需要被[@Observed](./cj-macro-observed-and-publish.md)修饰，内部需要感知变化的属性用[@Publish](./cj-macro-observed-and-publish.md)修饰，如果不使用[@Observed](./cj-macro-observed-and-publish.md)则无法感知成员变量等内部变化。详情请参见[@Prop嵌套场景](#prop嵌套场景)。

    声明Person和Model类。

    ```cangjie
    @Observed
    class Person {
        @Publish var value: String
    }

    @Observed
    class Model {
        @Publish var value: String = ""
        @Publish var name: Person = Person(value: " ")
    }
    ```

    \@Prop装饰的类型是Model。

    ```cangjie
    @Prop var title: Model
    ```

    对\@Prop装饰变量的赋值。

    ```cangjie
    // class属性的赋值
    this.title = Model(value: 'Hi', name: Person(value: 'ArkUI'))
    ```

    对\@Prop装饰变量的属性和嵌套属性的赋值都可以感知。

    ```cangjie
    // class属性的赋值
    this.title.value = 'Hi'
    // 嵌套的属性
    this.title.name.value = 'ArkUI'
    ```

- 当装饰的对象是数组时，无法单独感知某个数组项的变化，但能感知整体的变化。如果要感知内部的变化，需要使用[ObservedArrayList\<T>](../../reference/arkui-cj/cj-state-rendering-componentstatemanagement.md#class-observedarraylistt)。

    \@Prop装饰的对象为ArrayList类型数组时。

    ```cangjie
    @Prop var arrlist: ArrayList<Int16>
    ```

    数组整体的变化可以感知。

    ```cangjie
    this.arrlist = ArrayList<Int16>([10,9,8])
    ```

    数组项的赋值感知不到。

    ```cangjie
    this.arrlist[0] = 10
    ```

    声明Model类。

    ```cangjie
    @Observed
    class Model {
        @Publish public var value: Int
    }
    ```

    \@Prop装饰的对象为ObservedArray\<Model>类型数组时。

    ```cangjie
    // ObservedArray数组类型
    @Prop var title: ObservedArrayList<Model>
    ```

    数组自身的赋值可以感知。

    ```cangjie
    // 数组赋值
    this.title = ObservedArrayList<Model>([Model(value: 2)])
    ```

    数组项的赋值可以感知。

    ```cangjie
    // 数组项赋值
    this.title[0] = Model(value: 2)
    ```

    数组项中属性的赋值可以感知。

    ```cangjie
    // 嵌套的属性赋值可以感知
    this.title[0].value = 6
    ```

    \@Prop装饰的对象为ObservedArrayList\<Model>类型数组时，新增和删除数组项可以感知。

    删除数组项可以感知。

    ```cangjie
    // 数组项更改
    this.title.remove(0)
    ```

    新增数组项可以感知。

    ```cangjie
    // 数组项更改
    this.title.append(Model(value: 12))
    ```

对于\@State和\@Prop的同步场景：

- 使用父组件中\@State变量的值初始化子组件中的\@Prop变量。当\@State变量变化时，该变量值也会同步更新至\@Prop变量。
- \@Prop装饰的变量的修改不会影响其数据源\@State装饰变量的值。
- 除了\@State，数据源也可以用\@Link或\@Prop装饰，对\@Prop的同步机制是相同的。
- 数据源和\@Prop变量的类型需要相同，\@Prop允许简单类型和class类型。

- 当装饰的变量是其他数组类型和Collection类型，如Array、Varray、ArrayList、HashMap和HashSet，支持赋值新的数组，但是无法监听内部元素的变化。
    以HashSet为例。

    ```cangjie
    //@Prop装饰的对象为HashSet时
    @Prop var message: HashSet<Int64>
    ```

    HashSet整体的变化可以感知。

    ```cangjie
    this.message = HashSet<Int64>(1,2,3)
    ```

    HashSet内部的变化不能感知。

    ```cangjie
    this.message.add(5)
    ```

### 框架行为

要理解\@Prop变量值初始化和更新机制，有必要了解父组件和拥有\@Prop变量的子组件初始渲染和更新流程。

1. 初始渲染：
   a. 执行父组件的build()函数将创建子组件的新实例，将数据源传递给子组件；
   b. 初始化子组件\@Prop装饰的变量。

2. 更新：
   a. 子组件\@Prop更新时，更新仅停留在当前子组件，不会同步回父组件；
   b. 当父组件的数据源更新时，子组件的\@Prop装饰的变量将被来自父组件的数据源重置，所有\@Prop装饰的本地的修改将被父组件的更新覆盖。

> **说明：**
>
> \@Prop装饰的数据更新依赖其所属自定义组件的重新渲染，所以在应用进入后台后，\@Prop无法刷新，推荐使用\@Link代替。

## 使用场景

### 父组件\@State到子组件\@Prop简单数据类型同步

以下示例是\@State到子组件\@Prop简单数据同步，父组件EntryView的状态变量countDownStartValue初始化子组件CountDownComponent中\@Prop装饰的count，点击“Try again”，count的修改仅保留在CountDownComponent不会同步给父组件EntryView。

EntryView的状态变量countDownStartValue的变化将重置CountDownComponent的count。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Component
class CountDownComponent {
    @Prop var count: Int64
    var costOfOneAttempt: Int64 = 1
    func build() {
        Column() {
            if (this.count > 0) {
                Text("You have ${this.count} Nuggets left")
            } else {
                Text('Game over!')
            }
            // @Prop装饰的变量不会同步给父组件
            Button("Try again")
                .margin(10)
                .onClick({
                    evt => this.count -= this.costOfOneAttempt
                })
        }
    }
}

@Entry
@Component
class EntryView {
    @State var countDownStartValue: Int64 = 10
    func build() {
        Column {
            Text("Grant ${this.countDownStartValue} nuggets to play.")
            // 父组件的数据源的修改会同步给子组件
            Button("+1 - Nuggets in New Game")
                .margin(10)
                .onClick({
                    evt => this.countDownStartValue += 1
                })
            // 父组件的修改会同步给子组件
            Button("-1  - Nuggets in New Game")
                .margin(10)
                .onClick({
                    evt => this.countDownStartValue -= 1
                })
            CountDownComponent(count: this.countDownStartValue, costOfOneAttempt: 2)
        }
    }
}
```

![Video-Prop-CountDown](figures/Video-Prop-CountDown.gif)

在上面的示例中：

1. CountDownComponent子组件首次创建时其\@Prop装饰的count变量将从父组件\@State装饰的countDownStartValue变量初始化；

2. 按“+1”或“-1”按钮时，父组件的\@State装饰的countDownStartValue值会变化，这将触发父组件重新渲染，在父组件重新渲染过程中会刷新使用countDownStartValue状态变量的UI组件并单向同步更新CountDownComponent子组件中的count值；

3. 更新count状态变量值也会触发CountDownComponent的重新渲染，在重新渲染过程中，评估使用count状态变量的if语句条件（this.count &gt; 0），并执行true分支中的使用count状态变量的UI组件相关描述来更新Text组件的UI显示；

4. 当按下子组件CountDownComponent的“Try again”按钮时，其\@Prop变量count将被更改，但是count值的更改不会影响父组件的countDownStartValue值；

5. 父组件的countDownStartValue值会变化时，父组件的修改将覆盖掉子组件CountDownComponent中count本地的修改。

### 父组件\@State数组项到子组件\@Prop简单数据类型同步

父组件中\@State如果装饰的数组，其数组项也可以初始化\@Prop。以下示例中父组件Index中\@State装饰的数组arr，将其数组项初始化子组件Child中\@Prop装饰的value。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Component
class Child {
    @Prop var value: Int64
    func build() {
        Text("${this.value}")
            .fontSize(50.vp)
            .onClick({
                evt => this.value++
            })
    }
}

@Entry
@Component
class EntryView {
    @State var arr: Array<Int64> = [1, 2, 3]
    func build() {
        Row {
            Column {
                Child(value: this.arr[0])
                Child(value: this.arr[1])
                Child(value: this.arr[2])
                Divider().height(5)
                ForEach(
                    this.arr,
                    itemGeneratorFunc: {
                        item: Int64, _: Int64 => Child(value: item)
                    },
                    keyGeneratorFunc: {
                        item: Int64, _: Int64 => item.toString()
                    }
                )
                Text('replace entire arr')
                    .fontSize(50)
                    .onClick({
                        evt => if (this.arr[0] == 1) {
                            this.arr = [3, 4, 5]
                        } else {
                            this.arr = [1, 2, 3]
                        }
                    })
            }
        }
    }
}
```

初始渲染创建6个子组件实例，每个\@Prop装饰的变量初始化都在本地拷贝了一份数组项。子组件onclick事件处理程序会更改局部变量值。

如果连续单击界面上的“1”按钮六次、“2”按钮五次、“3”按钮四次，所有变量的本地取值将自动更新为“7”。

```text
7
7
7
----
7
7
7
```

单击replace entire arr后，屏幕将显示以下信息。

```text
7
7
7
----
7
4
5
```

- 在子组件Child中做的所有的修改都不会同步回父组件Index组件，所以即使6个组件显示都为7，但在父组件Index中，this.arr保存的值依旧是[1,2,3]。

- 点击replace entire arr，this.arr[0] == 1成立，将this.arr赋值为[3, 4, 5]；

- 因为this.arr[0]已更改，但此情形下修改\@State数组无法触发子组件UI更新，即修改无法同步至\@Prop变量，所以Child({value: this.arr[0]})组件的值仍然是7。

- this.arr的更改触发ForEach更新，this.arr更新的前后都有数值为3的数组项：[3, 4, 5] 和[1, 2, 3]。根据diff算法，数组项“3”将被保留，删除“1”和“2”的数组项，添加为“4”和“5”的数组项。这就意味着，数组项“3”的组件不会重新生成，而是将其移动到第一位。所以“3”对应的组件不会更新，此时“3”对应的组件数值为“7”，ForEach最终的渲染结果是“7”，“4”，“5”。

### 从父组件中的\@State类对象属性到\@Prop简单类型的同步

在此示例中，图书类使用\@Observed宏，由于class是引用类型，使用\@Observed修饰时在子组件中对class内部变量的修改会影响父组件。因此其中任意一个ReaderComp内属性的变化都会导致book对象的变化。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Observed
class Book {
     public var title: String
     public var pages: Int64
     @Publish public var readIt: Bool = false
}

@Component
class ReaderComp {
    @Prop var book: Book
    func build() {
        Row() {
            Text(this.book.title)
            Text("...has${this.book.pages} pages!")
            Text("${this.book.readIt}")
                .fontSize(50.vp)
                .onClick({
                    evt =>
                        this.book.readIt = true
                })
        }
    }
}

@Entry
@Component
class EntryView {
    @State var book: Book = Book(title:'100 secrets of C++',pages: 765)
    func build() {
        Column {
            ReaderComp(book: this.book)
            ReaderComp(book: this.book)
        }
    }
}
```

![Video-Prop-Book](figures/Video-Prop-Book.gif)

### 从父组件中的\@State数组项到\@Prop class类型的同步

在下面的示例中，更改了\@State装饰的allBooks数组中Book对象上的属性，需要使用\@Observed装饰class Book，Book的属性将被感知，并使用ObservedArrayList来观察Book对象的增删改。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import kit.PerformanceAnalysisKit.*
import ohos.arkui.state_macro_manage.*

@Observed
class Book {
    public var title: String
    public var pages: Int64
    @Publish public var readIt: Bool = false
}

@Component
class ReaderComp {
    @Prop var book: Book
    func build() {
        Row() {
            Text(this.book.title)
            Text("...has${this.book.pages} pages!")
            Text("${this.book.readIt}").onClick({
                evt => this.book.readIt = true
            })
        }
        .backgroundColor(0x00ff00)
        .width(312)
        .height(40)
        .padding(left: 20, top: 10)
        .borderRadius(20)
        .margin(10)
    }
}

@Entry
@Component
class EntryView {
    @State var allBooks: ObservedArrayList<Book> = ObservedArrayList<Book>(
        [Book(title: "JS", pages: 765), Book(title: "Cangjie", pages: 652), Book(title: "ArkUI", pages: 765)])

    func build() {
        Column {
            Text('library`s all time favorite')
                .width(312)
                .height(40)
                .backgroundColor(0x00ff00)
                .borderRadius(20)
                .margin(12)
                .padding(left: 20)
            ReaderComp(book: this.allBooks[2])
            Divider()
            Text('Books on loan to a reader')
                .width(312)
                .height(40)
                .backgroundColor(0x00ff00)
                .borderRadius(20)
                .margin(12)
                .padding(left: 20)
            ForEach(
                this.allBooks,
                itemGeneratorFunc: {
                    item: Book, _: Int64 => ReaderComp(book: item)
                },
                keyGeneratorFunc: {
                    item: Book, _: Int64 => item.title
                }
            )
            Button("Add new")
                .width(312)
                .height(40)
                .margin(12)
                .onClick({
                    evt => this.allBooks.append(Book(title: "JA", pages: 512))
                })
            Button("Remove first book")
                .width(312)
                .height(40)
                .margin(12)
                .onClick({
                    evt => if (this.allBooks.size > 0) {
                        this.allBooks.remove(0)
                    } else {
                        Hilog.info(0, "cangjie", "length <= 0")
                    }
                })
        }
    }
}
```

\@Observed装饰的类的实例会被不透明的代理对象包装，此代理可以检测到包装对象内的所有属性更改。如果发生这种情况，代理通知\@Prop，\@Prop对象值被更新。

![Video-prop-UsageScenario-one](figures/Video-prop-UsageScenario-one.gif)

### \@Prop嵌套场景

在嵌套场景下，每一层都要用\@Observed装饰，且每一层都要被\@Prop接收，这样才能感知到嵌套场景。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

// 以下是嵌套类对象的数据结构。
@Observed
class Son {
    @Publish var title: String
}

@Observed
class Father {
    @Publish var name: String
    @Publish var son: Son
}
// 以下组件层次结构呈现的是@Prop嵌套场景的数据结构。
@Entry
@Component
class EntryView {
    @State var person: Father = Father(name: 'Hello', son: Son(title: 'world'));
    func build() {
        Column {
            Flex(
                direction: FlexDirection.Column, alignItems: ItemAlign.Center,
                    justifyContent: FlexAlign.SpaceBetween) {
                Button('change Father name')
                    .width(312)
                    .height(40)
                    .margin(12)
                    .onClick({
                        evt => this.person.name = 'Hi'
                    })
                Button('change Son title')
                    .width(312)
                    .height(40)
                    .margin(12)
                    .onClick({
                        evt => this.person.son.title = 'ArkUI'
                    })
                Text(this.person.name)
                    .fontSize(16)
                    .margin(12)
                    .width(312)
                    .height(40)
                    .borderRadius(20)
                    .textAlign(TextAlign.Center)
                    .onClick({
                        evt => this.person.name = 'Bye'
                    })
                Text(this.person.son.title)
                    .fontSize(16)
                    .margin(12)
                    .width(312)
                    .height(40)
                    .borderRadius(20)
                    .textAlign(TextAlign.Center)
                    .onClick({
                        evt => this.person.son.title = "JS"
                    })
                Child(child: this.person.son)
            }
        }
    }
}

@Component
class Child {
    @Prop var child: Son
    func build() {
        Column() {
            Text(this.child.title)
                .fontSize(16)
                .margin(12)
                .width(312)
                .height(40)
                .borderRadius(20)
                .textAlign(TextAlign.Center)
                .onClick({
                    evt => this.child.title = "Bye Bye"
                })
        }
    }
}
```

![Video-prop-UsageScenario-three](figures/Video-prop-UsageScenario-three.gif)
