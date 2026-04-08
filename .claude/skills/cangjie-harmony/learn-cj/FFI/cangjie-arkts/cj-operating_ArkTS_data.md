# 仓颉访问 ArkTS 数据

此章节详细介绍通过 JSValue 类型使用 ArkTS 数据。

## 使用方法

1. 获取 JSValue 对应的 ArkTS 类型

   从 ArkTS 传过来的参数，其原始类型是`JSValue`，这是一个匿名类型的数据，首先需要获取其类型。获取类型有以下两种方式：

   - 通过 `JSValue.typeof()` 获取其类型枚举 `JSType`。
   - 通过其他途径（包括但不限于阅读 ArkTS 源码、参考文档等）知晓其类型，然后通过类型校验接口来验证，比如判断是否是 number 类型 `JSValue.isNumber()`。

2. 使用 JSValue

   获取 JSValue 类型之后，可以将 `JSValue` 转换为对应的仓颉类型或 ArkTS 引用。

   - 转换为仓颉类型。此时仓颉数据为 ArkTS 数据的拷贝，ArkTS 数据可能在仓颉变量生命周期中释放。例如 ArkTS string 转换为仓颉 String，`var a:String = JSValue.toString(JSContext)`。
   - 转换为 ArkTS 引用。此时仓颉数据为 ArkTS 数据的引用，ArkTS 数据不能在仓颉变量生命周期中释放。比如一个 ArkTS string 转换为 JSString，`var b:JSString = JSValue.asString(JSContext)`。

3. 构造仓颉类型的 ArkTS 数据

   通过仓颉类型来构造 ArkTS 数据，是通过 JSContext 的方法类来构造的。以 `number` 为例，创建一个 `number` 的方式是 `var a : Float64 = JSContext.number(Float64)`。

   ArkTS 主要数据类型对应到仓颉类型的映射如下：

| ArkTS 类型 | 引用类型    | typeof 类型      |
| ---------- | ----------- | ---------------- |
| undefined  | JSUndefined | JSType.UNDEFINED |
| null       | JSNull      | JSType.NULL      |
| boolean    | JSBoolean   | JSType.BOOL      |
| number     | JSNumber    | JSType.NUMBER    |
| string     | JSString    | JSType.STRING    |
| object     | JSObject    | JSType.OBJECT    |
| Array      | JSArray     | JSType.OBJECT    |
| bigint     | JSBigInt    | JSType.BIGINT    |
| function   | JSFunction  | JSType.FUNCTION  |
| symbol     | JSSymbol    | JSType.SYMBOL    |

## 使用实例介绍

### 操作 ArkTS 的普通对象

从一个互操作函数的实现举例:

1. 仓颉函数实现：

    <!--compile-->
    ```cangjie
    // 定义包名，该包名需要和 cjpm.toml 的 package name 保持一致
    package ohos_app_cangjie_entry

    // 导入互操作库ark_interop和互操作宏
    import ohos.ark_interop.*

    // 互操作函数定义，该函数参数类型必须为(JSContext，JSCallInfo),返回值类型必须为JSValue
    func addByObject(context: JSContext, callInfo: JSCallInfo): JSValue {
        // callInfo中记录的为函数调用的参数。如下为获取首个参数：
        let arg0 = callInfo[0]
        // 校验参数0是否是对象，否则返回undefined
        if (!arg0.isObject()) {
            return context.undefined().toJSValue()
        }
        // 把JSValue转换为Float64
        let a = arg0.asObject()["a"].toNumber()
        let b = arg0.asObject()["b"].toNumber()

        let result = a + b
        return context.number(result).toJSValue()
    }

    // 必须注册该函数到JSModule中
    let EXPORT_MODULE = JSModule.registerModule {
        runtime, exports =>
            exports["addByObject"] = runtime.function(addByObject).toJSValue()
    }
    ```

2. 互操作接口声明：

    ```typescript
    // libohos_app_cangjie_entry.so 对应的Index.d.ts
    export declare interface CustomObject {
        a: number;
        b: number;
    }
    // 定义的仓颉互操作函数，名称与仓颉侧注册名称一致
    export declare function addByObject(args: CustomObject): number;
    ```

3. ArkTS 调用函数：

    ```typescript
    // 导入仓颉动态库，该动态库名称为仓颉包名的名称，该名称需要和互操作接口所在的包名一致
    import { addByObject } from "libohos_app_cangjie_entry.so";

    // 调用仓颉接口
    let result = addByObject({a: 1, b: 2});
    console.log("result = " + result);
    ```

除了可以从对象上读取属性外，还可以对属性赋值或创建新属性，操作方式为 `JSObject[key] = value`，其中 key 可以是仓颉 String 、JSString 或 JSSymbol 类型，value 是 JSValue 类型 。

> **说明：**
>
> 通过 `JSObject[key] = value` 定义属性时，该属性可写、可枚举、可配置。
> 更多参见 [JavaScript 标准内置对象](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Object)。

**值得注意的是：**

1. 对属性赋值在以下几种场景会失败，失败之后没有异常或日志：

   1. 目标对象是 sealed 对象，由 `Object.seal()` 接口创建的对象具有不可修改的特性，无法创建新的属性和修改原有属性。
   2. 目标属性的 writable 是 false ，由 `Object.defineProperty(object, key, {writable: false, value: xxx})` 定义属性时，可以指定属性是否可写。

2. 对于一个未知对象，可以枚举出该对象的可枚举属性：

   <!--compile-->
   ```cangjie
   func handleUnknownObject(context: JSContext, target: JSObject): Unit {
       // keys接口枚举对象的可枚举属性
       let keys = target.keys()
       Hilog.info(0, "", "target keys: ${keys}")
   }
   ```

3. 创建一个新的 ArkTS 对象，可以通过 `JSContext.object()` 来创建。

4. 对于 ArkTS 运行时，有一个特殊的 ArkTS 全局对象，在任何 ArkTS 代码里都可以直接访问该对象下的属性，在仓颉侧可以通过 `JSContext.global` 来访问。

### 操作 ArkTS 的 sendable 对象

ArkTS 提供了 sendable 对象类型，在并发通信时支持通过引用传递来解决大量对象并发通信的诉求。

仓颉侧操作 sendable 对象和普通的 ArkTS 对象是一致的。

在 ArkTS 侧定义一个 sendable 对象：

```typescript
// 函数定义
@Sendable
class SendableTestClass {
  desc: string = "sendable: this is SendableTestClass ";
  num1: number = 5;
  num2: number = 5;
  printName() {
    console.info("sendable: SendableTestClass desc is: " + this.desc);
  }
  get getNum(): number {
    return this.num1;
  }
}
```

在仓颉侧操作 sendable 对象：

<!--compile-->
```cangjie
// 定义包名，该包名需要和 cjpm.toml 的 package name 保持一致
package ohos_app_cangjie_entry

// 导入互操作库ark_interop和互操作宏
import ohos.ark_interop.*

// 互操作函数定义，该函数参数类型必须为(JSContext，JSCallInfo),返回值类型必须为JSValue
func readNumber(context: JSContext, callInfo: JSCallInfo): JSValue {
    let obj = callInfo[0].asObject()
    // 从JSObject获取属性
    let argA = obj["num1"]
    let argB = obj["num2"]
    // 把JSValue转换为Float64
    let a = argA.toNumber()
    let b = argB.toNumber()

    let result = a + b
    return context.number(result).toJSValue()
}

// 必须注册该函数到JSModule中
let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports =>
        exports["readNumber"] = runtime.function(readNumber).toJSValue()
}
```

在 Index.d.ts 文件中，提供互操作的接口声明：

```typescript
// libohos_app_cangjie_entry.so 对应的 Index.d.ts
export declare function readNumber(data: SendableTestClass): number;

interface SendableTestClass {}
```

在 ArkTS 侧构建 sendable 对象：

```typescript
// 导入仓颉动态库，该动态库名称为仓颉包名的名称，该名称需要和互操作接口所在的包名一致
import { readNumber } from "libohos_app_cangjie_entry.so"

// 构建 sendable 对象
let a = new SendableTestClass();
// 调用仓颉接口
let result = readNumber(a);
console.log("result = " + result);
```

### ArkTS 异步锁

为了解决多并发实例间的数据竞争问题， ArkTS 语言基础库引入了异步锁能力。为了开发者的开发效率， AsyncLock 对象支持跨并发实例引用传递，具体可参考[异步锁](https://docs.openharmony.cn/pages/v6.0/zh-cn/application-dev/arkts-utils/arkts-async-lock-introduction.md)。本节重点介绍异步锁结合 sendable 对象的场景。

仓颉侧实现：

<!--compile-->
```cangjie
// 定义包名，该包名需要和 cjpm.toml 的 package name 保持一致
package ohos_app_cangjie_entry

internal import ohos.ark_interop.JSModule
internal import ohos.ark_interop.JSContext
internal import ohos.ark_interop.JSCallInfo
internal import ohos.ark_interop.JSValue

func testAsync(context: JSContext, callInfo: JSCallInfo): JSValue {
    // 创建 PromiseCapability
    let promise = context.promiseCapability()
    spawn {
        // 使用新线程来执行运算密集的任务
        // 回到 ArkTS 线程
        context.postJSTask {
            // 向 ArkTS 返回结果
            promise.resolve(context.string("abcdedf").toJSValue())
        }
    }
    // 返回 Promise
    promise.toJSValue()
}

func readName(context: JSContext, callInfo: JSCallInfo): JSValue {
    let some = callInfo[0].asObject()
    some["lock"].asObject().callMethod("lockAsync", context.function { context, callInfo =>
        return some["name"]
    }.toJSValue())
}

let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports =>
        exports["testAsync"] = runtime.function(testAsync).toJSValue()
        exports["readName"] = runtime.function(readName).toJSValue()
}
```

在 Index.d.ts 文件中，提供互操作的接口声明：

```typescript
// libohos_app_cangjie_entry.so对应的Index.d.ts
export declare function testAsync(): Promise<boolean>;
export declare function readName(data: Some): Promise<string>;

interface Some {}
```

在 entry->src->main->ets 中创建一个文件 workerTest.ets，主线程代码如下：

```typescript
// workerTest.ets
import hilog from '@ohos.hilog';
import worker, {MessageEvents} from '@ohos.worker';
import {ArkTSUtils} from "@kit.ArkTS";

// 导入仓颉动态库，该动态库名称为仓颉包名的名称，该名称需要和互操作接口所在的包名一致
import { readName } from "libohos_app_cangjie_entry.so";

// 定义 Sendable 类
@Sendable
export class Some {
  name: string = "safd";
  type: string = "";
  result: boolean = false;
  lock: ArkTSUtils.locks.AsyncLock;

  constructor() {
    this.lock = new ArkTSUtils.locks.AsyncLock();
  }

  getName(): Promise<string> {
    return this.lock.lockAsync(() => {
      return this.name;
    });
  }

  setName(value: string): Promise<void> {
    return this.lock.lockAsync(() => {
      this.name = value;
    });
  }
}
// 程序入口
export async function startTestWorker() {
  hilog.info(0, "test", "worker test begin");
  // 创建 worker
  const thread = new worker.ThreadWorker("entry/ets/workers/Worker.ets");
  // 创建并初始化事件回调表
  const eventHandlers = new Map<string, (msg: MessageEvents) => void>();
  eventHandlers.set("close", (evt) => {
    thread.terminate();
  });
  eventHandlers.set("result", async (evt) => {
    let result = evt.data.value as boolean;
    const name = await a.getName();
    hilog.info(0, "worker", `result is ${result}, name is ${name}`);
  });
  // 监听 worker 消息
  thread.onmessage = (evt) => {
    let type = evt.data.type as string;
    if (eventHandlers.has(type)) {
      eventHandlers.get(type)!(evt);
    } else {
      hilog.error(0, "worker", "unknown message type: %{public}s", type);
    }
  };
  // 创建 Sendable 对象
  let a = new Some();
  // 调用仓颉接口
  hilog.info(0, "test", `name: ${await readName(a)}`);
  // 向 worker 发送消息 "begin"
  a.type = "begin";
  thread.postMessageWithSharedSendable(a);
}
```

在 entry->src->main->ets 中创建一个 workers 文件夹，在 workers 中创建 Workers.ets 文件，代码如下：

```typescript
// Workers.ets
import {ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker} from '@kit.ArkTS';
import hilog from '@ohos.hilog';

// 导入仓颉动态库，该动态库名称为仓颉包名的名称，该名称需要和互操作接口所在的包名一致
import { readName, testAsync } from "libohos_app_cangjie_entry.so";

import {Some} from "../workerTest";

// 获取 worker 线程环境
const workerPort: ThreadWorkerGlobalScope = worker.workerPort;
// 监听主线程消息
workerPort.onmessage = (evt) => {
  let some = evt.data as Some;
  if (some.type == "begin") {
    beginTask(some);
  }
}

async function beginTask(some: Some) {
  // 在 worker 线程修改对象属性
  await some.setName("modified");
  some.type = "modify";
  hilog.info(0, "worker", `worker name: ${await readName(some)}`);
  // 调用仓颉函数
  testAsync().then(data => {
    hilog.info(0, "worker", `resolved: ${data}`);
    workerPort.postMessage({"type": "result", value: data});
  }).catch((err: Error) => {
    hilog.error(0, "worker", `caught error: ${err.message}`);
    workerPort.postMessage({"type": "result", value: false});
  });
}
```

在 ArkTS 侧启动 Worker：

```typescript
// 导入仓颉动态库，该动态库名称为仓颉包名的名称，该名称需要和互操作接口所在的包名一致
import { startTestWorker } from "../workerTest"

// 启动 Worker
startTestWorker();
```

### 调用 ArkTS 函数

#### 普通函数调用

获取一个 ArkTS 函数后（通过参数传递，全局变量传递，从 ArkTS 数据集合里获取如从数组通过索引获取元素），可以在仓颉里直接调用。
该示例是先从 ArkTS 调用仓颉函数，然后在仓颉函数的实现里回调 ArkTS 函数。

1. ArkTS 调用仓颉：

    ```typescript
    // libohos_app_cangjie_entry.so对应的Index.d.ts
    export declare function addByCallback(a: number, b: number, callback: (result: number) => void): void;
    ```

    ```typescript
    // 1.导入仓颉动态库，该动态库名称为仓颉包名的名称，该名称需要和互操作接口所在的包名一致
    import { addByCallback } from "libohos_app_cangjie_entry.so";

    // 2.调用仓颉接口
    addByCallback(1, 2, (result) => {
        console.log(`1 + 2 = ${result}`);
    });
    ```

2. 仓颉代码中回调 ArkTS 函数：

    <!--compile-->
    ```cangjie
    package ohos_app_cangjie_entry

    internal import ohos.ark_interop.JSModule
    internal import ohos.ark_interop.JSContext
    internal import ohos.ark_interop.JSCallInfo
    internal import ohos.ark_interop.JSValue

    func addByCallback(context: JSContext, callInfo: JSCallInfo): JSValue {
        // 获取第1、2个参数，并转换为Float64
        let a = callInfo[0].toNumber()
        let b = callInfo[1].toNumber()
        // 把第3个参数转换为JSFunction
        let callback = callInfo[2].asFunction()
        // 计算结果
        let result = a + b
        // 从仓颉Float64创建ArkTS number
        let retJSValue = context.number(result).toJSValue()
        // 调用回调函数
        callback.call(retJSValue)
    }

    let EXPORT_MODULE = JSModule.registerModule {
        runtime, exports =>
            exports["addByCallback"] = runtime.function(addByCallback).toJSValue()
    }
    ```

#### 带 this 指针的函数调用

这个用例里的函数是不带 this 指针的，针对需要 this 指针的方法调用，可以通过命名参数 `thisArg` 来指定。

<!--compile-->
```cangjie
func doSth(context: JSContext, callInfo: JSCallInfo): JSValue {
    let callback = callInfo[0].asFunction()
    let thisArg = callInfo[1]

    callback.call(thisArg: thisArg)
}
```

在 ArkTS 代码里，可以通过 `对象.方法(...)` 来进行调用，这时会隐式传递 this 指针。

```typescript
class Someone {
    id: number = 0;
    doSth(): void {
        console.log(`someone ${this.id} have done something`);
    }
}

let target = new Someone();

// 这里会隐式传递this指针，调用正常
target.doSth();

let doSth = target.doSth;
// 这里没有传递this指针，会出现异常`can't read property of undefined`
doSth.call();
```

在仓颉里，对应的写法如下：

<!--compile.error-->
```cangjie
func doSth(context: JSContext, callInfo: JSCallInfo): JSValue {
    let object = callInfo[0].asObject()
    // 会隐式传递this指针，调用正常
    object.callMethod("doSth")

    let doSth = object["doSth"].asFunction()
    // 未传递this指针，会出现异常`can't read property of undefined`
    doSth.call()
    // 显式传递this指针，调用正常
    doSth.call(thisArg: object.toJSValue())
}
```
