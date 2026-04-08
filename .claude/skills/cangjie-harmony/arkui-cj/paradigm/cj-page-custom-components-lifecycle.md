# 页面和自定义组件生命周期

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

在开始之前，需要先明确自定义组件和页面的关系：

- 自定义组件：[@Component](./cj-create-custom-components.md#component)修饰的UI单元，可以组合多个系统组件实现UI的复用，可以调用组件的生命周期。

- 页面：即应用的UI页面。可以由一个或者多个自定义组件组成，[@Entry](./cj-create-custom-components.md#entry)修饰的自定义组件为页面的入口组件，即页面的根节点，一个页面有且仅能有一个@Entry。只有被@Entry修饰的组件才可以调用页面的生命周期。

页面生命周期，即被@Entry修饰的组件生命周期，提供以下生命周期接口：

组件生命周期，即一般用@Component修饰的自定义组件的生命周期，提供以下生命周期接口：

生命周期流程如下图所示，下图展示的是被@Entry修饰的组件（页面）生命周期。

![lifecycle](./figures/lifecycle.png)

根据上面的流程图，本文从自定义组件的初始创建、重新渲染和删除来详细解释。

## 自定义组件的创建和渲染流程

1. 自定义组件的创建：自定义组件的实例由ArkUI框架创建。

2. 初始化自定义组件的成员变量：通过本地默认值或者构造方法传递参数来初始化自定义组件的成员变量，初始化顺序为成员变量的定义顺序。

3. 如果开发者定义了[aboutToAppear](../../reference/arkui-cj/cj-custom-component-lifecycle.md#func-abouttoappear)，则执行[aboutToAppear](../../reference/arkui-cj/cj-custom-component-lifecycle.md#func-abouttoappear)方法。

4. 在首次渲染的时候，执行build方法渲染系统组件，如果子组件为自定义组件，则创建自定义组件的实例。在首次渲染的过程中，框架会记录状态变量和组件的映射关系，当状态变量改变时，驱动其相关的组件刷新。

5. 如果开发者定义了onDidBuild，则执行onDidBuild方法。

## 自定义组件重新渲染

当事件句柄被触发（比如设置了点击事件，即触发点击事件）改变了状态变量时，或者LocalStorage / AppStorage中的属性更改，并导致绑定的状态变量更改其值时：

1. 框架观察到了变化，将启动重新渲染。

2. 根据框架持有的两个map（[自定义组件的创建和渲染流程](#自定义组件的创建和渲染流程)中第4步），框架可以知道该状态变量管理了哪些UI组件，以及这些UI组件对应的更新函数。执行这些UI组件的更新函数，实现最小化更新。

## 自定义组件的删除

如果if组件的分支改变，或者ForEach循环渲染中数组的个数改变，组件将被删除：

1. 在删除组件之前，将调用其[aboutToDisappear](../../reference/arkui-cj/cj-custom-component-lifecycle.md#func-abouttodisappear)生命周期函数，标记着该节点将要被销毁。ArkUI的节点删除机制是：后端节点直接从组件树上摘下，后端节点被销毁，对前端节点解引用，前端节点已经没有引用时，将被回收。

2. 自定义组件和它的变量将被删除，如果其有同步的变量，比如[@Link](../state_management/cj-macro-link.md)、[@Prop](../state_management/cj-macro-prop.md)、[@StorageLink](../state_management/cj-appstorage.md#storagelink)，将从[同步源](../state_management/cj-state-management-overview.md)上取消注册。

不建议在生命周期[aboutToDisappear](../../reference/arkui-cj/cj-custom-component-lifecycle.md#func-abouttodisappear)内使用异步操作，如果在生命周期的[aboutToDisappear](../../reference/arkui-cj/cj-custom-component-lifecycle.md#func-abouttodisappear)使用异步操作（spawn或者回调方法），自定义组件将被保留在spawn的闭包中，直到回调方法被执行完，这个行为阻止了自定义组件的垃圾回收。

以下示例展示了生命周期的调用时机：

 <!-- run -->

```cangjie
// Index.cj
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.ui_context.*
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class EntryView {
    @State var showChild: Bool = true
    @State var btnColor: Color = Color(0xFF007DFF)

    // 只有被@Entry修饰的组件才可以调用页面的生命周期
    protected override func onPageShow() {
        Hilog.info(0, "cangjie", "Index onPageShow")
    }

    // 只有被@Entry修饰的组件才可以调用页面的生命周期
    protected override func onPageHide() {
        Hilog.info(0, "cangjie", "Index onPageHide")
    }

    // 只有被@Entry修饰的组件才可以调用页面的生命周期
    protected override func onBackPress() {
        Hilog.info(0, "cangjie", "Index onBackPress")
        this.btnColor = Color(0xFFEE0606)
        // 返回true表示页面自己处理返回逻辑，不进行页面路由；返回false表示使用默认的路由返回逻辑
        return true
    }

    // 组件生命周期
    protected override func aboutToAppear() {
        Hilog.info(0, "cangjie", "EntryView aboutToAppear")
    }

    // 组件生命周期
    protected override func onDidBuild() {
        Hilog.info(0, "cangjie", "EntryView onDidBuild")
    }

    // 组件生命周期
    protected override func aboutToDisappear() {
        Hilog.info(0, "cangjie", "EntryView aboutToDisappear")
    }

    func build() {
        Column {
            // this.showChild为true，创建Child子组件，执行Child aboutToAppear
            if (this.showChild) {
                Child()
            }

            Button("delete Child")
            .margin(20)
            .backgroundColor(this.btnColor)
            .onClick({
                _ =>
                // this.showChild为false，删除Child子组件，执行Child aboutToDisappear
                this.showChild = false
            })

            // Push到Page页面，执行onPageHide
            Button("push to next page")
            .onClick({
                _ =>
                getUIContext().getRouter().pushUrl(url: "Page")
            })
        }
    }
}

@Component
class Child {
    @State var title: String = "Hello World"

    // 组件生命周期
    protected override func aboutToAppear() {
        Hilog.info(0, "cangjie", "Child aboutToAppear")
    }

    // 组件生命周期
    protected override func onDidBuild() {
        Hilog.info(0, "cangjie", "Child onDidBuild")
    }

    // 组件生命周期
    protected override func aboutToDisappear() {
        Hilog.info(0, "cangjie", "Child aboutToDisappear")
    }

    func build() {
        Text(this.title)
        .fontSize(50)
        .margin(20)
        .onClick({
            _ =>
            this.title = "Hello ArkUI"
        })
    }
}
```
 <!-- run -->

```cangjie
// Page.cj
package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class Page {
    @State var textColor: Color = Color.Black
    @State var num: Int64 = 0

    // 只有被@Entry修饰的组件才可以调用页面的生命周期
    protected override func onPageShow() {
        this.num = 5
    }

    // 只有被@Entry修饰的组件才可以调用页面的生命周期
    protected override func onPageHide() {
        Hilog.info(0, "cangjie", "Page onPageHide")
    }

    // 只有被@Entry修饰的组件才可以调用页面的生命周期
    protected override func onBackPress() {
        this.textColor = Color.Gray
        this.num = 0
        return false
    }

    // 组件生命周期
    protected override func aboutToAppear() {
        this.textColor = Color.Blue
    }

    func build() {
        Column {
            Text("num 的值为：" + this.num.toString())
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.textColor)
            .margin(20)
            .onClick({
                _ =>
                this.num += 5
            })
        }
        .width(100.percent)
    }
}
```

以上示例中，Index页面包含两个自定义组件，一个是被@Entry修饰的EntryView，也是页面的入口组件，即页面的根节点；一个是Child，是EntryView的子组件。只有@Entry修饰的节点才可以使页面级别的生命周期方法生效，因此在EntryView中声明当前Index页面的页面生命周期函数（onPageShow / onPageHide / onBackPress）。EntryView和其子组件Child分别声明了各自的组件级别生命周期函数（aboutToAppear / onDidBuild/aboutToDisappear）。

- 应用冷启动的初始化流程为：EntryView aboutToAppear --> EntryView build --> EntryView onDidBuild --> Child aboutToAppear --> Child build --> Child onDidBuild --> Index onPageShow。

- 点击“delete Child”，if绑定的this.showChild变成false，删除Child组件，会执行Child aboutToDisappear方法。

- 点击“push to next page”，调用router.pushUrl接口，跳转到另外一个页面，当前Index页面隐藏，执行页面生命周期Index onPageHide。此处调用的是router.pushUrl接口，Index页面被隐藏，并没有销毁，所以只调用onPageHide。跳转到新页面后，执行初始化新页面的生命周期的流程。

- 如果调用的是router.replaceUrl，则当前Index页面被销毁，上文已经提到，组件的销毁是从组件树上直接摘下子树，所以执行的生命周期流程将变为：新页面的初始化生命周期流程，然后执行Index onPageHide --> EntryView aboutToDisappear --> Child aboutToDisappear。

- 点击返回按钮，触发页面生命周期Index onBackPress，且触发返回一个页面后会导致当前Index页面被销毁。

- 最小化应用或者应用进入后台，触发Index onPageHide。当前Index页面没有被销毁，所以并不会执行组件的aboutToDisappear。应用回到前台，执行Index onPageShow。

- 退出应用，执行Index onPageHide --> EntryView aboutToDisappear --> Child aboutToDisappear。
