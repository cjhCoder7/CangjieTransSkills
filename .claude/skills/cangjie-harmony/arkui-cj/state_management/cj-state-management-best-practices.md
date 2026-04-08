# 状态管理优秀实践

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

为了帮助应用程序开发人员提高其应用程序质量，特别是在高效的状态管理方面。本章节面向开发者提供了多个在开发ArkUI应用中常见的低效开发的场景，并给出了对应的解决方案。此外，还提供了同一场景下，推荐用法和不推荐用法的对比和解释说明，更直观地展示两者区别，从而帮助开发者学习如何正确地在应用开发中使用状态变量，进行高性能开发。

## 不使用状态变量强行更新非状态变量关联组件

【反例】

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.LocalizationKit.*
import std.collection.*
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class EntryView{
    @State var needsUpdate: Bool = true
    var realStateArr: ArrayList<Int64> = ArrayList<Int64>([4, 1, 3, 2])
    var realState: Color = Color(0xFFFF00)

    func updateUIArr(param: ArrayList<Int64>): ArrayList<Int64>{
        let triggerAGet: Bool = this.needsUpdate
        return param
    }

    func updateUI(param: Color): Color{
        let triggerAGet: Bool = this.needsUpdate
        return param
    }

    func build(){
        Column(space: 20){
            ForEach(this.updateUIArr(this.realStateArr), itemGeneratorFunc: {item: Int64, _: Int64 => Text("${item}")})
            Text("add item")
            .onClick({ event =>
                // 改变realStateArr不会触发UI视图更新
                this.realStateArr.add(this.realStateArr[this.realStateArr.size - 1] + 1)

                // 触发UI视图更新
                this.needsUpdate = !this.needsUpdate
            })

            Text("chg color")
            .onClick({event =>
                // 改变realState不会触发UI视图更新
                match {
                    case this.realState.toUInt32() == Color(0xFFFF00).toUInt32() => this.realState = Color.Red
                    case this.realState.toUInt32() == Color.Red.toUInt32() => this.realState = Color(0xFFFF00)
                    case _ => Hilog.error(0, "test", "realState invalid")
                }

                // 触发UI视图更新
                this.needsUpdate = !this.needsUpdate
            })
        }
        .backgroundColor(this.updateUI(this.realState))
        .width(200).height(500)
    }
}
```

上述示例存在以下问题：

- 应用程序希望控制UI更新逻辑，但在ArkUI中，UI更新的逻辑应该是由框架来检测应用程序状态变量的更改去实现。
- this.needsUpdate是一个自定义的UI状态变量，应该仅应用于其绑定的UI组件。变量this.realStateArr、this.realState没有被装饰，其变化将不会触发UI刷新。
- 但是在该应用中，用户试图通过this.needsUpdate的更新来带动常规变量this.realStateArr、this.realState的更新，此方法不合理且更新性能较差。

【正例】

要解决此问题，应将realStateArr和realState成员变量用@State装饰。一旦完成此操作，就不再需要变量needsUpdate。

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry
import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class EntryView{
    @State var realStateArr: ObservedArrayList<Int64> = ObservedArrayList<Int64>([4, 1, 3, 2])
    @State var realState: Color = Color(0xFFFF00)

    func build(){
        Column(space: 20){
            ForEach(this.realStateArr, itemGeneratorFunc: {item: Int64, _: Int64 => Text("${item}")})

            Text("add item")
            .onClick({event =>
                // 改变realStateArr触发UI视图更新
                this.realStateArr.append((this.realStateArr[this.realStateArr.size - 1] + 1))
            })

            Text("chg color")
            .onClick({event =>
                // 改变realState触发UI视图更新
                match {
                    case this.realState.toUInt32() == Color(0xFFFF00).toUInt32() => this.realState = Color.Red
                    case this.realState.toUInt32() == Color.Red.toUInt32() => this.realState = Color(0xFFFF00)
                    case _ => Hilog.error(0, "test", "realState invalid")
                }
            })
            .backgroundColor(this.realState)
            .width(200).height(500)
        }
    }
}
```

## 合理控制对象类型状态变量关联的组件数量

如果将一个复杂对象定义为状态变量，需要合理控制其关联的组件数。当对象中某一个成员属性发生变化时，会导致该对象关联的所有组件刷新，尽管这些组件可能并没有直接使用到该改变的属性。为了避免这种“冗余刷新”对性能产生影响，建议合理拆分该复杂对象，控制对象关联的组件数量。具体请参见[状态管理合理使用开发指导](cj-properly-use-state-management-to-develope.md)。

## 避免在for、while等循环逻辑中频繁读取状态变量

在应用开发中，应避免在循环逻辑中频繁读取状态变量，而是应该放在循环外面读取。

【反例】

<!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class EntryView{
    @State var message: String = "message"

    func build(){
        Column(){
            Button("点击打印日志")
            .onClick({event=>
                for(i in 0..10 : 1){
                    Hilog.info(0, "AppLogCj", this.message)
                }
            })
            .width(90.percent)
            .backgroundColor(Color.Blue)
            .fontColor(Color.White)
            .margin(top: 10)
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
        .margin(top: 15)
    }
}
```

【正例】

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class EntryView{
    @State var message: String = "message"

    func build(){
        Column(){
            Button("点击打印日志")
            .onClick({event=>
                let logMessage: String = this.message
                for(i in 0..10 : 1){
                    Hilog.info(0, "AppLogCj", logMessage)
                }
            })
            .width(90.percent)
            .backgroundColor(Color.Blue)
            .fontColor(Color.White)
            .margin(top: 10)
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
        .margin(top: 15)
    }
}
```

## 建议使用临时变量替换状态变量

在应用开发中，应尽量减少对状态变量的直接赋值，通过临时变量完成数据计算操作。

状态变量发生变化时，ArkUI会查询依赖该状态变量的组件并执行依赖该状态变量的组件的更新方法，完成组件渲染的行为。通过使用临时变量的计算代替直接操作状态变量，可以使ArkUI仅在最后一次状态变量变更时查询并渲染组件，减少不必要的行为，从而提高应用性能。状态变量行为请参见[@State宏：组件内状态](cj-macro-state.md)。

【反例】

<!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.hi_trace_meter.HiTraceMeter

@Entry
@Component
class EntryView{
    @State var message: String = ""

    func appendMsg(newMsg: String){
        // 性能打点
        HiTraceMeter.startTrace('StateVariable', 1)
        this.message += newMsg
        this.message += ";"
        this.message += "<br/>"
        HiTraceMeter.finishTrace('StateVariable', 1)
    }

    func build(){
        Column(){
            Button("点击打印日志")
            .onClick({event => this.appendMsg("操作状态变量")})
            .width(90.percent)
            .backgroundColor(Color.Blue)
            .fontColor(Color.White)
            .margin(top: 10)
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
        .margin(top: 15)
    }
}
```

直接操作状态变量，三次触发计算函数，运行耗时结果如下

![trace1](./figures/trace1.png)

【正例】

 <!-- run -->

```cangjie
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.hi_trace_meter.HiTraceMeter

@Entry
@Component
class EntryView{
    @State var message: String = ""

    func appendMsg(newMsg: String){
        // 性能打点
        HiTraceMeter.startTrace('StateVariable', 1)
        var message: String = this.message
        message += newMsg
        message += ";"
        message += "<br/>"
        this.message = message
        HiTraceMeter.finishTrace('StateVariable', 1)
    }

    func build(){
        Column(){
            Button("点击打印日志")
            .onClick({event => this.appendMsg("操作状态变量")})
            .width(90.percent)
            .backgroundColor(Color.Blue)
            .fontColor(Color.White)
            .margin(top: 10)
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
        .margin(top: 15)
    }
}
```

使用临时变量取代状态变量的计算，三次触发计算函数，运行耗时结果如下：

![trace2](./figures/trace2.png)

直接操作状态变量与使用临时变量计算对比如下：

| 计算方式 | 耗时(局限不同设备和场景，数据仅供参考) | 说明 |
| :--- | :--- | :--- |
|直接操作状态变量|1.01ms|增加了ArkUI不必要的查询和渲染行为，导致性能劣化|
|使用临时变量计算|0.63ms|减少了ArkUI不必要的行为，优化性能|
