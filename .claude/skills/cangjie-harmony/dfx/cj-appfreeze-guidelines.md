# 分析AppFreeze（应用无响应）

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

用户在使用应用时会出现点击没反应、应用无响应等情况，其超过一定时间限制后即被定义为应用无响应(appfreeze)。系统提供了检测应用无响应的机制，并生成appfreeze日志供应用开发分析。

> **说明：**
>
> 本文仅适用于Stage模型下的应用使用。且在根据本文分析日志前，需要开发者对Cangjie在系统中运行情况、C++程序堆栈信息有相关基础知识，并对应用相关的子系统有一定了解。

## 应用无响应检测能力点

目前应用无响应检测从以下维度检测，应用开发者了解其原理对定位和分析appfreeze故障非常有帮助。

| 故障类型 | 说明 |
| -------- | -------- |
| THREAD_BLOCK_6S | 应用主线程执行停滞超时。 |
| APP_INPUT_BLOCK | 用户输入响应超时。 |
| LIFECYCLE_TIMEOUT | Ability生命周期切换超时。 |

### THREAD_BLOCK_6S 应用主线程执行停滞超时

该故障出现表示当前应用主线程有执行停滞或者执行任务过多的情况，影响任务执行的流畅度和体验。

该事件的检测原理是：应用的watchdog线程定期向主线程插入判活检测，并在自己线程插入超时上报机制。当判活检测超过3s没有被执行，会上报THREAD_BLOCK_3S警告事件；超过6s依然没有被执行，会上报THREAD_BLOCK_6S主线程执行停滞事件。两个事件匹配生成THREAD_BLOCK的应用无响应日志。

检测原理如下图：

![thread_block](figures/thread_block.png)

### APP_INPUT_BLOCK 用户输入响应超时

该故障是指用户的点击事件超过一定时间限制未得到响应，严重影响当前用户体验。

该事件的检测原理是：用户点击应用的按钮时，输入系统会向应用侧发送点击事件，但超时未收到应用侧的响应反馈回执，则上报该故障。

检测原理如下图：

![app_input_block](figures/app_input_block.png)

### 生命周期切换超时

生命周期切换超时指的是[Ability生命周期](../application-models/cj-uiability-lifecycle.md)切换超时。

该故障出现在生命周期切换的过程中，影响当前应用内Ability的切换。

该事件的检测原理是：通过获取不同生命周期切换的过程，在生命周期切换开始的位置向watchdog线程插入超时任务，在生命周期切换完成之后移除超时任务，固定时间内未成功移除将上报故障。

生命周期切换超时由LIFECYCLE_HALF_TIMEOUT和LIFECYCLE_TIMEOUT两个事件组合而成。LIFECYCLE_HALF_TIMEOUT作为LIFECYCLE_TIMEOUT的警告事件，抓取binder等信息。

![appfreeze_lifecycle](figures/appfreeze_lifecycle.png)

不同的生命周期，超时的时间不一样：

| 生命周期 | 超时时间 |
| -------- | -------- |
| Load | 10s |
| Terminate | 10s |
| Connect | 3s |
| Disconnect | 0.5s |
| Foreground | 5s |
| Background | 3s |

## 应用无响应日志分析

应用无响应(appfreeze)故障需要结合应用无响应日志和流水hilog日志一起分析。

当前示例仅提供一个分析方法，请开发者根据具体问题具体分析。

### 日志头部信息

| 字段 | 说明 |
| -------- | -------- |
| Reason | 应用无响应原因，与[应用无响应检测能力点](#应用无响应检测能力点)对应。 |
| PID | 发生故障时候的pid，可以用于在流水日志中搜索相关进程信息。 |
| PACKAGE_NAME | 应用进程包名。 |

```text
============================================================
Device info:OpenHarmony 3.2
Build info:OpenHarmony 4.0.5.3
Module name:com.xxx.xxx
Version:1.0.0
Pid:1561
Uid:20010039
Reason:LIFECYCLE_TIMEOUT
sysfreeze:LIFECYCLE_TIMEOUT LIFECYCLE_TIMEOUT at 20230317170653
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
DOMAIN:AAFWK
STRINGID:LIFECYCLE_TIMEOUT
TIMESTAMP:2023/XX/XX/XX-XX:XX:XX:XX
PID:1561
UID:20010039
PACKAGE_NAME:com.xxx.xxx
PROCESS_NAME:com.xxx.xxx
MSG:ablity:EntryAbility background timeout
```

### 日志主干通用信息

以上三种日志都包含以下几部分信息，可以通过搜索“主要信息字段”在日志中找到对应的位置：

| 主要信息字段 | 说明 |
| -------- | -------- |
| EVENTNAME | 应用无响应原因，或者组成appfreeze检测的不同事件。 |
| TIMESTAMP | 发生故障时上报事件的时刻，可以根据[应用无响应检测能力点](#应用无响应检测能力点)中说明的超时时间，在相应流水日志中缩小查看日志的时间范围。 |
| PID | 发生故障时候的pid，可以与发生时间和超时时间配合用于在流水日志中搜索相关进程信息。 |
| PACKAGE_NAME | 应用进程包名。 |
| MSG | 发生故障时dump信息或者说明信息，后面具体说明。 |
| BinderCatcher | 进程与其他系统进程间通信的调用信息，显示调用等待时间长的情况。 |
| PeerBinder Stacktrace | 当前进程相关的对端进程有appfreeze，会抓取对端的进程堆栈。 |
| cpuusage | 当前时间段整机CPU使用情况。 |
| memory | 当前时间当前进程的内存使用情况。 |

> **说明：**
>
> 在整机高负载的情况下，采用低开销方式获取调用栈或抓栈超时的情况，可能损失函数符号和build-id信息。

MSG字段信息主要包括appfreeze上报的原因，以及当前应用主线程的队列中任务堆积信息。

主线程队列中任务堆积信息包括：

- 当前正在运行的任务以及任务启动的时间：如果跟当前日志上报的时间相差很大，则当前运行的任务就是appfreeze的主要任务事件。

- 历史任务时间：可判断是否由于历史任务过多且每一个任务执行都占一定时间，导致当前的新任务运行时无法及时响应。

- 堆积中还没有执行的任务。

**当前进程堆栈示例：**

通过搜索pid对应的数字找到应用栈信息。以下堆栈示例表明窗口通过IPC向系统发送事件时，停留在IPC通信阶段。

```text
OpenStacktraceCatcher -pid==1561 packageName is com.example.myapplication
Result: 0 ( no error )
Timestamp:2017-08-0817:06:53.000
Pid:1561
Uid:20010039
Process name:com.example.myapplication
Tid:1561,Name:i.myapplication
#00 pc 0017888c /system/lib/libark_jsruntime.so
#01 pc 00025779 /system/lib/platformsdk/libipc_core.z.so(OHOS:BinderConnector:WriteBinder(unsigned Long,void*)+56)
#02 pc 000265a5 /system/lib/platformsdk/libipc_core.z.so(OHOS:BinderInvoker:TransactWithDriver(bool)+216)
#03 pc 0002666f /system/lib/platformsdk/libipc_core.z.so(OHOS:BinderInvoker:StartWorkLoop()+18)
#04 pc 000270a9 /system/lib/platformsdk/libipc_core.z.so(OHOS:BinderInvoker:JoinThread(bool)+32)
#05 pc 00023783 /system/lib/platformsdk/libipc_core.z.so(OHOS:IPCWorkThread:ThreadHandler(void*)+290)
#06 pc 00e1c6f7 /system/lib/libace.z.so
#07 pc 0091bbdd /system/lib/libace.z.so
#08 pc 0092fd9d /system/lib/libace.z.so
#09 pc 0092fa5f /system/lib/libace.z.so
#10 pc 0092cd6b /system/lib/libace.z.so
#11 pc 009326a9 /system/lib/libace.z.so
#12 pc 0093054b /system/lib/libace.z.so
#13 pc 009324f3 /system/lib/libace.z.so
#14 pc 003989e1 /system/lib/libace.z.so
#15 pc 0045dd4b /system/lib/libace.z.so
#16 pc 00d24fef /system/lib/libace.z.so
#17 pc 0041e6e9 /system/lib/libace.z.so
#18 pc 0000b4d9 /system/lib/platformsdk/libeventhandler.z.so(OHOS:AppExecFwk:EventHandler:DistributeEvent(std::__h:unique_ptr<0 #19 pc 00012829 /system/lib/platformsdk/libeventhandler.z.so))
#20 pc 00011841 /system/lib/platformsdk/libeventhandler.z.so(OHOS:AppExecFwk:EventRunner:Run()+64)
#21 pc 00054a8b /system/lib/libappkit_native.z.so(OHOS:AppExecFwk:MainThread:Start()+278)
#22 pc 00011503 /system/bin/appspawn
#23 pc 0001141f /system/bin/appspawn
#24 pc 0000ee97 /system/bin/appspawn
```

**BinderCatcher信息示例：**

通过搜索pid对应的数字找到当前进程与哪个进程在通信，同步的通信等待的时长。

示例表明当前1561进程向685进程请求通信，等待超过10s没有得到响应。

```text
PeerBinderCatcher -pid==1561 Layer_==0

BinderCatcher --
    1561:1561 to 685:0 code 0 wait:10.366245919 s
    1329:1376 to 487:794 code 0 wait:0.12070041 s

pid   context  request  started  max  ready free_async_space
1561   binder    0       3       16     4       520192
544    binder    0       4       16     5       520192
1104   binder    0       1       16     2       520192
1397   binder    0       1       16     3       520192
...
```

**PeerBinder Stacktrace信息示例：**

示例表明对端appfreeze进程685的堆栈信息。

```text
PeerBinder Stacktrace --

PeerBinderCatcher start catcher stacktrace for pid 685
Result: 0 ( no error )
Timestamp:2017-08-0817:06:55.000
Pid:685
Uid:1000
Process name:wifi_manager_service
Tid:658,Name:wifi_manager_service
#00 pc 000669f0 /system/lib/ld-musl-arm.so.1
#01 pc 000c60cc /system/lib/ld-musl-arm.so.1
#02 pc 000c5040 /system/lib/ld-musl-arm.so.1
#03 pc 000c6818 /system/lib/ld-musl-arm.so.1(__pthread_cond_timedwait_time64+596)
#04 pc 000bd058 /system/lib/libc++.so
#05 pc 0008592c /system/lib/ld-musl-arm.so.1(ioctl+72)
#06 pc 00025779 /system/lib/platformsdk/libipc_core.z.so(OHOS:BinderConnector:WriteBinder(unsigned long,void*)+56)
#07 pc 000265a5 /system/lib/platformsdk/libipc_core.z.so(OHOS:BinderInvoker:TransactWithDriver(bool)+216)
#08 pc 0002666f /system/lib/platformsdk/libipc_core.z.so(OHOS:BinderInvoker:StartWorkLoop()+18)
#09 pc 000270a9 /system/lib/platformsdk/libipc_core.z.so(OHOS:BinderInvoker:JoinThread(bool)+32)
#10 pc 00023783 /system/lib/platformsdk/libipc_core.z.so(OHOS:IPCWorkThread:ThreadHandler(void*)+290)
#11 pc 0007b4d9 /system/lib/platformsdk/libeventhandler.z.so
#12 pc 00072829 /system/lib/platformsdk/libeventhandler.z.so
#13 pc 00071841 /system/lib/platformsdk/libeventhandler.z.so(OHOS:AppExecFwk:EventRunner:Run()+64)
#14 pc 00094a8b /system/lib/libappkit_native.z.so(OHOS:AppExecFwk:MainThread:Start()+278)

Tid:1563,Name:IPC_0_1563
#00 pc 0009392c /system/lib/ld-musl-arm.so.1(ioctl+72)
#01 pc 00025779 /system/lib/platformsdk/libipc_core.z.so(OHOS:BinderConnector:WriteBinder(unsigned long,void*)+56)
```

**cpuusage信息示例：**

整机CPU信息。

```text
Load average: 2.87 / 1.45 / 0.58; the cpu load average in 1 min,5 min and 15 min
CPU usage from 2023-03-10 17:06:53 to 2023-03-10 17:06:53
Total: 29%; User Space: 28%; Kernel Space: 1%; iowait: 6%; irq: 0%; idle: 62%
Details of Processes:
    PID     Total Usage     User Space     Kernel Space     Page Fault Minor     Page Fault Major      Name
    1561       23%            23%              0%               9985                  26            i.myapplication
    527        1%             1%               0%               3046                  9             hidumper_servic
    242        1%             1%               0%               69799                 280           hiview
```

**memory信息示例：**

当前进程内存信息。

```text
-------------------------------------------[memory]----------------------------------------
                 Pss      Shared   Shared   Private  Private   Swap   SwapPss   Heap  Heap
                 Total    CLean    Dirty    CLean    Dirty     Total  Total     Size  Alloc
                 (kB)     (kB)     (kB)     (kB)      (kB)     (kB)    (kB)     (kB)  (kB)
-------------------------------------------------------------------------------------------
guard             0        0         0       0         0         0      0        0      0
native heap      185       0        180      0        160        0      0        0      0
AnonPage other   17881    12        12376    88       15948      0      0        0      0
stack            292       0        0        0        292        0      0        0      0
.S0              5053     63408     4172     1812     2640       0      0        0      0
.ttf             1133     3092      0        4        0          0      0        0      0
dev              10       0         108      8        0          0      0        0      0
FilePage other   121      556       8        0        4          0      0        0      0
------------------------------------------------------------------------------------------
Total            34675    67068     16844    1912     19044      0      0        0      0
```

### 日志主干特异性信息(应用主线程appfreeze超时)

Reason是THREAD_BLOCK_6S的日志。根据前面的[应用主线程appfreeze超时](#thread_block_6s-应用主线程执行停滞超时)的原理可知，THREAD_BLOCK由THREAD_BLOCK_3S和THREAD_BLOCK_6S两部分组成。将两部分日志对比分析，可更准确的判断是appfreeze还是执行任务过多造成无法响应的情况。

THREAD_BLOCK_3S在日志的前部分，THREAD_BLOCK_6S在THREAD_BLOCK_3S后面写入。可以通过EVENTNAME字段搜索两个事件在日志中的位置。

两个事件中都包含MSG字段，该字段在应用主线程appfreeze超时故障中写入了当前主线程处理队列的信息，可查看在两个时间点中主线程事件处理队列排队情况。

示例日志显示了在Low priority的队列中05:06:18.145的事件一直在处理，THREAD_BLOCK_3S和THREAD_BLOCK_6S的队列都显示其存在。这说明主线程appfreeze不是任务过多情况。

由于THREAD_BLOCK_6S是主线程appfreeze，进程堆栈信息只需要关注主线程的堆栈(主线程线程号跟进程号相同)。当前示例日志主线程堆栈显示通过ArkUI控件到CJ运行，说明appfreeze在CJ代码中。3S和6S都是这个位置的堆栈，说明CJ有appfreeze，但原因排除任务过多导致。

THREAD_BLOCK_3S：

```text
start time:2017/08/08-17:06:24:380
DOMAIN = AAFWK EVENTNAME THREAD_BLOCK_3S
TIMESTAMP = 2017/08/08-17:06:24:363
PID = 1561
UID = 20010039
TID = 1566
PACKAGE_NAME com.example.myapplication
PROCESS_NAME com.example.myapplication
eventLog_action pb:1 eventLog_interval 10
MSG = App main thread is not response!EventHandler dump begin curTime:2017-08-08 05:06:24.362
  Event runner (Thread name =Thread ID 1561)is running
  Current Running:start at 2017-08-08 05:06:18.145,Event send thread 1561,send time =2017-08-08 05:06:18.145,handle time =2017-08-08 05:
  Immediate priority event queue information:
  Total size of Immediate events 0
  High priority event queue information:
  No.1 Event send thread 1561,send time 2017-08-08 05:06:18.039,handle time 2017-08-08 05:06:21.539,task name [anr_handler.cpp(Send Total size of High events 1)]
  Low priority event queue information:
  No.1:Event{send thread=1566,send time=2017-08-0805:06:21.062,handle time=2017-08-0805:06:21.062,id=1}
  Total size of Low events 1
  Idle priority event queue information:
  Total size of Idle events 0
  Total event size :2

 Timestamp: 2017-08-0817:06:24.4142447784
 Pid: 1561
 Uid: 20010039
 Process name: com.example.myapplication
 Tid:1561 Name:i.myapplication
   at anonymous entry (D:/project/MyApplication_test/entry/build/default/intermediates/loader_out/default/ets,pages/Index_.js:0:1)
   #00 pc 0017909c /system/lib/libark_jsruntime.so
   #01 pc 00177ebb /system/lib/libark_jsruntime.so
   #02 pc 0024b4bb /system/lib/libark_jsruntime.so
   #03 pc 00fbed23 /system/lib/libace.z.so
   #04 pc 00d8208f /system/lib/libace.z.so
   ...
```

THREAD_BLOCK_6S：

```text
start time: 2017/08/08-17:06:27:299
DOMAIN = AAFWK
EVENTNAME THREAD_BLOCK_6S
TIMESTAMP = 2017/08/08-17:06:27:292
PID = 1561
UID = 20010039
TID = 1566
PACKAGE_NAME com.example.myapplication
PROCESS NAME com.example.myapplication eventLog_action cmd:c,cmd:m,tr,k:SysRqFile
eventLog_interval 10
MSG = App main thread is not response!EventHandler dump begin curTime:2017-08-08 05:06:27.291
  Event runner (Thread name =Thread ID =1561)is running
  Current Running:start at 2017-08-08 05:06:18.144, Event {send thread 1561,send time =2017-08-08 05:06:18.145,handle time =2017-08-08 05:
  Immediate priority event queue information:
  Total size of Immediate events 0
  High priority event queue information:
  No.1 Event send thread 1561,send time 2017-08-08 05:06:18.039,handle time 2017-08-08 05:06:21.539,task name [arr_handler.cpp(Se Total size of High events 1
  Low priority event queue information:
  No.1:Event{send thread=1566,send time=2017-08-0805:06:21.062,handle time=2017-08-0805:06:21.062,id=1}
  No.2 Event send thread 1566,send time 2017-08-08 05:06:24.369,handle time 2017-08-08 05:06:24.369,id =1
  Total size of Low events 2
  Idle priority event queue information:
  Total size of Idle events 0
  Total event size 3

Timestamp:2017-08-0817:0k:27,4142447784
Pid:1561
Uid:20010039
Process name:com.example.myapplication
Tid:1561 Name:i.myapplication
  at anonymous entry (D:/project/MyApplication_test/entry/build/default/intermediates/loader_out/default/ets/pages/Index_.js:0:1)
  #00 pc 00178dcc /system/lib/libark_jsruntime.so
  #01 pc 00177ebb /system/lib/libark_jsruntime.so
  #02 pc 0024b4bb /system/lib/libark_jsruntime.so(panda:FunctionRef:Call(panda:ecmascript:EcmaVM const*,panda:Local<panda:JSValueRef>,par
  #03 pc 00fbed23 /system/lib/libace.z.so
  #04 pc 00d8208f /system/lib/libace.z.so
  #05 pc 00d7af1b /system/lib/libace.z.so
```

再结合流水日志查看当前应用侧是在执行哪块代码。

一般情况下可以查看以上[通用日志信息](#日志主干通用信息)内容，判断是否存在对端通信appfreeze，整机CPU消耗很高导致当前应用响应不过来，内存泄漏，内存非常多导致任务无法运行的情况。

### 日志主干特异性信息(用户输入响应超时)

Reason是APP_INPUT_BLOCK，表明用户点击事件超过5s没有得到反馈。

MSG信息是这个事件的说明：用户的输入没有得到响应。

APP_INPUT_BLOCK的日志信息请参见[通用日志信息](#日志主干通用信息)进行分析。需特别说明的是，一般情况下用户输入无响应大概率主线程也会appfreeze。可以结合两个日志的三个堆栈、两个BinderCatcher信息，进行对比查看。如果没有主线程appfreeze的日志，说明有可能在输入事件之前有大量的细碎的其他事件，细碎的事件不足以导致主线程appfreeze，但是数量比较多导致用户的输入事件响应不过来。

### 日志主干特异性信息(生命周期切换超时)

Reason是LIFECYCLE_TIMEOUT的日志与上文THREAD_BLOCK_6S和THREAD_BLOCK_3S一样都是有两个事件。分别是LIFECYCLE_HALF_TIMEOUT和LIFECYCLE_TIMEOUT。

MSG说明当前是什么生命周期的超时。

示例可以看出，LIFECYCLE_TIMEOUT的可以看出Ability在切换后台的时候超时，可以按照上面[生命周期切换超时](#生命周期切换超时)的超时时间来找流水日志等信息。

LIFECYCLE_TIMEOUT：

```text
DOMAIN:AAFWK
STRINGID:LIFECYCLE
TIMEOUT TIMESTAMP:2023/03/10-17:06:53:65
PID:1561
UID:20010039
PACKAGE_NAME:com.example.myapplication
PROCESS_NAME:com.example.myapplication
MSG:ability:EntryAbility background timeout
```

其他的日志信息请参见[通用日志信息](#日志主干通用信息)进行分析。需要特别说明的是，一般情况下生命周期切换大概率主线程也会appfreeze。可以结合两个日志的三个堆栈、两个BinderCatcher信息，进行对比查看。

## 应用退出

当应用发生以下故障时，为了保证可恢复，会杀死应用。

| 故障类型 | 说明 |
| -------- | -------- |
| THREAD_BLOCK_6S | 应用主线程appfreeze超时。 |
| APP_INPUT_BLOCK | 用户输入响应超时。 |
| LIFECYCLE_TIMEOUT | Ability生命周期切换超时。 |

## 定位步骤与思路

定位应用无响应问题，首先需要开发者获取相关日志，再通过日志记录的问题基本信息，结合hilog日志和trace来定位出无响应问题的发生的具体位置。

### 获取日志

应用无响应日志是一种故障日志，与Native进程崩溃、cj应用崩溃、系统进程异常等都由FaultLog模块管理，可通过以下方式获取日志：

- 方式一：通过DevEco Studio获取日志。

    DevEco Studio会收集设备的故障日志并归档到FaultLog下。

- 方式二：通过hiAppEvent接口订阅。

    hiAppEvent 提供了故障订阅接口，可以订阅各类故障打点，详情请参见[HiAppEvent介绍](./cj-hiappevent-intro.md)。

<!--Del-->

- 方式三：设备ROOT模式下通过shell获取日志。

    应用无响应日志以appfreeze-开头，生成在设备“/data/log/faultlog/faultlogger/”路径下。文件名格式为“appfreeze-应用包名-应用UID-毫秒级时间.log”。

    ![appfreeze_12](figures/appfreeze_12.png)

<!--DelEnd-->

### 确认基本信息

#### 获取直接导致应用appfreeze的进程号，是否处于前台等基础信息

```text
Generated by HiviewDFX@OpenHarmony
============================================================
Device info:HUANEI Mate 60 Pro
Build info:ALN-AL00 x.x.x.xx(XXXXXXX)
Fingerprint:ef8bd28f8b57b54656d743b546efa73764c77866a65934bd96f2678f886813b7
Module name:com.xxx.xxx
Version:1.2.2.202
VersionCode:1002002202
PreInstalled:Yes
Foreground:No   --> 是否处于前台
Pid:15440
Uid:20020029
Reason:THREAD BLOCK 6S
appfreeze: com.xxx.xxx THREAD_BLOCK 6S at 20240410164052
DisplayPowerInfo:powerState: AWAKE
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```

#### 获取故障发生时间点

故障上报时间点。

```text
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
DOMAIN:AAFWK
STRINGID: THREAD BLOCK 6S
TIMESTAMP: 2024/04/10-16:40:52:743   --> 故障上报时间戳
PID:15440
UID:20020029
PACKAGE NAME:com.xxx.xxx
PROCESS NAME:com.xxx.xxx
****************************************
```

不同故障类型的不同场景下的检测时长汇总表格。

| THREAD_BLOCK_6S |APP_INPUT_BLOCK|LIFECYCLE_TIMEOUT|
| -------- |--------|--------|
|前台应用：6s <br> 后台应用 ：3s * 5 + 6s = 21s | 5s | Load：10s <br> Active：5s <br> Inactive：0.5s <br> Terminate：10s <br> Connect：3s <br> Disconnect：0.5s <br> Restart：5s <br> Foreground：5s <br> Background：3s |

> **说明：**
>
> - THREAD_BLOCK_3S / LIFECYCLE_HALF_TIMEOUT 的检测时长是相应THREAD_BLOCK_6S / LIFECYCLE_TIMEOUT的一半，warning 级别，不会单独上报日志；THREAD_BLOCK_6S / LIFECYCLE_TIMEOUT 是 error 级别，整合了本身和其一半检测时长故障的日志一同上报；
> - 前台应用发生THREAD_BLOCK_3S后即可触发后续THREAD_BLOCK_6S事件；
> - 后台应用存在计数器 backgroundReportCount_= 0，发生THREAD_BLOCK_3S后 +1 累计到 5 次后才会上报 （即连续发生5次 THREAD_BLOCK_3S 事件，计数不清零，才会上报THREAD_BLOCK_6S 事件，可知后台应用THREAD_BLOCK_3S 与THREAD_BLOCK_6S 检测时长依次为 18s 与 21s。

通过故障上报时间点往前推检测时长可得到故障发生的具体时间。

### 查看 eventHandler 信息

开发者可以通过 “mainHandler dump is” 关键字搜索日志中的 eventHandler dump 信息。

1. dump begin curTime & Current Running。

    ```text
    mainHandler dump is:
    EventHandler dump begin curTime: 2024-08-08 12:17:43.544      --> 开始 dump 时间
    Event runner (Thread name = , Thread ID = 35854) is running   --> 正在运行的线程信息
    Current Running: start at 2024-08-08 12:17:16.629, Event { send thread = 35882, send time = 2024-08-08 12:17:16.628,  handle time = 2024-08-08 12:17:16.629, trigger time = 2024-08-08 12:17:16.630, task name = , caller = xx }  
    --> trigger time--> 任务开始运行的时间
    ```

    当前任务运行时长 = dump begin curTime - trigger time, 如示例中当前任务运行达到27s。

    若任务运行时长 > 故障检测时长，表示当前正在运行的任务是导致应用appfreeze的任务，需对该任务进行排查。

    若任务运行时长较小，表示当前任务仅是检测时间区间内主线程运行的任务之一，主要耗时不一定是该任务，建议优先查看近期耗时最长任务（History event queue information中）。该情形多为线程繁忙导致的watchdog无法调度执行。

2. History event queue information。

    ```text
    Current Running: start at 2024-08-08 12:17:16.629, Event { send thread = 35882, send time = 2024-08-08 12:17:16.628, handle time = 2024-08-08 12:17:16.629, trigger time = 2024-08-08 12:17:16.630, task name = , caller = [extension_ability_thread.cpp(ScheduleAbilityTransaction:393)]}
    History event queue information:
    No. 0 : Event { send thread = 35854, send time = 2024-08-08 12:17:15.525, handle time = 2024-08-08 12:17:15.525, trigger time = 2024-08-08 12:17:15.527, completeTime time = 2024-08-08 12:17:15.528, priority = High, id = 1 }
    No. 1 : Event { send thread = 35854, send time = 2024-08-08 12:17:15.525, handle time = 2024-08-08 12:17:15.525, trigger time = 2024-08-08 12:17:15.527, completeTime time = 2024-08-08 12:17:15.527, priority = Low, task name = MainThread:SetRunnerStarted }
    No. 2 : Event { send thread = 35856, send time = 2024-08-08 12:17:15.765, handle time = 2024-08-08 12:17:15.765, trigger time = 2024-08-08 12:17:15.766, completeTime time = 2024-08-08 12:17:15.800, priority = Low, task name = MainThread:LaunchApplication }
    No. 3 : Event { send thread = 35856, send time = 2024-08-08 12:17:15.767, handle time = 2024-08-08 12:17:15.767, trigger time = 2024-08-08 12:17:15.800, completeTime time = 2024-08-08 12:17:16.629, priority = Low, task name = MainThread:LaunchAbility }
    No. 4 : Event { send thread = 35854, send time = 2024-08-08 12:17:15.794, handle time = 2024-08-08 12:17:15.794, trigger time = 2024-08-08 12:17:16.629, completeTime time = 2024-08-08 12:17:16.629, priority = IDEL, task name = IdleTime:PostTask }
    No. 5 : Event { send thread = 35852, send time = 2024-08-08 12:17:16.629, handle time = 2024-08-08 12:17:16.629, trigger time = 2024-08-08 12:17:16.629, completeTime time = , priority = Low, task name =  }
    ```

    可以从历史任务队列中寻找故障发生时间区间内较为耗时的任务。其中CompleteTime time 为空的任务是当前任务。

    任务运行耗时 = CompleteTime time - trigger time。

    筛选出耗时较高的任务，排查其运行情况。

3. VIP priority event queue information。

    ```text
    VIP priority event queue information:
    No. 1 : Event { send thread = 3205, send time = 2024-08-07 04:11:15.407, handle time = 2024-08-07 04:11:15.407, task name = ArkUIWindowInjectPointerEvent, caller = [task_runner_adapter_impl.cpp(PostTask:33)]}
    No. 2 : Event { send thread = 3205, send time = 2024-08-07 04:11:15.407, handle time = 2024-08-07 04:11:15.407, task name = ArkUIWindowInjectPointerEvent, caller = [task_runner_adapter_impl.cpp(PostTask:33)]}
    No. 3 : Event { send thread = 3205, send time = 2024-08-07 04:11:15.407, handle time = 2024-08-07 04:11:15.407, task name = ArkUIWindowInjectPointerEvent, caller = [task_runner_adapter_impl.cpp(PostTask:33)]}
    No. 4 : Event { send thread = 3961, send time = 2024-08-07 04:11:15.408, handle time = 2024-08-07 04:11:15.408, task name = MMI::OnPointerEvent, caller = [input_manager_impl.cpp (OnPointerEvent:493)]}
    No. 5 : Event { send thread = 3205, send time = 2024-08-07 04:11:15.408, handle time = 2024-08-07 04:11:15.408, task name = ArkUIWindowInjectPointerEvent, caller = [task_runner_adapter_impl.cpp(PostTask:33)]}
    No. 6 : Event { send thread = 3205, send time = 2024-08-07 04:11:15.409, handle time = 2024-08-07 04:11:15.409, task name = ArkUIWindowInjectPointerEvent, caller = [task_runner_adapter_impl.cpp(PostTask:33)]}
    No. 7 : Event { send thread = 3205, send time = 2024-08-07 04:11:15.409, handle time = 2024-08-07 04:11:15.409, task name = ArkUIWindowInjectPointerEvent, caller = [task_runner_adapter_impl.cpp(PostTask:33)]}
    No. 8 : Event { send thread = 3205, send time = 2024-08-07 04:11:15.409, handle time = 2024-08-07 04:11:15.409, task name = ArkUIWindowInjectPointerEvent, caller = [task_runner_adapter_impl.cpp(PostTask:33)]}
    No. 9 : Event { send thread = 3205, send time = 2024-08-07 04:11:15.410, handle time = 2024-08-07 04:11:15.410, task name = ArkUIWindowInjectPointerEvent, caller = [task_runner_adapter_impl.cpp(PostTask:33)]}
    ...
    ```

    为保障第一时间响应用户，用户输入事件传递链中的任务都属于高优先级任务。此任务事件队列均由系统创建，通常记录用户输入->屏幕->窗口->ArkUI->应用的传输过程，与三方应用事件无关，开发者无需额外关注。

4. High priority event queue information。

    ```text
    High priority event queue information:
    No. 1 : Event { send thread = 35862, send time = 2024-08-08 12:17:25.526, handle time = 2024-08-08 12:17:25.526, id = 1, caller = [watchdog.cpp(Timer:156)]}
    No. 2 : Event { send thread = 35862, send time = 2024-08-08 12:17:28.526, handle time = 2024-08-08 12:17:28.526, id = 1, caller = [watchdog.cpp(Timer:156)]}
    No. 3 : Event { send thread = 35862, send time = 2024-08-08 12:17:31.526, handle time = 2024-08-08 12:17:31.526, id = 1, caller = [watchdog.cpp(Timer:156)]}
    No. 4 : Event { send thread = 35862, send time = 2024-08-08 12:17:34.530, handle time = 2024-08-08 12:17:34.530, id = 1, caller = [watchdog.cpp(Timer:156)]}
    No. 5 : Event { send thread = 35862, send time = 2024-08-08 12:17:37.526, handle time = 2024-08-08 12:17:37.526, id = 1, caller = [watchdog.cpp(Timer:156)]}
    No. 6 : Event { send thread = 35862, send time = 2024-08-08 12:17:40.526, handle time = 2024-08-08 12:17:40.526, id = 1, caller = [watchdog.cpp(Timer:156)]}
    No. 7 : Event { send thread = 35862, send time = 2024-08-08 12:17:43.544, handle time = 2024-08-08 12:17:43.544, id = 1, caller = [watchdog.cpp(Timer:156)]}
    Total size of High events : 7
    ```

    watchdog 任务位于此优先级队列中，观察 watchdog 任务队列发现其是每隔 3s 发送一次。

    对比 warning/block 事件，观察 watchdog 任务在队列中的移动情况。

    warning:

    ```text
    High priority event queue information:
    No. 1 : Event { send thread = 35862, send time = 2024-08-08 12:17:25.526, handle time = 2024-08-08 12:17:25.526, id = 1, caller = [watchdog.cpp(Timer:156)]}
    No. 2 : Event { send thread = 35862, send time = 2024-08-08 12:17:28.526, handle time = 2024-08-08 12:17:28.526, id = 1, caller = [watchdog.cpp(Timer:156)]}
    No. 3 : Event { send thread = 35862, send time = 2024-08-08 12:17:31.526, handle time = 2024-08-08 12:17:31.526, id = 1, caller = [watchdog.cpp(Timer:156)]}
    No. 4 : Event { send thread = 35862, send time = 2024-08-08 12:17:34.530, handle time = 2024-08-08 12:17:34.530, id = 1, caller = [watchdog.cpp(Timer:156)]}
    Total size of High events : 4
    ```

    block:

    ```text
    High priority event queue information:
    No. 1 : Event { send thread = 35862, send time = 2024-08-08 12:17:25.526, handle time = 2024-08-08 12:17:25.526, id = 1, caller = [watchdog.cpp(Timer:156)]}
    No. 2 : Event { send thread = 35862, send time = 2024-08-08 12:17:28.526, handle time = 2024-08-08 12:17:28.526, id = 1, caller = [watchdog.cpp(Timer:156)]}
    No. 3 : Event { send thread = 35862, send time = 2024-08-08 12:17:31.526, handle time = 2024-08-08 12:17:31.526, id = 1, caller = [watchdog.cpp(Timer:156)]}
    No. 4 : Event { send thread = 35862, send time = 2024-08-08 12:17:34.530, handle time = 2024-08-08 12:17:34.530, id = 1, caller = [watchdog.cpp(Timer:156)]}
    No. 5 : Event { send thread = 35862, send time = 2024-08-08 12:17:37.526, handle time = 2024-08-08 12:17:37.526, id = 1, caller = [watchdog.cpp(Timer:156)]}
      Total size of High events : 5
    ```

    以上示例中可发现 block 队列相比于 warning 队列更长了，而对应的第一个任务没有发生变化，可能存在两种情况：

    - 当前正在运行的任务appfreeze，导致其他任务一直未被调度执行；
    - 更高优先级队列中任务堆积，导致位于较低优先级队列中的 watchdog 任务未被调度执行。

### 查看 stack 信息

通过得到的 Pid、Tid 查看对应的 stack，存在以下几种情况：

1. 有明确appfreeze堆栈信息。

    ```text
    Tid:3025, Name: xxx
    # 00 pc 00000000001b4094 /system/lib/ld-musl-aarch64.so.1(__timedwait_cp+188)(b168f10a179cf6050a309242262e6a17)
    # 01 pc 00000000001b9fc8 /system/lib/ld-musl-aarch64.so.1(__pthread_mutex_timedlock_inner+592)(b168f10a179cf6050a309242262e6a17)
    # 02 pc 00000000000c3e40 /system/lib64/libc++.so(std::__h::mutex::lock()+8)(9cbc937082b3d7412696099dd58f4f78242f9512) --> 等锁appfreeze
    # 03 pc 000000000007ac4c /system/lib64/platformsdk/libnative_rdb.z.so(OHOS::NativeRdb::SqliteConnectionPool::Container::Release(std::__h::shared_ptr<OHOS::NativeRdb::SqliteConnectionPool::ConnNode>)+60)(5e8443def4695e8c791e5f847035ad9f)
    # 04 pc 000000000007aaf4 /system/lib64/platformsdk/libnative_rdb.z.so(OHOS::NativeRdb::SqliteConnectionPool::ReleaseNode(std::__h::shared_ptr<OHOS::NativeRdb::SqliteConnectionPool::ConnNode>)+276)(5e8443def4695e8c791e5f847035ad9f)
    # 05 pc 000000000007a8c0 /system/lib64/platformsdk/libnative_rdb.z.so(5e8443def4695e8c791e5f847035ad9f)
    # 06 pc 00000000000b36ec /system/lib64/platformsdk/libnative_rdb.z.so(OHOS::NativeRdb::SqliteSharedResultSet::Close()+324)(5e8443def4695e8c791e5f847035ad9f)
    # 07 pc 000000000006da94 /system/lib64/module/data/librelationalstore.z.so(OHOS::RelationalStoreJsKit::ResultSetProxy::Close(napi_env__*, napi_callback_info__*) (.cfi)+212)(5c7c67512e12e0e53fd23e82ee576a88)
    # 08 pc 0000000000034408 /system/lib64/platformsdk/libace_napi.z.so(panda::JSValueRef ArkNativeFunctionCallBack<true>(panda::JsiRuntimeCallInfo*)+220)(f271f536a588ef9d0dc5328c70fce511)
    # 09 pc 00000000002d71d0 /system/lib64/module/arkcompiler/stub.an(RTStub_PushCallArgsAndDispatchNative+40)
    # 10 at parseResultSet (entry/build/default/cache/default/default@CompileArkTS/esmodule/release/datamanager/datawrapper/src/main/ets/database/RdbManager.ts:266:1)
    # 11 at query (entry/build/default/cache/default/default@CompileArkTS/esmodule/release/datamanager/datawrapper/src/main/ets/database/RdbManager.ts:188:1)
    ```

    所以明确等锁appfreeze，通过反编译获取对应代码行，排查代码上下文解决问题。

2. 卡在 ipc 请求。

    ```text
    Tid:53616, Name:xxx
    # 00 pc 0000000000171c1c /system/lib/ld-musl-aarch64.so.1(ioctl+176)(b168f10a179cf6050a309242262e6a17)
    # 01 pc 0000000000006508 /system/lib64/chipset-pub-sdk/libipc_common.z.so(OHOS::BinderConnector::WriteBinder(unsigned long, void*)+100)(1edec25445c569dd1093635c1da3bc0a) --> binder appfreeze
    # 02 pc 000000000004d500 /system/lib64/platformsdk/libipc_core.z.so(OHOS::BinderInvoker::TransactWithDriver(bool)+296)(6151eca3b47aa2ab3e378e6e558b90f3)
    # 03 pc 000000000004c6c0 /system/lib64/platformsdk/libipc_core.z.so(OHOS::BinderInvoker::WaitForCompletion(OHOS::MessageParcel*, int*)+128)(6151eca3b47aa2ab3e378e6e558b90f3)
    # 04 pc 000000000004c304 /system/lib64/platformsdk/libipc_core.z.so(OHOS::BinderInvoker::SendRequest(int, unsigned int, OHOS::MessageParcel&, OHOS::MessageParcel&, OHOS::MessageOption&)+348)(6151eca3b47aa2ab3e378e6e558b90f3)
    # 05 pc 00000000000319ac /system/lib64/platformsdk/libipc_core.z.so(OHOS::IPCObjectProxy::SendRequestInner(bool, unsigned int, OHOS::MessageParcel&, OHOS::MessageParcel&, OHOS::MessageOption&)+124)(6151eca3b47aa2ab3e378e6e558b90f3)
    # 06 pc 0000000000031cfc /system/lib64/platformsdk/libipc_core.z.so(OHOS::IPCObjectProxy::SendRequest(unsigned int, OHOS::MessageParcel&, OHOS::MessageParcel&, OHOS::MessageOption&)+184)(6151eca3b47aa2ab3e378e6e558b90f3)
    # 07 pc 0000000000023c7c /system/lib64/libipc.dylib.so(<ipc::remote::obj::RemoteObj>::send_request+268)(7006cb5520edc22f64d04df86cb90152)
    # 08 pc 000000000000b904 /system/lib64/libasset_sdk.dylib.so(<asset_sdk::Manager>::send_request+48)(4073ec22b58b83f79883d5fc8102ce77)
    # 09 pc 000000000000b600 /system/lib64/libasset_sdk.dylib.so(<asset_sdk::Manager>::query+156)(4073ec22b58b83f79883d5fc8102ce77)
    # 10 pc 0000000000006d94 /system/lib64/libasset_sdk_ffi.z.so(query_asset+116)(9a309896092ba014c878289a54688679)
    # 11 pc 0000000000006740 /system/lib64/module/security/libasset_napi.z.so((anonymous namespace)::NapiQuerySync(napi_env__*, napi_callback_info__*) (.cfi)+220)(ef7afe850712e4822f085ed0ac184e8a)
    # 12 pc 0000000000034408 /system/lib64/platformsdk/libace_napi.z.so(panda::JSValueRef ArkNativeFunctionCallBack<true>(panda::JsiRuntimeCallInfo*)+220)(f271f536a588ef9d0dc5328c70fce511)
    ```

3. warning/error 栈一致，栈顶为业务同步执行代码。

    warning/error 栈均为：

    ```text
    Tid:14727, Name:xxx
    # 00 pc 00000000001c4c60 /system/lib/ld-musl-aarch64.so.1(pread+72)(b168f10a179cf6050a309242262e6a17)
    # 01 pc 0000000000049154 /system/lib64/platformsdk/libsqlite.z.so(unixRead+180)(48485aa23da681fc87d8dc0b4be3e34c)
    # 02 pc 0000000000053e98 /system/lib64/platformsdk/libsqlite.z.so(readDbPage+116)(48485aa23da681fc87d8dc0b4be3e34c)
    # 03 pc 0000000000053d48 /system/lib64/platformsdk/libsqlite.z.so(getPageNormal+864)(48485aa23da681fc87d8dc0b4be3e34c)
    # 04 pc 00000000000757a0 /system/lib64/platformsdk/libsqlite.z.so(getAndInitPage+216)(48485aa23da681fc87d8dc0b4be3e34c)
    # 05 pc 0000000000077658 /system/lib64/platformsdk/libsqlite.z.so(moveToLeftmost+164)(48485aa23da681fc87d8dc0b4be3e34c)
    # 06 pc 000000000006aa34 /system/lib64/platformsdk/libsqlite.z.so(sqlite3VdbeExec+34532)(48485aa23da681fc87d8dc0b4be3e34c)
    # 07 pc 000000000002e424 /system/lib64/platformsdk/libsqlite.z.so(sqlite3_step+644)(48485aa23da681fc87d8dc0b4be3e34c)
    # 08 pc 00000000000b1a70 /system/lib64/platformsdk/libnative_rdb.z.so(FillSharedBlockOpt+408)(5e8443def4695e8c791e5f847035ad9f)
    # 09 pc 0000000000082a94 /system/lib64/platformsdk/libnative_rdb.z.so(OHOS::NativeRdb::SqliteStatement::FillBlockInfo(OHOS::NativeRdb::SharedBlockInfo*) const+76)(5e8443def4695e8c791e5f847035ad9f)
    # 10 pc 00000000000b4214 /system/lib64/platformsdk/libnative_rdb.z.so(OHOS::NativeRdb::SqliteSharedResultSet::ExecuteForSharedBlock(OHOS::AppDataFwk::SharedBlock*, int, int, bool)+236)(5e8443def4695e8c791e5f847035ad9f)
    ```

    结合 [trace](#结合-trace)进一步确认，排查调用的单一栈顶函数逻辑是否执行超时。

4. 瞬时栈，warning/error 栈不一致。

    warning 栈：

    ```text
    Tid:3108, Name:xxx
    # 00 pc 0000000000146e2c /system/lib/ld-musl-aarch64.so.1(open64+224)(b168f10a179cf6050a309242262e6a17)
    # 01 pc 0000000000014600 /system/lib64/chipset-pub-sdk/libextractortool.z.so(OHOS::AbilityBase::ZipFileReader::init()+600)(c4893935af8fc8cb36569be5ccdebfa9)
    # 02 pc 0000000000014144 /system/lib64/chipset-pub-sdk/libextractortool.z.so(OHOS::AbilityBase::ZipFileReader::CreateZipFileReader(std::__h::basic_string<char, std::__h::char_traits<char>, std::__h::allocator<char>> const&)+392)(c4893935af8fc8cb36569be5ccdebfa9)
    # 03 pc 000000000000f724 /system/lib64/chipset-pub-sdk/libextractortool.z.so(OHOS::AbilityBase::ZipFile::Open()+728)(c4893935af8fc8cb36569be5ccdebfa9)
    # 04 pc 000000000000a808 /system/lib64/chipset-pub-sdk/libextractortool.z.so(OHOS::AbilityBase::Extractor::Init()+124)(c4893935af8fc8cb36569be5ccdebfa9)
    # 05 pc 000000000000c4a4 /system/lib64/chipset-pub-sdk/libextractortool.z.so(OHOS::AbilityBase::ExtractorUtil::GetExtractor(std::__h::basic_string<char, std::__h::char_traits<char>, std::__h::allocator<char>> const&, bool&, bool)+596)(c4893935af8fc8cb36569be5ccdebfa9)
    # 06 pc 00000000000391e4 /system/lib64/platformsdk/libglobal_resmgr.z.so(OHOS::Global::Resource::GetIndexData(char const*, std::__h::unique_ptr<unsigned char [], std::__h::default_delete<unsigned char []>>&, unsigned long&)+284)(5c4263e737507b4a8f2ee7196a152dbd)
    # 07 pc 0000000000038590 /system/lib64/platformsdk/libglobal_resmgr.z.so(OHOS::Global::Resource::HapResource::LoadFromHap(char const*, std::__h::shared_ptr<OHOS::Global::Resource::ResConfigImpl>&, bool, bool, unsigned int const&)+80)(5c4263e737507b4a8f2ee7196a152dbd)
    # 08 pc 00000000000384e8 /system/lib64/platformsdk/libglobal_resmgr.z.so(OHOS::Global::Resource::HapResource::Load(char const*, std::__h::shared_ptr<OHOS::Global::Resource::ResConfigImpl>&, bool, bool, unsigned int const&)+364)(5c4263e737507b4a8f2ee7196a152dbd)
    # 09 pc 000000000002f118 /system/lib64/platformsdk/libglobal_resmgr.z.so(OHOS::Global::Resource::HapManager::AddResourcePath(char const*, unsigned int const&)+280)(5c4263e737507b4a8f2ee7196a152dbd)
    # 10 pc 000000000002efdc /system/lib64/platformsdk/libglobal_resmgr.z.so(OHOS::Global::Resource::HapManager::AddResource(char const*, unsigned int const&)+52)(5c4263e737507b4a8f2ee7196a152dbd)
    ```

    error 栈：

    ```text
    Tid:3108, xxx
    # 00 pc 00000000003e13cc /system/lib64/platformsdk/libark_jsruntime.so(panda::ecmascript::JSObject::GetProperty(panda::ecmascript::JSThread*, panda::ecmascript::JSHandle<panda::ecmascript::JSTaggedValue> const&, panda::ecmascript::JSHandle<panda::ecmascript::JSTaggedValue> const&, panda::ecmascript::JSShared::SCheckMode)+164)(13376099388381a01b166c00a8af99fb)
    # 01 pc 00000000003d5518 /system/lib64/platformsdk/libark_jsruntime.so(panda::ecmascript::JSIterator::IteratorStep(panda::ecmascript::JSThread*, panda::ecmascript::JSHandle<panda::ecmascript::JSTaggedValue> const&)+228)(13376099388381a01b166c00a8af99fb)
    # 02 pc 0000000000570fa8 /system/lib64/platformsdk/libark_jsruntime.so(panda::ecmascript::RuntimeStubs::StArraySpread(unsigned long, unsigned int, unsigned long)+592)(13376099388381a01b166c00a8af99fb)
    # 03 pc 00000000002d53c0 /system/lib64/module/arkcompiler/stub.an(RTStub_CallRuntime+40)
    # 04 at doTask (product/phone/build/default/cache/default/default@CompileArkTS/esmodule/release/staticcommon/launchercommon/src/main/ets/db/RdbTaskPool.ts:1:1)
    # 05 at update (product/phone/build/default/cache/default/default@CompileArkTS/esmodule/release/staticcommon/launchercommon/src/main/ets/db/RdbTaskPool.ts:1:1)
    # 06 at updateAppNameByAbilityInfoAndType (product/phone/build/default/cache/default/default@CompileArkTS/esmodule/release/staticcommon/launchercommon/src/main/ets/db/RdbStoreManager.ts:12:1)
    # 07 at anonymous (product/phone/build/default/cache/default/default@CompileArkTS/esmodule/release/staticcommon/launchercommon/src/main/ets/model/AppModel.ts:0:1)
    # 08 pc 0000000000304a94 /system/lib64/platformsdk/libark_jsruntime.so(panda::ecmascript::InterpreterAssembly::Execute(panda::ecmascript::EcmaRuntimeCallInfo*)+144)(13376099388381a01b166c00a8af99fb)
    # 09 pc 0000000000201d84 /system/lib64/platformsdk/libark_jsruntime.so(panda::ecmascript::builtins::BuiltinsPromiseJob::PromiseReactionJob(panda::ecmascript::EcmaRuntimeCallInfo*)+348)(13376099388381a01b166c00a8af99fb)
    # 10 pc 00000000002d6e14 /system/lib64/module/arkcompiler/stub.an(RTStub_AsmInterpreterEntry+208)
    ```

    此时栈是在线程的运行过程中抓的，没有规律，说明线程未appfreeze；线程繁忙场景，需结合 [trace](#结合-trace) 和 hilog 判断应用具体运行场景，针对场景进行优化。

### 查看 binder 信息

binder信息抓取时机：存在半周期检测的故障类型是在warning事件产生后获取；其他则在block事件后获取。

1. 获取binder调用链。

    ```text
    PeerBinderCatcher -- pid==35854 layer_ == 1
    BinderCatcher --
        35854:35854 to 52462:52462 code 3 wait:27.185154163 s frz_state:3          -> 35854:35854 to 52462:53462 code 3 wait:27.185154163 s
        ...
        52462:52462 to 1386:0 code 13 wait:24.733640622 s frz_state:3              -> 52462:52462 to 1386:0 code 13 wait:24.733640622 s
    ```

    以上示例为参考：从故障进程的主线程出发，存在 35854:35854 -> 52462:52462 -> 1386:0 的调用链关系，结合对端进程堆栈信息排查对端阻塞原因。

2. 线程号为0。

    表示该应用为IPC_FULL，即应用的ipc线程都在使用中，没有空闲线程分配来完成本次请求，导致阻塞，如上面示例中的1386进程，可参照其stack分析：

    ```text
    pid     context     request   started    max     ready   free_async_space

    35862    binder      0          2        16       2         519984

    35854    binder      0          2        16       3         520192

    35850    binder      0          2        16       3         520192

    13669    binder      0          1        16       3         520192

    ...

    1386     binder      1          15       16       0         517264                 -> binderInfo

    1474     binder      0          2        16       4         520192
    ```

    可以看到此时1386进程处于ready态的线程为0，验证了上述说法。此情况说明该进程的其他ipc线程可能全部被阻塞了，需要分析排查为什么其他ipc线程不释放。常见场景为：某一ipc线程持锁阻塞，导致其他线程等锁appfreeze。

    另一种情况为 free_async_space 消耗殆尽，导致新的ipc线程没有足够的 buffer 空间完成请求。值得说明的是，同步和异步请求都会消耗该值，常见场景为：某短时间段内大批量异步请求。

3. waitTime过小。

    waitTime 表示的是本次ipc通信时长，如果该值远小于故障检测时长，有理由确认本次ipc请求并不是appfreeze的根本原因。
    一种典型的场景是：应用侧主线程在短时间内多次ipc请求，总请求时长过长导致故障。

    排查方向：

    - 单次请求是否在预期时长内（例如：规格在20ms的请求接口异常情形下达到1s），排查接口性能不达预期的原因。
    - 应用测频繁调用场景是否合理。

4. 无调用关系，栈为ipc栈。

    确定是否为瞬时栈，即warning/block栈是否一致，可能场景是：warning为ipc栈，block栈为其他瞬时栈，表明抓取binder时ipc请求已经结束，本次ipc请求耗时并不长。

    需要提到的是：binder信息并不是在发生故障时刻实时获取的，有一定的延迟性；对于存在半周期检测的故障类型来说，binder抓取比较准确，绝大多数都可以在故障时间段内完成采集；而其他故障类型在上报存在延迟的情况下可能抓取到非现场binder。

    当然，结合 [trace](#结合-trace) 分析更能直观查看binder的耗时情况。

### 结合 hilog

#### DFX 相关日志

1. 故障上报（reportEvent）。

    ![appfreeze_01](figures/appfreeze_01.png)

2. 抓栈（signal: 35）。

    ![appfreeze_02](figures/appfreeze_02.png)

3. 后台应用检测（5次后上报），21s 左右。

    ![appfreeze_03](figures/appfreeze_03.png)

4. 记录查杀原因。

    ![appfreeze_04](figures/appfreeze_04.png)

5. APPFREEZE kill 应用appfreeze。

    ![appfreeze_05](figures/appfreeze_05.png)

#### 一般分析步骤

根据故障日志确定上报时间点，再根据具体场景下的故障类型推断appfreeze开始发生的时间点，查看对应时间段的hilog日志，分析日志得出应用对应线程运行状态：

- 应用日志完全无打印输出：appfreeze在最后日志打印的接口调用处。

   ![appfreeze_06](figures/appfreeze_06.png)

   ![appfreeze_07](figures/appfreeze_07.png)

   例如上图案例：APP_INPUT_BLOCK 类型在 07:24:08.167 上报，应用主线程在 07:24:01.581 后就没有打印了，可排查是否为 FormManagerService：

   [form_mgr_proxy.cpp(GetFormsInfoByApp:1128)] 中的逻辑超时。

- 应用频繁打印输出日志：分析对应输出表示的场景及其合理性。

   ![appfreeze_08](figures/appfreeze_08.png)

   例如上图案例：进程在被 APP_FREEZE 杀死前在大量输出，对应的 ImageEffect 领域需排查此日志是否正常。

### 结合 trace

存在以下可能：

1. 进程每一小段业务时间并不长，但是较长时间段运行非常密集，占满了主线程。

    ![appfreeze_09](figures/appfreeze_09.png)

    ![appfreeze_10](figures/appfreeze_10.png)

    上图案例为：PriviewArea::updateShotComponent（更新组件） -> animator （执行动画）-> 密集的动画执行过程达 9.2s；

    线程繁忙地循环执行某业务，分析每一小段业务：

    - 不符合业务场景（此处不应该频繁调用），分析业务代码，为何会循环执行；
    - 符合业务场景，分析每一小段业务是否耗时超过预期，性能为何不满足设计规格。

2. 进程执行某一函数接口超时。

    ![appfreeze_11](figures/appfreeze_11.png)

    上图案例为：OHOS::AppExecFwk::FormMgrAdapter::GetFormsInfoByApp 接口执行时长达到 8s。
