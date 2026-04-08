# @Builder宏：自定义构建函数

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

仓颉UI提供了一种轻量的UI元素复用机制@Builder，其内部UI结构固定，仅与使用方进行数据传递，开发者可以将重复使用的UI元素抽象成一个方法，在build方法里调用。

为了简化语言，将@Builder修饰的函数也称为“自定义构建函数”。

在阅读本文档前，建议提前阅读：[基本语法概述](./cj-basic-syntax-overview.md)，[声明式UI描述](./cj-declarative-ui-description.md)，[自定义组件-创建自定义组件](./cj-create-custom-components.md)。

## 宏使用说明

@Builder宏有两种使用方式，分别是定义在自定义组件内部的[私有自定义构建函数](#私有自定义构建函数)和定义在全局的[全局自定义构建函数](#全局自定义构建函数)。

### 私有自定义构建函数

示例：

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @Builder
    func showTextBuilder() {
        Text("Hello World")
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
    }

    @Builder
    func showTextValueBuilder(param: String) {
        Text(param)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
    }

    func build() {
        Column {
            // 无参数
            this.showTextBuilder()
            // 有参数
            this.showTextValueBuilder("Hello @Builder")
        }
    }
}
```

使用方法：

```cangjie
this.showTextBuilder()
```

- 允许在自定义组件内定义一个或多个@Builder方法，该方法被认为是该组件的私有、特殊类型的成员函数。

- 私有自定义构建函数允许在自定义组件内、build方法和其他自定义构建函数中调用。

- 在自定义函数体中，this指代当前所属组件，组件的状态变量可以在自定义构建函数内访问。建议通过this访问自定义组件的状态变量而不是参数传递。

### 全局自定义构建函数

示例：

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Builder
func showTextBuilder() {
    Text("Hello World")
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
}

@Entry
@Component
class EntryView {

    func build() {
        Column {
            showTextBuilder()
        }
    }
}
```

使用方法：

```cangjie
showTextBuilder()
```

- 如果不涉及组件状态变化，建议使用全局的自定义构建方法。

- 全局自定义构建函数允许在build方法和其他自定义构建函数中调用。

## 参数传递规则

自定义构建函数的参数传递有[按值传递](#按值传递参数)和[按引用传递](#按引用传递参数)两种，均需遵守以下规则：

- 参数的类型必须与参数声明的类型一致。

- 在@Builder修饰的函数内部，不允许改变参数值。

- @Builder内UI语法遵循[UI语法规则](./cj-create-custom-components.md)。

- 只有传入一个参数，且参数需要直接传入对象字面量才会按引用传递该参数，其余传递方式均为按值传递。

### 按值传递参数

调用@Builder修饰的函数默认按值传递。当传递的参数为状态变量时，状态变量的改变不会引起@Builder方法内的UI刷新。所以当使用状态变量的时候，推荐使用[按引用传递](#按引用传递参数)。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Builder
func overBuilder(paramA1: String) {
    Row {
        Text("UseStateVarByValue: ${paramA1}")
    }
}

@Entry
@Component
class EntryView {
    @State var label: String = "Hello"

    func build() {
        Column {
            overBuilder(label)
        }
    }
}
```

### 按引用传递参数

按引用传递参数时，传递的参数可为状态变量，且状态变量的改变会引起@Builder方法内的UI刷新。

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Observed
class Tmp {
    @Publish
    var paramA1: String = ""

}

@Builder
func overBuilder(params: Tmp) {
    Row {
        Text("UseStateVarByReference: ${params.paramA1}")
    }
}

@Entry
@Component
class EntryView {
    @State var tmp: Tmp = Tmp(paramA1: "Hello")

    func build() {
        Column {
            // 在父组件中调用overBuilder组件时，
            // 把参数通过引用传递的方式传给overBuilder组件。
            overBuilder(tmp)
            Button("Click me")
            .onClick({
                _ =>
                // 单击Click me后，UI文本更改为ArkUI。
                this.tmp.paramA1 = "ArkUI"
            })
        }
    }
}
```

## 限制条件

@Builder通过按引用传递的方式传入参数，才会触发动态渲染UI。请参考[按引用传递参数](#按引用传递参数)。

## 使用场景

### 自定义组件内使用自定义构建函数

创建私有的@Builder方法，在Column里面使用this.builder()方式调用，通过aboutToAppear生命周期函数和按钮的点击事件改变builder_value的内容，实现动态渲染UI。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var builder_value: String = "Hello"

    @Builder
    func builder() {
        Column {
            Text(this.builder_value)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
        }
    }

    protected override func aboutToAppear() {
        this.builder_value = "Hello World"
    }

    func build() {
        Row {
            Column {
                Text(this.builder_value)
                .fontSize(30)
                .fontWeight(FontWeight.Bold)

                this.builder()
                Button("点击改变builder_value内容")
                .onClick({
                    e =>
                    this.builder_value = "builder_value被点击了"
                })
            }
        }
    }
}
```

### 使用全局自定义构建函数

创建全局的@Builder方法，在Column里面使用overBuilder()方式调用，通过以对象字面量的形式传递参数，无论是简单类型还是复杂类型，值的改变都会引起UI界面的刷新。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList

@Observed
class ChildTmp {
    @Publish
    var val: Int64 = 1
}

@Observed
class Tmp {
    @Publish
    var tmp_value: ChildTmp = ChildTmp()
    @Publish
    var str_value: String = "Hello"
    @Publish
    var num_value: Int64 = 0
    @Publish
    var arrayTmp_value: ObservedArrayList<ChildTmp> = ObservedArrayList<ChildTmp>()
}

@Builder
func overBuilder(param: Tmp) {
    Column {
        Text("str_value: ${param.str_value}")
        Text("num_value: ${param.num_value}")
        Text("tmp_value: ${param.tmp_value.val}")
        ForEach(
            param.arrayTmp_value,
            itemGeneratorFunc: {
                item: ChildTmp, idx: Int64 => Text("arrayTmp_value: ${item.val}")
            }
        )
    }
}

@Entry
@Component
class EntryView {
    @State
    var objParam: Tmp = Tmp()

    func build() {
        Column {
            Text("通过调用@Builder渲染UI界面").fontSize(20)
            overBuilder(this.objParam)

            Line()
                .width(100.percent)
                .height(10)
                .backgroundColor(0x000000)
                .margin(10)

            Button("点击改变参数值").onClick(
                {
                    _ =>
                    this.objParam.str_value = "Hello World"
                    this.objParam.num_value = 1
                    this.objParam.tmp_value.val = 8
                    let child_value: ChildTmp = ChildTmp(val: 2)
                    this.objParam.arrayTmp_value.append(child_value)
                }
            )
        }
    }
}
```

### 修改宏修饰的变量触发UI刷新

此种场景@Builder只是用来展示Text组件，没有参与动态UI刷新的功能，Text组件中值的变化是使用了宏的特性，监听到值的改变触发的UI刷新，而不是通过@Builder的能力触发的。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Observed
class Tmp {
    @Publish var str_value: String = "Hello"
}

@Entry
@Component
class EntryView {
    @State var objParam: Tmp = Tmp()
    @State var label: String = "World"

    @Builder
    func privateBuilder() {
        Column {
            Text("wrapBuilder str_value: ${this.objParam.str_value}")
            Text("wrapBuilder num: ${this.label}")
        }
    }

    func build() {
        Column {
            Text("通过调用@Builder渲染UI界面")
            .fontSize(20)
            this.privateBuilder()
            Line()
            .width(100.percent)
            .height(10)
            .backgroundColor(0x000000)
            .margin(10)

            Button("点击改变参数值")
            .onClick({
                _ =>
                this.objParam.str_value = "str_value: Hello World"
                this.label = "label Hello World"
            })
        }

    }
}
```

### 使用全局和局部的@Builder传入CustomBuilder类型

当某个参数类型为CustomBuilder的时候，可以把定义的@Builder函数传入，因为CustomBuilder实际是一个Function(() -> Unit)类型，而@Builder实际也是一个Function类型。此场景中通过把@Builder传入已实现特定的效果

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Builder
func myBuilder2() {
    Column {
        Text("全局 Builder")
    }
    .width(100.percent)
    .height(100.percent)
    .align(Alignment.Center)
}

@Entry
@Component
class EntryView {
    @State var isShow: Bool = false
    @State var isShow2: Bool = false

    @Builder
    func myBuilder() {
        Column {
            Text("局部 Builder")
        }
        .width(100.percent)
        .height(100.percent)
        .align(Alignment.Center)
    }

    func build() {
        Column {
            Button("局部 Builder")
            .onClick({
              e => this.isShow = true
            })
            .fontSize(20)
            .margin(10)
            .bindSheet(this.isShow, myBuilder, options: SheetOptions(onDisappear: {=> this.isShow = false}) )

            Button("全局 Builder")
            .onClick({
              e => this.isShow2 = true
            })
            .fontSize(20)
            .margin(10)
            .bindSheet(this.isShow2, myBuilder2, options: SheetOptions(onDisappear: {=> this.isShow2 = false}) )
        }
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .width(100.percent)
        .height(100.percent)
    }
}
```

### 多层@Builder方法嵌套使用

在@Builder方法内调用自定义组件或者其他@Builder方法，以实现多个@Builder嵌套使用的场景，要想实现最里面的@Builder动态UI刷新功能，必须要保证每层调用@Builder的地方使用按引用传递的方式。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Observed
class Tmp {
    @Publish var paramA1: String = ""
}

@Builder
func parentBuilder(params: Tmp) {
    Row {
        Text("parentBuilder: ${params.paramA1}")
    }
    childBuilder(params)
}

@Builder
func childBuilder(params: Tmp) {

    Row {
        Text("childBuilder: ${params.paramA1}")
    }
    grandsonBuilder(params)
}

@Builder
func grandsonBuilder(params: Tmp) {

    Row {
        Text("grandsonBuilder: ${params.paramA1}")
    }
}

@Entry
@Component
class EntryView {
    @State var tmp: Tmp = Tmp(paramA1: "Hello")

    func build() {
        Column {
            parentBuilder(this.tmp)
            Text(this.tmp.paramA1)
            Button("Click me")
            .onClick({
                _ =>
                this.tmp.paramA1 = "ArkUI"
            })
        }
    }
}
```
