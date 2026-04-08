# @Provide宏和@Consume宏：与后代组件双向同步

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

`@Provide` 和 `@Consume`，应用于与后代组件的双向数据同步，应用于状态数据在多个层级之间传递的场景。不同于上文提到的父子组件之间通过命名参数机制传递，`@Provide` 和 `@Consume` 摆脱参数传递机制的束缚，实现跨层级传递。

其中`@Provide`装饰的变量是在祖先组件中，可以理解为被“提供”给后代的状态变量。`@Consume`装饰的变量是在后代组件中，去“消费（绑定）”祖先组件提供的变量。

`@Provide` / `@Consume` 是跨组件层级的双向同步。在阅读 `@Provide` 和 `@Consume` 文档前，建议开发者对UI范式基本语法和自定义组件有基本的了解。建议提前阅读：[基本语法概述](../paradigm/cj-basic-syntax-overview.md)，[声明式UI描述](../paradigm/cj-declarative-ui-description.md)，[自定义组件-创建自定义组件](../paradigm/cj-create-custom-components.md)。

## 概述

\@Provide / \@Consume装饰的状态变量有以下特性：

- \@Provide 装饰的状态变量自动对其所有后代组件可用，即该变量被“provide”给他的后代组件。由此可见，\@Provide 的方便之处在于，开发者不需要多次在组件之间传递变量。

- 后代通过使用 \@Consume 去获取 \@Provide 提供的变量，建立在 \@Provide 和 \@Consume 之间的双向数据同步，与 \@State / \@Link 不同的是，前者可以在多层级的父子组件之间传递。

- \@Provide 和 \@Consume 可以通过相同的变量名或者相同的变量别名绑定，需要类型相同，否则会发生类型隐式转换，从而导致应用行为异常。

```cangjie
// 通过相同的变量名绑定
@Provide
var age: Int64 = 0;
@Consume
var age: Int64;

// 通过相同的变量别名绑定
@Provide["a"]
var id: Float64 = 0.0;
@Consume["a"]
var age: Float64;
```

\@Provide 和 \@Consume通过相同的变量名或者相同的变量别名绑定时，\@Provide 装饰的变量和 \@Consume 装饰的变量是一对多的关系。如果在同一个自定义组件内，包括其子组件中声明多个同名或者同别名的 \@Provide 装饰的变量，\@Consume 声明的变量会向上查找匹配最近的 \@Provide 所修饰的变量。

同时，如果 \@Provide 注解中声明了别名，则需要根据对应的别名声明绑定 \@Consume 变量，根据变量名无法找到对应key的 \@Provide 变量。

## 宏说明

`@State` 的规则同样适用于 `@Provide`。不同之处在于 `@Provide` 还作为多层后代的同步源。

|\@Provide|说明|
|:---|:---|
|宏参数|别名：常量字符串，可选。如果指定了别名，则通过别名来绑定变量；如果未指定别名，则通过变量名绑定变量。|
|同步类型|双向同步。从 \@Provide 变量到所有 \@Consume 变量以及相反的方向的数据同步。双向同步的操作与 \@State 和 \@Link 的组合相同。|
|允许装饰的变量类型|仓颉内置类型包括基础数据类型（Nothing除外）和自定义类型，以及这些类型的数组。支持函数类型，支持DateTime类型。\@Provide 变量的 \@Consume 变量的类型必须相同。支持类型的场景请参考观察变化。|
|被装饰变量的初始值|必须指明类型，初始值必须指定。|
|\@Provide支持重名|允许重名，\@Consume 会向上查找匹配最近的 \@Provide。|

|\@Consume|说明|
|:---|:---|
|宏参数|别名：常量字符串，可选。如果提供了别名，则必须有 \@Provide 的变量和其有相同的别名才可以匹配成功；如果不提供别名，则需要变量名与变量类型都相同才能匹配成功。|
|同步类型|双向：从 \@Provide 变量（具体请参见 \@Provide ）到所有 \@Consume 变量，以及相反的方向。双向同步操作与 \@State 和 \@Link 的组合相同。|
|允许装饰的变量类型|仓颉内置类型包括基础数据类型（Nothing除外）和自定义类型，以及这些类型的数组。支持函数类型，支持DateTime类型。\@Provide 变量的 \@Consume 变量的类型必须相同。支持类型的场景请参考观察变化。|
|被装饰变量的初始值|必须指明类型，不能有初始值。|

## 变量的传递/访问规则说明

|\@Provide传递/访问|说明|
|:---|:---|
|从父组件初始化和更新|可选，允许父组件中常规变量（常规变量对 \@Provide 赋值，只是数值的初始化，常规变量的变化不会触发UI刷新，只有状态变量才能触发UI刷新）、[\@State](./cj-macro-state.md)、[\@Link](./cj-macro-link.md)、[\@Prop](./cj-macro-prop.md)、\@Provide、\@Consume、[\@Publish](./cj-macro-observed-and-publish.md)、[\@StorageLink](./cj-appstorage.md#storagelink)、[\@StorageProp](./cj-appstorage.md#storageprop)、[\@LocalStorageLink](./cj-localstorage.md#localstoragelink)和[\@LocalStorageProp](./cj-localstorage.md#localstorageprop)装饰的变量装饰变量初始化子组件 \@Provide。|
|用于初始化子组件|允许，可用于初始化 \@State、\@Link、\@Prop、\@Provide。|
|和父组件同步|否。|
|和后代组件同步|和 \@Consume 双向同步。|
|是否支持组件外访问|私有，仅可以在所属组件内访问。|

|\@Consume传递/访问|说明|
|:---|:---|
|从父组件初始化和更新|禁止。通过相同的变量名和alias（别名）从 \@Provide 初始化。|
|用于初始化子组件|允许，可用于初始化 \@State、\@Link、\@Prop、\@Provide。|
|和祖先组件同步|和 \@Provide 双向同步。|
|是否支持组件外访问|私有，所修饰的变量遵循`private`修饰符修饰变量的可见性。|

## 观察变化和行为表现

### 观察变化

- 当装饰的数据类型为整数类型、浮点类型、布尔类型、字符类型、字符串类型时，可以观察到数值的变化。

- 当装饰的对象是元组类型、数组类型、区间类型的时候，可以观察到数组的元素的更新。

- 当装饰的对象是DateTime时，可以观察到DateTime整体的赋值，同时可通过调用DateTime的函数addDays(Int64), addHours(Int64), addMinutes(Int64), addMonths(Int64), addNanoseconds(Int64), addSeconds(Int64), addWeeks(Int64), addYears(Int64)更新DateTime的属性。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.time.*

// 父组件
@Entry
@Component
class EntryView{

    @Provide
    var selectedDate: DateTime = DateTime.of(year:2021,month:8,dayOfMonth:8)

    public func build(){
        Column(){
            Button("parent increase the day by 1")
                .margin(10)
                .onClick({ event
                    => this.selectedDate = this.selectedDate.addDays(1)
                })
            Button("parent update the new date")
                .margin(10)
                .onClick({ event
                    => this.selectedDate = DateTime.of(year:2023,month:7,dayOfMonth:7)
                })
            DatePicker(
                start: DateTime.of(year:1970,month:1,dayOfMonth:1),
                end: DateTime.of(year:2100,month:1,dayOfMonth:1),
                selected: this.selectedDate
            )
           Child()
        }
    }
}

@Component
class Child{

    @Consume
    var selectedDate: DateTime;

    public func build(){
        Column(){
            Button("child increase the day by 1")
                .onClick({ event
                    => this.selectedDate = this.selectedDate.addDays(1)
                })
            Button("child update the new date")
                .margin(10)
                .onClick({ event
                    => this.selectedDate = DateTime.of(year:2023,month:9,dayOfMonth:9)
                })
            DatePicker(
                start: DateTime.of(year:1970,month:1,dayOfMonth:1),
                end: DateTime.of(year:2100,month:1,dayOfMonth:1),
                selected: this.selectedDate
            )
        }
    }
}
```

![img1](figures/provide_1_datepicker.gif)

- 当装饰的变量是HashMap时，可以观察到HashMap整体的赋值，同时可通过调用HashMap的接口set(), clear(), remove() 更新Map的值。详见[装饰Map类型变量](#装饰map类型变量)。

- 当装饰的变量是HashSet时，可以观察到HashSet整体的赋值，同时可通过调用HashSet的接口add(), clear(), remove() 更新Set的值。详见[装饰Set类型变量](#装饰set类型变量)。

- 可以装饰函数类型变量，并观察到函数输出值的变化。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

public func returnAdd(a: Int64, b:Int64): Int64{
    return a+b
}

public func returnMinus(a: Int64, b:Int64): Int64{
    return a-b
}

@Entry
@Component
class EntryView{

    @Provide["calc"]
    var Func1: (Int64, Int64) -> Int64 = returnAdd

    @Provide
    var isAdd : Bool = true

    func build(){
        Column{
            Text("Parent")
            Text(
                if(isAdd == true){
                    "1+1 = ${Func1(1,1)}"
                }else{
                    "1-1 = ${Func1(1,1)}"}
            )
            Button(
                if(isAdd == true){
                    "Switch to minus"
                }else{
                    "Switch to add"
                }
            ).onClick({ evt =>
                if(isAdd == true){ Func1 = returnMinus }
                else{ Func1 = returnAdd }
                isAdd = !isAdd
            })
            Divider()
            Child()
        }
    }
}

@Component
class Child{
    @Consume["calc"]
    var Func2: (Int64, Int64) -> Int64

    @Consume
    var isAdd: Bool

    func build(){
        Column{
            Text("Child")
            Text(
                if(isAdd == true){
                    "1+1 = ${Func2(1,1)}"
                }else{
                    "1-1 = ${Func2(1,1)}"}
            )
            Button(
                if(isAdd == true){
                    "Switch to minus"
                }else{
                    "Switch to add"
                }
            ).onClick({ evt =>
                if(isAdd == true){ Func2 = returnMinus }
                else{ Func2 = returnAdd }
                isAdd = !isAdd
            })
        }
    }
}
```

![img2](figures/provide_2_decorFunc.gif)

### 框架行为

1. 初始渲染：
   a. \@Provide装饰的变量会以Map的形式，传递给当前\@Provide所属组件的所有子组件。
   b. 子组件中如果使用\@Consume 变量，则会在Map中查找是否有该变量名对应的@Provide的变量。如果无法找到，则会抛出运行时错误。
   c. 在初始化\@Consume变量时，如果在Map中有该变量名/alias（别名）对应的\@Provide的变量，则和\@State/\@Link的流程类似，\@Consume变量会在Map中查找到对应的\@Provide变量进行保存，并把自己注册给\@Provide。

2. 当\@Provide装饰的数据变化时：
   a. 通过初始渲染的步骤可知，子组件\@Consume已把自己注册给父组件。父组件\@Provide变量变更后，会遍历更新所有依赖它的系统组件（elementid）和状态变量（\@Consume）。
   b. 通知\@Consume更新后，子组件所有依赖\@Consume的系统组件（elementId）都会被通知更新。以此实现\@Provide对\@Consume状态数据同步。

3. 当\@Consume装饰的数据变化时：
   通过初始渲染的步骤可知，子组件\@Consume持有\@Provide的实例。在\@Consume更新后调用\@Provide的更新方法，将更新的数值同步回\@Provide，以此实现\@Consume向\@Provide的同步更新。

## 限制条件

1. \@Provide / \@Consume 的参数key必须为String字面量，否则编译期会报错。

    【反例】

    ```cangjie

    let change: Int64 = 10;
    @Provide[change]
    var message: String = "Hello"

    let change: String = "10"
    @Provide[change]
    var message: String = "Hello"

    ```

    【正例】

    ```cangjie

    @Provide["10"]
    var message: String = "Hello"
    ```

2. \@Consume 装饰的变量不能本地初始化，也不能在构造参数中传入初始化，\@Consume 装饰的变量初始化不会起作用。\@Consume 仅能通过key来匹配对应的 \@Provide 变量进行初始化。

    【反例】

    <!-- code_no_check -->

    ```cangjie
    // 父组件
    @Entry
    @Component
    class EntryView {
        @Provide
        var message: String = "Hello";

        func build() {
            Column() {
                Child()
            }
        }
    }

    @Component
    class Child {

    //  错误写法，不能本地初始化
        @Consume
        var msg: String = "Hello";

        func build() {
            Text(this.msg)
        }
    }
    ```

    【正例】

    <!-- code_check_manual -->

    ```cangjie
    @Component
    class Child {

        @Consume
        var num: Int64;

        func build() {
            Column() {
                Text("num的值: ${this.num}")
            }
        }
    }

    // 父组件
    @Entry
    @Component
    class EntryView {

        @Provide
        var num: Int64 = 10;

        func build() {
            Column() {
                Text("num的值: ${this.num}")
                Child()
            }
        }
    }
    ```

3. \@Provide的key（变量名与别名）重复定义时，\@Consume 会根据组件树向上查找并绑定最近的 \@Provide

    ```cangjie
    // 如果变量名重复，\@Consume 会绑定最后一个 \@Provide 修饰的变量。
    // 需类型一致，若类型不一致，框架会弹出运行时错误。
    @Provide
    var count: Int32 = 10
    @Provide
    var count: Int64 = 10

    // 如果别名重复，\@Consume 会绑定最后一个 \@Provide 修饰的变量。
    // 同上，需类型一致。
    @Provide["a"]
    var count: Int32 = 10
    @Provide["a"]
    var num: Int64 = 10
    ```

4. 在初始化 \@Consume 变量时，如果开发者没有定义对应key的 \@Provide 变量，框架会抛出运行时错误，提示开发者初始化 \@Consume 变量失败，原因是无法找到其对应key（变量名或别名）的 \@Provide 变量。

    【反例】

    <!-- code_no_check -->

    ```cangjie
    @Component
    class Child{
        @Consume
        var num: Int64

        func build(){
            Column(){
                Text("num的值：${this.num}")
            }
        }
    }

    // 父组件
    @Entry
    @Component
    class EntryView{
        // 错误写法，缺少@Provide
        var num: Int64 = 10;

        func build(){
            Column(){
                Text("num的值：${this.num}")
                Child()
            }
        }
    }
    ```

    【正例】

    <!-- code_check_manual -->

    ```cangjie
    @Component
    class Child{
        @Consume
        var num: Int64

        func build(){
            Column(){
                Text("num的值：${this.num}")
            }
        }
    }

    // 父组件
    @Entry
    @Component
    class EntryView{
        // 正确写法
        @Provide
        var num: Int64 = 10;

        func build(){
            Column(){
                Text("num的值：${this.num}")
                Child()
            }
        }
    }
    ```

## 使用场景

在下面的示例是与后代组件双向同步状态 \@Provide 和 \@Consume 场景。当分别点击EntryView和ToDoItem组件内Button时，count的更改会双向同步在EntryView和ToDoItem中。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Component
class ToDoItem {

    // @Consume装饰的变量通过相同的属性名绑定其祖先组件EntryView内的@Provide装饰的变量
    @Consume
    var count: Int64;

    func build(){
        Column{
            Text("count(${this.count})")
            Button("count(${this.count}), count + 1")
                .onClick({
                   evt => this.count += 1
            })
        }.width(100.percent)
    }
}

@Component
class ToDoList{
    func build(){
        Row(space: 5){
            ToDoItem()
            ToDoItem()
        }
    }
}

@Component
class ToDoDemo{
    func build(){
        Column{
            ToDoList()
        }
    }
}

@Entry
@Component
class EntryView{
    // @Provide装饰的变量index由入口组件EntryView提供其后代组件
    @Provide
    var count: Int64 = 0;

    func build(){
        Column{
            Button("count(${this.count}), count + 1")
                .onClick({
                   evt => this.count += 1
                })
            ToDoDemo()
        }
    }
}
```

![img3](figures/provide_3_binding.gif)

### 装饰Map类型变量

在下面的示例中，message类型为HashMap\<Int64, String>，点击Button改变message的值，视图会随之刷新。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.HashMap

@Component
class Child {
    @Consume
    var message: HashMap<Int64, String> = HashMap<Int64, String>()

    @Consume
    var arr: Array<(Int64, String)>

    func build(){
        Column(){
            ForEach(arr,
                itemGeneratorFunc: { item: (Int64, String), idx: Int64 =>
                    Text("key: ${item[0]} value: ${item[1]}").fontSize(30)
                    Divider()
                },
                keyGeneratorFunc: {item: (Int64, String), idx: Int64
                    => "${idx}_${item[0]}" + item[1]
                })
            Button("Consume init map").onClick({
                evt =>
                    this.message = HashMap<Int64, String>([(0,"a"),(1,"b"),(3,"c")])
                    arr = message.toArray()
            })
            Button("Consume set new one").onClick({
                evt =>
                    this.message.add(4,"d")
                    arr = message.toArray()
            })
            Button("Consume clear").onClick({
                evt =>
                    this.message.clear()
                    arr = message.toArray()
            })
            Button("Consume replace the first item").onClick({
                evt =>
                    this.message.add(0,"aa")
                    arr = message.toArray()
            })
            Button("Consume delete the first item").onClick({
                evt =>
                    this.message.remove(0)
                    arr = message.toArray()
            })
        }
    }
}

@Entry
@Component
class EntryView {
    @Provide
    var message: HashMap<Int64, String> = HashMap<Int64, String>([(0,"a"),(1,"b"),(3,"c")])

    @Provide
    var arr: Array<(Int64, String)> = []

    public override func onPageShow(){
        arr = message.toArray()
    }

    func build(){
        Row(){
            Column(){
                Button("Provide init map").onClick({
                    evt =>
                        this.message = HashMap<Int64,String>([(0,"a"),(1,"b"),(3,"c"),(4,"d")])
                        arr = message.toArray()
                })
                Child()
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

![img4](figures/provide_4_map.gif)

### 装饰Set类型变量

在下面的示例中，message类型为HashSet\<Int64>，点击Button改变message的值，视图会随之刷新。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*

@Component
class Child{
    @Consume
    var message: HashSet<Int64>

    @Consume
    var arr: Array<Int64>

    func build(){
        Column{
            ForEach(arr,itemGeneratorFunc: {item: Int64, idx: Int64 =>
                Text("${item}").fontSize(30)
                Divider()
            })
            Button("Consume init set").onClick({
                evt =>
                    this.message = HashSet<Int64>([0,1,2,3,4])
                    this.arr = this.message.toArray()
            })
            Button("Consume set new one").onClick({
                evt =>
                    this.message.add(5)
                    this.arr = this.message.toArray()
            })
            Button("Consume clear").onClick({
                evt =>
                    this.message.clear()
                    this.arr = this.message.toArray()
            })
            Button("Consume delete the first one").onClick({
                evt =>
                    this.message.remove(0)
                    this.arr = this.message.toArray()
            })
        }
    }
}

@Entry
@Component
class EntryView{
    public override func onPageShow(){
        arr = message.toArray()
    }

    @Provide
    var message: HashSet<Int64> = HashSet([0,1,2,3,4])

    @Provide
    var arr: Array<Int64> = []

    func build(){
        Row(){
            Column(){
                Button("Provide init Set").onClick({
                    evt =>
                    this.message = HashSet<Int64>([0,1,2,3,4,5])
                    this.arr = this.message.toArray()
                })
                Child()
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

![img5](figures/provide_5_set.gif)
