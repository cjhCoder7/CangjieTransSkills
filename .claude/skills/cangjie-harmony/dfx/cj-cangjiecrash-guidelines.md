# 分析Cangjie Crash（进程崩溃）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

当未捕获的仓颉异常导致应用意外退出时，应用会在抛出未捕获异常时崩溃，并生成对应的 `Crash` 日志文件。开发者可通过错误日志确认引起崩溃的代码位置并分析原因。

## 仓颉 Crash 日志规格

以下是 `Crash` 日志中各字段含义。

```text
Device info:XXXXXX                        // 设备信息
Build info:XXX-XXXX X.X.X.XX(XXXXXXXX)    // 版本信息
Module name:com.example.myapplication     // 模块名
Version:1.0.0                             // 版本号
Pid:45570                                 // 进程号
Uid:0                                     // 用户ID
Reason:std.core:Exception                 // Crash 原因
Uncaught exception was found.
Exception info: throwing foo exception    // 异常信息
Stacktrace:                               // 异常代码调用栈
    at ohos_app_cangjie_entry.foo()(entry\src\main\cangjie/index.cj:20)
```

## 仓颉 Crash 异常捕获场景

在仓颉中，异常类有 `Error` 和 `Exception`：

- `Error` 类描述仓颉语言运行时，系统内部错误和资源耗尽错误，应用程序不应该抛出这种类型错误。如果出现内部错误，只能通知给用户，尽量安全终止程序。

- `Exception` 类描述的是程序运行时的逻辑错误或者 IO 错误导致的异常，例如数组越界或者试图打开一个不存在的文件等，这类异常需要在程序中捕获处理。常见的异常信息详见<!--RP1-->[常见运行时异常](https://gitcode.com/Cangjie/cangjie_docs/blob/main/docs/dev-guide/source_zh_cn/error_handle/common_runtime_exceptions.md)<!--RP1End-->。

## 问题定位思路

### 获取日志

进程崩溃日志是一种故障日志，与应用无响应日志、应用崩溃等均由 `FaultLogger` 模块管理，可通过以下方式获取：

1. 通过 `DevEco Studio` 获取日志

    `DevEco Studio` 会收集设备 `/data/log/faultlog/faultlogger/` 路径下的进程崩溃故障日志并归档在 `FaultLog` 下，仓颉进程崩溃日志归档在 `FaultLog` 下的 `cjerror` 类型中，获取日志的方法请参见 [FaultLog](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-fault-log)。

2. 通过 `hiAppEvent` 接口订阅

    `hiAppEvent` 提供了故障订阅接口，可以订阅各类故障打点，详见 [`HiAppEvent` 介绍](./cj-hiappevent-intro.md)。

### 根因分析

仓颉 `Crash` 问题分析可以通过故障日志中的异常信息、异常代码调用栈来定位到源代码，得出基本的分析结论。

对于 `Error` 类异常，调用栈参考意义有限，根因定位较为复杂，需要结合代码逻辑、内存开销、参数配置等方面，借助 `DevEco Studio` 中提供的分析工具进行分析。

对于 `Exception` 类异常，大多数情况为代码逻辑异常导致，可以根据调用栈直接定位到异常代码，检视代码逻辑即可。

## 案例分析

### Error 类案例分析

`Error` 类问题一般是仓颉语言运行时感知到系统内部错误或资源耗尽错误时抛出的异常。

开发者常见的此类异常有两种：

1. `OutOfMemoryError`：内存不足时由运行时抛出。

2. `StackOverflowError`：仓颉线程栈溢出时由运行时抛出。

#### 案例一：内存不足异常

案例源代码如下：

<!-- compile -->

```cangjie
var bigArray = Array<Rune>(1024 * 1024 * 60, repeat: r'a')
func foo(): Unit {
    var smallArray = Array<Rune>(1024 * 1024 * 5, repeat: r'a')
}

@Entry
@Component
class EntryView {
    @State
    var message: String = "Hello Cangjie"
    func build() {
        Row {
            Column {
                Button(message).onClick ({
                    evt => Hilog.info(1, "info", "Hello Cangjie")
                    foo()
                }).fontSize(40).height(80)
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

1. 获取 `Crash` 日志，根据日志信息中的 `Crash` 原因和异常信息确认程序崩溃的直接原因。

    `Crash` 日志核心内容如下：

    ```text
    Reason:std.core:OutOfMemoryError
    Uncaught exception was found.
    Exception info: [none]
    Stacktrace:
        at ohos_app_cangjie_entry.foo()(entry\src\main\cangjie/index.cj:24)
        at ohos_app_cangjie_entry.EntryView::build::lambda.0::lambda.0::lambda.0::lambda.0::lambda.0::lambda.0()(entry\src\main\cangjie/index.cj:38)
        at _CCN22ohos_app_cangjie_entry9EntryView5buildHvEL_L_L_L_L_L_E_29$i(:0)
        at _CCN14ohos.component13ComponentBaseIG_E7onClickHF0uRNY_10ClickEventEEEL_E_6$i(:0)
        at _CCN14ohos.component16InteractableView7onClickHF0uRNY_10ClickEventEEEL_E_6$i(:0)
        at ohos.arkui.component.CallbackCJClickEvent::invoke(Int32, CPointer<...>, CPointer<...>)(cj_lambda_invoker_impl.cj:50)
        at ohos.ffi.ohosFFICJCallbackInvoker(Int64, Int32, CPointer<...>, CPointer<...>)(ffi_callback.cj:172)
    ```

    根据 `Crash` 原因和异常信息可知，程序崩溃的直接原因是内存不足异常。

2. 分析问题根因。

    对于 `OutOfMemoryError` 异常，调用栈参考意义有限，因为内存不足时，任何地方都可能导致 `OutOfMemoryError`，异常抛出点可能只是恰好用完了所剩无几的可用内存。

    要分析 `OutOfMemoryError` 异常发生的根本原因，可以从以下几个方面综合分析：

    - 内存开销。可以借助 `DevEco Studio` 提供的 `Profiler` 工具对内存开销进行分析。

    - 代码逻辑。可以结合调用栈、堆栈开销等，检视业务代码，确认代码逻辑的正确性。如果代码逻辑无错误，再结合堆栈开销考虑是否可以优化代码。

    - 参数配置。确认 `cjHeapSize` 大小配置是否符合当前业务场景。

### Exception 类案例分析

`Exception` 类问题一般是开发者或仓颉标准库自主抛出的仓颉异常。

这类问题目前有两种场景：

1. 如果是当前应用程序遇到无法解决的只能终止当前业务的故障，需要考虑抛出仓颉异常来终止业务并生成故障日志。

2. 依赖使用仓颉标准库模块接口，对于可能抛出异常的接口，需要考虑使用 `try-catch` 机制进行捕获，或者提前增加保护性检查，否则也会终止当前业务。

#### 案例一：开发者自主抛出一个自定义的仓颉异常来终止程序

开发者自主抛出仓颉异常，可以通过如下代码实现：

<!-- compile -->

```cangjie
throw Exception("throwing exception")
```

或者继承内置的 `Exception` 或其子类来自定义异常并抛出，自定义异常的代码实现请参见<!--RP2-->[定义异常](https://gitcode.com/Cangjie/cangjie_docs/blob/main/docs/dev-guide/source_zh_cn/error_handle/exception_overview.md)<!--RP2End-->。

该类问题，通过故障日志中异常代码堆栈的栈顶抛出点可以直接定位到具体的代码行。

![image-20250425104944](./figures/cangjiecrash_image_001.png)

之后进一步检视上下文来分析问题即可。

#### 案例二：因未处理仓颉标准库抛出的异常导致的 Crash 问题

本节以 `NoneValueException` 异常为例，通过一个简单的案例展示分析仓颉 `Crash` 问题的过程。

案例源代码如下：

<!-- compile -->

```cangjie
import std.collection.*

func foo() {
    let map = HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2)])
    println(map["d"])
}
@Entry
@Component
class EntryView {
    @State
    var message: String = "Hello Cangjie"
    func build() {
        Row {
            Column {
                Button(message).onClick ({
                    evt => Hilog.info(1, "info","Hello Cangjie")
                    foo()
                }).fontSize(40).height(80)
            }.width(100.percent)
        }.height(100.percent)
    }
}
```

1. 获取 `Crash` 日志，根据日志信息中的 `Crash` 原因和异常信息确认程序崩溃的直接原因。

    `Crash` 日志核心内容如下：

    ```text
    Reason:std.core:NoneValueException
    Uncaught exception was found.
    Exception info: Value does not exist!

    Stacktrace:
        at _CNac10ArrayDequeIG_E4growHl.exception_outlined_func.10(std/collection/array_deque.cj:160)
        at std.collection.HashMap<...>::[](T0)(std/collection/hash_map.cj:835)
        at ohos_app_cangjie_entry.foo()(entry\src\main\cangjie/index.cj:22)
        at ohos_app_cangjie_entry.EntryView::build::lambda.0::lambda.0::lambda.0::lambda.0::lambda.0::lambda.0()(entry\src\main\cangjie/index.cj:35)
        at _CCN22ohos_app_cangjie_entry9EntryView5buildHvEL_L_L_L_L_L_E_29$i(:0)
        at _CCN14ohos.component13ComponentBaseIG_E7onClickHF0uRNY_10ClickEventEEEL_E_6$i(:0)
        at _CCN14ohos.component16InteractableView7onClickHF0uRNY_10ClickEventEEEL_E_6$i(:0)
        at ohos.arkui.component.CallbackCJClickEvent::invoke(Int32, CPointer<...>, CPointer<...>)(cj_lambda_invoker_impl.cj:50)
        at ohos.ffi.ohosFFICJCallbackInvoker(Int64, Int32, CPointer<...>, CPointer<...>)(ffi_callback.cj:172)
    ```

    根据 `Crash` 原因和异常信息可知，程序崩溃的直接原因是存在未捕获的 `NoneValueException` 异常。

2. 根据 `Crash` 日志中的堆栈定位到具体源代码。

    从上至下查看异常代码调用栈，前两帧为 `std` 模块即标准库抛出异常的现场，`std` 模块的上一帧为具体源代码的位置。

    分析堆栈可以定位到异常抛出位置在源代码的第 22 行 `foo` 函数中，且错误的发生与 `HashMap` 下标语法访问有关。

    具体异常代码如下：

    <!-- compile -->

    ```cangjie
    func foo() {
        let map = HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2)])
        println(map["d"])
    }
    ```

3. 分析异常代码，确定问题根因。

    分析异常代码上下文可知，由于 `map` 中不存在 `key` 为 `d` 的键值对导致异常。

    该案例，较为简单，如果代码逻辑复杂，可以借助 `DevEco Studio` 提供的调试工具对程序进行调试。

4. 修改方案。

    根据分析结果，对源代码进行相应修改。可以在查找 `HashMap` 中的键值对前，增加对 `key` 值是否存在的保护性判断。

    修改后 `foo` 函数源代码如下：

    <!-- compile -->

    ```cangjie
    func foo() {
       let map = HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2)])
       if (map.contains("d")) {
           println(map["d"])
       }
    }
    ```
