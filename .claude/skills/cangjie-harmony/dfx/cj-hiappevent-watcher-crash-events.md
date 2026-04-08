# 崩溃事件介绍

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

HiAppEvent提供接口用于订阅系统崩溃事件。

[订阅崩溃事件](./cj-hiappevent-watcher-crash-events-cangjie.md)

崩溃事件信息中params属性的详细描述如下：

**params属性：**

| 名称    | 类型   | 说明                       |
| ------- | ------ | ------------------------- |
| time     | Int32 | 事件触发时间，单位为毫秒。 |
| crash_type | String | 崩溃类型。支持CjError和NativeCrash两种崩溃类型。 |
| foreground | Bool | 应用是否处于前台状态。true表示处于前台状态；false表示处于后台状态。 |
| bundle_version | String | 应用版本。 |
| bundle_name | String | 应用名称。 |
| pid | Int32 | 应用的进程id。|
| uid | Int32 | 应用的用户id。 |
| uuid | String | 故障id。 |
| exception | Exception | 异常信息，详情请参见exception属性。exception只包含故障简要信息，具体的故障定位信息见external_log文件。 |
| hilog | Array\<String> | 日志信息，最多显示100行hilog日志，更多hilog日志通过故障日志文件获取。|
| threads | Array\<Thread> | 全量线程调用栈，详情请参见thread属性。仅NativeCrash类型的崩溃事件提供。 |
| external_log | Array\<String> | 故障日志文件路径。故障日志文件包括CPPCRASH，CjERROR。开发者可通过该路径下的文件，完成<!--RP1-->[CPPCRASH问题分析](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/dfx/cppcrash-guidelines.md)<!--RP1End-->及[CJERROR问题分析](./cj-cangjiecrash-guidelines.md)。**为避免目录空间超限（限制参考log_over_limit），导致新生成的日志文件写入失败，日志文件处理完后请及时删除。** |
| log_over_limit | Bool | 生成的故障日志文件与已存在的日志文件总大小是否超过5M上限。true表示超过上限，日志写入失败；false表示未超过上限。 |

**exception属性：**

| 名称    | 类型   | 说明                       |
| ------- | ------ | ------------------------- |
| name | String | 异常类型。 |
| message | String | 异常原因。 |
| stack | String | 异常调用栈。 |

**signal属性：**

| 名称    | 类型   | 说明                       |
| ------- | ------ | ------------------------- |
| signo | Int32 | 信号值(siginfo_t中的si_signo属性)。 |
| code | Int32 | 信号值二级分类（siginfo_t中的si_code属性）。 |
| address | String | 信号错误地址（siginfo_t中的si_address属性）。 |

详情请参见<!--RP2-->[CppCrash（进程崩溃）检测实现原理](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/dfx/cppcrash-guidelines.md)<!--RP2End-->。

**thread属性：**

| 名称    | 类型   | 说明                       |
| ------- | ------ | ------------------------- |
| thread_name | String | 线程名。 |
| tid | Int32 | 线程id。 |
| frames | Array\<Frame> | 线程调用栈，详情请参见frame属性。 |

**frame属性：**

| 名称    | 类型   | 说明                       |
| ------- | ------ | ------------------------- |
| file | String | 文件名。 |
| symbol | String | 函数名称。 |
| column | Int32 | 异常所在行。 |
| line | Int32 | 异常所在列。 |
