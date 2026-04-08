# 仓颉多线程中使用互操作库

ArkTS 是单线程执行的虚拟机，在运行时上没有对并发做任何的容错；而仓颉在语法上支持内存共享的多线程。

如果在互操作的场景中不加限制地使用多线程，可能会导致无法预期的错误，因此需要一些规范和指引来保证程序正常执行：

1. ArkTS 代码以及大部分互操作接口只能在 ArkTS 线程上执行，否则会抛出仓颉异常。
2. 在进入其他线程前，需要把所有依赖的 ArkTS 数据转换为仓颉数据。
3. 在其他线程如果想要使用 ArkTS 接口，需要通过 `context.postJSTask` 切换到 ArkTS 线程来执行。

下面通过一个用例来展示具体做法。该用例为一个互操作函数，其功能是对两个数字相加，并调用回调函数返回相加结果。

1. 定义仓颉函数：

    ```cangjie
    package ohos_app_cangjie_entry

    import ohos.ark_interop.*

    // 类名没有影响
    class Main {
        // 定义静态构造函数
        static init() {
            // 注册键值对
            JSModule.registerFunc("addNumberAsync", addNumberAsync)
        }
    }

    func addNumberAsync(context: JSContext, callInfo: JSCallInfo): JSValue {
        // 从 JSCallInfo 获取参数列表
        let arg0: JSValue = callInfo[0]
        let arg1: JSValue = callInfo[1]
        let arg2: JSValue = callInfo[2]
        // 把 JSValue 转换为仓颉类型
        let a: Float64 = arg0.toNumber()
        let b: Float64 = arg1.toNumber()
        let callback = arg2.asFunction()
        // 新建仓颉线程
        spawn {
            // 实际仓颉函数行为
            let value = a + b
            // 发起异步回调
            context.postJSTask {
                // 创建 result
                let result = context.number(value).toJSValue()
                // 调用 js 回调
                callback.call(result)
            }
        }

        // 返回 void
        return context.undefined().toJSValue()
    }
    ```

2. 在 Index.d.ts 文件中，提供互操作的接口声明：

    ```typescript
    // libohos_app_cangjie_entry.so 对应的 Index.d.ts
    export declare function addNumberAsync(a: number, b: number, callback: (result: number) => void): void;
    ```

3. ArkTS 调用仓颉函数：

    ```typescript
    // 导入仓颉动态库，该动态库名称为仓颉包名的名称，该名称需要和互操作接口所在的包名一致
    import { addNumberAsync } from "libohos_app_cangjie_entry.so";

    // 调用仓颉函数
    addNumberAsync(1, 2, (result) => {
        console.log("1 + 2 = " + result);
    });
    ```

在 ArkTS 中存在 Promise，这是对回调机制的一种封装，配合 async、await 的语法让回调机制变成同步调用的形式。对于上一个用例，可以使用 Promise 的形式来定义接口和访问：

1. 定义仓颉函数：

    ```cangjie
    package ohos_app_cangjie_entry

    import ohos.ark_interop.*

    // 类名没有影响
    class Main {
        // 定义静态构造函数
        static init() {
            // 注册键值对
            JSModule.registerFunc("addNumberAsync", addNumberAsync)
        }
    }

    // 接口定义
    func addNumberAsync(context: JSContext, callInfo: JSCallInfo): JSValue {
        // 参数转换为仓颉类型
        let a = callInfo[0].toNumber()
        let b = callInfo[1].toNumber()
        // 创建 PromiseCapability 对象
        let promise = context.promiseCapability()
        // 创建新线程
        spawn {
            // 在新线程执行仓颉逻辑
            let result = a + b
            // 切换到 ArkTS 线程
            context.postJSTask {
                // 在 ArkTS 线程执行 resolve
                promise.resolve(context.number(result).toJSValue())
            }
        }
        // 返回 Promise
        promise.toJSValue()
    }
    ```

2. 在 Index.d.ts 文件中，提供互操作的接口声明：

    ```typescript
    // libohos_app_cangjie_entry.so 对应的 Index.d.ts
    export declare function addNumberAsync(a: number, b: number): Promise<number>;
    ```

3. ArkTS 调用仓颉函数：

    ```typescript
    // 导入仓颉动态库，该动态库名称为仓颉包名的名称，该名称需要和互操作接口所在的包名一致
    import { addNumberAsync } from "libohos_app_cangjie_entry.so";

    async function call() {
        // 调用仓颉函数
        let result = await addNumberAsync(1, 2);
        console.log("1 + 2 = " + result);
    }

    call();
    ```
