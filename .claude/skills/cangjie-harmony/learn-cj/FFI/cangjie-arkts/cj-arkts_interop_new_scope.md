# 互操作对象生命周期管理

## 简介

在仓颉与ArkTS互操作库中，JSValue是一个表示ArkTS值的抽象类型，它可以表示任何ArkTS值，包括基本类型（如数字、字符串、布尔值）和复杂对象类型（如数组、函数、对象等）的值。

JSValue的生命周期与其在ArkTS中的对应值的生命周期紧密相关。当ArkTS值被垃圾回收时，与之关联的JSValue也失效。注意不要在ArkTS值不再存在时使用JSValue。

框架层的scope通常用于管理JSValue的生命周期。通过在scope内创建JSValue，可以确保在scope结束时自动释放JSValue，避免内存泄漏。在互操作库中，可以使用JSContext.newScope函数来创建和销毁scope。

JSHeapObject是一个互操作类型，用于管理ArkTS对象的生命周期。在JSValue的生命周期内，JSHeapObject允许开发者引用ArkTS对象，即使JSValue已经超出了其原始上下文的范围。因此，开发者可以在不同的上下文中共享ArkTS对象，并确保在不再需要时正确释放其内存。

## 基本概念

互操作库提供了一组功能，使开发者能够在互操作库模块中创建和操作ArkTS对象，管理引用和生命周期，并注册垃圾回收回调函数等。下面是一些基本概念：

* 作用域：用于管理ArkTS对象的生命周期。在某个作用域中创建的对象句柄，默认情况下只能在该作用域内使用。当作用域被关闭后，其中创建的对象将无法再被访问。
* 引用管理：互操作库提供函数来创建、删除和管理对象的引用，以延长对象的生命周期，避免出现对象use-after-free的问题。同时也通过引用管理去避免发生内存泄漏的问题。
* 垃圾回收回调：允许注册回调函数，以便在ArkTS对象被垃圾回收时执行特定的清理操作。

这些基本概念使开发者能够在互操作模块中安全且有效地操作ArkTS对象，并确保正确管理对象的生命周期。

## 场景和功能介绍

以下互操作库接口主要用于ArkTS对象的引用管理，并确保在互操作模块代码中正确地处理ArkTS对象的生命周期。使用场景如下：

| 接口                                                  | 描述                                                                                                                                    |
|-----------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| JSContext.newScope                                  | 	主要用于管理ArkTS对象的生命周期，确保在互操作模块代码中使用ArkTS对象时能够正确地进行内存管理。当在互操作模块中处理ArkTS对象时，需要创建一个临时的作用域来存储对象的引用，以便在执行期间正确访问这些对象，并在执行结束后关闭这个handle scope。 |
| JSValue.asObject、JSValue.asArray、JSValue.asFunction | 主要用于在互操作模块代码中创建ArkTS对象的安全引用，以确保对象的生命周期符合插件的需求。                                                                                        |
| JSHeapObject（例如：JSObject、JSArray、JSFunction）        | 可逃逸出handle scope的安全引用，ArkTS对象的生命周期会覆盖仓颉对象的生命周期。                                                                                       |

## 使用示例

通过接口JSContext.newScope创建一个上下文环境，并传入一个自定义的回调函数，该回调函数会在这个scope里执行。这组接口用于管理ArkTS对象的生命周期，确保在互操作模块代码处理ArkTS对象时能够正确地管理其句柄，以避免出现对象错误回收的问题。

<!--compile-->
```cangjie
func doSth(context: JSContext, callInfo: JSCallInfo): JSValue {
    context.postJSTask {
        context.newScope {
            let callback = context.function { c, _ =>
                Hilog.info(0, "test", "newScope called")
                c.undefined().toJSValue()
            }
            callback.call()
        }
    }
    context.undefined().toJSValue()
}
```

## 内存泄漏风险场景

当创建的JSValue没有被handle scope管理时，会造成内存泄漏。互操作库会检测这种场景，并打印出调用栈。

典型的泄漏场景如下：

- 在C语言侧使用libuv、eventhandle或ffrt等接口实现异步任务，然后在回调函数中进行互操作接口调用。
- 在使用spawn(UIThread)提交的仓颉任务中进行互操作接口调用。

