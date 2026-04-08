# 应用冻屏事件介绍

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

HiAppEvent提供接口用于订阅系统appfreeze事件。

[订阅应用冻屏事件](./cj-hiappevent-watcher-freeze-events-cangjie.md)

appfreeze事件信息中params属性的详细描述如下：

**params属性：**

| 名称    | 类型   | 说明                       |
| ------- | ------ | ------------------------- |
| time     | Int32 | 事件触发时间，单位为毫秒。 |
| foreground | Bool | 应用是否处于前台状态。true表示应用处于前台；false表示应用处于后台。|
| bundle_version | String | 应用版本。 |
| bundle_name | String | 应用名称。 |
| process_name | String | 应用的进程名称。 |
| pid | Int32 | 应用的进程id。|
| uid | Int32 | 应用的用户id。 |
| uuid | String | 故障id。 |
| exception | Exception | 异常信息，详情请参见exception属性。 |
| hilog | Array\<String> | 日志信息。|
| event_handler | Array\<String> | 主线程未处理消息。 |
| event_handler_size_3s | String | [THREAD_BLOCK_6S事件](./cj-appfreeze-guidelines.md#thread_block_6s-应用主线程执行停滞超时)（仅在该事件生效）中3s时任务栈中任务数。 |
| event_handler_size_6s | String | [THREAD_BLOCK_6S事件](./cj-appfreeze-guidelines.md#thread_block_6s-应用主线程执行停滞超时)（仅在该事件生效）中6s时任务栈中任务数。 |
| peer_binder | Array\<String> | binder调用信息。 |
| threads | Array\<Thread> | 全量线程调用栈，详情请参见thread属性。 |
| memory | Memory | 内存信息，详情请参见memory属性。 |
| external_log | Array\<String> | 故障日志文件路径。**为避免目录空间超限（限制参考log_over_limit），导致新生成的日志文件写入失败，日志文件处理完后请及时删除。** |
| log_over_limit | Bool | 生成的故障日志文件与已存在的日志文件总大小是否超过5M上限。true表示超过上限，日志写入失败；false表示未超过上限。 |

**exception属性：**

| 名称    | 类型   | 说明                       |
| ------- | ------ | ------------------------- |
| name | String | 异常类型。 |
| message | String | 异常原因。 |

**thread属性：**

| 名称    | 类型   | 说明                       |
| ------- | ------ | ------------------------- |
| thread_name | String | 线程名。 |
| tid | Int32 | 线程id。 |
| frames | Array\<Frame> | 线程调用栈，详情请参见frame属性。 |

**frame属性：**

| 名称    | 类型   | 说明                       |
| ------- | ------ | ------------------------- |
| symbol | String | 函数名称。 |
| file | String | 文件名。 |
| buildId | String | 文件唯一标识。 |
| pc | String | pc寄存器地址。 |
| offset | Int32 | 函数偏移量。 |

**memory属性：**

| 名称    | 类型   | 说明                       |
| ------- | ------ | ------------------------- |
| rss | Int32 | 进程实际占用内存大小，单位KB。 |
| vss | Int32 | 进程向系统申请的虚拟内存大小，单位KB。 |
| pss | Int32 | 进程实际使用的物理内存大小，单位KB。 |
| sys_free_mem | Int32 | 空闲内存大小，单位KB。 |
| sys_avail_mem | Int32 | 可用内存大小，单位KB。 |
| sys_total_mem | Int32 | 总内存大小，单位KB。 |
