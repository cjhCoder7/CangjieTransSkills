# ohos.hi_trace_meter（性能打点）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

hi_trace_meter模块提供了跟踪进程轨迹，度量程序执行性能的打点能力。本模块打点的数据供hiTraceMeter工具分析使用。

> **说明**
>
> - 性能打点接口startTrace、finishTrace、traceByValue无法指定跟踪输出级别，默认均为COMMERCIAL级别性能打点。
>
> - 用户态trace格式使用竖线 | 作为分隔符，所以通过性能打点接口传递的字符串类型参数应避免包含该字符，防止trace解析异常。
>
> - 用户态trace总长度限制512字符，超过的部分将会被截断。

## 导入模块

```cangjie
import kit.PerformanceAnalysisKit.*
```

## 使用说明

API示例代码使用说明：

- 若示例代码首行有“// index.cj”注释，表示该示例可在仓颉模板工程的“index.cj”文件中编译运行。
- 若示例需获取[Context](../AbilityKit/cj-apis-app-ability-ui_ability.md#class-context)应用上下文，需在仓颉模板工程中的“main_ability.cj”文件中进行配置。

上述示例工程及配置模板详见[仓颉示例代码说明](../cj-development-intro.md#仓颉示例代码说明)。

## class HiTraceMeter

```cangjie
public class HiTraceMeter {}
```

**功能：** 该类提供了跟踪进程轨迹，度量程序执行性能的打点能力。

**系统能力：** SystemCapability.HiviewDFX.HiTrace

**起始版本：** 22

### static func finishTrace(String, Int32)

```cangjie
public static func finishTrace(name: String, taskId: Int32): Unit
```

**功能：** 标记一个预跟踪耗时任务的结束。

finishTrace的name和taskId必须与流程开始的[startTrace()](#static-func-starttracestring-int32)对应参数值一致。

**系统能力：** SystemCapability.HiviewDFX.HiTrace

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-|要跟踪的任务名称。|
|taskId|Int32|是|-|任务id。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

func f1(){
    HiTraceMeter.finishTrace("myTestFunc", 1)
}

func f2(){
    // 跟踪并行执行的同名任务
    HiTraceMeter.startTrace("myTestFunc", 1)
    // 业务流程代码
    HiTraceMeter.startTrace("myTestFunc", 2)  // 第二个跟踪的任务开始，同时第一个跟踪的同名任务还没结束，出现了并行执行，对应接口的taskId需要不同。
    // 业务流程代码
    HiTraceMeter.finishTrace("myTestFunc", 1)
    // 业务流程代码
    HiTraceMeter.finishTrace("myTestFunc", 2)
}

func f3(){
    // 跟踪串行执行的同名任务
    HiTraceMeter.startTrace("myTestFunc", 1)
    // 业务流程代码
    HiTraceMeter.finishTrace("myTestFunc", 1)  // 第一个跟踪的任务结束
    // 业务流程代码
    HiTraceMeter.startTrace("myTestFunc", 1)   // 第二个跟踪的同名任务开始，同名的待跟踪任务串行执行。
    // 业务流程代码
    HiTraceMeter.finishTrace("myTestFunc", 1)
}

try {
    f1()
    f2()
    f3()
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```

### static func startTrace(String, Int32)

```cangjie
public static func startTrace(name: String, taskId: Int32): Unit
```

**功能：** 标记一个异步跟踪耗时任务的开始。

如果有多个相同name的任务需要跟踪或者对同一个任务要跟踪多次，并且任务同时被执行，则开发者每次调用startTrace传入的taskId需不同。

如果具有相同name的任务是串行执行的，则taskId可以相同。具体示例可参考[finishTrace()](#static-func-finishtracestring-int32)中的示例。

**系统能力：** SystemCapability.HiviewDFX.HiTrace

**起始版本：** 22

**参数：**

|参数名|类型|必填|默认值|说明|
|:---|:---|:---|:---|:---|
|name|String|是|-|要跟踪的任务名称。|
|taskId|Int32|是|-|任务id。|

**示例：**

<!-- compile -->

```cangjie
// index.cj

import ohos.base.*
import kit.PerformanceAnalysisKit.*
import ohos.business_exception.BusinessException

try {
    HiTraceMeter.startTrace("myTestFunc", 1)
} catch (e: BusinessException) {
    Hilog.info(0, "test", "${e.message}")
}
```
