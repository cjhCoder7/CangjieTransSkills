# AppStorage：应用全局的UI状态存储

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

AppStorage是应用全局的UI状态存储，是和应用的进程绑定的，由UI框架在应用程序启动时创建，为应用程序UI状态属性提供中央存储。

和AppStorage不同的是，LocalStorage是页面级的，通常应用于页面内的数据共享。而AppStorage是应用级的全局状态共享，还相当于整个应用的“中枢”，[持久化数据PersistentStorage](./cj-persiststorage.md)和[环境变量Environment](./cj-environment.md)都是通过AppStorage中转，才可以和UI交互。

> **说明：**
>
> AppStorage仅支持纯仓颉场景，不支持用于ArkTS与仓颉混合开发场景。

本文仅介绍AppStorage使用场景和相关的宏：@StorageProp和@StorageLink。

AppStorage是应用全局的UI状态存储，不同于@State等宏仅能在组件树上传递，AppStorage的目的是为了给开发者提供更大范围的跨ability基本的数据共享。在阅读本文档前，建议开发者对状态管理框架中AppStorage的定位有一个宏观了解。建议提前阅读：[状态管理概述](cj-state-management-overview.md)。

AppStorage还提供了API接口，可以让开发者通过接口在自定义组件外手动触发AppStorage对应key的增删改查，建议配合[AppStorage API文档](../../reference/arkui-cj/cj-state-rendering-appstatemanagement.md#class-appstorage)阅读。

## 概述

AppStorage是在应用启动的时候会被创建的单例。它的目的是为了提供应用状态数据的中心存储，这些状态数据在应用级别都是可访问的。AppStorage将在应用运行过程保留其属性。属性通过唯一的键字符串值访问。

AppStorage可以和UI组件同步，且可以在应用业务逻辑中被访问。

AppStorage中的属性可以被双向同步，数据可以是存在于本地或远程设备上，本地和远程设备具有不同的功能，比如数据持久化（详见[PersistentStorage](./cj-persiststorage.md)）。这些数据是通过业务逻辑中实现，与UI解耦，如果希望这些数据在UI中使用，需要用到[@StorageProp](#storageprop)和[@StorageLink](#storagelink)。

## @StorageProp

在上文中已经提到，如果要建立AppStorage和自定义组件的联系，需要使用@StorageProp和@StorageLink宏。使用@StorageProp(key)/@StorageLink(key)装饰组件内的变量，key标识了AppStorage的属性。

当自定义组件初始化的时候，会使用AppStorage中对应key的属性值将@StorageProp(key)/@StorageLink(key)装饰的变量初始化。由于应用逻辑的差异，无法确认是否在组件初始化之前向AppStorage实例中存入了对应的属性，所以AppStorage不一定存在key对应的属性，因此@StorageProp(key)/@StorageLink(key)装饰的变量进行本地初始化是必要的。

@StorageProp(key)是和AppStorage中key对应的属性建立单向数据同步，如果AppStorage给定key的属性发生改变，改变会被同步给@StorageProp，并覆盖掉本地的修改。

### 宏使用规则说明

|@StorageProp变量宏|说明|
|:---|:---|
|宏参数|key：常量字符串，必填（字符串需要有引号）。|
|允许装饰的变量类型|class、String、整数、浮点、Bool、enum类型，以及这些类型的数组。<br>支持Datetime，Map，Set类型。嵌套类型的场景请参见[观察变化和行为表现](#观察变化和行为表现)。<br>类型必须被指定，建议和LocalStorage中对应属性类型相同，否则会发生类型隐式转换，从而导致应用行为异常。<br>不支持Any。|
|同步类型|单向同步：从AppStorage的对应属性到组件的状态变量。AppStorage中给定的属性一旦发生变化，将覆盖本地的修改。|
|被装饰变量的初始值|必须指定，如果AppStorage实例中不存在属性，则用该初始值初始化该属性，并存入AppStorage中。|

### 变量的传递/访问规则说明

|传递/访问|说明|
|:---|:---|
|从父节点初始化和更新|禁止，@StorageProp不支持从父节点初始化，只能AppStorage中key对应的属性初始化，如果没有对应key的话，将使用本地默认值初始化。|
|初始化子节点|支持，可用于初始化[@State](./cj-macro-state.md)、[@Link](./cj-macro-link.md)、[@Prop](./cj-macro-prop.md)、[@Provide](./cj-macro-provide-and-consume.md)。|
|是否支持组件外访问|否。|

**@StorageProp初始化规则图示**

![StorageProp](figures/StorageProp.png)

### 观察变化和行为表现

#### 观察变化

- 当装饰的数据类型为Bool、String、整数、浮点类型时，可以观察到数值的变化。
- 当装饰的数据类型为class时，可以观察到对象整体赋值和对象属性变化（详见[从ui内部使用appstorage和localstorage](#从ui内部使用appstorage和localstorage)）。
- 当装饰的对象是Array时，可以观察到数组添加、删除、更新数组单元的变化。
- 当装饰的对象是Datetime时，可以观察到Datetime整体的赋值，同时可通过调用Datetime的接口addYears，addMonths，addWeeks，addMinutes，addSeconds，addNanoseconds更新Datetime的属性。详见[装饰Datetime类型变量](#装饰datetime类型变量)。
- 当装饰的变量是Map时，可以观察到Map整体的赋值，同时可通过调用Map的接口add，clear，remove 更新Map的值。详见[装饰Map类型变量](#装饰map类型变量)。
- 当装饰的变量是Set时，可以观察到Set整体的赋值，同时可通过调用Set的接口add，clear，remove 更新Set的值。详见[装饰Set类型变量](#装饰set类型变量)。

#### 框架行为

- 被@StorageProp装饰的变量为不可变类型。
- 当@StorageProp(key)装饰的数据本身是状态变量，会引起所属的自定义组件重新渲染。
- 当AppStorage中key对应的属性发生改变时，会同步给所有@StorageProp(key)装饰的数据，@StorageProp(key)本地的修改将被覆盖。

## @StorageLink

@StorageLink(key)是和AppStorage中key对应的属性建立双向数据同步：

1. 本地修改发生，该修改会被写回AppStorage中。
2. AppStorage中的修改发生后，该修改会被同步到所有绑定AppStorage对应key的属性上，包括单向（@StorageProp和通过Prop创建的单向绑定变量）、双向（@StorageLink和通过Link创建的双向绑定变量）变量和其他实例（比如PersistentStorage）。

### 宏使用规则说明

|@StorageLink变量宏|说明|
|:---|:---|
|宏参数|key：常量字符串，必填（字符串需要有引号）。|
|允许装饰的变量类型|class、String、整数、浮点、Bool、enum类型，以及这些类型的数组。<br>支持Datetime，Map，Set类型。嵌套类型的场景请参见[观察变化和行为表现](#观察变化和行为表现)。<br>类型必须被指定，建议和LocalStorage中对应属性类型相同，否则会发生类型隐式转换，从而导致应用行为异常。<br>不支持Any。|
|同步类型|双向同步：从AppStorage的对应属性到自定义组件，从自定义组件到AppStorage对应属性。|
|被装饰变量的初始值|必须指定，如果AppStorage实例中不存在属性，则用该初始值初始化该属性，并存入AppStorage中。|

### 变量的传递/访问规则说明

|传递/访问|说明|
|:---|:---|
|从父节点初始化和更新|禁止。|
|初始化子节点|支持，可用于初始化常规变量、@State、@Link、@Prop、@Provide。|
|是否支持组件外访问|否。|

**@StorageLink初始化规则图示**

![StorageLink](figures/StorageLink.png)

### 观察变化和行为表现

#### 观察变化

- 当装饰的数据类型为Bool、String、整数、浮点类型时，可以观察到数值的变化。
- 当装饰的数据类型为class时，可以观察到对象整体赋值和对象属性变化（详见[从ui内部使用appstorage和localstorage](#从ui内部使用appstorage和localstorage)）。
- 当装饰的对象是Array时，可以观察到数组添加、删除、更新数组单元的变化。
- 当装饰的对象是Datetime时，可以观察到Datetime整体的赋值，同时可通过调用Datetime的接口addYears，addMonths，addWeeks，addMinutes，addSeconds，addNanoseconds更新Datetime的属性。详见[装饰Datetime类型变量](#装饰datetime类型变量)。
- 当装饰的变量是Map时，可以观察到Map整体的赋值，同时可通过调用Map的接口add，clear，remove更新Map的值。详见[装饰Map类型变量](#装饰map类型变量)。
- 当装饰的变量是Set时，可以观察到Set整体的赋值，同时可通过调用Set的接口add，clear，remove更新Set的值。详见[装饰Set类型变量](#装饰set类型变量)。

#### 框架行为

1. 当@StorageLink(key)装饰的数值改变被观察到时，修改将被同步回AppStorage对应属性键值key的属性中。
2. AppStorage中属性键值key对应的数据一旦改变，属性键值key绑定的所有的数据（包括双向@StorageLink和单向@StorageProp）都将同步修改。
3. 当@StorageLink(key)装饰的数据本身是状态变量，它的改变不仅仅会同步回AppStorage中，还会引起所属的自定义组件的重新渲染。

## 限制条件

1. @StorageProp/@StorageLink的参数必须为string类型，否则编译期会报错。

    ```cangjie
    let storage = AppStorage.setOrCreate("PropA", 47)
    let temp = AppStorage.get<Int64>("PropA").getOrThrow() // 47

    // 错误写法，编译报错
    @StorageProp[] let storageProp: Int64 = 1
    @StorageLink[] var storageLink: Int64 = 2

    // 正确写法
    @StorageProp["PropA"] let storageProp: Int64 = 1
    @StorageLink["PropA"] var storageLink: Int64 = 2
    ```

2. @StorageProp与@StorageLink不支持装饰Func类型的变量，框架会抛出运行时错误。

3. AppStorage与[PersistentStorage](./cj-persiststorage.md)以及[Environment](./cj-environment.md)配合使用时，需要注意以下几点：

    a. 在AppStorage中创建属性后，调用PersistentStorage.[persistProp()](../../reference/arkui-cj/cj-state-rendering-appstatemanagement.md#static-func-persistproptstring-t)接口时，会使用在AppStorage中已经存在的值，并覆盖PersistentStorage中的同名属性，所以建议要使用相反的调用顺序，反例可见在[PersistentStorage之前访问AppStorage中的属性](./cj-persiststorage.md#在persistentstorage之后访问appstorage中的属性)。

    b. 如果在AppStorage中已经创建属性后，再调用Environment.[envProp()](../../reference/arkui-cj/cj-state-rendering-appstatemanagement.md#static-func-envproptstring-t)创建同名的属性，会调用失败。因为AppStorage已经有同名属性，Environment环境变量不会再写入AppStorage中，所以建议AppStorage中属性不要使用Environment预置环境变量名。

4. 状态宏装饰的变量，改变会引起UI的渲染更新，如果改变的变量不是用于UI更新，只是用于消息传递，推荐使用emitter方式。例子可见[不建议借助@StorageLink的双向同步机制实现事件通知](#不建议借助storagelink的双向同步机制实现事件通知)。

5. AppStorage同一进程内共享。

## 使用场景

### 从应用逻辑使用AppStorage和LocalStorage

AppStorage是单例，它的所有API都是静态的，使用方法类似于LocalStorage中对应的非静态方法。

```cangjie
let temp1 = AppStorage.setOrCreate<Int64>("PropA", 47)

let storage =  LocalStorage()
let temp2 = storage.setOrCreate("PropA", 17)
let propA = AppStorage.get<Int64>("PropA")                  // propA in AppStorage == 47, propA in LocalStorage == 17
let link1 = AppStorage.link<Int64>("PropA").getOrThrow()    // link1.get() == 47
let link2 = AppStorage.link<Int64>("PropA").getOrThrow()    // link2.get() == 47

let value1 = link1.set(48) // 双向同步: link1.get() == link2.get() == prop.get() == 48
let value2 = link1.set(49) // 双向同步: link1.get() == link2.get() == prop.get() == 49

let value3 = storage.get<Int64>("PropA") // == 17
let value4 = storage.set<Int64>("PropA", 101)
let value5 = storage.get<Int64>("PropA") // == 101

let value6 = AppStorage.get<Int64>("PropA") // == 49
let value7 = link1.get() // == 49
let value8 = link2.get() // == 49
```

### 从UI内部使用AppStorage和LocalStorage

@StorageLink变量宏与AppStorage配合使用，正如@LocalStorageLink与LocalStorage配合使用一样。此宏使用AppStorage中的属性创建双向数据同步。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

class Data{
    var code : Int64
    init(code: Int64){
        this.code = code
    }
}
let temp1 = AppStorage.setOrCreate("PropA", 47)
let temp2 = AppStorage.setOrCreate("PropB", Data(50))

let storage =  LocalStorage()
let res1 = storage.setOrCreate("LinkA", 47)
let res2 = storage.setOrCreate("LinkB", Data(50))

@Entry[storage]
@Component
class EntryView{
    @StorageLink["PropA"] var storageLink : Int64 = 1
    @LocalStorageLink["LinkA"] var localStorageLink : Int64 = 1
    @StorageLink["PropB"] var storageLinkObject : Data = Data(1)
    @LocalStorageLink["LinkB"] var localStorageLinkObject : Data = Data(1)

    func build() {
        Column(){
            Text("From AppStorage ${this.storageLink}")
                .onClick({evt => this.storageLink += 1;})
            Text("From LocalStorage ${this.localStorageLink}")
                .onClick({evt => this.localStorageLink += 1;})
            Text("From AppStorage ${this.storageLinkObject.code}")
                .onClick({evt =>
                    var temp = this.storageLinkObject
                    temp.code += 1
                    this.storageLinkObject = temp;
                    })
            Text("From LocalStorage ${this.localStorageLinkObject.code}")
                .onClick({evt =>
                    var temp = this.localStorageLinkObject
                    temp.code += 1
                    this.localStorageLinkObject = temp;
                    })
        }
    }
}
```

### 不建议借助@StorageLink的双向同步机制实现事件通知

不建议开发者使用@StorageLink和AppStorage的双向同步的机制来实现事件通知，因为AppStorage中的变量可能绑定在多个不同页面的组件中，但事件通知则不一定需要通知到所有的这些组件。并且，当这些@StorageLink装饰的变量在UI中使用时，会触发UI刷新，带来不必要的性能影响。

示例代码中，TapImage中的单击事件，会触发AppStorage中tapIndex对应属性的改变。因为@StorageLink是双向同步，修改会同步回AppStorage中，所以，所有绑定AppStorage的tapIndex自定义组件里都能感知到tapIndex的变化。使用@Watch监听到tapIndex的变化后，修改状态变量tapColor从而触发UI刷新（此处tapIndex并未直接绑定在UI上，因此tapIndex的变化不会直接触发UI刷新）。

使用该机制来实现事件通知需要确保AppStorage中的变量尽量不要直接绑定在UI上，且需要控制[@Watch](./cj-macro-watch.md)函数的复杂度（如果@Watch函数执行时间长，会影响UI刷新效率）。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.resource_manager.AppResource
import kit.PerformanceAnalysisKit.Hilog
import ohos.resource.__GenerateResource__

class ViewData {
    var title: String
    var uri  : AppResource
    var color : Color = Color.Black

    init(title: String,uri  : AppResource){
        this.title = title
        this.uri   = uri
    }
}

@Entry
@Component
class EntryView{
    // 此处"app.media.startIcon"仅作示例，请开发者自行替换，否则imageSource创建失败会导致后续无法正常执行。
    let dataList : Array<ViewData> = [ViewData("flower",@r(app.media.startIcon)),ViewData("OMG",@r(app.media.image))]
    var gridScroller: Scroller = Scroller()

    func build() {
        Column(){
            Grid(scroller: this.gridScroller){
                ForEach(this.dataList, itemGeneratorFunc: {item : ViewData , idx : Int64 =>
                        GridItem(){
                            TapImage(index: idx,uri: item.uri)
                        }
                            .aspectRatio(1.0)
                        })
            }
        }
    }
}

@Component
class TapImage {
    @StorageLink["PropA"] @Watch[onTapIndexChange] var tapIndex : Int64 = -1
    @State var tapColor : Color = Color.Black
    var index: Int64
    var uri: AppResource

    func onTapIndexChange(){
        if(this.tapIndex >= 0 && this.index == this.tapIndex){
            Hilog.info(0, "tapindex", "${this.tapIndex}, index: ${this.index},red")
            this.tapColor = Color.Red
        }else{
            Hilog.info(0, "tapindex", "${this.tapIndex}, index: ${this.index},black")
            this.tapColor = Color.Black
        }
    }
    func build() {
        Column(){
            Image(this.uri)
                .objectFit(ImageFit.Cover)
                .onClick({evt =>this.tapIndex = this.index;})
                .border(width: 5, color: this.tapColor)
        }
    }
}
```

### 装饰DateTime类型变量

在下面的示例中，@StorageLink装饰的selectedDate类型为DateTime，单击Button改变selectedDate的值，视图会随之刷新。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.time.*

@Entry
@Component
class EntryView {
    @StorageLink["date"] var selectedDate: DateTime = DateTime.of(year: 2003, month: Month.of(6), dayOfMonth: 24)
    func build() {
        Column(){
            Button("set selectedDate to 2025-04-21")
                .margin(10)
                .onClick({evt => AppStorage.setOrCreate<DateTime>("date",DateTime.of(year: 2025, month: Month.of(4), dayOfMonth: 21));})
             Button("increase the year by 1")
                .margin(10)
                .onClick({evt => this.selectedDate = this.selectedDate.addYears(1);})
            Button("increase the month by 1")
                .margin(10)
                .onClick({evt => this.selectedDate = this.selectedDate.addMonths(1);})
            Button("increase the day by 1")
                .margin(10)
                .onClick({evt => this.selectedDate = this.selectedDate.addDays(1);})
            DatePicker( start: DateTime.of(year: 1970, month: Month.of(1), dayOfMonth: 1),
                        end: DateTime.of(year: 2100, month: Month.of(1), dayOfMonth: 1),
                        selected: this.selectedDate )
        }
        .width(100.percent)
    }
}
```

### 装饰Map类型变量

在下面的示例中，@StorageLink装饰的message类型为Map\<Int64, String>，单击Button改变message的值，视图会随之刷新。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.Map
import std.collection.HashMap

@Entry
@Component
class EntryView {
    @StorageLink["map"] var message: Map<Int64, String> = HashMap<Int64, String>([(0, "a"), (1, "b"), (3, "c")])
    func build() {
        Row() {
            Column() {
                ForEach(
                    this.message.toArray(),itemGeneratorFunc: {item: (Int64, String), _: Int64 =>
                        Text("${item[0]}").fontSize(30)
                        Text("${item[1]}").fontSize(30)
                        Divider()
                    })
                Button("init map").onClick({evt =>
                    this.message = HashMap<Int64, String>([(0, "a"), (1, "b"), (3, "c")])
                })
                Button("add new one").onClick({evt =>
                        var temp = this.message
                        temp.add(4, "d")
                        this.message = temp
                    })
                Button("clear").onClick({evt =>
                        var temp = this.message
                        temp.clear()
                        this.message = temp
                    })
                Button("replace the first one").onClick({evt =>
                        var temp =this.message
                        temp.replace(0,"aa")
                        this.message=temp
                    })
                Button("remove the first one").onClick({evt =>
                        var temp = this.message
                        temp.remove(0)
                        this.message = temp
                })
            }
                .width(100.percent)
        }
        .height(100.percent)
    }
}
```

### 装饰Set类型变量

在下面的示例中，@StorageLink装饰的memberSet类型为Set\<Int64>，单击Button改变memberSet的值，视图会随之刷新。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.HashSet
import std.collection.Set

@Entry
@Component
class EntryView {
    @StorageLink["set"] var message: Set<Int64> = HashSet<Int64>([0, 1, 2, 3, 4])
    func build() {
        Row() {
            Column() {
                ForEach(
                    this.message.toArray(),
                    itemGeneratorFunc: {
                        item: Int64, _: Int64 => Text("${item}")
                            .fontSize(30)
                    }
                )
                Button("init set").onClick({evt =>
                        var temp = this.message
                        temp = HashSet<Int64>([0, 1, 2, 3, 4])
                        this.message = temp
                    })
                Button("add new one").onClick({evt =>
                        var temp = this.message
                        temp.add(5)
                        this.message = temp
                    })
                Button("clear").onClick({evt =>
                        var temp = this.message
                        temp.clear()
                        this.message = temp
                    })
                Button("remove the first one").onClick({evt =>
                        var temp = this.message
                        temp.remove(0)
                        this.message = temp
                    })
            }
                .width(100.percent)
        }
        .height(100.percent)
    }
}
```
