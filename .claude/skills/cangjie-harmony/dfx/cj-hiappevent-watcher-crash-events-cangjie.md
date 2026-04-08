# 订阅崩溃事件

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 接口说明

API接口的具体使用说明（参数使用限制、具体取值范围等）请参见[应用事件打点API文档](../reference/PerformanceAnalysisKit/cj-apis-hiappevent.md)。

> **说明：**
>
> 使用cangjie接口订阅崩溃事件，包含CjError和NativeCrash两种崩溃类型。

**订阅接口功能介绍：**

| 接口名 | 描述 |
| -------------- | ---------------- |
| addWatcher(watcher: Watcher): Option\<AppEventPackageHolder> | 添加应用事件观察者方法，可用于订阅应用事件。|
| removeWatcher(watcher: Watcher): Unit               | 移除应用事件观察者方法，可用于取消订阅应用事件。|

## 开发步骤

以实现对用户点击按钮触发崩溃场景生成的崩溃事件订阅为例，说明开发步骤。

1. 新建仓颉应用工程，编辑“entry > src > main > cangjie > main_bility.cj”文件，导入依赖模块：

   <!-- compile -->

   ```cangjie
   import kit.PerformanceAnalysisKit.*
   ```

2. 在“entry > src > main > cangjie > main_bility.cj”文件的onCreate函数中添加系统事件订阅，示例：

   <!-- compile -->

   ```cangjie
    let eventfilter = AppEventFilter("OS", names: ["APP_CRASH"])
    let watcher = Watcher(
        // 开发者可以自定义观察者名称，系统会使用名称来标识不同的观察者
        "watcher2",
        // 开发者可以订阅感兴趣的系统事件，此处是订阅了崩溃事件
        appEventFilters: [eventfilter],
        // 开发者可以自行实现订阅实时回调函数，以便对订阅获取到的事件数据进行自定义处理
        onReceive: {
            domain: String, appEventGroups: Array<AppEventGroup> =>
                Hilog.info(0x0000, 'testTag', "HiAppEvent onReceive: domain=${domain}")
            for (eventGroup in appEventGroups) {
                // 开发者可以根据事件集合中的事件名称区分不同的系统事件
                Hilog.info(0x0000, 'testTag', "HiAppEvent eventName=${eventGroup.name}")
                for (eventInfo in eventGroup.appEventInfos) {
                    // 开发者可以对事件集合中的事件数据进行自定义处理，此处是将事件数据打印在日志中
                    Hilog.info(0x0000, 'testTag', "HiAppEvent eventInfo.domain=${eventInfo.domain}")
                    Hilog.info(0x0000, 'testTag', "HiAppEvent eventInfo.name=${eventInfo.name}")
                    for ((k, v) in eventInfo.params) {
                        // 开发者可以获取到崩溃事件发生的相关信息
                        if (k == "hilog") {
                            Hilog.info(0x0000, 'testTag', "HiAppEvent eventInfo.params.${k}=${v}")
                        } else {
                            Hilog.info(0x0000, 'testTag', "HiAppEvent eventInfo.params.${k}=${v}")
                        }
                    }
                }
            }
        }
        )
    HiAppEvent.addWatcher(watcher)
   ```

3. 编辑“entry > src > main > cangjie > index.cj”，在onClick中构造崩溃场景以触发事件，示例代码如下：

    ```cangjie
    // 在Text点击函数中构造一个crash场景，触发应用崩溃事件
    unsafe { CPointer<UInt8>().read() }
    ```

4. 点击DevEco Studio界面中的运行按钮，运行应用工程，然后在应用界面中点击按钮“appCrash”，触发一次崩溃事件。崩溃事件发生后，系统会根据崩溃类型（CjError或NativeCrash）采用不同的栈回溯方式生成崩溃日志，然后再进行回调。其中NativeCrash栈回溯耗时约2秒，实际耗时与业务线程数量、进程间通信耗时有关。CjError触发进程内栈回溯，NativeCrash触发进程外栈回溯，因此NativeCrash栈回溯会比CjError栈回溯更耗时。用户可以订阅崩溃事件，栈回溯完成后会异步上报，不会阻塞当前业务。

5. 若应用未捕获崩溃异常，系统处理后应用退出；下次启动时，HiAppEvent会将崩溃事件上报给已注册的监听并回调。

若应用主动捕获崩溃异常，如下两种场景，HiAppEvent事件将会在应用退出前回调。

场景1：异常处理中未主动退出，应用崩溃后不退出。例如采用[errorManger.on](../reference/AbilityKit/cj-apis-app-ability-error_manager.md#static-func-onerrormanagerevent-errorobserver)捕获CjError，或主动注册NativeCrash信号处理函数但未退出。

场景2：异常处理耗时过久，应用退出时机延后。

HiAppEvent上报事件完成回调后，可以在Log窗口看到对系统事件数据的处理日志：

   ```text
   HiAppEvent onReceive: domain=OS
   HiAppEvent eventName=APP_CRASH
   HiAppEvent eventInfo.domain=OS
   HiAppEvent eventInfo.name=APP_CRASH
   HiAppEvent eventInfo.eventType.value=1
   HiAppEvent eventInfo.params.bundle_name=com.example.myapplication
   HiAppEvent eventInfo.params.bundle_version=1.0.0
   HiAppEvent eventInfo.params.crash_type=CjError
   HiAppEvent eventInfo.params.exception={"message":"none","name":"none","stack":"one"}
   HiAppEvent eventInfo.params.external_log=[/data/storage/el2/log/hiappevent/APP_CRASH_1744613860845_42711.log]
   HiAppEvent eventInfo.params.foreground=true
   HiAppEvent eventInfo.params.hilog= 10054
   HiAppEvent eventInfo.params.log_over_limit=false
   HiAppEvent eventInfo.params.pid=42711
   HiAppEvent eventInfo.params.time=1744613860665.000000
   HiAppEvent eventInfo.params.uid=20020192
   HiAppEvent eventInfo.params.uuid=4e85d04543811813ab4a2a3ed2443ebeebcca84298b89cb2460ecf99469b52de
   ```
