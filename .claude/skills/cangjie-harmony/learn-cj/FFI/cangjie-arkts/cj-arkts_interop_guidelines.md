# 仓颉-ArkTS 互操作开发规范

## 多引擎实例上下文敏感

**【规则】** 禁止跨引擎实例访问 JS 对象。

多引擎实例场景下，每个 JS 对象（如 JSValue 及其子类的实例）都绑定于创建它的引擎实例（JSContext）。不同引擎实例之间相互独立，不能共享 JS 对象。如果在非所属引擎中访问 JS 对象，可能会导致程序崩溃。

在仓颉- ArkTS 互操作库中，早期的访问 JS 对象的相关接口需要开发者手动传入 JSContext，调用时需要确保传入正确实例。这类接口已标记为“废弃（deprecated）”，建议统一使用不含 JSContext 参数的新接口，由接口实现本身来自动选择正确的引擎实例。

**错误示例：**

仓颉代码：

<!--compile.error-->
```cangjie
// 导入互操作库
import ohos.ark_interop.*

func doSth(context: JSContext, callInfo: JSCallInfo): JSValue {
    // 创建新的运行时实例
    let newRuntime = JSRuntime()
    let newContext = newRuntime.mainContext

    // 在新运行时上创建新对象
    let newObjValue = newContext.object().toJSValue()

    // 错误：将新对象的 JSValue 使用老运行时实例转换为对象
    let newObj = newObjValue.asObject()

    // 错误：在新对象设置属性时使用老运行时作为参数
    newObjValue.setProperty(context, newContext.string("a"), newContext.boolean(false).toJSValue())

    // 错误：在获取对象设置属性时使用老运行时创建的字符串作为键
    newObjValue.getProperty(newContext, context.string("a"))

    return newObjValue
}

let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports => exports["doSth"] = runtime.function(doSth).toJSValue()
}
```

**正确示例：**

仓颉代码：

<!--compile-->
```cangjie
// 导入互操作库
import ohos.ark_interop.*

func doSth(context: JSContext, callInfo: JSCallInfo): JSValue {
    // 创建新的运行时实例
    let newRuntime = JSRuntime()
    let newContext = newRuntime.mainContext

    // 在新运行时上创建新对象
    let newObjValue = newContext.object().toJSValue()

    // 正确：将新对象的 JSValue 使用新运行时实例转换为对象
    let newObj = newObjValue.asObject()

    // 正确：在新对象设置属性时使用非废弃接口（不显式传递context）
    newObjValue.setProperty(newContext.string("a"), newContext.boolean(false).toJSValue())

    // 正确：在获取对象设置属性时使用新运行时创建的字符串作为键
    newObjValue.getProperty(newContext.string("a"))

    return newObjValue
}

let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports => exports["doSth"] = runtime.function(doSth).toJSValue()
}
```

## 异常处理

**【规则】** 使用 try 语句捕获并处理跨语言调用异常。

在跨语言函数调用中，被调用侧（callee）抛出的异常会通过互操作库自动转换为调用侧（caller）可捕获的异常。调用侧应使用 try 语句进行异常捕获和处理，避免程序出错或崩溃。

**正确示例（在 ArkTS 侧捕获仓颉异常）：**

仓颉侧代码：

<!--compile-->
```cangjie
// 导入互操作库
import ohos.ark_interop.*

func doSthWithException(context: JSContext, callInfo: JSCallInfo): JSValue {
    if (callInfo.count > 0) {
        throw Exception("should not pass any argument")
    }
    context.undefined().toJSValue()
}

let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports => exports["doSthWithException"] = runtime.function(doSthWithException).toJSValue()
}
```

ArkTS 侧代码：

```javascript
interface CJLib {
    doSthWithException(src?: string): void
}

function doSth(lib: CJLib): void {
    // 在调用跨语言接口时，使用 try...catch 来捕获跨语言异常
    try {
        lib.doSthWithException("xxx")
    } catch (err) {
        // ...
    }
}
```

**正确示例（在仓颉侧捕获 ArkTS 异常）：**

仓颉侧代码：

<!--compile-->
```cangjie
// 导入互操作库
import ohos.ark_interop.*

func callArktsWithExp(context: JSContext, callInfo: JSCallInfo): JSValue {
    // 在调用跨语言接口时，使用 try...catch 来捕获跨语言异常
    try {
        callInfo[0].asFunction().call()
    } catch (err: JSCodeError) {
        // ...
    }
    context.undefined().toJSValue()
}

let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports => exports["callArktsWithExp"] = runtime.function(callArktsWithExp).toJSValue()
}
```

ArkTS 侧代码：

```javascript
interface CJLib {
    callArkTSWithExp(callback: () => void): void
}

function doSth(lib: CJLib): void {
    lib.callArkTSWithExp(() => {
        throw new Error("this is an error")
    })
}
```

## 正确的使用 JSContext.external 接口创建的 JS Object

**【规则】** 正确的使用 JSContext.external 接口创建的 JS Object。

通过 JSContext.external 创建的 JSExternal 对象，在 ArkTS 侧类型为 undefined，不应直接作为接口参数使用。建议将 JSExternal 对象绑定到一个 JSObject 上，通过对象封装隐藏内部数据，提升接口的安全性与可维护性。

**错误示例：**

仓颉侧代码：

<!--compile.error-->
```cangjie
// 导入互操作库
import ohos.ark_interop.*

// 定义共享类，SharedObject为互操作库的类
class Data <: SharedObject {
    Data(
        // 定义2个属性
        var id: Int64,
        let name: String
    ) {}

    static init() {
        // 注册导出到ark的函数
        JSModule.registerFunc("createData", createData)
        JSModule.registerFunc("setDataId", setDataId)
        JSModule.registerFunc("getDataId", getDataId)
    }

    // 创建共享对象
    static func createData(context: JSContext, _: JSCallInfo): JSValue {
        // 创建仓颉对象
        let data = Data(1, "abc")
        // 创建js对仓颉对象的引用
        let jsExternal = context.external(data)
        // 返回js对仓颉对象的引用
        return jsExternal.toJSValue()
    }

    // 设置对象的id
    static func setDataId(context: JSContext, callInfo: JSCallInfo): JSValue {
        // 读取参数
        let arg0 = callInfo[0]
        let arg1 = callInfo[1]

        // 把参数0转换为js对仓颉对象的引用
        let jsExternal = arg0.asExternal()
        // 获取仓颉对象
        let data: Data = jsExternal.cast<Data>().getOrThrow()
        // 把参数1转换为Float64
        let value = arg1.toNumber()

        // 仓颉对象修改属性
        data.id = Int64(value)

        // 返回undefined
        let result = context.undefined().toJSValue()
        return result
    }

    // 获取对象的id
    static func getDataId(context: JSContext, callInfo: JSCallInfo): JSValue {
        let arg0 = callInfo[0]

        let jsExternal = arg0.asExternal()

        let data: Data = jsExternal.cast<Data>().getOrThrow()

        let result = context.number(Float64(data.id)).toJSValue()
        return result
    }
}
```

仓颉侧代码对应的 ArkTS 接口声明：

```javascript
export declare function createData(): undefined;
export declare function setDataId(data: undefined, value: number): void;
export declare function getDataId(data: undefined): number;
```

ArkTS 侧代码：

```javascript
import { createData, setDatId, getDataId } from "libohos_app_cangjie_entry.so";

// 创建共享对象
let data = createData();
// 操作对象属性
setDataId(data, 3);
let id = getDataId(data);

console.log("id is " + id);
```

**正确示例：**

仓颉侧代码：

<!--compile-->
```cangjie
// 导入互操作库
import ohos.ark_interop.*

// 定义共享类
class Data <: SharedObject {
    Data(
        // 定义2个属性
        var id: Int64,
        let name: String
    ) {}

    static init() {
        // 注册导出到ark的函数
        JSModule.registerFunc("createData", createData)
    }

    // 创建共享对象
    static func createData(context: JSContext, _: JSCallInfo): JSValue {
        let data = Data(1, "abc")
        let jsExternal = context.external(data)

        // 创建空JSObject
        let object = context.object()
        // 把js对仓颉对象的引用挂在JSObject的隐藏属性上
        object.attachCJObject(jsExternal)

        // 为js对象增加2个方法
        object["setId"] = context.function(setDataId).toJSValue()
        object["getId"] = context.function(getDataId).toJSValue()

        return object.toJSValue()
    }

    // 设置对象的id
    static func setDataId(context: JSContext, callInfo: JSCallInfo): JSValue {
        // 获取this指针
        let thisArg = callInfo.thisArg
        let arg0 = callInfo[0]

        // 把this指针转换为JSObject
        let thisObject = thisArg.asObject()
        // 从JSObject上获取隐藏属性
        let jsExternal = thisObject.getAttachInfo().getOrThrow()
        // 从js对仓颉对象的引用上获取仓颉对象
        let data = jsExternal.cast<Data>().getOrThrow()
        // 把参数0转换为Float64
        let value = arg0.toNumber()

        // 修改仓颉对象的属性
        data.id = Int64(value)

        let result = context.undefined()
        return result.toJSValue()
    }

    // 获取对象的id
    static func getDataId(context: JSContext, callInfo: JSCallInfo): JSValue {
        let thisArg = callInfo.thisArg
        let thisObject = thisArg.asObject()
        let jsExternal = thisObject.getAttachInfo().getOrThrow()
        let data = jsExternal.cast<Data>().getOrThrow()

        let result = context.number(Float64(data.id)).toJSValue()
        return result
    }
}
```

仓颉侧代码对应的 ArkTS 接口声明：

```javascript
export declare interface Data {
    setId(value: number): void;
    getId(): number;
}

export declare function createData(): Data;
```

ArkTS 侧代码：

```javascript
import { createData } from "libohos_app_cangjie_entry.so";

// 创建共享对象
let data = createData();
// 操作对象属性
data.setId(3);
let id = data.getId();

console.log("id is " + id);
```

## 跨语言对象引用

**【规则】** 在跨语言传递对象时，开发者应避免本地代理对象持有对原生对象的引用，或在使用结束后及时将该引用置空，以防止内存泄漏。

在跨语言互操作过程中，容易出现跨语言对象引用成环的情况，进而导致相关对象无法被释放，造成内存泄漏。环形引用的根本原因在于，跨语言对象的代理（通常是跨语言方法的参数或返回值）与原生对象之间形成了环状依赖关系，而各自的垃圾回收机制（GC）无法自动识别并处理这种跨运行时的引用，从而需要开发者手动进行管理。

![interop-circle](../../figures/interop-circle.png)

如上图所示，为规避此类问题，建议开发者在设计时尽量避免代理对象直接引用原生对象。如果业务场景确实需要代理对象持有原生对象的引用，请在使用完毕后及时释放对原生对象的引用关系。

环形引用错误示例：

仓颉侧代码：

<!--compile.error-->
```cangjie
import ohos.ark_interop.*

class CJData <: SharedObject {
    let name: String
    var callback: ?()->Unit = None
    init(name: String) {
        this.name = name
    }
}

func createCJData(context: JSContext, callInfo: JSCallInfo): JSValue {
    let object = context.object()
    let data = CJData(callInfo[0].toString())
    object.attachCJObject(context.external(data))
    object.defineOwnAccessor("name", getter: { context, callInfo =>
        context.string(data.name).toJSValue()
    })
    object.defineOwnAccessor("callback", setter: {context, callInfo =>
        let callback = callInfo[0].asFunction()
        data.callback = { =>
            callback.call()
        }
        context.undefined().toJSValue()
    })

    object.toJSValue()
}

let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports => exports["createCJData"] = runtime.function(createCJData).toJSValue()
}
```

仓颉侧代码对应的 ArkTS 接口声明：

```javascript
export declare interface CJData {
    name: string;
    callback: () => void;
}

export declare function createCJData(): CJData;
```

ArkTS 侧代码：

```javascript
import { createCJData, CJData } from "libohos_app_cangjie_entry.so"

const data: CJData = createCJData("123")
data.callback = () => {
    console.log(data.name)
}
```

上述例子中引用成环的原因如下：

1. ArkTS 侧创建的 CJData 对象 **data** 底层通过 external 持有仓颉对象
2. 仓颉对象（CJData 类型）持有 **callback** 变量
3. **callback** 捕获 ArkTS 侧的 callback 函数
4. ArkTS 侧的 callback 函数捕获了 ArkTS 侧创建的 CJData 对象 **data**

假设上述场景为业务场景需要，那么开发者需要在 data.callback 执行完成之后及时将 data.callback 置空，既可解除环形引用。示例如下：

<!--code_no_check-->
```cangjie
// ...
data.callback()
data.callback = () = {}
// ...
```

## ArkTS 主线程中调用的仓颉接口中，不能在主线程中阻塞等待 spawn(UIThread) 的执行结果

**【规则】** ArkTS 主线程中调用的仓颉接口中，不能在主线程中阻塞等待 spawn(UIThread) 的执行结果，否则会造成死锁，触发 App Freeze 故障。

ArkTS 主线程中调用的仓颉接口时，仓颉代码中可能会通过 spawn(UIThread) 表达式向主线程抛一个异步任务，该操作通常用于将仓颉接口的执行结果返回给 ArkTS 侧。开发者需要注意，不能在主线程中阻塞等待 spawn(UIThread) 的执行结果，否则会造成死锁，触发 App Freeze 故障（APP_INPUT_BLOCK）。常见的阻塞行为包括但不限于：

- 使用 future.get() 等待 spawn(UIThread) 表达式返回值；
- 使用 Mutex 的 lock() 接口获取会在 spawn(UIThread) 的任务中释放的锁。

**错误示例：**

仓颉侧代码：

<!--compile.error-->
```cangjie
import ohos.ark_interop.*
import ohos.ark_interop_macro.*
import ohos.base.UIThread

@Interop[ArkTS]
public func testCJ(): Unit {
    // ...
    let future = spawn(UIThread) {
        // ...
    }
    future.get() // 错误：spawn(UIThread) 是创建一个仓颉任务到主线程，future.get() 又在主线程等待，会造成死锁
    // ...
}
```

ArkTS 侧代码：

```javascript
import { testCJ } from "libohos_app_cangjie_entry.so"

@Entry
@Component
struct Index {
   // ...
   testCJ() // ArkTS 主线程中调用仓颉接口
   // ...
}
```

## 仓颉与 ArkTS 互操作逻辑要求在与 ArkTS 运行时绑定的系统线程上执行

**【规则】** 在仓颉调用 ArkTS 时，所有涉及 ArkTS 数据访问或接口调用的操作，需要运行在 ArkTS 运行时绑定的系统线程上。否则将触发 JSThreadMisMatch 异常。

仓颉线程是用户态线程，运行时会将仓颉线程调度到系统线程上执行，因此仓颉程序默认不会绑定在特定系统线程执行；而仓颉与 ArkTS 互操作逻辑要求运行在与 ArkTS 运行时绑定的系统线程上，因此开发者进行互操作时，需要关注互操作发生的线程，如果在非 ArkTS 线程，开发者需要使用互操作库提供的接口切换到 ArkTS 线程执行。开发者可以使用以下接口来保证互操作逻辑的正确执行：

- 使用 JSContext.isInBindThread() 判断当前线程是否可以执行互操作接口；
- 如需切换线程执行，可使用：
    - JSContext.postJSTask { ... } 创建在 ArkTS 线程执行的任务；
    - 如果 ArkTS 被部署在主线程上，开发者可以使用 spawn(UIThread) 语法使互操作逻辑所在线程被调度到主线程执行、

**错误示例：**

仓颉代码：

<!--compile.error-->
```cangjie
import ohos.ark_interop.*

func addNumberAsync(context: JSContext, callInfo: JSCallInfo): JSValue {
    // 从JSCallInfo获取参数列表
    let arg0: JSValue = callInfo[0]
    let arg1: JSValue = callInfo[1]
    let arg2: JSValue = callInfo[2]

    // 把JSValue转换为仓颉类型
    let a: Float64 = arg0.toNumber()
    let b: Float64 = arg1.toNumber()
    let callback = arg2.asFunction()

    // 新建仓颉线程
    spawn {
        // 实际仓颉函数行为
        let value = a + b
        // 创建result
        let result = context.number(value).toJSValue() // 错误：没有运行在ArkTS运行时绑定的系统线程上
        // 调用js回调
        callback.call(result)
    }

    // 返回 void
    return context.undefined().toJSValue()
}

let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports => exports["addNumberAsync"] = runtime.function(addNumberAsync).toJSValue()
}
```

**正确示例（isInBindThread & postJSTask 使用示例）：**

仓颉代码：

<!--compile-->
```cangjie
import ohos.ark_interop.*

func addNumberAsync(context: JSContext, callInfo: JSCallInfo): JSValue {
    // 从JSCallInfo获取参数列表
    let arg0: JSValue = callInfo[0]
    let arg1: JSValue = callInfo[1]
    let arg2: JSValue = callInfo[2]

    // 把JSValue转换为仓颉类型
    let a: Float64 = arg0.toNumber()
    let b: Float64 = arg1.toNumber()
    let callback = arg2.asFunction()

    // 新建仓颉线程
    spawn {
        // 实际仓颉函数行为
        let value = a + b
        if (context.isInBindThread()) { // 正确：如果当前线程为 ArkTS 运行时绑定的系统线程，可以直接同步调用
            // 创建result
            let result = context.number(value).toJSValue()
            // 调用js回调
            callback.call(result)
        } else {                        // 正确：否则使用 postJSTask 发起异步回调至 ArkTS 线程上执行
            context.postJSTask {
                // 创建result
                let result = context.number(value).toJSValue()
                // 调用js回调
                callback.call(result)
            }
        }
    }

    // 返回 void
    return context.undefined().toJSValue()
}

let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports => exports["addNumberAsync"] = runtime.function(addNumberAsync).toJSValue()
}
```

**正确示例（spawn(UIThread) 使用示例）：**

仓颉代码：

<!--compile-->
```cangjie
import ohos.ark_interop.*
import ohos.base.UIThread

func addNumberAsync(context: JSContext, callInfo: JSCallInfo): JSValue {
    // 从JSCallInfo获取参数列表
    let arg0: JSValue = callInfo[0]
    let arg1: JSValue = callInfo[1]
    let arg2: JSValue = callInfo[2]

    // 把JSValue转换为仓颉类型
    let a: Float64 = arg0.toNumber()
    let b: Float64 = arg1.toNumber()
    let callback = arg2.asFunction()

    // 新建仓颉线程
    spawn {
        // 实际仓颉函数行为
        let value = a + b
        spawn(UIThread) { // 正确：调度到 ArkTS 主线程上执行
            // 创建result
            let result = context.number(value).toJSValue()
            // 调用js回调
            callback.call(result)
        }
    }

    // 返回 void
    return context.undefined().toJSValue()
}

let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports => exports["addNumberAsync"] = runtime.function(addNumberAsync).toJSValue()
}
```

## 仓颉应用中只能在主线程上使用 JSRuntime() 创建 ArkTS 运行时

**【规则】** 仓颉应用中只能在主线程上使用 JSRuntime() 创建 ArkTS 运行时。

线程环境要求 JSRuntime 绑定一个系统线程，所有互操作接口只能在这个系统线程上调用，否则会出现未定义的行为。然而仓颉的线程与系统线程不是 1：1 绑定的关系，导致在仓颉 spawn 出来的仓颉线程里创建的 JSRuntime，在仓颉视角里为同步调用，而在 ArkTS 的视角里会出现线程切换，进而触发未定义行为或崩溃。因此限制只能在系统线程上创建 JSRuntime 而不能在仓颉线程里创建 JSRuntime。

**错误示例：**

仓颉代码：

<!--compile.error-->
```cangjie
import ohos.ark_interop.*

func addNumberAsync(context: JSContext, callInfo: JSCallInfo): JSValue {
    // 从JSCallInfo获取参数列表
    let arg0: JSValue = callInfo[0]
    let arg1: JSValue = callInfo[1]
    let arg2: JSValue = callInfo[2]

    // 把JSValue转换为仓颉类型
    let a: Float64 = arg0.toNumber()
    let b: Float64 = arg1.toNumber()
    let callback = arg2.asFunction()

    // 新建仓颉线程
    spawn {
        let runtime = JSRuntime() // 错误：只能在主线程上使用 JSRuntime() 创建 ArkTS 运行时
        // ...
    }

    // 返回 void
    return context.undefined().toJSValue()
}

let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports => exports["addNumberAsync"] = runtime.function(addNumberAsync).toJSValue()
}
```
