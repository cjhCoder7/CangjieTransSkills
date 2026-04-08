# LocalStorage：页面级UI状态存储

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

LocalStorage是页面级的UI状态存储，通过@Entry宏接收的参数可以在页面内共享同一个LocalStorage实例。LocalStorage支持UIAbility实例内多个页面间状态共享。

本文仅介绍LocalStorage使用场景和相关的宏：@LocalStorageProp和@LocalStorageLink。

在阅读本文档前，建议开发者对状态管理框架有基本的了解。建议提前阅读：[状态管理概述](cj-state-management-overview.md)。

LocalStorage还提供了API接口，可以让开发者通过接口在自定义组件外手动触发Storage对应key的增删改查，建议配合[LocalStorage API文档](../../reference/arkui-cj/cj-state-rendering-appstatemanagement.md#class-localstorage)阅读。

## 概述

LocalStorage是Cangjie为构建页面级别状态变量提供存储的内存内的“数据库”。

- 应用程序可以创建多个LocalStorage实例，LocalStorage实例可以在页面内共享，也可以实现跨页面、UIAbility实例内共享。
- 组件树的根节点，即被[@Entry](../paradigm/cj-create-custom-components.md#entry)装饰的[@Component](../paradigm/cj-create-custom-components.md#component)，可以被分配一个LocalStorage实例，此组件的所有子组件实例将自动获得对该LocalStorage实例的访问权限。
- 被@Component装饰的组件最多可以访问一个LocalStorage实例和AppStorage，未被@Entry装饰的组件不可被独立分配LocalStorage实例，只能接受父组件通过@Entry传递来的LocalStorage实例。一个LocalStorage实例在组件树上可以被分配给多个组件。
- LocalStorage中的所有属性都是可变的。

应用程序决定LocalStorage对象的生命周期。当应用释放最后一个指向LocalStorage的引用时，比如销毁最后一个自定义组件，LocalStorage将被垃圾回收。

LocalStorage根据与@Component装饰的组件的同步类型不同，提供了两个宏：

- [@LocalStorageProp](#localstorageprop)：@LocalStorageProp装饰的变量与LocalStorage中给定属性建立单向同步关系。
- [@LocalStorageLink](#localstoragelink)：@LocalStorageLink装饰的变量与LocalStorage中给定属性建立双向同步关系。

## @LocalStorageProp

在上文中已经提到，如果要建立LocalStorage和自定义组件的联系，需要使用@LocalStorageProp和@LocalStorageLink宏。使用@LocalStorageProp(key)/@LocalStorageLink(key)装饰组件内的变量，key标识了LocalStorage的属性。

当自定义组件初始化的时候，@LocalStorageProp(key)/@LocalStorageLink(key)装饰的变量会通过给定的key，绑定LocalStorage对应的属性，完成初始化。本地初始化是必要的，因为无法保证LocalStorage一定存在给定的key（这取决于应用逻辑是否在组件初始化之前在LocalStorage实例中存入对应的属性）。

@LocalStorageProp(key)是和LocalStorage中key对应的属性建立单向数据同步，如果LocalStorage中key对应的属性值发生改变，例如通过set接口对LocalStorage中的值进行修改，改变会同步给@LocalStorageProp(key)，并覆盖掉本地的值。

### 宏使用规则说明

|@LocalStorageProp变量宏|说明|
|:---|:---|
|宏参数|key：常量字符串，必填（字符串需要有引号）。|
|允许装饰的变量类型|class、String、整数、浮点、Bool、enum类型，以及这些类型的数组。<br>支持Datetime，Map，Set类型。嵌套类型的场景请参见[观察变化和行为表现](#观察变化和行为表现)。<br>类型必须被指定，建议和LocalStorage中对应属性类型相同，否则会发生类型隐式转换，从而导致应用行为异常。<br>不支持Any。|
|同步类型|单向同步：从LocalStorage的对应属性到组件的状态变量。LocalStorage中给定的属性一旦发生变化，将覆盖本地的内容。|
|被装饰变量的初始值|必须指定，如果LocalStorage实例中不存在属性，则用该初始值初始化该属性，并存入LocalStorage中。|

### 变量的传递/访问规则说明

|传递/访问|说明|
|:---|:---|
|从父节点初始化和更新|禁止，@LocalStorageProp不支持从父节点初始化，只能从LocalStorage中key对应的属性初始化，如果没有对应key的话，将使用本地默认值初始化。|
|初始化子节点|支持，可用于初始化@State、@Link、@Prop、@Provide。|
|是否支持组件外访问|否。|

**@LocalStorageProp初始化规则图示**

![LocalStorageProp](figures/LocalStorageProp.png)

### 观察变化和行为表现

#### 观察变化

- 当装饰的数据类型为Bool、String、整数、浮点类型时，可以观察到数值的变化。
- 当装饰的数据类型为class时，可以观察到对象整体赋值和对象属性变化（详见[从ui内部使用localstorage](#从ui内部使用localstorage)）。
- 当装饰的对象是Array时，可以观察到数组添加、删除、更新数组单元的变化。
- 当装饰的对象是Datetime时，可以观察到Datetime整体的赋值，同时可通过调用Datetime的接口addYears，addMonths，addWeeks，addMinutes，addSeconds，addNanoseconds更新Datetime的属性。详见[装饰Datetime类型变量](#装饰datetime类型变量)。
- 当装饰的变量是Map时，可以观察到Map整体的赋值，同时可通过调用Map的接口add，clear，remove 更新Map的值。详见[装饰Map类型变量](#装饰map类型变量)。
- 当装饰的变量是Set时，可以观察到Set整体的赋值，同时可通过调用Set的接口add，clear，remove更新Set的值。详见[装饰Set类型变量](#装饰set类型变量)。

#### 框架行为

- 被@LocalStorageProp装饰的变量为不可变类型。
- @LocalStorageProp装饰的变量变化会使当前自定义组件中关联的组件刷新。
- LocalStorage(key)中值的变化会引发所有被@LocalStorageProp对应key装饰的变量的变化，会覆盖@LocalStorageProp本地的改变。

![LocalStorage(key)](figures/local-storage-key.png)

## @LocalStorageLink

如果需要将自定义组件的状态变量的更新同步回LocalStorage，就需要用到@LocalStorageLink。

@LocalStorageLink(key)是和LocalStorage中key对应的属性建立双向数据同步：

1. 本地修改发生，该修改会被写回LocalStorage中。
2. LocalStorage中的修改发生后，该修改会被同步到所有绑定LocalStorage对应key的属性上，包括单向（@LocalStorageProp和通过prop创建的单向绑定变量）、双向（@LocalStorageLink和通过link创建的双向绑定变量）变量。

### 宏使用规则说明

|@LocalStorageLink变量宏|说明|
|:---|:---|
|宏参数|key：常量字符串，必填（字符串需要有引号）。|
|允许装饰的变量类型|class、String、整数、浮点、Bool、enum类型，以及这些类型的数组。<br>支持Datetime，Map，Set类型。嵌套类型的场景请参见[观察变化和行为表现](#观察变化和行为表现)。<br>类型必须被指定，建议和LocalStorage中对应属性类型相同，否则会发生类型隐式转换，从而导致应用行为异常。<br>不支持Any。|
|同步类型|双向同步：从LocalStorage的对应属性到自定义组件，从自定义组件到LocalStorage对应属性。|
|被装饰变量的初始值|必须指定，如果LocalStorage实例中不存在属性，则用该初始值初始化该属性，并存入LocalStorage中。|

### 变量的传递/访问规则说明

|传递/访问|说明|
|:---|:---|
|从父节点初始化和更新|禁止，@LocalStorageLink不支持从父节点初始化，只能从LocalStorage中key对应的属性初始化，如果没有对应key的话，将使用本地默认值初始化。|
|初始化子节点|支持，可用于初始化@State、@Link、@Prop、@Provide。|
|是否支持组件外访问|否。|

**@LocalStorageLink初始化规则图示**

![LocalStorageLink](figures/LocalStorageLink.png)

### 观察变化和行为表现

#### 观察变化

- 当装饰的数据类型为Bool、String、整数、浮点类型时，可以观察到数值的变化。
- 当装饰的数据类型为class时，可以观察到对象整体赋值和对象属性变化（详见[从ui内部使用localstorage](#从ui内部使用localstorage)）。
- 当装饰的对象是Array时，可以观察到数组添加、删除、更新数组单元的变化。
- 当装饰的对象是Datetime时，可以观察到Datetime整体的赋值，同时可通过调用Datetime的接口addYears，addMonths，addWeeks，addMinutes，addSeconds，addNanoseconds更新Datetime的属性。详见[装饰Datetime类型变量](#装饰datetime类型变量)。
- 当装饰的变量是Map时，可以观察到Map整体的赋值，同时可通过调用Map的接口add，clear，remove更新Map的值。详见[装饰Map类型变量](#装饰map类型变量)。
- 当装饰的变量是Set时，可以观察到Set整体的赋值，同时可通过调用Set的接口add，clear，remove更新Set的值。详见[装饰Set类型变量](#装饰set类型变量)。

#### 框架行为

1. 当@LocalStorageLink(key)装饰的数值改变被观察到时，修改将被同步回LocalStorage对应属性键值key的属性中。
2. LocalStorage中属性键值key对应的数据一旦改变，属性键值key绑定的所有的数据（包括双向@LocalStorageLink和单向@LocalStorageProp）都将同步修改。
3. 当@LocalStorageLink(key)装饰的数据本身是状态变量，它的改变不仅仅会同步回LocalStorage中，还会引起所属的自定义组件的重新渲染。

![LocalStorageLink(key)](figures/local-storage-link-key.png)

## 限制条件

1. @LocalStorageProp/@LocalStorageLink的参数必须为string类型，否则编译期会报错。

    ```cangjie
    let storage =  LocalStorage()
    let temp = storage.setOrCreate("PropA", 48)

    //错误写法，编译报错
    @LocalStorageProp[] let localStorageProp: Int64 = 1
    @LocalStorageLink[] var localStorageLink: Int64 = 2

    //正确写法
    @LocalStorageProp["PropA"] let localStorageProp: Int64 = 1
    @LocalStorageLink["PropA"] var localStorageLink: Int64 = 2
    ```

2. @LocalStorageProp与@LocalStorageLink不支持装饰func类型的变量，框架会抛出运行时错误。
3. LocalStorage创建后，命名属性的类型不可更改。后续调用Set时必须使用相同类型的值。
4. LocalStorage是页面级存储。例子可见[将LocalStorage实例从UIAbility共享到一个或多个视图](#将localstorage实例从uiability共享到一个或多个视图)。

## 使用场景

### 应用逻辑使用LocalStorage

```cangjie
let storage =  LocalStorage()
let temp = storage.setOrCreate("PropA", 47)             // 创建新实例并使用给定对象初始化
let propA = storage.get<Int64>("PropA")                 // propA == 47
let link1 = storage.link<Int64>("PropA").getOrThrow()   // link1.get() == 47
let link2 = storage.link<Int64>("PropA").getOrThrow()   // link2.get() == 47

let value1 = link1.set(48) // 双向同步: link1.get() == link2.get() == prop1.get() == 48
let value2 = link1.set(49) // 双向同步: link1.get() == link2.get() == prop.get() == 49
```

### 从UI内部使用LocalStorage

除了应用程序逻辑使用LocalStorage，还可以借助LocalStorage相关的两个宏@LocalStorageProp和@LocalStorageLink，在UI组件内部获取到LocalStorage实例中存储的状态变量。

本示例以@LocalStorageLink为例，展示了：

- 使用构造函数创建LocalStorage实例storage。
- 使用@Entry宏将storage添加到Parent顶层组件中。
- @LocalStorageLink绑定LocalStorage对给定的属性，建立双向数据同步。

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
// 创建新实例并使用给定对象初始化
let storage =  LocalStorage()
let res1 = storage.setOrCreate("PropA", 47)
let res2 = storage.setOrCreate("PropB", Data(50))

@Component
class Child{
    // @LocalStorageLink变量宏与LocalStorage中的"PropA"属性建立双向绑定
    @LocalStorageLink["PropA"] var childLinkNumber: Int64 = 1
    // @LocalStorageLink变量宏与LocalStorage中的"PropB"属性建立双向绑定
    @LocalStorageLink["PropB"] var childLinkObject: Data = Data(0)
    func build() {
        Column(){
            Button("Child from LocalStorage ${this.childLinkNumber}") // 更改将同步至LocalStorage中的"PropA"以及Parent.parentLinkNumber
                .onClick({evt => this.childLinkNumber += 1;})
            Button("Child from LocalStorage ${this.childLinkObject.code}") // 更改将同步至LocalStorage中的"PropB"以及Parent.childLinkObject
                .onClick({evt =>
                    var temp = this.childLinkObject
                    temp.code += 1
                    this.childLinkObject = temp;
                    })
        }
    }
}
// 使LocalStorage可从@Component组件访问
@Entry[storage]
@Component
class EntryView {
    // @LocalStorageLink变量宏与LocalStorage中的"PropA"属性建立双向绑定
    @LocalStorageLink["PropA"] var parentLinkNumber: Int64 = 1
    // @LocalStorageLink变量宏与LocalStorage中的"PropB"属性建立双向绑定
    @LocalStorageLink["PropB"] var parentLinkObject: Data = Data(0)
    func build() {
        Column(){
            Button("Parent from LocalStorage ${this.parentLinkNumber}") // 由于LocalStorage中PropA已经被初始化，因此this.parentLinkNumber的值为47
                .onClick({evt => this.parentLinkNumber += 1;})
            Button("Parent from LocalStorage ${this.parentLinkObject.code}") // 由于LocalStorage中PropB已经被初始化，因此this.parentLinkObject.code的值为50
                .onClick({evt =>
                    var temp = this.parentLinkObject
                    temp.code += 1
                    this.parentLinkObject = temp;
                    })
            // @Component子组件自动获得对Parent LocalStorage实例的访问权限。
            Child()
        }
    }
}
```

### @LocalStorageProp和LocalStorage单向同步的简单场景

下面的示例展示@LocalStorageProp装饰的数据和LocalStorage单向同步的场景：

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

// 创建新实例并使用给定对象初始化
let storage =  LocalStorage()
let temp = storage.setOrCreate("PropA", 47)
// 使LocalStorage可从@Component组件访问
@Entry[storage]
@Component
class EntryView {
    // @LocalStorageProp变量宏与LocalStorage中的"PropA"属性建立单向绑定
    @LocalStorageProp["PropA"] let storageProp1: Int64 = 1
    func build() {
        Column(){
            Button("Parent from LocalStorage ${this.storageProp1}")
                .onClick({evt => storage.set<Int64>("PropA", storageProp1+1)
                    ;})
        }
    }
}
```

### @LocalStorageLink和LocalStorage双向同步的简单场景

下面的示例展示了@LocalStorageLink装饰的数据和LocalStorage双向同步的场景：

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

// 构造LocalStorage实例
let storage =  LocalStorage()
let temp = storage.setOrCreate("PropA", 47)
// 调用link接口构造"PropA"的双向同步数据，linkToPropA 是全局变量
let linkToPropA = storage.link<Int64>("PropA").getOrThrow()

// 使LocalStorage可从@Component组件访问
@Entry[storage]
@Component
class EntryView {
    // @LocalStorageLink("PropA")在Parent自定义组件中创建"PropA"的双向同步数据，初始值为47，因为在构造LocalStorage已经给“PropA”设置47
    @LocalStorageLink["PropA"] var storageLink: Int64 = 1
    func build() {
        Column(){
            Text("incr @LocalStorageLink variable")
            // 单击“incr @LocalStorageLink variable”，this.storageLink加1，改变同步回storage，全局变量linkToPropA也会同步改变
                .onClick({evt => this.storageLink += 1;})
            // 并不建议在组件内使用全局变量linkToPropA.get()，因为可能会有生命周期不同引起的错误。
            Text("@LocalStorageLink: ${this.storageLink} - linkToPropA: ${linkToPropA.get()}")
        }
    }
}
```

### 兄弟组件之间同步状态变量

下面的示例展示了通过@LocalStorageLink双向同步兄弟组件之间的状态。

先看Parent自定义组件中发生的变化：

1. 单击“playCount ${this.playCount} dec by 1”，this.playCount减1，修改同步回LocalStorage中，Child组件中的playCountLink绑定的组件会同步刷新。
2. 单击“countStorage ${this.playCount} incr by 1”，调用LocalStorage的set接口，更新LocalStorage中“countStorage”对应的属性，Child组件中的playCountLink绑定的组件会同步刷新。

Child自定义组件中的变化：

playCountLink的刷新会同步回LocalStorage，并且引起兄弟组件和父组件相应的刷新。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

let storage =  LocalStorage()
let temp = storage.setOrCreate("countStorage", 1)

@Component
class Child {
    let label: String
    @LocalStorageLink["countStorage"] var playCountLink: Int64 = 0
    func build() {
        Row(){
            Text(this.label)
                .width(50)
                .height(60)
                .fontSize(12)
            Text("playCountLink ${this.playCountLink}: inc by 1")
                .onClick({evt => this.playCountLink += 1;})
                .width(200)
                .height(60)
                .fontSize(12)
        }
        .width(300)
        .height(60)
    }
}
@Entry[storage]
@Component
class EntryView {
    @LocalStorageLink["countStorage"] var playCount: Int64 = 0
    func build() {
        Column(){
            Row(){
                Text("Parent")
                    .width(50)
                    .height(60)
                    .fontSize(12)
                Text("countStorage ${this.playCount} dec by 1")
                    .onClick({evt => this.playCount -= 1;})
                    .width(250)
                    .height(60)
                    .fontSize(12)
            }
            .width(300)
            .height(60)
            Child(label:"ChildA")
            Child(label:"ChildB")
        }
    }
}
```

### 将LocalStorage实例从UIAbility共享到一个或多个视图

上面的实例中，LocalStorage的实例仅仅在一个@Entry装饰的组件和其所属的子组件（一个页面）中共享，如果希望其在多个视图中共享，可以在所属UIAbility中创建LocalStorage实例。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import ohos.hilog.*
import ohos.app.ability.ability_stage.AbilityStage
import ohos.app.ability.ability_constant.LaunchReason
import ohos.app.ability.ui_ability.UIAbility
import ohos.app.ability.want.Want
import ohos.app.ability.ability_constant.LaunchParam
import kit.ArkUI.*

let storage =  LocalStorage()
let temp = storage.setOrCreate("PropA", 47)

class MainAbility <: UIAbility {
    public init() {
        super()
        registerSelf()
    }

    public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
        Hilog.info(0, "cangjie", "MainAbility OnCreated.${want.abilityName}")
        match (launchParam.launchReason) {
            case LaunchReason.StartAbility => Hilog.info(0, "cangjie", "START_ABILITY")
            case _ => ()
        }
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        Hilog.info(0, "cangjie", "MainAbility onWindowStageCreate.")
        windowStage.loadContent("EntryView")
    }
}
```

> **说明：**
>
> 在UI页面通过storage接口获取共享的LocalStorage实例。

在下面的用例中，EntryView页面中的propA通过storage获取到共享的LocalStorage实例。单击Button跳转到Page页面，单击Change propA改变propA的值，back回EntryView页面后，页面中propA的值也同步修改。

 <!-- run -->

```cangjie
// index.cj

package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.ui_context.*

//通过storage获取共享的LocalStorage实例
@Entry[storage]
@Component
class EntryView {
    @LocalStorageLink["PropA"] var propA: Int64 = 1
    func build() {
        Row(){
            Column(){
                Text("${this.propA}")
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
                Button("To page")
                    .onClick({evt => getUIContext().getRouter().pushUrl(url: "Page");})
            }
            .width(100.percent)
        }
        .height(100.percent)
    }
}
```

 <!-- run -->

```cangjie
//page.cj

package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.ui_context.*

//通过storage获取共享的LocalStorage实例
@Entry[storage]
@Component
class Page {
    @LocalStorageLink["PropA"] var propA: Int64 = 2
    func build() {
        Row(){
            Column(){
                Text("${this.propA}")
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
                Button("Change propA")
                    .onClick({evt => this.propA = 100;})
                Button("Back EntryView")
                    .onClick({evt => getUIContext().getRouter().pushUrl(url: "EntryView");})
            }
        }
    }
}
```

> **说明：**
>
> 对于开发者更建议使用这个方式来构建LocalStorage的实例，并且在创建LocalStorage实例的时候就写入默认值，因为默认值可以作为运行异常的备份，也可以用作页面的单元测试。

### 装饰DateTime类型变量

在下面的示例中，@LocalStorageLink装饰的selectedDate类型为DateTime，单击Button改变selectedDate的值，视图会随之刷新。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.time.*

let Storage =  LocalStorage()

@Entry[Storage]
@Component
class EntryView {
    @LocalStorageLink["date"] var selectedDate: DateTime = DateTime.of(year: 2003, month: Month.of(6), dayOfMonth: 24)
    @State var count : Int64 = 0
    func build() {
        Column(){
            Button("set selectedDate to 2025-04-21")
                .margin(10)
                .onClick({evt => this.selectedDate = DateTime.of(year: 2025, month: Month.of(4), dayOfMonth: 21);})
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

在下面的示例中，@LocalStorageLink装饰的message类型为Map\<Int64, string>，单击Button改变message的值，视图会随之刷新。

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
    @LocalStorageLink["map"] var message: Map<Int64, String> = HashMap<Int64, String>([(0, "a"), (1, "b"), (3, "c")])
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

在下面的示例中，@LocalStorageLink装饰的memberSet类型为Set\<Int64>，单击Button改变memberSet的值，视图会随之刷新。

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
    @LocalStorageLink["set"] var message: Set<Int64> = HashSet<Int64>([0, 1, 2, 3, 4])
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

### 自定义组件外改变状态变量

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

let storage =  LocalStorage()
let temp = storage.setOrCreate("count", 47)

public class Model {
  let storage: LocalStorage = storage

  public func change(propName: String, value: Int64) {
    this.storage.setOrCreate<Int64>(propName, value)
  }
}

let model: Model = Model()

@Entry[storage]
@Component
class EntryView {
    @LocalStorageLink["count"] var count: Int64 = 0
    func build() {
        Column(){
            Text("count值: ${this.count}")
            Button("change")
                .onClick({evt => model.change("count",this.count+1);})
            }
    }
}
```
