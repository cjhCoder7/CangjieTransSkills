# 创建自定义组件

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

在ArkUI中，UI显示的内容均为组件，由框架直接提供的称为系统组件，由开发者定义的称为自定义组件。在进行 UI 界面开发时，通常不是简单的将系统组件进行组合使用，而是需要考虑代码可复用性、业务逻辑与UI分离，后续版本演进等因素。因此，将UI和部分业务逻辑封装成自定义组件是不可或缺的能力。

自定义组件具有以下特点：

- 可组合：允许开发者组合使用系统组件、及其属性和方法。

- 可重用：自定义组件可以被其他组件重用，并作为不同的实例在不同的父组件或容器中使用。

- 数据驱动UI更新：通过状态变量的改变，来驱动UI的刷新。

## 自定义组件的基本用法

以下示例展示了自定义组件的基本用法。

<!-- code_check_manual -->

```cangjie
@Component
class HelloComponent {
    @State var message : String = "Hello, World!"
    func build() {
        // HelloComponent自定义组件组合系统组件Row和Text
        Row(){
            Text(this.message)
                // 状态变量message的改变驱动UI刷新，UI从"Hello, World!"刷新为"Hello, Cangjie!"
                .onClick({etv=>this.message="Hello, Cangjie!"})
        }
    }
}
```

HelloComponent可以在其他自定义组件中的build()函数中多次创建，实现自定义组件的重用。

<!-- code_check_manual -->

```cangjie
@Entry
@Component
class EntryView {
    func build() {
        Column(){
            Text("ArkUI message")
            HelloComponent(message: "Hello, World!")
            Divider()
            HelloComponent(message: "你好，世界!")
        }
    }
}
```

要完全理解上面的示例，需要了解自定义组件的以下概念定义，本文将在后面的小节中介绍：

- 自定义组件的基本结构

- 成员函数/变量

- 自定义组件的参数规定

- build()函数

- 自定义组件通用样式

## 自定义组件的基本结构

### class

自定义组件基于class实现，class + 自定义组件名 + {...}的组合构成自定义组件，不能有继承关系。

> **说明：**
>
> 自定义组件名、类名、函数名不能和系统组件名相同。

### @Component

@Component宏仅能装饰class关键字声明的数据结构。class被@Component装饰后具备组件化的能力，需要实现build方法描述UI，一个class只能被一个@Component装饰。

```cangjie
@Component
class MyComponent {
}
```

使用限制：

一个被@Component修饰的class类型(自定义组件)的成员变量（包括普通成员变量、状态变量）总数不能超过128个。

### build()函数

build()函数用于定义自定义组件的声明式UI描述，自定义组件必须定义build()函数。

```cangjie
@Component
class MyComponent {
    func build() {
    }
}
```

### @Entry

@Entry装饰的自定义组件将作为UI页面的入口。在单个UI页面中，最多可以使用@Entry装饰一个自定义组件。@Entry可以接受一个可选的[LocalStorage](../state_management/cj-localstorage.md)的参数。

```cangjie
@Entry
@Component
class MyComponent {
}
```

#### EntryOptions

|名称|类型|必填|说明|
|:---|:---|:---|:---|
|storage|[LocalStorage](../state_management/cj-localstorage.md)|否|页面级的UI状态存储。|

### @Reusable

@Reusable装饰的自定义组件具备可复用能力。详细请参见：[@Reusable宏：组件复用](./cj-macro-reusable.md#使用场景)。

```cangjie
@Reusable
@Component
class MyComponent {
}
```

## 成员函数/变量

自定义组件除了必须要实现build()函数外，还可以实现其他成员函数，成员函数具有以下约束：

- 自定义组件的成员函数为私有的，且不建议声明成静态函数。

自定义组件可以包含成员变量，成员变量具有以下约束：

- 自定义组件的成员变量为私有的，且不建议声明成静态变量。

- 自定义组件的成员变量本地初始化有些是可选的，有些是必选的。具体是否需要本地初始化，是否需要从父组件通过参数传递初始化子组件的成员变量，请参见[状态管理](../state_management/cj-state-management-overview.md)。

## 自定义组件的参数规定

从上文的示例中了解到，可以在build方法里创建自定义组件，在创建自定义组件的过程中，根据宏的规则来初始化自定义组件的参数。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Component
class MyComponent {
    private var countDownFrom: Int64 = 0
    private var color: Color = Color.Blue
    func build() {
    }
}

@Entry
@Component
class EntryView {
    private var someColor: Color = Color.Red
    func build() {
        Column(){
            // 创建MyComponent实例，并将创建MyComponent成员变量countDownFrom初始化为10，将成员变量color初始化为this.someColor
            MyComponent(countDownFrom: 10 , color: this.someColor)
        }
    }
}
```

下面的示例代码将父组件中的函数传递给子组件，并在子组件中调用。

<!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State var cnt : Int64 = 0
    func submit():UInt{
        this.cnt++
        return 0
    }
    func build() {
        Column(){
            Text("${this.cnt}")
            Child(Childsubmit: this.submit)
        }
    }
}

@Component
class Child {
    let Childsubmit : () -> UInt
    func build() {
        Row(){
            Button("add")
                .width(80)
                .onClick({etv=> this.Childsubmit()})
        }
    }
}
```

## build()函数

所有声明在build()函数的语句统称为UI描述，需要遵循以下规则：

- @Entry装饰的自定义组件，其build()函数下的根节点唯一且必要，且必须为容器组件，其中ForEach禁止作为根节点。
- @Component装饰的自定义组件，其build()函数下的根节点唯一且必要，可以为非容器组件，其中ForEach禁止作为根节点。

  <!-- run -->

  ```cangjie
  package ohos_app_cangjie_entry
  import kit.ArkUI.*
  import ohos.arkui.state_macro_manage.*
  import kit.LocalizationKit.*
  import ohos.resource.__GenerateResource__

  @Entry
  @Component
  class EntryView{
      func build() {
          // 根节点唯一且必要，必须为容器组件
          Row(){
              ChildComponent()
          }
      }
  }

  @Component
  class ChildComponent {
      func build() {
          // 根节点唯一且必要，可为非容器组件
          Image(@r(app.media.startIcon))
      }
  }
  ```

- 不允许声明本地变量，反例如下。

  ```cangjie
  func build() {
      let num :Int64 = 0
  }
  ```

- 不允许在UI描述里直接使用Hilog.info，但允许在方法或者函数里使用，反例如下。

  ```cangjie
  func build() {
      //反例：不允许Hilog.info
      Hilog.info(0, "HilogCj","print debug log" )
  }
  ```

- 不允许创建本地的作用域，反例如下。

  ```cangjie
  func build() {
      // 反例：不允许本地作用域
      {
          // ...
      }
  }
  ```

- 不允许调用没有用@Builder装饰的方法，允许系统组件的参数是CJ方法的返回值。

  <!-- code_check_manual -->

  ```cangjie
  @Component
  class EntryView {
      func doSomeCalculations() {

      }
      func calcTextValue():String {
          return "Hello World"
      }
      @Builder func doSomeRender() {
          Text("Hello World")
      }
      func build() {
          Column() {
              // 反例：不能调用没有用@Builder装饰的方法
              this.doSomeCalculations()
              // 正例：可以调用
              this.doSomeRender()
              // 正例：参数可以为调用CJ方法的返回值
              Text(this.calcTextValue())
          }
      }
  }
  ```

- 不允许使用match语法，如果需要使用条件判断，请使用[if](../rendering_control/cj-rendering-control-ifelse.md)。示例如下。

  ```cangjie
  func build() {
      Column() {
          // 反例：不允许使用match语法
          match(expression ) {
              case 0 => Text("...")
              case 1 => Text("...")
              case _ => Text("...")
          }
          // 正例：使用if
          if(expression == 1) {
              Text("...")
          } else if(expression == 2) {
              Button("...")
          } else {
              Text("...")
          }
      }
  }
  ```

- 不允许直接改变状态变量，反例如下。详细分析见[@State常见问题：不允许在build里改状态变量](../state_management/cj-macro-state.md#不允许在build里改状态变量)。

  <!-- code_check_manual -->

  ```cangjie
  @Component
  class EntryView {
      @State var textColor : Color = Color(0xFFFF00)
      @State var columnColor : Color  = Color.Green
      @State var count : Int64 = 1
      func build() {
          Column() {
              // 不允许直接在Text组件内改变count的值
              Text("${this.count++}")
                  .width(50)
                  .height(50)
                  .fontColor(this.textColor)
                  .onClick({etv=> this.columnColor = Color.Red})
              Button("change textColor")
                  .onClick({etv=> this.textColor = Color.Blue})
          }
          .backgroundColor(this.columnColor)
      }
  }
  ```

## 自定义组件通用样式

自定义组件通过“.”链式调用设置通用样式。

<!-- code_check_manual -->

```cangjie
@Component
class ChildComponent {
    func build() {
        Button("Hello World")
    }
}

@Entry
@Component
class MyComponent {
    func build() {
        Row(){
            ChildComponent()
            .width(200)
            .height(300)
            .backgroundColor(Color.Red)
        }
    }
}
```

> **说明：**
>
> ArkUI给自定义组件设置样式时，相当于给ChildComponent套了一个不可见的容器组件，这些样式是设置在容器组件上，而非直接设置给ChildComponent的Button组件。渲染结果显示，背景颜色红色并没有直接设置到Button上，而是设置在Button所在的不可见容器组件上。
